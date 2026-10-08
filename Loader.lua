-- ==========================================
-- DYCK MENU | MASTER LOADER
-- Detecta o ambiente (Lobby, In-Game, Hardcore)
-- e carrega a versão correta do hub.
-- ==========================================

local DyckLoader = {
    Version = "1.0.0",
    Repo = "https://raw.githubusercontent.com/drdyckrandola/dyckmenudoors/refs/heads/main/",
    Scripts = {
        Lobby = "Dyck-Menu-Lobby.lua",
        InGame = "Dyck-Menu-Doors.lua"
    }
}

-- 1. DETECÇÃO DE AMBIENTE
local function DetectEnvironment()
    local placeId = game.PlaceId
    local rs = game:GetService("ReplicatedStorage")
    
    -- Place IDs conhecidos do Doors
    local KNOWN_LOBBY_IDS = {
        [6516141723] = true, -- Lobby Principal
    }
    
    local KNOWN_GAME_IDS = {
        [6839171747] = true, -- Jogo Principal
        [110258689672367] = true, -- Jogo Principal (Novo ID)
    }
    
    local KNOWN_HARDWARE_IDS = {
        [137519142947486] = true, -- Hardcore
    }

    -- Lógica de Detecção
    if KNOWN_LOBBY_IDS[placeId] then
        return "Lobby"
    elseif KNOWN_HARDWARE_IDS[placeId] then
        return "Hardcore" -- O script In-Game é robusto o suficiente para Hardcore, 
                          -- mas se você tiver uma versão específica, troque aqui.
    elseif KNOWN_GAME_IDS[placeId] then
        return "In-Game"
    else
        -- Fallback: Se o PlaceId não for conhecido, checa a estrutura de dados
        if rs:FindFirstChild("GameData") and rs.GameData:FindFirstChild("Floor") then
            return "In-Game"
        elseif rs:FindFirstChild("LobbyData") or (rs:FindFirstChild("RemotesFolder") and rs.RemotesFolder:FindFirstChild("ElevatorJoin")) then
            return "Lobby"
        else
            -- Último recurso: assume In-Game se houver CurrentRooms
            if workspace:FindFirstChild("CurrentRooms") then
                return "In-Game"
            end
            return "Lobby"
        end
    end
end

-- 2. CARREGAMENTO DO SCRIPT
local function LoadScript(scriptName)
    local url = DyckLoader.Repo .. scriptName
    print(("[Dyck Loader]): Carregando %s (%s)..."):format(scriptName, url))
    
    local ok, result = pcall(function()
        local source = game:HttpGet(url)
        loadstring(source)()
    end)
    
    if not ok then
        warn(("[Dyck Loader]): ERRO ao carregar o script!\n%s"):format(result))
    else
        print(("[Dyck Loader]): %s carregado com sucesso."):format(scriptName))
    end
end

-- 3. EXECUÇÃO
local environment = DetectEnvironment()
print(("[Dyck Loader]): Ambiente detectado: %s"):format(environment)

if environment == "Lobby" then
    LoadScript(DyckLoader.Scripts.Lobby)
else
    -- In-Game e Hardcore usam o mesmo script principal (que é robusto)
    LoadScript(DyckLoader.Scripts.InGame)
end

print(("[Dyck Loader]): Initialização concluída. Bom jogo! 🚀"))
