require 'json'
require_relative './git_helper'
require_relative './jira_helper'

module PrHelper
    @@jira_project_prefix_glob = "[A-Z]+"
    @@jira_tag_pattern_glob = "#{@@jira_project_prefix_glob}-[0-9]{1,5}"
    @@app_version_pattern_glob = "[0-9]+\.[0-9]+\.[0-9]+"

    def self.get_title_from_jira_ticket(ticket_id)
        jira = JiraHelper.get_client()
        ticket = jira.Issue.find(ticket_id)
        return ticket.summary.gsub!('"', '')
    end

    def self.get_title_from_last_commit()
        return GitHelper.get_last_commit_message()
    end
    
    def self.find_all_jira_tags_from_branch_name(branch)
        return branch.scan(/#{@@jira_tag_pattern_glob}/).uniq
    end

    def self.get_app_version_from_ticket_fix_version(ticket_id)
        jira = JiraHelper.get_client()
        issue = jira.Issue.find(ticket_id)
        fix_versions = issue.fixVersions
        fix_versions.each do |version|
            match = version.name.scan(/#{@@app_version_pattern_glob}/).first
            return match if match != nil
        end

        return nil
    end

    def self.get_app_version_from_tickets_fix_version(tickets)
        tickets.each do |ticket|
            version = get_app_version_from_ticket_fix_version(ticket)
            return version if version != nil
        end

        return nil
    end

    def self.find_all_jira_tags_from_commit_messages(base, head)
        log = GitHelper.get_commit_messages_between_commits(base, head)
        return log.scan(/#{@@jira_tag_pattern_glob}/).uniq
    end
end