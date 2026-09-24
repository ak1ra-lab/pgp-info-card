// PGP Info Card
//
// A 90 x 55 mm card for the in-person phase of an OpenPGP key signing
// party. The front holds the identity (name, fingerprint, UIDs, contact
// channels); the back holds the fingerprint as a QR code.
//
// The `layouts` parameter selects the output:
//   "card" - one 90 x 55 mm card: front and back
//   "a4"   - ten copies tiled on two A4 sheets (fronts and backs) with
//            crop marks, for printing on plain A4 paper

#import "@preview/qrypst:0.1.1": qr

#let pgp-info-card(
  // --- Identity -----------------------------------------------------------
  display-name: "John Smith",
  // Up to `max-uids` entries; six one-line entries fill the card. A long
  // entry wraps onto an indented second line.
  uids: (
    "John Smith <jsmith@example.org>",
    "John Smith (work) <jsmith@example.com>",
    "John Smith (alt) <jsmith@example.net>",
  ),
  max-uids: 6,
  fingerprint: "0123 4567 89AB CDEF 0123 4567 89AB CDEF 0123 4567",

  // --- Contact channels ---------------------------------------------------
  // A channel set to `none` or "" is omitted from the card.
  telegram: "@jsmith",
  matrix: "@jsmith:example.org",
  website: "https://example.org/",
  github: "@jsmith",

  note: "Verify the fingerprint before trusting this key.",

  // --- Output -------------------------------------------------------------
  layouts: ("card", "a4"),

  // Filled by the show rule in the template's main.typ.
  body,
) = {
  assert(
    uids.len() <= max-uids,
    message: "at most " + str(max-uids) + " UIDs fit on this card",
  )
  assert(
    type(layouts) == array and layouts.len() > 0 and layouts.all(l => l in ("card", "a4")),
    message: "layouts must be an array containing \"card\" and/or \"a4\"",
  )

  // --- Style --------------------------------------------------------------

  let card-width = 90mm
  let card-height = 55mm
  let card-margin = 3.5mm
  let card-fill = rgb("F8F8F6")
  let ink = rgb("1A1A1A")
  let muted = rgb("666666")
  let rule-color = rgb("C8C8C4")
  let accent = rgb("315A7D")
  let label-width = 17mm

  set text(size: 7.6pt, fill: ink)

  // No implicit gaps between blocks; every gap below is explicit.
  set block(spacing: 0pt)

  // Canonical QR payload: fingerprint without whitespace.
  let fingerprint-qr-payload = fingerprint.replace(" ", "")

  // --- Building blocks ----------------------------------------------------

  let field-label(body) = text(
    size: 6.2pt,
    weight: "bold",
    fill: muted,
    tracking: 0.35pt,
  )[#body]

  let field(label-text, value, value-size: 7.0pt) = grid(
    columns: (label-width, 1fr),
    gutter: 1mm,
    align: (left, left),
    field-label(label-text),
    text(size: value-size, value),
  )

  let uid-field = grid(
    columns: (label-width, 1fr),
    gutter: 1mm,
    align: (left, left),
    field-label(if uids.len() > 1 { "UIDS" } else { "UID" }),
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

  let contacts = (
    ("TELEGRAM", telegram),
    ("MATRIX", matrix),
    ("WEBSITE", website),
    ("GITHUB", github),
  ).filter(pair => pair.at(1) != none and pair.at(1) != "")

  let contact-grid = grid(
    columns: (1fr, 1fr),
    column-gutter: 2.5mm,
    row-gutter: 1.5mm,
    ..contacts.map(pair => field(pair.at(0), pair.at(1), value-size: 6.35pt)),
  )

  // --- Card faces ---------------------------------------------------------

  let card-front = block(
    width: card-width,
    height: card-height,
    fill: card-fill,
    inset: card-margin,
    {
      align(
        center,
        stack(
          spacing: 1mm,
          // `bottom-edge` extends the line box past the descenders,
          // otherwise the title collides with the fingerprint below it.
          text(
            size: 12.6pt,
            weight: "bold",
            fill: ink,
            bottom-edge: "descender",
          )[#display-name],
          text(size: 9.2pt, weight: "bold", fill: accent)[#raw(fingerprint)],
        ),
      )
      v(2.6mm)
      block(height: 0.45pt, width: 100%, fill: rule-color)
      v(2.6mm)
      uid-field
      v(1fr)
      if contacts.len() > 0 {
        contact-grid
      }
      if note != none and note != "" {
        v(2mm)
        align(left)[#text(size: 5.55pt, fill: muted)[#note]]
      }
      // Keep the note's descenders inside the card margin.
      v(0.5mm)
    },
  )

  let card-back = block(
    width: card-width,
    height: card-height,
    fill: card-fill,
    inset: card-margin,
    align(
      center + horizon,
      stack(
        spacing: 1.2mm,
        qr(fingerprint-qr-payload, module: 1.15mm, ecc: "M", quiet: 4),
        text(size: 6.2pt, weight: "bold", fill: muted)[SCAN FINGERPRINT],
      ),
    ),
  )

  // --- Output -------------------------------------------------------------

  let card-pages = {
    set page(width: card-width, height: card-height, margin: 0mm)
    card-front
    pagebreak()
    card-back
  }

  // A4 fits a 2 x 5 grid of 90 x 55 mm cards with 15 mm / 11 mm margins.
  // Crop marks sit in the margins, just outside the card edges, so no cut
  // line is printed on the cards.
  let sheet-pages = {
    set page(width: 210mm, height: 297mm, margin: 0mm)

    let cols = 2
    let rows = 5
    let margin-x = (210mm - cols * card-width) / 2
    let margin-y = (297mm - rows * card-height) / 2
    let mark-gap = 1mm
    let mark-length = 4mm
    let mark-thickness = 0.2pt

    let cut-marks() = {
      for c in range(cols + 1) {
        let x = margin-x + c * card-width
        place(
          dx: x - mark-thickness / 2,
          dy: margin-y - mark-gap - mark-length,
          rect(width: mark-thickness, height: mark-length, fill: black),
        )
        place(
          dx: x - mark-thickness / 2,
          dy: 297mm - margin-y + mark-gap,
          rect(width: mark-thickness, height: mark-length, fill: black),
        )
      }
      for r in range(rows + 1) {
        let y = margin-y + r * card-height
        place(
          dx: margin-x - mark-gap - mark-length,
          dy: y - mark-thickness / 2,
          rect(width: mark-length, height: mark-thickness, fill: black),
        )
        place(
          dx: 210mm - margin-x + mark-gap,
          dy: y - mark-thickness / 2,
          rect(width: mark-length, height: mark-thickness, fill: black),
        )
      }
    }

    let sheet(card) = {
      pad(
        x: margin-x,
        y: margin-y,
        grid(
          columns: (card-width,) * cols,
          rows: (card-height,) * rows,
          ..range(cols * rows).map(_ => card),
        ),
      )
      cut-marks()
    }

    sheet(card-front)
    pagebreak()
    sheet(card-back)
  }

  for (i, layout) in layouts.enumerate() {
    if i > 0 { pagebreak() }
    if layout == "card" { card-pages } else { sheet-pages }
  }
}
