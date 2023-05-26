require 'json'
require 'optimist'

require_relative './../utility'
require_relative './../gh_helper'
require_relative './../git_helper'
require_relative './../config'

module CLI
    PR_SUBCOMMANDS = ['open', 'review-list']

    def self.command_pr_parse()
        command = ARGV.shift
        Optimist.die "Unknown subcommand #{command.inspect()}" unless PR_SUBCOMMANDS.include? command
        method = command_to_method(command)
        GhHelper.auth()
        self.send("command_pr_#{method}")
    end

    def self.command_pr_open_options()
        options = {}
        options = Optimist::options do
            opt(:dry, "Run a command, but without really changing anything, just check what you're about to do", :short => :n)
            stop_on_unknown()
        end

        return options
    end

    def self.command_pr_open()
        options = command_pr_open_options()
        branch = ARGV.shift
        Optimist.die "Unknown branch #{branch.inspect()}" if branch == nil || !GitHelper.branch_exists_on_remote?(branch, 'origin')
        options.concat(command_pr_open_options())
        pr_open_execute(branch, options)
    end

    def self.pr_open_execute(value, options)
        if !GitHelper.repo_exists?()
            print 'Git repo doesnt exists!'
            exit(1)
        end

        project = Config.project()
        if project == nil
            print 'Project is not initialized! Call "config init" first on repo!'
            exit(2)
        end

        branch = value
        if !GitHelper.branch_exists_on_remote?(branch, "origin")
            print "Branch '#{branch}' doesn't exist on remote 'origin'!"
            exit(5)
        end

        project_dir = Config.project_dir(project)
        if !File.exists?("#{project_dir}/impl.rb")
            print 'Must have impl.rb file!'
            exit(3)
        end

        prj_module = project.slice(0,1).capitalize + project.slice(1..-1)
        require_relative "#{project_dir}/impl" 
        if !eval("#{prj_module}.respond_to?(:get_pr_params)")
            print 'Impl must implement :get_pr_params instance method'
            exit(4)
        end

        params = eval("#{prj_module}.get_pr_params('#{branch}')")
        params['-B'] = "#{branch}"

        cmd = "gh pr create "
        params.each_pair do |key, value|
            cmd += "#{key} \"#{value}\" "
        end

        if options[:dry]
            print "#{cmd}\n"
        else
            `#{cmd}`
        end
    end

    def self.command_pr_review_list_options()
        options = {}
        options = Optimist::options do
            opt(:dry, "Run a command, but without really changing anything, just check what you're about to do", :short => :n)
            opt(:web, "Show in the web-browser (doesn't wor with open)", :short => :none)
            opt(:view, "Choose pull requests with label (only with review-list)", :type => :int, :short => :none)
            conflicts(:view, :web)
            stop_on_unknown()
        end

        return options
    end

    def self.command_pr_review_list()
        options = command_pr_review_list_options()
        pr_review_list_execute(options)
    end


    def self.pr_review_list_execute(options)
        if !GitHelper.repo_exists?()
            print 'Git repo doesnt exists!'
            exit(1)
        end

        project = Config.project()
        if project == nil
            print 'Project is not initialized! Call "config init" first on repo!'
            exit(2)
        end

        project_dir = Config.project_dir(project)
        if !File.exists?("#{project_dir}/impl.rb")
            print 'Must have impl.rb file!'
            exit(3)
        end

        prj_module = project.slice(0,1).capitalize + project.slice(1..-1)
        require_relative "#{project_dir}/impl" 
        if !eval("#{prj_module}.respond_to?(:get_pr_review_list_query)")
            print 'Impl must implement :get_pr_review_list_query instance method'
            exit(4)
        end

        query = eval("#{prj_module}.get_pr_review_list_query()")
        cmd = "gh pr list --search \"#{query}\" --json \"title,author,baseRefName,createdAt,headRefName,number,url\""

        if options[:dry]
            print "#{cmd}\n"
        else
            if options[:web]
                `open https://github.com/pulls?q=#{CGI.escape(query)}`
                return
            end

            output = `#{cmd}`
            prs = JSON.parse(output)

            if !options[:view_given]
                index = 1
                prs.each do |value|
                    printf("%02d [%s](%s) - %s [%s -> %s](#%4d)\n", index, value['createdAt'], value['author']['name'], value['title'], value['headRefName'], value['baseRefName'], value['number'])
                    index += 1
                end
            else
                count = prs.length
                if options[:view] < count
                    `open #{prs[options[:view] - 1]['url']}`
                else
                    print "List contains less then #{options[:view]} pull requests!\n"
                    index = 1
                    prs.each do |value|
                        printf("%02d [%s](%s) - %s [%s -> %s](#%4d)\n", index, value['createdAt'], value['author']['name'], value['title'], value['headRefName'], value['baseRefName'], value['number'])
                        index += 1
                    end
                end
            end
        end
    end
end