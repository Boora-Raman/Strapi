resource "aws_security_group" "allow_tls" {
  name        = "strapi-allow-tls"  # Renamed
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "medusa-allow-tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ecs_from_alb" {
  security_group_id        = aws_security_group.allow_tls.id
  referenced_security_group_id = aws_security_group.allow_tls.id
  from_port                = 1337
  ip_protocol              = "tcp"
  to_port                  = 1337
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

