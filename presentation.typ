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
    subtitle: [Implementation and Analysis of Merkle Tree Certificates for Post-Quantum Secure authentication in TLS],
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
#slide[
  #set text(size: 0.8em)
  #set table(inset: (y: 0.5em, x: 0.3em))
  #align(horizon, pq_signatures)
]

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
#slide[
  #set text(size: 0.7em)
  #set align(horizon)
  #figure(pki_overview, 
  // caption: [Certificate Transparency architecture]
)
]

== Certificate Transparency
#slide[
  #set text(size: 0.7em)
  #set align(horizon)
  #figure(ct_overview, 
  // caption: [Certificate Transparency architecture]
)
]

== Transport Layer Security (TLS)
#slide[
  #set text(size: 0.9em)
  #set align(horizon)
  #figure(tls_handshake_overview(default_width: 11em, params: presentation_protocol_diargram_params, heading_color: rgb("#B82B22")),
    // caption: [Example Merkle Tree]
)
]

== Merkle Trees
#slide[
  #set text(size: 0.7em)
  #set align(horizon)
  #figure(merkle_tree,
    // caption: [Example Merkle Tree]
)
]

= Merkle Tree Certificates

== Merkle Tree Certificates (MTC)
#slide[
  #set text(size: 0.7em)
  #set align(horizon)
  #figure(mtc_overview(),
  // caption: [Issuance flow for Merkle Tree Certificates]
)
]

== MCT Terms
#slide[
  #set align(horizon)
  #figure(mtc_terms(dist: 5em, env: "presentation"),
)
]

== A Single Batch
#slide[
  #set text(size: 0.9em)
  #set align(horizon)
  #figure(merkle_tree_abridged_assertion())
]

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
#slide[
  #set align(horizon + center)
  #x509_certificate_sizes(kem: false)
]

== MTC Certificate Size
#slide[
  #set align(horizon + center)
  #bikeshed_certificate_sizes(kem: false)
]

== Certificate Size Comparison
#slide[
  #set align(horizon + center)
  #bikeshed_x509_size_comp
]

== Beyond Authentication Bytes
#set list(tight: true)
#set par(leading: 0.65em, spacing: 0.65em)
- MTC uses optimized encoding
- X.509 uses ANS.1
- X.509 has more fields
  - Not before timestamp
  #text(size: 0.8em, list([Not after timestamp]))
  #text(size: 0.7em, list[Not after timestamp])
  #text(size: 0.6em, list[CRL endpoint])
  #text(size: 0.5em, list[OCSP endpoint])
  #text(size: 0.3em, list[SCT timestamps and log IDs])
  #text(size: 0.3em, list[Key usage restrictions])
  #text(size: 0.3em, list[Subject and authority key identifier])
- Median X.509 certificate is 3.2~kB with compression \
#sym.arrow.double X.509 has a big overhead

== Update Mechanism
#slide[
  #set text(size: 0.7em)
  #set align(horizon)
  #figure(mtc_overview(highlight_update: true),
  // caption: [Issuance flow for Merkle Tree Certificates]
)
]

== Update Mechanism Size
#show table.cell: it => {
  if it.x == 0 or it.y == 1 {
    strong(it)
  } else {
    it
  }
}

#show table: set text(size: 17pt)

- Depends on
  - Number of CAs #text(fill: gray)[150/15]
  - Batch duration #text(fill: gray)[1 hour]
  - Validity Window #text(fill: gray)[14 days]
  - CA signature algorithm #text(fill: gray)[SLH-DSA-128s]
  - Update frequency #text(fill: gray)[every 6 hours]
// #pause
- Three scenarios
#table(
  columns: 5,
  table.header(
    [], table.cell(colspan: 2)[Per update], table.cell(colspan: 2)[Per day],
    [], [150 CAs], [15 CAs], [150 CAs], [15 CAs],
  ),
  [A full update for every fetch], [2.8~MB], [280~kB], [-], [-],
  [Only new Signed Tree Heads + Signature], [1.2~MB], [120~kB], [4.8~MB], [480~kB],
  [Only new Signed Tree Heads], [29.4~kB], [2.94~kB], [117.6~kB], [11.76~kB]
)

