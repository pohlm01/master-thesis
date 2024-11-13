#import "@preview/fletcher:0.5.2" as fletcher: node, edge
#import "@preview/treet:0.1.1": *

#let global_diagram_params = (
  // debug: 3,
  mark-scale: 100%,
  node-fill: white,
  edge-stroke: .08em,
  node-shape: rect,
)

#let overview_params = (
  spacing: (12em, 4em),
  node-inset: 1em,
  node-stroke: .1em,
)

#let mtc_overview = {
  set enum(indent: 0em)
  
  fletcher.diagram(
  ..global_diagram_params,
  ..overview_params,

  node((0,0), [Authenticating Party], name: <ap>),
  
  node((0,1), [Relying Party], name: <rp>),

  node((1,0), [Certification Authority], name: <ca>),

  node((1,1), [Transparency Service], name: <ts>),
  node((rel: (1.5mm, 1.5mm)), [Transparency Service], layer: -1),
  
  node((1,2), [Monitor], name: <monitor>),
  node((rel: (1.5mm, 1.5mm)), [Monitor], layer: -1),

  edge(<ap>,  <ca>,       "-|>", shift:  6pt,                     [1. Issuance request]),
  edge(<ca>,          <ts>,       "-|>",              label-side: left,   [2. Sign and publish tree]),
  edge(<ap>,  <ca>,       "<|-", shift: -6pt, label-side: right,  [3. Inclusion proof]),
  edge(<ts>,          <monitor>,  "-|>",              label-side: left,   [4. Mirror tree]),
  edge(<rp>,          <ts>,       "<|-",              label-side: right,  [5. Batch tree heads]),
  edge(<ap>,  <rp>,       "<|-", shift: -6pt,                     [6. Known trust anchors]),
  edge(<ap>,  <rp>,       "-|>", shift:  6pt, label-side: left,   [7. Certificate]),
)
}

#let ct_overview = {
  set enum(indent: 0em)
  
  fletcher.diagram(
  ..global_diagram_params,
  ..overview_params,

  node((0, 0), [Domain Owner], name: <domain_owner>),
  
  node((1, 0), [Certification Authority], name: <ca>),
  
  node((1, 1), [Logs], name: <logs>),
  node((rel: (1.5mm, 1.5mm)), [Logs], layer: -1),

  node((1, 2), [Monitors], name: <monitors>),
  node((rel: (1.5mm, 1.5mm)), [Monitors], layer: -1),

  node((0, 2), [Relying Party], name: <rp>),

  edge(<domain_owner>, <ca>, "-|>", shift: 6pt, [1. Issuance request]),
  edge(<ca>, <logs>, "-|>", label-side: left, shift: 6pt, [2. Pre-certificate]),
  edge(<logs>, <ca>, "-|>", shift: 6pt, [3. SCT]),
  edge(<ca>, <domain_owner>, "-|>", shift: 6pt, label-side: left, [4. Certificate with SCT]),
  edge(<domain_owner>, <rp>, "-|>", [5. Certificate \ with SCT]),
  edge(<monitors>, <logs>, "-|>", label-side: right, [6. Monitor for \ suspicious activity]),
  edge(<monitors>, <domain_owner>, "-|>", label-side: left, label-angle: auto, [7. Notify about new certificates issued]),
)}


#let default_width = 45mm
#let al(it) = align(start, it)
#let ar(it) = align(end, it)
#let protocol_diargram_params = (
  node-inset: 0mm,
  spacing: (3mm, 1mm),
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

  edge((0,5), (2,5), "--|>"),

  node((2,5), align(right + top)[Server Hello], width: default_width, enclose: ((2,5), (2,6)), stroke: (dash: "dotted"), inset: 1mm),
  node((2,6), ar[\+ key share], width: default_width),
  node((2,7), ar[#emoji.lock Certificate], width: default_width + 2mm, stroke: (dash: "dotted"), inset: 1mm),
  node((2,8), ar[#emoji.lock Certificate Verify], width: default_width + 2mm, stroke: (dash: "dotted"), inset: 1mm),
  node((2,9), ar[#emoji.lock Finished], width: default_width + 2mm, stroke: (dash: "dotted"), inset: 1mm),

  edge("--|>", shift: -1mm),
  
  node((0,9), al[Finished  #emoji.lock], width: default_width + 2mm, stroke: (dash: "dotted"), inset: 1mm),
  edge((2,9), (0, 9), "<|--", shift: 1mm),

  node((0,10.5), al[Application Data #emoji.lock], width: default_width + 2mm, stroke: .2mm, inset: 1mm),
  edge("<|--|>"),
  node((2,10.5), ar[#emoji.lock Application Data], width: default_width + 2mm, stroke: .2mm, inset: 1mm),
  
)

#let merkle_tree = fletcher.diagram(
  ..global_diagram_params,
  spacing: (1em, 1em),
  node-inset: .7em,
  node-stroke: .07em,

  {
    node((-4, 0), [level 2:], stroke: none, inset: 0em)
    node((-4, 1), [level 1:], stroke: none, inset: 0em)
    node((-4, 2), [level 0:], stroke: none, inset: 0em)

    
    node((0, 0), [root], name: <root>)
    
    node((-2, 1), $t_10$, name: <t10>)
    node((2, 1), $t_11$, name: <t11>)
    
    node((-3, 2), $t_00$, name: <t00>)
    node((-1, 2), $t_01$, name: <t01>)
    node((1, 2), $t_02$, name: <t02>)
    node((3, 2), [empty], name: <t03>)

    node((-3, 3), $"aa"_0$, name: <a0>)
    node((-1, 3), $"aa"_1$, name: <a1>)
    node((1, 3), $"aa"_2$, name: <a2>)

    edge(<root>, "l,ld")
    edge(<root>, "r,rd")
    
    edge(<t10>, "ld")
    edge(<t10>, "rd")
    edge(<t11>, "ld")
    edge(<t11>, "rd")
    
    edge(<t00>, "d")
    edge(<t01>, "d")
    edge(<t02>, "d")
  }
)

#let mtc_client_file_tree = {
  set align(left)
  show list: tree-list
  set text(font: "New Computer Modern Mono")
  
  [
  etc\
  - ssl
    - mtc
      - \<tai\>
        - ca-params
        - validity-window
        - signature\*
  ]
}

#let mtc_server_file_tree = {
  set align(left)
  show list: tree-list
  set text(font: "New Computer Modern Mono")
  
  [
  \<some_dir>\
  - \<tai\>
    - 0.mtc
    - 240.mtc
    - ca-params
    - private-key.pem
  ]
}