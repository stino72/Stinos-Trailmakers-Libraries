_G.easings = {}

local c1 = 1.70158
local c2 = c1 * 1.525
local c3 = c1 + 1
local c4 = (2 * math.pi) / 3;
local c5 = (2 * math.pi) / 4.5

local n1 = 7.5625
local d1 = 2.75

---easings [https://easings.net/]
---@enum easing
easings.easing = {
    Linear = "Linear",
    Sine = "Sine",
    Quad = "Quad",
    Cubic = "Cubic",
    Quart = "Quart",
    Quint = "Quint",
    Expo = "Expo",
    Circ = "Circ",
    Back = "Back",
    Elastic = "Elastic",
    Bounce = "Bounce",
}

---@enum easingType
easings.easingType = {
    In = "In",
    Out = "Out",
    InOut = "InOut",
}

easings.swap = {
    [easings.easingType.In] = easings.easingType.Out,
    [easings.easingType.Out] = easings.easingType.In,
    [easings.easingType.InOut] = easings.easingType.InOut,
}

---@param x number
function easings.EaseLinear(x)
    return x
end


---@param x number
function easings.EaseInSine(x)
    return 1 - math.cos((x * math.pi) / 2)
end


---@param x number
function easings.EaseOutSine(x)
    return math.sin((x * math.pi) / 2)
end


---@param x number
function easings.EaseInOutSine(x)
    return -(math.cos(math.pi * x) - 1) / 2
end

---@param x number
function easings.EaseInQuad(x)
    return x * x
end


---@param x number
function easings.EaseOutQuad(x)
    return 1 - (1 - x) * (1 - x)
end


---@param x number
function easings.EaseInOutQuad(x)
    if x < 0.5 then
        return 2 * x * x 
    else
        return 1 - math.pow(-2 * x + 2, 2) / 2
    end
end

---@param x number
function easings.EaseInCubic(x)
    return x * x * x
end


---@param x number
function easings.EaseOutCubic(x)
    return 1 - math.pow(1 - x, 3)
end


---@param x number
function easings.EaseInOutCubic(x)
    if x < 0.5 then
        return 4 * x * x * x
    else
        return 1 - math.pow(-2 * x + 2, 3) / 2
    end
end

---@param x number
function easings.EaseInQuart(x)
    return x * x * x * x
end


---@param x number
function easings.EaseOutQuart(x)
    return 1 - math.pow(1 - x, 4)
end


---@param x number
function easings.EaseInOutQuart(x)
    if x < 0.5 then
        return 8 * x * x * x * x
    else
        return 1 - math.pow(-2 * x + 2, 4) / 2
    end
end

---@param x number
function easings.EaseInQuint(x)
    return x * x * x * x * x
end


---@param x number
function easings.EaseOutQuint(x)
    return 1 - math.pow(1 - x, 5)
end


---@param x number
function easings.EaseInOutQuint(x)
    if x < 0.5 then
        return 16 * x * x * x * x * x
    else
        return 1 - math.pow(-2 * x + 2, 5) / 2
    end
end


---@param x number
function easings.EaseInExpo(x)
    if x == 0 then
        return 0
    else
        return math.pow(2, 10 * x - 10)
    end
end


---@param x number
function easings.EaseOutExpo(x)
    if x == 1 then
        return 1
    else
        return math.pow(2, -10 * x)
    end
end


---@param x number
function easings.EaseInOutExpo(x)
    if x == 0 then
        return 0
    elseif x == 1 then
        return 1
    elseif x < 0.5 then
        return math.pow(2, 20 * x - 10) / 2
    else
        return (2 - math.pow(2, -20 * x + 10)) / 2
    end
end


---@param x number
function easings.EaseInCirc(x)
    return 1 - math.sqrt(1 - math.pow(x, 2))
end


---@param x number
function easings.EaseOutCirc(x)
    return math.sqrt(1 - math.pow(x - 1, 2))
end


---@param x number
function easings.EaseInOutCirc(x)
    if x < 0.5 then
        return (1 - math.sqrt(1 - math.pow(2 * x, 2))) / 2
    else
        return (math.sqrt(1 - math.pow(-2 * x + 2, 2)) + 1) / 2
    end
end


---@param x number
function easings.EaseInBack(x)
    return c3 * x * x * x - c1 * x * x
end


---@param x number
function easings.EaseOutBack(x)
    return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2)
end


---@param x number
function easings.EaseInOutBack(x)
    if x < 0.5 then
        return (math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
    else
        return (math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
    end
end


---@param x number
function easings.EaseInElastic(x)
    if x == 0 then
        return 0
    elseif x == 1 then
        return 1
    else
        return -math.pow(2, 10 * x - 10) * math.sin((x * 10 - 10.75) * c4)
    end
end


---@param x number
function easings.EaseOutElastic(x)
    if x == 0 then
        return 0
    elseif x == 1 then
        return 1
    else
        return math.pow(2, -10 * x) * math.sin((x * 10 - 0.75) * c4) + 1
    end
end


---@param x number
function easings.EaseInOutElastic(x)
    if x == 0 then
        return 0
    elseif x == 1 then
        return 1
    elseif x < 0.5 then
        return -(math.pow(2, 20 * x - 10) * math.sin((20 * x - 11.125) * c5)) / 2
    else
        return (math.pow(2, -20 * x + 10) * math.sin((20 * x - 11.125) * c5)) / 2 + 1
    end
end


---@param x number
function easings.EaseInBounce(x)
    return 1 - easings.EaseOutBounce(1 - x)
end


---@param x number
function easings.EaseOutBounce(x)
    if x < 1 / d1 then
        return n1 * x * x
    elseif x < 2 / d1 then
        x = x - 1.5 / d1
        return n1 * x * x + 0.75
    elseif x < 2.5 / d1 then
        x = x - 2.25 / d1
        return n1 * x * x + 0.9375
    else
        x = x - 2.625 / d1
        return n1 * x * x + 0.984375
    end
end


---@param x number
function easings.EaseInOutBounce(x)
    if x < 0.5 then
        return (1 - easings.EaseOutBounce(1 - 2 * x)) / 2
    else
        return (1 + easings.EaseOutBounce(2 * x - 1)) / 2
    end
end


local easingFunctions = {
    Linear = {
        In = easings.EaseLinear,
        Out = easings.EaseLinear,
        InOut = easings.EaseLinear,
    },
    Sine = {
        In = easings.EaseInSine,
        Out = easings.EaseOutSine,
        InOut = easings.EaseInOutSine,
    },
    Quad = {
        In = easings.EaseInQuad,
        Out = easings.EaseOutQuad,
        InOut = easings.EaseInOutQuad,
    },
    Cubic = {
        In = easings.EaseInCubic,
        Out = easings.EaseOutCubic,
        InOut = easings.EaseInOutCubic,
    },
    Quart = {
        In = easings.EaseInQuart,
        Out = easings.EaseOutQuart,
        InOut = easings.EaseInOutQuart,
    },
    Quint = {
        In = easings.EaseInQuint,
        Out = easings.EaseOutQuint,
        InOut = easings.EaseInOutQuint,
    },
    Expo = {
        In = easings.EaseInExpo,
        Out = easings.EaseOutExpo,
        InOut = easings.EaseInOutExpo,
    },
    Circ = {
        In = easings.EaseInCirc,
        Out = easings.EaseOutCirc,
        InOut = easings.EaseInOutCirc,
    },
    Back = {
        In = easings.EaseInBack,
        Out = easings.EaseOutBack,
        InOut = easings.EaseInOutBack,
    },
    Elastic = {
        In = easings.EaseInElastic,
        Out = easings.EaseOutElastic,
        InOut = easings.EaseInOutElastic,
    },
    Bounce = {
        In = easings.EaseInBounce,
        Out = easings.EaseOutBounce,
        InOut = easings.EaseInOutBounce,
    },
}

---@param easing easing
---@param easingType easingType
---@return function
function easings.GetEasingFunction(easing, easingType)
    return easingFunctions[easing][easingType]
end