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
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("BasePart") and (v.Name == "Ball" or v:GetAttribute("realBall")) then
            return v
        end
    end
    return nil
end

local function ShouldParry(Ball, HRP)
    if not Ball or not HRP then return false end
    local Distance = (HRP.Position - Ball.Position).Magnitude
    local Speed = Ball:FindFirstChild("zoomies") and Ball.zoomies.VectorVelocity.Magnitude or 0
    if Speed == 0 then return false end
    local PredictedPos = Ball.Position + Ball.zoomies.VectorVelocity * (Distance / Speed)
    local CurveFactor = (PredictedPos - Ball.Position).Magnitude > 0.3
    local IsTargeted = Ball:GetAttribute("target") == LocalPlayer.Name or Distance < 15
    if IsTargeted and Distance / Speed <= 0.65 then
        return CurveFactor and Distance / Speed <= 0.55 or true
    end
    return false
end

local function AutoParry()
    if not AutoParryEnabled then return end
    Ball = GetBall()
    local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Ball or not HRP then return end
    if ShouldParry(Ball, HRP) and not Parried and tick() - Cooldown >= 0.35 then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.01)
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
    if Distance < 7 and tick() - Cooldown >= 0.07 then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        Cooldown = tick()
    end
end

workspace.ChildAdded:Connect(function(child)
    if child:IsA("BasePart") and (child.Name == "Ball" or child:GetAttribute("realBall")) then
        Ball = child
        Parried = false
        if child:GetAttributeChangedSignal("target") then
            child:GetAttributeChangedSignal("target"):Connect(function()
                Parried = false
            end)
        end
    end
end)

local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Toggles")

Section:NewToggle("Auto Parry", "Rebate a bola automaticamente", function(state)
    AutoParryEnabled = state
    Library:Notify(state and "Auto Parry Ativado" or "Auto Parry Desativado")
end)

Section:NewToggle("Auto Spam", "Spamma parry quando a bola tá perto", function(state)
    AutoSpamEnabled = state
    Library:Notify(state and "Auto Spam Ativado" or "Auto Spam Desativado")
end)

RunService.Heartbeat:Connect(function()
    AutoParry()
    AutoSpam()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
end)
