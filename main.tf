# Variables

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "vpc_id" {}
variable "aws_key_pair" {}
variable "region" {
  default = "eu-west-2"
}
variable "key_pair" {
  default = "${var.aws_key_pair}"
}

variable "install_script" {}

# Provider
provider "aws" {
  access_key            = "${var.aws_access_key}"
  secret_key            = "${var.aws_secret_key}"
  region                = "${var.region}"
}

# Resources
resource "aws_instance" "apache" {
    ami             = "ami-0b0a60c0a2bd40612"
    instance_type   = "t2.micro"
    key_name        = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.web_open_world.id}"]


    connection {
        user        = "ubuntu"
        private_key = "${file(var.private_key_path)}"
    }

    provisioner "file" {
        source      = "${var.install_script}"
        destination = "/tmp/startup.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/startup.sh",
            "sudo /tmp/startup.sh"
        ]
    
    }
}

resource "aws_security_group" "web_open_world" {
    name        = "web_open_world"
    description = "Allows HTTP and HTTPS access to the open world"
    vpc_id      = "${var.vpc_id}"

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
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/32"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "web_open_world"
    }
}

# Output
output "aws_instance_public_dns" {
  value     = "${aws_instance.apache.public_ip}"
}
