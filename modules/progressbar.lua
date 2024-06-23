local IsDoingAction = false

ProgressBar = function(data)
    local _data = {
        desc = data.desc or "Wykonywanie akcji",
        lenght = data.lenght or 5000,
        canCancel = data.canCancel or false,
        useWhileDead = data.useWhileDead or false,
        controlDisables = {
            disableMovement = data.controlDisables.disableMovement or false,
            disableCarMovement = data.controlDisables.disableCarMovement or false,
            disableMouse = data.controlDisables.disableMouse or false,
            disableCombat = data.controlDisables.disableCombat or false,
        },
        finishAction = data.finishAction or function() end,
        cancelAction = data.cancelAction or function() end
    }

    HUD.ProgressbarCache = _data

    SendNUIMessage({
        action = "progressBar",
        desc = _data.desc,
        lenght = _data.lenght
    })

    IsDoingAction = true
    LocalPlayer.state.CanPlayAnimation = false
    while IsDoingAction do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 73) and HUD.ProgressbarCache.canCancel then
            StopProgressbar()
        end
        if IsEntityDead(ESX.PlayerData.ped) and not HUD.ProgressbarCache.useWhileDead then
            StopProgressbar()
        end
        DisableActions()
    end
end

RegisterNUICallback('FinishProgressbar', function(data)
    IsDoingAction = false
    LocalPlayer.state.CanPlayAnimation = true
    if data.type == 'success' then
        HUD.ProgressbarCache.finishAction()
    elseif data.type == 'cancel' then
        HUD.ProgressbarCache.cancelAction()
    end
end)

StopProgressbar = function()
    IsDoingAction = false
    LocalPlayer.state.CanPlayAnimation = true
    SendNUIMessage({
        action = "progressBar_stop"
    })
end

DisableActions = function()
    if HUD.ProgressbarCache.controlDisables.disableMouse then
        DisableControlAction(0, 1, true) -- LookLeftRight
        DisableControlAction(0, 2, true) -- LookUpDown
        DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
    end
    if HUD.ProgressbarCache.controlDisables.disableMovement then
        DisableControlAction(0, 30, true) -- disable left/right
        DisableControlAction(0, 31, true) -- disable forward/back
        DisableControlAction(0, 36, true) -- INPUT_DUCK
        DisableControlAction(0, 21, true) -- disable sprint
        DisableControlAction(0, 40, true) -- disable sprint
    end
    if HUD.ProgressbarCache.controlDisables.disableCarMovement then
        DisableControlAction(0, 63, true) -- veh turn left
        DisableControlAction(0, 64, true) -- veh turn right
        DisableControlAction(0, 71, true) -- veh forward
        DisableControlAction(0, 72, true) -- veh backwards
        DisableControlAction(0, 75, true) -- disable exit vehicle
    end
    if HUD.ProgressbarCache.controlDisables.disableCombat then
        DisablePlayerFiring(PlayerId(), true) -- Disable weapon firing
        DisableControlAction(0, 24, true) -- disable attack
        DisableControlAction(0, 25, true) -- disable aim
        DisableControlAction(1, 37, true) -- disable weapon select
        DisableControlAction(0, 47, true) -- disable weapon
        DisableControlAction(0, 58, true) -- disable weapon
        DisableControlAction(0, 140, true) -- disable melee
        DisableControlAction(0, 141, true) -- disable melee
        DisableControlAction(0, 142, true) -- disable melee
        DisableControlAction(0, 143, true) -- disable melee
        DisableControlAction(0, 263, true) -- disable melee
        DisableControlAction(0, 264, true) -- disable melee
        DisableControlAction(0, 257, true) -- disable melee
        DisableControlAction(0, 289, true) -- f2
    end
end

exports('ProgressBar', ProgressBar)

exports('ProgressBarIsDoingAction', function()
    return IsDoingAction
end)