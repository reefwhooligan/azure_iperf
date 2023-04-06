<!-- BEGIN_TF_DOCS -->
# azure\_iperf

Launches and configures an Azure instance with strongSwan and iperf3 to be used
for network throughput testing.  Both an IKEv1 and IKEv2 connection is configured
but only one should be connected at a time to function properly.

## VPN Configuration

ike=aes256-sha2\_256-modp2048\
esp=aes256-sha2\_256-modp2048,aes256gcm128-sha2\_256-modp2048

## Example iperf3

iperf3 will be running in server mode on the Azure instance after launch so
there is no need to login to it in most cases. The `-R` flag will reverse
the direction of the test so that both upload and download tests can be run
from the client.

```
# Test upload through VPN
iperf3 -B <IP in client_subnet> -c <cloud_private_ip>

# Test download through VPN
iperf3 -B <IP in client_subnet> -c <cloud_private_ip> -R

# Test upload without VPN
iperf3 -B <client_ip> -c <cloud_public_ip>

# Test download without VPN
iperf3 -B <client_ip> -c <cloud_public_ip> -R
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.43.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.3.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_security_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_id.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.psk](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [cloudinit_config.main](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_ip"></a> [client\_ip](#input\_client\_ip) | Local public IP for VPN | `string` | n/a | yes |
| <a name="input_client_subnet"></a> [client\_subnet](#input\_client\_subnet) | Local subnet for VPN | `string` | n/a | yes |
| <a name="input_cloud_subnet"></a> [cloud\_subnet](#input\_cloud\_subnet) | Remote subnet for VPN | `string` | `"10.254.254.0/24"` | no |
| <a name="input_create_nsg"></a> [create\_nsg](#input\_create\_nsg) | Restrict access to client IP | `bool` | `false` | no |
| <a name="input_pub_key"></a> [pub\_key](#input\_pub\_key) | Public key for ssh authentication | `string` | `"~/.ssh/id_rsa.pub"` | no |
| <a name="input_region"></a> [region](#input\_region) | Azure region | `string` | `"centralus"` | no |
| <a name="input_username"></a> [username](#input\_username) | Username for ssh authentication | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_ip"></a> [client\_ip](#output\_client\_ip) | Local public IP for VPN |
| <a name="output_client_subnet"></a> [client\_subnet](#output\_client\_subnet) | Local subnet for VPN |
| <a name="output_cloud_private_ip"></a> [cloud\_private\_ip](#output\_cloud\_private\_ip) | Remote IP for running iperf |
| <a name="output_cloud_public_ip"></a> [cloud\_public\_ip](#output\_cloud\_public\_ip) | Remote public IP for VPN |
| <a name="output_cloud_subnet"></a> [cloud\_subnet](#output\_cloud\_subnet) | Remote subnet for VPN |
| <a name="output_psk"></a> [psk](#output\_psk) | Pre-shared key for VPN |
<!-- END_TF_DOCS -->