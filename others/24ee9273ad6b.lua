--// Teleport Manager Modern UI – Full Save ke Lua Script
--// Paste di StarterPlayerScripts sebagai LocalScript

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Data dasar
local positions = {
    ["Puncak Hajoe"] = Vector3.new(198.5, 605.865, -178.5),
    ["ins"] = Vector3.new(354.519897, 25.934353, 2642.425781),
    ["tes hantu kebal"] = Vector3.new(-80.350044, 101.991714, 1349.169922),
    ["post 1"] = Vector3.new(-533.194336, 150.434616, 2541.255615),
    ["Lokasi 1"] = Vector3.new(179.035660, 90.434616, 1171.101807),}

local savedPositions = {}
local autoCount = 1
local scriptFile = "skriphejo.lua"

-- Fungsi teleport
local function teleport(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
    end
end

--======================
--=== UI SETUP START ===
--======================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportManager"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 400)
MainFrame.Position = UDim2.new(0.05,0,0.5,-200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(70,70,80)
stroke.Thickness = 2
stroke.Transparency = 0.6

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1,0,0,35)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local function makeButton(parent, posX, color, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,30,0,30)
    btn.Position = UDim2.new(1, posX,0,2.5)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    return btn
end
local MinBtn   = makeButton(TopBar,-35, Color3.fromRGB(255,170,0), "_")
local MaxBtn   = makeButton(TopBar,-70, Color3.fromRGB(0,170,255), "⬜")
local CloseBtn = makeButton(TopBar,-105, Color3.fromRGB(200,0,0), "X")

local MinimizedBtn = Instance.new("TextButton")
MinimizedBtn.Size = UDim2.new(0,60,0,35)
MinimizedBtn.Position = UDim2.new(0,10,0.7,0)
MinimizedBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
MinimizedBtn.Text = "UI"
MinimizedBtn.TextColor3 = Color3.new(1,1,1)
MinimizedBtn.Font = Enum.Font.GothamBold
MinimizedBtn.TextSize = 16
MinimizedBtn.Visible = false
MinimizedBtn.Parent = ScreenGui
Instance.new("UICorner", MinimizedBtn).CornerRadius = UDim.new(0,8)

-- Dragging
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,
            startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Minimize/Maximize/Close
local originalSize, originalPos = MainFrame.Size, MainFrame.Position
local isMaximized = false
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinimizedBtn.Visible = true
end)
MinimizedBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinimizedBtn.Visible = false
end)
MaxBtn.MouseButton1Click:Connect(function()
    isMaximized = not isMaximized
    if isMaximized then
        MainFrame.Size = UDim2.new(1,-40,1,-40)
        MainFrame.Position = UDim2.new(0,20,0,20)
    else
        MainFrame.Size = originalSize
        MainFrame.Position = originalPos
    end
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Save Current Position Button
local AddBtn = Instance.new("TextButton")
AddBtn.Size = UDim2.new(1,-10,0,40)
AddBtn.Position = UDim2.new(0,5,0,40)
AddBtn.BackgroundColor3 = Color3.fromRGB(0,255,100)
AddBtn.Text = "Save Current Position"
AddBtn.TextColor3 = Color3.new(1,1,1)
AddBtn.Font = Enum.Font.GothamBold
AddBtn.TextSize = 16
AddBtn.Parent = MainFrame
Instance.new("UICorner", AddBtn).CornerRadius = UDim.new(0,8)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-10,1,-95)
scroll.Position = UDim2.new(0,5,0,85)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.Parent = MainFrame
local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0,6)

-- Refresh daftar posisi
local function refreshButtons()
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end
    end
    local function addTeleportButton(name, vec)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1,0,0,35)
        holder.BackgroundTransparency = 1
        holder.Parent = scroll
        local tbtn = Instance.new("TextButton")
        tbtn.Size = UDim2.new(0.7,0,1,0)
        tbtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
        tbtn.Text = name
        tbtn.TextColor3 = Color3.new(1,1,1)
        tbtn.Font = Enum.Font.Gotham
        tbtn.TextSize = 15
        tbtn.Parent = holder
        Instance.new("UICorner", tbtn).CornerRadius = UDim.new(0,8)
        tbtn.MouseButton1Click:Connect(function() teleport(vec) end)
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.25,0,1,0)
        delBtn.Position = UDim2.new(0.75,0,0,0)
        delBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
        delBtn.Text = "X"
        delBtn.TextColor3 = Color3.new(1,1,1)
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 15
        delBtn.Parent = holder
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0,8)
        delBtn.MouseButton1Click:Connect(function()
            savedPositions[name] = nil
            refreshButtons()
            saveToLuaFile()
        end)
    end
    for name, vec in pairs(positions) do addTeleportButton(name, vec) end
    for name, vec in pairs(savedPositions) do addTeleportButton(name, vec) end
    scroll.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y + 10)
end

-- Popup input
local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(0,200,0,80)
InputFrame.Position = UDim2.new(0.5,-100,0.5,-40)
InputFrame.BackgroundColor3 = Color3.fromRGB(40,40,50)
InputFrame.Visible = false
InputFrame.Parent = ScreenGui
Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0,12)

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1,-20,0,40)
TextBox.Position = UDim2.new(0,10,0,10)
TextBox.PlaceholderText = "Nama lokasi (opsional)"
TextBox.TextColor3 = Color3.new(1,1,1)
TextBox.ClearTextOnFocus = true
TextBox.Parent = InputFrame
Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0,8)

local SaveInputBtn = Instance.new("TextButton")
SaveInputBtn.Size = UDim2.new(1,-20,0,25)
SaveInputBtn.Position = UDim2.new(0,10,0,55)
SaveInputBtn.Text = "Simpan"
SaveInputBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
SaveInputBtn.TextColor3 = Color3.new(1,1,1)
SaveInputBtn.Font = Enum.Font.GothamBold
SaveInputBtn.TextSize = 14
SaveInputBtn.Parent = InputFrame
Instance.new("UICorner", SaveInputBtn).CornerRadius = UDim.new(0,8)

SaveInputBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local vec = char.HumanoidRootPart.Position
        local name = TextBox.Text
        if name == "" or name == nil then
            name = "Lokasi "..autoCount
            autoCount = autoCount + 1
        end
        savedPositions[name] = vec
        refreshButtons()
        saveToLuaFile()
    end
    InputFrame.Visible = false
    TextBox.Text = ""
end)

AddBtn.MouseButton1Click:Connect(function()
    InputFrame.Visible = true
    TextBox:CaptureFocus()
end)

-- pertama kali refresh biar tombol langsung muncul
refreshButtons()
