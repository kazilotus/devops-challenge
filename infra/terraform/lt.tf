# ==============================================================================
# EC2 Launch Template for K3s Master Node (Private Subnet)
# ==============================================================================
resource "aws_launch_template" "k3s_master_launch_template" {
  name_prefix   = "${local.env}-${local.project}-k3s-master"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = local.k3s_config["instance_type"]
  key_name      = aws_key_pair.k3s_key_pair.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.k3s_profile.name
  }
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  user_data = base64encode(<<-EOT
    #!/bin/bash

    # Define Variables
    K3S_TOKEN_PATH="/var/lib/rancher/k3s/server/node-token"
    KUBECONFIG_PATH="/etc/rancher/k3s/k3s.yaml"

    SSM_PARAMETER_NAME="/k3s/${local.env}-${local.project}/token"

    ACCOUNT_ID=${data.aws_caller_identity.current.account_id}
    REGION=${local.global_config.region}

    ARGOCD_NAMESPACE="argocd"
    ARGOCD_VERSION="v2.12.3"
    ARGOCD_MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/$${ARGOCD_VERSION}/manifests/core-install.yaml"
    ARGOCD_CLI_URL="https://github.com/argoproj/argo-cd/releases/download/$${ARGOCD_VERSION}/argocd-linux-amd64"
    ARGOCD_CLI_PATH="/usr/local/bin/argocd"

    GITHUB_REPO_URL="https://github.com/kazilotus/devops-challenge"
    HELM_PATH="helm"
    SYNC_POLICY="automated"

    # Set Branch based on environment
    if [ "${local.env}" = "staging" ]; then
      BRANCH="stage"
    fi

    if [ "${local.env}" = "production" ]; then
      BRANCH="main"
    fi

    # Install AWS CLI
    sudo apt update
    sudo apt install -y awscli

    # Install K3s
    curl -sfL https://get.k3s.io | sh -
    K3S_TOKEN=$(sudo cat $K3S_TOKEN_PATH)
    aws ssm put-parameter --name "$SSM_PARAMETER_NAME" --value "$K3S_TOKEN" --type "SecureString" --overwrite --region "$REGION"

    # Auth ECR
    sudo kubectl -n default create secret docker-registry ecr-registry-secret \
    --docker-server=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com \
    --docker-username=AWS \
    --docker-password=$(aws ecr get-login-password --region $REGION)
    sudo kubectl create serviceaccount default -n default
    sudo kubectl patch serviceaccount default -n default -p '{"imagePullSecrets": [{"name": "ecr-registry-secret"}], "automountServiceAccountToken":true}'

    # Install Argo CD
    sudo kubectl create namespace $ARGOCD_NAMESPACE
    sudo kubectl apply -n $ARGOCD_NAMESPACE -f $ARGOCD_MANIFEST_URL
    sudo curl -sSL -o $ARGOCD_CLI_PATH $ARGOCD_CLI_URL
    sudo chmod +x $ARGOCD_CLI_PATH
    sudo kubectl wait --for=condition=available --timeout=600s -n $ARGOCD_NAMESPACE deployment/argocd-repo-server
    sudo kubectl config set-context --current --namespace=argocd

    # Set up Argo CD Application using appropriate branch
    sudo KUBECONFIG=$KUBECONFIG_PATH argocd login --core
    sudo KUBECONFIG=$KUBECONFIG_PATH argocd app create argo-devops \
      --repo $GITHUB_REPO_URL \
      --revision $BRANCH \
      --path $HELM_PATH  \
      --project default \
      --dest-namespace default \
      --dest-server https://kubernetes.default.svc \
      --sync-policy $SYNC_POLICY \
      --sync-option Prune=true \
      --sync-option SelfHeal=true \
      --values ${local.env}.values.yaml \
      --upsert

    sudo kubectl wait --for=condition=Available --timeout=600s -n $ARGOCD_NAMESPACE app/argo-devops
  EOT
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = local.k3s_config["ebs_volume_size"]
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.env}-${local.project}-k3s-master"
    })
  }
}

# ==============================================================================
# Auto Scaling Group for K3s Worker Nodes (Private Subnet)
# ==============================================================================
resource "aws_launch_template" "k3s_worker_launch_template" {
  name_prefix   = "${local.env}-${local.project}-k3s-worker"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = local.k3s_config["instance_type"]
  key_name      = aws_key_pair.k3s_key_pair.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.k3s_profile.name
  }
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  user_data = base64encode(<<-EOT
    #!/bin/bash

    # Install AWS CLI
    sudo apt update
    sudo apt install -y awscli

    # Define the maximum number of retries and delay between retries (1 minute)
    MAX_RETRIES=60
    RETRY_INTERVAL=60

    # Fetch the region from the environment
    REGION=${local.config["global"]["region"]}
    SSM_PARAMETER_NAME="/k3s/${local.env}-${local.project}/token"

    # Function to retrieve the K3S token from SSM Parameter Store
    fetch_k3s_token() {
      aws ssm get-parameter --name "$SSM_PARAMETER_NAME" --region "$REGION" --with-decryption --query "Parameter.Value" --output text 2>/dev/null || echo ""
    }

    # Retry loop to fetch the K3S token
    for ((i=1; i<=$MAX_RETRIES; i++)); do
        echo "Attempt $i: Fetching K3S token from SSM..."
        K3S_TOKEN=$(fetch_k3s_token)

        if [ -n "$K3S_TOKEN" ]; then
            echo "K3S token found!"
            break
        else
            echo "K3S token not found, retrying in $RETRY_INTERVAL seconds..."
            sleep $RETRY_INTERVAL
        fi
    done

    if [ -z "$K3S_TOKEN" ]; then
        echo "Failed to retrieve K3S token after $MAX_RETRIES attempts."
        exit 1
    fi

    # Join the K3s cluster using the EIP of the Master Node
    K3S_URL=https://${aws_instance.k3s_master.private_dns}:6443
    curl -sfL https://get.k3s.io | K3S_TOKEN=$K3S_TOKEN K3S_URL=$K3S_URL sh -s - agent
  EOT
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = local.k3s_config["ebs_volume_size"]
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.env}-${local.project}-k3s-worker"
    })
  }
}