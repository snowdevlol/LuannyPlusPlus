--!nonstrict
return function(Ctx, parent, order, options)
    local C, U = Ctx.C, Ctx.Utils
    local isTextarea = options.Type == "Textarea"

    local card = U.Card(Ctx, parent, order, isTextarea and 90 or 65)
    local lock = U.Lockable(Ctx, card)
    local iconOffset = options.InputIcon and 35 or 10

    if options.InputIcon then
        U.New("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1,
            Image = U.Icons[options.InputIcon] or "", ImageColor3 = C.Content,
        }, card)
    end

    local lblTitle = U.Label(Ctx, card, {
        Size = UDim2.new(1, -120, 0, 16), Position = UDim2.new(0, iconOffset, 0, 10), Text = options.Title or "Input",
    })
    local lblDesc = U.Label(Ctx, card, {
        Size = UDim2.new(1, -120, 0, 16), Position = UDim2.new(0, iconOffset, 0, 28),
        Text = options.Desc or "", TextSize = 11, TextColor3 = C.SubContent,
    })

    local boxBg = U.New("Frame", {
        Size = isTextarea and UDim2.new(1, -20, 0, 40) or UDim2.new(0, 110, 0, 30),
        AnchorPoint = isTextarea and Vector2.new(0, 0) or Vector2.new(1, 0.5),
        Position = isTextarea and UDim2.new(0, 10, 0, 45) or UDim2.new(1, -10, 0.5, 0),
        BackgroundColor3 = C.Field, BorderSizePixel = 0,
    }, card)
    U.Corner(boxBg, UDim.new(0, 6))
    U.Stroke(boxBg, C.CardStroke)

    local box = U.New("TextBox", {
        Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1,
        Text = options.Value or "", PlaceholderText = options.Placeholder or "",
        TextColor3 = C.Content, PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        FontFace = Ctx.Theme.Fonts.UI, TextSize = 12, TextWrapped = isTextarea,
        ClearTextOnFocus = not isTextarea,
        TextXAlignment = isTextarea and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
        TextYAlignment = isTextarea and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
    }, boxBg)
    U.RegisterText(box)

    box.FocusLost:Connect(function()
        if lock.IsLocked() then return end
        if options.Callback then task.spawn(options.Callback, box.Text) end
    end)

    return {
        SetTitle = function(t) lblTitle.Text = t end,
        SetDesc = function(d) lblDesc.Text = d end,
        SetPlaceholder = function(p) box.PlaceholderText = p end,
        SetValue = function(v) box.Text = v end,
        Get = function() return box.Text end,
        Lock = lock.Lock, Unlock = lock.Unlock,
        Destroy = function() card:Destroy() end,
    }
end
