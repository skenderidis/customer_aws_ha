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


variable "subnet_mgmt_1_id" {
  description = "MGMT subnet ID Device 1"
  type        = string
  default     = "subnet-08d8272ac66cefc8e"
}

variable "subnet_mgmt_2_id" {
  description = "MGMT subnet ID Device 2"
  type        = string
  default     = "subnet-07e7f5160d3ad772f"
}

variable "subnet_ext_1_id" {
  description = "EXT subnet ID Device 1"
  type        = string
  default     = "subnet-01aa257b54de9a793"
}

variable "subnet_ext_2_id" {
  description = "EXT subnet ID Device 2"
  type        = string
  default     = "subnet-05eb6ecb93b02d6dd"
}


variable "subnet_int_1_id" {
  description = "INT subnet ID Device 1"
  type        = string
  default     = "subnet-0fd52b04dec34f448"
}

variable "subnet_int_2_id" {
  description = "INT subnet ID Device 2"
  type        = string
  default     = "subnet-0b5d5a9357e4efd62"
}



variable "ext_cidr_block" {
  description = "External subnet for VNET"
  type        = string
  default     = "10.0.1.0/24"
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


variable "ext_2_cidr_block" {
  description = "External subnet for VNET"
  type        = string
  default     = "10.0.11.0/24"
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