variable "zone" {
  description = "Name of the zone i.e. ns1.fiservapis.com"
  type        = string
}

variable "domain" {
  description = "The FQDN of the record i.e. terraform.ns1.fiservapis.com"
  type        = string
}

variable "type" {
  description = "The DNS record type: A, CNAME, TXT, etc"
  type        = string
}

variable "ttl" {
  description = "The TTL for the record in seconds"
  default     = 3600
  type        = number
}

variable "up" {
  description = "The UP for ungrouped answers"
  default     = null
  type        = bool
}

variable "groups" {
  description = "The group object definition. NS1 use the term regions but it is really a group."
  default     = []
  type        = any
}

variable "answers" {
  description = "The answers object definition"
  default     = []
  type        = any
}

variable "filters" {
  description = "The filter chain object definition"
  default     = []
  type        = any
}
