# Define provider
provider "azurerm" {
  features {}
}
# Go to existing image
data "azurerm_image" "my_image" {
  name                = var.vm_image_name
  resource_group_name = var.resource_group_name
}

# Create virtual network and subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-azuredevops"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-azuredevops"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create the network security group and rules
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-azuredevops"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "DenyInternet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "AllowVnet"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "AllowLBInbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowInternalOutbound"
    priority                   = 400
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  tags = {
    environment = "Development"
  }
}

# Associate security group to rules
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create public IP address
resource "azurerm_public_ip" "pip" {
  name                = "pip-azuredevops"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

# Load balancer
resource "azurerm_lb" "lb" {
  name                = "lb-azuredevops"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Load balancer backend pool
resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
  name            = "backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

# Health probe
resource "azurerm_lb_probe" "lb_probe" {
  loadbalancer_id         = azurerm_lb.lb.id
  name                    = "tcp-probe"
  protocol                = "Tcp"
  port                    = 80
  interval_in_seconds     = 15
  number_of_probes        = 2
}

# Load balancer rule
resource "azurerm_lb_rule" "lb_rule" {
  name                      = "Tcp-rule"
  loadbalancer_id           = azurerm_lb.lb.id
  frontend_ip_configuration_name = "PublicIPAddress" # Change this to the actual name of your frontend IP configuration
  backend_address_pool_ids   = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
  probe_id                  = azurerm_lb_probe.lb_probe.id
  protocol                  = "Tcp"
  frontend_port             = 80
  backend_port              = 80
}

# Use VMSS instead of AS
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = "vmss-azuredevops"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  sku                             = "Standard_DS1_v2"
  instances                       = var.vm_count
  admin_username                  = "adminuser"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  source_image_id = data.azurerm_image.my_image.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = 30
  }

  network_interface {
    name                      = "vmss-ni"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.nsg.id

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
    }
  }

  tags = {
    environment = "Development"
  }
}