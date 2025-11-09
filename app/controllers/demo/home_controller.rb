# frozen_string_literal: true

# rubocop:disable Rails/I18nLocaleTexts
module Demo
  class HomeController < BaseController
    def uppertown_json
      render json: {
        "accounts" => [
          "11111111-1111-1111-1111-111111111111",
          "22222222-2222-2222-2222-222222222222"
        ]
      }
    end

    def index
      # Rails expected Flash keys

      flash.now[:notice] = {
        subject: "Subject here",
        content: "Some Rails notice message",
        dismissible: true,
        link_to: ["I'm button", "#"]
      }
      flash.now[:alert] = {
        subject: "Subject here",
        content: "Some Rails alert message",
        dismissible: true,
        link_to: ["I'm button", "#"]
      }

      # Alert scheme

      flash.now[:notice] = {
        subject: "Subject here",
        content: "Some info message",
        dismissible: true,
        link_to: ["I'm button", "#"]
      }
      flash.now[:danger] = {
        subject: "Subject here",
        content: "Some danger message",
        dismissible: true
      }
      flash.now[:warning] = {
        subject: "Subject here",
        content: "Some warning message",
        dismissible: true,
        link_to: ["I'm button", "#"]
      }

      flash.now[:success] = "Some success message"
    end
  end
end
# rubocop:enable Rails/I18nLocaleTexts
