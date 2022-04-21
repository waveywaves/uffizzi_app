# frozen_string_literal: true

# @resource Project

class UffizziCore::Api::Cli::V1::ProjectsController < UffizziCore::Api::Cli::V1::ApplicationController
  before_action :authorize_uffizzi_core_api_cli_v1_projects

  # Get projects of current user
  #
  # @path [GET] /api/cli/v1/projects
  #
  # @response [object<projects: Array<object<slug: string>> >] 200 OK
  # @response 401 Not authorized
  def index
    projects = current_user.projects.active.order(updated_at: :desc)

    respond_with projects
  end

  # Get a project by slug
  #
  # @path [GET] /api/cli/v1/projects/{slug}
  #
  # @response <object< project: Project>> 200 OK
  # @response 404 Not Found
  # @response 401 Not authorized
  def show
    respond_with project
  end

  private

  def project
    @project ||= current_user.projects.find_by!(slug: params[:slug])
  end
end
