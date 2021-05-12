variable region {
  type = string
  description = "AWS region: [ us-east-1 | us-east-2 | us-west-1 | us-west-2 ] "
  default = "us-west-1"
}

variable vpc_id {
  type = string
  description = "The vpc id for the selected region"
  default = "vpc-315cef56"
}

variable stack_name {
  type = string
  description = "The stack name prefix"
  default = "test"
}

# -----------------------------------------------------------------------------

provider "aws" {
  version                 = "~> 2.43"
  region                  = var.region
  # shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

resource "aws_security_group" "jenkins" {
  name   = "${var.stack_name}-jenkins-test-sg"
  vpc_id = var.vpc_id  

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.stack_name}-jenkins-test-sg"
  }
}

data "template_file" "jenkins_user_data" {
  template = "${file("${path.module}/jenkins-user-data.tpl")}"
  vars = {
    region      = var.region
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0d382e80be7ffdae5"
  instance_type = "t2.xlarge"
  key_name      = "automation-demo-key"
  user_data = data.template_file.jenkins_user_data.rendered
  security_groups = [aws_security_group.jenkins.name]

  tags = {
    Name = "${var.stack_name}-jenkins-test"
  }
}

# -----------------------------------------------------------------------------

output "public_dns" {
  value = aws_instance.jenkins.public_dns
}

output "command_to_retrieve_the_initial_admin_password" {
  description = "Run this command to retrieve the initial admin password"
  value = "ssh ubuntu@${aws_instance.jenkins.public_dns} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}