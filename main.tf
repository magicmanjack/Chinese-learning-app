locals {
   web_server_priv = "172.31.26.161"
   db_server_priv = "172.31.26.162"
   api_server_priv = "172.31.26.163"
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "metrics_bucket" {
    bucket = "jack-bredenbecks-metrics-bucket"
    force_destroy = true
}

/*
Lambda function configuration.
Firstly uploads lambda to s3 bucket.
*/

data "archive_file" "lambda_get_metrics" {
    type = "zip"

    source_dir = "${path.module}/lambda/get_metrics"
    output_path = "${path.module}/lambda/get_metrics.zip"
}

resource "aws_s3_object" "lambda_get_metrics" {
    bucket = aws_s3_bucket.metrics_bucket.id

    key = "get_metrics.zip"
    source = data.archive_file.lambda_get_metrics.output_path

    etag= filemd5(data.archive_file.lambda_get_metrics.output_path)
}

resource "aws_lambda_function" "get_metrics" {
    function_name="GetMetrics"
    s3_bucket = aws_s3_bucket.metrics_bucket.id
    s3_key = aws_s3_object.lambda_get_metrics.key

    runtime="nodejs20.x"
    handler="get_metrics.handler"

    source_code_hash = data.archive_file.lambda_get_metrics.output_base64sha256
    /* forced to use this role as do not access to create role policy.*/
    role = "arn:aws:iam::781024672893:role/LabRole"
}


/*
Security groups
*/


resource "aws_security_group" "allow_ssh" {
    name = "allow_ssh"
    description = "Allow inbound ssh traffic"

    ingress {
        description = "SSH from anywhere"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_web" {
    name = "allow_web"
    description = "Allow inbound webtraffic"

    ingress {
        description = "web traffic from anywhere"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_mysql" {
    name="allow_mysql"
    description = "Allow mysql traffic"

    ingress {
        description =  "MySQL traffic from webserver"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["172.31.26.161/32"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_security_group" "allow_api" {
    name="allow_api"
    description = "Allow connections to the API server"

    ingress {
        description="Connections only allowed to API port and only from web server"
        from_port=3000
        to_port=3000
        protocol="tcp"
        cidr_blocks=["${local.web_server_priv}/32"]
    }
    egress {
        from_port=0
        to_port=0
        protocol="-1"
        cidr_blocks=["0.0.0.0/0"]
    }
}

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

resource "aws_instance" "db_server" {
    ami = "ami-0360c520857e3138f"
    instance_type = "t2.micro"
    key_name = "cosc349-2024"
    private_ip = local.db_server_priv

    vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_mysql.id]

    connection {
        type = "ssh"
        user = "ubuntu"
        host = self.public_ip
        port = 22
        private_key = file(pathexpand("~/.ssh/cosc349-2024.pem"))
    }

    provisioner "file" {
        source = "db"
        destination = "db"
    }

    provisioner "file" {
      destination = "/home/ubuntu/prov.sh"
      content = templatefile("${path.module}/provision-dbserver.tftpl", {web_server_ip=local.web_server_priv, db_server_ip=local.db_server_priv, metrics_bucket=aws_s3_bucket.metrics_bucket.bucket})
    }

    provisioner "remote-exec" {
        inline = ["sh ~/prov.sh"]
    }

    //Copys aws credentials over to db server. Not perfect but works. 
    provisioner "file" {
      source = pathexpand("~/.aws/credentials")
      destination = "/home/ubuntu/.aws/credentials"
    }
    
}

resource "aws_instance" "api_server" {
    ami = "ami-0360c520857e3138f"
    instance_type = "t2.micro"
    key_name = "cosc349-2024"
    private_ip = local.api_server_priv
    vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_api.id]

    connection {
        type = "ssh"
        user = "ubuntu"
        host = self.public_ip
        port = 22
        private_key = file(pathexpand("~/.ssh/cosc349-2024.pem"))
    }

    provisioner "file" {
        source = "api"
        destination = "api"
    }

    provisioner "remote-exec" {
        scripts = [ "provision-apiserver.sh" ]
    }

}

output "function_name" {
    description = "Name of the lambda function"
    value = aws_lambda_function.get_metrics.function_name
}

output "web_server_ip" {
    value = aws_instance.web_server.public_ip
}
output "db_server_ip" {
    value = aws_instance.db_server.public_ip
}
output "api_server_ip" {
    value = aws_instance.api_server.public_ip
}
