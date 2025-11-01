# frozen_string_literal: true

class ServerVotesController < ApplicationController
  RATE_LIMIT_DURATION = -> { Rails.env.development? ? 1.minute : 6.hours }

  before_action :set_server, only: [:new, :create]

  rate_limit(
    to: 1,
    within: RATE_LIMIT_DURATION.call,
    by: -> { "#{request.remote_ip}:#{@server.game_id}" },
    with: -> do
      new
      flash.now[:alert] = t("shared.messages.too_many_votes_for_game", time: RATE_LIMIT_DURATION.call.inspect)
      render(:new, status: :too_many_requests)
    end,
    name: "create",
    only: [:create]
  )

  def show
    @server_vote = server_vote_from_params
  end

  def new
    @reference = reference_from_params
    @server_vote = ServerVote.new
  end

  def create
    @reference = server_vote_params[:reference]
    @server_vote = ServerVote.new(server_vote_params)

    result = check_captcha

    if result.failure?
      flash.now[:alert] = result.errors
      render(:new, status: :unprocessable_entity)

      return
    end

    result = Servers::CreateVote.new(@server, @server_vote, request.remote_ip, current_account).call

    if result.success?
      redirect_to(
        server_vote_path(result.server_vote),
        success: "Your vote has been saved! It will be consolidated in one minute."
      )
    else
      flash.now[:alert] = result.errors
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def set_server
    @server = server_from_params
  end

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
