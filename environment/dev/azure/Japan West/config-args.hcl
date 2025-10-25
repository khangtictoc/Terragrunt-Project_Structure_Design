locals {
    parameters = {
        region = ""
        vnet_name = ""
        vnet__rg_name = ""

        appgw_name = ""
        appgw__rg_name = ""
        appgw__gateway_ip_configuration = ""

        aks__kubeconfig_output_path = ""
        aks__name = ""
        aks__rg_name = ""
        aks__vnet_subnet_id = ""
        aks__ingress_appgw_id = ""
        aks__vnet_id = ""
    }
}
