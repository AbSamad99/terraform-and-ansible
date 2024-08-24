#!/bin/bash

configuringPath="../configuring"

terraform destroy -auto-approve
rm "$configuringPath/inventory"
chmod 700 $configuringPath/rsa-key.pem
rm $configuringPath/rsa-key.*