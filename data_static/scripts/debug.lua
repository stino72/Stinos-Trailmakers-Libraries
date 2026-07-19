function Print(...)
    local s = ""
    for _, v in ipairs({...}) do
        if type(v) == "table" then
            s = s .. " " .. _Encode(v)
        else
            s = s .. " " .. tostring(v)
        end
    end

    tm.playerUI.SendChatMessage("Debug - Print:", s, tm.color.White())
    tm.os.Log(s)
end


local function escape_str(s)
    local replacements = {
        ['"']  = '\\"',
        ['\\'] = '\\\\',
        ['\b'] = '\\b',
        ['\f'] = '\\f',
        ['\n'] = '\\n',
        ['\r'] = '\\r',
        ['\t'] = '\\t',
    }

    return s:gsub('[%z\1-\31\\"]', function(c)
        return replacements[c] or string.format("\\u%04x", c:byte())
    end)
end


local function is_array(t)
    local i = 1
    for k, _ in pairs(t) do
        if k ~= i then
            return false
        end
        i = i + 1
    end
    return true
end


function _Encode(value)
    local t = type(value)

    if t == "nil" then
        return "null"

    elseif t == "boolean" then
        return tostring(value)

    elseif t == "number" then
        return tostring(value)

    elseif t == "string" then
        return '"' .. escape_str(value) .. '"'

    elseif t == "table" then
        local result = {}

        if is_array(value) then
            for i = 1, #value do
                table.insert(result, _Encode(value[i]))
            end
            return "[" .. table.concat(result, ",") .. "]"
        else
            for k, v in pairs(value) do
                table.insert(
                    result,
                    _Encode(tostring(k)) .. ":" .. _Encode(v)
                )
            end
            return "{" .. table.concat(result, ",") .. "}"
        end

    else
        return t
    end
end