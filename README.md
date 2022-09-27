# Terraform Practice

## Install Terraform

- #### Windows

  - Download .exe file
  - Place to any folder, for example under the `C:/Terraform/`
  - Add environment variable
  - Enter in the terminal

    ```bash
    $ terraform -v
    ```

- #### Mac

  - Enter in the terminal

    ```bash
    $ brew install terraform

    $ terraform -v
    ```

## Start

- **Before deploy**

  ```bash
  $ cp terraform.example.tfvars terraform.tfvars
  ```

- **Check Configuration**

  ```bash
  $ terraform plan
  ```

- **Deploy**

  ```bash
  $ terraform apply
  ```

- **Destroy**

  ```bash
  $ terraform destroy
  ```

- **Deploy specific resource**

  ```bash
  # terraform apply <resource>.<name>
  $ terraform apply aws_instance.terraform_ec2
  ```

- **Destroy specific resource**

  ```bash
  # terraform destroy <resource>.<name>
  $ terraform destroy aws_instance.terraform_ec2
  ```

- **List all resource state**

  ```bash
  $ terraform state list
  ```

- **List specific resource detail**
  ```bash
  # terraform state show <resource>.<name>
  $ terraform state show aws_instance.terraform_ec2
  ```

## Reference

- [Terraform Course - Automate your AWS cloud infrastructure](https://www.youtube.com/watch?v=SLB_c_ayRMo)
- [Terraform CLI Documentation](https://www.terraform.io/cli)
