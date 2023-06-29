require 'json'
require 'optimist'

require_relative './../error'
require_relative './../utility'
require_relative './../gh_helper'
require_relative './../git_helper'
require_relative './../config'

module CLI
    def self.command_build_parse()
        GhHelper.auth()
        self.send("command_build")
    end

    def self.command_build_options()
       options = {}
       options[:dry] = true
       return options
    end

    def self.command_build()
        options = command_build_options()
        command_build_execute(options)
    end
    
    def self.command_build_execute(options)
        build_execute_batch(options)
    end

    def self.build_execute_batch(options)
        Validation.validate_repository_exists()
        Validation.validate_project_is_initialized()

        if options[:all]
            pr_query = "org:tripledotstudios state:open draft:false author:@me"
            cmd = "gh pr list --search \"#{pr_query}\" --json \"headRefName,mergeable,state\""
            output = `#{cmd}`
            prs = JSON.parse(output)
        end

        if (prs == nil || prs.length == 0)
            options[:branch] = GitHelper.get_current_branch()
            build_execute(options)
        else
            for pr in prs
                if !pr['mergeable']
                    next
                end

                options[:branch] = pr['headRefName']
                self.build_execute(options)
            end
        end
    end

    def self.build_execute(options)
        project = Config.project()
        project_dir = Config.project_dir(project)
        require_relative "#{project_dir}/impl" 
        prj = Object.const_get(Config.project_module_name())

        if !prj.respond_to?(:get_build_params)
            print 'Impl must implement :get_build_params instance method'
            exit(100)
        end

        params = prj.get_build_params(options)
        workflows = params['workflows']
        query = params['query']

        for workflow in workflows
            cmd = "gh workflow run #{workflow} #{query}"
            print "#{cmd}\n"
            if !options[:dry]
                `#{cmd}`
            end
        end
    end
end
