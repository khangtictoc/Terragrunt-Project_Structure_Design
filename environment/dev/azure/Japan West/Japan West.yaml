vnet_lists:
  main:
    created: true
    name: ${vnet_name}
    location: ${region}
    resource_group_name: sample-labs
    address_space:
      - 10.0.0.0/16
    subnets:
      - name: network_appliances
        address_prefixes:
          - 10.0.0.0/24
      - name: workloads
        address_prefixes:
          - 10.0.64.0/18
