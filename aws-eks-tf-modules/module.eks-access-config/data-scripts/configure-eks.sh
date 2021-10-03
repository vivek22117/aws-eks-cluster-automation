#!/usr/bin/env bash


sudo yum update -y
sudo yum install wget unzip -y
sleep 5

sudo yum install jq -y
cd /tmp


if [ ${ami_filter_type}=='amazon' ]; then

  echo "Installing AWS CLI v2"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo  ./aws/install -i /usr/local/aws-cli -b /usr/local/bin

  echo "Install SSM-Agent"
  sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
  sudo systemctl enable amazon-ssm-agent
  sudo systemctl start amazon-ssm-agent


  echo "Installing Kubectl"
  # https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
  curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/${kubectl_version}/2021-01-05/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin

  kubectl version --short --client


  echo "Installing eksctl"
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  mv /tmp/eksctl /usr/local/bin


  echo "Install Terraform"
  wget https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip
  unzip terraform_${terraform_version}_linux_amd64.zip
  mv terraform /usr/local/bin/
  terraform version


  echo "Install HELM"
  curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
fi



function download_eks_auth() {
  echo ================== Download EKS auth config ===============================
  echo 'Applying Auth ConfigMap with kubectl...'
  sudo aws s3 cp s3://${artifactory_bucket_name}/deploy/eks/config-auth.yaml . --region ${default_region}

}

function create_credentials() {
  echo ================== Configure Credentials ===============================

  TEMP=$(aws sts assume-role --role-arn ${eks_create_role_arn} --role-session-name Cluster-Config)
  aws configure set profile.eks-creator.aws_access_key_id $(echo $TEMP | jq -r .Credentials.AccessKeyId)
  aws configure set profile.eks-creator.aws_secret_access_key $(echo $TEMP | jq -r .Credentials.SecretAccessKey)
  aws configure set profile.eks-creator.aws_session_token $(echo $TEMP | jq -r .Credentials.SessionToken)
  aws configure set profile.eks-creator.region ${default_region}

  aws configure list-profiles
}


function update_and_apply_config() {
  echo ================== Update and Apply Config ===============================

  aws eks update-kubeconfig --name ${cluster_name} --region ${default_region} --role-arn ${eks_create_role_arn} --profile eks-creator
  kubectl apply -f config-auth.yaml
  echo 'Applied Auth ConfigMap with kubectl'
}


download_eks_auth
create_credentials
update_and_apply_config


