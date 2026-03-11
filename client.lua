RegisterNetEvent("reck-heallog:healPlayer", function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
end)

RegisterNetEvent("reck-heallog:revivePlayer", function()
    TriggerEvent("esx_ambulancejob:revive")
end)