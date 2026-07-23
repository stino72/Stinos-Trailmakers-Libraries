_G.tween = {
    _internals = {}
}

---@class Tweener
---@field object ModGameObject
---@field startValue ModVector3
---@field endValue ModVector3
---@field duration number
---@field timeLeft number
---@field easingFunction function
---@field completionCallback function?
---@field data any?
---@field animationCallback function
local Tweener = {}
Tweener.__index = Tweener

---@class TweenCallbackData
---@field object ModGameObject
---@field data any?
local TweenCallbackData = {}
TweenCallbackData.__index = TweenCallbackData

---@type Tweener[]
local tweeners = {}

---@param animationCallback function
---@param object ModGameObject
---@param startValue ModVector3
---@param endValue ModVector3
---@param duration number
---@param easing Easing?
---@param easingType EasingType?
---@param CompletionCallback function?
---@param data any?
function tween._internals.SetupTweener(animationCallback, object, startValue, endValue, duration, easing, easingType, CompletionCallback, data)
    local instance = setmetatable({}, Tweener)

    instance.object = object
    instance.startValue = startValue
    instance.endValue = endValue
    instance.duration = duration
    instance.timeLeft = duration

    instance.easingFunction = easings.GetEasingFunction(easing or animation.easing.Linear, easingType or animation.easingType.In)
    instance.completionCallback = CompletionCallback
    instance.animationCallback = animationCallback
    instance.data = data

    table.insert(tweeners, instance)
end


---@param object ModGameObject
---@param data any?
---@return TweenCallbackData
function tween._internals.CreateTweenCallbackData(object, data)
    local instance = setmetatable({}, TweenCallbackData)

    instance.object = object
    instance.data = data

    return instance
end


---@param object ModGameObject
---@param endPostition ModVector3
---@param duration number
---@param easing Easing?
---@param easingType EasingType?
---@param CompletionCallback function?
---@param data any?
function tween.AnimatePosition(object, endPostition, duration, easing, easingType, CompletionCallback, data)
    tween._internals.SetupTweener(tween._internals.AnimatePostition, object, object.GetTransform().GetPositionWorld(), endPostition, duration, easing, easingType, CompletionCallback, data)
end


---@param object ModGameObject
---@param endRotation ModVector3
---@param duration number
---@param easing Easing?
---@param easingType EasingType?
---@param CompletionCallback function?
---@param data any?
function tween.AnimateRotation(object, endRotation, duration, easing, easingType, CompletionCallback, data)
    tween._internals.SetupTweener(tween._internals.AnimateRotation, object, object.GetTransform().GetRotation(), endRotation, duration, easing, easingType, CompletionCallback, data)
end


---@param object ModGameObject
---@param endScale ModVector3
---@param duration number
---@param easing Easing?
---@param easingType EasingType?
---@param CompletionCallback function?
---@param data any?
function tween.AnimateScale(object, endScale, duration, easing, easingType, CompletionCallback, data)
    tween._internals.SetupTweener(tween._internals.AnimateScale, object, object.GetTransform().GetScale(), endScale, duration, easing, easingType, CompletionCallback, data)
end

---@type function[]
tween.TweenFunctions = {
    ["position"] = tween.AnimatePosition,
    ["rotation"] = tween.AnimateRotation,
    ["scale"] = tween.AnimateScale,
}


function tween.UpdateTweeners()
    for index, value in ipairs(tweeners) do
        tween._internals.UpdateAnimations(value, index)
    end
end


---@param tweener Tweener
---@param index integer
function tween._internals.UpdateAnimations(tweener, index)
    tweener.timeLeft = tweener.timeLeft - tm.os.GetModDeltaTime()

    local progress = math.min((tweener.duration - tweener.timeLeft) / tweener.duration, 1)

    tweener.animationCallback(tweener, tweener.easingFunction(progress))

    if tweener.timeLeft > 0 then
        return
    end

    if tweener.completionCallback then
        tweener.completionCallback(tween._internals.CreateTweenCallbackData(tweener.object, tweener.data))
    end

    table.remove(tweeners, index)
end


---@param tweener Tweener
---@param t number
function tween._internals.AnimatePostition(tweener, t)
    tweener.object.GetTransform().SetPositionWorld(tween.LerpV3(tweener.startValue, tweener.endValue, t))
end

---@param tweener Tweener
---@param t number
function tween._internals.AnimateRotation(tweener, t)
    tweener.object.GetTransform().SetRotation(tween.LerpAngleV3(tweener.startValue, tweener.endValue, t))
end

---@param tweener Tweener
---@param t number
function tween._internals.AnimateScale(tweener, t)
    tweener.object.GetTransform().SetScale(tween.LerpV3(tweener.startValue, tweener.endValue, t))
end


---@param a number
---@param b number 
---@param t number
---@return number
function tween.Lerp(a, b, t)
    return a + (b - a) * t
end


---@param a ModVector3
---@param b ModVector3
---@param t number
---@return ModVector3
function tween.LerpV3(a, b, t)
    return a + (b - a) * t
end


---@param a number
---@param b number 
---@param t number
---@return number
function tween.LerpAngle(a, b, t)
    return a + ((b - a - 180) % 360 - 180) * t
end

---@param a ModVector3
---@param b ModVector3
---@param t number
---@return ModVector3
function tween.LerpAngleV3(a, b, t)
    return tm.vector3.Create(
        tween.LerpAngle(a.x, b.x, t),
        tween.LerpAngle(a.y, b.y, t),
        tween.LerpAngle(a.z, b.z, t)
    )
end