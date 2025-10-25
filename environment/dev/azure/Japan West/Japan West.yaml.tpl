vnet_list:
  main:
    created: true
    name: ${vnet_name}
    location: ${region}
    resource_group_name: ${vnet__rg_name}
    address_space:
      - 10.0.0.0/16
    subnets:
      - name: network_appliances
        address_prefixes:
          - 10.0.0.0/24
      - name: workloads
        address_prefixes:
          - 10.0.64.0/18

application_gateway_list:
  main:
    created: true
    sku:
      name: "Standard_v2"
      tier: "Standard_v2"
      capacity: 1
    name: ${appgw_name}
    resource_group_name: ${appgw__rg_name}
    location: ${region}

    frontend_ip_configuration: {}
    http_listener:
      protocol: "Http"
    frontend_port:
      port: 80
    gateway_ip_configuration:
      vnet_name: TESTPROJECT-DEV-GENERAL-00
      subnet_name: network_appliances

    backend_address_pool: {}
    backend_http_settings:
      cookie_based_affinity: "Disabled"
      path: "/path1/"
      port: 80
      protocol: "Http"
      request_timeout: 60
    request_routing_rule:
      rule_type: "Basic"
      priority: 1
