---@class CacheHandler
local CacheHandler = {}
local Cache = GetCache("Cache")

local function isRedM()
    return GetGameName() == "redm"
end

local function getMount(ped)
    if isRedM() then
        return GetMount(ped)
    end
    return nil
end

local function isOnMount(ped)
    if isRedM() then
        return IsPedOnMount(ped)
    end
    return false
end


local function getPedSeatInVehicle(vehicle, ped)
    for index = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
        if GetPedInVehicleSeat(vehicle, index) == ped then
            return index
        end
    end
    return false
end

---@param type string
---@param callback fun(...: any): void
function CacheHandler:onCacheChange(type, callback)
    CreateThread(function()
        local lastMountId = nil
        local lastIsOnMount = nil
        local lastWeaponHash = nil
        local lastIsArmed = nil
        local lastVehicleId = nil
        local lastSeat = nil

        while true do
           Wait(500)
            local ped = PlayerPedId()

            if type == "Weapon" then
                local currentWeaponHash = GetSelectedPedWeapon(ped)
                local isArmed = currentWeaponHash ~= GetHashKey("WEAPON_UNARMED")

                if currentWeaponHash ~= lastWeaponHash or isArmed ~= lastIsArmed then
                    lastWeaponHash = currentWeaponHash
                    lastIsArmed = isArmed
                    Cache:set('weapon', currentWeaponHash)
                    Cache:set('isArmed', isArmed)
                    TriggerEvent(('LGF_Cache:onChange:%s'):format("Weapon"), currentWeaponHash, isArmed, ped)
                    callback(currentWeaponHash, isArmed)
                end
            end

            if isRedM() then
                if type == "Mount" then
                    local currentMountId = getMount(ped)
                    local isOnMount = isOnMount(ped)

                    if currentMountId ~= lastMountId or isOnMount ~= lastIsOnMount then
                        lastMountId = currentMountId
                        lastIsOnMount = isOnMount
                        Cache:set('mount', currentMountId)
                        Cache:set('isOnMount', isOnMount)
                        TriggerEvent(('LGF_Cache:onChange:%s'):format("Mount"), currentMountId, isOnMount, ped)
                        callback(currentMountId, isOnMount)
                    end
                end
            end

            if not isRedM() then
                if type == "Vehicle" then
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    local seat = -1

                    if vehicle > 0 then
                        seat = getPedSeatInVehicle(vehicle, ped)

                        if vehicle ~= lastVehicleId or seat ~= lastSeat then
                            lastVehicleId = vehicle
                            lastSeat = seat
                            Cache:set('vehicleId', vehicle)
                            Cache:set('seat', seat)
                            TriggerEvent(('LGF_Cache:onChange:%s'):format("Vehicle"), vehicle, seat, ped)
                            callback(vehicle, seat)
                        end
                    else
                        if lastVehicleId ~= false or lastSeat ~= false then
                            lastVehicleId = false
                            lastSeat = false
                            Cache:set('vehicleId', false)
                            Cache:set('seat', false)
                            TriggerEvent(('LGF_Cache:onChange:%s'):format("Vehicle"), false, false, ped)
                            callback(false, false)
                        end
                    end
                end
            end
        end
    end)
end


RegisterCache("CacheHandler", CacheHandler)
