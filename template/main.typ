// PGP Info Card
//
// Edit your details below, then compile:
//
//   typst compile main.typ
//
// The PDF contains the single card (front, back) followed by two A4
// sheets with ten copies each (fronts, backs) and crop marks. Change
// `layouts` to ("card",) or ("a4",) to emit only one of the two.

#import "@preview/pgp-info-card:0.1.0": pgp-info-card

#show: pgp-info-card.with(
  display-name: "John Smith",
  fingerprint: "0123 4567 89AB CDEF 0123 4567 89AB CDEF 0123 4567",
  uids: (
    "John Smith <jsmith@example.org>",
    "John Smith (work) <jsmith@example.com>",
    "John Smith (alt) <jsmith@example.net>",
  ),
  // (label, value) pairs; labels are uppercased. The number that fits
  // grows as UIDs shrink, and `max-contacts` overrides the automatic cap.
  contacts: (
    ("GitHub", "@jsmith"),
    ("Website", "https://example.org/"),
    ("Telegram", "@jsmith"),
    ("Matrix", "@jsmith:example.org"),
  ),
  note: "Verify the fingerprint before trusting this key.",
  layouts: ("card", "a4"),
)
