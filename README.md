# CCGC 5502 – Automation with Terraform (Group Project)

| Member | Humber ID | Root module |
|---|---|---|
| Ruchi Patel | N10042404 | `project-2404/` |
| Sukrutha Srirangam | ...9654 | `project-9654/` |

Each member deploys their own root module into their own Azure subscription with their own remote backend.

```bash
cd project-XXXX
terraform init
terraform validate
terraform apply --auto-approve
terraform state list | nl   # 48 lines
terraform output
```
