data "cloudinit_config" "main" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "packages: ['iperf3', 'strongswan']"
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("cloud-init.tpl",
      {
        cloud_private_ip = azurerm_network_interface.main.private_ip_address
        cloud_public_ip  = azurerm_public_ip.main.ip_address
        cloud_subnet     = azurerm_subnet.main.address_prefixes[0]
        client_ip        = "${var.client_ip}"
        client_subnet    = "${var.client_subnet}"
        shared_secret    = random_password.psk.result
      }
    )
  }
}