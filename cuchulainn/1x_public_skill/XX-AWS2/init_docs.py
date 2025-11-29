import os

BASE_DIR = "services"

services = [
    "ec2", "s3", "rds"
]

doc_types = [
    "01_overview.md",
    "02_console_setup.md",
    "03_cloudformation.md",
    "04_terraform.md",
    "05_operations.md",
]

os.makedirs(BASE_DIR, exist_ok=True)

for svc in services:
    svc_dir = os.path.join(BASE_DIR, svc)
    os.makedirs(svc_dir, exist_ok=True)

    for doc in doc_types:
        path = os.path.join(svc_dir, doc)
        with open(path, "w", encoding="utf-8") as f:
            f.write("")
        print("created:", path)
