# Terragrunt_Project_Structure_Design
Terragrunt (Terraform) - Project structure for multiple platform, environment and region 

## Prerequisite

Check account's limitations

**1. Free Tier - Instance Type**

```bash
aws ec2 describe-instance-types \
  --filters "Name=free-tier-eligible,Values=true" \
  --query "InstanceTypes[].{Type:InstanceType, vCPU:VCpuInfo.DefaultVCpus, MemoryMiB:MemoryInfo.SizeInMiB, Arch:ProcessorInfo.SupportedArchitectures[0]}" \
  --output table
```

Output will be something like this 

```bash
---------------------------------------------------
|              DescribeInstanceTypes              |
+--------+-------------+------------------+-------+
|  Arch  |  MemoryMiB  |      Type        | vCPU  |
+--------+-------------+------------------+-------+
|  x86_64|  4096       |  c7i-flex.large  |  2    |
|  arm64 |  2048       |  t4g.small       |  2    |
|  x86_64|  1024       |  t3.micro        |  2    |
|  arm64 |  1024       |  t4g.micro       |  2    |
|  x86_64|  2048       |  t3.small        |  2    |
|  x86_64|  8192       |  m7i-flex.large  |  2    |
+--------+-------------+------------------+-------+
```

## Getting started

Start to create all resource with

```
 terragrunt run-all destroy --non-interactive
```

Destroy all resources

```
 terragrunt run-all destroy --non-interactive
```

## Project Architecture Design

Go to [My Blog]() for more details.

Reference: [https://github.com/gruntwork-io/terragrunt-infrastructure-live-example](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example)

[![asciicast](https://avatars.githubusercontent.com/u/6506055?v=4)](https://asciinema.org/a/Skp2iV0M6pffFMrsrXf7BtJs5)