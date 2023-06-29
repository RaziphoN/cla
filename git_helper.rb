
module GitHelper
    def self.get_root_dir()
        dir = `git rev-parse --show-toplevel`
        return dir
    end

    def self.repo_exists?()
        `git rev-parse --is-inside-work-tree 2>/dev/null`
        return $? == 0
    end

    def self.get_current_branch()
        return `git branch --show-current`.strip
    end
    
    def self.is_ancestor_of(base, branch)
        branch = branch.gsub(%r!\s!, '')
        base = base.gsub(%r!\s!, '')
        `git merge-base --is-ancestor #{base} #{branch}`
        return $? == 0
    end

    def self.branch_exists_on_remote?(branch_name, remote)
        branch_name = branch_name.gsub(%r!\s!, '')
        remote = remote.gsub(%r!\s!, '')
        `git ls-remote --exit-code '#{remote}' '#{branch_name}'`
        return $? == 0
    end
    
    def self.get_commit_messages_between_commits(base, head)
        head = head.strip
        base = base.strip
        return `git log #{head} --not #{base} --no-merges --format="%s"`
    end
    
    def self.get_last_commit_message()
        return `git log HEAD -1 --no-merges --format="%s"`.strip
    end
end