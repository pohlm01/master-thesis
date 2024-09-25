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
    
      [Ed25519],      [#emoji.crossmark],     [32],     [64],     [1 (baseline)], [1 (baseline)],
      [RSA-2048],      [#emoji.crossmark],     [256],    [256],    table.cell(fill: yellow.lighten(50%))[70],           [0.3],
      [ML-DSA-44],    [#emoji.checkmark.box], table.cell(fill: orange.lighten(50%))[1,312],  table.cell(fill: orange.lighten(50%))[2,420],  [4.8],          [0.5],
      [SLH-DSA-128s], [#emoji.checkmark.box], [32],     table.cell(fill: red.lighten(50%))[7,856],  table.cell(fill: red.lighten(50%))[8,000],        [2.8],
      [SLH-DSA-128f], [#emoji.checkmark.box], [32],     table.cell(fill: red.lighten(50%))[17,088], table.cell(fill: red.lighten(50%))[550],          [7],
      [FN-DSA-512],   [#emoji.checkmark.box], table.cell(fill: yellow.lighten(50%))[897],    table.cell(fill: yellow.lighten(50%))[666],    table.cell(fill: yellow.lighten(50%))[8 #emoji.warning],            [0.5],
  )
}