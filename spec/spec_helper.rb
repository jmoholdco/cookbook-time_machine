require 'chefspec'
require 'chefspec/berkshelf'
require 'chef-vault/test_fixtures'

require_relative 'support/shared_examples'

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  else
    config.default_formatter = 'progress'
  end

  config.order = :random
  Kernel.srand config.seed

  config.file_cache_path = '/var/chef/cache'
  config.fail_fast = true
  config.include ChefVault::TestFixtures.rspec_shared_context(true), vault: true
end
