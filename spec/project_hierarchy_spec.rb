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
      root_project_name = vars(:project_hierarchy).root_project_name

      found_project = resource_manager.projects.find do |i|
        i.project_id == root_project_name
      end

      expect(found_project).to be_truthy
    end

    it 'outputs created folders' do
      folders = output(:project_hierarchy, 'folders')

      expect(folders.map { |folder| folder[:display_name] })
        .to(include('management', 'production'))
    end

    it 'creates the folders on GCP' do
      folders = output(:project_hierarchy, 'folders')

      client = Google::Cloud::ResourceManager::V3::Folders::Client.new do |conf|
        conf.endpoint = 'cloudresourcemanager.googleapis.com'
      end

      folders.each do |folder|
        expect do
          request = Google::Cloud::ResourceManager::V3::GetFolderRequest.new
          request.name = "folders/#{folder[:id]}"
          client.get_folder(request)
        end.not_to(raise_error)
      end
    end

    it 'creates the folders with the correct parent folder' do
      parent_folder_id = vars(:project_hierarchy).folder_id
      folders = output(:project_hierarchy, 'folders')

      client = Google::Cloud::ResourceManager::V3::Folders::Client.new do |conf|
        conf.endpoint = 'cloudresourcemanager.googleapis.com'
      end

      folders.each do |folder|
        request = Google::Cloud::ResourceManager::V3::GetFolderRequest.new
        request.name = "folders/#{folder[:id]}"
        gcp_folder = client.get_folder(request)

        expect(gcp_folder.parent).to eq("folders/#{parent_folder_id}")
      end
    end

    it 'creates the management folder with the correct name' do
      folders = output(:project_hierarchy, 'folders')

      client = Google::Cloud::ResourceManager::V3::Folders::Client.new do |conf|
        conf.endpoint = 'cloudresourcemanager.googleapis.com'
      end

      folders.each do |folder|
        request = Google::Cloud::ResourceManager::V3::GetFolderRequest.new
        request.name = "folders/#{folder[:id]}"
        gcp_folder = client.get_folder(request)

        expect(gcp_folder.display_name).to eq(folder[:display_name])
      end
    end

    it 'creates a management project' do
      project_name = vars(:project_hierarchy).management_project_name

      found_project = resource_manager.projects.find do |i|
        i.project_id == project_name
      end

      expect(found_project).to be_truthy
    end

    it 'creates a production project' do
      project_name = vars(:project_hierarchy).production_project_name

      found_project = resource_manager.projects.find do |i|
        i.project_id == project_name
      end

      expect(found_project).to be_truthy
    end

    it 'outputs the projects' do
      projects = output(:project_hierarchy,
                        'projects')

      expect(projects.count).to eq 2
    end
  end
end
