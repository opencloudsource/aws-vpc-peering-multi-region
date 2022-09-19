################################################################################
# Requester
################################################################################

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
  count    = length(var.requester_subnet_ids) == 0 ? 1 : 0
  provider = aws.requester
  filter {
    name   = "vpc-id"
    values = [var.requester_vpc_id]
  }
}

data "aws_route_table" "requester" {
  count     = length(var.requester_route_table_ids) == 0 ? 1 : 0
  provider  = aws.requester
  subnet_id = local.requester_subnet_ids[count.index]
}

locals {
  requester_subnet_ids          = length(var.requester_subnet_ids) > 0 ? var.requester_subnet_ids : try(distinct(sort(flatten(data.aws_subnets.requester.*.ids))), [])
  requester_aws_route_table_ids = length(var.requester_route_table_ids) > 0 ? var.requester_route_table_ids : try(distinct(sort(data.aws_route_table.requester.*.route_table_id)), [])
}

resource "aws_vpc_peering_connection" "requester" {
  provider    = aws.requester
  vpc_id      = var.requester_vpc_id
  peer_vpc_id = var.accepter_vpc_id
  peer_region = data.aws_region.accepter.name
  auto_accept = false
  tags = {
    Name = var.name
  }
}

# Options cannot be set until the vpc connection has been accepted
resource "aws_vpc_peering_connection_options" "requester" {
  provider                  = aws.requester
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accepter.id

  requester {
    allow_remote_vpc_dns_resolution = var.requester_allow_remote_vpc_dns_resolution
  }
}

resource "aws_route" "requester" {
  count                     = length(local.requester_aws_route_table_ids)
  provider                  = aws.requester
  route_table_id            = local.requester_aws_route_table_ids[count.index]
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
  depends_on = [
    data.aws_route_table.requester,
    aws_vpc_peering_connection.requester,
    aws_vpc_peering_connection_accepter.accepter
  ]
}

################################################################################
# Accepter
################################################################################

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
  count    = length(var.accepter_subnet_ids) == 0 ? 1 : 0
  provider = aws.accepter
  filter {
    name   = "vpc-id"
    values = [var.accepter_vpc_id]
  }
}

data "aws_route_table" "accepter" {
  count     = length(var.accepter_route_table_ids) == 0 ? 1 : 0
  provider  = aws.accepter
  subnet_id = local.accepter_subnet_ids[count.index]
}

locals {
  accepter_subnet_ids          = length(var.accepter_subnet_ids) > 0 ? var.accepter_subnet_ids : try(distinct(sort(flatten(data.aws_subnets.accepter.*.ids))), [])
  accepter_aws_route_table_ids = length(var.accepter_route_table_ids) > 0 ? var.accepter_route_table_ids : try(distinct(sort(data.aws_route_table.accepter.*.route_table_id)), [])
}

resource "aws_route" "accepter" {
  count                     = length(local.accepter_aws_route_table_ids)
  provider                  = aws.accepter
  route_table_id            = local.accepter_aws_route_table_ids[count.index]
  destination_cidr_block    = data.aws_vpc.requester.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
  depends_on = [
    data.aws_route_table.accepter,
    aws_vpc_peering_connection_accepter.accepter,
    aws_vpc_peering_connection.requester,
  ]
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
  auto_accept               = true
  tags = {
    Name = var.name
  }
}

# Options cannot be set until the vpc connection has been accepted
resource "aws_vpc_peering_connection_options" "accepter" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.accepter.id

  accepter {
    allow_remote_vpc_dns_resolution = var.accepter_allow_remote_vpc_dns_resolution
  }
}
