# frozen_string_literal: true

require 'ostruct'

require_relative '../terraform_module'

module RSpec
  module Terraform
    def configuration
      TerraformModule.configuration
    end

    # rubocop:disable Style/OpenStructUse
    def vars(role)
      OpenStruct.new(configuration.for(role).vars)
    end
    # rubocop:enable Style/OpenStructUse

    def output(role, name)
      TerraformModule.output(role, name)
    end

    def provision(role, overrides = nil, &)
      TerraformModule.provision(role, overrides, &)
    end

    def destroy(role, overrides = nil, &)
      TerraformModule.destroy(role, overrides, force: true, &)
    end

    def reprovision(role, overrides = nil, &)
      destroy(role, overrides, &)
      provision(role, overrides, &)
    end
  end
end

# rubocop:disable RSpec/ContextWording
shared_context 'terraform' do
  include RSpec::Terraform
end
# rubocop:enable RSpec/ContextWording
