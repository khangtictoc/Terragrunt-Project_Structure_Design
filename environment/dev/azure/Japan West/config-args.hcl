locals {
  parameters = {
    rg_name = ""
    region  = ""

    vnet_name    = ""
    vnet_rg_name = ""

    appgw_name                     = ""
    appgw_rg_name                  = ""
    appgw_gateway_ip_configuration = ""

    aks_kubeconfig_output_path = ""
    aks_name                   = ""
    aks_rg_name                = ""
    aks_vnet_subnet_id         = ""
    aks_ingress_appgw_id       = ""
    aks_vnet_id                = ""
  }
}
