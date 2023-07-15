# frozen_string_literal: true

class ServerVotesController < ApplicationController
  include Pagy::Backend

  def show
    @server_vote = server_vote_from_params
  end

  def new
    @server = server_from_params
    @reference = reference_from_params
    @captcha = Captcha.new
    @new_form = ServerVotes::NewForm.new
  end

  def create
    @server = server_from_params
    @reference = server_votes_new_form_params['reference']
    @captcha = Captcha.new
    @new_form = ServerVotes::NewForm.new(server_votes_new_form_params)

    if @new_form.valid?
      result = Servers::CreateVote.new(@server, @new_form.attributes, @captcha, request, current_user_account).call

      if result.success?
        flash[:success] = 'Your vote has been saved!'
        redirect_to(server_vote_path(result.data[:server_vote].suuid))
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

  def server_from_params
    Server.find_by_suuid!(params['server_suuid'])
  end

  def server_vote_from_params
    ServerVote.find_by_suuid!(params['suuid'])
  end

  def reference_from_params
    params['reference'].presence
  end

  def server_votes_new_form_params
    params.require('server_votes_new_form').permit('reference')
  end
end
