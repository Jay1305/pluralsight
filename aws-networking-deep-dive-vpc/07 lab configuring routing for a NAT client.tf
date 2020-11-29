# variables

# data

# resources
# 1. 
resource "aws_route" "db_instance_route_to_internet_via_nat_instance" {
  route_table_id         = "${aws_route_table.shared_rt.id}"
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = "${aws_instance.nat1.primary_network_interface_id}"
  depends_on             = [aws_route_table.shared_rt,aws_instance.nat1]
}