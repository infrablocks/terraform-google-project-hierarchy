# frozen_string_literal: true

require 'bundler/setup'
require 'ruby_terraform'

require 'support/shared_contexts/terraform'
require 'support/terraform_module'

RubyTerraform.configure do |c|
  logger = Logger.new($stdout)
  logger.level = Logger::Severity::DEBUG
  logger.formatter = proc do |_, _, _, msg|
    "#{msg}\n"
  end

  c.binary = Paths.from_project_root_directory(
    'vendor', 'terraform', 'bin', 'terraform'
  )
  c.logger = logger
end

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = '.rspec_status'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include_context 'terraform'

  config.before(:suite) do
    TerraformModule.provision(:prerequisites)
    TerraformModule.provision(:project_hierarchy)
  end

  config.after(:suite) do
    TerraformModule.destroy(:project_hierarchy)
  ensure
    TerraformModule.destroy(:prerequisites)
  end
end
