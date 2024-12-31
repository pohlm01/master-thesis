#import "imports.typ": *

= Conclusion and Outlook

Constant achievements in building quantum computers endanger many asymmetric cryptography systems used today.
This includes the signatures used in X.509-based certificates, which are used for server identification in @tls connections.
Replacing all signatures in the X.509-based architecture with #gls("pq")-secure signature schemes results in a big expansion of the certificate sizes.
This results in slower connections and more data to be transferred for each @tls handshake.


#cite(<rfc_mtc>, form: "author") propose #glspl("mtc", long: true) to supplement the current X.509 architecture which reduces the number of signatures to shrink the size of certificates.
As a trade, certificates cannot be used immediately and the @mtc architecture requires a regular update channel between the Transparency Service and the #gls("rp", long: true).

In this thesis, we analyzed theoretical improvements in terms of data transmission and computational effort when introducing @mtc and implemented a client as well as a server that use @mtc:pl to prove the server identity.
We showed that @mtc likely saves about 74~% to 80~% of the bytes related to the cryptographic server authentication compared to X.509 certificates when using #gls("pq")-secure signature schemes.
The actual improvement is even significant, as @mtc:pl use more efficient encoding and require less additional attributes in the certificate, such as not before / not after timestamps or @crl and @ocsp endpoints.

In favor of small certificates, the @mtc architecture introduces an update mechanism between the Transparency Service and the @rp.
We listed three update scenarios with either 150 or 15~@ca:pl and argued that the new update mechanism does not harm the @mtc architecture too much.
Firstly, we think that 15 @mtc @ca:pl is a realistic estimate based on that @mtc are not meant as a replacement but an optional optimization of the current Web@pki.
Therefore, many @ca:pl will refrain from implementing these significant changes into their operation as they mainly serve small use-cases which do not amortize the effort to adopt @mtc.
The second argument we made is that the Transparency Services are likely operated by the browser vendors, which a user must unavoidable trust anyway.
Therefore, the @ca signatures can be checked by the Transparency Service in most cases and therefore save a lot of update bandwidth.
This results in about 12~kB update bandwidth per day and @rp.
Compared to about 900~kB to 1,300~kB per day for application updates in Chrome and Firefox, this is only a small addition.
Additionally, a single @tls handshake with @mtc instead of a @pq X.509 certificate chain amortizes the daily updates.
Other scenarios require a bigger update bandwidth, but we expect them to be relevant for only few instances (client signature checks), or far in the future if at all (150~@ca:pl).

In addition to the size analysis, we estimated the computational cost associated with X.509 and @mtc.
We pointed out that there is no difference for a server, but clients can save about 81~% to 93~% in computational cost per handshake when using classical signature algorithms and about 73~% to 85~% when using #gls("pq")-save signature algorithms.

To explore the practicality of the @mtc architecture, we adopted Rustls to support @mtc:pl.
This 

// - Problem statement (the bigger picture)
//   - Quantum computers endanger current server identity validation in TLS
//   - replacing signatures results in big certificates
//   - results in fragmentation and slower connections

// - Recap the preliminaries
//   - Merkle Trees
//   - PKI with OCSP, ACME, and Certificate Transparency
//   - TLS handshake and KEMTLS
//   - PQ signatures
// - Explanation of the MTC system
//   - meant as an additional and optional improvement over the existing X.509 architecture
// - Certificate size
// - Update mechanism
//   - Depends on the number of CAs and if the Transparency Service does the signature checking
//   - Compared to loading a webpage or other regular updates, it has a reasonable size
//   - In the best case, a single TLS handshake is enough to amortize the update size
// - CPU usage
//   - PQ is better than ECDSA anyway (Better than RSA for the server)
//   - MTC is even better

- Common file structure
- Implemented
  - Changes in Rustls
    - Negotiation
  - MTC verifier
- Various changes to the I-D

  
- Figure out a good update mechanism
  - Must be PQ save
  - Must be reasonably small
  - Must work without MTC
- Analyze memory usage
- Use MTC in a larger real-world experiment
  - Collect telemetry data
- My personal expectation: There will be bigger tests within the Google ecosystem in 2025