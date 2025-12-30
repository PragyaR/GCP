# GCP SRE PLATFORM DEMO PROJECT

## Setup
1. From gcloud CLI, enable Services: ```gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com monitoring.googleapis.com logging.googleapis.com cloudresourcemanager.googleapis.com serviceusage.googleapis.com iam.googleapis.com compute.googleapis.com```
2. terraform init
3. Create "demo-ci-cd-sa" service account on GCP with Cloud Run Admin and Artifact Registry Create-on-Push Writer permissions.
4. To use OIDC authn from GitHub action pipeline,
    - Create Workload Identity Pool:   
    ```gcloud iam workload-identity-pools create github-pool --project="<PROJECT_ID>" --location="global" --display-name="GitHub Actions Pool"```
    - Create a Provider   
    ```gcloud iam workload-identity-pools providers create-oidc github-provider --project="<PROJECT_ID>" --location=global --workload-identity-pool=<WORKLOAD_IDENTITY_POOL_NAME> --display-name="GitHub OIDC Provider" --issuer-uri="https://token.actions.githubusercontent.com" --attribute-mapping="google.subject=assertion.sub, attribute.repository=assertion.repository, attribute.ref=assertion.ref" --attribute-condition="attribute.repository=='<GITHUB_USERNAME>/<REPO_NAME>' && attribute.ref=='refs/heads/main'"```
    - Bind provider to service account   
    ```gcloud iam service-accounts add-iam-policy-binding <SA_NAME>@<PROJECT_ID>.iam.gserviceaccount.com --role="roles/iam.workloadIdentityUser" --member="principalSet://iam.googleapis.com/projects/<PROJECT_NUMBER>/locations/global/workloadIdentityPools/<WORKLOAD_IDENTITY_POOL_NAME>/attribute.repository/<GITHUB_USERNAME>/<REPO_NAME>"```
5. Before running the terraform plan, set the GCP Application Default Credential (ADC). The file is stored at "%APPDATA%\gcloud\application_default_credentials.json":    
```gcloud auth application-default login --no-launch-browser```
6. Before apply, set Quota project for billing: ```gcloud auth application-default set-quota-project <PROJECT_ID>``` or ```$env:GOOGLE_CLOUD_QUOTA_PROJECT=<PROJECT_ID>```
7. Post apply, run to verify what was created: ```terraform state list```

## Running the app
1. Ensure the docker image is deployed via the ci-cd pipeline and cloud run app is deployed via terraform.
2. Get the service URL by running: ```gcloud run services describe demo-api```
3. 


