--!nonstrict
return function(Ctx, parent, order, options)
    local C, U = Ctx.C, Ctx.Utils
    local btns = options.Buttons or {}
    local hasButtons = #btns > 0
    local locked = options.Locked

    local card, stroke = U.Card(Ctx, parent, order, hasButtons and 95 or 65)
    if locked then card.BackgroundTransparency = 0.6 end

    if typeof(options.Color) == "string" then
        if options.Color == "Red" then stroke.Color = Color3.fromRGB(255, 50, 50) end
    elseif typeof(options.Color) == "Color3" then
        stroke.Color = options.Color
    end

    local lblTitle = U.Label(Ctx, card, {
        Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 10, 0, 10),
        Text = options.Title or "Paragraph", TextTransparency = locked and 0.5 or 0,
    })
    local lblDesc = U.Label(Ctx, card, {
        Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0, 10, 0, 28),
        Text = options.Desc or "", TextSize = 11, TextColor3 = C.SubContent, TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top, TextTransparency = locked and 0.5 or 0,
    })

    if hasButtons then
        local box = U.New("Frame", {
            Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0, 10, 0, 60), BackgroundTransparency = 1,
        }, card)
        U.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
        }, box)

        for _, data in ipairs(btns) do
            local b = U.New("TextButton", {
                Size = UDim2.new(1 / #btns, -6 + (6 / #btns), 1, 0), BackgroundColor3 = C.Button, BorderSizePixel = 0,
                Text = data.Title or "Button", TextColor3 = C.Content, FontFace = Ctx.Theme.Fonts.UI, TextSize = 12,
            }, box)
            U.Corner(b, UDim.new(0, 6))
            U.RegisterText(b)
            if locked then
                b.BackgroundTransparency = 0.5; b.TextTransparency = 0.5; b.AutoButtonColor = false
            else
                b.MouseButton1Click:Connect(function()
                    if data.Callback then task.spawn(data.Callback) end
                end)
            end
        end
    end

    return {
        SetTitle = function(t) lblTitle.Text = t end,
        SetDesc = function(d) lblDesc.Text = d end,
        Destroy = function() card:Destroy() end,
    }
end
