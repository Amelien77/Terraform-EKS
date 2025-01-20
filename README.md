#----------------------------------Installation-----------------------------------------------#

Installation des paquets:
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common


Installation de la clé GPG Hashicorp:
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null


Vérification de l'empreinte digitale de la clé:
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint


Ajout du référentiel officiel HashiCorp à notre système:
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list


Téléchargement des informations du package:
sudo apt update


Installation de Terraform:
sudo apt-get install terraform


Vérification de la version Terraform:
terraform --version

Installer aws configure:
sudo apt  install awscli

Configuration aws
aws configure
AccessKey:""
SecretKey:""
region: eu-west-3
Default output format [none]: json

Vérification config aws:
cat ~/.aws/credentials
cat ~/.aws/config

Variables database persistente:
--> taper cette commande:
nano ~/.bashrc
--> Ajouter vos variables à la fin du fichier:
export TF_VAR_db_username=""
export TF_VAR_db_password="" (attention au moins 8 digits)
--> Recharger le fichier:
source ~/.bashrc
--> Vérifier vos variables:
echo $TF_VAR_db_username
echo $TF_VAR_db_password
ou
env | grep TF

Création d'un certificat:
--> aller sur votre compte cloundns
--> Créer votre DNS (zone) en mettant à jour votre IP VM
--> aller sur le compte aws
--> taper ACM dans la barre de recherche
--> demander un certificat
--> certificat publique
--> donner le nom de domaine complet de cloudns (domaine+sousdomaine)
--> validation dns
--> rsa 2048
--> valider (il sera en attente de validation)
--> dans domaine, prendre "Nom CNAME" et "Valeur CNAME"
--> retourner sur cloudns dans zone et ajouter un CNAME
--> recopier dans hôte "Nom CNAME" (sans "." à la fin) et valeur CNAME dans "indique vers"
--> valider et attender que le certificat soit émis et validé.

Vérification certificat:
aws acm list-certificates --region eu-west-3

Vous pouvez maintenant utiliser ces commandes:
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
terraform show
terraform destroy -auto-approve

#-------------------------Correction d'erreur éventuelle----------------------------------------------#

si erreur lors du Terraform apply:

--> AMI inconnu
faire cette commande pour trouver une AMI valide (x86_64 pour T2_micro):
aws ec2 describe-images --owners amazon --region eu-west-3 --filters "Name=name,Values=*ubuntu*" --query "Images[*].{ID:ImageId,Name:Name}" --output table
ou
aws ec2 describe-images \
>   --owners amazon \
>   --region eu-west-3 \
>   --filters "Name=name,Values=*ubuntu*20.04*" "Name=architecture,Values=x86_64" \
>   --query "Images | sort_by(@, &CreationDate) | [-5:].{ID:ImageId, Name:Name}" \
>   --output table
puis remplacer l'AMI dans main.tf

--> syntaxe ASCII
Vérifier les descriptions, les mettre en anglais et sans accents

#------------------------------Explications sur infrastructure aws----------------------------#

Infrastructure cloud sécurisée et scalable sur AWS, comprenant un réseau VPC avec des sous-réseaux publics
et privés, un déploiement dynamique d'instances WordPress avec auto-scaling, une base de données sécurisée,
un serveur Bastion pour l'accès sécurisé, et un Load Balancer pour la distribution du trafic.




Module Bastion:
"Ce module déploie une instance bastion pour accéder de manière sécurisée aux ressources dans un VPC privé.
Le groupe de sécurité associé permet l'accès SSH (port 22) uniquement depuis des IPs spécifiées.
L'instance EC2 de type bastion agit comme un pont pour accéder aux autres ressources internes du réseau."

Groupe de sécurité Bastion                      1
Instance EC2 Bastion                            1
Elastic IP Bastion                              1

Total:                                          3



Module Database:
"Ce module configure une base de données RDS MySQL pour héberger le backend de WordPress.
Il crée un groupe de sous-réseaux spécifiquement pour la base de données, un groupe de sécurité restrictif permettant l'accès
uniquement à partir de sous-réseaux ou IPs définis, et une instance RDS sécurisée avec des paramètres spécifiques.
La base de données est configurée pour la haute disponibilité avec multi-AZ."


Groupe de sécurité DB                           1
Instance RDS                                    1
Elastic IP DB                                   1
Security Group DB                               1
Subnets DB                                      2
Route Tables DB                                 2
Route Table Association DB                      2

Total:                                          10

Module Load-balancer (10 ressources):
"Ce module configure un Load Balancer (ALB) pour diriger le trafic HTTP et HTTPS vers les instances WordPress.
Il crée plusieurs ressources, y compris des listeners HTTP et HTTPS (avec un certificat SSL/TLS),
des groupes de sécurité pour contrôler l'accès, un groupe cible pour le trafic vers les instances,
et attache un groupe de mise à l'échelle automatique pour gérer dynamiquement les instances EC2.

Load Balancer (ALB)                             1
Security Group Load Balancer                    1
Target Group Load Balancer                      1
Listener HTTP                                   1
Listener HTTPS                                  1
Autoscaling Group                               1
Autoscaling Attachment                          1
Launch Configuration                            1
ACM SSL Certificate                             1

Total:                                          9

Module Network-vpc (17 ressources):
"Ce module crée une infrastructure de réseau complète dans AWS.
Cela comprend un VPC avec deux sous-réseaux publics et deux sous-réseaux privés répartis sur deux zones de disponibilité (AZ).
Il configure des passerelles NAT et des adresses IP élastiques pour permettre aux instances dans les sous-réseaux privés d'accéder à Internet.
Un Internet Gateway est créé pour permettre aux sous-réseaux publics d'accéder à Internet.
Enfin, des tables de routage et leurs associations sont configurées pour diriger correctement le trafic
entre les sous-réseaux publics et privés."

VPC                                             1
Sous-réseau public A                            1
Sous-réseau public B                            1
Sous-réseau privé A                             1
Sous-réseau privé B                             1
Passerelle NAT public A                         1
Passerelle NAT public B                         1
Adresse IP Élastique (EIP) pour NAT public A    1
Adresse IP Élastique (EIP) pour NAT public B    1
Internet Gateway                                1
Table de routage publique                       1
Table de routage privée A                       1
Table de routage privée B                       1
Association de tables de routage (public)       2
Association de tables de routage (privé)        2

Total:                                          17

Module Wordpress:
"Ce module configure l'infrastructure nécessaire pour déployer un site WordPress hautement disponible sur AWS.
Il crée un groupe de sécurité dédié à WordPress pour contrôler l'accès réseau.
Ensuite, une configuration de lancement est définie pour les instances EC2, suivie d'un Auto Scaling Group
pour gérer dynamiquement le nombre d'instances EC2.
Le module associe également l'Auto Scaling Group à un groupe cible du Load Balancer pour diriger le trafic entrant vers les instances EC2.
Enfin, des listeners HTTP et HTTPS sont configurés pour le Load Balancer,
avec un certificat SSL/TLS pour sécuriser les connexions HTTPS."


Groupe de sécurité WordPress                   1
Launch Configuration WordPress                 1
Auto Scaling Group WordPress                   1
Target Group WordPress                         1
Autoscaling Attachment WordPress               1

Total:                                         5

Total global:                                  44
Ressource AWS                                  34
