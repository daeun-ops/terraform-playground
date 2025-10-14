# File Structure

for-expression-basic/
├─ README.md
├─ versions.tf
├─ variables.tf
└─ main.tf



# Terraform For-Expression Basics

This module showcases clean, production-ready patterns for Terraform `for` expressions:
- `[]` vs `{}` output types (list/tuple vs map/object)
- Iterating maps with `key, value`
- Filtering with `if`
- Ordering & deduplication with `toset()`, `sort()`, `keys()`
- Nested loops with `flatten()` (Cartesian product)
- Group-by patterns using `distinct()` and nested comprehensions
- Data shape transforms using `zipmap()` and `transpose()`

No cloud resources are created — applying this project is safe.  
All results are shown as Terraform outputs.

## Quick Start
```bash
terraform init
terraform apply
