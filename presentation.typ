#import "style/radboud-slides.typ": *
#import "figures.typ": *
// #import university: *

#set text(font: "New Computer Modern Sans")
#show: radboud-theme.with(aspect-ratio: "16-9",
  config-info(
    title: [Master Thesis],
    subtitle: [Implementation and Analysis of Merkle Tree Certificates for Post-Quantum Secure authentication in TLS],
    author: [Maximilian Pohl],
    date: datetime.today(),
    // institution: [Radboud University],
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
][#image("images/hero.jpg")]

== What is the Problem?
- Post-Quantum signatures are big

= Preliminaries

== Public Key Infrastructure (PKI)

== Certificate Transparency
#slide[
  #set text(size: 0.7em)
  #set align(horizon)
  #figure(ct_overview, caption: [Certificate Transparency architecture])
]

== Merkle Trees
#slide[
  #set text(size: 0.7em)
  #set align(horizon)
  #figure(merkle_tree, caption: [Example Merkle Tree])
]

== Post-Quantum Signatures

= Merkle Tree Certificates
#slide[
  #set text(size: 0.7em)
  #set align(horizon)
  #figure(mtc_terms(dist: 4em), caption: [Example Merkle Tree])
]

== Merkle Tree Certificates
#slide[
  #set text(size: 0.7em)
  #set align(horizon)
  #figure(mtc_overview, caption: [Issuance flow for Merkle Tree Certificates])
]


== Test

