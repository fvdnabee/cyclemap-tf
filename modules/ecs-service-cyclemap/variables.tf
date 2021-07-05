variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "mongodb_uri" {
  description = "mongodb URI to set as MONGODB_URI env variable"
  type = string
  sensitive = true
}
