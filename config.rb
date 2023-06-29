require 'json'

module Config
    @@filename = "config.json"
    @@global_path = "#{File.dirname(__FILE__)}/#{@@filename}"
    @@project_path = "./.cla"
    @@values = nil

    def self.get_values()
        if @@values != nil
            return @@values
        end

        global = load(@@global_path)

        prj = project()
        local_path = "#{project_dir(prj).chomp('/')}/@@project_path"
        local = load(local_path)

        local_hash = local.to_hash()
        @@values = global.to_hash().merge(local.to_hash())
        return @@values
    end

    def self.load(path)
        if path == nil || !File.exists?(path)
            return JSON["{}"]
        end

        source = File.read(path)
        if source == nil
            return JSON["{}"]
        end

        return JSON.parse(source)
    end

    def self.template_dir()
        return "#{File.dirname(__FILE__)}/templates/"
    end

    def self.project_dir(project)
        return "#{File.dirname(__FILE__)}/prj/#{project}/"
    end
    
    def self.local_project_definition_path()
        return @@project_path
    end

    def self.get_filename()
        return @@filename
    end

    def self.project()
        path = @@project_path

        if path == nil || !File.exists?(path)
            return nil
        end

        source = File.read(path)
        return source
    end

    def self.project_module_name()
        project = project()
        module_name = project.slice(0,1).capitalize + project.slice(1..-1)
        return module_name
    end
end