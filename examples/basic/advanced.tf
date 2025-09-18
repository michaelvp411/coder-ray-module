terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
  }
}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

# Parameter for selecting Ray extras
data "coder_parameter" "ray_extras" {
  name        = "Ray Extras"
  description = "Select Ray components to install"
  type        = "string"
  default     = "default,jupyter"
  mutable     = true
  
  option {
    name  = "Basic (Default + Jupyter)"
    value = "default,jupyter"
  }
  option {
    name  = "ML Suite (Default + Tune + Train + Data)"
    value = "default,tune,train,data"
  }
  option {
    name  = "Full AI Runtime"
    value = "air"
  }
  option {
    name  = "Custom"
    value = "default,jupyter,tune,rllib,serve,data,train"
  }
}

resource "coder_agent" "main" {
  os   = "linux"
  arch = "amd64"
  dir  = "/home/coder"
  
  startup_script = <<-EOT
    #!/bin/bash
    
    # Update system packages
    sudo apt-get update
    
    # Install Python and system dependencies
    sudo apt-get install -y python3 python3-pip python3-venv build-essential
    
    # Create workspace directory
    mkdir -p ~/workspace/ray-projects
    
    # Create a sample Ray script
    cat > ~/workspace/ray-projects/hello_ray.py << 'EOF'
import ray
import time

# Initialize Ray
ray.init()

print(f"Ray cluster resources: {ray.cluster_resources()}")

@ray.remote
def compute_task(x):
    time.sleep(1)  # Simulate work
    return x * x

# Execute tasks
results = ray.get([compute_task.remote(i) for i in range(10)])
print(f"Results: {results}")

print("Ray dashboard available at: http://localhost:8265")
print("Happy Ray computing!")
EOF
  EOT
}

# Advanced Ray configuration
module "ray" {
  source   = "../.."  # In real usage: "registry.coder.com/modules/ray/coder"
  agent_id = coder_agent.main.id
  
  # Custom dashboard settings
  display_name = "Ray ML Dashboard"
  port         = 8265
  share        = "owner"
  
  # Ray installation with user-selected extras
  ray_extras = split(",", data.coder_parameter.ray_extras.value)
  additional_python_packages = [
    "numpy",
    "pandas", 
    "matplotlib",
    "scikit-learn",
    "jupyter",
    "plotly"
  ]
  
  # Environment configuration
  venv_path          = "/home/coder/.ray-ml-env"
  auto_activate_venv = true
  ray_temp_dir       = "/tmp/ray"
}

# Additional Jupyter setup for Ray
resource "coder_app" "jupyter" {
  agent_id     = coder_agent.main.id
  slug         = "jupyter"
  display_name = "Jupyter Lab (Ray)"
  icon         = "https://jupyter.org/assets/main-logo.svg"
  url          = "http://localhost:8888"
  subdomain    = true
  share        = "owner"
}

resource "coder_script" "jupyter_setup" {
  agent_id     = coder_agent.main.id
  display_name = "Setup Jupyter"
  script       = <<-EOT
    #!/bin/bash
    source ${module.ray.ray_venv_path}/bin/activate
    
    # Install and configure Jupyter
    pip install jupyterlab
    
    # Start Jupyter Lab
    jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root > /tmp/jupyter.log 2>&1 &
  EOT
  
  run_on_start = true
}

# Outputs
output "ray_dashboard_url" {
  value       = module.ray.ray_dashboard_url
  description = "URL to access the Ray dashboard"
}

output "jupyter_url" {
  value       = coder_app.jupyter.url
  description = "URL to access Jupyter Lab"
}

output "ray_venv_path" {
  value       = module.ray.ray_venv_path
  description = "Path to Ray Python virtual environment"
}

