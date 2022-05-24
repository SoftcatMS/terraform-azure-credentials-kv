$disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number

$letters = 70..89 | ForEach-Object { [char]$_ }
$count = 0
$label = "Data "

foreach ($disk in $disks) {
    $driveLetter = $letters[$count].ToString()
    $disk |
    Initialize-Disk -PartitionStyle GPT -PassThru |
    New-Partition -UseMaximumSize -DriveLetter $driveLetter |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel $label$driveLetter -Confirm:$false -Force
$count++
}

$userName = "softcatadmin"
$checkForUser = (Get-LocalUser).Name -Contains $userName

if ($checkForUser -eq $false) { 
    New-LocalUser -AccountNeverExpires:$true -Password (ConvertTo-SecureString -AsPlainText -Force "C0mpl3xP4sswd") -Name $userName -Description "Softcat Administrator" 
    Add-LocalGroupMember -Group "Administrators" -Member $userName
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member $userName
} 
ElseIf ($checkForUser -eq $true) 
{ 
    Write-Host "$userName Exists"
}
