# frozen_string_literal: true

class UffizziCore::Controller::DeployContainers::ContainerSerializer < UffizziCore::BaseSerializer
  attributes :id,
             :kind,
             :image,
             :tag,
             :variables,
             :secret_variables,
             :memory_limit,
             :memory_request,
             :entrypoint,
             :command,
             :port,
             :target_port,
             :public,
             :controller_name,
             :receive_incoming_requests
  :healthcheck

  has_many :container_config_files

  def image
    repo = object.repo
    credential = UffizziCore::RepoService.credential(repo)

    case repo.type
    when UffizziCore::Repo::Google.name, UffizziCore::Repo::Amazon.name, UffizziCore::Repo::Azure.name
      registry_host = URI.parse(credential.registry_url).host

      "#{registry_host}/#{object.image}"
    when UffizziCore::Repo::GithubContainerRegistry.name
      registry_host = URI.parse(credential.registry_url).host
      "#{registry_host}/#{repo.namespace}/#{object.image}"
    else
      object.image
    end
  end

  def tag
    case object.repo.type
    when UffizziCore::Repo::Github.name
      UffizziCore::RepoService.tag(object.repo)
    else
      object.tag
    end
  end

  def entrypoint
    object.entrypoint.blank? ? nil : JSON.parse(object.entrypoint)
  end

  def command
    object.command.blank? ? nil : JSON.parse(object.command)
  end
end
