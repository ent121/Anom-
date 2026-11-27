--[[
    ANOMY TECH • WindUI + Real Key System
    Ключи хранятся в GitHub: https://raw.githubusercontent.com/ТВОЙ_НИК/Anom-/main/keys.txt
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- ==================== 1. КОНФИГУРАЦИЯ ====================
local KEYS_URL = "https://raw.githubusercontent.com/ТВОЙ_НИК/Anom-/main/keys.txt" -- ЗАМЕНИ НА СВОЙ РЕПОЗИТОРИЙ
local VALID_KEYS = {} -- Сюда загрузятся ключи с GitHub
local IsUnlocked = false

-- ==================== 2. РЕАЛЬНАЯ ПРОВЕРКА КЛЮЧА ====================
local function LoadKeysFromGitHub()
    local success, result = pcall(function()
        return game:HttpGet(KEYS_URL)
    end)
    
    if success and result then
        -- Разбиваем текст на строки и убираем пустые
        for key in string.gmatch(result, "[^\r\n]+") do
            local cleanKey = string.gsub(key, "%s+", "") -- Убираем пробелы
            if #cleanKey > 0 then
                VALID_KEYS[cleanKey] = true
            end
        end
        return true
    else
        warn("[Anomy] Не удалось загрузить список ключей с GitHub.")
        return false
    end
end

local function CheckKey(inputKey)
    if not inputKey or #inputKey < 5 then return false end
    local cleanInput = string.gsub(inputKey, "%s+", "")
    return VALID_KEYS[cleanInput] == true
end

-- ==================== 3. ЗАГРУЗКА WINDUI ====================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Anomy Tech",
    Author = "by Anomy",
    Folder = "AnomyTech",
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark",
    HideSearchBar = true,
    Transparent = true,
    KeySystem = false, -- Отключаем встроенную систему, так как делаем свою
    OpenButton = {
        Title = "Anomy",
        Enabled = true,
        Draggable = true,
        CornerRadius = UDim.new(1, 0),
        Color = ColorSequence.new(Color3.fromHex("#8A2BE2"), Color3.fromHex("#4B0082")),
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

-- ==================== 4. ОКНО ВВОДА КЛЮЧА ====================
local KeyTab = Window:Tab({ Title = "Authentication", Icon = "key" })

KeyTab:Paragraph({
    Title = "Введите ключ доступа",
    Desc = "Ключ можно получить на нашем сайте. Формат: ANX-XXXX-XXXX-XXXX",
    Color = "White",
})

local KeyInput = KeyTab:Input({
    Title = "Ключ",
    Value = "",
    Placeholder = "ANX-XXXX-XXXX-XXXX",
    Callback = function(text)
        -- Просто сохраняем введённый текст
    end,
})

local StatusLabel = KeyTab:Paragraph({
    Title = "Статус",
    Desc = "Ожидание проверки...",
    Color = "Gray",
})

KeyTab:Button({
    Title = "Проверить ключ",
    Callback = function()
        local enteredKey = KeyInput.Value
        
        -- Сначала загружаем ключи с GitHub (если ещё не загружены)
        if not next(VALID_KEYS) then
            StatusLabel:Set("Статус", "Загрузка базы ключей...", "Yellow")
            local loaded = LoadKeysFromGitHub()
            if not loaded then
                StatusLabel:Set("Статус", "Ошибка загрузки ключей. Проверьте интернет.", "Red")
                return
            end
        end
        
        -- Проверяем ключ
        if CheckKey(enteredKey) then
            StatusLabel:Set("Статус", "✅ Ключ верный! Загрузка меню...", "Green")
            task.wait(1)
            IsUnlocked = true
            Window:Destroy() -- Закрываем окно авторизации
            LoadMainMenu() -- Загружаем основной функционал
        else
            StatusLabel:Set("Статус", "❌ Неверный ключ. Попробуйте снова.", "Red")
        end
    end,
})

-- ==================== 5. ОСНОВНОЙ ФУНКЦИОНАЛ (ПОСЛЕ АВТОРИЗАЦИИ) ====================
function LoadMainMenu()
    if not IsUnlocked then return end

    local Config = {
        Enabled = false,
        SnapDelay = 0.25,
        LaunchPower = 800,
        Visuals = true,
    }

    -- Создаём новое окно для чита
    local CheatWindow = WindUI:CreateWindow({
        Title = "Anomy Tech | Combat",
        Author = "by Anomy",
        Folder = "AnomyTech",
        Size = UDim2.fromOffset(480, 350),
        Theme = "Dark",
        HideSearchBar = true,
        Transparent = true,
        KeySystem = false,
        OpenButton = {
            Title = "Anomy",
            Enabled = true,
            Draggable = true,
            CornerRadius = UDim.new(1, 0),
            Color = ColorSequence.new(Color3.fromHex("#8A2BE2"), Color3.fromHex("#4B0082")),
        },
    })

    local CombatTab = CheatWindow:Tab({ Title = "Combat", Icon = "swords" })

    CombatTab:Toggle({
        Title = "Enable Anomy Tech",
        Desc = "Автоматическое притягивание и запуск врага",
        Default = false,
        Callback = function(state)
            Config.Enabled = state
        end,
    })

    CombatTab:Slider({
        Title = "Snap Delay",
        Desc = "Задержка перед срабатыванием (настрой под пинг)",
        Step = 0.01,
        Width = 200,
        Value = { Min = 0.05, Max = 0.8, Default = 0.25 },
        Callback = function(val)
            Config.SnapDelay = val
        end,
    })

    CombatTab:Slider({
        Title = "Launch Power",
        Desc = "Сила, с которой враг улетает в небо",
        Step = 10,
        Width = 200,
        Value = { Min = 100, Max = 2000, Default = 800 },
        Callback = function(val)
            Config.LaunchPower = val
        end,
    })

    CombatTab:Toggle({
        Title = "Visual Effects",
        Desc = "Взрыв и след за врагом",
        Default = true,
        Callback = function(state)
            Config.Visuals = state
        end,
    })

    -- ==================== ЛОГИКА ЧИТА (ИЗ DECODED.LUA) ====================
    local Character, Humanoid, HRP
    local TriggerAnims = {
        ["10479335397"] = true,
        ["13380255751"] = true,
    }
    local AlignPos, AlignOrient, Part, Conn

    local function CreateVisuals(targetModel)
        if not Config.Visuals or not targetModel then return end
        local targetHRP = targetModel:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end

        local highlight = Instance.new("Highlight")
        highlight.Parent = targetModel
        highlight.FillColor = Color3.fromRGB(150, 0, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5

        task.delay(2, function()
            if highlight then highlight:Destroy() end
        end)
    end

    local function Cleanup()
        if AlignPos then AlignPos:Destroy() end
        if AlignOrient then AlignOrient:Destroy() end
        if Part then Part:Destroy() end
        if Conn then Conn:Disconnect() end
        
        if HRP then
            for _, v in ipairs(HRP:GetChildren()) do
                if v:IsA("Attachment") or v.Name == "HasSnapped" then
                    v:Destroy()
                end
            end
        end
    end

    local function GetTarget()
        local closest = nil
        local minDist = 30
        if not Character or not HRP then return nil end
        
        for _, v in pairs(workspace.Live:GetChildren()) do
            if v:IsA("Model") and v ~= Character then
                local eHRP = v:FindFirstChild("HumanoidRootPart")
                local eHum = v:FindFirstChildOfClass("Humanoid")
                if eHRP and eHum and eHum.Health > 0 then
                    local dist = (eHRP.Position - HRP.Position).Magnitude
                    if dist <= minDist then
                        if v.Name == "Weakest Dummy" or Players:GetPlayerFromCharacter(v) then
                            closest = v
                            minDist = dist
                        end
                    end
                end
            end
        end
        return closest
    end

    local function ExecuteAnomyTech(targetModel)
        Cleanup()
        if not targetModel or not targetModel.Parent then return end
        local targetHRP = targetModel:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end
        
        CreateVisuals(targetModel)

        Part = Instance.new("Part")
        Part.Size = Vector3.new(0.5, 0.5, 0.5)
        Part.Transparency = 1
        Part.Anchored = true
        Part.CanCollide = false
        Part.Parent = workspace
        
        local a0 = Instance.new("Attachment", HRP)
        local a1 = Instance.new("Attachment", Part)
        local a2 = Instance.new("Attachment", HRP)
        local a3 = Instance.new("Attachment", Part)
        
        AlignPos = Instance.new("AlignPosition")
        AlignPos.Attachment0 = a0
        AlignPos.Attachment1 = a1
        AlignPos.RigidityEnabled = true
        AlignPos.Responsiveness = 200
        AlignPos.MaxForce = math.huge
        AlignPos.Parent = HRP
        
        AlignOrient = Instance.new("AlignOrientation")
        AlignOrient.Attachment0 = a2
        AlignOrient.Attachment1 = a3
        AlignOrient.RigidityEnabled = true
        AlignOrient.Responsiveness = 100
        AlignOrient.MaxTorque = math.huge
        AlignOrient.Parent = HRP
        
        Conn = RunService.RenderStepped:Connect(function()
            if targetHRP and targetHRP.Parent then
                local snapCF = targetHRP.CFrame * CFrame.Angles(math.rad(55), 0, 0)
                Part.CFrame = snapCF
                if not HRP:FindFirstChild("HasSnapped") then
                    HRP.CFrame = snapCF
                    local bv = Instance.new("BoolValue")
                    bv.Name = "HasSnapped"
                    bv.Parent = HRP
                end
            end
        end)
        
        task.delay(0.1, function()
            if targetHRP and targetHRP.Parent then
                for i = 1, 3 do
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new())
                        task.wait(0.05)
                        VirtualUser:Button1Up(Vector2.new())
                    end)
                end

                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, Config.LaunchPower, -Config.LaunchPower / 2)
                bv.Parent = targetHRP
                
                task.delay(2, function()
                    if bv then bv:Destroy() end
                end)
            end
        end)
        
        task.delay(0.6, Cleanup)
    end

    local function OnAnimationPlayed(animTrack)
        if not Config.Enabled then return end
        local animId = string.match(animTrack.Animation.AnimationId, "%d+")
        
        if TriggerAnims[animId] then
            task.delay(Config.SnapDelay, function()
                pcall(function()
                    if Character and Character:FindFirstChild("Communicate") then
                        Character.Communicate:FireServer(unpack({
                            { Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress" }
                        }))
                    end
                end)
                
                local target = GetTarget()
                if target then
                    ExecuteAnomyTech(target)
                end
            end)
        end
    end

    local function SetupCharacter()
        Character = LP.Character or LP.CharacterAdded:Wait()
        Humanoid = Character:WaitForChild("Humanoid")
        HRP = Character:WaitForChild("HumanoidRootPart")
        Humanoid.AnimationPlayed:Connect(OnAnimationPlayed)
    end

    SetupCharacter()
    LP.CharacterAdded:Connect(function()
        task.wait(1)
        SetupCharacter()
    end)
end
