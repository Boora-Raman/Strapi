variable "vpc_id" {}
variable "subnet_id" {}
variable "security_group_id" {}

resource "aws_instance" "strapi_ec2" {
  ami                         = "ami-0779caf41f9ba54f0" 
  instance_type               = "t2.small"
  subnet_id                   = var.subnet_id  
  vpc_security_group_ids      = [var.security_group_id]
  
  associate_public_ip_address = true



   user_data = <<-EOF

#!/bin/bash
set -e
LOGFILE="/home/admin/docker-setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

trap 'echo "❌ Script failed, cleaning up..."; minikube delete; exit 1' ERR
export HOME=/root

# ✅ System requirements
if [ $(nproc) -lt 2 ] || [ $(free -m | awk '/Mem:/ {print $2}') -lt 2000 ]; then
    echo "❌ Requires at least 2 CPUs and 2GB RAM"
    exit 1
fi

echo "🛠️ Updating system and installing dependencies..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https nginx

echo "🔐 Adding Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "📦 Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/debian \
$(lsb_release -cs 2>/dev/null || echo bookworm) stable" > /etc/apt/sources.list.d/docker.list

echo "📥 Installing Docker..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✅ Starting Docker..."
systemctl enable docker
systemctl start docker

echo "📥 Installing Minikube..."
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
install -m 0755 minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

echo "📥 Installing kubectl..."
K_VER=$(curl -Ls https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${K_VER}/bin/linux/amd64/kubectl"
install -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

echo "📁 Setting up Minikube config dirs..."
mkdir -p $HOME/.kube $HOME/.minikube
touch $HOME/.kube/config
chmod -R 777 $HOME/.kube $HOME/.minikube

echo "🚀 Starting Minikube with Docker driver..."
minikube start --driver=docker --force

echo "✅ Minikube is up:"
minikube status

echo "📥 Pulling Strapi image..."
docker pull booraraman/strapi-app:053a8235e0799766123b09e5043afbbd48374d65

echo "📦 Creating Strapi deployment..."
kubectl create deployment strapi --image=booraraman/strapi-app:053a8235e0799766123b09e5043afbbd48374d65

echo "🌍 Exposing Strapi on NodePort 30004 (port 1337)..."
kubectl expose deployment strapi --type=NodePort --port=1337 --target-port=1337
kubectl patch service strapi -p '{"spec": {"ports": [{"port": 1337, "targetPort": 1337, "nodePort": 30004}]}}'

echo "⏳ Waiting for Strapi pod to be ready..."
kubectl rollout status deployment/strapi --timeout=120s || {
  echo "❌ Strapi pod failed to become ready"
  kubectl get pods
  kubectl describe deployment strapi
  kubectl logs deployment/strapi
  exit 1
}

# ✅ Configure NGINX reverse proxy
echo "⚙️ Configuring NGINX to forward to Minikube..."

cat > /etc/nginx/sites-available/strapi <<EOF
server {
    listen 80;
    listen 1337;
    listen 30004;

    location / {
        proxy_pass http://192.168.49.2:30004;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/strapi /etc/nginx/sites-enabled/strapi
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx
systemctl enable nginx

echo "✅ NGINX is set up to forward traffic on ports 80, 1337, and 30004"
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
echo "🌐 Access Strapi at: http://$PUBLIC_IP"

EOF
  tags = {
    Name = "strapi-ec2+docker+terraform"
  }
}



output "ec2_public_ip" {
  value = aws_instance.strapi_ec2.public_ip
}
