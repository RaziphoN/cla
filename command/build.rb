require 'json'
require 'optimist'

require_relative './../error'
require_relative './../utility'
require_relative './../gh_helper'
require_relative './../git_helper'
require_relative './../config'

module CLI
    class Option
        @name = ""
        @desc = ""
        @opts = {}
    end

    def self.command_build_parse()
        GhHelper.auth()

        Validation.validate_repository_exists()
        Validation.validate_project_is_initialized()
        project = Config.project()
        project_dir = Config.project_dir(project)
        require_relative "#{project_dir}/impl"
        prj = Object.const_get(Config.project_module_name())

        command_build(prj)
    end

    def self.command_build_options(custom_opts)
       options = Optimist::options do
           opt(:all, "Build all PRs", :short => :x)
           opt(:dry, "Run a command, but without really changing anything, just check what you're about to do")
           custom_opts.each do |key, value|
               opt(key, value[:desc], value)
           end
           stop_on_unknown()
       end

       return options
    end

    def self.command_build(prj)
        custom_opts = prj.get_build_options()
        options = command_build_options(custom_opts)
        command_build_execute(prj, options)
    end

    def self.command_build_execute(prj, options)
        build_execute(prj, options)
    end

    def self.build_execute(prj, options)
        if !prj.respond_to?(:get_build_params)
            print 'Impl must implement :get_build_params instance method'
            exit(100)
        end

        params = prj.get_build_params(options)
        workflows = params['workflows']
        query = params['query']
        refs = params['refs']

        for ref in refs
            for workflow in workflows
                cmd = "gh workflow run #{workflow} --ref \"#{ref}\" #{query}"
                if options[:dry]
                    print "#{cmd}\n"
                    next
                end

                print "Scheduled workflow #{workflow} for #{ref}\n"
                `#{cmd}`
            end
        end
    end
end
