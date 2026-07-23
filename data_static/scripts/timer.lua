---@meta
---API for timers, made by Stino

_G.timer = {}

---@class Timer
---@field duration number
---@field timeLeft number
---@field completeCallback fun(data: TimerCallbackData)
---@field data any?
---@field deleteOnComplete boolean
---@field loop boolean
---@field active boolean
---@field progressCallback fun(data: TimerCallbackData)?
local Timer = {}
Timer.__index = Timer

---Callback data for when a timer times out or updates
---@class TimerCallbackData
---@field timer Timer Gives you reference to the timer
---@field timeLeft number Gives you the time left before the timer times out
---@field data any? Gives you the data in the timer
local TimerCallbackData = {}
TimerCallbackData.__index = TimerCallbackData

---@type Timer[]
local timers = {}

---Creates a Timer with the given duration, It will call the `completeCallback` when the Timer times out
---@param duration number Duration of the Timer
---@param completeCallback fun(data: TimerCallbackData) Function to execute when the Timer times out
---@param data any? Arbitrary data passed to the callback functions
---@param deleteOnComplete boolean? [Default = true] If true the internal reference for the timer will be deleted when the Timer times out, will be ignored when `loop` is true
---@param loop boolean? [Default = false] If true the timer will restart when the Timer times out
---@param autoStart boolean? [Default = true] If true the timer will immediately start when its created
---@param progressCallback fun(data: TimerCallbackData)? Function to execute when the Timer progresses
---@return Timer Timer Reference to the timer 
function timer.Create(duration, completeCallback, data, deleteOnComplete, loop, autoStart, progressCallback)
    local instance = setmetatable({}, Timer)

    instance.duration = duration
    instance.timeLeft = duration
    instance.completeCallback = completeCallback
    instance.deleteOnComplete = deleteOnComplete or true
    instance.data = data
    instance.loop = loop or false
    instance.active = autoStart or true
    instance.progressCallback = progressCallback

    table.insert(timers, instance)

    return instance
end


---@param timer Timer
---@return TimerCallbackData
function CreateCallbackData(timer)
    local instance = setmetatable({}, TimerCallbackData)

    instance.timer = timer
    instance.timeLeft = math.max(timer.timeLeft, 0)
    instance.data = timer.data

    return instance
end


---Starts the timer from its current timeLeft
function Timer:Start()
    self.active = true
end


---Stops the timer
function Timer:Stop()
    self.active = false
end


---Restarts the timer
---@param duration number? Duration of the Timer, if not set Timer will restart with its current duration
function Timer:Restart(duration)
    self.timeLeft = duration or self.duration
    self.duration = duration or self.duration
    self.active = true
end


---deletes the internal reference to the timer
function Timer:delete()
    for index, value in ipairs(timers) do
        if value == self then
            table.remove(timers, index)
        end
    end
end


function timer.UpdateTimers()
    for index, value in ipairs(timers) do
        _UpdateTimer(value, index)
    end
end


---@param timer Timer
---@param index integer
function _UpdateTimer(timer, index)
    if not timer.active then
        return
    end

    timer.timeLeft = timer.timeLeft - tm.os.GetModDeltaTime()

    if timer.progressCallback then
        timer.progressCallback(CreateCallbackData(timer))
    end

    if timer.timeLeft > 0 then
        return
    end

    timer.completeCallback(CreateCallbackData(timer))

    if timer.loop then
        timer.timeLeft = timer.duration + timer.timeLeft
        return
    end

    if timer.deleteOnComplete then
        table.remove(timers, index)
        return
    end

    timer.active = false
    timer.timeLeft = timer.duration
end