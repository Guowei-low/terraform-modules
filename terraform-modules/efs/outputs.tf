//output for aws_efs_file_system
output "efs_arn" {
  value = aws_efs_file_system.ereg_efs.*.arn
}

output "efs_id" {
    value = aws_efs_file_system.ereg_efs.*.id
}

output "efs_dns_name" {
    value = aws_efs_file_system.ereg_efs.*.dns_name
}

//output for aws_efs_mount_target

output "mount_target_id" {
    value = aws_efs_mount_target.ereg_target.*.id
}

output "mount_target_dns_name" {
    value = aws_efs_mount_target.ereg_target.*.dns_name
}

output "mount_target_file_system_arn" {
    value = aws_efs_mount_target.ereg_target.*.file_system_arn
}

output "mount_target_network_interface_id" {
    value = aws_efs_mount_target.ereg_target.*.network_interface_id
}

