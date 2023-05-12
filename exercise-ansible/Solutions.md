</details>

******

<details>
<summary>Exercise 1: Build & Deploy Java Artifact </summary>
 <br />

**preparation**
```sh
- Create an Ubuntu server (Ubuntu version 20.04) on any platform you want
- Configure ssh access to your server (open port 22, create ssh key access)
- Set "server IP address", "user" and "ssh private key path" inside "hosts-deploy-app" file
- Fix the test in the application (if you have not already done it in the Build tools module exercises) to allow building it successfully
Fix: In file - src/test/java/AppTest.java, line - 22, remove quotes from true to make it boolean.

- Install the "acl" package that includes "setfacl" command on the ubuntu machine, so that Ansible can set temporary file permissions correctly, when connecting to the server as an unprivileged user (ubuntu) and becoming another unprivileged user (my-user)
sudo apt-get update -y
sudo apt-get install -y acl

Link: https://docs.ansible.com/ansible/latest/user_guide/become.html#risks-of-becoming-an-unprivileged-user
```

**code**

```sh
# Implementation in file 1-build-and-deploy.yaml 

# execute with hosts-deploy-app host file
ansible-playbook -i hosts-deploy-app 1-build-and-deploy.yaml --extra-vars "linux_user=your-name project_dir=/absolute/path/to/java/gradle/project jar_name=bootcamp-java-project-1.0-SNAPSHOT.jar"
```

</details>

******

<details>
<summary>Exercise 2: Push Java Artifact to Nexus </summary>
 <br />

**code**
```sh
# Make sure you have a Nexus repository manager up and running with maven-snapshots repository

# Implementation in file 2-push-to-nexus.yaml 

# Execute 
ansible-playbook 2-push-to-nexus.yaml --extra-vars "nexus_url=http://nexus-ip:nexus-port nexus_user=admin nexus_password=admin-pass repository_name=maven-snapshots artifact_name=bootcamp-java-project artifact_version=1.0-SNAPSHOT jar_file_path=/absolute/path/to/jar/file/bootcamp-java-project-1.0-SNAPSHOT"

# NOTE: you can specify any inventory file (ansible-playbook -i hosts-deploy-app 2-push-to-nexus.yaml) to avoid the warning, even though we are using localhost, so we don't need an inventory file
```

</details>

******

<details>
<summary>Exercise 3: Install Jenkins on amazon-linux EC2 instance </summary>
 <br />

**steps**
```sh
# Implementations in files: 
- 3-provision-jenkins-ec2.yaml 
- 3-install-jenkins-ec2.yaml 

# Execute to provision jenkins server 
ansible-playbook 3-provision-jenkins-ec2.yaml --extra-vars "ssh_key_path=/path/to/ssh-key/file aws_region=your-aws-region key_name=your-key-pair-name subnet_id=your-subnet-id ami_id=image-id-for-amazon-linux ssh_user=ec2-user" 

# NOTE: Optionally you can try getting some of these parameter values programatically using Ansible itself. You can also put them into a variables file instead of passing on cli. Or parameterise even more values inside the playbook, like version numbers of different tools etc. As you see you are very flexible in what you can do with Ansible.

# Wait until the server is fully initialised

# Execute to configure jenkins server 
ansible-playbook -i hosts-jenkins-server 3-install-jenkins-ec2.yaml --extra-vars "aws_region=your-aws-region"
```

</details>

******

<details>
<summary>Exercise 4: Install Jenkins on Ubuntu EC2 instance </summary>
 <br />

**steps**
```sh
# Implementations in files: 
- 3-provision-jenkins-ec2.yaml 
- 4-install-jenkins-ubuntu.yaml
- 4-host-amazon.yaml
- 4-host-ubuntu.yaml

# To Create and configure Jenkins on --ubuntu-- EC2 instance
ansible-playbook 3-provision-jenkins-ec2.yaml --extra-vars "ssh_key_path=/path/to/ssh-key/file aws_region=your-aws-region key_name=your-key-pair-name subnet_id=your-subnet-id ami_id=image-id-for-ubuntu ssh_user=ubuntu"

ansible-playbook -i hosts-jenkins-server 4-install-jenkins-ubuntu.yaml --extra-vars "host_os=ubuntu aws_region=your-aws-region"

# Execute to Create Jenkins server on --amazon-linux-- EC2 instance
ansible-playbook 3-provision-jenkins-ec2.yaml --extra-vars "ssh_key_path=/path/to/ssh-key/file aws_region=your-aws-region key_name=your-key-pair-name subnet_id=your-subnet-id ami_id=image-id-for-ubuntu ssh_user=ubuntu"

# Wait until the server is fully initialised

# Execute to configure Jenkins
ansible-playbook -i hosts-jenkins-server 4-install-jenkins-ubuntu.yaml --extra-vars "host_os=amazon-linux aws_region=your-aws-region"

# NOTES:
- When executing "3-provision-jenkins-ec2.yaml" script, the only difference between the 2 is the "ami_id" value. So you either provide the "amazon-linux" ami-id or "ubuntu" ami-id
- The shared tasks are all defined in the common "provision-jenkins-ec2.yaml" and the differenes are in respective "host-amazon" or "host-ubuntu" yaml files, which get dynamically selected, based on what "host_os" variable you provide

```

</details>

******

<details>
<summary>Exercise 5: Install Jenkins as a Docker Container </summary>
 <br />

**steps:**
```sh
# Implementation in files: 
- 3-provision-jenkins-ec2.yaml 
- 5-install-jenkins-docker.yaml

# Execute to provision the ubuntu Jenkins server
ansible-playbook 3-provision-jenkins-ec2.yaml --extra-vars "ssh_key_path=/path/to/ssh-key/file aws_region=your-aws-region key_name=your-key-pair-name subnet_id=your-subnet-id ami_id=image-id-for-ubuntu ssh_user=ubuntu"

# Wait until the server is fully initialised

# Execute to configure server to run jenkins as a docker container
ansible-playbook -i hosts-jenkins-server 5-install-jenkins-docker.yaml --extra-vars "aws_region=your-aws-region"

```

</details>

******

<details>
<summary>Exercise 6: Web server and Database server configuration </summary>
 <br />

**steps:**
```sh
# Implementation in files: 
- 6-provision-ansible-server.yaml
- 6-configure-ansible-server.yaml
- 6-inventory_aws_ec2.yaml
- 6-provision-app-servers.yaml
- 6-configure-app-servers.yaml
- 6-vars.yaml


# Create an aws key-pair "ansible-managed-server-key" for web server and database server, download locally and set permission to 400 
chmod 400 ~/Downloads/ansible-managed-server-key.pem

# Create an aws key-pair "ansible-control-server-key" for ansible control server, download locally and set permission to 400
chmod 400 ~/Downloads/ansible-control-server-key.pem

# Set the correct aws region, in which you want to create all your servers, inside 6-inventory_aws_ec2.yaml file
regions: 
- eu-west-3

# Comment in lines 6,7,8 inside ansible.cfg file, to enable the aws_ec2 plugin and configure remote user
enable_plugins = amazon.aws.aws_ec2
remote_user = ubuntu
private_key_file = /home/ubuntu/ansible-managed-server-key.pem

# IMPORTANT! Since we are creating database server without public ip address, by default it won't have internet access. But we need outgoing internet access on the database server in order to be able to download and install packages and tools, including the mysql service itself, so we need to configure that with the following steps:

1: Create a NAT gateway called "my-nat" in one of the PUBLIC subnets, meaning subnets with internet gateway configured in the associated route table. Allocate elastic IP address to the NAT when creating it
2: Create a new route table called "my-db-rt" and add a route: destination: 0.0.0.0/0, target: "my-nat" 
3: In subnet associations of the route table, select a subnet in which you will create your database server. So this will be our "private" subnet. 
4: Copy the 2 subnet ids, 1 public subnet id in which we created the NAT gateway and 1 private subnet id which we assosiated with the "my-db-rt" route table. 
Because we will create the "ansible-server" and "web-server" in the public subnet and "database-server" in the private subnet by providing them as variables values to our playbook.  


# NOTE: make sure to set the correct variable values for aws_region etc for your playbook execution:

# Execute playbook to provision ansible control server itself
ansible-playbook 6-provision-ansible-server.yaml --extra-vars "aws_region=eu-west-3 key_name=ansible-control-server-key subnet_id=public-subnet-id ami_id=ami-0c6ebbd55ab05f070"

# Wait until the server is fully initialised

# Execute playbook to configure ansible control server with all needed tools and files
ansible-playbook -i 6-inventory_aws_ec2.yaml 6-configure-ansible-server.yaml


# SSH into ansible control server to execute the playbooks for configuring database and web servers
ssh -i ~/Downloads/ansible-control-server-key.pem ubuntu@ansible-server-public-ip

# Execute to provision both (ubuntu) servers inside the same VPC
ansible-playbook 6-provision-app-servers.yaml --extra-vars "aws_region=eu-west-3 key_name=ansible-managed-server-key subnet_id_web=public-subnet-id subnet_id_db=private-subnet-id ami_id=ami-0c6ebbd55ab05f070"

# Wait until the servers are fully initialised

# Execute to configure both servers
ansible-playbook -i 6-inventory_aws_ec2.yaml 6-configure-app-servers.yaml

# Make sure to open port 8080 for the web server and access the application via web-server-public-ip-or-dns-name:8080 from browser to make sure the application was successfuly deployed :)
```

</details>

******

<details>
<summary>Exercise 7: Deploy Java MySQL Application in Kubernetes </summary>
 <br />

**steps:**
```sh
# Implementation in files: 
- 7-deploy-on-k8s.yaml
- kubernetes-manifests/exercise-7/*.yaml

# To dockerize the java-mysql application, use the Dockerfile from solutions branch: 
https://gitlab.com/devops-bootcamp3/bootcamp-java-mysql/-/blob/feature/solutions/Dockerfile

# Build and push the image with name: "your-docker-hub-id/demo-app:java-mysql-app" (that's how we are referencing it in kubernetes-manifests/exercise-7/java-app.yaml) to your private dockerhub repo. 

# Create a k8s cluster any way you want: Minikube, LKE, EKS and get the kubeconfig file

# Set value of the ingress host in file kubernetes-manifests/exercise-7/java-app-ingress.yaml, which you will use to access the java app from browser

# Set environment variable for accessing K8s cluster with kubectl and Ansible
export KUBECONFIG=/path/to/kube/config/file

# Execute playbook to deploy K8s manifests (make sure you have Docker running locally when executing the playbook)
ansible-playbook 7-deploy-on-k8s.yaml --extra-vars "docker_user=your-dockerhub-user docker_pass=your-dockerhub-password"

# NOTE: if you get an error on creating ingress component related to "nginx-controller-admission" webhook, than manually delete the ValidationWebhook and try again. To delete the ValidationWebhook:
kubectl get ValidatingWebhookConfiguration # gives you the name
kubectl delete ValidatingWebhookConfiguration {name}

```
</details>

******

<details>
<summary>Exercise 8: Deploy MySQL Chart in Kubernetes </summary>
 <br />

**steps:**
```sh
# Implementation in files: 
- 8-deploy-on-k8s.yaml
- kubernetes-manifests/exercise-8/*.yaml

# Set value of the ingress host in file kubernetes-manifests/exercise-7/java-app-ingress.yaml, which you will use to access the java app from browser

# Set environment variable for accessing K8s cluster with kubectl and Ansible
export KUBECONFIG=/path/to/kube/config/file

# Remove the currently running mysql deployment, that we created in exercise 7
kubectl delete deployment mysql-deployment

# Execute playbook to deploy the mysql chart in your already existing k8s cluster
ansible-playbook 8-deploy-on-k8s.yaml --extra-vars "docker_user=your-dockerhub-user docker_pass=your-dockerhub-password"

```
</details>
