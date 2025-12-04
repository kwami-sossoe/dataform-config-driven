PROJECT_ID=itg-data-solutions-fabric-dv

gcloud auth configure-docker europe-west1-docker.pkg.dev

cd apps/off-extractor

docker build -t europe-west1-docker.pkg.dev/${PROJECT_ID}/data-services/off-extractor:latest .

docker push europe-west1-docker.pkg.dev/${PROJECT_ID}/data-services/off-extractor:latest


gcloud run deploy off-extractor-service \
  --image europe-west1-docker.pkg.dev/${PROJECT_ID}/data-services/off-extractor:latest \
  --region europe-west1







SEED_PROJECT_ID="cloud-insights-data-lab"
cd apps/off-extractor

docker build -t europe-west1-docker.pkg.dev/${SEED_PROJECT_ID}/cn-services/off-extractor:latest .

docker push europe-west1-docker.pkg.dev/${SEED_PROJECT_ID}/cn-services/off-extractor:latest




docker build -t europe-west1-docker.pkg.dev/cloud-insights-ops-play/cn-services2/off-extractor:latest .

docker push europe-west1-docker.pkg.dev/cloud-insights-ops-play/cn-services2/off-extractor:latest