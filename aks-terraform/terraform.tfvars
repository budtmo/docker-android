
resource_group_name = "docker-android"
resource_group_location = "West US"
dns_name_prefix = "docker-android"
linux_agent_count = "1"

#Only use Dv3 or Ev3 series
linux_agent_vm_size = "Standard_D2_v3"

linux_admin_username = "(Insert any username here!)"
linux_admin_ssh_publickey = "(Insert ssh key here!)"
master_count = "1"


# Azure credentials
service_principal_client_id = "(Insert principal key client id here!)"
service_principal_client_secret = "(Insert principal key client secret here!)"
subscription_id = "(Insert subscription id here!)"
tenant_id = "(Insert tenant id here!)"