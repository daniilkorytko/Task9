
$MyResourceGroup = "Task9.1"
$MyLOcation = "westeurope"
$StorageAccount="task9runbook"
#Select your subscription if you have more than one
#Select-AzureSubscription -SubscriptionName "My Subscription Name"
$dscName ='Workflow_Stop-AzureVM.ps1'

New-AzureRmResourceGroup -Name $MyResourceGroup -Location $MyLOcation

New-AzureRmStorageAccount -ResourceGroupName $MyResourceGroup -AccountName $StorageAccount -Location $MyLOcation -SkuName Standard_GRS 

Publish-AzureRmAutomationRunbook -AutomationAccountName "MyAccount" -Name "Runbk01" -ResourceGroupName "ResourceGroup01"


$TemplateParametersPS = 'https://raw.githubusercontent.com/daniilkorytko/Task7/master/Task7.1Parametr.json'
$ParametersFilePathPS = "$env:TEMP\Task7Parametr.json" 

$webContent1 = Invoke-WebRequest -Uri $TemplateParametersUriTask7
$webContent1.Content | Out-File $ParametersFilePathTask7



#create container
$storagecontainername = 'task9run'
$storagecontainer = New-AzureStorageContainer -Name $storagecontainername `
    -Context $(New-AzureStorageContext -StorageAccountName $StorageAccount `
        -StorageAccountKey $(Get-AzureRmStorageAccountKey -ResourceGroupName $MyResourceGroup -StorageAccountName $StorageAccount).Value[0])


#downoload script
Set-AzureStorageBlobContent -Container $storagecontainername `
    -File $ParametersFilePath1 `
    -Context $(New-AzureStorageContext -StorageAccountName $StorageAccount `
    -StorageAccountKey $(Get-AzureRmStorageAccountKey -ResourceGroupName $MyResourceGroup -StorageAccountName $StorageAccount).Value[0])


$key = ((Get-AzureRMStorageAccountKey -ResourceGroupName $MyResourceGroup -Name $StorageAccount) | where {$_.KeyName -Like 'key1'}).Value
$ctx = New-AzureStorageContext -StorageAccountName $StorageAccount -StorageAccountKey $key
$sasToken = New-AzureStorageBlobSASToken -Container $storagecontainername -Blob $dscName -Permission rwl `
-ExpiryTime ([DateTime]::Now.AddHours(1.0)) -FullUri -Context $ctx






#Create a GUID for the job
$JobGUID = [System.Guid]::NewGuid().toString()

#Set the parameter values for the template
$Params = @{
    accountName = "MyAccount" ;
    jobId = $JobGUID;
    credentialName = "DefaultAzureCredential";
    userName = "c99a9b40-1a53-439a-8cec-1944f0a05dc2"; 
    password = "3ZIq/GUC+22r/2Uk7axHA6JLL3BOawD5er/2iai/e+A=";

}

$TemplateURI = "C:\Users\Daniil_Korytko\Desktop\Azure\Task9.1.json"

New-AzureRmResourceGroupDeployment -TemplateParameterObject $Params -ResourceGroupName $MyResourceGroup -TemplateFile $TemplateURI -verbose

