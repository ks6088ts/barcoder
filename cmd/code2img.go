/*
Copyright © 2022 ks6088ts

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package cmd

import (
	"fmt"
	"image/png"
	"log"
	"os"

	"github.com/spf13/cobra"

	"github.com/boombuler/barcode"
	"github.com/boombuler/barcode/codabar"
	"github.com/boombuler/barcode/code128"
	"github.com/boombuler/barcode/code39"
	"github.com/boombuler/barcode/code93"
	"github.com/boombuler/barcode/datamatrix"
	"github.com/boombuler/barcode/ean"
	"github.com/boombuler/barcode/qr"
	"github.com/boombuler/barcode/twooffive"
)

type barcodeType string

const (
	barcodeTypeCodabar    = barcodeType("codabar")
	barcodeTypeCode128    = barcodeType("code128")
	barcodeTypeCode39     = barcodeType("code39")
	barcodeTypeCode93     = barcodeType("code93")
	barcodeTypeDatamatrix = barcodeType("datamatrix")
	barcodeTypeEan        = barcodeType("ean")
	barcodeTypeQr         = barcodeType("qr")
	barcodeTypeTwooffive  = barcodeType("twooffive")
)

func createBarcode(bts string, code string) (barcode.Barcode, error) {
	bt := barcodeType(bts)
	if bt == barcodeTypeCodabar {
		return codabar.Encode(code)
	}
	if bt == barcodeTypeCode128 {
		return code128.Encode(code)
	}
	if bt == barcodeTypeCode39 {
		return code39.Encode(code, true, true)
	}
	if bt == barcodeTypeCode93 {
		return code93.Encode(code, true, true)
	}
	if bt == barcodeTypeDatamatrix {
		return datamatrix.Encode(code)
	}
	if bt == barcodeTypeEan {
		return ean.Encode(code)
	}
	if bt == barcodeTypeQr {
		return qr.Encode(code, qr.M, qr.Auto)
	}
	if bt == barcodeTypeTwooffive {
		return twooffive.Encode(code, true)
	}
	return nil, fmt.Errorf("barcode type %s is not supported", bt)
}

// code2imgCmd represents the code2img command
var code2imgCmd = &cobra.Command{
	Use:   "code2img",
	Short: "code2img",
	Long:  `generate image from code`,
	Run: func(cmd *cobra.Command, args []string) {
		code, err := cmd.Flags().GetString("code")
		if err != nil {
			log.Fatalf("failed to parse `code`: %v", err)
		}
		width, err := cmd.Flags().GetInt("width")
		if err != nil {
			log.Fatalf("failed to parse `width`: %v", err)
		}
		height, err := cmd.Flags().GetInt("height")
		if err != nil {
			log.Fatalf("failed to parse `height`: %v", err)
		}
		output, err := cmd.Flags().GetString("output")
		if err != nil {
			log.Fatalf("failed to parse `output`: %v", err)
		}
		bts, err := cmd.Flags().GetString("type")
		if err != nil {
			log.Fatalf("failed to parse `type`: %v", err)
		}

		b, err := createBarcode(bts, code)
		if err != nil {
			log.Fatalf("failed to crate a barcode: %v", err)
		}

		b, err = barcode.Scale(b, width, height)
		if err != nil {
			log.Fatalf("failed to scale a barcode: %v", err)
		}

		file, err := os.Create(output)
		if err != nil {
			log.Fatalf("failed to create an output file: %v", err)
		}
		defer file.Close()

		if err = png.Encode(file, b); err != nil {
			log.Fatalf("failed to encode the barcode as png: %v", err)
		}
	},
}

func init() {
	rootCmd.AddCommand(code2imgCmd)

	code2imgCmd.Flags().StringP("code", "c", "code", "code2img")
	code2imgCmd.Flags().IntP("width", "w", 200, "width of output image")
	code2imgCmd.Flags().IntP("height", "e", 200, "height of output image")
	code2imgCmd.Flags().StringP("output", "o", "qr.png", "path to output image")
	code2imgCmd.Flags().StringP("type", "t", "qr", "barcode type (codabar|code128|code39|code93|datamatrix|ean|qr|twooffive)")
}
