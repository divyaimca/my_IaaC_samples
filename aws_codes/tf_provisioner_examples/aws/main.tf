

##Providers

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = var.aws_region
}



##Resources

resource "aws_instance" "nginx" {
  ami = var.ami_name
  instance_type = "t2.micro"
  key_name = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "${var.instance_name}-public"
  }
}

resource "aws_security_group" "websg" {
  name = var.instance_name

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = var.ssh_port
    to_port   = var.ssh_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = var.http_port
    to_port   = var.http_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  network_interface_id = "${aws_instance.nginx.primary_network_interface_id}"
  security_group_id = "${aws_security_group.websg.id}"
}


resource "null_resource" "example_provisioner" {
  triggers = {
    public_ip = aws_instance.nginx.public_ip
  }

  connection  {
    type = "ssh"
    host = aws_instance.nginx.public_ip
    user = var.ssh_user
    port = var.ssh_port
    agent = true
    private_key = "${file("${path.module}/./secrets/PriyadarsheeKeys")}"
  }

  // copy our example script to the server
  provisioner "file" {
    source      = "files/script1.sh"
    destination = "/tmp/script1.sh"
  }

  // Remote execution of commands
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
      "sudo yum install -y epel-release",
      "sudo yum update -y",
      "sudo yum install nginx -y",
      "sudo /bin/systemctl start nginx.service",
      "chmod +x /tmp/script1.sh",
      "/tmp/script1.sh > /tmp/public-ip",
    ]
  }

// Local execution of commands
  provisioner "local-exec" {
    # copy the public-ip file back to CWD, which will be tested
    command = "scp -i ./secrets/PriyadarsheeKeys -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_user}@${aws_instance.nginx.public_ip}:/tmp/public-ip public-ip"
  }

}
##output

output "aws_instance_public_dns" {
  value = aws_instance.nginx.public_dns
}
output "aws_instance_public_ip" {
  value = aws_instance.nginx.public_ip
}
