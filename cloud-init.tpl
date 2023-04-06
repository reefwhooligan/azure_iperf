write_files:
- content: |
    ${cloud_private_ip} ${client_ip} : PSK "${shared_secret}"
  path: /etc/ipsec.secrets
- content: |
    conn ikev1
      leftauth=psk
      left=${cloud_private_ip}
      leftid=${cloud_public_ip}
      leftsubnet=${cloud_subnet}
      rightauth=psk
      right=${client_ip}
      rightsubnet=${client_subnet}
      auto=add
      keyingtries=%forever
      keyexchange=ikev1
      ikelifetime=8h
      dppaction=restart
      fragmentation=yes
      ike=aes256-sha2_256-modp2048
      esp=aes256-sha2_256-modp2048,aes256gcm128-sha2_256-modp2048
    conn ikev2
      leftauth=psk
      left=${cloud_private_ip}
      leftid=${cloud_public_ip}
      leftsubnet=${cloud_subnet}
      rightauth=psk
      right=${client_ip}
      rightsubnet=${client_subnet}
      auto=add
      keyingtries=%forever
      keyexchange=ikev2
      ikelifetime=8h
      dppaction=restart
      fragmentation=yes
      ike=aes256-sha2_256-modp2048
      esp=aes256-sha2_256-modp2048,aes256gcm128-sha2_256-modp2048
  path: /etc/ipsec.conf
- content: |
    [Unit]
    Description=iperf3 server
    After=syslog.target network.target auditd.service

    [Service]
    Type=simple
    Restart=always
    RestartSec=1
    RemainAfterExit=yes
    ExecStartPre=/usr/bin/sleep 60
    ExecStart=/usr/bin/iperf3 -s

    [Install]
    WantedBy=multi-user.target
  path: /etc/systemd/system/iperf3.service
runcmd:
- [ systemctl, enable, iperf3 ]
- [ systemctl, start, iperf3 ]
