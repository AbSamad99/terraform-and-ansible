#!/bin/bash

configuringPath="../configuring"

terraform init
terraform apply -auto-approve

inventoryPath="$configuringPath/inventory"
echo "[web_servers]" > $inventoryPath
terraform output -json web_servers | jq -r '.[]' >> $inventoryPath
echo "[db_server]" >> $inventoryPath 
terraform output -json db_server | jq -r >> $inventoryPath
cp rsa-key.* $configuringPath/
chmod 400 $configuringPath/rsa-key.pem

while read -r ip; do
  if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Getting certificate of $ip"
    ssh-keyscan -H "$ip" >> ~/.ssh/known_hosts
  fi
done < $inventoryPath
