local scripts = {
    [138665815682498] = "AimIncremental.lua",  -- your first game
    [1234567890] = "OtherGame1.lua",          -- another game
    [987654321] = "OtherGame2.lua",           -- yet another game
}

local placeId = game.PlaceId
local scriptName = scripts[placeId]

if scriptName then
    local url = "https://raw.githubusercontent.com/Dylan123121/PickleHub/main/" .. scriptName
    loadstring(game:HttpGet(url))()
else
    warn("No script found for this PlaceId: " .. placeId)
end
