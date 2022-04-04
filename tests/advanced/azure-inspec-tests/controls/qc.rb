# copyright: 2018, The Authors

# Test values

resource_group1 = 'password-advanced-kv-rg'


describe azure_resource_group(name: resource_group1) do
  it { should exist }
end

describe azure_key_vault(resource_group: resource_group1, name: 'password-adv-kv') do
  it            { should exist }
end

describe azure_key_vault_secret(vault_name: 'password-adv-kv', secret_name: 'password1') do
  it { should exist }
end

describe azure_key_vault_secret(vault_name: 'password-adv-kv', secret_name: 'password2') do
  it { should exist }
end

describe azure_key_vault_secret(vault_name: 'password-adv-kv', secret_name: 'web-2') do
  it { should exist }
end