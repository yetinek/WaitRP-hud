HUD = {
    Enabled = true,
    PlayerLoaded = false,
    CinameticMode = false,
    ProgressbarCache = {},
    HelpNotificationCache = {
        Update = GetGameTimer(),
        Display = false,
        Message = ''
    },
    HelpInputCache = {
        Update = GetGameTimer(),
        Display = false
    },
    CurrentVehicle = nil,
}

local HideResources = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    SendNUIMessage({
        action = "playerLoaded",
        id = GetPlayerServerId(PlayerId()),
        ssn = 2115 -- ustaw to se baranie jak masz ssn
    })
    SendNUIMessage({
        action = "toggleUI",
        bool = true
    })
    HUD.PlayerLoaded = true
end)

-- RegisterCommand('fakeload', function()
--     SendNUIMessage({
--         action = "playerLoaded",
--         id = GetPlayerServerId(PlayerId()),
--         ssn = 1
--     })
--     SendNUIMessage({
--         action = "toggleUI",
--         bool = true
--     })
--     HUD.PlayerLoaded = true
-- end)

RegisterNetEvent('esx_status:UpdateStatusValue', function(statusName, statusValue)
    if not HUD.PlayerLoaded then return end
    if statusName == 'hunger' or statusName == 'thirst' then
        SendNUIMessage({
            action = "updateHud",
            status = {
                {name = statusName, value = statusValue},
            }
        })
    end
end)

AddEventHandler('pma-voice:setTalkingMode', function(mode)
    SendNUIMessage({
        action = "UpdateVoice",
        mode = mode
    })
end)

AddEventHandler('esx:enteredVehicle', function(vehicle, plate, seat, displayName, netId)
    HUD.CurrentVehicle = vehicle
    SetEntityMaxSpeed(vehicle, 190 / 2.236936)
    SendNUIMessage({
        action = "togglecarHud",
        bool = true,
        map_width = GetMinimapAnchor().width_px
    })
    Citizen.CreateThread(function()
        while true do
            if HUD.CurrentVehicle ~= nil then
                DisplayRadar(not HUD.CinameticMode)
                local direction = nil
                for k, v in pairs({[0] = 'N', [45] = 'NW', [90] = 'W', [135] = 'SW', [180] = 'S', [225] = 'SE', [270] = 'E', [315] = 'NE', [360] = 'N' }) do
					direction = GetEntityHeading(ESX.PlayerData.ped)
					if math.abs(direction - k) < 22.5 then
						direction = v
						break
					end
				end

                SendNUIMessage({
                    action = "updatecarHud",
                    speed = math.ceil((GetEntitySpeed(HUD.CurrentVehicle)) * 2.236936),
                    direction = direction,
                    streetLabel = GetLabelText(GetNameOfZone(GetEntityCoords(HUD.CurrentVehicle))),
                    engine = GetIsVehicleEngineRunning(HUD.CurrentVehicle),
                    fuel = Entity(HUD.CurrentVehicle).state.fuel or GetVehicleFuelLevel(HUD.CurrentVehicle),
                    rpm = math.floor(GetVehicleCurrentRpm(HUD.CurrentVehicle) * 100),
                    heading = math.floor(360.0 - GetEntityHeading(ESX.PlayerData.ped)),
                })
            else
                break
            end
            Wait(100)
        end
    end)
end)

AddEventHandler('esx:exitedVehicle', function(vehicle, plate, seat, displayName, netId)
    HUD.CurrentVehicle = nil
    DisplayRadar(false)
    SendNUIMessage({
        action = "togglecarHud",
        bool = false
    })
end)

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        if HUD.PlayerLoaded then
            SendNUIMessage({
                action = "UpdateTime",
                time = string.format("%02d:%02d", GetClockHours(), GetClockMinutes()),
                IsPauseMenuActive = IsPauseMenuActive()
            })
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(100)
        if HUD.PlayerLoaded then
            SendNUIMessage({
                action = 'toggleTalking',
                talking = MumbleIsPlayerTalking(PlayerId())
            })
            SendNUIMessage({
                action = "updateHud",
                status = {
                    {name = 'health', value = (math.floor((GetEntityHealth(ESX.PlayerData.ped) - 100) / (GetEntityMaxHealth(ESX.PlayerData.ped) - 100) * 100))},
                    {name = 'armour', value = GetPedArmour(ESX.PlayerData.ped)},
                    {name = 'oxygen', value = math.floor(GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10)}
                }
            })
        end
    end
end)

-- exports('ChangeColor', function(bool, elements)
--     SendNUIMessage({
--         action = "ChangeColor",
--         bool = bool,
--         elements = elements
--     })
-- end)

exports('ChangeHideResourceState', function(bool)
    local resourceName = GetInvokingResource()
    if bool then
        local InTable = false
        for _, resource in pairs(HideResources) do
            if resource == resourceName then
                InTable = true
                break
            end
        end
        if not InTable then
            table.insert(HideResources, resourceName)
        end
        SendNUIMessage({
            action = "toggleHideResource",
            bool = true
        })
        TriggerEvent('chat:display', false)
    else
        for index, resource in pairs(HideResources) do
            if resource == resourceName then
                table.remove(HideResources, index)
            end
        end
        if #HideResources == 0 then
            SendNUIMessage({
                action = "toggleHideResource",
                bool = false
            })
            TriggerEvent('chat:display', true)
        end
    end
end)

-- ToggleHud = function()
--     exports['w_hud']:ChangeHideResourceState(HUD.Enabled)
--     HUD.Enabled = not HUD.Enabled
-- end

-- RegisterKeyMapping("togglehud", "Toggle HUD", "mouse_button", "MOUSE_MIDDLE")
-- RegisterCommand("togglehud", function()
--     ToggleHud()
-- end, false)

-- RegisterCommand('hud', function()
--     SendNUIMessage({
--         action = 'toggleHudSettings',
--         bool = true
--     })
--     SetNuiFocus(true, true)
-- end, false)

local confirm = nil
local CurrentConfirmMenu = nil
local WaitMenu = false

exports('OpenConfirmMenu', function(data, cb)
    while CurrentConfirmMenu ~= nil do
        WaitMenu = true
        Wait(100)
    end
    if WaitMenu then
        Wait(250)
        WaitMenu = false
    end
    CurrentConfirmMenu = data
    if not confirm then
        confirm = promise.new()
    end
    --exports['w_radialmenu']:CloseRadial()
    SendNUIMessage({
        action = 'OpenCofirmMenu',
        data = {
            title = data.title,
            desc = data.desc,
            btnCancel = (data.btnCancel and data.btnCancel or 'Nie'),
            btnConfirm = (data.btnConfirm and data.btnConfirm or 'Tak'),
        }
    })
    SetNuiFocus(true, true)
    cb(Citizen.Await(confirm))
end)

RegisterNUICallback('ConfirmMenuResult', function(data)
    if not confirm then return end
    local p = confirm
    confirm = nil
    p:resolve(data.result and data.result or false)
    CurrentConfirmMenu = nil
    SetNuiFocus(false, false)
end)

RegisterCommand("hud", function()
    SendNUIMessage({
        action = 'OpenSettings',
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('LoadSettings', function(data)
    -- exports['w_core']:SaveCrosshair(data.settings.Crosshair)
    TriggerEvent('chat:display', not data.settings.CinemaMode)
    if data.close then
        SetNuiFocus(false, false)
    end
end)


RegisterNUICallback('SaveSettings', function(data)
    SetNuiFocus(false, false)
    HUD.CinameticMode = data.settings.cinameticMode
    SetResourceKvp("hud-settings", json.encode(data.settings))
    TriggerEvent("chat:display", not HUD.CinameticMode)
end)

RegisterNUICallback('CloseSettings', function(data)
    SetNuiFocus(false, false)
end)

AddEventHandler("gameEventTriggered", function(args1, args2)
    if args1 == 'CEventNetworkPlayerEnteredVehicle' and args2[1] == PlayerId() then
        InitMap()
    end
end)

function GetMinimapAnchor()
    local aspect_ratio = GetAspectRatio(0)
    local res_x, _ = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    local Minimap = {}
    Minimap.width = xscale * (res_x / (3.5 * aspect_ratio))
    Minimap.xunit = xscale
    Minimap.width_px = math.floor(Minimap.width / Minimap.xunit)
    return Minimap
end

function InitMap()
    RequestStreamedTextureDict("squaremap", false)
    while not HasStreamedTextureDictLoaded("squaremap") do
        Wait(0)
    end

    local defaultAspectRatio = 1920 / 1080
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
    end

    SetMinimapClipType(0)
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
    
    -- 0.0 = nav symbol and icons left
    -- 0.1638 = nav symbol and icons stretched
    -- 0.216 = nav symbol and icons raised up
    SetMinimapComponentPosition("minimap", "L", "B", 0.0 + minimapOffset, -0.017, 0.1638, 0.183)

    -- icons within map
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.0 + minimapOffset, 0.0, 0.128, 0.20)

    -- -0.01 = map pulled left
    -- 0.025 = map raised up
    -- 0.262 = map stretched
    -- 0.315 = map shorten
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.055, 0.262, 0.300)
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetMinimapClipType(0)

    SetRadarBigmapEnabled(true, false)
    while IsBigmapActive() do
        Wait(0)
        SetRadarBigmapEnabled(false, false)
    end
end

local block = false

exports('SetFocus', function(bool)
    block = bool
    SetNuiFocus(bool, bool)
    SetNuiFocusKeepInput(bool)
    SendNUIMessage({
        action = 'SetFocus',
        bool = bool
    })
    if bool then
        while block do
            Wait(0)
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
        end
    end
end)