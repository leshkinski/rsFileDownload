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
			Write-Verbose "File is not present and will be downloaded."
			$downloadtry = 1
			While ($downloadtry -lt 4)
				{
					try{
						Write-Verbose "Trying download attempt $downloadtry"
						Invoke-WebRequest $SourceURL -OutFile $DestinationFile
						$downloadtry = 4
					}
					catch {
						Write-Verbose "Download failed - retrying"
						$downloadtry++
						}
				}
			#after while loop completes check path again
			if(!(Test-Path -Path $DestinationFile))
			{
				Write-Verbose "Download of $SourceURL to $DestinationFile was successful"
			}
			else
			{
				Write-Verbose "Download of $SourceURL to $DestinationFile failed"
				Write-EventLog -LogName DevOps -Source $myLogSource -EntryType Error -EventId 1000 -Message "Failed to download $SourceURL"
			}
		}
		else
		{
			Write-Verbose "File is present, no action needed."
		}
	}
	else
	{
		if (!(Test-Path -Path $DestinationFile))
		{
			Write-Verbose "File is not present, no action needed"
		}
		else
		{
			Write-Verbose "File is present, and will be removed."
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
		Write-Verbose "Checking for presence of $DestinationFile"
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
			Write-Verbose "File is not present."
			$IsValid = $true
		}
		else
		{
			Write-Verbose "File is present."
		}
	}
	return $IsValid
}




													