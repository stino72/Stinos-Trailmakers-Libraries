---requires:
--- - animation.lua
--- - easings.lua
--- - tween.lua
--- - timer.lua

---(they are added in main.lua)

---@type ModGameObject
local obj

---@type AnimationPlayer?
local anim

---@param player ModPlayer
function OnPlayerJoined(player)
	if player.playerId != 0 then
		return
	end

	tm.playerUI.AddUILabel(0, "a header", "-- Animation --")
	tm.playerUI.AddUIButton(0, "play", "Play", Play)
	tm.playerUI.AddUIButton(0, "stop", "Stop", Stop)

	obj = tm.physics.SpawnObject(tm.vector3.Create(0, 350, 0), "PFB_Container_Blue_Dynamic")
	obj.SetIsStatic(true)
end


function Play()
	anim = animation.PlayAnimation(obj, json.parse(tm.os.ReadAllText_Static("animations/exampleAnimation.json")), 0.5, OnAnimationComplete, "complete")
end


function OnAnimationComplete(data)
	tm.playerUI.AddSubtleMessageForAllPlayers("Animation Complete", "", 3)
end


function Stop()
	if anim then
		anim:interupt()
	end
end

tm.players.OnPlayerJoined.add(OnPlayerJoined)
