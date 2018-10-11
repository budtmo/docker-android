
resource "azurerm_container_service" "container_service" {
  name                   = "k8s-docker-android"
  resource_group_name    = "${var.resource_group_name}"
  location               = "${var.resource_group_location}"
  orchestration_platform = "Kubernetes"

  master_profile {
    count      = "${var.master_count}"
    dns_prefix = "${var.dns_name_prefix}-master"
  }

  agent_pool_profile {
    name       = "agentpools"
    count      = "${var.linux_agent_count}"
    dns_prefix = "${var.dns_name_prefix}-agent"
    vm_size    = "${var.linux_agent_vm_size}"
  }

  linux_profile {
    admin_username = "${var.linux_admin_username}"

    ssh_key {
      key_data = "${var.linux_admin_ssh_publickey}"
    }
  }

  service_principal {
    client_id     = "${var.service_principal_client_id}"
    client_secret = "${var.service_principal_client_secret}"
  }

  diagnostics_profile {
    enabled = false
  }

  tags {
    Source = "K8s with Terraform"
  }
}

output "master_fqdn" {
  value = "${azurerm_container_service.container_service.master_profile.fqdn}"
}

output "ssh_command_master0" {
  value = "ssh ${var.linux_admin_username}@${azurerm_container_service.container_service.master_profile.fqdn} -A -p 22"
}