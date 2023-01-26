//create EFS file system
resource "aws_efs_file_system" "ereg_efs" {
  creation_token                  = var.creation_token
//  tags                            = var.tags
  encrypted                       = var.encrypted
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode
  kms_key_id                      = var.kms_key_id 
  lifecycle_policy {
    transition_to_ia =  var.transition_to_ia //"AFTER_30_DAYS"
  }
  tags = merge( {
//    Name      = "${format("rt-%[1]s-%[2]s%[3]s%[4]s-001",var.project_code,var.env_name,var.zone_name,var.subnet_name)}"
    Terraform = "true"
  }, var.tags, var.customer_tags)    
}
//create target for each available zone
resource "aws_efs_mount_target" "ereg_target" {
  count           = length(var.availability_zones) > 0 ? length(var.availability_zones) : 0
  file_system_id  = aws_efs_file_system.ereg_efs.id
 // ip_address      = var.mount_target_ip_address
  subnet_id       = var.subnets[count.index]
  security_groups = var.security_groups
}