if NOT "%~1" == "" goto mainproc

echo "Argument - lang code" 
exit

:mainproc

rm -f PinkieCakeGame-%2-%VERSION%-Win32.zip

echo %1 > ..\..\bin\text\deflang

7z a -mx9 PinkieCakeGame-%2-%VERSION%-Win32.zip ..\..\bin\*
