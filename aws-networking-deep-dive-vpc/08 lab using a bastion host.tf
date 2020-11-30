# variables
variable "private_key_file_path" {
  description = "File path of private key for NAT Instance"
  default     = "F:/Pluralsight/pluralsight.pem" # This should be your file path
}

# data

# resources
# 1. run docker database image on db1 instance from nat instance. 
# MAKE SURE IF YOU ARE ON WINDOWS MACHINE, RUN PEGEANT AUTHENTICATION AGENT
resource "null_resource" "run_db_in_docker_on_db1" {
  depends_on = [aws_instance.nat1, aws_instance.db1, aws_eip.nat_instance_public_ip]
  connection {
    type                = "ssh"
    bastion_user        = "ec2-user"
    user                = "ec2-user"
    timeout             = "30s"
    private_key         = file("${var.private_key_file_path}")
    bastion_private_key = file("${var.private_key_file_path}")
    agent               = true # this is required for our ssh forwarding from bastion to private instance
    host                = "${aws_instance.db1.private_ip}"
    bastion_host        = "${aws_instance.nat1.public_ip}"

  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker run --name db1 -p 3306:3306 -d benpiper/aws-db1",
    ]
  }
}

# 2. run docker wordpress image on www1 instance.
# MAKE SURE IF YOU ARE ON WINDOWS MACHINE, RUN PEGEANT AUTHENTICATION AGENT
resource "null_resource" "run_wordpress_in_docker_on_www1" {
  depends_on = [aws_instance.web, aws_eip.pub_ip]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    timeout     = "30s"
    private_key = file("${var.private_key_file_path}")
    host        = "${aws_instance.web.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker run --name www1 -p 80:80 -d benpiper/aws-www1",
    ]
  }
}