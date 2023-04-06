variable "region" {
  type        = string
  default     = "centralus"
  description = "Azure region"
}

variable "pub_key" {
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Public key for ssh authentication"
}

variable "cloud_subnet" {
  type        = string
  default     = "10.254.254.0/24"
  description = "Remote subnet for VPN"
}

variable "create_nsg" {
  type        = bool
  default     = false
  description = "Restrict access to client IP"
}

variable "username" {
  type        = string
  description = "Username for ssh authentication"
}

variable "client_ip" {
  type        = string
  description = "Local public IP for VPN"
}

variable "client_subnet" {
  type        = string
  description = "Local subnet for VPN"
}

resource "random_password" "psk" {
  length  = 16
  special = true
}

resource "random_id" "id" {
  byte_length = 2
}
