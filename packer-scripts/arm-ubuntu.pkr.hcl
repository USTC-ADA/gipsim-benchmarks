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
  default = "arm-ubuntu"
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
    iso_url        = "http://old-releases.ubuntu.com/releases/18.04.0/ubuntu-18.04-server-arm64.iso"
    iso_checksum   = "md5:b1bd39537613dc5e14d969e0d4091345"
    iso_path       = "iso/ubuntu-18.04-server-arm64.iso"
    http_directory = "http/arm"
  }
  disk_image_path = "./disk-image/arm-disk-image-18-04"
}

variable "use_kvm" {
  type    = string
  default = "false"
  validation {
    condition     = contains(["true", "false"], var.use_kvm)
    error_message = "KVM option must be either 'true' or 'false'."
  }
}

locals {
  qemuargs_base = [
    ["-machine", "virt"],
    ["-boot", "strict=off"],
    ["-bios", "./bios/QEMU_EFI.fd"],
    ["-display", "none"],
    ["-device", "virtio-scsi-device"],
    ["-device", "scsi-cd,drive=cdrom"],
    ["-device", "virtio-blk-device,drive=hd0"],
    ["-drive", "if=none,id=cdrom,media=cdrom,file=${local.iso_data.iso_path}"],
    ["-drive", "if=none,id=hd0,cache=writeback,discard=ignore,format=raw,file=${local.disk_image_path}/${var.image_name}"],
    ["-device", "virtio-gpu-pci"],
    ["-device", "qemu-xhci"],
    ["-device", "usb-kbd"]
  ]

  qemuargs_kvm = concat(local.qemuargs_base,[
    ["-cpu", "host"],
    ["-enable-kvm"]
  ])

  qemuargs_no_kvm = concat(local.qemuargs_base,[
    ["-cpu", "cortex-a57"]
  ])

  qemuargs = var.use_kvm == "true" ? local.qemuargs_kvm : local.qemuargs_no_kvm
}

source "qemu" "initialize" {
  boot_command     = [
                      "c<wait>",
                      "linux /install/vmlinuz auto=true priority=critical url=http://{{.HTTPIP}}:{{.HTTPPort}}/preseed.cfg --- ",
                      "<enter><wait>",
                      "initrd /install/initrd.gz",
                      "<enter><wait>",
                      "boot",
                      "<enter>"
                    ]
  cpus             = "4"
  disk_size        = "48000"
  format           = "raw"
  headless         = "true"
  http_directory   = local.iso_data.http_directory
  iso_checksum     = local.iso_data.iso_checksum
  iso_urls         = [local.iso_data.iso_url]
  iso_target_path  = local.iso_data.iso_path
  memory           = "8192"
  output_directory = local.disk_image_path
  qemu_binary      = "/usr/bin/qemu-system-aarch64"
  qemuargs         = local.qemuargs
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
    environment_vars = ["ISA=arm64"]
    expect_disconnect = true
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = [
                        "benchmarks/spec/arm/install.sh",
                        "benchmarks/npb/arm/install.sh",
                      ]
    expect_disconnect = true
  }
}