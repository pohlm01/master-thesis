#let o = (body) => table.cell(fill: orange.lighten(50%), body);
#let r = (body) => table.cell(fill: red.lighten(50%), body);
#let y = (body) => table.cell(fill: yellow.lighten(50%), body);

#let pq_signatures = {
  show table.cell: it => {
    if it.y == 1 or it.y == 0 {
      strong(it)
    } else {
      it
    }
  }

  table(
    columns: 6,
    align: (left, center, left, left, left, left),
    stroke: 0.3pt,
    table.header(
      [], [], table.cell(colspan: 2)[Sizes (bytes)], table.cell(colspan: 2)[CPU time (lower is better)],
      [Name], [PQ], [Public Key], [Signature], [Signing], [Verification]),
    
      [Ed25519],      [#emoji.crossmark],     [32],     [64],     [1 (baseline)],   [1 (baseline)],
      [RSA-2048],     [#emoji.crossmark],     [256],    [256],    y[70],            [0.3],
      [ML-DSA-44],    [#emoji.checkmark.box], o[1,312],  o[2,420],  [4.8],          [0.5],
      [SLH-DSA-128s], [#emoji.checkmark.box], [32],     r[7,856],  r[8,000],        [2.8],
      [SLH-DSA-128f], [#emoji.checkmark.box], [32],     r[17,088], r[550],          [7],
      [FN-DSA-512],   [#emoji.checkmark.box], y[897],    y[666],   y[8 #emoji.warning],            [0.5],
  )
}

#let x509_certificate_sizes = {
  
  show table.cell: it => {
    if it.y == 0 or it.y == 1 or it.x == 6 {
      strong(it)
    } else {
      it
    }
  }
  
  table(
    columns: 8,
    
    fill: (x, y) => {
      if calc.odd(y) and y > 1 {
        gray.lighten(40%)
      }
    },

    align: (x, y) => {
      if calc.odd(y) and y > 1 and x != 7{
        right
      } else if y > 1 and x != 7{
        left
      } else {
        center
      }
    },

    table.header(
      table.cell(colspan: 4)[Signatures],             table.cell(colspan: 2)[Public Keys],  [$sum$], [PQ],
      [Handshake],[SCT + OCSP], [EE], [Intermediate], [EE], [Intermediate],                 [], []
    ),
    
    [ECDSA],  [ECDSA],  [ECDSA],  [ECDSA],  [ECDSA],  [ECDSA],  [],               [],
    [64],     [192],    [64],     [64],     [32],     [32],     [448],            [#emoji.crossmark],
    
    [RSA-2048], [ECDSA],  [RSA-2048], [RSA-4096], [RSA-2048], [RSA-2048], [],       [],
    [256],      [192],    [256],      [512],      [256],      [256],      [1,728],  [#emoji.crossmark],
    
    [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [],               [],
    [2,420],  [7,260],  [2,420],  [2,420],  [1,312],  [1,312],  [17,144],         [#emoji.checkmark.box],
    
    [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [SLH-DSA-128s], [ML-DSA-44], [ML-DSA-44], [],         [],
    [2,420],  [7,260],  [2,420],  [7,856],        [1,312],  [1,312],  [22,580],   [#emoji.checkmark.box],

    y[ML-KEM-768], [ML-DSA-44], [ML-DSA-44], [ML-DSA-44],  y[ML-KEM-768],  [ML-DSA-44], [],           [],
     [1,088],  [7,260],  [2,420],  [2,420],   [1,184],    [1,312],  [15,684],     [#emoji.checkmark.box],
  )
}

#let bikeshed_certificate_sizes = {
  show table.cell: it => {
    if it.y == 0 or it.x == 3 {
      strong(it)
    } else {
      it
    }
  }

  table(
    columns: 5,
    align: (x, y) => {
      if calc.even(y) and y > 0 and x != 4{
        right
      } else if y > 0  and x != 4{
        left
      } else {
        center
      }
    },
    
    fill: (x, y) => {
      if calc.even(y) and y > 0 {
        gray.lighten(40%)
      }
    },
    
    table.header([Handshake], [Public Key], [Proof Length], [$sum$], [PQ]),

    [ECDSA],  [ECDSA],  [280M active @ap:pl],  [], [],
    [64],     [32],     [672],            [768], [#emoji.crossmark],
    
    [ML-DSA-44], [ML-DSA-44], [280M active @ap:pl],  [], [],
    [2,420],  [1,312],  [672],            [4,404], [#emoji.checkmark.box],

    y[ML-KEM-768], y[ML-KEM-768], [280M active @ap:pl],  [], [],
    [1,088],    [1,184],  [672],            [2,944], [#emoji.checkmark.box],
    
    [ECDSA],  [ECDSA],  [1B active @ap:pl],  [], [],
    [64],     [32],     [832],            [928], [#emoji.crossmark],
    
    [ML-DSA-44], [ML-DSA-44], [1B active @ap:pl],  [], [],
    [2,420],  [1,312],  [832],            [4,564], [#emoji.checkmark.box],

    y[ML-KEM-768], y[ML-KEM-768], [1B active @ap:pl],  [], [],
    [1,088],    [1,184],  [832],            [3,104], [#emoji.checkmark.box],
    
  )
}

#let x509_certificates_top_10 = {
  show table.cell: it => {
    if it.y == 0 {
      strong(it)
    } else {
      it
    }
  }
    table(
      columns: 6,
  
      table.header(
        [Domain], [Handshake], [SCT], [EE], [Intermediate], [SHA-256 fingerprint],
      ),
      
      [gooogle.com], [256-bit ECDSA],  [2x 256-bit ECDSA],  [RSA-2048],  [RSA-4096],
      [`37:9A:80:C9:25:2C:66:A1:BB:89:D6:C0:C8:83:33:39: 55:1D:E6:0F:D3:75:58:5C:F9:A3:18:37:03:57:A0:D6`],
      
      [apple.com], [RSA-2048], [4x 256-bit ECDSA], [RSA-2048], [RSA-2048],
      [`8B:29:CD:F1:D9:4E:D6:19:13:19:BF:47:AB:05:20:16: 8D:0D:21:D5:80:3E:5E:CA:A2:FE:40:A7:BA:BE:1B:AD`],
      
      [facebook.com], [256-bit ECDSA], [3x 256-bit ECDSA], [RSA-2048],  [RSA-2048],
      [`AA:52:70:47:1F:CB:25:A5:47:0D:2F:04:21:52:23:2A: 80:7C:EE:D5:C0:D0:F8:41:54:B4:C3:C7:EF:FA:84:B4`],
      
      [microsoft.com], [RSA-2048], [3x 256-bit ECDSA], [RSA-4096], [RSA-2048],
      [`5E:7E:E1:BF:7B:02:DE:64:07:57:84:02:E6:8F:30:E4: 07:4A:4C:68:04:DA:E9:B7:12:50:70:E2:6E:A5:6B:F0`],
  
      [cloudflare.com], [256-bit ECDSA], [2x 256-bit ECDSA], [256-bit ECDSA], [384-bit ECDSA], 
      [`5A:18:79:DD:30:77:B1:51:E6:96:E2:BA:6D:D6:9F:E2: 77:EB:2E:BE:D6:82:D2:00:1E:A2:05:DB:94:A1:09:FA`]
    )
}