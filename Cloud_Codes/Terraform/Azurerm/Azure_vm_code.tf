terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "prefix" {
  default = "Lab-vm-01"
}

resource "azurerm_resource_group" "lab-rs-grp-01" {
  name     = "${var.prefix}-resource"
  location = <your>
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.lab-rs-grp-01.location
  resource_group_name = azurerm_resource_group.lab-rs-grp-01.name
}

resource "azurerm_subnet" "lab-subnet-inter-01" {
  name                 = "lab-subnet-inter-01"
  resource_group_name  = azurerm_resource_group.lab-rs-grp-01.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_public_ip" "lab-pub-ip" {
  name                = "${var.prefix}-pub-ip"
  location            = azurerm_resource_group.lab-rs-grp-01.location
  resource_group_name = azurerm_resource_group.lab-rs-grp-01.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "lab-ns-gp-01" {
  name                = "${var.prefix}-ns-sg-01"
  location            = azurerm_resource_group.lab-rs-grp-01.location
  resource_group_name = azurerm_resource_group.lab-rs-grp-01.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.lab-rs-grp-01.location
  resource_group_name = azurerm_resource_group.lab-rs-grp-01.name

  ip_configuration {
    name                          = "lab-ip-config-01"
    subnet_id                     = azurerm_subnet.lab-subnet-inter-01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab-pub-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "lab-nic-sg-01" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.lab-ns-gp-01.id
}

# Create (and display) an SSH key
resource "tls_private_key" "lab-ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.lab-rs-grp-01.location
  resource_group_name   = azurerm_resource_group.lab-rs-grp-01.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = <your>
    admin_password = <your>
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "staging"
  }
}
