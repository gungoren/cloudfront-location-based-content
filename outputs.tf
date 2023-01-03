output "distribution_url" {
    value = "https://${module.cdn.cloudfront_distribution_domain_name}"
}

output "flag_url" {
    value = "https://${module.cdn.cloudfront_distribution_domain_name}/flag.png"
}