#import "@preview/fletcher:0.5.2" as fletcher: node, edge, shapes
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
  edge(<ap>,  <rp>,       "<|-", shift: -6pt, label-side: right,   [6. Known trust anchors]),
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
  edge(<logs>, <ca>, "-|>", shift: 6pt, label-side: left, [3. SCT]),
  edge(<ca>, <domain_owner>, "-|>", shift: 6pt, label-side: left, [4. Certificate with SCTs]),
  edge(<domain_owner>, <rp>, "-|>", [5. Certificate \ with SCTs]),
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
    // node((-4, 0), [level 2:], stroke: none, inset: 0em)
    // node((-4, 1), [level 1:], stroke: none, inset: 0em)
    // node((-4, 2), [level 0:], stroke: none, inset: 0em)

    
    node((0, 0), $"root" = H_2(h_4, h_5)$, name: <root>)
    
    node((rel: (-1.4, 1), to: <root>), $h_4 = H_2(h_0, h_1)$, name: <t10>)
    node((rel: (1.4, 1), to: <root>), $h_5 = H_2(h_2, h_3)$, name: <t11>, fill: yellow)
    
    node((rel: (-0.8, 1), to: <t10>), $h_0 = H_1(x_0)$, name: <t00>, fill: yellow)
    node((rel: (0.8, 1), to: <t10>), $h_1 = H_1(x_1)$, name: <t01>)
    node((rel: (-0.8, 1), to: <t11>), $h_2 = H_1(x_2)$, name: <t02>)
    node((rel: (0.8, 1), to: <t11>), $h_3 = H_1(x_4)$, name: <t03>)

    node((rel: (0, 1), to: <t00>), $x_0$, name: <a0>)
    node((rel: (0, 1), to: <t01>), $x_1$, name: <a1>, fill: yellow)
    node((rel: (0, 1), to: <t02>), $x_2$, name: <a2>)
    node((rel: (0, 1), to: <t03>), $x_3$, name: <a3>)

    edge(<root>, <t10>, stroke: red + 1mm)
    edge(<root>, <t11>)
    
    edge(<t10>, <t00>)
    edge(<t10>, <t01>, stroke: red + 1mm)
    edge(<t11>, <t02>)
    edge(<t11>, <t03>)
    
    edge(<t00>, "d")
    edge(<t01>, "d", stroke: red + 1mm)
    edge(<t02>, "d")
    edge(<t03>, "d")
  }
)

#let mtc_terms(dist: 2em) = fletcher.diagram(
  ..global_diagram_params,
  spacing: (1em, 1em),
  node-shape: auto,
  node-inset: 0.4em,
  node-stroke: 0em,
  node-defocus: -1,
  edge-stroke: (paint: blue, thickness: .1em, dash: "dashed"),
  let w(c) = text(fill: white.transparentize(100%), c),
  let c(x, y, z) = (rel: (1.2 * z * dist, 0.5 * z * dist), to: (x , y)),

  let nl(pos, name: <none>, layer: 0, ..content) = {
    node(
      pos,
      name: name,
      layer: layer,
      stroke: .07em + black.lighten(-layer * 40%),
      inset: .7em,
      fill: white.transparentize(40%),
      // width: 2.8em,
      // height: 2.2em,
      ..content.pos().map(c => text(fill: black.lighten(-layer * 40%), c)),
    )
  },

  let e(layer: 0, ..arguments) = {
    edge(..arguments, layer: layer, stroke: (paint: black.lighten(layer * -40%), thickness: 0.07em, dash: none))
  },
  
  for layer in (0, -1, -2) {
    nl(c(0, 0, -layer), $"root"_#str(-layer)$, name: label("root" + str(-layer)), layer: layer)
    
    nl((rel: (-2 * dist, -dist), to: label("root" + str(-layer))), name: label("t10" + str(-layer)), layer: layer)
    nl((rel: (2 * dist, -dist), to: label("root" + str(-layer))), name: label("t11" + str(-layer)), layer: layer)
    
    nl((rel: (-dist, -dist), to: label("t10" + str(-layer))), w($"aa"_1$), name: label("a0" + str(-layer)), layer: layer)
    nl((rel: (dist, -dist), to: label("t10" + str(-layer))), w($"aa"_1$), name: label("a1" + str(-layer)), layer: layer)
    nl((rel: (-dist, -dist), to: label("t11" + str(-layer))), w($"aa"_2$), name: label("a2" + str(-layer)), layer: layer)
    nl((rel: (dist, -dist), to: label("t11" + str(-layer))), w($"aa"_3$), name: label("a3" + str(-layer)), layer: layer)

    e(label("root" + str(-layer)), label("t10" + str(-layer)), layer: layer)
    e(label("root" + str(-layer)), label("t11" + str(-layer)), layer: layer)
    
    e(label("t10" + str(-layer)), label("a0" + str(-layer)), layer: layer)
    e(label("t10" + str(-layer)), label("a1" + str(-layer)), layer: layer)
    e(label("t11" + str(-layer)), label("a2" + str(-layer)), layer: layer)
    e(label("t11" + str(-layer)), label("a3" + str(-layer)), layer: layer)
  },

  node((rel: (1, -5), to: <root0>), [Batch Tree Heads], name: <tree_heads>, defocus: 4),
  edge(<tree_heads>, <root0>),
  edge(<tree_heads>, <root1>),
  edge(<tree_heads>, <root2>),

  node((rel: (-3, -3), to: <a00>), [Assertions], name: <assertions>, defocus: 4),
  edge(<assertions>, <a00>),

)

#let merkle_tree_abridged_assertion = fletcher.diagram(
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