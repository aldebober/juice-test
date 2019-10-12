output "s3_store" {
  value = aws_s3_bucket.kops-bucket.bucket
}

output "waf_acl" {
  value = aws_wafregional_web_acl.acl.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}


output "cert_arn" {
  value = aws_iam_server_certificate.mycert.arn
}

