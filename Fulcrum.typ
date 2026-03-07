#let WarningMessage = state("warning", [])
#let WarningRender = context {
  let message = WarningMessage.get()
  if (message != []) {
    block(
      fill: rgb("#FFF3CD"),
      inset: 4pt,
      radius: 4pt,
      stroke: rgb("#856404"),
      width: 100%,
      spacing: 1em,
    )[
      #text(fill: rgb("#856404"), message)
    ]
  }
}

#let counterList = state("counterList", ())

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
    set text(font: ("Consolas", "SimHei"))
    block(
      fill: rgb("#EEEEEE"),
      inset: 8pt,
      radius: 4pt,
      body
    )
  }
  // 行内代码块
  show raw.where(block: false): (body) => {
    set text(font: ("Consolas", "SimHei"))
    box(
      fill: rgb("#EEEEEE"),
      inset: 4pt,
      radius: 4pt,
      baseline: 4pt,
      body
    )
  }
  show title: (body) => [#align(center)[#ApplyBold(text(size: 1.5em, body))]]

  // 全局警告信息渲染
  set page(header: WarningRender)

  body
}

#let allowQuery = state("allowQuery", true)
#let 关闭索引 = allowQuery.update(false)

/// 索引创建函数。如果存在标签则链接到标签，否则链接到 URL，若都无则显示纯文本
/// 1. `uuid : str | label` 索引指向的 uuid
/// 2. `body : content` 索引显示的内容
/// - `url : str` 索引指向的 URL，一般为维基百科
#let optionLink = (
  uuid,
  body,
  url: ""
) => {
  // 标签容器
  let l

  // 类型检查
  if (type(uuid) == str) {
    // `str` 则转换为 `label`
    l = label(uuid)
  } else if (type(uuid) == label) {
    // `label` 则不变
    l = uuid
  } else {
    // 报类型错
    assert(false, message: "Type Error: type of argument `uuid` must be either `str` or `label`.")
  }
  context {
    // 查找标签是否在文档中存在
    let elements
    if (allowQuery.get()){
      elements = query(l)
    } else {
      elements = ()
    }
    // 视情况链接或显示纯文本
    if (elements.len() > 0) {
      // 标签存在，链接到标签
      link(l)[#body]
    } else if (url != "") {
      // 标签不存在但 URL 不为空，链接到 URL
      link(url)[#body]
    } else {
      // 显示纯文本
      body
    }
  }
}

/// “令 ... 为 ...” 语言
#let 令 = (varName, type: [], value) => {
  [#optionLink("TypeLet", [令]) #varName]
  if (type != []) [ $:#type$]
  [ 为 #value]
}


/// 通用条目块生成函数。返回一个函数，用于创建带编号、配色的条目块
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
  // 若不指定计数器名称，以环境为名创建计数器
  if (counter_name == "") {
    counter_name = env
  }
  let envCounter = counter(counter_name)

  // 返回条目函数
  (
    uuid: "",
    title_cn,
    title_en,
    body,
    inline: default_inline,
    extention: false,
    contributors: (),
  ) => {
    // 覆盖全局格式，清空首行缩进
    set par(first-line-indent: 0em)
    counterList.update(prev => {
      
      if ((prev == none) or (not counter_name in prev)) {
        prev + (counter_name,)
      }
      
    })

    if (not extention) {
      // 更新计数器
      envCounter.step()
    } else {
      // 与上一个条目衔接
      v(-1em)
    }

    // 条目块
    block(
      fill: color_fill,
      inset: (x: 12pt, y: 8pt),
      stroke: (left: 3pt + color_stroke),
      width: 100%,
      spacing: 1em,
      {
        if (inline) {
          // 单行块
          strong({
            [#env #if (uuid != "") { label(uuid) }]
            [: ]
          })
          body
        } else {
          // 正常块
          strong({
            if (not extention) {
              env
              context {
                let num = if (parentEntry != "") {
                  [#counter(parentEntry).get().at(0)]
                } + envCounter.get().at(0)
                let levels = counter(heading).display()
                if (levels != "0") { [#levels#num] } else { [#num] }
              }
              [:]
            } else [#v(-5pt)#line(length: 100%, stroke: 0.5pt + color_stroke)#v(-5pt)#env：]
            [
              #title_cn
              #if (uuid != "") { label(uuid) }
            ]
            if title_en != "" { "（" + title_en + "）" }
          })
          v(-5pt)
          line(length: 100%, stroke: 0.5pt + color_stroke)
          v(-5pt)
          body
        }

        place(
          bottom + right,
        )[
          #show link : set text(fill: white)
          #text(fill: white, contributors.join("，"))
        ]
      },
    )
  }
}

// 定义命令

/// 约定条目。用绿色主题创建约定块
/// - `uuid : str` <可选> 条目的唯一标识符，用于链接引用
/// - `body : content` <#1> 约定的内容
#let 约定 = (uuid: "", body) => {
  let b
  if (type(body) == array) {
    b = list(..body)
  } else if (type(body) == content) {
    b = body
  }

  entry(
    env: "约定",
    counter_name: "variable",
    color_stroke: rgb("#00B8A0"),
    color_fill: rgb("#D0FFF1"),
    default_inline: true,
  )(uuid: uuid, "", "", b)
}

/// Hypotheses 渲染函数
#let hRender = (
  hypotheses,
  hstyle,
) => {
  if type(hypotheses) == "string" {
    hypotheses = (hypotheses,)
  }
  if (hypotheses.len() > 0) {
    if (hstyle == "display") {
      [设：#enum(..hypotheses.map(h => [#h；]))]
    } else {
      if (hypotheses.len() > 0) [设#hypotheses.join("，")，]
    }
  }
}

/// Conclusion 渲染函数
#let cRender = (
  hasHyp,
  conclusion,
  hstyle,
  cstyle,
) => {
  if (hasHyp) {
    if (hstyle == "display") {
      [则]
    } else {
      [，则]
    }
    if (cstyle == "display") {
      [：]
    }
  }
  if (cstyle == "display") {
    conclusion
  } else {
    conclusion
    [。]
  }
}

// Members 渲染函数
#let mRender = (members) => {
  enum(..members.map(member => {
    // 成员名
    strong({
      member.name
      if ("name_en" in member) [（#member.name_en）]
    })
    // 变量名与值
    if ("varName" in member) {
      $(#member.varName : #member.value)$
    } else {
      [：]
      member.value
    }
    // 分号
    if (not ("style" in member and member.style == "display")) [；]
  }))
}

// Notation 渲染函数
#let nRender = (
  notation,
  bstyle,
  nstyle,
) => {
  if (notation != []) {
    if (bstyle == "display") [记作：#notation] else [，记作：#notation]
  }
  if ((notation != [] and nstyle != "display") or (notation == [] and bstyle != "display")) [。]
}

// 公理
#let 公理 = entry(
  env: "公理",
  counter_name: "axiom",
  color_stroke: rgb("#C1C103"),
  color_fill: rgb("#FFFFAC"),
)
#let 公理块 = entry(
  env: "公理",
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
#let 规则块 = entry(
  env: "规则",
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

/// 标准化定义条目函数。提供结构化的定义显示格式，支持假设、名称、内容、记号等
/// 
/// *必填参数*：
/// 1. `title_cn : content` 定义的中文标题
/// 2. `title_en : content` 定义的英文标题
/// 3. `target : content` 被定义项的陈述
/// 4. `value : content` 定义的主体内容
/// *可选参数*：
/// - `uuid : str` 定义的唯一标识符，用于链接引用
/// - `extention : bool` 是否为扩展定义，默认 false
/// - `isPredicate : bool` 是否为谓词定义，默认 false
/// - `hypotheses : content | list` 假设内容
/// - `notation : content` 定义的记号，默认空
/// - `hstyle : str` 假设显示样式，"inline" 或 "display"，默认 "inline"
/// - `tstyle : str` 被定义项陈述显示样式，"inline" 或 "display"，默认 "inline"
/// - `bstyle : str` 主体显示样式，"inline" 或 "display"，默认 "inline"
/// - `nstyle : str` 记号显示样式，"inline" 或 "display"，默认 "inline"
/// - `contributors : list` 贡献者列表，用于显示在条目右下角，默认空
#let 定义 = (
  title_cn,
  title_en,
  target,
  value,
  uuid: "",
  isExtention: false,
  isPredicate: false,
  hypotheses: (),
  notation: [],
  hstyle: "inline",
  tstyle: "inline",
  bstyle: "inline",
  nstyle: "inline",
  contributors: (),
) => {
  定义块(uuid: uuid, title_cn, title_en, extention: isExtention, contributors: contributors, {
    // 假设
    hRender(hypotheses, hstyle)
    // 目标
    if (tstyle == "display") {
      [定义：#target]
    } else {
      [定义【#target】]
    }
    // 目标
    if (bstyle == "display") {
      if (isPredicate) [当且仅当：] else [为：] + value
    } else {
      if (isPredicate) [当且仅当] else [为] + value
    }
    // 记号
    nRender(notation, bstyle, nstyle)
  })
}

/// 标准化实例条目函数。用于展示具体实例的结构化组件
/// 
/// *必填参数*：
/// 1. `title_cn : content` 实例的中文标题
/// 2. `title_en : content` 实例的英文标题
/// 3. `target : content` 实例的目标
/// 4. `content : list` 实例的成员列表，每个元素为包含 name、name_en、varName、value 的字典
/// 5. `class : content` 实例所属的类别
/// *可选参数*：
/// - `uuid : str` 实例的唯一标识符，用于链接引用
/// - `hypotheses : content | list` 假设内容
/// - `hstyle : str` 假设显示样式，"inline" 或 "display"，默认 "inline"
/// - `extention : bool` 是否为扩展实例，默认 false
/// - `isPredicate : bool` 是否为谓词实例，默认 false
/// - `contributors : list` 贡献者列表，用于显示在条目右下角，默认空
#let 实例 = (
  uuid: "",
  title_cn,
  title_en,
  hypotheses: (),
  hstyle: "inline",
  target,
  content,
  class,
  extention: false,
  isPredicate: false,
  contributors: (),
) => {
  定义块(uuid: uuid, title_cn, title_en, extention: extention, contributors: contributors, {
    // 假设
    hRender(hypotheses, hstyle)
    // 目标
    [定义【]
    name
    [】为携带以下信息的]
    class
    [：]
    enum(..content.map(member => [
      *#member.name#if ("name_en" in member) [（#member.name_en）]*#if ("varName" in member) [ $(#member.varName):$ ] else [：]#member.value；
    ]))
  })
}

// 结构
#let 结构块 = entry(
  env: "结构",
  counter_name: "definition",
  color_stroke: rgb("#009C27"),
  color_fill: rgb("#D6FEE0"),
)

/// 标准化结构条目函数。用于定义包含特定组件的结构
/// 
/// *必填参数*：
/// 1. `title_cn : content` 结构的中文标题
/// 2. `title_en : content` 结构的英文标题
/// 3. `target : content` 结构的目标
/// 4. `members : list` 结构的成员列表，每个元素为包含 name、name_en、varName、value 的字典
/// *可选参数*：
/// - `uuid : str` 结构的唯一标识符，用于链接引用
/// - `hypotheses : content | list` 假设内容
/// - `extends : list` 继承的结构列表
/// - `hstyle : str` 假设显示样式，"inline" 或 "display"，默认 "inline"
/// - `extention : bool` 是否为扩展结构，默认 false
/// - `isPredicate : bool` 是否为谓词结构，默认 false
/// - `notation : content` 结构的记号，默认空
/// - `nstyle : str` 记号显示样式，"inline" 或 "display"，默认 "inline"
/// - `contributors : list` 贡献者列表，用于显示在条目右下角，默认空
#let 结构 = (
  uuid: "",
  title_cn,
  title_en,
  hypotheses: (),
  extends: (),
  hstyle: "inline",
  target,
  members,
  extention: false,
  isPredicate: false,
  notation: [],
  nstyle: "inline",
  contributors: (),
) => {
  结构块(uuid: uuid, title_cn, title_en, extention: extention, contributors: contributors, {
    // 假设
    hRender(hypotheses, hstyle)
    // 目标
    [定义【#target;】]
    if (extends != ()) [在#extends.join("，")的基础上]
    if (isPredicate) [当且仅当：] else [包含以下信息：]
    // 成员
    mRender(members)
    // 记号
    nRender(notation, "display", nstyle)
  })
}

// 性质
#let 性质块 = entry(
  env: "性质",
  counter_name: "property",
  color_stroke: rgb("#AC00AF"),
  color_fill: rgb("#FFEDFF"),
)

/// 标准化性质条目函数。用于展示某对象的性质或特征
/// 
/// *必填参数*：
/// 1. `title_cn : content` 性质的中文标题
/// 2. `title_en : content` 性质的英文标题
/// 3. `conclusion : content` 性质的结论
/// *可选参数*：
/// - `uuid : str` 性质的唯一标识符，用于链接引用
/// - `hypotheses : content | list` 假设内容
/// - `hstyle : str` 假设显示样式，"inline" 或 "display"，默认 "inline"
/// - `cstyle : str` 结论显示样式，"inline" 或 "display"，默认 "inline"
/// - `extention : bool` 是否为扩展性质，默认 false
/// - `contributors : list` 贡献者列表，用于显示在条目右下角，默认空
#let 性质 = (
  uuid: "",
  title_cn,
  title_en,
  hypotheses: (),
  hstyle: "inline",
  conclusion,
  cstyle: "inline",
  extention: false,
  contributors: (),
  // 下面这个废除
  bstyle: "WARNING", 
) => {
  性质块(uuid: uuid, title_cn, title_en, extention: extention, contributors: contributors, {
    // 假设
    hRender(hypotheses, hstyle)
    // 结论
    cRender(hypotheses != (), conclusion, hstyle, bstyle)
    // 废除警告
    if (bstyle != "WARNING") {
      WarningMessage.update([Warning (in command `性质`): argument `bstyle` is deprecated and will be removed in future versions. Please use `cstyle` instead.])
    }
  })
}

/// 标准化结构性质条目函数。展示结构性质及其包含的成员
/// 
/// *必填参数*：
/// 1. `title_cn : content` 结构性质的中文标题
/// 2. `title_en : content` 结构性质的英文标题
/// 3. `content : content` 性质的内容
/// *可选参数*：
/// - `uuid : str` 结构性质的唯一标识符，用于链接引用
/// - `hypotheses : content | list` 假设内容
/// - `hstyle : str` 假设显示样式，"inline" 或 "display"，默认 "inline"
/// - `members : list` 成员列表，每个元素为包含 name、name_en、varName、value 的字典
/// - `contributors : list` 贡献者列表，用于显示在条目右下角，默认空
#let 结构性质 = (
  uuid: "",
  title_cn,
  title_en,
  hypotheses: (),
  hstyle: "inline",
  content,
  members: (),
  contributors: (),
) => {
  性质块(uuid: uuid, title_cn, title_en, contributors: contributors, {
    // 假设
    hRender(hypotheses, hstyle)
    // 主体
    content
    if (members.len() > 0) [，其中：] else [。]
    // 成员
    mRender(members)
  })
}

// 定理
#let 定理块 = entry(
  env: "定理",
  counter_name: "theorem",
  color_stroke: rgb("#005B9C"),
  color_fill: rgb("#DAF0FF"),
)

/// 标准化定理条目函数。用于陈述和证明重要的数学定理
/// 
/// *必填参数*：
/// 1. `title_cn : content` 定理的中文标题
/// 2. `title_en : content` 定理的英文标题
/// 3. `conclusion : content` 定理的结论
/// *可选参数*：
/// - `uuid : str` 定理的唯一标识符，用于链接引用
/// - `hypotheses : content | list` 假设内容
/// - `hstyle : str` 假设显示样式，"inline" 或 "display"，默认 "inline"
/// - `cstyle : str` 结论显示样式，"inline" 或 "display"，默认 "inline"
/// - `extention : bool` 是否为扩展定理，默认 false
/// - `contributors : list` 贡献者列表，用于显示在条目右下角，默认空
#let 定理 = (
  uuid: "",
  title_cn,
  title_en,
  conclusion,
  hypotheses: (),
  hstyle: "inline",
  cstyle: "inline",
  extention: false,
  contributors: (),
) => {
  定理块(uuid: uuid, title_cn, title_en, extention: extention, contributors: contributors, {
    // 假设
    hRender(hypotheses, hstyle)
    // 结论
    cRender(hypotheses != (), conclusion, hstyle, cstyle)
  })
}
#let 引理块 = entry(
  env: "引理",
  counter_name: "theorem",
  color_stroke: rgb("#005B9C"),
  color_fill: rgb("#DAF0FF"),
)

/// 标准化引理条目函数。用于陈述和证明辅助性的数学命题
/// 
/// *必填参数*：
/// 1. `title_cn : content` 引理的中文标题
/// 2. `title_en : content` 引理的英文标题
/// 3. `conclusion : content` 引理的结论
/// *可选参数*：
/// - `uuid : str` 引理的唯一标识符，用于链接引用
/// - `hypotheses : content | list` 假设内容
/// - `hstyle : str` 假设显示样式，"inline" 或 "display"，默认 "inline"
/// - `cstyle : str` 结论显示样式，"inline" 或 "display"，默认 "inline"
/// - `extention : bool` 是否为扩展引理，默认 false
/// - `contributors : list` 贡献者列表，用于显示在条目右下角，默认空
#let 引理 = (
  uuid: "",
  title_cn,
  title_en,
  conclusion,
  hypotheses: (),
  hstyle: "inline",
  cstyle: "inline",
  extention: false,
  contributors: (),
) => {
  引理块(uuid: uuid, title_cn, title_en, extention: extention, contributors: contributors, {
    // 假设
    hRender(hypotheses, hstyle)
    // 结论
    cRender(hypotheses != (), conclusion, hstyle, cstyle)
  })
}

// 例
#let 例 = entry(
  env: "例",
  counter_name: "example",
  color_stroke: rgb("#7700E4"),
  color_fill: rgb("#EFDFFF"),
)

// 反例
#let 反例 = entry(
  env: "反例",
  counter_name: "counterexample",
  color_stroke: rgb("#D20022"),
  color_fill: rgb("#FFD6DC"),
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

// English

#let axm = entry(
  env: "Axiom",
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
#let dfn = entry(
  env: "Definition",
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
#let ppt = entry(
  env: "Property",
  counter_name: "property",
  color_stroke: rgb("#AC00AF"),
  color_fill: rgb("#FFEDFF"),
)
#let thm = entry(
  env: "Theorem",
  counter_name: "theorem",
  color_stroke: rgb("#005B9C"),
  color_fill: rgb("#DAF0FF"),
)
#let xmp = entry(
  env: "Example",
  counter_name: "example",
  color_stroke: rgb("#7700E4"),
  color_fill: rgb("#EFDFFF"),
)
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