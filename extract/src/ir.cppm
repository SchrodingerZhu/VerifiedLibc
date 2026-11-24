module;

#include <cstdint>
#include <memory>
#include <optional>
#include <string>
#include <utility>
#include <variant>
#include <vector>

export module libc_extract.ir;

import libc_extract.core_ops;

export namespace libc_extract::ir {

/// Overloaded visitor helper for std::visit.
template <class... Ts>
struct Overloaded : Ts... {
  using Ts::operator()...;
};

// ============================================================================
// Captured LLVM libc build / target configuration
// ============================================================================

struct MathConfig {
  bool skip_accurate_pass = false;
  bool small_tables = false;
  bool no_errno = false;
  bool no_except = false;
  bool intermediate_comp_in_float = false;
  bool assume_round_nearest_only = false;
  bool has_fma_half = false;
  bool has_fma_float = false;
  bool has_fma_double = false;
  bool has_nearest_int = false;
  bool has_fpu_float = true;
  bool has_fpu_double = true;
  bool has_fast_float16 = false;
  bool has_int128 = true;
  std::string target_triple = "x86_64-unknown-linux-gnu";
  std::string impl_variant = "default";
};

// ============================================================================
// Types
// ============================================================================

struct Type;
using TypePtr = std::shared_ptr<Type>;

struct VoidType {};
struct BoolType {};
struct IntType {
  std::uint32_t width = 32;
  bool is_signed = true;
};
struct FloatType {
  FloatFmt fmt = FloatFmt::Binary32;
};
struct FPBitsType {
  FloatFmt fmt = FloatFmt::Binary32;
};
struct DyadicFloatType {
  std::uint32_t bits = 128;
};
struct NumberPairType {
  FloatFmt fmt = FloatFmt::Binary64;
};
struct TripleDoubleType {};
struct Frac64Type {};
struct ExceptValuesType {
  FloatFmt fmt = FloatFmt::Binary32;
  std::size_t size = 0;
};
struct SignType {};
struct OptionalType {
  TypePtr elem;
};
struct ArrayType {
  TypePtr elem;
  std::size_t size = 0;
};
struct StructType {
  std::string name;
};
struct PtrType {
  TypePtr pointee;
};
struct OpaqueType {
  std::string cpp_name;
};

struct Type {
  std::variant<
    VoidType,
    BoolType,
    IntType,
    FloatType,
    FPBitsType,
    DyadicFloatType,
    NumberPairType,
    TripleDoubleType,
    Frac64Type,
    ExceptValuesType,
    SignType,
    OptionalType,
    ArrayType,
    StructType,
    PtrType,
    OpaqueType
  > v = VoidType{};

  static auto makeVoid() -> TypePtr { return std::make_shared<Type>(Type{VoidType{}}); }
  static auto makeBool() -> TypePtr { return std::make_shared<Type>(Type{BoolType{}}); }
  static auto makeInt(std::uint32_t w, bool s) -> TypePtr {
    return std::make_shared<Type>(Type{IntType{w, s}});
  }
  static auto makeFloat(FloatFmt f) -> TypePtr {
    return std::make_shared<Type>(Type{FloatType{f}});
  }
  static auto makeFPBits(FloatFmt f) -> TypePtr {
    return std::make_shared<Type>(Type{FPBitsType{f}});
  }
  static auto makeDyadic(std::uint32_t bits) -> TypePtr {
    return std::make_shared<Type>(Type{DyadicFloatType{bits}});
  }
  static auto makeNumberPair(FloatFmt f) -> TypePtr {
    return std::make_shared<Type>(Type{NumberPairType{f}});
  }
  static auto makeTripleDouble() -> TypePtr {
    return std::make_shared<Type>(Type{TripleDoubleType{}});
  }
  static auto makeFrac64() -> TypePtr {
    return std::make_shared<Type>(Type{Frac64Type{}});
  }
  static auto makeExceptValues(FloatFmt f, std::size_t n) -> TypePtr {
    return std::make_shared<Type>(Type{ExceptValuesType{f, n}});
  }
  static auto makeSign() -> TypePtr { return std::make_shared<Type>(Type{SignType{}}); }
  static auto makeOptional(TypePtr e) -> TypePtr {
    return std::make_shared<Type>(Type{OptionalType{std::move(e)}});
  }
  static auto makeArray(TypePtr e, std::size_t n) -> TypePtr {
    return std::make_shared<Type>(Type{ArrayType{std::move(e), n}});
  }
  static auto makeStruct(std::string name) -> TypePtr {
    return std::make_shared<Type>(Type{StructType{std::move(name)}});
  }
  static auto makePtr(TypePtr p) -> TypePtr {
    return std::make_shared<Type>(Type{PtrType{std::move(p)}});
  }
  static auto makeOpaque(std::string name) -> TypePtr {
    return std::make_shared<Type>(Type{OpaqueType{std::move(name)}});
  }

  auto isFloat() const -> bool { return std::holds_alternative<FloatType>(v); }
  auto isInt() const -> bool { return std::holds_alternative<IntType>(v); }
  auto isBool() const -> bool { return std::holds_alternative<BoolType>(v); }
  auto isVoid() const -> bool { return std::holds_alternative<VoidType>(v); }
  auto isDyadic() const -> bool { return std::holds_alternative<DyadicFloatType>(v); }
  auto isNumberPair() const -> bool { return std::holds_alternative<NumberPairType>(v); }
  auto isFrac64() const -> bool { return std::holds_alternative<Frac64Type>(v); }
  auto isSign() const -> bool { return std::holds_alternative<SignType>(v); }
};

// ============================================================================
// Constants (exact bit-level values evaluated by Clang Sema/APValue)
// ============================================================================

struct ConstVal;

struct BoolConst {
  bool value = false;
};
struct SignConst {
  bool is_neg = false;
};
struct IntConst {
  std::uint32_t width = 32;
  bool is_signed = true;
  std::string hex_bits; // Unsigned two's-complement hex without 0x prefix.
  std::int64_t signed_val = 0;
  bool fits_i64 = true;
};
struct FloatConst {
  FloatFmt fmt = FloatFmt::Binary32;
  std::uint64_t raw_bits = 0;
  std::string repr; // Human-readable comment, e.g. "0x1.555555p-6".
};
struct Frac64Const {
  std::string hex_bits; // 64-bit unsigned hex without 0x prefix.
};
struct DyadicConst {
  std::uint32_t bits = 128;
  bool sign_neg = false;
  std::int64_t exponent = 0;
  std::string mantissa_hex;
};
struct NumberPairConst {
  FloatFmt fmt = FloatFmt::Binary64;
  std::uint64_t lo_bits = 0;
  std::uint64_t hi_bits = 0;
};
struct ArrayConst {
  TypePtr elem_type;
  std::vector<ConstVal> elems;
};
struct StructConst {
  std::string type_name;
  std::vector<std::pair<std::string, ConstVal>> fields;
};

struct ConstVal {
  std::variant<
    BoolConst,
    SignConst,
    IntConst,
    FloatConst,
    Frac64Const,
    DyadicConst,
    NumberPairConst,
    ArrayConst,
    StructConst
  > v = BoolConst{};
};

// ============================================================================
// Expressions
// ============================================================================

struct Expr;
using ExprPtr = std::shared_ptr<Expr>;

enum class UnaryOp : std::uint8_t {
  Neg,
  BitNot,
  LogNot,
};

enum class BinaryOp : std::uint8_t {
  Add, Sub, Mul, Div, Rem,
  BitAnd, BitOr, BitXor, Shl, Shr,
  Eq, Ne, Lt, Le, Gt, Ge,
  LogAnd, LogOr,
};

enum class CastKind : std::uint8_t {
  IntToInt,
  FloatToFloat,
  IntToFloat,
  FloatToInt,
  BitCast,
  ToBool,
  BoolToInt,
  NoOp,
};

enum class PolyScheme : std::uint8_t {
  Horner,
  AltHorner,
  Estrin,
};

struct ConstExpr {
  ConstVal value;
};
struct VarExpr {
  std::string name;
};
struct TableRefExpr {
  std::string table_name;
};
struct UnaryExpr {
  UnaryOp op;
  ExprPtr operand;
};
struct BinaryExpr {
  BinaryOp op;
  ExprPtr lhs;
  ExprPtr rhs;
};
struct CastExpr {
  CastKind kind;
  ExprPtr operand;
};
struct SelectExpr {
  ExprPtr cond;
  ExprPtr then_e;
  ExprPtr else_e;
};
struct IndexExpr {
  ExprPtr base;
  ExprPtr index;
};
struct FieldExpr {
  ExprPtr base;
  std::string field;
};
struct StructLitExpr {
  std::string type_name;
  std::vector<std::pair<std::string, ExprPtr>> fields;
};
struct StructUpdateExpr {
  ExprPtr base;
  std::string field;
  ExprPtr value;
};
struct CoreCallExpr {
  CoreOpKind op;
  std::string lean_name;
  std::vector<ExprPtr> args;
  std::vector<std::string> type_args;
  bool needs_mode = false;
  bool needs_config = false;
  bool is_effect = false;
};
struct PolyevalExpr {
  PolyScheme scheme = PolyScheme::Horner;
  ExprPtr var;
  std::vector<ExprPtr> coeffs; // c0, c1, ..., cn (ascending degree), or single array expr when array_arg
  std::size_t offset = 0;      // Template OFFSET for array-based polyeval/estrin
  bool array_arg = false;      // True when `coeffs` holds a single array expression
};
struct FuncCallExpr {
  std::string callee;
  std::vector<ExprPtr> args;
  bool needs_mode = false;
};
struct LetExpr {
  std::string name;
  TypePtr bind_type;
  ExprPtr value;
  ExprPtr body;
};
struct LetJoinExpr {
  std::string name;
  TypePtr result_type;
  ExprPtr join_body; // Lazy zero-arg thunk `let name (_ : Unit) := join_body`
  ExprPtr body;
};
struct CallJoinExpr {
  std::string name;
};
struct LetTupleExpr {
  std::vector<std::pair<std::string, TypePtr>> bindings;
  ExprPtr value;
  ExprPtr body;
};
struct TupleExpr {
  std::vector<ExprPtr> elems;
};
struct IfExpr {
  ExprPtr cond;
  ExprPtr then_e;
  ExprPtr else_e;
};
struct MatchArm {
  std::vector<ConstVal> patterns; // Multiple fallthrough cases can share a body.
  ExprPtr body;
};
struct MatchExpr {
  ExprPtr scrutinee;
  std::vector<MatchArm> arms;
  ExprPtr default_arm;
};
struct UnsupportedExpr {
  std::string reason;
};

struct Expr {
  std::variant<
    ConstExpr,
    VarExpr,
    TableRefExpr,
    UnaryExpr,
    BinaryExpr,
    CastExpr,
    SelectExpr,
    IndexExpr,
    FieldExpr,
    StructLitExpr,
    StructUpdateExpr,
    CoreCallExpr,
    PolyevalExpr,
    FuncCallExpr,
    LetExpr,
    LetJoinExpr,
    CallJoinExpr,
    LetTupleExpr,
    TupleExpr,
    IfExpr,
    MatchExpr,
    UnsupportedExpr
  > v;
  TypePtr type;

  template <class Node>
  static auto make(Node &&node, TypePtr ty) -> ExprPtr {
    return std::make_shared<Expr>(Expr{std::forward<Node>(node), std::move(ty)});
  }
};

// ============================================================================
// Statements (imperative AST from Clang, lifted to functional Expr in lift.cppm)
// ============================================================================

struct Stmt;
using StmtPtr = std::shared_ptr<Stmt>;

struct VarDeclStmt {
  std::string name;
  TypePtr type;
  std::optional<ExprPtr> init;
  bool is_const = false;
  bool is_volatile = false;
};
struct TupleDeclStmt {
  std::vector<std::pair<std::string, TypePtr>> bindings;
  ExprPtr init;
};
struct AssignStmt {
  std::string target;
  std::optional<BinaryOp> compound_op;
  ExprPtr value;
};
struct FieldAssignStmt {
  ExprPtr base;
  std::string field;
  std::optional<BinaryOp> compound_op;
  ExprPtr value;
};
struct ExprStmt {
  ExprPtr expr;
};
struct IfStmt {
  ExprPtr cond;
  std::vector<Stmt> then_body;
  std::vector<Stmt> else_body;
};
struct SwitchCase {
  std::vector<ConstVal> values;
  std::vector<Stmt> body;
};
struct SwitchStmt {
  ExprPtr scrutinee;
  std::vector<SwitchCase> cases;
  std::vector<Stmt> default_body;
};
struct WhileStmt {
  ExprPtr cond;
  std::vector<Stmt> body;
};
struct ForStmt {
  std::optional<StmtPtr> init;
  std::optional<ExprPtr> cond;
  std::optional<StmtPtr> step;
  std::vector<Stmt> body;
};
struct ReturnStmt {
  std::optional<ExprPtr> value;
};
struct BlockStmt {
  std::vector<Stmt> stmts;
};
struct BreakStmt {};
struct ContinueStmt {};
struct UnsupportedStmt {
  std::string reason;
};

struct Stmt {
  std::variant<
    VarDeclStmt,
    TupleDeclStmt,
    AssignStmt,
    FieldAssignStmt,
    ExprStmt,
    IfStmt,
    SwitchStmt,
    WhileStmt,
    ForStmt,
    ReturnStmt,
    BlockStmt,
    BreakStmt,
    ContinueStmt,
    UnsupportedStmt
  > v;
};

// ============================================================================
// Module-level definitions
// ============================================================================

struct Table {
  std::string lean_name;
  std::string cpp_name;
  TypePtr type;
  ConstVal value;
};

struct Param {
  std::string name;
  TypePtr type;
};

struct Function {
  std::string lean_name;
  std::string cpp_name;
  std::string mangled_name;
  std::vector<Param> params;
  TypePtr return_type;
  std::vector<Stmt> body_stmts;
  std::optional<ExprPtr> lifted_expr; // Populated by lift pass when loop-free.
  bool uses_rounding_mode = false;
  std::vector<std::string> diagnostics;
};

struct Module {
  std::string origin;
  std::string source_file;
  std::string source_commit;
  std::string clang_version;
  MathConfig config;
  std::vector<Table> tables;
  std::vector<Function> functions;
};

} // namespace libc_extract::ir
