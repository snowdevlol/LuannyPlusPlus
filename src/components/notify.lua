-- random notif lol
local TweenService = game:GetService("TweenService")

return function(Ctx)
    local Theme, U = Ctx.Theme, Ctx.Utils
    local N = Theme.Notify
    local Icons, New = U.Icons, U.New

    if U.Root:FindFirstChild("LuannyNotifyScreen") then U.Root.LuannyNotifyScreen:Destroy() end

    local screen = New("ScreenGui", {
        Name = "LuannyNotifyScreen",
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, U.Root)

    local holder = New("Frame", {
        Size = UDim2.new(0, 320, 1, -40),
        Position = UDim2.new(1, -20, 0, 20),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
    }, screen)
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 10),
    }, holder)

    local function label(parent, props)
        props.BackgroundTransparency = 1
        props.TextXAlignment = Enum.TextXAlignment.Left
        local l = New("TextLabel", props, parent)
        l.FontFace = props.Bold and Theme.Fonts.Title or Theme.Fonts.UI
        U.RegisterText(l)
        return l
    end

    return function(options)
        local duration = options.Duration or 5
        local color = options.Color or Color3.fromRGB(0, 150, 255)
        local buttons = options.Buttons or {}
        local hasButtons = #buttons > 0
        local iconName = options.Icon

        local wrapper = New("Frame", {
            Size = UDim2.new(0, 300, 0, hasButtons and 100 or 65),
            BackgroundTransparency = 1,
        }, holder)

        local card = New("CanvasGroup", {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 50, 0, 0),
            BackgroundColor3 = N.Card,
            GroupTransparency = 1,
        }, wrapper)
        U.Corner(card, UDim.new(0, 8))
        U.Stroke(card, N.Stroke)

        local rightOffset = 12
        if iconName and Icons[iconName] and Icons[iconName] ~= "" then
            rightOffset = 38
            New("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 12),
                BackgroundTransparency = 1,
                Image = Icons[iconName],
                ImageColor3 = color,
            }, card)
        end

        label(card, {
            Size = UDim2.new(1, -(rightOffset + 12), 0, 18), Position = UDim2.new(0, 12, 0, 12),
            Text = options.Title or "Notification", TextColor3 = N.Title, TextSize = 13, Bold = true,
        })
        label(card, {
            Size = UDim2.new(1, hasButtons and -24 or -(rightOffset + 12), 0, hasButtons and 20 or 30),
            Position = UDim2.new(0, 12, 0, 30),
            Text = options.Desc or "", TextColor3 = N.Desc, TextSize = 12,
            TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
        })

        local progressBg = New("Frame", {
            Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = N.Track, BorderSizePixel = 0,
        }, card)
        local bar = New("Frame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = color, BorderSizePixel = 0,
        }, progressBg)

        local closed = false
        local function close()
            if closed then return end
            closed = true
            local tw = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                GroupTransparency = 1, Position = UDim2.new(0, 50, 0, 0),
            })
            tw:Play()
            tw.Completed:Connect(function() wrapper:Destroy() end)
        end

        if hasButtons then
            local box = New("Frame", {
                Size = UDim2.new(1, -24, 0, 28), Position = UDim2.new(0, 12, 0, 58), BackgroundTransparency = 1,
            }, card)
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
            }, box)

            for _, data in ipairs(buttons) do
                local btn = New("TextButton", {
                    Size = UDim2.new(1 / #buttons, -((6 * (#buttons - 1)) / #buttons), 1, 0),
                    BackgroundColor3 = N.Button,
                    Text = data.Title or "Button",
                    TextColor3 = N.ButtonText,
                    TextSize = 12,
                    AutoButtonColor = false,
                }, box)
                btn.FontFace = Theme.Fonts.UI
                U.RegisterText(btn)
                U.Corner(btn, UDim.new(0, 5))
                U.Stroke(btn, N.ButtonStroke)

                btn.MouseEnter:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = N.ButtonHover}):Play()
                end)
                btn.MouseLeave:Connect(function()
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = N.Button}):Play()
                end)
                btn.MouseButton1Click:Connect(function()
                    if data.Callback then task.spawn(data.Callback) end
                    close()
                end)
            end
        end

        TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0),
        }):Play()
        TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0),
        }):Play()
        task.delay(duration, close)
    end
end
