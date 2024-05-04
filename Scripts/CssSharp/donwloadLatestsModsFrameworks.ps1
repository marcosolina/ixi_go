$LogFile = "C:\tmp\addons.log"
Start-Transcript -path $LogFile -append


$baseFolder = $PSScriptRoot

$csgoUtilDir = "$baseFolder\csgo_util"
git clone "https://github.com/marcosolina/csgo_util.git" $csgoUtilDir

$URL = "https://www.sourcemm.net/downloads.php?branch=dev"

# Fetch HTML content
$HTML = Invoke-WebRequest -Uri $URL

# Extract download link
$TAG = $HTML.RawContent | Select-String -Pattern "<a.*class='quick-download download-link'.*href='[^']*linux.tar.gz'" | Select-Object -ExpandProperty Matches

# Extract the URL from the matched tag
$FILE_URL = $TAG.Value -replace ".*href='([^']*)'.*", '$1'

$metaModeFile = "$baseFolder/metamod.tar.gz"

# Download the file
Invoke-WebRequest -Uri $FILE_URL -OutFile $metaModeFile


$CSS_URL="https://api.github.com/repos/roflmuffin/CounterStrikeSharp/releases/latest"

# Fetch HTML content
$HTML = Invoke-WebRequest -Uri $CSS_URL | ConvertFrom-Json

$cssSharpFile = "$baseFolder/cssharp.zip"
$HTML.assets | ForEach-Object {
    if ($_.name -like "*with-runtime-build*linux*") {
        $_.browser_download_url
        Invoke-WebRequest -Uri $_.browser_download_url -OutFile $cssSharpFile
    }
}

$cssSharpUnzipDir = "$baseFolder/cssharp"
# Extract the files
tar -xf $metaModeFile -C $baseFolder
Expand-Archive -Path $cssSharpFile -DestinationPath $cssSharpUnzipDir

# Merge directories if they exist
$sourceDir = "$cssSharpUnzipDir/addons"
$destinationDir = "$baseFolder/addons"


Copy-Item -Path $sourceDir\* -Destination $destinationDir -Recurse -Force

$ixigoPluginDir = "$csgoUtilDir\CsgoPlugins\IxigoPlugin"
$ixigoPluginBinDir = "$csgoUtilDir\CsgoPlugins\IxigoPlugin\bin\Debug\net8.0"

dotnet add $ixigoPluginDir package CounterStrikeSharp.API
dotnet clean $ixigoPluginDir
dotnet build $ixigoPluginDir

$cssSharpDirectoryPlugins = "$destinationDir/counterstrikesharp/plugins"

$ixigoPluginDir = "$cssSharpDirectoryPlugins/IxigoPlugin"
New-Item -ItemType Directory -Path $ixigoPluginDir

Copy-Item -Path $ixigoPluginBinDir\* -Destination $ixigoPluginDir -Recurse -Force


Compress-Archive -Path $destinationDir -DestinationPath "$baseFolder/addons.zip"

Remove-Item -Path $metaModeFile
Remove-Item -Path $cssSharpFile
Remove-Item -Path $cssSharpUnzipDir -Recurse -Force
Remove-Item -Path $destinationDir -Recurse -Force
Remove-Item -Path $csgoUtilDir -Recurse -Force


Move-Item -Path "$baseFolder/addons.zip" -Destination "$baseFolder/../.." -Force

git commit -a -m "updating plugin framework"
git push origin

Stop-Transcript