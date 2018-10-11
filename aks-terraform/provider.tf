
# Use this if you can't specify your credentials in file but you need ingress in the UI console.
provider "azurerm" {}

#Use this if you can specify your credentials and no more configuration is necessary 
 #provider "azurerm" {
 #  subscription_id = "${var.subscription_id}"
 #  client_id       = "${var.service_principal_client_id}"
 #  client_secret   = "${var.service_principal_client_secret}"
 #  tenant_id       = "${var.tenant_id}"
 #}