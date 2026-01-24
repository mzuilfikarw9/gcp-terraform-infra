# 1. Login if you haven't already
gcloud auth login

# 2. Set your current project
gcloud config set project my-company-sit-platform

##Terraform uses your "Application Default Credentials" (ADC) to authenticate. Currently, your local credential file is stamped with an old project ID. If you run Terraform now, it might try to bill/quota the wrong project.##
Run this command to fix it:
gcloud auth application-default set-quota-project my-company-sit-platform

If looks like the authentication process was interrupted or the permissions were not fully granted on the consent screen
Force Clean Login (No Browser)
# gcloud auth application-default login --no-browser --scopes=https://www.googleapis.com/auth/cloud-platform #
It will print a long URL starting with https://accounts.google.com/...

# Copy that full URL and paste it into your web browser.
Log in with your account.
CRITICAL: When asked for permission, you MUST check the box that says:

"See, edit, configure, and delete your Google Cloud Platform data"

It will give you a code. Copy the code and paste it back into your terminal prompt.

Step 2: Set the Quota Project Again
Once the login succeeds (it will say Credentials saved to file...), run the command that failed earlier:

## gcloud auth application-default set-quota-project my-company-sit-platform ##

Step 3: Resume Infrastructure Build
Now you can create the bucket and run Terraform:
# 1. Create Bucket
gcloud storage buckets create gs://tf-state-my-company-sit \
    --project=my-company-sit-platform \
    --location=asia-southeast1 \
    --uniform-bucket-level-access

# 2. Run Terraform
terraform init


