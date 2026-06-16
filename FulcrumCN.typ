// FulcrumCN.typ
//
// 新中文 (new CN) CNL 模板: 条目 + 子句 二级分离架构。
//
// 设计原则:
// 1. 条目命令(*条目)只管框: 颜色、标题、uuid、贡献者、计数器
// 2. 子句命令(*子句)只管文字: CNL 语义自洽的完整子句
// 3. 一个条目内可放多个子句, 各子句各自处理可选参数为空的情况
// 4. 与旧 Fulcrum.typ 共存, 不冲突, 旧代码继续可用
//
// ============================================================
// 条目 (*条目)
//   定义条目 / 公理条目 / 引理条目 / 定理条目 / 推论条目 / 性质条目
//   注条目 / 例条目 / 反例条目 / 构造条目 / 证明条目 / 题目条目
//
// 子句 (*子句)
//   定义类(用于 #定义条目 / #公理条目 内):
//     #定义子句       —— 普通定义
//     #递归定义子句   —— 归纳/递归定义
//     #结构子句       —— 结构体定义(类型, 含成员列表)
//     #结构实例子句   —— 结构体的具体实例(含 value)
//
//   定理类(用于 #引理条目/#定理条目/#推论条目/#公理条目/#性质条目 内):
//     #定理子句       —— 普通定理 / 性质 / 推论(陈述+条件)
//
//   推论本身不需要专属子句, 用 #定理子句 即可。
//
// 调用约定: 所有"必填"参数都是 named (有默认值 none, 函数体内 assert),
//          这样调用必须写 `主体: ..., 内容: ...` 等, 顺序自由可读。
// ============================================================


#import "FulcrumCore.typ": (
  entry,
  ClauseHypotheses,
  ClauseConclusion,
  ClauseMembers,
  ClauseNotation,
  ClauseDefine,
  ClauseBe,
  ClauseIff,
  ClauseContains,
)


// ============================================================
// 1. 条目命令(*条目)— 只管框
// ============================================================

/// 定义条目: 绿色框, definition counter
#let 定义条目 = entry(
  env: "定义",
  counter_name: "definition",
  color_stroke: rgb("#009C27"),
  color_fill: rgb("#D6FEE0"),
)

/// 公理条目: 黄色框, axiom counter
#let 公理条目 = entry(
  env: "公理",
  counter_name: "axiom",
  color_stroke: rgb("#C1C103"),
  color_fill: rgb("#FFFFAC"),
)

/// 引理条目: 蓝色框, theorem counter (与定理/推论共用)
#let 引理条目 = entry(
  env: "引理",
  counter_name: "theorem",
  color_stroke: rgb("#005B9C"),
  color_fill: rgb("#DAF0FF"),
)

/// 定理条目: 蓝色框, theorem counter
#let 定理条目 = entry(
  env: "定理",
  counter_name: "theorem",
  color_stroke: rgb("#005B9C"),
  color_fill: rgb("#DAF0FF"),
)

/// 推论条目: 蓝色框 (同定理/引理), theorem counter
#let 推论条目 = entry(
  env: "推论",
  counter_name: "theorem",
  color_stroke: rgb("#005B9C"),
  color_fill: rgb("#DAF0FF"),
)

/// 性质条目: 品红框, property counter
#let 性质条目 = entry(
  env: "性质",
  counter_name: "property",
  color_stroke: rgb("#AC00AF"),
  color_fill: rgb("#FFEDFF"),
)

/// 注条目: 橙色 remark 风格(无背景色)
#let 注条目 = entry(
  env: "注",
  counter_name: "remark",
  color_stroke: rgb("#E07B00"),
  color_fill: rgb("#FFEBD2"),
  style: "remark",
)

/// 例条目: 紫色框, example counter
#let 例条目 = entry(
  env: "例",
  counter_name: "example",
  color_stroke: rgb("#7700E4"),
  color_fill: rgb("#EFDFFF"),
)

/// 反例条目: 红色框, counterexample counter
#let 反例条目 = entry(
  env: "反例",
  counter_name: "counterexample",
  color_stroke: rgb("#D20022"),
  color_fill: rgb("#FFD6DC"),
)

/// 构造条目: 灰色 proof 风格 (与证明同色)
#let 构造条目 = entry(
  env: "构造",
  counter_name: "construction",
  color_stroke: rgb("#787878"),
  color_fill: rgb("#F0F0F0"),
  style: "proof",
)

/// 证明条目: 灰色 proof 风格
#let 证明条目 = entry(
  env: "证明",
  counter_name: "proof",
  color_stroke: rgb("#787878"),
  color_fill: rgb("#F0F0F0"),
  style: "proof",
)

/// 题目条目: 蓝色 problem 风格
#let 题目条目 = entry(
  env: "题目",
  counter_name: "problem",
  color_stroke: rgb("#005B9C"),
  color_fill: rgb("#DAF0FF"),
  style: "problem",
)


// ============================================================
// 2. 子句命令(*子句)— 只管文字
// ============================================================

// 内部 helper: 渲染 type 注解
// type != none 且 主体不是谓词 → "[主体 : type]"
// 否则 → "[主体]"
#let _format-target = (target, t) => {
  if (t != none) {
    [#target #h(0.2em)$:$#h(0.2em)#t]
  } else {
    target
  }
}

// 内部 helper: 处理 hypotheses 单个内容 / 数组的两种输入
#let _normalize-hypotheses = (hypotheses) => {
  if (type(hypotheses) == str or type(hypotheses) == content) {
    (hypotheses,)
  } else {
    hypotheses
  }
}


// ----------------------------------------
// 2.1 #定义子句 — 普通定义
//
//   设 [条件], 定义【[主体] : [type]】 为 [内容], 记作 [记号]
//   设 [条件], 定义【[主体] : [type]】 当且仅当 [内容], 记作 [记号]   (isPredicate=true)
//
// 必填: 主体, 内容   (named, 调用必须写 主体: ..., 内容: ...)
// 可选: 条件, type, 记号, isPredicate, *style
// ----------------------------------------
#let 定义子句 = (
  主体: none,
  内容: none,
  条件: (),
  type: none,
  记号: [],
  isPredicate: false,
  hstyle: "inline",
  tstyle: "inline",
  bstyle: "inline",
  nstyle: "inline",
) => {
  let _t = std.type
  assert(主体 != none, message: "定义子句: 参数 `主体` 必填")
  assert(内容 != none, message: "定义子句: 参数 `内容` 必填")
  let hyps = _normalize-hypotheses(条件)
  // 假设
  ClauseHypotheses(hyps, hstyle)
  // 目标 (含可选 type 注解)
  ClauseDefine(_format-target(主体, type), tstyle: tstyle)
  // 连接词 + 内容
  (if (isPredicate) { ClauseIff(bstyle: bstyle) } else { ClauseBe(bstyle: bstyle) }) + 内容
  // 记号
  ClauseNotation(记号, bstyle, nstyle)
}


// ----------------------------------------
// 2.2 #递归定义子句 — 归纳/递归定义
//
// 一般情形 (isPredicate=false):
//   设 [条件], 定义【[主体] : [type]】类型的成员为以下之一:
//     1. [构造子1] : [类型1]
//     2. ...
//
// 谓词情形 (isPredicate=true):
//   设 [条件], 定义【[主体]】(可省 type) 若以下之一成立:
//     1. [构造子1] : [类型1]
//     2. ...
//
// 必填: 主体, 构造子   (named)
// 可选: 条件, type, isPredicate, *style
//
// 构造子: array, 每条 (name: ..., type: ...) 字典 (其中 type 可省)
//                若该条仅一个 content, 当 name 处理无 type 后续。
// ----------------------------------------
#let 递归定义子句 = (
  主体: none,
  构造子: none,
  条件: (),
  type: none,
  isPredicate: false,
  hstyle: "inline",
  tstyle: "inline",
) => {
  let _t = std.type
  assert(主体 != none, message: "递归定义子句: 参数 `主体` 必填")
  assert(构造子 != none, message: "递归定义子句: 参数 `构造子` 必填")
  let hyps = _normalize-hypotheses(条件)
  // 假设
  ClauseHypotheses(hyps, hstyle)
  // 目标
  ClauseDefine(_format-target(主体, type), tstyle: tstyle)
  // 连接词
  if (isPredicate) {
    [类型若以下之一成立：]
  } else {
    [类型的成员为以下之一：]
  }
  // 构造子列表
  enum(
    ..构造子.map(c => {
      // 兼容: dict 或 content
      if (_t(c) == dictionary) {
        if ("type" in c and c.type != none) {
          [#strong(c.name) #h(0.2em)$:$#h(0.2em) #c.type]
        } else {
          strong(c.name)
        }
      } else {
        c
      }
    })
  )
}


// ----------------------------------------
// 2.3 #结构子句 — 结构体类型定义
//
//   设 [条件], 定义【[主体]】(在 [继承] 的基础上) 类型包含以下信息:
//     1. [成员名] (varName : type) := value
//     2. ...
//   记作 [记号]。
//
// 必填: 主体, 成员   (named)
// 可选: 条件, 继承, 记号, isPredicate, *style
//
// 成员: array, 每条字典:
//   (name, name_en?, varName?, type?, value?, style?)
//
// 渲染规则(继承自旧 ClauseMembers):
//   - 有 varName + value (不传 type) → "(varName : value)"
//   - 有 varName + type (+ value) → "(varName : type) := value"
//   - 仅 value(无 varName) → ": value"
// ----------------------------------------
#let 结构子句 = (
  主体: none,
  成员: none,
  条件: (),
  继承: (),
  记号: [],
  isPredicate: false,
  hstyle: "inline",
  nstyle: "inline",
) => {
  let _t = std.type
  assert(主体 != none, message: "结构子句: 参数 `主体` 必填")
  assert(成员 != none, message: "结构子句: 参数 `成员` 必填")
  let hyps = _normalize-hypotheses(条件)
  let exts = if (_t(继承) == str or _t(继承) == content) { (继承,) } else { 继承 }
  // 假设
  ClauseHypotheses(hyps, hstyle)
  // 目标
  [定义【#主体】]
  // 继承(在 ... 基础上)
  if (exts.len() > 0) [在#exts.join("，")的基础上]
  // 连接词
  if (isPredicate) {
    ClauseIff(bstyle: "display")
  } else {
    ClauseContains(bstyle: "display")
  }
  // 成员
  ClauseMembers(成员)
  // 记号
  ClauseNotation(记号, "display", nstyle)
}


// ----------------------------------------
// 2.4 #结构实例子句 — 结构体的具体实例
//
//   设 [条件], 定义【[主体]】是携带以下信息的 [类别]:
//     1. [成员名] (varName : type) := value
//     2. ...
//   记作 [记号]。
//
// 必填: 主体, 类别, 成员    (named)
// 可选: 条件, 记号, *style
// ----------------------------------------
#let 结构实例子句 = (
  主体: none,
  类别: none,
  成员: none,
  条件: (),
  记号: [],
  hstyle: "inline",
  nstyle: "inline",
) => {
  assert(主体 != none, message: "结构实例子句: 参数 `主体` 必填")
  assert(类别 != none, message: "结构实例子句: 参数 `类别` 必填")
  assert(成员 != none, message: "结构实例子句: 参数 `成员` 必填")
  let hyps = _normalize-hypotheses(条件)
  ClauseHypotheses(hyps, hstyle)
  [定义【#主体】为携带以下信息的 #类别：]
  ClauseMembers(成员)
  ClauseNotation(记号, "display", nstyle)
}


// ----------------------------------------
// 2.5 #定理子句 — 唯一定理类子句
//
//   设 [条件], 则 [结论]
//   [结论]   (无条件时)
//
// 必填: 结论    (named)
// 可选: 条件, *style
//
// 用于: #定理条目 / #引理条目 / #推论条目 / #公理条目 / #性质条目 内
// ----------------------------------------
#let 定理子句 = (
  结论: none,
  条件: (),
  hstyle: "inline",
  cstyle: "inline",
) => {
  assert(结论 != none, message: "定理子句: 参数 `结论` 必填")
  let hyps = _normalize-hypotheses(条件)
  let hasHyp = hyps.len() > 0
  // 假设
  ClauseHypotheses(hyps, hstyle)
  // 结论
  ClauseConclusion(hasHyp, 结论, cstyle)
}
