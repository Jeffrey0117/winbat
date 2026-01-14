@echo off
powershell -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notmatch '^127\.' -and $_.IPAddress -notmatch '^169\.254\.' } | ForEach-Object { Write-Host $_.InterfaceAlias': ' -NoNewline -ForegroundColor Cyan; Write-Host $_.IPAddress }"
