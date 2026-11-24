module;

#include <algorithm>
#include <cstdint>
#include <format>
#include <memory>
#include <optional>
#include <ranges>
#include <span>
#include <string>
#include <string_view>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <variant>
#include <vector>

export module libc_extract.lift;

import libc_extract.core_ops;
import libc_extract.ir;

export namespace libc_extract {

struct LiftOptions {
  bool fold_polynomials = true;   // Recognize manual Horner chains into PolyevalExpr.
  bool drop_effects = false;      // Drop setErrno / raiseExcept / clearExcept / do_not_optimize.
  bool lift_functional = true;    // Lift loop-free imperative stmts to pure let/if/match trees.
  bool unroll_small_loops = true; // Unroll constant-bound loops with <= 32 iterations.
};

/// Run all high-level lifting & cleanup passes on an extracted IR module.
void liftModule(ir::Module &mod, const LiftOptions &opts);

} // namespace libc_extract

module : private;

namespace libc_extract {
namespace {

using namespace ir;

// ============================================================================
// Structural expression helpers
// ============================================================================

auto sameVar(const ExprPtr &a, const ExprPtr &b) -> bool {
  if (!a || !b)
    return false;
  const auto *va = std::get_if<VarExpr>(&a->v);
  const auto *vb = std::get_if<VarExpr>(&b->v);
  return va && vb && va->name == vb->name;
}

auto isEffectExpr(const ExprPtr &e) -> bool {
  if (!e)
    return false;
  if (const auto *cc = std::get_if<CoreCallExpr>(&e->v)) {
    return cc->is_effect;
  }
  return false;
}

auto isFloatExpr(const ExprPtr &e) -> bool { return e && e->type && e->type->isFloat(); }

auto isNumberPairExpr(const ExprPtr &e) -> bool { return e && e->type && e->type->isNumberPair(); }

auto isPolyCoeffCandidate(const ExprPtr &e, std::string_view var_name) -> bool {
  if (!e)
    return false;
  return std::visit(
      Overloaded{
          [](const ConstExpr &) { return true; },
          [](const TableRefExpr &) { return true; },
          [var_name](const VarExpr &v) { return v.name != var_name; },
          [var_name](const IndexExpr &ix) {
            return isPolyCoeffCandidate(ix.base, var_name) &&
                   isPolyCoeffCandidate(ix.index, var_name);
          },
          [var_name](const UnaryExpr &u) { return isPolyCoeffCandidate(u.operand, var_name); },
          [var_name](const CastExpr &c) { return isPolyCoeffCandidate(c.operand, var_name); },
          [](const auto &) { return false; },
      },
      e->v);
}

struct HornerStep {
  ExprPtr var;
  ExprPtr inner;
  ExprPtr coeff;
};

auto matchMulWithVar(const ExprPtr &prod, const ExprPtr &expected_var)
    -> std::optional<std::pair<ExprPtr, ExprPtr>> {
  const auto *bm = std::get_if<BinaryExpr>(&prod->v);
  if (!bm || bm->op != BinaryOp::Mul)
    return std::nullopt;
  if (expected_var) {
    if (sameVar(bm->lhs, expected_var))
      return std::pair{bm->lhs, bm->rhs};
    if (sameVar(bm->rhs, expected_var))
      return std::pair{bm->rhs, bm->lhs};
    return std::nullopt;
  }
  if (std::holds_alternative<VarExpr>(bm->lhs->v))
    return std::pair{bm->lhs, bm->rhs};
  if (std::holds_alternative<VarExpr>(bm->rhs->v))
    return std::pair{bm->rhs, bm->lhs};
  return std::nullopt;
}

auto matchHornerStep(const ExprPtr &e, const ExprPtr &expected_var) -> std::optional<HornerStep> {
  if (!e || !isFloatExpr(e))
    return std::nullopt;

  if (const auto *cc = std::get_if<CoreCallExpr>(&e->v);
      cc && (cc->op == CoreOpKind::MultiplyAdd || cc->op == CoreOpKind::Fma) &&
      cc->args.size() == 3) {
    const auto &a = cc->args[0];
    const auto &b = cc->args[1];
    const auto &c = cc->args[2];
    ExprPtr var, inner;
    if (expected_var) {
      if (sameVar(a, expected_var)) {
        var = a;
        inner = b;
      } else if (sameVar(b, expected_var)) {
        var = b;
        inner = a;
      }
    } else {
      if (std::holds_alternative<VarExpr>(a->v)) {
        var = a;
        inner = b;
      } else if (std::holds_alternative<VarExpr>(b->v)) {
        var = b;
        inner = a;
      }
    }
    if (var) {
      auto vname = std::get<VarExpr>(var->v).name;
      if (isPolyCoeffCandidate(c, vname)) {
        return HornerStep{var, inner, c};
      }
    }
  }

  if (const auto *ba = std::get_if<BinaryExpr>(&e->v);
      ba && (ba->op == BinaryOp::Add || ba->op == BinaryOp::Sub)) {
    auto tryPair = [&](const ExprPtr &mul_side, const ExprPtr &c_side,
                       bool neg_inner) -> std::optional<HornerStep> {
      if (auto mv = matchMulWithVar(mul_side, expected_var)) {
        auto vname = std::get<VarExpr>(mv->first->v).name;
        if (isPolyCoeffCandidate(c_side, vname)) {
          auto inner = mv->second;
          if (neg_inner) {
            inner = Expr::make(UnaryExpr{UnaryOp::Neg, inner}, inner->type);
          }
          return HornerStep{mv->first, inner, c_side};
        }
      }
      return std::nullopt;
    };
    if (ba->op == BinaryOp::Add) {
      if (auto s = tryPair(ba->lhs, ba->rhs, false))
        return s;
      if (auto s = tryPair(ba->rhs, ba->lhs, false))
        return s;
    } else if (ba->op == BinaryOp::Sub) {
      if (auto s = tryPair(ba->rhs, ba->lhs, true))
        return s;
    }
  }
  return std::nullopt;
}

auto tryLiftHorner(const ExprPtr &e) -> std::optional<ExprPtr> {
  auto first = matchHornerStep(e, nullptr);
  if (!first)
    return std::nullopt;

  ExprPtr var = first->var;
  auto vname = std::get<VarExpr>(var->v).name;
  std::vector<ExprPtr> coeffs;
  coeffs.push_back(first->coeff);

  ExprPtr cur = first->inner;
  while (auto next = matchHornerStep(cur, var)) {
    coeffs.push_back(next->coeff);
    cur = next->inner;
  }

  if (const auto *pe = std::get_if<PolyevalExpr>(&cur->v);
      pe && !pe->array_arg && pe->scheme == PolyScheme::Horner && sameVar(pe->var, var)) {
    for (const auto &c : pe->coeffs)
      coeffs.push_back(c);
    if (coeffs.size() >= 3) {
      return Expr::make(PolyevalExpr{PolyScheme::Horner, var, std::move(coeffs), 0, false},
                        e->type);
    }
  }

  if (coeffs.size() >= 2 && isPolyCoeffCandidate(cur, vname)) {
    coeffs.push_back(cur);
    return Expr::make(PolyevalExpr{PolyScheme::Horner, var, std::move(coeffs), 0, false}, e->type);
  }
  return std::nullopt;
}

auto exprMentionsVar(const ExprPtr &e, std::string_view name) -> bool {
  if (!e)
    return false;
  return std::visit(
      Overloaded{
          [](const ConstExpr &) { return false; },
          [](const TableRefExpr &) { return false; },
          [](const CallJoinExpr &) { return false; },
          [](const UnsupportedExpr &) { return false; },
          [name](const VarExpr &v) { return v.name == name; },
          [name](const UnaryExpr &u) { return exprMentionsVar(u.operand, name); },
          [name](const BinaryExpr &b) {
            return exprMentionsVar(b.lhs, name) || exprMentionsVar(b.rhs, name);
          },
          [name](const CastExpr &c) { return exprMentionsVar(c.operand, name); },
          [name](const SelectExpr &s) {
            return exprMentionsVar(s.cond, name) || exprMentionsVar(s.then_e, name) ||
                   exprMentionsVar(s.else_e, name);
          },
          [name](const IndexExpr &ix) {
            return exprMentionsVar(ix.base, name) || exprMentionsVar(ix.index, name);
          },
          [name](const FieldExpr &f) { return exprMentionsVar(f.base, name); },
          [name](const StructLitExpr &sl) {
            return std::ranges::any_of(
                sl.fields, [name](const auto &kv) { return exprMentionsVar(kv.second, name); });
          },
          [name](const StructUpdateExpr &su) {
            return exprMentionsVar(su.base, name) || exprMentionsVar(su.value, name);
          },
          [name](const CoreCallExpr &cc) {
            return std::ranges::any_of(cc.args,
                                       [name](const auto &a) { return exprMentionsVar(a, name); });
          },
          [name](const PolyevalExpr &pe) {
            return exprMentionsVar(pe.var, name) ||
                   std::ranges::any_of(pe.coeffs,
                                       [name](const auto &c) { return exprMentionsVar(c, name); });
          },
          [name](const FuncCallExpr &fc) {
            return std::ranges::any_of(fc.args,
                                       [name](const auto &a) { return exprMentionsVar(a, name); });
          },
          [name](const LetExpr &le) {
            return exprMentionsVar(le.value, name) ||
                   (le.name != name && exprMentionsVar(le.body, name));
          },
          [name](const LetJoinExpr &lj) {
            return exprMentionsVar(lj.join_body, name) || exprMentionsVar(lj.body, name);
          },
          [name](const LetTupleExpr &lt) {
            if (exprMentionsVar(lt.value, name))
              return true;
            bool shadowed = std::ranges::any_of(
                lt.bindings, [name](const auto &kv) { return kv.first == name; });
            return !shadowed && exprMentionsVar(lt.body, name);
          },
          [name](const TupleExpr &te) {
            return std::ranges::any_of(
                te.elems, [name](const auto &el) { return exprMentionsVar(el, name); });
          },
          [name](const IfExpr &ie) {
            return exprMentionsVar(ie.cond, name) || exprMentionsVar(ie.then_e, name) ||
                   exprMentionsVar(ie.else_e, name);
          },
          [name](const MatchExpr &me) {
            return exprMentionsVar(me.scrutinee, name) || exprMentionsVar(me.default_arm, name) ||
                   std::ranges::any_of(me.arms, [name](const MatchArm &arm) {
                     return exprMentionsVar(arm.body, name);
                   });
          },
      },
      e->v);
}

// ============================================================================
// Constant-bound loop unrolling (e.g. `for (int i = 4; i >= 0; --i)`)
// ============================================================================

auto substVarInExpr(const ExprPtr &e, std::string_view var, const ExprPtr &replacement) -> ExprPtr {
  if (!e)
    return nullptr;
  if (const auto *v = std::get_if<VarExpr>(&e->v); v && v->name == var) {
    return replacement;
  }
  auto rec = [&](const ExprPtr &sub) { return substVarInExpr(sub, var, replacement); };
  auto copy = std::make_shared<Expr>(*e);
  std::visit(Overloaded{
                 [](ConstExpr &) {},
                 [](VarExpr &) {},
                 [](TableRefExpr &) {},
                 [](CallJoinExpr &) {},
                 [](UnsupportedExpr &) {},
                 [&](UnaryExpr &u) { u.operand = rec(u.operand); },
                 [&](BinaryExpr &b) {
                   b.lhs = rec(b.lhs);
                   b.rhs = rec(b.rhs);
                 },
                 [&](CastExpr &c) { c.operand = rec(c.operand); },
                 [&](SelectExpr &s) {
                   s.cond = rec(s.cond);
                   s.then_e = rec(s.then_e);
                   s.else_e = rec(s.else_e);
                 },
                 [&](IndexExpr &ix) {
                   ix.base = rec(ix.base);
                   ix.index = rec(ix.index);
                 },
                 [&](FieldExpr &f) { f.base = rec(f.base); },
                 [&](StructLitExpr &sl) {
                   for (auto &[_, fe] : sl.fields)
                     fe = rec(fe);
                 },
                 [&](StructUpdateExpr &su) {
                   su.base = rec(su.base);
                   su.value = rec(su.value);
                 },
                 [&](CoreCallExpr &cc) {
                   for (auto &a : cc.args)
                     a = rec(a);
                 },
                 [&](PolyevalExpr &pe) {
                   pe.var = rec(pe.var);
                   for (auto &c : pe.coeffs)
                     c = rec(c);
                 },
                 [&](FuncCallExpr &fc) {
                   for (auto &a : fc.args)
                     a = rec(a);
                 },
                 [&](LetExpr &le) {
                   le.value = rec(le.value);
                   if (le.name != var)
                     le.body = rec(le.body);
                 },
                 [&](LetJoinExpr &lj) {
                   lj.join_body = rec(lj.join_body);
                   lj.body = rec(lj.body);
                 },
                 [&](LetTupleExpr &lt) {
                   lt.value = rec(lt.value);
                   bool shadowed = std::ranges::any_of(
                       lt.bindings, [var](const auto &kv) { return kv.first == var; });
                   if (!shadowed)
                     lt.body = rec(lt.body);
                 },
                 [&](TupleExpr &te) {
                   for (auto &el : te.elems)
                     el = rec(el);
                 },
                 [&](IfExpr &ie) {
                   ie.cond = rec(ie.cond);
                   ie.then_e = rec(ie.then_e);
                   ie.else_e = rec(ie.else_e);
                 },
                 [&](MatchExpr &me) {
                   me.scrutinee = rec(me.scrutinee);
                   for (auto &arm : me.arms)
                     arm.body = rec(arm.body);
                   me.default_arm = rec(me.default_arm);
                 },
             },
             copy->v);
  return copy;
}

auto substVarInStmts(std::span<const Stmt> stmts, std::string_view var, const ExprPtr &replacement)
    -> std::vector<Stmt> {
  std::vector<Stmt> out;
  out.reserve(stmts.size());
  auto recE = [&](const ExprPtr &e) { return substVarInExpr(e, var, replacement); };
  for (const auto &s : stmts) {
    Stmt c = s;
    std::visit(Overloaded{
                   [&](VarDeclStmt &v) {
                     if (v.init)
                       v.init = recE(*v.init);
                   },
                   [&](TupleDeclStmt &td) { td.init = recE(td.init); },
                   [&](AssignStmt &a) { a.value = recE(a.value); },
                   [&](FieldAssignStmt &fa) {
                     fa.base = recE(fa.base);
                     fa.value = recE(fa.value);
                   },
                   [&](ExprStmt &es) { es.expr = recE(es.expr); },
                   [&](IfStmt &i) {
                     i.cond = recE(i.cond);
                     i.then_body = substVarInStmts(i.then_body, var, replacement);
                     i.else_body = substVarInStmts(i.else_body, var, replacement);
                   },
                   [&](SwitchStmt &sw) {
                     sw.scrutinee = recE(sw.scrutinee);
                     for (auto &cs : sw.cases)
                       cs.body = substVarInStmts(cs.body, var, replacement);
                     sw.default_body = substVarInStmts(sw.default_body, var, replacement);
                   },
                   [&](WhileStmt &w) {
                     w.cond = recE(w.cond);
                     w.body = substVarInStmts(w.body, var, replacement);
                   },
                   [&](ForStmt &f) {
                     if (f.cond)
                       f.cond = recE(*f.cond);
                     f.body = substVarInStmts(f.body, var, replacement);
                   },
                   [&](ReturnStmt &r) {
                     if (r.value)
                       r.value = recE(*r.value);
                   },
                   [&](BlockStmt &b) { b.stmts = substVarInStmts(b.stmts, var, replacement); },
                   [](auto &) {},
               },
               c.v);
    out.push_back(std::move(c));
  }
  return out;
}

auto hasBreakOrContinue(std::span<const Stmt> stmts) -> bool {
  return std::ranges::any_of(stmts, [](const Stmt &s) {
    return std::visit(Overloaded{
                          [](const BreakStmt &) { return true; },
                          [](const ContinueStmt &) { return true; },
                          [](const IfStmt &i) {
                            return hasBreakOrContinue(i.then_body) ||
                                   hasBreakOrContinue(i.else_body);
                          },
                          [](const BlockStmt &b) { return hasBreakOrContinue(b.stmts); },
                          [](const auto &) { return false; },
                      },
                      s.v);
  });
}

auto extractConstInt(const ExprPtr &e) -> std::optional<std::int64_t> {
  if (!e)
    return std::nullopt;
  if (const auto *ce = std::get_if<ConstExpr>(&e->v)) {
    if (const auto *ic = std::get_if<IntConst>(&ce->value.v); ic && ic->fits_i64) {
      return ic->signed_val;
    }
  }
  if (const auto *c = std::get_if<CastExpr>(&e->v); c && c->kind == CastKind::IntToInt) {
    return extractConstInt(c->operand);
  }
  return std::nullopt;
}

/// Unroll simple constant-bound loops (<= 32 iterations) such as
/// `for (int i = 4; i >= 0; --i)` or `for (int i = 0; i < 8; ++i)`.
auto tryUnrollForStmt(const ForStmt &f) -> std::optional<std::vector<Stmt>> {
  if (!f.init || !*f.init || !f.cond || !f.step || !*f.step)
    return std::nullopt;
  if (hasBreakOrContinue(f.body))
    return std::nullopt;

  const auto *init_vd = std::get_if<VarDeclStmt>(&(*f.init)->v);
  if (!init_vd || !init_vd->init || !init_vd->type || !init_vd->type->isInt())
    return std::nullopt;
  auto start_opt = extractConstInt(*init_vd->init);
  if (!start_opt)
    return std::nullopt;
  const std::string &ivar = init_vd->name;
  const auto &itype = std::get<IntType>(init_vd->type->v);

  const auto *step_asgn = std::get_if<AssignStmt>(&(*f.step)->v);
  if (!step_asgn || step_asgn->target != ivar || !step_asgn->compound_op)
    return std::nullopt;
  auto step_mag = extractConstInt(step_asgn->value);
  if (!step_mag || *step_mag <= 0)
    return std::nullopt;
  std::int64_t delta = 0;
  if (*step_asgn->compound_op == BinaryOp::Add)
    delta = *step_mag;
  else if (*step_asgn->compound_op == BinaryOp::Sub)
    delta = -*step_mag;
  else
    return std::nullopt;

  const auto *cond_bo = std::get_if<BinaryExpr>(&(*f.cond)->v);
  if (!cond_bo)
    return std::nullopt;
  const auto *lhs_v = std::get_if<VarExpr>(&cond_bo->lhs->v);
  if (!lhs_v || lhs_v->name != ivar)
    return std::nullopt;
  auto bound_opt = extractConstInt(cond_bo->rhs);
  if (!bound_opt)
    return std::nullopt;

  auto condHolds = [&](std::int64_t cur) -> bool {
    switch (cond_bo->op) {
    case BinaryOp::Lt:
      return cur < *bound_opt;
    case BinaryOp::Le:
      return cur <= *bound_opt;
    case BinaryOp::Gt:
      return cur > *bound_opt;
    case BinaryOp::Ge:
      return cur >= *bound_opt;
    case BinaryOp::Ne:
      return cur != *bound_opt;
    default:
      return false;
    }
  };

  std::vector<Stmt> unrolled;
  std::int64_t cur = *start_opt;
  int trips = 0;
  while (condHolds(cur)) {
    if (++trips > 32)
      return std::nullopt;
    std::string hex = std::format("{:X}", static_cast<std::uint64_t>(cur));
    auto iconst = Expr::make(
        ConstExpr{ConstVal{IntConst{itype.width, itype.is_signed, std::move(hex), cur, true}}},
        init_vd->type);
    auto iter_stmts = substVarInStmts(f.body, ivar, iconst);
    for (auto &st : iter_stmts)
      unrolled.push_back(std::move(st));
    cur += delta;
  }
  return unrolled;
}

// ============================================================================
// Pass 1: Expression simplification & polynomial recognition
// ============================================================================

auto simplifyExpr(ExprPtr e, const LiftOptions &opts) -> ExprPtr {
  if (!e)
    return nullptr;

  auto recurse = [&](ExprPtr sub) { return simplifyExpr(std::move(sub), opts); };

  std::visit(Overloaded{
                 [](ConstExpr &) {},
                 [](VarExpr &) {},
                 [](TableRefExpr &) {},
                 [](CallJoinExpr &) {},
                 [](UnsupportedExpr &) {},
                 [&](UnaryExpr &u) { u.operand = recurse(std::move(u.operand)); },
                 [&](BinaryExpr &b) {
                   b.lhs = recurse(std::move(b.lhs));
                   b.rhs = recurse(std::move(b.rhs));
                 },
                 [&](CastExpr &c) { c.operand = recurse(std::move(c.operand)); },
                 [&](SelectExpr &s) {
                   s.cond = recurse(std::move(s.cond));
                   s.then_e = recurse(std::move(s.then_e));
                   s.else_e = recurse(std::move(s.else_e));
                 },
                 [&](IndexExpr &ix) {
                   ix.base = recurse(std::move(ix.base));
                   ix.index = recurse(std::move(ix.index));
                 },
                 [&](FieldExpr &f) { f.base = recurse(std::move(f.base)); },
                 [&](StructLitExpr &sl) {
                   for (auto &[_, fe] : sl.fields)
                     fe = recurse(std::move(fe));
                 },
                 [&](StructUpdateExpr &su) {
                   su.base = recurse(std::move(su.base));
                   su.value = recurse(std::move(su.value));
                 },
                 [&](CoreCallExpr &cc) {
                   for (auto &a : cc.args)
                     a = recurse(std::move(a));
                 },
                 [&](PolyevalExpr &pe) {
                   pe.var = recurse(std::move(pe.var));
                   for (auto &c : pe.coeffs)
                     c = recurse(std::move(c));
                 },
                 [&](FuncCallExpr &fc) {
                   for (auto &a : fc.args)
                     a = recurse(std::move(a));
                 },
                 [&](LetExpr &le) {
                   le.value = recurse(std::move(le.value));
                   le.body = recurse(std::move(le.body));
                 },
                 [&](LetJoinExpr &lj) {
                   lj.join_body = recurse(std::move(lj.join_body));
                   lj.body = recurse(std::move(lj.body));
                 },
                 [&](LetTupleExpr &lt) {
                   lt.value = recurse(std::move(lt.value));
                   lt.body = recurse(std::move(lt.body));
                 },
                 [&](TupleExpr &te) {
                   for (auto &el : te.elems)
                     el = recurse(std::move(el));
                 },
                 [&](IfExpr &ie) {
                   ie.cond = recurse(std::move(ie.cond));
                   ie.then_e = recurse(std::move(ie.then_e));
                   ie.else_e = recurse(std::move(ie.else_e));
                 },
                 [&](MatchExpr &me) {
                   me.scrutinee = recurse(std::move(me.scrutinee));
                   for (auto &arm : me.arms)
                     arm.body = recurse(std::move(arm.body));
                   me.default_arm = recurse(std::move(me.default_arm));
                 },
             },
             e->v);

  // Constant boolean folding on `IfExpr` and `SelectExpr`.
  if (auto *ie = std::get_if<IfExpr>(&e->v); ie && ie->cond) {
    if (const auto *ce = std::get_if<ConstExpr>(&ie->cond->v)) {
      if (const auto *bc = std::get_if<BoolConst>(&ce->value.v)) {
        return bc->value ? ie->then_e : ie->else_e;
      }
    }
  }
  if (auto *se = std::get_if<SelectExpr>(&e->v); se && se->cond) {
    if (const auto *ce = std::get_if<ConstExpr>(&se->cond->v)) {
      if (const auto *bc = std::get_if<BoolConst>(&ce->value.v)) {
        return bc->value ? se->then_e : se->else_e;
      }
    }
  }

  // Rewrite `Cast(NoOp, x)` -> `x`.
  if (auto *c = std::get_if<CastExpr>(&e->v); c && c->kind == CastKind::NoOp) {
    return c->operand;
  }

  // Rewrite `Cast(ToBool, x)` when `x` is already Bool or a Bool->Int promotion.
  if (auto *c = std::get_if<CastExpr>(&e->v); c && c->kind == CastKind::ToBool && c->operand) {
    if (c->operand->type && c->operand->type->isBool()) {
      return c->operand;
    }
    if (auto *inner = std::get_if<CastExpr>(&c->operand->v);
        inner && (inner->kind == CastKind::IntToInt || inner->kind == CastKind::BoolToInt) &&
        inner->operand && inner->operand->type && inner->operand->type->isBool()) {
      return inner->operand;
    }
  }

  // Rewrite `let x := v; x` -> `v`, and eliminate dead pure constant/var lets.
  if (auto *le = std::get_if<LetExpr>(&e->v)) {
    if (const auto *vr = std::get_if<VarExpr>(&le->body->v); vr && vr->name == le->name) {
      return le->value;
    }
    if (le->name != "_" && !isEffectExpr(le->value) && !exprMentionsVar(le->body, le->name)) {
      if (std::holds_alternative<ConstExpr>(le->value->v) ||
          std::holds_alternative<VarExpr>(le->value->v)) {
        return le->body;
      }
    }
  }

  // Rewrite `Core.FPBits.getVal (Core.FPBits.ofVal x)` -> `x`.
  if (auto *cc = std::get_if<CoreCallExpr>(&e->v);
      cc && cc->op == CoreOpKind::FPBitsGetVal && cc->args.size() == 1) {
    if (auto *inner = std::get_if<CoreCallExpr>(&cc->args[0]->v);
        inner && inner->op == CoreOpKind::FPBitsOfVal && inner->args.size() == 1 &&
        isFloatExpr(inner->args[0])) {
      return inner->args[0];
    }
  }

  // Rewrite `!true` / `!false` and `!!x`.
  if (auto *u1 = std::get_if<UnaryExpr>(&e->v); u1 && u1->op == UnaryOp::LogNot) {
    if (const auto *ce = std::get_if<ConstExpr>(&u1->operand->v)) {
      if (const auto *bc = std::get_if<BoolConst>(&ce->value.v)) {
        return Expr::make(ConstExpr{ConstVal{BoolConst{!bc->value}}}, Type::makeBool());
      }
    }
    if (auto *u2 = std::get_if<UnaryExpr>(&u1->operand->v); u2 && u2->op == UnaryOp::LogNot) {
      return u2->operand;
    }
  }

  // Lift manual Horner chains into `PolyevalExpr`.
  if (opts.fold_polynomials) {
    if (auto poly = tryLiftHorner(e)) {
      return *poly;
    }
  }

  return e;
}

void simplifyStmts(std::vector<Stmt> &stmts, const LiftOptions &opts) {
  std::vector<Stmt> cleaned;
  cleaned.reserve(stmts.size());

  for (auto &st : stmts) {
    bool keep = true;
    std::optional<std::vector<Stmt>> splice;

    std::visit(Overloaded{
                   [&](VarDeclStmt &v) {
                     if (v.init)
                       v.init = simplifyExpr(std::move(*v.init), opts);
                   },
                   [&](TupleDeclStmt &td) { td.init = simplifyExpr(std::move(td.init), opts); },
                   [&](AssignStmt &a) { a.value = simplifyExpr(std::move(a.value), opts); },
                   [&](FieldAssignStmt &fa) {
                     fa.base = simplifyExpr(std::move(fa.base), opts);
                     fa.value = simplifyExpr(std::move(fa.value), opts);
                   },
                   [&](ExprStmt &es) {
                     es.expr = simplifyExpr(std::move(es.expr), opts);
                     if (opts.drop_effects && isEffectExpr(es.expr)) {
                       keep = false;
                     }
                   },
                   [&](IfStmt &ifs) {
                     ifs.cond = simplifyExpr(std::move(ifs.cond), opts);
                     simplifyStmts(ifs.then_body, opts);
                     simplifyStmts(ifs.else_body, opts);
                     if (const auto *ce = std::get_if<ConstExpr>(&ifs.cond->v)) {
                       if (const auto *bc = std::get_if<BoolConst>(&ce->value.v)) {
                         splice = bc->value ? std::move(ifs.then_body) : std::move(ifs.else_body);
                         keep = false;
                         return;
                       }
                     }
                     if (ifs.then_body.empty() && ifs.else_body.empty())
                       keep = false;
                   },
                   [&](SwitchStmt &sw) {
                     sw.scrutinee = simplifyExpr(std::move(sw.scrutinee), opts);
                     for (auto &c : sw.cases)
                       simplifyStmts(c.body, opts);
                     simplifyStmts(sw.default_body, opts);
                   },
                   [&](WhileStmt &w) {
                     w.cond = simplifyExpr(std::move(w.cond), opts);
                     simplifyStmts(w.body, opts);
                   },
                   [&](ForStmt &f) {
                     if (f.init && *f.init) {
                       std::vector<Stmt> tmp{std::move(**f.init)};
                       simplifyStmts(tmp, opts);
                       if (!tmp.empty())
                         f.init = std::make_shared<Stmt>(std::move(tmp[0]));
                       else
                         f.init.reset();
                     }
                     if (f.cond)
                       f.cond = simplifyExpr(std::move(*f.cond), opts);
                     if (f.step && *f.step) {
                       std::vector<Stmt> tmp{std::move(**f.step)};
                       simplifyStmts(tmp, opts);
                       if (!tmp.empty())
                         f.step = std::make_shared<Stmt>(std::move(tmp[0]));
                       else
                         f.step.reset();
                     }
                     simplifyStmts(f.body, opts);
                     if (opts.unroll_small_loops) {
                       if (auto unrolled = tryUnrollForStmt(f)) {
                         simplifyStmts(*unrolled, opts);
                         splice = std::move(*unrolled);
                         keep = false;
                       }
                     }
                   },
                   [&](ReturnStmt &r) {
                     if (r.value)
                       r.value = simplifyExpr(std::move(*r.value), opts);
                   },
                   [&](BlockStmt &b) {
                     simplifyStmts(b.stmts, opts);
                     if (b.stmts.empty())
                       keep = false;
                   },
                   [](BreakStmt &) {},
                   [](ContinueStmt &) {},
                   [](UnsupportedStmt &) {},
               },
               st.v);

    if (splice) {
      for (auto &s : *splice)
        cleaned.push_back(std::move(s));
    } else if (keep) {
      cleaned.push_back(std::move(st));
    }
  }
  stmts = std::move(cleaned);
}

// ============================================================================
// Pass 2: Imperative -> Functional expression-tree lifting
// ============================================================================

auto containsUnliftableConstruct(std::span<const Stmt> stmts) -> bool {
  return std::ranges::any_of(stmts, [](const Stmt &s) {
    return std::visit(Overloaded{
                          [](const WhileStmt &) { return true; },
                          [](const ForStmt &) { return true; },
                          [](const FieldAssignStmt &fa) {
                            return !fa.base || !std::holds_alternative<VarExpr>(fa.base->v);
                          },
                          [](const BreakStmt &) { return true; },
                          [](const ContinueStmt &) { return true; },
                          [](const IfStmt &i) {
                            return containsUnliftableConstruct(i.then_body) ||
                                   containsUnliftableConstruct(i.else_body);
                          },
                          [](const SwitchStmt &sw) {
                            return std::ranges::any_of(sw.cases,
                                                       [](const SwitchCase &c) {
                                                         return containsUnliftableConstruct(c.body);
                                                       }) ||
                                   containsUnliftableConstruct(sw.default_body);
                          },
                          [](const BlockStmt &b) { return containsUnliftableConstruct(b.stmts); },
                          [](const auto &) { return false; },
                      },
                      s.v);
  });
}

auto alwaysReturns(std::span<const Stmt> stmts) -> bool {
  for (const Stmt &s : stmts) {
    bool ret = std::visit(Overloaded{
                              [](const ReturnStmt &) { return true; },
                              [](const IfStmt &i) {
                                return !i.else_body.empty() && alwaysReturns(i.then_body) &&
                                       alwaysReturns(i.else_body);
                              },
                              [](const SwitchStmt &sw) {
                                return !sw.default_body.empty() && alwaysReturns(sw.default_body) &&
                                       std::ranges::all_of(sw.cases, [](const SwitchCase &c) {
                                         return alwaysReturns(c.body);
                                       });
                              },
                              [](const BlockStmt &b) { return alwaysReturns(b.stmts); },
                              [](const auto &) { return false; },
                          },
                          s.v);
    if (ret)
      return true;
  }
  return false;
}

auto mayReturn(std::span<const Stmt> stmts) -> bool {
  return std::ranges::any_of(stmts, [](const Stmt &s) {
    return std::visit(
        Overloaded{
            [](const ReturnStmt &) { return true; },
            [](const IfStmt &i) { return mayReturn(i.then_body) || mayReturn(i.else_body); },
            [](const SwitchStmt &sw) {
              return mayReturn(sw.default_body) ||
                     std::ranges::any_of(sw.cases,
                                         [](const SwitchCase &c) { return mayReturn(c.body); });
            },
            [](const BlockStmt &b) { return mayReturn(b.stmts); },
            [](const auto &) { return false; },
        },
        s.v);
  });
}

void collectMutatedOuterVars(std::span<const Stmt> stmts,
                             const std::unordered_set<std::string> &outer_scope,
                             std::vector<std::string> &order,
                             std::unordered_set<std::string> &seen) {
  std::unordered_set<std::string> local_shadow;
  for (const Stmt &s : stmts) {
    std::visit(
        Overloaded{
            [&](const VarDeclStmt &v) { local_shadow.insert(v.name); },
            [&](const TupleDeclStmt &td) {
              for (const auto &[n, _] : td.bindings)
                local_shadow.insert(n);
            },
            [&](const AssignStmt &a) {
              if (!local_shadow.contains(a.target) && outer_scope.contains(a.target) &&
                  !seen.contains(a.target)) {
                seen.insert(a.target);
                order.push_back(a.target);
              }
            },
            [&](const FieldAssignStmt &fa) {
              if (fa.base) {
                if (const auto *v = std::get_if<VarExpr>(&fa.base->v)) {
                  if (!local_shadow.contains(v->name) && outer_scope.contains(v->name) &&
                      !seen.contains(v->name)) {
                    seen.insert(v->name);
                    order.push_back(v->name);
                  }
                }
              }
            },
            [&](const IfStmt &i) {
              collectMutatedOuterVars(i.then_body, outer_scope, order, seen);
              collectMutatedOuterVars(i.else_body, outer_scope, order, seen);
            },
            [&](const SwitchStmt &sw) {
              for (const auto &c : sw.cases) {
                collectMutatedOuterVars(c.body, outer_scope, order, seen);
              }
              collectMutatedOuterVars(sw.default_body, outer_scope, order, seen);
            },
            [&](const BlockStmt &b) { collectMutatedOuterVars(b.stmts, outer_scope, order, seen); },
            [](const auto &) {},
        },
        s.v);
  }
}

class FunctionalLifter {
public:
  FunctionalLifter(TypePtr ret_type, const std::vector<Param> &params)
      : ret_type_(std::move(ret_type)) {
    for (const auto &p : params) {
      var_types_[p.name] = p.type;
    }
  }

  auto lift(std::span<const Stmt> stmts, std::unordered_set<std::string> scope, ExprPtr fallthrough)
      -> std::optional<ExprPtr> {
    if (stmts.empty()) {
      return fallthrough ? std::optional{fallthrough} : std::nullopt;
    }

    const Stmt &head = stmts.front();
    auto tail = stmts.subspan(1);

    return std::visit(
        Overloaded{
            [&](const ReturnStmt &r) -> std::optional<ExprPtr> {
              if (r.value)
                return *r.value;
              return Expr::make(ConstExpr{ConstVal{BoolConst{false}}}, Type::makeVoid());
            },
            [&](const VarDeclStmt &v) -> std::optional<ExprPtr> {
              var_types_[v.name] = v.type;
              scope.insert(v.name);
              auto body = lift(tail, scope, fallthrough);
              if (!body)
                return std::nullopt;
              auto body_ty = (*body)->type;
              ExprPtr init =
                  v.init.value_or(Expr::make(UnsupportedExpr{"uninitialized " + v.name}, v.type));
              return Expr::make(LetExpr{v.name, v.type, std::move(init), std::move(*body)},
                                std::move(body_ty));
            },
            [&](const TupleDeclStmt &td) -> std::optional<ExprPtr> {
              for (const auto &[n, t] : td.bindings) {
                var_types_[n] = t;
                scope.insert(n);
              }
              auto body = lift(tail, scope, fallthrough);
              if (!body)
                return std::nullopt;
              auto body_ty = (*body)->type;
              return Expr::make(LetTupleExpr{td.bindings, td.init, std::move(*body)},
                                std::move(body_ty));
            },
            [&](const AssignStmt &a) -> std::optional<ExprPtr> {
              auto vty = lookupType(a.target, a.value->type);
              ExprPtr rhs = a.value;
              if (a.compound_op) {
                auto lhs = Expr::make(VarExpr{a.target}, vty);
                rhs = Expr::make(BinaryExpr{*a.compound_op, std::move(lhs), std::move(rhs)}, vty);
              }
              auto body = lift(tail, scope, fallthrough);
              if (!body)
                return std::nullopt;
              auto body_ty = (*body)->type;
              return Expr::make(LetExpr{a.target, vty, std::move(rhs), std::move(*body)},
                                std::move(body_ty));
            },
            [&](const FieldAssignStmt &fa) -> std::optional<ExprPtr> {
              const auto *vr = fa.base ? std::get_if<VarExpr>(&fa.base->v) : nullptr;
              if (!vr)
                return std::nullopt;
              auto vty = lookupType(vr->name, fa.base->type);
              ExprPtr new_field_val = fa.value;
              if (fa.compound_op) {
                auto cur_field = Expr::make(FieldExpr{fa.base, fa.field}, fa.value->type);
                new_field_val = Expr::make(
                    BinaryExpr{*fa.compound_op, std::move(cur_field), std::move(new_field_val)},
                    fa.value->type);
              }
              auto upd =
                  Expr::make(StructUpdateExpr{fa.base, fa.field, std::move(new_field_val)}, vty);
              auto body = lift(tail, scope, fallthrough);
              if (!body)
                return std::nullopt;
              auto body_ty = (*body)->type;
              return Expr::make(LetExpr{vr->name, std::move(vty), std::move(upd), std::move(*body)},
                                std::move(body_ty));
            },
            [&](const ExprStmt &es) -> std::optional<ExprPtr> {
              auto body = lift(tail, scope, fallthrough);
              if (!body)
                return std::nullopt;
              auto body_ty = (*body)->type;
              return Expr::make(LetExpr{"_", es.expr->type, es.expr, std::move(*body)},
                                std::move(body_ty));
            },
            [&](const BlockStmt &b) -> std::optional<ExprPtr> {
              std::vector<Stmt> combined;
              combined.reserve(b.stmts.size() + tail.size());
              combined.insert(combined.end(), b.stmts.begin(), b.stmts.end());
              combined.insert(combined.end(), tail.begin(), tail.end());
              return lift(combined, std::move(scope), std::move(fallthrough));
            },
            [&](const IfStmt &ifs) -> std::optional<ExprPtr> {
              return liftIf(ifs, tail, scope, fallthrough);
            },
            [&](const SwitchStmt &sw) -> std::optional<ExprPtr> {
              return liftSwitch(sw, tail, scope, fallthrough);
            },
            [&](const UnsupportedStmt &u) -> std::optional<ExprPtr> {
              auto body = lift(tail, scope, fallthrough);
              if (!body)
                return std::nullopt;
              auto body_ty = (*body)->type;
              auto ue = Expr::make(UnsupportedExpr{u.reason}, Type::makeVoid());
              return Expr::make(LetExpr{"_", Type::makeVoid(), std::move(ue), std::move(*body)},
                                std::move(body_ty));
            },
            [](const auto &) -> std::optional<ExprPtr> { return std::nullopt; },
        },
        head.v);
  }

private:
  auto lookupType(const std::string &name, const TypePtr &fallback) -> TypePtr {
    if (auto it = var_types_.find(name); it != var_types_.end())
      return it->second;
    return fallback ? fallback : Type::makeOpaque("T");
  }

  auto makeVarsExpr(const std::vector<std::string> &vars) -> ExprPtr {
    if (vars.size() == 1) {
      return Expr::make(VarExpr{vars[0]}, lookupType(vars[0], nullptr));
    }
    std::vector<ExprPtr> elems;
    elems.reserve(vars.size());
    for (const auto &v : vars) {
      elems.push_back(Expr::make(VarExpr{v}, lookupType(v, nullptr)));
    }
    return Expr::make(TupleExpr{std::move(elems)}, Type::makeOpaque("Tuple"));
  }

  auto liftIf(const IfStmt &ifs, std::span<const Stmt> tail,
              const std::unordered_set<std::string> &scope, ExprPtr fallthrough)
      -> std::optional<ExprPtr> {
    bool then_ret = alwaysReturns(ifs.then_body);
    bool else_ret = !ifs.else_body.empty() && alwaysReturns(ifs.else_body);

    if (then_ret && else_ret) {
      auto t = lift(ifs.then_body, scope, nullptr);
      auto e = lift(ifs.else_body, scope, nullptr);
      if (!t || !e)
        return std::nullopt;
      auto res_ty = (*t)->type;
      return Expr::make(IfExpr{ifs.cond, std::move(*t), std::move(*e)}, std::move(res_ty));
    }

    if (then_ret && ifs.else_body.empty()) {
      auto t = lift(ifs.then_body, scope, nullptr);
      auto e = lift(tail, scope, fallthrough);
      if (!t || !e)
        return std::nullopt;
      auto res_ty = (*t)->type;
      return Expr::make(IfExpr{ifs.cond, std::move(*t), std::move(*e)}, std::move(res_ty));
    }

    if (!mayReturn(ifs.then_body) && !mayReturn(ifs.else_body)) {
      std::vector<std::string> mutated;
      std::unordered_set<std::string> seen;
      collectMutatedOuterVars(ifs.then_body, scope, mutated, seen);
      collectMutatedOuterVars(ifs.else_body, scope, mutated, seen);

      auto cont = lift(tail, scope, fallthrough);
      if (!cont)
        return std::nullopt;
      auto cont_ty = (*cont)->type;

      if (mutated.empty()) {
        auto unit = Expr::make(ConstExpr{ConstVal{BoolConst{true}}}, Type::makeVoid());
        auto t = lift(ifs.then_body, scope, unit);
        auto e = lift(ifs.else_body, scope, unit);
        if (!t || !e)
          return std::nullopt;
        auto branch = Expr::make(IfExpr{ifs.cond, std::move(*t), std::move(*e)}, Type::makeVoid());
        return Expr::make(LetExpr{"_", Type::makeVoid(), std::move(branch), std::move(*cont)},
                          std::move(cont_ty));
      }

      auto target_expr = makeVarsExpr(mutated);
      auto t = lift(ifs.then_body, scope, target_expr);
      auto e = lift(ifs.else_body, scope, target_expr);
      if (!t || !e)
        return std::nullopt;
      auto branch = Expr::make(IfExpr{ifs.cond, std::move(*t), std::move(*e)}, target_expr->type);

      if (mutated.size() == 1) {
        return Expr::make(LetExpr{mutated[0], lookupType(mutated[0], nullptr), std::move(branch),
                                  std::move(*cont)},
                          std::move(cont_ty));
      }
      std::vector<std::pair<std::string, TypePtr>> binds;
      binds.reserve(mutated.size());
      for (const auto &v : mutated)
        binds.emplace_back(v, lookupType(v, nullptr));
      return Expr::make(LetTupleExpr{std::move(binds), std::move(branch), std::move(*cont)},
                        std::move(cont_ty));
    }

    if (!then_ret && !else_ret && !tail.empty()) {
      std::vector<std::string> mutated;
      std::unordered_set<std::string> seen;
      collectMutatedOuterVars(ifs.then_body, scope, mutated, seen);
      collectMutatedOuterVars(ifs.else_body, scope, mutated, seen);
      if (mutated.empty() && tail.size() > 1) {
        auto join_e = lift(tail, scope, fallthrough);
        if (!join_e)
          return std::nullopt;
        auto join_ty = (*join_e)->type;
        auto jname = join_counter_ == 0 ? std::string("cont")
                                        : std::string("cont") + std::to_string(join_counter_);
        ++join_counter_;
        auto call_join = Expr::make(CallJoinExpr{jname}, join_ty);
        auto t = lift(ifs.then_body, scope, call_join);
        auto e = lift(ifs.else_body, scope, call_join);
        if (!t || !e)
          return std::nullopt;
        auto branch = Expr::make(IfExpr{ifs.cond, std::move(*t), std::move(*e)}, join_ty);
        return Expr::make(
            LetJoinExpr{std::move(jname), join_ty, std::move(*join_e), std::move(branch)},
            std::move(join_ty));
      }
    }

    auto appendTail = [&](const std::vector<Stmt> &branch) -> std::vector<Stmt> {
      std::vector<Stmt> combined;
      combined.reserve(branch.size() + tail.size());
      combined.insert(combined.end(), branch.begin(), branch.end());
      combined.insert(combined.end(), tail.begin(), tail.end());
      return combined;
    };

    auto t_stmts = then_ret ? ifs.then_body : appendTail(ifs.then_body);
    auto e_stmts = else_ret ? ifs.else_body : appendTail(ifs.else_body);
    auto t = lift(t_stmts, scope, fallthrough);
    auto e = lift(e_stmts, scope, fallthrough);
    if (!t || !e)
      return std::nullopt;
    auto res_ty = (*t)->type;
    return Expr::make(IfExpr{ifs.cond, std::move(*t), std::move(*e)}, std::move(res_ty));
  }

  auto liftSwitch(const SwitchStmt &sw, std::span<const Stmt> tail,
                  const std::unordered_set<std::string> &scope, ExprPtr fallthrough)
      -> std::optional<ExprPtr> {
    bool all_cases_ret =
        std::ranges::all_of(sw.cases, [](const SwitchCase &c) { return alwaysReturns(c.body); });
    bool def_ret = !sw.default_body.empty() && alwaysReturns(sw.default_body);

    if (all_cases_ret && (def_ret || sw.default_body.empty())) {
      std::vector<MatchArm> arms;
      arms.reserve(sw.cases.size());
      for (const auto &c : sw.cases) {
        auto body = lift(c.body, scope, nullptr);
        if (!body)
          return std::nullopt;
        arms.push_back(MatchArm{c.values, std::move(*body)});
      }
      auto def = def_ret ? lift(sw.default_body, scope, nullptr) : lift(tail, scope, fallthrough);
      if (!def)
        return std::nullopt;
      auto ty = (*def)->type;
      return Expr::make(MatchExpr{sw.scrutinee, std::move(arms), std::move(*def)}, std::move(ty));
    }

    bool none_ret =
        !mayReturn(sw.default_body) &&
        std::ranges::none_of(sw.cases, [](const SwitchCase &c) { return mayReturn(c.body); });
    if (none_ret) {
      std::vector<std::string> mutated;
      std::unordered_set<std::string> seen;
      for (const auto &c : sw.cases)
        collectMutatedOuterVars(c.body, scope, mutated, seen);
      collectMutatedOuterVars(sw.default_body, scope, mutated, seen);
      auto cont = lift(tail, scope, fallthrough);
      if (!cont)
        return std::nullopt;
      auto cont_ty = (*cont)->type;
      if (mutated.empty())
        return cont;

      auto target_expr = makeVarsExpr(mutated);
      std::vector<MatchArm> arms;
      arms.reserve(sw.cases.size());
      for (const auto &c : sw.cases) {
        auto body = lift(c.body, scope, target_expr);
        if (!body)
          return std::nullopt;
        arms.push_back(MatchArm{c.values, std::move(*body)});
      }
      auto def = lift(sw.default_body, scope, target_expr);
      if (!def)
        return std::nullopt;
      auto m =
          Expr::make(MatchExpr{sw.scrutinee, std::move(arms), std::move(*def)}, target_expr->type);

      if (mutated.size() == 1) {
        return Expr::make(
            LetExpr{mutated[0], lookupType(mutated[0], nullptr), std::move(m), std::move(*cont)},
            std::move(cont_ty));
      }
      std::vector<std::pair<std::string, TypePtr>> binds;
      for (const auto &v : mutated)
        binds.emplace_back(v, lookupType(v, nullptr));
      return Expr::make(LetTupleExpr{std::move(binds), std::move(m), std::move(*cont)},
                        std::move(cont_ty));
    }

    return std::nullopt;
  }

  TypePtr ret_type_;
  std::unordered_map<std::string, TypePtr> var_types_;
  int join_counter_ = 0;
};

// ============================================================================
// Pass 3: Rounding-mode dependency analysis
// ============================================================================

auto exprUsesRoundingMode(const ExprPtr &e, const std::unordered_set<std::string> &mode_funcs)
    -> bool {
  if (!e)
    return false;
  return std::visit(
      Overloaded{
          [](const ConstExpr &) { return false; },
          [](const VarExpr &) { return false; },
          [](const TableRefExpr &) { return false; },
          [](const CallJoinExpr &) { return false; },
          [](const UnsupportedExpr &) { return false; },
          [&](const UnaryExpr &u) { return exprUsesRoundingMode(u.operand, mode_funcs); },
          [&](const BinaryExpr &b) {
            bool op_rounds = isFloatExpr(e) && (b.op == BinaryOp::Add || b.op == BinaryOp::Sub ||
                                                b.op == BinaryOp::Mul || b.op == BinaryOp::Div);
            return op_rounds || exprUsesRoundingMode(b.lhs, mode_funcs) ||
                   exprUsesRoundingMode(b.rhs, mode_funcs);
          },
          [&](const CastExpr &c) {
            bool cast_rounds = c.kind == CastKind::FloatToFloat || c.kind == CastKind::IntToFloat;
            return cast_rounds || exprUsesRoundingMode(c.operand, mode_funcs);
          },
          [&](const SelectExpr &s) {
            return exprUsesRoundingMode(s.cond, mode_funcs) ||
                   exprUsesRoundingMode(s.then_e, mode_funcs) ||
                   exprUsesRoundingMode(s.else_e, mode_funcs);
          },
          [&](const IndexExpr &ix) {
            return exprUsesRoundingMode(ix.base, mode_funcs) ||
                   exprUsesRoundingMode(ix.index, mode_funcs);
          },
          [&](const FieldExpr &f) { return exprUsesRoundingMode(f.base, mode_funcs); },
          [&](const StructLitExpr &sl) {
            return std::ranges::any_of(sl.fields, [&](const auto &kv) {
              return exprUsesRoundingMode(kv.second, mode_funcs);
            });
          },
          [&](const StructUpdateExpr &su) {
            return exprUsesRoundingMode(su.base, mode_funcs) ||
                   exprUsesRoundingMode(su.value, mode_funcs);
          },
          [&](const CoreCallExpr &cc) {
            // Frac64 multiply_add does not depend on IEEE rounding mode.
            bool op_needs_mode = cc.needs_mode && !(e->type && e->type->isFrac64());
            return op_needs_mode || std::ranges::any_of(cc.args, [&](const auto &a) {
                     return exprUsesRoundingMode(a, mode_funcs);
                   });
          },
          [&](const PolyevalExpr &pe) {
            bool op_needs_mode = isFloatExpr(e) || isNumberPairExpr(e);
            return op_needs_mode || exprUsesRoundingMode(pe.var, mode_funcs) ||
                   std::ranges::any_of(pe.coeffs, [&](const auto &c) {
                     return exprUsesRoundingMode(c, mode_funcs);
                   });
          },
          [&](const FuncCallExpr &fc) {
            return mode_funcs.contains(fc.callee) ||
                   std::ranges::any_of(
                       fc.args, [&](const auto &a) { return exprUsesRoundingMode(a, mode_funcs); });
          },
          [&](const LetExpr &le) {
            return exprUsesRoundingMode(le.value, mode_funcs) ||
                   exprUsesRoundingMode(le.body, mode_funcs);
          },
          [&](const LetJoinExpr &lj) {
            return exprUsesRoundingMode(lj.join_body, mode_funcs) ||
                   exprUsesRoundingMode(lj.body, mode_funcs);
          },
          [&](const LetTupleExpr &lt) {
            return exprUsesRoundingMode(lt.value, mode_funcs) ||
                   exprUsesRoundingMode(lt.body, mode_funcs);
          },
          [&](const TupleExpr &te) {
            return std::ranges::any_of(
                te.elems, [&](const auto &el) { return exprUsesRoundingMode(el, mode_funcs); });
          },
          [&](const IfExpr &ie) {
            return exprUsesRoundingMode(ie.cond, mode_funcs) ||
                   exprUsesRoundingMode(ie.then_e, mode_funcs) ||
                   exprUsesRoundingMode(ie.else_e, mode_funcs);
          },
          [&](const MatchExpr &me) {
            return exprUsesRoundingMode(me.scrutinee, mode_funcs) ||
                   exprUsesRoundingMode(me.default_arm, mode_funcs) ||
                   std::ranges::any_of(me.arms, [&](const MatchArm &arm) {
                     return exprUsesRoundingMode(arm.body, mode_funcs);
                   });
          },
      },
      e->v);
}

auto stmtsUseRoundingMode(std::span<const Stmt> stmts,
                          const std::unordered_set<std::string> &mode_funcs) -> bool {
  return std::ranges::any_of(stmts, [&](const Stmt &s) {
    return std::visit(
        Overloaded{
            [&](const VarDeclStmt &v) {
              return v.init && exprUsesRoundingMode(*v.init, mode_funcs);
            },
            [&](const TupleDeclStmt &td) { return exprUsesRoundingMode(td.init, mode_funcs); },
            [&](const AssignStmt &a) { return exprUsesRoundingMode(a.value, mode_funcs); },
            [&](const FieldAssignStmt &fa) {
              return exprUsesRoundingMode(fa.base, mode_funcs) ||
                     exprUsesRoundingMode(fa.value, mode_funcs);
            },
            [&](const ExprStmt &es) { return exprUsesRoundingMode(es.expr, mode_funcs); },
            [&](const IfStmt &i) {
              return exprUsesRoundingMode(i.cond, mode_funcs) ||
                     stmtsUseRoundingMode(i.then_body, mode_funcs) ||
                     stmtsUseRoundingMode(i.else_body, mode_funcs);
            },
            [&](const SwitchStmt &sw) {
              return exprUsesRoundingMode(sw.scrutinee, mode_funcs) ||
                     stmtsUseRoundingMode(sw.default_body, mode_funcs) ||
                     std::ranges::any_of(sw.cases, [&](const SwitchCase &c) {
                       return stmtsUseRoundingMode(c.body, mode_funcs);
                     });
            },
            [&](const WhileStmt &w) {
              return exprUsesRoundingMode(w.cond, mode_funcs) ||
                     stmtsUseRoundingMode(w.body, mode_funcs);
            },
            [&](const ForStmt &f) {
              return (f.cond && exprUsesRoundingMode(*f.cond, mode_funcs)) ||
                     stmtsUseRoundingMode(f.body, mode_funcs);
            },
            [&](const ReturnStmt &r) {
              return r.value && exprUsesRoundingMode(*r.value, mode_funcs);
            },
            [&](const BlockStmt &b) { return stmtsUseRoundingMode(b.stmts, mode_funcs); },
            [](const auto &) { return false; },
        },
        s.v);
  });
}

void propagateCallModeExpr(ExprPtr &e, const std::unordered_set<std::string> &mode_funcs) {
  if (!e)
    return;
  std::visit(Overloaded{
                 [](ConstExpr &) {},
                 [](VarExpr &) {},
                 [](TableRefExpr &) {},
                 [](CallJoinExpr &) {},
                 [](UnsupportedExpr &) {},
                 [&](UnaryExpr &u) { propagateCallModeExpr(u.operand, mode_funcs); },
                 [&](BinaryExpr &b) {
                   propagateCallModeExpr(b.lhs, mode_funcs);
                   propagateCallModeExpr(b.rhs, mode_funcs);
                 },
                 [&](CastExpr &c) { propagateCallModeExpr(c.operand, mode_funcs); },
                 [&](SelectExpr &s) {
                   propagateCallModeExpr(s.cond, mode_funcs);
                   propagateCallModeExpr(s.then_e, mode_funcs);
                   propagateCallModeExpr(s.else_e, mode_funcs);
                 },
                 [&](IndexExpr &ix) {
                   propagateCallModeExpr(ix.base, mode_funcs);
                   propagateCallModeExpr(ix.index, mode_funcs);
                 },
                 [&](FieldExpr &f) { propagateCallModeExpr(f.base, mode_funcs); },
                 [&](StructLitExpr &sl) {
                   for (auto &[_, fe] : sl.fields)
                     propagateCallModeExpr(fe, mode_funcs);
                 },
                 [&](StructUpdateExpr &su) {
                   propagateCallModeExpr(su.base, mode_funcs);
                   propagateCallModeExpr(su.value, mode_funcs);
                 },
                 [&](CoreCallExpr &cc) {
                   for (auto &a : cc.args)
                     propagateCallModeExpr(a, mode_funcs);
                 },
                 [&](PolyevalExpr &pe) {
                   propagateCallModeExpr(pe.var, mode_funcs);
                   for (auto &c : pe.coeffs)
                     propagateCallModeExpr(c, mode_funcs);
                 },
                 [&](FuncCallExpr &fc) {
                   fc.needs_mode = mode_funcs.contains(fc.callee);
                   for (auto &a : fc.args)
                     propagateCallModeExpr(a, mode_funcs);
                 },
                 [&](LetExpr &le) {
                   propagateCallModeExpr(le.value, mode_funcs);
                   propagateCallModeExpr(le.body, mode_funcs);
                 },
                 [&](LetJoinExpr &lj) {
                   propagateCallModeExpr(lj.join_body, mode_funcs);
                   propagateCallModeExpr(lj.body, mode_funcs);
                 },
                 [&](LetTupleExpr &lt) {
                   propagateCallModeExpr(lt.value, mode_funcs);
                   propagateCallModeExpr(lt.body, mode_funcs);
                 },
                 [&](TupleExpr &te) {
                   for (auto &el : te.elems)
                     propagateCallModeExpr(el, mode_funcs);
                 },
                 [&](IfExpr &ie) {
                   propagateCallModeExpr(ie.cond, mode_funcs);
                   propagateCallModeExpr(ie.then_e, mode_funcs);
                   propagateCallModeExpr(ie.else_e, mode_funcs);
                 },
                 [&](MatchExpr &me) {
                   propagateCallModeExpr(me.scrutinee, mode_funcs);
                   for (auto &arm : me.arms)
                     propagateCallModeExpr(arm.body, mode_funcs);
                   propagateCallModeExpr(me.default_arm, mode_funcs);
                 },
             },
             e->v);
}

void propagateCallModeStmts(std::vector<Stmt> &stmts,
                            const std::unordered_set<std::string> &mode_funcs) {
  for (auto &s : stmts) {
    std::visit(Overloaded{
                   [&](VarDeclStmt &v) {
                     if (v.init)
                       propagateCallModeExpr(*v.init, mode_funcs);
                   },
                   [&](TupleDeclStmt &td) { propagateCallModeExpr(td.init, mode_funcs); },
                   [&](AssignStmt &a) { propagateCallModeExpr(a.value, mode_funcs); },
                   [&](FieldAssignStmt &fa) {
                     propagateCallModeExpr(fa.base, mode_funcs);
                     propagateCallModeExpr(fa.value, mode_funcs);
                   },
                   [&](ExprStmt &es) { propagateCallModeExpr(es.expr, mode_funcs); },
                   [&](IfStmt &i) {
                     propagateCallModeExpr(i.cond, mode_funcs);
                     propagateCallModeStmts(i.then_body, mode_funcs);
                     propagateCallModeStmts(i.else_body, mode_funcs);
                   },
                   [&](SwitchStmt &sw) {
                     propagateCallModeExpr(sw.scrutinee, mode_funcs);
                     for (auto &c : sw.cases)
                       propagateCallModeStmts(c.body, mode_funcs);
                     propagateCallModeStmts(sw.default_body, mode_funcs);
                   },
                   [&](WhileStmt &w) {
                     propagateCallModeExpr(w.cond, mode_funcs);
                     propagateCallModeStmts(w.body, mode_funcs);
                   },
                   [&](ForStmt &f) {
                     if (f.cond)
                       propagateCallModeExpr(*f.cond, mode_funcs);
                     propagateCallModeStmts(f.body, mode_funcs);
                   },
                   [&](ReturnStmt &r) {
                     if (r.value)
                       propagateCallModeExpr(*r.value, mode_funcs);
                   },
                   [&](BlockStmt &b) { propagateCallModeStmts(b.stmts, mode_funcs); },
                   [](auto &) {},
               },
               s.v);
  }
}

} // namespace

void liftModule(ir::Module &mod, const LiftOptions &opts) {
  std::unordered_set<std::string> mode_funcs;

  for (auto &fn : mod.functions) {
    simplifyStmts(fn.body_stmts, opts);

    if (opts.lift_functional && !containsUnliftableConstruct(fn.body_stmts)) {
      std::unordered_set<std::string> initial_scope;
      for (const auto &p : fn.params)
        initial_scope.insert(p.name);
      FunctionalLifter lifter(fn.return_type, fn.params);
      if (auto lifted = lifter.lift(fn.body_stmts, std::move(initial_scope), nullptr)) {
        fn.lifted_expr = simplifyExpr(std::move(*lifted), opts);
      }
    }

    bool uses_mode = fn.lifted_expr ? exprUsesRoundingMode(*fn.lifted_expr, mode_funcs)
                                    : stmtsUseRoundingMode(fn.body_stmts, mode_funcs);
    fn.uses_rounding_mode = uses_mode;
    if (uses_mode) {
      mode_funcs.insert(fn.lean_name);
    }
    if (fn.lifted_expr)
      propagateCallModeExpr(*fn.lifted_expr, mode_funcs);
    propagateCallModeStmts(fn.body_stmts, mode_funcs);
  }
}

} // namespace libc_extract
