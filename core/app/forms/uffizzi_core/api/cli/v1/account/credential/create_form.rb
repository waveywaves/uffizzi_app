# frozen_string_literal: true

class UffizziCore::Api::Cli::V1::Account::Credential::CreateForm < UffizziCore::Credential
  include UffizziCore::ApplicationForm

  permit :type, :registry_url, :username, :password

  validates :password, presence: { message: :password_blank }
  validate :check_registry_url, if: -> { errors[:password].empty? }
  validate :check_credential_correctness, if: -> { errors[:password].empty? }
  validate :credential_exists?, if: -> { errors[:password].empty? }

  private

  def check_registry_url
    errors.add(:registry_url, :invalid_scheme) if URI.parse(registry_url).scheme.nil?
  end

  def check_credential_correctness
    errors.add(:username, :incorrect) unless UffizziCore::CredentialService.correct_credentials?(self)
  end

  def credential_exists?
    errors.add(:type, :exist) if account.credentials.by_type(type).exists?
  end
end
