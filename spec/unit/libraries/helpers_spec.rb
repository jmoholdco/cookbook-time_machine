require './libraries/helpers'

module TimeMachineCookbook
  class Dummy
    include Helpers

    def new_resource
      @new_resource ||= OpenStruct.new.tap do |new_resource|
        new_resource.name = 'Time Machine'
        new_resource.path = '/a/path/to/a/volume'
        new_resource.config_options = {}

      end
    end
  end
end
