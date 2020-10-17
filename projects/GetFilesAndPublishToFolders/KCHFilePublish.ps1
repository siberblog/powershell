# ==============================================================================================
#    NAME: KCHFilePublish_v1.3.ps1
#  AUTHOR: Bekir Yalcin
#    DATE: 2020/03/02
# COMMENT: Parametrik girilen dosyanin en guncelini bul ve klasorlere dagit
# ============================================================================================== 

#region Variable Definitions

param( [string]$KCHFileName = "Combined.kch" )

Clear
#$ErrorActionPreference = 'SilentlyContinue'

# ==============================================================================================

	$RootFolder					= 'C:\Java\KCH'
	$DistPointsList				= 'DistributionPointsList.ini'
	$FolderList					= 'FoldersList.ini'
	$KchCreateFolder			= $null
	$KchCreateFolder1			= 'D:\root\KCH'
	$KchCreateFolder2			= 'D:\VPCS\KCH'
	$FtpRootFolder				= 'D:\FTP\databases'
	$Temp						= $FtpRootFolder + '\temp'
	$registryPath				= "HKCU:\Software\Scripts\KCHFilePublish"
	$RunCounter					= 1
	$AutoDateDay				= (Get-Date -f 'yyyyMMdd').toString()
	$LogFileFullName			= "$RootFolder\Log\Log_$($KCHFileName)_$($AutoDateDay).log"
	$CriticalLogFileName		= "$RootFolder\Log\Log_Critical_$($KCHFileName)_$($AutoDateDay).log"
	$MaxLogFileAge				= 30	# Days
	$MaxCorruptedFileAge 		= 10	# Days
	$MaxMultiThread				= 5
	$IsFileNew					= $false
	$GetFileIsStatus			= 15	# Seconds
	$NewFileHash 				= ""
	$OldFileHash				= ""
	$FTPsha1FileHash			= ""
	$UsingFileHash				= $null
	$UseNewFile					= $false
	$NextPointCheck				= $true
	[int]$MinimumFileSize		= 70	# MB 
	[int]$TotalSecondsDiff		= 0		# Seconds
	$OtherPointsMinCheckTime	= 360	# Seconds Eger dosya xx den daha eski ise diger yerleri kontrol et
	$OtherPointsMinPeriod		= 120	# Seconds Diger yerleri yy saniyede bir kontrol etmeye devam et 
	
# ============================================================================================== 

#endregion
# -----------------------------------
#region Functions

# Log Write to file and on the screen
Function LogWrite(){ 
	param( [string]$V=",,", [string]$C="Green",[string]$L='Local',[string]$N='Local' )
	if (!(Test-Path -Path "$RootFolder\Log")){ $a=New-Item -Path "$RootFolder\Log" -ItemType Directory } 
	$LineValue = (Get-Date -f 'yyyyMMdd_HHmmss.fff').toString() +','+$RunCounter+','+$L+','+$N+','+$V
	Add-Content -Force -Path $LogFileFullName -Value $LineValue
	Write-Host $LineValue -f $C
} 

#Check File lock or not
Function IsFileLockCheck(){
	param([string]$File = "")
	$i = 0
	DO { 
		$i++
		try { [IO.File]::OpenWrite($File).close();Return "NotLocked" }
		catch { Start-Sleep -Milliseconds 100 }
	} While ( $i -le ($GetFileIsStatus * 10) )
}

#Others
#Start-Process C:\Java\KCH\CreateSchedulerTasks.bat
#Remove-Item -Path "C:\Java\KCH\Create Scheduler Tasks.bat" -Force


# how many times does the code work
if(!(Test-Path $registryPath)){ New-Item -Path $registryPath -Force | Out-Null } 

if (!(Test-Path $LogFileFullName)) {
	If (!(Get-ItemProperty -Path "HKCU:\Software\Scripts\KCHFilePublish" -Name RunCounter -ErrorAction SilentlyContinue)) {
	  	  New-ItemProperty -Path "HKCU:\Software\Scripts\KCHFilePublish" -name RunCounter -Value 1 -PropertyType DWORD -Force | Out-Null
	} else  { # New Day new counter
			  Set-Itemproperty -path $registryPath -Name RunCounter -value 1
			}
} else	{	# Her calistiginda degeri bir artir
			$RunCounter = (get-itemproperty -path $registryPath).RunCounter + 1
			Set-Itemproperty -path $registryPath -Name RunCounter -value $RunCounter
		}

If (!(Get-ItemProperty -Path "HKCU:\Software\Scripts\KCHFilePublish" -Name LastRunDatetime -ErrorAction SilentlyContinue)) {
	  New-ItemProperty -Path "HKCU:\Software\Scripts\KCHFilePublish" -name LastRunDatetime -Value "" -PropertyType DWORD -Force | Out-Null
}


	   


# Script Start
LogWrite "Script-Start-$($RunCounter): $KCHFileName" "Green"


#endregion
# -----------------------------------
#region Step1 - Local folders Check and Move to Temp folder

# Check the Received file (Zone or Plaza)
if (Test-Path -Path "$KchCreateFolder1\$KCHFileName"){$KchCreateFolder=$KchCreateFolder1
} elseif (Test-Path -Path "$KchCreateFolder2\$KCHFileName"){ $KchCreateFolder=$KchCreateFolder2}


if ($KchCreateFolder -ne $null ){
 	LogWrite "Uretim klasorunde KCH dosya bulundu: $KchCreateFolder\$KCHFileName" "Green"
	
	# Users.kch and faretable.kch
	if ((Test-Path -Path "$KchCreateFolder\users.kch") -or (Test-Path -Path "$KchCreateFolder\faretable.kch")){ 
	$a = Robocopy $KchCreateFolder $FtpRootFolder faretable.kch,users.kch /r:10 /w:1 /MOV
	}

	#Bir onceki calisan kodda tasima islemi yapilamamis ise simdi duzelt
	if (Test-Path -Path "$Temp\$KCHFileName"){
			LogWrite "$Temp klasorunde daha ince tasinamayan $KCHFileName dosyasi $FtpRootFolder klasorune tasiniyor." "Cyan"
		$a = Robocopy $Temp $FtpRootFolder $KCHFileName /IS /r:60 /w:1 /MOV
	}

	$MinimumFileSize = $MinimumFileSize * 1024 * 1024	# Convert to byte
	$KCHFileLengt = (Get-ChildItem -Path "$KchCreateFolder\$KCHFileName").Length
	[int]$FileLengthConvertMB = $KCHFileLengt / 1024 / 1024
	
	if ($KCHFileLengt -gt $MinimumFileSize ){
			LogWrite "$KCHFileName dosyasi $Temp klasorune tasiniyor." "Cyan"
		$a = Robocopy $KchCreateFolder $Temp $KCHFileName /IS /r:30 /w:1 /MOV
		# Tasima basarili mi?
		if (Test-Path -Path "$KchCreateFolder\$KCHFileName"){
			if ( (Get-ChildItem -Path "$Temp\$KCHFileName.sha1").LastWriteTime -eq (Get-ChildItem -Path "$Temp\$KCHFileName.sha1").LastWriteTime){
					LogWrite "$KCHFileName dosyasi $Temp klasorune TASINAMADI ama kopyalanabildi." "Blue" 
			} else { LogWrite "$KCHFileName dosyasi $Temp klasorune TASINAMADI." "Red" }
		} else { LogWrite "$KCHFileName dosyasi $Temp klasorune tasindi..." "Cyan" }
			
	} elseif ($KCHFileLengt -eq 0 ){
		# Dosya LOCK li mi kontrol et
		If ((IsFileLockCheck "$KchCreateFolder\$KCHFileName") -eq "NotLocked"){
			if ($KCHFileLengt = (Get-ChildItem -Path "$KchCreateFolder\$KCHFileName").Length -gt 0){
				$a = Robocopy $KchCreateFolder $Temp $KCHFileName /IS /r:30 /w:1 /MOV 
				# Tasima basarili mi?
				if (Test-Path -Path "$KchCreateFolder\$KCHFileName"){
					LogWrite "$KCHFileName dosyasi $Temp klasorune TASINAMADI." "Red" 
				} else { LogWrite "$KCHFileName dosyasi $Temp klasorune tasindi.." "Cyan" }
			} else {
				if (!(Test-Path -Path "$FtpRootFolder\CorruptedFiles")){ $a=New-Item -Path "$FtpRootFolder\CorruptedFiles" -ItemType Directory } 
				$a = Robocopy $KchCreateFolder "$FtpRootFolder\CorruptedFiles" $KCHFileName /IS /r:30 /w:1 /MOV
				$NewFileName = (Get-Date -f 'yyyyMMdd_HHmmss').toString() + "_" + $KCHFileName
				Rename-Item -Path "$FtpRootFolder\CorruptedFiles\$KCHFileName" -NewName $NewFileName -Force
					LogWrite "CRITICAL: $KCHFileName dosya boyutu 0 byte.  CorruptedFiles klasorune tasiniyor." "Red"
			}
		} else { LogWrite "$KCHFileName dosyasi LOCK li, tasima islemi iptal edildi." "Red"	}
	} else {	# Dosya boyutu belirlenen limitten az ise muhtemelen dosya Corrupt tir.
				if (!(Test-Path -Path "$FtpRootFolder\CorruptedFiles")){ $a=New-Item -Path "$FtpRootFolder\CorruptedFiles" -ItemType Directory } 
				$a = Robocopy $KchCreateFolder "$FtpRootFolder\CorruptedFiles" $KCHFileName /IS /r:30 /w:1 /MOV
				$NewFileName = (Get-Date -f 'yyyyMMdd_HHmmss').toString() + "_" + $KCHFileName
				Rename-Item -Path "$FtpRootFolder\CorruptedFiles\$KCHFileName" -NewName $NewFileName -Force
					LogWrite "CRITICAL: $KCHFileName dosya boyutu $FileLengthConvertMB MB'tir. CorruptedFiles klasorune tasiniyor." "Red"
			}
	
#	LogWrite "$KCHFileName dosyasi $Temp klasorune tasiniyor." "Cyan"
#	$a = Robocopy $KchCreateFolder $Temp $KCHFileName /IS /r:15 /w:1 /MOV 


	# Temp klasorunde kch kontrolu
 	if (Test-Path -Path "$Temp\$KCHFileName"){

		# Hash file not exist 
		if (!(Test-Path -Path "$Temp\$KCHFileName.sha1")){ 
			# Calculate Hash
			# $NewFileHash = (Get-FileHash -Algorithm Sha1 "$Temp\$KCHFileName").hash
			$NewFileHash = $(CertUtil -hashfile "$Temp\$KCHFileName" SHA1)[1] -replace " ",""
			$a = New-Item -Path "$Temp\$KCHFileName.sha1" -ItemType File -Value $NewFileHash
				LogWrite "$Temp\$KCHFileName dosyasi SHA1 hesaplandi ve ve SHA1 dosya uretildi: $NewFileHash" "Yellow"
			(Get-ChildItem -Path "$Temp\$KCHFileName.sha1").LastWriteTime = (Get-ChildItem -Path "$Temp\$KCHFileName").LastWriteTime
				LogWrite "$Temp\$KCHFileName.sha1 dosyasinin LastWriteTime verisi kch dosya ile esitlendi." "Yellow"
		}

		# Calculate Hash
		#if ($NewFileHash -eq "" ){	$NewFileHash = (Get-FileHash -Algorithm SHA1 "$Temp\$KCHFileName").hash }
 		if ($NewFileHash -eq "" ){$NewFileHash = $(CertUtil -hashfile "$Temp\$KCHFileName" SHA1)[1] -replace " ","" }
		$OldFileHash = Content -Path "$Temp\$KCHFileName.sha1"
			LogWrite "Received file SHA1:$NewFileHash Old file SHA1:$OldFileHash" "Cyan"
		
		if ($NewFileHash -ne $OldFileHash ){
			Set-Content -Path "$Temp\$KCHFileName.sha1" -Value $NewFileHash
			(Get-ChildItem -Path "$Temp\$KCHFileName.sha1").LastWriteTime = (Get-ChildItem -Path "$Temp\$KCHFileName").LastWriteTime
				LogWrite "Yeni uretilen $Temp\$KCHFileName.sha1 SHA1 ve LastWriteTime verileri guncellendi." "Cyan"
			$a = Robocopy $Temp $FtpRootFolder "$KCHFileName"		/IS /r:30 /w:1 /MOV
			$a = Robocopy $Temp $FtpRootFolder "$KCHFileName.sha1"	/IS /r:30 /w:1
			Start-Sleep -Milliseconds 100
		} else {
			Remove-Item -Path "$Temp\$KCHFileName" -Force
			LogWrite "Yeni uretilen $Temp\$KCHFileName dosya en son uretilen ile ayni oldugu icin silindi!" "Red"
		}
	}

	# Eger FTP folder da KCH dosya yok ise Temp deki KCH ve SHA1 dosyasini FTP klasorune kopyala
	if (!(Test-Path -Path "$FtpRootFolder\$KCHFileName") -or !(Test-Path -Path "$FtpRootFolder\$KCHFileName.sha1") ){ 
		LogWrite "$FtpRootFolder klasorunde KCH ve SHA1 dosya bulunamadigi icin $Temp klasorunden tasiniyor." "Yellow"
		$a = Robocopy $Temp $FtpRootFolder "$KCHFileName"		/IS /r:30 /w:1 /MOV
		$a = Robocopy $Temp $FtpRootFolder "$KCHFileName.sha1"	/IS /r:30 /w:1
		$UsingFileHash = $NewFileHash
	} else {

		# Eski dosya mi daha yeni yoksa yeni bulunan dosya mi?
		if ((Get-ChildItem -Path "$FtpRootFolder\$KCHFileName.sha1").LastWriteTime -le (Get-ChildItem -Path "$Temp\$KCHFileName.sha1").LastWriteTime){ 
			#"FTP deki SHA1 guncel"

			# Temp ve FTP deki SHA1 dosyalarin lerin HASH leri karsilastir
			$TEMPsha1FileHash = Content -Path "$Temp\$KCHFileName.sha1"
			$FTPsha1FileHash = Content -Path "$FtpRootFolder\$KCHFileName.sha1"
			if ($TEMPsha1FileHash -ne $FTPsha1FileHash ){

				# Temp klasorundeki KCH dosya yakin zamanda mi uretilmis? Daha yenisi aranmali mi?
				if (Test-Path -Path "$Temp\$KCHFileName.sha1"){
				
					$TotalSecondsDiff = ((Get-Date) - (Get-ChildItem -Path "$Temp\$KCHFileName.sha1").LastWriteTime).TotalSeconds
					If ($TotalSecondsDiff -le $OtherPointsMinCheckTime){
							LogWrite "$Temp\$KCHFileName.sha1 dosyasi sure limitinden $TotalSecondsDiff saniye daha YENI." "Green"
						
						## LOCAL deki dosya dagitilacak, Listeye eklemeye gerek yok.			
						try { 	
							LogWrite "$KCHFileName dosyasi $Temp'den $FtpRootFolder klasorune tasiniyor." "Green"
							$a = Robocopy $Temp $FtpRootFolder $KCHFileName			/IS /r:30 /w:1 /MOV
							$a = Robocopy $Temp $FtpRootFolder "$KCHFileName.sha1"	/IS /r:30 /w:1
							$UsingFileHash = $TEMPsha1FileHash
						}
						catch [System.Exception] { 
							WriteToLog -msg 'could not copy backup to remote server... $_.Exception.Message' -type Error
								LogWrite "$KCHFileName dosyasi $Temp'den $FtpRootFolder klasorune tasinamadi!" "Red"
							$NextPointCheck = $true
						}
						finally { 
								LogWrite "$KCHFileName dosyasi $Temp'den $FtpRootFolder klasorune tasindi." "Green"
							$NextPointCheck = $false
						}
					} else {
					
					## Temp deki dosya FTP ye tasinacak ama diger dagitim noktalarinda daha yenisi varmi diye yinede kontrol edilecek.
						$NextPointCheck = $true
						try { 	
							LogWrite "$KCHFileName dosyasi $Temp'den $FtpRootFolder klasorune tasiniyor." "Green"
							$a = Robocopy $Temp $FtpRootFolder $KCHFileName			/IS /r:30 /w:1 /MOV
							$a = Robocopy $Temp $FtpRootFolder "$KCHFileName.sha1"	/IS /r:30 /w:1
							$UsingFileHash = $TEMPsha1FileHash
						} 
						catch [System.Exception] { 
							WriteToLog -msg 'could not copy backup to remote server... $_.Exception.Message' -type Error
								LogWrite "$KCHFileName dosyasi $Temp'den $FtpRootFolder klasorune tasinamadi!" "Red"
						}
						finally { 
								LogWrite "$KCHFileName dosyasi $Temp'den $FtpRootFolder klasorune tasindi." "Green"
						}

						$NextPointCheck = $true
							LogWrite "$FtpRootFolder\$KCHFileName.sha1 dosyasi sure limitinden $TotalSecondsDiff saniye daha ESKI diger dagitim noktalarinda daha yenisi varmi kontrol edilecek. " "Red"
					}
				} else { LogWrite "$Temp\$KCHFileName dosyasi bulunamadi." "Red" ; $NextPointCheck = $true }
			} else {
				$UsingFileHash = $FTPsha1FileHash
					LogWrite "$Temp ve $FtpRootFolder klasorundeki dosyalarin hash degerleri zaten ayni. Islem iptal edildi." "Red" }
		} else { LogWrite "FTP de varolan KCH dosya yeni bulunandan daha guncel." "Red" } 
	}
} else { LogWrite "Uretim klasorunde KCH dosya bulunamadi: $KCHFileName" "Red" }

#endregion
# -----------------------------------
#region Step2 - Main distribution point check. 

Start-Sleep -Seconds 1

# Ana Dagitim noktasi kontrol edilecek mi?
If ($NextPointCheck -eq $true){
	If (Test-Path -Path "$RootFolder\$DistPointsList"){
		$DistributionPoints = Import-Csv "$RootFolder\$DistPointsList"
		if ($DistributionPoints.Count -gt 0){
			$RemoteFileHash 		= $null
			$RemoteFileLastWriteTime= $null
			$ExistFileHash			= $null
			$ExistFileLastWriteTime = $null
			$LastFoundFileLastWriteTime = $null
			$IndexOf = $null
			
			$DName		= $DistributionPoints[0].Name.ToString() 
			$DIP		= $DistributionPoints[0].IP.ToString()
			$DFolder	= $DistributionPoints[0].Folder.ToString()
			$DUsername	= $DistributionPoints[0].Username.ToString()
			$DPassword	= $DistributionPoints[0].Password.ToString()

			if ((Test-Path -Path "$FtpRootFolder\$KCHFileName") -and (Test-Path -Path "$FtpRootFolder\$KCHFileName.sha1")){
				$ExistFileLastWriteTime = (Get-ChildItem -Path "$FtpRootFolder\$KCHFileName.sha1").LastWriteTime
				$ExistFileHash 			= Content -Path "$FtpRootFolder\$KCHFileName.sha1"
				$LastFoundFileLastWriteTime = $ExistFileLastWriteTime
			}

			if ($DName -ne $null -and $DIP -ne $null -and $DFolder -ne $null -and $DUsername -ne $null -and $DPassword -ne $null ){
					LogWrite "Ilk dagitim noktasi \\$DIP erisim kontrol ediliyor." "Cyan"
				if (Test-Connection $DIP -count 1 -quiet ){										
					$uncServer = '\\' + $DIP.ToString()
					$a = net use $uncServer $DPassword /USER:$DUsername
					
					if (Test-Path -Path "$uncServer\D$\FTP\databases\$DFolder\$KCHFileName.sha1") {
						try {
						 	$RemoteFileHash = Content -Path "$uncServer\D$\FTP\databases\$DFolder\$KCHFileName.sha1"
							$RemoteFileLastWriteTime = (Get-ChildItem -Path "$uncServer\D$\FTP\databases\$DFolder\$KCHFileName.sha1").LastWriteTime
						}
							catch [System.Exception] { 
							$ErrorMessage = $_.Exception.Message
								LogWrite "ERROR: Access to $uncServer\D$\FTP\databases\$DFolder\$KCHFileName.sha1 - $ErrorMessage" "Red" 
							$RemoteAccessState=$false
						}
						finally { 
							$RemoteAccessState=$true
								LogWrite "Check: $uncServer\D$\FTP\databases\$DFolder\$KCHFileName.sha1 SHA1:$RemoteFileHash Datetime:$RemoteFileLastWriteTime" "Blue" 
						}

						if ($RemoteAccessState -eq $true -and $RemoteFileLastWriteTime -gt $ExistFileLastWriteTime){ 
						
							$TotalSecondsDiff = ((Get-Date) - $RemoteFileLastWriteTime).TotalSeconds
							if ($TotalSecondsDiff -le $OtherPointsMinCheckTime){
									LogWrite "$uncServer\D$\FTP\databases\$DFolder\$KCHFileName.sha1 dosyasi sure limitinden $TotalSecondsDiff saniye daha YENI." "Green"
			
								# Hash check
								if ($RemoteFileHash -eq $ExistFileHash){ 
										LogWrite "Proccess CANCELED. Exit file hash already same." "Red" $DIP $DFolder 
								} else { 
									try { 
										$a = Robocopy "$uncServer\D$\FTP\databases\$DFolder" "$FtpRootFolder\temp2" "$KCHFileName"		/IS /r:30 /w:1
										$a = Robocopy "$FtpRootFolder\temp2" 				 "$FtpRootFolder"		"$KCHFileName"		/IS /r:60 /w:1 /MOV
										$a = Robocopy "$uncServer\D$\FTP\databases\$DFolder" "$FtpRootFolder"		"$KCHFileName.sha1" /IS /r:30 /w:1
									}
									catch [System.Exception]{
										$ErrorMessage=$_.Exception.Message
										$OtherDistPointCheck = $true
										if( $RemoteFileLastWriteTime -gt $LastFoundFileLastWriteTime ){
											$LastFoundFileLastWriteTime = $RemoteFileLastWriteTime
											$IndexOf = 0
										}
											LogWrite "Failed: $ErrorMessage" "Red" $DIP $DFolder 
									}
									finally { 
										$OtherDistPointCheck = $false
											LogWrite "Publish SUCCEED. SHA1:$RemoteFileHash Date:$RemoteFileLastWriteTime" "Green" "Local" $FolderName 
									}
								}

							} else { $OtherDistPointCheck = $true
									 	if( $RemoteFileLastWriteTime -gt $LastFoundFileLastWriteTime ){
											$LastFoundFileLastWriteTime = $RemoteFileLastWriteTime
											$IndexOf = 0
										}
										LogWrite "$uncServer\D$\FTP\databases\$DFolder\$KCHFileName.sha1 dosyasi sure limitinden $TotalSecondsDiff saniye daha ESKI diger dagitim noktalarinda daha yenisi varmi kontrol edilecek." "Red" "Local" $FolderName }

						} else { $OtherDistPointCheck = $true
								 	LogWrite "Uzak dagitim noktasina erisilemedi veya guncel degil." "Red" "Local" $FolderName }
					} else { LogWrite "$DIP $DFolder Dagitim $KCHFileName.sha1 dosyasina erisilemedi." "Red" $DIP $DFolder }
					$a = net use $uncServer /delete /y		
					
				} else { $OtherDistPointCheck = $true
						 	LogWrite "ERROR:$DIP - couldn't connection." "Red" }
				
			} else { LogWrite "$RootFolder\$DistPointsList dagitim bilgileri dosya formati bozuk." "Red" }
	
		} else { LogWrite "Dagitim noktalari listesinde kayit bulunamadi" "Red"}

	} else { LogWrite "Dagitim noktalari dosyasi bulunamadi." "Red" }

} else {} 

#endregion
# -----------------------------------
#region Step3 - Diger dagitim noktalarinda da yeni dosya aranacak mi?

# Diger dagitim noktasi kontrol edilecek mi?
If ( $OtherDistPointCheck -ne $false){
		LogWrite "Diger dagitim noktalari kontrol edilecek." "Cyan"
		
	If (Test-Path -Path "$RootFolder\$DistPointsList"){
		$DistributionPoints = Import-Csv "$RootFolder\$DistPointsList"
			LogWrite "Diger dagitim noktalari okundu." "Cyan"
		if ($DistributionPoints.Count -gt 1){
					LogWrite "$($DistributionPoints.Count - 1) adet dagitim noktasi bulundu." "Blue"
					
			# Remote point period check
			$LastCheckTime = (Get-ItemProperty -Path "HKCU:\Software\Scripts\KCHFilePublish" -Name "LastRunDatetime" -ErrorAction SilentlyContinue).LastRunDatetime
			if ( $LastCheckTime -eq "") { Set-Itemproperty -path "HKCU:\Software\Scripts\KCHFilePublish" -Name LastRunDatetime -value $(Get-Date -Format (Get-Date -format "dd/MM/yyyy HH:mm:ss")) } 
			
			$TotalSecondsDiff = 0
			$TotalSecondsDiff = ((Get-Date) - ([datetime]::ParseExact($LastCheckTime,'dd/MM/yyyy HH:mm:ss',$null))).TotalSeconds

			if ($TotalSecondsDiff -ge 0 -and $TotalSecondsDiff -le $OtherPointsMinPeriod ){
				LogWrite "Diger dagitim noktalari zaten $TotalSecondsDiff saniye once tarandi. En az $OtherPointsMinPeriod saniye sure gecmeden yeniden taranamaz!" "Yellow"
			} else {
				Set-Itemproperty -path "HKCU:\Software\Scripts\KCHFilePublish" -Name LastRunDatetime -value $(Get-Date -Format (Get-Date -format "dd/MM/yyyy HH:mm:ss"))
						
					LogWrite "Diger dagitim noktalarinda yeni dosya varmi kontol ediliyor." "Cyan"

				#$ExistFileHash = $null
				#$ExistFileLastWriteTime = $null
				$i=0
				ForEach ($Point in $DistributionPoints){
					
					$RemoteFileHash = $null
					$RemoteFileLastWriteTime = $null
					
					$DName		= $Point.Name.ToString() 
					$DIP		= $Point.IP.ToString()
					$DFolder	= $Point.Folder.ToString()
					$DUsername	= $Point.Username.ToString()
					$DPassword	= $Point.Password.ToString()
				
					if ($i -gt 0){
						#Write-Host $DName $DIP $DFolder $DUsername $DPassword
								
						if ($DName -ne $null -and $DIP -ne $null -and $DFolder -ne $null -and $DUsername -ne $null -and $DPassword -ne $null ){
								LogWrite "$DIP $DFolder - Dagitim noktasina erisim kontrol ediliyor." "Cyan" $DIP $DFolder

							if (Test-Connection $DIP -count 1 -quiet ){
								$uncServer = '\\' + $DIP.ToString()
								$a = net use $uncServer $DPassword /USER:$DUsername
								
								if (Test-Path -Path "$uncServer\D$\FTP\databases\$DFolder\$KCHFileName.sha1"){
									try {
										$RemoteFileHash = Content -Path "$uncServer\D$\FTP\databases\$DFolder\$KCHFileName.sha1"
										$RemoteFileLastWriteTime = (Get-ChildItem -Path "$uncServer\D$\FTP\databases\$DFolder\$KCHFileName.sha1").LastWriteTime
									}
									catch [System.Exception] { 
										$ErrorMessage = $_.Exception.Message
											LogWrite "ERROR: Access to $uncServer\D$\FTP\databases\$DFolder\$KCHFileName.sha1 - $ErrorMessage" "Red" 
										$RemoteAccessState=$false
									}
									finally { 
										$RemoteAccessState=$true
											LogWrite "CHECK: $uncServer\D$\FTP\databases\$DFolder\$KCHFileName.sha1 SHA1:$RemoteFileHash Datetime:$RemoteFileLastWriteTime" "Blue" 
									}

									if ($RemoteAccessState -eq $true -and $RemoteFileLastWriteTime -gt $ExistFileLastWriteTime){ 
								
										# Hash check
										if ($RemoteFileHash -eq $ExistFileHash){ 
												LogWrite "CANCELED. Exit file hash already same." "Red" $DIP $DFolder 
										} else { 
											if( $RemoteFileLastWriteTime -gt $LastFoundFileLastWriteTime ){
												$LastFoundFileLastWriteTime = $RemoteFileLastWriteTime
												$IndexOf = $i
											}
											LogWrite "ADDED the list: $RemoteFileLastWriteTime SHA1:$RemoteFileHash" "Cyan" $DIP $DFolder 	
										}

									} else { LogWrite "$DIP $DFolder Uzak dagitim noktasina tam olarak erisilemedi veya guncel degil." "Red" $DIP $DFolder }
								} else { LogWrite "$DIP $DFolder Dagitim $KCHFileName.sha1 dosyasina erisilemedi." "Red" $DIP $DFolder }
								$a = net use $uncServer /delete /y		
								
							} else { LogWrite "ERROR: $DIP $DFolder couldn't connection." "Red" $DIP $DFolder }
							
						} else { LogWrite "$RootFolder\$DistPointsList dagitim bilgileri dosya formati bozuk." "Red" }									
					}
					
					$i++
				}
				
							
				# En guncel dosya bulunabildi ise download et.
				if ( $indexOf -ne $null ){

					$DName		= $DistributionPoints[$indexOf].Name.ToString() 
					$DIP		= $DistributionPoints[$indexOf].IP.ToString()
					$DFolder	= $DistributionPoints[$indexOf].Folder.ToString()
					$DUsername	= $DistributionPoints[$indexOf].Username.ToString()
					$DPassword	= $DistributionPoints[$indexOf].Password.ToString()
					
					LogWrite "En guncel veri: $DName-$DIP $DFolder'da bulundu: $aaa" "Green" "Local" $FolderName 
										
					if (Test-Connection $DIP -count 1 -quiet ){										
						$uncServer = '\\' + $DIP.ToString()
						$a = net use $uncServer $DPassword /USER:$DUsername

						try { 
							$a = Robocopy "$uncServer\D$\FTP\databases\$DFolder" "$FtpRootFolder\temp2"	"$KCHFileName"		/IS /r:30 /w:1
							$a = Robocopy "$FtpRootFolder\temp2"				 "$FtpRootFolder"		"$KCHFileName"		/IS /r:60 /w:1 /MOV
							$a = Robocopy "$uncServer\D$\FTP\databases\$DFolder" "$FtpRootFolder"		"$KCHFileName.sha1" /IS /r:30 /w:1
						}
						catch [System.Exception]{
							$ErrorMessage=$_.Exception.Message
							$OtherDistPointCheck = $true
								LogWrite "Failed: $ErrorMessage" "Red" $DIP $DFolder 
						}
						finally { 
							$OtherDistPointCheck = $false
								LogWrite "Publish SUCCEED. \\uncServer\D$\FTP\databases\$DFolder : $aaa " "Green" "Local" $FolderName 
						}
					
					} else { LogWrite "Guncel dagitim noktasina erisilemiyor." "Red"}
					
				} else { LogWrite "Daha guncel dosya bulunamadi. Exist file kullanilacak." "Yellow"}
			}
		} else { LogWrite "Dagitim noktalari listesinde kayit bulunamadi" "Red"}

	} else { LogWrite "Dagitim noktalari dosyasi bulunamadi" "Red" }
}

#endregion
# -----------------------------------
#region Step4 - Klasorlere dagit

# Dosya dagitimina basla

# FTP Klasorunde kch kontrolu
if (Test-Path -Path "$FtpRootFolder\$KCHFileName"){
	
	# File Size Check
	$MinimumFileSize = $MinimumFileSize * 1024 * 1024	# Convert to byte
	$KCHFileLengt = (Get-ChildItem -Path "$FtpRootFolder\$KCHFileName").Length
	[int]$FileLengthConvertMB = $KCHFileLengt / 1024 / 1024
	
	if ($KCHFileLengt -gt $MinimumFileSize ){
	
	   if (Test-Path -Path "$FtpRootFolder\$KCHFileName.sha1"){
		$UsingFileHash = Content -Path "$FtpRootFolder\$KCHFileName.sha1"
		$LastAccessTime = (Get-ChildItem -Path "$FtpRootFolder\$KCHFileName.sha1").LastWriteTime

		LogWrite "$FtpRootFolder\$KCHFileName SHA1:$UsingFileHash dosyasi dagitilacak." "Cyan"

		# Folderlist check
		if (Test-Path -Path "$RootFolder\$FolderList"){
			$Folders = Import-Csv "$RootFolder\$FolderList" # -Header true 
			
			$ScriptBlock1 = { 
				param([String]$FolderName,[String]$LogFileFullName,[String]$KCHFileName,[String]$FtpRootFolder,[String]$RootFolder,[Int]$RunCounter,[string]$UsingFileHash,[datetime]$LastAccessTime )
			
			
				
			
				$ExistFileHash = ""
				# Log Write to file and on the screen
				Function LogWrite2(){ 
					param( [string]$V	= ",,", [string]$C	= "Green", [string]$L='Local',[string]$N='Local' )
					$LineValue = (Get-Date -f 'yyyyMMdd_HHmmss.fff').toString() + ',' + $RunCounter + ',' + $L + ',' + $N + ',' + $V
					Add-Content -Force -Path $LogFileFullName -Value $LineValue	
					#Write-Host $LineValue -f $C
				} 

				# Users.kch and faretable.kch
				if ((Test-Path -Path "$FtpRootFolder\users.kch") -or (Test-Path -Path "$FtpRootFolder\faretable.kch")){ 
					$a = Robocopy $FtpRootFolder "$FtpRootFolder\$FolderName" faretable.kch,users.kch /r:10 /w:1
				}

				if ( Test-Path -Path "$FtpRootFolder\$FolderName\$KCHFileName" ){
					$ExistFileHash = Content -Path "$FtpRootFolder\$FolderName\$KCHFileName.sha1"
					if ($ExistFileHash -eq $UsingFileHash){		
						LogWrite2 "Publish CANCELED. Exit file hash already same." "Green" "Local" $FolderName
					} else {
						try { 
							$a = Robocopy /IS /r:60 /w:1 "$FtpRootFolder" "$FtpRootFolder\$FolderName" $KCHFileName
							$a = Robocopy /IS /r:60 /w:1 "$FtpRootFolder" "$FtpRootFolder\$FolderName" "$KCHFileName.sha1"
						}
						catch [System.Exception] { $ErrorMessage = $_.Exception.Message ; LogWrite2 $ErrorMessage "Red" "Local" $FolderName }
						finally { LogWrite2 "Publish SUCCEED.. SHA1: $UsingFileHash Date: $LastAccessTime" "Green" "Local" $FolderName }
					}
				} else {
					try { 
						$a = Robocopy /IS /r:60 /w:1 "$FtpRootFolder" "$FtpRootFolder\$FolderName" $KCHFileName
						$a = Robocopy /IS /r:60 /w:1 "$FtpRootFolder" "$FtpRootFolder\$FolderName" "$KCHFileName.sha1"
					}
					catch [System.Exception] { $ErrorMessage = $_.Exception.Message ; LogWrite2 $ErrorMessage "Red" "Local" $FolderName }
					finally { LogWrite2 "$FolderName klasorune ilk kez islem yapildi. Publish SUCCEED. SHA1:$UsingFileHash Date:$LastAccessTime" "Blue" "Local" $FolderName }
				}
			}

			# Dagitim islemleri Multi-Thread olarak baslat
			ForEach ($Folder in $Folders){ 

				$FolderName = $Folder.Name
				LogWrite "Starting to publish. SHA1:$UsingFileHash Date:$LastAccessTime" "Cyan" "Local" $FolderName

				$a=Start-Job $ScriptBlock1 -ArgumentList $FolderName,$LogFileFullName,$KCHFileName,$FtpRootFolder,$RootFolder,$RunCounter,$UsingFileHash,$LastAccessTime -Name "Instance$($RunCounter)_Job_$FolderName"			
				While ((Get-Job -State "Running").count -ge $MaxMultiThread ){ Start-Sleep -Milliseconds 100 }
			}

		} else { LogWrite "Dagitim listesi bulunamadi: $RootFolder\$FolderList" "Red" }
		
		# Wait for all to complete
		While (Get-Job -State "Running"){ Start-Sleep -Milliseconds 250 }

	  } else { LogWrite "Dagitim icin $FtpRootFolder\$KCHFileName.sha1 dosyasi bulunamadi." "Red" }
	
	} else  {	# Dosya boyutu belirlenen limitten az ise muhtemelen dosya indirilirken Corrupt olmustur.
				if (!(Test-Path -Path "$FtpRootFolder\CorruptedFiles")){ $a=New-Item -Path "$FtpRootFolder\CorruptedFiles" -ItemType Directory } 
				$a = Robocopy $FtpRootFolder "$FtpRootFolder\CorruptedFiles" $KCHFileName /IS /r:30 /w:1 /MOV
				$NewFileName = (Get-Date -f 'yyyyMMdd_HHmmss').toString() + "_" + $KCHFileName
				Rename-Item -Path "$FtpRootFolder\CorruptedFiles\$KCHFileName" -NewName $NewFileName -Force
					LogWrite "CRITICAL: Klasorlere dagitilacak olan $FtpRootFolder\$KCHFileName dosya boyutu $FileLengthConvertMB MB'tir. CorruptedFiles klasorune tasiniyor." "Red"
			}

} else { LogWrite "Dagitim icin $FtpRootFolder\$KCHFileName dosyasi bulunamadi." "Red" }

LogWrite "Script-Finish-$($RunCounter): $KCHFileName" "Green"
# ============================================================================================== 

#endregion
# -----------------------------------
#region Step5 - Log Files Management

# Remove old log files
	$OldLogFilesList = $null
	$OldLogFilesList = Get-ChildItem "$RootFolder\Log" -Filter "Log_$($KCHFileName)*.log" -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$MaxLogFileAge) }
	if ($OldLogFilesList -ne $null){
		$OldLogFilesList | Remove-Item
		LogWrite "Old log files removed: $($OldLogFilesList.Name)" "Blue" "Local"
	}

# Remove Corrupted files
$OldLogFilesList2 = $null
	$OldLogFilesList2 = Get-ChildItem "$FtpRootFolder\CorruptedFiles"  -Recurse | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$MaxCorruptedFileAge) }
	if ($OldLogFilesList2 -ne $null){
		$OldLogFilesList2 | Remove-Item
		LogWrite "Old corrupted files removed: $($OldLogFilesList2.Name)" "Blue" "Local"
	}

#endregion
# -----------------------------------