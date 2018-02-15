# Sysprep

$cmd = 'C:\Windows\System32\Sysprep\Sysprep.exe'

if (Test-Path $cmd) 
{
    $args = '/generalize','/oobe','/quiet'
    Write-Host "Running Sysprep" $cmd $args        
    #& $cmd $args
    exit 0;
} else {
    Write-Host "Unabe to find sysprex exe " $cmd 
    exit -1;
}


