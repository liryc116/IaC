terraform {

    required_version = ">= 0.13.0"

    required_providers {
        proxmox = {
            source = "bpg/proxmox"
            version = ">=0.76.0"
        }
    }
}

variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
    sensitive = true
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

provider "proxmox" {
    endpoint = var.proxmox_api_url
    insecure = true
    username = var.proxmox_api_token_id
    api_token =format("%s=%s",var.proxmox_api_token_id,var.proxmox_api_token_secret)
}
