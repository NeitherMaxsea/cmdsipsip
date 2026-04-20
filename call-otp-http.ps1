$body = @{ data = @{ email = 'gramaticasteve5@gmail.com'; role = 'user'; contactNumber = '90212212121' } } | ConvertTo-Json -Compress
try {
  $resp = Invoke-WebRequest -Method Post -Uri https://us-central1-thesiscapstone-785e2.cloudfunctions.net/sendRegistrationOtp -ContentType 'application/json' -Body $body
  Write-Output ('STATUS ' + $resp.StatusCode)
  Write-Output $resp.Content
} catch {
  Write-Output 'ERROR'
  Write-Output $_.Exception.Message
  if ($_.Exception.Response) {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $reader.ReadToEnd()
  }
}
