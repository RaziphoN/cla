require 'fileutils'

require_relative './../utility'
require_relative './../config'
require_relative './../git_helper'

module CLI
    CONFIG_SUBCOMMANDS = ['init', 'delete']

    def self.command_config_parse()
        command = ARGV.shift
        Optimist.die "Unknown subcommand #{command.inspect()}" unless CONFIG_SUBCOMMANDS.include? command
        method = command_to_method(command)
        self.send("command_config_#{method}")
    end

    def self.command_config_init_options()
        return {}
    end

    def self.command_config_init()
        options = command_config_init_options()
        project = ARGV.shift
        command_config_init_execute(project, options)
    end

    def self.command_config_init_execute(project, options)
        if !GitHelper.repo_exists?()
            print 'Git repo doesnt exists!'
            exit(1)
        end

        init_filepath = "#{GitHelper.get_root_dir().chomp('/').strip()}/.cla"
        if !File.exists?(init_filepath)
            print "Creating config file at: #{init_filepath}\n"
            File.open(init_filepath, 'w') { |definition_file| definition_file.write("#{project}") }
        else
            print "Project init file already exists! Delete it first"
            exit(1)
        end

        project_dir = Config.project_dir(project)
        if Dir.exists?(project_dir)
            print "Project directory already exists\r\n"
            exit(0)
        end

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

    def self.command_config_delete_options()
        return {}
    end

    def self.command_config_delete()
        options = command_config_delete_options()
        project = ARGV.shift
        options.concat(command_config_delete_options()).uniq()
        command_config_delete_execute(project, options)
    end

    def self.command_config_delete_execute(project, options)
        if !GitHelper.repo_exists?()
            print "Git repo doesnt exists!"
            exit(1)
        end

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
end