# frozen_string_literal: true

ActionView::Base.field_error_proc = ->(html_tag, instance) do
  case instance
  when ActionView::Helpers::Tags::Label
    html_tag
  else
    tag.div(class: "field-with-errors") do
      html_tag + tag.div(class: "invalid-feedback") do
        if instance.error_message.one?
          StringHelper.format_sentence(instance.error_message.first)
        else
          tag.ul do
            instance.error_message.each do |message|
              concat(tag.li(StringHelper.format_sentence(message)))
            end
          end
        end
      end
    end
  end
end
