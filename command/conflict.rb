require 'json'
require 'optimist'

require_relative './../error'
require_relative './../config'
require_relative './../gh_helper'
require_relative './../git_helper'

module CLI
    CONFLICT_DEFAULT_EDITOR = 'rider'
    CONFLICT_SUBCOMMANDS = ['edit']

    def self.command_conflict_parse()
        command = ARGV.shift
        Optimist.die "Unknown subcommand #{command.inspect()}" unless CONFLICT_SUBCOMMANDS.include? command
        method = command_to_method(command)
        self.send("command_conflict_#{method}")
    end

    def self.command_conflict_edit_options()
        options = Optimist::options do
            opt(:editor, "Choose editor to open conflict files with", :short => :e)
            stop_on_unknown()
        end

        return options
    end

    def self.command_conflict_edit()
        options = command_conflict_edit_options()
        command_conflict_edit_execute(options)
    end
    
    def self.command_conflict_edit_execute(options)
        if !GitHelper.repo_exists?()
            print 'Git repo doesnt exists!'
            exit(1)
        end

        editor = CONFLICT_DEFAULT_EDITOR
        if options[:editor_given]
            editor = options[:editor]
        end

        status = `git status --porcelain`.strip()
        entries = status.split("\n")

        entries.each do |entry|
            if entry[0] == 'U' || entry[1] == 'U'
                path = entry.slice(3..-1)
                `#{editor} #{path}`
            end
        end
    end
end