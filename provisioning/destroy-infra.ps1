$configuringPath = "..\configuring"
rm "$configuringPath\rsa-key.*"
rm "$configuringPath\inventory"

terraform destroy -auto-approve