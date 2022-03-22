# windows-damaged-sticker
Script to find and activate Windows when the product key sticker has unreadable characters

If you have some unreadable characters in your Windows license, this script can help you:  generate all the possibilities, install the license in your operating system and then try to validate the license. Note that the time to test the keys increases exponentially with each missing character. 4 unreadable characters means 456,976 possibilities. It is likely that more than one key will be found, however only one will be able to  activate with microsoft servers.

#How to use:
Make sure you have Internet connection to validate your key and run powershell as administrator.
Execute the script running:

PS> .\find_keys V3.ps1

It will ask you to enter your license, replace the unreadable characters with "?". For example: AAAAA-BBBBB-CCCCC-D?DDD-EE???
You can also pass your product key during execution:

PS> .\find_keys V3.ps1 -productkey 'AAAAA-BBBBB-CCCCC-D?DDD-EE????'

The script will ask you for possible characters for each "?", let it blank or write * if it is totally unreadable. Result: If everything went well, check that your Windows has been activated correctly, a text document will be opened with the detected keys and the one that finally has been activated.

#SOME CHARACTERS ARE PROHIBITED IN WINDOWS PRODUCT KEYS, 
LIST OF VALID CHARACTERS: 2,3,4,5,6,7,8,9,b,c,d,f,g,h,j,k,m,n,p,q,r,t,v,w,x,y
