# PGP Info Card

[![GitHub](https://img.shields.io/badge/GitHub-ak1ra--lab%2Fpgp--info--card-181717?logo=github&logoColor=white)](https://github.com/ak1ra-lab/pgp-info-card)
[![Typst 0.13+](https://img.shields.io/badge/Typst-0.13%2B-239DAD?logo=typst&logoColor=white)](https://typst.app/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

English · [简体中文](README.zh.md)

A [Typst](https://typst.app/) template for a 90 × 55 mm card used at the **in-person phase of an OpenPGP key signing party**: the front carries your key's fingerprint, its User IDs, and the contact channels that should be verified against the key; the back carries the same fingerprint as a QR code. The process around the card — the in-person exchange and the checks done at home before certifying — is documented in the [key signing party guide](docs/key-signing-party.md).

Start a new card from the template:

```sh
typst init @preview/pgp-info-card:0.1.0 my-card
cd my-card
$EDITOR main.typ
typst compile main.typ
```

The PDF holds both versions of the same card: the single card on pages 1–2 (front, back) and two A4 sheets on pages 3–4 with ten copies each (fronts, backs) and dashed cut guides. Print the A4 sheets double-sided on plain paper and cut along the guides; every copy is identical, so any duplex mode lines up. Print pages 1–2 instead if you want a single card at business-card size.

## The card

The template takes the following arguments (edit them in `main.typ`):

- `display-name`
- `fingerprint` (formatted in groups of four hex digits), shown under the name
- `uids` — up to six one-line entries (guarded by `max-uids`; a longer UID wraps onto an indented second line)
- `contacts` — `(label, value)` pairs rendered in a two-column grid, labels uppercased (a pair with a `none` or `""` value is omitted); the number of pairs that fit grows as UIDs shrink, with `max-contacts: auto` computing the cap and an integer overriding it
- `note` — a short line at the bottom (defaults to "Verify the fingerprint before trusting this key.")
- `layouts` — which outputs to emit: `("card", "a4")` by default, or `("card",)` / `("a4",)`

Each A4 sheet tiles ten copies in a 2 × 5 grid of 90 × 55 mm cards with 15 mm / 11 mm margins. The QR code on the back encodes the fingerprint without whitespace, so scanning it yields exactly the string you compare against the downloaded key.

## Development

The repository follows the [Typst packages](https://github.com/typst/packages) layout: `lib.typ` is the package entrypoint and `template/` is what `typst init` copies. The [justfile](justfile) symlinks a clone into Typst's package directory (no `--package-path` needed) and compiles the split PDFs:

```sh
just link              # symlink the checkout into Typst's package directory
just init my-card      # create a card from the local template
just compile my-card   # card.pdf (pages 1-2) and sheet.pdf (pages 3-4)
```

Bump `version` in both `typst.toml` and the justfile when releasing.

## License

[MIT](LICENSE)
