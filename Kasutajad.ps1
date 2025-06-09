# CSV-faili asukoht
$csvFail = "C:\Users\Administrator\Desktop\kasutajad.csv"

# Domeeni DN ja "Kasutajad" OU DN
$domainDN = (Get-ADDomain).DistinguishedName
$kasutajadOU = "OU=Kasutajad,$domainDN"

# Funktsioon täpitähtede eemaldamiseks
function EemaldaTahed {
    param([string]$tekst)

    $tekst = $tekst -replace 'ä', 'a'
    $tekst = $tekst -replace 'Ä', 'A'
    $tekst = $tekst -replace 'ö', 'o'
    $tekst = $tekst -replace 'Ö', 'O'
    $tekst = $tekst -replace 'ü', 'u'
    $tekst = $tekst -replace 'Ü', 'U'
    $tekst = $tekst -replace 'õ', 'o'
    $tekst = $tekst -replace 'Õ', 'O'
    $tekst = $tekst -replace 'š', 's'
    $tekst = $tekst -replace 'Š', 'S'
    $tekst = $tekst -replace 'ž', 'z'
    $tekst = $tekst -replace 'Ž', 'Z'

    return $tekst
}

# Laeb CSV sisu
$kasutajad = Import-Csv -Path $csvFail -Delimiter ';'

foreach ($rida in $kasutajad) {
    # Lahuta ees- ja perenimi (toetab mitmiksõnalisi nimesid)
    $nimed = $rida.Nimi -split " "
    $eesnimi = $nimed[0]
    $perenimi = ($nimed[1..($nimed.Length - 1)] -join "").Trim()
    $kasutajanimi = EemaldaTahed(("$eesnimi.$perenimi").ToLower())

    # Osakonnast OU ja selle tee "Kasutajad" OU alla
    $ouNimi = ($rida.Osakond).Trim()
    $ouPath = "OU=$ouNimi,$kasutajadOU"

    # Kontroll, kas OU on olemas "Kasutajad" all
    $ouExists = Get-ADOrganizationalUnit -Filter "Name -eq '$ouNimi'" -SearchBase $kasutajadOU -ErrorAction SilentlyContinue

    if (-not $ouExists) {
        New-ADOrganizationalUnit -Name $ouNimi -Path $kasutajadOU
        Write-Host "Loodud OU: $ouNimi asukohas Kasutajad"
    }

    # Loob kasutaja, kui ei eksisteeri
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$kasutajanimi'" -ErrorAction SilentlyContinue)) {
        New-ADUser `
            -Name "$eesnimi $perenimi" `
            -GivenName $eesnimi `
            -Surname $perenimi `
            -SamAccountName $kasutajanimi `
            -UserPrincipalName "$kasutajanimi@$(Get-ADDomain).DNSRoot" `
            -AccountPassword (ConvertTo-SecureString "TurvalineEsmaneParool1!" -AsPlainText -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -Path $ouPath
        Write-Host "Loodud kasutaja: $kasutajanimi → $ouNimi"
    } else {
        Write-Host "Kasutaja juba olemas: $kasutajanimi"
    }
}
