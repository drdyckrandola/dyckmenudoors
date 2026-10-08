-- ==========================================
-- DYCK MENU | MASTER LOADER (V2.0)
-- Corrigido para detecção precisa de Lobby/In-Game
-- ==========================================

local GameList = {
    [6516141723] = "Doors lobby",
    [6839171747] = "Doors",
    [110258689672367] = "Doors"
}

local place_id = game.PlaceId
local url = "https://raw.githubusercontent.com/drdyckrandola/dyckmenudoors/refs/heads/main/Dyck-Menu-Doors.lua"
local lobby_url = "https://raw.githubusercontent.com/drdyckrandola/dyckmenudoors/refs/heads/main/Dyck-Menu-Lobby.lua"

local function Load(url)
    loadstring(game:HttpGet(url))()
end

if GameList[place_id] == "Doors" then
    Load(url)
elseif GameList[place_id] == "Doors lobby" then
    Load(lobby_url)
end
