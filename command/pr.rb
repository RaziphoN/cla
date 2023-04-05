require 'json'

require_relative './../gh_helper'
require_relative './../git_helper'
require_relative './../config'

module Automation
    def self.pull_request(subcommand, value, options)
        GhHelper.auth()

        case subcommand
            when 'open'
                pr_open(value, options)
            when 'review-list'
                pr_review_list(value, options)
            when 'merge-list'
                pr_merge_list(value, options)
        end
    end

    def self.pr_open(value, options)
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

    def self.pr_review_list(value, options)
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
                prs.each do |value|
                    printf("[%s](%s) - %s [%s -> %s](#%4d)\n", value['createdAt'], value['author']['name'], value['title'], value['headRefName'], value['baseRefName'], value['number'])
                end
            else
                count = prs.length
                if options[:view] < count
                    `open #{prs[options[:view]]['url']}`
                else
                    print "List contains less then #{options[:view]} pull requests!\n"
                    prs.each do |value|
                        printf("[%s](%s) - %s [%s -> %s](#%4d)\n", value['createdAt'], value['author']['name'], value['title'], value['headRefName'], value['baseRefName'], value['number'])
                    end
                end
            end
        end
    end

    def self.pr_merge_list(value, options)
        print 'Not implemented!'
    end
end