source 'https://supermarket.chef.io'

metadata

cookbook 'netatalk', path: '../netatalk'

group :integration do
  cookbook 'apt'
  cookbook 'test', path: './test/fixtures/cookbooks/test'
  cookbook 'jml-defaults', path: '../jml-defaults'
  cookbook 'setup', path: '../setup'
end
