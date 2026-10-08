if not getgenv().DyckLobby then

    repeat task.wait() until game:IsLoaded()
    repeat task.wait() until game:GetService("Players").LocalPlayer

    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
    local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
    local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
    local FlyModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/GeorgeRoblox/LINDOR/refs/heads/main/addonsfolder/Fly.lua"))()
    local Environments = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/Abysall/refs/heads/main/Components/Environment.luau"))()

    local Functions = {}
    local Connections = {}
    local Globals = {}

    local Services = setmetatable({}, {
        __index = function(self, Key)
            return game:GetService(Key)
        end
    })

    local Player = Services.Players.LocalPlayer
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChild("Humanoid")

    -- AGUARDA PERSONAGEM E HUMANOID
    while not Character or not Humanoid do
        task.wait()
        Character = Player.Character
        Humanoid = Character and Character:FindFirstChild("Humanoid")
    end

    local RemotesFolder
    if Services.ReplicatedStorage:FindFirstChild("RemotesFolder") then
        RemotesFolder = Services.ReplicatedStorage:FindFirstChild("RemotesFolder")
    elseif Services.ReplicatedStorage:FindFirstChild("EntityInfo") then
        RemotesFolder = Services.ReplicatedStorage:FindFirstChild("EntityInfo")
    elseif Services.ReplicatedStorage:FindFirstChild("Bricks") then
        RemotesFolder = Services.ReplicatedStorage:FindFirstChild("Bricks")
    end

    if not RemotesFolder then
        warn("[Dyck Lobby] RemotesFolder não encontrado. Algumas features podem falhar.")
        RemotesFolder = Services.ReplicatedStorage
    end

    local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/ESPLibrary/refs/heads/main/Library.lua"))()
    ESPLibrary:SetRainbow(false)
    ESPLibrary:SetShowDistance(false)
    ESPLibrary:SetFillTransparency(0.75)
    ESPLibrary:SetOutlineTransparency(0)
    ESPLibrary:SetFadeTime(0.25)
    ESPLibrary:SetTextSize(18)
    ESPLibrary:SetFont(Enum.Font.RobotoCondensed)
    ESPLibrary:SetTracers(false)
    ESPLibrary:SetTracerSize(0.75)
    ESPLibrary:SetTracerOrigin("Bottom")
    ESPLibrary:SetArrows(false)
    ESPLibrary:SetArrowRadius(250)
    ESPLibrary:SetDistanceSizeRatio(0.8)

    local Options = Library.Options
    local Toggles = Library.Toggles

    local Window = Library:CreateWindow({
        Title = "Dyck Menu | Doors Lobby",
        Center = true,
        AutoShow = true,
        Resizable = true,
        ShowCustomCursor = true,
        UnlockMouseWhileOpen = true,
        NotifySide = "Right",
        TabPadding = 8,
        MenuFadeTime = 0.2
    })

    local Tabs = {
        Info = Window:AddTab("Info"),
        Main = Window:AddTab("General"),
        ["UI Settings"] = Window:AddTab("UI Settings"),
    }

    getgenv().DyckLobby = true

    local infTab = Tabs.Info:AddLeftTabbox()
    local inffirsttab = infTab:AddTab('Update Log')
    inffirsttab:AddLabel("\n<DOORS LOBBY>")
    inffirsttab:AddLabel("<font color='#1eff00'>+ Auto Join Elevator</font>")
    inffirsttab:AddLabel("<font color='#1eff00'>+ Redeem All Codes</font>")
    inffirsttab:AddLabel("<font color='#1eff00'>+ Cycle Achievements</font>")

    local mntab = Tabs.Main:AddLeftTabbox()
    local mainft = mntab:AddTab('LocalPlayer')
    local mntab2 = Tabs.Main:AddLeftTabbox()
    local mainrg = mntab2:AddTab('Game')

    -- LÓGICA DE ELEVATOR
    Functions.CheckElevators = function()
        if not Toggles.AutoJoinElevator.Value then return end
        if not RemotesFolder:FindFirstChild("ElevatorJoin") then return end

        local TargetCharacter
        local targetOption = Options.AutoJoinElevatorTarget and Options.AutoJoinElevatorTarget.Value
        if typeof(targetOption) == "Instance" then
            TargetCharacter = targetOption.Character
        elseif typeof(targetOption) == "string" then
            local targetPlayer = Services.Players:FindFirstChild(targetOption)
            TargetCharacter = targetPlayer and targetPlayer.Character
        end

        local elevators = Services.Workspace:FindFirstChild("Lobby")
        if not elevators then return end
        local lobbyElevators = elevators:FindFirstChild("LobbyElevators")
        if not lobbyElevators then return end

        local TargetFound = false
        for _, Elevator in pairs(lobbyElevators:GetChildren()) do
            if TargetCharacter and TargetCharacter:GetAttribute("InGameElevator") and Elevator:GetAttribute("ID") then
                if Elevator:GetAttribute("ID") == TargetCharacter:GetAttribute("InGameElevator") then
                    TargetFound = true
                    RemotesFolder.ElevatorJoin:FireServer(Elevator)
                    break
                end
            end
        end

        if not TargetFound and RemotesFolder:FindFirstChild("ElevatorExit") then
            RemotesFolder.ElevatorExit:FireServer()
        end
    end

    -- LÓGICA DE CÓDIGOS
    Globals.RedeemingCodes = false
    Globals.CodesList = {
        "67", "54", "41", "CHEDDAR BALLS", "XQC", "PENGUINZ0",
        "KREEKCRAFT", "ISHOWSPEED", "DANTDM", "KUBZ SCOUTS",
        "FIND THE TROLLFACES", "THINKNOODLES", "W", "RAGDOLL UNIVERSE",
        "RAGDOLL MAYHEM", "BIJUU MIKE", "8BITRYAN", "SCREECHSUCKS",
        "LORE", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "3rd", "LAZYDEVS",
        "RAGDOLL COMBAT", "VOCAB HAVOC", "PATHSWAP", "JUMP OVER THE BRICK"
    }

    mainrg:AddToggle("AutoJoinElevator", {
        Text = "Auto Join Elevator",
        Default = false,
        Tooltip = "Automatically joins the selected player's elevator."
    })
    mainrg:AddDropdown("AutoJoinElevatorTarget", {
        Text = "Target",
        SpecialType = "Player",
        ExcludeLocalPlayer = true,
        Searchable = true
    })

    mainrg:AddDivider()
    mainrg:AddToggle("CycleAchievements", {
        Text = "Cycle Achievements",
        Default = false,
        Tooltip = "Rapidly equips a random badge."
    })
    mainrg:AddSlider("CycleAchievementsDelay", {
        Text = "Cycle Delay",
        Min = 0,
        Max = 1,
        Default = 0.1,
        Rounding = 2,
        Compact = true
    })

    mainrg:AddDivider()
    mainrg:AddButton("Redeem All Codes", function()
        if Globals.RedeemingCodes then return end
        Globals.RedeemingCodes = true
        Library:Notify("<b>[Dyck]</b> Iniciando resgate de códigos...")
        for _, Code in pairs(Globals.CodesList) do
            if RemotesFolder:FindFirstChild("ShopCode") then
                RemotesFolder.ShopCode:FireServer(Code)
            end
            task.wait(5.1)
        end
        Globals.RedeemingCodes = false
        Library:Notify("<b>[Dyck]</b> Códigos resgatados!")
    end)

    -- LÓGICA DE CONQUISTAS (SEGURA)
    Globals.UnlockedBadges = {}
    Globals.LastBadgeChange = tick()
    local PreviousBadge = nil

    local function ScanBadges()
        local gui = Player:FindFirstChild("PlayerGui")
        local mainUI = gui and gui:FindFirstChild("MainUI")
        local lobbyFrame = mainUI and mainUI:FindFirstChild("LobbyFrame")
        local achievements = lobbyFrame and lobbyFrame:FindFirstChild("Achievements")
        local list = achievements and achievements:FindFirstChild("List")
        
        if not list then return end

        for _, Frame in pairs(list:GetChildren()) do
            if Frame:IsA("ImageButton") and Frame.ImageTransparency == 0 then
                table.insert(Globals.UnlockedBadges, Frame.Name)
            end
        end
    end

    -- Aguarda a UI carregar e varre
    task.spawn(function()
        while true do
            task.wait(1)
            ScanBadges()
            if #Globals.UnlockedBadges > 0 then break end
        end
    end)

    local ConnectionBadgeAdded
    local function HookBadgeConnection()
        local gui = Player:FindFirstChild("PlayerGui")
        local mainUI = gui and gui:FindFirstChild("MainUI")
        local lobbyFrame = mainUI and mainUI:FindFirstChild("LobbyFrame")
        local achievements = lobbyFrame and lobbyFrame:FindFirstChild("Achievements")
        local list = achievements and achievements:FindFirstChild("List")
        
        if list and not ConnectionBadgeAdded then
            ConnectionBadgeAdded = list.ChildAdded:Connect(function(Frame)
                Services.RunService.Heartbeat:Wait()
                if Frame:IsA("ImageButton") and Frame.ImageTransparency == 0 then
                    table.insert(Globals.UnlockedBadges, Frame.Name)
                end
            end)
        end
    end
    task.spawn(function()
        while true do
            task.wait(1)
            HookBadgeConnection()
            if ConnectionBadgeAdded then break end
        end
    end)

    Connections.MainConnection = Services.RunService.Heartbeat:Connect(function()
        local LastElevatorCheck = Globals.LastElevatorCheck or 0
        if tick() - LastElevatorCheck > 0.25 then
            Functions.CheckElevators()
            Globals.LastElevatorCheck = tick()
        end

        if Toggles.CycleAchievements.Value and tick() - Globals.LastBadgeChange > Options.CycleAchievementsDelay.Value then
            if #Globals.UnlockedBadges == 0 then return end
            
            local Badge = Globals.UnlockedBadges[math.random(1, #Globals.UnlockedBadges)]
            if Badge == PreviousBadge then
                local NewBadge = Badge
                while NewBadge == PreviousBadge do
                    NewBadge = Globals.UnlockedBadges[math.random(1, #Globals.UnlockedBadges)]
                    task.wait()
                end
                Badge = NewBadge
            end

            -- Esconde estrelas de outras
            local gui = Player:FindFirstChild("PlayerGui")
            local mainUI = gui and gui:FindFirstChild("MainUI")
            local lobbyFrame = mainUI and mainUI:FindFirstChild("LobbyFrame")
            local achievements = lobbyFrame and lobbyFrame:FindFirstChild("Achievements")
            local list = achievements and achievements:FindFirstChild("List")
            
            if list then
                for _, Frame in pairs(list:GetChildren()) do
                    if Frame:IsA("ImageButton") and Frame.ImageTransparency == 0 then
                        local icons = Frame:FindFirstChild("Icons")
                        if icons then
                            local star = icons:FindFirstChild("Star")
                            if star then star.Visible = (Frame.Name == Badge) end
                        end
                    end
                end
            end

            if RemotesFolder:FindFirstChild("FlexAchievement") then
                RemotesFolder.FlexAchievement:FireServer(Badge)
            end
            PreviousBadge = Badge
            Globals.LastBadgeChange = tick()
        end
    end)

    -- WALK SPEED
    WSConnection = {}
    CurrentWS = 16
    WS_Enabled = false

    local function ApplyWalkSpeed()
        if not Character or not Humanoid then return end
        Humanoid.WalkSpeed = WS_Enabled and CurrentWS or 16
    end

    local function HookCharacter(char)
        Character = char
        Humanoid = char:WaitForChild("Humanoid")
        ApplyWalkSpeed()
    end

    if Player.Character then
        HookCharacter(Player.Character)
    end
    Player.CharacterAdded:Connect(HookCharacter)

    mainft:AddSlider("WSSLIDER", {
        Text = "Walk Speed",
        Default = 16,
        Min = 16,
        Max = 85,
        Rounding = 0,
        Compact = true,
        Callback = function(v)
            CurrentWS = v
            ApplyWalkSpeed()
        end
    })
    mainft:AddToggle("EnableWS", {
        Text = "Enable Walk Speed",
        Default = false,
        Callback = function(state)
            WS_Enabled = state
            ApplyWalkSpeed()
        end
    })

    -- UI SETTINGS
    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
    Library.KeybindFrame.Visible = true
    _G.ShowKeybind = false
    _G.ShowCustomCursor = true

    MenuGroup:AddToggle('ShowKeybind', { 
        Text = 'Show Keybind',
        Default = true,
        Callback = function(ShowKbs)
            _G.ShowKeybind = ShowKbs
            if _G.ShowKeybind == false then
                Library.KeybindFrame.Visible = false
            else
                Library.KeybindFrame.Visible = true
            end
        end
    })

    MenuGroup:AddToggle('ShowCustomCursor', { 
        Text = 'Show CustomCursor',
        Default = _G.ShowCustomCursor,
        Callback = function(ShowCustomCursors)
            _G.ShowCustomCursor = ShowCustomCursors
            if _G.ShowCustomCursor == false then
                Library.ShowCustomCursor = false
            else
                Library.ShowCustomCursor = true
            end
        end
    })

    MenuGroup:AddDivider()
    MenuGroup:AddButton('Copy Discord Server Link', function()
        setclipboard("https://discord.gg/HjqzMPJveZ")
        Library:Notify("<b>[Dyck]</b> Link copiado!")
    end)

    MenuGroup:AddDivider()
    MenuGroup:AddButton("Unload", function()
        if WS_Enabled == true and Player.Character then
            local hum = Player.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
        ESPLibrary:Unload()
        Library:Unload()
        getgenv().DyckLobby = nil
    end)

    MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightControl', NoUI = true, Text = 'Menu keybind' })
    Library.ToggleKeybind = Options.MenuKeybind

    local AboutGroup = Tabs['UI Settings']:AddRightGroupbox('Contributors')
    AboutGroup:AddLabel("<font color='#15ff00'>Dyck Menu</font> - Lobby Edition")
    
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
    ThemeManager:SetFolder('DyckMenu')
    SaveManager:SetFolder('DyckMenu/Lobby')
    SaveManager:BuildConfigSection(Tabs['UI Settings'])
    ThemeManager:ApplyToTab(Tabs['UI Settings'])
end
