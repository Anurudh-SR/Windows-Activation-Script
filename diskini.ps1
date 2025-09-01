# Check for administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as administrator and try again."
    exit 1
}

# Get available drive letters
$AllLetters = 67..90 | ForEach-Object {[char]$_}
$UsedLetters = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Name
$AvailableLetters = $AllLetters | Where-Object {$_ -notin $UsedLetters}

Write-Host "Available drive letters: $($AvailableLetters -join ', ')" -ForegroundColor Cyan

# Get uninitialized disks
$UninitializedDisks = Get-Disk | Where-Object {$_.PartitionStyle -eq 'RAW'}

if ($UninitializedDisks.Count -eq 0) {
    Write-Host "No uninitialized disks found." -ForegroundColor Green
    exit 0
}

# Process each disk
$letterIndex = 0
foreach ($disk in $UninitializedDisks) {
    if ($letterIndex -ge $AvailableLetters.Count) {
        Write-Host "No more available drive letters!" -ForegroundColor Red
        break
    }
    
    $diskNumber = $disk.Number
    $assignedLetter = $AvailableLetters[$letterIndex]
    
    Write-Host "Processing Disk $diskNumber ($([math]::Round($disk.Size/1GB,2)) GB)..." -ForegroundColor Yellow
    
    try {
        # Initialize, partition, and format
        Initialize-Disk -Number $diskNumber -PartitionStyle GPT -Confirm:$false
        $partition = New-Partition -DiskNumber $diskNumber -UseMaximumSize -DriveLetter $assignedLetter
        Format-Volume -DriveLetter $assignedLetter -FileSystem NTFS -NewFileSystemLabel "Disk $diskNumber" -Confirm:$false | Out-Null
        
        Write-Host "Successfully assigned drive $assignedLetter`: to Disk $diskNumber" -ForegroundColor Green
        $letterIndex++
        
    } catch {
        Write-Host "Error processing Disk $diskNumber`: $_" -ForegroundColor Red
    }
}

Write-Host "`nDisk initialization completed!" -ForegroundColor Green
Get-Disk | Format-Table Number, OperationalStatus, PartitionStyle, @{Name='Size(GB)';Expression={[math]::Round($_.Size/1GB,2)}} -AutoSize
