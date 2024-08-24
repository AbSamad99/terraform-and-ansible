#!/bin/bash

configuringPath="../configuring"

terraform init
terraform apply -auto-approve

inventoryPath="$configuringPath/inventory"
echo "[web-servers]" >> $inventoryPath
terraform output -json web-servers | jq -r '.[]' >> $inventoryPath
echo "[db-server]" >> $inventoryPath 
terraform output -json db-server | jq -r >> $inventoryPath
cp rsa-key.* $configuringPath/
chmod 400 $configuringPath/rsa-key.pem

while read -r ip; do
  if [[ "$ip" =~ ^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$ ]]; then
    ssh-keyscan -H "$ip" >> ~/.ssh/known_hosts
  fi
done < $inventoryPath
