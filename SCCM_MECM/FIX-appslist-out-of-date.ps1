$ErrorActionPreference = "Stop"
$TRIGGER_ALL = $false
$SLEEP_INTERVAL = 3000 # in ms
$DEBUG_LEVEL = 2
$LOG_ONLY = $true # for suppressing output so SCCM doesn't choke on it when running as a "Script" object
$LOG_TS = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOG = "c:\windows\ccm\logs\_trigger-sccm-assignment-evaluation_$LOG_TS.log"
$shutup = New-Item -ItemType File -Force -Path $LOG

function log {
	param (
		[string]$msg,
		[int]$level=0,
		[int]$debug=0
	)
	
	$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	for($i = 0; $i -lt $level; $i += 1) {
		$msg = "    $msg"
	}
	$msg = "[$ts] $msg"
	
	if($debug -le $DEBUG_LEVEL) {
		if(!$LOG_ONLY) {
			Write-Host $msg
		}
		$msg | Out-File $LOG -Append
	}
}

function Trigger-Assignment($assignment) {
	$id = $assignment.AssignmentId
	
	# This original code doesn't seem to work
	#$sched = [wmi] "root\ccm\Policy\machine\ActualConfig:CCM_Scheduler_ScheduledMessage.ScheduledMessageID='$id'"
	#$sched.Triggers = @('SimpleInterval;Minutes=1;MaxRandomDelayMinutes=0')
	#$null = $sched.Put()
	
	# This seems to be more reliable
	# Not sure what the difference is, but it seems like the below is actually triggering something, while the above is scheduling something to be triggered later
	$trigger = [wmiclass] "\root\ccm:SMS_Client"
	$result = $trigger.TriggerSchedule($id)
	log ($result | Out-String)
		
	Start-Sleep -Milliseconds $SLEEP_INTERVAL
}


log "Getting application data from WMI..."
$apps = Get-WmiObject -namespace root\ccm\clientsdk -query "select * from ccm_application"
log "Done."

log "Counting apps with missing deployment type (DT) data..."
[int]$countMissing = 0
$countTotal = $apps.Length
$missingApps = @()
foreach($app in $apps) {
	$AppDT = [wmi] $app.__Path
	if($AppDT.AppDTs.Name.Length -eq 0) {
		$count = $countMissing + 1
		$name = ($AppDT | Select Name).Name
		$id = $app.ID
		log "$count) `"$name`" ($id)" -level 1
		$appObj = @{
			"name" = $name
			"id" = $id
		}
		$missingApps += @($appObj)
		$countMissing = $countMissing + 1
	}
}
log "Done. Counted `"$countMissing`" apps with missing DTs, out of `"$countTotal`" apps."



if(($countMissing -gt 0) -or ($TRIGGER_ALL)) {
	log "Apps with missing DTs detected, or `$TRIGGER_ALL was specified. Getting all assignments..."
	
	$assignments = Get-WmiObject -query "select AssignmentName, AssignmentId, AssignedCIs from CCM_ApplicationCIAssignment" -namespace "ROOT\ccm\policy\Machine"
	
	if($assignments -ne $null) {
		log "Assignments found. Processing assignments..."
		
		foreach($assignment in $assignments) {
			$ciXML = $assignment.AssignedCIs[0]
			$ciXMLNode = $ciXML | Select-XML -XPath "/CI/ID" | Select-Object -ExpandProperty Node
			$ciID = $ciXMLNode.'#text'
			$ciIDParts = $ciID.Split("/")
			$ciIDVersionless = $ciIDParts[0] + "/" + $ciIDParts[1]
			$ciIDSanitized = $ciIDVersionless.replace("RequiredApplication", "Application")
			
			log "Processing assignment: `"$($assignment.AssignmentName)`", ID: $($assignment.AssignmentId), CIID: $ciID..." -level 1
			
			$trigger = $false
			if(!$TRIGGER_ALL) {
				log "`$TRIGGER_ALL was not specified. Checking if assignment is for one of apps with a missing DT..." -level 2
				
				foreach($app in $missingApps) {
					log "Checking app with missing DT: `"$($app.name)`" ($($app.id))..." -level 3
					log "CIID: $ciID, CIID Sanitized: $ciIDSanitized, App CIID: $($app.id)"
					if($ciIDSanitized -eq $app.id) {
						log "App matches assignment. Will trigger assignment." -level 3
						$trigger = $true
						break
					}
					else {
						log "App doesn't match assignment." -level 3
					}
					log "Done checking app: `"$($app.name)`", CIID: $($app.id)..." -level 3
				}
				log "Done checking apps for assignment." -level 2
			}
			else {
				log "`$TRIGGER_ALL was specified. Will trigger assignment." -level 2
				$trigger = $true
			}
			
			if($trigger) {
				log "Triggering assignment..." -level 2
				Trigger-Assignment $assignment
			}
			else {
				log "`$TRIGGER_ALL was not specified, and this assignment was not for any apps with a missing DT. Will not trigger assignment." -level 2
			}
			log "Done processing assignment: `"$($assignment.AssignmentName)`", ID: $($assignment.AssignmentId), CIID: $ciID." -level 1
		}
		log "Done processing all assignments."
	}
	else {
		log "No assignments found!"
	}
}
else {
	log "`$TRIGGER_ALL was not specified, and there were no apps with missing DTs to process."
}

log "EOF"

