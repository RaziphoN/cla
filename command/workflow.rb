require 'json'

require_relative './../gh_helper'
require_relative './../git_helper'
require_relative './../config'

module Automation
    def self.workflow(subcommand, options)
        GhHelper.auth()

        case subcommand
            when 'run'
                workflow_run(options)
        end
    end
    
    def self.workflow_run(options)
        
    end
end