ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

--

local function CanSellToPed(ped)
	if not IsPedAPlayer(ped) and not IsEntityAMissionEntity(ped) and not IsPedInAnyVehicle(ped, false) and not IsEntityDead(ped) and IsPedHuman(ped) and GetEntityModel(ped) ~= GetHashKey("s_m_y_cop_01") and GetEntityModel(ped) ~= GetHashKey("s_m_y_dealer_01") and GetEntityModel(ped) ~= GetHashKey("mp_m_shopkeep_01") and ped ~= PlayerPedId() then 
		return true
	end
	return false
end

local function animsAction(animObj, player)
    Citizen.CreateThread(function()
        if not playAnim then
            local playerPed = player
            if DoesEntityExist(playerPed) then -- Check if ped exist
                dataAnim = animObj
  
                -- Play Animation
                RequestAnimDict(dataAnim.lib)
                while not HasAnimDictLoaded(dataAnim.lib) do
                    Citizen.Wait(0)
                end
                if HasAnimDictLoaded(dataAnim.lib) then
                    local flag = 0
                    if dataAnim.loop ~= nil and dataAnim.loop then
                        flag = 1
                    elseif dataAnim.move ~= nil and dataAnim.move then
                        flag = 49
                    end
  
                    TaskPlayAnim(playerPed, dataAnim.lib, dataAnim.anim, 8.0, -8.0, -1, flag, 0, 0, 0, 0)
                    playAnimation = true
                end
  
                -- Wait end animation
                while true do
                    Citizen.Wait(0)
                    if not IsEntityPlayingAnim(playerPed, dataAnim.lib, dataAnim.anim, 3) then
                        playAnim = false
                        TriggerEvent('ft_animation:ClFinish')
                        break
                    end
                end
            end -- end ped exist
        end
    end)
end

local function MakeEntityFaceEntity(entity1, entity2)
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading( entity1, heading )
end

local function RequestAndWaitDict(dictName) -- Request une animation (dict)
	if dictName and DoesAnimDictExist(dictName) and not HasAnimDictLoaded(dictName) then
		RequestAnimDict(dictName)
		while not HasAnimDictLoaded(dictName) do Citizen.Wait(100) end
	end
end

local function RequestAndWaitModel(modelName) -- Request un modèle de véhicule
	if modelName and IsModelInCdimage(modelName) and not HasModelLoaded(modelName) then
		RequestModel(modelName)
		while not HasModelLoaded(modelName) do Citizen.Wait(100) end
	end
end

--
local pnj = nil
local drugsell = false
local open = false
local mainMenu = RageUI.CreateMenu("Choix drogue", "Interaction", nil, nil, "root_cause5", xDrugSeller.Banniere)
mainMenu.Display.Header = true
mainMenu.Closed = function()
    open = false
    FreezeEntityPosition(pnj, false)
end

RegisterNetEvent('xDrugSeller:blips')
AddEventHandler('xDrugSeller:blips', function(pPos)
    PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
    PlaySoundFrontend(-1, "OOB_Start", "GTAO_FM_Events_Soundset", 1)
    PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", 1)
    local blipId = AddBlipForCoord(pPos.x, pPos.y, pPos.z)
    SetBlipSprite(blipId, 161)
    SetBlipScale(blipId, 1.2)
    SetBlipColour(blipId, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Vente de stupéfiants')
    EndTextCommandSetBlipName(blipId)
    Wait(60 * 1000)
    RemoveBlip(blipId)
    PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
    PlaySoundFrontend(-1, "FocusOut", "HintCamSounds", 1)
end)

RegisterCommand(xDrugSeller.Commande, function()
    if not drugsell then
        ESX.TriggerServerCallback("xDrugSeller:checkcops", function(can)
            if can then
                drugsell = true
                ESX.ShowNotification("Mode vente drogue ~g~activer~s~.")
            else
                ESX.ShowNotification("~r~Pas assez de policier en ville.")
            end
        end)
    else
        drugsell = false
        ESX.ShowNotification("Mode vente drogue ~r~désactiver~s~.")
    end
end)
TriggerEvent('chat:addSuggestion', ('/%s'):format(xDrugSeller.Commande), 'Vous permet d\'activer et de désactiver le mode vente de drogue.', nil)

local function MenuSelection(outEntity, pPos)
    pnj = outEntity
    if open then
        open = false
        RageUI.Visible(mainMenu, false)
    else
        open = true
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            while open do
                Wait(0)
                RageUI.IsVisible(mainMenu, function()
                    for _,v in pairs(xDrugSeller.Drugs) do
                        RageUI.Button(("~%s~→~s~ %s"):format(xDrugSeller.CouleurMenu, v.Label), nil, {RightBadge = RageUI.BadgeStyle.Star}, true, {
                            onActive = function()
                                local coord = GetEntityCoords(outEntity)
                                DrawMarker(0, coord.x, coord.y, coord.z + 1.1, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.2, 0.2, 0.2, xDrugSeller.MarkerColorR, xDrugSeller.MarkerColorG, xDrugSeller.MarkerColorB, xDrugSeller.MarkerOpacite, xDrugSeller.MarkerSaute, true, p19, xDrugSeller.MarkerTourne)
                            end,
                            onSelected = function()
                                local chance = math.random(0 , 100)
                                local callingchance = math.random(1, 2)
                                local gain = math.random(v.MinPrice, v.MaxPrice)
                                local selling = math.random(1, 4)

                                if chance <= 13 then
                                    RageUI.CloseAll()
                                    FreezeEntityPosition(PlayerPedId(), true)
                                    ESX.ShowAdvancedNotification("Citoyen", "Discussion", "Attendez un instant, je réfléchis.", "CHAR_ARTHUR", 1)
                                    if callingchance == 2 then TriggerServerEvent("xDrugSeller:Call", pPos) end
                                    local pCreate = CreateObject(GetHashKey('prop_phone_cs_frank'), 0, 0, 0, true)
                                    AttachEntityToEntity(pCreate, outEntity, GetPedBoneIndex(outEntity, 57005), 0.13, 0.02, 0.0, 90.0, 0, 0, 1, 1, 0, 1, 0, 1)
                                    animsAction({ lib = "cellphone@", anim = "cellphone_text_read_base" }, outEntity)
                                    Wait(4000)
                                    ESX.ShowAdvancedNotification("Citoyen", "Discussion", "Je ne suis pas intéressé !", "CHAR_ARTHUR", 1)
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    FreezeEntityPosition(outEntity, false)
                                    DeleteObject(pCreate)
                                else
                                    ESX.TriggerServerCallback("xDrugSeller:getDrug", function(can)
                                        if can then
                                            RageUI.CloseAll()
                                            RequestAndWaitDict("mp_common")
                                            RequestAndWaitModel("prop_meth_bag_01")                
                                            SetPedTalk(outEntity)
                                            PlayAmbientSpeech1(outEntity, 'GENERIC_HI', 'SPEECH_PARAMS_STANDARD')                     
                                            local cCreate = CreateObject(GetHashKey("prop_meth_bag_01"), 0, 0, 0, true)
                                            AttachEntityToEntity(cCreate, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.13, 0.02, 0.0, -90.0, 0, 0, 1, 1, 0, 1, 0, 1)
                                            TaskPlayAnim(PlayerPedId(), 'mp_common', 'givetake1_a', 8.0, 8.0, -1, 0, 1, false, false, false)
                                            TaskPlayAnim(outEntity, 'mp_common', 'givetake1_a', 8.0, 8.0, -1, 0, 1, false, false, false)
                                            Wait(1000)
                                            PlaySoundFrontend(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0)
                                            TaskWanderStandard(outEntity, 10.0, 10)
                                            PlayAmbientSpeech1(outEntity, 'GENERIC_THANKS', 'SPEECH_PARAMS_STANDARD')
                                            SetEntityAsMissionEntity(outEntity, true, true)
                                            SetPedCanRagdollFromPlayerImpact(outEntity, true)
                                            DeleteObject(cCreate)
                                            FreezeEntityPosition(outEntity, false)
                                        else
                                            FreezeEntityPosition(outEntity, false)
                                            RageUI.CloseAll()
                                        end
                                    end, v.Name, v.Label, gain, selling)
                                end
                            end
                        })
                    end
                end)
            end
        end)
    end
end

Citizen.CreateThread(function()
    while true do 
        local wait = 1000
        local pPos = GetEntityCoords(PlayerPedId())

        if drugsell and not IsPedInAnyVehicle(PlayerPedId()) then 
            wait = 250
            local retval, outEntity = FindFirstPed()
            local succesPed = nil 
            repeat
                pPos = GetEntityCoords(PlayerPedId())
                succesPed, outEntity = FindNextPed(retval)
                local cPos = GetEntityCoords(outEntity)
                local dst = Vdist(pPos.x, pPos.y, pPos.z, cPos.x, cPos.y, cPos.z)

                if dst <= 5.0 and CanSellToPed(outEntity) then 
                    wait = 5
                    SetBlockingOfNonTemporaryEvents(outEntity, true)
					PlayAmbientSpeech2(outEntity, "GENERIC_HI", "SPEECH_PARAMS_FORCE")
					SetPedCanRagdollFromPlayerImpact(outEntity, false)

                    if dst <= 2.5 then 
                        ESX.ShowHelpNotification(("Appuyez sur ~INPUT_CONTEXT~ pour ~%s~vendre votre drogue~s~."):format(xDrugSeller.CouleurMenu))
                        if IsControlJustPressed(1, 51) then
                            FreezeEntityPosition(outEntity, true)
                            ClearPedTasksImmediately(outEntity)
                            MakeEntityFaceEntity(PlayerPedId(), outEntity)
                            MakeEntityFaceEntity(outEntity, PlayerPedId())
                            MenuSelection(outEntity, pPos)
                        end
                    end
                end
            until not succesPed
            EndFindPed(retval)
        end
        Wait(wait)
    end
end)

--- Xed#1188
