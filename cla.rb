require_relative './config'
require_relative './pr_helper'
require_relative './gh_helper'
require_relative './git_helper'
require_relative './jira_helper'

require_relative './commands'
require_relative './command/config'
require_relative './command/pr'


cla = Cla.new()

case cla.command
    when "pr"
        Automation.pull_request(cla.subcommand, cla.value, cla.subopts)
    when "config"
        Automation.config(cla.subcommand, cla.value, cla.subopts)
end