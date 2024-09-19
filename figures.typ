#import "@preview/fletcher:0.5.1" as fletcher: node, edge

#let mtc_overview = fletcher.diagram(
  node-stroke: .1em,
  spacing: 4em,
  node((0,0), [Subscriber], inset: 1em),
  edge((0,0), (0,1), "-|>", shift: 6pt, label-side: left, [7. inclusion proof]),
  edge((0,0), (0,1), "<|-", shift: -6pt, [6. accepted tree heads]),
  node((0,1), [Relying Party], inset: 1em),

  node((3,0), [Certification Authority], inset: 1em),
  edge("-|>", label-side: left, [2. sign and publish tree]),
  node((3,1), [Transparency Service], inset: 1em),
  edge("-|>", label-side: left, [4. mirror tree]),
  node((3,2), [Monitors], inset: 1em),

  edge((0,0), (3,0), "-|>", shift: 6pt, [1. issuance request]),
  edge((0,0), (3,0), "<|-", shift: -6pt, label-side: right, [3. inclusion proof]),
  edge((0,1), (3,1), "<|-", label-side: right, [5. batch tree heads]),
)