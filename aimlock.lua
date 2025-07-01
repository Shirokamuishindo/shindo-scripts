-- Aimlock Seguro - carregado via GitHub
-- Protegido com whitelist

local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local players = game:GetService("Players")
local lp = players.LocalPlayer
local camera = workspace.CurrentCamera
local pg = lp:WaitForChild("PlayerGui")

-- Whitelist: adicione seu UserId (números sem aspas)
local whitelist = {
    [12345678] = true,
}

if not whitelist[lp.UserId] then
    warn("Usuário não autorizado.")
    return
end

-- Detecção simples de staff/admin
local suspicious = {"mod", "admin", "staff", "tester"}
for _, p in pairs(players:GetPlayers()) do
    for _, w in ipairs(suspicious) do
        if p ~= lp and string.find(p.Name:lower(), w) then
            warn("Admin detectado: "..p.Name)
            return
        end
    end
end
players.PlayerAdded:Connect(function(p)
    for _, w in ipairs(suspicious) do
        if string.find(p.Name:lower(), w) then
            warn("Admin entrou: "..p.Name)
            return
        end
    end
end)

-- Interface discreta
local gui = Instance.new("ScreenGui", pg)
gui.Name = "sUI"
local label = Instance.new("TextLabel", gui)
label.Size = UDim2.new(0,160,0,35)
label.Position = UDim2.new(0,15,0,100)
label.BackgroundTransparency = 0.5
label.BackgroundColor3 = Color3.fromRGB(25,25,25)
label.Text = "Aimlock: OFF"
label.TextColor3 = Color3.new(1,0,0)
label.Font = Enum.Font.GothamBold
label.TextSize = 16

-- Variáveis de controle
local isOn = false
local target = nil
local toggleKey = Enum.KeyCode.F7

-- Função para buscar alvo
local function getClosestTarget()
    local best, bestD = nil, math.huge
    local mpos = uis:GetMouseLocation()
    for _, p in pairs(players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos = p.Character.HumanoidRootPart.Position
            local sp, vis = camera:WorldToScreenPoint(pos)
            if vis then
                local d = (Vector2.new(sp.X,sp.Y) - mpos).Magnitude
                if d < bestD and d < 250 then
                    best, bestD = p, d
                end
            end
        end
    end
    return best
end

-- Atualização da mira
rs.RenderStepped:Connect(function()
    if isOn and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local pos = target.Character.HumanoidRootPart.Position
        local newC = CFrame.new(camera.CFrame.Position, pos)
        camera.CFrame = camera.CFrame:Lerp(newC, 0.08 + math.random()*0.02)
    end
end)

-- Handler de tecla
uis.InputBegan:Connect(function(inp, processed)
    if processed then return end
    if inp.KeyCode == toggleKey then
        isOn = not isOn
        if isOn then
            target = getClosestTarget()
            label.Text = "Aimlock: ON"
            label.TextColor3 = Color3.new(0,1,0)
        else
            target = nil
            label.Text = "Aimlock: OFF"
            label.TextColor3 = Color3.new(1,0,0)
        end
    end
end)
