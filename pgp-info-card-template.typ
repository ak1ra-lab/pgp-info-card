// PGP Info Card template
// 90 x 55 mm card, two pages: the front holds the identity, the back the
// QR code. Edit the fields below.

#import "@preview/qrypst:0.1.1": qr

// --- Identity -------------------------------------------------------------

#let display-name = "John Smith"

// Up to `max-uids` entries; six one-line entries fill the card. A long
// entry wraps onto an indented second line.
#let uids = (
  "John Smith <jsmith@example.org>",
  "John Smith (work) <jsmith@example.com>",
  "John Smith (alt) <jsmith@example.net>",
)
#let max-uids = 6

#let fingerprint = "0123 4567 89AB CDEF 0123 4567 89AB CDEF 0123 4567"

// --- Contact channels -----------------------------------------------------

#let telegram = "@jsmith"
#let matrix = "@jsmith:example.org"
#let website = "https://example.org/"
#let github = "@jsmith"

#let note = "Verify the fingerprint before trusting this key."

#assert(
  uids.len() <= max-uids,
  message: "at most " + str(max-uids) + " UIDs fit on this card",
)

// --- Style ----------------------------------------------------------------

#set page(
  width: 90mm,
  height: 55mm,
  margin: 3.5mm,
  fill: rgb("F8F8F6"),
)

#set text(
  size: 7.6pt,
  fill: rgb("1A1A1A"),
)

// No implicit gaps between blocks; every gap below is explicit.
#set block(spacing: 0pt)

#let ink = rgb("1A1A1A")
#let muted = rgb("666666")
#let rule = rgb("C8C8C4")
#let accent = rgb("315A7D")

// Canonical QR payload: fingerprint without whitespace.
#let fingerprint-qr-payload = fingerprint.replace(" ", "")

// --- Building blocks ------------------------------------------------------

#let label(body) = text(
  size: 6.2pt,
  weight: "bold",
  fill: muted,
  tracking: 0.35pt,
)[#body]

// Shared label column width.
#let label-width = 17mm

#let field(label-text, value, value-size: 7.0pt) = grid(
  columns: (label-width, 1fr),
  gutter: 1mm,
  align: (left, left),
  label(label-text),
  text(size: value-size, value),
)

#let uid-field = grid(
  columns: (label-width, 1fr),
  gutter: 1mm,
  align: (left, left),
  label(if uids.len() > 1 { "UIDS" } else { "UID" }),
  // `leading` keeps a wrapped UID's continuation line as close as the gap
  // between entries, so the UID reads as one unit instead of a detached
  // line; `hanging-indent` then marks the continuation. `bottom-edge`
  // keeps stacked lines from colliding on descenders.
  stack(
    spacing: 1.3mm,
    ..uids.map(u => par(
      leading: 0.5em,
      hanging-indent: 3.5mm,
      text(size: 7.0pt, bottom-edge: "descender", u),
    )),
  ),
)

// --- Card: front ----------------------------------------------------------

#align(
  center,
  stack(
    spacing: 1mm,
    // `bottom-edge` extends the line box past the descenders, otherwise the
    // title collides with the fingerprint below it.
    text(
      size: 12.6pt,
      weight: "bold",
      fill: ink,
      bottom-edge: "descender",
    )[#display-name],
    text(size: 9.2pt, weight: "bold", fill: accent)[#raw(fingerprint)],
  ),
)

#v(2.6mm)

#block(height: 0.45pt, width: 100%, fill: rule)

#v(2.6mm)

#uid-field

#v(1fr)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 2.5mm,
  row-gutter: 1.5mm,
  field("TELEGRAM", telegram, value-size: 6.35pt),
  field("MATRIX", matrix, value-size: 6.35pt),
  field("WEBSITE", website, value-size: 6.35pt),
  field("GITHUB", github, value-size: 6.35pt),
)

#v(2mm)

#align(left)[
  #text(size: 5.55pt, fill: muted)[#note]
]

// Keep the note's descenders inside the 3.5 mm margin.
#v(0.5mm)

// --- Card: back -----------------------------------------------------------

#pagebreak()

#align(
  center + horizon,
  stack(
    spacing: 1.2mm,
    qr(
      fingerprint-qr-payload,
      module: 1.15mm,
      ecc: "M",
      quiet: 4,
    ),
    text(size: 6.2pt, weight: "bold", fill: muted)[SCAN FINGERPRINT],
  ),
)
