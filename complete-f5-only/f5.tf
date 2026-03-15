provider "aws" {
  region = var.region
}

resource "aws_key_pair" "f5" {
  key_name   = "f5-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqDTxbQUK1GC4u0JMMMUHNJ1+6j7hgoQo6q3HI85NhxyFAWttEWvzgVeLcNfNzEkQ05eIExJSGQbK24a9WD1E1F7fEedkwMNgCSEPnDUkPb4YnP0UTpgLSxuCmhfEy5IBbM42RdBQ+Pxi+PzmgfcoPa6QE6fKbBBuW9dip9EwKvWmZLj7YPweJf1hR71nVBTLy1h8JYbbM97364rowgRGAcKTKc2mCb//JnI/MTmXBfvoU1qWYldJXFXok0n4QRQj6yvzbSguDILkKHU3o36G3KazyfmHmYIpqYSMr7WPpVoGnI4EXyZQt40bipy0R1OZusO6CiMIuwRUoVls2p459 k.skenderidis@f5.com"
}


module bigip_ha_1 {
  source                      = "F5Networks/bigip-module/aws"
  prefix                      = "bigip-01"
  ec2_key_name                = aws_key_pair.f5.key_name
  mgmt_subnet_ids             = [{ "subnet_id" = var.mgmt_1_id, "public_ip" = true, "private_ip_primary" =  var.mgmt_ip_1}]
  mgmt_securitygroup_ids      = [var.sec_group_mgmt_id]
  external_subnet_ids         = [{ "subnet_id" = var.ext_1_id, "public_ip" = true, "private_ip_primary" = var.ext_ip_1, "private_ip_secondary" = var.ext_ip_sec_1}]
  external_securitygroup_ids  = [var.sec_group_ext_id]
  internal_subnet_ids         = [{"subnet_id" =  var.int_1_id, "public_ip"=false, "private_ip_primary" = var.int_ip_1}]
  internal_securitygroup_ids  = [var.sec_group_int_id]
  ebs_volume_size  = 100
  sleep_time                  = "400s"
  f5_ami_search_name          = "F5 BIGIP-17.5* PAYG-Best Plus 25Mbps*"
  custom_user_data = templatefile("templates/f5_onboard.tmpl", {
    bigip_username         = var.username
    ssh_keypair            = file("~/.ssh/id_rsa.pub")
    aws_secretmanager_auth = false
    bigip_password         = var.password
    ext_self_ip            = var.ext_ip_1
    int_self_ip            = var.int_ip_1
    mgmt_ip                = var.mgmt_ip_1
    gateway_ip             = join(".", concat(slice(split(".", var.ext_cidr_block), 0, 3), [1]))  
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
  mgmt_subnet_ids             = [{ "subnet_id" = var.mgmt_2_id, "public_ip" = true, "private_ip_primary" =  var.mgmt_ip_2}]
  mgmt_securitygroup_ids      = [var.sec_group_mgmt_id]
  external_subnet_ids         = [{ "subnet_id" = var.ext_2_id, "public_ip" = true, "private_ip_primary" = var.ext_ip_2, "private_ip_secondary" = var.ext_ip_sec_2}]
  external_securitygroup_ids  = [var.sec_group_ext_id]
  internal_subnet_ids         = [{"subnet_id" =  var.int_2_id, "public_ip"=false, "private_ip_primary" = var.int_ip_2}]
  internal_securitygroup_ids  = [var.sec_group_int_id]
  sleep_time                  = "400s"
  f5_ami_search_name          = "F5 BIGIP-17.5* PAYG-Best Plus 25Mbps*"
  ebs_volume_size  = 100
  custom_user_data = templatefile("templates/f5_onboard.tmpl", {
    bigip_username         = var.username
    ssh_keypair            = file("~/.ssh/id_rsa.pub")
    aws_secretmanager_auth = false
    bigip_password         = var.password
    ext_self_ip            = var.ext_ip_2
    int_self_ip            = var.int_ip_2
    mgmt_ip                = var.mgmt_ip_2
    gateway_ip             = join(".", concat(slice(split(".", var.ext_2_cidr_block), 0, 3), [1]))  
    INIT_URL               = "https://github.com/F5Networks/f5-bigip-runtime-init/releases/download/2.0.3/f5-bigip-runtime-init-2.0.3-1.gz.run",
    DO_URL                 = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.47.0/f5-declarative-onboarding-1.47.0-14.noarch.rpm",
    DO_VER                 = "v1.47.0",
    CFE_URL                = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v2.4.0/f5-cloud-failover-2.4.0-0.noarch.rpm",
    CFE_VER                = "v2.4.0"
  })
}


resource "time_sleep" "wait_10_minutes1" {
  create_duration = "13m"
  depends_on = [module.bigip_ha_1]
}

resource "time_sleep" "wait_10_minutes2" {
  create_duration = "13m"
  depends_on = [module.bigip_ha_2]
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
depends_on = [time_sleep.wait_10_minutes1, time_sleep.wait_10_minutes2]
}