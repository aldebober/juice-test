resource "aws_iam_server_certificate" "mycert" {
  name = "mycert"
  certificate_body = "${file("files/example.pem")}"
  private_key = "${file("files/example.key")}"
}

