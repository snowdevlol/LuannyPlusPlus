local TweenService = game:GetService("TweenService")

return function(Ctx, parent, order, options)
    local C, U = Ctx.C, Ctx.Utils

    local card, stroke = U.Card(Ctx, parent, order, 55, "TextButton")
    local lock = U.Lockable(Ctx, card)

    local lblTitle = U.Label(Ctx, card, {
        Size = UDim2.new(1, -40, 0, 18), Position = UDim2.new(0, 10, 0, 8),
        Text = options.Title or "Button", ZIndex = 13,
    })
    local lblDesc = U.Label(Ctx, card, {
        Size = UDim2.new(1, -40, 0, 16), Position = UDim2.new(0, 10, 0, 28),
        Text = options.Desc or "", TextSize = 11, TextColor3 = C.SubContent, ZIndex = 13,
    })
    U.New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
        BackgroundTransparency = 1, Image = U.Icons[options.Icon or "mouse-pointer-click"] or "",
        ImageColor3 = C.Content, ZIndex = 13,
    }, card)

    card.MouseEnter:Connect(function()
        if not lock.IsLocked() then
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = C.CardStrokeHover}):Play()
        end
    end)
    card.MouseLeave:Connect(function()
        if not lock.IsLocked() then
            TweenService:Create(stroke, TweenInfo.new(0.2), {Color = C.CardStroke}):Play()
        end
    end)
    card.MouseButton1Click:Connect(function()
        if lock.IsLocked() then return end
        local tw = TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = C.CardHover})
        tw:Play()
        tw.Completed:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.1), {BackgroundColor3 = C.Card}):Play()
        end)
        if options.Callback then task.spawn(options.Callback) end
    end)

    return {
        SetTitle = function(t) lblTitle.Text = t end,
        SetDesc = function(d) lblDesc.Text = d end,
        Lock = lock.Lock, Unlock = lock.Unlock,
        Destroy = function() card:Destroy() end,
    }
end
