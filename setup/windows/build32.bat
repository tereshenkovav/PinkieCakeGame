SET VERSION=1.0.0

"C:\Program Files (x86)\NSIS\makensis.exe" /DGAMELANG=ru /DUPPERLANG=RU /DVERSION=%VERSION% PinkieCakeGame.nsi
"C:\Program Files (x86)\NSIS\makensis.exe" /DGAMELANG=en /DUPPERLANG=EN /DVERSION=%VERSION% PinkieCakeGame.nsi

del ..\..\bin\text\deflang

SmartZipBuilder.exe script.szb /LANGL=ru /LANGH=RU
SmartZipBuilder.exe script.szb /LANGL=en /LANGH=EN
