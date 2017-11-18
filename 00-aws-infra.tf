##Amazon Infrastructure
provider "aws" {
  region = "${var.aws_region}"
}

##Create security group
resource "aws_security_group" "aws_k8s_sg" {
  name        = "aws-k8s_sg"
  vpc_id            = "${var.aws_vpc_id}"
  description = "Allow all inbound traffic necessary for Kubernetes"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  tags {
    Name = "aws_k8s_sg"
  }
}

##Find latest Ubuntu 16.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

##Create k8s Master Instance
resource "aws_instance" "aws-k8s-master" {
  subnet_id              = "${var.aws_subnet_id}"
  depends_on             = ["aws_security_group.aws_k8s_sg"]
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.aws_instance_size}"
  vpc_security_group_ids = ["${aws_security_group.aws_k8s_sg.id}"]
  key_name               = "${var.aws_key_name}"
  tags {
    Name = "k8s-master"
    kubespray-role = "kube-master, etcd"
  }
}

##Create AWS k8s Workers
resource "aws_instance" "k8s-members" {
  subnet_id              = "${var.aws_subnet_id}"
  depends_on             = ["aws_security_group.aws_k8s_sg"]
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "${var.aws_instance_size}"
  vpc_security_group_ids = ["${aws_security_group.aws_k8s_sg.id}"]
  key_name               = "${var.aws_key_name}"
  count                  = "${var.aws_worker_count}"
  tags {
    Name = "k8s-member-${count.index}"
    role = "k8s-member"
    kubespray-role = "kube-node"
  }
}

