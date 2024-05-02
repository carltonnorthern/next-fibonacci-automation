resource "aws_instance" "pebblepost" {
  ami = "ami-03c983f9003cb9cd1" # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type (64-bit (x86))
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.main-public-1.id}"
  vpc_security_group_ids = ["${aws_security_group.allow-ssh-http.id}"]
  key_name = aws_key_pair.terraform_ec2_key.key_name
}

resource "aws_key_pair" "terraform_ec2_key" {
  key_name = "id_ed25519"
  public_key = "${file("~/.ssh/id_ed25519.pub")}"
}