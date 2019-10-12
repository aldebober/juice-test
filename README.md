# juice-test
Test task

### Development Toolchain
Component | Software | Version | Notes
--------- | -------- | ------- |------
Ansible	 |	| 2.7.10	| Installation method: pip
Infrastructure to run Ansible role runs on | AWS EC2 | |
AWS API | boto3 | 1.5.10 |
Infrastructure is deployed with Terraform | Terraform | v0.12.3 |

## Process
### There are two subdirectories: 
- Ansible 
- Terraform

### Infrastructure
Go to terraform
Edit terraform.tfvars and apply.
Terraform creates resources:
- aws_iam_server_certificate.mycert
- aws_internet_gateway.igw
- aws_route.public-igw
- aws_route_table.public
- aws_s3_bucket.kops-bucket
- aws_vpc.vpc
- aws_wafregional_rule.owasp_01_sql_injection_rule
- aws_wafregional_sql_injection_match_set.owasp_01_sql_injection_set
- aws_wafregional_web_acl.acl

Edit kops.sh init script and run it.
It runs ```kops create cluster```
It also sets some variables for Ansible roles:
```
echo "waf_acl: \"$(terraform output waf_acl)\"" >>../ansible/inventory/group_vars/all/all.yml
echo "cert_arn: \"$(terraform output cert_arn)\"" >>../ansible/inventory/group_vars/all/all.yml
echo "subnets_ids: \"$(aws ec2 describe-subnets --filters 'Name=tag:KubernetesCluster,Values=juice.k8s.local' --query 'Subnets[*].SubnetId' --output text | sed -e 's/\s\+/,/g')\"" >>../ansible/inventory/group_vars/all/all.yml
```
Looks weired but there is no time ((


To edit existing cluster:
```
 kops get cluster --name=juice.k8s.local --output yaml > cluster.yml
 kops get instancegroups --name=juice.k8s.local --output yaml >> cluster.yml
 kops replace -f cluster.yml
 kops create secret --name juice.k8s.local sshpublickey admin -i ~/.ssh/id_rsa.pub
 kops update cluster --name juice.k8s.local --yes
```

Now we have vpc, two subnets and kubernetes cluster

### Deploy Helm, Alb ingress and our application

go to ../ansible

add ssh key:
```
ssh-add ~/.ssh/id_rsa
```

I use dynamic invetory file inventory/ec2.py, you can edit inventory/ec2.ini
There is two playbook:
- helm.yml
- app.yml

First of all we need helm:
```
ansible-playbook -i ./inventory/ec2.py --limit "tag_k8s_io_role_master_1" playbooks/helm.yml  -u admin -v -b
```

And finaly we deploy alb ingress and app:
```
ansible-playbook -i ./inventory/ec2.py --limit "tag_k8s_io_role_master_1" playbooks/app.yml  -u admin -v -b --vault-password-file=~/vault
```

I was in rush a little and used aws key and secret as env variable, so I had to use ansible-valt. not good..
And using --limit is not necessary, I could set group 'tag_k8s_io_role_master_1' in playbook.

After applying I have app deployment, service and alb ingress rule

