---requires:
--- - timer.lua

---(they are added in main.lua)

---@type ModGameObject
local obj

---@param player ModPlayer
function OnPlayerJoined(player)
	if player.playerId != 0 then
		return
	end

	tm.playerUI.AddUILabel(0, "t header", "-- Timer --")
	tm.playerUI.AddUIButton(0, "start", "start", Start)
end


function Start()
	timer.Create(1, OnTimerComplete, 5, true, false, true)
end


---@param data TimerCallbackData
function OnTimerComplete(data)
	if data.data > 0 then
		tm.playerUI.ShowIntrusiveMessageForAllPlayers(tostring(data.data), "", 1)
		timer.Create(0.9, OnTimerComplete, data.data - 1, true, false, true)
	end
end

tm.players.OnPlayerJoined.add(OnPlayerJoined)
