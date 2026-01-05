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
  default = "riscv-ubuntu"
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
    # https://old-releases.ubuntu.com/releases/22.04.1/ubuntu-22.04.1-preinstalled-server-riscv64+unmatched.img.xz
    iso_url       = "./iso/ubuntu-22.04.1-preinstalled-server-riscv64+unmatched.img"
    iso_checksum  = "sha256:87341227f621e2c41c0d18d7fd1c01762a3eebeea296edc80b4c69ca174bea7c"
  }
  disk_image_path = "./disk-image/riscv-disk-image-22-04"
}

source "qemu" "initialize" {
  cpus             = "4"
  disk_size        = "32000"
  format           = "raw"
  headless         = "true"
  disk_image       = "true"
  boot_command = [
                  "<wait10><enter>",
                  "<wait120>",
                  "ubuntu<enter><wait>",
                  "ubuntu<enter><wait>",
                  "ubuntu<enter><wait>",
                  "12345678<enter><wait>",
                  "12345678<enter><wait>",
                  "<wait20>",
                  "sudo adduser gipsim<enter><wait10>",
                  "12345<enter><wait10>",
                  "12345<enter><wait10>",
                  "<enter><enter><enter><enter><enter>y<enter><wait>",
                  "sudo usermod -aG sudo gipsim<enter><wait>"
                ]
  iso_checksum     = local.iso_data.iso_checksum
  iso_urls         = [local.iso_data.iso_url]
  memory           = "8192"
  output_directory = local.disk_image_path
  qemu_binary      = "/usr/bin/qemu-system-riscv64"

  qemuargs       = [  ["-bios", "/usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.elf"],
                      ["-machine", "virt"],
                      ["-kernel","/usr/lib/u-boot/qemu-riscv64_smode/uboot.elf"],
                      ["-device", "virtio-vga"],
                      ["-device", "qemu-xhci"],
                      ["-device", "usb-kbd"]
                  ]
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
    environment_vars = ["ISA=riscv"]
    expect_disconnect = true
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = ["benchmarks/spec/riscv/install.sh"]
    expect_disconnect = true
  }
}