# frozen_string_literal: true

class ServerVotesController < ApplicationController
  include Pagy::Backend

  def show
    @server_vote = server_vote_from_params
  end

  def new
    @server = server_from_params
    @server_vote = ServerVote.new
    @reference_id = reference_id_from_params
  end

  def create
    @server = server_from_params
    @server_vote = ServerVote.new
    @reference_id = server_vote_params_for_new['reference_id']

    form = ServerVotes::NewForm.new(server_vote_params_for_new)

    if form.valid?
      result = Servers::CreateVote.new(@server, form.attributes, request, current_user_account).call

      if result.success?
        flash[:success] = 'Your vote has been saved!'
        redirect_to(server_vote_path(result.data[:server_vote].suuid))
      else
        flash.now[:alert] = result.errors.full_messages
        render(:new, status: :unprocessable_entity)
      end
    else
      flash.now[:alert] = form.errors.full_messages
      render(:new, status: :unprocessable_entity)
    end
  end

  private

  def server_from_params
    Server.find_by_suuid!(params['server_suuid'])
  end

  def server_vote_from_params
    ServerVote.find_by_suuid!(params['suuid'])
  end

  def reference_id_from_params
    params['reference_id'].presence
  end

  def server_vote_params_for_new
    params.require('server_vote').permit('reference_id')
  end
end
