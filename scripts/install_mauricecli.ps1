Param(
  [string]$Version = "",
  [string]$BinDir = "",
  [string]$Channel = $(if ($env:MAURICECLI_UPDATE_CHANNEL) { $env:MAURICECLI_UPDATE_CHANNEL } else { "stable" }),
  [string]$Endpoint = $(if ($env:MAURICECLI_UPDATE_ENDPOINT) { $env:MAURICECLI_UPDATE_ENDPOINT } else { "https://get.agentmaurice.app/products/mauricecli/latest.json" }),
  [string]$PublicKey = $(if ($env:MAURICECLI_MINISIGN_PUBLIC_KEY) { $env:MAURICECLI_MINISIGN_PUBLIC_KEY } else { "RWT2dtVKMzMezZOuTS4bQoM1kEix9oTYEq5j5mIOYJaskfsvHC+qNBVp" })
)

$ErrorActionPreference = "Stop"
$bin = "maurice"
$legacyBin = "mauricecli"

function Get-OSArch {
  $os = "windows"
  $arch = $env:PROCESSOR_ARCHITECTURE
  switch ($arch.ToLower()) {
    "amd64" { $arch = "amd64" }
    "arm64" { $arch = "arm64" }
    default { throw "Unsupported arch: $arch" }
  }
  return @($os, $arch)
}

function ManifestUrl {
  if ($Endpoint.Contains("?")) {
    return "$Endpoint&channel=$Channel"
  }
  return "$Endpoint?channel=$Channel"
}

function Download($url, $dest) {
  Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

try {
  if ([string]::IsNullOrWhiteSpace($PublicKey)) {
    throw "MAURICECLI_MINISIGN_PUBLIC_KEY must be configured in this installer."
  }
  if ($null -eq (Get-Command minisign -ErrorAction SilentlyContinue)) {
    throw "minisign is required and must be in PATH."
  }

  $pair = Get-OSArch
  $os = $pair[0]
  $arch = $pair[1]
  $key = "$os/$arch"

  $manifestUrl = ManifestUrl
  Write-Host "Fetching manifest $manifestUrl"
  $manifest = Invoke-RestMethod -Method GET -Uri $manifestUrl
  if ([string]::IsNullOrWhiteSpace($manifest.version)) {
    throw "Manifest missing version."
  }
  if (![string]::IsNullOrWhiteSpace($Version) -and $Version -ne $manifest.version) {
    throw "Manifest latest is $($manifest.version), requested $Version."
  }

  $assetProperty = $manifest.assets.PSObject.Properties[$key]
  if ($null -eq $assetProperty) {
    throw "Manifest has no asset for $key."
  }
  $asset = $assetProperty.Value
  if ([string]::IsNullOrWhiteSpace($asset.download_url) -or
      [string]::IsNullOrWhiteSpace($asset.signature_url) -or
      [string]::IsNullOrWhiteSpace($asset.sha256) -or
      [string]::IsNullOrWhiteSpace($asset.binary_name)) {
    throw "Manifest asset for $key is incomplete."
  }

  $tmp = New-Item -ItemType Directory -Path ([System.IO.Path]::GetTempPath()) -Name ("mauricecli_" + [System.Guid]::NewGuid().ToString())
  try {
    $archivePath = Join-Path $tmp.FullName "package.zip"
    $signaturePath = "$archivePath.minisig"
    Write-Host "Downloading $($asset.download_url)"
    Download $asset.download_url $archivePath
    Download $asset.signature_url $signaturePath

    $hash = (Get-FileHash -Algorithm SHA256 $archivePath).Hash.ToLower()
    if ($hash -ne $asset.sha256.ToLower()) {
      throw "Checksum mismatch."
    }
    & minisign -Vm $archivePath -x $signaturePath -P $PublicKey | Out-Null
    if ($LASTEXITCODE -ne 0) {
      throw "Minisign verification failed."
    }

    $extract = Join-Path $tmp.FullName "extract"
    Expand-Archive -Path $archivePath -DestinationPath $extract -Force
    $srcExe = Get-ChildItem -Path $extract -Recurse -File -Filter $asset.binary_name | Select-Object -First 1
    if ($null -eq $srcExe) {
      throw "Binary '$($asset.binary_name)' not found in archive."
    }

    $versionOutput = & $srcExe.FullName --json version | Out-String
    $versionInfo = $versionOutput | ConvertFrom-Json
    if ($versionInfo.obfuscated -ne "true" -or $versionInfo.build_profile -ne "release") {
      throw "Downloaded binary is not an obfuscated release build."
    }

    if ([string]::IsNullOrWhiteSpace($BinDir)) {
      $BinDir = Join-Path $env:USERPROFILE ".local\bin"
    }
    if (!(Test-Path $BinDir)) {
      New-Item -ItemType Directory -Path $BinDir | Out-Null
    }

    $target = Join-Path $BinDir "$bin.exe"
    Copy-Item $srcExe.FullName $target -Force

    $legacy = Join-Path $BinDir "$legacyBin.exe"
    if (!(Test-Path $legacy)) {
      try {
        New-Item -ItemType SymbolicLink -Path $legacy -Target "$bin.exe" | Out-Null
      } catch {
        Copy-Item $target $legacy -Force
      }
    }

    Write-Host "Installed $bin $($manifest.version) to $target"
    Write-Host "Ensure $BinDir is in your PATH."
  }
  finally {
    Remove-Item -Recurse -Force $tmp.FullName -ErrorAction SilentlyContinue
  }
}
catch {
  Write-Error $_
  exit 1
}
