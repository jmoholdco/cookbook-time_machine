require 'chef/resource'

class Chef
  class Resource
    # The time_machine_volume resource
    #
    class TimeMachineVolume < Chef::Resource
      # Initializes time_machine_volume resource
      #
      # @param name [String] name of the resource
      # @param run_context [Chef::RunContext] the run context of chef run
      #
      # @return [Chef::Resource::TimeMachineVolume] the time_machine_volume
      #
      def initialize(name, run_context = nil)
        super
        @resource_name = :time_machine_volume
        @action = :create
        @allowed_actions.push :create
        @allowed_actions.push :remove
        @provider = Chef::Provider::TimeMachineVolume
      end

      # Attribute: name - the name of the time machine volume
      #
      # @param arg [String] the name of the time machine volume
      #
      # @return [String] the name of the time machine volume
      #
      def name(arg = nil)
        set_or_return(
          :name,
          arg,
          kind_of: String,
          regex: /[\w+.-]+/,
          name_attribute: true,
          required: true
        )
      end

      # Attribute: path - the path from which to serve the time machine volume
      #
      # @param arg [String] the path to the volume
      #
      # @return [String] the path to the volume
      #
      def path(arg = nil)
        set_or_return(
          :path,
          arg,
          kind_of: String,
          required: true
        )
      end

      # Attribute: size - the size of the volume
      #
      # @param arg [Integer] the maximum size of the volume in KB
      #
      # @return [Integer] the maximum size of the volume in KB
      #
      def size(arg = nil)
        set_or_return(
          :size,
          arg,
          kind_of: Integer,
          default: 1_024_000
        )
      end

      # Attribute: allowed_users - a list of users allowed to access the volume
      #
      # @param arg [Array] the users allowed to access the volume
      #
      # @return [Array] the users allowed to access the volume
      #
      def allowed_users(arg = nil)
        set_or_return(
          :allowed_users,
          arg,
          kind_of: Array
        )
      end

      # Attribute: config_options - a hash of options to render in the config
      #
      # @param arg [Hash] the config options to render
      #
      # @return [Hash] the config options to render
      #
      def config_options(arg = nil)
        set_or_return(
          :config_options,
          arg,
          kind_of: Hash,
          default: {}
        )
      end

      # Attribute: allowed_user_group - The group name to create for users
      # allowed to access the volume
      #
      # @param arg [String] the group name
      #
      # @return [String] the group name
      #
      def allowed_user_group(arg = nil)
        set_or_return(
          :allowed_user_group,
          arg,
          kind_of: String,
          default: lazy { name.gsub(/\s+/, '_').downcase }
        )
      end
    end
  end
end
