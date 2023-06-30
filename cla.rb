#!/usr/bin/ruby
require_relative './config'
require_relative './pr_helper'
require_relative './gh_helper'
require_relative './git_helper'
require_relative './jira_helper'

require_relative './command/config.rb'
require_relative './command/pr.rb'
require_relative './command/conflict.rb'
require_relative './command/build.rb'

module CLI
    VERSION = '1.0.0'
    COMMANDS = ['config', 'pr', 'conflict', 'build']

    def self.execute()
        command = nil
        globalopts = Optimist::options do
            version "cla: #{VERSION}"
            stop_on_unknown()
        end
        return if ARGV.empty?()
        command = ARGV.shift
        Optimist.die "Unknown command #{command.inspect()}" unless COMMANDS.include? command

        eval("command_#{command}_parse()")
    end
end

CLI.execute()