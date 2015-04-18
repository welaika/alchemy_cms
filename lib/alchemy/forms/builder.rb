module Alchemy
  module Forms
    class Builder < SimpleForm::FormBuilder

      # Renders a button tag wrapped in a div with 'submit' class.
      #
      def submit(label, options = {})
        options = {class: 'submit'}.update(options[:wrapper_html] || {})
        button_options = {class: 'btn btn-success'}.update(options[:input_html] || {})
        template.content_tag('div', options) do
          template.content_tag('button', label, button_options)
        end
      end
    end
  end
end
