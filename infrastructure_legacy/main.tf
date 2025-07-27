provider "aws" {
  region = "eu-west-3"  # Région Paris
}
variable "db_username" {
  description = "Nom d'utilisateur admin pour MariaDB"
  type        = string
}

variable "db_password" {
  description = "Mot de passe pour l'utilisateur admin MariaDB"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nom bd MariaDB"
  type        = string
  sensitive   = true
}
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH, HTTP and App traffic"
  vpc_id      = "vpc-0366c1072f3fb9c58"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Autorisé depuis n'importe où ; à limiter pour plus de sécurité
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Autorise tout le trafic sortant
  }

  tags = {
    Name = "WebSecurityGroup"
  }
}


resource "aws_instance" "my_ec2" {
  ami           = "ami-0fcc1d7ed380d3549"  # Amazon Linux 2023
  instance_type = "t2.micro"  # Gratuit
  key_name      = "mamiche_devops_cle_rsa"  # Utilisation de ta clé existante
  subnet_id     = "subnet-0047114579f7b7712"
  # Attacher le groupe de sécurité existant
  vpc_security_group_ids = [aws_security_group.web_sg.id]   # Remplace par l'ID du sg //TODO ajout dans terraform creation sg 
  
  tags = {
    Name = "devops_tomcat_project_1_ansible_terraform"
  }
}

# ---------------------------------------------------
# 1. Groupe de sous‑réseaux privés pour RDS
resource "aws_db_subnet_group" "rds_subnets" {
  name       = "rds-private-subnet-group"
  subnet_ids = [
    "subnet-09ada7a8e0ea46194",
    "subnet-0c3bf92b64176e7e3"
  ]
  tags = {
    Name = "rds-private-subnet-group"
  }
}

# 2. Groupe de sécurité pour MariaDB (port 3306 accessible uniquement depuis votre EC2)
resource "aws_security_group" "rds_sg" {
  name        = "rds-private-sg"
  description = "Allow MariaDB access from EC2"
  vpc_id      = "vpc-0366c1072f3fb9c58" # VPC defaut

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp" 
    security_groups = [aws_security_group.web_sg.id] #  indique que seuls les membres du groupe de sécurité web_sg (sg de EC2 ) peuvent établir une connexion entrante sur le port 3306 (MariaDB).
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Instance MariaDB RDS dans le VPC, non accessible publiquement
resource "aws_db_instance" "mariadb" {
  identifier             = "dptwebdb"
  engine                 = "mariadb"
  engine_version         = "10.6"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  tags = {
    Environment = "dev"
  }
}

#recuperer instan de domain mariadb aws rds describe-db-instances --db-instance-identifier dptwebdb --query "DBInstances[0].[Endpoint.Address,Endpoint.Port]" --output table


# se connecter a la mariaDB via mysql de ec2 : mysql -h dptwebdb.cfyoy48im4h0.eu-west-3.rds.amazonaws.com \
#      -P 3306 \
#      -u user \
#      -p


