# variables
variable "image_ami_id" {
  description = "AMI id to be used for the instance"
  default     = "ami-0007a70384a7897c4" # this is for region us-east-2. Use appropriately for your chosen region
}

variable "key_name" { # Using key that was already created
  description = "Key to use for Ec2 instance"
  default     = "pluralsight"
}


# data
# To get external public IP of current client
data "http" "myip" {
  url = "https://ifconfig.co"
}

# resource
# 1. web-pub-sg security group
resource "aws_security_group" "web_pub_sg" {
  name        = "web-pub-sg"
  description = "web-pub subnet sg"
  vpc_id      = "${aws_vpc.web_vpc.id}"
  tags = {
    Name = "web-pub-sg"
  }

  ingress {
    # SSH
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    description = "me"
  }

  ingress {
    # HTTP
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "the world"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

# 2. ENI
resource "aws_network_interface" "www1_eth0" {
  description     = "www1 eth0"
  subnet_id       = "${aws_subnet.web_pub.id}"
  private_ips     = ["10.1.254.10"]
  security_groups = ["${aws_security_group.web_pub_sg.id}"]
  tags = {
    "Name" = "www1 eth0"
  }
}

# 3. EIP
resource "aws_eip" "pub_ip" {
  network_interface         = "${aws_network_interface.www1_eth0.id}"
  associate_with_private_ip = "10.1.254.10"
  tags = {
    "Name" = "eip for web"
  }
}

# 4. Instance

resource "aws_instance" "web" {
  depends_on    = [aws_network_interface.www1_eth0, aws_eip.pub_ip]
  ami           = "${var.image_ami_id}"
  instance_type = "t2.micro"
  #subnet_id     = "${aws_subnet.web_pub.id}"
  network_interface {
    network_interface_id = "${aws_network_interface.www1_eth0.id}"
    device_index         = 0
  }

  #security_groups = ["${aws_security_group.web_pub_sg.id}"]
  key_name = "${var.key_name}"
  tags = {
    Name = "www1"
  }
}

output "www1_public_ip" {
  depends_on = [aws_eip.pub_ip]
  value      = "${aws_eip.pub_ip.public_ip}"
}