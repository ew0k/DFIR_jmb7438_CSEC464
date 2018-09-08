<#
    Collect forensics information
#>

Get-Date -Format "F"
Get-TimeZone

gwmi win32_operatingsystem

gwmi win32_processor | % name
gwmi win32_physicalmemoryarray | % maxcapacity
gwmi win32_diskdrive | % size

gwmi win32_computersystem

gwmi win32_useraccount

get-service | where {$_.StartType -eq 'Automatic'}

arp -a
getmac
ipconfig
get-nettcpconnection -state Listen
get-dnsclientcache
get-smbshare
Get-Printer

gwmi win32_product

Get-CimInstance -ClassName Win32_Process

Get-WindowsDriver -Online -All

Get-ChildItem -Recurse -Path C:\Users\