-- Copyright (C) 2021  DoJoMan18
-- This script is licensed under "GNU General Public License v3.0". https://www.gnu.org/licenses/gpl-3.0.html

_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Fluffy's Weapons", "~b~© 2021 Team Reaver")
_menuPool:Add(mainMenu)
local raw = LoadResourceFile(GetCurrentResourceName(), 'weapons.json')
local data = json.decode(raw)
local SubMenus = {}; Items = {}

SubMenus[mainMenu] = mainMenu

-- Functions
function CreateWeaponMenu(menu)

    for k,v in pairs(data) do
        if not IsWeaponValid(GetHashKey(k)) then
            local Unavailable = NativeUI.CreateItem("~m~".. v.label, "Weapon unavailable")
            Unavailable:SetRightBadge(BadgeStyle.Lock)
            menu:AddItem(Unavailable)

            table.insert(Items, {Unavailable, k, false})
        else
            if not SubMenus[k] then
                SubMenus[k] = _menuPool:AddSubMenu(menu, v.label)
            end
    
            local Spawn = NativeUI.CreateItem("~r~Equip/Remove " .. v.label, "Add or remove this weapon to/from your inventory.")
            SubMenus[k]:AddItem(Spawn)
            table.insert(Items, {Spawn, k})
    
            for attachments_key,attachments_value in pairs(v.attachments) do
                if attachments_value then
                    SubMenus[attachments_key] = _menuPool:AddSubMenu(SubMenus[k], attachments_key)
        
                    for _, attach_item  in ipairs(attachments_value) do
                        attach = NativeUI.CreateItem(attach_item.label, "Add or remove attachment to/from your weapon.")
                        SubMenus[attachments_key]:AddItem(attach)
                        table.insert(Items, {attach, k, attach_item.value})
                    end
                end
            end
        end
    end

    for SubMenuIndex, SubMenu in pairs(SubMenus) do
        SubMenu.OnItemSelect = function(Sender, Item, Index)
            for _, Value in pairs(Items) do
                if Item == Value[1] then
                    if Value[3] ~= nil then
                        if Value[3] == false then
                            ShowNotification("Buy this weapon at: https://fluffy.tebex.io/")
                        elseif HasPedGotWeaponComponent(GetPlayerPed(-1), GetHashKey(Value[2]), GetHashKey(Value[3])) then
                            RemoveWeaponComponentFromPed(GetPlayerPed(-1), GetHashKey(Value[2]), GetHashKey(Value[3]))
                        else
                            GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(Value[2]), GetHashKey(Value[3]))
                        end
                    else
                        if HasPedGotWeapon(GetPlayerPed(-1), GetHashKey(Value[2])) then
                            RemoveWeaponFromPed(GetPlayerPed(-1), GetHashKey(Value[2]))
                        else
                            GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(Value[2]), 1000, false, true)
                        end
                    end
                end
            end
        end
    end
end

-- Creating and maintaining menu
function GenerateMenu(menu) 
    mainMenu:Clear()

    CreateWeaponMenu(mainMenu)
    
    -- refresh menu index
    _menuPool:RefreshIndex()
    mainMenu:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
end

GenerateMenu(mainMenu)

RegisterCommand('+weapons', function()
    mainMenu:Visible(not mainMenu:Visible())
end, false)

RegisterKeyMapping('+weapons', "Fluffy's Weapons Menu", 'keyboard', 'F7')

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:ProcessMenus()
    end
end)

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end