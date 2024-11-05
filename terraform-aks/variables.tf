# Defines input variables that can be reused
variable "location" {
  type        = string
  default     = "westeurope"  # Changed to be closer to Germany
  description = "The Azure region where resources will be created"
}