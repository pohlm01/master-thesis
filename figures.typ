#import "@preview/fletcher:0.5.4" as fletcher: node, edge, shapes
#import "@preview/treet:0.1.1": *
#import "@preview/touying:0.5.5": touying-reducer, pause

#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)
#let ruRed = rgb("#B82B22");

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

#let implementation = {
  set enum(indent: 0em)

  let g(x) = {
    x.stroke = gray
    x.label = text(gray, x.label)
  }

  set align(center)
  
  fletcher.diagram(
  ..global_diagram_params,
  ..overview_params,
  spacing: (13em, 3em),
  node-inset: .5em,
  

  node((0,0), [Authenticating Party #align(horizon, box[#image("images/rustls-logo-web.png", width: 5em)])], name: <ap>),
  
  node((0,1), [Relying Party #align(horizon, box[#image("images/rustls-logo-web.png", width: 5em)])], name: <rp>),

  node((1,0), [Certification Authority #align(horizon, box[#image("images/Go-Logo.svg", width: 5em)])], name: <ca>),

  node((1,1), text(fill: gray)[Transparency Service], name: <ts>, stroke: gray, inset: 1em),
  node((rel: (1.5mm, 1.5mm)), [Transparency Service], layer: -1, stroke: gray, inset: 1em),
  
  node((1,2), text(gray)[Monitor], name: <monitor>, stroke: gray, inset: 1em),
  node((rel: (1.5mm, 1.5mm)), text(gray)[Monitor], layer: -1, stroke: gray, inset: 1em),

  edge(<ap>,  <ca>,       "-|>", shift:  6pt,                     [1. Manual issuance request]),
  edge(<ca>,          <ts>,       "-|>",              label-side: left,   text(gray)[Sign and publish tree], stroke: gray),
  edge(<ap>,  <ca>,       "<|-", shift: -6pt, label-side: right,  [2. Certificate]),
  edge(<ts>,          <monitor>,  "-|>",              label-side: left,   text(gray)[Mirror tree], stroke: gray),
  edge(<rp>,          <ts>,       "<|-",              label-side: right, label: text(gray)[Batch tree heads], stroke: gray),
  edge(<ap>,  <rp>,       "<|-", shift: -6pt, label-side: right,   [3. Known trust anchors]),
  edge(<ap>,  <rp>,       "-|>", shift:  6pt, label-side: left,   [4. Certificate]),
  edge(<ca>, <rp>, "-|>", align(center)[Manually copy validity window\ and signature], label-angle: auto, label-side: left)
)}

#let mtc_overview(highlight_update: false) = {
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
  edge(<rp>,          <ts>,       "<|-",              label-side: right, 
    ..if highlight_update{(
      stroke: ruRed + .15em,
      label: strong[5. Batch tree heads])
    } else{(
      label: [5. Batch tree heads])
    }
  ),
  edge(<ap>,  <rp>,       "<|-", shift: -6pt, label-side: right,   [6. Known trust anchors]),
  edge(<ap>,  <rp>,       "-|>", shift:  6pt, label-side: left,   [7. Certificate]),
)}

#let w(c) = text(fill: white, c)
#let w2 = (stroke: white)

#let pki_overview = {
  set enum(indent: 0em)
  
  fletcher.diagram(
  ..global_diagram_params,
  ..overview_params,

  node((0, 0), [Authenticating Party], name: <domain_owner>),
  
  node((1, 0), [Certification Authority], name: <ca>),
  
  node((1, 1), w[Logs], name: <logs>, ..w2),
  node((rel: (1.5mm, 1.5mm)), w[Logs], layer: -1, ..w2),

  node((1, 2), w[Monitors], name: <monitors>, ..w2),
  node((rel: (1.5mm, 1.5mm)), w[Monitors], layer: -1, ..w2),

  node((0, 2), [Relying Party], name: <rp>),

  edge(<domain_owner>, <ca>, "-|>", shift: 6pt, [1. Issuance request]),
  edge(<ca>, <logs>, "-|>", label-side: left, shift: 6pt, w[2. Pre-certificate], ..w2),
  edge(<logs>, <ca>, "-|>", shift: 6pt, label-side: left, w[3. SCT], ..w2),
  edge(<ca>, <domain_owner>, "-|>", shift: 6pt, label-side: left, [2. Certificate]),
  edge(<domain_owner>, <rp>, "-|>", [3. Certificate]),
  
  edge(<monitors>, <logs>, "-|>", label-side: right, w[6. Monitor for \ suspicious activity], ..w2),
  edge(<monitors>, <domain_owner>, "-|>", label-side: left, label-angle: auto, w[7. Notify about new certificates issued], ..w2),
)}

#let ct_overview = {
  set enum(indent: 0em)
  
  fletcher.diagram(
  ..global_diagram_params,
  ..overview_params,

  node((0, 0), [Authenticating Party], name: <domain_owner>),
  
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


// #let default_width = 45mm
#let al(it) = align(start, it)
#let ar(it) = align(end, it)
#let paper_protocol_diargram_params = (
  node-inset: 1mm,
  spacing: (12em, 1mm),
  cell-size: (11em, 1em + 2mm),
  node-outset: 1mm
)

#let presentation_protocol_diargram_params = (
  // node-inset: 2mm,
  spacing: (8em, .3em),
  cell-size: (11mm, 1em + 2mm),
  node-outset: 1mm,
)


#let acme_overview(default_width: 45mm, params: paper_protocol_diargram_params) = fletcher.diagram(
  ..global_diagram_params,
  ..params,

  
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

#let adapter(env: "paper", ..args) = {
  if env == "presentation" {
    fletcher-diagram(
      ..args
    )
  } else {
    fletcher.diagram(
      ..args.named(),
      ..args.pos().filter(x => x != pause)
    )
  }
}

#let tls_handshake_overview(default_width: 45mm, heading_color: black, params: paper_protocol_diargram_params, env: "paper") = adapter(
  ..global_diagram_params,
  ..params,
  env: env,
  
  node((0, 0), al(text(fill: heading_color, weight: "semibold",  "Client")), width: default_width + 4mm, stroke: gray, inset: 2mm, name: <client>),
  node((rel: (1, 0)), ar(text(fill: heading_color, weight: "semibold", "Server")), width: default_width + 4mm, stroke: gray, inset: 2mm, name: <server>),

  node((rel: (0, 1.8), to:<client>), al[Client Hello \ + key share \ + signature algorithms], width: default_width, stroke: (dash: "dotted"), name: <client_hello>),
  edge((rel: (0, 0.5), to: <client_hello>), <server_hello>, "--|>"),

  pause,
  node((rel: (1, 0.5), to: <client_hello>), ar[Server Hello \ + key share], width: default_width + 2mm, stroke: (dash: "dotted"), name: <server_hello>),
  node((rel: (0, 1), to: <server_hello>), ar[#emoji.lock #text(weight: if env == "presentation" {"bold"} else {"regular"})[Certificate]], width: default_width + 2mm, stroke: (dash: "dotted"), name: <certificate>),
  node((rel: (0, 1), to: <certificate>), ar[#emoji.lock #text(weight: if env == "presentation" {"bold"} else {"regular"})[Certificate Verify]], width: default_width + 2mm, stroke: (dash: "dotted"), name: <certifcate_verify>),
  node((rel: (0, 1), to: <certifcate_verify>), ar[#emoji.lock Finished], width: default_width + 2mm, stroke: (dash: "dotted"), name: <server_finished>),


  edge("--|>", shift: -1mm),
  
  node((rel: (-1, 0), to: <server_finished>), al[Finished  #emoji.lock], width: default_width + 2mm, stroke: (dash: "dotted"), name: <client_finished>),

  pause,
  
  edge(<server_finished>, <client_finished>, "<|--", shift: .3em),

  node((rel: (0, 1.5), to: <client_finished>), al[Application Data #emoji.lock], width: default_width + 2mm, stroke: .2mm, name: <client_data>),
  edge("<|--|>"),
  node((rel: (0, 1.5), to: <server_finished>), ar[#emoji.lock Application Data], width: default_width + 2mm, stroke: .2mm, name: <server_data>),
  
)

#let merkle_tree = fletcher.diagram(
  ..global_diagram_params,
  spacing: (1em, 1em),
  node-inset: .7em,
  node-stroke: .07em,
  {
    node((0, 0), $"root" = H_2(h_4, h_5)$, name: <root>)
    
    node((rel: (-1.4, 1), to: <root>), $h_4 = H_2(h_0, h_1)$, name: <t10>)
    node((rel: (1.4, 1), to: <root>), $h_5 = H_2(h_2, h_3)$, name: <t11>, fill: yellow)
    
    node((rel: (-0.8, 1), to: <t10>), $h_0 = H_1(x_0)$, name: <t00>, fill: yellow)
    node((rel: (0.8, 1), to: <t10>), $h_1 = H_1(x_1)$, name: <t01>)
    node((rel: (-0.8, 1), to: <t11>), $h_2 = H_1(x_2)$, name: <t02>)
    node((rel: (0.8, 1), to: <t11>), $h_3 = H_1(x_3)$, name: <t03>)

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


#let mtc_terms(dist: 2em, env: "paper") = adapter(
  ..global_diagram_params,
  spacing: (1em, 1em),
  node-shape: auto,
  node-inset: 0.4em,
  node-stroke: 0em,
  node-defocus: -1,
  env: env,
  edge-stroke: (paint: ruRed, thickness: .1em, dash: "dashed"),
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

  // pause,

  node((rel: (1, -6), to: <root0>), text(fill: ruRed, weight: "semibold", "Batch Tree Heads"), name: <tree_heads>, defocus: 4),
  edge(<tree_heads>, <root0>),
  edge(<tree_heads>, <root1>),
  edge(<tree_heads>, <root2>),
  
  pause,
  
  node((rel: (-3, -3), to: <a00>), text(fill: ruRed, weight: "semibold", "Assertions"), name: <assertions>, defocus: 4, inset: 0mm, outset: 0.4em),
  edge(<assertions>, <a00>),
  
  pause,
  
  edge((rel: (0 * dist, 0.5 * dist), to: <root0>), (rel: (0 * dist, 0.5 * dist), to: <root1>), stroke: (paint: ruRed, dash: none), "|--|", layer: 1, box(fill: white, inset: .2em, text(fill: ruRed, weight: "semibold", "Batch Duration")), label-side: left, snap-to: none, label-pos: 0.5),

  pause,
  
  edge((rel: (0.7 * dist, -0.3 * dist), to: <root0>), (rel: (0.7 * dist, -0.3 * dist), to: <root2>), stroke: (paint: ruRed, dash: none), "|--|", layer: 1, text(fill: ruRed, weight: "semibold", "Validity Window"), label-side: right, label-angle: auto, snap-to: none, label-sep: 0.5em, label-pos: 0.6)
)


#let merkle_tree_abridged_assertion(node-width: 4em) = fletcher.diagram(
  ..global_diagram_params,
  spacing: (0em, 1em),
  node-inset: .5em,
  node-stroke: .07em,

  let ar(c) = align(right, [#box(c) #h(1em)]),

  {
    node((-4, 0), ar[level 2:], stroke: none, inset: 0em, name: <level2>, width: 1.2 * node-width)
    node((rel: (0, 1), to: <level2>), ar[level 1:], stroke: none, inset: 0em,  name: <level1>, width: 1.2 * node-width)
    node((rel: (0, 1), to: <level1>), ar[level 0:], stroke: none, inset: 0em,  name: <level0>, width: 1.2 * node-width)
    node((rel: (0, 1), to: <level0>), ar[abridged\ assertion:], stroke: none, inset: 0em,  name: <aa>, width: 1.2 * node-width)
    node((rel: (0, 1), to: <aa>), ar[assertion:], stroke: none, inset: 0em,  name: <assertion>, width: 1.2 * node-width)
    
    node((0, 0), [$"root"$], name: <root>, width: node-width)
    
    node((-2, 1), $t_10$, name: <t10>, width: node-width)
    node((2, 1), $t_11$, name: <t11>, width: node-width)
    
    node((rel: (-1, 1), to: <t10>), $t_00$, name: <t00>, width: node-width)
    node((rel: (1, 1), to: <t10>), $t_01$, name: <t01>, width: node-width)
    node((rel: (-1, 1), to: <t11>), $t_02$, name: <t02>, width: node-width)
    node((rel: (1, 1), to: <t11>), [empty], name: <t03>, width: node-width)

    node((rel: (0, 1), to: <t00>), text(size: 0.6em)[$H("pk"_0)$ + \ `example.com`], name: <aa0>, width: node-width)
    node((rel: (0, 1), to: <t01>), text(size: 0.6em)[$H("pk"_1)$ + \ `13.42.50.6`], name: <aa1>, width: node-width)
    node((rel: (0, 1), to: <t02>), text(size: 0.6em)[$H("pk"_2)$ + \ `foo.bar`], name: <aa2>, width: node-width)

    node((rel: (0, 1), to: <aa0>), text(size: 0.6em)[$"pk"_0$ + \ `example.com`], name: <a0>, width: node-width)
    node((rel: (0, 1), to: <aa1>), text(size: 0.6em)[$"pk"_1$ + \ `13.42.50.6`], name: <a1>, width: node-width)
    node((rel: (0, 1), to: <aa2>), text(size: 0.6em)[$"pk"_2$ + \ `foo.bar`], name: <a2>, width: node-width)

    edge(<root>, "l,ld")
    edge(<root>, "r,rd")
    
    edge(<t10>, "ld")
    edge(<t10>, "rd")
    edge(<t11>, "ld")
    edge(<t11>, "rd")
    
    edge(<t00>, <aa0>)
    edge(<t01>, <aa1>)
    edge(<t02>, <aa2>)

    edge(<a0>, <aa0>)
    edge(<a1>, <aa1>)
    edge(<a2>, <aa2>)
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
      - \<issuer_id\>
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
  - \<issuer_id\>
    - 0.mtc
    - 240.mtc
    - ca-params
    - private-key.pem
  ]
}