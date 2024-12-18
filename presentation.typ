#import "style/radboud-slides.typ": *
#import "figures.typ": *
#import "tables.typ": *

#set text(font: "New Computer Modern Sans")
#set list(marker: (sym.bullet, [--]))
#set table(inset: (x: 0.3em, y: 0.5em), align: horizon)
#set figure(supplement: none)

#show table: set text(size: 17.9pt)

#show: radboud-theme.with(aspect-ratio: "16-9",
  config-info(
    title: [Master Thesis],
    subtitle: [Implementation and Analysis of Merkle Tree Certificates for Post-Quantum Secure Authentication in TLS],
    author: [Maximilian Pohl],
    date: datetime.today(),
    logo: image("style/Radboud.svg"),
  ),
)

#title-slide()

= Motivation

== Motivation
#slide(composer: (1fr, auto))[
  - Many cryptographic algorithms could be broken by quantum computers
  
  - TLS is used a lot
  
  - Confidentiality #emoji.checkmark.box
  
  - Server identity #emoji.crossmark
][#image("images/quantum-computer.jpg")]

== What is the Problem?
#slide[#{
  set text(size: 0.8em)
  set table(inset: (y: 0.5em, x: 0.3em))
  align(horizon, pq_signatures)
}]

== TL;DR Fail
#slide[
  - Big messages might be fragmented
  
  - Buggy implementations break the connection #emoji.beetle

  - Not directly applicable here, but similar
][
  #image("images/tldr.svg")
]

= Preliminaries

== Public Key Infrastructure (PKI)
#slide[#{
  set text(size: 0.7em)
  set align(horizon)
  figure(pki_overview, 
  // caption: [Certificate Transparency architecture]
)}]

== Certificate Transparency
#slide[#{
  set text(size: 0.7em)
  set align(horizon)
  figure(ct_overview, 
  // caption: [Certificate Transparency architecture]
)}]

== Transport Layer Security (TLS)
#slide[#{
  set text(size: 0.9em)
  set align(horizon)
  figure(tls_handshake_overview(default_width: 11em, params: presentation_protocol_diargram_params, heading_color: rgb("#B82B22")),
    // caption: [Example Merkle Tree]
)}]

== Merkle Trees
#slide[#{
  set text(size: 0.7em)
  set align(horizon)
  figure(merkle_tree,
    // caption: [Example Merkle Tree]
)}]

= Merkle Tree Certificates
== A Single Batch
#slide[#{
  set text(size: 0.9em)
  set align(horizon)
  figure(merkle_tree_abridged_assertion())
}]

== MCT Terms
#slide[#{
  set align(horizon)
  figure(mtc_terms(dist: 5em, env: "presentation"),
)}]

== Overall Architecture
#slide[#{
  set text(size: 0.7em)
  set align(horizon)
  figure(mtc_overview(),
  // caption: [Issuance flow for Merkle Tree Certificates]
)}]

= MTC vs. X.509
== Certificate Size
- Authentication-related bytes only
- X.509
  - Handshake signature
  - OCSP + 2 x SCT signatures
  - End-Entity certificate signature + public key
  - Intermediate certificate signature + public key
- MTC
  - Proof length #sym.arrow.double number of assertions per batch
  - Public key
  - Handshake signature
  
== X.509 Certificate Size
#slide[#{
  set align(horizon + center)
  x509_certificate_sizes(kem: false)
}]

== MTC Certificate Size
#slide[#{
  set align(horizon + center)
  bikeshed_certificate_sizes(kem: false)
}]

== Certificate Size Comparison
#slide[#{
  set align(horizon + center)
  bikeshed_x509_size_comp
}]

== Beyond Authentication Bytes
#slide[#{
  set list(tight: true)
  set par(leading: 0.65em, spacing: 0.65em)
  [
    - MTC uses optimized encoding
    - X.509 uses ANS.1
    - X.509 has more fields
      - Not before timestamp
      #text(size: 0.8em, list([Not after timestamp]))
      #text(size: 0.6em, list[CRL endpoint])
      #text(size: 0.5em, list[OCSP endpoint])
      #text(size: 0.3em, list[SCT timestamps and log IDs])
      #text(size: 0.3em, list[Key usage restrictions])
      #text(size: 0.3em, list[Subject and authority key identifier])
    - Median X.509 certificate is 3.2~kB with compression \
    #sym.arrow.double X.509 has a big overhead
  ]
}]


== Update Mechanism
#slide[#{
  set text(size: 0.7em)
  set align(horizon)
  figure(mtc_overview(highlight_update: true),
  // caption: [Issuance flow for Merkle Tree Certificates]
)}
]

== Update Mechanism Size
#slide[#{
  set par(leading: 0.65em, spacing: 0.65em)
  show table: set text(size: 17pt)
  [
    - Depends on
      - Number of CAs #text(fill: gray)[150/15]
      - Batch duration #text(fill: gray)[1 hour]
      - Validity Window #text(fill: gray)[14 days]
      - CA signature algorithm #text(fill: gray)[SLH-DSA-128s]
      - Update frequency #text(fill: gray)[every 6 hours]
    #pause
    - Three scenarios
  ]
  update_mechanism_size
}]

== Update Mechanism Size in Comparison
#slide[#{
  show table: set text(size: 17pt) 
  update_mechanism_size
  [
    We approximated already existing update bandwidth \
    #box(image("images/Google_Chrome_icon.svg", height: 1.5em), baseline: 0.35em) Chrome in the order of 900~kB per day and user \
    #box(image("images/Firefox_logo.svg", height: 1.5em), baseline: 0.35em) Firefox in the order of 1,300~kB per day and user
]}]


// - Chrome stable updates once a week
//   - Patch updates are typically 3–5 MB (every week)
//   - Subsequent updates from one version to the next are approximately 10-15 MB (every month)
//   - Everything else is approximately 50 MB
//   - $3 dot 4 + 13 = 25$ MB per month #sym.arrow.double in the order of one MB per day
// - Firefox major updates approx. once a month
//   - patch updates are irregular, about every 1 - 2 weeks
//   - Any update takes about 10 - 20 MB
//   - $3 dot 15 = 45$ MB per month #sym.arrow.double in the order of 1 - 1.5 MB per day


== MTC vs. X.509
#{
  show table: set text(size: 24pt)
  table(
  stroke: none,
  column-gutter: 1em,
  row-gutter: 20pt,
  columns: (1fr, 1fr),
  align: top,
  table.header(
    strong([Pro MTC]), strong[Pro X.509]
  ),
  [
    - MTC is smaller than X.509 in all cases
    
    - MTC can perform the certificate signature checks ahead of time
    
    - Revocation is not (as) necessary
  ], [
    - Longer issuance delays
    
    - Requires regular update channel
  ]
)}


== Development Insights
#grid(
  columns: (auto, 1fr),
  align: (left, center),
  [
  - Adopt #emph[Rustls]
    - Add negotiation mechanisms
    - Keep state about certificate type
    - Example client/server
  - Write crate for MTC verification
    - On startup
      - Read available certs from disk
      - Verify CA signatures
    - On connection
      - Check inclusion proof
],
  grid(
    row-gutter: 2em,
    image("images/rustls-logo-web.png", height: 40%),
    image("images/Rust_logo.svg", height: 40%)
))

== Contributions to the Internet-Draft
#grid(
  columns: 2,
  gutter: 3mm,
  image("images/fix-prefix-1.png"),
  image("images/fix-prefix-2.png"),
  image("images/fix-prefix-3.png"),
  image("images/tai-1.png"),
  image("images/tai-2.png"),
  image("images/ml-dsa.png"),
  image("images/file-structure.png"),
  image("images/superseed-cert-type.png"),
)

== Conclusion
#slide[#{
  set list(marker: emoji.checkmark.box)
  [
    - Merkle Tree Certificates work #emoji.face.party
    
    - The implementation is backward-compatible
    
    - Classical and especially post-quantum certificates are a lot smaller
    
    - The update channel bandwidth is reasonable
]}]
