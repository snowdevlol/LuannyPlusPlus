--!nonstrict
local TweenService = game:GetService("TweenService")

return function(Ctx, parent, order, options)
    local C, U = Ctx.C, Ctx.Utils
    local state = options.Value or false
    local isCheckbox = options.Type == "Checkbox"

    local card = U.Card(Ctx, parent, order, 60, "TextButton")
    local lock = U.Lockable(Ctx, card)
    local textOffset = options.Icon and 35 or 10

    if options.Icon then
        U.New("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1,
            Image = U.Icons[options.Icon] or "", ImageColor3 = C.Content, ZIndex = 13,
        }, card)
    end

    local lblTitle = U.Label(Ctx, card, {
        Size = UDim2.new(1, -(textOffset + 50), 0, 16), Position = UDim2.new(0, textOffset, 0, 10),
        Text = options.Title or "Toggle", ZIndex = 13,
    })
    local lblDesc = U.Label(Ctx, card, {
        Size = UDim2.new(1, -60, 0, 28), Position = UDim2.new(0, 10, 0, 28),
        Text = options.Desc or "", TextSize = 11, TextColor3 = C.SubContent,
        TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 13,
    })

    local switchBg = U.New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
        BackgroundColor3 = state and C.On or C.Off, BorderSizePixel = 0, ZIndex = 14,
        Size = isCheckbox and UDim2.new(0, 22, 0, 22) or UDim2.new(0, 32, 0, 18),
    }, card)

    local checkMark, circle
    if isCheckbox then
        U.Corner(switchBg, UDim.new(0, 6))
        checkMark = U.New("ImageLabel", {
            Size = UDim2.new(0, 16, 0, 16), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1, Image = U.Icons["check"] or "", ImageColor3 = Color3.new(1, 1, 1),
            ImageTransparency = state and 0 or 1, ZIndex = 15,
        }, switchBg)
    else
        U.Corner(switchBg, UDim.new(1, 0))
        circle = U.New("Frame", {
            Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(0, 0.5),
            Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 15,
        }, switchBg)
        U.Corner(circle, UDim.new(1, 0))
    end

    local function refresh()
        TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = state and C.On or C.Off}):Play()
        if isCheckbox then
            TweenService:Create(checkMark, TweenInfo.new(0.2), {ImageTransparency = state and 0 or 1}):Play()
        else
            TweenService:Create(circle, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            }):Play()
        end
    end

    card.MouseButton1Click:Connect(function()
        if lock.IsLocked() then return end
        state = not state
        refresh()
        if options.Callback then task.spawn(options.Callback, state) end
    end)

    return {
        SetTitle = function(t) lblTitle.Text = t end,
        SetDesc = function(d) lblDesc.Text = d end,
        SetValue = function(v) state = v; refresh() end,
        Get = function() return state end,
        Lock = lock.Lock, Unlock = lock.Unlock,
        Destroy = function() card:Destroy() end,
    }
end
