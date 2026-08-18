tm.os.DoFile("scripts/libraries/debug")

tm.os.DoFile("scripts/libraries/timer")
tm.os.DoFile("scripts/libraries/animation")
tm.os.DoFile("scripts/libraries/easings")
tm.os.DoFile("scripts/libraries/tween")

tm.os.SetModTargetDeltaTime(1/60)

tm.playerUI.AddUILabel(0, 1, "<align=left>Examaples are stored in")
tm.playerUI.AddUILabel(0, 1, "<align=left>  data_static/scripts/examples/")
tm.playerUI.AddUILabel(0, 1, "<align=left>Libraries are stored in")
tm.playerUI.AddUILabel(0, 1, "<align=left>  data_static/scripts/libraries/")
tm.playerUI.AddUILabel(0, 1, "Examples:")

tm.os.DoFile("scripts/examples/exampleAnimation")
tm.os.DoFile("scripts/examples/exampleTween")
tm.os.DoFile("scripts/examples/exampleTimer")

function update()
	timer.UpdateTimers()
	tween.UpdateTweeners()
end

local testTable = {
	tm.vector3.Create(1, 2, 3),
	tm.vector3.Create(),
}

Print(testTable)
