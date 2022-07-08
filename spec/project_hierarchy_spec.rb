# frozen_string_literal: true

require 'spec_helper'

describe 'project hierarchy' do
  context 'when provisioned with default' do
    let(:deployment_identifier) do
      vars(:project_hierarchy).deployment_identifier
    end

    it 'creates a root project' do
      found_project = resource_manager.projects.find do |i|
        i.project_id == "infrablocks-test-#{deployment_identifier}-root"
      end
      expect(found_project).to be_truthy
    end
  end
end
