Install mediawiki using Terraform and Ansible

Terraform Module does the following:
   1 VPC
   3 Subnets - 2 Web and 1 DB
   3 EC2 Instances - 2 Web and 1 DB
   1 Elastic Load Balancer

 Ansible Playbook performs the following:
    Dynamically fetches your resources based on the tags you defined in the terraform IaC.
    Performs the Installation of the MySQL Database
    Creates the Database and Users and other Validations.
    Encrypts the passwords into a vault.
    Role that installs Apache HTTPD, PHP from third-party repositories (remi, epel)
    Configures the webserver
    Makes it ready for the Launch on the browser.
    
 Assumptions/pre-requisites:
   Terraform and Ansible installed.
    Have a pem file named "mediawiki_key.pem"
    If not, download the setup using the instructions in the link below: 
    https://learn.hashicorp.com/tutorials/terraform/install-cli
       
 Install Ansible on Amazon Linux 2:
    sudo amazon-linux-extras install ansible2 -y
 
 Install Git:
    sudo yum install git -y

 Steps to setup:
 
 Clone and switch the directory to the Repository.

 Navigate to the folder:
 
 cd terraform/
 
 Copy "mediawiki_key.pem" here
 
 Initialize the working directory.:

 terraform init -input=false

 Create a plan and save it to the local file tfplan:

 terraform plan -out=tfplan -input=false
 
 Apply the plan stored in the file tfplan. terraform apply -input=false tfplan
 
 cd ../ansible
 
 Copy "mediawiki_key.pem" here
 
 chmod 755 get-pip.py ec2.py
  
 Install pip and boto
 
 ./get-pip.py

  pip install --upgrade --user boto
  
  Run the playbooks:
  
  ansible-playbook site.yaml -i ec2.py --private-key mediawiki_key.pem -i ec2.py --limit "tag_group_web" --tags "install_web" --ask-vault-pass -u ec2-user

  ansible-playbook site.yaml -i ec2.py --private-key mediawiki_key.pem -u ec2-user -i ec2.py --limit "tag_group_db" --tags "install_db" --ask-vault-pass
  
  vault key: tw
 
  Access Mediawiki using Load Balancer DNS name
