# frozen_string_literal: true

module Admin
  class DemosController < BaseController
    def show
      # Rails expected Flash keys

      flash.now[:notice] = {
        subject: 'Subject here',
        content: 'Some Rails notice message',
        dismissible: true,
        link_to: ["I'm button", '#']
      }
      flash.now[:alert] = {
        subject: 'Subject here',
        content: 'Some Rails alert message',
        dismissible: true,
        link_to: ["I'm button", '#']
      }

      # Alert scheme

      flash.now[:info] = {
        subject: 'Subject here',
        content: 'Some info message',
        dismissible: true,
        link_to: ["I'm button", '#']
      }
      flash.now[:danger] = {
        subject: 'Subject here',
        content: 'Some danger message',
        dismissible: true
      }
      flash.now[:warning] = {
        subject: 'Subject here',
        content: 'Some warning message',
        dismissible: true,
        link_to: ["I'm button", '#']
      }

      flash.now[:success] = 'Some success message'
    end
  end
end
