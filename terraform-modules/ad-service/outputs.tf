output "microsoft-ad_dns_ip_addresses" {
  value = aws_directory_service_directory.microsoft-ad.dns_ip_addresses
}
 
output "microsoft-ad_access_url" {
  value = aws_directory_service_directory.microsoft-ad.access_url
}

output "domain_id"  {
  value = aws_directory_service_directory.microsoft-ad.id
}

output "microsoft-ad_security_group_id" {
  value =aws_directory_service_directory.microsoft-ad.security_group_id
}