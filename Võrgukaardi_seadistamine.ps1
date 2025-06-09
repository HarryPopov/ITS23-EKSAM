# Seadistab võrguliidesele IP aadressi ning DefaultGateway.
New-NetIPAddress -InterfaceIndex 6 -IPAddress 10.0.90.2 -PrefixLength 24 -DefaultGateway 10.0.90.1
# Määrab peamise ja varu DNS aadressid.
Set-DnsClientServerAddress -InterfaceIndex 6 -ServerAddresses 127.0.0.1,10.0.90.3,10.0.90.12
# Nimetab arvuti ümber ning taaskäivitab muudatuste jõustumiseks
Rename-Computer -NewName DC1 -Restart