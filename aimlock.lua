-- Secure Aimlock for Shindo Life
-- Whitelist: huyu944 (Roblox UserId substituído)
-- Protects against basic detection, binds F7, shows status UI

-- Serviços
local uis    = game:GetService("UserInputService")
local rs     = game:GetService("RunService")
local players= game:GetService("Players")
local lp     = players.LocalPlayer
local cam    = workspace.CurrentCamera
local pg     = lp:WaitForChild("PlayerGui")

-- 🛡️ Whitelist
local whitelist = {
    [lp.UserId] = true,
}
if not whitelist[lp.UserId] then return end

-- Anti-detect flag
local flagged = false
local suspicious = {"mod","admin","staff","tester"}
for _, p in pairs(players:GetPlayers()) do
    if p~=lp then
        for _, w in ipairs(suspicious) do
            if string.find(p.Name:lower(),w) then flagged = true end
        end
    end
end
players.PlayerAdded:Connect(function(p)
    for _, w in ipairs(suspicious) do
        if string.find(p.Name:lower(),w) then flagged = true end
    end
end)
if flagged then return end

-- Quick UI
local gui = Instance.new("ScreenGui", pg)
gui.Name = "AimStatusUI"
local lbl = Instance.new("TextLabel", gui)
lbl.Size = UDim2.new(0,140,0,30)
lbl.Position = UDim2.new(0,10,0,80)
lbl.BackgroundTransparency = 0.5
lbl.BackgroundColor3 = Color3.fromRGB(20,20,20)
lbl.TextColor3 = Color3.fromRGB(255,0,0)
lbl.Font = Enum.Font.GothamBold
lbl.TextSize = 16
lbl.Text = "Aimlock: OFF"

-- Variáveis
local isOn = false
local target = nil
local key = Enum.KeyCode.F7

-- Função para encontrar alvo próximo da mira
local function getTarget()
    local best, bd = nil, math.huge
    local mpos = uis:GetMouseLocation()
    for _, p in pairs(players:GetPlayers()) do
        if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local sp, vis = cam:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
            if vis then
                local d = (Vector2.new(sp.X,sp.Y)-mpos).Magnitude
                if d < bd and d < 250 then best, bd = p, d end
            end
        end
    end
    return best
end

-- Mira suave + delays
rs.RenderStepped:Connect(function()
    if isOn and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local p = target.Character.HumanoidRootPart.Position
        local cf = CFrame.new(cam.CFrame.Position, p)
        cam.CFrame = cam.CFrame:Lerp(cf, 0.08 + math.random()*0.02)
    end
end)

-- Toggle via F7
uis.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == key then
        isOn = not isOn
        if isOn then
            target = getTarget()
            lbl.TextColor3 = Color3.fromRGB(0,255,0)
            lbl.Text = "Aimlock: ON"
        else
            target = nil
            lbl.TextColor3 = Color3.fromRGB(255,0,0)
            lbl.Text = "Aimlock: OFF"
        end
    end
end)
