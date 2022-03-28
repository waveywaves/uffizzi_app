# frozen_string_literal: true

# @resource Account/Credential
class UffizziCore::Api::Cli::V1::Account::CredentialsController < UffizziCore::Api::Cli::V1::Account::ApplicationController
  before_action :authorize_uffizzi_core_api_cli_v1_account_credentials

  # rubocop:disable Layout/LineLength
  # Create account credential
  #
  # @path [POST] /api/cli/v1/account/credentials
  #
  # @parameter credential(required,body) [object<username:string, password: string, type:string>]
  # @response [object<id:integer, username:string, password:string, type:string, state:string>] 201 Created successfully
  # @response [object<errors>] 422 Unprocessable entity
  #
  # @example
  #    type can be one of UffizziCore::Credential::Amazon, UffizziCore::Credential::Azure, UffizziCore::Credential::DockerHub, UffizziCore::Credential::Google
  # rubocop:enable Layout/LineLength
  def create
    credential_form = UffizziCore::Api::Cli::V1::Account::Credential::CreateForm.new
    credential_form.assign_attributes(credential_params)
    credential_form.account = resource_account
    credential_form.registry_url = Settings.docker_hub.registry_url if credential_form.docker_hub?
    if credential_form.google?
      credential_form.registry_url = Settings.google.registry_url
      credential_form.username = '_json_key'
    end
    credential_form.activate

    if credential_form.save
      UffizziCore::Account::CreateCredentialJob.perform_async(credential_form.id)
    end

    respond_with credential_form
  end

  # Delete account credential
  #
  # @path [DELETE] /api/cli/v1/account/credentials/{type}
  #
  # @parameter type(required,path) [string] Type of the credential
  # @response 204 No Content
  # @response 401 Not authorized
  # @response 404 Not found
  def destroy
    credential.destroy
  end

  private

  def credential
    @credential ||= resource_account.credentials.find_by!(type: params[:type])
  end

  def credential_params
    params.require(:credential)
  end
end
