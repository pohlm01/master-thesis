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
#speaker-note[
- Start with motivation
- Some background
- proposed Internet-Draft
- Performance characteristics
- Implementation
]


== Motivation
#slide(composer: (1fr, auto))[
  - Many cryptographic algorithms could be broken by quantum computers
  
  - TLS is used a lot
  
  - Confidentiality #emoji.checkmark.box
    - `X25519MLKEM768`
  
  - Server identity #emoji.crossmark
    - X.509 certificates

  #speaker-note[
    - Everyone heard the buzz word quantum computer
    - Some crypto algorithms might break
    - TLS is used for Web browsing, Email, almost any other protocol has a TLS version
    - "Hybrid key exchange in TLS 1.3" for confidentially
      - Against #emph[harvest now, decrypt later]
      - `X255-19-ML-KEM-768` previously known as Kyber
    - Server identity is still unprotected against Quantum computers
      - cannot be attacked retroactively
  ]
][#image("images/quantum-computer.jpg")]

== What is the Problem?
#slide[#{
  set text(size: 0.8em)
  set table(inset: (y: 0.5em, x: 0.3em))
  align(horizon, pq_signatures)
}
  #speaker-note[
    - X.509 certificate chains have 5 or more signatures + 2 keys
    - PQ signatures are significantly bigger (and/or worse CPU performance)
    - Listed are the winners of the NIST PQ competition
    - FN-DSA uses floating point to be fast
  ]
]

== TL;DR Fail
#slide(composer: (1fr, 1fr))[
  - Many applications, routers, and firewalls assume a single package for `ClientHello`
  
  - Big messages might be fragmented
  
  - Buggy implementations break the connection #emoji.beetle

  - Not directly applicable here, but similar

  #speaker-note[
    - many applications and middleware such as routers and firewalls assumed a single package
    - applicable to `X255-19-ML-KEM-768`
    - Some popular software still not patched (nginx ingress k8s)

    - Additionally to bugs, we want the best performance
  ]
][
  #align(horizon + center, image("images/tldr.svg"))
]

= Preliminaries


#speaker-note[
  - TLS handshake
  - the present PKI
  - CT
  - Merkle Trees
]


== Transport Layer Security (TLS)
#slide[#{
  set text(size: 0.9em)
  set align(horizon)
  figure(tls_handshake_overview(default_width: 11em, params: presentation_protocol_diargram_params, heading_color: rgb("#B82B22"), env: "presentation"),
    // caption: [Example Merkle Tree]
)}
  #speaker-note[
    - Simplified TLS handshake
    - Quick walk through
    - We concentrate on the `Certificate` (and `CertificateVerify`) message
  ]
]

== Public Key Infrastructure (PKI)
#slide[#{
  set text(size: 0.7em)
  set align(horizon)
  figure(
    pki_overview, 
  // caption: [Certificate Transparency architecture]
)}
  #speaker-note[
    - A web server (authenticating Party) requests a cert at the CA
    - CA checks the request
    - CA issues the cert
    - AP can use cert for connections with RP

    - Well: That too easy
  ]
]

== Certificate Transparency
#slide[#{
  set text(size: 0.7em)
  set align(horizon)
  figure(ct_overview, 
  // caption: [Certificate Transparency architecture]
)}
  #speaker-note[
    - Became necessary after DigiNotar was hacked
    - Certificate transparency ensures all certs are *publicly*, *verifiably* logged
    - RPs enforce the usage
    - Keep this in mind: Now switch to TLS
  ]]


== Merkle Trees
#slide[#{
  set text(size: 0.7em)
  set align(horizon)
  figure(merkle_tree,
    // caption: [Example Merkle Tree]
)}
  #speaker-note[
    - Various applications
      - Post Quantum signatures
      - Data bases
      - Certificate Transparency 
    - Used in Merkle Tree Certificates #emoji.face.explode
  ]
]

= Merkle Tree Certificates
#speaker-note[
  - Try to explain the idea
]


== The Idea
- An optional optimization in parallel to the X.509 architecture

- Use hashes instead of signatures
  - Multiple *assertions* are bundled in one *batch*
  - *Batch tree heads* are distributed to Relying Parties (Browsers)
  - Certificate contains *inclusion proof* to batch tree head
  #math.arrow.double Longer issuance delays

#speaker-note[
  
]

== A Single Batch
#slide[#{
  set text(size: 0.9em)
  set align(horizon)
  figure(merkle_tree_abridged_assertion())
}
  #speaker-note[
    - Let's zoom in to a single batch
    - bottom to top
  ]
]

== MCT Terms
#slide[#{
  set align(horizon)
  figure(mtc_terms(dist: 6em, env: "presentation"),
)}
  #speaker-note[
    - Let's zoom out a little
    - Each batch, there is a new Tree
    - The trees are independent of each other
  ]
]

== Issuance Flow
#slide[#{
  set text(size: 0.7em)
  set align(horizon)
  figure(mtc_overview(),
  // caption: [Issuance flow for Merkle Tree Certificates]
)}]

= MTC vs. X.509
#speaker-note[
  - We will concentrate on certificate size
  - Additionally, the update link between Transparency Service and Relying Party
  - The thesis also reviews CPU usage
]

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
}
  #speaker-note[
    - Comparing RSA and ECDSA with ML-DSA (and SLH-DSA), both on smallest security level
    - Huge increase in size for PQ
  ]
]

== MTC Certificate Size
#slide[#{
  set align(horizon + center)
  bikeshed_certificate_sizes(kem: false)
}
  #speaker-note[
    - Shows 280M or 2B active Authenticating parties
      - 280M is what Let's Encrypt currently has
      - 2B a an very conservative estimate for the future
    - Shows a ECDSA and RSA case
    - Shows ML-DSA  
  ]
]

== Certificate Size Comparison
#slide[#{
  set align(horizon + center)
  bikeshed_x509_size_comp
}
  #speaker-note[
    - Looks as if X.509 is smaller in the best case
      - Not true (next slide)
    - Last case is 5 times as big 
    - #text(fill: gray)[22,580 is #math.approx 15 packets (MTC 1,500 bytes)]
  ]
]

== Beyond Authentication Bytes
#slide[#{
  set list(tight: true)
  set par(leading: 0.65em, spacing: 0.65em)
  [
    - MTC uses optimized encoding
    \
    - X.509 uses ASN.1
    - X.509 has more fields
      - Not before timestamp
      #text(size: 0.8em, list([Not after timestamp]))
      #text(size: 0.6em, list[CRL endpoint])
      #text(size: 0.5em, list[OCSP endpoint])
      #text(size: 0.3em, list[SCT timestamps and log IDs])
      #text(size: 0.3em, list[Key usage restrictions])
      #text(size: 0.3em, list[Subject and authority key identifier])
    - Median X.509 certificate chain is #alternatives[3,200][*3,200*]~bytes with compression \
    \
    #pause
    #place(top + end, dx: -4em, dy: 2em, x509_size_short)
    #sym.arrow.double X.509 has a big overhead
    
  ]
}
  #speaker-note[
    - MTC uses a new "Bikeshed" certificate encoding
    \
    - X.509 uses ASN.1
    - And has additional fields
    - Median size 3.2 kB
  ]
]

= Update Mechanism
== Update Mechanism
#slide[#{
  set text(size: 0.7em)
  set align(horizon)
  figure(mtc_overview(highlight_update: true),
  // caption: [Issuance flow for Merkle Tree Certificates]
)}
  #speaker-note[
    - Remember the MTC issuance flow
    - Requires pushing the batch tree heads from the Transparency Service to the Relying Party
    - We investigated: How much data is that?
  ]
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
}
  #speaker-note[
    - The size of the update channel depends on a couple of assumptions
    - Three scenarios
    - Full update (naive)
    - Only new tree heads + *single* signature 
    - Only new tree heads
    \
    - We expect rather 15 than 150 CAs because many CA exist for political / policy reasons that are covered by "normal" CAs
    - Often, relying parties can trust the transparency service as it is their browser/OS vendor
  ]
]

== Update Mechanism Size in Comparison
#slide[#{
  show table: set text(size: 17pt)
  set par(spacing: 0.9em)
  update_mechanism_size
  [
    We approximated already existing update bandwidth \
    #box(image("images/Google_Chrome_icon.svg", height: 1.5em), baseline: 0.35em) Chrome in the order of 900~kB per day and user \
    #box(image("images/Firefox_logo.svg", height: 1.5em), baseline: 0.35em) Firefox in the order of 1,300~kB per day and user

    #line(length: 100%, stroke: gray)

    #grid(
      columns: 8,
      align: horizon + start,
      column-gutter: (0.4em, 1fr, 0.4em, 1fr, 0.4em, 1fr, 0.4em, 1fr),
      image("images/Google_logo.svg", height: 1.5em),
      [0.8 MB],
      image("images/The_New_York_Times_icon.svg", height: 1.5em),
      [2.7 MB],
      image("images/Gmail_icon.svg", height: 1.3em),
      [6.6 MB],
      image("images/Microsoft_Office_Outlook.svg", height: 1.5em),
      [10.6 MB],
    )

]}
  #speaker-note[
    - We got two comparisons to put these numbers into perspective
    - The "normal" browser updates
      - Updates every week, sometimes bigger
    - Comparisons to page loads of popular web pages that are likely to be visited regularly
  ]
]


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
    - Smaller than X.509 in all cases
    
    - Performs the signature checks ahead of time

    - Less CPU cost at client side
    
    - Revocation is not (as) necessary
  ], [
    - Short issuance delays
    
    - Does not require regular update channel
  ]
)}
#speaker-note[
  - Smaller because of encoding and metadata
  - Smaller because of less signatures
  - CPU costs are analyzed closer in the thesis
  - Revocation is very hard
  \
  - Required as a fallback
  - Relying parties can be offline
]

= Development Insights
#speaker-note[
  - Nice to analyze all these properties in theory
  - But does it actually work?
  - We 
    - implemented the spec 
    - fixed some details in the draft spec
]

== Overview
#{
  set text(size: 0.7em)
  set align(horizon) 
  figure(implementation)
}
#speaker-note[
  - We implemented the Authenticating and Relying party
  - The existed a CA implementation in Go from Bas Westerbaan, one of the authors
    - We adopted this a bit
  - We omitted the Transparency Service but copied the tree heads and signature manually
]


== Development Insights
#grid(
  columns: (auto, 1fr),
  align: (left, center),
  [
  - Adopt #emph[Rustls]
    - Add negotiation mechanisms
    - Keep state about certificate type
    - Example client/server
  - Write library for MTC verification
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

#speaker-note[
  - For the implementation
  - Used Rustls (modern, clean, Rust)
  - Add negotiation mechanism (two extensions `server_certificate_type`, `trust_anchor_identifier`)
  - Adopt code base to deal with different certificate types
  - Create an example client/server to verify that it works
  - Use self written library to verify MTCs
]

== Contributions to the Internet-Draft
#place(dx: -2em, dy: 10em,rotate(-20deg, image("images/tai-1.png", width: 20em)))
#pause
#place(dx: 10em, dy: 5em,rotate(15deg, image("images/tai-2.png", width: 23em)))
#pause
#place(dx: 0em, dy: 6em, rotate(20deg, image("images/fix-prefix-1.png", width: 20em)))
#pause
#place(dx: 13em, dy: 10em,rotate(20deg, image("images/fix-prefix-2.png", width: 20em)))
#place(dx: 2em, dy: 1em,rotate(-13deg, image("images/superseed-cert-type.png", width: 20em)))
#place(dx: 12em, dy: 3em,rotate(-25deg, image("images/fix-prefix-3.png", width: 20em)))
#place(dx: 0em, dy: 10em,rotate(26deg, image("images/ml-dsa.png", width: 20em)))
#place(dx: 2em, dy: 3em,rotate(22deg, image("images/file-structure.png", width: 20em)))

#speaker-note[
  - Added a couple of fixes and improvements to
  - the draft spec
  - the Go implementation of the CA
]

== Conclusion
#slide[
  #align(horizon, {
  [
    #set list(marker: emoji.checkmark.box) 
    - Merkle Tree Certificates work #emoji.face.party
    - We showed a working implementation
    - Improved the Internet-Draft
    - The update channel bandwidth is reasonable
    - Classical and especially post-quantum certificates are a lot smaller
    \
    #set list(marker: emoji.construction) 
    - Design and implement the update mechanism
    - Real world experiments
]})
  #speaker-note[
    - 
  ]
]

= Questions?

= Thank you!