# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Projects::Deployments::ContainerSerializer < UffizziCore::BaseSerializer
  attributes :id, :name, :memory_limit, :memory_request, :continuously_deploy, :variables, :secret_variables

  has_many :container_config_files

  type :container

  def name
    image_name = object.image.split('/').pop
    commit = object&.repo&.builds&.deployed&.last&.commit
    container_name = "#{image_name}:#{object.tag}"

    if !commit.nil?
      short_commit_hash = commit.slice(0..5)
      container_name = "#{container_name}@#{short_commit_hash}"
    end

    container_name
  end
end