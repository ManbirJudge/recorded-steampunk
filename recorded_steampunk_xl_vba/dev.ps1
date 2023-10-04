# vars
$pythonVenvPath = ".\venv"
$requirementsPath = ".\requirements.txt"

# ---
if (!(Test-Path -Path $pythonVenvPath)) {
    Write-Host "--------------------------------- Virutal environment not present at specified location. Creating one ... ---------------------------------`n"
    python -m venv $pythonVenvPath
}

Write-Host "`n--------------------------------- Activating Python virtual environment. ---------------------------------`n"
Start-Process ($pythonVenvPath + "\Scripts\Activate.ps1")

Write-Host "`n--------------------------------- Installing required dependencies. ---------------------------------`n"
pip install -r $requirementsPath

Write-Host "`n--------------------------------- Starting xwlings VBA editing. ---------------------------------`n"
xlwings vba edit --file '.\Test Record.xlsm'
