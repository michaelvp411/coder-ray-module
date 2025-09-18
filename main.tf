resource "coder_app" "ray-dashboard" {
  agent_id     = var.agent_id
  slug         = var.slug
  display_name = var.display_name
  icon         = var.icon
  url          = "http://localhost:${var.port}"
  subdomain    = var.subdomain
  share        = var.share

  healthcheck {
    url       = "http://localhost:${var.port}"
    interval  = var.healthcheck_interval
    threshold = var.healthcheck_threshold
  }
}

resource "coder_script" "ray_setup" {
  count               = var.auto_install_ray ? 1 : 0
  agent_id            = var.agent_id
  display_name        = "Ray Setup"
  icon                = var.icon
  script              = local.ray_setup_script
  start_blocks_login  = true
  run_on_start        = true
}

locals {
  ray_setup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail
    
    echo "Setting up Ray environment..."
    
    # Install system dependencies
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip python3-venv build-essential
    
    # Create Python virtual environment for Ray
    python3 -m venv ${var.venv_path}
    source ${var.venv_path}/bin/activate
    
    # Upgrade pip and install Ray
    pip install --upgrade pip
    pip install "ray[${join(",", var.ray_extras)}]"
    
    # Install additional packages if specified
    %{if length(var.additional_python_packages) > 0~}
    pip install ${join(" ", var.additional_python_packages)}
    %{endif~}
    
    # Set up Jupyter kernel if included
    %{if contains(var.ray_extras, "jupyter")~}
    pip install ipykernel ipywidgets
    python -m ipykernel install --user --name ray-env --display-name "Python (Ray)"
    %{endif~}
    
    # Auto-activate environment
    if [ "${var.auto_activate_venv}" = "true" ]; then
        echo "source ${var.venv_path}/bin/activate" >> ~/.bashrc
    fi
    
    # Start Ray dashboard if enabled
    %{if var.auto_start_dashboard~}
    source ${var.venv_path}/bin/activate
    ray start --head --dashboard-host=0.0.0.0 --dashboard-port=${var.port} --disable-usage-stats > /tmp/ray-dashboard.log 2>&1 &
    %{endif~}
    
    echo "Ray setup complete!"
  EOT
}
