-- ==========================================
-- DYCK MENU | MASTER LOADER (V2.0)
-- Corrigido para detecção precisa de Lobby/In-Game
-- ==========================================

local DyckLoader = {
    Version = "2.0.0",
    Repo = "https://raw.githubusercontent.com/drdyckrandola/dyckmenudoors/refs/heads/main/",
    Scripts = {
        Lobby = "Dyck-Menu-Lobby.lua",
        InGame = "Dyck-Menu-Doors.lua"
    }
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- 1. AGUARDA O JOGO CARREGAR
repeat task.wait() until game:IsLoaded()
repeat task.wait() until LocalPlayer

-- 2. FUNÇÃO DE DETECÇÃO APRENDIDA
local function DetectEnvironment()
    local placeId = game.PlaceId
    
    -- Place IDs Conhecidos (Prioridade Máxima)
    if placeId == 6516141723 then return "Lobby" end
    if placeId == 6839171747 or placeId == 110258689672367 then return "In-Game" end
    if placeId == 137519142947486 then return "In-Game" end -- Hardcore usa a mesma lógica de In-Game

    -- Fallback: Detecção por Estrutura de Dados
    -- Espera até que o ReplicatedStorage tenha os dados essenciais
    task.wait(2) 

    if ReplicatedStorage:FindFirstChild("GameData") and ReplicatedStorage.GameData:FindFirstChild("Floor") then
        return "In-Game"
    end
    
    if ReplicatedStorage:FindFirstChild("RemotesFolder") then
        local rf = ReplicatedStorage.RemotesFolder
        -- Remotes específicos de Lobby
        if rf:FindFirstChild("ElevatorJoin") or rf:FindFirstChild("ShopCode") or rf:FindFirstChild("FlexAchievement") then
            return "Lobby"
        end
        -- Remotes específicos de In-Game
        if rf:FindFirstChild("ShadeResult") or rf:FindFirstChild("A90") or rf:FindFirstChild("Crouch") then
            return "In-Game"
        end
    end

    -- Último Fallback: Verifica Workspace
    if workspace:FindFirstChild("CurrentRooms") then
        return "In-Game"
    end
    
    return "Lobby" -- Assume Lobby se nada for encontrado (mais comum em PlaceIds novos de lobby)
end

-- 3. FUNÇÃO DE CARREGAMENTO
local function LoadScript(scriptName, environment)
    local url = DyckLoader.Repo .. scriptName
    print(("[Dyck Loader v%s]): Carregando %s para %s..."):format(DyckLoader.Version, scriptName, environment))
    
    -- Se for Lobby, aguarda a UI específica carregar para evitar erros de nil
    if environment == "Lobby" then
        print("[Dyck Loader]: Aguardando UI do Lobby...")
        local gui = LocalPlayer:WaitForChild("PlayerGui")
        local mainUI = gui:WaitForChild("MainUI", 10)
        if mainUI then
            -- Aguarda a LobbyFrame específica do Doors Lobby
            local lobbyFrame = mainUI:WaitForChild("LobbyFrame", 10)
            if not lobbyFrame then
                warn("[Dyck Loader]: LobbyFrame não encontrada. Tentando carregar mesmo assim.")
            end
        end
    end

    local ok, result = pcall(function()
        local source = game:HttpGet(url)
        loadstring(source)()
    end)
    
    if not ok then
        warn(("[Dyck Loader]: ERRO ao carregar o script!\n%s"):format(result))
    else
        print(("[Dyck Loader]): %s carregado com sucesso."):format(scriptName))
    end
end

-- 4. EXECUÇÃO
local environment = DetectEnvironment()
print(("[Dyck Loader]): Ambiente detectado: %s"):format(environment)

if environment == "Lobby" then
    LoadScript(DyckLoader.Scripts.Lobby, environment)
else
    LoadScript(DyckLoader.Scripts.InGame, environment)
end

print(("[Dyck Loader]): Inicialização concluída. Dyck Menu ativo. 🚀"))
