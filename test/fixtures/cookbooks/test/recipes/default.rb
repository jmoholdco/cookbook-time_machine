include_recipe 'time_machine::default'

time_machine_volume 'Time Machine' do
  path '/srv/time_machine'
  allowed_users %w(vagrant)
end
