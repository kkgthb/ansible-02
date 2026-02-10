resource "azurerm_resource_group" "my_resource_group" {
  provider = azurerm.demo
  name     = "${var.workload_nickname}-rg-demo"
  location = "centralus"
}