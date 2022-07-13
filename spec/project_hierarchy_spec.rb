# frozen_string_literal: true

require 'google/cloud/resource_manager/v3'
require 'spec_helper'

describe 'project hierarchy' do
  context 'when provisioned with default' do
    let(:deployment_identifier) do
      vars(:project_hierarchy).deployment_identifier
    end

    let(:component) do
      vars(:project_hierarchy).component
    end

    it 'creates a root project' do
      found_project = resource_manager.projects.find do |i|
        i.project_id == "#{component}-#{deployment_identifier}-root"
      end
      expect(found_project).to be_truthy
    end

    it 'outputs the management_folder_id' do
      management_folder_id = output(:project_hierarchy, 'management_folder_id')

      expect(management_folder_id).to be_truthy
    end

    it 'creates the management folder' do
      parent_folder_id = vars(:project_hierarchy).folder_id
      management_folder_id = output(:project_hierarchy, 'management_folder_id')

      client = Google::Cloud::ResourceManager::V3::Folders::Client.new do |config|
        config.endpoint = 'cloudresourcemanager.googleapis.com'
      end

      folder = nil

      expect {
        request = Google::Cloud::ResourceManager::V3::GetFolderRequest.new
        request.name = "folders/#{management_folder_id}"
        folder = client.get_folder(request)
      }.not_to(raise_error)

      expect(folder.parent).to eq('folders/' + parent_folder_id)
      expect(folder.display_name).to eq('management')

    end

    it 'creates a management project' do
      found_project = resource_manager.projects.find do |i|
        i.project_id == "#{component}-#{deployment_identifier}-management"
      end
      expect(found_project).to be_truthy
    end

    it 'outputs the management_project_id' do
      management_project_id = output(:project_hierarchy, 'management_project_id')

      expect(management_project_id).to be_truthy
    end

  end
end
