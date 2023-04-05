require 'slack-ruby-client'
require_relative './secret_helper'

class SlackHelper
    def self.get_slack_client()
        Slack.configure do |config|
            config.token = get_token()
        end

        return Slack::Web::Client.new
    end
    
    def self.get_token()
        secrets = Secrets.get_values()

        if secrets['SLACK_TOKEN'] != nil
            return secrets['SLACK_TOKEN']
        end

        return ENV['SLACK_TOKEN']
    end
end