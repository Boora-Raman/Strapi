
variable "vpc_id" {}
variable "subnet_id" {}

resource "aws_security_group" "allow_tls" {
  name        = "strapi-allow-tls"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id
  tags = {
    Name = "strapi-allow"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "strapi_ui" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 1337
  ip_protocol       = "tcp"
  to_port           = 1337
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


output "sg_id" {
  value = aws_security_group.allow_tls.id
}

