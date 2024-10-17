#let report(doc, table_of_contents: true) = {
  set text(font: "New Computer Modern")

  show link: set text(fill: rgb(0, 0, 180))
  show ref: set text(fill: rgb(0, 0, 180))
  show table: set text(size: 9pt)
  set figure(gap: 1em)
  set list(indent: 2em)
  set enum(indent: 2em)

  counter(page).update(0)
  set page(numbering: "1", margin: (x: 8em, top:10em, bottom: 14em))
  set heading(numbering: "1.1")
  set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
  show par: set block(spacing: 0.55em)

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
      [],it.body.children.first(), it.body.children.slice(2, it.body.children.len()).fold([], (it, acc) => it + acc), it.fill, align(end, it.page)
    )
  }
  
  show outline.entry.where(level: 1): it => {
    v(1em, weak: true)
    grid(
      columns: (2em, auto, 1fr, auto),
    strong(it.body.children.first()),
    strong(it.body.children.at(2)),
    strong(align(end, it.page))
    )
  }


  if table_of_contents {
    show par: set block(spacing: 0.0em)
    
    heading(outlined: false, "Contents", numbering: none, level: 1)
    box(outline(title: none, fill: repeat(" .")))
  }

  doc
}

#let appendix(doc) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  
  doc
}