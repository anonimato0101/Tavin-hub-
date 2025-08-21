local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Death Ball Hub", "DarkTheme")

local AutoParryEnabled = false
local AutoSpamEnabled = false
local Parried = false
local Cooldown = 0
local Ball = nil

local function GetBall()
    for _, v in ipairs(workspace.Balls:GetChildren()) do
        if v:GetAttribute("realBall") then
            return v
        end
    end
    return nil
end

local function ShouldParry(Ball, HRP)
    if not Ball or not HRP then return false end
    local Distance = (HRP.Position - Ball.Position).Magnitude
    local Speed = Ball.zoomies.VectorVelocity.Magnitude
    local Direction = Ball.zoomies.VectorVelocity.Unit
    local RelativePos = Ball.Position - HRP.Position
    local PredictedPos = Ball.Position + Ball.zoomies.VectorVelocity * (Distance / Speed)
    local CurveFactor = (PredictedPos - Ball.Position).Magnitude > 0.5 and true or false
    if Ball:GetAttribute("target") == LocalPlayer.Name and Distance / Speed <= 0.55 then
        if CurveFactor then
            return Distance / Speed <= 0.45
        else
            return true
        end
    end
    return false
end

local function AutoParry()
    if not AutoParryEnabled then return end
    Ball = GetBall()
    local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Ball or not HRP then return end
    if ShouldParry(Ball, HRP) and not Parried and tick() - Cooldown >= 0.5 then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        Parried = true
        Cooldown = tick()
    elseif not ShouldParry(Ball, HRP) then
        Parried = false
    end
end

local function AutoSpam()
    if not AutoSpamEnabled then return end
    Ball = GetBall()
    local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Ball or not HRP then return end
    local Distance = (HRP.Position - Ball.Position).Magnitude
    if Distance < 10 and tick() - Cooldown >= 0.1 then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        Cooldown = tick()
    end
end

workspace.Balls.ChildAdded:Connect(function()
    Ball = GetBall()
    if Ball then
        Parried = false
        Ball:GetAttributeChangedSignal("target"):Connect(function()
            Parried = false
        end)
    end
end)

local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Toggles")

Section:NewToggle("Auto Parry", "Automatically parry the ball", function(state)
    AutoParryEnabled = state
    Library:Notify(state and "Auto Parry Enabled" or "Auto Parry Disabled")
end)

Section:NewToggle("Auto Spam", "Spam parry when ball is close", function(state)
    AutoSpamEnabled = state
    Library:Notify(state and "Auto Spam Enabled" or "Auto Spam Disabled")
end)

RunService.PreSimulation:Connect(function()
    AutoParry()
    AutoSpam()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
end)
```​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​​
