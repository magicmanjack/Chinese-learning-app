# Chinese-learning-app
An web application that speeds up a Chinese language learners experience. The goal of the tool is to present learners with practice challenges to rapidly increase their rate of learning.

## Attributions
This project uses the publicly available node.js pinyin module to serve pinyin suggestions: https://pinyin.js.org/en-US



## Overview of inner workings
The application is spread accross 3 servers:
1. A web server to serve the website content. (Apache2 and php)
2. A database to store user information. (MySQL)
3. An API server which provides extra services such as pinyin suggestions. (Node.js and Express)

The application can be deployed onto the local machine using Vagrant. (TODO: As it stands, the Vagrantfile and the provisioning scripts used for Vagrant deployment do not work and need to be updated). The application can also be deployed to the cloud (AWS) using terraform. Either method deploys the machines with Ubuntu. There are instructions below for both options.

There is also an extra tool when deploying to AWS. It comprises of an AWS API gateway attached to a lambda function,  and serves a metrics website. The metrics website displays information about the users interactions with the website (such as accounts created). The lambda function, upon execution, accesses an s3 bucket that contains the metric data. Metric data can be passed to this bucket using cron jobs on the seperate EC2 machines or other methods.


## Vagrant deployment
The deployment involves booting up three virtual machines and setting up port forwarding so that the localhost on port 80 forwards to the virtual web server.

1. In order to get the three servers up and running locally for testing, you must first install vagrant. (information at https://developer.hashicorp.com/vagrant/install). Then you can start the servers by a simple shell command in the project root directory:
```
vagrant up
```
2. This will take a small while. Once the command has finished, you can test if the app is working by navigating to (http://127.0.0.1:8080/) in your web browser. The sites login page should appear. 

You can also ssh to the virtual machines using the command:
```
vagrant ssh webserver
```
In order to ssh to the other machines replace "webserver" from the command above with "dbserver" or "apiserver".

## Terraform deployment to AWS
The Terraform deployment process involves instantiating three AWS EC2's to host the webserver, the mysql database, the API server, and the components of the metrics tool (the API gateway, the lambda function, and the S3 bucket).

1. Firstly you need to install Terraform (https://developer.hashicorp.com/terraform/install). It is recommended that you also install the aws command line interface (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

2. In order to deploy, you need to set up AWS credentials to be authenticated. Instructions to do that are here https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-authentication.html.

3. Once you have got everything installed, change into the root directory of the project. You now to perform a necessary initialization step. On zshell that would be:
```
terraform init
```
4. After initialization, and assuming you have set up you AWS credentials properly, you should be able to deploy the application to AWS with a single command which applies the changes preposed by the main.tf file:
```
terraform apply
```
5. Here is what an example of the what a successful output in the console should look like:
```
Outputs:

api_server_ip = "34.203.13.173"
db_server_ip = "3.90.205.109"
function_name = "GetMetrics"
metrics_url = "https://dbrfygdkt6.execute-api.us-east-1.amazonaws.com/get-metrics"
web_server_ip = "98.81.116.101"

```
You should be able to navigate to the website in your browser by using the ip address shown in the output next to web_server_ip. You can also navigate the domain name provided in the AWS console. If you want to access the metrics web page, use the URL next to the metrics_url.

5.If you want to shutdown all the things deployed you use:
```
terraform destroy
```

## Extending functionality with the Vagrant method
To make permanent changes to the project that happen at boot time, add the bash script commands to one of corrosponding bash scripts:
- provision-apiserver.sh
- provision-dbserver.sh
- provision-webserver.sh

Where apiserver, dbserver, and webserver are the names of the vagrant machines. To affect changes, restart the corrosponding vagrant vm. E.g:
```
vagrant destroy dbserver
vagrant up dbserver
```

## Extending functionality with the Terraform method
The file that defines the structure of the cloud infrastructure is the main.tf file. In there, all of the machines base configurations and provisions are defined. Here is an example of the webserver definition:
```
resource "aws_instance" "web_server" {
    ami = "ami-0360c520857e3138f"
    instance_type = "t2.micro"
    key_name = "cosc349-2024"
    private_ip = local.web_server_priv
    vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_web.id]

    connection {
        type = "ssh"
        user = "ubuntu"
        host = self.public_ip
        port = 22
        private_key = file(pathexpand("~/.ssh/cosc349-2024.pem"))
    }

    provisioner "file" {
        source = "webserver"
        destination = "webserver"
    }

    provisioner "file" {
      destination = "/home/ubuntu/prov.sh"
      content = templatefile("${path.module}/provision-webserver.tftpl", {db_server_ip=local.db_server_priv, api_server_ip=local.api_server_priv})
    }

    provisioner "remote-exec" {
        inline = ["sh ~/prov.sh"]
    }

}
```
The first half defines what OS and type of machine to use. The connection block defines how to upload provision files to the machine (which is using SSH, port 22, using a private key in the .ssh directory). The following provision blocks define what files to upload as provisions. The last provision block instructs the machine to execute a provision script.

So any changes that you want to make to initial machine state go in main.tf. Provision scripts are named in the directory with the prefix "provision" such as "provision-apiserver.sh" or "provision-dbserver.tftpl" so you can add commands you want to execute on the remote machines into those files. 

The ".tftpl" extension is a slightly modified script file called a terraform template file. Those scripts can have variables injected into them at runtime for convenience or to prevent writing in sensitive information into the scripts.

Any changes you make will not be reflected on the remote servers unless you affect the changes with the command used before:
```
terraform apply
```
Sometimes you will need to restart a machine if you need to make changes to the provisioning scripts (which only get loaded during the machines boot). In this case you can use a command such as:
```
terraform taint aws_instance.web_server
terraform apply
```

**To add functionality to the metrics grabbing tool** there are different methods you can do. If you want to edit the  website gets returned, you need to edit the lambda/get_metrics.mjs source file (Node.js). Changes to this file will be reflected upon another terraform apply. If you want to add more types of data to the metrics website, you need to provision the servers to do so. For example, the database server was provisioned to set up a cron job, so that on every minute, it updates the s3 bucket using the AWS command line interface. 