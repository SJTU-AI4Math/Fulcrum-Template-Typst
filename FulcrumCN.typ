#let FulcrumCN(body) = {
  // 设置字体

  set heading(numbering: "1.1.")
  set text(font: ("New Computer Modern", "SimSun"), size: 11pt)
  show strong: set text(font: ("New Computer Modern", "SimHei"), weight: "bold")

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
  color_stroke: rgb("#000000"),
  color_fill: rgb("#DDDDDD"),
  parentEntry: "",
) = {
  // 创建计数器
  let envCounter = counter(env)

  // 返回条目函数
  (uuid: "", title_cn, title_en, body) => {
    envCounter.step()

    block(
      fill: color_fill,
      inset: (x: 12pt, y: 8pt),
      stroke: (left: 3pt + color_stroke),
      width: 100%,
      [
        *#env
        #context {
          let num = if (parentEntry != "") { [#counter(parentEntry).get().at(0)] } + envCounter.get().at(0)
          let levels = counter(heading).display()
          if (levels != "0") { [#levels#num] } else { [#num] }
        }
        : #title_cn #if title_en != "" { "(" + title_en + ")" }*
        #if (uuid != "") { label(uuid) }
        #v(-5pt)
        #line(length: 100%, stroke: 0.5pt + color_stroke)
        #v(-5pt)
        #body
      ],
    )
  }
}

// 定义命令
#let dfn = entry(
  env: "定义",
  color_stroke: rgb("#009C27"),
  color_fill: rgb("#D6FEE0"),
)
#let thm = entry(
  env: "定理",
  color_stroke: rgb("#005B9C"),
  color_fill: rgb("#DAF0FF"),
)
