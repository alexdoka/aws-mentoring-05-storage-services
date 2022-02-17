terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.1"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      "stack" = "dev-05"
      "owner" = "Aliaksandr_Dakutovich"
    }
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion-01"
  description = "Bastion-01 Security Group"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description = "Allow SSH"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "test" {
  ami           = data.aws_ami.amazonlinux.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  vpc_security_group_ids = [ aws_security_group.bastion.id ]

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/xvdf"
    volume_size           = 10
    volume_type           = "gp2"
    
    tags = {
      Name = "test_volume"
    }
  }

  user_data = <<EOF
#!/bin/bash
mkfs.xfs /dev/xvdf
mount /dev/xvdf /mnt/
echo 'Hello from instance 1' > /mnt/test.txt
EOF

  tags = {
    "Name" = "test-ec2"
  }
}
