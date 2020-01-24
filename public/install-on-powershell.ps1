$ErrorActionPreference = "Stop"

function CheckLastExitCode {
    if ($LastExitCode -ne 0) {
        $msg = @"
Program failed with: $LastExitCode
Callstack: $(Get-PSCallStack | Out-String)
"@
        throw $msg
    }
}

$TEMP_FILE = New-TemporaryFile
Invoke-WebRequest http://rakubrew.org/win/rakubrew.exe -OutFile $TEMP_FILE

$RAKUBREW_HOME = $TEMP_FILE home | Out-String
mv $TEMP_FILE $RAKUBREW_HOME/bin/rakubrew.exe

$RAKUBREW_HOME/bin/rakubrew.exe init # Further installation instructions

