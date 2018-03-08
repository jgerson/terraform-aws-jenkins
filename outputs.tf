output "next steps" {
  value = "To finish the installation visit http://${aws_route53_record.jenkins.fqdn}:8080 to configure jenkins"
}
