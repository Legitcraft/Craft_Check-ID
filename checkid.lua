local playerDistances = {}
local isAnimating = false

-- Define your animation dictionary and animation name
local animDict = "mp_common"
local animName = "givetake2_a"

-- Adjust the height above the head
local heightAboveHead = 0.4 -- Increase this value to raise the label higher

Citizen.CreateThread(function()
    while true do
        local playerPos = GetEntityCoords(PlayerPedId())
        
        for _, id in ipairs(GetActivePlayers()) do
            local targetPed = GetPlayerPed(id)
            local boneIndex = GetPedBoneIndex(targetPed, 12844) -- 12844 is the head bone ID
            local targetPos = GetWorldPositionOfEntityBone(targetPed, boneIndex)
            
            local distance = #(playerPos - targetPos)
            playerDistances[id] = distance
            
            local labelX, labelY, labelZ = targetPos.x, targetPos.y, targetPos.z + heightAboveHead

            if IsControlPressed(0, Config.Key) and playerDistances[id] and playerDistances[id] < 20 then
                DrawText3D(labelX, labelY, labelZ, GetPlayerServerId(id), 255, 255, 255)
                
                if not isAnimating then
                    isAnimating = true
                    PlayAnimation()
                end
            else
                if isAnimating then
                    isAnimating = false
                    StopAnimation()
                end
            end
        end
        
        Citizen.Wait(0)
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        local dist = GetDistanceBetweenCoords(GetGameplayCamCoords(), x, y, z, 1)
        local scale = 1 * (1 / dist) * (1 / GetGameplayCamFov()) * 100

        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function PlayAnimation()
    RequestAnimDict(animDict)
    
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
    
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -8.0, -1, 0, 0, 0, 0, 0)
end

function StopAnimation()
    ClearPedTasks(PlayerPedId())
end
