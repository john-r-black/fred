#Requires -RunAsAdministrator
<#
Opens the Windows Firewall for RustDesk Direct IP Access (TCP/UDP 21118)
and adds a custom inbound ICMPv4 echo-request rule for LAN/VPN pings.

Scope is locked to LAN + tunnel ranges:
  192.168.1.0/24  - church VLAN 1 (DPUMC Network)
  10.1.10.0/24    - church VLAN 2 (AV Production)
  192.168.0.0/24  - home VLAN 1 (reached via IPsec tunnel)

Run on any Windows machine that should accept direct-IP RustDesk sessions.
Current deployment: Pastor2023 (192.168.1.40), Worship PC (10.1.10.205),
Broadcast PC (10.1.10.101).

Idempotent: re-running removes and recreates the three rules by display name.

IMPORTANT: rules are scoped to Private + Domain profiles. If the machine's
active connection is classified as Public, the rules will not apply. The
script checks and warns. Fix with:
  Set-NetConnectionProfile -InterfaceIndex <idx> -NetworkCategory Private

We do NOT touch the built-in "File and Printer Sharing (Echo Request)"
rules because they are scoped to LocalSubnet by default and will not
match traffic arriving over the IPsec tunnel.
#>

$ErrorActionPreference = 'Stop'

$remoteScopes = @('192.168.1.0/24', '10.1.10.0/24', '192.168.0.0/24')
$profiles     = @('Private', 'Domain')

$rules = @(
    @{ Name = 'RustDesk Direct IP (TCP 21118)'; Protocol = 'TCP';    Port = 21118; IcmpType = $null },
    @{ Name = 'RustDesk Direct IP (UDP 21118)'; Protocol = 'UDP';    Port = 21118; IcmpType = $null },
    @{ Name = 'ICMPv4 Echo LAN+VPN';            Protocol = 'ICMPv4'; Port = $null; IcmpType = 8 }
)

foreach ($r in $rules) {
    if (Get-NetFirewallRule -DisplayName $r.Name -ErrorAction SilentlyContinue) {
        Remove-NetFirewallRule -DisplayName $r.Name
        Write-Host "Removed existing rule: $($r.Name)"
    }
    $params = @{
        DisplayName   = $r.Name
        Direction     = 'Inbound'
        Action        = 'Allow'
        Protocol      = $r.Protocol
        RemoteAddress = $remoteScopes
        Profile       = $profiles
    }
    if ($r.Port)     { $params.LocalPort = $r.Port }
    if ($r.IcmpType) { $params.IcmpType  = $r.IcmpType }
    New-NetFirewallRule @params | Out-Null
    $detail = if ($r.Port) { "$($r.Protocol) $($r.Port)" } else { "$($r.Protocol) type $($r.IcmpType)" }
    Write-Host "Created rule: $($r.Name) [$detail from $($remoteScopes -join ', ')]"
}

Write-Host ""
Write-Host "Active RustDesk / ICMP inbound rules:" -ForegroundColor Cyan
Get-NetFirewallRule -Direction Inbound -Enabled True |
    Where-Object { $_.DisplayName -like '*RustDesk*' -or $_.DisplayName -like '*ICMPv4 Echo LAN+VPN*' } |
    Select-Object DisplayName, Enabled, Profile, Action |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Network connection profile check:" -ForegroundColor Cyan
$profilesActive = Get-NetConnectionProfile
$profilesActive | Select-Object InterfaceAlias, InterfaceIndex, NetworkCategory | Format-Table -AutoSize
if ($profilesActive | Where-Object { $_.NetworkCategory -eq 'Public' }) {
    Write-Warning "One or more interfaces are classified as 'Public'. The rules above will NOT apply to those interfaces."
    Write-Warning "Fix: Set-NetConnectionProfile -InterfaceIndex <idx> -NetworkCategory Private"
}
