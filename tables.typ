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
    columns: 7,
    
    fill: (x, y) => {
      if calc.odd(y) and y > 1 {
        gray.lighten(40%)
      }
    },

    align: (x, y) => {
      if calc.odd(y) and y > 1 {
        right
      } else if y > 1 {
        left
      } else {
        center
      }
    },

    table.header(
      table.cell(colspan: 4)[Signatures],             table.cell(colspan: 2)[Public Keys],  [$sum$],
      [Handshake],[SCT + OCSP], [EE], [Intermediate], [EE], [Intermediate],                 [],
    ),
    
    [ECDSA],  [ECDSA],  [ECDSA],  [ECDSA],  [ECDSA],  [ECDSA],  [],
    [64],     [192],    [64],     [64],     [32],     [32],     [448],
    
    [ECDSA],  [ECDSA],  [RSA-2048], [RSA-4096], [RSA-2048], [RSA-2048], [],
    [64],     [192],    [256],      [512],      [256],      [256],      [1,536],
    
    [ML-DSA], [ML-DSA], [ML-DSA], [ML-DSA], [ML-DSA], [ML-DSA], [],
    [2,420],  [7,260],  [2,420],  [2,420],  [1,312],  [1,312],  [17,144],
    
    [ML-DSA], [ML-DSA], [ML-DSA], [SLH-DSA-128s], [ML-DSA], [ML-DSA], [],
    [2,420],  [7,260],  [2,420],  [7,856],        [1,312],  [1,312],  [22,580],

    y[ML-KEM], [ML-DSA], [ML-DSA], [ML-DSA],  y[ML-KEM],  [ML-DSA], [],
     [1,088],  [7,260],  [2,420],  [2,420],   [1,184],    [1,312],  [15,684],
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
    columns: 4,
    align: (x, y) => {
      if calc.even(y) and y > 0 {
        right
      } else if y > 0 {
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
    
    table.header([Handshake Authentication], [Public Key], [Proof Length], [$sum$]),

    [ECDSA],  [ECDSA],  [280M subscribers],  [],
    [64],     [32],     [672],            [768],
    
    [ML-DSA], [ML-DSA], [280M subscribers],  [],
    [2,420],  [1,312],  [672],            [4,404],

    y[ML-KEM], y[ML-KEM], [280M subscribers],  [],
    [1,088],    [1,184],  [672],            [2,944],
    
    [ECDSA],  [ECDSA],  [1B subscribers],  [],
    [64],     [32],     [832],            [928],
    
    [ML-DSA], [ML-DSA], [1B subscribers],  [],
    [2,420],  [1,312],  [832],            [4,564],

    y[ML-KEM], y[ML-KEM], [1B subscribers],  [],
    [1,088],    [1,184],  [832],            [3,104],
    
  )
}