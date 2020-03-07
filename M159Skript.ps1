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

$user = @()
$userGroup = @()
$userOu = @()
$username = @()
$organizationalunits = @{"O_Gertzenstein" = "O_Gertzenstein";"O_Deaktiviert" = "O_Deaktiviert";"O_Diverse" = "O_Diverse";"O_Lehrer" = "O_Lehrer";"O_Schueler" = "O_Schueler";"O_Oberstufe" = "O_Oberstufe";"O_Verwaltung" = "O_Verwaltung"}
$groups = @{"G_Deaktiviert" = "507";"G_Diverse" = "508";"GL_Gymnasium" = "505";"GL_Handelsmatura" = "506";"GL_Sekundarschule" = "504";"GS_Handelsmatura" = "510";"GS_Matura" = "511";"G_Verwaltung" = "509"}
#End Of Definition of all Variables

#Username generation
foreach($x in $tables){
  $vorname = get-sanitizedUTF8Input $x.vorname.ToLower()
  $nachname = get-sanitizedUTF8Input $x.nachname.ToLower()
  $username += $vorname +"."+ $nachname

}

#OrganizationUnit generation
foreach($x in $tables){
    if ($x.Beschreibung -match "Sekundar" -And !($x.Beschreibung -match "Lehrer")) {
    $userOu = "O_Schueler"
}
 else{
 $userOu = "empty"
 } 

}

# Object for a user with the necessary properties of this User
$userobject = new-object PSObject -Property @{
    username = $username;
    ou = $userOu;
    group = $userGroup;
       
    }


$user += $userobject
$user.ou