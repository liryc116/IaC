# Install Virtio Drivers
Write-Output "Starting Virtio drivers installation..."

# Download Virtio ISO
$virtioIsoUrl = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.240-1/virtio-win-0.1.240.iso"
$virtioIsoPath = "C:\virtio-win.iso"
Invoke-WebRequest -Uri $virtioIsoUrl -OutFile $virtioIsoPath

# Mount the ISO
$mountResult = Mount-DiskImage -ImagePath $virtioIsoPath -PassThru
$driveLetter = ($mountResult | Get-Volume).DriveLetter + ":"

# Install the drivers using pnputil
Write-Output "Installing Virtio drivers from $driveLetter"
pnputil /add-driver "$driveLetter\*.inf" /install

# Dismount the ISO
Dismount-DiskImage -ImagePath $virtioIsoPath

Write-Output "Virtio drivers installation completed."

