@echo off

rmdir /s /q generated
mkdir generated

for /f "tokens=1,2 delims=," %%i in (code_list.csv) do (
  barcoder.exe code2img --height 100 --width 500 --type code128 --output generated/%%i.png --code %%i
  echo %%i %%j ^<img src="./%%i.png" width="100%%"^> >> generated/sheet.md
)
