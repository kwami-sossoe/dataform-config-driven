env=dev
tf_folder=infra

rm -rf ./${tf_folder}/bootstrap/.terraform/terraform.tfstate ./${tf_folder}/bootstrap/.terraform.lock.hcl 
rm -rf ./${tf_folder}/bootstrap/.terraform ./${tf_folder}/bootstrap/.terraform.lock.hcl 


# tf fmt
terraform -chdir=./${tf_folder}/bootstrap fmt 
terraform -chdir=./${tf_folder}/environments/${env} fmt 


# tf init
terraform -chdir=./${tf_folder}/bootstrap init -backend-config=../../${tf_folder}/environments/${env}/tf-backend-${env}.conf


# tf validate and plan
terraform -chdir=./${tf_folder}/bootstrap validate 

terraform -chdir=./${tf_folder}/bootstrap plan -var-file=../../${tf_folder}/environments/${env}/terraform-${env}.tfvars -compact-warnings


# tf apply
# terraform -chdir=./${tf_folder}/bootstrap apply -var-file=../../${tf_folder}/environments/${env}/terraform-${env}.tfvars -compact-warnings

terraform -chdir=./${tf_folder}/bootstrap apply -var-file=../../${tf_folder}/environments/${env}/terraform-${env}.tfvars -compact-warnings -auto-approve


# tf destroy 
terraform -chdir=./${tf_folder}/bootstrap destroy -var-file=../../${tf_folder}/environments/${env}/terraform-${env}.tfvars -compact-warnings

terraform -chdir=./${tf_folder}/bootstrap state rm google_service_account.workflows_sa

terraform -chdir=./${tf_folder}/bootstrap state list | grep workflows_sa


cd infra/bootstrap

terraform init -backend-config=../../infra/environments/dev/tf-backend-dev.conf


terraform apply -var-file=../../infra/environments/dev/terraform-dev.tfvars -compact-warnings -auto-approve


terraform -chdir=./${tf_folder}/bootstrap import -var-file=../../${tf_folder}/environments/${env}/terraform-${env}.tfvars google_cloudbuildv2_connection.github_connection projects/itg-data-solutions-fabric-dv/locations/europe-west1/connections/infra-repo-connection



terraform -chdir=./${tf_folder}/bootstrap import -var-file=../../${tf_folder}/environments/${env}/terraform-${env}.tfvars google_cloudbuild_trigger.infra_deploy projects/itg-data-solutions-fabric-dv/locations/europe-west1/triggers/054cdcb3-24c7-450b-95eb-af85b3f07882





gcloud iam service-accounts add-iam-policy-binding \
  custom-dataform-sa-dev@itg-data-solutions-fabric-dv.iam.gserviceaccount.com \
  --member="user:devops.iac@skwailab.com" \
  --role="roles/iam.serviceAccountUser"


gcloud iam service-accounts add-iam-policy-binding \
  custom-dataform-sa-dev@itg-data-solutions-fabric-dv.iam.gserviceaccount.com \
  --member="user:kwami.sossoe@gmail.com" \
  --role="roles/iam.serviceAccountUser"


find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.css" -o -name "*.json" -o -name "*.yaml" -o -name "*.txt" -o -name "*.yml" -o -name "Dockerfile" \) \
-exec sh -c '
    for file in "$@"; do
        echo "--- FILE: ${file} ---"
        cat "${file}"
        echo
    done
' _ {} + > ../all_code_filtered.txt
