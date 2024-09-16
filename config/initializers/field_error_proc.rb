# frozen_string_literal: true

ActionView::Base.field_error_proc = proc do |html_tag, instance|
  case instance
  when ActionView::Helpers::Tags::Label
    html_tag
  else
    tag.div(class: 'field-with-errors') do
      html_tag + tag.div(class: 'invalid-feedback') do
        if instance.error_message.one?
          instance.error_message.first.capitalize
        else
          tag.ul do
            instance.error_message.each do |message|
              concat(tag.li(message.capitalize))
            end
          end
        end
      end
    end
  end
end
