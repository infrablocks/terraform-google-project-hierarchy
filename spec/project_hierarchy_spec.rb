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
      management_folder_id = output(:project_hierarchy, 'management_folder_id')

      client = Google::Cloud::ResourceManager::V3::Folders::Client.new do |conf|
        conf.endpoint = 'cloudresourcemanager.googleapis.com'
      end

      expect do
        request = Google::Cloud::ResourceManager::V3::GetFolderRequest.new
        request.name = "folders/#{management_folder_id}"
        client.get_folder(request)
      end.not_to(raise_error)
    end

    it 'creates the management folder with the correct parent folder' do
      parent_folder_id = vars(:project_hierarchy).folder_id
      management_folder_id = output(:project_hierarchy, 'management_folder_id')

      client = Google::Cloud::ResourceManager::V3::Folders::Client.new do |conf|
        conf.endpoint = 'cloudresourcemanager.googleapis.com'
      end

      request = Google::Cloud::ResourceManager::V3::GetFolderRequest.new
      request.name = "folders/#{management_folder_id}"
      folder = client.get_folder(request)

      expect(folder.parent).to eq("folders/#{parent_folder_id}")
    end

    it 'creates the management folder with the correct name' do
      management_folder_id = output(:project_hierarchy, 'management_folder_id')

      client = Google::Cloud::ResourceManager::V3::Folders::Client.new do |conf|
        conf.endpoint = 'cloudresourcemanager.googleapis.com'
      end

      request = Google::Cloud::ResourceManager::V3::GetFolderRequest.new
      request.name = "folders/#{management_folder_id}"
      folder = client.get_folder(request)

      expect(folder.display_name).to eq('management')
    end

    it 'creates a management project' do
      found_project = resource_manager.projects.find do |i|
        i.project_id == "#{component}-#{deployment_identifier}-mgmt"
      end
      expect(found_project).to be_truthy
    end

    it 'outputs the management_project_id' do
      management_project_id = output(:project_hierarchy,
                                     'management_project_id')

      expect(management_project_id).to be_truthy
    end

    it 'outputs the management_service_account_id' do
      management_service_account_id = output(:project_hierarchy,
                                             'management_service_account_id')

      expect(management_service_account_id).to be_truthy
    end
  end
end
