tm.os.DoFile("scripts/debug")

tm.os.DoFile("scripts/shell") --Neut's Shell Mod v 0.2
shell.init()

tm.os.DoFile("scripts/timer")
tm.os.DoFile("scripts/animation")
tm.os.DoFile("scripts/easings")
tm.os.DoFile("scripts/tween")

tm.os.SetModTargetDeltaTime(1/60)

---@type ModGameObject
local obj

---@type animationPlayer?
local a

---@param player ModPlayer
function OnPlayerJoined(player)
    if player.playerId != 0 then
        return
    end

    tm.playerUI.AddUIButton(0, "play", "Play", Play)
    tm.playerUI.AddUIButton(0, "stop", "Stop", Stop)

    obj = tm.physics.SpawnObject(tm.vector3.Create(0, 300, 0), "PFB_Container_Blue_Dynamic")
    obj.SetIsStatic(true)
end


function update()
    shell.flush()
    timer.UpdateTimers()
    tween.UpdateTweeners()
end


function Play(param)
    a = animation.PlayAnimation(obj, json.parse(tm.os.ReadAllText_Static("animations/monorail animation.json")), tonumber(param), OnAnimationComplete, "complete")
end
shell.addCommand(Play, "play")


function OnAnimationComplete(data)
    Print(data.data)
end


function Stop()
    if a then
        a:interupt()
    end
end
shell.addCommand(Stop, "stop")

tm.players.OnPlayerJoined.add(OnPlayerJoined)