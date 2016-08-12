provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_key_pair" "server" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"

}

#################################
####  ENVIRONMENT INSTANCES  ####
#################################
resource "aws_instance" "appserver" {
  count           = "${var.appserver_instances}"
  key_name        = "${var.key_name}"
  ami             = "${var.ami}"
  instance_type   = "${var.appserver_instance_type}"
  subnet_id = "${aws_subnet.public.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  source_dest_check = false
  tags {
    Name = "appserver-${count.index}"
  }
  connection = {
    user     = "${var.connection_user}"
    key_file = "${var.connection_key_file}"
  }
  provisioner "file" {
      source = "./scripts/bootstrap.sh"
      destination = "~/bootstrap.sh"
  }
  provisioner "remote-exec" {
    inline = [
    "sudo chmod a+x ~/bootstrap.sh",
    "sudo ./bootstrap.sh appserver ${aws_instance.nginx.0.private_ip}"
    ]
  }

}

resource "aws_instance" "nginx" {
  count           = "${var.nginx_instances}"
  key_name        = "${var.key_name}"
  ami             = "${var.ami}"
  instance_type   = "${var.nginx_instance_type}"
  subnet_id = "${aws_subnet.public.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}", "${aws_security_group.web.id}"]
  source_dest_check = false
  tags {
    Name = "nginx-${count.index}"
  }
  connection = {
    user     = "${var.connection_user}"
    key_file = "${var.connection_key_file}"
  }
  provisioner "file" {
      source = "./scripts/bootstrap.sh"
      destination = "~/bootstrap.sh"
  }
  provisioner "remote-exec" {
    inline = [
    "sudo chmod a+x ~/bootstrap.sh",
    "sudo ./bootstrap.sh nginx"
    ]
  }
}

output "nginx_publicdns" { value = "${aws_instance.nginx.public_dns}" }
