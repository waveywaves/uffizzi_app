# frozen_string_literal: true

class UffizziCore::ComposeFile::Parsers::ServicesParserService
  class << self
    include UffizziCore::DependencyInjectionConcern

    def parse(services, global_configs_data, global_secrets_data, compose_payload)
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.no_services') if services.nil? || services.keys.empty?

      services.keys.map do |service|
        service_data = prepare_service_data(service, services.fetch(service), global_configs_data, global_secrets_data, compose_payload)

        if service_data[:image].blank? && service_data[:build].blank?
          raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.image_build_no_specified', value: service)
        end

        service_data
      end
    end

    private

    def prepare_service_data(service_name, service_data, global_configs_data, global_secrets_data, compose_payload)
      options_data = {}
      service_data.each_pair do |key, value|
        service_key = key.to_sym

        options_data[service_key] = case service_key
                                    when :image
                                      UffizziCore::ComposeFile::Parsers::Services::ImageParserService.parse(value)
                                    when :build
                                      check_and_parse_build_option(value, compose_payload)
                                    when :env_file
                                      UffizziCore::ComposeFile::Parsers::Services::EnvFileParserService.parse(value)
                                    when :environment
                                      UffizziCore::ComposeFile::Parsers::Services::EnvironmentParserService.parse(value)
                                    when :configs
                                      UffizziCore::ComposeFile::Parsers::Services::ConfigsParserService.parse(value, global_configs_data)
                                    when :secrets
                                      UffizziCore::ComposeFile::Parsers::Services::SecretsParserService.parse(value, global_secrets_data)
                                    when :deploy
                                      UffizziCore::ComposeFile::Parsers::Services::DeployParserService.parse(value)
                                    when :entrypoint
                                      UffizziCore::ComposeFile::Parsers::Services::EntrypointParserService.parse(value)
                                    when :command
                                      UffizziCore::ComposeFile::Parsers::Services::CommandParserService.parse(value)
                                    when :healthcheck
                                      UffizziCore::ComposeFile::Parsers::Services::HealthcheckParserService.parse(value)
                                    when :'x-uffizzi-continuous-preview', :'x-uffizzi-continuous-previews'
                                      UffizziCore::ComposeFile::Parsers::ContinuousPreviewParserService.parse(value)
        end
      end

      options_data[:container_name] = service_name

      options_data
    end

    def check_and_parse_build_option(value, compose_payload)
      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.not_implemented', option: :build) unless build_parser_module

      build_parser_module.parse(value, compose_payload)
    end
  end
end
