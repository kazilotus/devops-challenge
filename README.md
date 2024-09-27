# Bird Application

This is the bird Application! It gives us birds!!!

The app is written in Golang and contains 2 APIs:
- the bird API
- the birdImage API

When you run the application (figure it out), you will see the relationship between those 2 APIs.

# installation & how to run it

Find it

# Challenge

How to:
- fork the repository
- work on the challenges
- share your repository link with the recruitment team

Here are the challenges:
- Install and run the app
- Dockerize it (create dockerfile for each API)
- Create an infra on AWS (VPC, SG, instances) using IaC
- Install a small version of kubernetes on the instances (no EKS)
- Build the manifests to run the 2 APIs on k8s 
- Bonus points: observability, helm, scaling

Rules:
- Use security / container / k8s / cloud best practices
- Change in the source code is possible

Evaluation criterias:
- best practices
- code organization
- clarity & readability


# Solution

## Live Link
http://staging-devops-ingress-nlb-38d45003f97243d4.elb.us-east-1.amazonaws.com/

The solution I implemented follows best practices in terms of infrastructure, security, and deployment while being flexible and multi-environment ready.

## Modifications Made
- **Environment Variables**: Updated the source code to take constants and variables from environment variables.
- **Dockerization**: Created Dockerfiles for both APIs and tested them by running both services together using Docker Compose.

## Infrastructure-as-Code (IaC) and Architecture
The infrastructure is built using Terraform for provisioning on AWS. Here's an outline of the key components:

### VPC
- A custom VPC with a `/20` CIDR block.
- **Subnets**: 3 public and 3 private subnets spread across different availability zones.
- **Internet Gateway**: Connected to the public subnets.
- **NAT Gateway**: For routing traffic from private subnets to the Internet.
- **Security Groups**: Configured for secure access, limiting SSH to the bastion server and allowing k3s-related traffic between nodes.

### EC2 Instances for K3s Cluster
- **Master Node**:
  - Single EC2 instance deployed via a Launch Template with a user data script to:
    - Install k3s.
    - Store the k3s token in AWS SSM Parameter Store.
    - Authenticate to AWS ECR for pulling container images.
    - Install Argo CD and configure it to deploy from this GitHub repository's helm chart, listening to the appropriate branch based on the environment.

- **Worker Nodes**:
  - Autoscaling Group of EC2 instances using a separate Launch Template.
  - User data for workers fetches the k3s token from Parameter Store and joins the master node using its private IP.
  - The worker node retries to connect for up to an hour in case the master is delayed.

### Bastion Host
A bastion server was deployed manually in the public subnet for development and secure SSH access to the cluster nodes. The SSH access is restricted to within the VPC only.

### Kubernetes (K3s) Setup
- K3s is used for lightweight Kubernetes.
- **Master node** handles control-plane operations, while worker nodes scale dynamically using the autoscaler.
- **Argo CD** is installed on the master node to automatically manage the GitOps workflow for the cluster.

### Continuous Deployment
A **GitHub Action pipeline** is set up to build Docker images for each app (Bird and BirdImage) whenever changes are detected in the `apps` directory. The pipeline pushes the images to AWS ECR.

### Helm Chart
The deployment is managed using Helm with the following features:
- Multi-environment support (staging, production) through `values.yaml`.
- **Services**: Kubernetes services and Ingress for exposing APIs.
- **Nginx Ingress**: Configured to listen on a NodePort, routing traffic for the Bird API.
- The Bird API internally calls the BirdImage API via a Kubernetes Service.

### Network Load Balancer (NLB)
A Network Load Balancer (NLB) is deployed in the public subnet to forward HTTP traffic to the Kubernetes NodePort.
- The NLB target group distributes traffic across both master and worker nodes.
- HTTP requests to the Bird API are routed through this load balancer.

### Dynamic and Configurable Infrastructure
- **Terraform Code**: All variables are centralized in a single YAML file, making the infrastructure easily configurable for different environments.
- **Helm**: The Helm chart takes all required variables from `values.yaml`, ensuring consistent deployment across environments.