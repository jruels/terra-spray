resource "null_resource" "ansible-provision" {
  depends_on = ["aws_instance.k8s-master", "aws_instance.aws-k8s-members"]

  provisioner "local-exec" {
    command = "echo \"[kube-master]\" > kargo/inventory/inventory"
  }

  provisioner "local-exec" {
    command = "echo \"${format("%s ansible_ssh_user=%s", aws_instance.k8s-master.0.public_ip, var.ssh_user)}\" >> kargo/inventory/inventory"
  }
  provisioner "local-exec" {
    command = "echo \"[etcd]\" >> kargo/inventory/inventory"
  }

  provisioner "local-exec" {
    command = "echo \"${format("%s ansible_ssh_user=%s", aws_instance.k8s-master.0.public_ip, var.ssh_user)}\" >> kargo/inventory/inventory"
  }

  provisioner "local-exec" {
    command = "echo \"[kube-node]\" >> kargo/inventory/inventory"
  }

  provisioner "local-exec" {
    command = "echo \"${join("\n",formatlist("%s ansible_ssh_user=%s", aws_instance.aws-k8s-members.*.public_ip, var.ssh_user))}\" >> kargo/inventory/inventory"
  }

  provisioner "local-exec" {
    command =  "echo \"\n[k8s-cluster:children]\nkube-node\nkube-master\" >> kargo/inventory/inventory"
  }

}
 