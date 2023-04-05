require 'fileutils'

require_relative './../config'
require_relative './../git_helper'

module Automation
    def self.config(subcommand, value, options)
        if subcommand == 'init'
            if !GitHelper.repo_exists?()
                print 'Git repo doesnt exists!'
                exit(1)
            end

            project = value
            project_dir = Config.project_dir(project)
            if Dir.exists?(project_dir)
                print "Project directory already exists\r\n"
                exit(0)
            end

            init_filepath = "#{GitHelper.get_root_dir().chomp('/')}/.cla"

            File.open(init_filepath, 'w') { |definition_file| definition_file.write("#{project}") }
            Dir.mkdir(project_dir)
            FileUtils.copy_entry(Config.template_dir(), project_dir)
            File.open("#{project_dir.chomp('/')}/impl.rb", 'r+') do |definition_file|
                source = definition_file.read()
                source.gsub!(/\$PROJECT/, project.slice(0,1).capitalize + project.slice(1..-1))
                definition_file.pwrite(source, 0)
            end

            print "Project #{project} inited!\r\n"
            exit(0)
        end

        if subcommand == 'delete'
            if !GitHelper.repo_exists?()
                print "Git repo doesnt exists!"
                exit(1)
            end

            project = value
            project_dir = Config.project_dir(project)
            if Dir.exists?(project_dir)
                `rm -r #{project_dir}`
            end

            if File.exists?(init_filepath)
                `rm #{init_filepath}`
            end

            print 'Project directory deleted!'
            exit(0)
        end

        Config.set_value(subcommand, value, options['global'])
        exit(0)
    end
end
