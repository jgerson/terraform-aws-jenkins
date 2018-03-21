# Jenkins Installer

Automates the provision of the necessary AWS infrastructure for a Jenkins installation.

Must be run in the HashiCorp SE AWS account to access the hashidemos.io hosted zone.

Final interactive steps are:

- Open the resulting URL `(http://<fqdn>:8080)` to access Jenkins via the web and you will be prompted for a password
- SSH to <fqdn> and access the following path to retrieve your initial password /var/lib/jenkins/secrets/initialAdminPassword
