variable "project_name" {
  description = "Project name"
  type        = string
  default     = "secureship"
}

variable "private_server1" {
  description = "value of the ec2 instance"
  type        = string
  default     = "private-server1"
}

variable "private_server2" {
  description = "value of the ec2 instance"
  type        = string
  default     = "private-server2"
}

variable "instance_type" {
  description = "type of the ec2 instance"
  type        = string
  default     = "t3.micro"
}
