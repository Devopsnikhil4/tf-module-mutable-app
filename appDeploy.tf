resource "null_resource" "app_deploy" {
    triggers = {
        always_run = timestamp()
        # APP_VERSION = var.APP_VERSION
    }
    count       = local.INSTANCE_COUNT
    provisioner "remote-exec" {

        # connection block establishes connection to this
        connection {
        type     = "ssh"
        user     = local.SSH_USER
        password = local.SSH_PASS
        host     = element(local.INSTANCE_IPS, count.index)            # aws_instance.sample.private_ip : Use this only if your provisioner is outside the resource.
        }

        inline = [
           "ansible-pull -U https://github.com/b54-clouddevops/ansible.git -e ENV=dev -e COMPONENT=${var.COMPONENT} -e APP_VERSION=${var.APP_VERSION} roboshop-pull.yml"
        ]
    }
}