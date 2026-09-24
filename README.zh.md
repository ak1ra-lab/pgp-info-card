# PGP 信息卡

[English](README.md) · 简体中文

[Typst](https://typst.app/) 模板，用于 OpenPGP key signing party 的线下环节，产出一张 90 × 55 mm 的卡片：正面是密钥指纹、User ID 和需要与密钥核对的联系渠道；背面是同一指纹的 QR 码。卡片周边的流程——线下怎么交换、回家认证前要核对什么——见 [key signing party 指南](docs/key-signing-party.zh.md)。

从模板新建一张卡片：

```sh
typst init @preview/pgp-info-card:0.1.0 my-card
cd my-card
$EDITOR main.typ
typst compile main.typ
```

PDF 里是同一张卡的两个版本：第 1–2 页是单张卡（正、背），第 3–4 页是两张 A4，每张平铺十份（正面、背面）并带裁切刻度。要平铺版就用普通 A4 双面打印，再沿刻度裁开——每份都一样，双面翻页方向怎么选都能对上；只要名片大小，就打印第 1–2 页。把 `layouts` 改成 `("card",)` 或 `("a4",)` 可以只保留其中一个版本。

Typst 一次编译只产出一个 PDF。想从同一份输入拆成两个文件，就按页范围导出：

```sh
typst compile --pages 1-2 main.typ card.pdf    # 单张卡
typst compile --pages 3-4 main.typ sheets.pdf  # A4 平铺
```

`--pages` 会去掉 PDF 无障碍标签并给出警告，加 `--no-pdf-tags` 可静音。

## 卡片

模板的参数（在 `main.typ` 里改）：

- `display-name`
- `fingerprint`（每四个十六进制数字一组），显示在名字下方
- `uids`：最多六个单行条目（由 `max-uids` 断言限制；过长的 UID 会折到缩进的第二行）
- 联系渠道：`telegram`、`matrix`、`website`、`github`（设为 `none` 或 `""` 的渠道不会显示）
- `note`：底部一行小字（默认 "Verify the fingerprint before trusting this key."）
- `layouts`：输出哪个版本，默认 `("card", "a4")`，也可以只写 `("card",)` 或 `("a4",)`

每张 A4 按 2 × 5 平铺十份 90 × 55 mm 卡片，四周留 15 mm / 11 mm，边距里画 4 mm 裁切刻度。背面 QR 码里是去掉空格的指纹，扫出来的字符串，正好是你下载密钥后要比对的那一串。

## 开发

仓库采用 [Typst packages](https://github.com/typst/packages) 的目录结构：`lib.typ` 是包入口，`template/` 是 `typst init` 会复制的文件。不发布、直接从 clone 测试：

```sh
mkdir -p /tmp/typst-packages/preview/pgp-info-card
ln -s "$PWD" /tmp/typst-packages/preview/pgp-info-card/0.1.0
typst init --package-path /tmp/typst-packages @preview/pgp-info-card:0.1.0 /tmp/my-card
typst compile --package-path /tmp/typst-packages /tmp/my-card/main.typ
```

## 许可证

[MIT](LICENSE)
