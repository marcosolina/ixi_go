$LogFile = "C:\tmp\addons.log"

Start-Transcript -path $LogFile -append


$baseFolder = $PSScriptRoot

##########################################################
# Download the latest version of CounterStrikeSharp plugin
##########################################################

$CSS_URL="https://api.github.com/repos/roflmuffin/CounterStrikeSharp/releases/latest"
$HTML = Invoke-WebRequest -Uri $CSS_URL | ConvertFrom-Json

# If I have the latest version, I can stop the script
$filePath = "$baseFolder/latest.id"

if (-not (Test-Path $filePath)) {
    New-Item -Path $filePath -ItemType File -Force
}

$containsString = Get-Content $filePath -ErrorAction SilentlyContinue | Select-String -Pattern $HTML.id
$id = $HTML.id
if ($containsString) {
    Write-Host "The file contains the string $id"
    Exit 0
} else {
    $HTML.id | Set-Content -Path $filePath
    Write-Host "The file does not contain the string $id"
}

# New version available, download the file
$cssSharpFile = "$baseFolder/cssharp.zip"
$HTML.assets | ForEach-Object {
    if ($_.name -like "*with-runtime-build*linux*") {
        $_.browser_download_url
        Invoke-WebRequest -Uri $_.browser_download_url -OutFile $cssSharpFile
    }
}


#########################################################
# Download the latest version of Metamod plugin framework
#########################################################
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


########################################################
# Extract metamod and CounterStrikeSharp plugin files
# and merge them into the destination directory
########################################################
$cssSharpUnzipDir = "$baseFolder/cssharp"
# Extract the files
tar -xf $metaModeFile -C $baseFolder
Expand-Archive -Path $cssSharpFile -DestinationPath $cssSharpUnzipDir

# Merge directories if they exist
$sourceDir = "$cssSharpUnzipDir/addons"
$destinationDir = "$baseFolder/addons"

Copy-Item -Path $sourceDir\* -Destination $destinationDir -Recurse -Force

#################################################
# Clone the repo that contains the CSSharp plugin
################################################# 
$csgoUtilDir = "$baseFolder\csgo_util"
git clone "https://github.com/marcosolina/csgo_util.git" $csgoUtilDir
$ixigoPluginDir = "$csgoUtilDir\CsgoPlugins\IxigoPlugin"
$ixigoPluginBinDir = "$csgoUtilDir\CsgoPlugins\IxigoPlugin\bin\Debug\net8.0"

# Build the plugin
dotnet add $ixigoPluginDir package CounterStrikeSharp.API
dotnet clean $ixigoPluginDir
dotnet build $ixigoPluginDir

# Copy the plugin to the destination directory
$cssSharpDirectoryPlugins = "$destinationDir/counterstrikesharp/plugins"
$ixigoPluginDir = "$cssSharpDirectoryPlugins/IxigoPlugin"
New-Item -ItemType Directory -Path $ixigoPluginDir
Copy-Item -Path $ixigoPluginBinDir\* -Destination $ixigoPluginDir -Recurse -Force

#########################################################
# Compress the files and move them to the root directory
#########################################################
Compress-Archive -Path $destinationDir -DestinationPath "$baseFolder/addons.zip"
Move-Item -Path "$baseFolder/addons.zip" -Destination "$baseFolder/../.." -Force

# Clean up
Remove-Item -Path $metaModeFile
Remove-Item -Path $cssSharpFile
Remove-Item -Path $cssSharpUnzipDir -Recurse -Force
Remove-Item -Path $destinationDir -Recurse -Force
Remove-Item -Path $csgoUtilDir -Recurse -Force


# Commit the changes
git -C $baseFolder commit -a -m "updating plugin framework"
git -C $baseFolder push origin

Stop-Transcript

Exit 0