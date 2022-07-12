# frozen_string_literal: true

require 'google/cloud/resource_manager/v3'
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

    it 'creates a management sub-folder' do


      client = Google::Cloud::ResourceManager::V3::Folders::Client.new do |config|
        config.credentials = "/Users/jonassvalin/Documents/git/atomic/terraform-google-project-hierarchy/config/secrets/gcp/infrablocks-testing-bootstrap.json"
      end
      request = Google::Cloud::ResourceManager::V3::GetFolderRequest.new
      response = client.get_folder request
      expect(response).to be_truthy
    end
  end
end
