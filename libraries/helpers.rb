require 'securerandom'
# Top-level namespace for this cookbook
module TimeMachineCookbook
  # Helper module for TimeMachineCookbook
  # Provides a variety of helper methods for resources in this cookbook.
  module Helpers
    # Provides a helper method to render the new resource's config options in
    # a PORO to ease serialization and rendering multiple time machine volumes
    # in the same configuration file
    #
    # @return [TimeMachineCookbook::Helpers::TMConfigOptions]
    #
    def rendered_config
      @rendered ||= TMConfigOptions.new(merged_config_options)
    end

    # Generates a unique resource name to avoid resource collisions when there
    # is more than one volume being configured. Adds a random string to the
    # end of the original name
    #
    # @param [String] resource_name the canonical name of the resource
    #
    # @return [String] the unique resource name
    #
    def unique_resource_name(resource_name)
      "#{resource_name}-#{SecureRandom.hex(10)}"
    end

    # Merges all the config options needed to instantiate the TMConfigOptions
    # object into a hash.
    #
    # @return [Hash] an options hash to pass to TMConfigOptions.new
    #
    def merged_config_options
      {
        name: new_resource.name,
        path: new_resource.path
      }.merge(new_resource.config_options)
    end

    # Provides a helper method to determine if the configuration file on the
    # node already contains the volume we are rendering.
    # Uses TMConfigOptions#to_regexp to match the contents of the file to what
    # the rendered config would look like in the file
    #
    # @return [TrueClass, NilClass, FalseClass]
    #
    def config_exists?
      return false unless ::File.exist?(node['netatalk']['conf_file'])
      config = IO.read(::File.expand_path(node['netatalk']['conf_file']))
      true if config =~ rendered_config.to_regexp
    end

    # Provides a helper method to determine if the node already has the
    # volume configuration in it's attributes. If the file does not yet exist
    # (as determined by #config_exists?), but the node has the volume in it's
    # attributes, we must render the config template with this volume's
    # attributes.
    #
    # @return [TrueClass, NilClass, FalseClass]
    #
    def node_has_config?
      return false unless node.attribute?('time_machine')
      return false unless node['time_machine']['volumes']
      true if node['time_machine']['volumes'].include?(rendered_config.to_h)
    end

    # The TMConfigOptions object. Essentially a helper object to ease multiple
    # volume configuration in the same file. Provides several serialization and
    # helper methods to determine if the nodes config file already contain's
    # this volumes attributes, serialize the configuration as a hash to be
    # stored in the node's attributes, and render the proper configuration
    # in the file at the end of the run
    #
    class TMConfigOptions
      attr_accessor :options

      # Initializes a new TMConfigOptions object
      #
      #   TMConfigOptions.new('TimeMachine', { path: '/a/path/to/the/volume' }
      #   TMConfigOptins.new(name: 'TimeMachine', path: '/a/path/to/the/volume')
      #
      # @param args [Array] variable number of arguments. If the first argument
      # is not a Hash (of options for the volume), the first argument will be
      # interpreted as the name of the volume. The name can also be set by
      # passing name: 'YOUR VOLUME NAME' in the options hash.
      #
      # All options besides name will be rendered in the apf.conf file WITHOUT
      # first being checked for validity. Please see the netatalk documentation
      # {http://netatalk.sourceforge.net/wiki/index.php/Main_Page}
      # for more details regarding configuration options.
      #
      def initialize(*args)
        opts = args.extract_options!
        @name = args.empty? ? (opts.delete(:name) || 'TimeMachine') : args[0]
        @options = default_opts.update(opts)
      end

      # Renders a string of the Volume's name in the format required by the
      # netatalk configuration file.
      #
      # @return [String] the volume name formatted properly
      #
      def section_header
        "[#{@name}]"
      end

      # Formats the configuration options for the netatalk config file.
      # Removes underscores and turns them into spaces, stringifies the symbol
      # keys of the options hash, and formats them all with '=' instead of ':'
      #
      #   c = TMConfigOptions.new(path: '/a/path', vol_size_limit: 1_024_000)
      #   c.pretty_opts  # => path = /a/path
      #                       vol size limit = 1024000
      #                       time machine = yes
      #
      # @return [String] the formatted string of options for the conf file
      #
      def pretty_opts
        options.map { |k, v| "#{k.to_s.tr('_', ' ')} = #{v}" }
      end

      # Formats the entire volume configuration to be rendered directly in the
      # netatalk config file. Makes use of #pretty_opts and #section_header
      #
      #   c = TMConfigOptions.new(path: '/a/path')
      #   c.to_s  # =>  [TimeMachine]
      #                 path = /a/path
      #                 vol size limit = 1024000
      #                 time machine = yes
      #
      # @return [String] the formatted configuration
      #
      def to_s
        pretty_opts.unshift(section_header).join("\n")
      end

      # Turns the formatted config options string into a regexp so the provider
      # can match the contents of the configuration file against the regexp,
      # thereby telling the provider whether or not this particular time machine
      # volume has been configured.
      #
      # @return [Regexp] the config options as a regexp
      #
      def to_regexp
        Regexp.new(pretty_opts.unshift(header_regex).join('\s+^'))
      end

      # Serializes the configuration options as a hash so they can be stored in
      # the node's attributes for rendering at the end of the chef run.
      #
      # Allows the object to be easily re-instantiated from the hash so the
      # file can be rendered at any time.
      #
      # @return [Hash] the serialized configuration
      #
      def to_h
        { name: @name }.merge(options)
      end

      private

      def header_regex
        "\\[#{@name}\\]"
      end

      def default_opts
        {
          path: nil,
          time_machine: true,
          vol_size_limit: 512_000
        }
      end
    end
  end

  # Helper methods for templates. No need to pollute the template namespace
  # with every method the provider needs.
  #
  module TemplateHelpers
    # See Helpers#rendered_config
    # Provides the same functionality of Helpers#rendered_config, but is not
    # dependent on instance state. Allows the template to instantiate multiple
    # TMConfigOptions objects in order to utilize their functionality.
    #
    # @param [Hash] serialized_config the hash stored in the node's attributes
    #
    # @return [TimeMachineCookbook::Helpers::TMConfigOptions] the config object
    #
    def render_config(serialized_config)
      TimeMachineCookbook::Helpers::TMConfigOptions.new(serialized_config)
    end
  end
end

# Adding extract_options! to Array so I don't have to require ActiveSupport
#
class Array
  # Extract options from a set of arguments. Removes and returns the last
  # element in the array if it's a hash, otherwise it returns a blank hash.
  #
  #   def options(*args)
  #     args.extract_options!
  #   end
  #
  #   options(1, 2)           # => {}
  #   options(1, 2, :a => :b) # => {:a => :b}
  #
  # @return [Hash] a hash of options extracted from the array
  #
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end
