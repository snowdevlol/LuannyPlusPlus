--!nonstrict
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

return function(Ctx, parent, order, options)
    local C, U = Ctx.C, Ctx.Utils

    local range = options.Value or {}
    local step = options.Step or 1
    local minVal = range.Min or 0
    local maxVal = range.Max or 100
    local defaultVal = range.Default or minVal
    local currentVal = defaultVal

    local card = U.Card(Ctx, parent, order, 65)
    local lock = U.Lockable(Ctx, card)
    local jan = Ctx.Janitor.new()

    local lblTitle = U.Label(Ctx, card, {
        Size = UDim2.new(1, -100, 0, 16), Position = UDim2.new(0, 12, 0, 10), Text = options.Title or "Slider",
    })
    local lblDesc = U.Label(Ctx, card, {
        Size = UDim2.new(1, -100, 0, 16), Position = UDim2.new(0, 12, 0, 26),
        Text = options.Desc or "", TextSize = 11, TextColor3 = C.SubContent,
    })

    local valBox = U.New("TextBox", {
        Size = UDim2.new(0, 45, 0, 22), Position = UDim2.new(1, -57, 0, 12), BackgroundColor3 = C.Field,
        TextColor3 = C.Content, Text = tostring(defaultVal), FontFace = Ctx.Theme.Fonts.UI, TextSize = 12,
        BorderSizePixel = 0, ClearTextOnFocus = false,
    }, card)
    U.Corner(valBox, UDim.new(0, 4))
    U.RegisterText(valBox)

    local track = U.New("TextButton", {
        Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 48), BackgroundColor3 = C.Track,
        Text = "", AutoButtonColor = false, BorderSizePixel = 0,
    }, card)
    U.Corner(track, UDim.new(1, 0))

    local fill = U.New("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = C.Accent, BorderSizePixel = 0,
    }, track)
    U.Corner(fill, UDim.new(1, 0))

    local knob = U.New("Frame", {
        Size = UDim2.new(0, 12, 0, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
    }, fill)
    U.Corner(knob, UDim.new(1, 0))

    local sliding = false

    local function update(raw, animate)
        local clamped = math.clamp(raw, minVal, maxVal)
        local rounded = math.round((clamped - minVal) / step) * step + minVal
        currentVal = math.clamp(rounded, minVal, maxVal)
        valBox.Text = tostring(currentVal)

        local pct = (currentVal - minVal) / (maxVal - minVal)
        if animate then
            TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
        else
            fill.Size = UDim2.new(pct, 0, 1, 0)
        end
        if options.Callback then task.spawn(options.Callback, currentVal) end
    end

    local function isPress(input: InputObject): boolean
        return input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
    end

    local function fromPosition(x: number)
        if lock.IsLocked() then return end
        local pct = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        update(minVal + pct * (maxVal - minVal), false)
    end

    track.InputBegan:Connect(function(input)
        if lock.IsLocked() or not isPress(input) then return end
        sliding = true
        fromPosition(input.Position.X)
    end)
    jan:Add(UserInputService.InputChanged:Connect(function(input)
        local moving = input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        if sliding and moving then fromPosition(input.Position.X) end
    end))
    jan:Add(UserInputService.InputEnded:Connect(function(input)
        if isPress(input) then sliding = false end
    end))
    valBox.FocusLost:Connect(function()
        local n = tonumber(valBox.Text)
        if n then update(n, true) else valBox.Text = tostring(currentVal) end
    end)

    update(defaultVal, false)

    return {
        SetTitle = function(t) lblTitle.Text = t end,
        SetDesc = function(d) lblDesc.Text = d end,
        SetMin = function(m) minVal = m; update(currentVal, true) end,
        SetMax = function(m) maxVal = m; update(currentVal, true) end,
        SetValue = function(v) update(v, true) end,
        Get = function() return currentVal end,
        Lock = lock.Lock, Unlock = lock.Unlock,
        Destroy = function() jan:Destroy(); card:Destroy() end,
    }
end
