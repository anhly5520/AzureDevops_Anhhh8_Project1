variable "resource_group_name" {
  description = "The name of the existing resource group."
  default     = "Azuredevops"
}

variable "vm_image_name" {
  description = "The name of the Packer image."
  default     = "udacity-packer-image"
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  default     = "East US"
}

variable "vm_count" {
  description = "The number of virtual machines to deploy."
  default     = 2
}