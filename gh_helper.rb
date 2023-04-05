require 'json'
require_relative './config'

module GhHelper
    def self.auth()
        config = Config.get_values()

        if config['GITHUB_TOKEN'] == nil
            print 'Token not found!'
            return
        end

        if ENV['GH_TOKEN'] != nil
            ENV['GH_TOKEN'] = config['GITHUB_TOKEN']
            return
        end

        if ENV['GITHUB_TOKEN'] != nil
            ENV['GITHUB_TOKEN'] = config['GITHUB_TOKEN']
            return
        end

        ENV['GH_TOKEN'] = config['GITHUB_TOKEN']
    end

    def self.get_pr_info(number)
        return JSON.parse(`gh pr view #{number} --json "title,additions,assignees,author,baseRefName,body,changedFiles,commits,createdAt,headRefName,headRepository,id,isDraft,labels,latestReviews,mergeable,milestone,number,state,url,reviewRequests"`)
    end
end