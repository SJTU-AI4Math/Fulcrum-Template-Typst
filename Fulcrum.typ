#let ApplyBold = it => {
  set text(font: ("New Computer Modern", "SimHei"), weight: "bold")
  it
}

#let FulcrumCN(body) = {
  // 设置字体

  set heading(numbering: "1.1.")
  set text(font: ("New Computer Modern", "SimSun"), size: 11pt)
  set par(first-line-indent: 2em)
  set enum(indent: 2em)
  set figure(supplement: [图])
  show heading: ApplyBold
  show strong: ApplyBold
  show link: set text(weight: "regular", fill: rgb("#000080"))

  body
}

#let optionLink = (uuid, body, url: "") => {
  context {
    let elements = query(label(uuid))

    if (elements.len() > 0) {
      link(uuid)[#body]
    } else if (url != "") {
      link(url)[#body]
    } else {
      body
    }
  }
}

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
  (uuid: "", title_cn, title_en, body, inline: default_inline) => {
    envCounter.step()

    block(
      fill: color_fill,
      inset: (x: 12pt, y: 8pt),
      stroke: (left: 3pt + color_stroke),
      width: 100%,
      if not inline [
        *
        #env
        #context {
          let num = if (parentEntry != "") { [#counter(parentEntry).get().at(0)] } + envCounter.get().at(0)
          let levels = counter(heading).display()
          if (levels != "0") { [#levels#num] } else { [#num] }
        }
        : #title_cn #if title_en != "" { "(" + title_en + ")" }
        *
        #if (uuid != "") { label(uuid) }
        #v(-5pt)
        #line(length: 100%, stroke: 0.5pt + color_stroke)
        #v(-5pt)
        #body
      ] else [
        *#env: *#body
      ],
    )
  }
}

// 定义命令

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
#let 定义 = entry(
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

// 结构
#let 结构 = entry(
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

// 注
#let 注 = entry(
  env: "注",
  counter_name: "remark",
  color_stroke: rgb("#E07B00"),
  color_fill: rgb("#FFEBD2"),
  default_inline: true,
)
#let rmk = entry(
  env: "Remark",
  counter_name: "remark",
  color_stroke: rgb("#E07B00"),
  color_fill: rgb("#FFEBD2"),
  default_inline: true,
)
