require_relative '../../pr_helper'
require_relative '../../jira_helper'

module $PROJECT
    def self.get_pr_params(branch)
        params = {
            :t => PrHelper.get_title_from_last_commit()
        }

        return params
    end

    def self.get_pr_review_list_query()
        return "state:open"
    end
end