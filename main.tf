# Provider
provider "aws" {
  region                = "${var.region}"
}

module "security_group" {
  source                    = "./modules/secuity_group"
  aws_security_group_name   = "${var.aws_security_group_name}"
  description               = "Wordpress Security Group"
  vpc_id                    = "${var.vpc_id}"
}


# Resources
module "ec2_instance" {
  source = "./modules/ec2_instance"
  default_ami               = "${var.default_ami}"
  instance_type             = "${var.instance_type}"
  key_pair                  = "${var.aws_key_pair}"
  security_group_id         = "${module.security_group.id}"
}

# Output
output "aws_instance_public_dns" {
  value     = "${aws_instance.apache.public_ip}"
}
