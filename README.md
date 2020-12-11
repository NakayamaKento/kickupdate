Title：kickupdate

内容：
Azure VM に対して更新プログラムを実行する。


使い方：
1．事前にBlob Storage に更新プログラムをアップロードする。
2. sample.ps1 を Blob Storage にアップロードする。
3. Runbook.ps1 を Azure Automation に追加する。
4. 1. 2. の Blob ファイルの SAS を取得し、パラメータとしてAutomationに実行する。
