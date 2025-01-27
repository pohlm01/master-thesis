#import "imports.typ": *

= Conclusion and Outlook <sec:conclusion>

Constant achievements in building quantum computers endanger many asymmetric cryptography systems used today.
This includes the signatures used in X.509-based certificates, which are used for server identification in @tls connections.
Replacing all signatures in the X.509-based architecture with #gls("pq")-secure signature schemes results in a large expansion of the certificate sizes.
This ultimately results in slower connections and more data to be transferred for each @tls handshake.


#cite(<rfc_mtc>, form: "author") propose #glspl("mtc", long: true) to supplement the current X.509 architecture, which reduces the number of signatures to shrink the size of certificates.
As a trade, certificates cannot be used immediately and the @mtc architecture requires a regular update channel between the Transparency Service and the #gls("rp", long: true).

In this thesis, we analyzed theoretical improvements in data transmission when introducing @mtc.
// and implemented a client as well as a server that use @mtc:pl to prove the server identity.
We showed that @mtc saves about 74~% to 80~% of the bytes related to the cryptographic server authentication compared to X.509 certificates when using #gls("pq")-secure signature schemes.
The actual improvement is even more significant, as @mtc:pl use more efficient encoding and require fewer additional attributes in the certificate, such as not before / not after timestamps or @crl and @ocsp endpoints.
As a result, @pq#{"-secure"} @mtc certificates are around the same size as today's median certificate chains, which are non-@pq#{"-secure"}.

In favor of small certificates, the @mtc architecture introduces an update mechanism between the Transparency Service and the @rp.
We listed three update scenarios with either 150 or 15~@ca:pl and argued that the new update mechanism does not harm the @mtc architecture too much.
Firstly, we think that 15 @mtc @ca:pl is a realistic estimate based on the fact that @mtc:pl are not meant as a replacement but an optional optimization of the current Web@pki.
Therefore, many @ca:pl will refrain from implementing these significant changes into their operation as many of them serve small use cases that do not amortize the effort to adopt @mtc.
The second argument we made is that the Transparency Services are likely operated by the browser vendors, which a user must unavoidably trust anyway.
Therefore, the Transparency Service can usually check the @ca signatures, ultimately saving a lot of update bandwidth.
This results in about 12~kB update bandwidth per day and @rp.
This is only a small addition compared to the about 900~kB to 1,300~kB per day for application updates in Chrome and Firefox.
A single @tls handshake with @mtc instead of a @pq X.509 certificate chain amortizes the daily updates.
Other scenarios require a bigger update bandwidth, but we expect them to be relevant for only a few instances (client that perform signature checks), or far in the future if at all (150~@ca:pl).

In addition to the size analysis, we estimated the computational cost associated with X.509 and @mtc.
We pointed out that there is no difference for a server.
Still, clients can save about 81~% to 93~% in computational cost per handshake when using classical signature algorithms and about 73~% to 85~% when using #gls("pq")-save signature algorithms.
This is mainly because clients have to perform way fewer signature verifications, which are computationally expensive.
Instead, clients have to perform hash operations to rebuild the Merkle Tree.
Because hash operations are much more lightweight than signature verifications, the client saves computational resources, which in turn helps with a longer battery life or frees up resources for other tasks.

To explore the practicality of the @mtc architecture, we modified the @tls library #emph[Rustls] to support @mtc:pl.
This included the negotiation mechanisms for the certificate type and the specific trust anchor, i.e., the specific @mtc batch.
Additionally, we developed a library that validates @mtc:pl and integrated this into Rustls.
We successfully performed a handshake between the modified client and server and analyzed it on a byte level to conform with the specification.

Overall, our work showed that the @mtc architecture has the potential to mitigate or even overcompensate the performance penalty associated with introducing @pq secure algorithms for server identification.
Nevertheless, there are still some open points that should be investigated further.
One point could be to investigate the memory usage associated with the usage of the X.509 and @mtc architectures.
Another challenging task is to design an update mechanism that safely transfers the batch tree heads from the Transparency Service to the @rp.
To be practical, it must be reasonably small, i.e., the overhead to create a secure channel must not be too big.
At the same time, this update protocol must be secured against quantum computers to create an end-to-end secure architecture.
Lastly, it must not solely rely on @mtc:pl, as it is designed to bootstrap @mtc.

Finally, it is up to the major technology companies to run real-world experiments and use their telemetry collection mechanism to gather information that shows how the mostly theoretical numbers from this work translate to big deployments.
From what I perceived from the community, I expect this will happen in 2025.


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

// - Implemented
//   - Changes in Rustls
//     - Negotiation
//   - MTC verifier

  
// - Figure out a good update mechanism
//   - Must be PQ save
//   - Must be reasonably small
//   - Must work without MTC
// - Analyze memory usage
// - Use MTC in a larger real-world experiment
//   - Collect telemetry data
// - My personal expectation: There will be bigger tests within the Google ecosystem in 2025

// - Various changes to the I-D
// - Common file structure
