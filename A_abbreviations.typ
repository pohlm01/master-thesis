#import "imports.typ": *

= Abbreviations

#let abbreviations = (
    (key: "tls", short: "TLS", long: "Transport Layer Security"),
    (key: "ocsp", short: "OCSP", long: "Online Certificate Status Protocol"),
    (key: "ca", short: "CA", long: "Certification Authority", longplural: "Certification Authorities"),
    (key: "pki", short: "PKI", long: "Public Key Infrastructure"),
    (key: "crl", short: "CRL", long: "Certificate Revocation List"),
    (key: "oid", short: "OID", long: "Object Identifier"),
    (key: "pen", short: "PEN", long: "Private Enterprise Number"),
    (key: "iana", short: "IANA", long: "Internet Assigned Numbers Authority"),
    (key: "vpn", short: "VPN", long: "Virtual Private Network"),
    (key: "ra", short: "RA", long: "Registration Authority", longplural: "Registration Authorities"),
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
    (key: "mldsa", short: [ML-DSA], long: "Module-Lattice-Based Digital Signature Algorithm", 
      description: [@pq signature algorithm, previously known as CRYSTALS-Dilithium]),
    (key: "slhdsa", short: [SLH-DSA], long: "Stateless Hash-Based Digital Signature Algorithm", 
      description: [@pq signature algorithm, previously known as Sphincs+]),
    (key: "fndsa", short: [FN-DSA], long: "FFT (Fast-Fourier transform) over NTRU-Lattice-Based Digital Signature Algorithm",
      description: [@pq signature algorithm, previously known as FALCON]),
    (key: "sha", short: "SHA", long: "Secure Hash Algorithm"),
    (key: "mtc", short: "MTC", long: "Merkle Tree Certificate"),
    (key: "rp", short: "RP", long: "Relying Party", longplural: "Relying Parties"),
    (key: "dns", short: "DNS", long: "Domain Name System"),
    (key: "ip", short: "IP", long: "Internet Protocol"),
    (key: "imap", short: "IMAP", long: "Internet Message Access Protocol"),
    (key: "smtp", short: "SMTP", long: "Simple Mail Transfer Protocol"),
    (key: "ldap", short: "LDAP", long: "Lightweight Directory Access Protocol"),
    (key: "kem", short: "KEM", long: "Key-Encapsulation Mechanism"),
    (key: "kemtls", short: "KEMTLS",
      description: [An alternative to the @tls 1.3 handshake that uses #glspl("kem") instead of signatures for server authentication]),
    (key: "mac", short: "MAC", long: "Message Authentication Code"),
    (key: "ap", short: "AP", long: "Authenticating Party", longplural: "Authenticating Parties"),
    (key: "tai", short: "TAI", long: "Trust Anchor Identifier"),
    (key: "ecdsa", short: "ECDSA", long: "Elliptic Curve Digital Signature Algorithm"),
    (key: "api", short: "API", long: "Application Programming Interface"),
    (key: "rsa", short: "RSA", long: "Rivest–Shamir–Adleman",
      description: [Widely adopted asymmetric crypto system developed by Ron Rivest, Adi Shamir and Leonard Adleman. First published in 1977. Not secure against quantum computers.]),
    (key: "mlkem", short: [ML-KEM], long: [Module-Lattice-Based Key-Encapsulation Mechanism],
      description: [@pq @kem algorithm, previously known as CRYSTALS-Kyber]),
    (key: "asn1", short: "ASN.1", long: "Abstract Syntax Notation One"),
    (key: "der", short: "DER", long: "Distinguished Encoding Rules"),
    (key: "ee", short: "EE", long: "End-Entity", longplural: "End-Entities"),
    (key: "os", short: "OS", long: "Operating System"),
    (key: "sni", short: "SNI", long: "Server Name Indication"),
    (key: "svcb", short: "SVCB", long: "Service Binding"),
)

#let __has_attribute(entry, key) = {
  let attr = entry.at(key, default: "")
  return attr != "" and attr != []
}

#let has-short(entry) = __has_attribute(entry, "short")
#let has-long(entry) = __has_attribute(entry, "long")

#let user-print-title(entry) = {
  if has-long(entry) and has-short(entry) {
    return strong(entry.short) + [ -- ] + entry.long
  } else if has-long(entry) {
    return entry.long
  } else {
    return strong(entry.short)
  }
}



#print-glossary(abbreviations, disable-back-references: true, user-print-title: user-print-title)