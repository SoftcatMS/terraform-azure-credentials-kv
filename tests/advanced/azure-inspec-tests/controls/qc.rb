# copyright: 2018, The Authors

# Test values

resource_group1 = 'rg-test-kv-adv-resources'


describe azure_resource_group(name: resource_group1) do
  it { should exist }
end

describe azure_key_vaults.where { name.include?('kv-test-adv') } do
  it { should exist }
end

describe azure_key_vault_secret(vault_name: 'kv-test-adv', secret_name: 'password1') do
  it { should exist }
end

describe azure_key_vault_secret(vault_name: 'kv-test-adv', secret_name: 'password2') do
  it { should exist }
end

describe azure_key_vault_secret(vault_name: 'kv-test-adv', secret_name: 'web-2') do
  it { should exist }
end

describe azure_virtual_machine(resource_group: resource_group1, name: 'linux-sshkey-test-adv-vm') do
  it { should exist }
end

describe azure_virtual_machine(resource_group: resource_group1, name: 'linux-password-test-adv-vm-vmLinux-0') do
  it { should exist }
end