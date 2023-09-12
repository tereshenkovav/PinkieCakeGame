SET VERSION=0.6.0

"C:\Program Files (x86)\NSIS\makensis.exe" /DGAMELANG=ru /DUPPERLANG=RU /DVERSION=%VERSION% PinkieCakeGame.nsi
"C:\Program Files (x86)\NSIS\makensis.exe" /DGAMELANG=en /DUPPERLANG=EN /DVERSION=%VERSION% PinkieCakeGame.nsi

call create_zip32.bat ru RU
call create_zip32.bat en EN
