variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}

variable "prefix" {
  description = "Prefix for resources created by this module"
  type        = string
  default     = "tf-aws-bigip"
}

variable "owner" {
  description = "Owner of VNET"
  type        = string
  default     = "Kostas"
}

variable "vpc_cidr_block" {
  description = "CIDR subnet for VNET"
  type        = string
  default     = "10.0.0.0/16"
}

variable "mgmt_cidr_block" {
  description = "F5 MGMT subnet for VNET"
  type        = string
  default     = "10.0.0.0/24"
}

variable "ext_cidr_block" {
  description = "External subnet for VNET"
  type        = string
  default     = "10.0.1.0/24"
}

variable "int_cidr_block" {
  description = "F5 Internal subnet for VNET"
  type        = string
  default     = "10.0.2.0/24"
}


variable "mgmt_ip_1" {
  description = "F5 MGMT IP for Device 1"
  type        = string
  default     = "10.0.0.10"
}

variable "mgmt_ip_2" {
  description = "F5 MGMT IP for Device 2"
  type        = string
  default     = "10.0.10.11"
}


variable "int_ip_1" {
  description = "F5 Internal IP for Device 1"
  type        = string
  default     = "10.0.2.10"
}

variable "int_ip_2" {
  description = "F5 Internal IP for Device 2"
  type        = string
  default     = "10.0.12.11"
}


variable "ext_ip_1" {
  description = "F5 External IP for Device 1"
  type        = string
  default     = "10.0.1.10"
}
variable "ext_ip_sec_1" {
  description = "F5 External Secondary IP for Device 1"
  type        = string
  default     = "10.0.1.50"
}


variable "ext_ip_2" {
  description = "F5 External IP for Device 2"
  type        = string
  default     = "10.0.11.11"
}

variable "ext_ip_sec_2" {
  description = "F5 External Secondary IP for Device 2"
  type        = string
  default     = "10.0.11.51"
}



variable "mgmt_2_cidr_block" {
  description = "F5 MGMT subnet for VNET"
  type        = string
  default     = "10.0.10.0/24"
}

variable "ext_2_cidr_block" {
  description = "External subnet for VNET"
  type        = string
  default     = "10.0.11.0/24"
}

variable "int_2_cidr_block" {
  description = "F5 Internal subnet for VNET"
  type        = string
  default     = "10.0.12.0/24"
}




variable "username" {
  description = "F5 username"
  type        = string
  default     = "kostas"
}

variable "password" {
  description = "F5 username"
  type        = string
  default     = "Aisopou36"
}