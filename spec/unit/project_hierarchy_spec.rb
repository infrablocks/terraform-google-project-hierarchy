# frozen_string_literal: true

require 'spec_helper'

describe 'project hierarchy' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end

  let(:folder_id) do
    var(role: :root, name: 'folder_id')
  end
  let(:root_project_name) do
    var(role: :root, name: 'root_project_name')
  end
  let(:root_project_id) do
    var(role: :root, name: 'root_project_id')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'creates a project for the root project' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_project')
              .with_attribute_value(:project_id, root_project_id))
    end

    it 'uses the provided root project name for the root project' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_project')
              .with_attribute_value(:name, root_project_name))
    end

    it 'uses the provided folder ID for the root project' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_project')
              .with_attribute_value(:folder_id, folder_id))
    end

    it 'adds the IAM service to the root project' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_project_service')
              .with_attribute_value(:service, 'iam.googleapis.com'))
    end

    it 'disables dependent services on the IAM service for the root project' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_project_service')
              .with_attribute_value(:service, 'iam.googleapis.com')
              .with_attribute_value(:disable_dependent_services, true))
    end

    it 'does not create any folders' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'google_folder'))
    end

    it 'does not create any other projects' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_project')
              .once)
    end

    it 'outputs details of the folders' do
      expect(@plan)
        .to(include_output_creation(name: 'folders'))
    end
  end

  describe 'when no projects are provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.projects = []
      end
    end

    it 'does not create any other projects' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_project')
              .once)
    end
  end

  describe 'when one project is provided' do
    before(:context) do
      component = var(role: :root, name: 'component')
      deployment_identifier = var(role: :root, name: 'deployment_identifier')

      folder = { display_name: 'management' }

      @project = {
        name: "#{component}-#{deployment_identifier}-one",
        id: "#{component}-#{deployment_identifier}-1",
        folder: 'management'
      }

      @plan = plan(role: :root) do |vars|
        vars.folders = [folder]
        vars.projects = [@project]
      end
    end

    it 'creates a project for the provided project' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_project')
              .with_attribute_value(:project_id, @project[:id]))
    end

    it 'uses the provided project name for the project' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_project')
              .with_attribute_value(:project_id, @project[:id])
              .with_attribute_value(:name, @project[:name]))
    end
  end

  describe 'when many projects provided' do
    before(:context) do
      component = var(role: :root, name: 'component')
      deployment_identifier = var(role: :root, name: 'deployment_identifier')

      folder = { display_name: 'project-folder' }

      project1 = {
        name: "#{component}-#{deployment_identifier}-one",
        id: "#{component}-#{deployment_identifier}-1",
        folder: 'project-folder'
      }
      project2 = {
        name: "#{component}-#{deployment_identifier}-two",
        id: "#{component}-#{deployment_identifier}-2",
        folder: 'project-folder'
      }
      @projects = [project1, project2]

      @plan = plan(role: :root) do |vars|
        vars.folders = [folder]
        vars.projects = @projects
      end
    end

    it 'creates a project for each provided project' do
      @projects.each do |project|
        expect(@plan)
          .to(include_resource_creation(type: 'google_project')
                .with_attribute_value(:project_id, project[:id]))
      end
    end

    it 'uses the provided project name for each project' do
      @projects.each do |project|
        expect(@plan)
          .to(include_resource_creation(type: 'google_project')
                .with_attribute_value(:project_id, project[:id])
                .with_attribute_value(:name, project[:name]))
      end
    end
  end

  describe 'when no folders are provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.folders = []
      end
    end

    it 'does not create any folders' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'google_folder'))
    end
  end

  describe 'when one folder provided' do
    before(:context) do
      @folder = {
        display_name: 'development'
      }
      @plan = plan(role: :root) do |vars|
        vars.folders = [@folder]
      end
    end

    it 'creates a folder' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_folder')
              .once)
    end

    it 'uses the provided display name' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_folder')
              .with_attribute_value(:display_name, @folder[:display_name]))
    end

    it 'uses the provided root folder ID as the parent' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_folder')
              .with_attribute_value(:parent, "folders/#{folder_id}"))
    end
  end

  describe 'when many folders provided' do
    before(:context) do
      folder1 = {
        display_name: 'development'
      }
      folder2 = {
        display_name: 'production'
      }
      @folders = [folder1, folder2]
      @plan = plan(role: :root) do |vars|
        vars.folders = @folders
      end
    end

    it 'creates a folder for each provided' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_folder')
              .twice)
    end

    it 'uses the provided display names' do
      @folders.each do |folder|
        expect(@plan)
          .to(include_resource_creation(type: 'google_folder')
                .with_attribute_value(:display_name, folder[:display_name]))
      end
    end

    it 'uses the provided root folder ID as the parent' do
      expect(@plan)
        .to(include_resource_creation(type: 'google_folder')
              .with_attribute_value(:parent, "folders/#{folder_id}")
              .twice)
    end
  end
end
