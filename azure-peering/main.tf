provider "azurerm" {
  features {}
  subscription_id = "d4aded41-83d4-4fac-9f19-50f912e1703e"
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "myPeeringRG"
  location = "uksouth"
}

# Create VNet 1
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

# Create VNet 2
resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.1.0.0/16"]
}

# Create Subnet 1 (Ensure VNet1 is created first)
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  virtual_network_name = azurerm_virtual_network.vnet1.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on           = [azurerm_virtual_network.vnet1]
}

# Create Subnet 2 (Ensure VNet2 is created first)
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  virtual_network_name = azurerm_virtual_network.vnet2.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.1.0/24"]
  depends_on           = [azurerm_virtual_network.vnet2]
}

# VNet Peering from VNet1 → VNet2 (Ensure both VNets exist first)
resource "azurerm_virtual_network_peering" "peer1_to_2" {
  name                         = "peer1-to-2"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet2.id
  allow_virtual_network_access = true
  depends_on                   = [azurerm_virtual_network.vnet1, azurerm_virtual_network.vnet2]
}

# VNet Peering from VNet2 → VNet1 (Ensure both VNets exist first)
resource "azurerm_virtual_network_peering" "peer2_to_1" {
  name                         = "peer2-to-1"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet1.id
  allow_virtual_network_access = true
  depends_on                   = [azurerm_virtual_network.vnet1, azurerm_virtual_network.vnet2]
}
