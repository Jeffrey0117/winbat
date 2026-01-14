$seen = @{}
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Sort-Object LocalPort |
    ForEach-Object {
        $key = "$($_.LocalPort)|$($_.OwningProcess)"
        if (-not $seen[$key]) {
            $seen[$key] = $true
            $proc = (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName
            if ($proc) {
                Write-Host ("{0,-6} " -f $_.LocalPort) -NoNewline -ForegroundColor Yellow
                Write-Host $proc
            }
        }
    }
