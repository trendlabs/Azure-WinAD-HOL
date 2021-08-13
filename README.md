# Trend Micro XDR Hands-on lab Infra in Azure
the modules section is originally from below project with some customization
*https://github.com/DefensiveOrigins/APT-Lab-Terraform*

## Overview
- Automate the Hands-on lab infra in Azure
- Each attendee will have 2 virtual machines:
  + 1 Jump host (will be referred as Victim 2 / CnC server in the lab Handbook)
  + 1 internal VM (will be referred as Victim 1 in the lab Handbook)
- There is 1 domain controller - DC01 (private IP: 10.10.98.10)
- Each attendee will be provided an email address hosted in Microsoft 365 (business Basic) - valid public domain
- Trend Micro products:
  + Trend Micro CAS needs intergrating to Microsoft 365
  + Apex Central and CAS needs connect to Vision One

## How to use

### Requirements
- Linux machine (*This terraform tested on Ubuntu 20.04 (but Amazon Linux 2 / Centos should be OK*)
- Terraform CLI
- Azure CLI
- Git
- Azure account

### Let's start
- Review and update values in terraform.tfvars.example to match your Azure environment
- Save as new file, name it: terraform.tfvars  
- Review the locals section in file main.tf, and change cidr settings if neccessary to avoid confict with existing resources in same resource group
- When you are ready, open terminal and run below commands:
```
  $ git clone https://github.com/trendlabs/xdr-demo.git
  $ cd xdr-demo
  $ terraform init
  $ terraform plan
  $ terraform apply -auto-approve
```
*Note: terraform needs about 30min to provision labs*

- After infra provisioned, make sure a file ***terraform.tfstate*** generated in the same folder. This file is critical for your to clean up all the labs after the session
- When you finish the hands-on, to clean-up all the infra, run below:
```
  $ terraform destroy -auto-approve
```

## Lab access
- Once terraform finishes the provision, its output contains the RDP Public IPs map to each user lab, some things like below

```
Outputs:

jump_host_public_ip_addresses = [
  [
    "13.84.213.29",
  ],
]
victim_private_ip_address = [
  [
    "10.10.0.4",
  ],
]
```
- User can use configuration that you specified in terraform.tfvars to login

## Things need to do in each lab
- Disable WindowsDefender, Firewall.
- Install AtomicRed (as guided in Handbook)
- Unzip MITRE-DEMO-KIT-master.zip (pass: virus) (can be found in c:\lab-guide)
- Install Apex One in both VMs (link can be found in c:\lab-guide)
- Provide attendee link to Vision One / Apex Central
