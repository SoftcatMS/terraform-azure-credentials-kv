# copyright: 2018, The Authors

# Test values

resource_group1 = 'password-basic-kv-rg'

describe azure_resource_group(name: resource_group1) do
  it { should exist }
end

describe azure_key_vaults.where { name.include?('basic-kv') } do
  it { should exist }
end