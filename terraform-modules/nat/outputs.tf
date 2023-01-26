output "nats_id" {
  value   =  "${aws_nat_gateway.nat.*.id}"
  description = "List of NAT's id"
  }