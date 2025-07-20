ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

local webhook = 'webhook' --create your own webhook URL

local activeEvent = nil
local eventParticipants = {}
local eventWorlds = {}
local staffJobs = {'admin', 'moderator', 'staff'}
local staffOnlyMode = false


local function isPlayerStaff(source)
    if not staffOnlyMode then return true end
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    for _, staffJob in ipairs(staffJobs) do
        if xPlayer.job.name == staffJob then
            return true
        end
    end
    return false
end


local function createEventWorld(eventName, creatorId)
    local worldId = 1000
    eventWorlds[worldId] = {
        name = eventName .. " - Private Event",
        eventName = eventName,
        creator = creatorId,
        players = {},
        createdAt = os.time()
    }
    return worldId
end


local function sendEventToDiscord(title, message, color)
    if webhook == '' then return end

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = 'Event Logs',
        embeds = {{
            title = title,
            description = message,
            color = color or 3447003,
            footer = { text = 'Gert = Awesome' },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }}
    }), { ['Content-Type'] = 'application/json' })
end


local function movePlayerToEventWorld(playerId, worldId)
    if eventWorlds[worldId] then
        SetPlayerRoutingBucket(playerId, worldId)
        table.insert(eventWorlds[worldId].players, playerId)
    end
end


local function removePlayerFromEventWorld(playerId, worldId)
    if eventWorlds[worldId] then
        for i, p in ipairs(eventWorlds[worldId].players) do
            if p == playerId then
                table.remove(eventWorlds[worldId].players, i)
                break
            end
        end
    end
    SetPlayerRoutingBucket(playerId, 0)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(120000)
        for worldId, world in pairs(eventWorlds) do
            if #world.players == 0 then
                eventWorlds[worldId] = nil
            end
        end
    end
end)

RegisterCommand("startevent", function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if not isPlayerStaff(source) then
        TriggerClientEvent('CodePlazaNotify:Alert', source, 'Fout', 'no permission to create an event', 5000, 'error', true)
        return
    end

    if activeEvent then
        TriggerClientEvent('CodePlazaNotify:Alert', source, 'Fout', 'There is already an event active.', 5000, 'error', true)
        return
    end

    local eventName = table.concat(args, " ")
    if not eventName or string.len(eventName) < 3 then
        TriggerClientEvent('CodePlazaNotify:Alert', source, 'Fout', 'Atleast 3 characters in the name.', 5000, 'warning', true)
        return
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local worldId = createEventWorld(eventName, source)

    activeEvent = {
        id = os.time(),
        name = eventName,
        creator = xPlayer.getName(),
        creatorId = source,
        createdAt = os.date('%Y-%m-%d %H:%M:%S'),
        participants = {},
        worldId = worldId,
        location = {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            heading = heading
        }
    }

    sendEventToDiscord("📢 Event started", ("**Event:** %s\n**By:** %s"):format(eventName, xPlayer.getName()), 3066993)

    eventParticipants = {}
    movePlayerToEventWorld(source, worldId)
    eventParticipants[source] = {
        playerId = source,
        playerName = xPlayer.getName(),
        joinedAt = os.date('%Y-%m-%d %H:%M:%S')
    }

    TriggerClientEvent('eventsystem:teleportToEvent', source, activeEvent.location)
    TriggerClientEvent('CodePlazaNotify:Alert', source, 'Succes', 'Event "' .. eventName .. '" Created an event!', 5000, 'success', true)
end, false)

RegisterCommand("joinevent", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if not activeEvent then
        TriggerClientEvent('CodePlazaNotify:Alert', source, 'Fout', 'No active event found.', 5000, 'error', true)
        return
    end

    if eventParticipants[source] then
        TriggerClientEvent('CodePlazaNotify:Alert', source, 'Info', 'You are already in the event.', 5000, 'info', true)
        return
    end

    eventParticipants[source] = {
        playerId = source,
        playerName = xPlayer.getName(),
        joinedAt = os.date('%Y-%m-%d %H:%M:%S')
    }

    movePlayerToEventWorld(source, activeEvent.worldId)
    TriggerClientEvent('eventsystem:teleportToEvent', source, activeEvent.location)
    TriggerClientEvent('eventsystem:joinedEvent', source)
end, false)

RegisterCommand("leaveevent", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if not eventParticipants[source] then
        TriggerClientEvent('CodePlazaNotify:Alert', source, 'error', 'You are not in an event.', 5000, 'error', true)
        return
    end

    eventParticipants[source] = nil
    removePlayerFromEventWorld(source, activeEvent.worldId)
    TriggerClientEvent('CodePlazaNotify:Alert', source, 'Info', 'You have left the event.', 5000, 'info', true)
end, false)

RegisterCommand("Qevent", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not activeEvent then return end

    if source ~= activeEvent.creatorId then
        TriggerClientEvent('CodePlazaNotify:Alert', source, 'error', 'Only the event creator can do this.', 5000, 'error', true)
        return
    end

    for playerId, _ in pairs(eventParticipants) do
        removePlayerFromEventWorld(playerId, activeEvent.worldId)
        TriggerClientEvent('CodePlazaNotify:Alert', playerId, 'Event Stopped', 'The event has been stopped.', 5000, 'info', true)
    end

    sendEventToDiscord("⛔ Event Stopped", ("**Event:** %s\n**Door:** %s"):format(activeEvent.name, xPlayer.getName()), 15158332)

    activeEvent = nil
    eventParticipants = {}
end, false)


AddEventHandler('esx:playerDropped', function(playerId)
    if eventParticipants[playerId] then
        local currentWorld = GetPlayerRoutingBucket(playerId)
        removePlayerFromEventWorld(playerId, currentWorld)
        eventParticipants[playerId] = nil
    end
end)