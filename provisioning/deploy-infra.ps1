$configuringPath = "..\configuring"

terraform init
terraform plan
terraform apply -auto-approve

$addresses = terraform output ubuntu-instances-public-ip
$cleanAddress = $($addresses -replace '[\[\]""]', '').Trim()
$splitAddress = $cleanAddress.Split(',')
$splitAddress | ForEach-Object {$_.Trim()} | Set-Content -Path "$configuringPath\inventory"

cp rsa-key.* "$configuringPath\"