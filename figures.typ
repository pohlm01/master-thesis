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


#let acme_overview = fletcher.diagram(
  let default_width = 45mm,
  node-inset: 0mm,
  debug: 3,
  spacing: (3mm, 0mm),
  cell-size: (default_width + 5mm, 5mm),
  node-outset: 0mm,
  mark-scale: 150%,
  
  node((0, 0), align(left)[Client], width: default_width + 4mm, stroke: gray, inset: 2mm),
  node((2, 0), align(right)[Server], width: default_width + 4mm, stroke: gray, inset: 2mm),

  node((0, 2), align(left)[Order], width: default_width),
  edge("-solid"),
  node((2, 2), " ", width: default_width),
  node((2, 3), align(right)[Required Authorizations], width: default_width, name: <ra>),
  edge("-solid"),
  node((0, 3), " ", width: default_width),
  node((0, 5), align(left)[Responses], width: default_width),
  edge("-solid"),
  node((2, 5), " ", width: default_width),
  edge((0, 7), (2,7), [Validation], "--")
  
  



  
  // node((0, 3), align(left)[ToS Agreement], width: default_width, name: <ta>, fill: silver),
  // node((0, 4), align(left)[Additional Data], width: default_width, name: <ad>, fill: silver),
  // node((0, 5), align(left)[Signature], width: default_width, name: <sig>, fill: gray),
  // node((0, 5), width: default_width, enclose: (<ci>, <ta>, <ad>), fill: silver),
)