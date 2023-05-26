#!/usr/bin/ruby
require_relative './config'
require_relative './pr_helper'
require_relative './gh_helper'
require_relative './git_helper'
require_relative './jira_helper'

require_relative './command/config.rb'
require_relative './command/pr.rb'
require_relative './command/conflict.rb'
require_relative './command/workflow.rb'

module CLI
    VERSION = '1.0.0'
    COMMANDS = ['config', 'pr', 'conflict', 'workflow']

    def self.execute()
        command, = nil, nil, nil, nil
        globalopts = Optimist::options do
            version "CLA Version: #{VERSION}"
            opt :version, "Print version and exit", :short => :v
            opt :help, "Show help message", :short => :h
            stop_on_unknown()
        end
        return if ARGV.empty?()
        command = ARGV.shift
        Optimist.die "Unknown command #{command.inspect()}" unless COMMANDS.include? command
        
        
        eval("command_#{command}_parse()")
    end
end


CLI.execute()