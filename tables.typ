#let o = (body) => table.cell(fill: orange.lighten(50%), body);
#let r = (body) => table.cell(fill: red.lighten(50%), body);
#let y = (body) => table.cell(fill: yellow.lighten(50%), body);

#let chrome_releases = {
table(
  stroke: .1mm,
  align: left,
  columns: 4,
  table.header(
    strong[Major version], strong[Release Date], strong[Days since last release], strong[Days since last major release]
  ),
    table.hline(stroke: .3mm),
    [131],  [December 10, 2024],    [7],    [],
    [131],  [December 3, 2024],     [14],   [],
    [131],  [November 19, 2024],    [7],    [],
    [131],  [November 12, 2024],    [7],    [28],
    table.hline(stroke: .3mm),
    [130],  [November 5, 2024],     [7],    [],
    [130],  [October 29, 2024],     [7],    [],
    [130],  [October 22, 2024],     [7],    [],
    [130],  [October 15, 2024],     [7],    [35],
    table.hline(stroke: .3mm),
    [129],  [October 8, 2024],      [7],    [],
    [129],  [October 1, 2024],      [7],    [],
    [129],  [September 24, 2024],   [7],    [],
    [129],  [September 17, 2024],   [7],    [27],
    table.hline(stroke: .3mm),
    [128],  [September 10, 2024],   [8],    [],
    [128],  [September 2, 2024],    [5],    [],
    [128],  [August 28, 2024],      [7],    [],
    [128],  [August 21, 2024],      [8],    [29],
    table.hline(stroke: .3mm),
    [127],  [August 13, 2024],      [7],    [],
    [127],  [August 6, 2024],       [7],    [],
    [127],  [July 30, 2024],        [7],    [],
    [127],  [July 23, 2024],        [7],    [],
    table.hline(stroke: .3mm),
    [126],  [July 16, 2024],        [],     [],
    table.hline(stroke: .4mm),
    table.cell(colspan: 2)[#strong[Average:]],  [7.35],  [29.75],
)}

#let firefox_releases = {
table(
  stroke: .1mm,
  align: (left, left, right, right, right),
  columns: (6em, auto, auto, auto, auto),
  table.header(
    strong[Version], strong[Release Date], strong[Days since last release], strong[Days since last major release], strong[Update size]
  ),
  table.hline(stroke: .3mm),
  [133.0],      [November 26, 2024],    [14],   [28],   [17~MB],
  table.hline(stroke: .3mm),
  [132.0.2],    [November 12, 2024],    [8],    [],     [9~MB],
  [132.0.1],    [November 4, 2024],     [6],    [],     [10~MB],
  [132.0],      [October 29, 2024],     [15],   [28],   [20~MB],
  table.hline(stroke: .3mm),
  [131.0.3],    [October 14, 2024],     [5],    [],     [9~MB],
  [131.0.2],    [October 9, 2024],      [8],    [],     [10~MB],
  [131.0],      [October 1, 2024],      [14],   [28],   [14~MB],
  table.hline(stroke: .3mm),
  [130.0.1],    [September 17, 2024],   [14],   [],     [9~MB],
  [130.0],      [September 3, 2024],    [14],   [28],   [18~MB],
  table.hline(stroke: .3mm),
  [129.0.2],    [August 20, 2024],      [7],    [],     [9~MB],
  [129.0.1],    [August 13, 2024],      [7],    [],     [8~MB],
  [129.0],      [August 6, 2024],       [11],   [28],   [16~MB],
  table.hline(stroke: .3mm),
  [128.0.3],    [July 26, 2024],        [3],    [],     [8~MB],
  [128.0.2],    [July 23, 2024],        [14],   [],     [8~MB],
  [128.0],      [July 9, 2024],         [],     [],     [33~MB],
  table.hline(stroke: .4mm),
  table.cell(colspan: 2)[#strong[Average:]], [10],  [28], [13.2~MB],
)}

#let format_num(num, decimal: ".", thousands: ",", precision: 2) = {
  let parts = str(calc.round(num, digits: precision)).split(".")
  let decimal_part = if parts.len() == 2 { parts.at(1) }
  let decimal_part = if decimal_part != none {
    let missing_zeros = precision - decimal_part.len()
    decimal_part + missing_zeros * "0"
  } else {
    "00"
  }
  let integer_part = parts.at(0).rev().clusters().enumerate()
    .map((item) => {
      let (index, value) = item
      return value + if calc.rem(index, 3) == 0 and index != 0 {
        thousands
      }
    }).rev().join("")
  return integer_part + decimal + decimal_part
}

#let update_mechanism_size = {
  show table.cell: it => {
    if it.x == 0 {
      align(left, strong(it))
    } else if it.y == 1 {
      align(center, strong(it))
    } else if it.y == 0 {
      align(center, it)
    } else {
      align(right, it)
    }
  }

  let g = (x) => table.cell([#format_num(x)~kB])
  
  table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr),
  table.header(
    [], table.cell(colspan: 2)[Per update], table.cell(colspan: 2)[Per day],
    [], [150 CAs], [15 CAs], [150 CAs], [15 CAs],
  ),
  [A full update for every fetch],          g(2800),   g(280),    g(11200),  g(1120),
  [Only new Tree Heads + Signature], g(1200),   g(120),   g(4800),   g(480),
  [Only new Tree Heads],             g(29.40),  g(2.94),  g(117.6),  g(11.76)
)
}

#let pq_signatures = {
  show table.cell: it => {
    if it.y == 1 or it.y == 0 {
      strong(it)
    } else {
      it
    }
  }

  let g = (x, body) => {
    let text_color = if x > 0.5 {
      white
    } else {
      black
    }
    table.cell(fill: gradient.linear(..color.map.viridis).sample(100% - x * 100%),  text(fill: text_color, body))
  }

  grid(
    columns: (auto, auto),
    gutter: 2em,
    table(
      columns: 6,
      align: (left, center, left, left, left, left),
      stroke: 0.3pt,
      table.header(
        [], [], table.cell(colspan: 2)[Sizes (bytes)], table.cell(colspan: 2)[CPU time (lower is better)],
        [Name], [PQ], [Public Key], [Signature], [Signing], [Verification]),
      
        [Ed25519],      [#emoji.crossmark],     g(32/1312)[32],     g(64/17088)[64],     g(1/8000)[1 (baseline)],      g(1/7)[1 (baseline)],
        [RSA-2048],     [#emoji.crossmark],     g(256/1312)[256],    g(256/17088)[256],    g(70/8000)[70],             g(0.3/7)[0.3],
        [ML-DSA-44],    [#emoji.checkmark.box], g(1312/1312)[1,312],  g(2420/17088)[2,420],  g(4.8/8000)[4.8],         g(0.5/7)[0.5],
        [SLH-DSA-128s], [#emoji.checkmark.box], g(32/1312)[32],     g(7856/17088)[7,856],  g(8000/8000)[8,000],        g(2.8/7)[2.8],
        [SLH-DSA-128f], [#emoji.checkmark.box], g(32/1312)[32],     g(17088/17088)[17,088], g(550/8000)[550],          g(7/7)[7],
        [FN-DSA-512],   [#emoji.checkmark.box], g(897/1312)[897],    g(666/17088)[666],   g(8/8000)[8 #h(.3em) #box(height: 0.7em, inset: -1pt,  image("images/red-alert-icon.svg"))], g(0.5/7)[0.5],
    ),
    align(horizon,
    grid(
      gutter: .5em,
      text(size: .8em)[bad\ performance],
      rect(
        width: 10pt,
        height: 8em,
        fill: gradient.linear(
          dir: ttb,
          ..color.map.viridis,
      )),
      text(size: .8em)[good\ performance]
),
)

  )
}

#let x509_certificate_sizes(kem: true, results_only: false) = {
  
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
    
    [ECDSA-256],  [ECDSA-256],  [ECDSA-256],  [ECDSA-256],  [ECDSA-256],  [ECDSA-256],  [],               [],
    [64],     [192],    [64],     [64],     [32],     [32],     [448],            [#emoji.crossmark],
    
    [RSA-2048], [ECDSA],  [RSA-2048], [RSA-4096], [RSA-2048], [RSA-2048], [],       [],
    [256],      [192],    [256],      [512],      [256],      [256],      [1,728],  [#emoji.crossmark],
    
    [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [],               [],
    [2,420],  [7,260],  [2,420],  [2,420],  [1,312],  [1,312],  [17,144],         [#emoji.checkmark.box],
    
    [ML-DSA-44], [ML-DSA-44], [ML-DSA-44], [SLH-DSA-128s], [ML-DSA-44], [ML-DSA-44], [],         [],
    [2,420],  [7,260],  [2,420],  [7,856],        [1,312],  [1,312],  [22,580],   [#emoji.checkmark.box],

    ..if kem {(
    y[ML-KEM-768], [ML-DSA-44], [ML-DSA-44], [ML-DSA-44],  y[ML-KEM-768],  [ML-DSA-44], [],           [],
     [1,088],  [7,260],  [2,420],  [2,420],   [1,184],    [1,312],  [15,684],     [#emoji.checkmark.box],
    )},
  )
}

#let bikeshed_certificate_sizes(kem: true) = {
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

    [ECDSA],  [ECDSA],  [280M active APs],  [], [],
    [64],     [32],     [672],            [768], [#emoji.crossmark],
        
    [RSA-2048],  [RSA-2048],  [1B active APs],  [], [],
    [256],     [256],     [832],            [1,344], [#emoji.crossmark],
    
    [ML-DSA-44], [ML-DSA-44], [280M active APs],  [], [],
    [2,420],  [1,312],  [672],            [4,404], [#emoji.checkmark.box],
    
    [ML-DSA-44], [ML-DSA-44], [1B active APs],  [], [],
    [2,420],  [1,312],  [832],            [4,564], [#emoji.checkmark.box],

    ..if kem {(
    y[ML-KEM-768], y[ML-KEM-768], [280M active APs],  [], [],
    [1,088],    [1,184],  [672],            [2,944], [#emoji.checkmark.box],
    )},

    ..if kem {(
    y[ML-KEM-768], y[ML-KEM-768], [1B active APs],  [], [],
    [1,088],    [1,184],  [832],            [3,104], [#emoji.checkmark.box],
    )},
  )
}

#let bikeshed_x509_size_comp = {
  show table.cell: it => {
    strong(it)
  }

  grid(
    columns: 2,
    gutter: 3em,
    figure(
      table(
        columns: 2,
        
        fill: (x, y) => {
          if calc.odd(y) {
            gray.lighten(40%)
          }
        },
    
        align: (x, y) => {
          if x == 0 and y > 0 {
            right
          } else {
            center
          }
        },
    
        table.header(
          [$sum$], [PQ],
        ),
        [448 bytes],      [#emoji.crossmark],
        [1,728 bytes],    [#emoji.crossmark],
        [17,144 bytes],   [#emoji.checkmark.box],
        [22,580 bytes],   [#emoji.checkmark.box],
      ),
    caption: [X.509]),
  
    figure(
        table(
        columns: 2,
        
        fill: (x, y) => {
          if calc.odd(y) {
            gray.lighten(40%)
          }
        },
    
        align: (x, y) => {
          if x == 0 and y > 0{
            right
          } else {
            center
          }
        },
    
        table.header(
          [$sum$], [PQ],
        ),
    
        [768 bytes],    [#emoji.crossmark],
        [1,344 bytes],    [#emoji.crossmark],
        [4,404 bytes],  [#emoji.checkmark.box],
        [4,564 bytes],  [#emoji.checkmark.box],
      ),
      caption: [MTC]
    )
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