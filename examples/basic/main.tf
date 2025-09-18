terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
  }
}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

resource "coder_agent" "main" {
  os   = "linux"
  arch = "amd64"
  dir  = "/home/coder"
  
  startup_script = <<-EOT
    #!/bin/bash
    
    # Update system packages
    sudo apt-get update
    
    # Install Python and pip if not present
    sudo apt-get install -y python3 python3-pip python3-venv
    
    # Create workspace directory
    mkdir -p ~/workspace
  EOT
}

# Ray module with default settings
module "ray" {
  source   = "../.."  # In real usage: "registry.coder.com/modules/ray/coder"
  agent_id = coder_agent.main.id
}

# Output the Ray dashboard URL
output "ray_dashboard_url" {
  value = module.ray.ray_dashboard_url
  description = "URL to access the Ray dashboard"
}

