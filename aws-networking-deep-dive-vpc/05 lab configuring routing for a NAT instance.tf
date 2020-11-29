# variables

# data

# resources
# 1. shared-igw internet gateway
resource "aws_internet_gateway" "shared_vpc_gw" {
  vpc_id = "${aws_vpc.shared_vpc.id}"

  tags = {
    Name = "shared_igw"
  }
}

# 2. Subnet nat-pub
resource "aws_subnet" "nat_pub" {
  vpc_id            = "${aws_vpc.shared_vpc.id}"
  cidr_block        = "10.2.254.0/24"
  availability_zone = "${var.az}"
  tags = {
    Name = "nat-pub"
  }
}

# 3. Route table nat-pub
resource "aws_route_table" "nat_pub_rt" {
  vpc_id = "${aws_vpc.shared_vpc.id}"

  tags = {
    Name = "nat-pub"
  }
}

# 4. Route to internet for nat-pub rt
resource "aws_route" "nat_pub_rt_to_internet" {
  route_table_id         = "${aws_route_table.nat_pub_rt.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.shared_vpc_gw.id}"
  depends_on             = [aws_route_table.nat_pub_rt]
}

# 5. nat_pub_rt route table association with subnet
resource "aws_route_table_association" "nat_pub_rt_association_with_nat_pub_subnet" {
  subnet_id      = "${aws_subnet.nat_pub.id}"
  route_table_id = "${aws_route_table.nat_pub_rt.id}"
}