#################################################################
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2017, 2018.
#
#################################################################

provider "aws" {
  version = "~> 1.2"
  region  = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

#########################################################
# Define the variables
#########################################################

variable app_download_url {
  description = "URL where to download application."
}

#AWS variables
variable aws_access_key {
  description = "AWS access key."
  #default     = "ADD YOUR AWS ACCESS KEY HERE"
}

variable aws_secret_key {
  description = "AWS secret key."
  #default     = "ADD YOUR AWS ACCESS SECRET KEY HERE"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-central-1"
}

variable "aws_image_size" {
  description = "AWS Image Instance Size"
  default     = "t2.small"
}

#Variable : AWS image name
variable "aws_image" {
  type        = "string"
  description = "Operating system image id / template that should be used when creating the virtual image"
  default     = "ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"
}

variable "aws_ami_owner_id" {
  description = "AWS AMI Owner ID"
  default     = "099720109477"
}

variable "network_name_prefix" {
  description = "The prefix of names for VPC, Gateway, Subnet and Security Group"
  default     = "terraform-created-network"
}

# Lookup for AMI based on image name and owner ID
data "aws_ami" "aws_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.aws_image}*"]
  }

  owners = ["${var.aws_ami_owner_id}"]
}

#########################################################
# Build network
#########################################################
resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "${var.network_name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.network_name_prefix}-gateway"
  }
}

resource "aws_subnet" "primary" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}b"

  tags {
    Name = "${var.network_name_prefix}-subnet"
  }
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "${var.network_name_prefix}-route-table"
  }
}

resource "aws_route_table_association" "primary" {
  subnet_id      = "${aws_subnet.primary.id}"
  route_table_id = "${aws_route_table.default.id}"
}

resource "aws_security_group" "application" {
  name        = "${var.network_name_prefix}-security-group-app"
  description = "Security group which applies to the server"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.network_name_prefix}-security-group-application"
  }
}


##############################################################
# Create temp public key for ssh connection
##############################################################
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}

resource "aws_key_pair" "temp_public_key" {
  key_name   = "ssh-pub-key-name-temp"
  public_key = "${tls_private_key.ssh.public_key_openssh}"
}

#server
resource "aws_instance" "orpheus_ubuntu_micro" {
  instance_type = "${var.aws_image_size}"
  ami           = "${data.aws_ami.aws_ami.id}"
  subnet_id    = "${aws_subnet.primary.id}"
  vpc_security_group_ids = ["${aws_security_group.application.id}"]
  key_name      = "${aws_key_pair.temp_public_key.id}"
  associate_public_ip_address = true

  ##############################################################
  # Set up remote machine
  ##############################################################

 # Specify the ssh connection
  connection {
    user        = "ubuntu"
    private_key = "${tls_private_key.ssh.private_key_pem}"
    host        = "${self.public_ip}"
  }

  # Copy script file(s)
  provisioner "file" {
    source      = "scripts/install_docker.sh"
    destination = "install_docker.sh"
  }

  provisioner "file" {
    source      = "scripts/install_app.sh"
    destination = "install_app.sh"
  }
  
  # Execute setup script remotely
  provisioner "remote-exec" {
    inline = [
      "bash install_docker.sh",
      "bash install_app.sh ${var.app_download_url}",
    ]
  }

}

#########################################################
# Output
#########################################################
output "IP address" {
  value = "${aws_instance.orpheus_ubuntu_micro.public_ip}"
}


