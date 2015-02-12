module Alchemy
  module Modules
    mattr_accessor :alchemy_modules

    @@alchemy_modules = YAML.load_file(File.expand_path('../../../config/alchemy/modules.yml', __FILE__))

    def self.included(base)
      base.send :helper_method, :alchemy_modules, :module_definition_for
    end

    # Register a Alchemy module.
    #
    # A module is a Hash that must have at least a name and a navigation key
    # that has a controller and action name.
    #
    # == Example:
    #
    #     name: 'module',
    #     navigation: {
    #       controller: 'admin/controller_name',
    #       action: 'index'
    #     }
    #
    def self.register_module(module_definition)
      @@alchemy_modules << module_definition.stringify_keys
    end

    # Get the module definition for given module name
    #
    # You can also pass a hash of an module definition.
    # It then tries to find the module defintion from controller name and action name
    #
    def module_definition_for(name)
      case name
      when String
        alchemy_modules.detect { |p| p['name'] == name }
      when Hash
        alchemy_modules.detect do |alchemy_module|
          definition_from_subnavi(alchemy_module, params.stringify_keys) ||
            definition_from_mainnavi(alchemy_module, params.stringify_keys)
        end
      else
        raise ArgumentError, "Could not find module definition for #{name}"
      end
    end

    private

    def alchemy_module_navigation(alchemy_module)
      alchemy_module.stringify_keys!
      alchemy_module.fetch('navigation', {}).stringify_keys
    end

    def definition_from_subnavi(alchemy_module, params)
      navi = alchemy_module_navigation(alchemy_module)['sub_navigation']
      return if navi.nil?
      navi.map(&:stringify_keys).detect do |navi|
        controller_matches?(navi, params) && action_matches?(navi, params)
      end
    end

    def definition_from_mainnavi(alchemy_module, params)
      navi = alchemy_module_navigation(alchemy_module)
      controller_matches?(navi, params) && action_matches?(navi, params)
    end

    def controller_matches?(navi, params)
      remove_slash(navi['controller']) == remove_slash(params['controller'])
    end

    def action_matches?(navi, params)
      navi['action'] == params['action']
    end

    def remove_slash(name)
      name.gsub(/^\//, '')
    end
  end
end
