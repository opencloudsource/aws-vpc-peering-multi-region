variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "requester_vpc_id" {
  description = "Requester VPC ID"
  type        = string
}

variable "requester_allow_remote_vpc_dns_resolution" {
  type        = bool
  default     = true
  description = "Allow requester VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the accepter VPC"
}

variable "requester_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Requester subnets ids"
}

variable "requester_route_table_ids" {
  type        = list(string)
  default     = []
  description = "Requester route table ids"
}

variable "accepter_vpc_id" {
  description = "Accepter VPC ID"
  type        = string
}

variable "accepter_allow_remote_vpc_dns_resolution" {
  type        = bool
  default     = true
  description = "Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC"
}

variable "accepter_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Accepter subnets ids"
}

variable "accepter_route_table_ids" {
  type        = list(string)
  default     = []
  description = "Accepter route table ids"
}
