variable "requester_region" {
  description = "Requester region"
  type        = string
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

variable "accepter_region" {
  description = "Accepter region"
  type        = string
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