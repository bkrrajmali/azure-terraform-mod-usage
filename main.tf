provider "azurerm" {
  features {}
  subscription_id = "202d4be6-e0dd-4b9e-84b7-e235d53271a8"
}

module "rg" {
  source   = "git::https://github.com/bkrrajmali/azure-terraform-modules/tree/prod/modules/resource-group?ref=prod"
  name     = var.resource_group_name
  location = var.location
}

module "vnet" {
  source              = "git::https://github.com/bkrrajmali/azure-terraform-modules/tree/prod/moduless/vnet?ref=prod"
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = module.rg.name
}

module "subnet" {
  source               = "git::https://github.com/bkrrajmali/azure-terraform-modules/tree/prod/modules/subnet?ref=prod"
  name                 = var.subnet_name
  resource_group_name  = module.rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "pip" {
  source              = ".git::https://github.com/bkrrajmali/azure-terraform-modules/tree/prod/modules/public-ip?ref=prod"
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = module.rg.name
}

module "nsg" {
  source              = "git::https://github.com/bkrrajmali/azure-terraform-modules/tree/prod/modules/nsg?ref=prod"
  name                = var.nsg_name
  location            = var.location
  resource_group_name = module.rg.name
}

module "nic" {
  source              = "git::https://github.com/bkrrajmali/azure-terraform-modules/tree/prod/modules/nic?ref=prod"
  name                = var.nic_name
  location            = var.location
  resource_group_name = module.rg.name
  subnet_id           = module.subnet.id
  public_ip_id        = module.pip.id
  nsg_id              = module.nsg.id
}

module "vm" {
  source              = "git::https://github.com/bkrrajmali/azure-terraform-modules/tree/prod/modules/vm?ref=prod"
  name                = var.vm_name
  location            = var.location
  resource_group_name = module.rg.name
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  nic_id              = module.nic.id
}
