env=play
tf_folder=infra

rm -rf ./${tf_folder}/bootstrap/.terraform/terraform.tfstate ./${tf_folder}/bootstrap/.terraform.lock.hcl 
rm -rf ./${tf_folder}/bootstrap/.terraform ./${tf_folder}/bootstrap/.terraform.lock.hcl 


# tf fmt
terraform -chdir=./${tf_folder}/bootstrap fmt 
terraform -chdir=./${tf_folder}/envs/${env} fmt 


# tf init
terraform -chdir=./${tf_folder}/bootstrap init -backend-config=../../${tf_folder}/envs/${env}/tf-backend-${env}.conf


# tf validate and plan
terraform -chdir=./${tf_folder}/bootstrap validate 

terraform -chdir=./${tf_folder}/bootstrap plan -var-file=../../${tf_folder}/envs/${env}/terraform-${env}.tfvars -compact-warnings


# tf apply
# terraform -chdir=./${tf_folder}/bootstrap apply -var-file=../../${tf_folder}/envs/${env}/terraform-${env}.tfvars -compact-warnings

terraform -chdir=./${tf_folder}/bootstrap apply -var-file=../../${tf_folder}/envs/${env}/terraform-${env}.tfvars -compact-warnings -auto-approve


# tf destroy 
terraform -chdir=./${tf_folder}/bootstrap destroy -var-file=../../${tf_folder}/envs/${env}/terraform-${env}.tfvars -compact-warnings

terraform -chdir=./${tf_folder}/bootstrap state rm google_service_account.workflows_sa

terraform -chdir=./${tf_folder}/bootstrap state list | grep workflows_sa


cd infra/bootstrap

terraform init -backend-config=../../infra/envs/play/tf-backend-play.conf


terraform apply -var-file=../../infra/envs/play/terraform-play.tfvars -compact-warnings -auto-approve

