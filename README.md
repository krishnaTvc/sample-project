# Sample Project - Automated S3 Static Website Deployment

This project contains a simple web application (`index.html`) deployed to **AWS S3 Static Website Hosting** using **Terraform** and **GitHub Actions** with **OIDC Authentication** (passwordless, secure authentication).

---

## 🏗️ Architecture Overview

```
┌────────────────────────┐      OIDC Token      ┌────────────────────────┐
│  GitHub Actions CI/CD  │ ───────────────────> │  AWS IAM Role (OIDC)   │
└───────────┬────────────┘                      └───────────┬────────────┘
            │                                               │
            │  1. terraform init / plan / apply             │ 2. Assumes Role
            ▼                                               ▼
┌────────────────────────────────────────────────────────────────────────┐
│                          AWS S3 Static Website                         │
│                    (Hosts index.html with public access)              │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Step-by-Step Setup Instructions

### Phase 1: AWS Console Configuration (IAM OIDC & Role)

#### Step 1: Create GitHub OIDC Provider in AWS IAM
1. Log into your **AWS Management Console**.
2. Search for **IAM** in the top search bar and open the IAM Dashboard.
3. In the left menu, click **Identity providers** -> click **Add provider**.
4. Select **OpenID Connect**.
5. Fill in the provider details:
   - **Provider URL**: `https://token.actions.githubusercontent.com` *(Click "Get thumbprint")*
   - **Audience**: `sts.amazonaws.com`
6. Click **Add provider**.

---

#### Step 2: Create IAM Role for GitHub Actions
1. In the IAM left menu, click **Roles** -> click **Create role**.
2. Select **Web identity**.
3. Under **Identity provider**, select `token.actions.githubusercontent.com`.
4. Under **Audience**, select `sts.amazonaws.com`.
5. Under **GitHub organization**, enter your GitHub username (e.g., `YourGitHubUsername`).
6. *(Optional)* Enter repository name `sample-project` and branch `main`.
7. Click **Next**.

---

#### Step 3: Attach IAM Permissions
1. Search for and attach the following managed policy (or create a custom S3 policy):
   - **`AmazonS3FullAccess`** *(allows creating and configuring the S3 bucket & website settings)*
2. Click **Next**.
3. Name the Role: `GitHubActions-S3-Deployer-Role`.
4. Click **Create role**.
5. Copy the **Role ARN** (e.g., `arn:aws:iam::123456789012:role/GitHubActions-S3-Deployer-Role`). You will need this for GitHub settings.

---

#### Step 4: Verify the IAM Role Trust Policy
Open your created role in AWS IAM Console, click the **Trust relationships** tab, and verify the policy matches:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<YOUR_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<YOUR_GITHUB_USERNAME>/sample-project:*"
        }
      }
    }
  ]
}
```

---

### Phase 2: GitHub Repository Setup & Push

#### Step 1: Create a GitHub Repository
1. Go to [GitHub New Repository](https://github.com/new).
2. Set Repository name: **`sample-project`**.
3. Choose **Public** or **Private**.
4. Do **NOT** initialize with README, .gitignore, or license (we already have them locally).
5. Click **Create repository**.

---

#### Step 2: Push Local Code to GitHub
Run the following commands in your local `sample-project` directory terminal:

```bash
git init -b main
git add .
git commit -m "Initial commit: S3 static site Terraform deployment pipeline"
git remote add origin https://github.com/<YOUR_GITHUB_USERNAME>/sample-project.git
git push -u origin main
```

---

### Phase 3: Add GitHub Repository Variables

1. Go to your GitHub repository on github.com.
2. Click **Settings** -> Expand **Secrets and variables** -> Click **Actions**.
3. Click the **Variables** tab (next to Secrets) -> Click **New repository variable**.
4. Add the following two variables:

| Variable Name | Example Value | Description |
| :--- | :--- | :--- |
| `AWS_ROLE_ARN` | `arn:aws:iam::123456789012:role/GitHubActions-S3-Deployer-Role` | The Role ARN created in Phase 1 |
| `AWS_REGION` | `us-east-1` | AWS Region where the S3 bucket will be created |

---

### Phase 4: Trigger Pipeline & Verify Deployment

1. Go to the **Actions** tab in your GitHub repository.
2. Click on the **Deploy Sample Project via Terraform** workflow.
3. You can click **Run workflow** -> Select `main` branch -> Click **Run workflow** (or simply push a new commit to `main`).
4. Watch the pipeline execution:
   - `Configure AWS Credentials via OIDC`
   - `Terraform Init` & `Validate`
   - `Terraform Plan`
   - `Terraform Apply`
5. At the end of the `Output Website URL` step, copy the S3 website URL output (e.g., `http://sample-project-dev-a1b2c3d4.s3-website-us-east-1.amazonaws.com`) and open it in your browser to view your live website! 🎉

---

## 🛠️ Local Project Structure

```
sample-project/
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions CI/CD workflow with OIDC
├── .gitignore               # Ignores local terraform state & binaries
├── index.html               # Web application source file
├── main.tf                  # S3 bucket, website config, policy & object resource definitions
├── outputs.tf               # Exports live website URL and bucket name
├── provider.tf              # AWS & Random providers configuration
├── README.md                # Project documentation and setup guide
└── variables.tf             # Input variables (aws_region, app_name, environment)
```
