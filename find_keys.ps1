#Iván Prieto
#If you have some unreadable characters in your Windows license, this script can help you: 
#generate all the possibilities, install the license in your operating system and then try to validate the license
#Note that the time to test the keys increases exponentially with each missing character. 4 unreadable characters 
#means 456,976 possibilities. It is likely that more than one key will be found, however only one will be able to 
#activate with microsoft servers.
#
#How to use:
#Make sure you have Internet connection to validate your key and run powershell as administrator.
#
#1- Basic mode: Execute the script running: 
#PS> .\find_keys.ps1
#It will ask you to enter your license, replace the unreadable characters with "?". For example:
#AAAAA-BBBBB-CCCCC-D?DDD-EE???
#You can also pass your product key during execution:
#PS> .\find_keys.ps1 -key 'AAAAA-BBBBB-CCCCC-D?DDD-EE????'
#
#2- Advanced mode: Edit "find_keys.ps1" and enter your product key as an array, this way you can reduce the possible
#combinations if some of the characters are partially readable:
#PS> .\find_keys.ps1 -advanced true
#
#Result: If everything went well, check that your Windows has been activated correctly, a text document will be opened
#with the detected keys and the one that finally has been activated.

#SOME CHARACTERS ARE PROHIBITED IN PRODUCT KEYS, 
#LIST OF VALID CHARACTERS: 2,3,4,5,6,7,8,9,b,c,d,f,g,h,j,k,m,n,p,q,r,t,v,w,x,y
#

param ($advanced, $key)

$advancedKey = #EDIT THIS ARRAY IF YOU WANT TO EXECUTE WITH THE ADVANCED OPTION
'AAAAA-BBBBB-CCCCC-D',
('2','3','4','5','6','7','8', '9','B','C','D','F','G','H','J','K','M','N','P','Q','R','T','V','W','X','Y'),
('2','3','4','5','6','7','8', '9','B','C','D','F','G','H','J','K','M','N','P','Q','R','T','V','W','X','Y'),
'DD-EE',
('K','M','N','X','Y'),
('2','G'),
('K','M','N','P','Q','R','T','V','W','X','Y');


if ($advanced -ne "true") {
	if ($key -eq $null) {
		$key = Read-Host -Prompt 'Enter Product Key, replace unknown characters with ?'
	}
	$keyArray = @()
	$combinations = ('2','3','4','5','6','7','8', '9','B','C','D','F','G','H','J','K','M','N','P','Q','R','T','V','W','X','Y')

	$key = $key -split '(?=\?)'

	foreach($value in $key){
		if($value -like "``?*"){
			$keyArray += , $combinations
			if($value -ne "?"){
				$value = $value.replace("?","")
				$keyArray += ,  $value
			}
		}
		else {
			$keyArray += ,  $value
		}
	}

}
else {
	$keyArray = $advancedKey;
}


function getKeyCombinations {
    param([array] $a)
    filter f {
        $i = $_
        $a[$MyInvocation.PipelinePosition - 1] | ForEach-Object { $i + $_ }
    }
    Invoke-Expression ('''''' + ' | f' * $a.Length)
}

$data = getKeyCombinations ($keyArray)
$keyListPath = $PSScriptRoot + '\keylist.txt'
$data | out-file $PSScriptRoot'\keylist.txt'
$i=0
$arrayOfKeys = [IO.File]::ReadAllLines($PSScriptRoot + '\keylist.txt')
foreach($item in $arrayOfKeys){
	$consoleOutput = cscript C:\Windows\System32\slmgr.vbs -ipk $item 
	if (!($consoleOutput -like "*Error*")){
		$activationOutput = cscript C:\Windows\System32\slmgr.vbs -ato
		if (!($activationOutput -like "*Error*")){
			echo "$item - Installed, validation success"
			echo "$item - Installed, validation success" >>.\result.txt
			& 'notepad.exe' '.\result.txt'
			break;
		}
		else {
			echo "$item - Installed but cannot activate"
			echo "$item - Installed but cannot activate" >>.\result.txt
		}
	}

	$i++
	Write-Progress -activity "Testing product keys..." -Status "Tested: $i of $($arrayOfKeys.count)" -CurrentOperation $item
}
