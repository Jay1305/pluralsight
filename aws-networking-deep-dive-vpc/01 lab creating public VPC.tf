# variables
variable "region" {
  description = "Region to choose for VPC"
  default     = "us-east-2"
}

variable "az" {
  description = "Availbility Zone to use"
  default     = "us-east-2a"
}

variable "profile" {
  description = "AWS Profile name to use"
  default     = "pluralsight"
}

# providers

provider "aws" {
  region  = var.region
  profile = var.profile
}

# data

# resources    
# 1. vpc web_vpc 
resource "aws_vpc" "web_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "web-vpc"
  }

}

# 2. subnet web_pub
resource "aws_subnet" "web_pub" {
  vpc_id            = "${aws_vpc.web_vpc.id}"
  cidr_block        = "10.1.254.0/24"
  availability_zone = "${var.az}"

  tags = {
    Name = "web-pub"
  }
}

# 3. Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.web_vpc.id}"

  tags = {
    Name = "web-igw"
  }
}

# 4. Route table
resource "aws_route_table" "web_vpc_rt" {
  vpc_id = "${aws_vpc.web_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "web-pub"
  }
}

# 5. Subnet association
resource "aws_route_table_association" "web_pub_rt_association_with_web_pub_subnet" {
  subnet_id      = "${aws_subnet.web_pub.id}"
  route_table_id = "${aws_route_table.web_vpc_rt.id}"
}

