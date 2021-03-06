﻿#Functions Beginning
function get-sanitizedUTF8Input {
    Param(
        [String]$inputString
    )
    $replaceTable = @{"ß" = "ss"; "à" = "a"; "á" = "a"; "â" = "a"; "ã" = "a"; "ä" = "a"; "å" = "a"; "æ" = "ae"; "ç" = "c"; "è" = "e"; "é" = "e"; "ê" = "e"; "ë" = "e"; "ì" = "i"; "í" = "i"; "î" = "i"; "ï" = "i"; "ð" = "d"; "ñ" = "n"; "ò" = "o"; "ó" = "o"; "ô" = "o"; "õ" = "o"; "ö" = "o"; "ø" = "o"; "ù" = "u"; "ú" = "u"; "û" = "u"; "ü" = "u"; "ý" = "y"; "þ" = "p"; "ÿ" = "y" }

    foreach ($key in $replaceTable.Keys) {
        $inputString = $inputString -Replace ($key, $replaceTable.$key)
    }
    $inputString = $inputString -replace '[^a-zA-Z0-9]', ''
    return $inputString
}
#Functions End

$list = Import-Csv -Path "J:\1_Bibliothek\School\Modul159\ADExportALL.csv" -Delimiter ";"
$userDAO = @()
$groups = @{"G_Deaktiviert" = "501"; "G_Diverse" = "500"; "GL_Gymnasium" = "507"; "GL_Handelsmatura" = "508"; "GL_Sekundarschule" = "506"; "GS_Sekundarschule" = "502"; "GS_Handelsmatura" = "505"; "GS_Matura" = "504"; "G_Verwaltung" = "509"; "GS_Oberstufe" = "503" }


foreach ($row in $list) {
    $vorname = get-sanitizedUTF8Input $row.Vorname.ToLower();
    $nachname = get-sanitizedUTF8Input $row.Nachname.ToLower();
    $ou = "DefaultOU"
    $group = "DefaultGroup"

    if (!($row.Beschreibung -match "Lehrer") -and !($row.Beschreibung -match "Verwaltung") -and !($row.Beschreibung -match "deaktiviert") -and !($row.Beschreibung -match "Leitung")) {
        $ou = "O_Schueler"
        if ($row.Beschreibung -match "Sekundar") {
            $group = $groups.GS_Sekundarschule
        }


        elseif ($row.Beschreibung -match "Handelsmatur") {
            $group = $groups.GS_Handelsmatura
        }

        elseif ($row.Beschreibung -match "Matur") {
            $group = $groups.GS_Matura
        }

        elseif ($row.Beschreibung -match "Oberstufe") {
            $group = $groups.GS_Oberstufe
        }


    }

    elseif ($row.Beschreibung -match "Lehrer") {
        $ou = "O_Lehrer"

        if ($row.Beschreibung -match "Sekundar") {
            $group = $groups.GL_Sekundarschule
        }
        elseif ($row.Beschreibung -match "Gym") {
            $group = $groups.GL_Gymnasium
        }
        elseif ($row.Beschreibung -match "Handel") {
            $group = $groups.GL_Handelsmatura
        }


    }

    elseif ($row.Beschreibung -match "Verwaltung") {
        $ou = "O_Verwaltung"
        $group = $groups.G_Verwaltung
        
    }
    elseif ($row.Beschreibung -match "Leitung") {
        $ou = "O_Verwaltung"
        $group = $groups.G_Verwaltung
        
    }

    elseif ($row.Beschreibung -match "deaktiviert") {
        $ou = "O_Deaktiviert"
        $group = $groups.G_Deaktiviert
    }


    $userDAO += new-object PSObject -Property @{
        vorname  = $vorname
        nachname = $nachname
        username = $vorname + "." + $nachname
        ou       = $ou;
        group    = $group;
           
    }
}

$uidvar = 1000

foreach ($ldifentry in $userDAO) {
    

    "dn: uid=" + $ldifentry.username + ",ou=" + $ldifentry.ou + ",ou=O_Gertzenstein" + ",dc=gertzenstein,dc=local"
    "changetype: add"
    "objectClass: inetOrgPerson"
    "objectClass: organizationalPerson"
    "objectClass: posixAccount"
    "objectClass: top"
    "loginShell: /bin/bash"
    "gidnumber: " + $ldifentry.group
    "cn: " + $ldifentry.vorname + " " + $ldifentry.nachname
    "gn: " + $ldifentry.vorname
    "sn: " + $ldifentry.nachname
    "uid: " + $ldifentry.username
    "homeDirectory: /home/users/" + $ldifentry.username
    "mail: " + $ldifentry.username + "@gertzenstein.local"
    "uidnumber: " + $uidvar++
    "userPassword: leer" 
    "`n"
}