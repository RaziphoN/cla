require_relative 'git_helper'

module Error
    def self.git_repository_doesnt_exists()
        print 'Git repo doesnt exists!'
        exit(1)
    end

    def self.unknown_command(command)
        print "Unknown subcommand #{command.inspect()}"
        exit(3)
    end

    def self.branch_doesnt_exists(branch, remote)
        print "Branch '#{branch}' doesn't exist on remote '#{remote}'!"
        exit(5)
    end

    def self.project_is_not_initialized(project)
        print 'Project is not initialized or directory was removed! Run "config init" first!'
        exit(2)
    end
    
    def self.custom(message)
        print message
        exit(6)
    end
end

module Validation
    def self.validate_command_exists(command, options)
        Error.unknown_command(command) unless options.include? command
    end

    def self.validate_repository_exists()
        if !GitHelper.repo_exists?()
            Error.git_repository_doesnt_exists()
        end
    end

    def self.validate_branch_exists(branch, remote)
        if !GitHelper.branch_exists_on_remote?(branch, remote)
            Error.branch_doesnt_exists(branch, remote)
        end
    end

    def self.validate_project_is_initialized()
        project = Config.project()
        if project == nil
            Error.project_is_not_initialized(project)
        end

        project_dir = Config.project_dir(project)
        if !File.exists?("#{project_dir}")
            Error.project_is_not_initialized(project)
        end
    end
end