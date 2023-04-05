require 'optimist'

class Cla
    COMMANDS = {
        'config' => 'Create/Update a local automation config to setup',
        'pr' => 'Manage pull request automation'
    }

    PR_SUBCOMMANDS = {
        'open' => "Open a pull request for current repository to a target branch",
        'review-list' => "Get a list of PRs that you have to review",
        'merge-list' => "Get a list of PRs that you have to merge"
    }

    def initialize()
        @subopts, @command, @subcommand, @value = nil, nil, nil, nil
        @globalopts = Optimist::options do
            version 'Command line automation (cla) version 1.0.0'
            banner "Usage:"
            banner "    cla [options] [<command> [suboptions]]\n \n"
            banner "Options:"
            opt :version, "Print version and exit", :short => :v
            opt :help, "Show help message", :short => :h
            stop_on COMMANDS.keys
            banner "\nCommands:"
            COMMANDS.each { |cmd, desc| banner format("    %-10s %s", cmd, desc) }
        end
        return if ARGV.empty?()
        @command = ARGV.shift
        Optimist.die "Unknown command #{@command.inspect()}" unless COMMANDS.key? @command
        self.send("#{@command}")
    end

    def config()
        cmd = @command
        @subopts = Optimist::options do
            banner "Usage:"
            banner "    cla config [options] [[<key> <value>] | [<command> [<value>]]]\n \n"
            banner "Options for #{cmd}:"
            opt(:global, "update global config", :short => :none) if 
            stop_on_unknown
        end

        @subcommand = ARGV.shift
        Optimist.die("Config key is not present or sub command is not correct") if @subcommand == nil || @subcommand !~ /[A-Za-z_]+/
        @value = ARGV.shift
        Optimist.die "Config or subcommand value is not present" if @value == nil
    end

    def pr()
        cmd = @command
        @subcommand = ARGV.shift
        Optimist.die "Unknown subcommand #{@subcommand.inspect()}" unless PR_SUBCOMMANDS.key? @subcommand
        
        if @subcommand == 'open'
            @value = ARGV.shift
            Optimist.die "Unknown branch #{@value.inspect()}" if @value == nil
        end

        @subopts = Optimist::options do
            banner "Usage:"
            banner "    cla pr <subcommand> [<target_branch> [options]]\n \n"
            banner "Subcommands for #{cmd}:\n"
            PR_SUBCOMMANDS.each { |cmd, desc| banner format("    %-10s %s", cmd, desc) }

            banner "\nOptions for #{cmd}:\n"
            opt(:dry, "Run a command, but without really changing anything, just check what you're about to do", :short => :n)

            opt(:web, "Show in the web-browser (doesn't wor with open)", :short => :none)
            #opt(:milestone, "Choose pull requests with milestone (only with review-list)", :type => :string, :short => :none)
            #opt(:label, "Choose pull requests with label (only with review-list)", :type => :string, :short => :none)
            opt(:view, "Choose pull requests with label (only with review-list)", :type => :int, :short => :none)
            conflicts(:view, :web)
            stop_on_unknown()
        end
    end

    attr_reader :globalopts, :command, :subopts, :subcommand, :value
end