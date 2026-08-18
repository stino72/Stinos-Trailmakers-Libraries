---@meta
---Animation library, made by Stino
---
---Runs a series of tweeners on a single `ModGameObject` specified in a table with start positions and keyframes.  
---see exampleAnimation.json.
---
---requires:
--- - easings.lua
--- - tween.lua
--- - timer.lua
---
---make sure they run with `tm.os.DoFile` in main.lua
_G.animation = {
	utils = {},
	_internals = {}
}

---Animation
---@class AnimationPlayer
---@field object ModGameObject
---@field timeScale number
---@field loop LoopModes
---@field startTransform StartTransform
---@field keyframes Keyframe[]
---@field animationIndex integer
---@field interupted boolean
---@field completionCallback function?
---@field data any?
local AnimationPlayer = {}
AnimationPlayer.__index = AnimationPlayer

---Stops the animation when it reaches the next keyframe.
function AnimationPlayer:interupt()
	self.interupted = true
end


---Sets the timeScale when it reaches the next keyframe.
---@param timeScale number 
function AnimationPlayer:setTimeScale(timeScale)
	self.timeScale = timeScale
end

---Options for how the animation should loop.
---
---`never` - The animation will never loop
---
---`loop` - The animation will return back to the start once its completed.
---
---`pingPong` - The animation will play in reverse when its completed, (if the parallel frames dont have the same lenght as their main frame it might not reverse correctly)
---@enum LoopModes
animation.loopModes = {
	never = "never",
	loop = "loop",
	pingPong = "ping pong"
}

---@class Keyframe
---@field type string
---@field endValue ModVector3
---@field duration integer
---@field easing Easing
---@field easingType EasingType
---@field parallel boolean
local Keyframe = {}
Keyframe.__index = Keyframe

---@class StartTransform
---@field position ModVector3
---@field rotation ModVector3
---@field scale ModVector3
local StartTransform = {}
StartTransform.__index = StartTransform

---@class AnimationCallbackData
---@field object ModGameObject
---@field data any?
local AnimationCallbackData = {}
AnimationCallbackData.__index = AnimationCallbackData

---@param object ModGameObject
---@param data any?
---@return AnimationCallbackData
function animation._internals.CreateCallbackData(object, data)
	local instance = setmetatable({}, AnimationCallbackData)

	instance.object = object
	instance.data = data

	return instance
end


---Plays an animation with the given keyframes.
---@param object ModGameObject The object that will be animated
---@param animationList table The List of keyframes as well as the loop mode.
---@param timeScale number? Timer scale that animation will be played at, 1 is normal speed, 2 is twice as fast ect.
---@param CompletionCallback fun(data: AnimationCallbackData)? Function to execute when the Animation is completed, will be called at the end of every loop.
---@param data any? Arbitrary data passed to the callback function.
---@return AnimationPlayer? AnimationPlayer Reference to the animation.
function animation.PlayAnimation(object, animationList, timeScale, CompletionCallback, data)
	if #animationList["keyframes"] <= 0 then
		tm.os.Log("Animation does not have keyframes")
		return nil
	end

	local instance = setmetatable({}, AnimationPlayer)

	instance.object = object
	instance.loop = animationList["loop"]
	instance.timeScale = 1 / (timeScale or 1)
	instance.startTransform = animation._internals.CreateStartTransform(animationList["start"])

	instance.keyframes = {}
	for _, value in ipairs(animationList["keyframes"]) do
		table.insert(instance.keyframes, animation._internals.CreateKeyFrame(value))
	end

	instance.animationIndex = 1
	instance.interupted = false

	if instance.loop == animation.loopModes.pingPong then
		animation.utils.ConbineTables(instance.keyframes, animation._internals.GenerateReversedKeyframes(instance.keyframes, instance.startTransform))
	end

	instance.completionCallback = CompletionCallback
	instance.data = data

	animation._internals.ResetObjectPos(object, instance.startTransform)

	animation._internals.PlayAnimationFrame(tween._internals.CreateTweenCallbackData(object, instance))

	return instance
end


---@param keyframeData table
---@return Keyframe
function animation._internals.CreateKeyFrame(keyframeData)
	local instance = setmetatable({}, Keyframe)

	instance.type = keyframeData["type"]
	if instance.type != "wait" then
		instance.endValue = animation.utils.TableToVector(keyframeData["endValue"])
	end

	instance.duration = keyframeData["duration"]
	instance.easing = keyframeData["easing"] or easings.easing.Linear
	instance.easingType = keyframeData["easingType"] or easings.easingType.In

	instance.parallel = keyframeData["parallel"] or false

	return instance
end


---@param transformData table
---@return StartTransform
function animation._internals.CreateStartTransform(transformData)
	local instance = setmetatable({}, StartTransform)

	instance.position = animation.utils.TableToVector(transformData["position"])
	instance.rotation = animation.utils.TableToVector(transformData["rotation"])
	instance.scale = animation.utils.TableToVector(transformData["scale"])

	return instance
end


---@param keyframes Keyframe[]
---@param startTransform StartTransform
function animation._internals.GenerateReversedKeyframes(keyframes, startTransform)
	local reversedKeyframes = {}
	local parallelBuffer = {}

	for i = #keyframes, 1, -1 do
		---@type Keyframe
		local keyframe = keyframes[i]

		---@type Keyframe
		local newKeyframe = animation.utils.TableCopy(keyframe)
		local type = newKeyframe.type

		if type != "wait" then
			newKeyframe.endValue = animation._internals.GetEndValue(i, type, keyframes, startTransform)

			newKeyframe.easingType = easings.swap[newKeyframe.easingType]
		end

		if newKeyframe.parallel == true then
			table.insert(parallelBuffer, newKeyframe)
		else
			table.insert(reversedKeyframes, newKeyframe)
			animation.utils.ConbineTables(reversedKeyframes, parallelBuffer)
			parallelBuffer = {}
		end
	end

	return reversedKeyframes
end


---@param keyFrameIndex integer
---@param type string
---@param keyframes Keyframe[]
---@param startTransform StartTransform
---@return ModVector3
function animation._internals.GetEndValue(keyFrameIndex, type, keyframes, startTransform)
	for i = 1, 5, 1 do
		if keyFrameIndex - i < 1 then
			return startTransform[type]
		end

		if keyframes[keyFrameIndex - i].type == type then
			return keyframes[keyFrameIndex - i].endValue
		end
	end

	tm.os.Log("animation: No previous position could be found")
	return tm.vector3.Create()
end



---@param object ModGameObject
---@param transform StartTransform
function animation._internals.ResetObjectPos(object, transform)
	object.GetTransform().SetPositionWorld(transform.position)
	object.GetTransform().SetRotation(transform.rotation)
	object.GetTransform().SetScale(transform.scale)
end


---@param data TweenCallbackData
function animation._internals.PlayAnimationFrame(data)
	---@type AnimationPlayer
	local anim = data.data

	if anim.interupted then
		return
	end

	if anim.animationIndex > #anim.keyframes then
		animation._internals.OnAnimationComplete(anim)
		return
	end

	if anim.loop == animation.loopModes.pingPong and anim.animationIndex == #anim.keyframes * 0.5 + 1 then
		animation._internals.DoCompleteCallback(anim)
	end

	---@type Keyframe
	local keyframe = anim.keyframes[anim.animationIndex]
	local type = keyframe.type

	anim.animationIndex = anim.animationIndex + 1

	while anim.animationIndex <= #anim.keyframes do
		---@type Keyframe
		local newKeyframe = anim.keyframes[anim.animationIndex]

		if newKeyframe.parallel == true then
			animation._internals.PlayParallel(anim.object, newKeyframe, anim.timeScale)
		else
			break
		end

		anim.animationIndex = anim.animationIndex + 1
	end

	if type == "wait" then
		timer.Create(keyframe.duration * anim.timeScale, animation._internals.PlayAnimationFrame, anim)
		return
	end

	local tweenFunction = tween.TweenFunctions[type]
	local duration = keyframe.duration * anim.timeScale
	tweenFunction(anim.object, keyframe.endValue, duration, keyframe.easing, keyframe.easingType, animation._internals.PlayAnimationFrame, anim)
end


---@param object ModGameObject
---@param keyframe Keyframe
---@param timeScale number
function animation._internals.PlayParallel(object, keyframe, timeScale)
	local tweenFunction = tween.TweenFunctions[keyframe.type]
	local duration = keyframe.duration * timeScale
	tweenFunction(object, keyframe.endValue, duration, keyframe.easing, keyframe.easingType)
end


---@param anim AnimationPlayer
function animation._internals.OnAnimationComplete(anim)
	animation._internals.DoCompleteCallback(anim)

	if anim.loop == animation.loopModes.never then
		return
	end

	if anim.loop == animation.loopModes.loop then
		animation._internals.ResetObjectPos(anim.object, anim.startTransform)
	end

	anim.animationIndex = 1
	animation._internals.PlayAnimationFrame(tween._internals.CreateTweenCallbackData(anim.object, anim))
end


---@param anim AnimationPlayer
function animation._internals.DoCompleteCallback(anim)
	if anim.completionCallback then
		anim.completionCallback(animation._internals.CreateCallbackData(anim.object, anim.data))
	end
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
