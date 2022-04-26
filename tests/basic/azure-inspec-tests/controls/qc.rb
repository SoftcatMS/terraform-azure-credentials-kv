# copyright: 2018, The Authors

# Test values

describe azure_key_vaults.where { name.include?('kv-test-basic') } do
  it { should exist }
end

describe azure_key_vault_secret(vault_name: 'kv-test-basic', secret_name: 'password1') do
  it { should exist }
end

describe azure_key_vault_secret(vault_name: 'kv-test-basic', secret_name: 'password2') do
  it { should exist }
end
