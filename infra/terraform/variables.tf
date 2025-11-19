variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
  default     = "ocid1.tenancy.oc1..aaaaaaaa3h3ywdhnpjp7mq2ysz4h2kjr4knsd2pj6lqm37ru2tgibxudqd2a"
}

variable "subnet_id" {
  description = "OCID of the subnet"
  type        = string
  default     = "ocid1.subnet.oc1.iad.aaaaaaaaznvj7s3bn2y52gkgcfg6f4plbod4tvvminajyw6w7h5bze4t3oha"
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/ZgUzaiv72wGbYkbpZoD6N2Z/cE0jDvO/51t6zxb4zbVvK6yoygJPsn6aOXE+l73EI5IKR13Q109ANHxV+8UMsZstCye8Jd7uDza9iP8wVr7PnjdoQ2aKrHU0momaZDpe93gulJnyzgydLstfrqh4YhxRytSDjIp7LNRMv51+PBPSs58flRbIzAWB5yK2HuHyXM5n3rmCSJR0Y93YD8t6ykuV9tahAibaIblqBW7sVcAJdrrhj8MuQlq3xnLKq8U/br1KwANBNlMAJAUM7xaBOd0impSYxG4IBLyEiYF8zNoM1GYedovqNGswLbGi3wKjEXLXiPJ6ctcrbcDjNZMX ssh-key-2025-11-17"
}

variable "availability_domain" {
  description = "Availability domain for the instance"
  type        = string
  default     = "muFr:US-ASHBURN-AD-1"
}

variable "source_id" {
  description = "OCID of the source image"
  type        = string
  default     = "ocid1.image.oc1.iad.aaaaaaaa5lh4ly5pkbwb6rnvgrc6v7zspxp4hrffzrawxrzowlemfrsbdv6a"
}