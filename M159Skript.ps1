#Functions Beginning
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

#Definition of all Variables
$tables = Import-Csv -Path "J:\1_Bibliothek\School\Modul159\ADmini.csv" -Delimiter ";"


$uservorname = @()
$usernachname = @()
$userGroup = @()
$userOu = @()
$username = @()
#$organizationalunits = @{"O_Gertzenstein" = "O_Gertzenstein"; "O_Deaktiviert" = "O_Deaktiviert"; "O_Diverse" = "O_Diverse"; "O_Lehrer" = "O_Lehrer"; "O_Schueler" = "O_Schueler"; "O_Oberstufe" = "O_Oberstufe"; "O_Verwaltung" = "O_Verwaltung" }
$groups = @{"G_Deaktiviert" = "507"; "G_Diverse" = "508"; "GL_Gymnasium" = "505"; "GL_Handelsmatura" = "506"; "GL_Sekundarschule" = "504"; "GS_Sekundarschule" = "504"; "GS_Handelsmatura" = "510"; "GS_Matura" = "511"; "G_Verwaltung" = "509" }
#End Of Definition of all Variables

#Username generation
foreach ($x in $tables) {
    $vorname = get-sanitizedUTF8Input $x.vorname.ToLower()
    $nachname = get-sanitizedUTF8Input $x.nachname.ToLower()
    $username += $vorname + "." + $nachname
    $uservorname += $vorname
    $usernachname += $nachname

}

#OrganizationUnit and Group generation
foreach ($x in $tables) {
    if (!($x.Beschreibung -match "Lehrer") -and !($x.Beschreibung -match "Verwaltung") -and !($x.Beschreibung -match "deaktiviert")) {
        $userOu += "O_Schueler"
        if ($x.Beschreibung -match "Sekundar") {
            $userGroup += $groups.GS_Sekundarschule
        }

        elseif ($x.Beschreibung -match "Handelsmatur") {
            $userGroup += $groups.GS_Handelsmatura
        }

        elseif ($x.Beschreibung -match "Matur") {
            $userGroup += $groups.GS_Matura
        }

    }

    elseif ($x.Beschreibung -match "Lehrer") {
        $userOu += "O_Lehrer"

        if ($x.Beschreibung -match "Sekundar") {
            $userGroup += $groups.GL_Sekundarschule
        }
        elseif ($x.Beschreibung -match "Gym") {
            $userGroup += $groups.GL_Gymnasium
        }
        elseif ($x.Beschreibung -match "Handel") {
            $userGroup += $groups.GL_Handelsmatura
        }

    }

    elseif ($x.Beschreibung -match "Verwaltung") {
        $userOu += "O_Verwaltung"
        $userGroup += $groups.G_Verwaltung
        
    }
    elseif ($x.Beschreibung -match "deaktiviert") {
        $userOu += "O_Deaktiviert"
        $userGroup += $groups.G_Deaktiviert
    }
    else {
        $userOu = "empty"
    } 
}

# Object for a user with the necessary properties of this User
$userobject = new-object PSObject -Property @{
    vorname  = $uservorname;
    nachname = $usernachname;
    username = $username;
    ou       = $userOu;
    group    = $userGroup;
       
}

$i=0
$uidvar=1000
while ($i -lt $userobject.vorname.length){
<#   
   $userobject.vorname[$i]
   $userobject.nachname[$i]
   $userobject.username[$i]
   $userobject.ou[$i]
   $userobject.group[$i]
   #>


"dn: uid="+$userobject.username[$i]+",ou="+$userobject.ou[$i]+",dc=prekek,dc=com"
"changetype: add"
"objectClass: inetOrgPerson"
"objectClass: organizationalPerson"
"objectClass: posixAccount"
"objectClass: top"
"gidnumber: "+$userobject.group[$i]
"cn: "+$userobject.vorname[$i]+" "+$userobject.nachname[$i]
"sn: "+$userobject.nachname[$i]
"uid: "+$userobject.username[$i]
"mail: "+$userobject.username[$i]+"@prekek.com"
"uidnumber: "+$uidvar++
"userPassword: leer" 
"`n"

   $i++

}



<#
foreach ($x in $userobject.username ){
Write-Host "Benutzername: " $x

}

foreach ($x in $userobject.ou ){
Write-Host "Organisationseinheit: " $x

}
foreach ($x in $userobject.group ){
Write-Host "Gruppe: " $x

}
#>

