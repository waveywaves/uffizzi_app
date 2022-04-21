# frozen_string_literal: true

class UffizziCore::ComposeFile::VolumeHostOptionsService
  class << self
    def parse(volume_host_options, services_data)
      return if volume_host_options.nil?

      if !volume_host_options.is_a?(Hash)
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: 'x-uffizzi-volume-host')
      end

      container_name = container_name(volume_host_options, services_data)
      root_path = build_root_path(volume_host_options)

      {
        source_container_name: container_name,
        source_container_mount_root_path: root_path,
      }
    end

    private

    def container_name(volume_host_options, services_data)
      container_name = volume_host_options['service'].to_s.strip

      if container_name.blank?
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_host_service_not_found')
      end

      unless services_data.keys.include?(container_name)
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_volume_host_service', value: container_name)
      end

      container_name
    end

    def build_root_path(volume_host_options)
      root_path = volume_host_options['root_path'].to_s.strip

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_host_root_path_not_specified') if root_path.blank?

      if !Pathname.new(root_path).absolute?
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_host_root_path_is_invalid')
      end

      root_path
    end
  end
end
