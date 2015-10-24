include_recipe 'time_machine::default'

time_machine_volume 'one' do
  path '/srv/tm_one'
  allowed_users %w(vagrant)
end

time_machine_volume 'two' do
  path '/srv/tm_two'
  allowed_users %w(vagrant)
end
