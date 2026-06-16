// FulcrumEN.typ
//
// CNL 模板英文版独立文件。
//
// 此文件 re-export 由 Fulcrum.typ 已经定义好的英文相关命令,
// 让用户只需 #import "FulcrumEN.typ": * 就能拿到全部英文工具。
//
// 设计原则:
// 1. 保持与 Fulcrum.typ 现有英文实现完全兼容(它们仍是真正的实现源)
// 2. 这里仅 re-export 命名, 不复制实现
// 3. 等条件成熟可以把英文实现整体迁移过来, 但现阶段 0 风险方式
//
// 如果你只想用英文工具, 在 main.typ 写:
//   #import "../../Fulcrum-Template-Typst/FulcrumEN.typ": *


#import "Fulcrum.typ": (
  // 元 keyword 着色
  _meta,

  // CNL clauses
  declare,
  structure_declare,
  theorem_declare,
  instance_declare,
  structure_instance_declare,

  // English entry blocks (full, named)
  definition,
  theorem,
  lemma,
  proposition,
  structure,
  example,
  remark,
  variable_block,
  instance_block,

  // Short aliases
  axm,
  rule,
  dfn,
  struct,
  ppt,
  thm,
  xmp,
  rmk,

  // Misc commentary helper
  doc_remark,
)


// 显式 re-export(import .. 默认就 re-export, 这里写 #let 别名只是文档化)
#let _re_export_marker = "fulcrum-en-1.0"
