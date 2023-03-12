# frozen_string_literal: true

module Inside
  class BaseController < ApplicationController
    before_action :authenticate_user!

    layout 'application'
  end
end
