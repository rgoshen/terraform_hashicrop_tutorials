# Terraform Hashicorp Tutorials

## Table of Contents

- [Terraform Hashicorp Tutorials](#terraform-hashicorp-tutorials)
  - [Table of Contents](#table-of-contents)
  - [Get Started - AWS](#get-started---aws)
    - [What is Infrastructure as Code (IaC) with Terraform?](#what-is-infrastructure-as-code-iac-with-terraform)
      - [Manage any infrastructure](#manage-any-infrastructure)
      - [Standardize your deployment workflow](#standardize-your-deployment-workflow)
      - [Track your infrastructure](#track-your-infrastructure)
      - [Collaborate](#collaborate)
    - [Commands](#commands)
    - [Build Infrastructure](#build-infrastructure)
      - [Write configuration](#write-configuration)
      - [Initialize the directory](#initialize-the-directory)
      - [Format and validate the configuration](#format-and-validate-the-configuration)
      - [Create infrastructure](#create-infrastructure)
      - [Inspect state](#inspect-state)
        - [Manually Managing State](#manually-managing-state)
      - [Troubleshooting](#troubleshooting)
    - [Change Infrastructure](#change-infrastructure)
      - [Configuration](#configuration)
      - [Apply Changes](#apply-changes)
    - [Destroy Infrastructure](#destroy-infrastructure)
      - [Destroy](#destroy)
    - [Define Input Variables](#define-input-variables)
      - [Set the instance name with a variable](#set-the-instance-name-with-a-variable)
      - [Apply your configuration](#apply-your-configuration)
    - [Query Data with Outputs](#query-data-with-outputs)
      - [Output EC2 instance configuration](#output-ec2-instance-configuration)
      - [Inspect output values](#inspect-output-values)
      - [Destroy infrastructure](#destroy-infrastructure-1)
    - [Store Remote State](#store-remote-state)

## Get Started - AWS

[tutorial](https://developer.hashicorp.com/terraform/tutorials/aws-get-started)

### What is Infrastructure as Code (IaC) with Terraform?

[tutorial](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code)

- allow you to manage infrastructure with configuration files rather than through a graphical user interface
- allow you to build, change, and manage your infrastructure in a safe, consistent, and repeatable way by defining resource configurations that you can version, reuse, and share

Terraform is HashiCorp's IaC. You can define resources and infrastructure in human-readable, declarative configuration files, and manages your infrastructure's lifecycle

Advantages over manual management:

- Terraform can manage infrastructure on multiple cloud platforms
- The human-readable configuration language helps you write infrastructure code quickly
- Terraform's state allows you to track resource changes throughout your deployments
- You can commit your configurations to version control to safely collaborate on infrastructure

#### Manage any infrastructure

Terraform plugins called providers let Terraform interact with cloud platforms and other services via their application programming interfaces (APIs). Find providers for many of the platforms and services you already use in the [Terraform Registry](https://registry.terraform.io/browse/providers).

#### Standardize your deployment workflow

Providers define individual units of infrastructure, for example compute instances or private networks, as resources. You can compose resources from different providers into reusable Terraform configurations called modules, and manage them with a consistent language and workflow.

Terraform's configuration language is declarative, meaning that it describes the desired end-state for your infrastructure, in contrast to procedural programming languages that require step-by-step instructions to perform tasks. Terraform providers automatically calculate dependencies between resources to create or destroy them in the correct order.

![overview](/assets/images/terraform_overview.png)

To deploy infrastructure with Terraform:

- **Scope** - Identify the infrastructure for your project.
- **Author** - Write the configuration for your infrastructure.
- **Initialize** - Install the plugins Terraform needs to manage the infrastructure.
- **Plan** - Preview the changes Terraform will make to match your configuration.
- **Apply** - Make the planned changes.

#### Track your infrastructure

Terraform keeps track of your real infrastructure in a state file, which acts as a source of truth for your environment. Terraform uses the state file to determine the changes to make to your infrastructure so that it will match your configuration.

#### Collaborate

Terraform allows you to collaborate on your infrastructure with its remote state backends. When you use Terraform Cloud (free for up to five users), you can securely share your state with your teammates, provide a stable environment for Terraform to run in, and prevent race conditions when multiple people make configuration changes at once.

You can also connect Terraform Cloud to version control systems (VCSs) like GitHub, GitLab, and others, allowing it to automatically propose infrastructure changes when you commit configuration changes to VCS. This lets you manage changes to your infrastructure through version control, as you would with application code.

### Commands

| Command                | Action                                      |
| ---------------------- | ------------------------------------------- |
| `terraform init`       | Initialize the project                      |
| `terraform apply`      | Provisions what ever resource is configured |
| `terraform destroy`    | Stops the resource                          |
| `terraform fmt`        | Format your configuration                   |
| `terraform validate`   | Validate your configuration                 |
| `terraform show`       | Inspect current state                       |
| `terraform state`      | Advance state management                    |
| `terraform state list` | List of resources in project's state        |
| `terraform destroy`    | Terminates resources managed by your Terraform project        |
| `terraform output`    | Prints output values to the screen when you apply your configuration      |

### Build Infrastructure

[tutorial](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build)

#### Write configuration

The set of files used to describe infrastructure in Terraform is known as a Terraform _configuration_. You will write your first configuration to define a single AWS EC2 instance.

Each Terraform configuration must be in its own working directory.

> **Tip:** The AMI ID used in this configuration is specific to the `us-west-2` region. If you would like to use a different region, see the [Troubleshooting section](#troubleshooting) for guidance.

```bash
mkdir <directory> && cd <directory>
touch main.tf
```

```json
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
```

This is a complete configuration that you can deploy with Terraform. The following sections review each block of this configuration in more detail.

**Terraform Block**
The `terraform {}` block contains Terraform settings, including the required providers Terraform will use to provision your infrastructure. For each provider, the `source` attribute defines an optional hostname, a namespace, and the provider type. Terraform installs providers from the [Terraform Registry](https://registry.terraform.io/) by default. In this example configuration, the `aws` provider's source is defined as `hashicorp/aws`, which is shorthand for `registry.terraform.io/hashicorp/aws`.

You can also set a version constraint for each provider defined in the `required_providers` block. The `version` attribute is optional, but we recommend using it to constrain the provider version so that Terraform does not install a version of the provider that does not work with your configuration. If you do not specify a provider version, Terraform will automatically download the most recent version during initialization.

To learn more, reference the [provider source documentation](https://developer.hashicorp.com/terraform/language/providers/requirements).

**Providers**
The `provider` block configures the specified provider, in this case `aws`. A provider is a plugin that Terraform uses to create and manage your resources.

You can use multiple provider blocks in your Terraform configuration to manage resources from different providers. You can even use different providers together. For example, you could pass the IP address of your AWS EC2 instance to a monitoring resource from DataDog.

**Resources**
Use `resource` blocks to define components of your infrastructure. A resource might be a physical or virtual component such as an EC2 instance, or it can be a logical resource such as a Heroku application.

Resource blocks have two strings before the block: the resource type and the resource name. In this example, the resource type is `aws_instance` and the name is `app_server`. The prefix of the type maps to the name of the provider. In the example configuration, Terraform manages the `aws_instance` resource with the `aws` provider. Together, the resource type and resource name form a unique ID for the resource. For example, the ID for your EC2 instance is `aws_instance.app_server`.

Resource blocks contain arguments which you use to configure the resource. Arguments can include things like machine sizes, disk image names, or VPC IDs. Our [providers reference](https://developer.hashicorp.com/terraform/language/providers) lists the required and optional arguments for each resource. For your EC2 instance, the example configuration sets the AMI ID to an Ubuntu image, and the instance type to `t2.micro`, which qualifies for AWS' free tier. It also sets a tag to give the instance a name.

#### Initialize the directory

When you create a new configuration — or check out an existing configuration from version control — you need to initialize the directory with `terraform init`.

Initializing a configuration directory downloads and installs the providers defined in the configuration, which in this case is the `aws` provider.

Initialize the directory.

```bash
terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 4.16"...
- Installing hashicorp/aws v4.17.0...
- Installed hashicorp/aws v4.17.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Terraform downloads the `aws` provider and installs it in a hidden subdirectory of your current working directory, named `.terraform`. The `terraform init` command prints out which version of the provider was installed. Terraform also creates a lock file named `.terraform.lock.hcl` which specifies the exact provider versions used, so that you can control when you want to update the providers used for your project.

#### Format and validate the configuration

We recommend using consistent formatting in all of your configuration files. The `terraform fmt` command automatically updates configurations in the current directory for readability and consistency.

Format your configuration. Terraform will print out the names of the files it modified, if any. In this case, your configuration file was already formatted correctly, so Terraform won't return any file names.

```bash
terraform fmt
```

You can also make sure your configuration is syntactically valid and internally consistent by using the `terraform validate` command.

Validate your configuration. The example configuration provided above is valid, so Terraform will return a success message.

```bash
terraform validate

Success! The configuration is valid.
```

#### Create infrastructure

Apply the configuration now with the `terraform apply` command. Terraform will print output similar to what is shown below. We have truncated some of the output to save space.

```bash
 terraform apply

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

   # aws_instance.app_server will be created
  + resource "aws_instance" "app_server" {
      + ami                          = "ami-830c94e3"
      + arn                          = (known after apply)
##...

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

> **Tip:** If your configuration fails to apply, you may have customized your region or removed your default VPC. Refer to the [troubleshooting section](#troubleshooting) of this tutorial for help.

Before it applies any changes, Terraform prints out the _execution plan_ which describes the actions Terraform will take in order to change your infrastructure to match the configuration.

The output format is similar to the diff format generated by tools such as Git. The output has a `+` next to `aws_instance.app_server`, meaning that Terraform will create this resource. Beneath that, it shows the attributes that will be set. When the value displayed is `(known after apply)`, it means that the value will not be known until the resource is created. For example, AWS assigns Amazon Resource Names (ARNs) to instances upon creation, so Terraform cannot know the value of the `arn` attribute until you apply the change and the AWS provider returns that value from the AWS API.

Terraform will now pause and wait for your approval before proceeding. If anything in the plan seems incorrect or dangerous, it is safe to abort here before Terraform modifies your infrastructure.

In this case the plan is acceptable, so type `yes` at the confirmation prompt to proceed. Executing the plan will take a few minutes since Terraform waits for the EC2 instance to become available.

```bash
  Enter a value: yes

aws_instance.app_server: Creating...
aws_instance.app_server: Still creating... [10s elapsed]
aws_instance.app_server: Still creating... [20s elapsed]
aws_instance.app_server: Still creating... [30s elapsed]
aws_instance.app_server: Creation complete after 36s [id=i-01e03375ba238b384]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

You have now created infrastructure using Terraform! Visit the [EC2 console](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Instances:) and find your new EC2 instance.

> **Note:** Per the `aws` provider block, your instance was created in the `us-west-2` region. Ensure that your AWS Console is set to this region.

#### Inspect state

When you applied your configuration, Terraform wrote data into a file called `terraform.tfstate`. Terraform stores the IDs and properties of the resources it manages in this file, so that it can update or destroy those resources going forward.

The Terraform state file is the only way Terraform can track which resources it manages, and often contains sensitive information, so you must store your state file securely and restrict access to only trusted team members who need to manage your infrastructure. In production, we recommend [storing your state remotely](https://developer.hashicorp.com/terraform/tutorials/cloud/cloud-migrate) with Terraform Cloud or Terraform Enterprise. Terraform also supports several other [remote backends](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) you can use to store and manage your state.

Inspect the current state using `terraform show`.

```bash
 terraform show
# aws_instance.app_server:
resource "aws_instance" "app_server" {
    ami                          = "ami-830c94e3"
    arn                          = "arn:aws:ec2:us-west-2:561656980159:instance/i-01e03375ba238b384"
    associate_public_ip_address  = true
    availability_zone            = "us-west-2c"
    cpu_core_count               = 1
    cpu_threads_per_core         = 1
    disable_api_termination      = false
    ebs_optimized                = false
    get_password_data            = false
    hibernation                  = false
    id                           = "i-01e03375ba238b384"
    instance_state               = "running"
    instance_type                = "t2.micro"
    ipv6_address_count           = 0
    ipv6_addresses               = []
    monitoring                   = false
    primary_network_interface_id = "eni-068d850de6a4321b7"
    private_dns                  = "ip-172-31-0-139.us-west-2.compute.internal"
    private_ip                   = "172.31.0.139"
    public_dns                   = "ec2-18-237-201-188.us-west-2.compute.amazonaws.com"
    public_ip                    = "18.237.201.188"
    secondary_private_ips        = []
    security_groups              = [
        "default",
    ]
    source_dest_check            = true
    subnet_id                    = "subnet-31855d6c"
    tags                         = {
        "Name" = "ExampleAppServerInstance"
    }
    tenancy                      = "default"
    vpc_security_group_ids       = [
        "sg-0edc8a5a",
    ]

    credit_specification {
        cpu_credits = "standard"
    }

    enclave_options {
        enabled = false
    }

    metadata_options {
        http_endpoint               = "enabled"
        http_put_response_hop_limit = 1
        http_tokens                 = "optional"
    }

    root_block_device {
        delete_on_termination = true
        device_name           = "/dev/sda1"
        encrypted             = false
        iops                  = 0
        tags                  = {}
        throughput            = 0
        volume_id             = "vol-031d56cc45ea4a245"
        volume_size           = 8
        volume_type           = "standard"
    }
}
```

When Terraform created this EC2 instance, it also gathered the resource's metadata from the AWS provider and wrote the metadata to the state file. In later tutorials, you will modify your configuration to reference these values to configure other resources and output values.

##### Manually Managing State

Terraform has a built-in command called `terraform state` for advanced state management. Use the `list` subcommand to list of the resources in your project's state.

```bash
terraform state list
aws_instance.app_server
```

#### Troubleshooting

If `terraform validate` was successful and your apply still failed, you may be encountering one of these common errors.

- **If you use a region other than** `us-west-2`, you will also need to change your `ami`, since AMI IDs are region-specific. Choose an AMI ID specific to your region by following [these instructions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html#finding-quick-start-ami), and modify main.tf with this ID. Then re-run `terraform apply`.

- **If you do not have a default VPC in your AWS account in the correct region**, navigate to the AWS VPC Dashboard in the web UI, create a new VPC in your region, and associate a subnet and security group to that VPC. Then add the security group ID (`vpc_security_group_ids`) and subnet ID (`subnet_id`) arguments to your `aws_instance` resource, and replace the values with the ones from your new security group and subnet.

```bash
 resource "aws_instance" "app_server" {
   ami                    = "ami-830c94e3"
   instance_type          = "t2.micro"
+  vpc_security_group_ids = ["sg-0077..."]
+  subnet_id              = "subnet-923a..."
 }
```

Save the changes to `main.tf`, and re-run `terraform apply`.

Remember to add these lines to your configuration for later tutorials. For more information, [review this document](https://docs.aws.amazon.com/vpc/latest/userguide/working-with-vpcs.html) from AWS on working with VPCs.

> **NOTE:** Also check to make sure when you select your AMI for your region, you pay attention to the cpu architecture and pick the correct `instance_type`

### Change Infrastructure

Infrastructure is continuously evolving, and Terraform helps you manage that change. As you change Terraform configurations, Terraform builds an execution plan that only modifies what is necessary to reach your desired state.

When using Terraform in production, it is recommend that you use a version control system to manage your configuration files, and store your state in a remote backend such as Terraform Cloud or Terraform Enterprise.

#### Configuration

Now update the `ami` of your instance. Change the `aws_instance.app_server` resource under the provider block in `main.tf` by replacing the current AMI ID with a new one.

> **TIP:** The below snippet is formatted as a diff to give you context about which parts of your configuration you need to change.  Replace the content displayed in red with the content displayed in green, leaving out the leading `+` and `-` signs.

> **Note:** The new AMI ID used in this configuration is specific to the `us-west-2` region.  If you are working in a different region, be sure to select an appropriate AMI for that region by following [these instructions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html#finding-quick-start-ami).

```bash
resource "aws_instance" "app_server" {
-   ami           = "ami-830c94e3"
+   ami           = "ami-08d70e59c07c61a3a"
    instance_type = "t2.micro"
}
```

This update changes the AMI to an Ubuntu 16.04 AMI. The AWS provider knows that it cannot change the AMI of an instance after it has been created, so Terraform will destroy the old instance and create a new one.

#### Apply Changes

After changing the configuration, run `terraform apply` again to see how Terraform will apply this change to the existing resources.

```bash
terraform apply
aws_instance.app_server: Refreshing state... [id=i-01e03375ba238b384]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:



 # aws_instance.app_server must be replaced
-/+ resource "aws_instance" "app_server" {
      ~ ami                          = "ami-830c94e3" -> "ami-08d70e59c07c61a3a" # forces replacement
      ~ arn                          = "arn:aws:ec2:us-west-2:561656980159:instance/i-01e03375ba238b384" -> (known after apply)

#...

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

The prefix `-/+` means that Terraform will destroy and recreate the resource, rather than updating it in-place. Terraform can update some attributes in-place (indicated with the `~` prefix), but changing the AMI for an EC2 instance requires recreating it. Terraform handles these details for you, and the execution plan displays what Terraform will do.

Additionally, the execution plan shows that the AMI change is what forces Terraform to replace the instance. Using this information, you can adjust your changes to avoid destructive updates if necessary.

Once again, Terraform prompts for approval of the execution plan before proceeding. Answer `yes` to execute the planned steps.

```bash
  Enter a value: yes

aws_instance.app_server: Destroying... [id=i-01e03375ba238b384]
aws_instance.app_server: Still destroying... [id=i-01e03375ba238b384, 10s elapsed]
aws_instance.app_server: Still destroying... [id=i-01e03375ba238b384, 20s elapsed]
aws_instance.app_server: Still destroying... [id=i-01e03375ba238b384, 30s elapsed]
aws_instance.app_server: Still destroying... [id=i-01e03375ba238b384, 40s elapsed]
aws_instance.app_server: Destruction complete after 42s
aws_instance.app_server: Creating...
aws_instance.app_server: Still creating... [10s elapsed]
aws_instance.app_server: Still creating... [20s elapsed]
aws_instance.app_server: Still creating... [30s elapsed]
aws_instance.app_server: Still creating... [40s elapsed]
aws_instance.app_server: Creation complete after 50s [id=i-0fd4a35969bd21710]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

As indicated by the execution plan, Terraform first destroyed the existing instance and then created a new one in its place. You can use `terraform show` again to have Terraform print out the new values associated with this instance.

### Destroy Infrastructure

Once you no longer need infrastructure, you may want to destroy it to reduce your security exposure and costs. For example, you may remove a production environment from service, or manage short-lived environments like build or testing systems. In addition to building and modifying infrastructure, Terraform can destroy or recreate the infrastructure it manages.

#### Destroy

The `terraform destroy` command terminates resources managed by your Terraform project. This command is the inverse of `terraform apply` in that it terminates all the resources specified in your Terraform state. It does _not_ destroy resources running elsewhere that are not managed by the current Terraform project.

Destroy the resources you created.

```bash
 terraform destroy
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:



 # aws_instance.app_server will be destroyed
  - resource "aws_instance" "app_server" {
      - ami                          = "ami-08d70e59c07c61a3a" -> null
      - arn                          = "arn:aws:ec2:us-west-2:561656980159:instance/i-0fd4a35969bd21710" -> null

#...

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

The `-` prefix indicates that the instance will be destroyed. As with apply, Terraform shows its execution plan and waits for approval before making any changes.

Answer `yes` to execute this plan and destroy the infrastructure.

```bash
Enter a value: yes

aws_instance.app_server: Destroying... [id=i-0fd4a35969bd21710]
aws_instance.app_server: Still destroying... [id=i-0fd4a35969bd21710, 10s elapsed]
aws_instance.app_server: Still destroying... [id=i-0fd4a35969bd21710, 20s elapsed]
aws_instance.app_server: Still destroying... [id=i-0fd4a35969bd21710, 30s elapsed]
aws_instance.app_server: Destruction complete after 31s

Destroy complete! Resources: 1 destroyed.
```

Just like with `apply`, Terraform determines the order to destroy your resources. In this case, Terraform identified a single instance with no other dependencies, so it destroyed the instance. In more complicated cases with multiple resources, Terraform will destroy them in a suitable order to respect dependencies.

### Define Input Variables

#### Set the instance name with a variable

The current configuration includes a number of hard-coded values. Terraform variables allow you to write configuration that is flexible and easier to re-use.

Add a variable to define the instance name.

Create a new file called `variables.tf` with a block defining a new `instance_name` variable.

```bash
variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}
```

> **Note:** Terraform loads all files in the current directory ending in `.tf`, so you can name your configuration files however you choose.

In `main.tf`, update the `aws_instance` resource block to use the new variable. The `instance_name` variable block will default to its default value ("ExampleAppServerInstance") unless you declare a different value.

```bash
 resource "aws_instance" "app_server" {
   ami           = "ami-08d70e59c07c61a3a"
   instance_type = "t2.micro"

   tags = {
-    Name = "ExampleAppServerInstance"
+    Name = var.instance_name
   }
 }

```

#### Apply your configuration

Apply the configuration. Respond to the confirmation prompt with a `yes`.

```bash
 terraform apply

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:



 # aws_instance.app_server will be created
  + resource "aws_instance" "app_server" {
      + ami                          = "ami-08d70e59c07c61a3a"
      + arn                          = (known after apply)

#...

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.app_server: Creating...
aws_instance.app_server: Still creating... [10s elapsed]
aws_instance.app_server: Still creating... [20s elapsed]
aws_instance.app_server: Still creating... [30s elapsed]
aws_instance.app_server: Still creating... [40s elapsed]
aws_instance.app_server: Creation complete after 50s [id=i-0bf954919ed765de1]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Now apply the configuration again, this time overriding the default instance name by passing in a variable using the `-var` flag. Terraform will update the instance's `Name` tag with the new name. Respond to the confirmation prompt with yes.

```bash
terraform apply -var "instance_name=YetAnotherName"
aws_instance.app_server: Refreshing state... [id=i-0bf954919ed765de1]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:



 aws_instance.app_server will be updated in-place
  ~ resource "aws_instance" "app_server" {
        id                           = "i-0bf954919ed765de1"
      ~ tags                         = {
          ~ "Name" = "ExampleAppServerInstance" -> "YetAnotherName"
        }


 (26 unchanged attributes hidden)






 (4 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.app_server: Modifying... [id=i-0bf954919ed765de1]
aws_instance.app_server: Modifications complete after 7s [id=i-0bf954919ed765de1]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

Setting variables via the command-line will not save their values. Terraform supports many ways to use and set variables so you can avoid having to enter them repeatedly as you execute commands. To learn more, follow our in-depth tutorial, [Customize Terraform Configuration with Variables](https://developer.hashicorp.com/terraform/tutorials/configuration-language/variables).

### Query Data with Outputs

#### Output EC2 instance configuration

Create a file called `outputs.tf` in your `learn-terraform-aws-instance` directory.

Add the configuration below to `outputs.tf` to define outputs for your EC2 instance's ID and IP address.

```bash
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}
```

#### Inspect output values

You must apply this configuration before you can use these output values. Apply your configuration now. Respond to the confirmation prompt with `yes`.

```bash
 terraform apply
aws_instance.app_server: Refreshing state... [id=i-0bf954919ed765de1]

Changes to Outputs:
  + instance_id        = "i-0bf954919ed765de1"
  + instance_public_ip = "54.186.202.254"

You can apply this plan to save these new output values to the Terraform state,
without changing any real infrastructure.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

instance_id = "i-0bf954919ed765de1"
instance_public_ip = "54.186.202.254"
```

Terraform prints output values to the screen when you apply your configuration. Query the outputs with the `terraform output` command.

```bash
terraform output
instance_id = "i-0bf954919ed765de1"
instance_public_ip = "54.186.202.254"
```

You can use Terraform outputs to connect your Terraform projects with other parts of your infrastructure, or with other Terraform projects. To learn more, follow our in-depth tutorial, [Output Data from Terraform](https://developer.hashicorp.com/terraform/tutorials/configuration-language/outputs).

#### Destroy infrastructure

> **Tip:** If you plan to continue to later tutorials, skip this destroy step.

Destroy your infrastructure. Respond to the confirmation prompt with `yes`.

```bash
 terraform destroy

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:



 # aws_instance.app_server will be destroyed
  - resource "aws_instance" "app_server" {
      - ami                          = "ami-08d70e59c07c61a3a" -> null
      - arn                          = "arn:aws:ec2:us-west-2:561656980159:instance/i-0bf954919ed765de1" -> null

#...

Plan: 0 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  - instance_id        = "i-0bf954919ed765de1" -> null
  - instance_public_ip = "54.186.202.254" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_instance.app_server: Destroying... [id=i-0bf954919ed765de1]
aws_instance.app_server: Still destroying... [id=i-0bf954919ed765de1, 10s elapsed]
aws_instance.app_server: Still destroying... [id=i-0bf954919ed765de1, 20s elapsed]
aws_instance.app_server: Still destroying... [id=i-0bf954919ed765de1, 30s elapsed]
aws_instance.app_server: Destruction complete after 31s

Destroy complete! Resources: 1 destroyed.
```

### Store Remote State
