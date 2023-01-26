resource "aws_key_pair" "ec2_keypair" {
  key_name   = var.ec2_key_name
  public_key = file("../../../global/keys/${var.ec2_key_name}.pub")
  tags       = merge({Name = "${var.ec2_ebs_name}"}, var.customer_tags)
}

resource "aws_instance" "ec2" {
  count                       = var.ec2_count 
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instancetype
  subnet_id                   = element(var.ec2_subnetid, count.index)
  vpc_security_group_ids      = [var.ec2_vpc_security_group_ids]
  key_name                    = aws_key_pair.ec2_keypair.key_name
  associate_public_ip_address = var.ec2_associate_public_ip_address
  iam_instance_profile        =  var.iam_instance_profile
  ebs_optimized               = var.ebs_optimized
  disable_api_termination     = var.disable_api_termination
  
  dynamic "root_block_device" {
    for_each = var.ec2_root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)      
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      tags                  = merge({Name = "${var.ec2_ebs_name}"}, var.customer_tags)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ec2_ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = lookup(ebs_block_device.value, "device_name", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      tags                  = merge({Name = "${var.ec2_ebs_name}"}, var.customer_tags)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ec2_ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  // additional customer tags
  tags = merge( 
    {
      Hostname    = "${var.hostname_tag}0${format("%00d", count.index + 1)}"
      Name        = "${var.ec2_name}0${format("%00d", count.index + 1)}"
      Description = var.ec2_description
      Terraform   = "true"
    },
    var.customer_tags
  )
  //user_data = file("../../config/SetupApache.sh")
}

/* Enable for ebs volume addition
# set volume
resource "aws_ebs_volume" "ebs_volume" {
  availability_zone = var.ebs_volume_availability_zone
  size              = var.ebs_volume_size
}

#attach volume
resource "aws_volume_attachment" "ec2_attach_ebs_volume" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs_volume.id
  instance_id = aws_instance.ec2.id
}
*/
