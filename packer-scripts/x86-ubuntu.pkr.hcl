packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

variable "image_name" {
  type    = string
  default = "x86-ubuntu"
}

variable "ssh_password" {
  type    = string
  default = "12345"
}

variable "ssh_username" {
  type    = string
  default = "gipsim"
}

locals {
  iso_data = {
    iso_url       = "http://old-releases.ubuntu.com/releases/18.04.0/ubuntu-18.04-server-amd64.iso"
    iso_checksum  = "md5:1413c9797dbfa1e57fabfb5c91cfb96f"
    iso_path      = "iso/ubuntu-18.04-server-amd64.iso"
  }
  disk_image_path = "./disk-image/x86-disk-image-18-04"
}

source "qemu" "initialize" {
  accelerator      = "kvm"
  boot_command     = [  
                        "<enter><wait><f6><esc><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                        "debian-installer=en_US auto locale=en_US kbd-chooser/method=us ",
                        "file=/floppy/preseed.cfg ",
                        "fb=false debconf/frontend=noninteractive ",
                        "hostname=gipsim ",
                        "/install/vmlinuz noapic ",
                        "initrd=/install/initrd.gz ",
                        "keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA ",
                        "keyboard-configuration/variant=USA console-setup/ask_detect=false ",
                        "passwd/user-fullname=gipsim ",
                        "passwd/user-password=12345 ",
                        "passwd/user-password-again=12345 ",
                        "passwd/username=gipsim ",
                        "-- <enter>"
                    ]
  cpus             = "4"
  disk_size        = "48000"
  format           = "raw"
  headless         = "true"
  http_directory   = "http/x86"
  floppy_files     = ["http/x86/preseed.cfg"]
  iso_checksum     = local.iso_data.iso_checksum
  iso_urls         = [local.iso_data.iso_url]
  iso_target_path  = local.iso_data.iso_path
  memory           = "8192"
  output_directory = local.disk_image_path
  qemu_binary      = "/usr/bin/qemu-system-x86_64"
  qemuargs         = [["-cpu", "host"], ["-display", "none"]]
  shutdown_command = "echo '${var.ssh_password}'|sudo -S shutdown -P now"
  ssh_password     = "${var.ssh_password}"
  ssh_username     = "${var.ssh_username}"
  ssh_wait_timeout = "60m"
  vm_name          = "${var.image_name}"
  ssh_handshake_attempts = "1000"
}

build {
  sources = ["source.qemu.initialize"]

  provisioner "file" {
    destination = "/home/gipsim/"
    source      = "files/serial-getty@.service-override.conf"
  }

  provisioner "file" {
    destination = "/home/gipsim/"
    source      = "files/init.sh"
  }

  provisioner "file" {
    destination = "/home/gipsim/"
    source      = "files/runscript.sh"
  }

  provisioner "file" {
    destination = "/home/gipsim/"
    source      = "benchmarks/spec"
  }

  provisioner "file" {
    destination = "/home/gipsim/"
    source      = "benchmarks/parsec"
  }

  provisioner "file" {
    destination = "/home/gipsim/"
    source      = "benchmarks/npb"
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    inline = [
      "cp /boot/vmlinuz-* /home/gipsim/vmlinuz",
      "cp /boot/initrd.img-* /home/gipsim/initrd.img",
      "chown gipsim:gipsim /home/gipsim/vmlinuz /home/gipsim/initrd.img"
    ]
  }
  
  provisioner "file" {
    source      = "/home/gipsim/vmlinuz"
    destination = "./${local.disk_image_path}/vmlinuz"
    direction   = "download"
  }

  provisioner "file" {
    source      = "/home/gipsim/initrd.img"
    destination = "./${local.disk_image_path}/initrd.img"
    direction   = "download"
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = ["scripts/install-common-packages.sh"]
    environment_vars = ["ISA=x86"]
    expect_disconnect = true
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = [
                        "benchmarks/spec/x86/install.sh",
                        "benchmarks/parsec/x86/install.sh",
                        "benchmarks/npb/x86/install.sh",
                      ]
    expect_disconnect = true
  }
}