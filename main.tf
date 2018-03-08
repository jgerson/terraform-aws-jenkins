terraform {
  required_version = ">= 0.9.3"
}

provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

data "aws_route53_zone" "hashidemos" {
  name = "hashidemos.io."
}

#------------------------------------------------------------------------------
# instance user data 
#------------------------------------------------------------------------------

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.tpl")}"

  vars {
    hostname       = "${var.service_name}.hashidemos.io"
  }
}

#------------------------------------------------------------------------------
# vpc
#------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "${var.service_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.service_name}-internet_gateway"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.service_name}-route_table"
  }
}

resource "aws_subnet" "subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = "${aws_vpc.main.id}"

  tags {
    Name = "${var.service_name}-subnet"
  }

  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "subnet" {
  route_table_id = "${aws_route_table.main.id}"
  subnet_id      = "${aws_subnet.subnet.id}"
}

#------------------------------------------------------------------------------
# security group
#------------------------------------------------------------------------------

resource "aws_security_group" "main" {
  name        = "${var.service_name}-sg"
  description = "${var.service_name} security group"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    self      = true
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#------------------------------------------------------------------------------
# demo ptfe resources
#------------------------------------------------------------------------------

resource "aws_instance" "jenkins" {
  ami                    = "${var.aws_instance_ami}"
  instance_type          = "${var.aws_instance_type}"
  subnet_id              = "${aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.main.id}"]
  key_name               = "${var.ssh_key_name}"
  user_data              = "${data.template_file.user_data.rendered}"

  tags {
    Name  = "${var.service_name}-instance"
    owner = "${var.owner}"
    TTL   = "${var.ttl}"
  }
}

resource "aws_eip" "demo" {
  instance = "${aws_instance.jenkins.id}"
  vpc      = true
}

resource "aws_route53_record" "jenkins" {
  zone_id = "${data.aws_route53_zone.hashidemos.zone_id}"
  name    = "${var.service_name}.hashidemos.io."
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.demo.public_ip}"]
}

