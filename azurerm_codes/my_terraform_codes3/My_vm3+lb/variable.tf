variable "rg4" {}
variable "vnet4" {}
variable "subnet4" {}
variable "username" {}
variable "password" {}
variable "location" {}
variable "vm4_name" {}
variable "vm4_size" {}
variable "vm4_pip" {}
variable "vm4_nic" {}
variable "node_location" {
type = string
}

variable "resource_prefix" {
type = string
}

variable "node_address_space" {
default = ["1.0.0.0/16"]
}

#variable for network range

variable "node_address_prefix" {
default = ["1.0.1.0/24"]
}

#variable for Environment
variable "Environment" {
type = string
}

variable "node_count" {
type = number
}