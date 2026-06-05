provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "zero-touch-rg"
  location = "Central India"
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "zero-touch-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "zero-touch-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "main" {
  name                = "zero-touch-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "zero-touch-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "zero-touch-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# NSG Association
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Linux VM
resource "azurerm_linux_virtual_machine" "main" {
  name                = "zero-touch-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.main.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDF5R8dcsaHu26WV486FZuCjhKoSh7GJXjmTbjH0O/Ca3416/+RUbH7jD8QTdbbv8/2rcel1JcP47rWzhrJI7K8KrKf3Rb4cT+r/HU2ySc+iZ3Zstjz4JSDwr4T6J3mbGIJ3bbXZL8vlkx2+GERodUfpvT9mOnm6ao/4a+O7baTzPUBMmKBcZMoCUPCr6TXTE25yc4i/DfV+u4WTuElaVdnbZImZu3N4+BSahv7Gr1po0ZNbxX30lnHCSqew3avj3dwCfIp0i7ZZWAn68wXfj3xOkiuCOriZNGKwOXYsnGA8kxv9TEIxFuwUfUqhZ1PvDYMdYTUiyv7mM4sXJPV1VWu1PV7VaHikwAoOzrVxAeXSciA+vpM0xsAw2RS0yW6/tGvq4SzJvgjcfFLC/Bs/5ITQW+qyygC+pyJYQ5qpUiXUqhKujycpvcF96TVT5N+5AlK03g6MdofAwz+FuNzmPOqTO44k+eKMeSrH84fFOG93cP+zAoD60umraGB0p/h9SmtB0OLx4XSgTA9mdwg2XHXsqlofDGzzgPyn1OxO/9Dj5ZJS0LhYaFWadKfEG1rPk/6V50NYYhF9P3BitU6owzmWi+F64NAcVoODqsOIxCqUXoPBjfMdeR346xazciyXR3oOn8fK/KJ2cK9n5IYAJJz5V8DynRY7l4O+nysmD51iw== dann@DESKTOP-F248V42"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}