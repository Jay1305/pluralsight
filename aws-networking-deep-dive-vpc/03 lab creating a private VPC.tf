# variables

# data

# resources
# 1. vpc shared-vpc 
resource "aws_vpc" "shared_vpc" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Name = "shared-vpc"
  }

}

# 2. subnet database
resource "aws_subnet" "database" {
  vpc_id            = "${aws_vpc.shared_vpc.id}"
  cidr_block        = "10.2.2.0/24"
  availability_zone = "${var.az}"

  tags = {
    Name = "database"
  }
}

# 3. Route table shared
resource "aws_route_table" "shared_rt" {
  vpc_id = "${aws_vpc.shared_vpc.id}"

  #   route {
  #     cidr_block = "0.0.0.0/0"
  #     gateway_id = "${aws_internet_gateway.igw.id}"
  #   }

  tags = {
    Name = "shared"
  }
}

# 4. Subnet association
resource "aws_route_table_association" "shared_rt_association_with_database_subnet" {
  subnet_id      = "${aws_subnet.database.id}"
  route_table_id = "${aws_route_table.shared_rt.id}"
}


# 5. database-sg security group
resource "aws_security_group" "database_sg" {
  name        = "database-sg"
  description = "database subnet sg"
  vpc_id      = "${aws_vpc.shared_vpc.id}"
  tags = {
    Name = "database-sg"
  }

  ingress {
    # SSH
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16", "10.2.0.0/16"]
    description = "internal SSH"
  }

  ingress {
    # HTTP
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.1.254.0/24"]
    description = "web-pub subnet"
  }


  ingress {
    # HTTP
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

# 6. Instance
resource "aws_instance" "db1" {
  ami             = "${var.image_ami_id}"
  subnet_id       = "${aws_subnet.database.id}"
  instance_type   = "t2.micro"
  private_ip      = "10.2.2.41"
  security_groups = ["${aws_security_group.database_sg.id}"]
  key_name        = "${var.key_name}"
  tags = {
    Name = "db1"
  }
}

