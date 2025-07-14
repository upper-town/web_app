# frozen_string_literal: true

module Inside
  class ServersController < BaseController
    MAX_VERIFIED_SERVERS_PER_ACCOUNT = 10
    MAX_NOT_VERIFIED_SERVERS_PER_ACCOUNT = 2

    before_action(
      :max_verified_servers_per_account,
      :max_not_verified_servers_per_account,
      only: [:new, :create]
    )

    def index
      @servers = current_account.servers
    end

    def new
      @server = Server.new
    end

    def create
      @server = Server.new(server_params)
      server_banner_image_uploaded_file = ServerBannerImageUploadedFile.new(
        uploaded_file: params.require(:server)[:banner_image]
      )

      if @server.invalid?
        render(:new, status: :unprocessable_entity)

        return
      end

      if server_banner_image_uploaded_file.invalid?
        server_banner_image_uploaded_file.errors.each do |error|
          @server.errors.add(:banner_image, error)
        end
        render(:new, status: :unprocessable_entity)

        return
      end

      result = Servers::Create.new(
        @server,
        current_account,
        server_banner_image_uploaded_file
      ).call

      if result.success?
        redirect_to(inside_servers_path, success: "Your server has been added.")
      else
        flash.now[:alert] = result.errors
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
        flash[:success] = "Server has been archived. " \
          "Servers that are archived and without votes will be deleted soon automatically."
      else
        flash[:alert] = result.errors
      end

      redirect_to(inside_servers_path)
    end

    def unarchive
      server = server_from_params
      result = Servers::Unarchive.new(server).call

      if result.success?
        flash[:success] = t("inside.servers.unarchive.success")
      else
        flash[:alert] = result.errors
      end

      redirect_to(inside_servers_path)
    end

    def mark_for_deletion
      server = server_from_params
      result = Servers::MarkForDeletion.new(server).call

      if result.success?
        flash[:success] = t("inside.servers.mark_for_deletion.success")
      else
        flash[:alert] = result.errors
      end

      redirect_to(inside_servers_path)
    end

    def unmark_for_deletion
      server = server_from_params
      result = Servers::UnmarkForDeletion.new(server).call

      if result.success?
        flash[:success] = t("inside.servers.unmark_for_deletion.success")
      else
        flash[:alert] = result.errors
      end

      redirect_to(inside_servers_path)
    end

    private

    def server_from_params
      Server.find(params[:id])
    end

    def server_params
      params.expect(server: [
        :game_id,
        :country_code,
        :name,
        :site_url,
        :description,
        :info
      ])
    end

    def max_verified_servers_per_account
      count = current_account.servers.verified.count

      if count >= MAX_VERIFIED_SERVERS_PER_ACCOUNT
        redirect_to(
          inside_servers_path,
          warning: t("inside.servers.max_verified_servers_per_account")
        )
      end
    end

    def max_not_verified_servers_per_account
      count = current_account.servers.not_verified.count

      if count >= MAX_NOT_VERIFIED_SERVERS_PER_ACCOUNT
        redirect_to(
          inside_servers_path,
          warning: t("inside.servers.max_not_verified_servers_per_account")
        )
      end
    end
  end
end
