# Runbook に貼り付け
Param(
    [Parameter(mandatory=$true)] [string] $VMName,
    [Parameter(mandatory=$true)] [string] $RGName,
    [Parameter(mandatory=$true)] [string] $Region,
    [Parameter(mandatory=$true)] [string] $UpdateFileBlobSAS,
    [Parameter(mandatory=$true)] [string] $ScriptBlobSAS,
    [string] $TempFilePath = "C:\temp\",
    [string] $Restart = "false"
)


# Azure に接続
try {
    $automationConnectionName = "AzureRunAsConnection"
    $connection = Get-AutomationConnection -Name $automationConnectionName

    Write-Output "# Logging in to Azure..."

    $account = Add-AzAccount `
        -ServicePrincipal `
        -TenantId $connection.TenantId `
        -ApplicationId $connection.ApplicationId `
        -CertificateThumbprint $connection.CertificateThumbprint

    Write-Output "Done."
}
catch {
    if (!$connection) {
        throw "Connection $automationConnectionName not found."
    } else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

###################################
## 既存のカスタムスクリプトの削除 ##
###################################

$VMExtension = Get-AzVMExtension `
    -ResourceGroupName $RGName `
    -VMName $VMName | where ExtensionType -eq "CustomScriptExtension"

if($VMExtension -eq $null ){
    Write-Output "No Existing Custom Script."
}Else{
    Write-Output "Delete Exiting Custom Script."
    Remove-AzVMExtension -Name $VMExtension.Name -ResourceGroupName $VMExtension.ResourceGroupName -VMName $VMExtension.VMName -Force
}

##################
## 文字列の整理 ##
##################

#Script PowerShell （sample.ps1）を抽出
$Split_ScriptBlobSAS = $ScriptBlobSAS.Split("?")
$ScripName = split-path $Split_ScriptBlobSAS[0] -leaf

#更新ファイル（XXXX.msu）を取得
$Split_UpdateFileBlobSAS = $UpdateFileBlobSAS.Split("?")
$UpdateFileName = split-path $Split_UpdateFileBlobSAS[0] -leaf

#VM内に更新プログラムを保存する場所を指定
$TempFilePath = $TempFilePath + $UpdateFileName

#Run コマンド生成
$UpdateFileBlobSAS = "`""  + $UpdateFileBlobSAS + "`""
$TempFilePath = "`""  + $TempFilePath + "`""
$Restart = "`""  + $Restart + "`""
$Run = $ScripName + " " + $UpdateFileBlobSAS + " " + $TempFilePath + " " + $Restart

#実行コマンド
Set-AzVMCustomScriptExtension -ResourceGroupName $RGName `
    -VMName $VMName `
    -Location $Region `
    -FileUri $ScriptBlobSAS `
    -Run $Run `
    -Name DemoScriptExtension