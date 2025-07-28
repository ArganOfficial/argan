local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ArganUILib = {}
ArganUILib.__index = ArganUILib

local themes = {
    Dark = {
        Frame = Color3.fromRGB(35, 35, 50),
        ButtonOff = Color3.fromRGB(60, 60, 80),
        ButtonOn = Color3.fromRGB(120, 80, 200),
        TextColor = Color3.fromRGB(255, 255, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        SliderTrack = Color3.fromRGB(80, 80, 100),
        SliderHandle = Color3.fromRGB(150, 150, 200),
        Dropdown = Color3.fromRGB(50, 50, 70)
    },
    Light = {
        Frame = Color3.fromRGB(200, 200, 210),
        ButtonOff = Color3.fromRGB(180, 180, 190),
        ButtonOn = Color3.fromRGB(100, 150, 255),
        TextColor = Color3.fromRGB(0, 0, 0),
        Shadow = Color3.fromRGB(50, 50, 50),
        SliderTrack = Color3.fromRGB(150, 150, 160),
        SliderHandle = Color3.fromRGB(80, 80, 255),
        Dropdown = Color3.fromRGB(170, 170, 180)
    },
    Neon = {
        Frame = Color3.fromRGB(20, 20, 30),
        ButtonOff = Color3.fromRGB(40, 40, 60),
        ButtonOn = Color3.fromRGB(0, 255, 255),
        TextColor = Color3.fromRGB(200, 255, 255),
        Shadow = Color3.fromRGB(0, 100, 100),
        SliderTrack = Color3.fromRGB(30, 30, 50),
        SliderHandle = Color3.fromRGB(0, 200, 200),
        Dropdown = Color3.fromRGB(25, 25, 40)
    },
    Pastel = {
        Frame = Color3.fromRGB(230, 220, 240),
        ButtonOff = Color3.fromRGB(200, 190, 210),
        ButtonOn = Color3.fromRGB(180, 150, 220),
        TextColor = Color3.fromRGB(80, 80, 80),
        Shadow = Color3.fromRGB(150, 140, 160),
        SliderTrack = Color3.fromRGB(210, 200, 220),
        SliderHandle = Color3.fromRGB(160, 130, 200),
        Dropdown = Color3.fromRGB(220, 210, 230)
    }
}

local defaultSizes = {
    PanelWidth = 220,
    PanelHeight = 700,
    PanelSpacing = 240,
    TitleHeight = 50,
    ButtonHeight = 44,
    SliderHeight = 30,
    DropdownHeight = 30,
    SettingsWidth = 300
}

function ArganUILib.new(player, guiName, toggleKey)
    local self = setmetatable({}, ArganUILib)
    
    self.Player = player
    self.PlayerGui = player:WaitForChild("PlayerGui")
    self.GuiName = guiName or "ArganUI"
    self.ToggleKey = toggleKey or Enum.KeyCode.RightShift
    self.Theme = themes.Dark
    self.Sizes = defaultSizes
    self.AllFrames = {}
    self.GuiVisible = true
    self.Categories = {}
    
    local oldGui = self.PlayerGui:FindFirstChild(self.GuiName)
    if oldGui then oldGui:Destroy() end
    
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = self.GuiName
    self.Gui.ResetOnSpawn = false
    self.Gui.IgnoreGuiInset = true
    self.Gui.Parent = self.PlayerGui
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.ToggleKey then
            self:ToggleVisibility()
        end
    end)
    
    self:AddSettingsCategory()
    
    return self
end

function ArganUILib:SetTheme(themeName)
    self.Theme = themes[themeName] or themes.Dark
    for _, frame in ipairs(self.AllFrames) do
        frame.BackgroundColor3 = self.Theme.Frame
        for _, child in ipairs(frame:GetChildren()) do
            if child:IsA("TextLabel") then
                child.TextColor3 = self.Theme.TextColor
                child.BackgroundColor3 = self.Theme.ButtonOff
            elseif child:IsA("TextButton") then
                child.TextColor3 = self.Theme.TextColor
                child.BackgroundColor3 = self.Theme.ButtonOff
            elseif child:IsA("UIStroke") then
                child.Color = self.Theme.Shadow
            elseif child:IsA("Frame") and child.Name == "SliderTrack" then
                child.BackgroundColor3 = self.Theme.SliderTrack
                for _, handle in ipairs(child:GetChildren()) do
                    if handle:IsA("Frame") then
                        handle.BackgroundColor3 = self.Theme.SliderHandle
                    end
                end
            elseif child:IsA("Frame") and child.Name == "Dropdown" then
                child.BackgroundColor3 = self.Theme.Dropdown
            end
        end
    end
end

function ArganUILib:SetSizes(customSizes)
    for key, value in pairs(customSizes) do
        self.Sizes[key] = value
    end
end

function ArganUILib:TweenVisibility(frame, visible)
    if visible then
        frame.Visible = true
        frame.Size = UDim2.new(0, frame.Name == "Settings" and self.Sizes.SettingsWidth or self.Sizes.PanelWidth, 0, 0)
        TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, frame.Name == "Settings" and self.Sizes.SettingsWidth or self.Sizes.PanelWidth, 0, self.Sizes.PanelHeight)
        }):Play()
    else
        local tween = TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, frame.Name == "Settings" and self.Sizes.SettingsWidth or self.Sizes.PanelWidth, 0, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            frame.Visible = false
        end)
    end
end

function ArganUILib:ToggleVisibility()
    self.GuiVisible = not self.GuiVisible
    for _, frame in ipairs(self.AllFrames) do
        self:TweenVisibility(frame, self.GuiVisible)
    end
end

function ArganUILib:CreateCategoryFrame(name, position)
    local holder = Instance.new("Frame")
    holder.Name = name
    holder.Size = UDim2.new(0, name == "Settings" and self.Sizes.SettingsWidth or self.Sizes.PanelWidth, 0, 0)
    holder.Position = position
    holder.BackgroundColor3 = self.Theme.Frame
    holder.BorderSizePixel = 0
    holder.Active = true
    holder.Draggable = true
    holder.Visible = false
    holder.Parent = self.Gui

    local stroke = Instance.new("UIStroke", holder)
    stroke.Color = self.Theme.Shadow
    stroke.Thickness = 1.5
    stroke.Transparency = 0.7

    local corner = Instance.new("UICorner", holder)
    corner.CornerRadius = UDim.new(0, 12)

    table.insert(self.AllFrames, holder)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, self.Sizes.TitleHeight)
    title.BackgroundColor3 = self.Theme.ButtonOff
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Text = name
    title.TextColor3 = self.Theme.TextColor
    title.BorderSizePixel = 0
    title.Parent = holder

    local titleCorner = Instance.new("UICorner", title)
    titleCorner.CornerRadius = UDim.new(0, 8)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, -self.Sizes.TitleHeight - 10)
    container.Position = UDim2.new(0, 0, 0, self.Sizes.TitleHeight + 5)
    container.BackgroundTransparency = 1
    container.Parent = holder

    local layout = Instance.new("UIListLayout", container)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    return holder, container
end

function ArganUILib:CreateToggleButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, self.Sizes.ButtonHeight)
    button.BackgroundColor3 = self.Theme.ButtonOff
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextColor3 = self.Theme.TextColor
    button.Text = text
    button.AutoButtonColor = false
    button.Parent = parent

    local round = Instance.new("UICorner", button)
    round.CornerRadius = UDim.new(0, 6)

    local toggled = false
    button.MouseButton1Click:Connect(function()
        toggled = not toggled
        TweenService:Create(button, TweenInfo.new(0.25), {
            BackgroundColor3 = toggled and self.Theme.ButtonOn or self.Theme.ButtonOff
        }):Play()
        if callback then callback(toggled) end
    end)
end

function ArganUILib:CreateSlider(parent, text, min, max, callback)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.9, 0, 0, self.Sizes.SliderHeight)
    slider.BackgroundTransparency = 1
    slider.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = self.Theme.TextColor
    label.Text = text
    label.Parent = slider

    local track = Instance.new("Frame")
    track.Name = "SliderTrack"
    track.Size = UDim2.new(1, 0, 0, 10)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = self.Theme.SliderTrack
    track.Parent = slider

    local corner = Instance.new("UICorner", track)
    corner.CornerRadius = UDim.new(0, 5)

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 10, 0, 10)
    handle.BackgroundColor3 = self.Theme.SliderHandle
    handle.Parent = track

    local handleCorner = Instance.new("UICorner", handle)
    handleCorner.CornerRadius = UDim.new(0, 5)

    local dragging = false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            handle.Position = UDim2.new(relativeX, -5, 0, 0)
            local value = min + (max - min) * relativeX
            if callback then callback(value) end
        end
    end)
end

function ArganUILib:CreateColorPicker(parent, text, callback)
    local picker = Instance.new("TextButton")
    picker.Size = UDim2.new(0.9, 0, 0, self.Sizes.ButtonHeight)
    picker.BackgroundColor3 = self.Theme.ButtonOff
    picker.BorderSizePixel = 0
    picker.Font = Enum.Font.Gotham
    picker.TextSize = 16
    picker.TextColor3 = self.Theme.TextColor
    picker.Text = text
    picker.AutoButtonColor = false
    picker.Parent = parent

    local round = Instance.new("UICorner", picker)
    round.CornerRadius = UDim.new(0, 6)

    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(0.3, 0, 1, 0)
    colorFrame.Position = UDim2.new(0.7, 0, 0, 0)
    colorFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    colorFrame.Parent = picker

    local colorCorner = Instance.new("UICorner", colorFrame)
    colorCorner.CornerRadius = UDim.new(0, 6)

    picker.MouseButton1Click:Connect(function()
        local r = self:CreateSlider(parent, text .. " R", 0, 255, function(value)
            local currentColor = colorFrame.BackgroundColor3
            colorFrame.BackgroundColor3 = Color3.fromRGB(value, currentColor.G * 255, currentColor.B * 255)
            if callback then callback(colorFrame.BackgroundColor3) end
        end)
        local g = self:CreateSlider(parent, text .. " G", 0, 255, function(value)
            local currentColor = colorFrame.BackgroundColor3
            colorFrame.BackgroundColor3 = Color3.fromRGB(currentColor.R * 255, value, currentColor.B * 255)
            if callback then callback(colorFrame.BackgroundColor3) end
        end)
        local b = self:CreateSlider(parent, text .. " B", 0, 255, function(value)
            local currentColor = colorFrame.BackgroundColor3
            colorFrame.BackgroundColor3 = Color3.fromRGB(currentColor.R * 255, currentColor.G * 255, value)
            if callback then callback(colorFrame.BackgroundColor3) end
        end)
        picker:Destroy()
    end)
end

function ArganUILib:CreateDropdown(parent, text, options, callback)
    local dropdown = Instance.new("Frame")
    dropdown.Name = "Dropdown"
    dropdown.Size = UDim2.new(0.9, 0, 0, self.Sizes.DropdownHeight)
    dropdown.BackgroundColor3 = self.Theme.Dropdown
    dropdown.Parent = parent

    local round = Instance.new("UICorner", dropdown)
    round.CornerRadius = UDim.new(0, 6)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextColor3 = self.Theme.TextColor
    button.Text = text .. ": " .. options[1]
    button.Parent = dropdown

    local optionContainer = Instance.new("Frame")
    optionContainer.Size = UDim2.new(1, 0, 0, #options * self.Sizes.DropdownHeight)
    optionContainer.Position = UDim2.new(0, 0, 1, 5)
    optionContainer.BackgroundColor3 = self.Theme.Dropdown
    optionContainer.Visible = false
    optionContainer.Parent = dropdown

    local optionLayout = Instance.new("UIListLayout", optionContainer)
    optionLayout.Padding = UDim.new(0, 2)

    for _, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, self.Sizes.DropdownHeight)
        optionButton.BackgroundTransparency = 1
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextSize = 14
        optionButton.TextColor3 = self.Theme.TextColor
        optionButton.Text = option
        optionButton.Parent = optionContainer
        optionButton.MouseButton1Click:Connect(function()
            button.Text = text .. ": " .. option
            optionContainer.Visible = false
            if callback then callback(option) end
        end)
    end

    button.MouseButton1Click:Connect(function()
        optionContainer.Visible = not optionContainer.Visible
    end)
end

function ArganUILib:AddSettingsCategory()
    local settings = {
        Name = "Settings",
        Buttons = {
            {Name = "Theme", Type = "Dropdown", Options = {"Dark", "Light", "Neon", "Pastel"}, Callback = function(theme) self:SetTheme(theme) end},
            {Name = "Panel Width", Type = "Slider", Min = 150, Max = 400, Callback = function(value) self.Sizes.PanelWidth = value end},
            {Name = "Panel Height", Type = "Slider", Min = 400, Max = 800, Callback = function(value) self.Sizes.PanelHeight = value end},
            {Name = "Frame Color", Type = "ColorPicker", Callback = function(color) self.Theme.Frame = color end},
            {Name = "Button On Color", Type = "ColorPicker", Callback = function(color) self.Theme.ButtonOn = color end},
            {Name = "Text Color", Type = "ColorPicker", Callback = function(color) self.Theme.TextColor = color end}
        }
    }
    table.insert(self.Categories, settings)
    local totalWidth = #self.Categories * self.Sizes.PanelSpacing
    local centerOffset = (workspace.CurrentCamera.ViewportSize.X / 2) - (totalWidth / 2)
    local xOffset = centerOffset + ((#self.Categories - 1) * self.Sizes.PanelSpacing)
    
    local frame, content = self:CreateCategoryFrame(settings.Name, UDim2.new(0, xOffset, 0, 100))
    
    for _, btnData in ipairs(settings.Buttons) do
        if btnData.Type == "Slider" then
            self:CreateSlider(content, btnData.Name, btnData.Min, btnData.Max, btnData.Callback)
        elseif btnData.Type == "ColorPicker" then
            self:CreateColorPicker(content, btnData.Name, btnData.Callback)
        elseif btnData.Type == "Dropdown" then
            self:CreateDropdown(content, btnData.Name, btnData.Options, btnData.Callback)
        end
    end
    
    delay(0.05 * #self.Categories, function()
        self:TweenVisibility(frame, true)
    end)
end

function ArganUILib:AddCategory(categoryData)
    table.insert(self.Categories, categoryData)
    local index = #self.Categories
    local totalWidth = #self.Categories * self.Sizes.PanelSpacing
    local centerOffset = (workspace.CurrentCamera.ViewportSize.X / 2) - (totalWidth / 2)
    local xOffset = centerOffset + ((index - 1) * self.Sizes.PanelSpacing)
    
    local frame, content = self:CreateCategoryFrame(categoryData.Name, UDim2.new(0, xOffset, 0, 100))
    
    for _, btnData in ipairs(categoryData.Buttons) do
        if btnData.Type == "Slider" then
            self:CreateSlider(content, btnData.Name, btnData.Min, btnData.Max, btnData.Callback)
        elseif btnData.Type == "ColorPicker" then
            self:CreateColorPicker(content, btnData.Name, btnData.Callback)
        elseif btnData.Type == "Dropdown" then
            self:CreateDropdown(content, btnData.Name, btnData.Options, btnData.Callback)
        else
            self:CreateToggleButton(content, btnData.Name, btnData.Callback)
        end
    end
    
    delay(0.05 * index, function()
        self:TweenVisibility(frame, true)
    end)
end

function ArganUILib:Destroy()
    self.Gui:Destroy()
end

return ArganUILib