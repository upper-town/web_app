# frozen_string_literal: true

module Servers
  class CreateVote
    def initialize(server, form_attributes, captcha, request, user_account = nil)
      @server = server
      @form_attributes = form_attributes
      @captcha = captcha
      @request = request
      @user_account = user_account

      @rate_limiter = CreateVoteRateLimiter.build(@request, @server.app_id)
    end

    def call
      result = @captcha.call(@request)
      return result if result.failure?

      result = @rate_limiter.call
      return result if result.failure?

      server_vote = build_server_vote
      server_vote.assign_attributes(@form_attributes)

      if server_vote.invalid?
        @rate_limiter.uncall
        return Result.failure(server_vote.errors)
      end

      begin
        server_vote.save!
      rescue StandardError => e
        @rate_limiter.uncall
        raise e
      end

      schedule_jobs(server_vote)

      Result.success(server_vote: server_vote)
    end

    private

    def build_server_vote
      ServerVote.new(
        uuid:         SecureRandom.uuid,
        server:       @server,
        app_id:       @server.app_id,
        country_code: @server.country_code,
        remote_ip:    @request.remote_ip,
        user_account: @user_account,
      )
    end

    def schedule_jobs(server_vote)
      ConsolidateVoteCountsJob.set(queue: 'critical').perform_async(server_vote.server_id, 'current', true)
    end
  end
end
