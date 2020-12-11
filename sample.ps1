Param(
    [string] $SAS_URI,
    [string] $OutPutFile,
    [string] $Reboot
)

Invoke-WebRequest -UseBasicParsing -Uri $SAS_URI -OutFile $OutPutFile

If( $Reboot -eq "true" ){
	wusa.exe $OutPutFile /quiet 
}Else{
	wusa.exe $OutPutFile /quiet /norestart
}
