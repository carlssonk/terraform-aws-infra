#cloud-config
cloud_final_modules:
  - [scripts-user, always]

write_files:
  - path: /var/lib/cloud/scripts/per-boot/user-script.sh
    permissions: '0755'
    content: |
${indent(8, nginx_config)}

runcmd:
  - /var/lib/cloud/scripts/per-boot/user-script.sh