require_relative '../config'
require_relative '../interface'
require_relative '../util'

module Builderator
  # :nodoc:
  class Interface
    class << self
      def vagrant(profile = :default)
        @vagrant ||= {}
        @vagrant[profile] ||= Vagrant.new(profile)
      end
    end

    ##
    # Render a temporary Vagrantfile
    ##
    class Vagrant < Interface
      def initialize(profile_ = :default)
        super

        includes Config.profile(profile_).vagrant
        artifact.includes Config.profile(profile_).artifact

        build_name Config.build_name
        version Config.version
        log_level Config.profile(profile_).log_level

        ec2.region Config.aws.region

        chef do |chef|
          chef.includes Config.local
          chef.includes Config.profile(profile_).chef
        end
      end

      template 'template/Vagrantfile.erb'

      attribute :build_name
      attribute :version
      attribute :log_level

      collection :artifact do
        attribute :path
        attribute :destination
      end

      namespace :local do
        attribute :provider
        attribute :box
        attribute :box_url

        attribute :cpus
        attribute :memory
      end

      namespace :ec2 do
        attribute :provider
        attribute :box
        attribute :box_url

        attribute :region
        attribute :availability_zone
        attribute :subnet_id
        attribute :private_ip_address

        attribute :instance_type
        attribute :security_groups, :type => :list
        attribute :iam_instance_profile_arn

        attribute :source_ami
        attribute :user_data

        attribute :ssh_username
        attribute :keypair_name
        attribute :private_key_path

        attribute :associate_public_ip
        attribute :ssh_host_attribute
        attribute :instance_ready_timeout
        attribute :instance_check_interval
      end

      namespace :chef do
        attribute :version, 'latest'

        attribute :cookbook_path
        attribute :data_bag_path
        attribute :environment_path
        attribute :staging_directory

        attribute :run_list, :type => :list, :singular => :run_list_item
        attribute :environment
        attribute :node_attrs
      end

      def source
        directory.join('Vagrantfile')
      end
    end
  end
end
