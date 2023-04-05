require 'jira-ruby'
require_relative './config'

module JiraHelper
    def self.get_client()
        login = get_login()
        token = get_token()
        url = get_url()

        options = {
            :username => login,
            :password => token,
            :site => url,
            :context_path => '',
            :auth_type => :basic,
            :read_timeout => 120
        }

        client = JIRA::Client.new(options)
        return client
    end

    def self.get_login()
        config = Config.get_values()
        return config['JIRA_LOGIN']
    end

    def self.get_token()
        config = Config.get_values()
        return config['JIRA_TOKEN']
    end

    def self.get_url()
        config = Config.get_values()
        return config['JIRA_URL']
    end
end