# frozen_string_literal: true

FactoryBot.define do
  factory :container, class: UffizziCore::Container do
    image
    tag
    name
    variables { nil }
    secret_variables { nil }
    deployment
    repo { nil }
    receive_incoming_requests { false }
    entrypoint { nil }
    command { nil }
    continuously_deploy { UffizziCore::Container::STATE_DISABLED }
    volumes { nil }

    trait :continuously_deploy_enabled do
      continuously_deploy { UffizziCore::Container::STATE_ENABLED }
    end

    trait :with_public_port do
      public { true }

      port
    end

    trait :continuously_deploy_enabled do
      continuously_deploy { UffizziCore::Container::STATE_ENABLED }
    end

    trait :continuously_deploy_disabled do
      continuously_deploy { UffizziCore::Container::STATE_DISABLED }
    end

    initialize_with { new }

    trait :active do
      state { UffizziCore::Container::STATE_ACTIVE }
    end

    trait :with_volume do
      volumes do
        [
          {
            source: generate(:path),
            target: generate(:path),
            type: UffizziCore::ComposeFile::ServicesOptions::VolumesService::HOST_VOLUME_TYPE,
            source_container_name: name,
          },
        ]
      end
    end
  end
end
