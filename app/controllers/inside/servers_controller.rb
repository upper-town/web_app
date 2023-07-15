# frozen_string_literal: true

module Inside
  class ServersController < BaseController
    def index
      @servers = current_user_account.servers
    end

    def new
      set_form_options

      @new_form = Servers::NewForm.new
    end

    def create
      set_form_options

      @new_form = Servers::NewForm.new(servers_new_form_params)
      @new_form.user_account = current_user_account

      if @new_form.valid?
        result = Servers::Create.new(@new_form.attributes, current_user_account).call

        if result.success?
          flash[:success] = 'Your server has been added!'
          redirect_to(inside_servers_path)
        else
          flash.now[:alert] = result.errors.full_messages
          render(:new, status: :unprocessable_entity)
        end
      else
        flash.now[:alert] = @new_form.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    private

    def servers_new_form_params
      params.require('servers_new_form').permit(
        'app_id',
        'country_code',
        'name',
        'site_url'
      )
    end

    def set_form_options
      form_options_query = FormOptionsQuery.new(
        cache_enabled: true,
        cache_options: {
          key_prefix: 'inside:servers_new',
          expires_in: 1.minute
        }
      )
      @app_id_options = form_options_query.build_app_id_options
      @country_code_options = form_options_query.build_country_code_options
    end
  end
end
