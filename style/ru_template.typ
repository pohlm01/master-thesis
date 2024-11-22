#let report(doc, table_of_contents: true) = {
  set text(font: "New Computer Modern")

  show link: set text(fill: rgb(0, 0, 180))
  show ref: set text(fill: rgb(0, 0, 180))
  show table: set text(size: 8pt)
  set figure(gap: 1em)
  set list(indent: 2em)
  set enum(indent: 2em)
  set bibliography(style: "./ieee.csl")
  set cite(style: "./ieee.csl")
  // set cite(style: "springer-basic")

  show figure.caption: set par(first-line-indent: 0em, hanging-indent: 1cm)
  show figure.caption: cap => {
    // cap.body = box(cap.body)
    box(align(left, cap))
  }
  show figure: set block(spacing: 2em)
  show list: set block(spacing: 2em)
  show enum: set block(spacing: 2em)

  set quote(block: true)
  show quote: set block(above: 1em, below: 1em)
  show quote.where(block: true): set text(style: "normal", font: "DejaVu Sans Mono", size: 0.75em)


  set heading(numbering: "1.1")
  set par(spacing: 0.55em, leading: 0.55em, first-line-indent: 1.8em, justify: true)

  show heading: it => block({
    if counter(heading).get() != (0,) {
      box(counter(heading).display(), inset: (right: 1em))
    }
    it.body
  })
  
  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(4em)
    block(text(25pt, it,), below: 2.5em)
  }

  show heading.where(level: 2): it => {
    block(text(size: 17pt, it), below: 1.5em, above: 2em)
  }
  
  show heading.where(level: 3): set text(size: 15pt)

  
  show outline.entry: it => {
    grid(
      gutter: (0pt, 0pt, 0pt, 10pt),
      columns: (5pt * calc.binom(it.level - 1, 2) + (it.level - 1) * 2em, 5pt * (it.level - 1) + 2em, auto, 1fr, auto),
      [], link(it.element.location(), it.body.children.first()), link(it.element.location(), it.body.children.slice(2, it.body.children.len()).fold([], (it, acc) => it + acc)), link(it.element.location(), it.fill), link(it.element.location(), align(end, it.page))
    )
  }
  
  show outline.entry.where(level: 1): it => {
    v(1em, weak: true)
    grid(
      columns: (2em, auto, 1fr, auto),
    strong(link(it.element.location(), it.body.children.first())),
    strong(link(it.element.location(), it.body.children.at(2))),
    strong(link(it.element.location(), align(end, it.page)))
    )
  }


  if table_of_contents {
    set par(spacing: 0.0em)
    
    heading(outlined: false, "Contents", numbering: none, level: 1)
    box(outline(title: none, fill: repeat(" .")))
  }

  counter(page).update(0)
  set page(numbering: "1", margin: (x: 8em, top:10em, bottom: 14em))

  doc
}

#let appendix(doc) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  
  doc
}