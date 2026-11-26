--!nonstrict
local TweenService = game:GetService("TweenService")

return function(Ctx, parent, order, options)
    local C, U = Ctx.C, Ctx.Utils
    local list = options.Options or {}
    local current = options.Value or list[1] or "..."
    local isOpen = false

    local card = U.Card(Ctx, parent, order, 60)
    card.ClipsDescendants = true
    local lock = U.Lockable(Ctx, card)
    local textOffset = options.Icon and 35 or 10

    if options.Icon then
        U.New("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1,
            Image = U.Icons[options.Icon] or "", ImageColor3 = C.Content, ZIndex = 13,
        }, card)
    end

    local lblTitle = U.Label(Ctx, card, {
        Size = UDim2.new(1, -(textOffset + 120), 0, 16), Position = UDim2.new(0, textOffset, 0, 10),
        Text = options.Title or "Dropdown", ZIndex = 13,
    })
    U.Label(Ctx, card, {
        Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0, 10, 0, 28),
        Text = options.Desc or "", TextSize = 11, TextColor3 = C.SubContent,
        TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 13,
    })

    local selectBtn = U.New("TextButton", {
        Size = UDim2.new(0, 110, 0, 24), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 6),
        BackgroundColor3 = C.Button, BorderSizePixel = 0, Text = "  " .. current, TextColor3 = C.Content,
        FontFace = Ctx.Theme.Fonts.UI, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    }, card)
    U.Corner(selectBtn, UDim.new(0, 6))
    U.RegisterText(selectBtn)

    local arrow = U.New("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -5, 0.5, 0),
        BackgroundTransparency = 1, Image = U.Icons["chevron-down"] or "", ImageColor3 = C.Content, ZIndex = 15,
    }, selectBtn)

    local listFrame = U.New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 60), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 2, ZIndex = 14,
    }, card)
    U.New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}, listFrame)

    local function setOpen(open)
        isOpen = open
        local h = open and math.min(60 + (#list * 29), 160) or 60
        listFrame.Size = UDim2.new(1, -20, 0, math.max(h - 65, 0))
        listFrame.CanvasSize = UDim2.new(0, 0, 0, #list * 29)
        TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = open and 180 or 0}):Play()
        TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 340, 0, h),
        }):Play()
    end

    for _, name in ipairs(list) do
        local opt = U.New("TextButton", {
            Size = UDim2.new(1, -8, 0, 25), BackgroundColor3 = C.Option, BorderSizePixel = 0,
            Text = "  " .. name, TextColor3 = C.Content, FontFace = Ctx.Theme.Fonts.UI, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15,
        }, listFrame)
        U.Corner(opt, UDim.new(0, 4))
        U.RegisterText(opt)
        opt.MouseButton1Click:Connect(function()
            if lock.IsLocked() then return end
            current = name
            selectBtn.Text = "  " .. current
            setOpen(false)
            if options.Callback then task.spawn(options.Callback, current) end
        end)
    end

    selectBtn.MouseButton1Click:Connect(function()
        if lock.IsLocked() then return end
        setOpen(not isOpen)
    end)

    return {
        SetTitle = function(t) lblTitle.Text = t end,
        Set = function(v) current = v; selectBtn.Text = "  " .. v end,
        Get = function() return current end,
        Lock = lock.Lock, Unlock = lock.Unlock,
        Destroy = function() card:Destroy() end,
    }
end
