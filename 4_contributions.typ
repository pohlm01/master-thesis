= Contributions

- Develop certificate verifier in Rust #link("https://github.com/pohlm01/mtc-verifier", "pohlm01/mtc-verifier")
- Fix prefix error #link("https://github.com/davidben/merkle-tree-certs/pull/90", "davidben/merkle-tree-certs#90"), #link("https://github.com/bwesterb/mtc/pull/2", "bwesterb/mtc#2"),  #link("https://github.com/bwesterb/mtc/pull/4", "bwesterb/mtc#4")
- Replace `issuer` and `batch_number` in hash structs with `batch_id` #link("https://github.com/davidben/merkle-tree-certs/pull/91", "davidben/merkle-tree-certs#91"), #link("https://github.com/bwesterb/mtc/pull/8", "bwesterb/mtc#8")

== Open Questions
- Do we need the `server_certificate_type` and `client_certificate_type` extensions of RFC 7250 (Raw Public Keys) or isn't the Trust Anchor enough?