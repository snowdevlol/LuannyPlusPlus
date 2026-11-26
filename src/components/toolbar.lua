local TweenService = game:GetService("TweenService")

return function(Ctx)
    local Theme, U, C, Cfg = Ctx.Theme, Ctx.Utils, Ctx.C, Ctx.Config
    local Icons, New = U.Icons, U.New
    local expanded = false
    local barVisible = Cfg.ShowWindow

    local Toolbar = New("Frame", {
        Name = "Toolbar",
        Size = UDim2.new(0, 16, 0, 45),
        AnchorPoint = Vector2.new(0.5, 1),
        Position = barVisible and UDim2.new(0.5, 0, 1, -20) or UDim2.new(0.5, 0, 1, 60),
        BackgroundColor3 = C.Window,
        BackgroundTransparency = Cfg.Transparent and 0.15 or 0,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, Ctx.ScreenGui)
    U.Corner(Toolbar, Theme.Corner.Toolbar)
    U.Stroke(Toolbar, C.Stroke, C.StrokeAlpha)
    U.Glow(Toolbar, 20, 0.6)

    local Main = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 6,
    }, Toolbar)
    U.Corner(Main, Theme.Corner.Toolbar)
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
    }, Main)
    New("UIPadding", {PaddingLeft = UDim.new(0, 8)}, Main)

    -- Dock: botões das abas
    local Dock = New("Frame", {Name = "Dock", Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 7}, Main)
    local dockLayout = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
    }, Dock)
    Ctx.Dock = Dock

    -- Info: título/autor (aparece ao expandir)
    local Info = New("Frame", {
        Name = "Info",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false,
        LayoutOrder = 2,
        ZIndex = 7,
    }, Main)
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 2),
    }, Info)
    New("UIPadding", {PaddingRight = UDim.new(0, 5)}, Info)

    U.Label(Ctx, Info, {
        Size = UDim2.new(1, 0, 0, 16), Text = Cfg.Title, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 10,
    })
    U.Label(Ctx, Info, {
        Size = UDim2.new(1, 0, 0, 12), Text = Cfg.Author, TextSize = 11, TextTransparency = 0.35,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 10,
    })

    local function updateWidth()
        local dockW = Dock.Size.X.Offset
        local infoW = expanded and 110 or 0
        local pad = expanded and 8 or 0
        if expanded then Info.Visible = true end

        TweenService:Create(Toolbar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, dockW + pad + infoW + 16, 0, 45),
        }):Play()
        local tw = TweenService:Create(Info, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, infoW, 1, 0),
        })
        tw:Play()
        if not expanded then
            tw.Completed:Connect(function() if not expanded then Info.Visible = false end end)
        end
    end

    dockLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Dock.Size = UDim2.new(0, dockLayout.AbsoluteContentSize.X, 1, 0)
        updateWidth()
    end)

    -- Botão expandir
    local ExpandBtn = New("ImageButton", {
        Size = UDim2.new(0, 24, 0, 24),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(1, 6, 0.5, 0),
        BackgroundTransparency = 1,
        Image = Icons["chevron-right"] or "",
        ImageColor3 = C.Content,
        ImageTransparency = 0.35,
        ZIndex = 6,
    }, Toolbar)
    ExpandBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        ExpandBtn.Image = expanded and Icons["chevron-left"] or Icons["chevron-right"]
        updateWidth()
    end)

    -- Botão esconder/mostrar barra
    local HideBtn = New("ImageButton", {
        Size = UDim2.new(0, 24, 0, 24),
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 0, -6),
        BackgroundTransparency = 1,
        Image = barVisible and Icons["chevron-down"] or Icons["chevron-up"],
        ImageColor3 = C.Content,
        ImageTransparency = 0.35,
        ZIndex = 6,
    }, Toolbar)
    HideBtn.MouseButton1Click:Connect(function()
        barVisible = not barVisible
        HideBtn.Image = barVisible and Icons["chevron-down"] or Icons["chevron-up"]
        TweenService:Create(Toolbar, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = barVisible and UDim2.new(0.5, 0, 1, -20) or UDim2.new(0.5, 0, 1, 60),
        }):Play()
        if not barVisible and Ctx.CurrentWindow then
            Ctx.ToggleWindow(Ctx.CurrentWindow, Ctx.CurrentWindow:GetAttribute("Height") or 350)
        end
    end)

    Ctx.Toolbar = Toolbar
end
