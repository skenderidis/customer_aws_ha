resource "aws_key_pair" "f5" {
  key_name   = "f5-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqDTxbQUK1GC4u0JMMMUHNJ1+6j7hgoQo6q3HI85NhxyFAWttEWvzgVeLcNfNzEkQ05eIExJSGQbK24a9WD1E1F7fEedkwMNgCSEPnDUkPb4YnP0UTpgLSxuCmhfEy5IBbM42RdBQ+Pxi+PzmgfcoPa6QE6fKbBBuW9dip9EwKvWmZLj7YPweJf1hR71nVBTLy1h8JYbbM97364rowgRGAcKTKc2mCb//JnI/MTmXBfvoU1qWYldJXFXok0n4QRQj6yvzbSguDILkKHU3o36G3KazyfmHmYIpqYSMr7WPpVoGnI4EXyZQt40bipy0R1OZusO6CiMIuwRUoVls2p459 k.skenderidis@f5.com"
}


module bigip_ha_1 {
  source                      = "F5Networks/bigip-module/aws"
  prefix                      = "bigip-01"
  ec2_key_name                = aws_key_pair.f5.key_name
  mgmt_subnet_ids             = [{ "subnet_id" = aws_subnet.mgmt.id, "public_ip" = true, "private_ip_primary" =  var.mgmt_ip_1}]
  mgmt_securitygroup_ids      = [aws_security_group.mgmt.id]
  external_subnet_ids         = [{ "subnet_id" = aws_subnet.ext.id, "public_ip" = true, "private_ip_primary" = var.ext_ip_1, "private_ip_secondary" = var.ext_ip_sec_1}]
  external_securitygroup_ids  = [aws_security_group.ext.id]
  internal_subnet_ids         = [{"subnet_id" =  aws_subnet.int.id, "public_ip"=false, "private_ip_primary" = var.int_ip_1}]
  internal_securitygroup_ids  = [aws_security_group.int.id]
  ebs_volume_size  = 100
  sleep_time                  = "400s"
  f5_ami_search_name          = "F5 BIGIP-17.5* PAYG-Best Plus 25Mbps*"
  custom_user_data = templatefile("templates/f5_onboard.tmpl", {
    bigip_username         = var.username
    ssh_keypair            = file("~/.ssh/id_rsa.pub")
    aws_secretmanager_auth = false
    bigip_password         = var.password
    INIT_URL               = "https://github.com/F5Networks/f5-bigip-runtime-init/releases/download/2.0.3/f5-bigip-runtime-init-2.0.3-1.gz.run",
    DO_URL                 = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.47.0/f5-declarative-onboarding-1.47.0-14.noarch.rpm",
    DO_VER                 = "v1.47.0",
    CFE_URL                = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v2.4.0/f5-cloud-failover-2.4.0-0.noarch.rpm",
    CFE_VER                = "v2.4.0"
  })
}


module bigip_ha_2 {
  source                      = "F5Networks/bigip-module/aws"
  prefix                      = "bigip-02"
  ec2_key_name                = aws_key_pair.f5.key_name
  mgmt_subnet_ids             = [{ "subnet_id" = aws_subnet.mgmt_2.id, "public_ip" = true, "private_ip_primary" =  var.mgmt_ip_2}]
  mgmt_securitygroup_ids      = [aws_security_group.mgmt.id]
  external_subnet_ids         = [{ "subnet_id" = aws_subnet.ext_2.id, "public_ip" = true, "private_ip_primary" = var.ext_ip_2, "private_ip_secondary" = var.ext_ip_sec_2}]
  external_securitygroup_ids  = [aws_security_group.ext.id]
  internal_subnet_ids         = [{"subnet_id" =  aws_subnet.int_2.id, "public_ip"=false, "private_ip_primary" = var.int_ip_2}]
  internal_securitygroup_ids  = [aws_security_group.int.id]
  sleep_time                  = "400s"
  f5_ami_search_name          = "F5 BIGIP-17.5* PAYG-Best Plus 25Mbps*"
  ebs_volume_size  = 100
  custom_user_data = templatefile("templates/f5_onboard.tmpl", {
    bigip_username         = var.username
    ssh_keypair            = file("~/.ssh/id_rsa.pub")
    aws_secretmanager_auth = false
    bigip_password         = var.password
    INIT_URL               = "https://github.com/F5Networks/f5-bigip-runtime-init/releases/download/2.0.3/f5-bigip-runtime-init-2.0.3-1.gz.run",
    DO_URL                 = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.47.0/f5-declarative-onboarding-1.47.0-14.noarch.rpm",
    DO_VER                 = "v1.47.0",
    CFE_URL                = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v2.4.0/f5-cloud-failover-2.4.0-0.noarch.rpm",
    CFE_VER                = "v2.4.0"
  })
}

resource "time_sleep" "wait_5_minutes1" {
  create_duration = "10m"
  depends_on = [module.bigip_ha_1]
}

resource "time_sleep" "wait_5_minutes2" {
  create_duration = "10m"
  depends_on = [module.bigip_ha_2]
}



data "template_file" "tmpl_bigip1" {
  template = "${file("./templates/onboard_do_3nic_ha.tpl")}"
  vars = {
    hostname      = module.bigip_ha_1.mgmtPublicDNS
    primary       = var.ext_ip_1
    secondary     = var.ext_ip_2
    name_servers  = join(",", formatlist("\"%s\"", ["169.254.169.253"]))
    search_domain = "f5.com"
    ntp_servers   = join(",", formatlist("\"%s\"", ["169.254.169.213"]))
    vlan-name1    = "external"
    self-ip1      = var.ext_ip_1
    vlan-name2    = "internal"
    self-ip2      = var.int_ip_1
    mgmt_ip       = var.mgmt_ip_1
    password      = var.password
    gateway       = join(".", concat(slice(split(".", var.ext_cidr_block), 0, 3), [1]))

  }
  depends_on = [time_sleep.wait_5_minutes1]
}


resource "local_sensitive_file" "do_bigip1" {
  filename = "${path.module}/primary-bigip.json"
  content  = data.template_file.tmpl_bigip1.rendered
}


data "template_file" "tmpl_bigip2" {
  template = "${file("./templates/onboard_do_3nic_ha.tpl")}"
  vars = {
    hostname      = module.bigip_ha_2.mgmtPublicDNS
    primary       = var.ext_ip_1
    secondary     = var.ext_ip_2
    name_servers  = join(",", formatlist("\"%s\"", ["169.254.169.253"]))
    search_domain = "f5.com"
    ntp_servers   = join(",", formatlist("\"%s\"", ["169.254.169.213"]))
    vlan-name1    = "external"
    self-ip1      = var.ext_ip_2
    vlan-name2    = "internal"
    self-ip2      = var.int_ip_2
    mgmt_ip       = var.mgmt_ip_2
    password      = var.password
    gateway       = join(".", concat(slice(split(".", var.ext_2_cidr_block), 0, 3), [1]))
  }
  depends_on = [time_sleep.wait_5_minutes2]
}


resource "local_sensitive_file" "do_bigip2" {
  filename = "${path.module}/secondary-bigip.json"
  content  = data.template_file.tmpl_bigip2.rendered
}



####  Deploy DO with Bash script

resource "null_resource" "do_script_bigip01" {
  provisioner "local-exec" {
    command = "./do-script.sh"
    environment = {
      TF_VAR_bigip_ip  = module.bigip_ha_1.mgmtPublicDNS
      TF_VAR_username  = "admin"
      TF_VAR_password  = var.password
      TF_VAR_json_file = "primary-bigip.json"
      TF_VAR_prefix = "bigip01"
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "ls -la"
    # This is where you can configure the BIGIQ revole API
  } 
  depends_on = [local_sensitive_file.do_bigip1]
}

resource "null_resource" "do_script_bigip02" {
  provisioner "local-exec" {
    command = "./do-script.sh"
    environment = {
      TF_VAR_bigip_ip  = module.bigip_ha_2.mgmtPublicDNS
      TF_VAR_username  = "admin"
      TF_VAR_password  = var.password
      TF_VAR_json_file = "secondary-bigip.json"
      TF_VAR_prefix = "bigip02"
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "ls -la"
    # This is where you can configure the BIGIQ revole API
  }
    depends_on = [local_sensitive_file.do_bigip2]

}



resource "null_resource" "bigip_add_to_trust" {
  provisioner "local-exec" {
    command = "./ha-script.sh"
    environment = {
      TF_VAR_bigip_dns  = module.bigip_ha_1.mgmtPublicDNS
      TF_VAR_username  = "admin"
      TF_VAR_password  = var.password
      TF_VAR_device_ip = var.mgmt_ip_1
      TF_VAR_device_ip_remote = var.mgmt_ip_2
    }
  }
    depends_on = [null_resource.do_script_bigip02, null_resource.do_script_bigip02, ]

}

