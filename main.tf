provider "aws" {
    region = "us-east-1"
}

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

resource "aws_instance" "web_server" {
    ami = "ami-0360c520857e3138f"
    instance_type = "t2.micro"
    key_name = "cosc349-2024"

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

    provisioner "remote-exec" {
        script = "provision-webserver.sh"
    }
}

output "web_server_ip" {
    value = aws_instance.web_server.public_ip
}