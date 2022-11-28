# Terraform AWS Project #1

## Helpful Definitions

-   VPC:
-   CIDR: Stands for Classless Inter-Domain Routing (also known as supernetting), this was created to help reduce the number of routing tables on routers and slow the rapidly depleting IPv4 addresses. CIDR addresses are made up of two sets of numbers, a prefix and a s suffix (ex. 192.168.123.45/16).

```sh
chmod 400 ec2_key_pair.pem
ssh -i ec2_key_pair.pem ec2-user@<ec2-ip>
```

Push tags with:

```sh
git push origin <tag_name>
```

Create the following `terraform.tfvars` file:
```
aws_region     = "us-east-2"
aws_access_key = ""
aws_secret_key = ""
vpc_cidr = "10.10.0.0/16"
public_subnet_cidr  = "10.10.0.128/26"
private_subnet_cidr = "10.10.0.192/26"
vm_instance_type         = "t3.nano"
vm_has_public_ip_address = true
vm_root_volume_size      = 10
vm_root_volume_type      = "gp3"
vm_data_volume_size      = 10
vm_data_volume_type      = "gp3"
```

Sources
[Making Sense of AWS CIDRs and Subnets](https://virtualizationreview.com/articles/2021/03/26/aws-subnetting.aspx)
[CIDR (Classless Inter-Domain Routing or supernetting)](https://www.techtarget.com/searchnetworking/definition/CIDR)
[List packages installed on Amazon Linux](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/managing-software.html)
[User data and cloud-init directives](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)
[Terraform Security Group Rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)
