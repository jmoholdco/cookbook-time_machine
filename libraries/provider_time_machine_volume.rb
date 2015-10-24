require 'chef/mixin/shell_out'
require 'chef/dsl/recipe'

class Chef
  class Provider
    # The provider for time_machine_volume resource
    #
    class TimeMachineVolume < Chef::Provider
      include Chef::DSL::Recipe
      include Chef::Mixin::ShellOut
      include TimeMachineCookbook::Helpers
      include Chef::DSL::Recipe

      # Loads the current resource
      #
      # @return [Chef::Resource::TimeMachineVolume the time_machine volume
      # resource
      #
      def load_current_resource
        @current_resource ||= Chef::Resource::TimeMachineVolume.new(
          @new_resource.name
        )
        @configured = if config_exists? then true
                      elsif node_has_config? then true
                      else false
                      end
        @current_resource
      end

      # The create action
      #
      def action_create
        ruby_block 'configure_run_state' do
          block do
            node.run_state['time_machine_volumes'] ||= []
          end
        end

        return if @configured
        create_allowed_user_group
        create_volume_path

        add_config_to_node unless node_has_config?
      end

      protected

      # Creates the config directory for afp.conf
      #
      # @return [Chef::Resource::Directory]
      #
      def create_config_directory
        directory_resource = ::File.dirname(node['netatalk']['conf_file'])
        return if ::File.directory?(directory_resource)
        directory directory_resource do
          recursive true
        end
      end

      # Creates the group allowed to access the volume and adds the appropriate
      # members. NOTE: This resource/provider DOES NOT create the user accounts.
      # Please declare your user resources before declaring the time machine
      # volume resource.
      #
      def create_allowed_user_group
        group new_resource.allowed_user_group do
          action :create
          append true
          members new_resource.allowed_users
        end
      end

      # Creates the path from which the volume will be served. Ensures proper
      # permissions are set given the allowed user group
      #
      def create_volume_path
        directory new_resource.path do
          recursive true
          group new_resource.allowed_user_group
          mode '0664'
        end
      end

      # Adds the configured volume to the node attributes so it can be rendered
      # into the afp.conf file at the end of the run. This ensures each volume
      # can be configured independently, and still be accessed in the regular
      # config file for netatalk (apf.conf for netatalk 3+). See #setup_template
      # for how this works.
      #
      def add_config_to_node
        node.set['time_machine']['volumes'] =
          [node['time_machine']['volumes'], [rendered_config.to_h]].flatten
        setup_template
      end

      # Lazily renders the config variables to the afp.conf template that are
      # set earlier in the chef run. Passes config objects to the template
      # so the template can render the file.
      #
      def setup_template
        ruby_block 'reload_node_volumes' do
          block do
            node.run_state['time_machine_volumes'] << rendered_config.to_h
          end
          # Tells the template to render itself at the end of the chef run,
          # so it knows about all the volumes configured on this node,
          # including those configured by this run.
          #
          notifies :create, 'template[afp.conf]', :delayed
        end
      end
    end
  end
end
