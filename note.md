## AWS & Terraform Notes

### AWS Services

- **SSM (AWS Systems Manager Parameter Store):**  
    Secure storage for configuration data and secrets. Useful for managing environment variables and sensitive information.

- **AMI (Amazon Machine Image):**  
    A pre-configured template used to launch EC2 instances. Contains the OS, application server, and applications.

---

### Terraform Commands

- `terraform plan -out=plan.tfplan`  
    Generates and saves an execution plan to the file `plan.tfplan`.

- `terraform apply plan.tfplan`  
    Applies the saved plan without prompting for approval again. Useful for automation and ensuring the applied changes match the reviewed plan.

---

**Tip:**  
Always review your Terraform plan before applying to avoid unintended infrastructure changes.