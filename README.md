# terraform-examples

Don't run it in cloud9. no permission to create IAM role.
Please clone to you own laptop and config your aws credentials, make sure you have admin permission.

git clone https://github.com/twoyang0917/terraform-examples.git

# skip this step if got error message: ParameterAlreadyExists.
cd secrets && terragrunt apply

terragrunt apply-all

terragrunt output-all > /tmp/outputs

cat /tmp/outputs

# clone /home/ec2-user/.ssh/ansible to your own laptop.
chmod 600 ~/.ssh/ansible
ssh -p 22 -i ~/.ssh/ansible ubuntu@public_ip

# execute on bastion
cd /services/aws-bootstrap/
ansible-playbook ansible/playbooks/bastion.yml
ansible-playbook ansible/playbooks/wordpress.yml

# open endpoint of the ALB on chrome.
