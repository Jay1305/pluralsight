# variables
variable "nat_instance_ami_id" {
  description = "NAT instance AMI id. Consult the ami_id for selected region."
  default     = "ami-00d1f8201864cc10c" #for region us-east-2 ohio
}

# data

# resources
# 1. EIP
resource "aws_eip" "nat_instance_public_ip" {
  vpc = true
  tags = {
    "Name" = "eip for nat"
  }
}

# 2. SG NAT Instance
resource "aws_security_group" "nat_instance_sg" {
  name        = "NAT Instance"
  description = "NAT Instance"
  vpc_id      = "${aws_vpc.shared_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16"]
    description = "VPC and on-prem"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "NAT Instance"
  }
}

# 3. nat1 instance
resource "aws_instance" "nat1" {
  depends_on             = [aws_eip.nat_instance_public_ip, aws_security_group.nat_instance_sg]
  ami                    = "${var.nat_instance_ami_id}"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.nat_instance_sg.id}"]
  subnet_id              = "${aws_subnet.nat_pub.id}"
  private_ip             = "10.2.254.254"
  key_name               = "${var.key_name}"
  source_dest_check      = false

  tags = {
    Name = "nat1"
  }
}

# 4. EIP association
resource "aws_eip_association" "nat1_public_ip_association" {
  instance_id   = "${aws_instance.nat1.id}"
  allocation_id = "${aws_eip.nat_instance_public_ip.id}"
}

# output
output "nat_instance_ip" {
  description = "NAT instance public IP in Shared VPC"
  value       = "${aws_eip.nat_instance_public_ip.public_ip}"
}
