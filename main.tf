# Variables

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "region" {
  default = "eu-west-2"
}
variable "key_pair" {
  default = "aws-testing"
}
variable "security_group_id" {}

# Provider

provider "aws" {
  access_key            = "${var.aws_access_key}"
  secret_key            = "${var.aws_secret_key}"
  region                = "${var.region}"
}

resource "aws_instance" "apache" {
    ami             = "ami-0b0a60c0a2bd40612"
    instance_type   = "t2.micro"
    key_name        = "${var.key_pair}"

    connection {
        user        = "ubuntu"
        private_key = "${file(var.private_key_path)}"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update -y",
            "sudo apt-get install apache2 -y",
            "sudo service apache2 start"
        ]
    }
}

data "aws_security_group" "selected" {
  id = "${var.security_group_id}"
}

# Output

output "aws_instance_public_dns" {
  value = "${aws_instance.apache.public_dns}"
}


