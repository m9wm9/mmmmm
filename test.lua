local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Whitelist: Only allow specific UserIds to run the script
local whitelist = {
    [42024922] = true, -- << Replace this with YOUR UserId
    [7869193949] = true, -- << Replace this with "anyes" UserId if known
}

if not whitelist[LocalPlayer.UserId] then
    LocalPlayer:Kick("your not whitelisted nigger")
    return
end

local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OrbitUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 400)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(160, 64, 255)
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 100, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local TabList = Instance.new("UIListLayout", Sidebar)
TabList.FillDirection = Enum.FillDirection.Vertical
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 5)

-- Page Container
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 100, 0, 0)
PageContainer.Size = UDim2.new(1, -100, 1, 0)
PageContainer.BackgroundTransparency = 1

-- Tab logic
local Pages = {}
local function createTab(name)
	local btn = Instance.new("TextButton", Sidebar)
	btn.Size = UDim2.new(1, -10, 0, 40)
	btn.Text = name
	btn.Font = Enum.Font.SourceSansBold
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.BorderSizePixel = 0

	local page = Instance.new("Frame", PageContainer)
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false

	local layout = Instance.new("UIListLayout", page)
	layout.Padding = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(Pages) do p.Visible = false end
		page.Visible = true
	end)

	table.insert(Pages, page)
	return page
end

-- UI Components
local function createLabel(text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -10, 0, 20)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.Font = Enum.Font.SourceSans
	lbl.TextSize = 16
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	return lbl
end

local function createTextBox(placeholder)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -10, 0, 25)
	box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.PlaceholderText = placeholder
	box.Font = Enum.Font.SourceSans
	box.TextSize = 16
	box.BorderSizePixel = 0
	return box
end

local function createSlider(labelText, minVal, maxVal, default)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -10, 0, 40)
	container.BackgroundTransparency = 1

	local label = createLabel(labelText .. ": " .. default)
	label.Parent = container

	local sliderBar = Instance.new("Frame")
	sliderBar.Size = UDim2.new(1, 0, 0, 8)
	sliderBar.Position = UDim2.new(0, 0, 1, -10)
	sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	sliderBar.BorderSizePixel = 0
	sliderBar.Parent = container

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 10, 1, 0)
	knob.Position = UDim2.new((default - minVal) / (maxVal - minVal), 0, 0, 0)
	knob.BackgroundColor3 = Color3.fromRGB(160, 64, 255)
	knob.BorderSizePixel = 0
	knob.Parent = sliderBar

	local dragging = false
	local value = default

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local posX = sliderBar.AbsolutePosition.X
			local width = sliderBar.AbsoluteSize.X
			local rel = math.clamp((input.Position.X - posX) / width, 0, 1)
			knob.Position = UDim2.new(rel, 0, 0, 0)
			value = math.round((minVal + (maxVal - minVal) * rel) * 100) / 100
			label.Text = labelText .. ": " .. value
		end
	end)

	return container, function() return value end
end

-- Target tab
local targetPage = createTab("Target")

local displayBox = createTextBox("Target Display Name")
displayBox.Parent = targetPage

local usernameBox = createTextBox("Target Username")
usernameBox.Parent = targetPage

local speedSlider, getSpeed = createSlider("Speed", 1, 50, 10)
speedSlider.Parent = targetPage
local radiusSlider, getRadius = createSlider("Radius", 1, 20, 5)
radiusSlider.Parent = targetPage
local predictionSlider, getPrediction = createSlider("Prediction", 0, 0.19, 0.1)
predictionSlider.Parent = targetPage

local startBtn = Instance.new("TextButton", targetPage)
startBtn.Size = UDim2.new(1, -10, 0, 30)
startBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 100)
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.Text = "Start Orbit"
startBtn.Font = Enum.Font.SourceSansBold
startBtn.TextSize = 16
startBtn.BorderSizePixel = 0

local stopBtn = Instance.new("TextButton", targetPage)
stopBtn.Size = UDim2.new(1, -10, 0, 30)
stopBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 60)
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.Text = "Stop Orbit"
stopBtn.Font = Enum.Font.SourceSansBold
stopBtn.TextSize = 16
stopBtn.BorderSizePixel = 0

-- Settings tab
local settingsPage = createTab("Settings")
local note = createLabel("autoshoot is V")
note.Parent = settingsPage

-- Orbit logic
local orbiting = false
local orbitConn

startBtn.MouseButton1Click:Connect(function()
	local target
	for _, p in ipairs(Players:GetPlayers()) do
		if p.DisplayName == displayBox.Text or p.Name == usernameBox.Text then
			target = p
			break
		end
	end

	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local tRoot = target.Character.HumanoidRootPart
		local angle = 0
		orbiting = true

		getgenv().Locked = true
		getgenv().AimlockState = true
		getgenv().Victim = target

		orbitConn = RunService.Heartbeat:Connect(function(dt)
			if not orbiting or not target.Character then return end
			local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
			if not tRoot then return end

			local radius = getRadius()
			local speed = getSpeed()
			angle += speed * dt

			local x = math.cos(angle) * radius
			local z = math.sin(angle) * radius
			LocalPlayer.Character.HumanoidRootPart.CFrame = tRoot.CFrame * CFrame.new(x, 0, z)
		end)
	end
end)

stopBtn.MouseButton1Click:Connect(function()
	orbiting = false
	if orbitConn then orbitConn:Disconnect() orbitConn = nil end
	getgenv().Locked = false
	getgenv().AimlockState = false
	getgenv().Victim = nil
end)

Pages[1].Visible = true

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.End then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)

RunService.RenderStepped:Connect(function()
	if getgenv().Locked and getgenv().Victim and getgenv().Victim.Character then
		local hrp = getgenv().Victim.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local cam = workspace.CurrentCamera
			local prediction = getPrediction()
			cam.CFrame = CFrame.new(cam.CFrame.Position, hrp.Position + hrp.Velocity * prediction)
		end
	end
end)

-- Auto Shoot Toggle (V key)
local autoShoot = false
local autoShootStatus = createLabel("Auto Shoot: OFF")
autoShootStatus.Parent = settingsPage

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.V then
		autoShoot = not autoShoot
		autoShootStatus.Text = "Auto Shoot: " .. (autoShoot and "ON" or "OFF")
	end
end)

-- Simulate click at center of screen
task.spawn(function()
	while true do
		task.wait(0.09)
		if autoShoot then
			local viewportSize = workspace.CurrentCamera.ViewportSize
			local x = viewportSize.X / 2
			local y = viewportSize.Y / 2
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
		end
	end
end)

local function pressR()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
end

task.spawn(function()
    while true do
        task.wait(0.3)
        local char = LocalPlayer.Character
        if char then
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    local ammo = item:FindFirstChild("Ammo")
                    local maxAmmo = item:FindFirstChild("MaxAmmo")
                    if ammo and maxAmmo then
                        -- print("Ammo:", ammo.Value, "/", maxAmmo.Value)
                        if ammo.Value == 0 then
                            pressR()
                        end
                    end
                end
            end
        end
    end
end)
