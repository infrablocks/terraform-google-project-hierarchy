# frozen_string_literal: true

require 'git'
require 'os'
require 'rake_circle_ci'
require 'rake_github'
require 'rake_gpg'
require 'rake_ssh'
require 'rake_terraform'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'securerandom'
require 'semantic'
require 'yaml'

require_relative 'lib/configuration'
require_relative 'lib/version'

configuration = Configuration.new

def repo
  Git.open(Pathname.new('.'))
end

def latest_tag
  repo.tags.map do |tag|
    Semantic::Version.new(tag.name)
  end.max
end

def tmpdir
  base = (ENV.fetch('TMPDIR', nil) || '/tmp')
  OS.osx? ? "/private#{base}" : base
end

task default: %i[
  test:code:fix
  test:integration
]

RakeTerraform.define_installation_tasks(
  path: File.join(Dir.pwd, 'vendor', 'terraform'),
  version: '1.0.11'
)

namespace :encryption do
  namespace :directory do
    desc 'Ensure CI secrets directory exists'
    task :ensure do
      FileUtils.mkdir_p('config/secrets/ci')
    end
  end

  namespace :passphrase do
    desc 'Generate encryption passphrase for CI GPG key'
    task generate: ['directory:ensure'] do
      File.write(
        'config/secrets/ci/encryption.passphrase',
        SecureRandom.base64(36)
      )
    end
  end
end

namespace :keys do
  namespace :deploy do
    RakeSSH.define_key_tasks(
      path: 'config/secrets/ci/',
      comment: 'maintainers@infrablocks.io'
    )
  end

  namespace :secrets do
    namespace :gpg do
      RakeGPG.define_generate_key_task(
        output_directory: 'config/secrets/ci',
        name_prefix: 'gpg',
        owner_name: 'InfraBlocks Maintainers',
        owner_email: 'maintainers@infrablocks.io',
        owner_comment: 'terraform-google-project-hierarchy CI Key'
      )
    end

    task generate: ['gpg:generate']
  end
end

namespace :secrets do
  namespace :directory do
    desc 'Ensure secrets directory exists and is set up correctly'
    task :ensure do
      FileUtils.mkdir_p('config/secrets')
      unless File.exist?('config/secrets/.unlocked')
        File.write('config/secrets/.unlocked', 'true')
      end
    end
  end

  desc 'Regenerate all secrets'
  task regenerate: %w[
    directory:ensure
    encryption:passphrase:generate
    keys:deploy:generate
    keys:secrets:generate
  ]
end

RakeCircleCI.define_project_tasks(
  namespace: :circle_ci,
  project_slug: 'github/infrablocks/terraform-google-project-hierarchy'
) do |t|
  circle_ci_config =
    YAML.load_file('config/secrets/circle_ci/config.yaml')

  t.api_token = circle_ci_config['circle_ci_api_token']
  t.environment_variables = {
    ENCRYPTION_PASSPHRASE:
      File.read('config/secrets/ci/encryption.passphrase')
          .chomp,
    CIRCLECI_API_KEY:
      YAML.load_file(
        'config/secrets/circle_ci/config.yaml'
      )['circle_ci_api_token']
  }
  t.checkout_keys = []
  t.ssh_keys = [
    {
      hostname: 'github.com',
      private_key: File.read('config/secrets/ci/ssh.private')
    }
  ]
end

RakeGithub.define_repository_tasks(
  namespace: :github,
  repository: 'infrablocks/terraform-google-project-hierarchy'
) do |t, args|
  github_config =
    YAML.load_file('config/secrets/github/config.yaml')

  t.access_token = github_config['github_personal_access_token']
  t.deploy_keys = [
    {
      title: 'CircleCI',
      public_key: File.read('config/secrets/ci/ssh.public')
    }
  ]
  t.branch_name = args.branch_name
  t.commit_message = args.commit_message
end

namespace :pipeline do
  desc 'Prepare CircleCI Pipeline'
  task prepare: %i[
    circle_ci:env_vars:ensure
    circle_ci:checkout_keys:ensure
    circle_ci:ssh_keys:ensure
    github:deploy_keys:ensure
  ]
end

RuboCop::RakeTask.new

namespace :test do
  namespace :code do
    desc 'Run all checks on the test code'
    task check: [:rubocop]

    desc 'Attempt to automatically fix issues with the test code'
    task fix: [:'rubocop:autocorrect']
  end

  RSpec::Core::RakeTask.new(integration: ['terraform:ensure']) do
    test_configuration = configuration.for(:project_hierarchy)

    plugin_cache_directory =
      "#{Paths.project_root_directory}/vendor/terraform/plugins"

    mkdir_p(plugin_cache_directory)

    ENV['TF_PLUGIN_CACHE_DIR'] = plugin_cache_directory
    ENV['RESOURCE_MANAGER_PROJECT'] = test_configuration.gcp_project_id
    ENV['RESOURCE_MANAGER_CREDENTIALS'] = test_configuration.gcp_credentials
    ENV['GOOGLE_APPLICATION_CREDENTIALS'] = test_configuration.gcp_credentials
  end
end

namespace :deployment do
  namespace :prerequisites do
    RakeTerraform.define_command_tasks(
      configuration_name: 'prerequisites',
      argument_names: [:deployment_identifier]
    ) do |t, args|
      deployment_configuration =
        configuration.for(:prerequisites, args)

      t.source_directory = deployment_configuration.source_directory
      t.work_directory = deployment_configuration.work_directory

      t.state_file = deployment_configuration.state_file
      t.vars = deployment_configuration.vars
    end
  end

  namespace :project_hierarchy do
    RakeTerraform.define_command_tasks(
      configuration_name: 'project_hierarchy',
      argument_names: [:deployment_identifier]
    ) do |t, args|
      deployment_configuration =
        configuration.for(:project_hierarchy, args.to_h)

      state_file = deployment_configuration.state_file
      vars = deployment_configuration
             .vars.to_h

      environment = {
        'GOOGLE_APPLICATION_CREDENTIALS' =>
          deployment_configuration.gcp_credentials
      }

      t.source_directory = deployment_configuration.source_directory
      t.work_directory = deployment_configuration.work_directory
      t.environment =  environment
      t.state_file = state_file
      t.vars = vars
    end
  end
end

namespace :version do
  desc 'Bump version for specified type (pre, major, minor, patch)'
  task :bump, [:type] do |_, args|
    next_tag = latest_tag.send("#{args.type}!")
    repo.add_tag(next_tag.to_s)
    repo.push('origin', 'main', tags: true)
    puts "Bumped version to #{next_tag}."
  end

  desc 'Release gem'
  task :release do
    next_tag = latest_tag.release!
    repo.add_tag(next_tag.to_s)
    repo.push('origin', 'main', tags: true)
    puts "Released version #{next_tag}."
  end
end
