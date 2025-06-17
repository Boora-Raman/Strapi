variable "vpc_id" {}
variable "subnet_id" {}
variable "security_group_id" {}

resource "aws_instance" "strapi_ec2" {
  ami                         = "ami-0779caf41f9ba54f0" 
  instance_type               = "t2.small"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]

  associate_public_ip_address = true
  key_name = "ec2-key"




   user_data = <<-EOF
#!/bin/bash
set -e
LOGFILE="/home/admin/docker-setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

sleep 10

echo "System update and prerequisites"
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https

echo "Add Docker’s official GPG key"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "Add Docker repository"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs 2>/dev/null || echo bookworm) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Update apt and install Docker"
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Enable and start Docker service"
systemctl start docker
systemctl enable docker

echo "Run test container"
docker run -d -p 1337:1337 --name strapi-deployment booraraman/strapi-app:77abefcaa8c3bd31331824bcf09cace74ba0e9f6 


   EOF
  tags = {
    Name = "strapi-ec2+docker+terraform"
  }
}



output "ec2_public_ip" {
  value = aws_instance.strapi_ec2.public_ip
}
