resource "aws_eip" "nat" {
  vpc   = true
  count = "${length(var.natgw_subnetids)}"
}

resource "aws_nat_gateway" "nat" {
  count =  "${length(var.natgw_subnetids)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(var.natgw_subnetids, count.index)}"
  tags = {
    Name = "${var.natgw_name}_${count.index}"
  }
}