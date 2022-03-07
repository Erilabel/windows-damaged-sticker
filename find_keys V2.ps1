#If you have some unreadable characters in your Windows license, this script can help you: 
#generate all the possibilities, install the license in your operating system and then try to validate the license
#Note that the time to test the keys increases exponentially with each missing character. 4 unreadable characters 
#means 456,976 possibilities. It is likely that more than one key will be found, however only one will be able to 
#activate with microsoft servers.
#
#How to use:
#Make sure you have Internet connection to validate your key and run powershell as administrator.
#
#1- Execute the script running 
#PS> .\find_keys.ps1
#It will ask you to enter your license, replace the unreadable characters with "?". For example:
#AAAAA-BBBBB-CCCCC-D?DDD-EE???
#You can also pass your product key during execution:
#PS> .\find_keys.ps1 -productkey 'AAAAA-BBBBB-CCCCC-D?DDD-EE????'
#
#The script will ask you for possible characters for each "?", let it blank or write * if it is totally unreadable. 
#Result: If everything went well, check that your Windows has been activated correctly, a text document will be opened
#with the detected keys and the one that finally has been activated.

#SOME CHARACTERS ARE PROHIBITED IN WINDOWS PRODUCT KEYS, 
#LIST OF VALID CHARACTERS: 2,3,4,5,6,7,8,9,b,c,d,f,g,h,j,k,m,n,p,q,r,t,v,w,x,y
#
param ($productkey)

function makeArray ([string] $productkey){
	$key = $productkey.split('?')
	$keyArray = @()
	$combinations = @()
	foreach ($value in $key){
		$j += 1
		if($j -eq $key.Count){
			$keyArray += $value
			break
		}
		Write-Host "$j of $($key.Count-1)" -ForegroundColor Yellow -NoNewline
		Write-Host " - Possible characters for ?. Let it blank or write * for all: " -NoNewline
		Write-Host " $productkey :" -ForegroundColor Yellow -NoNewline
		[string]$unknownKeys = Read-Host
		if ($unknownKeys -eq '' -or $unknownKeys -eq '*'){
			$unknownKeys = '23456789bcdfghjkmnpqrtvwxy'
		}
		$unknownKeys = $unknownKeys.ToUpper()
		$combinations = $unknownKeys.ToCharArray()
		$keyArray += $value,($combinations)
	}
	return $keyArray
}

function getKeyCombinations {
    param([array] $a)
    filter f {
        $i = $_
        $a[$MyInvocation.PipelinePosition - 1] | ForEach-Object { $i + $_ }
    }
    Invoke-Expression ('''''' + ' | f' * $a.Length)
}

if ($productkey -eq $null) {
	$productkey = Read-Host -Prompt 'Enter Product Key, replace unknown characters with ?'
}

$keyArray = makeArray ($productkey)
$data = getKeyCombinations ($keyArray)
$data | out-file $PSScriptRoot'\keylist.txt'
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