---@meta
---Tween library, made by stino.
---
---a Tweener can animation either the position, rotation or scale of a `ModGameObject`
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
---@param CompletionCallback fun(data: TweenCallbackData)?
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

---Creates a Tweener that animations the position of `object`.
---@param object ModGameObject The object that will be animated.
---@param endPostition ModVector3 The end position of the Tween, start position is the position of `object` when the function is called.
---@param duration number The amount of time the tweener will take in seconds.
---@param easing Easing? What easing the tweener will uses, if nothing is set it will be linear.
---@param easingType EasingType? What easingType the tweener will uses, if nothing is set it will be In.
---@param CompletionCallback fun(data: TweenCallbackData)? Function to execute when the Tween is completed.
---@param data any? Arbitrary data passed to the callback function.
function tween.CreatePositionTween(object, endPostition, duration, easing, easingType, CompletionCallback, data)
	tween._internals.SetupTweener(tween._internals.TweenPosition, object, object.GetTransform().GetPositionWorld(), endPostition, duration, easing, easingType, CompletionCallback, data)
end


---Creates a Tweener that animations the rotation of `object`.
---@param object ModGameObject The object that will be animated.
---@param endRotation ModVector3 The end rotation of the Tween, start position is the position of `object` when the function is called.
---@param duration number The amount of time the tweener will take in seconds.
---@param easing Easing? What easing the tweener will uses, if nothing is set it will be linear.
---@param easingType EasingType? What easingType the tweener will uses, if nothing is set it will be In.
---@param CompletionCallback fun(data: TweenCallbackData)? Function to execute when the Tween is completed.
---@param data any? Arbitrary data passed to the callback function.
function tween.CreateRotationTween(object, endRotation, duration, easing, easingType, CompletionCallback, data)
	tween._internals.SetupTweener(tween._internals.TweenRotation, object, object.GetTransform().GetRotation(), endRotation, duration, easing, easingType, CompletionCallback, data)
end


---Creates a Tweener that animations the scale of `object`.
---@param object ModGameObject The object that will be animated.
---@param endScale ModVector3 The end scale of the Tween, start position is the position of `object` when the function is called.
---@param duration number The amount of time the tweener will take in seconds.
---@param easing Easing? What easing the tweener will uses, if nothing is set it will be linear.
---@param easingType EasingType? What easingType the tweener will uses, if nothing is set it will be In.
---@param CompletionCallback fun(data: TweenCallbackData)? Function to execute when the Tween is completed.
---@param data any? Arbitrary data passed to the callback function.
function tween.CreateScaleTween(object, endScale, duration, easing, easingType, CompletionCallback, data)
	tween._internals.SetupTweener(tween._internals.TweenScale, object, object.GetTransform().GetScale(), endScale, duration, easing, easingType, CompletionCallback, data)
end


---Reference for the tween functions by name.
---@type function[]
tween.TweenFunctions = {
	["position"] = tween.CreatePositionTween,
	["rotation"] = tween.CreateRotationTween,
	["scale"] = tween.CreateScaleTween,
}


---Updates all Tweeners, this **must** be called every process frame.
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
function tween._internals.TweenPosition(tweener, t)
	tweener.object.GetTransform().SetPositionWorld(tween.LerpV3(tweener.startValue, tweener.endValue, t))
end


---@param tweener Tweener
---@param t number
function tween._internals.TweenRotation(tweener, t)
	tweener.object.GetTransform().SetRotation(tween.LerpAngleV3(tweener.startValue, tweener.endValue, t))
end


---@param tweener Tweener
---@param t number
function tween._internals.TweenScale(tweener, t)
	tweener.object.GetTransform().SetScale(tween.LerpV3(tweener.startValue, tweener.endValue, t))
end


---Lerps from `a` to `b` with `t`
---return will be equal to `a` when `t` is 0 and return will be equal to `b` when `t` is 1.
---`t` can to outside of [0, 1].
---@param a number
---@param b number 
---@param t number
---@return number
function tween.Lerp(a, b, t)
	return a + (b - a) * t
end


---Lerps all axis from `a` to `b` with `t`
---return will be equal to `a` when `t` is 0 and return will be equal to `b` when `t` is 1.
---`t` can to outside of [0, 1].
---@param a ModVector3
---@param b ModVector3
---@param t number
---@return ModVector3
function tween.LerpV3(a, b, t)
	return a + (b - a) * t
end


---Lerps from `a` to `b` with `t`
---will always take the shortest way in range [-180, 180]
---return will be equal to `a` when `t` is 0 and return will be equal to `b` when `t` is 1.
---`t` can to outside of [0, 1].
---@param a number
---@param b number 
---@param t number
---@return number
function tween.LerpAngle(a, b, t)
	return a + ((b - a - 180) % 360 - 180) * t
end


---Lerps all axis from `a` to `b` with `t`
---will always take the shortest way in range [-180, 180]
---return will be equal to `a` when `t` is 0 and return will be equal to `b` when `t` is 1.
---`t` can to outside of [0, 1].
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
