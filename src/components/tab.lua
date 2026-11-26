-- Cria as abas e liga cada método (Button, Toggle...) ao arquivo em Elements/.
-- Para adicionar um elemento novo: crie Elements/Nome.lua e adicione "Nome" na lista abaixo.
local TweenService = game:GetService("TweenService")

return function(Ctx)
    local Theme, U = Ctx.Theme, Ctx.Utils

    local TabClass = {}
    TabClass.__index = TabClass

    for _, name in ipairs({"Section", "Button", "Toggle", "Input", "Dropdown", "Paragraph", "Slider"}) do
        local build = Ctx.Import("Elements/" .. name .. ".lua")
        TabClass[name] = function(self, options)
            self.ItemCount += 1
            return build(Ctx, self.Container, self.ItemCount, options or {})
        end
    end

    return function(options)
        local C = Ctx.C
        Ctx.LayoutOrder += 1

        local title = options.Title or "Tab"
        local icon = options.Icon or "layout-grid"
        local height = options.Height or 350
        local tabColor = options.Color or C.Content

        local accent = C.Content
        if typeof(tabColor) == "ColorSequence" then
            accent = tabColor.Keypoints[#tabColor.Keypoints].Value
        elseif typeof(tabColor) == "Color3" then
            accent = tabColor
        end

        local btn = U.New("TextButton", {
            Size = UDim2.new(0, 32, 0, 32),
            BackgroundColor3 = C.Content,
            BackgroundTransparency = 0.93,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = Ctx.LayoutOrder,
            ZIndex = 8,
        }, Ctx.Dock)
        U.Corner(btn, Theme.Corner.TabButton)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.93}):Play()
        end)

        U.New("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Image = U.Icons[icon] or "",
            ImageColor3 = accent,
            ZIndex = 9,
        }, btn)

        local mask, container = Ctx.CreateTabWindow(title, height)
        btn.MouseButton1Click:Connect(function() Ctx.ToggleWindow(mask, height) end)

        return setmetatable({Container = container, ItemCount = 0}, TabClass)
    end
end
