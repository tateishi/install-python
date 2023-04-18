function Confirm($title, $message="") {
    $CollectionType = [System.Management.Automation.Host.ChoiceDescription]
    $ChoiceType = "System.Collections.ObjectModel.Collection"

    $descriptions = New-Object "$ChoiceType``1[$CollectionType]"
    $questions = (("&Yes", "実行します"), ("&No", "実行しません"))
    $questions | %{$descriptions.Add((New-Object $CollectionType $_))}

    $answer = $host.UI.PromptForChoice($title, $message, $descriptions, 1)

    return $answer
}

function Download-Archive($url, $file, $dest) {
    if (-Not(Test-Path $dest)) {
        New-Item $dest -ItemType Directory > $null
    }

    Push-Location $dest
    Invoke-WebRequest $url -OutFile $file
    Pop-Location
}

function Copy-Unattend-File($dest, $path_flag) {
    $dest_file = Join-Path $dest "unattend.xml"
    if ($path_flag) {
        $unattend_file = "unattend_with_path.xml"
    } else {
        $unattend_file = "unattend.xml"
    }
    Copy-Item $unattend_file $dest_file
}

function Invoke-Installer($dest, $file) {
    Push-Location $dest
    Start-Process -FilePath $file -ArgumentList "/passive" -Wait
    Pop-Location
}

function Remove-Temp-Directory($dest) {
    Remove-Item $dest -Recurse
}

function Install-Python($url, $path_flag) {
    $dest = Join-Path $env:TEMP "python"
    $file = $url.split("/")[-1]

    Download-Archive $url $file $dest
    Copy-Unattend-File $dest $path_flag
    Invoke-Installer $dest $file
    Remove-Temp-Directory $dest
}

function Copy-Pyini($inifile) {
    $dest = $env:LOCALAPPDATA

    Copy-Item $inifile $dest
}

$ans = Confirm("実行確認")
if ($ans -eq 1) {
    Exit 1
}

Install-Python "https://www.python.org/ftp/python/3.7.9/python-3.7.9-amd64-webinstall.exe" $false
Install-Python "https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe" $false
Install-Python "https://www.python.org/ftp/python/3.9.13/python-3.9.13-amd64.exe" $false
Install-Python "https://www.python.org/ftp/python/3.10.11/python-3.10.11-amd64.exe" $false
Install-Python "https://www.python.org/ftp/python/3.11.3/python-3.11.3-amd64.exe" $true
Install-Python "https://www.python.org/ftp/python/3.12.0/python-3.12.0a7-amd64.exe" $false

Copy-Pyini "py.ini"