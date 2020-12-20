module ActionView::Helpers
  module FormHelper
    def error_for(object_name, attribute, **options)
      tag.span options[:content], options.merge!(id: error_id_for(object_name, attribute))
    end

    def error_id_for(object_name, attribute)
      Optimism.error_selector.sub("RESOURCE", object_name.to_s.delete("]").tr("[", "_")).sub("ATTRIBUTE", attribute.to_s)[1..-1]
    end
  end

  class FormBuilder
    def container_for(attribute, **options, &block)
      @template.tag.div @template.capture(&block), options.merge!(
        id: container_id_for(attribute),
        class: @template.token_list(options[:class], {
          error: object.errors.include?(attribute)
        }),
      ) if block_given?
    end

    def container_id_for(attribute)
      Optimism.container_selector.sub("RESOURCE", object_name.to_s.delete("]").tr("[", "_")).sub("ATTRIBUTE", attribute.to_s)[1..-1]
    end

    def error_for(attribute, **options)
      @template.error_for(object_name, attribute, options.merge!(
        content: object.errors.full_messages_for(attribute).join(" ")
      ))
    end
  end
end

module OptimismHelper
  
end
