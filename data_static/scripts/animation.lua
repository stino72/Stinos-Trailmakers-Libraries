_G.animation = {}

---@class anim
---@field object ModGameObject
---@field startValue ModVector3
---@field endValue ModVector3
---@field duration number
---@field timeLeft number
---@field easingFunction function
---@field completionCallback function?
---@field data any?
---@field animationCallback function
local anim = {}
anim.__index = anim


---@class animationTable
---@field object ModGameObject
---@field timeScale number
---@field loop loopModes
---@field startPostion ModVector3
---@field startRotation ModVector3
---@field startScale ModVector3
---@field keyframes table
---@field animationIndex integer
---@field animationAmount integer
---@field interupted boolean
---@field reversed boolean
---@field reversedKeyframes table
---@field completionCallback function?
---@field data any?
local animationTable = {}
animationTable.__index = animationTable

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


---@type anim[]
local animations = {}

---@param animationCallback function
---@param object ModGameObject
---@param startValue ModVector3
---@param endValue ModVector3
---@param duration number
---@param easing easing?
---@param easingType easingType?
---@param CompletionCallback function?
---@param data any?
function _SetupAnimation(animationCallback, object, startValue, endValue, duration, easing, easingType, CompletionCallback, data)
    local instance = setmetatable({}, anim)

    instance.object = object
    instance.startValue = startValue
    instance.endValue = endValue
    instance.duration = duration
    instance.timeLeft = duration
    instance.easingFunction = easings.GetEasingFunction(easing or animation.easing.Linear, easingType or animation.easingType.In)
    instance.completionCallback = CompletionCallback
    instance.animationCallback = animationCallback
    instance.data = data

    table.insert(animations, instance)
end

---@param a anim
---@return animationCallbackData
function CreateAnimationCallbackData(a)
    local instance = setmetatable({}, animationCallbackData)

    instance.object = a.object
    instance.data = a.data

    return instance
end

---@param object ModGameObject
---@param endPostition ModVector3
---@param duration number
---@param easing easing?
---@param easingType easingType?
---@param CompletionCallback function?
---@param data any?
function animation.AnimatePosition(object, endPostition, duration, easing, easingType, CompletionCallback, data)
    _SetupAnimation(_AnimatePostition, object, object.GetTransform().GetPositionWorld(), endPostition, duration, easing, easingType, CompletionCallback, data)
end


---@param object ModGameObject
---@param endRotation ModVector3
---@param duration number
---@param easing easing?
---@param easingType easingType?
---@param CompletionCallback function?
---@param data any?
function animation.AnimateRotation(object, endRotation, duration, easing, easingType, CompletionCallback, data)
    _SetupAnimation(_AnimateRotation, object, object.GetTransform().GetRotation(), endRotation, duration, easing, easingType, CompletionCallback, data)
end


---@param object ModGameObject
---@param endScale ModVector3
---@param duration number
---@param easing easing?
---@param easingType easingType?
---@param CompletionCallback function?
---@param data any?
function animation.AnimateScale(object, endScale, duration, easing, easingType, CompletionCallback, data)
    _SetupAnimation(_AnimateScale, object, object.GetTransform().GetScale(), endScale, duration, easing, easingType, CompletionCallback, data)
end

---@param object ModGameObject
---@param animationList table
---@param timeScale number?
---@param CompletionCallback function?
---@param data any?
function animation.PlayAnimation(object, animationList, timeScale, CompletionCallback, data)
    local instance = setmetatable({}, animationTable)

    instance.object = object
    instance.loop = animationList["loop"]
    instance.timeScale = 1 / (timeScale or 1)
    instance.startPostion = TableToVector(animationList["start"]["position"])
    instance.startRotation = TableToVector(animationList["start"]["rotation"])
    instance.startScale = TableToVector(animationList["start"]["scale"])
    instance.keyframes = animationList["keyframes"]
    instance.animationIndex = 1
    instance.animationAmount = #instance.keyframes
    instance.interupted = false
    instance.reversed = false

    if #instance.keyframes <= 0 then
        Print("Animation does not have keyframes")
        return nil
    end

    if animationList["loop"] == animation.loopModes.pingPong then
        instance.reversedKeyframes = GenerateReversedKeyframes(animationList)
    end

    instance.completionCallback = CompletionCallback
    instance.data = data

    ResetObjectPost(object, instance.startPostion, instance.startRotation, instance.startScale)

    local d = setmetatable({}, animationCallbackData)
    d.object = object
    d.data = instance

    PlayAnimationFrame(d)

    return instance
end

---@param animationList table
function GenerateReversedKeyframes(animationList)
    local startTransform = animationList["start"]
    local keyframes = animationList["keyframes"]
    local reversedKeyframes = {}
    local parallelBuffer = {}

    for i = #keyframes, 1, -1 do
        ---@type table
        local keyframe = keyframes[i]
        local newKeyframe = TableCopy(keyframe)
        local type = newKeyframe["type"]

        local j = 1

        if type == "wait" then
            goto finalize
        end

        while true do
            if i - j < 1 then
                newKeyframe["end value"] = startTransform[type]
                break
            end

            if keyframes[i - j]["type"] == type then
                newKeyframe["end value"] = keyframes[i - j]["end value"]
                break
            end

            j = j + 1
        end

        if newKeyframe["easing type"] == easings.easingType.In then
            newKeyframe["easing type"] = easings.easingType.Out
        elseif newKeyframe["easing type"] == easings.easingType.Out then
            newKeyframe["easing type"] = easings.easingType.In
        end


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


function TableCopy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end


function animationTable:interupt()
    self.interupted = true
end

---@param object ModGameObject
---@param pos ModVector3
---@param rot ModVector3
---@param scale ModVector3
function ResetObjectPost(object, pos, rot, scale)
    object.GetTransform().SetPositionWorld(pos)
    object.GetTransform().SetRotation(rot)
    object.GetTransform().SetScale(scale)
end


local animationFunctions = {
    ["position"] = animation.AnimatePosition,
    ["rotation"] = animation.AnimateRotation,
    ["scale"] = animation.AnimateScale,
}

---@param data animationCallbackData
function PlayAnimationFrame(data)
    ---@type animationTable
    local table = data.data

    if table.interupted then
        return
    end

    if table.animationIndex > table.animationAmount then
        --Print("animation ended")
        if table.completionCallback then
            local d = setmetatable({}, animationCallbackData)
            d.object = table.object
            d.data = table.data
            table.completionCallback(d)
        end

        if table.loop == animation.loopModes.never then
            return
        end

        if table.loop == animation.loopModes.loop then
            ResetObjectPost(table.object, table.startPostion, table.startRotation, table.startScale)
        elseif table.loop == animation.loopModes.pingPong then
            table.reversed = not table.reversed
        end

        table.animationIndex = 1
        local d = setmetatable({}, animationCallbackData)
        d.object = table.object
        d.data = table
        PlayAnimationFrame(d)

        return
    end

    local a = {}
    if not table.reversed then
        a = table.keyframes[table.animationIndex]
    else
        a = table.reversedKeyframes[table.animationIndex]
    end
        

    local type = a["type"]

    while true do
        table.animationIndex = table.animationIndex + 1

        if table.animationIndex > table.animationAmount then
            break
        end

        local animNew = {}
        if not table.reversed then
            animNew = table.keyframes[table.animationIndex]
        else
            animNew = table.reversedKeyframes[table.animationIndex]
        end

        if animNew["parallel"] == true then
            PlayParallel(table.object, animNew, table.timeScale)
        else
            break
        end
    end

    if type == "wait" then
        timer.Create(a["duration"] * table.timeScale, PlayAnimationFrame, table)
        return
    end


    local f = animationFunctions[type]
    f(table.object, TableToVector(a["end value"]), a["duration"] * table.timeScale, a["easing"], a["easing type"], PlayAnimationFrame, table)
end


---@param object ModGameObject
---@param keyframe table
---@param timeScale number
function PlayParallel(object, keyframe, timeScale)
    local f = animationFunctions[keyframe["type"]]
    f(object, TableToVector(keyframe["end value"]), keyframe["duration"] * timeScale, keyframe["easing"], keyframe["easing type"])
end


function animation.UpdateAnimations()
    for index, value in ipairs(animations) do
        _UpdateAnimations(value, index)
    end
end


---@param a anim
---@param index integer
function _UpdateAnimations(a, index)
    a.timeLeft = a.timeLeft - tm.os.GetModDeltaTime()

    local progress = math.min((a.duration - a.timeLeft) / a.duration, 1)

    a.animationCallback(a, a.easingFunction(progress))

    if a.timeLeft > 0 then
        return
    end

    if a.completionCallback then
        a.completionCallback(CreateAnimationCallbackData(a))
    end

    table.remove(animations, index)
end


---@param a anim
---@param t number
function _AnimatePostition(a, t)
    a.object.GetTransform().SetPositionWorld(animation.LerpV3(a.startValue, a.endValue, t))
end

---@param a anim
---@param t number
function _AnimateRotation(a, t)
    a.object.GetTransform().SetRotation(animation.LerpAngleV3(a.startValue, a.endValue, t))
end

---@param a anim
---@param t number
function _AnimateScale(a, t)
    a.object.GetTransform().SetScale(animation.LerpV3(a.startValue, a.endValue, t))
end


---@param table table
---@return ModVector3
function TableToVector(table)
    return tm.vector3.Create(table.x, table.y, table.z)
end 


---@param a number
---@param b number 
---@param t number
---@return number
function animation.Lerp(a, b, t)
    return a + (b - a) * t
end


---@param a ModVector3
---@param b ModVector3
---@param t number
---@return ModVector3
function animation.LerpV3(a, b, t)
    return a + (b - a) * t
end


---@param a number
---@param b number 
---@param t number
---@return number
function animation.LerpAngle(a, b, t)
    return a + ((b - a - 180) % 360 - 180) * t
end

---@param a ModVector3
---@param b ModVector3
---@param t number
---@return ModVector3
function animation.LerpAngleV3(a, b, t)
    return tm.vector3.Create(
        animation.LerpAngle(a.x, b.x, t),
        animation.LerpAngle(a.y, b.y, t),
        animation.LerpAngle(a.z, b.z, t)
    )
end