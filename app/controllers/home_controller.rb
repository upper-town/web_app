# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    # Rails expected Flash keys

    flash[:notice] = {
      subject: 'Subject here',
      content: 'Some Rails notice message',
      dismissible: true,
      link_to: ["I'm button", '#']
    }
    flash[:alert] = {
      subject: 'Subject here',
      content: 'Some Rails alert message',
      dismissible: true,
      link_to: ["I'm button", '#']
    }

    # AlertComponent scheme

    flash[:info] = {
      subject: 'Subject here',
      content: 'Some info message',
      dismissible: true,
      link_to: ["I'm button", '#']
    }
    flash[:danger] = {
      subject: 'Subject here',
      content: 'Some danger message',
      dismissible: true
    }
    flash[:warning] = {
      subject: 'Subject here',
      content: 'Some warning message',
      dismissible: true,
      link_to: ["I'm button", '#']
    }

    flash[:success] = 'Some success message'
  end
end
