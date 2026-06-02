# High-Availability AWS 3-Tier Architecture via Terraform

## Project Overview
This project provisions a secure, highly available, and scalable **AWS 3-Tier Web Architecture** entirely as Infrastructure as Code (IaC) using Terraform. 

The design pattern isolates each tier into distinct subnets across multiple Availability Zones (AZs) to ensure resilience, fault tolerance, and zero single points of failure.

### Key Architecture Highlights:
* **Presentation Tier:** Public subnets hosting an internet-facing Application Load Balancer (ALB).
* **Application Tier:** Private subnets containing a dynamic EC2 Auto Scaling Group (ASG) protected from direct public access.
* **Data Tier:** Fully isolated private subnets hosting a Multi-AZ Amazon RDS MySQL cluster.

---

## Architecture Diagram
![AWS 3-Tier Architecture Diagram](images/architecture-diagram.png)

---

## AWS Services & Terraform Features Used

* **Networking:** VPC, Public/Private Subnets (2x each across 2 AZs), Internet Gateway (IGW), NAT Gateway, Route Tables.
* **Compute & Scaling:** EC2, Launch Templates, Auto Scaling Group (ASG), Application Load Balancer (ALB).
* **Database:** Amazon RDS MySQL with automated storage autoscaling.
* **Security:** Layered Security Groups forming a strict **Chain Link Security** mechanism (ALB ➔ EC2 ➔ RDS).
* **HCL Concepts:** `count` meta-arguments, dynamic data sources (`aws_availability_zones`), explicit dependencies (`depends_on`), and input variable abstraction.

---

##  How to Deploy This Infrastructure

### 1. Prerequisites
* [Terraform CLI](https://developer.hashicorp.com/terraform/install) installed locally (v1.15.x+).
* [AWS CLI](https://aws.amazon.com/cli/) configured with valid IAM administrative credentials.

### 2. Deployment Steps
Clone the repository and initialize the working directory:
```bash
git clone [https://github.com/YOUR_GITHUB_USERNAME/aws-3-tier-project.git](https://github.com/YOUR_GITHUB_USERNAME/aws-3-tier-project.git)
cd aws-3-tier-project
terraform init