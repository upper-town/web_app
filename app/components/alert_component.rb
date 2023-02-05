# frozen_string_literal: true

class AlertComponent < ApplicationComponent
  DEFAULT_SCHEME = :info

  ALERT_CLASS = {
    danger:  'text-red-700    bg-red-100    border-red-500',
    info:    'text-gray-700   bg-gray-100   border-gray-500',
    success: 'text-green-700  bg-green-100  border-green-500',
    warning: 'text-orange-700 bg-orange-100 border-orange-500',
  }.freeze

  BUTTON_DISMISS_CLASS = {
    danger:  'text-red-500    bg-red-100    hover:bg-red-200    focus:ring-red-400',
    info:    'text-gray-500   bg-gray-100   hover:bg-gray-200   focus:ring-gray-400',
    success: 'text-green-500  bg-green-100  hover:bg-green-200  focus:ring-green-400',
    warning: 'text-orange-500 bg-orange-100 hover:bg-orange-200 focus:ring-orange-400',
  }.freeze

  renders_one :button_link_to, ->(*args, **kwargs, &block) do
    kwargs = { class: "btn btn-#{@scheme}" }.merge(kwargs)

    link_to(*args, **kwargs, &block)
  end

  def initialize(scheme: DEFAULT_SCHEME, subject: '', dismissible: true, **options)
    @scheme = scheme
    @subject = subject
    @dismissible = dismissible

    @options = build_default_options.merge(options)
    @button_dismiss_options = build_default_button_dismiss_options
  end

  def render?
    @subject.present? || content.present?
  end

  private

  def build_default_options
    {
      data: { controller: 'alert-component' },
      role: 'alert',
      class: token_list(
        ALERT_CLASS.fetch(@scheme, ALERT_CLASS[DEFAULT_SCHEME]),
        '
          border-l-4
          flex
          flex-row
          max-w-screen-lg
          p-4
          w-full
        '
      )
    }
  end

  def build_default_button_dismiss_options
    {
      data: { action: 'click->alert-component#close' },
      type: 'button',
      aria: { label: I18n.t('components.alert.close') },
      class: token_list(
        BUTTON_DISMISS_CLASS.fetch(@scheme, BUTTON_DISMISS_CLASS[DEFAULT_SCHEME]),
        '
          -mx-1.5
          -my-1.5
          focus:ring-2
          h-8
          inline-flex
          ml-auto
          p-1.5
          rounded-lg
          w-8
        '
      )
    }
  end
end
