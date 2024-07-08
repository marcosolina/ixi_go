Write-Host "Copying the *.dem files from the server to the current folder" -ForegroundColor Green

$currentFolder = $PSScriptRoot

#scp -o StrictHostKeyChecking=no marco@ixigo.selfip.net:/home/marco/cs2/game/csgo/replays/*.dem $currentFolder
scp -o StrictHostKeyChecking=no marco@ixigo.selfip.net:/home/marco/cs2/game/csgo/addons/metamod/replays/*.dem $currentFolder

Write-Host "Do you want to push the files to the server? (Y/N)" -ForegroundColor Green -NoNewline
$pushFiles = Read-Host " "
if ($pushFiles -ne "Y") {
    Write-Host "Script terminated." -ForegroundColor Red
    exit
}


$demFiles = Get-ChildItem -Filter "*.dem"
foreach ($file in $demFiles) {
    $apiUrl = "https://marco.selfip.net/ixigoproxy/ixigo-dem-manager/demmanager/files"
    
    Write-Host "Uploading file: $($file.FullName)" -ForegroundColor Yellow

    $multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
    $multipartFile =  $file.FullName
    $FileStream = [System.IO.FileStream]::new($multipartFile, [System.IO.FileMode]::Open)
    $fileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
    $fileHeader.Name = "file"
    $fileHeader.FileName = $($file.Name)
    $fileContent = [System.Net.Http.StreamContent]::new($FileStream)
    $fileContent.Headers.ContentDisposition = $fileHeader
    $multipartContent.Add($fileContent)

    $body = $multipartContent

    Invoke-RestMethod $apiUrl -Method 'POST' -Headers $headers -Body $body
}

Write-Host "Triggering parse DEM files" -ForegroundColor Cyan
$response = Invoke-RestMethod 'https://marco.selfip.net/ixigoproxy/ixigo-dem-manager/demmanager/parse/all' -Method 'POST' -Headers $headers
$response | ConvertTo-Json