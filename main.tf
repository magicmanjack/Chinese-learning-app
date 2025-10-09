variable "db_name" {
    description = "The name of the database."
    type = string
}

variable "db_private_ip" {
    description = "The private IPv4 address of the DB server. Put in same CIDR as VPC."
    type = string
}

variable "db_root_password" {
    description = "The root password of the database."
    type = string
    sensitive = true
}

variable "db_user_username" {
    description = "The username of the main user to access the DB."
    type = string
}

variable "db_user_password" {
    description = "The password of the main user to access the DB"
    type = string
    sensitive = true
}

provider "aws" {
    region = "ap-southeast-2"
}

resource "aws_lightsail_instance" "chinese_app" {
    name = "chinese_app"
    availability_zone = "ap-southeast-2a"
    blueprint_id = "ubuntu_24_04"
    bundle_id = "nano_3_2"
    key_pair_name = "ChineseAppKey"

    connection {
        type = "ssh"
        user = "ubuntu"
        host = self.public_ip_address
        port = 22
        private_key = file(pathexpand("~/.ssh/ChineseAppKey.pem"))
    }

    provisioner "file" {
        source = "webserver"
        destination = "webserver"
    }

    provisioner "file" {
      destination = "/home/ubuntu/prov.sh"
      content = templatefile("${path.module}/provision-webserver.tftpl", {db_name=var.db_name, db_server_ip=var.db_private_ip, api_server_ip="127.0.0.1", db_username=var.db_user_username, db_password=var.db_user_password})
    }

    provisioner "remote-exec" {
        inline = ["sh ~/prov.sh"]
    }
    
}

//Security group needed to SSH to EC2

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


resource "aws_security_group" "allow_mysql" {
    name="allow_mysql"
    description = "Allow mysql traffic"

    ingress {
        description =  "Only allow MySQL traffic from webserver"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${aws_lightsail_instance.chinese_app.private_ip_address}/32"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_instance" "db_server" {
    ami = "ami-0279a86684f669718"
    instance_type = "t2.micro"
    key_name = "dbaccess"
    private_ip = var.db_private_ip

    vpc_security_group_ids = [ aws_security_group.allow_mysql.id, aws_security_group.allow_ssh.id ]

    // Data base provisioning

    connection {
        type = "ssh"
        user = "ubuntu"
        host = self.public_ip
        port = 22
        private_key = file(pathexpand("~/.ssh/dbaccess.pem"))
    }

    provisioner "file" {
        source = "db"
        destination = "db"
    }

    provisioner "file" {
      destination = "/home/ubuntu/prov.sh"
      content = templatefile("${path.module}/provision-dbserver.tftpl", {web_server_ip=aws_lightsail_instance.chinese_app.private_ip_address, db_server_ip=var.db_private_ip, db_root_password=var.db_root_password, db_name=var.db_name, db_user_username=var.db_user_username, db_user_password=var.db_user_password})
    }

    provisioner "remote-exec" {
        inline = ["sh ~/prov.sh"]
    }
}

output "web_server_ip" {
    value = aws_lightsail_instance.chinese_app.public_ip_address
}

output "database_server_ip" {
    value = aws_instance.db_server.public_ip
}