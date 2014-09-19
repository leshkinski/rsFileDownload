function Get-TargetResource
{
	[OutputType([Hashtable])]
	param
	(
		[Parameter()]
		[ValidateSet("Present", "Absent")]
		[string]$Ensure = "Present",
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$SourceURL,
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$DestinationFile
	)
	
	#check to see if file exists
	if(!(Test-Path -Path $DestinationFile))
	{
		Write-Verbose "File is not present and needs to be downloaded."
		$Configuration = @{
					Ensure = $Ensure
					SourceURL = $SourceURL
					DestinationFile = $DestinationFile
					}
	}
	else
	{
		Write-Verbose "File is present."
		$Configuration = @{
					Ensure = $Ensure
					SourceURL = $SourceURL
					DestinationFile = $DestinationFile
					}
	}
	
		
}




function Set-TargetResource
{
	param
	(
		[Parameter()]
		[ValidateSet("Present", "Absent")]
		[string]$Ensure = "Present",
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$SourceURL,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$DestinationFile
	)
	try
	{
	$myLogSource = $PSCmdlet.MyInvocation.MyCommand.ModuleName
	New-Eventlog -LogName "DevOps" -Source $myLogSource -ErrorAction SilentlyContinue
	}
	catch {}
	
	if ($Ensure -like 'Present')
	{
		if(!(Test-Path -Path $DestinationFile)) 
		{
			Write-EventLog -LogName DevOps -Source $myLogSource -EntryType Information -EventId 1000 -Message "File $DestinationFile is present in configuration, but not present on disk, and will be downloaded from $SourceURL."
			$downloadtry = 1
			$downloadtrymax = 5
			While($downloadtry -lt 6)
				{
					try{
						Write-EventLog -LogName DevOps -Source $myLogSource -EntryType Information -EventId 1000 -Message "Try $downloadtry of $downloadtrymax downloading $SourceURL to $DestinationFile"
						$webclient = New-Object System.Net.WebClient
						$webclient.downloadfile($SourceURL,$DestinationFile)
						if(Test-Path -Path $DestinationFile)
							{
							Write-EventLog -LogName DevOps -Source $myLogSource -EntryType Information -EventId 1000 -Message "Download of $SourceURL to $DestinationFile was successful"
							$downloadtry = 6
							}
						}
					catch {
						if($downloadtry -lt 5){
							Write-EventLog -LogName DevOps -Source $myLogSource -EntryType Error -EventId 1002 -Message "Download $downloadtry of $downloadtrymax of $SourceURL failed, retrying"
							$downloadtry++
						}
						else{
							Write-EventLog -LogName DevOps -Source $myLogSource -EntryType Error -EventId 1002 -Message "Download of $SourceURL has exceeded the maximum number of retries"
							$downloadtry = 6
						}
					}
				}
		}
		else
		{
			Write-EventLog -LogName DevOps -Source $myLogSource -EntryType Information -EventId 1000 -Message "File $DestinationFile is present in configuration, and present on disk, no action taken"
		}
	}
	else
	{
		if (!(Test-Path -Path $DestinationFile))
		{
			Write-EventLog -LogName DevOps -Source $myLogSource -EntryType Information -EventId 1000 -Message "File $DestinationFile is absent in configuration, and not present on disk, no action taken"
		}
		else
		{
			Write-EventLog -LogName DevOps -Source $myLogSource -EntryType Information -EventId 1000 -Message "File $DestinationFile is absent in configuration, but present on disk, deleting"
			Remove-Item $DestinationFile -Force
		}
	}
}




function Test-TargetResource
{
	[OutputType([boolean])]
	param
	(
		[Parameter()]
		[ValidateSet("Present", "Absent")]
		[string]$Ensure = "Present",
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$SourceURL,

		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$DestinationFile
	)
	
	$IsValid = $false
	
	$FileLocation = $DestinationFile
	
	if ($Ensure -like 'Present')
	{
		if(!(Test-Path -Path $DestinationFile))
		{
			Write-Verbose "File is not present."
		}
		else
		{
			Write-Verbose "File is present."
			$IsValid = $true
		}
	}
	else
	{
		if(!(Test-Path -Path $DestinationFile))
		{
			$IsValid = $true
		}
		else
		{
			Write-Verbose "File is present."
		}
	}
	return $IsValid
}




													