// PGP Info Card
//
// A 90 x 55 mm card for the in-person phase of an OpenPGP key signing
// party. The front holds the identity (name, fingerprint, UIDs, contact
// channels); the back holds the fingerprint as a QR code.
//
// The `layouts` parameter selects the output:
//   "card" - one 90 x 55 mm card: front and back
//   "a4"   - ten copies tiled on two A4 sheets (fronts and backs) with
//            dashed cut guides, for printing on plain A4 paper

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
  // `(label, value)` pairs, rendered uppercase in a two-column grid. A
  // pair with a `none` or "" value is omitted. How many pairs fit depends
  // on the UID count; `max-contacts: auto` derives the cap from
  // `uids.len()`, and an integer overrides it.
  contacts: (
    ("GitHub", "@jsmith"),
    ("Website", "https://example.org/"),
    ("Telegram", "@jsmith"),
    ("Matrix", "@jsmith:example.org"),
  ),
  max-contacts: auto,

  note: "Verify the fingerprint before trusting this key.",

  // --- Output -------------------------------------------------------------
  layouts: ("card", "a4"),

  // Filled by the show rule in the template's main.typ.
  body,
) = {
  assert(
    type(uids) == array,
    message: "uids must be an array of strings; a lone UID still needs a trailing comma: (\"...\",)",
  )
  assert(
    uids.len() <= max-uids,
    message: "at most " + str(max-uids) + " UIDs fit on this card",
  )
  assert(
    type(layouts) == array and layouts.len() > 0 and layouts.all(l => l in ("card", "a4")),
    message: "layouts must be an array containing \"card\" and/or \"a4\"",
  )
  assert(
    type(contacts) == array and contacts.all(c =>
      type(c) == array and c.len() == 2 and type(c.at(0)) == str),
    message: "contacts must be an array of (label, value) pairs; a lone pair still needs a trailing comma: ((\"label\", \"value\"),)",
  )
  assert(
    max-contacts == auto or type(max-contacts) == int,
    message: "max-contacts must be `auto` or an integer",
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

  let contact-list = contacts.filter(pair => pair.at(1) != none and pair.at(1) != "")

  // Contact capacity, calibrated against the card front's actual flow
  // heights: the header, rule and empty UID row take 12.20 mm, the note
  // adds 3.79 mm, the first UID adds 0.82 mm, every further one-line UID
  // 3.53 mm, and every contact channel 1.49 mm. Like `max-uids`, this is
  // a count guard: UID lines and contact values that wrap to a second
  // line can still overflow.
  let note-height = if note == none or note == "" { 0mm } else { 3.79mm }
  let uid-height = if uids.len() == 0 { 0mm } else { 0.82mm + (uids.len() - 1) * 3.53mm }
  let contact-capacity = calc.max(
    0,
    2 * calc.floor(
      (card-height - 2 * card-margin - 12.20mm - note-height - uid-height) / (2 * 1.49mm),
    ),
  )
  let effective-max-contacts = if max-contacts == auto { contact-capacity } else { max-contacts }
  assert(
    contact-list.len() <= effective-max-contacts,
    message: "at most " + str(effective-max-contacts) + " contact channels fit with " +
      str(uids.len()) + " UIDs (got " + str(contact-list.len()) +
      "); trim the UIDs or raise `max-contacts`",
  )

  let contact-grid = grid(
    columns: (1fr, 1fr),
    column-gutter: 2.5mm,
    row-gutter: 1.5mm,
    ..contact-list.map(pair => field(upper(pair.at(0)), pair.at(1), value-size: 6.35pt)),
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
      if contact-list.len() > 0 {
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
  // The grid is flush, so these are the widest margins ten cards allow;
  // dashed guides along every card edge run from paper edge to paper edge
  // for a ruler or guillotine to follow, without a solid line on a card.
  let sheet-pages = {
    set page(width: 210mm, height: 297mm, margin: 0mm)

    let cols = 2
    let rows = 5
    let margin-x = (210mm - cols * card-width) / 2
    let margin-y = (297mm - rows * card-height) / 2
    let guide-color = rgb("B0B0AC")
    let guide-thickness = 0.4pt
    let guide-stroke = (
      paint: guide-color,
      thickness: guide-thickness,
      dash: (array: (1.5mm, 1.2mm)),
    )

    let cut-guides() = {
      for c in range(cols + 1) {
        place(
          dx: margin-x + c * card-width - guide-thickness / 2,
          dy: 0mm,
          line(angle: 90deg, length: 297mm, stroke: guide-stroke),
        )
      }
      for r in range(rows + 1) {
        place(
          dx: 0mm,
          dy: margin-y + r * card-height - guide-thickness / 2,
          line(length: 210mm, stroke: guide-stroke),
        )
      }
    }

    // The cards go in through `place` (which takes no flow space) rather
    // than `pad`, so the guides afterwards share the page's top-left
    // anchor and paint on top of the cards.
    let sheet(card) = {
      place(
        dx: margin-x,
        dy: margin-y,
        grid(
          columns: (card-width,) * cols,
          rows: (card-height,) * rows,
          ..range(cols * rows).map(_ => card),
        ),
      )
      cut-guides()
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
