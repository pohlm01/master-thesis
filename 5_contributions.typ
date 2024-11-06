= Development Insights

- Develop certificate verifier in Rust #link("https://github.com/pohlm01/mtc-verifier", "pohlm01/mtc-verifier")
- Integrate MTC negotiation and verification for client and server in Rustls https://github.com/pohlm01/rustls-mtc
- Fix prefix error #link("https://github.com/davidben/merkle-tree-certs/pull/90", "davidben/merkle-tree-certs#90"), #link("https://github.com/bwesterb/mtc/pull/2", "bwesterb/mtc#2"),  #link("https://github.com/bwesterb/mtc/pull/4", "bwesterb/mtc#4")
- Replace `issuer` and `batch_number` in hash structs with `batch_id` #link("https://github.com/davidben/merkle-tree-certs/pull/91", "davidben/merkle-tree-certs#91"), #link("https://github.com/bwesterb/mtc/pull/8", "bwesterb/mtc#8")
- Integrate Trust Anchor Identifiers into example CA implementation https://github.com/bwesterb/mtc/issues/3
- Use array embedding for Certificate message https://github.com/davidben/merkle-tree-certs/pull/95
- Discussion on TAI for certificate type negotiation: https://github.com/davidben/tls-trust-expressions/issues/76