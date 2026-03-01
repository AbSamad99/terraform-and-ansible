$configuringPath = "..\configuring"

terraform init
terraform plan
terraform apply -auto-approve

$webIPs = terraform output -json web_servers | ConvertFrom-Json
$dbIP = terraform output -raw db_server

@("[web_servers]") + $webIPs + @("", "[db_server]", $dbIP) | Set-Content -Path "$configuringPath\inventory"

cp rsa-key.* "$configuringPath\"