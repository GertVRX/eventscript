ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end
end)


RegisterNetEvent('eventsystem:joinedEvent')
AddEventHandler('eventsystem:joinedEvent', function()
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName("~b~JE ZIT NU IN DE EVENT WERELD")
    DrawNotification(false, true)
end)


RegisterNetEvent('eventsystem:teleportToEvent')
AddEventHandler('eventsystem:teleportToEvent', function(coords)
   
    Wait(500)
    
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z + 0.5, false, false, false, false)
    SetEntityHeading(ped, coords.heading or 0.0)

 
    TriggerEvent('CodePlazaNotify:Alert', 'Event', 'You have been teleported to the event!', 5000, 'success', true)
end)

