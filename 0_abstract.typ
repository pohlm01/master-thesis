#import "imports.typ": *


Constant improvements in quantum computers pose an increasing risk to the security of #gls("tls", long: false), a vital part of the security in today's internet.
The transition to post-quantum secure cryptography in @tls includes multiple challenges.
This work focuses on the challenge of identifying the server to the client.
Currently, X.509-based certificates allow browsers to check the server identity cryptographically.
Naively replacing signatures in these certificates will significantly increase their size and thus slow down connections.
@mtc:pl are a proposal to mitigate this increase as an optional optimization to the current @pki.
We analyzed this proposal regarding transmission sizes and CPU usage and concluded that these performance metrics outperform X.509 certificates with classical and post-quantum signatures.
Moreover, we implemented a library to verify @mtc:pl and integrated it with the @tls library #emph[Rustls].
Using our implementation, we performed a successful @tls handshake, negotiating @mtc:pl and verifying them.
Overall, this work showed that @mtc:pl are a valuable addition to the X.509 certificate infrastructure, and we are looking forward to large-scale experiments in real deployments.