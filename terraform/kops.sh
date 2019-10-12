# Before we start play with kops create vpc with terraform apply

# Here we go..
export KOPS_CLUSTER_NAME=juice.k8s.local
export KOPS_STATE_STORE=s3://$(terraform output s3_store)
export ZONES=us-east-1b,us-east-1a

kops create cluster \
    --zones $ZONES \
    --node-count=1 \
    --node-size=t2.medium \
    --networking calico \
    --vpc $(terraform output vpc_id) \
    --name=${KOPS_CLUSTER_NAME}

# Apply new configuration manually, just because..
## kops update cluster --name juice.k8s.local --yes

# Updating cluster
# kops get cluster --name=juice.k8s.local --output yaml > cluster.yml
# kops get instancegroups --name=juice.k8s.local --output yaml >> cluster.yml
# kops replace -f cluster.yml
# kops create secret --name juice.k8s.local sshpublickey admin -i ~/.ssh/id_rsa.pub
# kops update cluster --name juice.k8s.local --yes

# Next step - ansible
## to get some things..
echo "waf_acl: \"$(terraform output waf_acl)\"" >>../ansible/inventory/group_vars/all/all.yml
echo "cert_arn: \"$(terraform output cert_arn)\"" >>../ansible/inventory/group_vars/all/all.yml
echo "subnets_ids: \"$(aws ec2 describe-subnets --filters 'Name=tag:KubernetesCluster,Values=juice.k8s.local' --query 'Subnets[*].SubnetId' --output text | sed -e 's/\s\+/,/g')\"" >>../ansible/inventory/group_vars/all/all.yml
