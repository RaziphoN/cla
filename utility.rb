def command_to_method(command)
    return command.gsub('-', '_')
end
