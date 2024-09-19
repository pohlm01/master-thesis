#let title_page(
  title: none,
  subtitle: none,
  author: [],
  others: (),
  date: datetime.today()
) = {
  let fill = white
  // let fill = rgb("e4e5ea")
  
  set text(font: "New Computer Modern", size: 14pt)
  set align(center)
  set page(margin: 6em)
  
  grid(
    columns: (1fr),
    // rows: 8,
    gutter: 13pt,
    fill: fill,
    image("ru_title_logo.svg", width: 27%),
    smallcaps(text(size: 19pt, "Radboud University Nijmegen")),
    grid.hline(stroke: (0.5pt + black), position: bottom),
    v(1em),
    text(weight: "bold", size: 15pt, title),
    grid.hline(stroke: (0.5pt + black), position: top),
    [],
    text(style: "italic", subtitle),
  )
  box(inset: (x: 10pt, y: 20pt),
  grid(    
    columns: (1fr, 1fr),
    gutter: 3em,
    align: (start, end),
    fill: fill,
    grid.cell(rowspan: others.len(), [#text(style: "italic", "Author:") \ #author]),
    ..others.map(name => [
     #text(style: "italic", name.function + ":") \ #name.name
    ])
  ))

  v(2fr)
  date.display(
    "[month repr:long] [day], [year]"
  )
  v(1fr)

    pagebreak(weak: true)
}