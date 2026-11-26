local TweenService = game:GetService("TweenService")

return function(Ctx)
    local Theme, U = Ctx.Theme, Ctx.Utils

    function Ctx.ToggleWindow(target, h)
        local inner = target:FindFirstChildOfClass("CanvasGroup")

        if Ctx.CurrentWindow == target then
            TweenService:Create(Ctx.Overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
            if inner then
                local tw = TweenService:Create(inner, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    GroupTransparency = 1,
                    Size = UDim2.new(0, 380, 0, h - 15),
                })
                tw:Play()
                tw.Completed:Connect(function() target.Visible = false end)
            else
                target.Visible = false
            end
            Ctx.CurrentWindow = nil
        else
            if Ctx.CurrentWindow then
                local old = Ctx.CurrentWindow:FindFirstChildOfClass("CanvasGroup")
                if old then old.GroupTransparency = 1 end
                Ctx.CurrentWindow.Visible = false
            end
            target.Size = UDim2.new(0, 380, 0, h)
            target.Visible = true
            Ctx.CurrentWindow = target
            TweenService:Create(Ctx.Overlay, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                BackgroundTransparency = Ctx.Config.Transparent and 0.4 or 0.6,
            }):Play()
            if inner then
                inner.Size = UDim2.new(0, 380, 0, h - 15)
                inner.GroupTransparency = 1
                TweenService:Create(inner, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    GroupTransparency = 0,
                    Size = UDim2.new(0, 380, 0, h),
                }):Play()
            end
        end
    end

    -- retorna (mask, container)
    function Ctx.CreateTabWindow(title, h)
        local C = Ctx.C

        local mask = U.New("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -72),
            Size = UDim2.new(0, 380, 0, h),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 10,
        }, Ctx.ScreenGui)
        mask:SetAttribute("Height", h)

        local frame = U.New("CanvasGroup", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, 0),
            Size = UDim2.new(0, 380, 0, h),
            BackgroundColor3 = C.Window,
            BackgroundTransparency = Ctx.Config.Transparent and 0.15 or 0,
            BorderSizePixel = 0,
            ZIndex = 10,
        }, mask)
        U.Corner(frame, Theme.Corner.Window)
        U.Stroke(frame, C.Stroke, C.StrokeAlpha)

        U.Label(Ctx, frame, {
            Size = UDim2.new(1, 0, 0, 45),
            Text = title,
            TextSize = 22,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 11,
        })

        local container = U.New("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, -50),
            Position = UDim2.new(0, 0, 0, 45),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            ZIndex = 11,
        }, frame)
        local layout = U.New("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
        }, container)
        U.New("UIPadding", {PaddingTop = UDim.new(0, 5)}, container)
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)

        return mask, container
    end
end
