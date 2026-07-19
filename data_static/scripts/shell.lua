---@meta

---API for a trailmakers "shell" using the built in chat
_G.shell = {
    ---internals used by the member functions, touching these can break stuff
    _internals = {
        msgQueue = {},
        commands = {},
        aliases = {}
    },
    ---helper functions for processing arguments
    helpers = {}
}

---Initialises all needed functions and variables
---@return nil
function shell.init()
    if tm.os.IsSingleplayer() then
        tm.playerUI.AddSubtleMessageForPlayer(0, "TerminalMod", "Not available in singleplayer.", 3, "")
        tm.os.Log("TerminalMod is not available in singleplayer.")
        return
    end

    tm.playerUI.OnChatMessage.add(shell._internals.processChatMessage)
    shell._internals.loadAliases()
    tm.os.Log("TerminalMod started.")
end

---buffers a chat message, is sent in chat on the next call of shell.flush()
---@param contents string
---@param senderName? string
---@param color? ModColor
---@return nil
function shell.bufferChat(contents, senderName, color)
    senderName = senderName or "shell"
    color = color or tm.color.White()

    table.insert(
        shell._internals.msgQueue,
        {
            _sender = senderName,
            _contents = contents,
            _color = color
        }
    )
end

---flushes the currently buffered chat messages
---@return nil
function shell.flush()
    for _, message in ipairs(shell._internals.msgQueue) do
        tm.playerUI.SendChatMessage(message._sender, message._contents, message._color)
    end

    shell._internals.msgQueue = {}
end

---registers a command as a callback
---@param callback fun(arguments: string): nil
---@param name string
---@return nil
function shell.addCommand(callback, name)
    shell._internals.commands[name] = callback
end

---adds an alias for a command, use `nil` for commandName to remove alias
---@param alias string
---@param commandName string|nil
---@return nil
function shell.addAlias(alias, commandName)
    shell._internals.aliases[alias] = commandName
end

---processes chat message and calls any function that has been registered as a command
---@param senderName string
---@param message string
---@param color ModColor
---@return nil
function shell._internals.processChatMessage(senderName, message, color)
    if senderName ~= tm.players.GetPlayerName(0) or string.sub(message, 1, 1) ~= '/' then
        return
    end

    local s = string.find(message, "%s") or #message + 1
    local cmdName = string.sub(message, 2, s - 1)
    local arg = string.sub(message, s + 1)
    tm.os.Log("Command: " .. cmdName .. ". Arguments: " .. arg)

    local command = shell._internals.commands[cmdName] or shell._internals.commands[shell._internals.aliases[cmdName]]
    if command then
        command(arg)
    else
        shell.bufferChat("Command not found.")
    end
end

---loads aliases from data_dynamic/aliases.tvs
---@return nil
function shell._internals.loadAliases()
    local contents = tm.os.ReadAllText_Dynamic("aliases.tsv")
    for line in string.gmatch(contents, "[^\n]+") do
        local s = string.find(line, "\t")
        local alias = string.sub(line, 0, s - 1)
        local command = string.sub(line, s + 1, #line)

        shell.addAlias(alias, command)
        tm.os.Log("Alias loaded: " .. alias .. " -> " .. command)
    end
end

---saves aliases to data_dynamic/aliases.tsv
---@return nil
function shell._internals.saveAliases()
    local contents = ""
    for key, value in pairs(shell._internals.aliases) do
        contents = contents .. key .. "\t" .. value .. "\n"
    end

    if contents == "" then
        contents = "\n"
    end

    tm.os.WriteAllText_Dynamic("aliases.tsv", contents)
end

---Splits a string by spaces, blocks enclosed in parentheses are grouped together.
---Parentheses can be escaped with `\"`, backslashes can be escaped with `\\`.
---Whitespace characters other than space might cause errors.
---Returns `nil` if string is invalid.
---@param line string
---@return table|nil
function shell.helpers.splitLine(line)
    local ptr = 1
    local blockMode = false
    local temp = ""
    local result = {}

    while ptr <= #line do
        local char = string.sub(line, ptr, ptr)

        if char == "\\" then
            local nextChar = string.sub(line, ptr + 1, ptr + 1)
            if nextChar ~= "\"" and nextChar ~= "\\" then
                return nil
            end

            temp = temp .. nextChar
            ptr = ptr + 1
        elseif blockMode then
            if char == "\"" then
                local nextChar = string.sub(line, ptr + 1, ptr + 1)
                if nextChar ~= " " and nextChar ~= "" then
                    return nil
                end

                table.insert(result, temp)
                temp = ""
                blockMode = false
            else
                temp = temp .. char
            end
        elseif char == " " then
            if temp ~= "" then
                table.insert(result, temp)
                temp = ""
            end
        elseif char == "\"" then
            if temp == "" then
                blockMode = true
            else
                return nil
            end
        else
            temp = temp .. char
        end

        ptr = ptr + 1
    end

    if temp ~= "" then
        table.insert(result, temp)
    end

    if #result > 0 then
        return result
    else
        return nil
    end
end
