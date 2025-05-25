# frozen_string_literal: true

class ServerVotesController < ApplicationController
  def show
    @server_vote = server_vote_from_params
  end

  def new
    @server = server_from_params
    @reference = reference_from_params
    @server_vote = ServerVote.new
  end

  def create
    @server = server_from_params
    @reference = server_vote_params[:reference]
    @server_vote = ServerVote.new(server_vote_params)

    result = captcha_check

    if result.failure?
      flash.now[:alert] = result.errors.full_messages
      render(:new, status: :unprocessable_entity)

      return
    end

    result = Servers::CreateVote.new(@server, @server_vote, request.remote_ip, current_account).call

    if result.success?
      redirect_to(
        server_vote_path(result.server_vote),
        success: "Your vote has been saved!"
      )
    else
      flash.now[:alert] = result.errors.full_messages
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def server_from_params
    Server.find(params[:server_id])
  end

  def server_vote_from_params
    ServerVote.find(params[:id])
  end

  def reference_from_params
    params[:reference].presence
  end

  def server_vote_params
    params.expect(server_vote: [:reference])
  end
end
