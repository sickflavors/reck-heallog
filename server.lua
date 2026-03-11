local ESX = exports["es_extended"]:getSharedObject()

local function HasPermission(xPlayer)
    if not xPlayer then
        return false
    end

    if Config.UseAce and IsPlayerAceAllowed(xPlayer.source, Config.AcePermission) then
        return true
    end

    local group = xPlayer.getGroup and xPlayer.getGroup() or "user"
    for _, allowedGroup in ipairs(Config.AllowedGroups) do
        if group == allowedGroup then
            return true
        end
    end

    return false
end

local function GetCharacterName(xPlayer)
    if not xPlayer then
        return "Unknown"
    end

    local firstName = xPlayer.get and (xPlayer.get("firstName") or xPlayer.get("firstname")) or nil
    local lastName = xPlayer.get and (xPlayer.get("lastName") or xPlayer.get("lastname")) or nil

    if firstName and lastName and firstName ~= "" and lastName ~= "" then
        return (firstName .. " " .. lastName)
    end

    local name = GetPlayerName(xPlayer.source)
    return name or ("Player " .. tostring(xPlayer.source))
end

local function SendStaffLog(message)
    for _, playerId in ipairs(GetPlayers()) do
        local id = tonumber(playerId)
        local xTarget = ESX.GetPlayerFromId(id)

        if xTarget and HasPermission(xTarget) then
            TriggerClientEvent("chat:addMessage", id, {
                color = Config.ChatColor,
                multiline = true,
                args = { message }
            })
        end
    end
end

local function NotifySource(src, msg)
    TriggerClientEvent("chat:addMessage", src, {
        color = {255, 0, 0},
        multiline = true,
        args = { msg }
    })
end

local function BuildReason(args, startIndex)
    local parts = {}

    for i = startIndex, #args do
        parts[#parts + 1] = args[i]
    end

    return table.concat(parts, " ")
end

RegisterCommand(Config.ReviveCommand, function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return
    end

    if not HasPermission(xPlayer) then
        NotifySource(source, "You do not have permission to use this command.")
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        NotifySource(source, "Usage: /" .. Config.ReviveCommand .. " [id] [reason]")
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        NotifySource(source, "Invalid player ID.")
        return
    end

    local reason = BuildReason(args, 2)

    if Config.RequireReviveReason and reason == "" then
        NotifySource(source, "You must provide a reason. Usage: /" .. Config.ReviveCommand .. " [id] [reason]")
        return
    end

    if reason == "" then
        reason = "No reason provided"
    end

    TriggerClientEvent("reck-heallog:revivePlayer", targetId)

    local adminName = GetCharacterName(xPlayer)
    local targetName = GetCharacterName(xTarget)

    local message = string.format(
        "AdmCmd: %s (%s) has granted a revive to %s (%s). Reason: %s",
        adminName, source, targetName, targetId, reason
    )

    SendStaffLog(message)
end, false)

RegisterCommand(Config.HealCommand, function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return
    end

    if not HasPermission(xPlayer) then
        NotifySource(source, "You do not have permission to use this command.")
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        NotifySource(source, "Usage: /" .. Config.HealCommand .. " [id] [reason]")
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        NotifySource(source, "Invalid player ID.")
        return
    end

    local reason = BuildReason(args, 2)

    if Config.RequireHealReason and reason == "" then
        NotifySource(source, "You must provide a reason. Usage: /" .. Config.HealCommand .. " [id] [reason]")
        return
    end

    if reason == "" then
        reason = "No reason provided"
    end

    TriggerClientEvent("reck-heallog:healPlayer", targetId)

    local adminName = GetCharacterName(xPlayer)
    local targetName = GetCharacterName(xTarget)

    local message = string.format(
        "AdmCmd: %s (%s) has granted a heal to %s (%s). Reason: %s",
        adminName, source, targetName, targetId, reason
    )

    SendStaffLog(message)
end, false)

if Config.EnableTxAdminHealHook then
    AddEventHandler("txAdmin:events:playerHealed", function(eventData)
        if not eventData then
            return
        end

        local targetId = tonumber(eventData.target)
        local author = eventData.author or "txAdmin"

        if not targetId or targetId == -1 then
            return
        end

        local xTarget = ESX.GetPlayerFromId(targetId)
        if not xTarget then
            return
        end

        TriggerClientEvent("reck-heallog:healPlayer", targetId)
        TriggerClientEvent("reck-heallog:revivePlayer", targetId)

        local targetName = GetCharacterName(xTarget)

        local message = string.format(
            "AdmCmd: %s (txAdmin) has granted a heal to %s (%s). Reason: txAdmin heal",
            author, targetName, targetId
        )

        SendStaffLog(message)
    end)
end