# GCP SRE PLATFORM DEMO PROJECT

## Pre-req and installation on Windows
1. Google Cloud Account having one Project with Owner permission.
2. Install terraform
3. Install Git
4. Install and verify gcloud CLI  
    - Install: ```choco install gcloudsdk -y```. Installs gcloud CLI, gsutil (CLI for GCS- Google Cloud Storage), bq (Big Query CLI).
    - Login: ```gcloud auth login --no-launch-browser``` and enter the verification code from browser
    - Set project: ```gcloud config set project <PROJECT_ID>```
    - Set region: ```gcloud config set run/region us-central1```
5. Install TFLint to catch any semantic errors (Optional)
    - Run ```choco install tflint``` to install
    - Run ```tflint --version``` to verify the installation


## App setup
1. From gcloud CLI, enable Services: ```gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com monitoring.googleapis.com logging.googleapis.com cloudresourcemanager.googleapis.com serviceusage.googleapis.com iam.googleapis.com compute.googleapis.com```
2. Run ```terraform init``` and ```tflint --init```
3. Create "demo-ci-cd-sa" service account on GCP with Cloud Run Admin and Artifact Registry Create-on-Push Writer permissions.
4. For GitHub Actoin pipeline to push docker image to GCP using OIDC authn, do the following - 
    - Create Workload Identity Pool:   
    ```gcloud iam workload-identity-pools create github-pool --project="<PROJECT_ID>" --location="global" --display-name="GitHub Actions Pool"```
    - Create a Provider   
    ```gcloud iam workload-identity-pools providers create-oidc github-provider --project="<PROJECT_ID>" --location=global --workload-identity-pool=<WORKLOAD_IDENTITY_POOL_NAME> --display-name="GitHub OIDC Provider" --issuer-uri="https://token.actions.githubusercontent.com" --attribute-mapping="google.subject=assertion.sub, attribute.repository=assertion.repository, attribute.ref=assertion.ref" --attribute-condition="attribute.repository=='<GITHUB_USERNAME>/<REPO_NAME>' && attribute.ref=='refs/heads/main'"```
    - Bind provider to service account   
    ```gcloud iam service-accounts add-iam-policy-binding <SA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com --role="roles/iam.workloadIdentityUser" --member="principalSet://iam.googleapis.com/projects/<PROJECT_NUMBER>/locations/global/workloadIdentityPools/<WORKLOAD_IDENTITY_POOL_NAME>/attribute.repository/<GITHUB_USERNAME>/<REPO_NAME>"```
    - Workload Identity + OIDC is like a handshake: GitHub proves it’s running this workflow, GCP trusts it, and temporarily gives the workflow the identity of the service account. We can now safely push Docker images or deploy Cloud Run without ever storing a long-lived key.
5. Before running the terraform plan, set the GCP Application Default Credential (ADC). The file is stored at "%APPDATA%\gcloud\application_default_credentials.json":    
```gcloud auth application-default login --no-launch-browser```
6. Run ```terraform validate``` `, ```tflint``` and then ```terraform plan```.
6. Before apply, set Quota project for billing: ```gcloud auth application-default set-quota-project <PROJECT_ID>``` or ```$env:GOOGLE_CLOUD_QUOTA_PROJECT=<PROJECT_ID>```
7. Post apply, run to verify what was created: ```terraform state list```

## Running the app
1. Ensure the docker image is deployed via the ci-cd pipeline and cloud run app is deployed via terraform.
2. Get the service URL by running: ```gcloud run services describe demo-api```
3. Perform a curl on the service URL to verify the service is up and running.
4. Run the simulate-load.ps1 script from the scripts folder to simulate an app returning occasional errors. Check the metrics and logs on the portal.
5. To trigger alerts, temporarily increase the error rate for the api -  
```gcloud run services update demo-api --update-env-vars ERROR_RATE=0.5``` and execute   
```\simulate-load.ps1 -Requests 1000 -DelayMs 100 -ServiceUrl <service url>```

## Common Commands
- ```gcloud projects list```
- ```gcloud iam service-accounts list```
- ```gcloud config get-value project```
- ```gcloud auth application-default revoke```