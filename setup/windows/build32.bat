SET VERSION=0.5.0

"C:\Program Files (x86)\NSIS\makensis.exe" /DGAMELANG=ru /DUPPERLANG=RU /DVERSION=%VERSION% PinkieCakeGame.nsi

call create_zip32.bat ru RU
