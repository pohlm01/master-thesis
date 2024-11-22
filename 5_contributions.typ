#import "imports.typ": *

= Development Insights

As part of this work, we implemented parts of the @mtc system and contributed to the standardization process.
The objective was to establish a @tls connection between an @ap and @rp, and to contribute enhancements or address errors or ambiguities in the Internet-Draft along the way.

Our starting point was an experimental software written in Go that can function as an @mtc @ca @go_mtc_ca.
Furthermore, we used the @tls library #emph[Rustls] @github_rustls as a basis.
Rustls is written in the programming language Rust @rust, but already gains adoption beyond the Rust ecosystem @lets_encrypt_rustls @rustls_openssl_nginx.
Rustls uses a separate library for checking certificates, called #emph[WebPKI] @github_rustls_webpki.
In the Rust ecosystem, libraries are referred to as #emph[crates].

The integration of @mtc into Rustls necessitated numerous modifications.
First, we added the negotiation mechanism for the certificate type, based on RFC~7250 @rfc_raw_public_keys.
The negotiation mechanism relies on extensions exchanged during the `ClientHello` and `ServerHello` messages.
This adoption entailed several changes to the Rustls code base, as it needs to keep state about which certificate type was negotiated.
Previously, it assumed X.509 certificates and related structures like stapled @ocsp responses at various places.
In addition to the negotiation of the certificate type, we implemented the negotiation mechanism for the #glspl("tai", long: true) as described in another Internet-Draft @rfc_tai.
Therefore, we had to extend the certificate selection logic to first match on the requested @tai:pl and fall back to the previously used @sni based certificate selection.
We simplified the @tai negotiation in that the client does not preselect the @tai:pl it requests in the `ClientHello` based a @dns query, to simplify the implementation and testing.
// Instead, the client sends all the @tai:pl it supports, which is only a very limited set in our test setup.
// In a real deployment, this is not practical due to the possibly large set of supported @tai:pl and fingerprinting possibilities.

For checking X.509 certificates, Rustls uses the WebPKI crate.
Similarly, we developed an @mtc verifier crate @github_mtc_verifier.
Specifically, it reads the supported Trust Anchors from `/etc/ssl/mtc` and verifies the @ca signature over the validity window as proposed in @sec:update_size.
On startup, the library automatically loads all validated root tree heads into memory and also allows triggering a reload during runtime.
For each @tls handshake that negotiated to use @mtc as certificate type, the crate parses the server certificate, rebuilds the path though the Merkle Tree, checks if the recomputed tree head matches the stored, and calculates the validity window based on the stored @ca parameters and batch number in the certificate.
If everything works successful, the server certificate validates.
Note that there is no signature validation necessary during the certificate validation, as the @ca signature was checked when loading the tree heads into memory.

Along the way, the @ca implementation required a few adoptions.
First, we found a mismatch between the test vectors provided in the Internet-Draft and the specification due to a 16 instead of 8-bit length encoding.
We adopted the @ca implementation and standard accordingly @fix_mtc_length_prefix_1 @fix_mtc_length_prefix_2 @fix_mtc_length_prefix_3.
Later, the Internet-Draft switched to using @tai:pl for identifying the batches instead of a issuer ID and batch number specific to @mtc.
This change left some inconsistencies in the specification, which we fixed together with some improvements in the data structures @fix_consitently_use_tai.
We also implemented the usage of @tai:pl in the @ca software @add_mtc_tai @fix_mtc_tai.
While implementing the parser for @tls `Certificate` message, we noticed that a consistent way of embedding the certificate in the @tls message -- independent of the type -- keeps the parsing logic free of external state.
Therefore, we slightly adopted this embedding in the Internet-Draft @add_array_embedding. 
Moreover we replaced a pre-standard version of Dilithium with @mldsa in the @ca implementation, to be able to verify the signature in the @rp @mtc_use_mldsa.
Further, we opened a discussion on simplifying the certificate type negotiation, but the proposal turned out not be practical @supersede_certificate_type.
Lastly, we also proposed the file structure explained in @sec:update_size to be added to the Internet-Draft @file_structure.

As a result, we managed to successfully perform a @tls handshake between an example client and server based on our modified Rustls version.
@sec:byte_analysis_handshake compares the exchanged handshake messages on a byte level with the Internet-Drafts and shows that we match the draft specifications.
This was necessary as our implementation is the first and interoperability tests with other implementations are therefore not possible.
At the same time, we showed interoperability between the existing @ca implementation in Go with our @mtc verifier written in Rust.


// - Develop certificate verifier in Rust #link("https://github.com/pohlm01/mtc-verifier", "pohlm01/mtc-verifier")
// - Integrate MTC negotiation and verification for client and server in Rustls https://github.com/pohlm01/rustls-mtc
  // - Rustls is a modern TLS library purely written in Rust
  // - It gains adoption beyond the Rust ecosystem @lets_encrypt_rustls @rustls_openssl_nginx
  // - Rust is a modern, memory-safe programming language
  // - There exist already a Go implementation of a CA: Show compatibility with it

  // - The integration required implementation/adoption of negotiation mechanism via RFC 7250
  // - Also keeping track of the certificate type: So far X.509 was assumed implicitly at various places
  // - Additionally, implementing TAI negotiation (no DNS mechanism included yet), including choosing the cert at the server
  
  // - Server and client read the data from disk as described in @sec:update_size

  // - mtc verifier provides functionality to check mtc certificates (rebuilding the Merkle tree path in during TLS handshake, verifying CA signature during startup)
  
  

// - Fix prefix error #link("https://github.com/davidben/merkle-tree-certs/pull/90", "davidben/merkle-tree-certs#90"), #link("https://github.com/bwesterb/mtc/pull/2", "bwesterb/mtc#2"),  #link("https://github.com/bwesterb/mtc/pull/4", "bwesterb/mtc#4")

// - Replace `issuer` and `batch_number` in hash structs with `batch_id` #link("https://github.com/davidben/merkle-tree-certs/pull/91", "davidben/merkle-tree-certs#91"), #link("https://github.com/bwesterb/mtc/pull/8", "bwesterb/mtc#8")

// - Update CA implementation to from Dilithium to ML-DSA https://github.com/bwesterb/mtc/pull/9

// - Use array embedding for Certificate message https://github.com/davidben/merkle-tree-certs/pull/95

// - Integrate Trust Anchor Identifiers into example CA implementation https://github.com/bwesterb/mtc/issues/3

// - Discussion on TAI for certificate type negotiation: https://github.com/davidben/tls-trust-expressions/issues/76

// - Propose file/data structure https://github.com/davidben/merkle-tree-certs/issues/97