# frozen_string_literal: true

require 'spec_helper'
require 'google/cloud/resource_manager'
require 'google/cloud/resource_manager/v3'

describe 'full' do
  let(:component) do
    var(role: :full, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :full, name: 'deployment_identifier')
  end
  let(:folder_id) do
    var(role: :full, name: 'folder_id')
  end
  let(:root_project_id) do
    var(role: :full, name: 'root_project_id')
  end
  let(:root_project_name) do
    var(role: :full, name: 'root_project_name')
  end

  let(:resource_manager) do
    Google::Cloud::ResourceManager.new
  end

  before(:context) do
    apply(role: :full)
  end

  after(:context) do
    destroy(role: :full)
  end

  it 'creates a root project' do
    found_project = resource_manager.projects.find do |i|
      i.project_id == root_project_name
    end

    expect(found_project).to(be_truthy)
  end

  it 'outputs created folders' do
    folders = output(role: :full, name: 'folders')

    expect(folders.map { |folder| folder[:display_name] })
      .to(include('development', 'production'))
  end

  it 'creates the folders on GCP' do
    folders = output(role: :full, name: 'folders')

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
    folders = output(role: :full, name: 'folders')

    client = Google::Cloud::ResourceManager::V3::Folders::Client.new do |conf|
      conf.endpoint = 'cloudresourcemanager.googleapis.com'
    end

    folders.each do |folder|
      request = Google::Cloud::ResourceManager::V3::GetFolderRequest.new
      request.name = "folders/#{folder[:id]}"
      gcp_folder = client.get_folder(request)

      expect(gcp_folder.parent).to(eq("folders/#{folder_id}"))
    end
  end

  it 'creates all folders with the correct name' do
    folders = output(role: :full, name: 'folders')

    client = Google::Cloud::ResourceManager::V3::Folders::Client.new do |conf|
      conf.endpoint = 'cloudresourcemanager.googleapis.com'
    end

    folders.each do |folder|
      request = Google::Cloud::ResourceManager::V3::GetFolderRequest.new
      request.name = "folders/#{folder[:id]}"
      gcp_folder = client.get_folder(request)

      expect(gcp_folder.display_name).to(eq(folder[:display_name]))
    end
  end

  it 'creates all projects' do
    %W[
      development-#{deployment_identifier}
      production-#{deployment_identifier}
    ].each do |project_name|
      found_project = resource_manager.projects.find do |i|
        i.project_id == project_name
      end

      expect(found_project).to(be_truthy)
    end
  end

  it 'outputs the projects' do
    projects = output(role: :full, name: 'projects')

    expect(projects.count).to(eq(2))
  end
end
