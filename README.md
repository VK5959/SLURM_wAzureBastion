# SLURM_wAzureBastion
SLURM setup with MSI Gaming laptops and SSH with Azure Bastion VM

## System Setup
### SLURM Control Node
- **Hostname**: ctlnode
- **OS**: Ubuntu 22.04 LTS
- **Modules**: Miniconda(25.3.1), Pytorch(2.7.0), Tensorflow (2.19.0)
- **NFS**: 1TB Shared Storage

### Compute Nodes
- **Hostname**: computenode[1-4]
- **OS**: Ubuntu 22.04 LTS
- 4 units of MSI Stealth 16 AI Studio A1VGG-029SG with NVIDIA® GeForce RTX™ 4070 Laptop GPU 8GB

### Azure Bastion VM
- **VM Name**: Bastion
- **Region**: SEA
- **VM Size**: Standard B1s
- **OS**: Ubuntu Server 22.04 LTS
- **Username**: `username`
- **Public IP**: `20.***.***.***` (example)
- **Inbound Port Open**: 22 only
- **Reverse Port**: 2222 mapped to ctlnode via reverse SSH

## Pre-requisite Installations
### MUNGE setup 
For more information on Munge please head to `https://github.com/dun/munge`
- Create Munge User and Directories
``` bash
sudo groupadd --system munge
sudo useradd --system --gid munge --home /var/lib/munge --shell /sbin/nologin munge
```

- Create Munge Directories and set correct permissions
``` bash
sudo mkdir -p /etc/munge /var/log/munge /var/lib/munge /run/munge
sudo chown -R munge:munge /etc/munge /var/log/munge /var/lib/munge /run/munge
sudo chmod 0700 /etc/munge /var/log/munge /var/lib/munge /run/munge
```

- Compile and Install Munge
``` bash
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --localstatedir=/var \
    --runstatedir=/run

make -j$(nproc)
sudo make install
```

- Generate Munge Key
``` bash
sudo /usr/sbin/create-munge-key
sudo chown munge:munge /etc/munge/munge.key
sudo chmod 0400 /etc/munge/munge.key
```

- Create and Enable Munge systemd Service
Create as `/etc/systemd/system/munged.service`
``` ini
[Unit]
Description=MUNGE authentication service
After=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/munged --syslog
User=munge
Group=munge
RuntimeDirectory=munge
PIDFile=/run/munge/munged.pid

[Install]
WantedBy=multi-user.target
```

- Reload systemd and enable:
``` bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now munged
```

- Test Munge
``` bash
munge -n | unmunge
```

## SLURM Setup
### Work in Porgress

## SSH connection setup Local-AzureBastionVM-Slurm cluster via reverse SSH tunnel
### Create SSH config file (Windows/Linux)

Create `~/.ssh/config`
``` ssh
Host azure
  HostName <azure-vm-ip>
  User azureuser
  IdentityFile C:/Users/YourName/.ssh/EDICBastion_key.pem

Host slurm
  HostName localhost
  Port 2222
  User slurmuser
  ProxyJump azure
```

