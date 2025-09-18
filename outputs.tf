output "ray_dashboard_url" {
  description = "The URL for accessing the Ray Dashboard"
  value       = coder_app.ray-dashboard.url
}

output "ray_dashboard_app_id" {
  description = "The ID of the Ray Dashboard app resource"
  value       = coder_app.ray-dashboard.id
}

output "ray_venv_path" {
  description = "Path to the Ray Python virtual environment"
  value       = var.venv_path
}

output "ray_port" {
  description = "The port number used by Ray Dashboard"
  value       = var.port
}

output "ray_setup_script_id" {
  description = "The ID of the Ray setup script resource (if auto_install_ray is enabled)"
  value       = var.auto_install_ray ? coder_script.ray_setup[0].id : null
}

