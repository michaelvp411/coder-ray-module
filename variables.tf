variable "agent_id" {
  description = "The ID of the Coder agent to install Ray on"
  type        = string
}

variable "slug" {
  description = "The slug for the Ray Dashboard app"
  type        = string
  default     = "ray-dashboard"
}

variable "display_name" {
  description = "The display name for the Ray Dashboard app"
  type        = string
  default     = "Ray Dashboard"
}

variable "icon" {
  description = "The icon URL for the Ray Dashboard app"
  type        = string
  default     = "https://raw.githubusercontent.com/ray-project/ray/master/doc/source/images/ray_logo.png"
}

variable "port" {
  description = "The port number for the Ray Dashboard"
  type        = number
  default     = 8265
}

variable "subdomain" {
  description = "Whether to use a subdomain for the Ray Dashboard"
  type        = bool
  default     = true
}

variable "share" {
  description = "The sharing level for the Ray Dashboard app"
  type        = string
  default     = "owner"
  validation {
    condition     = contains(["owner", "authenticated", "public"], var.share)
    error_message = "Share must be one of: owner, authenticated, public."
  }
}

variable "healthcheck_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 5
}

variable "healthcheck_threshold" {
  description = "Health check threshold"
  type        = number
  default     = 10
}

variable "auto_install_ray" {
  description = "Whether to automatically install Ray on agent startup"
  type        = bool
  default     = true
}

variable "auto_start_dashboard" {
  description = "Whether to automatically start the Ray dashboard"
  type        = bool
  default     = true
}

variable "venv_path" {
  description = "Path to create the Python virtual environment for Ray"
  type        = string
  default     = "/home/coder/.venv-ray"
}

variable "auto_activate_venv" {
  description = "Whether to auto-activate the Ray virtual environment in shell profiles"
  type        = bool
  default     = true
}

variable "ray_extras" {
  description = "Ray installation extras (e.g., 'default', 'jupyter', 'tune', 'rllib')"
  type        = list(string)
  default     = ["default", "jupyter"]
}

variable "additional_python_packages" {
  description = "Additional Python packages to install in the Ray environment"
  type        = list(string)
  default     = []
}

variable "ray_temp_dir" {
  description = "Custom temporary directory for Ray (leave empty for default)"
  type        = string
  default     = ""
}
