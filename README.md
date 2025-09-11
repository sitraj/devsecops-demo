# DevSecOps Demo Project

A comprehensive DevSecOps demonstration project showcasing security scanning, infrastructure as code, containerization, and policy enforcement across the entire development lifecycle.

## 🏗️ Project Overview

This project demonstrates a complete DevSecOps pipeline with:
- **Application**: Node.js web service with SQLite database
- **Infrastructure**: AWS S3 bucket with modern Terraform configuration
- **Containerization**: Docker with multi-stage builds
- **Orchestration**: Kubernetes deployment manifests
- **Security Scanning**: Multiple security tools integrated
- **Policy Enforcement**: Rego policies for infrastructure compliance
- **CI/CD Integration**: Automated security validation with AWS credentials

## 📁 Project Structure

```
devsecops-demo/
├── app/                    # Node.js application
│   ├── index.js           # Main application file
│   ├── package.json       # Node.js dependencies
│   └── package-lock.json  # Locked dependencies
├── infra/                 # Infrastructure as Code
│   └── terraform/         # Terraform configuration
│       ├── main.tf        # AWS S3 bucket resources (modern structure)
│       └── *.tfstate      # Terraform state files
├── k8s/                   # Kubernetes manifests
│   ├── deployment.yaml    # Application deployment
│   ├── service.yaml       # Service configuration
│   └── kind-config.yaml   # Local cluster config
├── policy/                # Security policies (Rego)
│   ├── s3.rego           # S3 security policies
│   ├── ec2.rego          # EC2 security policies
│   ├── iam.rego          # IAM security policies
│   ├── encryption.rego   # Encryption policies
│   ├── networking.rego   # Networking policies
│   └── logging.rego      # Logging policies
├── .github/workflows/     # CI/CD pipelines
│   └── ci.yml            # Main security & build pipeline
├── Dockerfile            # Container definition
└── .gitignore           # Git ignore rules
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- Docker
- Terraform
- Kubernetes (kind recommended)
- Conftest (for policy testing)
- AWS CLI (for local Terraform operations)

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/sitraj/devsecops-demo.git
   cd devsecops-demo
   ```

2. **Run the application locally**
   ```bash
   cd app
   npm install
   npm start
   ```
   Visit: http://localhost:3000

3. **Test with Docker**
   ```bash
   docker build -t devsecops-demo .
   docker run -p 3000:3000 devsecops-demo
   ```

4. **Deploy to Kubernetes (kind)**
   ```bash
   # Create kind cluster
   kind create cluster --config k8s/kind-config.yaml
   
   # Deploy application
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   
   # Access application
   kubectl port-forward service/devsecops-demo-service 8080:80
   ```
   Visit: http://localhost:8080

## 🔒 Security Features

### 1. Code Security Scanning
- **Semgrep**: Static analysis for code vulnerabilities
- **Trivy**: Dependency vulnerability scanning
- **SARIF Integration**: Results uploaded to GitHub Security tab

### 2. Infrastructure Security
- **tfsec**: Terraform security scanner
- **Checkov**: Infrastructure as Code security analysis
- **Conftest**: Policy enforcement with Rego
- **Automated Policy Validation**: CI/CD integration with Terraform plans

### 3. Container Security
- **Trivy Image Scan**: Container vulnerability scanning
- **Multi-stage Docker builds**: Optimized container images
- **Non-root user**: Security best practices

### 4. Policy Enforcement
Comprehensive Rego policies covering:

#### S3 Security (`s3.rego`)
- ❌ Public S3 buckets (`aws_s3_bucket_acl` with `acl = "public-read"`)
- ❌ Legacy public S3 buckets (backward compatibility)
- ✅ **Fixed**: S3 bucket now uses private ACL

#### EC2 Security (`ec2.rego`)
- ❌ Security groups allowing SSH from anywhere (0.0.0.0/0:22)
- ❌ Security groups allowing RDP from anywhere (0.0.0.0/0:3389)
- ❌ EC2 instances with unencrypted EBS volumes

#### IAM Security (`iam.rego`)
- ❌ Overly permissive IAM policies (`Action: *, Resource: *`)
- ❌ IAM users/roles with AdministratorAccess

#### Encryption (`encryption.rego`)
- ❌ S3 buckets without server-side encryption
- ❌ RDS instances without encryption
- ❌ EBS volumes without encryption
- ❌ Weak encryption algorithms
- ✅ **Fixed**: S3 bucket now has AES256 encryption enabled

#### Networking (`networking.rego`)
- ❌ VPCs without DNS hostnames enabled
- ❌ Subnets without proper tagging
- ❌ Load balancers using HTTP instead of HTTPS

#### Logging (`logging.rego`)
- ❌ CloudTrail without logging enabled
- ❌ CloudWatch log groups without retention
- ✅ **Note**: S3 logging requirement removed (not mandatory for demo)

## 🛠️ Usage Examples

### Application Endpoints

The Node.js application provides several endpoints:

- **GET /** - Usage instructions and examples
- **GET /users** - Get all users from database
- **GET /query** - Custom SQL queries with parameters

#### Example Queries

```bash
# Get all users
curl http://localhost:3000/users

# Get users older than 25
curl "http://localhost:3000/query?condition=age>25"

# Get specific columns
curl "http://localhost:3000/query?column=name,email&condition=age>25"

# Get users with specific email
curl "http://localhost:3000/query?condition=email='john@example.com'"
```

### Policy Testing

Test infrastructure policies with Conftest:

```bash
# Test all policies
conftest test infra/terraform/tfplan.json -p policy/ --all-namespaces

# Test specific policy category
conftest test infra/terraform/tfplan.json -p policy/ --namespace s3
conftest test infra/terraform/tfplan.json -p policy/ --namespace ec2
conftest test infra/terraform/tfplan.json -p policy/ --namespace iam
```

### Infrastructure Deployment

Deploy AWS infrastructure with Terraform:

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

**Note**: Ensure AWS credentials are configured locally:
```bash
aws configure
# or set environment variables:
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-1
```

## 🔄 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/ci.yml`) includes:

### Security Scanning Jobs
1. **Code Security Scan**
   - Semgrep static analysis
   - SARIF report upload to GitHub Security

2. **Dependency Scan**
   - Trivy filesystem scan
   - Vulnerability detection in dependencies

3. **Infrastructure Scan**
   - tfsec Terraform security analysis
   - Checkov IaC security scanning
   - SARIF report upload

4. **Policy Enforcement**
   - Conftest policy validation against Terraform plan
   - Custom Rego policies for infrastructure compliance
   - Terraform plan generation and JSON conversion
   - AWS credentials configuration for plan generation
   - Policy validation before infrastructure deployment

5. **Container Security**
   - Trivy image vulnerability scan
   - Pre-push security validation

### Build & Deploy
- **Security Gates**: All security scans must pass before build
- **Docker Image**: Build and push to GHCR only after policy validation
- **Container Registry**: Automated deployment with security validation
- **Dependencies**: Waits for code scan, dependency scan, infrastructure scan, and policy enforcement
- **AWS Integration**: Terraform plans generated with proper AWS credentials

## 🐳 Container Registry

Images are automatically built and pushed to GitHub Container Registry:
- **Registry**: `ghcr.io/sitraj/devsecops-demo`
- **Tag**: `latest`
- **Security**: Pre-scan validation required

## 📊 Security Dashboard

All security scan results are automatically uploaded to:
- **GitHub Security Tab**: Centralized security findings
- **SARIF Format**: Standardized security reports
- **Artifacts**: Detailed scan reports for analysis

## 🚨 Current Security Issues

The project includes some security issues for demonstration:

1. **SQL Injection**: Concatenated SQL queries in application
2. **CORS**: Wildcard origin policy
3. **Dependencies**: Potential vulnerabilities in Node.js packages

**Note**: Infrastructure security issues have been resolved:
- ✅ S3 bucket ACL changed from public to private
- ✅ Server-side encryption enabled
- ✅ S3 logging requirement removed (not mandatory for demo)

These remaining issues are detected by the security scanning pipeline and should be addressed in a real-world scenario.

## 🛡️ Security Best Practices Demonstrated

- **Shift Left Security**: Security scanning in CI/CD pipeline
- **Policy as Code**: Infrastructure compliance with Rego
- **Automated Policy Enforcement**: Conftest validation in CI/CD
- **Container Security**: Image vulnerability scanning
- **Dependency Management**: Automated vulnerability detection
- **Infrastructure Scanning**: IaC security analysis
- **Security Gates**: Build prevention on policy violations
- **SARIF Integration**: Standardized security reporting
- **Modern Terraform**: Updated to use current AWS provider best practices
- **Credential Management**: Secure AWS credential handling in CI/CD

## 🔧 Development

### Adding New Policies

1. Create a new `.rego` file in the `policy/` directory
2. Define the package name (e.g., `package mypolicy`)
3. Add deny rules for security violations
4. Test with: `conftest test tfplan.json -p policy/ --namespace mypolicy`

### Adding New Security Scans

1. Add new job to `.github/workflows/ci.yml`
2. Configure appropriate security tool
3. Upload SARIF reports to GitHub Security tab
4. Add security gates to build process
5. Update `build-and-push` job dependencies if needed

### Policy Enforcement in CI/CD

The `iac-policy` job automatically:
1. Sets up Terraform and Conftest
2. Configures AWS credentials for plan generation
3. Generates Terraform plan with proper AWS authentication
4. Converts plan to JSON format
5. Runs all Rego policies against the plan
6. Fails the pipeline if policies are violated

### Required GitHub Secrets

For the CI/CD pipeline to work properly, add these secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key
- `GHCR_PAT`: GitHub Container Registry personal access token

## 📝 License

This project is for educational and demonstration purposes.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all security scans pass
5. Submit a pull request

## 📚 Resources

- [Semgrep Documentation](https://semgrep.dev/docs/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Conftest Documentation](https://www.conftest.dev/)
- [Rego Policy Language](https://www.openpolicyagent.org/docs/latest/policy-language/)
- [Terraform Security](https://www.terraform.io/docs/cloud/guides/security.html)
