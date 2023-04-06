/**
  * # azure_iperf
  *
  * Launches and configures an Azure instance with strongSwan and iperf3 to be used
  * for network throughput testing.  Both an IKEv1 and IKEv2 connection is configured
  * but only one should be connected at a time to function properly.
  *
  * ## VPN Configuration
  *
  * ike=aes256-sha2_256-modp2048\
  * esp=aes256-sha2_256-modp2048,aes256gcm128-sha2_256-modp2048
  *
  * ## Example iperf3
  *
  * iperf3 will be running in server mode on the Azure instance after launch so
  * there is no need to login to it in most cases. The `-R` flag will reverse
  * the direction of the test so that both upload and download tests can be run
  * from the client.
  *
  * ```
  * # Test upload through VPN
  * iperf3 -B <IP in client_subnet> -c <cloud_private_ip>
  *
  * # Test download through VPN
  * iperf3 -B <IP in client_subnet> -c <cloud_private_ip> -R
  *
  * # Test upload without VPN
  * iperf3 -B <client_ip> -c <cloud_public_ip>
  *
  * # Test download without VPN
  * iperf3 -B <client_ip> -c <cloud_public_ip> -R
  * ```
  */

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  required_version = "~> 1.4.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "iperf-rg-${random_id.id.hex}"
  location = var.region
}

resource "azurerm_virtual_network" "main" {
  name                = "iperf-vnet"
  address_space       = [var.cloud_subnet]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "iperf-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.cloud_subnet]
}

resource "azurerm_network_security_group" "main" {
  count = var.create_nsg ? 1 : 0

  name                = "iperf-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "iperf-sr"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.client_ip
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "main" {
  count = var.create_nsg ? 1 : 0

  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main[0].id
}

resource "azurerm_public_ip" "main" {
  name                = "iperf-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_network_interface" "main" {
  name                          = "iperf-nic"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "iperf-ip"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "iperf-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_F2s_v2"
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = var.username
    public_key = file(var.pub_key)
  }

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"

    diff_disk_settings {
      option = "Local"
    }
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = data.cloudinit_config.main.rendered
}
