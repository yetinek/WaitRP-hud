local LastHelpNotification = GetGameTimer()

ShowHelpNotification = function(notificationText)
    LastHelpNotification = GetGameTimer() + 200
    if not HUD.HelpNotificationCache.Display then
        HUD.HelpNotificationCache.Display = true
        SendNUIMessage({
            action = 'ShowHelpNotification',
            state = 'open',
            display = true,
            message = notificationText
        })
        Wait(50)
        TriggerEvent("chat:updateHeight", true)
        HUD.HelpNotificationCache.Message = notificationText
    else
        if HUD.HelpNotificationCache.Update <= GetGameTimer() then
            HUD.HelpNotificationCache.Update = GetGameTimer() + 200
            if HUD.HelpNotificationCache.Message ~= notificationText then	
                HUD.HelpNotificationCache.Message = notificationText
                SendNUIMessage({
                    action = 'ShowHelpNotification',
                    state = 'open',
                    display = false,
                    message = notificationText
                })
                TriggerEvent("chat:updateHeight", true)
            end
        end
    end
end

RegisterNUICallback('SetHelpNotificationDisplay', function(data)	
    HUD.HelpNotificationCache.Display = data.bool
end)

CreateThread(function()
    while true do
        Wait(0)
        if HUD.HelpNotificationCache.Display then
            if LastHelpNotification <= GetGameTimer() then
                SendNUIMessage({
                    action = 'ShowHelpNotification',
                    state = 'close',
                })
                HUD.HelpNotificationCache = {
                    Update = GetGameTimer(),
                    Display = false,
                    Message = ''
                }
                TriggerEvent("chat:updateHeight", false)
            end
        else
            Wait(250)
        end
    end
end)

exports('ShowHelpNotification', ShowHelpNotification)