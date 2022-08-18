@echo off

mkdir images

for /f "tokens=1 delims=," %%i in (code_list.csv) do (
  barcoder.exe code2img --height 100 --width 500 --type code128 --output images/%%i.png --code %%i
)
