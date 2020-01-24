TEMP_FILE=powershell -command "New-TemporaryFile.FullName"
powershell -command "Invoke-WebRequest https://rakubrew.org/win/rakubrew.exe -OutFile %TEMP_FILE%"
SET RAKUBREW_HOME=%TEMP_FILE% home
mv %TEMP_FILE% %RAKUBREW_HOME%/bin/rakubrew.exe
%RAKUBREW_HOME%/bin/rakubrew.exe init
