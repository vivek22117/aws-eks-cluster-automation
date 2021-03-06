#!/usr/bin/env bash


echo ====================================== Info =======================================================
echo "The below script will first create terraform backend resources that is S3 bucket and DynamoDB table.
They will be used in other modules to store the TF state file"
echo -e "===============================================================================================\n\n"


echo ============================== Reading AWS Default Profile ====================================
aws configure list --profile default >/dev/null 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 256 ]; then
    echo "'default' aws profile does not exit, please create!"
    exit 1
else
  echo "'default' aws profile exists! Let's provision some AWS resources."
fi


echo -e "\n\n =========================== Fetch AWS Account Id ======================================"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text --profile default)
if [ -z $AWS_ACCOUNT_ID  ]; then
    echo "Credentials are not valid!"
    exit 1
else
  echo $AWS_ACCOUNT_ID
fi


echo -e "\n\n =========================== Choose Terraform Execution Type ==========================="

PS3="Select the terraform execution type: "

select EXEC_TYPE in apply destroy
do
    echo "You have decided to $EXEC_TYPE the AWS resources!"
    break
done


echo -e "\n\n ============================= Choose AWS Region ======================================="

PS3="Select aws region to deploy the resources: "

select AWS_REGION in us-east-1 us-east-2 eu-central-1 eu-west-1 eu-west-2 ap-south-1
do
    echo "You have selected $AWS_REGION to deploy the resources!"
    break
done


echo -e "\n\n ======================= Choose Environment To Deploy =================================="

PS3="Select environment to deploy: "

select ENV in qa test prod
do
    echo "You have selected $ENV environment for deployment"
    break
done


echo -e "\n\n ======================= Choose AMI Type To EKS Administrator Machine =================================="

PS3="Select ami filter type: "

AMI_FILTER_TYPE="amazon"

select AMI_FILTER in self_owned amazon_owned
do
    echo "You have selected $AMI_FILTER ami filter type."

    if [ $AMI_FILTER == 'self_owned' ]; then
      AMI_FILTER_TYPE='self'
    fi

    break
done


function terraform_backend_deployment() {
    echo -e "\n\n==================== Starting Terraform Backend Deployment ========================="

    cd aws-eks-tf-backend

    sed -i '/profile/s/^#//g' providers.tf
    sed -i '/backend/,+4d' providers.tf

    terraform init -reconfigure
    terraform plan -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION"
    terraform apply -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve

    cd ..

    echo -e "========================= Completed ================================================ \n\n"
}


function s3_bucket_resources_deployment() {
    echo -e "\n\n===================== Starting S3 Bucket Resource Deployment ========================="

    cd deployment/s3-buckets

    sed -i '/profile/s/^#//g' providers.tf
    sed -i "s/us-east-1/$AWS_REGION/g" providers.tf
    sed -i "s/us-east-1/$AWS_REGION/g" config/$ENV-backend-config.config

    terraform init -backend-config="config/$ENV-backend-config.config" \
    -backend-config="bucket=$ENV-eks-tfstate-$AWS_ACCOUNT_ID-$AWS_REGION" -reconfigure

    terraform plan -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION"
    terraform apply -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -auto-approve

    cd ../..

    echo -e "============================== Completed =============================================== \n\n"
}


function deploy_eks_vpc_network() {
    echo -e "\n\n ========================= Starting EKS vpc network deployment using TF ====================="

    cd deployment/eks-vpc

    sed -i '/profile/s/^#//g' providers.tf
    sed -i "s/us-east-1/$AWS_REGION/g" providers.tf
    sed -i "s/us-east-1/$AWS_REGION/g" config/$ENV-backend-config.config

    terraform init -backend-config="config/$ENV-backend-config.config" \
    -backend-config="bucket=$ENV-eks-tfstate-$AWS_ACCOUNT_ID-$AWS_REGION" -reconfigure

    terraform plan -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV"
    terraform apply -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve

    cd ../..

    echo -e "============================== Completed ================================================ \n\n"
}


function deploy_eks_cluster_resources() {

  echo -e "\n\n ========================= Starting EKS cluster deployment using TF ====================="

  cd deployment/eks-cluster

  sed -i '/profile/s/^#//g' providers.tf
  sed -i "s/us-east-1/$AWS_REGION/g" providers.tf
  sed -i "s/us-east-1/$AWS_REGION/g" config/$ENV-backend-config.config

  terraform init -backend-config="config/$ENV-backend-config.config" \
  -backend-config="bucket=$ENV-eks-tfstate-$AWS_ACCOUNT_ID-$AWS_REGION" -reconfigure

  terraform plan -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV"
  terraform apply -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve

  cd ../..

  echo -e "============================== Completed ================================================ \n\n"
}



function deploy_eks_access_config() {

  if [ $AMI_FILTER_TYPE == 'self' ]; then
    echo -e "You have decided to create AMI for EKS Administration Host."

    echo -e "\n\n ====================== Creating EKS Admin host AMI using Packer ========================="
    echo "Checking whether AMI exists"
    EKS_ADMIN_AMI_ID=$(aws ec2 describe-images --filters "Name=tag:Name,Values=EKS-Admin-Host-AMI" --query 'Images[*].ImageId' --region $AWS_REGION --profile default --output text)

    if [ -z $EKS_ADMIN_AMI_ID ]; then
      echo "Creating AMI named eks-admin-YYYY-MM-DD using packer as it is being used in Terraform script"

      cd packer/eks-admin-host
      packer validate eks-admin-host-template.json
      packer build -var "aws_profile=default" -var "default_region=$AWS_REGION"  -var "terraform_version=1.0.6" -var "kubectl_version=1.20.4" eks-admin-host-template.json
      cd ../..
    else
      echo "AMI exits with id $EKS_ADMIN_AMI_ID, now creating EKS access resources.."
    fi

  fi
  echo -e "\n\n ========================= Starting EKS access config deployment using TF ====================="

  cd deployment/eks-access-config

  sed -i '/profile/s/^#//g' providers.tf
  sed -i "s/us-east-1/$AWS_REGION/g" providers.tf
  sed -i "s/us-east-1/$AWS_REGION/g" config/$ENV-backend-config.config

  terraform init -backend-config="config/$ENV-backend-config.config" \
  -backend-config="bucket=$ENV-eks-tfstate-$AWS_ACCOUNT_ID-$AWS_REGION" -reconfigure

  terraform plan -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -var="ami_filter_type=$AMI_FILTER_TYPE"
  terraform apply -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -var="ami_filter_type=$AMI_FILTER_TYPE" -auto-approve

  cd ../..

  echo -e "============================== Completed ================================================ \n\n"
}



function deploy_eks_irsa_resources() {
  echo -e "\n\n ========================= Starting EKS IRSA resources deployment using TF ====================="

  cd deployment/eks-irsa

  sed -i '/profile/s/^#//g' providers.tf
  sed -i "s/us-east-1/$AWS_REGION/g" providers.tf
  sed -i "s/us-east-1/$AWS_REGION/g" config/$ENV-backend-config.config

  terraform init -backend-config="config/$ENV-backend-config.config" \
  -backend-config="bucket=$ENV-eks-tfstate-$AWS_ACCOUNT_ID-$AWS_REGION" -reconfigure

  terraform plan -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV"
  terraform apply -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve

  cd ../..

  echo -e "============================== Completed ================================================ \n\n"
}


function deploy_eks_container_insights_resources() {
  echo -e "\n\n ========================= Starting EKS container insights resources deployment using TF ====================="

  cd deployment/eks-container-insights

  sed -i '/profile/s/^#//g' providers.tf
  sed -i "s/us-east-1/$AWS_REGION/g" providers.tf
  sed -i "s/us-east-1/$AWS_REGION/g" config/$ENV-backend-config.config

  terraform init -backend-config="config/$ENV-backend-config.config" \
  -backend-config="bucket=$ENV-eks-tfstate-$AWS_ACCOUNT_ID-$AWS_REGION" -reconfigure

  terraform plan -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV"
  terraform apply -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve

  cd ../..

  echo -e "============================== Completed ================================================ \n\n"
}


function deploy_eks_cluster_autoscaler_resources() {
  echo -e "\n\n ========================= Starting EKS cluster autoscaler resources deployment using TF ====================="

  cd deployment/eks-cluster-autoscaler

  sed -i '/profile/s/^#//g' providers.tf
  sed -i "s/us-east-1/$AWS_REGION/g" providers.tf
  sed -i "s/us-east-1/$AWS_REGION/g" config/$ENV-backend-config.config

  terraform init -backend-config="config/$ENV-backend-config.config" \
  -backend-config="bucket=$ENV-eks-tfstate-$AWS_ACCOUNT_ID-$AWS_REGION" -reconfigure

  terraform plan -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV"
  terraform apply -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve

  cd ../..

  echo -e "============================== Completed ================================================ \n\n"
}




if [ $EXEC_TYPE == 'apply' ]; then

  terraform_backend_deployment
  s3_bucket_resources_deployment

  PS3="Do you want to deploy EKS VPC resources module? The TF outputs referred in EKS Cluster module. "
  select ENABLE in Yes No
  do
    echo "You decision is $ENABLE to deploy EKS VPC resources!"
    break
  done

  if [ $ENABLE == 'Yes' ]; then
    deploy_eks_vpc_network
  fi


  PS3="Do you want to deploy EKS Cluster resources? "
  select ENABLE in Yes No
  do
    echo "You decision is $ENABLE to deploy EKS Cluster resources!"
    break
  done

  if [ $ENABLE == 'Yes' ]; then
    deploy_eks_cluster_resources
  fi


  PS3="Do you want to deploy EKS Access Config? It will update aws-auth config file, and creates EKS Admin host. "
  select ENABLE in Yes No
  do
    echo "You decision is $ENABLE to deploy EKS Config resources!"
    break
  done

  if [ $ENABLE == 'Yes' ]; then
    deploy_eks_access_config
  fi

#
#  PS3="Do you want to deploy EKS IRSA resources? It will create Service Account and IAM Role"
#  select ENABLE in Yes No
#  do
#    echo "You decision is $ENABLE to deploy EKS Config resources!"
#    break
#  done
#
#  if [ $ENABLE == 'Yes' ]; then
#    deploy_eks_irsa_resources
#  fi
#
#
#  PS3="Do you want to deploy EKS Container Insights resources? It will create PODs in the Cluster"
#  select ENABLE in Yes No
#  do
#    echo "You decision is $ENABLE to deploy EKS Container Insights resources!"
#    break
#  done
#
#  if [ $ENABLE == 'Yes' ]; then
#    deploy_eks_container_insights_resources
#  fi
#
#
#    PS3="Do you want to deploy EKS Cluster Autoscaler resources? It will create PODs in the Cluster"
#  select ENABLE in Yes No
#  do
#    echo "You decision is $ENABLE to deploy EKS Cluster Autoscaler resources!"
#    break
#  done
#
#  if [ $ENABLE == 'Yes' ]; then
#    deploy_eks_cluster_autoscaler_resources
#  fi


fi



if [ $EXEC_TYPE == 'destroy' ]; then

  echo -e "\n\n ============================ Destroying EKS Access Config Resources ========================="
  cd deployment/eks-access-config

  terraform init -backend-config="config/$ENV-backend-config.config" \
  -backend-config="bucket=$ENV-eks-tfstate-$AWS_ACCOUNT_ID-$AWS_REGION" -reconfigure

  terraform destroy -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -var="ami_filter_type=$AMI_FILTER_TYPE" -auto-approve
  cd ../..


  echo -e "\n\n ============================ Destroying EKS Cluster Resources ========================="
  cd deployment/eks-cluster

  terraform init -backend-config="config/$ENV-backend-config.config" \
  -backend-config="bucket=$ENV-eks-tfstate-$AWS_ACCOUNT_ID-$AWS_REGION" -reconfigure

  terraform destroy -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve
  cd ../..


  echo -e "\n\n ============================ Destroying EKS VPC Network Resources ========================="
  cd deployment/eks-vpc

  terraform init -backend-config="config/$ENV-backend-config.config" \
  -backend-config="bucket=$ENV-eks-tfstate-$AWS_ACCOUNT_ID-$AWS_REGION" -reconfigure

  terraform destroy -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve
  cd ../..



  echo -e "\n\n ========================= Destroying S3 Resources ====================================="
  cd deployment/s3-buckets

  terraform init -backend-config="config/$ENV-backend-config.config" \
  -backend-config="bucket=$ENV-eks-tfstate-$AWS_ACCOUNT_ID-$AWS_REGION" -reconfigure

  terraform destroy -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve
  cd ../..


  PS3="Do you want to destroy TF backend resources as well? "

  select DESTROY_BACKEND in Yes No
  do
      echo "Your input is $DESTROY_BACKEND"
      break
  done

  if [ $DESTROY_BACKEND == 'Yes' ]; then
    echo -e "\n\n ========================= Destroying Backend TF Resources =============================="
    cd aws-eks-tf-backend
    terraform init -reconfigure
    terraform destroy -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve
    cd ..
  fi
  
  
  echo -e "\n\n ========================= =============================== =============================="
  PS3="Do you want to deregister & delete EKS Admin Host AMI which we create using Packer? Select by inserting the number: "

  select AMI_DELETE_FLAG in Yes No
  do
      echo "Your input is $AMI_DELETE_FLAG"
      break
  done
  
  if [ $AMI_DELETE_FLAG=='Yes' ] && [ $AMI_FILTER_TYPE=='self' ]; then

      EKS_ADMIN_AMI_ID=$(aws ec2 describe-images --filters "Name=tag:Name,Values=EKS-Admin-Host-AMI" --query 'Images[*].ImageId' --region $AWS_REGION --profile default --output text)

      if [ ! -z $EKS_ADMIN_AMI_ID]; then
        aws ec2 deregister-image --image-id $EKS_ADMIN_AMI_ID --region $AWS_REGION

        EKS_SNAPSHOT=$(aws ec2 describe-snapshots --owner-ids self --filters Name=tag:Name,Values=EKS-Admin-Host-AMI --query "Snapshots[*].SnapshotId" --output text --region $AWS_REGION)

        for ID in $EKS_SNAPSHOT;
        do
          aws ec2 delete-snapshot --snapshot-id $ID --region $AWS_REGION
          echo ======================== EKS AMI Deleted Successfully ======================================
        done
      fi

  else
    echo "No activity to perform!"
  fi

fi