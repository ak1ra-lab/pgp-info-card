# Package coordinates; keep in sync with typst.toml.
version := "0.1.0"
package := "preview/pgp-info-card"
packages-dir := env("XDG_DATA_HOME", home_directory() / ".local/share") / "typst/packages"
package-dir := packages-dir / package / version

# show available recipes
default:
    @just --list --unsorted

# symlink this checkout into the local Typst package directory
link:
    mkdir -p "{{ packages-dir }}/{{ package }}"
    ln -sfn "{{ justfile_directory() }}" "{{ package-dir }}"

# create a new card from the template (e.g. `just init my-card`)
init dest: link
    typst init @{{ package }}:{{ version }} "{{ dest }}"

# compile a card into card.pdf and sheet.pdf (e.g. `just compile my-card`)
compile dest: link
    typst compile --no-pdf-tags --pages 1-2 "{{ dest }}/main.typ" "{{ dest }}/card.pdf"
    typst compile --no-pdf-tags --pages 3-4 "{{ dest }}/main.typ" "{{ dest }}/sheet.pdf"
