# ==============================================================================================
#    NAME: VNK_Log_Analysis_v8.0.5.ps1
#  AUTHOR: Bekir Yalcin
#    DATE: 2020/10/10
# COMMENT: Auto log analysis 
# ==============================================================================================  

$ErrorActionPreference = "SilentlyContinue"
Clear

# Default values
# ==============================================================================================    
 
$SearchString1 = "Begin new transaction" 
$SearchString2 = "AEV: AEV_TICKTIME_RISE_PRLOOP" 
$SearchString3 = "AEV: AEV_TICKTIME_RISE_PROB1"
$SearchString4 = "AEV: AEV_TICKTIME_RISE_PROB2"
$SearchString5 = "AEV: AEV_TICKTIME_RISE_PSLOOP"
$SearchString6 = "AEV: AEV_TICKTIME_RISE_OB1"

$SearchString7  = "\[IOREPORT\]\[PRLOOP\]\["
$SearchString8  = "\[IOREPORT\]\[PROB1\]\["
$SearchString9  = "\[IOREPORT\]\[PROB2\]\["
$SearchString10 = "\[IOREPORT\]\[PSLOOP\]\["
$SearchString11 = "\[IOREPORT\]\[OB1\]\["

$SearchString22 = "ERR_MSG"
$SearchString28 = "ERR: ERR_SMDEBUG_PROBLEM"

$SearchString13 = "Manual Entry Triggered by"
$SearchString14 = "Manual Exit Triggered by"

$SearchString15 = "Logged In - TOLL_COLLECTOR"
$SearchString16 = "Teller logged out"
$SearchString33 = "Teller Disconnected"
$SearchString20 = "VPC Disconnected"

$SearchString17 = "Received TagUsedManually"
$SearchString18 = "Received Tag: EtcTag"

$SearchString29 = "event.tag.raw_arrive tag_id"
$SearchString32 = "Duplicate tag"

$SearchString26 = "Insufficient write power"

$SearchString30 = "UHF Disconnected"
$SearchString31 = "UHF Offline for"


$SearchString12 = "Vehicle went Back!"
$SearchString19 = "Runtime Error null"
$SearchString23 = "JMS Error"
$SearchString24 = "Cannot create directory"
$SearchString25 = "ERROR \[tr.com.vendeka.ftp.Main.FTPMain"
$SearchString27 = "An ALPR result file came but"
$SearchString21 = "ERROR \[tr.com.vendeka."

$SearchString34 = "VENDEKA TOLL COLLECTION SYSTEM"
$SearchString35 = "Git-Revision"
$SearchString36 = "VPC RESET COUNTER"
$SearchString53 = "VPC VERSION"

$SearchString37 = "CMD_GET_PROBS_ENABLE"
$SearchString38 = "CMD_PUT_PROBS_ENABLE"

$SearchString39 = "CMD_GET_DB_TIME_AND_SAMPLE_COUNT"
$SearchString40 = "CMD_PUT_DB_TIME_AND_SAMPLE_COUNT"

$SearchString41 = "CMD_GET_DB_SAMPLE_COUNT_RF"
$SearchString42 = "CMD_PUT_DB_SAMPLE_COUNT_RF"

$SearchString43 = "CMD_GET_IN5_RISE_SAMPLE_COUNT"
$SearchString44 = "CMD_PUT_IN5_RISE_SAMPLE_COUNT"

$SearchString45 = "CMD_GET_IN5_FALL_SAMPLE_COUNT"
$SearchString46 = "CMD_PUT_IN5_FALL_SAMPLE_COUNT"

$SearchString47 = "CMD_GET_IN6_RISE_SAMPLE_COUNT"
$SearchString48 = "CMD_PUT_IN6_RISE_SAMPLE_COUNT"

$SearchString49 = "CMD_GET_IN6_FALL_SAMPLE_COUNT"
$SearchString50 = "CMD_PUT_IN6_FALL_SAMPLE_COUNT"

$SearchString51 = "Checking Account Entry"
$SearchString52 = "Entry response"

$Plaza = ((100,''))
$Plaza += (,(102,'102-Skyway Main Toll Plaza A'))
$Plaza += (,(103,'103-Skyway Main Toll Plaza B'))
$Plaza += (,(105,'105-Runway'))
$Plaza += (,(108,'108-Dona Soledad South Barrier'))
$Plaza += (,(111,'111-Nichols Entry-SB'))
$Plaza += (,(112,'112-Nichols (A) North Exit-NB'))
$Plaza += (,(114,'114-Nichols (B) North Exit-NB'))
$Plaza += (,(117,'117-C5 Entry-SB'))
$Plaza += (,(118,'118-C5 North Exit-NB'))
$Plaza += (,(119,'119-Merville South Exit-SB'))
$Plaza += (,(120,'120-Bicutan South Entry-SB'))
$Plaza += (,(122,'122-Bicutan South Exit-SB'))
$Plaza += (,(124,'124-Bicutan North Entry-NB'))
$Plaza += (,(126,'126-Bicutan North Exit-NB'))
$Plaza += (,(128,'128-Sucat South Entry-SB'))
$Plaza += (,(130,'130-Sucat South Exit-SB'))
$Plaza += (,(131,'131-Dr A Santos Sucat Elevated'))
$Plaza += (,(132,'132-Sucat North Entry-NB'))
$Plaza += (,(134,'134-Sucat North Exit-NB'))
$Plaza += (,(135,'135-Bunye South Exit-SB'))
$Plaza += (,(136,'136-Alabang South Exit-SB'))
$Plaza += (,(137,'137-Alabang Elevated'))
$Plaza += (,(138,'138-Alabang North Entry-NB'))
$Plaza += (,(201,'201-Filinvest Nor/Sth Entry/Exit'))
$Plaza += (,(205,'205-Alabang North Exit-NB'))
$Plaza += (,(206,'206-Alabang South Entry-SB'))
$Plaza += (,(210,'210-Susana Heights Nor/Sth Ent/Ext'))
$Plaza += (,(215,'215-San Pedro South Entry/Exit-SB'))
$Plaza += (,(220,'220-Southwoods North Entry/Exit-NB'))
$Plaza += (,(221,'221-Southwoods South Entry/Exit-SB'))
$Plaza += (,(225,'225-Carmona Nor/Sth Entry/Exit'))
$Plaza += (,(230,'230-Mamplasan North Entry/Exit-NB'))
$Plaza += (,(231,'231-Mamplasan South Entry/Exit-SB'))
$Plaza += (,(235,'235-Santa Rosa North Entry/Exit-NB'))
$Plaza += (,(236,'236-Santa Rosa South Entry/Exit-SB'))
$Plaza += (,(240,'240-ABI-Greenfield North Ent/Ext-NB'))
$Plaza += (,(241,'241-ABI-Greenfield South Ent/Ext-SB'))
$Plaza += (,(245,'245-Cabuyao North Entry/Exit-NB'))
$Plaza += (,(246,'246-Cabuyao South Entry/Exit-SB'))
$Plaza += (,(250,'250-Silangan North Entry/Exit-NB'))
$Plaza += (,(251,'251-Silangan South Entry/Exit-SB'))
$Plaza += (,(255,'255-Calamba South Exit/North Entry'))
$Plaza += (,(260,'260-Ayala TR3'))
$Plaza += (,(321,'321-Sto Tomas Plaza'))
$Plaza += (,(322,'322-Tanauan SB Plaza-SB'))
$Plaza += (,(332,'332-Tanauan NB Plaza-NB'))
$Plaza += (,(323,'323-Malvar SB Plaza-SB'))
$Plaza += (,(333,'333-Malvar NB Plaza-NB'))
$Plaza += (,(324,'324-Sto Toribio SB Plaza -SB'))
$Plaza += (,(334,'334-Sto Toribio NB Plaza-NB'))
$Plaza += (,(325,'325-Lipa SB Plaza-SB'))
$Plaza += (,(335,'335-Lipa NB Plaza-NB'))
$Plaza += (,(326,'326-Ibaan SB Plaza-SB'))
$Plaza += (,(336,'336-Ibaan NB Plaza-NB'))
$Plaza += (,(337,'337-Batangas Plaza'))
$Plaza += (,(161,'161-NAIA Road A-Ramp9'))
$Plaza += (,(162,'162-NAIA Road B-Ramp10'))
$Plaza += (,(163,'163-NAIA Main A'))
$Plaza += (,(164,'164-NAIA Main B'))
$Plaza += (,(165,'165-NAIA Airport Road-Ramp4'))
$Plaza += (,(166,'166-Skyway Exit-Ramp17'))
$Plaza += (,(167,'167-Skyway Entry-Ramp1'))


$Log = "Truee"
$LineLengtgh = 40
$MaxSensorHang = 290
$LogFileName  = "Log.csv"
$LogFileNameSummary  = "LogSummary"

$LogDesc = " "

$AutoDateTime  = ( (Get-Date –f "yyyyMMdd_HHmmss").tostring() )                 
$SelectFiles   = $null
$SelectFolders = $null
$SelectMultiFilter = $null

# --------Sensor Limits------------
$LimitLevel1 = 100
$LimitLevel2 = 200
$LimitLevel3 = 900
$LimitLevel4 = 1750
$LimitLevel5 = 2750
$LimitLevel6 = 4000
$LimitLevel7 = 5000


# --------Percent Limits------------
$CarpanLimitLevel1 = 0.300
$CarpanLimitLevel2 = 0.100
$CarpanLimitLevel3 = 0.050
$CarpanLimitLevel4 = 0.020
$CarpanLimitLevel5 = 0.008
$CarpanLimitLevel6 = 0.004
$CarpanLimitLevel7 = 0.002
$CarpanLimitLevel8 = 0.001
$CarpanLimitLevel9 = 0.0005


# --------Percent Carpan Limits------------
$PercCarpanLimitLevel1 = 1.500
$PercCarpanLimitLevel2 = 1.200
$PercCarpanLimitLevel3 = 1.100
$PercCarpanLimitLevel4 = 1.070
$PercCarpanLimitLevel5 = 1.050
$PercCarpanLimitLevel6 = 1.030
$PercCarpanLimitLevel7 = 1.020
$PercCarpanLimitLevel8 = 1.010
$PercCarpanLimitLevel9 = 1.005


# Add-Content -Path D:\SID$AutoDateTime.csv -Value "$($sid2.value);$DomainShortName\$($user.sAMAccountName)"          
   

# Functions
# ==============================================================================================    

function Log_Basla
  {
   $T = Start-Transcript -Path $LogDosyaAdi -Append -Force -NoClobber
  }
 
######## 
  
function Log_Dur
  {
   $T = Stop-Transcript
  }

Function Get-FileName() 
  {   
     [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
     $OpenFileDialog = $null

     $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
     $OpenFileDialog.Multiselect = $true
     $OpenFileDialog.Title = "Select Log Files..."
     $OpenFileDialog.ShowHelp = $true
     $OpenFileDialog.filter = "Log Files(*.log;*.txt)|*.log;*.txt|All files (*.*)|*.*"
     $a = $OpenFileDialog.ShowDialog() | Out-Null

     Return $OpenFileDialog.FileNames
} 


Function Get-FileName1() 
  {   
     [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
     $OpenFileDialog = $null

     $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
     $OpenFileDialog.Multiselect = $false
     $OpenFileDialog.Title = "Select Multi Filter IP List File..."
     $OpenFileDialog.ShowHelp = $true
     $OpenFileDialog.filter = "Filter List File(*.txt)|*.txt|All files (*.*)|*.*"
     $a = $OpenFileDialog.ShowDialog() | Out-Null
	 
     Return $OpenFileDialog.FileNames
} 


Function Get-Folder()
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.rootfolder = "MyComputer"
	$foldername.SelectedPath = "D:\LaneDebugLogs"
	
    #$a = $foldername.ShowDialog() 


    if($foldername.ShowDialog() -eq "OK") { Return $foldername.SelectedPath }

    #    if($foldername.ShowDialog() -eq "OK") {$folder += $foldername.SelectedPath}
}


# Run
# ==============================================================================================    


$a = new-object -comobject wscript.shell
$intAnswer = $a.popup("(YES) for FILEs select and (NO) for FOLDER or LIST select.", `
0,"
Select File(s)",4)
If ($intAnswer -eq 6) { $SelectFiles = Get-FileName # -initialDirectory "c:\"

} else 	{ 

	$bb = new-object -comobject wscript.shell
	$intAnswer = $bb.popup("(YES) for LIST select and (NO) for FOLDER select.", `
	0,"
	Select File(s)",4)
	If ($intAnswer -eq 6) { Write-Host "Filter List File: " -F Cyan -NoNewline
							$SelectMultiFilter = Get-FileName1 # -initialDirectory "c:\"

							Write-Host $SelectMultiFilter -ForegroundColor Green
			 				
							Write-Host "Select Search Folder: " -ForegroundColor Cyan -NoNewline
							$SelectFolders = Get-Folder 
							
							Write-Host $SelectFolders[1] -ForegroundColor Green
							
							# File Filter
							# $FileNameFilter = "*20181008*"
							$userInput = $null
							$userInput = Read-Host "Any filename filter (For Exp: 20180715) "
							if ( $userInput -ne $null ) 
							{
							 #Write-Host "New filter:" $userInput
							 $FileNameFilter = "lanecontroller_debug*" + $userInput + "*"
							 $LogFileName = $LogFileName.Substring(0,$LogFileName.Length -4) + "_" + $userInput + ".csv"

							}
							else
							{
							 # Write-Host "Cancel filter"
							 $FileNameFilter = "*"
							}							
	
	
	} else 	{ 

		Write-Host "Select Files or Folder: " -ForegroundColor Cyan -NoNewline
		$SelectFolders = Get-Folder 
 
		Write-Host $SelectFolders[1] -ForegroundColor Green
		 
			# File Path Filter
			# $FileNamePathFilter = "172.25.21.50"
			""
			$userInput1 = $null
			$userInput1 = Read-Host "Any filename path filter (For Exp: 172.25.21.50) "
			if ( $userInput1 -ne $null ) 
			{
			 #Write-Host "New filter:" $userInput
			 $FileNamePathFilter = "*" + $userInput1 + "*"
			 $LogFileName = $LogFileName.Substring(0,$LogFileName.Length -4) + "_" + $userInput1 + ".csv"
			}
			else
			{
			 # Write-Host "Cancel filter"
			 $FileNamePathFilter = "*"
			}


			# File Filter
			# $FileNameFilter = "*20180826*"
			""
			$userInput = $null 
			$userInput = Read-Host "Any filename filter (For Exp: 20180826) "
			if ( $userInput -ne $null ) 
			{
			 #Write-Host "New filter:" $userInput
			 $FileNameFilter = "lanecontroller_debug*" + $userInput + "*"
			 $LogFileName = $LogFileName.Substring(0,$LogFileName.Length -4) + "_" + $userInput + ".csv"
			}
			else
			{
			 # Write-Host "Cancel filter"
			 $FileNameFilter = "*"
			}
		}
	}
	
## $LogFileNameSummary = $LogFileName + "_Summary.csv"
##$LogFileName += ".csv"


# Open Zip files
$shell = New-Object -ComObject shell.application
if ($SelectFolders[1] -ne $null)
    {     
        $aaa = Get-ChildItem -Path $SelectFolders[1] -Force -Filter "*.zip" -Recurse  | ? {$_.Name -like "$FileNameFilter" -and $_.PSParentPath -like "$FileNamePathFilter" -and !$_.PSIsContainer } 
        Foreach( $bbb in $aaa )
            { 	  
				$zipPackage = (new-object -com shell.application).NameSpace($bbb.FullName)
				$destinationFolder = (new-object -com shell.application).NameSpace($bbb.DirectoryName)
				$destinationFolder.CopyHere($zipPackage.Items(),16)			
            }
    }

if ($SelectMultiFilter -ne $null)
    {	
		$SelectMultiFilterName = $SelectMultiFilter.Split("\")[($SelectMultiFilter.Split("\")).count - 1]
		$SelectMultiFilter = Get-Content $SelectMultiFilter
		
		$LogFileName = $LogFileName.Substring(0,$LogFileName.Length -4)  + "_" + $SelectMultiFilterName + ".csv"
		Foreach( $Filterrr in $SelectMultiFilter )
		{ 	 
			if ( $Filterrr -ne "" ) 
			{	$FileNamePathFilter = "*" + $Filterrr + "*"
		
		        $ccc = Get-ChildItem -Path $SelectFolders[1] -Force -Filter "*.zip" -Recurse  | ? {$_.Name -like "$FileNameFilter" -and $_.PSParentPath -like "$FileNamePathFilter" -and !$_.PSIsContainer } 
		        Foreach( $bbb in $ccc )
		            { 	  
						$zipPackage = (new-object -com shell.application).NameSpace($bbb.FullName)
						$destinationFolder = (new-object -com shell.application).NameSpace($bbb.DirectoryName)
						$destinationFolder.CopyHere($zipPackage.Items(),16)			
		            }
					
				 ######$zipPackage = (new-object -com shell.application).NameSpace($zipfilename)
			}
		}
    }




if ($SelectFiles -ne $null -or $SelectFolders[1] -ne $null -or $SelectMultiFilter -ne $null)
    { 
	
	if ($SelectFiles -eq $null) {
	      if ($SelectFolders[1] -ne $null) 
	          { 
	            $SelectFiles = Get-ChildItem -Path $SelectFolders[1] -Force -Filter "*.log" -Recurse | ? {$_.Name -like "$FileNameFilter" -and $_.PSParentPath -like "$FileNamePathFilter"  -and !$_.PSIsContainer} 
	            $SelectFiles = $SelectFiles + (Get-ChildItem -Path $SelectFolders[1] -Force -Filter "*.txt" -Recurse   | ? {$_.Name -like "$FileNameFilter" -and $_.PSParentPath -like "$FileNamePathFilter"  -and !$_.PSIsContainer} )
	          }


	      if ($SelectMultiFilter -ne $null) 
	        { 	$SelectFiles = @()
				Foreach( $Filterrr in $SelectMultiFilter )
				{ 	 
					if ( $Filterrr -ne "" ) 
					{	
						$FileNamePathFilter = "*" + $Filterrr + "*"			
				        $SelectFiles +=  Get-ChildItem -Path $SelectFolders[1] -Force -Filter "*.log" -Recurse  | ? {$_.Name -like "$FileNameFilter" -and $_.PSParentPath -like "$FileNamePathFilter" -and !$_.PSIsContainer } 
					}
				}		  
	        }
		}
		
      ""

 if ($SelectMultiFilter -ne $null -or $SelectFolders[1] -ne $null) 
	{ $SelectFiles = $SelectFiles | foreach {$_.FullName} | get-unique | sort -unique
	  $SelectFiles	
	  Write-Host "Total:" ($SelectFiles).Count -ForegroundColor Cyan
	}
	
 ""
 $FileNumber = 0
 Foreach( $SelectFile in $SelectFiles )
        {   
			# Write-Host $SelectFile ":" $($FileNumber + 1)
			
		
			$FileNumber ++           
            Write-Host "File $($FileNumber): " -NoNewline -ForegroundColor Cyan
            Write-Host  $SelectFile -ForegroundColor Green
            Write-Host "       " $SelectFile.FullName -ForegroundColor Green

            $AutoDateTime2  = ( (Get-Date –f "yyyyMMdd_HHmmss").tostring() )                 

# --------------------------------------GEREKSIZ VERILERI FITRELE--------------------------------------------------------------
$RawValues = @()
$RawValues = select-string -pattern   $SearchString1,$SearchString2,$SearchString3,$SearchString4,$SearchString5,
                                      $SearchString6,$SearchString7,$SearchString8,$SearchString9,$SearchString10,
                                      $SearchString11,$SearchString12,$SearchString13,$SearchString14,$SearchString15,
                                      $SearchString16,$SearchString17,$SearchString18,$SearchString19,$SearchString20,
                                      $SearchString21,$SearchString22,$SearchString23,$SearchString24,$SearchString25,
                                      $SearchString26,$SearchString27,$SearchString28,$SearchString29,$SearchString32,
                                      $SearchString30,$SearchString31,$SearchString33,$SearchString34,$SearchString35,
                                      $SearchString36,$SearchString37,$SearchString38,$SearchString39,$SearchString40,
                                      $SearchString41,$SearchString42,$SearchString43,$SearchString44,$SearchString45,
                                      $SearchString46,$SearchString47,$SearchString48,$SearchString49,$SearchString50,
									  $SearchString51,$SearchString52,$SearchString53 -path $SelectFile -CaseSensitive     
#$RawValues.Count

# --------------------------------------Filter Only Teller Login----------------------------------------------------------------------------------     


#---------TELLER Login / Logout------------
	# --First Login or Logout?
	$First = $null
	$AddLine = $null
	$NextStatus = $null
	$Login = @()
	$Logout = @()
	$TellerDisconnected = @()
	$LoginLogout = @()
	$FilterValues = @()
	$LoginLogout = $RawValues | select-string -pattern $SearchString15,$SearchString16 -CaseSensitive
	$LoginLogoutBeginNew = $RawValues | select-string -pattern $SearchString1,$SearchString15,$SearchString16 -CaseSensitive
	$TotalLines = $RawValues.Count
	$LoginLogoutDif = 0
	$LogDesc = ""
	$UniqeID = ""
	$LaneIP = ""
	$ZoneID = 0
	$ZoneName = ""
	$PlazaID = 0
	$PlazaName = ""
	$LaneID = 0
	$PRLOOP_BeginN_Percent = 0.00
	$P1P2_Dif = 0
	$P1P2_Percent = 0
	$PSLOOP_BeginN_Percent = 0.00
	$OB1_BeginN_Percent = 0.00
	$Ob1_P1P2_Dif = 0	
	$Ob1_P1P2_Percent = 0
	$BeginNewCount = 0
	$PRLOOPCount = 0
	$PSLOOPCount = 0
	$PROB1Count = 0
	$PROB2Count = 0
	$OB1Count = 0
	$Logincount = 0
	$Logoutcount = 0
	$VPCVERSION = @()
	$LogfileDate = ""

	if ($LoginLogout.count -gt 0 ) { 
		
		$Login  = $LoginLogout | select-string -pattern $SearchString15 -CaseSensitive
		$Logincount = $Login.count
		$Logout = $LoginLogout | select-string -pattern $SearchString16 -CaseSensitive
		$Logoutcount = $Logout.count
		
		$LoginLogoutDif = [math]::abs($Logincount - $Logoutcount)
	
		if ($LoginLogoutDif -gt 1) { $FilterValues = $RawValues } else 
		{		
			if ($LoginLogoutBeginNew[0].ToString() -like  '*Logged In *' -and 
			    $LoginLogoutBeginNew[0].ToString() -notlike  '*Logged In - MAINTENANCE*' -and
			    $LoginLogoutBeginNew[0].ToString() -notlike  '*Begin New Transaction*'
				) {
				$First = "Login"
				$NextStatus = "StopRecord"
			} else {
			 	$First = "Logout"
				$NextStatus = "Record"
			}

			Foreach ($Value in $RawValues) {	
				if ($Value -like '*Teller logged out*' -or $Value -like '*Maintenance logged out*') { $NextStatus = "StopRecord" }		
				elseif ($Value -like '*Logged In *' -and $Value -notlike '*Logged In - MAINTENANCE*') { $NextStatus = "Record" }
				
				if ($NextStatus -eq "Record"){ $FilterValues += $Value }	
			}
			
		} else { $FilterValues = $RawValues }
	} else { $FilterValues = $RawValues }
	
$ProcessLines = $FilterValues.Count

#$FilterValues.Count

# --------------------------------------START----------------------------------------------------------------------------------     
       
$BeginNew 		= $FilterValues | select-string -pattern $SearchString1  -CaseSensitive
$BeginNewcount  = $BeginNew.count
$PRLOOP   		= $FilterValues | select-string -pattern $SearchString2  -CaseSensitive
$PRLOOPcount   	= $PRLOOP.count
$PROB1    		= $FilterValues | select-string -pattern $SearchString3  -CaseSensitive
$PROB1count    	= $PROB1.count
$PROB2    		= $FilterValues | select-string -pattern $SearchString4  -CaseSensitive
$PROB2count    	= $PROB2.count
$PSLOOP   		= $FilterValues | select-string -pattern $SearchString5  -CaseSensitive  
$PSLOOPcount   	= $PSLOOP.count
$OB1      		= $FilterValues | select-string -pattern $SearchString6  -CaseSensitive
$OB1count      	= $OB1.count


# ------ ManualEntry---------
$ManualEntry = $FilterValues | select-string -pattern $SearchString13 -CaseSensitive

# --Check Sensör problem--------
$OrtalamaFind = @()
if ($PROB1count -eq 0 -and $PROB2count -eq 0 ) { 
                                                    $OrtalamaFind += $PRLOOPcount 
                                                    $OrtalamaFind += $PSLOOPcount 
                                                    $OrtalamaFind += $OB1count                 
                                                      $OrtalamaFind = $OrtalamaFind  | Measure-Object -Maximum -Minimum -Sum
                                                 } 
                                            else {  $OrtalamaFind += $PRLOOPcount 
                                                    $OrtalamaFind += $PSLOOPcount 
                                                    $OrtalamaFind += $OB1count        
                                                    $OrtalamaFind += $PROB1count        
                                                    $OrtalamaFind += $PROB2count        
                                                      $OrtalamaFind = $OrtalamaFind  | Measure-Object -Maximum -Minimum -Sum
                                                 }

$Ortalama = [System.Math]::Round(($OrtalamaFind.Sum - ($OrtalamaFind.Minimum + $OrtalamaFind.Maximum)) / ($OrtalamaFind.Count - 2),0)

# -----------------------

# Begin new
if ($SearchString1.Length  -gt 0) { Write-Host " " $SearchString1.PadRight($LineLengtgh)   ":" $BeginNewcount }

# PRLOOP
if ($SearchString2.Length  -gt 0) { Write-Host " " $SearchString2.PadRight($LineLengtgh)   ": " -NoNewline #$PRLOOPcount 
								  }	
	# Auto problem finder PRLOOP
	if ( $BeginNewcount -gt $LimitLevel1 -and $BeginNewcount -le $LimitLevel2 -and ($PRLOOPcount - $BeginNewcount) -gt 0 ) {
		if ($BeginNewcount* $PercCarpanLimitLevel3 -le $PRLOOPcount) { 
			$PRLoop_BeginN_Percent = ($PRLOOPcount - $BeginNewcount) / $BeginNewcount
			$LogDesc += "PRLOOP: $($PRLOOPcount). "
			Write-Host $PRLOOPcount -ForegroundColor RED
		} else { Write-Host $PRLOOPcount -ForegroundColor Green }	
	} elseif ( $BeginNewcount -gt $LimitLevel2 -and $BeginNewcount -le $LimitLevel3 -and ($PRLOOPcount - $BeginNewcount) -gt 0 ) {
		if ($BeginNewcount* $PercCarpanLimitLevel4 -le $PRLOOPcount) { 
			$PRLoop_BeginN_Percent = ($PRLOOPcount - $BeginNewcount) / $BeginNewcount
			$LogDesc += "PRLOOP: $($PRLOOPcount). "
			Write-Host $PRLOOPcount -ForegroundColor RED 
		}  else { Write-Host $PRLOOPcount -ForegroundColor Green }	
	} elseif ( $BeginNewcount -gt $LimitLevel3 -and $BeginNewcount -le $LimitLevel4 -and ($PRLOOPcount - $BeginNewcount) -gt 0 ) {
		if ($BeginNewcount* $PercCarpanLimitLevel5 -le $PRLOOPcount) { 
			$PRLoop_BeginN_Percent = ($PRLOOPcount - $BeginNewcount) / $BeginNewcount
			$LogDesc += "PRLOOP: $($PRLOOPcount). "
			Write-Host $PRLOOPcount -ForegroundColor RED 
		}  else { Write-Host $PRLOOPcount -ForegroundColor Green }	
	} elseif ( $BeginNewcount -gt $LimitLevel4 -and $BeginNewcount -le $LimitLevel5 -and ($PRLOOPcount - $BeginNewcount) -gt 0 ) {
		if ($BeginNewcount* $PercCarpanLimitLevel6 -le $PRLOOPcount) { 
			$PRLoop_BeginN_Percent = ($PRLOOPcount - $BeginNewcount) / $BeginNewcount
			$LogDesc += "PRLOOP: $($PRLOOPcount). "
			Write-Host $PRLOOPcount -ForegroundColor RED 
		}  else { Write-Host $PRLOOPcount -ForegroundColor Green }		
	} elseif ( $BeginNewcount -gt $LimitLevel5 -and ($PRLOOPcount - $BeginNewcount) -gt 0 ) {
		if ($BeginNewcount * $PercCarpanLimitLevel7 -le $PRLOOPcount) { 
			$PRLoop_BeginN_Percent = ($PRLOOPcount - $BeginNewcount) / $BeginNewcount
			$LogDesc += "PRLOOP: $($PRLOOPcount). "
			Write-Host $PRLOOPcount -ForegroundColor RED 
		}  else { Write-Host $PRLOOPcount -ForegroundColor Green }		
	}  else { Write-Host $PRLOOPcount -ForegroundColor Green }
									


# PROB1 PROB2
$P1P2_Dif 				= [math]::abs($PROB1count - $PROB2count)
$P1P2_Percent 			= [System.Math]::Round([math]::abs($PROB1count - $PROB2count) / (($PROB1count + $PROB2count) / 2),3)

if ($PROB1count -gt 0 -and $PROB2count -gt 0 ) { 
    if ($SearchString3.Length  -gt 0) { Write-Host " " $SearchString3.PadRight($LineLengtgh)   ": " -NoNewline
									  }
        if ( $BeginNewcount -gt $LimitLevel1 ) {
			# Auto problem finder PROB1
			if ( $BeginNewcount * $PercCarpanLimitLevel3 - $ManualEntry.count -lt $PROB1Count ) { 
				 $LogDesc += "PROB1: $($PROB1count). "
				 Write-Host $PROB1count -ForegroundColor Red
			} elseif ( (($PROB1count + $PROB2count)/2) -gt $LimitLevel1 -and (($PROB1count + $PROB2count)/2) -le $LimitLevel2 -and $P1P2_Percent -gt $CarpanLimitLevel1 ) {
				if ($PROB1Count -gt $PROB2Count) {
				 $LogDesc += "PROB1: $($PROB1count). "	
				 Write-Host $PROB1count -ForegroundColor Red
				} else { Write-Host $PROB1count -ForegroundColor Green }
			} elseif ( (($PROB1count + $PROB2count)/2) -gt $LimitLevel2 -and (($PROB1count + $PROB2count)/2) -le $LimitLevel3 -and $P1P2_Percent -gt $CarpanLimitLevel2 ) {
				if ($PROB1Count -gt $PROB2Count) {
				 $LogDesc += "PROB1: $($PROB1count). "	
				 Write-Host $PROB1count -ForegroundColor Red
				} else { Write-Host $PROB1count -ForegroundColor Green }
			} elseif ( (($PROB1count + $PROB2count)/2) -gt $LimitLevel3 -and (($PROB1count + $PROB2count)/2) -le $LimitLevel4 -and $P1P2_Percent -gt $CarpanLimitLevel3 ) {
				if ($PROB1Count -gt $PROB2Count) {
				 $LogDesc += "PROB1: $($PROB1count). "	
				 Write-Host $PROB1count -ForegroundColor Red
				} else { Write-Host $PROB1count -ForegroundColor Green }
			} elseif ( (($PROB1count + $PROB2count)/2) -gt $LimitLevel4 -and (($PROB1count + $PROB2count)/2) -le $LimitLevel5 -and $P1P2_Percent -gt $CarpanLimitLevel4 ) {
				if ($PROB1Count -gt $PROB2Count) {
				 $LogDesc += "PROB1: $($PROB1count). "	
				 Write-Host $PROB1count -ForegroundColor Red
				} else { Write-Host $PROB1count -ForegroundColor Green }
			} elseif ( (($PROB1count + $PROB2count)/2) -gt $LimitLevel5 -and (($PROB1count + $PROB2count)/2) -le $LimitLevel6 -and $P1P2_Percent -gt $CarpanLimitLevel5 ) {
				if ($PROB1Count -gt $PROB2Count) {
				 $LogDesc += "PROB1: $($PROB1count). "	
				 Write-Host $PROB1count -ForegroundColor Red
				} else { Write-Host $PROB1count -ForegroundColor Green }
			} elseif ( (($PROB1count + $PROB2count)/2) -gt $LimitLevel6 -and $P1P2_Percent -gt $CarpanLimitLevel6 ) {
				if ($PROB1Count -gt $PROB2Count) {
				 $LogDesc += "PROB1: $($PROB1count). "	
				 Write-Host $PROB1count -ForegroundColor Red
				} else { Write-Host $PROB1count -ForegroundColor Green }
			} else { Write-Host $PROB1count -ForegroundColor Green }			
		} else { Write-Host $PROB1count -ForegroundColor Green }				
	}


if ($PROB2count -gt 0 -and $PROB1count -gt 0 ) { 
    if ($SearchString4.Length  -gt 0) { Write-Host " " $SearchString4.PadRight($LineLengtgh)   ": " -NoNewline }
        if ( $BeginNewcount -gt $LimitLevel1 ) {
			# Auto problem finder PROB2
			if ( $BeginNewcount * $PercCarpanLimitLevel3 - $ManualEntry.count -lt $PROB2Count ) { 
				 $LogDesc += "PROB2: $($PROB2count). "
				 Write-Host $PROB2count -ForegroundColor Red
			} elseif ( (($PROB2count + $PROB1count)/2) -gt $LimitLevel1 -and (($PROB2count + $PROB1count)/2) -le $LimitLevel2 -and $P1P2_Percent -gt $CarpanLimitLevel1 ) {
				if ($PROB2Count -gt $PROB1Count) {
				 $LogDesc += "PROB2: $($PROB2count). "	
				 Write-Host $PROB2count -ForegroundColor Red
				} else { Write-Host $PROB2count -ForegroundColor Green }
			} elseif ( (($PROB2count + $PROB1count)/2) -gt $LimitLevel2 -and (($PROB2count + $PROB1count)/2) -le $LimitLevel3 -and $P1P2_Percent -gt $CarpanLimitLevel2 ) {
				if ($PROB2Count -gt $PROB1Count) {
				 $LogDesc += "PROB2: $($PROB2count). "	
				 Write-Host $PROB2count -ForegroundColor Red
				} else { Write-Host $PROB2count -ForegroundColor Green }
			} elseif ( (($PROB2count + $PROB1count)/2) -gt $LimitLevel3 -and (($PROB2count + $PROB1count)/2) -le $LimitLevel4 -and $P1P2_Percent -gt $CarpanLimitLevel3 ) {
				if ($PROB2Count -gt $PROB1Count) {
				 $LogDesc += "PROB2: $($PROB2count). "	
				 Write-Host $PROB2count -ForegroundColor Red
				} else { Write-Host $PROB2count -ForegroundColor Green }
			} elseif ( (($PROB2count + $PROB1count)/2) -gt $LimitLevel4 -and (($PROB2count + $PROB1count)/2) -le $LimitLevel5 -and $P1P2_Percent -gt $CarpanLimitLevel4 ) {
				if ($PROB2Count -gt $PROB1Count) {
				 $LogDesc += "PROB2: $($PROB2count). "	
				 Write-Host $PROB2count -ForegroundColor Red
				} else { Write-Host $PROB2count -ForegroundColor Green }
			} elseif ( (($PROB2count + $PROB1count)/2) -gt $LimitLevel5 -and (($PROB2count + $PROB1count)/2) -le $LimitLevel6 -and $P1P2_Percent -gt $CarpanLimitLevel5 ) {
				if ($PROB2Count -gt $PROB1Count) {
				 $LogDesc += "PROB2: $($PROB2count). "	
				 Write-Host $PROB2count -ForegroundColor Red
				} else { Write-Host $PROB2count -ForegroundColor Green }
			} elseif ( (($PROB2count + $PROB1count)/2) -gt $LimitLevel6 -and $P1P2_Percent -gt $CarpanLimitLevel6 ) {
				if ($PROB2Count -gt $PROB1Count) {
				 $LogDesc += "PROB2: $($PROB2count). "	
				 Write-Host $PROB2count -ForegroundColor Red
				} else { Write-Host $PROB2count -ForegroundColor Green }
			} else { Write-Host $PROB2count -ForegroundColor Green }
		} else { Write-Host $PROB2count -ForegroundColor Green }
	}
	
if ($P1P2_Dif  -gt 1) { Write-Host "    P1P2 Differance".PadRight($LineLengtgh) "  :  " $P1P2_Dif  -ForegroundColor Yellow }
if ($P1P2_Dif  -gt 1 -and $P1P2_Percent -gt 0) { Write-Host "    P1P2 Percent".PadRight($LineLengtgh) "  :   $($P1P2_Percent*100)%" -ForegroundColor Yellow }
	


# PSLOOP
if ($SearchString5.Length  -gt 0) { Write-Host " " $SearchString5.PadRight($LineLengtgh)   ": " -NoNewline }
	# Auto problem finder PSLOOP
	if ( $BeginNewcount -gt $LimitLevel1 -and $BeginNewcount -le $LimitLevel2 ) {
		if ( $BeginNewcount * $PercCarpanLimitLevel3 -le ($BeginNewcount + [math]::abs($BeginNewcount - $PSLOOPcount))) { 
			$PSLOOP_BeginN_Percent = [math]::abs($PSLOOPcount - $BeginNewcount) / $BeginNewcount
			$LogDesc += "PSLOOP: $($PSLOOPcount). "
			Write-Host $PSLOOPcount  -ForegroundColor RED 
		} else { Write-Host $PSLOOPcount -ForegroundColor Green }
	} elseif ( $BeginNewcount -gt $LimitLevel2 -and $BeginNewcount -le $LimitLevel3 ) {
		if ($BeginNewcount * $PercCarpanLimitLevel4 -le ($BeginNewcount + [math]::abs($BeginNewcount - $PSLOOPcount))) { 
			$PSLOOP_BeginN_Percent = [math]::abs($PSLOOPcount - $BeginNewcount) / $BeginNewcount
			$LogDesc += "PSLOOP: $($PSLOOPcount). "
			Write-Host $PSLOOPcount  -ForegroundColor RED 
		} else { Write-Host $PSLOOPcount -ForegroundColor Green }	
	} elseif ( $BeginNewcount -gt $LimitLevel3 -and $BeginNewcount -le $LimitLevel4 ) {
		if ($BeginNewcount * $PercCarpanLimitLevel5 -le ($BeginNewcount + [math]::abs($BeginNewcount - $PSLOOPcount))) { 
			$PSLOOP_BeginN_Percent = [math]::abs($PSLOOPcount - $BeginNewcount) / $BeginNewcount
			$LogDesc += "PSLOOP: $($PSLOOPcount). "
			Write-Host $PSLOOPcount  -ForegroundColor RED 
		} else { Write-Host $PSLOOPcount -ForegroundColor Green }		
	} elseif ( $BeginNewcount -gt $LimitLevel4 -and $BeginNewcount -le $LimitLevel5 ) {
		if ($BeginNewcount * $PercCarpanLimitLevel6 -le ($BeginNewcount + [math]::abs($BeginNewcount - $PSLOOPcount))) { 
			$PSLOOP_BeginN_Percent = [math]::abs($PSLOOPcount - $BeginNewcount) / $BeginNewcount
			$LogDesc += "PSLOOP: $($PSLOOPcount). "
			Write-Host $PSLOOPcount  -ForegroundColor RED 
		} else { Write-Host $PSLOOPcount -ForegroundColor Green }			
	} elseif ( $BeginNewcount -gt $LimitLevel5 ) {
		if ($BeginNewcount * $PercCarpanLimitLevel7 -le ($BeginNewcount + [math]::abs($BeginNewcount - $PSLOOPcount))) { 
			$PSLOOP_BeginN_Percent = [math]::abs($PSLOOPcount - $BeginNewcount) / $BeginNewcount
			$LogDesc += "PSLOOP: $($PSLOOPcount). "
			Write-Host $PSLOOPcount  -ForegroundColor RED 
		} else { Write-Host $PSLOOPcount -ForegroundColor Green }			
	} else { Write-Host $PSLOOPcount -ForegroundColor Green }

#OB1
if ($SearchString6.Length  -gt 0) { Write-Host " " $SearchString6.PadRight($LineLengtgh)   ": " -NoNewline }
	# Auto problem finder OB1
	if ( $BeginNewcount -gt $LimitLevel1 -and $BeginNewcount -le $LimitLevel2 ) {
		if ( $BeginNewcount * $PercCarpanLimitLevel3 -le ($BeginNewcount + [math]::abs($BeginNewcount - $OB1count))) { 
			$OB1_BeginN_Percent = [math]::abs($OB1count - $BeginNewcount) / $BeginNewcount
			$LogDesc += "OB1: $($OB1count). "
			Write-Host $OB1count  -ForegroundColor RED 
		} else { Write-Host $OB1count -ForegroundColor Green }	
	} elseif ( $BeginNewcount -gt $LimitLevel2 -and $BeginNewcount -le $LimitLevel3 ) {
		if ($BeginNewcount * $PercCarpanLimitLevel4 -le ($BeginNewcount + [math]::abs($BeginNewcount - $OB1count))) { 
			$OB1_BeginN_Percent = [math]::abs($OB1count - $BeginNewcount) / $BeginNewcount
			$LogDesc += "OB1: $($OB1count). "
			Write-Host $OB1count  -ForegroundColor RED
		} else { Write-Host $OB1count -ForegroundColor Green }	
	} elseif ( $BeginNewcount -gt $LimitLevel3 -and $BeginNewcount -le $LimitLevel4 ) {
		if ($BeginNewcount * $PercCarpanLimitLevel5 -le ($BeginNewcount + [math]::abs($BeginNewcount - $OB1count))) { 
			$OB1_BeginN_Percent = [math]::abs($OB1count - $BeginNewcount) / $BeginNewcount
			$LogDesc += "OB1: $($OB1count). "
			Write-Host $OB1count  -ForegroundColor RED
		} else { Write-Host $OB1count -ForegroundColor Green }		
	} elseif ( $BeginNewcount -gt $LimitLevel4 -and $BeginNewcount -le $LimitLevel5 ) {
		if ($BeginNewcount * $PercCarpanLimitLevel6 -le ($BeginNewcount + [math]::abs($BeginNewcount - $OB1count))) { 
			$OB1_BeginN_Percent = [math]::abs($OB1count - $BeginNewcount) / $BeginNewcount
			$LogDesc += "OB1: $($OB1count). "
			Write-Host $OB1count  -ForegroundColor RED 
		} else { Write-Host $OB1count -ForegroundColor Green }			
	} elseif ( $BeginNewcount -gt $LimitLevel5 ) {
		if ($BeginNewcount * $PercCarpanLimitLevel7 -le ($BeginNewcount + [math]::abs($BeginNewcount - $OB1count))) { 
			$OB1_BeginN_Percent = [math]::abs($OB1count - $BeginNewcount) / $BeginNewcount
			$LogDesc += "OB1: $($OB1count). "
			Write-Host $OB1count  -ForegroundColor RED
		} else { Write-Host $OB1count -ForegroundColor Green }			
	} else { Write-Host $OB1count -ForegroundColor Green }


	$Ob1_P1P2_Dif 			= [System.Math]::Round([math]::abs((($PROB1count + $PROB2count) / 2) - $OB1count),0)
	if ($Ob1_P1P2_Dif -gt 1 -and $PROB1Count -gt 0) { Write-Host "    Ob1 Avg_P1P2 Differance".PadRight($LineLengtgh) "  :  " $Ob1_P1P2_Dif -ForegroundColor Yellow }
	else {$Ob1_P1P2_Dif = 0}
	
	$Ob1_P1P2_Percent 		= [System.Math]::Round([math]::abs((($PROB1count + $PROB2count) / 2) - $OB1count) / $OB1count,3)
	if ($Ob1_P1P2_Dif -gt 1 -and $Ob1_P1P2_Percent -gt 0 -and $PROB1Count -gt 0) { Write-Host "    Ob1 Avg_P1P2 Percent".PadRight($LineLengtgh) "  :   $($Ob1_P1P2_Percent*100)%" -ForegroundColor Yellow }
	else {$Ob1_P1P2_Percent = 0}

""

# --------------------------------------GEREKSIZ VERILERI TEKRAR FITRELE--------------------------------------------------------------
$FilterValues = $FilterValues | select-string -pattern $SearchString7,$SearchString8,$SearchString9,$SearchString10,
                                      $SearchString11,$SearchString12,$SearchString13,$SearchString14,$SearchString15,
                                      $SearchString16,$SearchString17,$SearchString18,$SearchString19,$SearchString20,
                                      $SearchString21,$SearchString22,$SearchString23,$SearchString24,$SearchString25,
                                      $SearchString26,$SearchString27,$SearchString28,$SearchString29,$SearchString32,
                                      $SearchString30,$SearchString31,$SearchString33,$SearchString51,$SearchString52  -CaseSensitive  									  

# -------Sensör Takılma----------------

Write-Host "  Sensor hang (More than five minutes)".PadRight($LineLengtgh).ToString() "  : Times   `t hh:mm:ss" -ForegroundColor Cyan
# ---PRLOOP Hang Check--
$PRLOOPHangs = $FilterValues | select-string -pattern $SearchString7  -CaseSensitive
    $PRLOOPHangValue = @()
    $PRLOOPHangValueMax = 0
    Foreach ($PRLOOPHang in $PRLOOPHangs)     { $Deger = [int]$PRLOOPHang.ToString().Split("][")[7]
                                          if ( $Deger -gt $MaxSensorHang ) { $PRLOOPHangValue += $Deger }
                                        }
    $PRLOOPHangValueMax = ($PRLOOPHangValue | Measure-Object -Maximum).Maximum

    if ($SearchString7.Length -gt 0) { 
         Write-Host "   PRLOOP Hang".PadRight($LineLengtgh) "  :" ($FilterValues | select-string -pattern "\[IOREPORT\]\[PRLOOP\]\[300\]").count -NoNewline 
         if ($PRLOOPHangValueMax -gt 0) { Write-Host "  `t" (New-TimeSpan -Seconds $PRLOOPHangValueMax).ToString() -f Red } else {""} }


# ---PROB1 Hang Check--
$PROB1Hangs = $FilterValues | select-string -pattern $SearchString8  -CaseSensitive
    $PROB1HangValue = @()
    $PROB1HangValueMax = 0
    Foreach ($PROB1Hang in $PROB1Hangs)     { $Deger = [int]$PROB1Hang.ToString().Split("][")[7]
                                          if ( $Deger -gt $MaxSensorHang ) { $PROB1HangValue += $Deger }
                                        }
    $PROB1HangValueMax = ($PROB1HangValue | Measure-Object -Maximum).Maximum

    if ($SearchString8.Length -gt 0) { 
         Write-Host "   PROB1 Hang".PadRight($LineLengtgh) "  :" ($FilterValues | select-string -pattern "\[IOREPORT\]\[PROB1\]\[300\]").count -NoNewline 
         if ($PROB1HangValueMax -gt 0) { Write-Host "  `t" (New-TimeSpan -Seconds $PROB1HangValueMax).ToString() -f Red } else {""} }                                                                        


# ---PROB2 Hang Check--
$PROB2Hangs = $FilterValues | select-string -pattern $SearchString9  -CaseSensitive
    $PROB2HangValue = @()
    $PROB2HangValueMax = 0
    Foreach ($PROB2Hang in $PROB2Hangs)     { $Deger = [int]$PROB2Hang.ToString().Split("][")[7]
                                          if ( $Deger -gt $MaxSensorHang ) { $PROB2HangValue += $Deger }
                                        }
    $PROB2HangValueMax = ($PROB2HangValue | Measure-Object -Maximum).Maximum

    if ($SearchString9.Length -gt 0) { 
         Write-Host "   PROB2 Hang".PadRight($LineLengtgh) "  :" ($FilterValues | select-string -pattern "\[IOREPORT\]\[PROB2\]\[300\]").count -NoNewline 
         if ($PROB2HangValueMax -gt 0) { Write-Host "  `t" (New-TimeSpan -Seconds $PROB2HangValueMax).ToString() -f Red } else {""} }                                                                        


# ---PSLOOP Hang Check--
$PSLOOPHangs = $FilterValues | select-string -pattern $SearchString10  -CaseSensitive
    $PSLOOPHangValue = @()
    $PSLOOPHangValueMax = 0
    Foreach ($PSLOOPHang in $PSLOOPHangs)     { $Deger = [int]$PSLOOPHang.ToString().Split("][")[7]
                                          if ( $Deger -gt $MaxSensorHang ) { $PSLOOPHangValue += $Deger }
                                        }
    $PSLOOPHangValueMax = ($PSLOOPHangValue | Measure-Object -Maximum).Maximum

    if ($SearchString10.Length -gt 0) { 
         Write-Host "   PSLOOP Hang".PadRight($LineLengtgh) "  :" ($FilterValues | select-string -pattern "\[IOREPORT\]\[PSLOOP\]\[300\]").count -NoNewline 
         if ($PSLOOPHangValueMax -gt 0) { Write-Host "  `t" (New-TimeSpan -Seconds $PSLOOPHangValueMax).ToString() -f Red } else {""} }                                                                        


# ---OB1 Hang Check--
$OB1Hangs = $FilterValues | select-string -pattern $SearchString11  -CaseSensitive
    $OB1HangValue = @()
    $OB1HangValueMax = 0
    Foreach ($OB1Hang in $OB1Hangs) { $Deger = [int]$OB1Hang.ToString().Split("][")[7]
                                      if ( $Deger -gt $MaxSensorHang ) { $OB1HangValue += $Deger }
                                    }
    $OB1HangValueMax = ($OB1HangValue | Measure-Object -Maximum).Maximum

    if ($SearchString11.Length -gt 0) { 
         Write-Host "   OB1 Hang".PadRight($LineLengtgh) "  :" ($FilterValues | select-string -pattern "\[IOREPORT\]\[OB1\]\[300\]").count -NoNewline 
         if ($OB1HangValueMax -gt 0) { Write-Host "  `t" (New-TimeSpan -Seconds $OB1HangValueMax).ToString() -f Red } else {""} }                                                                        
""


# ------Add-Remove-------------

# $ManualEntry = $FilterValues | select-string -pattern $SearchString13 -CaseSensitive
# --Manual Entry--
 if ($SearchString13.Length -gt 0) { Write-Host " " $SearchString13.PadRight($LineLengtgh)  ": " -NoNewline 
                                     if ($ManualEntry.count -gt 10) { Write-Host $ManualEntry.count -f Red 
									 								  $LogDesc += "Manual Entry: $($ManualEntry.count). "
																	} else { Write-Host $ManualEntry.count } 
								   }

# --Manual Exit--
$ManualExit = $FilterValues | select-string -pattern $SearchString14 -CaseSensitive
 if ($SearchString14.Length -gt 0) { Write-Host " " $SearchString14.PadRight($LineLengtgh)  ": " -NoNewline 
                                     if ($ManualExit.count -gt 10) { Write-Host $ManualExit.count -f Red 
									 							     $LogDesc += "Manual Exit: $($ManualExit.count). "
																   } else { Write-Host $ManualExit.count } 
								   }
# --Teller disconnect--
$TellerDisconnected = $FilterValues | select-string -pattern $SearchString33 -CaseSensitive
 if ($SearchString33.Length -gt 0) { Write-Host " " $SearchString33.PadRight($LineLengtgh)  ": " -NoNewline 
                                     if ($TellerDisconnected.count -gt 0) { Write-Host $TellerDisconnected.count -f Red 
									 							     $LogDesc += "TellerDisconnected: $($TellerDisconnected.count). "
																   } else { Write-Host $TellerDisconnected.count } 
								   }								   


# --VPC disconnect--
    $VPCdisconnect = $VPCdisconnect = $RawValues | select-string -pattern $SearchString20 -CaseSensitive                                         
    if ($SearchString20.Length -gt 0) { Write-Host " " (($SearchString20.Replace('\','')).PadRight($LineLengtgh)).ToString() ": " -NoNewline }
    if ($VPCdisconnect.Count -gt 0) { Write-Host $VPCdisconnect.Count -f R 
								      $LogDesc = "VPC Disconnected: $($VPCdisconnect.Count). " + $LogDesc 
									} else { Write-Host $VPCdisconnect.Count } 


""

#---------TELLER Login / Logout------------
if ($SearchString15.Length -gt 0) { Write-Host " " $SearchString15.PadRight($LineLengtgh)  ":" $Logincount }
if ($SearchString16.Length -gt 0) { Write-Host " " $SearchString16.PadRight($LineLengtgh)  ":" $Logoutcount -NoNewline}

if ( $LoginLogoutDif -gt 1) { Write-Host "`t`t Warring: UI wrong ended $($LoginLogoutDif - 1) times!!!" -f red 
													   $LogDesc += "UI wrong ended: $($LoginLogoutDif - 1) times. "
													 } else {""}
""

#------Read-Rate---------------
$M_RFID = @()
$M_RFID = $FilterValues | select-string -pattern $SearchString17 -CaseSensitive 
$M_RFID = $M_RFID | select-string -pattern 'INACTIVE' -notMatch 
	if ($SearchString17.Length -gt 0) { Write-Host " " $SearchString17.PadRight($LineLengtgh)  ":" $M_RFID.count }
$RFID = @()
$RFID = $FilterValues | select-string -pattern $SearchString18 -CaseSensitive
	if ($SearchString18.Length -gt 0) { Write-Host " " $SearchString18.PadRight($LineLengtgh)  ":" $RFID.count -NoNewline }

$ReadRate =  0 #@() 
$ReadRate =  [System.Math]::Round(($RFID.count / ($RFID.count + $M_RFID.count)) * 100, 2)
	if ($ReadRate -lt 90 -and $ReadRate -gt 0 -and $RFID.count -gt 0 ) { Write-Host " `t ReadRate: $ReadRate%" -f Red 
  						   $LogDesc += "Low ReadRate $($ReadRate)%. "
  	} elseif ($ReadRate -lt 97 -and $ReadRate -gt 89.99 -and $RFID.count -gt 0 ) { Write-Host " `t ReadRate: $ReadRate%" -f Yellow 
	} elseif ($ReadRate -gt 96.99 -and $RFID.count -gt 0 ) { Write-Host " `t ReadRate: $ReadRate%" -f Green }
	
	if ($ReadRate -eq 0) { $ReadRate = "" }
""


# -- Raw okuma: UHFEventClient                    ] [ru]--
	$UHFEventClient = @()
    $UHFEventClient = $FilterValues | select-string -pattern $SearchString29 -CaseSensitive
    

    if ($SearchString29.Length -gt 0) { Write-Host " " (("Raw okunan TAG sayısı".Replace('\','')).PadRight($LineLengtgh)).ToString() ":" $UHFEventClient.Count }

# -- Duplicate TAG: Duplicate tag
    $DuplicateTAG = $FilterValues | select-string -pattern $SearchString32 -CaseSensitive    
    if ($SearchString32.Length -gt 0) { Write-Host " " (("Duplicate okunan TAG sayısı".Replace('\','')).PadRight($LineLengtgh)).ToString() ":" $DuplicateTAG.Count }

""


# --Insufficient write power--
    $Insufficientwritepower = $FilterValues | select-string -pattern $SearchString26 -CaseSensitive
    if ($SearchString26.Length -gt 0) { Write-Host " " (($SearchString26.Replace('\','')).PadRight($LineLengtgh)).ToString() ": " -NoNewline }
    if ($Insufficientwritepower.Count -gt 0) { Write-Host $Insufficientwritepower.Count -f Y 
											 } else { Write-Host $Insufficientwritepower.Count } 
""


# --UHF Disconnect--
    $UHFDisconnect = $FilterValues | select-string -pattern $SearchString30 -CaseSensitive
    if ($SearchString30.Length -gt 0) { Write-Host " " (($SearchString30.Replace('\','')).PadRight($LineLengtgh)).ToString() ": " -NoNewline }
    if ($UHFDisconnect.Count -gt 0) { Write-Host $UHFDisconnect.Count -f R 
									 # $LogDesc += "Reader disconnected: $($UHFDisconnect.Count). "
									} else { Write-Host $UHFDisconnect.Count } 

# --UHF offline--
    $UHFoffline = $FilterValues | select-string -pattern $SearchString31 -CaseSensitive
    if ($SearchString31.Length -gt 0) { Write-Host " " (($SearchString31.Replace('\','')).PadRight($LineLengtgh)).ToString() ": " -NoNewline }
    if ($UHFoffline.Count -gt 0) { Write-Host $UHFoffline.Count -f Red 
								   # $LogDesc += "Reader disconnected time: $($UHFoffline.Count). "								 
								 } else { Write-Host $UHFoffline.Count } 
""


# --Sensör delay hatası ERR_MSG--
    $ERR_MSG = $FilterValues | select-string -pattern $SearchString22 -CaseSensitive 
    if ($SearchString22.Length -gt 0) { Write-Host " " (('Sensor fall order problem - ERR_MSG'.Replace('\','')).PadRight($LineLengtgh)).ToString() ": " -NoNewline }
    if ($ERR_MSG.Count -gt 0 -and $ERR_MSG.Count -lt 10) { Write-Host $ERR_MSG.Count -f Yellow } 
    elseif ($ERR_MSG.Count -gt 10 ) { Write-Host $ERR_MSG.Count -f Red } else { Write-Host $ERR_MSG.Count }     

# --Sensör delay hatası ERR: ERR_SMDEBUG_PROBLEM--
    $ERR_SMDEBUG_PROBLEM = $FilterValues | select-string -pattern $SearchString28 -CaseSensitive 
    if ($SearchString28.Length -gt 0) { Write-Host " " (('SMDEBUG'.Replace('\','')).PadRight($LineLengtgh)).ToString() ": " -NoNewline }
    if ($ERR_SMDEBUG_PROBLEM.Count -gt 0 -and $ERR_SMDEBUG_PROBLEM.Count -lt 6) { Write-Host $ERR_SMDEBUG_PROBLEM.Count -f Y } 
    elseif ($ERR_SMDEBUG_PROBLEM.Count -gt 5 ) { Write-Host $ERR_SMDEBUG_PROBLEM.Count -f R 
											     $LogDesc += "SMDEBUG: $($ERR_SMDEBUG_PROBLEM.Count). "		
											   } else { Write-Host $ERR_SMDEBUG_PROBLEM.Count }     

# --Vehicle went Back!--
    $Vehiclewent = $FilterValues | select-string -pattern $SearchString12 -CaseSensitive
    if ($SearchString12.Length -gt 0) { Write-Host " " (($SearchString12.Replace('\','')).PadRight($LineLengtgh)).ToString() ": " -NoNewline }
    if ($Vehiclewent.Count -gt 5) { Write-Host $Vehiclewent.Count -f Red 
								    $LogDesc += "Vehicle went: $($Vehiclewent.Count). "	
								  } else { Write-Host $Vehiclewent.Count } 

""


# --Core Start Count--
$CoreStartCount = @()
$CoreLastStartTime = ""
$CoreStartCount = $RawValues | select-string -pattern $SearchString34 -CaseSensitive
 if ($SearchString34.Length -gt 0) { Write-Host " " "Core Start Count".PadRight($LineLengtgh)  ": " -NoNewline 
                                     if ($CoreStartCount.count -gt 0) 
										{ Write-Host $CoreStartCount.count " " -f Red  -NoNewline 
									 	  $LogDesc += "CoreStartCount: $($CoreStartCount.count). "
										} else { Write-Host $CoreStartCount.count " " -NoNewline } 
								   }								   

# --Core Last Start Time
$CoreLastStartTime = ""
 if ($CoreStartCount.count -gt 0) { $CoreLastStartTime =$CoreStartCount[$CoreStartCount.count-1].ToString().Split(":")[3] + ":" +
														$CoreStartCount[$CoreStartCount.count-1].ToString().Split(":")[4] + ":" +
														$CoreStartCount[$CoreStartCount.count-1].ToString().Split(":")[5].Substring(0,2)

								 	Write-Host "Last Start Time: " -NoNewline
									Write-Host $CoreLastStartTime -f cyan
 
								   } else {""}							   



# --Git-Revision--Core Version--
$GitRevision = @()
$GitRevision = $RawValues | select-string -pattern $SearchString35 -CaseSensitive
 if ($SearchString35.Length -gt 0) { Write-Host " " $SearchString35.PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($GitRevision.count -gt 0) 
									 	{ $GitRevision = ($GitRevision[$GitRevision.count-1].ToString().Split(":")[6]).Split(" ")[1]	
										  Write-Host $GitRevision -ForegroundColor Cyan
										} else {""} 
								   }								   								   						   
								   								   
	
					   
# --VPC VERSION--
$VPCVERSION = @()
$VPCVERSION = $RawValues | select-string -pattern $SearchString53 -CaseSensitive

 if ($SearchString53.Length -gt 0) { Write-Host " " "VPC Firmware Version".PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($VPCVERSION.count -gt 0) { $VPCVERSION = $VPCVERSION[$VPCVERSION.count-1].ToString().Split(":")[6].Substring(1,4)																	 
																	Write-Host $VPCVERSION -ForegroundColor Cyan
																  } else {""}
								   }						   
					   
					   
# --VPC RESET COUNTER--
$VPCRESETCOUNTER = @()
$VPCRESETCOUNTER = $RawValues | select-string -pattern $SearchString36 -CaseSensitive
 if ($SearchString36.Length -gt 0) { Write-Host " " $SearchString36.PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($VPCRESETCOUNTER.count -gt 0) { $VPCRESETCOUNTER = $VPCRESETCOUNTER[$VPCRESETCOUNTER.count-1].ToString().Split(":")[6].Substring(1,2)
									 									 #$VPCRESETCOUNTER = [Convert]::ToInt64($VPCRESETCOUNTER,16)																		 
									 							   	     Write-Host $VPCRESETCOUNTER -ForegroundColor Cyan
																   	   } else {""}
								   }								   								   


# --CMD_GET_PROBS_ENABLE--
$CMD_GET_PROBS_ENABLE = @()
$CMD_GET_PROBS_ENABLE = $RawValues | select-string -pattern $SearchString37,$SearchString38 -CaseSensitive
 if ($SearchString37.Length -gt 0) { Write-Host " " "VPC Mode".PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($CMD_GET_PROBS_ENABLE.count -gt 0) { $CMD_GET_PROBS_ENABLE = $CMD_GET_PROBS_ENABLE[$CMD_GET_PROBS_ENABLE.count-1].ToString().Split(":")[7].Substring(1,2)
									 									 	  $CMD_GET_PROBS_ENABLE = [Convert]::ToInt64($CMD_GET_PROBS_ENABLE,16)
									 							   	     	  if ($CMD_GET_PROBS_ENABLE -eq 1) {$CMD_GET_PROBS_ENABLE = "Dedicated Mode"}
																		 	  else {$CMD_GET_PROBS_ENABLE = "Mixed Mode"}
																			  Write-Host $CMD_GET_PROBS_ENABLE -ForegroundColor Cyan
																   	   		} else {""} 
								   }								   							   


# --CMD_GET_DB_TIME_AND_SAMPLE_COUNT--
$CMD_GET_DB_TIME_AND_SAMPLE_COUNT = @()
$Debounce = ""
$CMD_GET_DB_TIME_AND_SAMPLE_COUNT = $RawValues | select-string -pattern $SearchString39,$SearchString40 -CaseSensitive
 if ($SearchString39.Length -gt 0) { # Write-Host " " "Debounce".PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($CMD_GET_DB_TIME_AND_SAMPLE_COUNT.count -gt 0) { $CMD_GET_DB_TIME_AND_SAMPLE_COUNT = $CMD_GET_DB_TIME_AND_SAMPLE_COUNT[$CMD_GET_DB_TIME_AND_SAMPLE_COUNT.count-1].ToString().Split(":")[7].Substring(1,4)
									 									 	  $Debounce = [Convert]::ToInt64($CMD_GET_DB_TIME_AND_SAMPLE_COUNT.Substring(0,2) ,16).ToString() + "_" + [Convert]::ToInt64($CMD_GET_DB_TIME_AND_SAMPLE_COUNT.Substring(2,2) ,16).ToString()
									 							   	     	  #Write-Host $Debounce -ForegroundColor Cyan
																   	   		} else {#""
																					} 
								   }								   
# --CMD_GET_DB_SAMPLE_COUNT_RF--
$CMD_GET_DB_SAMPLE_COUNT_RF = @()
$Debounce2 = ""
$CMD_GET_DB_SAMPLE_COUNT_RF = $RawValues | select-string -pattern $SearchString41,$SearchString42 -CaseSensitive
 if ($SearchString41.Length -gt 0) { # Write-Host " " "DebounceLoops".PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($CMD_GET_DB_SAMPLE_COUNT_RF.count -gt 0) { $CMD_GET_DB_SAMPLE_COUNT_RF = $CMD_GET_DB_SAMPLE_COUNT_RF[$CMD_GET_DB_SAMPLE_COUNT_RF.count-1].ToString().Split(":")[7].Substring(1,4)
									 									 	  $Debounce2 = [Convert]::ToInt64($CMD_GET_DB_SAMPLE_COUNT_RF.Substring(0,2) ,16).ToString() + "_" + [Convert]::ToInt64($CMD_GET_DB_SAMPLE_COUNT_RF.Substring(2,2) ,16).ToString()
									 							   	     	  #Write-Host $Debounce2 -ForegroundColor Cyan
																   	   		} else {#""
																					}
								   }								   

if ($SearchString41.Length -gt 0 -or $SearchString39.Length -gt 0 ) { Write-Host " " "Debounce Loops".PadRight($LineLengtgh)  ": " -NoNewline
																	  Write-Host $Debounce"."$Debounce2 -ForegroundColor Cyan

																}

# --PROB1 RISE DELAY--
$PROB1RISEDELAY = @()
$PROB1RISEDELAY = $RawValues | select-string -pattern $SearchString43,$SearchString44 -CaseSensitive
 if ($SearchString43.Length -gt 0) { #Write-Host " " "PROB1 RISE DELAY".PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($PROB1RISEDELAY.count -gt 0) { $PROB1RISEDELAY = $PROB1RISEDELAY[$PROB1RISEDELAY.count-1].ToString().Split(":")[7].Substring(1,2)
									 									 $PROB1RISEDELAY = [Convert]::ToInt64($PROB1RISEDELAY,16)																		 
									 							   	     #Write-Host $PROB1RISEDELAY -ForegroundColor Cyan
																   	   } else {#""
																	   			}
								   }								   								   
# --PROB1 FALL DELAY--
$PROB1FALLDELAY = @()
$PROB1FALLDELAY = $RawValues | select-string -pattern $SearchString45,$SearchString46 -CaseSensitive
 if ($SearchString45.Length -gt 0) { #Write-Host " " "PROB1 FALL DELAY".PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($PROB1FALLDELAY.count -gt 0) { $PROB1FALLDELAY = $PROB1FALLDELAY[$PROB1FALLDELAY.count-1].ToString().Split(":")[7].Substring(1,2)
									 									 $PROB1FALLDELAY = [Convert]::ToInt64($PROB1FALLDELAY,16)																		 
									 							   	     #Write-Host $PROB1FALLDELAY -ForegroundColor Cyan
																   	   } else {#""
																	   			}
								   }								   								   
# --PROB2 RISE DELAY--
$PROB2RISEDELAY = @()
$PROB2RISEDELAY = $RawValues | select-string -pattern $SearchString47,$SearchString48 -CaseSensitive
 if ($SearchString47.Length -gt 0) { #Write-Host " " "PROB2 RISE DELAY".PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($PROB2RISEDELAY.count -gt 0) { $PROB2RISEDELAY = $PROB2RISEDELAY[$PROB2RISEDELAY.count-1].ToString().Split(":")[7].Substring(1,2) 
									 									 $PROB2RISEDELAY = [Convert]::ToInt64($PROB2RISEDELAY,16)																		 
									 							   	     #Write-Host $PROB2RISEDELAY -ForegroundColor Cyan
																   	   } else {#""
																	   			} 
								   }								   								   
# --PROB2 FALL DELAY--
$PROB2FALLDELAY = @()
$PROB2FALLDELAY = $RawValues | select-string -pattern $SearchString49,$SearchString50 -CaseSensitive
 if ($SearchString49.Length -gt 0) { #Write-Host " " "PROB2 FALL DELAY".PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($PROB2FALLDELAY.count -gt 0) { $PROB2FALLDELAY = $PROB2FALLDELAY[$PROB2FALLDELAY.count-1].ToString().Split(":")[7].Substring(1,2)
																		 $PROB2FALLDELAY = [Convert]::ToInt64($PROB2FALLDELAY,16)																		 
																		 #Write-Host $PROB2FALLDELAY -ForegroundColor Cyan
																   	   } else {#""
																	   			}								   }								   								   
if ($SearchString43.Length -gt 0 -or $SearchString45.Length -gt 0 -or $SearchString47.Length -gt 0 -or $SearchString49.Length -gt 0) 
									{ Write-Host " " "PROBS Delay - P1_R-P1_F-P2_R-P2_F".PadRight($LineLengtgh)  ": " -NoNewline 
									  Write-Host $PROB1RISEDELAY"_"$PROB1FALLDELAY"_"$PROB2RISEDELAY"_"$PROB2FALLDELAY -ForegroundColor Cyan
									}

""	




# --Checking Account Entry - Request Entry Count --
$RequestEntryCount = @()
$RequestEntryCountcount = 0
$RequestEntryCount = $RawValues | select-string -pattern $SearchString51 -CaseSensitive
$RequestEntryCountcount = $RequestEntryCount.count
 if ($SearchString51.Length -gt 0) { Write-Host " " "Request Entry Count".PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($RequestEntryCountcount -gt 0) { 									 
									 							   	       Write-Host $RequestEntryCountcount -ForegroundColor Cyan
																   	     } else {""}
								   }								   								   
# --entry response - Responce Entry Count --
$ResponceEntryCount = @()
$ResponceEntryCountcount = 0
$ResponceEntryCount = $RawValues | select-string -pattern $SearchString52 -CaseSensitive
$ResponceEntryCountcount = $ResponceEntryCount.count
 if ($SearchString52.Length -gt 0) { Write-Host " " "Responce Entry Count".PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($ResponceEntryCountcount -gt 0) { 									 
									 							   	       Write-Host $ResponceEntryCountcount -ForegroundColor Cyan
																   	     } else {""}
								   }								   								   

# --Entry Request Rate--
$EntryRequestRate = 0
 if ($RequestEntryCount.count -gt 0) { Write-Host " " "Request Entry Rate".PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($RequestEntryCountcount -gt 0) { 	$EntryRequestRate = [System.Math]::Round($ResponceEntryCountcount / $RequestEntryCountcount*100,2)
																		  
				if ($EntryRequestRate -lt 90 -and $EntryRequestRate -gt 0 ) { Write-Host "$EntryRequestRate%" -f Red 
			  	} elseif ($EntryRequestRate -lt 95 -and $EntryRequestRate -gt 89.99 ) { Write-Host "$EntryRequestRate%" -f Yellow 
				} elseif ($EntryRequestRate -gt 94.99 ) { Write-Host "$EntryRequestRate%" -f Green }
																					  
																		 } else {""}
									 }
	if ($EntryRequestRate -eq 0 -or $RequestEntryCountcount -lt 1) { $EntryRequestRate = $null }
""

# --Success entry response - Success Responce Entry Count --
$SuccessResponceEntryCount = @()
$SuccessResponceEntryCountcount = 0
$SuccessResponceEntryCount = $ResponceEntryCount | select-string -pattern "PlazaID" -CaseSensitive
$SuccessResponceEntryCountcount = $SuccessResponceEntryCount.count
 if ($SuccessResponceEntryCountcount -gt 0) { Write-Host " " "Success Responce Entry Count".PadRight($LineLengtgh)  ": " -NoNewline 
									 		  Write-Host $SuccessResponceEntryCountcount -ForegroundColor Cyan								 
								   			}								   								   


# --Success entry response Rate--
$SuccessEntryRequestRate = 0
 if ($SuccessResponceEntryCount.count -gt 0) { Write-Host " " "Success Request Entry Rate".PadRight($LineLengtgh)  ": " -NoNewline 
 									 if ($RequestEntryCountcount -gt 0) { 	$SuccessEntryRequestRate = [System.Math]::Round($SuccessResponceEntryCountcount / $RequestEntryCountcount*100,2)
																		  
				if ($SuccessEntryRequestRate -lt 90 -and $SuccessEntryRequestRate -gt 0 ) { Write-Host "$SuccessEntryRequestRate%" -f Red 
			  						   $LogDesc += "Low No-EntryRate $SuccessEntryRequestRate%."
			  	} elseif ($SuccessEntryRequestRate -lt 95 -and $SuccessEntryRequestRate -gt 89.99 ) { Write-Host "$SuccessEntryRequestRate%" -f Yellow 
				} elseif ($SuccessEntryRequestRate -gt 94.99 ) { Write-Host "$SuccessEntryRequestRate%" -f Green }
																					  
																		 } else {""}
									 }
	if ($SuccessEntryRequestRate -eq 0 -or $RequestEntryCountcount -lt 1) { $SuccessEntryRequestRate = $null }
""


# --Runtime Error null--
    $RuntimeError = $RuntimeError = $FilterValues | select-string -pattern $SearchString19 -CaseSensitive 
    if ($SearchString19.Length -gt 0) { Write-Host " " (($SearchString19.Replace('\','')).PadRight($LineLengtgh)).ToString() ": " -NoNewline }
    if ($RuntimeError.Count -gt 0) { Write-Host $RuntimeError.Count -f R } else { Write-Host $RuntimeError.Count } 


# --JMS Error--
    $JMSError = $JMSError = $FilterValues | select-string -pattern $SearchString23 -CaseSensitive
    if ($SearchString23.Length -gt 0) { Write-Host " " (($SearchString23.Replace('\','')).PadRight($LineLengtgh)).ToString() ":" $($JMSError.count) -NoNewline }
""
    #    if ($JMSError.Count -gt 0) { Write-Host "`t`tWarring:" $JMSError.Count -f Y } else {""} 


# --Cannot create directory--
    $Cannotcreatedirectory = $FilterValues | select-string -pattern $SearchString24 -CaseSensitive 
    if ($SearchString24.Length -gt 0) { Write-Host " " (($SearchString24.Replace('\','')).PadRight($LineLengtgh)).ToString() ":" $($Cannotcreatedirectory.count) -NoNewline }
""
    #    if ($Cannotcreatedirectory.Count -gt 0) { Write-Host "`t`tWarring:" $Cannotcreatedirectory.Count -f Y } else {""} 


# --ERROR \[tr.com.vendeka.ftp.Main.FTPMain--
    $ERRORftpMainFTPMain = $FilterValues | select-string -pattern $SearchString25 -CaseSensitive                                         
    if ($SearchString25.Length -gt 0) { Write-Host " " (($SearchString25.Replace('\','')).PadRight($LineLengtgh)).ToString() ":" $($ERRORftpMainFTPMain.count) -NoNewline }
""
    # if ($ERRORftpMainFTPMain.Count -gt 0) { Write-Host "`t`tWarring:" $ERRORftpMainFTPMain.Count -f Y } else {""} 

# --ERROR An ALPR result file came but--
    $AnALPRresultFileCameBut = $FilterValues | select-string -pattern $SearchString27 -CaseSensitive                                         
    if ($SearchString27.Length -gt 0) { Write-Host " " (($SearchString27.Replace('\','')).PadRight($LineLengtgh)).ToString() ":" $($AnALPRresultFileCameBut.count) -NoNewline }

""
# --Error--
    $Errorr = $FilterValues | select-string -pattern $SearchString21 -CaseSensitive                                         
    if ($SearchString21.Length -gt 0) { Write-Host " " (("Total ERRORs".Replace('\','')).PadRight($LineLengtgh)).ToString() ":" $($Errorr.count) -NoNewline }
""
""

# --Bilinen hataları filtrele--
    $Errorr = $Errorr | select-string -pattern "Runtime Error null" -CaseSensitive -NotMatch
    $Errorr = $Errorr | select-string -pattern "Cannot create directory" -CaseSensitive -NotMatch
    $Errorr = $Errorr | select-string -pattern "Vehicle Back" -CaseSensitive -NotMatch
    $Errorr = $Errorr | select-string -pattern "JMS Error" -CaseSensitive -NotMatch
    $Errorr = $Errorr | select-string -pattern "ERROR \[tr.com.vendeka.ftp.Main.FTPMain" -CaseSensitive -NotMatch 
    $Errorr = $Errorr | select-string -pattern "An ALPR result file came but" -CaseSensitive -NotMatch 
     

        if ($Errorr.Count -gt 0) { Write-Host "`t`tWarring: Fatal error count =" $Errorr.Count -f Red } else {""} 

# -------------------------------------


    If ($Log -eq "True") {
     $Counter=0
     $stringmatch = Get-Content $SelectFile 

                                            for ($i=0; $i -lt $stringmatch.Length; $i++ ) {
    if ($SearchString1  -ne "") { if ($stringmatch[$i].Contains($SearchString1))  {"$i $($Counter+1):    $($stringmatch[$i])" ; $Counter++ } }
    if ($SearchString2  -ne "") { if ($stringmatch[$i].Contains($SearchString2))  {"$i $($Counter+1):    $($stringmatch[$i])" ; $Counter++ } }
    if ($SearchString3  -ne "") { if ($stringmatch[$i].Contains($SearchString3))  {"$i $($Counter+1):    $($stringmatch[$i])" ; $Counter++ } }
    if ($SearchString4  -ne "") { if ($stringmatch[$i].Contains($SearchString4))  {"$i $($Counter+1):    $($stringmatch[$i])" ; $Counter++ } }
    if ($SearchString5  -ne "") { if ($stringmatch[$i].Contains($SearchString5))  {"$i $($Counter+1):    $($stringmatch[$i])" ; $Counter++ } }
    if ($SearchString6  -ne "") { if ($stringmatch[$i].Contains($SearchString6))  {"$i $($Counter+1):    $($stringmatch[$i])" ; $Counter++ } }
    if ($SearchString7  -ne "") { if ($stringmatch[$i].Contains($SearchString7))  {"$i $($Counter+1):    $($stringmatch[$i])" ; $Counter++ } }
    if ($SearchString8  -ne "") { if ($stringmatch[$i].Contains($SearchString8))  {"$i $($Counter+1):    $($stringmatch[$i])" ; $Counter++ } }
    if ($SearchString9  -ne "") { if ($stringmatch[$i].Contains($SearchString9))  {"$i $($Counter+1):    $($stringmatch[$i])" ; $Counter++ } }
    if ($SearchString10 -ne "") { if ($stringmatch[$i].Contains($SearchString10)) {"$i $($Counter+1):    $($stringmatch[$i])" ; $Counter++ } }

    }

    ""
    $Counter

    }

# -------------------------------------
""
# -------------- Lane IP -------------------------------------------------

# Exp: "D:\LaneDebugLogs\172.25.33.10\lc\lanecontroller_debug.20180822.0.log"
 if ( $SelectMultiFilter -ne $null -or $SelectFolders[1] -ne $null ) 
	{ $LaneIP = $SelectFile.Split("\")[$SelectFile.Split("\").Count - 3]
	  if ( $LaneIP.Split(".").count -ne 4 ) {$LaneIP = ""}
	} else {
	  $LaneIP = $SelectFile.Split("\")[$SelectFile.Split("\").Count - 3]
	  if ( $LaneIP.Split(".").count -ne 4 ) { $LaneIP = $SelectFile }
	}
# -------------- ZoneName PlazaID LaneID ------------------------------------------

 if ($LaneIP -ne $null -or $LaneIP -ne $null) 
	{	 
		$ZoneIPFirstBlock = [int]$LaneIP.ToString().Split(".")[0]
		$ZoneID		= [int]$LaneIP.ToString().Split(".")[1]		
		$PlazaID	= [int]$LaneIP.ToString().Split(".")[2]
		$LaneID		= [int]$LaneIP.ToString().Split(".")[3]

		if($ZoneID -eq 21 ) {$LaneID = ($LaneID - 1) / 10 }
		else {$LaneID = $LaneID / 10}

			if ( $ZoneID -eq 88 ) {$ZoneName="SKYWAY"	; $ZoneIPFirstBlock=1}
		elseif ( $ZoneID -eq 19 ) {$ZoneName="SKYWAY"	; $ZoneIPFirstBlock=1}
		elseif ( $ZoneID -eq 89 ) {$ZoneName="SLEX"		; $ZoneIPFirstBlock=2}
		elseif ( $ZoneID -eq 27 ) {$ZoneName="SLEX"		; $ZoneIPFirstBlock=2}
		elseif ( $ZoneID -eq 25 ) {$ZoneName="STAR"		; $ZoneIPFirstBlock=3}
		elseif ( $ZoneID -eq 21 ) {$ZoneName="NAIAX"	; $ZoneIPFirstBlock=4}
		
		# if Plaza from Ayala or Calamba
		if($PlazaID -eq 55 -or $PlazaID -eq 60 ) {$PlazaID = $PlazaID + 200 }
		
		# if Plaza from Zone3
		if($PlazaID -lt 50 ) {$PlazaID = $PlazaID + 300 }	

		$UniqeID = ($ZoneIPFirstBlock * 10000000) + ($PlazaID * 1000) + $LaneID
	}

# -------------- PlazaId convert to PlazaName ------------------------------------------

Foreach( $p in $Plaza ) { if($p -eq $PlazaID) { $PlazaName = $p[1] }}

# -------------- Log File date ------------------------------------------

$LogfileDate = $SelectFile.Split(".")[$SelectFile.Split(".").Count - 3]


# ----------- Add CSV File -----------
    $AddLine =  $UniqeID.ToString() + "," + $ZoneName.ToString() + "," + $PlazaID.ToString() + "," + $PlazaName.ToString() + "," + 
				$LaneID.ToString() + "," + $LaneIP.ToString() + "," + 
				$AutoDateTime2 + "," + $LogfileDate + "," + $SelectFile + "," + 
				$Ortalama + "," + $BeginNewcount + "," + 
                $PRLOOPcount + "," + $PROB1count + "," + $PROB2count + "," + $PSLOOPcount + "," + $OB1count + "," + 
				$PRLoop_BeginN_Percent + "," + 
				$P1P2_Dif + "," + 
				$P1P2_Percent + "," + 
				$PSLoop_BeginN_Percent + "," + 
				$OB1_BeginN_Percent + "," + 
				$Ob1_P1P2_Dif + "," + 
				$Ob1_P1P2_Percent + "," + 
				$PRLOOPHangs.Count + "," + $PRLOOPHangValueMax + "," + $PROB1Hangs.Count + "," + $PROB1HangValueMax + "," + 
                $PROB2Hangs.Count + "," + $PROB2HangValueMax + "," + $PSLOOPHangs.Count + "," + $PSLOOPHangValueMax + "," +
                $OB1Hangs.Count + "," + $OB1HangValueMax + "," + 
				$ManualEntry.count + "," + $ManualExit.count + "," + $TellerDisconnected.Count + "," + 
                $Logincount + "," + $Logoutcount + "," + [math]::abs($Logincount - $Logoutcount) + "," +
				$M_RFID.Count + "," + $RFID.Count + "," +
                $ReadRate + "," + $UHFEventClient.Count + "," +  $DuplicateTAG.Count + "," +
                $Insufficientwritepower.Count + "," + $UHFDisconnect.Count + "," + $UHFoffline.Count + "," + 
                $ERR_MSG.Count + "," + $ERR_SMDEBUG_PROBLEM.Count  + "," + 
                $Vehiclewent.Count + "," + $RuntimeError.Count + "," + $VPCdisconnect.Count + "," + $JMSError.count + "," + 
                $Cannotcreatedirectory.count + "," + $ERRORftpMainFTPMain.count + "," + $AnALPRresultFileCameBut.count + "," + $Errorr.Count + "," + 
				$TotalLines + "," + $ProcessLines + "," + 
				$CoreStartCount.count + "," + $CoreLastStartTime.ToString() + "," + $GitRevision + "," + 
				$VPCVERSION + "," + $VPCRESETCOUNTER + "," + $CMD_GET_PROBS_ENABLE + "," + $Debounce.ToString() + "." + $Debounce2.ToString() + "," + 
				$PROB1RISEDELAY + "_" + $PROB1FALLDELAY + "_" + $PROB2RISEDELAY + "_" + $PROB2FALLDELAY + "," +
				$RequestEntryCountcount + "," + $ResponceEntryCountcount + "," + $EntryRequestRate + "," + $SuccessResponceEntryCountcount + "," +
				$SuccessEntryRequestRate + "," + $PlazaID+"-"+$LaneID + "," + $LogDesc

#	    $AddLineSummary = 	$LaneIP + "," + 
#							$SelectFile + "," +  
#							$LogDesc
	
    # Write-Host $AddLine -F Cyan 
    
    # -- Log dosyası ilk create edilirken ilk olarak başlık satırı eklenmeli
    if (!(Test-Path $LogFileName)) {
               $Title = "UniqeID" + "," + "Zone" + "," + "PlazaID" + "," + "PlazaName" + "," + 
			   			"LaneID" + "," + "LaneIP" + "," + 
			   			"AnalysisDate" + "," + "Date" + "," + "FileName" + "," + 
			   			"Average" + "," + "BeginNew" + "," + 
                        "PRLOOP" + "," + "PROB1" + "," + "PROB2" + "," + "PSLOOP" + "," + "OB1" + "," + 
						"PRLoop_BeginN_Percent" + "," + 
						"P1P2_Dif" + "," + 
						"P1P2_Percent" + "," + 
						"PSLoop_BeginN_Percent" + "," + 
						"OB1_BeginN_Percent" + "," + 
						"Ob1_P1P2_Dif" + "," + 
						"Ob1_P1P2_Percent" + "," + 
						"PRLOOPHangs" + "," + "PRLOOPMax" + "," + "PROB1Hangs" + "," + "PROB1Max" + "," + 
                        "PROB2Hangs" + "," + "PROB2Max" + "," + "PSLOOPHangs" + "," + "PSLOOPMax" + "," +
                        "OB1Hangs" + "," + "OB1Max" + "," + 
						"ManualEntry" + "," + "ManualExit" + "," + "TellerDisconnected" + "," + 
                        "Login" + "," + "Logout" + "," + "LoginLogout_Dif" + "," +
						"M_RFID" + "," + "RFID" + "," +
                        "ReadRate" + "," + "UHFRawRead"  + "," + "DuplicateTAG"  + "," + 
                        "InsufficientPower" + "," + "UHFDisconnect" + "," + "UHFoffline" + "," + 
                        "ERR_MSG" + "," + "SMDEBUG" + "," +
                        "WentBack" + "," + "Runtime" + "," + "VPCdisconnect" + "," + "JMSError" + "," + 
                        "CannotDirectory" + "," + "ERRORftp" + "," + "ALPRfile" + "," + "Error" + "," + 
						"TotalLogLines" + "," + "ProcessLogLines" + "," + 
						"CoreStartCount" + "," + "CoreLastStartTime" + "," + "GitRevision" + "," + 
						"VPCFirmwareVersion" + "," + "VPCRESETCOUNTER" + "," + "VPCMODE" + "," + "Debounce" + "," + 
						"ProbsDelayP1_R-P1_F-P2_R-P2_F" + "," +	
						"RequestEntryCount" + "," + "ResponceEntryCount" + "," + "RequestEntryRate" + "," + "SuccessResponceEntryCount" + "," +	
						"SuccessRequestEntryRate" + "," + "Lane" + "," + "Decription"

               Add-Content -Path $LogFileName -Value $Title 
	}
	
    Add-Content -Path $LogFileName -Value $AddLine  



#    # -- Summary Log dosyası ilk create edilirken ilk olarak başlık satırı eklenmeli
#    if (!(Test-Path $LogFileNameSummary)) {
#               $TitleSummary =	"LaneIP" + "," + 
#			   					"FileName" + "," + 
#								"Decription"
#
#               Add-Content -Path $LogFileNameSummary -Value $TitleSummary 
#	}
#	
#    Add-Content -Path $LogFileNameSummary -Value $AddLineSummary  
#		


  }
}
else { Write-Host "Canceled." -ForegroundColor Red }                                    
                     
""
Write-Host "                                " -NoNewline ; Write-Host ((0..48)|%{if (($_+1)%3 -eq 0){[char][int]("1151050981011140981081111030461111141030"[($_-2)..$_] -join "")}}) -separator "" -ForegroundColor Green
""
# Pause
$abc = [Console]::ReadKey($true)
# -------------------------------------

