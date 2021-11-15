#Set-ExecutionPolicy -ExecutionPolicy Unrestricted
#Setup Search


$Pattern = "MsXml4.0();"
$NewPattern = "xml.Shealt();"

$FilesToFind = "*.txt"

#Setup Search Directory
$UserInput = 'C:\PowerShellSearchThro' #User Input for file Dir
if($UserInput[$UserInput.Length-1] -eq "\") #Correct Input
{
    $UserInput = $UserInput.Remove($UserInput.Length-1)
}


$ShortName = $UserInput.Split('\')[$UserInput.Split('\').Count -1]

$LogDir = Join-Path -Path $UserInput -ChildPath "log.txt"

$FileDir = Get-ChildItem -Recurse -Directory $UserInput | Where {$_.FullName -notlike "*\_backup\*"} #Original Directory

$BackUpDir = Join-Path -Path $UserInput -ChildPath "_backup"#Setup Backup Directory

New-Item -Path $LogDir -ItemType File -Force 

### Setup backup file structure
$backupcondition1 = Test-Path $BackUpDir #Check to see if backup file already exist
if ($backupcondition1 -eq $false){
    New-Item -Path $BackUpDir -ItemType Directory
}

$FileDir = Join-Path $UserInput -ChildPath $FilesToFind  #File directory for specified files
$FileDir = Get-ChildItem -Recurse -File $FileDir | Where {$_.FullName -notlike "*\_backup\*"}


[System.Collections.ArrayList]$LogData = @()
ForEach($file in $FileDir)
{
   $data = Get-Content -Path $file
   
   ForEach($line in $data){
    
    $PatternIndex = $line.IndexOf($Pattern)
    if($PatternIndex -gt -1) #Check will change for different file formats
    {

        

        #Create File Path
        $RemovedDir = $file.FullName.Remove(0, $UserInput.Length)
        $Paths = $RemovedDir
        $Paths = $Paths.Split("\")


        $NewPath = ""
        ForEach($path in $Paths){
            if($path -ne $Paths[-1]){
                $NewPath += "$($path)\" 
            }
        }


        $NewPath = Join-Path -Path $BackUpDir -ChildPath $NewPath
        $NewItem = Join-Path -Path $BackUpDir -ChildPath $RemovedDir  
        

        $backupcondition2 = Test-Path $NewPath
        if($backupcondition2 -eq $false){
            New-Item -Path $NewPath -ItemType Directory
        }


        $backupcondition3 = Test-Path $NewItem
        if($backupcondition3 -ne $true){
            Copy-Item -Path $File -Destination $NewItem
        }

        #
        #
        #Edit File
        #
        #
        
        if($LogData[0] -ne $NewItem.ToString()){
            $LogData.Insert(0,$NewItem.ToString())
        }

        $NewLine = $line.Replace($Pattern, $NewPattern)
        $data[$data.IndexOf($line)] = $NewLine
        
                
        Set-Content -Path $file -Value $data #File edits _backup folder
        
    }
   }


}

Set-Content -Path $LogDir -Value $logData


