#import "imports.typ": *

= Abbreviations

#let abbreviations = (
    (key: "tls", short: "TLS", long: "Transport Layer Security"),
    (key: "ocsp", short: "OCSP", long: "Online Certificate Status Protocol"),
    (key: "ca", short: "CA", long: "Certificate Authority"),
    (key: "pki", short: "PKI", long: "Public Key Infrastructure"),
    (key: "crl", short: "CRL", long: "Certificate Revocation List"),
    (key: "oid", short: "OID", long: "Object Identifier"),
    (key: "pen", short: "PEN", long: "Private Enterprise Number"),
    (key: "iana", short: "IANA", long: "Internet Assigned Numbers Authority"),
    (key: "vpn", short: "VPN", long: "Virtual Private Network"),
    (key: "ra", short: "RA", long: "Registration Authority"),
    (key: "rpki", short: "RPKI", long: "Resource Public Key Infrastructure"),
    (key: "bgp", short: "BGP", long: "Border Gateway Protocol"),
    (key: "acme", short: "ACME", long: "Automatic Certificate Management Environment"),
    (key: "ietf", short: "IETF", long: "Internet Engineering Task Force"),
    (key: "ssl", short: "SSL", long: "Secure Sockets Layer"),
    (key: "nist", short: "NIST", long: "National Institute of Standards and Technology"),
    (key: "https", short: "HTTPS", long: "Hypertext Transfer Protocol Secure"),
    (key: "http", short: "HTTP", long: "Hypertext Transfer Protocol"),
    (key: "ct", short: "CT", long: "Certificate Transparency"),
    (key: "sct", short: "SCT", long: "Signed Certificate Timestamp"),
    (key: "pq", short: "PQ", long: "Post-Quantum"),
    (key: "mldsa", short: "ML-DSA", long: "Module-Lattice-Based Digital Signature Algorithm", 
      description: [@pq signature algorithm, previously known as CRYSTALS-Dilithium]),
    (key: "slhdsa", short: "SLH-DSA", long: "Stateless Hash-Based Digital Signature Algorithm", 
      description: [@pq signature algorithm, previously known as Sphincs+]),
    (key: "fndsa", short: "FN-DSA", long: "FFT (fast-Fourier transform) over NTRU-Lattice-Based Digital Signature Algorithm",
      description: [@pq signature algorithm, previously known as FALCON]),
    (key: "sha", short: "SHA", long: "Secure Hash Algorithm"),
    (key: "mtc", short: "MTC", long: "Merkle Tree Certificate"),
    (key: "rp", short: "RP", long: "Relying Party"),
    (key: "dns", short: "DNS", long: "Domain Name System"),
    (key: "ip", short: "IP", long: "Internet Protocol"),
    (key: "imap", short: "IMAP", long: "Internet Message Access Protocol"),
    (key: "smtp", short: "SMTP", long: "Simple Mail Transfer Protocol"),
    (key: "ldap", short: "LDAP", long: "Lightweight Directory Access Protocol"),
    (key: "kem", short: "KEM", long: "Key Encapsulation Mechanism"),
    (key: "kemtls", short: "KEMTLS",
      description: [An alternative to the @tls 1.3 handshake that uses #glspl("kem") instead of signatures for server authentication]),
    (key: "mac", short: "MAC", long: "Message Authentication Code"),
    (key: "ap", short: "AP", long: "Authenticating Party"),
    (key: "tai", short: "TAI", long: "Trust Anchor Identifier"),
    (key: "ecdsa", short: "ECDSA", long: "Elliptic Curve Digital Signature Algorithm"),
    (key: "api", short: "API", long: "Application Programming Interface"),
)

#print-glossary(abbreviations, disable-back-references: true)