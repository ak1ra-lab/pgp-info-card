# PGP Info Card

English · [简体中文](README.zh.md)

A [Typst](https://typst.app/) template for a 90 × 55 mm card used at the **in-person phase of an OpenPGP key signing party**: the front carries your key's fingerprint, its User IDs, and the contact channels that should be verified against the key; the back carries the same fingerprint as a QR code. The process around the card — the in-person exchange and the checks done at home before certifying — is documented in the [key signing party guide](docs/key-signing-party.md).

Start a new card from the template:

```sh
typst init @preview/pgp-info-card:0.1.0 my-card
cd my-card
$EDITOR main.typ
typst compile main.typ
```

The PDF holds both versions of the same card: the single card on pages 1–2 (front, back) and two A4 sheets on pages 3–4 with ten copies each (fronts, backs) and crop marks. Print the A4 sheets double-sided on plain paper and cut along the crop marks; every copy is identical, so any duplex mode lines up. Print pages 1–2 instead if you want a single card at business-card size. Set `layouts` to `("card",)` or `("a4",)` to emit only one of the two.

Typst writes one PDF per compile. To split the combined PDF into one file per version, export page ranges from the same input:

```sh
typst compile --pages 1-2 main.typ card.pdf    # single card
typst compile --pages 3-4 main.typ sheets.pdf  # A4 sheets
```

`--pages` drops the PDF accessibility tags and prints a warning; add `--no-pdf-tags` to silence it.

## The card

The template takes the following arguments (edit them in `main.typ`):

- `display-name`
- `fingerprint` (formatted in groups of four hex digits), shown under the name
- `uids` — up to six one-line entries (guarded by `max-uids`; a longer UID wraps onto an indented second line)
- contact channels: `telegram`, `matrix`, `website`, `github` (a channel set to `none` or `""` is omitted)
- `note` — a short line at the bottom (defaults to "Verify the fingerprint before trusting this key.")
- `layouts` — which outputs to emit: `("card", "a4")` by default, or `("card",)` / `("a4",)`

Each A4 sheet tiles ten copies in a 2 × 5 grid of 90 × 55 mm cards, with 15 mm / 11 mm margins and 4 mm crop marks in the margins. The QR code on the back encodes the fingerprint without whitespace, so scanning it yields exactly the string you compare against the downloaded key.

## Development

The repository follows the [Typst packages](https://github.com/typst/packages) layout: `lib.typ` is the package entrypoint, and `template/` is what `typst init` copies. To test a clone without publishing:

```sh
mkdir -p /tmp/typst-packages/preview/pgp-info-card
ln -s "$PWD" /tmp/typst-packages/preview/pgp-info-card/0.1.0
typst init --package-path /tmp/typst-packages @preview/pgp-info-card:0.1.0 /tmp/my-card
typst compile --package-path /tmp/typst-packages /tmp/my-card/main.typ
```

## License

[MIT](LICENSE)
