param(
 [ValidateSet('Package','Installed')][string]$Mode='Package',
 [string]$ModsDirectory,
 [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$LoaderModName='IoStoreLoaderMod'
)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$package=[IO.Path]::GetFullPath($PSScriptRoot)
function Hash([string]$Path){(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Child([string]$Root,[string]$Relative){
 if([IO.Path]::IsPathRooted($Relative) -or $Relative -match '(^|[/\\])\.\.([/\\]|$)'){throw 'Invalid relative package path'}
 $path=[IO.Path]::GetFullPath((Join-Path $Root $Relative))
 if(-not $path.StartsWith($Root.TrimEnd('\')+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Path outside requested directory'}
 $path
}
$lines=Get-Content -LiteralPath (Join-Path $package 'SHA256SUMS.txt')
$count=0
foreach($line in $lines){
 if(-not $line){continue}
 if($line -notmatch '^([0-9a-f]{64})  (.+)$'){throw 'Invalid checksum list'}
 $expected=$Matches[1];$relative=$Matches[2]
 $path=Child $package $relative
 if(-not(Test-Path -LiteralPath $path -PathType Leaf) -or (Hash $path) -ne $expected){throw "Package file differs or is missing: $relative"}
 $count++
}
if($count -lt 10){throw 'Incomplete checksum list'}
$manifest=Get-Content -LiteralPath (Join-Path $package 'release-manifest.json') -Raw|ConvertFrom-Json
Write-Output "PASS: $count package file hashes match."
if($Mode -eq 'Package'){return}
if($manifest.packageType -ne 'runtime'){throw 'Installed mode requires the runtime package'}
if(-not $ModsDirectory){throw 'Supply -ModsDirectory with the active UE4SS Mods directory'}
$mods=[IO.Path]::GetFullPath($ModsDirectory).TrimEnd('\')
if(-not(Test-Path -LiteralPath (Join-Path (Split-Path -Parent $mods) 'UE4SS.dll') -PathType Leaf)){throw 'UE4SS.dll was not found above the supplied Mods directory; confirm the active runtime'}
$loader=Child $mods $LoaderModName
$dll=Join-Path $loader 'dlls\main.dll'
if(-not(Test-Path -LiteralPath $dll -PathType Leaf) -or (Hash $dll) -ne $manifest.testedLoaderSha256){throw 'The tested AC8 Mod Loader 1.3.1 DLL is missing or differs; install the prerequisite separately'}
$checked=0
foreach($entry in $manifest.installedFiles.PSObject.Properties){
 $relative=$entry.Name
 if($relative.StartsWith('F22LDTPTrial/')){
  $target=Child $mods $relative
 }elseif($relative.StartsWith('TexturePayload/')){
  $target=Child $loader ('payloads/'+$relative.Substring('TexturePayload/'.Length))
 }else{throw 'Unexpected install mapping'}
 if(-not(Test-Path -LiteralPath $target -PathType Leaf) -or (Hash $target) -ne $entry.Value){throw "Installed file differs or is missing: $target"}
 $checked++
}
foreach($other in @('IoStoreLoaderMod','AC8OverrideLoader')){
 if($other -ne $LoaderModName -and (Test-Path -LiteralPath (Join-Path $mods "$other\dlls\main.dll"))){throw "Another loader folder is present: $other. Confirm that only one asset loader is active."}
}
$control=Join-Path $mods 'mods.txt'
if(Test-Path -LiteralPath $control){
 $text=Get-Content -LiteralPath $control -Raw
 foreach($name in @('F22LDTPTrial',$LoaderModName)){
  if($text -match ('(?im)^\s*'+[regex]::Escape($name)+'\s*:\s*0\s*(?:;.*)?$')){throw "Files match, but mods.txt explicitly disables $name. Enable it with your manager."}
 }
}
Write-Output "PASS: $checked installed file hashes and the tested loader match."
Write-Output 'This check is read-only. Launcher synchronization, offline launch configuration and live game compatibility still need your normal setup.'

