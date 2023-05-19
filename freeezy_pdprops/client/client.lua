local cooldown = false

local function Cooldown()
    if cooldown then
        ShowNotification('You cant put objects down that fast!', 'error')
    else
        cooldown = true
        SetTimeout(4000, function()
            cooldown = false
        end)
        return true
    end
end

local jobs = {
    ['police'] = 0,
    ['sheriff'] = 0,
    ['sahp'] = 0,
    ['us_army'] = 0,
}

CreateThread(function()
    exports.ox_target:addModel({ `prop_roadcone02a`, `p_ld_stinger_s`, `prop_barrier_work05` }, {
        {
            name = 'remove_prop',
            icon = 'fa-solid fa-trash',
            label = 'Remove object',
            groups = jobs,
            onSelect = function(data)
                local tick = 0
                lib.progressCircle({
                    duration = 3500,
                    position = 'bottom',
                    label = 'Youre removing an object...',
                    useWhileDead = false,
                    canCancel = false,
                    anim = {
                        dict = 'mini@repair',
                        clip = 'fixing_a_player'
                    },
                    disable = {
                        move = true,
                        car = false
                    },
                })
                while not NetworkHasControlOfEntity(data.entity) and tick < 50 do
                    NetworkRequestControlOfEntity(data.entity)
                    tick = tick + 1
                    Wait(0)
                end
                DeleteEntity(data.entity)
            end
        }
    })
    lib.registerContext({
        id = 'pdprops',
        title = 'Police Objects',
        options = {
            {
                icon = 'triangle-exclamation',
                title = 'Cone',
                onSelect = function()
                    if not Cooldown() then return end
                    local playerPed = PlayerPedId()
                    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.5, 0.0)
                    lib.requestModel(`prop_roadcone02a`)
                    local object = CreateObject(`prop_roadcone02a`, coords.x, coords.y, coords.z, true, true)
                    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(object), true)
                    SetEntityHeading(object, GetEntityHeading(playerPed))
                    PlaceObjectOnGroundProperly(object)
                end
            },
            {
                
                icon = 'road-spikes',
                title = 'Spike strip',
                onSelect = function()
                    if not Cooldown() then return end
                    local playerPed = PlayerPedId()
                    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.5, 0.0)
                    lib.requestModel(`p_ld_stinger_s`)
                    local object = CreateObject(`p_ld_stinger_s`, coords.x, coords.y, coords.z, true, true)
                    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(object), true)
                    SetEntityHeading(object, GetEntityHeading(playerPed) + 90.0)
                    PlaceObjectOnGroundProperly(object)
                end
            },
            {
                icon = 'road-barrier',
                title = 'Barrier',
                onSelect = function()
                    if not Cooldown() then return end
                    local playerPed = PlayerPedId()
                    local coords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 0.5, 0.0)
                    lib.requestModel(`prop_barrier_work05`)
                    local object = CreateObject(`prop_barrier_work05`, coords.x, coords.y, coords.z, true, true)
                    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(object), true)
                    SetEntityHeading(object, GetEntityHeading(playerPed))
                    PlaceObjectOnGroundProperly(object)
                end
            }
        }
    })
    while true do
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local object = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, `p_ld_stinger_s`, false, false, false)
        if object ~= 0 then
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
    
                for i=0, 7, 1 do
                    if not IsVehicleTyreBurst(vehicle, i, true) then
                        SetVehicleTyreBurst(vehicle, i, true, 1000)
                    end
                end
            end
        end
        Wait(500)
    end
end)

RegisterKeyMapping('pdprops', 'Menu on objects', 'keyboard', 'F5')

RegisterCommand('pdprops', function()
    if jobs[ESX.GetPlayerData().job.name] == nil then return end
    lib.showContext('pdprops')
end, false)