# Family Space: glass assets v3

Generated on 2026-10-21 with the built-in GPT Images tool. Original RGBA PNGs
were copied unchanged into this folder; no background-removal processing,
resizing or compositing was applied.

References: approved `design/concepts/family-rebrand-2026-10-21/child-home.png`,
`teen-learning.png`, and official `design/brand/mtbank-2026/slides/29-graphics.png`.
These are illustrations, not redrawn bank logos.

## Prompts

Both prompts requested a square 1024px transparent standalone UI asset,
optical glass with realistic thickness/refraction and soft studio lighting,
centered with balanced padding, readable at 112 logical pixels; palette
`#2334C8`, `#E7F4FF`, `#97CFFF`, `#82AED3`, clear/white highlights.
No UI, text, numbers, logos, people, faces, toys, plastic, neon, red/orange,
external shadow, floor, halo, opaque background or painted checkerboard.

- Wallet: reproduce only the approved blue glass wallet from child-home;
  compact upright closed bifold wallet, rounded front, clear clasp on the
  right, one clear card projecting from its top, one plain translucent coin
  near lower left, three-quarter perspective facing slightly right.
- Learning: reproduce only the approved open glass book from teen-learning;
  gently curved clear pages, two or three thicker underlying page layers,
  elegant center valley and rounded corners, cobalt polished edges,
  three-quarter view slightly from above, front-right presentation.

## Validation

The tool returned 1254×1254 images despite the requested 1024×1024.
Keep their native resolution and use layout sizing at runtime.
Both originals have RGBA channels and a genuine alpha range of 0–255.

| Asset | Fully transparent pixels | SHA-256 |
| --- | --- | --- |
| wallet-glass.png | 55.35% | d93f99a5396818947a2a2273b24314aa88e8e77e70ecc094fc7f277029a60441 |
| learning-glass.png | 57.35% | b3790ff076d34c83f3744e32c97fbb0d9d5e742ca3285204dc7a0165976b6274 |
