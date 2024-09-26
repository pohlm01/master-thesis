#import "@preview/fletcher:0.5.1" as fletcher: node, edge

#let global_diagram_params = (
  // debug: 3,
  mark-scale: 150%,
  node-fill: white,
)

#let mtc_overview = {
  set enum(indent: 0em)
  
  fletcher.diagram(
  ..global_diagram_params,
  node-stroke: .1em,
  spacing: 4em,
  node-inset: 1em,
  node((0,0), [Subscriber], name: <subscriber>),
  
  node((0,1), [Relying Party], name: <rp>),

  node((3,0), [Certification Authority], name: <ca>),
  
  node((3,1), [Transparency Service], name: <ts>),
  node((rel: (1.5mm, 1.5mm)), [Transparency Service], layer: -1),
  
  node((3,2), [Monitor], name: <monitor>),
  node((rel: (1.5mm, 1.5mm)), [Monitor], layer: -1),

  edge(<subscriber>,  <ca>,       "-|>", shift:  6pt,                     [1. issuance request]),
  edge(<ca>,          <ts>,       "-|>",              label-side: left,   [2. sign and publish tree]),
  edge(<subscriber>,  <ca>,       "<|-", shift: -6pt, label-side: right,  [3. inclusion proof]),
  edge(<ts>,          <monitor>,  "-|>",              label-side: left,   [4. mirror tree]),
  edge(<rp>,          <ts>,       "<|-",              label-side: right,  [5. batch tree heads]),
  edge(<subscriber>,  <rp>,       "<|-", shift: -6pt,                     [6. accepted tree heads]),
  edge(<subscriber>,  <rp>,       "-|>", shift:  6pt, label-side: left,   [7. inclusion proof]),
)
}


#let default_width = 45mm
#let al(it) = align(start, it)
#let ar(it) = align(end, it)
#let protocol_diargram_params = (
  node-inset: 0mm,
  spacing: (3mm, 0mm),
  cell-size: (default_width + 5mm, 5mm),
  node-outset: 0mm,
)


#let acme_overview = fletcher.diagram(
  ..global_diagram_params,
  ..protocol_diargram_params,

  
  node((0, 0), al[Client], width: default_width + 4mm, stroke: gray, inset: 2mm),
  node((2, 0), ar[Server], width: default_width + 4mm, stroke: gray, inset: 2mm),

  node((0, 2), al[Order], width: default_width),
  edge("-solid"),
  node((2, 2), " ", width: default_width),
  node((2, 3), ar[Required Authorizations], width: default_width, name: <ra>),
  edge("-solid"),
  node((0, 3), " ", width: default_width),
  node((0, 5), al[Responses], width: default_width),
  edge("-solid"),
  node((2, 5), " ", width: default_width),
  edge((0, 7), (2,7), [Validation], "--")
  
  // node((0, 3), al[ToS Agreement], width: default_width, name: <ta>, fill: silver),
  // node((0, 4), al[Additional Data], width: default_width, name: <ad>, fill: silver),
  // node((0, 5), al[Signature], width: default_width, name: <sig>, fill: gray),
  // node((0, 5), width: default_width, enclose: (<ci>, <ta>, <ad>), fill: silver),
)

#let tls_handshake_overview = fletcher.diagram(
  ..global_diagram_params,
  ..protocol_diargram_params,
  
  node((0, 1), al[Client], width: default_width + 4mm, stroke: gray, inset: 2mm),
  node((2, 1), ar[Server], width: default_width + 4mm, stroke: gray, inset: 2mm),
  

  node((0,3), align(left + top)[Client Hello], width: default_width, enclose: ((0,3),(0,5)), stroke: (dash: "dotted"), inset: 1mm),
  node((0,4), al[\+ key share], width: default_width),
  node((0,5), al[\+ signature algorithms], width: default_width),

  edge((0,5), (2,5), "--solid"),

  node((2,5), align(right + top)[Server Hello], width: default_width, enclose: ((2,5), (2,6)), stroke: (dash: "dotted"), inset: 1mm),
  node((2,6), ar[\+ key share], width: default_width),
  node((2,7), ar[#emoji.lock Certificate], width: default_width + 2mm, stroke: (dash: "dotted"), inset: 1mm),
  node((2,8), ar[#emoji.lock Certificate Verify], width: default_width + 2mm, stroke: (dash: "dotted"), inset: 1mm),
  node((2,9), ar[#emoji.lock Finished], width: default_width + 2mm, stroke: (dash: "dotted"), inset: 1mm),

  edge((2,9), (0,9), "--solid"),
  
  node((0,9), al[Finished  #emoji.lock], width: default_width + 2mm, stroke: (dash: "dotted"), inset: 1mm),

  node((0,10.5), al[Application Data #emoji.lock], width: default_width + 2mm, stroke: .2mm, inset: 1mm),
  edge((0,10.5), (2,10.5), "solid--solid"),
  node((2,10.5), ar[#emoji.lock Application Data], width: default_width + 2mm, stroke: .2mm, inset: 1mm),
  
)