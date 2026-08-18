---requires:
--- - tween.lua

---(they are added in main.lua)

---@type ModGameObject
local obj

---@param player ModPlayer
function OnPlayerJoined(player)
	if player.playerId != 0 then
		return
	end

	tm.playerUI.AddUILabel(0, "t header", "-- Tween --")
	tm.playerUI.AddUIButton(0, "t play", "play", PlayTween)

	obj = tm.physics.SpawnObject(tm.vector3.Create(15, 300, 0), "PFB_Container_Red_Dynamic")
	obj.SetIsStatic(true)
end


function PlayTween()
	tween.CreateScaleTween(obj, tm.vector3.Create(3, 3, 3), 4, easings.easing.Quad, easings.easingType.InOut, OnTweenComplete)
end


---@param data TweenCallbackData
function OnTweenComplete(data)
	data.object.GetTransform().SetScale(1)
	tm.playerUI.AddSubtleMessageForAllPlayers("Tween Complete", "", 3)
end

tm.players.OnPlayerJoined.add(OnPlayerJoined)
