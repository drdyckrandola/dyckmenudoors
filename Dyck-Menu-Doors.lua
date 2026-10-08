if not getgenv().Dyck then

    repeat task.wait() until game:IsLoaded()

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

    -- CONFIGURAÇÕES GLOBAIS
    local VERSION_URL = "https://raw.githubusercontent.com/GeorgeRoblox/version/refs/heads/main/.luau"
    local EXPECTED_VERSION = "v.2.0.0"
    local FILE_NAME = "DYCK_MENU_INIT"
    local MENU_NAME = "Dyck Menu"

    if not isfile(FILE_NAME) then
        writefile(FILE_NAME, "Dyck Menu Initialized")
    end

    local success, onlineVersion = pcall(function()
        return game:HttpGet(VERSION_URL)
    end)

    if not success then
        warn("[Dyck] Version check failed. Continuing.")
    else
        onlineVersion = tostring(onlineVersion):gsub("%s+", "")
        if onlineVersion ~= EXPECTED_VERSION then
            local lp = game:GetService("Players").LocalPlayer
            lp:Kick("Wrong version of " .. MENU_NAME .. ". Current: " .. EXPECTED_VERSION)
            return
        end
    end

    -- VARIÁVEIS DE ESTADO
    local LocalPlayer = Services.Players.LocalPlayer
    local Character = LocalPlayer.Character

    -- MAPPING DE FLOORS (NORMALIZAÇÃO)
    -- Mapeia nomes internos possiveis para o nome canônico usado no script
    local FloorAliases = {
        ["Hotel"] = "The Hotel",
        ["hotel"] = "The Hotel",
        ["The Hotel"] = "The Hotel",
        ["Mines"] = "The Mines",
        ["The Mines"] = "The Mines",
        ["Archives"] = "The Archives",
        ["The Archives"] = "The Archives",
        ["Rooms"] = "The Archives", -- Legacy mapping
        ["Outdoors"] = "The Outdoors",
        ["The Outdoors"] = "The Outdoors",
        ["Garden"] = "The Outdoors", -- Legacy mapping
        ["Backdoor"] = "The Backdoor",
        ["The Backdoor"] = "The Backdoor",
        ["Stairwell"] = "The Stairwell",
        ["The Stairwell"] = "The Stairwell",
        ["Ladders"] = "The Stairwell", -- Legacy/Informal mapping
        ["Rush Mode"] = "Past Vision: Rush",
        ["Rush"] = "Past Vision: Rush",
        ["Retro Mode"] = "Past Vision: Retro",
        ["Retro"] = "Past Vision: Retro",
        ["Super Hard Mode"] = "Past Vision: Super Hard",
        ["Super Hard"] = "Past Vision: Super Hard",
        ["Hotel-"] = "Past Vision: Hotel-",
        ["The Rooms"] = "The Rooms",
        ["Trick Or Treat"] = "Past Vision: Trick Or Treat",
        ["Trick-or-Treat"] = "Past Vision: Trick Or Treat",
    }

    local function NormalizeFloor(rawName)
        if not rawName then return "Unknown" end
        return FloorAliases[rawName] or rawName
    end

    -- DETECÇÃO DE FLOOR
    local Floor = "Unknown"
    if Services.ReplicatedStorage:FindFirstChild("GameData") then
        local floorValue = Services.ReplicatedStorage.GameData:FindFirstChild("Floor")
        if floorValue and floorValue.Value then
            Floor = NormalizeFloor(tostring(floorValue.Value))
        end
    end

    local OldHotel = (Services.ReplicatedStorage:FindFirstChild("Bricks") ~= nil)
    local NewHotel = (Floor == "The Hotel" and Services.ReplicatedStorage:FindFirstChild("RemotesFolder") ~= nil)
    local IsArchives = (Floor == "The Archives")
    local IsStairwell = (Floor == "The Stairwell")
    local IsOutdoors = (Floor == "The Outdoors")
    local IsPastVision = string.find(Floor, "Past Vision") ~= nil

    local SupportedFloors = {
        "The Hotel",
        "The Mines",
        "The Archives",
        "The Outdoors",
        "The Backdoor",
        "The Stairwell",
        "Past Vision: Rush",
        "Past Vision: Retro",
        "Past Vision: Super Hard",
        "Past Vision: Hotel-",
        "The Rooms",
        "Past Vision: Trick Or Treat"
    }

    local function FloorSupported(name)
        for _, floor in ipairs(SupportedFloors) do
            if floor == name then return true end
        end
        return false
    end

    if not FloorSupported(Floor) then
        local list = table.concat(SupportedFloors, ", ")
        LocalPlayer:Kick("This script doesn't support this floor. Supported: " .. list)
        return
    end

    local EntityShortNames = {
        ["RushMoving"] = "Rush",
        ["AmbushMoving"] = "Ambush",
        ["A60"] = "A-60",
        ["A120"] = "A-120",
        ["BackdoorRush"] = "Blitz",
        ["Eyes"] = "Eyes",
        ["Lookman"] = "Eyes",
        ["BackdoorLookman"] = "Lookman",
        ["CustomEntity"] = "Custom Entity",
        ["GloombatSwarm"] = "Gloombat Swarm",
        ["Jeff"] = "Jeff The Killer",
        ["Halt"] = "Halt",
        ["GlitchRush"] = "RNIUSHCG",
        ["GlitchedAmbush"]  = "AR0xMBUSH",
        ["MonumentEntity"] = "Monument",
        ["Groundskeeper"] = "Groundskeeper",
        ["FigureRig"] = "Figure",
        ["LiveEntityBramble"] = "Bramble",
        ["FigureRagdoll"] = "Figure",
        ["SallyMoving"] = "Sally",
        ["JeffTheKiller"] = "Jeff The Killer",
    }

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

    -- SEGURANÇA: AGUARDA MODULES
    local Module
    do
        local ok, lplr = pcall(function() return Services.Players.LocalPlayer end)
        if ok and lplr then
            local pgui = lplr:FindFirstChild("PlayerGui")
            local mainUI = pgui and pgui:WaitForChild("MainUI", 15)
            local initiator = mainUI and mainUI:WaitForChild("Initiator", 15)
            local mainGame = initiator and initiator:WaitForChild("Main_Game", 15)
            local remoteListener = mainGame and mainGame:WaitForChild("RemoteListener", 15)
            Module = remoteListener and remoteListener:WaitForChild("Modules", 15)
        end
        if
