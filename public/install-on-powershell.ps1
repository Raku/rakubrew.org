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

Function Test-CommandExists {
    Param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
    try {if(Get-Command $command){RETURN $true}}
    Catch {RETURN $false}
    Finally {$ErrorActionPreference=$oldPreference}
}

foreach($cmd in "rakudobrew", "p6env") {
    if (Test-CommandExists $cmd) {
        echo "A previous $cmd installation was found. rakubrew can not be used in"
        echo "parallel with other Raku version managers."
        echo "Please remove $cmd before installing rakubrew."
        exit 1
    }
}

$TMP_DIR = New-TemporaryFile
rm $TMP_DIR
New-Item -Path $TMP_DIR -ItemType "directory" | Out-Null

echo "Downloading rakubrew..."

Invoke-WebRequest https://25-234419075-gh.circle-artifacts.com/0/rakubrew-windows.exe -OutFile "$TMP_DIR/rakubrew.exe"

$RAKUBREW_HOME = . "$TMP_DIR/rakubrew.exe" home | Out-String
$RAKUBREW_HOME = $RAKUBREW_HOME.trim()

if (Test-Path $RAKUBREW_HOME\bin\rakubrew.exe -PathType leaf) {
    echo "A previous rakubrew installation was found here: $RAKUBREW_HOME"
    echo "You should just upgrade your installation instead of installing over it!"
    echo "You can run"
    echo "    rakubrew self-upgrade"
    echo "to do so."

    Remove-Item -Recurse -Force -Path $TMP_DIR
    exit 1
}

echo "Installing rakubrew to $RAKUBREW_HOME ..."
echo ""

New-Item -Path "$RAKUBREW_HOME\bin" -ItemType "Directory" -Force
mv "$TMP_DIR\rakubrew.exe" "$RAKUBREW_HOME\bin\rakubrew.exe"
rm -r $TMP_DIR

. "$RAKUBREW_HOME\bin\rakubrew.exe" init # Further installation instructions
