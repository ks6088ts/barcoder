[![go](https://github.com/ks6088ts/barcoder/workflows/go/badge.svg)](https://github.com/ks6088ts/barcoder/actions/workflows/go.yml)
[![release](https://github.com/ks6088ts/barcoder/workflows/release/badge.svg)](https://github.com/ks6088ts/barcoder/actions/workflows/release.yml)

# barcoder

A CLI for handling barcode related tasks

## How to use

```bash
# Help command
❯ ./dist/barcoder code2img -h
generate image from code

Usage:
  barcoder code2img [flags]

Flags:
  -c, --code string     code2img (default "code")
  -e, --height int      height of output image (default 200)
  -h, --help            help for code2img
  -o, --output string   path to output image (default "qr.png")
  -t, --type string     barcode type (codabar|code128|code39|code93|datamatrix|ean|qr|twooffive) (default "qr")
  -w, --width int       width of output image (default 200)

# Generate `hello` QR code to generated/hello.png
❯ ./dist/barcoder code2img \
  --code hello \
  --output generated/hello.png \
  --height 200 \
  --width 200 \
  --type qr
```
