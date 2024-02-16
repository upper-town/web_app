# frozen_string_literal: true

module Inside
  class ServersController < BaseController
    MAX_VERIFIED_SERVERS_PER_USER_ACCOUNT = 10
    MAX_NOT_VERIFIED_SERVERS_PER_USER_ACCOUNT = 2

    before_action(
      :max_verified_servers_per_user_account,
      :max_not_verified_servers_per_user_account,
      only: [:new, :create]
    )

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

      if @new_form.invalid?
        flash.now[:alert] = @new_form.errors.full_messages
        render(:new, status: :unprocessable_entity)

        return
      end

      result = Servers::Create.new(@new_form.attributes, current_user_account).call

      if result.success?
        redirect_to(
          inside_servers_path,
          success: 'Your server has been added.'
        )
      else
        flash.now[:alert] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    end

    def edit
    end

    def update
    end

    def archive
      server = server_from_params
      result = Servers::Archive.new(server).call

      if result.success?
        flash[:success] = 'Server has been archived. ' \
          'Servers that are archived and without votes will be deleted soon automatically.'
      else
        flash[:alert] = result.errors.full_messages
      end

      redirect_to(inside_servers_path)
    end

    def unarchive
      server = server_from_params
      result = Servers::Unarchive.new(server).call

      if result.success?
        flash[:success] = 'Server has been unarchived.'
      else
        flash[:alert] = result.errors.full_messages
      end

      redirect_to(inside_servers_path)
    end

    def mark_for_deletion
      server = server_from_params
      result = Servers::MarkForDeletion.new(server).call

      if result.success?
        flash[:success] = 'Server has been marked to be deleted.'
      else
        flash[:alert] = result.errors.full_messages
      end

      redirect_to(inside_servers_path)
    end

    def unmark_for_deletion
      server = server_from_params
      result = Servers::UnmarkForDeletion.new(server).call

      if result.success?
        flash[:success] = 'Server has been unmarked for deletion.'
      else
        flash[:alert] = result.errors.full_messages
      end

      redirect_to(inside_servers_path)
    end

    private

    def server_from_params
      Server.find_by_suuid!(params['suuid'])
    end

    def servers_new_form_params
      params.require('servers_new_form').permit(
        'app_id',
        'country_code',
        'name',
        'site_url'
      )
    end

    def max_verified_servers_per_user_account
      count = current_user_account.servers.verified.count

      if count >= MAX_VERIFIED_SERVERS_PER_USER_ACCOUNT
        redirect_to(
          inside_servers_path,
          warning: 'You already have too many verified servers associated with your user account.'
        )
      end
    end

    def max_not_verified_servers_per_user_account
      count = current_user_account.servers.not_verified.count

      if count >= MAX_NOT_VERIFIED_SERVERS_PER_USER_ACCOUNT
        redirect_to(
          inside_servers_path,
          warning: 'You have many servers pending verification. Please verify them first before adding more servers.'
        )
      end
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

      nil
    end
  end
end
