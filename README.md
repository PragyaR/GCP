# GCP

## Pre-req and installation on Windows
1. Google Cloud Account having one Project with Owner permission.
2. Install terraform
3. Install Git
4. Install and verify gcloud CLI  
    - Install: ```choco install gcloudsdk -y```. Installs gcloud CLI, gsutil (CLI for GCS- Google Cloud Storage), bq (Big Query CLI).
    - Login: ```gcloud auth login --no-launch-browser``` and enter the verification code from browser
    - Set project: ```gcloud config set project <PROJECT_ID>```
    - Set region: ```gcloud config set run/region us-central1```

## Common Commands
- ```gcloud projects list```
- ```gcloud iam service-accounts list```
- ```gcloud config get-value project```
- ```gcloud auth application-default revoke```