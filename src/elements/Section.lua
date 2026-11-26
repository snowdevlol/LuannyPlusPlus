--!nonstrict
return function(Ctx, parent, order, options)
    local C, U = Ctx.C, Ctx.Utils

    local frame = U.New("Frame", {
        Size = UDim2.new(0, 340, 0, 30), BackgroundTransparency = 1, LayoutOrder = order,
    }, parent)
    local lbl = U.Label(Ctx, frame, {
        Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), Text = options.Title or "Section",
    })
    U.New("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C.Content, BackgroundTransparency = 0.8, BorderSizePixel = 0,
    }, frame)

    return {
        SetTitle = function(t) lbl.Text = t end,
        Destroy = function() frame:Destroy() end,
    }
end
