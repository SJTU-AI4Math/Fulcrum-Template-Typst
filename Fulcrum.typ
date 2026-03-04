/// 工具函数，适配中文宋体的加粗函数
/// - `body : content` <#1> 需要加粗的内容
#let ApplyBold = (body) => {
  set text(font: ("New Computer Modern", "SimHei"), weight: "bold")
  body
}

/// 显示设置，通过 `#show : FulcrumCN` 启用。配置中文排版样式（字体、缩进、编号等）
/// - `body : content` <#1> 文档正文内容
#let FulcrumCN = (body) => {
  // 章节编号样式："1.1."
  set heading(numbering: "1.1.")
  // 字体样式：西文使用 New Computer Modern，中文使用宋体
  set text(font: ("New Computer Modern", "SimSun"))
  // 首行缩进两个字符宽度
  set par(first-line-indent: (amount: 2em, all: true),)
  // 有序枚举缩进两个字符宽度
  set enum(indent: 2em)
  // 无序枚举缩进两个字符宽度
  set list(indent: 2em)
  // 图片编号规则为“图1”
  set figure(supplement: [图])
  // 章节标题加粗
  show heading: ApplyBold
  // 普通加粗
  show strong: ApplyBold
  // 超链接样式：深蓝色
  show link: set text(weight: "regular", fill: rgb("#000080"))
  // 代码块
  show raw.where(block: true): (body) => {
    block(
      fill: rgb("#EEEEEE"),
      inset: 8pt,
      radius: 4pt,
      body
    )
  }
  // 行内代码块
  show raw.where(block: false): (body) => {
    box(
      fill: rgb("#EEEEEE"),
      inset: 4pt,
      radius: 4pt,
      baseline: 4pt,
      body
    )
  }
  show title: (body) => [#align(center)[#ApplyBold(text(size: 1.5em, body))]]

  body
}

/// 索引创建函数。如果存在标签则链接到标签，否则链接到 URL，若都无则显示纯文本
/// - `uuid : str | label` <#1> 索引指向的 uuid
/// - `body : content` <#2> 索引显示的内容
/// - `url : str` <可选> 索引指向的 URL，一般为维基百科
#let optionLink = (
  uuid,
  body,
  url: ""
) => {
  let l
  if (type(uuid) == str) {
    l = label(uuid)
  } else if (type(uuid) == label) {
    l = uuid
  } else {
    assert(false, message: "Error: type of argument `uuid` must be either `str` or `label`.")
  }
  context {
    let elements = query(l)

    if (elements.len() > 0) {
      link(l)[#body]
    } else if (url != "") {
      link(url)[#body]
    } else {
      body
    }
  }
}

/// 通用条目生成函数。返回一个函数，用于创建带编号、配色的条目块
/// - `env : str` <可选> 条目类型名称，如"定义"、"定理"等，默认"条目"
/// - `counter_name : str` <可选> 计数器名称，用于编号，默认与 env 相同
/// - `color_stroke : color` <可选> 左边按边颜色，默认黑色
/// - `color_fill : color` <可选> 背景填充颜色，默认浅灰色
/// - `parentEntry : str` <可选> 父条目计数器名称，用于嵌套编号
/// - `default_inline : bool` <可选> 是否默认使用行内模式，默认 false
#let entry(
  env: "条目",
  counter_name: "",
  color_stroke: rgb("#000000"),
  color_fill: rgb("#DDDDDD"),
  parentEntry: "",
  default_inline: false,
) = {
  // 创建计数器

  if (counter_name == "") {
    counter_name = env
  }
  let envCounter = counter(counter_name)

  // 返回条目函数
  (uuid: "", title_cn, title_en, body, inline: default_inline, extention: false) => {
    // 覆盖全局首行缩进设置
    set par(first-line-indent: 0em)

    if (not extention) { envCounter.step() } else { v(-1em) }

    block(
      fill: color_fill,
      inset: (x: 12pt, y: 8pt),
      stroke: (left: 3pt + color_stroke),
      width: 100%,
      spacing: 1em,
      if not inline [
        *
        #if (not extention) [
          #env
          #context {
            let num = if (parentEntry != "") { [#counter(parentEntry).get().at(0)] } + envCounter.get().at(0)
            let levels = counter(heading).display()
            if (levels != "0") { [#levels#num] } else { [#num] }
          }:
        ] else [#v(-5pt)#line(length: 100%, stroke: 0.5pt + color_stroke)#v(-5pt)#env：]#title_cn#if title_en != "" { "（" + title_en + "）" }
        *
        #if (uuid != "") { label(uuid) }
        #v(-5pt)
        #line(length: 100%, stroke: 0.5pt + color_stroke)
        #v(-5pt)
        #body
      ] else [
        *#env#if (uuid != "") { label(uuid) }: *#body
      ],
    )
  }
}

// 定义命令

/// 约定条目。用绿色主题创建约定块
/// - `uuid : str` <可选> 条目的唯一标识符，用于链接引用
/// - `body : content` <#1> 约定的内容
#let 约定 = (uuid: "", body) => entry(
  env: "约定",
  counter_name: "variable",
  color_stroke: rgb("#00B8A0"),
  color_fill: rgb("#D0FFF1"),
  default_inline: true,
)(uuid: uuid, "", "", body)

// 公理
#let 公理 = entry(
  env: "公理",
  counter_name: "axiom",
  color_stroke: rgb("#C1C103"),
  color_fill: rgb("#FFFFAC"),
)
#let axm = entry(
  env: "Axiom",
  counter_name: "axiom",
  color_stroke: rgb("#C1C103"),
  color_fill: rgb("#FFFFAC"),
)

// 规则
#let 规则 = entry(
  env: "规则",
  counter_name: "axiom",
  color_stroke: rgb("#C1C103"),
  color_fill: rgb("#FFFFAC"),
)
#let rule = entry(
  env: "Rule",
  counter_name: "axiom",
  color_stroke: rgb("#C1C103"),
  color_fill: rgb("#FFFFAC"),
)

// 定义
/**
 * 非标准化定义块函数
 * 位置参数：
 * `title_cn : string` 定义块的中文标题
 * `title_en : string` 定义块的英文标题
 *
 */
#let 定义块 = entry(
  env: "定义",
  counter_name: "definition",
  color_stroke: rgb("#009C27"),
  color_fill: rgb("#D6FEE0"),
)
#let dfn = entry(
  env: "Definition",
  counter_name: "definition",
  color_stroke: rgb("#009C27"),
  color_fill: rgb("#D6FEE0"),
)

/// 标准化定义条目函数。提供结构化的定义显示格式，支持假设、名称、内容、记号等
/// - `uuid : str` <可选> 定义的唯一标识符，用于链接引用
/// - `title_cn : str` <#2> 定义的中文标题
/// - `title_en : str` <#3> 定义的英文标题
/// - `hypotheses : list` <可选> 假设列表，支持字符串或列表
/// - `hstyle : str` <可选> 假设显示风格，"inline" 或 "display"，默认 "inline"
/// - `name : str` <可选> 定义项的名称
/// - `tstyle : str` <可选> 标题显示风格，"inline" 或 "display"，默认 "inline"
/// - `content : content` <可选> 定义的主体内容
/// - `bstyle : str` <可选> 主体显示风格，"inline" 或 "display"，默认 "inline"
/// - `notation : content` <可选> 定义的记号，默认空
/// - `nstyle : str` <可选> 记号显示风格，"inline" 或 "display"，默认 "inline"
/// - `isPredicate : bool` <可选> 是否为谓词定义，默认 false
/// - `extention : bool` <可选> 是否为扩展定义，默认 false
#let 定义 = (
  uuid: "",
  title_cn,
  title_en,
  hypotheses: (),
  hstyle: "inline",
  name,
  tstyle: "inline",
  content,
  bstyle: "inline",
  notation: [],
  nstyle: "inline",
  isPredicate: false,
  extention: false,
) => {
  定义块(uuid: uuid, title_cn, title_en, extention: extention, {
    if type(hypotheses) == "string" {
      hypotheses = (hypotheses,)
    }
    // 假设
    if (hypotheses.len() > 0) {
      if (hstyle == "display") {
        [设：#enum(..hypotheses.map(h => [#h；]))]
      } else {
        if (hypotheses.len() > 0) [设#hypotheses.join("，")，]
      }
    }
    // 目标
    if (tstyle == "display") {
      [定义：#name]
    } else {
      [定义【#name】]
    }
    // 主体
    if (bstyle == "display") {
      if (isPredicate) [当且仅当：] else [为：] + content
    } else {
      if (isPredicate) [当且仅当] else [为] + content
    }
    // 记号
    if (notation != []) {
      if (nstyle == "display") [记作：#notation] else [，记作：#notation]
    }
    if ((notation != [] and nstyle != "display") or (notation == [] and bstyle != "display")) [。]
  })
}
/// 实例条目函数。用于展示具体实例的结构化组件
/// - `uuid : str` <可选> 实例的唯一标识符，用于链接引用
/// - `title_cn : str` <#2> 实例的中文标题
/// - `title_en : str` <#3> 实例的英文标题
/// - `hypotheses : list` <可选> 假设列表，支持字符串或列表
/// - `hstyle : str` <可选> 假设显示风格，"inline" 或 "display"，默认 "inline"
/// - `name : str` <可选> 实例的名称
/// - `content : list` <可选> 实例的成员列表，每个元素为包含 name、name_en、varName、value 的字典
/// - `class : str` <可选> 实例所属的类别
/// - `extention : bool` <可选> 是否为扩展实例，默认 false
/// - `isPredicate : bool` <可选> 是否为谓词实例，默认 false
#let 实例 = (
  uuid: "",
  title_cn,
  title_en,
  hypotheses: (),
  hstyle: "inline",
  name,
  content,
  class,
  extention: false,
  isPredicate: false,
) => {
  定义块(uuid: uuid, title_cn, title_en, extention: extention, [
    // 假设
    #if (hypotheses.len() > 0) [
      #if (hstyle == "display") [
        设：
        #enum(..hypotheses)
      ] else [
        #if (hypotheses.len() > 0) [设#hypotheses.join("，")，]
      ]
    ]
    // 目标
    定义【#name;】为携带以下信息的#class：
    #enum(..content.map(member => [
      *#member.name#if ("name_en" in member) [（#member.name_en）]*#if ("varName" in member) [ $(#member.varName):$ ] else [：]#member.value；
    ]))
  ])
}

// 结构
#let 结构块 = entry(
  env: "结构",
  counter_name: "definition",
  color_stroke: rgb("#009C27"),
  color_fill: rgb("#D6FEE0"),
)
#let struct = entry(
  env: "Structure",
  counter_name: "definition",
  color_stroke: rgb("#009C27"),
  color_fill: rgb("#D6FEE0"),
)
/// 结构条目函数。用于定义包含特定组件的结构
/// - `uuid : str` <可选> 结构的唯一标识符，用于链接引用
/// - `title_cn : str` <#2> 结构的中文标题
/// - `title_en : str` <#3> 结构的英文标题
/// - `hypotheses : list` <可选> 假设列表，支持字符串或列表
/// - `extends : list` <可选> 继承的结构列表
/// - `hstyle : str` <可选> 假设显示风格，"inline" 或 "display"，默认 "inline"
/// - `name : str` <可选> 结构的名称
/// - `content : list` <可选> 结构的成员列表，每个元素为包含 name、name_en、varName、value 的字典
/// - `extention : bool` <可选> 是否为扩展结构，默认 false
/// - `isPredicate : bool` <可选> 是否为谓词结构，默认 false
/// - `notation : content` <可选> 结构的记号，默认空
/// - `nstyle : str` <可选> 记号显示风格，"inline" 或 "display"，默认 "inline"
#let 结构 = (
  uuid: "",
  title_cn,
  title_en,
  hypotheses: (),
  extends: (),
  hstyle: "inline",
  name,
  content,
  extention: false,
  isPredicate: false,
  notation: [],
  nstyle: "inline",
) => {
  结构块(uuid: uuid, title_cn, title_en, extention: extention, [
    // 假设
    #if (hypotheses.len() > 0) [
      #if (hstyle == "display") [
        设：
        #enum(..hypotheses)
      ] else [
        #if (hypotheses.len() > 0) [设#hypotheses.join("，")，]
      ]
    ]
    // 目标
    定义【#name;】#if (extends != ()) [在#extends.join("，")的基础上]#if (isPredicate) [当且仅当] else [包含以下信息]：
    #enum(..content.map(member => [
      *#member.name#if ("name_en" in member) [（#member.name_en）]*#if ("varName" in member) [ $(#member.varName):$ ] else [：]#member.value；
    ]))
    #if (notation != []) [
      #if (nstyle == "display") [记作：#notation] else [记作：#notation。]
    ]
  ])
}

// 性质
#let 性质块 = entry(
  env: "性质",
  counter_name: "property",
  color_stroke: rgb("#AC00AF"),
  color_fill: rgb("#FFEDFF"),
)
#let ppt = entry(
  env: "Property",
  counter_name: "property",
  color_stroke: rgb("#AC00AF"),
  color_fill: rgb("#FFEDFF"),
)

/// 性质条目函数。用于展示某对象的性质或特征
/// - `uuid : str` <可选> 性质的唯一标识符，用于链接引用
/// - `title_cn : str` <#2> 性质的中文标题
/// - `title_en : str` <#3> 性质的英文标题
/// - `hypotheses : list | str` <可选> 假设列表或字符串，支持自动转换为列表
/// - `hstyle : str` <可选> 假设显示风格，"inline" 或 "display"，默认 "inline"
/// - `content : content` <#6 或可选> 性质的内容
/// - `bstyle : str` <可选> 内容显示风格，"inline" 或 "display"，默认 "inline"
/// - `extention : bool` <可选> 是否为扩展性质，默认 false
#let 性质 = (
  uuid: "",
  title_cn,
  title_en,
  hypotheses: (),
  hstyle: "inline",
  content,
  bstyle: "inline",
  extention: false, 
) => {
  性质块(uuid: uuid, title_cn, title_en, extention: extention, {
    if type(hypotheses) == "string" {
      hypotheses = (hypotheses,)
    }
    // 假设
    if (hypotheses.len() > 0) {
      if (hstyle == "display") {
        [设：#enum(..hypotheses.map(h => [#h；]))则：]
      } else {
        if (hypotheses.len() > 0) [设#hypotheses.join("，")，则：]
      }
    }
    // 主体
    if (bstyle == "display") {
      content
    } else {
      [#content;。]
    }
  })
}

/// 结构性质条目函数。展示结构性质及其包含的成员
/// - `uuid : str` <可选> 结构性质的唯一标识符，用于链接引用
/// - `title_cn : str` <#2> 结构性质的中文标题
/// - `title_en : str` <#3> 结构性质的英文标题
/// - `hypotheses : list | str` <可选> 假设列表或字符串，支持自动转换为列表
/// - `hstyle : str` <可选> 假设显示风格，"inline" 或 "display"，默认 "inline"
/// - `content : content` <可选> 性质的内容
/// - `members : list` <可选> 成员列表，每个元素为包含 name、name_en、varName、value 的字典
#let 结构性质 = (
  uuid: "",
  title_cn,
  title_en,
  hypotheses: (),
  hstyle: "inline",
  content,
  members: (),
) => {
  性质块(uuid: uuid, title_cn, title_en, {
    if type(hypotheses) == "string" {
      hypotheses = (hypotheses,)
    }
    // 假设
    if (hypotheses.len() > 0) {
      if (hstyle == "display") {
        [设：#enum(..hypotheses.map(h => [#h；]))则：]
      } else {
        if (hypotheses.len() > 0) [设#hypotheses.join("，")，则：]
      }
    }
    // 主体
    [#content#if (members.len() > 0) [，其中：] else [。]]
    if (members.len() > 0) [
      #enum(..members.map(member => [
        *#member.name#if ("name_en" in member) [（#member.name_en）]*#if ("varName" in member) [ $(#member.varName):$ ] else [：]#member.value；
      ]))
    ]
  })
}

// 定理
#let 定理 = entry(
  env: "定理",
  counter_name: "theorem",
  color_stroke: rgb("#005B9C"),
  color_fill: rgb("#DAF0FF"),
)
#let thm = entry(
  env: "Theorem",
  counter_name: "theorem",
  color_stroke: rgb("#005B9C"),
  color_fill: rgb("#DAF0FF"),
)

// 例
#let 例 = entry(
  env: "例",
  counter_name: "example",
  color_stroke: rgb("#7700E4"),
  color_fill: rgb("#EFDFFF"),
)
#let xmp = entry(
  env: "Example",
  counter_name: "example",
  color_stroke: rgb("#7700E4"),
  color_fill: rgb("#EFDFFF"),
)

/// 全局状态：控制注释块的可见性
#let remark_visible = state("remark_visible", true)

/// 显示注释块。将 remark_visible 状态设置为 true
#let showRemark = context {
  remark_visible.update(true)
  []
}
/// 隐藏注释块。将 remark_visible 状态设置为 false
#let hideRemark = context {
  remark_visible.update(false)
  []
}

/// 注条目函数。在 remark_visible 状态为 true 时显示注释
/// - `uuid : str` <可选> 注的唯一标识符，用于链接引用
/// - `title_cn : str` <可选> 注的中文标题
/// - `title_en : str` <可选> 注的英文标题
/// - `body : content` <#4 或可选> 注的内容
/// - `inline : bool` <可选> 是否使用行内模式，默认 true
/// - `extention : bool` <可选> 是否为扩展注，默认 false
#let 注 = (
  uuid: "",
  title_cn: "",
  title_en: "",
  body,
  inline: true,
  extention: false
) => {
  context if (remark_visible.get() == true) {
    entry(
      env: "注",
      counter_name: "remark",
      color_stroke: rgb("#E07B00"),
      color_fill: rgb("#FFEBD2"),
      default_inline: true,
    )(uuid: uuid, title_cn, title_en, body, inline: inline, extention: extention)
  }
}
#let rmk = entry(
  env: "Remark",
  counter_name: "remark",
  color_stroke: rgb("#E07B00"),
  color_fill: rgb("#FFEBD2"),
  default_inline: true,
)

#show: FulcrumCN

= Examples

== `#optionLink`

This function is primarily designed for reference constants that may or may not have a labelled definition to refer to across different documents.

*Code:*

```typ
Write a line of text labelled with `ExampleLabel`, <ExampleLabel>

Create an #optionLink(<ExampleLabel>, "example constant") that links to a label if it exists. 

And here is #optionLink(<InexistLabel>, "another constant") that does not find the label, so it just displays the text. 

Moreover, you can create a #optionLink(<InexistLabel>, "constant with backup", url: "http://www.wikipedia.org") that links to a URL if the label does not exist. In this case it's Wikipedia homepage. 
```

*Output:*

Write a line of text labelled with `ExampleLabel`, <ExampleLabel>

Create an #optionLink(<ExampleLabel>, "example constant") that links to a label if it exists. 

And here is #optionLink(<InexistLabel>, "another constant") that does not find the label, so it just displays the text. 

Moreover, you can create a #optionLink(<InexistLabel>, "constant with backup", url: "http://www.wikipedia.org") that links to a URL if the label does not exist. In this case it's Wikipedia homepage. 

== `#entry`