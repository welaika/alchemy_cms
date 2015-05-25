module Alchemy
  module OptionsParams
    extend ActiveSupport::Concern

    included do
      before_action :set_options_from_params
      helper_method :options_from_params
    end

    # Extracts options from params.
    #
    # Helps to parse JSONified options into Hash or Array
    #
    def options_from_params
      @_options_from_params ||= begin
        case options_params
        when ''
          {}
        when String
          JSON.parse(options_params).symbolize_keys
        else
          options_params
        end
      end
    end

    private

    def options_params
      params.fetch(:options, {})
    end

    def set_options_from_params
      @options = options_from_params
    end
  end
end
