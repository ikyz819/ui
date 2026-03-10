-- KeySystem Library (with X button and draggable)
local KeySystem = {}
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Default configuration
local DEFAULT_CONFIG = {
    Color = Color3.fromRGB(88, 101, 242),
    Title = "Key System",
    Icon = "",
}

-- Helper function to get icon ID
local function getIconId(icon)
    if type(icon) == "string" and icon ~= "" then
        if icon:match("^rbxassetid://") then
            return icon
        elseif tonumber(icon) then
            return "rbxassetid://" .. icon
        end
    end
    return ""
end

function KeySystem.new(config)
    config = config or {}

    local ks = {
        Title = config.Title or DEFAULT_CONFIG.Title,
        Note = config.Note or "",
        Placeholder = config.Placeholder or "Enter Key",
        Default = config.Default or "",
        Icon = config.Icon or DEFAULT_CONFIG.Icon,
        Buttons = config.Buttons or {},
        OnSubmit = config.OnSubmit,
        OnExit = config.OnExit,
        ValidateKey = config.ValidateKey,
    }

    local GuiConfig = {
        Color = config.Color or DEFAULT_CONFIG.Color,
        Title = ks.Title,
    }

    -- Create GUI
    local KsGui = Instance.new("ScreenGui")
    KsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KsGui.Name = "KeySystemGui"
    KsGui.ResetOnSpawn = false
    KsGui.Parent = CoreGui

    -- Card
    local Card = Instance.new("Frame")
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.Position = UDim2.new(0.5, 0, 0.45, 0)
    Card.Size = UDim2.new(0, 300, 0, 178)
    Card.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    Card.BackgroundTransparency = 1
    Card.BorderSizePixel = 0
    Card.ZIndex = 101
    Card.Parent = KsGui
    Card.Active = true
    Card.Selectable = true

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Color3.fromRGB(38, 38, 48)
    CardStroke.Thickness = 1
    CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    CardStroke.Parent = Card

    -- DRAGGABLE FUNCTIONALITY
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function updateDrag(input)
        if not dragging then return end
        
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        
        -- Keep card within screen bounds
        local absPos = newPosition
        Card.Position = absPos
    end

    -- Use the top bar area for dragging (icon box + title area)
    local DragArea = Instance.new("Frame")
    DragArea.Size = UDim2.new(1, -50, 0, 50) -- Leave space for X button
    DragArea.Position = UDim2.new(0, 0, 0, 0)
    DragArea.BackgroundTransparency = 1
    DragArea.BorderSizePixel = 0
    DragArea.ZIndex = 200
    DragArea.Parent = Card

    DragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Card.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    DragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)

    -- X BUTTON (Close)
    local XButton = Instance.new("TextButton")
    XButton.Size = UDim2.new(0, 30, 0, 30)
    XButton.Position = UDim2.new(1, -35, 0, 10)
    XButton.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    XButton.BackgroundTransparency = 0
    XButton.BorderSizePixel = 0
    XButton.ZIndex = 200
    XButton.Text = "✕"
    XButton.TextColor3 = Color3.fromRGB(140, 140, 150)
    XButton.TextSize = 16
    XButton.Font = Enum.Font.GothamBold
    XButton.Parent = Card

    local XButtonCorner = Instance.new("UICorner")
    XButtonCorner.CornerRadius = UDim.new(0, 6)
    XButtonCorner.Parent = XButton

    local XButtonStroke = Instance.new("UIStroke")
    XButtonStroke.Color = Color3.fromRGB(50, 50, 62)
    XButtonStroke.Thickness = 1
    XButtonStroke.Parent = XButton

    -- X Button hover effects
    XButton.MouseEnter:Connect(function()
        TweenService:Create(XButton, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(190, 65, 65),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)

    XButton.MouseLeave:Connect(function()
        TweenService:Create(XButton, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(28, 28, 36),
            TextColor3 = Color3.fromRGB(140, 140, 150)
        }):Play()
    end)

    -- X Button click
    XButton.MouseButton1Click:Connect(function()
        CloseKeySystem()
    end)

    -- Icon Box (moved slightly to accommodate X button)
    local IconBox = Instance.new("Frame")
    IconBox.Size = UDim2.new(0, 24, 0, 24)
    IconBox.Position = UDim2.new(0, 14, 0, 16)
    IconBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    IconBox.BorderSizePixel = 0
    IconBox.ZIndex = 102
    IconBox.Parent = Card

    local IconBoxCorner = Instance.new("UICorner")
    IconBoxCorner.CornerRadius = UDim.new(0, 6)
    IconBoxCorner.Parent = IconBox

    local IconBoxStroke = Instance.new("UIStroke")
    IconBoxStroke.Color = Color3.fromRGB(50, 50, 62)
    IconBoxStroke.Thickness = 1
    IconBoxStroke.Parent = IconBox

    local KsIconImg = Instance.new("ImageLabel")
    KsIconImg.AnchorPoint = Vector2.new(0.5, 0.5)
    KsIconImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    KsIconImg.Size = UDim2.new(0, 13, 0, 13)
    KsIconImg.BackgroundTransparency = 1
    KsIconImg.BorderSizePixel = 0
    local ksIconId = getIconId(ks.Icon or "")
    KsIconImg.Image = (ksIconId ~= "") and ksIconId or "rbxassetid://6031094678"
    KsIconImg.ImageColor3 = Color3.fromRGB(180, 180, 190)
    KsIconImg.ScaleType = Enum.ScaleType.Fit
    KsIconImg.ZIndex = 103
    KsIconImg.Parent = IconBox

    -- Title
    local KsTitle = Instance.new("TextLabel")
    KsTitle.Font = Enum.Font.GothamBold
    KsTitle.Text = ks.Title
    KsTitle.TextColor3 = Color3.fromRGB(232, 232, 238)
    KsTitle.TextSize = 14
    KsTitle.TextXAlignment = Enum.TextXAlignment.Left
    KsTitle.BackgroundTransparency = 1
    KsTitle.BorderSizePixel = 0
    KsTitle.AnchorPoint = Vector2.new(0, 0.5)
    KsTitle.Position = UDim2.new(0, 44, 0, 28)
    KsTitle.Size = UDim2.new(1, -90, 0, 18) -- Adjusted for X button
    KsTitle.ZIndex = 102
    KsTitle.Parent = Card

    -- Header Divider
    local HDivider = Instance.new("Frame")
    HDivider.Size = UDim2.new(1, 0, 0, 1)
    HDivider.Position = UDim2.new(0, 0, 0, 50)
    HDivider.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
    HDivider.BorderSizePixel = 0
    HDivider.ZIndex = 102
    HDivider.Parent = Card

    -- Note
    local KsNote = Instance.new("TextLabel")
    KsNote.Font = Enum.Font.Gotham
    KsNote.Text = ks.Note
    KsNote.TextColor3 = Color3.fromRGB(95, 95, 108)
    KsNote.TextSize = 12
    KsNote.TextXAlignment = Enum.TextXAlignment.Left
    KsNote.BackgroundTransparency = 1
    KsNote.BorderSizePixel = 0
    KsNote.Position = UDim2.new(0, 14, 0, 60)
    KsNote.Size = UDim2.new(1, -28, 0, 14)
    KsNote.ZIndex = 102
    KsNote.Parent = Card

    -- Input Background
    local InputBg = Instance.new("Frame")
    InputBg.Position = UDim2.new(0, 14, 0, 84)
    InputBg.Size = UDim2.new(1, -28, 0, 32)
    InputBg.BackgroundColor3 = Color3.fromRGB(22, 22, 29)
    InputBg.BorderSizePixel = 0
    InputBg.ZIndex = 102
    InputBg.Parent = Card

    local InputBgCorner = Instance.new("UICorner")
    InputBgCorner.CornerRadius = UDim.new(0, 7)
    InputBgCorner.Parent = InputBg

    local InputBgStroke = Instance.new("UIStroke")
    InputBgStroke.Color = Color3.fromRGB(44, 44, 56)
    InputBgStroke.Thickness = 1
    InputBgStroke.Parent = InputBg

    -- Input Icon
    local InputIcon = Instance.new("ImageLabel")
    InputIcon.AnchorPoint = Vector2.new(0, 0.5)
    InputIcon.Position = UDim2.new(0, 9, 0.5, 0)
    InputIcon.Size = UDim2.new(0, 13, 0, 13)
    InputIcon.BackgroundTransparency = 1
    InputIcon.Image = "rbxassetid://6031094678"
    InputIcon.ImageColor3 = Color3.fromRGB(75, 75, 88)
    InputIcon.ScaleType = Enum.ScaleType.Fit
    InputIcon.ZIndex = 103
    InputIcon.Parent = InputBg

    -- Text Input
    local KsInput = Instance.new("TextBox")
    KsInput.Font = Enum.Font.Gotham
    KsInput.PlaceholderText = ks.Placeholder
    KsInput.PlaceholderColor3 = Color3.fromRGB(65, 65, 78)
    KsInput.Text = ks.Default
    KsInput.TextColor3 = Color3.fromRGB(210, 210, 222)
    KsInput.TextSize = 12
    KsInput.TextXAlignment = Enum.TextXAlignment.Left
    KsInput.BackgroundTransparency = 1
    KsInput.BorderSizePixel = 0
    KsInput.ClearTextOnFocus = false
    KsInput.Position = UDim2.new(0, 28, 0, 0)
    KsInput.Size = UDim2.new(1, -34, 1, 0)
    KsInput.ZIndex = 103
    KsInput.Parent = InputBg

    -- Input focus effects
    KsInput.Focused:Connect(function()
        TweenService:Create(InputBgStroke, TweenInfo.new(0.18), {
            Color = GuiConfig.Color, 
            Transparency = 0.45
        }):Play()
    end)

    KsInput.FocusLost:Connect(function()
        TweenService:Create(InputBgStroke, TweenInfo.new(0.18), {
            Color = Color3.fromRGB(44, 44, 56), 
            Transparency = 0
        }):Play()
    end)

    -- Bottom Divider
    local BDivider = Instance.new("Frame")
    BDivider.Size = UDim2.new(1, 0, 0, 1)
    BDivider.Position = UDim2.new(0, 0, 0, 128)
    BDivider.BackgroundColor3 = Color3.fromRGB(34, 34, 44)
    BDivider.BorderSizePixel = 0
    BDivider.ZIndex = 102
    BDivider.Parent = Card

    -- Button Row
    local BtnRow = Instance.new("Frame")
    BtnRow.BackgroundTransparency = 1
    BtnRow.BorderSizePixel = 0
    BtnRow.Position = UDim2.new(0, 14, 0, 136)
    BtnRow.Size = UDim2.new(1, -28, 0, 30)
    BtnRow.ZIndex = 102
    BtnRow.Parent = Card

    local BtnList = Instance.new("UIListLayout")
    BtnList.FillDirection = Enum.FillDirection.Horizontal
    BtnList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    BtnList.VerticalAlignment = Enum.VerticalAlignment.Center
    BtnList.Padding = UDim.new(0, 6)
    BtnList.SortOrder = Enum.SortOrder.LayoutOrder
    BtnList.Parent = BtnRow

    -- Shake animation helper
    local function ShakeCard()
        local origPos = Card.Position
        local offsets = {7, -7, 5, -5, 3, -3, 0}
        for _, ox in ipairs(offsets) do
            Card.Position = UDim2.new(
                origPos.X.Scale, origPos.X.Offset + ox,
                origPos.Y.Scale, origPos.Y.Offset
            )
            task.wait(0.04)
        end
        Card.Position = origPos
    end

    -- Close function
    local ksClosing = false
    local function CloseKeySystem()
        if ksClosing then return end
        ksClosing = true
        TweenService:Create(Card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 0.56, 0),
            BackgroundTransparency = 1,
        }):Play()
        task.delay(0.25, function()
            pcall(function() 
                KsGui:Destroy()
                if ks.OnExit then
                    pcall(ks.OnExit)
                end
            end)
        end)
    end

    -- Create buttons
    local buttons = ks.Buttons
    if #buttons == 0 then
        buttons = {
            { Name = "Exit", Style = "secondary" },
            { Name = "Submit", Style = "primary" },
        }
    end

    for i, btnCfg in ipairs(buttons) do
        local isPrimary = (btnCfg.Style == "primary") or 
                         (btnCfg.Name == "Submit") or 
                         (i == #buttons and btnCfg.Style ~= "secondary")

        local Btn = Instance.new("TextButton")
        Btn.Font = Enum.Font.GothamBold
        Btn.Text = ""
        Btn.AutomaticSize = Enum.AutomaticSize.X
        Btn.Size = UDim2.new(0, 0, 1, 0)
        Btn.BorderSizePixel = 0
        Btn.LayoutOrder = i
        Btn.ZIndex = 103
        Btn.Parent = BtnRow

        if isPrimary then
            Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 62)
            Btn.BackgroundTransparency = 0
        else
            Btn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
            Btn.BackgroundTransparency = 0
        end

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 7)
        BtnCorner.Parent = Btn

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = isPrimary and Color3.fromRGB(65, 65, 80) or Color3.fromRGB(44, 44, 56)
        BtnStroke.Thickness = 1
        BtnStroke.Parent = Btn

        local BtnPadding = Instance.new("UIPadding")
        BtnPadding.PaddingLeft  = UDim.new(0, 10)
        BtnPadding.PaddingRight = UDim.new(0, 10)
        BtnPadding.Parent = Btn

        -- Button inner content
        local BtnInner = Instance.new("Frame")
        BtnInner.BackgroundTransparency = 1
        BtnInner.BorderSizePixel = 0
        BtnInner.AutomaticSize = Enum.AutomaticSize.X
        BtnInner.Size = UDim2.new(0, 0, 1, 0)
        BtnInner.ZIndex = 103
        BtnInner.Parent = Btn

        local BtnInnerList = Instance.new("UIListLayout")
        BtnInnerList.FillDirection = Enum.FillDirection.Horizontal
        BtnInnerList.VerticalAlignment = Enum.VerticalAlignment.Center
        BtnInnerList.Padding = UDim.new(0, 5)
        BtnInnerList.Parent = BtnInner

        -- Button icon
        local iconId = getIconId(btnCfg.Icon or "")
        if iconId and iconId ~= "" then
            local BtnIcon = Instance.new("ImageLabel")
            BtnIcon.BackgroundTransparency = 1
            BtnIcon.BorderSizePixel = 0
            BtnIcon.Size = UDim2.new(0, 12, 0, 12)
            BtnIcon.Image = iconId
            BtnIcon.ImageColor3 = Color3.fromRGB(180, 180, 195)
            BtnIcon.ScaleType = Enum.ScaleType.Fit
            BtnIcon.LayoutOrder = 0
            BtnIcon.ZIndex = 104
            BtnIcon.Parent = BtnInner
        end

        -- Button label
        local BtnLabel = Instance.new("TextLabel")
        BtnLabel.Font = Enum.Font.GothamBold
        BtnLabel.Text = btnCfg.Name or "Button"
        BtnLabel.TextColor3 = Color3.fromRGB(195, 195, 208)
        BtnLabel.TextSize = 12
        BtnLabel.BackgroundTransparency = 1
        BtnLabel.BorderSizePixel = 0
        BtnLabel.AutomaticSize = Enum.AutomaticSize.X
        BtnLabel.Size = UDim2.new(0, 0, 1, 0)
        BtnLabel.LayoutOrder = 1
        BtnLabel.ZIndex = 104
        BtnLabel.Parent = BtnInner

        -- Hover effects
        local normBg = isPrimary and Color3.fromRGB(50,50,62) or Color3.fromRGB(26,26,34)
        local hovBg  = isPrimary and Color3.fromRGB(62,62,78) or Color3.fromRGB(34,34,44)

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.12), { BackgroundColor3 = hovBg }):Play()
        end)

        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.12), { BackgroundColor3 = normBg }):Play()
        end)

        -- Button click handler (FIXED VERSION)
        Btn.MouseButton1Click:Connect(function()
            local currentKey = KsInput.Text
            
            -- Check if this is the submit button
            local isSubmit = (btnCfg.Name == "Submit" or btnCfg.Style == "primary")
            
            -- Handle validation if this is submit and ValidateKey exists
            if ks.ValidateKey and isSubmit then
                local isValid = ks.ValidateKey(currentKey)
                if isValid then
                    if ks.OnSubmit then
                        local success, err = pcall(ks.OnSubmit, currentKey)
                        if not success then
                            warn("OnSubmit error:", err)
                        end
                    end
                    CloseKeySystem()
                else
                    -- Invalid key animation
                    TweenService:Create(InputBgStroke, TweenInfo.new(0.1), {
                        Color = Color3.fromRGB(220, 55, 55), 
                        Transparency = 0
                    }):Play()
                    
                    task.delay(0.7, function()
                        TweenService:Create(InputBgStroke, TweenInfo.new(0.3), {
                            Color = Color3.fromRGB(44,44,56), 
                            Transparency = 0
                        }):Play()
                    end)
                    
                    task.spawn(ShakeCard)
                end
                return
            end
            
            -- Handle custom button callbacks
            if btnCfg.Callback then
                local success, callbackResult = pcall(btnCfg.Callback, currentKey)
                
                if success then
                    if callbackResult == true then
                        CloseKeySystem()
                    end
                    -- If callbackResult is false, nil, etc., keep GUI open
                else
                    warn("Button callback error:", callbackResult)
                end
                return
            end
            
            -- Default behavior: check if it's an exit button
            local isCloseBtn = btnCfg.Close == true or
                             btnCfg.Name == "Exit" or
                             btnCfg.Name == "Close" or
                             btnCfg.Name == "Cancel"
            
            if isCloseBtn then
                CloseKeySystem()
            end
        end)
    end

    -- Entrance animation
    TweenService:Create(Card, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0,
    }):Play()

    -- Return the GUI object for external control
    return KsGui
end

return KeySystem
