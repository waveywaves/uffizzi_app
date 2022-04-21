# frozen_string_literal: true

class UffizziCore::ComposeFile::ServicesOptions::VolumesService
  HOST_VOLUME_TYPE = :host
  NAMED_VOLUME_TYPE = :named
  ANONYMOUS_VOLUME_TYPE = :anonymous
  READONLY_OPTION = 'ro'

  class << self
    def parse(volumes, global_volume_host_data)
      return [] if volumes.blank?

      volumes.map do |volume|
        volume_data = case volume
                      when String
                        process_short_syntax(volume, global_volume_host_data)
                      when Hash
                        process_long_syntax(volume, global_volume_host_data)
                      else
                        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.invalid_type', option: :volumes)
        end

        volume_data
      end
    end

    private

    def process_short_syntax(volume_data, global_volume_host_data)
      first_path, second_path = volume_data.split(':').map(&:strip)
      source_path = second_path.present? && second_path.downcase != READONLY_OPTION ? first_path : nil
      target_path = source_path.present? ? second_path : first_path

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_prop_is_required', prop_name: 'target') if target_path.blank?

      volume_type = volume_type(source_path, target_path)

      {
        source: build_source_path(source_path, volume_type, global_volume_host_data),
        target: target_path,
        type: volume_type,
        source_container_name: source_container_name(global_volume_host_data, volume_type),
      }
    end

    def process_long_syntax(volume_data, global_volume_host_data)
      source_path = volume_data['source'].to_s.strip
      target_path = volume_data['target'].to_s.strip

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_prop_is_required', prop_name: 'target') if target_path.blank?

      volume_type = volume_type(source_path, target_path)

      {
        source: build_source_path(source_path, volume_type, global_volume_host_data),
        target: target_path,
        type: volume_type,
        source_container_name: source_container_name(global_volume_host_data, volume_type),
      }
    end

    def path?(path)
      /^(\/|\.\/|~\/)/.match?(path)
    end

    def need_root_path?(path)
      /^\.\//.match?(path)
    end

    def volume_type(source_path, target_path)
      return HOST_VOLUME_TYPE if path?(source_path) && path?(target_path)
      return ANONYMOUS_VOLUME_TYPE if source_path.blank? && path?(target_path)
      return NAMED_VOLUME_TYPE if source_path.present? && !path?(source_path) && path?(target_path)

      raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_path_is_invalid', path: [source_path, target_path].join(':'))
    end

    def source_container_name(global_volume_host_data, volume_type)
      return if volume_type != HOST_VOLUME_TYPE

      if global_volume_host_data.nil? || global_volume_host_data[:source_container_name].blank?
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_host_option_is_not_defined', option: :server)
      end

      global_volume_host_data[:source_container_name]
    end

    def build_source_path(path, volume_type, global_volume_host_data)
      return path if volume_type != HOST_VOLUME_TYPE
      return path unless need_root_path?(path)

      if global_volume_host_data.nil? || global_volume_host_data[:source_container_mount_root_path].blank?
        raise UffizziCore::ComposeFile::ParseError, I18n.t('compose.volume_host_option_is_not_defined', option: :root_path)
      end

      (Pathname.new(global_volume_host_data[:source_container_mount_root_path]) + Pathname.new(path)).to_s
    end
  end
end
