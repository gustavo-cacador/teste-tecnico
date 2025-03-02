provider "aws" {
  region = "us-east-1"
}

# Variáveis para nomeação dos recursos
variable "projeto" {
  default = "infra-aws"
}

variable "candidato" {
  default = "meu-estagio"
}

# Criar uma Key Pair para SSH
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "debian_key" {
  key_name   = "${var.projeto}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Criar uma VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.projeto}-vpc"
  }
}

# Criar uma Subnet pública
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "${var.projeto}-subnet"
  }
}

# Criar um Internet Gateway e anexá-lo à VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.projeto}-igw"
  }
}

# Criar uma tabela de rotas para permitir acesso à internet
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.projeto}-route-table"
  }
}

# Associar a tabela de rotas à Subnet
resource "aws_route_table_association" "route_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}

# Criar um Security Group mais seguro
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id

  # Permitir acesso SSH apenas de um IP específico (modifique para seu IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["MEU_IP/32"] # Altere para seu IP
  }

  # Permitir tráfego HTTP para Nginx
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfego HTTPS (caso instale SSL depois)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir todo tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.projeto}-sg"
  }
}

# Criar uma instância EC2 com Debian e Nginx instalado automaticamente
resource "aws_instance" "web" {
  ami                         = "ami-04b70fa74e45c3917" # Debian 12
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.debian_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = {
    Name = "${var.projeto}-instance"
  }
}

# Criar um CloudWatch Log Group para logs do sistema
resource "aws_cloudwatch_log_group" "nginx_logs" {
  name = "/var/log/nginx/access.log"

  retention_in_days = 7
}

# Configuração de um snapshot automático da instância (backup)
resource "aws_backup_vault" "backup_vault" {
  name = "${var.projeto}-backup"
}

resource "aws_backup_plan" "backup_plan" {
  name = "${var.projeto}-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = "cron(0 12 * * ? *)"  # Faz backup todos os dias ao meio-dia

    lifecycle {
      delete_after = 30  # Mantém backups por 30 dias
    }
  }
}

resource "aws_backup_selection" "backup_selection" {
  name         = "daily-backup-selection"
  iam_role_arn = "arn:aws:iam::YOUR_ACCOUNT_ID:role/service-role/AWSBackupDefaultServiceRole"
  plan_id      = aws_backup_plan.backup_plan.id

  resources = [aws_instance.web.arn]
}

# Saídas importantes
output "public_ip" {
  value = aws_instance.web.public_ip
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}