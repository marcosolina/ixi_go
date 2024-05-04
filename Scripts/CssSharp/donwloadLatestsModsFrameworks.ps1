
$URL = "https://www.sourcemm.net/downloads.php?branch=dev"

# Fetch HTML content
$HTML = Invoke-WebRequest -Uri $URL

# Extract download link
$TAG = $HTML.RawContent | Select-String -Pattern "<a.*class='quick-download download-link'.*href='[^']*linux.tar.gz'" | Select-Object -ExpandProperty Matches

# Extract the URL from the matched tag
$FILE_URL = $TAG.Value -replace ".*href='([^']*)'.*", '$1'

$metaModeFile = "$PSScriptRoot/metamod.tar.gz"

# Download the file
Invoke-WebRequest -Uri $FILE_URL -OutFile $metaModeFile


$CSS_URL="https://api.github.com/repos/roflmuffin/CounterStrikeSharp/releases/latest"

# Fetch HTML content
$HTML = Invoke-WebRequest -Uri $CSS_URL | ConvertFrom-Json

$cssSharpFile = "$PSScriptRoot/cssharp.zip"
$HTML.assets | ForEach-Object {
    if ($_.name -like "*with-runtime-build*linux*") {
        $_.browser_download_url
        Invoke-WebRequest -Uri $_.browser_download_url -OutFile $cssSharpFile
    }
}

$cssSharpUnzipDir = "$PSScriptRoot/cssharp"
# Extract the files
tar -xf $metaModeFile -C $PSScriptRoot
Expand-Archive -Path $cssSharpFile -DestinationPath $cssSharpUnzipDir

# Merge directories if they exist
$sourceDir = "$PSScriptRoot/cssharp/addons"
$destinationDir = "$PSScriptRoot/addons"


Copy-Item -Path $sourceDir\* -Destination $destinationDir -Recurse -Force

Compress-Archive -Path $destinationDir -DestinationPath "$PSScriptRoot/addons.zip"

Remove-Item -Path $metaModeFile
Remove-Item -Path $cssSharpFile
Remove-Item -Path $cssSharpUnzipDir -Recurse -Force
Remove-Item -Path $destinationDir -Recurse -Force