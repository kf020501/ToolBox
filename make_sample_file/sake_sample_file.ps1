$FilePath = "C:\path\to\src_filepath"
$FileSize = 1GB
$RandomBytes = New-Object byte[] $FileSize
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($RandomBytes)
[System.IO.File]::WriteAllBytes($FilePath , $RandomBytes)
