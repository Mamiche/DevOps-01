# Infrastructure AWS pour l’application Java

Ce répertoire contient des configurations Terraform pour déployer l’infrastructure AWS nécessaire à votre application Java. L’architecture respecte les bonnes pratiques AWS : elle est sécurisée, évolutive et hautement disponible.

## Aperçu de l’architecture

L’infrastructure comprend :
- Une **VPC** avec des sous‑réseaux **publics et privés** répartis sur plusieurs zones de disponibilité.
- Un **Application Load Balancer (ALB)** dans les sous‑réseaux publics.
- Des instances **EC2** dans les sous‑réseaux privés gérées par des **Auto Scaling Groups (ASG)**.
- Une base de données **RDS MariaDB/MySQL** dans les sous‑réseaux privés.
- Un **bastion host** pour l’accès SSH sécurisé.
- Monitoring et logs via **CloudWatch**.

## Prérequis

### Compte AWS et accès
- Compte AWS avec les permissions appropriées
- AWS CLI installé et configuré
- Clé d’accès AWS (access key et secret key) avec les permissions nécessaires

### Outils
- Terraform version **≥ 1.0.0**
- AWS CLI version **≥ 2.0.0**

## Structure du répertoire
```
infrastructure/
├── main.tf           # Main Terraform configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── modules/
│   ├── vpc/         # VPC and networking
│   ├── security/    # Security groups
│   ├── rds/         # Database
│   ├── alb/         # Load balancer
│   ├── asg/         # Auto Scaling Group
│   └── monitoring/  # CloudWatch monitoring
└── environments/    # Environment-specific configurations
    ├── dev/
    └── prod/
```


## Utilisation
1. **Initialiser Terraform**
   ```bash
   terraform init
   ```

2. **Configurer les variables**


Crée un fichier terraform.tfvars (par exemple) :
   ```hcl
   environment        = "dev"
   aws_region        = "us-east-1"
   vpc_cidr          = "192.168.0.0/16"
   public_subnets    = ["192.168.1.0/24", "192.168.2.0/24"]
   private_subnets   = ["192.168.3.0/24", "192.168.4.0/24"]
   db_username       = "admin"
   db_password       = "your-secure-password"
   key_name          = "your-key-pair-name"
   ```

3. **Générer le plan Terraform**
   ```bash
   terraform plan -out=tfplan
   ```

4. **Application de l'infrastucture**
   ```bash
   terraform apply tfplan
   ```

## Sécurité

1. **Sécurité Réseau**
   - Toutes les Applications EC2 dans sous‑réseaux privés, non exposés à Internet
   - Seul l’ALB est visible publiquement
   - Bastion host utilisé pour un accès SSH sécurisé

2. **Securité base de données**
   - RDS MariaDB dans sous‑réseau privé
   - accès limité aux EC2 backend
   - Sauvegardes automatisées activées

3. **Access Management**
   - Utilisation de rôles IAM
   - Security Groups restreints
   - Enregistrement des VPC flow logs
   

## Monitoring et Logging

1. **CloudWatch**
   - CPU
   - Memoire
   - Trafic réseau
   - Connexions à la base de données

2. **CloudWatch Logs**
   - Logs applicatifs
   - VPC flow logs
   - Logs d’accès ALB

## Optimisation des coûts

1. **Resource Sizing**
   - Instances adaptées à la charge réelle
   - Auto Scaling pour ajustement dynamique

2. **Storage Management**
   - Nettoyage automatique des anciens logs
   - Gestion du cycle de vie des backups

## Maintenance

1. **Backup Strategy**
   - Backups automatiques de RDS
   - Période de rétention configurable
   - Récupération à un point dans le temps (PITR) possible

2. **Updates et Patches**
   - Gestion via AWS Systems Manager
   - Patches de sécurité automatisés
   - Déploiements progressifs sans interruption

## Dépannage
   - Vérifie les règles du Security Group
   - VContrôle la configuration des sous‑réseaux et des tables de routage
   - Consulte les logs CloudWatch


