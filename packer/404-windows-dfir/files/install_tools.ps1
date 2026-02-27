# Enable WSL 2
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
wsl --set-default-version 2

# Install Windows Terminal
Invoke-WebRequest -Uri "https://github.com/microsoft/terminal/releases/download/v1.15.2921.0/Microsoft.WindowsTerminal_1.15.2921.0_8wekyb3d8bbwe.msixbundle" -OutFile "terminal.msixbundle"
Add-AppxPackage -Path "terminal.msixbundle"

# Install Sysinternals Suite
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/SysinternalsSuite.zip" -OutFile "SysinternalsSuite.zip"
Expand-Archive -Path "SysinternalsSuite.zip" -DestinationPath "C:\Sysinternals"
New-Item -Path "C:\Sysinternals" -ItemType Directory -Force
Set-Location "C:\Sysinternals"
Start-Process -FilePath "C:\Sysinternals\SysinternalsSuite.zip"

# Install Microsoft PowerToys
Invoke-WebRequest -Uri "https://github.com/microsoft/PowerToys/releases/download/v0.57.2/PowerToysSetup-0.57.2-x64.exe" -OutFile "PowerToysSetup.exe"
Start-Process -FilePath "PowerToysSetup.exe" -ArgumentList '/S' -Wait

# Install DCode
Invoke-WebRequest -Uri "https://www.digital-detective.com/start/dcode/" -OutFile "dcode_installer.exe"
Start-Process -FilePath "dcode_installer.exe" -ArgumentList '/S' -Wait

# Install FTK Imager
Invoke-WebRequest -Uri "https://accessdata.com/product-download" -OutFile "ftkimager_installer.exe"
Start-Process -FilePath "ftkimager_installer.exe" -ArgumentList '/S' -Wait

# Install PST Walker
# Note: Replace the URL with the actual download link for PST Walker
Invoke-WebRequest -Uri "https://www.pstwalker.com/download" -OutFile "pstwalker_installer.exe"
Start-Process -FilePath "pstwalker_installer.exe" -ArgumentList '/S' -Wait

# Install Arsenal Image Mounter
Invoke-WebRequest -Uri "https://arsenalrecon.com/downloads/" -OutFile "aim_installer.exe"
Start-Process -FilePath "aim_installer.exe" -ArgumentList '/S' -Wait

# Install Hibernation Recon
# Note: Replace the URL with the actual download link for Hibernation Recon
Invoke-WebRequest -Uri "https://www.arcticwolf.com/hibernationrecon" -OutFile "hibernationrecon_installer.exe"
Start-Process -FilePath "hibernationrecon_installer.exe" -ArgumentList '/S' -Wait

# Install KAPE
Invoke-WebRequest -Uri "https://ericzimmerman.github.io/KapeDocs/#!Pages/0.-Download.md" -OutFile "kape_installer.exe"
Start-Process -FilePath "kape_installer.exe" -ArgumentList '/S' -Wait

# Install NirSoft Tools
Invoke-WebRequest -Uri "https://laelaps.nirsoft.net/download/NirSoftUtils.zip" -OutFile "NirSoftUtils.zip"
Expand-Archive -Path "NirSoftUtils.zip" -DestinationPath "C:\NirSoftTools"
New-Item -Path "C:\NirSoftTools" -ItemType Directory -Force
Set-Location "C:\NirSoftTools"
Start-Process -FilePath "C:\NirSoftTools\NirSoftUtils.zip"

# Install X-Ways Forensics
# Note: Replace the URL with the actual download link for X-Ways Forensics
Invoke-WebRequest -Uri "https://www.x-ways.net/winhex/" -OutFile "xways_installer.exe"
Start-Process -FilePath "xways_installer.exe" -ArgumentList '/S' -Wait

# Install Eric Zimmerman Tools
# Note: Replace the URL with the actual download link for Eric Zimmerman Tools
Invoke-WebRequest -Uri "https://ericzimmerman.github.io/#!index.md" -OutFile "eztools_installer.exe"
Start-Process -FilePath "eztools_installer.exe" -ArgumentList '/S' -Wait

# Install Chainsaw
Invoke-WebRequest -Uri "https://github.com/withsecurelabs/chainsaw/releases" -OutFile "chainsaw_installer.exe"
Start-Process -FilePath "chainsaw_installer.exe" -ArgumentList '/S' -Wait

# Install INDXRipper
# Note: Replace the URL with the actual download link for INDXRipper
Invoke-WebRequest -Uri "https://github.com/jankais3r/INDXRipper" -OutFile "indxripper_installer.exe"
Start-Process -FilePath "indxripper_installer.exe" -ArgumentList '/S' -Wait

# Install RegRipper
Invoke-WebRequest -Uri "https://github.com/keydet89/RegRipper3.0" -OutFile "regripper.zip"
Expand-Archive -Path "regripper.zip" -DestinationPath "C:\RegRipper"
New-Item -Path "C:\RegRipper" -ItemType Directory -Force
Set-Location "C:\RegRipper"
Start-Process -FilePath "C:\RegRipper\regripper.zip"

# Install balenaEtcher
Invoke-WebRequest -Uri "https://github.com/balena-io/etcher/releases/download/v1.7.9/balenaEtcher-Setup-1.7.9.exe" -OutFile "balenaEtcher_installer.exe"
Start-Process -FilePath "balenaEtcher_installer.exe" -ArgumentList '/S' -Wait

# Install Sysinternals Suite (RDCMan)
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/RDCMan.zip" -OutFile "RDCMan.zip"
Expand-Archive -Path "RDCMan.zip" -DestinationPath "C:\RDCMan"
New-Item -Path "C:\RDCMan" -ItemType Directory -Force
Set-Location "C:\RDCMan"
Start-Process -FilePath "C:\RDCMan\RDCMan.zip"

# Install Visual Studio Code
Invoke-WebRequest -Uri "https://code.visualstudio.com/docs/?dv=win" -OutFile "vscode_installer.exe"
Start-Process -FilePath "vscode_installer.exe" -ArgumentList '/S' -Wait

