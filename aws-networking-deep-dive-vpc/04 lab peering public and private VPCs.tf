# variables

# data

# resources
# 1. web-shared-pcx perring connection
resource "aws_vpc_peering_connection" "web_shared_pcx" {
  peer_vpc_id = "${aws_vpc.web_vpc.id}"
  vpc_id      = "${aws_vpc.shared_vpc.id}"
  auto_accept = true
  tags = {
    "Name" = "web-shared-pcx"
  }
}

# 2. Route that needs to add in web_vpc_rt route table for peering connection
resource "aws_route" "web_vpc_rt_to_pcx" {
  route_table_id            = "${aws_route_table.web_vpc_rt.id}"
  destination_cidr_block    = "${aws_subnet.database.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.web_shared_pcx.id}"
  depends_on                = [aws_route_table.web_vpc_rt]
}

# 3. Route that needs to add in shared_rt route table for peering connection
resource "aws_route" "shared_rt_to_pcx" {
  route_table_id            = "${aws_route_table.shared_rt.id}"
  destination_cidr_block    = "${aws_subnet.web_pub.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.web_shared_pcx.id}"
  depends_on                = [aws_route_table.shared_rt]
}