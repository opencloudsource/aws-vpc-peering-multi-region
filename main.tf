# REQUESTER
data "aws_caller_identity" "requester" {
  provider = aws.requester
}

data "aws_region" "requester" {
  provider = aws.requester
}

data "aws_vpc" "requester" {
  provider = aws.requester
  id       = var.requester_vpc_id
}

data "aws_subnets" "requester" {
  provider = aws.requester
  filter {
    name   = "vpc-id"
    values = [var.requester_vpc_id]
  }
}

locals {
  requester_subnet_ids          = try(distinct(sort(flatten(data.aws_subnets.requester.*.ids))), [])
  requester_aws_route_table_ids = try(distinct(sort(data.aws_route_table.requester.*.route_table_id)), [])
}

# Lookup requester route tables
data "aws_route_table" "requester" {
  count     = length(local.requester_subnet_ids)
  provider  = aws.requester
  subnet_id = local.requester_subnet_ids[count.index]
}

resource "aws_vpc_peering_connection" "requester" {
  provider    = aws.requester
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id
  peer_region = var.accepter_region
  auto_accept = false
}

# Options can't be set until the connection has been accepted and is active,
# so create an explicit dependency on the accepter when setting options.
#locals {
#  active_vpc_peering_connection_id = local.accepter_enabled ? join("", aws_vpc_peering_connection_accepter.accepter.*.id) : null
#}
#
#resource "aws_vpc_peering_connection_options" "requester" {
#  # Only provision the options if the accepter side of the peering connection is enabled
#  count    = local.accepter_count
#  provider = aws.requester
#
#  # As options can't be set until the connection has been accepted
#  # create an explicit dependency on the accepter.
#  vpc_peering_connection_id = local.active_vpc_peering_connection_id
#
#  requester {
#    allow_remote_vpc_dns_resolution = var.requester_allow_remote_vpc_dns_resolution
#  }
#}

# Create routes from requester to accepter
resource "aws_route" "requester" {
  count                     = length(local.requester_aws_route_table_ids)
  provider                  = aws.requester
  route_table_id            = local.requester_aws_route_table_ids[count.index]
  destination_cidr_block    = data.aws_vpc.accepter[0].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester[0].id
  depends_on                = [
    data.aws_route_table.requester,
    aws_vpc_peering_connection.requester,
    aws_vpc_peering_connection_accepter.accepter
  ]
}

# ACCEPTER
data "aws_caller_identity" "accepter" {
  provider = aws.accepter
}

data "aws_region" "accepter" {
  provider = aws.accepter
}

data "aws_vpc" "accepter" {
  provider = aws.accepter
  id       = var.accepter_vpc_id
}

data "aws_subnets" "accepter" {
  provider = aws.accepter
  filter {
    name   = "vpc-id"
    values = [var.accepter_vpc_id]
  }
}

locals {
  accepter_subnet_ids = try(distinct(sort(flatten(data.aws_subnets.accepter.*.ids))), [])
}

data "aws_route_table" "accepter" {
  count = length(local.accepter_subnet_ids)
  provider = aws.accepter
  subnet_id = local.accepter_subnet_ids[count.index]
}

locals {
  accepter_aws_route_table_ids           = try(distinct(sort(data.aws_route_table.accepter.*.route_table_id)), [])
}

# Create routes from accepter to requester
resource "aws_route" "accepter" {
  count                     = length(local.accepter_aws_route_table_ids)
  provider                  = aws.accepter
  route_table_id            = local.accepter_aws_route_table_ids[count.index]
  destination_cidr_block    = data.aws_vpc.requester[0].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester[0].id
  depends_on                = [
    data.aws_route_table.accepter,
    aws_vpc_peering_connection_accepter.accepter,
    aws_vpc_peering_connection.requester,
  ]
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.requester[0].id
  auto_accept               = true
}

#resource "aws_vpc_peering_connection_options" "accepter" {
#  provider                  = aws.accepter
#  vpc_peering_connection_id = local.active_vpc_peering_connection_id
#
#  accepter {
#    allow_remote_vpc_dns_resolution = var.accepter_allow_remote_vpc_dns_resolution
#  }
#}
