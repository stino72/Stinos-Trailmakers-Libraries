_G.animation = {
    utils = {},
    _internals = {}
}

---@class animationPlayer
---@field object ModGameObject
---@field timeScale number
---@field loop loopModes
---@field startTransform table
---@field keyframes table
---@field animationIndex integer
---@field interupted boolean
---@field completionCallback function?
---@field data any?
local animationPlayer = {}
animationPlayer.__index = animationPlayer

function animationPlayer:interupt()
    self.interupted = true
end


---@param timeScale number
function animationPlayer:setTimeScale(timeScale)
    self.timeScale = timeScale
end


---@class animationCallbackData
---@field object ModGameObject
---@field data any?
local animationCallbackData = {}
animationCallbackData.__index = animationCallbackData

---@enum loopModes
animation.loopModes = {
    never = "never",
    loop = "loop",
    pingPong = "ping pong"
}


---@param object ModGameObject
---@param data any?
---@return animationCallbackData
function animation._internals.CreateCallbackData(object, data)
    local instance = setmetatable({}, animationCallbackData)

    instance.object = object
    instance.data = data

    return instance
end

---@param object ModGameObject
---@param animationList table
---@param timeScale number?
---@param CompletionCallback function?
---@param data any?
---@return animationPlayer?
function animation.PlayAnimation(object, animationList, timeScale, CompletionCallback, data)
    local instance = setmetatable({}, animationPlayer)

    instance.object = object
    instance.loop = animationList["loop"]
    instance.timeScale = 1 / (timeScale or 1)
    instance.startTransform = animationList["start"]
    instance.keyframes = animationList["keyframes"]
    instance.animationIndex = 1
    instance.interupted = false

    if #instance.keyframes <= 0 then
        Print("Animation does not have keyframes")
        return nil
    end

    if animationList["loop"] == animation.loopModes.pingPong then
        animation.utils.ConbineTables(instance.keyframes, animation._internals.GenerateReversedKeyframes(animationList))
    end

    instance.completionCallback = CompletionCallback
    instance.data = data

    animation._internals.ResetObjectPos(object, instance.startTransform)

    local d = setmetatable({}, animationCallbackData)
    d.object = object
    d.data = instance

    animation._internals.PlayAnimationFrame(d)

    return instance
end


---@param anim table
function animation._internals.GenerateReversedKeyframes(anim)
    local keyframes = anim["keyframes"]
    local reversedKeyframes = {}
    local parallelBuffer = {}

    for i = #keyframes, 1, -1 do
        ---@type table
        local keyframe = keyframes[i]
        local newKeyframe = animation.utils.TableCopy(keyframe)
        local type = newKeyframe["type"]

        local j = 1

        if type == "wait" then
            goto finalize
        end

        while true do
            if i - j < 1 then
                newKeyframe["end value"] = anim["start"][type]
                break
            end

            if keyframes[i - j]["type"] == type then
                newKeyframe["end value"] = keyframes[i - j]["end value"]
                break
            end

            j = j + 1
        end

        newKeyframe["easing type"] = easings.swap[newKeyframe["easing type"]]

        ::finalize::
        if newKeyframe["parallel"] == true then
            table.insert(parallelBuffer, newKeyframe)
        else
            table.insert(reversedKeyframes, newKeyframe)
            for index, value in ipairs(parallelBuffer) do
                table.insert(reversedKeyframes, value)
            end
            parallelBuffer = {}
        end
    end

    return reversedKeyframes
end


---@param object ModGameObject
---@param transform table
function animation._internals.ResetObjectPos(object, transform)
    object.GetTransform().SetPositionWorld(animation.utils.TableToVector(transform["position"]))
    object.GetTransform().SetRotation(animation.utils.TableToVector(transform["rotation"]))
    object.GetTransform().SetScale(animation.utils.TableToVector(transform["scale"]))
end


---@param data animationCallbackData -- FIX: also gets called with tweenCallbackData, 
function animation._internals.PlayAnimationFrame(data)
    ---@type animationPlayer
    local aPlayer = data.data

    if aPlayer.interupted then
        return
    end

    if aPlayer.animationIndex > #aPlayer.keyframes then
        animation._internals.OnAnimationComplete(aPlayer)
        return
    end

    if aPlayer.loop == animation.loopModes.pingPong and aPlayer.animationIndex == #aPlayer.keyframes * 0.5 + 1 then
        if aPlayer.completionCallback then
            aPlayer.completionCallback(animation._internals.CreateCallbackData(aPlayer.object, aPlayer.data))
        end
    end

    local a = aPlayer.keyframes[aPlayer.animationIndex]
        
    local type = a["type"]

    Print(aPlayer.animationIndex, type)

    while true do
        aPlayer.animationIndex = aPlayer.animationIndex + 1

        if aPlayer.animationIndex > #aPlayer.keyframes then
            break
        end

        local animNew = aPlayer.keyframes[aPlayer.animationIndex]

        if animNew["parallel"] == true then
            animation._internals.PlayParallel(aPlayer.object, animNew, aPlayer.timeScale)
        else
            break
        end
    end

    if type == "wait" then
        timer.Create(a["duration"] * aPlayer.timeScale, animation._internals.PlayAnimationFrame, aPlayer)
        return
    end


    local f = tween.TweenFunctions[type]
    f(aPlayer.object, animation.utils.TableToVector(a["end value"]), a["duration"] * aPlayer.timeScale, a["easing"], a["easing type"], animation._internals.PlayAnimationFrame, aPlayer)
end


---@param object ModGameObject
---@param keyframe table
---@param timeScale number
function animation._internals.PlayParallel(object, keyframe, timeScale)
    local f = tween.TweenFunctions[keyframe["type"]]
    f(object, animation.utils.TableToVector(keyframe["end value"]), keyframe["duration"] * timeScale, keyframe["easing"], keyframe["easing type"])
end


---@param anim animationPlayer
function animation._internals.OnAnimationComplete(anim)
    if anim.completionCallback then
        anim.completionCallback(animation._internals.CreateCallbackData(anim.object, anim.data))
    end

    if anim.loop == animation.loopModes.never then
        return
    end

    if anim.loop == animation.loopModes.loop then
        animation._internals.ResetObjectPos(anim.object, anim.startTransform)
    end

    anim.animationIndex = 1
    animation._internals.PlayAnimationFrame(animation._internals.CreateCallbackData(anim.object, anim))
end


---@param table table
---@return ModVector3
function animation.utils.TableToVector(table)
    return tm.vector3.Create(table.x, table.y, table.z)
end 


---@param t table
---@return table
function animation.utils.TableCopy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end


---@param t table
---@param a table
---@return table
function animation.utils.ConbineTables(t, a)
    for i, v in ipairs(a) do
        table.insert(t, v)
    end
    return t
end