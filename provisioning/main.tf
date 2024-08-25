# Setting the provider as AWS and configuring the region 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
}

# Creating the key pair which will be used to login to the machines (THIS IS NOT SECURE!!!! IT IS BETTER TO GENERATE THE KEY SEPARATELY AND SHARE IT!!!)
resource "tls_private_key" "rsa-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "rsa-key" {
  key_name   = "rsa-key"
  public_key = tls_private_key.rsa-key.public_key_openssh
}

resource "local_file" "private" {
  content  = tls_private_key.rsa-key.private_key_pem
  filename = "rsa-key.pem"
}

resource "local_file" "public" {
  content  = tls_private_key.rsa-key.public_key_openssh
  filename = "rsa-key.pub"
}

# Creating the security group and it's rules
resource "aws_security_group" "instances" {
  name = "instances-security-group"
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.instances.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["172.110.70.155/32"] # My IP
}

resource "aws_security_group_rule" "allow_rdp" {
  type              = "ingress"
  security_group_id = aws_security_group.instances.id
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["172.110.70.155/32"] # My IP
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  security_group_id = aws_security_group.instances.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["172.110.70.155/32"] # My IP
}

resource "aws_security_group_rule" "allow_egress" {
  type              = "egress"
  security_group_id = aws_security_group.instances.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Provisioning the ubuntu instances
resource "aws_instance" "ubuntu-instances" {
  count           = 3
  ami             = "ami-01923bb5372808c50" # Ubuntu 22.04 LTS
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.rsa-key.key_name
  security_groups = [aws_security_group.instances.name]

  tags = {
    "Name" = "Ubuntu-${count.index + 1}"
  }
}

# Provisioning the CentOS instances
# resource "aws_instance" "centos-instance" {
#   ami             = "ami-059972b88fabb1811" # CentOS Stream 9
#   instance_type   = "t2.micro"
#   key_name        = aws_key_pair.rsa-key.key_name
#   security_groups = [aws_security_group.instances.name]

#   tags = {
#     "Name" = "CentOS"
#   }
# }

output "web_servers" {
  value = slice(aws_instance.ubuntu-instances[*].public_ip, 0, 2)
}

output "db_server" {
  value = aws_instance.ubuntu-instances[2].public_ip
}

# output "centos-instance-public-ip" {
#   value = aws_instance.centos-instance.public_ip
# }

# output "centos-instance-private-ip" {
#   value = aws_instance.centos-instance.private_ip
# }
