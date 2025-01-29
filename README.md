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

terraform plan -var="bucket_name=your-s3-bucket-name" -var="certificate_arn=arn:aws:acm:region:account-id:certificate/certificate-id" -var="cluster_name=your-cluster-name" -var="cluster_oidc_issuer_url=https://oidc.eks.region.amazonaws.com/id/your-cluster-id" -var="eks_nodes_sg_id=sg-xxxxxxxxxxxxxxxxx" -var="launch_configuration_name=your-launch-configuration-name" -var="openid_connect_provider_uri=https://oidc.eks.region.amazonaws.com/id/your-cluster-id" -var="velero_provider=aws"


#------------------------------Explications sur infrastructure aws----------------------------#

Infrastructure cloud sécurisée et scalable sur AWS, comprenant un réseau VPC avec des sous-réseaux publics
et privés, un déploiement dynamique d'instances WordPress avec auto-scaling, une base de données sécurisée,
un serveur Bastion pour l'accès sécurisé, et un Load Balancer pour la distribution du trafic.




