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

$tables = Import-Csv -Path "J:\1_Bibliothek\School\Modul159\ADmini.csv" -Delimiter ";"

$username = @()

foreach($x in $tables){
  $vorname = get-sanitizedUTF8Input $x.vorname
  $nachname = get-sanitizedUTF8Input $x.nachname
  $username += $vorname +"."+ $nachname
}

$username

#$username = $table[1].vorname +"."+ $table[1].nachname
#contains for more shit