# frozen_string_literal: true

class ServerVotesController < ApplicationController
  def show
    @server_vote = server_vote_from_params
  end

  def new
    @server = server_from_params
    @reference = reference_from_params
    @new_form = ServerVotes::NewForm.new
  end

  def create
    @server = server_from_params
    @reference = server_votes_new_form_params['reference']
    @new_form = ServerVotes::NewForm.new(server_votes_new_form_params)

    result = captcha_check

    if result.failure?
      flash.now[:alert] = result.errors.full_messages
      render(:new, status: :unprocessable_entity)

      return
    end

    if @new_form.invalid?
      flash.now[:alert] = @new_form.errors.full_messages
      render(:new, status: :unprocessable_entity)

      return
    end

    result = Servers::CreateVote.new(@server, @new_form.attributes, request, current_user_account).call

    if result.success?
      redirect_to(
        server_vote_path(result.data[:server_vote].uuid),
        success: 'Your vote has been saved!'
      )
    else
      flash.now[:alert] = result.errors.full_messages
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def server_from_params
    Server.find_by_suuid!(params['server_suuid'])
  end

  def server_vote_from_params
    ServerVote.find_by!(uuid: params['uuid'])
  end

  def reference_from_params
    params['reference'].presence
  end

  def server_votes_new_form_params
    params.require('server_votes_new_form').permit('reference')
  end
end
