resource "aws_instance" "ec2_instance" {
    ami             = "${var.default_ami}"
    instance_type   = "${var.instance_type}"
    key_name        = "${var.key_pair}"
    vpc_security_group_ids = ["${var.security_group_id}"]
}