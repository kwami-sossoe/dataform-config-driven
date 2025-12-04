# dataform-config-driven

### Requirements
```shell

# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 24

# Verify the Node.js version:
node -v # Should print "v24.11.1".

# Verify npm version:
npm -v # Should print "11.6.2".

```



### Dataform cli


```shell

# requires nodejs
npm i -g @dataform/cli

Run dataform compile from the root of your Dataform project to ensure that you are able to use the cli

Install gcloud cli and run

gcloud init

gcloud auth application-default login

 gcloud config set project <project_id> #replace with your gcp project id

To enable formatting using sqlfluff install sqlfluff

# install python and run
pip install sqlfluff

To enable prettier diagnostics install Error Lens extension [ optional ]

Git cli

```



npm init -y

npm install @dataform/core


```shell 
# outputs 


$ npm i -g @dataform/cli
npm warn deprecated google-p12-pem@3.1.4: Package is no longer maintained
npm warn deprecated vm2@3.9.19: The library contains critical security issues and should not be used for production! The maintenance of the project has been discontinued. Consider migrating your code to isolated-vm.

added 203 packages in 15s

32 packages are looking for funding
  run `npm fund` for details
npm notice
npm notice New patch version of npm available! 11.6.2 -> 11.6.4
npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.6.4
npm notice To update run: npm install -g npm@11.6.4
npm notice


```


# Initialize a new project in the current directory
$ dataform init . itg-data-solutions-fabric-dv europe-west1
Writing project files...

Directories successfully created:
  /home/operations/Documents/dev-cloudnative/use_case_studies/dataform-config-driven/definitions
  /home/operations/Documents/dev-cloudnative/use_case_studies/dataform-config-driven/includes
Files successfully written:
  /home/operations/Documents/dev-cloudnative/use_case_studies/dataform-config-driven/workflow_settings.yaml
  /home/operations/Documents/dev-cloudnative/use_case_studies/dataform-config-driven/.gitignore


  
# Install dependencies (packages defined in package.json)
npm install







# source table

# Télécharge les 100 premières lignes du dump officiel
curl -L https://static.openfoodfacts.org/data/openfoodfacts-products.jsonl.gz | zcat | head -n 1000 > extract.jsonl

project_id=itg-data-solutions-fabric-dv
off_lz_bucket=off-raw-landing-kss-id-dp-test

gsutil cp extract.jsonl gs://${off_lz_bucket}



bq load \
--source_format=NEWLINE_DELIMITED_JSON \
--json_extension=JSON \
--time_partitioning_type=DAY \
--time_partitioning_field=ingestion_date \
'itg-data-solutions-fabric-dv:off.off_raw_dump' \
gs://${off_lz_bucket}/extract.jsonl \
raw_json:JSON

