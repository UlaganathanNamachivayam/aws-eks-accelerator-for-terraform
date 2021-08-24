/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

variable "terraform_version" {
  type        = string
  default     = "Terraform"
  description = "Terraform Version"
}
variable "org" {
  type        = string
  description = "tenant, which could be your organization name, e.g. aws'"
  default     = "aws"
}
variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = ""
}
variable "environment" {
  type        = string
  default     = "preprod"
  description = "Environment area, e.g. prod or preprod "
}
variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
  default     = ""
}
variable "attributes" {
  type        = string
  default     = ""
  description = "Additional attributes (e.g. `1`)"
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}


#----------------------------------------------------------
// VPC
#----------------------------------------------------------
variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = false
}
variable "enable_public_subnets" {
  description = "Enable public subnets for EKS Cluster"
  type        = bool
  default     = false
}
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for public subnets"
  type        = bool
  default     = false
}
variable "single_nat_gateway" {
  description = "Create single NAT gateway for all private subnets"
  type        = bool
  default     = true
}
variable "create_igw" {
  description = "Create internet gateway in public subnets"
  type        = bool
  default     = false
}
variable "enable_private_subnets" {
  description = "Enable private subnets for EKS Cluster"
  type        = bool
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "VPC id"
  default     = ""
}

variable "private_subnet_ids" {
  description = "list of private subnets Id's for the Worker nodes"
  default     = []
}
variable "public_subnet_ids" {
  description = "list of public subnets Id's for the Worker nodes"
  default     = []
}
variable "vpc_cidr_block" {
  type        = string
  default     = ""
  description = "VPC CIDR"
}
variable "public_subnets_cidr" {
  description = "list of Public subnets for the Worker nodes"
  default     = []
}
variable "private_subnets_cidr" {
  description = "list of Private subnets for the Worker nodes"
  default     = []
}

variable "create_vpc_endpoints" {
  type        = bool
  default     = false
  description = "Create VPC endpoints for Private subnets"
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false"
}
variable "endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
}
variable "enable_irsa" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
}