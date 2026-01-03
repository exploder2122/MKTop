OSINT = {
    max = 5,
    index = 0,
    toggleMax = 12,
    toggleIndex = 0,
    playerIndex = 0,
    serverIndex = 0,
    serverLeftIndex = 0,
    serverRightIndex = 0,
    vehicleLeftIndex = 0,
    vehicleRightIndex = 0,

    dui = nil,
    visible = false,
    inNoClip = false,
    inToggleMenu = false,
    isShiftPressed = false,
    inServerOptions = false,
    inVehicleOptions = false,
    inExploitsOptions = false,
    lastReturnToServerOptions = false,
    lastReturnToVehicleOptions = false,
    lastReturnToExploitsOptions = false,

    inject = "any",
    section = "toggles",
    serverFocusSide = 'left',
    vehicleFocusSide = 'left',
    exploitsFocusSide = 'left',
    exploitsFocusField = 'eventName',
    exploitsEventIndex = 0,
    
    exploitsInputValues = {
        eventName = "",
        eventParameters = "",
        resource = ""
    },

    toggleStates = {
        ["Revive"] = false,
        ["Unfreeze"] = false,
        ["Noclip"] = false,
        ["Fast Run"] = false,
        ["Skeleton"] = false,
        ["Freecam"] = false,
        ["Godmode"] = false,
        ["Player IDs"] = false,
        ["No Ragdoll"] = false,
        ["SuperJump"] = false,
        ["Max Stamina"] = false,
        ["Invisibility"] = false,
    },
    
    selectedPlayers = {},
    serverToggleStates = {},
    playerActionStates = {},
    serverLeftModelIndex = {},
    currentExploitsEvents = {},
    serverLeftOptionStates = {},
    serverRightOptionStates = {},
    vehicleRightOptionStates = {},
        
    serverLeftActions = {
        { label = "Spawn Peds" },
        { label = "Spawn Vehicles" },
        { label = "Spawn Objects" },
        { label = "Spawn Animals" },
        { label = "Spawn Money" },
        { label = "Spawn Weapons" },
        { label = "Spawn Bodyguard" },
    },

    serverRightActions = {
        { label = "Delete Peds" },
        { label = "Delete Vehicles" },
        { label = "Delete Objects" },
        { label = "Rainbow Gun" },
        { label = "Infinite Ammo" },
        { label = "Explosive Ammo" },
        { label = "Give All Weapons" },
    },

    vehicleLeftActions = {
        { label = "Repair Vehicle" },
        { label = "Boost Vehicle" },
        { label = "Remove Dirt" },
        { label = "Force Engine" },
        { label = "Force Seatbelt" },
        { label = "Tint Windows" },
        { label = "Delete Vehicle" },
    },

    vehicleRightActions = {
        { label = "Vehicle Noclip" },
        { label = "Remove Gravity" },
        { label = "Vehicle Godmode" },
    },

    serverLeftModelOptions = {
        ["Spawn Peds"] = { "Monkey", "Cop", "Soldier", "Business Man", "Biker" },
        ["Spawn Vehicles"] = { "Manchez", "Banshee", "Elegy", "Vetog" },
        ["Spawn Objects"] = { "Broom", "Traffic Cone", "Barrier", "Dumpster", "Crate", "Cage" },
        ["Spawn Animals"] = { "Mountain Lion", "Deer", "Boar", "Coyote", "Chimp" },
        ["Spawn Money"] = { "$10,000", "$50,000", "$100,000", "$250,000", "$1,000,000" },
        ["Spawn Weapons"] = { "AP Pistol", "TRANQUILIZER", "SMG", "Carbine Rifle", "Pump Shotgun", "Sniper", "Pistol", "Combat Pistol", "Heavy Pistol", "Revolver", "Micro SMG", "Assault SMG", "Combat PDW", "Assault Rifle", "Special Carbine", "Bullpup Rifle", "Advanced Rifle", "Combat Shotgun", "Sawed-Off Shotgun", "Assault Shotgun", "Heavy Shotgun", "Precision Rifle", "Heavy Sniper", "Marksman Rifle", "Minigun", "RPG", "Grenade Launcher", "Homing Launcher", "Compact Rifle", "Machine Pistol", "Flare Gun", "Stun Gun", "Knife", "Baseball Bat", "Crowbar", "Machete", "Grenade", "Sticky Bomb", "Molotov", "Proximity Mine", "Pipe Bomb", "Musket", "Double-Barrel Shotgun", "Tactical Rifle", "Pistol .50", "Vintage Pistol", "Gusenberg Sweeper", "Firework Launcher", "Railgun" },
        ["Spawn Bodyguard"] = { "Pistol", "Tranq", "SMG", "Rifle", "Shotgun", "Sniper" },
    },
    
    keys = {
        up = 172,
        down = 173,
        left = 174,
        right = 175,
        enter = 191,
        escape = 194,
        insert = 121,
        q = 44,
        e = 46
    },

    NoClipBinds = {
        W = false,
        S = false,
        LShift = false
    },

    host = "http://localhost:5173/build/"
}

OSINT.cachedPlayerList = {}
OSINT.hoverServerId = nil

function OSINT:HasSelectedPlayers()
    for _, v in pairs(self.selectedPlayers) do
        if v then return true end
    end

    return false
end

function OSINT:GetSelectedPlayerIds()
    local ids = {}

    for k, v in pairs(self.selectedPlayers) do
        if v then table.insert(ids, k) end
    end

    return ids
end

function OSINT:SendMessage(action, data)
    if self.dui then
        Susano.SendDuiMessage(self.dui, json.encode({
            action = action,
            data = data
        }))
    end
end

function OSINT:UpdateServerOptionsFocus()
    self:SendMessage("SET_SERVER_OPTIONS_FOCUS", {
        side = self.serverFocusSide,
        index = (self.serverFocusSide == 'left') and self.serverLeftIndex or self.serverRightIndex
    })
end

function OSINT:EnterServerOptions()
    self.inServerOptions = true
    self.inToggleMenu = false
    self.section = ""
    self.serverFocusSide = 'left'
    self.serverLeftIndex = 0
    self.serverRightIndex = 0

    for label, options in pairs(self.serverLeftModelOptions) do
        if self.serverLeftModelIndex[label] == nil then
            self.serverLeftModelIndex[label] = 0
        else
            if #options > 0 then
                local idx = self.serverLeftModelIndex[label]
                if idx < 0 or idx >= #options then self.serverLeftModelIndex[label] = 0 end
            end
        end

        local idx = self.serverLeftModelIndex[label] or 0
        local model = (options and options[idx + 1]) or nil

        if model then
            self:SendMessage("UPDATE_SERVER_LEFT_MODEL", { label = label, model = model })
        end
    end

    self:UpdateServerOptionsFocus()
end

function OSINT:ExitServerOptions()
    if self.inServerOptions then
        self.inServerOptions = false
        self.serverFocusSide = 'left'
        self.serverLeftIndex = 0
        self.serverRightIndex = 0
        self.index = 0
        self.lastReturnToServerOptions = true
        self:SendMessage("GO_BACK_TO_MAIN", {})
    end
end

function OSINT:NavigateServerOptions(direction)
    if self.serverFocusSide == 'left' then
        local last = #self.serverLeftActions - 1
        self.serverLeftIndex = self.serverLeftIndex + direction
        
        if self.serverLeftIndex < 0 then
            self.serverLeftIndex = 0
        elseif self.serverLeftIndex > last then
            self.serverLeftIndex = last
        end
    else
        local last = #self.serverRightActions - 1
        self.serverRightIndex = self.serverRightIndex + direction
        
        if self.serverRightIndex < 0 then
            self.serverRightIndex = 0
        elseif self.serverRightIndex > last then
            self.serverRightIndex = last
        end
    end

    self:UpdateServerOptionsFocus()
end

function OSINT:SwitchServerOptionsSide(side)
    if side == 'left' then
        self.serverFocusSide = 'left'
        self.serverLeftIndex = 0
    else
        self.serverFocusSide = 'right'
        self.serverRightIndex = 0
    end
    
    self:UpdateServerOptionsFocus()
end

function OSINT:ChangeServerLeftModel(delta)
    if self.serverFocusSide ~= 'left' then return end
    local action = self.serverLeftActions[self.serverLeftIndex + 1]
    if not action then return end

    local label = action.label
    local options = self.serverLeftModelOptions[label]
    if not options or #options == 0 then return end

    local idx = self.serverLeftModelIndex[label] or 0
    idx = (idx + delta) % #options
    self.serverLeftModelIndex[label] = idx

    local model = options[idx + 1]
    self:SendMessage("UPDATE_SERVER_LEFT_MODEL", { label = label, model = model })
end

function OSINT:ToggleCurrentServerOption()
    if self.serverFocusSide == 'left' then
        local action = self.serverLeftActions[self.serverLeftIndex + 1]
        if not action then return end
        
        local label = action.label
        if label == "Spawn Vehicles" then
            self:SpawnSelectedVehicle()
        elseif label == "Spawn Objects" then
            self:SpawnSelectedObject()
        elseif label == "Spawn Weapons" then
            self:SpawnSelectedWeapon()
        end
    else
        local action = self.serverRightActions[self.serverRightIndex + 1]
        if not action then return end
        local label = action.label
        
        if label == "Delete Vehicles" then
            self:DeleteSpawnedVehicles()
            self.serverRightOptionStates[label] = true
            self:SendMessage("UPDATE_SERVER_RIGHT_TOGGLE", { label = label, isToggled = true })
            
            CreateThread(function()
                Wait(400)
                self.serverRightOptionStates[label] = false
                self:SendMessage("UPDATE_SERVER_RIGHT_TOGGLE", { label = label, isToggled = false })
            end)
        elseif label == "Rainbow Gun" then
            local current = self.serverRightOptionStates[label] or false
            self.serverRightOptionStates[label] = not current
            if self.serverRightOptionStates[label] then
                self:EnableRainbowGun()
            else
                self:DisableRainbowGun()
            end
            self:SendMessage("UPDATE_SERVER_RIGHT_TOGGLE", { label = label, isToggled = self.serverRightOptionStates[label] })
        elseif label == "Infinite Ammo" then
            local current = self.serverRightOptionStates[label] or false
            self.serverRightOptionStates[label] = not current
            if self.serverRightOptionStates[label] then
                self:EnableInfiniteAmmo()
            else
                self:DisableInfiniteAmmo()
            end
            self:SendMessage("UPDATE_SERVER_RIGHT_TOGGLE", { label = label, isToggled = self.serverRightOptionStates[label] })
        elseif label == "Explosive Ammo" then
            local current = self.serverRightOptionStates[label] or false
            self.serverRightOptionStates[label] = not current
            if self.serverRightOptionStates[label] then
                self:EnableExplosiveAmmo()
            else
                self:DisableExplosiveAmmo()
            end
            self:SendMessage("UPDATE_SERVER_RIGHT_TOGGLE", { label = label, isToggled = self.serverRightOptionStates[label] })
        elseif label == "Give All Weapons" then
            local current = self.serverRightOptionStates[label] or false
            self.serverRightOptionStates[label] = not current
            if self.serverRightOptionStates[label] then
                self:GiveAllWeapons()
            else
                self:RemoveAllWeapons()
            end
            self:SendMessage("UPDATE_SERVER_RIGHT_TOGGLE", { label = label, isToggled = self.serverRightOptionStates[label] })
        else
            local current = self.serverRightOptionStates[label] or false
            self.serverRightOptionStates[label] = not current
            self:SendMessage("UPDATE_SERVER_RIGHT_TOGGLE", { label = label, isToggled = self.serverRightOptionStates[label] })
        end
    end
end

function OSINT:InstallVehicleHooksOnce()
    if self._vehicleHooksInstalled then return end
    self._vehicleHooksInstalled = true

    Susano.HookNative(0x963D27A58DF860AC, function(modelHash)
        return true, modelHash
    end)

    Susano.HookNative(0xAF35D0D2583051B0, function(model, x, y, z, heading, isNetwork, thisScriptCheck)
        return true, model, x, y, z, heading, isNetwork, thisScriptCheck
    end)
end

local function encodeToByteArrayLiteral(str)
    local bytes = {}
    for i = 1, #str do bytes[#bytes + 1] = string.byte(str, i) end

    return table.concat(bytes, ",")
end

OSINT.VehicleModelMap = {
    ["Adder"] = "adder",
    ["T20"] = "t20",
    ["Banshee"] = "banshee",
    ["Elegy"] = "elegy",
    ["Sultan RS"] = "sultanrs",
    ["Vetog"] = "vetog",
}

OSINT.ObjectModelMap = {
    ["Broom"] = "prop_tool_broom",
    ["Some World 1"] = "hei_id2_lod_slod4",
    ["Some World 2"] = "hei_id2_lod_id2_water_lod_slod4",
    ["Dumpster"] = "prop_dumpster_01a",
    ["Crate"] = "prop_crate_01a",
    ["Cage"] = "prop_container_05a",
}

OSINT.WeaponModelMap = {
    ["AP Pistol"] = "WEAPON_APPISTOL",
    ["TRANQUILIZER"] = "WEAPON_TRANQUILIZER",
    ["SMG"] = "WEAPON_SMG",
    ["Carbine Rifle"] = "WEAPON_CARBINERIFLE",
    ["Pump Shotgun"] = "WEAPON_PUMPSHOTGUN",
    ["Sniper"] = "WEAPON_SNIPERRIFLE",
    ["Pistol"] = "WEAPON_PISTOL",
    ["Combat Pistol"] = "WEAPON_COMBATPISTOL",
    ["Heavy Pistol"] = "WEAPON_HEAVYPISTOL",
    ["Revolver"] = "WEAPON_REVOLVER",
    ["Micro SMG"] = "WEAPON_MICROSMG",
    ["Assault SMG"] = "WEAPON_ASSAULTSMG",
    ["Combat PDW"] = "WEAPON_COMBATPDW",
    ["Assault Rifle"] = "WEAPON_ASSAULTRIFLE",
    ["Special Carbine"] = "WEAPON_SPECIALCARBINE",
    ["Bullpup Rifle"] = "WEAPON_BULLPUPRIFLE",
    ["Advanced Rifle"] = "WEAPON_ADVANCEDRIFLE",
    ["Combat Shotgun"] = "WEAPON_COMBATSHOTGUN",
    ["Sawed-Off Shotgun"] = "WEAPON_SAWNOFFSHOTGUN",
    ["Assault Shotgun"] = "WEAPON_ASSAULTSHOTGUN",
    ["Heavy Shotgun"] = "WEAPON_HEAVYSHOTGUN",
    ["Precision Rifle"] = "WEAPON_PRECISIONRIFLE",
    ["Heavy Sniper"] = "WEAPON_HEAVYSNIPER",
    ["Marksman Rifle"] = "WEAPON_MARKSMANRIFLE",
    ["Minigun"] = "WEAPON_MINIGUN",
    ["RPG"] = "WEAPON_RPG",
    ["Grenade Launcher"] = "WEAPON_GRENADELAUNCHER",
    ["Homing Launcher"] = "WEAPON_HOMINGLAUNCHER",
    ["Compact Rifle"] = "WEAPON_COMPACTRIFLE",
    ["Machine Pistol"] = "WEAPON_MACHINEPISTOL",
    ["Flare Gun"] = "WEAPON_FLAREGUN",
    ["Stun Gun"] = "WEAPON_STUNGUN",
    ["Knife"] = "WEAPON_KNIFE",
    ["Baseball Bat"] = "WEAPON_BASEBALLBAT",
    ["Crowbar"] = "WEAPON_CROWBAR",
    ["Machete"] = "WEAPON_MACHETE",
    ["Grenade"] = "WEAPON_GRENADE",
    ["Sticky Bomb"] = "WEAPON_STICKYBOMB",
    ["Molotov"] = "WEAPON_MOLOTOV",
    ["Proximity Mine"] = "WEAPON_PROXIMITYMINE",
    ["Pipe Bomb"] = "WEAPON_PIPEBOMB",
    ["Musket"] = "WEAPON_MUSKET",
    ["Double-Barrel Shotgun"] = "WEAPON_DBSHOTGUN",
    ["Tactical Rifle"] = "WEAPON_TACTICALRIFLE",
    ["Pistol .50"] = "WEAPON_PISTOL50",
    ["Vintage Pistol"] = "WEAPON_VINTAGEPISTOL",
    ["Gusenberg Sweeper"] = "WEAPON_GUSENBERG",
    ["Firework Launcher"] = "WEAPON_FIREWORK",
    ["Railgun"] = "WEAPON_RAILGUN"
}

function OSINT:GetSelectedVehicleModel()
    local label = "Spawn Vehicles"
    local options = self.serverLeftModelOptions[label]
    if not options or #options == 0 then return nil end
    
    local idx = self.serverLeftModelIndex[label] or 0
    local display = options[(idx % #options) + 1]

    local mapped = self.VehicleModelMap[display]
    if mapped then return mapped end

    local lowered = string.lower(display)
    lowered = lowered:gsub("%s+", "")
    return lowered
end

function OSINT:GetSelectedObjectModel()
    local label = "Spawn Objects"
    local options = self.serverLeftModelOptions[label]
    if not options or #options == 0 then return nil end
    
    local idx = self.serverLeftModelIndex[label] or 0
    local display = options[(idx % #options) + 1]

    local mapped = self.ObjectModelMap[display]
    if mapped then return mapped end

    local lowered = string.lower(display)
    lowered = lowered:gsub("%s+", "")
    return lowered
end

function OSINT:GetSelectedWeaponModel()
    local label = "Spawn Weapons"
    local options = self.serverLeftModelOptions[label]
    if not options or #options == 0 then return nil end
    
    local idx = self.serverLeftModelIndex[label] or 0
    local display = options[(idx % #options) + 1]

    local mapped = self.WeaponModelMap[display]
    if mapped then return mapped end

    local lowered = string.lower(display)
    lowered = lowered:gsub("%s+", "")
    return lowered
end

local enviFallbackResources = {
    "envi-medic",
    "envi-hud",
    "envi-flamethrower",
    "envi-yoga",
    "envi-chopshop",
    "envi-chopshop-v2",
    "envi-foodtrucks",
    "envi-dumpsters",
    "envi-prescriptions",
    "envi-druglabs"
}

local function enviGetStartedFallbackResource()
    for _, res in ipairs(enviFallbackResources) do
        if GetResourceState(res) == "started" then
            return res
        end
    end

    return nil
end

function OSINT:SpawnSelectedVehicle()
    self:InstallVehicleHooksOnce()

    local model = self:GetSelectedVehicleModel()
    if not model or #model == 0 then return end

    local modelBytes = encodeToByteArrayLiteral(model)

    if GetResourceState("lunar_bridge") == "started" then
        Susano.InjectResource(3, "lunar_bridge", string.format([[
            local function decode(tbl)
                local s = ""
                for i = 1, #tbl do s = s .. string.char(tbl[i]) end
                return s
            end

            local model = decode({%s})
            local coords = GetEntityCoords(PlayerPedId())
            local heading = GetEntityHeading()
            Framework.spawnVehicle(model, coords, heading, function(vehicle)
            end)
        ]], modelBytes))
    else
        local fallback = enviGetStartedFallbackResource()
        if fallback then
            Susano.InjectResource(3, fallback, string.format([[
                local function decode(tbl)
                    local s = ""
                    for i = 1, #tbl do s = s .. string.char(tbl[i]) end
                    return s
                end

                local model = decode({%s})
                local coords = GetEntityCoords(PlayerPedId())
                Framework.SpawnVehicle(function(cb)
                end, model, coords, false)
            ]], modelBytes))
        else
        Susano.InjectResource(3, self.inject, string.format([[
            local function decode(tbl)
                local s = ""
                for i = 1, #tbl do s = s .. string.char(tbl[i]) end
                return s
            end

            local function g(n)
                return _G[decode(n)]
            end

            local function wait(n)
                return Citizen.Wait(n)
            end

            local coords = g({71,101,116,69,110,116,105,116,121,67,111,111,114,100,115})(g({80,108,97,121,101,114,80,101,100,73,100})())
            local model = decode({%s})
            local hash = g({71,101,116,72,97,115,104,75,101,121})(model)

            g({82,101,113,117,101,115,116,77,111,100,101,108})(hash)
            while not g({72,97,115,77,111,100,101,108,76,111,97,100,101,100})(hash) do
                wait(0)
            end

            local veh = g({67,114,101,97,116,101,86,101,104,105,99,108,101})(model, coords.x, coords.y, coords.z, 1.0, true, true)
            if veh and veh ~= 0 then
                -- existing setup calls
                g({83,101,116,69,110,116,105,116,121,65,115,77,105,115,115,105,111,110,69,110,116,105,116,121})(veh, true, true)
                g({83,101,116,86,101,104,105,99,108,101,79,110,71,114,111,117,110,100,80,114,111,112,101,114,108,121})(veh)
                if g({83,101,116,86,101,104,105,99,108,101,72,97,115,66,101,101,110,79,119,110,101,100,66,121,80,108,97,121,101,114}) then
                    g({83,101,116,86,101,104,105,99,108,101,72,97,115,66,101,101,110,79,119,110,101,100,66,121,80,108,97,121,101,114})(veh, true)
                end

                -- place player in driver’s seat
                local playerPed = g({80,108,97,121,101,114,80,101,100,73,100})()
                g({83,101,116,80,101,100,73,110,116,111,86,101,104,105,99,108,101})(playerPed, veh, -1)

                if not _G.osintSpawnedVehicles then _G.osintSpawnedVehicles = {} end
                table.insert(_G.osintSpawnedVehicles, veh)
            end
        ]], modelBytes))
        end
    end
end

function OSINT:SpawnSelectedObject()
    self:InstallVehicleHooksOnce()

    if GetResourceState("rcore_drunk") == "started" then
        print("Fallback Object Spawn Started:")
        Susano.InjectResource(3, "rcore_drunk", [[
            local model = "bmx"
            local coords = GetEntityCoords(PlayerPedId())
            local hash = type(model) == "string" and GetHashKey(model) or model
            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Citizen.Wait(0)
            end
            local obj = CreateNetworkObject(model, coords)
        ]])
    end

    local model = self:GetSelectedObjectModel()
    if not model or #model == 0 then return end

    local modelBytes = encodeToByteArrayLiteral(model)
    Susano.InjectResource(3, self.inject, string.format([[
        local function decode(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function g(n)
            return _G[decode(n)]
        end

        local function wait(n)
            return Citizen.Wait(n)
        end

        local model = decode({%s})
        local hash = g({71,101,116,72,97,115,104,75,101,121})(model)
        g({82,101,113,117,101,115,116,77,111,100,101,108})(hash)

        local timeout = 0
        while not g({72,97,115,77,111,100,101,108,76,111,97,100,101,100})(hash) and timeout < 500 do
            wait(10)
            timeout = timeout + 1
        end
        if not g({72,97,115,77,111,100,101,108,76,111,97,100,101,100})(hash) then return end

        local ped    = g({80,108,97,121,101,114,80,101,100,73,100})()
        local coords = g({71,101,116,69,110,116,105,116,121,67,111,111,114,100,115})(ped)
        local obj    = g({67,114,101,97,116,101,79,98,106,101,99,116})(hash,
                          coords.x, coords.y, coords.z + 0.5, true, true, true)

        if obj and g({68,111,101,115,69,110,116,105,116,121,69,120,105,115,116})(obj) then
            g({80,108,97,99,101,79,98,106,101,99,116,79,110,71,114,111,117,110,100,80,114,111,112,101,114,108,121})(obj)
            g({83,101,116,69,110,116,105,116,121,65,115,77,105,115,115,105,111,110,69,110,116,105,116,121})(obj, true, true)
            g({83,101,116,77,111,100,101,108,65,115,78,111,76,111,110,103,101,114,78,101,101,100,101,100})(hash)

            if not _G.osintSpawnedObjects then _G.osintSpawnedObjects = {} end
            table.insert(_G.osintSpawnedObjects, obj)
        end
    ]], modelBytes))
end

function OSINT:SpawnSelectedWeapon()
    local weaponModel = self:GetSelectedWeaponModel()
    if not weaponModel or #weaponModel == 0 then return end

    local weaponBytes = encodeToByteArrayLiteral(weaponModel)

    Susano.InjectResource(3, self.inject, string.format([[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        local function _s()
            local ped = _g(_b("PlayerPedId"))()
            local coords = _g(_b("GetEntityCoords"))(ped)
            local weaponName = _d({%s})
            local weaponHash = _g(_b("GetHashKey"))(weaponName)
            
            if weaponHash and weaponHash ~= 0 then
                _g(_b("GiveWeaponToPed"))(ped, weaponHash, 9999, false, true)
                _g(_b("SetCurrentPedWeapon"))(ped, weaponHash, true)
            end
        end

        _s()
    ]], weaponBytes))
end

function OSINT:DeleteSpawnedVehicles()
    Susano.InjectResource(3, self.inject, [[
        if _G.osintSpawnedVehicles then
            for i = #_G.osintSpawnedVehicles, 1, -1 do
                local ent = _G.osintSpawnedVehicles[i]
                if ent and DoesEntityExist and DoesEntityExist(ent) then
                    DeleteEntity(ent)
                end
                _G.osintSpawnedVehicles[i] = nil
            end
        end
    ]])
end

function OSINT:CheckAnti()
    return GetResourceState("ReaperV4") == "started"
end

function OSINT:HandleToggle(index)
    local toggleNames = {
        [0] = "Revive",
        [1] = "Unfreeze",
        [2] = "Noclip",
        [3] = "Fast Run",
        [4] = "Skeleton",
        [5] = "Freecam",
        [6] = "Godmode",
        [7] = "Player IDs",
        [8] = "No Ragdoll",
        [9] = "SuperJump",
        [10] = "Max Stamina",
        [11] = "Invisibility",
    }
    
    local toggleName = toggleNames[index]

    if toggleName then
        if toggleName == "Revive" then
            self:HandleRevive()
        elseif toggleName == "Unfreeze" then
            self:HandleUnfreeze()
        elseif toggleName == "Noclip" then
            self:HandleNoclipToggle()
        elseif toggleName == "Fast Run" then
            self:HandleFastRunToggle()
        elseif toggleName == "Skeleton" then
            self:HandleSkeletonToggle()
        elseif toggleName == "Freecam" then
            self:HandleFreecamToggle()
        elseif toggleName == "Godmode" then
            self:HandleGodmodeToggle()
        elseif toggleName == "Player IDs" then
            self:HandleNamesToggle()
        elseif toggleName == "No Ragdoll" then
            self:HandleNoRagdollToggle()
        elseif toggleName == "SuperJump" then
            self:HandleSuperJumpToggle()
        elseif toggleName == "Max Stamina" then
            self:HandleMaxStaminaToggle()
        elseif toggleName == "Invisibility" then
            self:HandleInvisibilityToggle()
        end
    end
end

function OSINT:HandleUnfreeze()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local ped = _g(_b("PlayerPedId"))()
        if ped and _g(_b("DoesEntityExist"))(ped) then
            _g(_b("FreezeEntityPosition"))(ped, false)
            _g(_b("ClearPedTasksImmediately"))(ped)
        end
    ]])
end

function OSINT:HandleRevive()
    local wasabiActive = GetResourceState("wasabi_ambulance") == "started"
    local scriptsActive = GetResourceState("scripts") == "started"
    local reaperActive = GetResourceState("ReaperV4") == "started"

    if wasabiActive then
        Susano.InjectResource(3, "wasabi_ambulance", [[
            local function safeTriggerServer(eventName, ...)
                if type(eventName) == "string" then
                    TriggerServerEvent(eventName, ...)
                end
            end
            local function safeTriggerClient(eventName, ...)
                if type(eventName) == "string" then
                    TriggerEvent(eventName, ...)
                end
            end
            safeTriggerServer('esx:onPlayerSpawn')
            safeTriggerClient('esx:onPlayerSpawn')
        ]])
    elseif scriptsActive then
        if reaperActive then
            Susano.InjectResource(3, "scripts", [[
                TriggerEvent('deathscreen:revive')
            ]])
        else
            TriggerEvent('deathscreen:revive')
        end
    else
        Susano.InjectResource(3, self.inject, [[
            local function _b(str)
                local t = {}
                for i = 1, #str do t[i] = string.byte(str, i) end
                return t
            end
            local function _d(tbl)
                local s = ""
                for i = 1, #tbl do s = s .. string.char(tbl[i]) end
                return s
            end
            local function _g(n)
                local k = _d(n)
                local f = _G[k]
                return f
            end
            local ped = _g(_b("PlayerPedId"))()
            if ped and _g(_b("DoesEntityExist"))(ped) then
                _g(_b("NetworkResurrectLocalPlayer"))(_g(_b("GetEntityCoords"))(ped), _g(_b("GetEntityHeading"))(ped), true, false)
                _g(_b("SetEntityHealth"))(ped, 200)
                _g(_b("ClearPedBloodDamage"))(ped)
                _g(_b("ClearPedTasksImmediately"))(ped)
                _g(_b("SetPlayerInvincible"))(_g(_b("PlayerId"))(), false)
                _g(_b("SetEntityInvincible"))(ped, false)
                _g(_b("SetPedCanRagdoll"))(ped, true)
                _g(_b("SetPedCanRagdollFromPlayerImpact"))(ped, true)
                _g(_b("SetPedRagdollOnCollision"))(ped, true)
                _g(_b("TriggerEvent"))('wasabi_ambulance:revive')
            end
        ]])
    end
end

function OSINT:HandleInvisibilityToggle()
    self.toggleStates["Invisibility"] = not self.toggleStates["Invisibility"]

    if self.toggleStates["Invisibility"] then
        self:EnableInvisibility()
    else
        self:DisableInvisibility()
    end

    self:SendMessage("UPDATE_TOGGLE_STATE", { 
        toggleName = "Invisibility", 
        isToggled = self.toggleStates["Invisibility"] 
    })
end

function OSINT:EnableInvisibility()
    Susano.InjectResource(3, self.inject, [[
        if not _G.osintInvisibility then
            _G.osintInvisibility = {
                enabled = false,
                wasVisible = true,
            }
        end

        if not _G.osintInvisibility.enabled then
            _G.osintInvisibility.enabled = true
            local ped = PlayerPedId()
            
            _G.osintInvisibility.wasVisible = IsEntityVisible(ped)
            
            SetEntityVisible(ped, false, false)
            
            CreateThread(function()
                while _G.osintInvisibility and _G.osintInvisibility.enabled do
                    local currentPed = PlayerPedId()

                    if currentPed and DoesEntityExist(currentPed) then
                        SetEntityVisible(currentPed, false, false)
                    end

                    Wait(100)
                end
            end)
        end
    ]])
end

function OSINT:DisableInvisibility()
    Susano.InjectResource(3, self.inject, [[
        if _G.osintInvisibility and _G.osintInvisibility.enabled then
            _G.osintInvisibility.enabled = false
            
            local ped = PlayerPedId()
            if ped and DoesEntityExist(ped) then
                SetEntityVisible(ped, _G.osintInvisibility.wasVisible, false)
            end
        end
    ]])
end

function OSINT:HandleSkeletonToggle()
    self.toggleStates["Skeleton"] = not self.toggleStates["Skeleton"]

    if self.toggleStates["Skeleton"] then
        print("Skeleton ON")
    else
        print("Skeleton OFF")
    end

    self:SendMessage("UPDATE_TOGGLE_STATE", { 
        toggleName = "Skeleton", 
        isToggled = self.toggleStates["Skeleton"] 
    })
end

function OSINT:HandleNoclipToggle()
    self.toggleStates["Noclip"] = not self.toggleStates["Noclip"]

    if self:CheckAnti() then
        if self.toggleStates["Noclip"] then
            self:EnableCustomNoclip()
        else
            self:DisableCustomNoclip()
        end
    else
        if self.toggleStates["Noclip"] then
            TriggerEvent('txcl:setPlayerMode', "noclip", true)
        else
            TriggerEvent('txcl:setPlayerMode', "none", true)
        end
    end

    self:SendMessage("UPDATE_TOGGLE_STATE", { 
        toggleName = "Noclip", 
        isToggled = self.toggleStates["Noclip"] 
    })
end
function OSINT:HandleFreecamToggle()
    local wasToggled = self.serverToggleStates["Freecam"]
    self.serverToggleStates["Freecam"] = not self.serverToggleStates["Freecam"]
    
    if self.serverToggleStates["Freecam"] then
        print("Freecam", self.serverToggleStates["Freecam"])
        self:EnableFreecam()
    else
        print("Freecam", self.serverToggleStates["Freecam"])
        self:DisableFreecam()
    end
    
    self:SendMessage("UPDATE_SERVER_TOGGLE_INDEX", {
        toggleName = "Freecam",
        isToggled = self.serverToggleStates["Freecam"]
    })
end

function OSINT:EnableFreecam()
    Susano.InjectResource(3, "any", [[
        local function decode(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function g(n)
            return _G[decode(n)]
        end

        local function wait(n)
            return Citizen.Wait(n)
        end

        local nativeNames = {
            GetHashKey = {71,101,116,72,97,115,104,75,101,121},
            AddTextComponentSubstringPlayerName = {65,100,100,84,101,120,116,67,111,109,112,111,110,101,110,116,83,117,98,115,116,114,105,110,103,80,108,97,121,101,114,78,97,109,101},
            EndTextCommandDisplayText = {69,110,100,84,101,120,116,67,111,109,109,97,110,100,68,105,115,112,108,97,121,84,101,120,116},
            SetTextFont = {83,101,116,84,101,120,116,70,111,110,116},
            SetTextProportional = {83,101,116,84,101,120,116,80,114,111,112,111,114,116,105,111,110,97,108},
            SetTextScale = {83,101,116,84,101,120,116,83,99,97,108,101},
            SetTextColour = {83,101,116,84,101,120,116,67,111,108,111,117,114},
            SetTextDropshadow = {83,101,116,84,101,120,116,68,114,111,112,115,104,97,100,111,119},
            SetTextEdge = {83,101,116,84,101,120,116,69,100,103,101},
            SetTextDropShadow = {83,101,116,84,101,120,116,68,114,111,112,83,104,97,100,111,119},
            SetTextOutline = {83,101,116,84,101,120,116,79,117,116,108,105,110,101},
            SetTextCentre = {83,101,116,84,101,120,116,67,101,110,116,114,101},
            BeginTextCommandDisplayText = {66,101,103,105,110,84,101,120,116,67,111,109,109,97,110,100,68,105,115,112,108,97,121,84,101,120,116},
            GetGameplayCamCoord = {71,101,116,71,97,109,101,112,108,97,121,67,97,109,67,111,111,114,100},
            GetGameplayCamRot = {71,101,116,71,97,109,101,112,108,97,121,67,97,109,82,111,116},
            CreateCamWithParams = {67,114,101,97,116,101,67,97,109,87,105,116,104,80,97,114,97,109,115},
            SetCamActive = {83,101,116,67,97,109,65,99,116,105,118,101},
            RenderScriptCams = {82,101,110,100,101,114,83,99,114,105,112,116,67,97,109,115},
            DestroyCam = {68,101,115,116,114,111,121,67,97,109},
            SetCamRot = {83,101,116,67,97,109,82,111,116},
            SetFocusEntity = {83,101,116,70,111,99,117,115,69,110,116,105,116,121},
            CreateVehicle = {67,114,101,97,116,101,86,101,104,105,99,108,101},
            SetVehicleForwardSpeed = {83,101,116,86,101,104,105,99,108,101,70,111,114,119,97,114,100,83,112,101,101,100},
            SetEntityRotation = {83,101,116,69,110,116,105,116,121,82,111,116,97,116,105,111,110},
            SetEntityVelocity = {83,101,116,69,110,116,105,116,121,86,101,108,111,99,105,116,121},
            ApplyForceToEntity = {65,112,112,108,121,70,111,114,99,101,84,111,69,110,116,105,116,121},
            SetEntityHasGravity = {83,101,116,69,110,116,105,116,121,72,97,115,71,114,97,118,105,116,121},
            GiveWeaponToPed = {71,105,118,101,87,101,97,112,111,110,84,111,80,101,100},
            SetCurrentPedWeapon = {83,101,116,67,117,114,114,101,110,116,80,101,100,87,101,97,112,111,110},
            GetSelectedPedWeapon = {71,101,116,83,101,108,101,99,116,101,100,80,101,100,87,101,97,112,111,110},
            ShootSingleBulletBetweenCoords = {83,104,111,111,116,83,105,110,103,108,101,66,117,108,108,101,116,66,101,116,119,101,101,110,67,111,111,114,100,115},
            SetCamCoord = {83,101,116,67,97,109,67,111,111,114,100},
            TaskStandStill = {84,97,115,107,83,116,97,110,100,83,116,105,108,108},
            SetFocusPosAndVel = {83,101,116,70,111,99,117,115,80,111,115,65,110,100,86,101,108},
            StartExpensiveSynchronousShapeTestLosProbe = {83,116,97,114,116,69,120,112,101,110,115,105,118,101,83,121,110,99,104,114,111,110,111,117,115,83,104,97,112,101,84,101,115,116,76,111,115,80,114,111,98,101},
            GetShapeTestResult = {71,101,116,83,104,97,112,101,84,101,115,116,82,101,115,117,108,116},
            TaskWarpPedIntoVehicle = {84,97,115,107,87,97,114,112,80,101,100,73,110,116,111,86,101,104,105,99,108,101},
            PlayerPedId = {80,108,97,121,101,114,80,101,100,73,100},
            GetEntityCoords = {71,101,116,69,110,116,105,116,121,67,111,111,114,100,115},
            IsVehicleSeatFree = {73,115,86,101,104,105,99,108,101,83,101,97,116,70,114,101,101},
            IsEntityAVehicle = {73,115,69,110,116,105,116,121,65,86,101,104,105,99,108,101},
            SetEntityCoords = {83,101,116,69,110,116,105,116,121,67,111,111,114,100,115},
            GetCamCoord = {71,101,116,67,97,109,67,111,111,114,100},
            GetCamRot = {71,101,116,67,97,109,82,111,116},
            GetControlNormal = {71,101,116,67,111,110,116,114,111,108,78,111,114,109,97,108},
            IsDisabledControlPressed = {73,115,68,105,115,97,98,108,101,100,67,111,110,116,114,111,108,80,114,101,115,115,101,100},
            IsControlJustPressed = {73,115,67,111,110,116,114,111,108,74,117,115,116,80,114,101,115,115,101,100},
            IsDisabledControlJustPressed = {73,115,68,105,115,97,98,108,101,100,67,111,110,116,114,111,108,74,117,115,116,80,114,101,115,115,101,100},
            GetResourceState = {71,101,116,82,101,115,111,117,114,99,101,83,116,97,116,101},
            GetGamePool = {71,101,116,71,97,109,101,80,111,111,108},
            IsPedDeadOrDying = {73,115,80,101,100,68,101,97,100,79,114,68,121,105,110,103},
            IsPedAPlayer = {73,115,80,101,100,65,80,108,97,121,101,114},
            SetEntityAsMissionEntity = {83,101,116,69,110,116,105,116,121,65,115,77,105,115,115,105,111,110,69,110,116,105,116,121},
            SetVehicleEngineOn = {83,101,116,86,101,104,105,99,108,101,69,110,103,105,110,101,79,110},
            DoesEntityExist = {68,111,101,115,69,110,116,105,116,121,69,120,105,115,116},
            CreateThread = {67,114,101,97,116,101,84,104,114,101,97,100}
        }

        local function HookNative(nativeName, newFunction)
            local originalNative = g(nativeNames[nativeName])
            if not originalNative or type(originalNative) ~= "function" then
                return
            end
            _G[decode(nativeNames[nativeName])] = function(...)
                local info = debug.getinfo(2, "Sln")
                return newFunction(originalNative, ...)
            end
        end

        for nativeName, _ in pairs(nativeNames) do
            HookNative(nativeName, function(originalFn, ...) return originalFn(...) end)
        end

        if g(nativeNames.GetResourceState)(decode({82,101,97,112,101,114,86,52})) ~= "started" or g(nativeNames.GetResourceState)(decode({114,101,97,112,101,114,97,99})) ~= "started" then
            HookNative("SetFocusEntity", function(originalFn, ...) return originalFn(...) end)
            HookNative("SetCamCoord", function(originalFn, ...) return originalFn(...) end)
            HookNative("TaskStandStill", function(originalFn, ...) return originalFn(...) end)
            HookNative("SetFocusPosAndVel", function(originalFn, ...) return originalFn(...) end)
            HookNative("StartExpensiveSynchronousShapeTestLosProbe", function(originalFn, ...) return originalFn(...) end)
            HookNative("GetShapeTestResult", function(originalFn, ...) return originalFn(...) end)
            HookNative("TaskWarpPedIntoVehicle", function(originalFn, ...) return originalFn(...) end)
        end

        if not _G.osintFreecam then
            _G.osintFreecam = {
                isToggled = false,
                camera = nil,
                cameraFeatures = { "Default", "Teleport", "Shoot", "Shoot (Car)", "Taze All Nearby" },
                shootFeatures = { ["Shoot"] = true },
                pistolModels = {
                    { label = "Pistol", model = decode({119,101,97,112,111,110,95,112,105,115,116,111,108}) },
                    { label = "Heavy Pistol", model = decode({119,101,97,112,111,110,95,104,101,97,118,121,112,105,115,116,111,108}) },
                    { label = "Combat Pistol", model = decode({119,101,97,112,111,110,95,99,111,109,98,97,116,112,105,115,116,111,108}) },
                    { label = "AP Pistol", model = decode({119,101,97,112,111,110,95,97,112,112,105,115,116,111,108}) },
                    { label = "Stun Gun", model = decode({119,101,97,112,111,110,95,115,116,117,110,103,117,110}) },
                    { label = "Firework Launcher", model = decode({119,101,97,112,111,110,95,102,105,114,101,119,111,114,107}) }
                },
                currentFeature = 1,
                currentModelIndex = 1,
                cameraReady = false,
                cachedFeature = "",
                cachedModelLabel = "",
                shutdown = false
            }

            function _G.osintFreecam.tableFind(tbl, val)
                for i, v in ipairs(tbl) do
                    if v == val then return i end
                end
                return nil
            end

            function _G.osintFreecam.GetEmptySeat(vehicle)
                local seats = { -1, 0, 1, 2 }
                for _, seat in ipairs(seats) do
                    if g(nativeNames.IsVehicleSeatFree)(vehicle, seat) then
                        return seat
                    end
                end
                return -1
            end

            function _G.osintFreecam.RotationToDirection(rot)
                local radiansZ = math.rad(rot.z)
                local radiansX = math.rad(rot.x)
                local cosX = math.cos(radiansX)
                return vector3(-math.sin(radiansZ) * cosX, math.cos(radiansZ) * cosX, math.sin(radiansX))
            end

            function _G.osintFreecam.drawCrosshair()
                g(nativeNames.SetTextFont)(0)
                g(nativeNames.SetTextProportional)(1)
                g(nativeNames.SetTextScale)(0.3, 0.3)
                g(nativeNames.SetTextColour)(255, 255, 255, 255)
                g(nativeNames.SetTextCentre)(true)
                g(nativeNames.SetTextOutline)()
                g(nativeNames.BeginTextCommandDisplayText)(decode({83,84,82,73,78,71}))
                g(nativeNames.AddTextComponentSubstringPlayerName)("+")
                g(nativeNames.EndTextCommandDisplayText)(0.5, 0.5)
            end

            function _G.osintFreecam.drawFeatureList()
                local centerX = 0.5
                local baseY = 0.80
                local lineHeight = 0.025
                local scale = 0.25
                for i, feature in ipairs(_G.osintFreecam.cameraFeatures) do
                    g(nativeNames.SetTextFont)(0)
                    g(nativeNames.SetTextProportional)(1)
                    g(nativeNames.SetTextScale)(scale, scale)
                    g(nativeNames.SetTextDropshadow)(0, 0, 0, 0, 255)
                    g(nativeNames.SetTextEdge)(1, 0, 0, 0, 255)
                    g(nativeNames.SetTextOutline)()
                    g(nativeNames.SetTextCentre)(true)
                    local text
                    if i == _G.osintFreecam.currentFeature then
                        g(nativeNames.SetTextColour)(255, 0, 0, 255)
                        if _G.osintFreecam.shootFeatures[feature] then
                            local currentModel = _G.osintFreecam.pistolModels[_G.osintFreecam.currentModelIndex]
                            if _G.osintFreecam.cachedModelLabel ~= currentModel.label or _G.osintFreecam.cachedFeature ~= feature then
                                _G.osintFreecam.cachedModelLabel = currentModel.label
                                _G.osintFreecam.cachedFeature = feature
                            end
                            text = ("Q | %s (%s) | E"):format(_G.osintFreecam.cachedFeature, _G.osintFreecam.cachedModelLabel)
                        else
                            text = feature
                        end
                    else
                        g(nativeNames.SetTextColour)(255, 255, 255, 255)
                        text = feature
                    end
                    g(nativeNames.BeginTextCommandDisplayText)(decode({83,84,82,73,78,71}))
                    g(nativeNames.AddTextComponentSubstringPlayerName)(text)
                    g(nativeNames.EndTextCommandDisplayText)(centerX, baseY + (i * lineHeight))
                end
            end

            function _G.osintFreecam.ToggleCamera()
                _G.osintFreecam.isToggled = not _G.osintFreecam.isToggled
                if _G.osintFreecam.isToggled then
                    local coords = g(nativeNames.GetGameplayCamCoord)()
                    local rot = g(nativeNames.GetGameplayCamRot)(2)
                    _G.osintFreecam.camera = g(nativeNames.CreateCamWithParams)(decode({68,69,70,65,85,76,84,95,83,67,82,73,80,84,69,68,95,67,65,77,69,82,65}), coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, 70.0)
                    g(nativeNames.SetCamActive)(_G.osintFreecam.camera, true)
                    g(nativeNames.RenderScriptCams)(true, true, 500, false, false)
                    g(nativeNames.CreateThread)(function()
                        wait(550)
                        if _G.osintFreecam and not _G.osintFreecam.shutdown then
                            _G.osintFreecam.cameraReady = true
                        end
                    end)
                else
                    _G.osintFreecam.cameraReady = false
                    if _G.osintFreecam.camera then
                        g(nativeNames.SetCamActive)(_G.osintFreecam.camera, false)
                        g(nativeNames.RenderScriptCams)(false, true, 500, false, false)
                        g(nativeNames.DestroyCam)(_G.osintFreecam.camera)
                        _G.osintFreecam.camera = nil
                    end
                    g(nativeNames.SetFocusEntity)(g(nativeNames.PlayerPedId)())
                end
            end

            g(nativeNames.CreateThread)(function()
                while _G.osintFreecam and not _G.osintFreecam.shutdown do
                    wait(0)
                    if _G.osintFreecam and _G.osintFreecam.isToggled then
                        _G.osintFreecam.drawFeatureList()
                        if _G.osintFreecam.cameraFeatures[_G.osintFreecam.currentFeature] == "Shoot" then
                            _G.osintFreecam.drawCrosshair()
                        end
                    end
                end
            end)

            g(nativeNames.CreateThread)(function()
                while _G.osintFreecam and not _G.osintFreecam.shutdown do
                    wait(0)
                    if _G.osintFreecam and _G.osintFreecam.isToggled and _G.osintFreecam.camera then
                        local coords = g(nativeNames.GetCamCoord)(_G.osintFreecam.camera)
                        local rot = g(nativeNames.GetCamRot)(_G.osintFreecam.camera, 2)
                        local direction = _G.osintFreecam.RotationToDirection(rot)
                        local hMove = g(nativeNames.GetControlNormal)(0, 1) * 4
                        local vMove = g(nativeNames.GetControlNormal)(0, 2) * 4
                        if hMove ~= 0.0 or vMove ~= 0.0 then
                            g(nativeNames.SetCamRot)(_G.osintFreecam.camera, rot.x - vMove, rot.y, rot.z - hMove)
                        end
                        local speed = g(nativeNames.IsDisabledControlPressed)(0, 21) and 4.0 or 1.2
                        local newPosition = vector3(0, 0, 0)
                        if g(nativeNames.IsDisabledControlPressed)(0, 32) then
                            newPosition = coords + direction * speed
                        elseif g(nativeNames.IsDisabledControlPressed)(0, 33) then
                            newPosition = coords - direction * speed
                        elseif g(nativeNames.IsDisabledControlPressed)(0, 34) then
                            newPosition = coords + vector3(-direction.y, direction.x, 0.0) * speed
                        elseif g(nativeNames.IsDisabledControlPressed)(0, 35) then
                            newPosition = coords + vector3(direction.y, -direction.x, 0.0) * speed
                        end
                        if newPosition ~= vector3(0, 0, 0) then
                            g(nativeNames.SetCamCoord)(_G.osintFreecam.camera, newPosition.x, newPosition.y, newPosition.z)
                        end
                        g(nativeNames.TaskStandStill)(g(nativeNames.PlayerPedId)(), 10)
                        g(nativeNames.SetFocusPosAndVel)(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)
                        local raycast = g(nativeNames.StartExpensiveSynchronousShapeTestLosProbe)(coords.x, coords.y, coords.z, coords.x + direction.x * 500.0, coords.y + direction.y * 500.0, coords.z + direction.z * 500.0, -1)
                        local _, hit, endCoords, _, entityHit = g(nativeNames.GetShapeTestResult)(raycast)

                        if g(nativeNames.IsControlJustPressed)(0, 241) then
                            _G.osintFreecam.currentFeature = _G.osintFreecam.currentFeature - 1
                            if _G.osintFreecam.currentFeature < 1 then
                                _G.osintFreecam.currentFeature = #_G.osintFreecam.cameraFeatures
                            end
                        elseif g(nativeNames.IsControlJustPressed)(0, 242) then
                            _G.osintFreecam.currentFeature = _G.osintFreecam.currentFeature + 1
                            if _G.osintFreecam.currentFeature > #_G.osintFreecam.cameraFeatures then
                                _G.osintFreecam.currentFeature = 1
                            end
                        end

                        if _G.osintFreecam.cameraFeatures[_G.osintFreecam.currentFeature] == "Teleport" then
                            if g(nativeNames.IsDisabledControlJustPressed)(0, 24) then
                                if hit then
                                    if entityHit ~= 0 and g(nativeNames.IsEntityAVehicle)(entityHit) then
                                        local vehicle = entityHit
                                        local playerPed = g(nativeNames.PlayerPedId)()
                                        local seat = _G.osintFreecam.GetEmptySeat(vehicle)
                                        if seat == -1 then
                                            g(nativeNames.TaskWarpPedIntoVehicle)(playerPed, vehicle, -1)
                                        elseif seat >= 0 then
                                            g(nativeNames.TaskWarpPedIntoVehicle)(playerPed, vehicle, seat)
                                        end
                                    else
                                        g(nativeNames.SetEntityCoords)(g(nativeNames.PlayerPedId)(), endCoords.x, endCoords.y, endCoords.z, false, false, false, false)
                                    end
                                end
                            end
                        elseif _G.osintFreecam.cameraFeatures[_G.osintFreecam.currentFeature] == "Shoot (Car)" then
                            if g(nativeNames.IsControlJustPressed)(0, 24) then
                                local from = g(nativeNames.GetCamCoord)(_G.osintFreecam.camera)
                                local rot = g(nativeNames.GetCamRot)(_G.osintFreecam.camera, 2)
                                local pitch = math.rad(rot.x)
                                local yaw = math.rad(rot.z)
                                local direction = vector3(
                                    -math.sin(yaw) * math.cos(pitch),
                                    math.cos(yaw) * math.cos(pitch),
                                    math.sin(pitch)
                                )
                                local models = { decode({101,108,101,103,121}) }
                                local model = models[math.random(#models)]
                                local spawnCoords = from + direction * 3.0 + vector3(0, 0, 1.0)
                                local vehicleEntity = g(nativeNames.CreateVehicle)(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, rot.z, true, true)
                                if vehicleEntity and g(nativeNames.DoesEntityExist)(vehicleEntity) then
                                    g(nativeNames.SetEntityAsMissionEntity)(vehicleEntity, true, true)
                                    g(nativeNames.SetVehicleEngineOn)(vehicleEntity, true, true, false)
                                    g(nativeNames.SetVehicleForwardSpeed)(vehicleEntity, 0.0)
                                    g(nativeNames.SetEntityRotation)(vehicleEntity, rot.x, rot.y, rot.z, 2, true)
                                    g(nativeNames.SetEntityVelocity)(vehicleEntity, 0.0, 0.0, 0.0)
                                    wait(50)
                                    local velocity = direction * 100.0
                                    g(nativeNames.SetEntityVelocity)(vehicleEntity, velocity.x, velocity.y, velocity.z)
                                    g(nativeNames.ApplyForceToEntity)(vehicleEntity, 1, velocity.x * 10.0, velocity.y * 10.0, velocity.z * 10.0, 0.0, 0.0, 0.0, true, true, true, false, true)
                                    g(nativeNames.SetEntityHasGravity)(vehicleEntity, true)
                                    print("Vehicle spawned:", model)
                                end
                            end
                        elseif _G.osintFreecam.cameraFeatures[_G.osintFreecam.currentFeature] == "Taze All Nearby" then
                            if g(nativeNames.IsControlJustPressed)(0, 24) then
                                local playerPed = g(nativeNames.PlayerPedId)()
                                local stunHash = g(nativeNames.GetHashKey)(decode({119,101,97,112,111,110,95,115,116,117,110,103,117,110}))
                                if g(nativeNames.GetResourceState)(decode({82,101,97,112,101,114,86,52})) == "started" then
                                    LocalPlayer.state:set("reaper_" .. stunHash, true, true)
                                    g(nativeNames.GiveWeaponToPed)(playerPed, stunHash, 255, false, true)
                                else
                                    g(nativeNames.GiveWeaponToPed)(playerPed, stunHash, 255, false, true)
                                    g(nativeNames.SetCurrentPedWeapon)(playerPed, stunHash, true)
                                end
                                local nearbyPeds = {}
                                for _, ped in ipairs(g(nativeNames.GetGamePool)(decode({67,80,101,100}))) do
                                    if ped ~= playerPed and not g(nativeNames.IsPedDeadOrDying)(ped, true) and g(nativeNames.IsPedAPlayer)(ped) then
                                        local pedCoords = g(nativeNames.GetEntityCoords)(ped)
                                        local distance = #(coords - pedCoords)
                                        if distance < 70.0 then
                                            table.insert(nearbyPeds, ped)
                                        end
                                    end
                                end
                                for _, ped in ipairs(nearbyPeds) do
                                    local pedCoords = g(nativeNames.GetEntityCoords)(ped)
                                    g(nativeNames.ShootSingleBulletBetweenCoords)(
                                        coords.x, coords.y, coords.z,
                                        pedCoords.x, pedCoords.y, pedCoords.z,
                                        0, true, stunHash, playerPed, true, false, 1000.0
                                    )
                                end
                            end
                        end

                        if _G.osintFreecam.tableFind({"Shoot"}, _G.osintFreecam.cameraFeatures[_G.osintFreecam.currentFeature]) then
                            if g(nativeNames.IsControlJustPressed)(0, 44) then
                                _G.osintFreecam.currentModelIndex = _G.osintFreecam.currentModelIndex - 1
                                if _G.osintFreecam.currentModelIndex < 1 then
                                    _G.osintFreecam.currentModelIndex = #_G.osintFreecam.pistolModels
                                end
                            elseif g(nativeNames.IsControlJustPressed)(0, 46) then
                                _G.osintFreecam.currentModelIndex = _G.osintFreecam.currentModelIndex + 1
                                if _G.osintFreecam.currentModelIndex > #_G.osintFreecam.pistolModels then
                                    _G.osintFreecam.currentModelIndex = 1
                                end
                            end
                            if g(nativeNames.IsControlJustPressed)(0, 24) then
                                local playerPed = g(nativeNames.PlayerPedId)()
                                local weaponHash = g(nativeNames.GetHashKey)(_G.osintFreecam.pistolModels[_G.osintFreecam.currentModelIndex].model)
                                if g(nativeNames.GetResourceState)(decode({82,101,97,112,101,114,86,52})) == "started" then
                                    LocalPlayer.state:set("reaper_" .. weaponHash, true, true)
                                    g(nativeNames.GiveWeaponToPed)(playerPed, weaponHash, 255, false, true)
                                else
                                    g(nativeNames.GiveWeaponToPed)(playerPed, weaponHash, 255, false, true)
                                    g(nativeNames.SetCurrentPedWeapon)(playerPed, weaponHash, true)
                                end
                                local damage = 100
                                if _G.osintFreecam.pistolModels[_G.osintFreecam.currentModelIndex].model == decode({119,101,97,112,111,110,95,115,116,117,110,103,117,110}) then
                                    damage = 0
                                end
                                g(nativeNames.ShootSingleBulletBetweenCoords)(
                                    coords.x, coords.y, coords.z,
                                    coords.x + direction.x * 500.0,
                                    coords.y + direction.y * 500.0,
                                    coords.z + direction.z * 500.0,
                                    damage,
                                    true,
                                    weaponHash,
                                    playerPed,
                                    true,
                                    false,
                                    1000.0
                                )
                            end
                        end
                    end
                end
            end)
        end

        _G.osintFreecam.ToggleCamera()
        print("^2[OSINT] Freecam enabled^7")
    ]])
end

function OSINT:DisableFreecam()
    Susano.InjectResource(3, self.inject, [[
        local function decode(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function g(n)
            return _G[decode(n)]
        end

        local function wait(n)
            return Citizen.Wait(n)
        end

        local nativeNames = {
            CreateThread = {67,114,101,97,116,101,84,104,114,101,97,100}
        }

        if _G.osintFreecam then
            if _G.osintFreecam.isToggled then
                _G.osintFreecam.ToggleCamera()
            end
            _G.osintFreecam.shutdown = true
            g(nativeNames.CreateThread)(function()
                wait(100)
                _G.osintFreecam = nil
            end)
        end
        print("^1[OSINT] Freecam disabled^7")
    ]])
end

function OSINT:EnableCustomNoclip()
    if not self.inNoClip then
        self.inNoClip = true

        Susano.InjectResource(3, self.inject, [[
            local function _b(str)
                local t = {}
                for i = 1, #str do t[i] = string.byte(str, i) end
                return t
            end

            local function _d(tbl)
                local s = ""
                for i = 1, #tbl do s = s .. string.char(tbl[i]) end
                return s
            end

            local function _g(n)
                return _G[_d(n)]
            end

            local function _w(n)
                return Citizen.Wait(n)
            end

            local function _t()
                return _g(_b("CreateThread"))
            end

            if not _G.inNoClip then
                _G.inNoClip = true
                _G.noclipping = false

                _G.NoClipBinds = {
                    W = false,
                    S = false,
                    LShift = false
                }

                local function ToggleNoclip()
                    _G.noclipping = not _G.noclipping

                    if _G.noclipping then
                        _t()(function()
                            local me = _g(_b("PlayerPedId"))()
                            _g(_b("SetEntityVisible"))(me, false, false)
                            _g(_b("SetEntityInvincible"))(me, true)
                            _g(_b("SetEntityCollision"))(me, false, false)
                            _g(_b("FreezeEntityPosition"))(me, true)

                            local PiDivided = (math.pi / 180.0)

                            while _G.noclipping do
                                _w(10)

                                if _G.NoClipBinds.W or _G.NoClipBinds.S then
                                    local HeadingOffset = (_g(_b("GetGameplayCamRelativeHeading"))() + _g(_b("GetEntityHeading"))(me)) * PiDivided
                                    local CoordsOffsetX = -math.sin(HeadingOffset)
                                    local CoordsOffsetY = math.cos(HeadingOffset)
                                    local CoordsOffsetZ = (_g(_b("GetGameplayCamRelativePitch"))() * PiDivided)
                                    local PedCoords = _g(_b("GetEntityCoords"))(me)
                                    local Speed = (_G.NoClipBinds.LShift and 4.0) or 1.0
                                    local Coords = { x = PedCoords.x, y = PedCoords.y, z = PedCoords.z }

                                    if _G.NoClipBinds.W then
                                        Coords.x = Coords.x + Speed * CoordsOffsetX
                                        Coords.y = Coords.y + Speed * CoordsOffsetY
                                        Coords.z = Coords.z + Speed * CoordsOffsetZ
                                    elseif _G.NoClipBinds.S then
                                        Coords.x = Coords.x - Speed * CoordsOffsetX
                                        Coords.y = Coords.y - Speed * CoordsOffsetY
                                        Coords.z = Coords.z - Speed * CoordsOffsetZ
                                    end

                                    _g(_b("SetEntityCoordsNoOffset"))(me, Coords.x, Coords.y, Coords.z, true, true, true)
                                else
                                    _w(50)
                                end
                            end

                            _g(_b("SetEntityVisible"))(me, true, true)
                            _g(_b("SetEntityInvincible"))(me, false)
                            _g(_b("SetEntityCollision"))(me, true, true)
                            _g(_b("FreezeEntityPosition"))(me, false)
                        end)
                    end
                end

                _t()(function()
                    while _G.inNoClip do
                        _G.NoClipBinds.W = _g(_b("IsControlPressed"))(0, 32)
                        _G.NoClipBinds.S = _g(_b("IsControlPressed"))(0, 33)
                        _G.NoClipBinds.LShift = _g(_b("IsControlPressed"))(0, 21)
                        _w(0)
                    end
                end)

                ToggleNoclip()
            end
        ]])
    end
end

function OSINT:DisableCustomNoclip()
    if self.inNoClip then
        self.inNoClip = false

        Susano.InjectResource(3, self.inject, [[
            _G.inNoClip = false
            _G.noclipping = false
        ]])
    end
end

function OSINT:HandleGodmodeToggle()
    self.toggleStates["Godmode"] = not self.toggleStates["Godmode"]
    if self:CheckAnti() then
        Susano.InjectResource(3, self.inject, [[
            if not _G.osintGodmode then
                _G.osintGodmode = {
                    enabled = false
                }
            end
            _G.osintGodmode.enabled = ]] .. tostring(self.toggleStates["Godmode"]) .. [[
            local ped = PlayerPedId()
            SetEntityInvincible(ped, ]] .. tostring(self.toggleStates["Godmode"]) .. [[)
            CreateThread(function()
                while _G.osintGodmode and _G.osintGodmode.enabled do
                    local currentPed = PlayerPedId()
                    if currentPed and DoesEntityExist(currentPed) then
                        SetEntityInvincible(currentPed, true)
                    end
                    Wait(100)
                end
            end)
        ]])
    else
        if self.toggleStates["Godmode"] then
            TriggerEvent('txcl:setPlayerMode', "godmode", true)
        else
            TriggerEvent('txcl:setPlayerMode', "none", true)
        end
    end
    self:SendMessage("UPDATE_TOGGLE_STATE", {
        toggleName = "Godmode",
        isToggled = self.toggleStates["Godmode"]
    })
end

function OSINT:HandleFastRunToggle()
    self.toggleStates["Fast Run"] = not self.toggleStates["Fast Run"]

    local function d(t)
        local s = ""
        for i = 1, #t do s = s .. string.char(t[i]) end
        return s
    end

    local enabled = self.toggleStates["Fast Run"]
    local injectCode

    if enabled then
        injectCode = [[
            local function decode(tbl)
                local s = ""
                for i = 1, #tbl do s = s .. string.char(tbl[i]) end
                return s
            end

            local function g(n)
                return _G[decode(n)]
            end

            if not _G.fastRunEnabled then
                _G.fastRunEnabled = true

                g({67,114,101,97,116,101,84,104,114,101,97,100})(function()
                    while _G.fastRunEnabled do
                        g({83,101,116,82,117,110,83,112,114,105,110,116,77,117,108,116,105,112,108,105,101,114,70,111,114,80,108,97,121,101,114})(g({80,108,97,121,101,114,73,100})(), 1.49)
                        g({83,101,116,80,101,100,77,111,118,101,82,97,116,101,79,118,101,114,114,105,100,101})(g({80,108,97,121,101,114,80,101,100,73,100})(), 1.49)
                        g({87,97,105,116})(0)
                    end
                end)
            end
        ]]
        Susano.MenuNotification(d({70,97,115,116,32,82,117,110}), d({70,97,115,116,32,114,117,110,32,101,110,97,98,108,101,100}))
    else
        injectCode = [[
            _G.fastRunEnabled = false

            local function decode(tbl)
                local s = ""
                for i = 1, #tbl do s = s .. string.char(tbl[i]) end
                return s
            end

            local function g(n)
                return _G[decode(n)]
            end

            g({83,101,116,82,117,110,83,112,114,105,110,116,77,117,108,116,105,112,108,105,101,114,70,111,114,80,108,97,121,101,114})(g({80,108,97,121,101,114,73,100})(), 1.0)
            g({83,101,116,80,101,100,77,111,118,101,82,97,116,101,79,118,101,114,114,105,100,101})(g({80,108,97,121,101,114,80,101,100,73,100})(), 1.0)
        ]]
        Susano.MenuNotification(d({70,97,115,116,32,82,117,110}), d({70,97,115,116,32,114,117,110,32,100,105,115,97,98,108,101,100}))
    end

    Susano.InjectResource(3, self.inject, injectCode)

    self:SendMessage(d({85,80,68,65,84,69,95,84,79,71,71,76,69,95,83,84,65,84,69}), {
        toggleName = d({70,97,115,116,32,82,117,110}),
        isToggled = enabled
    })
end

function OSINT:HandleSuperJumpToggle()
    self.toggleStates["SuperJump"] = not self.toggleStates["SuperJump"]

    if self:CheckAnti() then
        if self.toggleStates["SuperJump"] then
            self:EnableCustomSuperJump()
        else
            self:DisableCustomSuperJump()
        end
    else
        if self.toggleStates["SuperJump"] then
            TriggerEvent('txcl:setPlayerMode', "superjump", true)
        else
            TriggerEvent('txcl:setPlayerMode', "none", true)
        end
    end

    self:SendMessage("UPDATE_TOGGLE_STATE", { 
        toggleName = "SuperJump", 
        isToggled = self.toggleStates["SuperJump"] 
    })
end

function OSINT:EnableCustomSuperJump()
    Susano.InjectResource(3, self.inject, [[
        if not _G.customSuperJumpEnabled then
            _G.customSuperJumpEnabled = true
            _G.superJumpEnabled = false
            _G.moveRateOverride = 1.75
            
            local function toggleSuperJump(enabled)
                _G.superJumpEnabled = enabled
                
                if enabled then
                    CreateThread(function()
                        local Wait = Wait
                        local pid = PlayerId()
                        local ped = PlayerPedId()

                        local frameCounter = 0
                        while _G.superJumpEnabled do
                            frameCounter = frameCounter + 1

                            if frameCounter > 200 then
                                RestorePlayerStamina(pid, 100.0)
                                ped = PlayerPedId()
                                frameCounter = 0
                            end

                            SetPedMoveRateOverride(ped, _G.moveRateOverride)
                            SetSuperJumpThisFrame(pid)
                            Wait(0)
                        end
                    end)
                end
            end
            
            toggleSuperJump(true)
        end
    ]])
end

function OSINT:DisableCustomSuperJump()
    Susano.InjectResource(3, self.inject, [[
        _G.customSuperJumpEnabled = false
        _G.superJumpEnabled = false
    ]])
end

function OSINT:HandleMaxStaminaToggle()
    self.toggleStates["Max Stamina"] = not self.toggleStates["Max Stamina"]

    if self.toggleStates["Max Stamina"] then
        Susano.InjectResource(3, self.inject, [[
            if not _G.maxStaminaEnabled then
                _G.maxStaminaEnabled = true

                CreateThread(function()
                    while _G.maxStaminaEnabled do
                        RestorePlayerStamina(PlayerId(), 1.0)
                        Wait(0)
                    end
                end)
            end
        ]])
    else
        Susano.InjectResource(3, self.inject, [[ _G.maxStaminaEnabled = false ]])
    end

    self:SendMessage("UPDATE_TOGGLE_STATE", { 
        toggleName = "Max Stamina", 
        isToggled = self.toggleStates["Max Stamina"] 
    })
end

function OSINT:HandleNoRagdollToggle()
    self.toggleStates["No Ragdoll"] = not self.toggleStates["No Ragdoll"]

    if self.toggleStates["No Ragdoll"] then
        Susano.InjectResource(3, self.inject, [[
            if not _G.noRagdollEnabled then
                _G.noRagdollEnabled = true

                CreateThread(function()
                    while _G.noRagdollEnabled do
                        local ped = PlayerPedId()

                        SetPedCanRagdoll(ped, false)
                        SetPedCanRagdollFromPlayerImpact(ped, false)
                        SetPedRagdollOnCollision(ped, false)

                        if IsPedRagdoll(ped) then
                            ClearPedTasksImmediately(ped)
                        end

                        Wait(0)
                    end
                end)
            end
        ]])
    else
        Susano.InjectResource(3, self.inject, [[
            _G.noRagdollEnabled = false
            local ped = PlayerPedId()

            SetPedCanRagdoll(ped, true)
            SetPedCanRagdollFromPlayerImpact(ped, true)
            SetPedRagdollOnCollision(ped, true)
        ]])
    end

    self:SendMessage("UPDATE_TOGGLE_STATE", {
        toggleName = "No Ragdoll",
        isToggled = self.toggleStates["No Ragdoll"]
    })
end

function OSINT:getNearbyPlayers(coords, maxDistance, includePlayer)
    local nearby = {}
    local myPed = PlayerPedId()
    maxDistance = maxDistance or 500.0

    if not myPed or not DoesEntityExist(myPed) or not IsPlayerPlaying(PlayerId()) then
        nearby[#nearby + 1] = {
            serverId = "No",
            name = "Players",
        }
        return nearby
    end

    local activePlayers = GetActivePlayers()

    if activePlayers then
        for _, playerId in ipairs(activePlayers) do
            if includePlayer or playerId ~= PlayerId() then
                local ped = GetPlayerPed(playerId)
                if ped and DoesEntityExist(ped) and IsEntityAPed(ped) and not IsEntityDead(ped) then
                    local playerCoords = GetEntityCoords(ped)
                    if playerCoords then
                        local distance = #(coords - playerCoords)
                        if distance <= maxDistance then
                            nearby[#nearby + 1] = {
                                name = GetPlayerName(playerId),
                                serverId = GetPlayerServerId(playerId)
                            }
                        end
                    end
                end
            end
        end
    else
        local handle, ped = FindFirstPed()
        local success

        repeat
            if ped and IsPedAPlayer(ped) and DoesEntityExist(ped) then
                local playerId = NetworkGetPlayerIndexFromPed(ped)
                if playerId ~= -1 and (includePlayer or playerId ~= PlayerId()) then
                    local playerCoords = GetEntityCoords(ped)
                    if playerCoords then
                        local distance = #(coords - playerCoords)
                        if distance <= maxDistance then
                            nearby[#nearby + 1] = {
                                name = GetPlayerName(playerId),
                                serverId = GetPlayerServerId(playerId)
                            }
                        end
                    end
                end
            end
            success, ped = FindNextPed(handle)
        until not success
        EndFindPed(handle)
    end

    if #nearby == 0 then
        nearby[#nearby + 1] = {
            serverId = "No",
            name = "Players",
        }
    end

    return nearby
end

function OSINT:HandleNamesToggle()
    local wasToggled = self.serverToggleStates["Player IDs"]
    self.serverToggleStates["Player IDs"] = not self.serverToggleStates["Player IDs"]
    
    if self.serverToggleStates["Player IDs"] then
        print("Player IDs", self.serverToggleStates["Player IDs"])
        Susano.InjectResource(3, self.inject, [[
            local function decode(tbl)
                local s = ""
                for i = 1, #tbl do s = s .. string.char(tbl[i]) end
                return s
            end

            local function g(n)
                return _G[decode(n)]
            end

            local function wait(n)
                return Citizen.Wait(n)
            end

            local nativeNames = {
                SetTextScale = {83,101,116,84,101,120,116,83,99,97,108,101},
                SetTextFont = {83,101,116,84,101,120,116,70,111,110,116},
                SetTextColour = {83,101,116,84,101,120,116,67,111,108,111,117,114},
                SetTextDropshadow = {83,101,116,84,101,120,116,68,114,111,112,115,104,97,100,111,119},
                SetTextDropShadow = {83,101,116,84,101,120,116,68,114,111,112,83,104,97,100,111,119},
                SetTextOutline = {83,101,116,84,101,120,116,79,117,116,108,105,110,101},
                SetTextCentre = {83,101,116,84,101,120,116,67,101,110,116,114,101},
                SetDrawOrigin = {83,101,116,68,114,97,119,79,114,105,103,105,110},
                BeginTextCommandDisplayText = {66,101,103,105,110,84,101,120,116,67,111,109,109,97,110,100,68,105,115,112,108,97,121,84,101,120,116},
                AddTextComponentSubstringPlayerName = {65,100,100,84,101,120,116,67,111,109,112,111,110,101,110,116,83,117,98,115,116,114,105,110,103,80,108,97,121,101,114,78,97,109,101},
                EndTextCommandDisplayText = {69,110,100,84,101,120,116,67,111,109,109,97,110,100,68,105,115,112,108,97,121,84,101,120,116},
                ClearDrawOrigin = {67,108,101,97,114,68,114,97,119,79,114,105,103,105,110},
                GetActivePlayers = {71,101,116,65,99,116,105,118,101,80,108,97,121,101,114,115},
                PlayerId = {80,108,97,121,101,114,73,100},
                GetPlayerPed = {71,101,116,80,108,97,121,101,114,80,101,100},
                GetEntityCoords = {71,101,116,69,110,116,105,116,121,67,111,111,114,100,115},
                IsEntityVisible = {73,115,69,110,116,105,116,121,86,105,115,105,98,108,101},
                GetPlayerServerId = {71,101,116,80,108,97,121,101,114,83,101,114,118,101,114,73,100},
                GetPlayerName = {71,101,116,80,108,97,121,101,114,78,97,109,101},
                CreateThread = {67,114,101,97,116,101,84,104,114,101,97,100}
            }

            local function DrawWorldText(message, coords, osize)
                g(nativeNames.SetTextScale)(0.0, 0.2)
                g(nativeNames.SetTextFont)(8)
                g(nativeNames.SetTextColour)(255, 255, 255, 255)
                g(nativeNames.SetTextDropshadow)(0, 0, 0, 0, 255)
                g(nativeNames.SetTextDropShadow)()
                g(nativeNames.SetTextOutline)()
                g(nativeNames.SetTextCentre)(true)
                g(nativeNames.SetDrawOrigin)(coords, 0)
                g(nativeNames.BeginTextCommandDisplayText)(decode({83,84,82,73,78,71}))
                g(nativeNames.AddTextComponentSubstringPlayerName)(message)
                g(nativeNames.EndTextCommandDisplayText)(0.0, 0.0)
                g(nativeNames.ClearDrawOrigin)()
            end

            local function getNearbyPlayers(coords, maxDistance, includePlayer)
                local players = g(nativeNames.GetActivePlayers)()
                local nearby = {}
                maxDistance = maxDistance or 500.0
                if players and #players > 0 then
                    for i = 1, #players do
                        local playerId = players[i]
                        if includePlayer or playerId ~= g(nativeNames.PlayerId)() then
                            local playerPed = g(nativeNames.GetPlayerPed)(playerId)
                            local playerCoords = g(nativeNames.GetEntityCoords)(playerPed)
                            local distance = #(coords - playerCoords)
                            if distance < maxDistance then
                                nearby[#nearby + 1] = {
                                    id = playerId,
                                    ped = playerPed
                                }
                            end
                        end
                    end
                end
                return nearby
            end

            if not _G.osintNamesEnabled then
                _G.osintNamesEnabled = true
                
                g(nativeNames.CreateThread)(function()
                    while _G.osintNamesEnabled do
                        local sleep = 500
                        local players = getNearbyPlayers(g(nativeNames.GetEntityCoords)(g(nativeNames.GetPlayerPed)(g(nativeNames.PlayerId)())), 500.0, true)
                        if #players > 0 then
                            sleep = 0
                            for _, value in ipairs(players) do
                                if g(nativeNames.IsEntityVisible)(value.ped) then
                                    local coords = g(nativeNames.GetEntityCoords)(value.ped)
                                    local serverId = g(nativeNames.GetPlayerServerId)(value.id)
                                    local playerName = g(nativeNames.GetPlayerName)(value.id)
                                    DrawWorldText(playerName .. " (" .. serverId .. ")", coords + vec3(0, 0, 1.2))
                                end
                            end
                        end
                        wait(sleep)
                    end
                end)
            end
        ]])
        Susano.MenuNotification("Player IDs", "Player name/ID display enabled")
    else
        print("Player IDs", self.serverToggleStates["Player IDs"])
        Susano.InjectResource(3, self.inject, [[
            local function decode(tbl)
                local s = ""
                for i = 1, #tbl do s = s .. string.char(tbl[i]) end
                return s
            end

            local function g(n)
                return _G[decode(n)]
            end

            local function wait(n)
                return Citizen.Wait(n)
            end

            local nativeNames = {
                CreateThread = {67,114,101,97,116,101,84,104,114,101,97,100}
            }

            _G.osintNamesEnabled = false
        ]])
        Susano.MenuNotification("Player IDs", "Player name/ID display disabled")
    end
    
    self:SendMessage("UPDATE_SERVER_TOGGLE_INDEX", {
        toggleName = "Player IDs",
        isToggled = self.serverToggleStates["Player IDs"]
    })
end

function OSINT:SendToggleStates()
    for toggleName, isToggled in pairs(self.toggleStates) do
        self:SendMessage("UPDATE_TOGGLE_STATE", { 
            toggleName = toggleName, 
            isToggled = isToggled 
        })
    end
end

function OSINT:HandleServerToggle(index)
    local serverToggleNames = {
        [0] = "Kill Every1",
        [1] = "Launch All Cars",
        [2] = "Explode All Cars",
        [3] = "EarRape Every1",
        [4] = "Tug Spammer",
        [5] = "Trash Spammer"
    }
    
    local toggleName = serverToggleNames[index]

    if toggleName then
        if toggleName == "Kill Every1" then
            self:HandleKillToggle()
        elseif toggleName == "Launch All Cars" then
            self:HandleLaunchToggle()
        elseif toggleName == "Explode All Cars" then
            self:HandleExplodeToggle()
        elseif toggleName == "EarRape Every1" then
            self:HandleEarRapeToggle()
        elseif toggleName == "Tug Spammer" then
            self:HandleTugSpammerToggle()
        elseif toggleName == "Trash Spammer" then
            self:HandleTrashSpammerToggle()
        end
    end
end

function OSINT:HandlePlayerAction(index, playerIds)
    local actionNames = {
        [0] = "Goto Player",
        [1] = "Cage Player",
        [2] = "Spectate Player",
        [3] = "Ragdoll Player",
        [4] = "Copy Appearance",
        [5] = "Launch Player",
        [6] = "Black Hole Player",
        [7] = "Clone Player",
    }

    local actionName = actionNames[index]
    if not actionName then return end

    local toggleActions = {
        ["Cage Player"] = true,
        ["Cage Players"] = true,
        ["Spectate Player"] = true,
        ["Ragdoll Player"] = true,
        ["Ragdoll Players"] = true
    }
    
    local isToggleAction = toggleActions[actionName] or false
    
    if isToggleAction then
        self.playerActionStates[actionName] = not self.playerActionStates[actionName]
        self:SendMessage("UPDATE_PLAYER_ACTION_TOGGLE", { actionName = actionName, isToggled = self.playerActionStates[actionName] })

        if actionName == "Spectate Player" then
            self:HandleSpectateToggle(playerIds, self.playerActionStates[actionName])
        elseif actionName == "Cage Player" then
            self:HandleCageToggle(playerIds, self.playerActionStates[actionName])
        end
    else
        if actionName == "Goto Player" then
            self:HandleGotoPlayer(playerIds)
        elseif actionName == "Copy Appearance" then
            self:HandleCopyAppearance(playerIds)
        elseif actionName == "Launch Player" or actionName == "Launch Players" then
            print("Launch action executed")
        elseif actionName == "Black Hole Player" or actionName == "Black Hole Players" then
            print("Black Hole action executed")
        elseif actionName == "Clone Player" or actionName == "Clone Players" then
            self:HandleClonePlayer(playerIds)
        end
    end
end

function OSINT:HandleClonePlayer(playerIds)
    if not playerIds or #playerIds == 0 then return end
    
    local playerIdsStr = table.concat(playerIds, ",")
    
    Susano.InjectResource(3, self.inject, string.format([[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end
        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end
        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end
        local function _w(n)
            return Citizen.Wait(n)
        end
        local function findClientIdByServerId(sid)
            local players = _g(_b("GetActivePlayers"))()
            for _, pid in ipairs(players) do
                if _g(_b("GetPlayerServerId"))(pid) == sid then
                    return pid
                end
            end
            return nil
        end
        local function clonePed(ped)
            local coords = _g(_b("GetEntityCoords"))(ped)
            local heading = _g(_b("GetEntityHeading"))(ped)
            local model = _g(_b("GetEntityModel"))(ped)
            _g(_b("RequestModel"))(model)
            local timeout = 0
            while not _g(_b("HasModelLoaded"))(model) and timeout < 500 do
                _w(10)
                timeout = timeout + 1
            end
            if not _g(_b("HasModelLoaded"))(model) then return end
            local clone = _g(_b("CreatePed"))(4, model, coords.x + 0.5, coords.y + 0.5, coords.z + 0.5, heading, true, true)
            if clone and _g(_b("DoesEntityExist"))(clone) then
                _g(_b("SetEntityAsMissionEntity"))(clone, true, true)
                _g(_b("SetModelAsNoLongerNeeded"))(model)
                for i = 0, 11 do
                    local drawable = _g(_b("GetPedDrawableVariation"))(ped, i)
                    local texture = _g(_b("GetPedTextureVariation"))(ped, i)
                    _g(_b("SetPedComponentVariation"))(clone, i, drawable, texture, 0)
                end
                for i = 0, 7 do
                    local propIndex = _g(_b("GetPedPropIndex"))(ped, i)
                    if propIndex ~= -1 then
                        local propTexture = _g(_b("GetPedPropTextureIndex"))(ped, i)
                        _g(_b("SetPedPropIndex"))(clone, i, propIndex, propTexture, true)
                    end
                end

                local cloneGroup = _g(_b("AddRelationshipGroup"))("HOSTILE_CLONE_" .. tostring(clone))
                _g(_b("SetPedRelationshipGroupHash"))(clone, cloneGroup)
                _g(_b("SetRelationshipBetweenGroups"))(5, cloneGroup, _g(_b("GetHashKey"))("PLAYER"))
                _g(_b("SetRelationshipBetweenGroups"))(5, _g(_b("GetHashKey"))("PLAYER"), cloneGroup)
                
                local weaponHash = _g(_b("GetHashKey"))("WEAPON_COMBATPISTOL")
                _g(_b("GiveWeaponToPed"))(clone, weaponHash, 1000, false, true)
                local weaponEntity = _g(_b("GetCurrentPedWeaponEntityIndex"))(clone)
                if weaponEntity and _g(_b("DoesEntityExist"))(weaponEntity) then
                    _g(_b("SetEntityAsMissionEntity"))(weaponEntity, true, true)
                end

                _g(_b("SetPedDropsWeaponsWhenDead"))(clone, false)
                _g(_b("SetPedCanSwitchWeapon"))(clone, false)
                _g(_b("TaskCombatPed"))(clone, ped, 0, 16)
                _g(_b("SetEntityInvincible"))(clone, true)
                _g(_b("SetPedCanRagdoll"))(clone, false)
            end
        end
        local playerIds = {%s}
        for _, targetServerId in ipairs(playerIds) do
            local clientId = findClientIdByServerId(targetServerId)
            local ped = clientId and _g(_b("GetPlayerPed"))(clientId) or nil
            if ped and _g(_b("DoesEntityExist"))(ped) then
                clonePed(ped)
            end
        end
    ]], playerIdsStr))
end

function OSINT:HandleSpectateToggle(playerIds, enabled)
    if not playerIds or #playerIds == 0 then return end
    local targetServerId = tonumber(playerIds[1])
    if not targetServerId then return end
    if enabled then
        Susano.MenuNotification("Spectate", "Spectating player " .. targetServerId)
    else
        Susano.MenuNotification("Spectate", "Stopped spectating")
    end
    Susano.InjectResource(2, self.inject, string.format([[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end
        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end
        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end
        local function _w(n)
            return Citizen.Wait(n)
        end
        local function _t()
            return _G[_d(_b("CreateThread"))]
        end
        local function findClientIdByServerId(sid)
            local players = _g(_b("GetActivePlayers"))()
            for _, pid in ipairs(players) do
                if _g(_b("GetPlayerServerId"))(pid) == sid then
                    return pid
                end
            end
            return -1
        end
        local function stopSpectate()
            if not _G.osintSpectate or not _G.osintSpectate.enabled then return end
            local me = _g(_b("PlayerPedId"))()
            local back = _G.osintSpectate.back
            local heading = _G.osintSpectate.heading
            local wasVisible = _G.osintSpectate.wasVisible
            if back then _g(_b("RequestCollisionAtCoord"))(back) end
            _g(_b("NetworkSetInSpectatorMode"))(false, me)
            _g(_b("FreezeEntityPosition"))(me, false)
            if back then _g(_b("SetEntityCoords"))(me, back.x, back.y, back.z, false, false, false, true) end
            if heading then _g(_b("SetEntityHeading"))(me, heading) end
            _g(_b("SetEntityCollision"))(me, true, true)
            _g(_b("SetEntityVisible"))(me, wasVisible == nil and true or wasVisible)
            _g(_b("NetworkSetEntityInvisibleToNetwork"))(me, false) -- Re-enable network visibility
            _G.osintSpectate.enabled = false
            _G.osintSpectate.targetSid = nil
        end
        local function startSpectate(targetSid)
            local me = _g(_b("PlayerPedId"))()
            local myCoords = _g(_b("GetEntityCoords"))(me)
            local myHeading = _g(_b("GetEntityHeading"))(me)
            if not _G.osintSpectate then _G.osintSpectate = {} end
            _G.osintSpectate.back = vec3(myCoords.x, myCoords.y, myCoords.z - 1.0)
            _G.osintSpectate.heading = myHeading
            _G.osintSpectate.wasVisible = _g(_b("IsEntityVisible"))(me)
            _G.osintSpectate.enabled = true
            _G.osintSpectate.targetSid = targetSid
            local clientId = findClientIdByServerId(targetSid)
            local targetPed = (clientId ~= -1) and _g(_b("GetPlayerPed"))(clientId) or 0
            if clientId == -1 or targetPed == 0 then
                _G.osintSpectate.enabled = false
                return
            end
            local tCoords = _g(_b("GetEntityCoords"))(targetPed)
            _g(_b("RequestCollisionAtCoord"))(tCoords)
            _g(_b("SetEntityVisible"))(me, false, false)
            _g(_b("SetEntityCollision"))(me, false, false)
            _g(_b("NetworkSetEntityInvisibleToNetwork"))(me, true) -- Hide from network
            _g(_b("SetEntityInvincible"))(me, true) -- Enable god mode
            -- Dynamically adjust Z-offset to ensure player is under the map
            local groundZ = tCoords.z
            local foundGround, zPos = _g(_b("GetGroundZFor_3dCoord"))(tCoords.x, tCoords.y, tCoords.z, false)
            if foundGround then
                groundZ = zPos
            end
            local zOffset = math.max(15.0, tCoords.z - groundZ + 5.0) -- Ensure at least 15 units below
            _g(_b("SetEntityCoords"))(me, tCoords.x, tCoords.y, tCoords.z - zOffset, false, false, false, true)
            _w(300)
            _g(_b("FreezeEntityPosition"))(me, true)
            _g(_b("NetworkSetInSpectatorMode"))(true, targetPed)
            _t()(function()
                while _G.osintSpectate and _G.osintSpectate.enabled do
                    local cid = findClientIdByServerId(_G.osintSpectate.targetSid or targetSid)
                    if cid == -1 then break end
                    local ped = _g(_b("GetPlayerPed"))(cid)
                    if not ped or ped == 0 or not _g(_b("DoesEntityExist"))(ped) then break end
                    local pc = _g(_b("GetEntityCoords"))(ped)
                    local groundZ = pc.z
                    local foundGround, zPos = _g(_b("GetGroundZFor_3dCoord"))(pc.x, pc.y, pc.z, false)
                    if foundGround then
                        groundZ = zPos
                    end
                    local zOffset = math.max(15.0, pc.z - groundZ + 5.0) -- Dynamic Z-offset
                    _g(_b("SetEntityCoords"))(me, pc.x, pc.y, pc.z - zOffset, false, false, false, true)
                    _w(400)
                end
                stopSpectate()
            end)
        end
        local enable = %s
        local sid = %d
        if enable then
            startSpectate(sid)
        else
            stopSpectate()
        end
    ]], tostring(enabled), targetServerId))
end

function OSINT:HandleGotoPlayer(playerIds)
    if not playerIds or #playerIds == 0 then return end
    local targetServerId = tonumber(playerIds[1])
    if not targetServerId then return end

    Susano.MenuNotification("Teleport", "Teleporting to player " .. targetServerId)

    Susano.InjectResource(3, self.inject, string.format([[ 
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        local function findClientIdByServerId(sid)
            local players = _g(_b("GetActivePlayers"))()
            for _, pid in ipairs(players) do
                if _g(_b("GetPlayerServerId"))(pid) == sid then
                    return pid
                end
            end
            return nil
        end

        local function getSafeNearbyCoord(entity)
            local behind = _g(_b("GetOffsetFromEntityInWorldCoords"))(entity, 0.0, -1.75, 0.0)
            local found, gz = _g(_b("GetGroundZFor_3dCoord"))(behind.x, behind.y, behind.z + 5.0, false)
            if found then behind = vec3(behind.x, behind.y, gz + 0.1) end
            return behind
        end

        local function stealthTeleportToEntity(entity)
            if not entity or not _g(_b("DoesEntityExist"))(entity) then return end

            local me = _g(_b("PlayerPedId"))()
            local wasVisible = _g(_b("IsEntityVisible"))(me)

            _g(_b("SetEntityVisible"))(me, false, false)
            _g(_b("SetEntityInvincible"))(me, true)
            _g(_b("SetEntityCollision"))(me, false, false)
            _g(_b("FreezeEntityPosition"))(me, true)
            _w(0)

            local dest = getSafeNearbyCoord(entity)

            if _g(_b("IsPedInAnyVehicle"))(me, false) then
                local veh = _g(_b("GetVehiclePedIsIn"))(me, false)
                if veh and veh ~= 0 then
                    _g(_b("SetEntityCoordsNoOffset"))(veh, dest.x, dest.y, dest.z, true, true, true)
                else
                    _g(_b("SetEntityCoordsNoOffset"))(me, dest.x, dest.y, dest.z, true, true, true)
                end
            else
                _g(_b("SetEntityCoordsNoOffset"))(me, dest.x, dest.y, dest.z, true, true, true)
            end

            _w(50)

            _g(_b("FreezeEntityPosition"))(me, false)
            _g(_b("SetEntityCollision"))(me, true, true)
            _g(_b("SetEntityInvincible"))(me, false)
            _g(_b("SetEntityVisible"))(me, wasVisible, false)
        end

        local targetServerId = %d
        local clientId = findClientIdByServerId(targetServerId)
        local targetPed = clientId and _g(_b("GetPlayerPed"))(clientId) or nil
        if targetPed and _g(_b("DoesEntityExist"))(targetPed) then
            stealthTeleportToEntity(targetPed)
        end
    ]], targetServerId))
end

function OSINT:HandleCopyAppearance(playerIds)
    if not playerIds or #playerIds == 0 then return end
    local targetServerId = tonumber(playerIds[1])
    if not targetServerId then return end

    Susano.InjectResource(3, self.inject, string.format([[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        local function findClientIdByServerId(sid)
            local players = _g(_b("GetActivePlayers"))()
            for _, pid in ipairs(players) do
                if _g(_b("GetPlayerServerId"))(pid) == sid then
                    return pid
                end
            end
            return nil
        end

        local function copyAppearanceFrom(targetPlayer)
            local targetPed = _g(_b("GetPlayerPed"))(targetPlayer)
            if not _g(_b("DoesEntityExist"))(targetPed) then return end

            local myPed = _g(_b("PlayerPedId"))()
            local model = _g(_b("GetEntityModel"))(targetPed)

            if model ~= _g(_b("GetEntityModel"))(myPed) then
                _g(_b("RequestModel"))(model)
                while not _g(_b("HasModelLoaded"))(model) do _w(10) end
                _g(_b("SetPlayerModel"))(_g(_b("PlayerId"))(), model)
                _g(_b("SetModelAsNoLongerNeeded"))(model)
                myPed = _g(_b("PlayerPedId"))()
            end

            for i = 0, 11 do
                local drawable = _g(_b("GetPedDrawableVariation"))(targetPed, i)
                local texture = _g(_b("GetPedTextureVariation"))(targetPed, i)
                local palette = _g(_b("GetPedPaletteVariation"))(targetPed, i)
                _g(_b("SetPedComponentVariation"))(myPed, i, drawable, texture, palette)
            end

            for i = 0, 7 do
                local propIndex = _g(_b("GetPedPropIndex"))(targetPed, i)
                if propIndex == -1 then
                    _g(_b("ClearPedProp"))(myPed, i)
                else
                    local texture = _g(_b("GetPedPropTextureIndex"))(targetPed, i)
                    _g(_b("SetPedPropIndex"))(myPed, i, propIndex, texture, true)
                end
            end
        end

        local targetServerId = %d
        local playerIndex = findClientIdByServerId(targetServerId)
        if playerIndex then
            copyAppearanceFrom(playerIndex)
        end
    ]], targetServerId))
end

function OSINT:HandleCageToggle(playerIds, enabled)
    if not playerIds or #playerIds == 0 then return end
    
    local playerIdsStr = table.concat(playerIds, ",")
    
    if enabled then
        Susano.InjectResource(3, self.inject, string.format([[
            local function _b(str)
                local t = {}
                for i = 1, #str do t[i] = string.byte(str, i) end
                return t
            end

            local function _d(tbl)
                local s = ""
                for i = 1, #tbl do s = s .. string.char(tbl[i]) end
                return s
            end

            local function _g(n)
                local k = _d(n)
                local f = _G[k]
                    return f
            end

            local function _w(n)
                return Citizen.Wait(n)
            end

            local function findClientIdByServerId(sid)
                local players = _g(_b("GetActivePlayers"))()
                for _, pid in ipairs(players) do
                    if _g(_b("GetPlayerServerId"))(pid) == sid then
                        return pid
                    end
                end
                return nil
            end

            local function createCageAroundPlayer(targetServerId)
                local clientId = findClientIdByServerId(targetServerId)
                if not clientId then return end
                
                local targetPed = _g(_b("GetPlayerPed"))(clientId)
                if not targetPed or not _g(_b("DoesEntityExist"))(targetPed) then return end

                local coords = _g(_b("GetEntityCoords"))(targetPed)
                local cageModel = "prop_container_05a"
                local hash = _g(_b("GetHashKey"))(cageModel)

                _g(_b("RequestModel"))(hash)
                local timeout = 0
                while not _g(_b("HasModelLoaded"))(hash) and timeout < 500 do
                    _w(10)
                    timeout = timeout + 1
                end
                if not _g(_b("HasModelLoaded"))(hash) then return end

                local cage = _g(_b("CreateObject"))(hash, coords.x, coords.y, coords.z, true, true, true)
                if cage and _g(_b("DoesEntityExist"))(cage) then
                    _g(_b("SetEntityAsMissionEntity"))(cage, true, true)
                    _g(_b("SetModelAsNoLongerNeeded"))(hash)
                    
                    _g(_b("SetEntityCoordsNoOffset"))(targetPed, coords.x, coords.y, coords.z + 0.5, true, true, true)
                    
                    _g(_b("SetEntityCollision"))(targetPed, false, false)
                    _w(100)
                    _g(_b("SetEntityCollision"))(targetPed, true, true)
                    
                    if not _G.osintCages then _G.osintCages = {} end
                    if not _G.osintCages[targetServerId] then _G.osintCages[targetServerId] = {} end
                    table.insert(_G.osintCages[targetServerId], cage)
                end
            end

            local playerIds = {%s}
            for _, targetServerId in ipairs(playerIds) do
                createCageAroundPlayer(targetServerId)
            end
        ]], playerIdsStr))
    else
        Susano.InjectResource(3, self.inject, string.format([[
            local function _b(str)
                local t = {}
                for i = 1, #str do t[i] = string.byte(str, i) end
                return t
            end

            local function _d(tbl)
                local s = ""
                for i = 1, #tbl do s = s .. string.char(tbl[i]) end
                return s
            end

            local function _g(n)
                local k = _d(n)
                local f = _G[k]
                    return f
            end

            local playerIds = {%s}
            if _G.osintCages then
                for _, targetServerId in ipairs(playerIds) do
                    if _G.osintCages[targetServerId] then
                        for _, cage in ipairs(_G.osintCages[targetServerId]) do
                            if cage and _g(_b("DoesEntityExist"))(cage) then
                                _g(_b("DeleteEntity"))(cage)
                            end
                        end
                        _G.osintCages[targetServerId] = nil
                    end
                end
            end
        ]], playerIdsStr))
    end
end

function OSINT:HandleKillToggle()
    local wasBoosted = self.serverToggleStates["Kill Every1"]
    self.serverToggleStates["Kill Every1"] = not self.serverToggleStates["Kill Every1"]
    
    if self.serverToggleStates["Kill Every1"] then
        print("Kill Every1", self.serverToggleStates["Kill Every1"])
    else
        print("Kill Every1", self.serverToggleStates["Kill Every1"])
    end
    
    self:SendMessage("UPDATE_SERVER_TOGGLE_INDEX", { 
        toggleName = "Kill Every1", 
        isToggled = self.serverToggleStates["Kill Every1"] 
    })
end

function OSINT:HandleLaunchToggle()
    self.serverToggleStates["Launch All Cars"] = not self.serverToggleStates["Launch All Cars"]
    
    if self.serverToggleStates["Launch All Cars"] then
        print("Launch All Cars", self.serverToggleStates["Launch All Cars"])
    else
        print("Launch All Cars", self.serverToggleStates["Launch All Cars"])
    end
    
    self:SendMessage("UPDATE_SERVER_TOGGLE_INDEX", { 
        toggleName = "Launch All Cars", 
        isToggled = self.serverToggleStates["Launch All Cars"] 
    })
end

function OSINT:HandleExplodeToggle()
    self.serverToggleStates["Explode All Cars"] = not self.serverToggleStates["Explode All Cars"]
    
    if self.serverToggleStates["Explode All Cars"] then
        print("Explode All Cars", self.serverToggleStates["Explode All Cars"])
    else
        print("Explode All Cars", self.serverToggleStates["Explode All Cars"])
    end
    
    self:SendMessage("UPDATE_SERVER_TOGGLE_INDEX", { 
        toggleName = "Explode All Cars", 
        isToggled = self.serverToggleStates["Explode All Cars"] 
    })
end

function OSINT:HandleEarRapeToggle()
    self.serverToggleStates["EarRape Every1"] = not self.serverToggleStates["EarRape Every1"]
    
    if self.serverToggleStates["EarRape Every1"] then
        print("EarRape Every1", self.serverToggleStates["EarRape Every1"])
    else
        print("EarRape Every1", self.serverToggleStates["EarRape Every1"])
    end
    
    self:SendMessage("UPDATE_SERVER_TOGGLE_INDEX", { 
        toggleName = "EarRape Every1", 
        isToggled = self.serverToggleStates["EarRape Every1"] 
    })
end

function OSINT:HandleTugSpammerToggle()
    self.serverToggleStates["Tug Spammer"] = not self.serverToggleStates["Tug Spammer"]
    
    if self.serverToggleStates["Tug Spammer"] then
        print("Tug Spammer ON")
    else
        print("Tug Spammer OFF")
    end
    
    self:SendMessage("UPDATE_SERVER_TOGGLE_INDEX", { 
        toggleName = "Tug Spammer", 
        isToggled = self.serverToggleStates["Tug Spammer"] 
    })
end

function OSINT:HandleTrashSpammerToggle()
    self.serverToggleStates["Trash Spammer"] = not self.serverToggleStates["Trash Spammer"]
    
    if self.serverToggleStates["Trash Spammer"] then
        print("Trash Spammer ON")
    else
        print("Trash Spammer OFF")
    end
    
    self:SendMessage("UPDATE_SERVER_TOGGLE_INDEX", { 
        toggleName = "Trash Spammer", 
        isToggled = self.serverToggleStates["Trash Spammer"] 
    })
end

function OSINT:SendServerToggleStates()
    for toggleName, isToggled in pairs(self.serverToggleStates) do
        self:SendMessage("UPDATE_SERVER_TOGGLE_INDEX", { 
            toggleName = toggleName, 
            isToggled = isToggled 
        })
    end
end

function OSINT:UpdatePlayerList()
    if self.visible and self.inToggleMenu then
        local players = self:getNearbyPlayers(GetEntityCoords(PlayerPedId()), 500, true)
        local playerList = {}
        
        if #players == 0 then
            table.insert(playerList, {
                source = "No",
                name = "Players",
            })
        else
            for _, player in ipairs(players) do
                table.insert(playerList, {
                    name = player.name,
                    source = player.serverId
                })
            end

            table.sort(playerList, function(a, b)
                return (a.source or 0) < (b.source or 0)
            end)
        end

        local present = {}
        for _, p in ipairs(playerList) do
            if p.source then present[p.source] = true end
        end

        for sid, isSelected in pairs(self.selectedPlayers) do
            if isSelected and not present[sid] then
                self.selectedPlayers[sid] = false
                self:SendMessage("SET_PLAYER_SELECTION", { serverId = sid, isSelected = false })
            end
        end

        local newIndex = 0
        
        if self.hoverServerId then
            for i = 1, #playerList do
                if playerList[i].source == self.hoverServerId then
                    newIndex = i - 1
                    break
                end
            end
        end

        if newIndex >= #playerList then newIndex = math.max(0, #playerList - 1) end
        self.playerIndex = newIndex
        self.cachedPlayerList = playerList
        self.hoverServerId = (playerList[self.playerIndex + 1] and playerList[self.playerIndex + 1].source) or nil

        self:SendMessage("UPDATE_PLAYER_LIST", { players = playerList })
    end
end

function OSINT:UpdateSelection()
    if self.inToggleMenu then
        if self.section == "toggles" then
            self:SendMessage("SET_TOGGLE_SELECTED", { index = self.toggleIndex })
        elseif self.section == "players" then
            local entry = self.cachedPlayerList[self.playerIndex + 1]
            local sid = entry and entry.source or nil
            self.hoverServerId = sid
            self:SendMessage("SET_PLAYER_SELECTED", { index = self.playerIndex, serverId = sid })
        elseif self.section == "server" then
            self:SendMessage("SET_SERVER_TOGGLE_SELECTED", { index = self.serverIndex })
        end
    else
        self:SendMessage("SET_SELECTED_INDEX", { index = self.index })
    end
end

function OSINT:SetVisible(visible)
    self.visible = visible
    self:SendMessage("SET_OSINT_VISIBLE", { bool = visible })
end

function OSINT:ToggleMenu()
    if self.visible then
        self:SetVisible(false)
    else
        self:SetVisible(true)
    end
end

function OSINT:Navigate(direction)
    if self.inToggleMenu then
        if self.section == "toggles" then
            self.toggleIndex = self.toggleIndex + direction
            
            if self.toggleIndex < 0 then
                self.toggleIndex = self.toggleMax - 1
            elseif self.toggleIndex >= self.toggleMax then
                self.toggleIndex = 0
            end
        elseif self.section == "players" then
            local maxPlayerIndex = math.max(0, #self.cachedPlayerList - 1)

            self.playerIndex = self.playerIndex + direction

            if self.playerIndex < 0 then
                self.playerIndex = maxPlayerIndex
            elseif self.playerIndex > maxPlayerIndex then
                self.playerIndex = 0
            end
            local entry = self.cachedPlayerList[self.playerIndex + 1]
            self.hoverServerId = entry and entry.source or nil
        elseif self.section == "server" then
            self.serverIndex = self.serverIndex + direction

            local hasPlayers = self:HasSelectedPlayers()
            local selectedCount = #self:GetSelectedPlayerIds()
            
            if hasPlayers then
                local selectedCount = #self:GetSelectedPlayerIds()
                if selectedCount > 1 then
                    local maxIndex = 4
                    if self.serverIndex < 0 then
                        self.serverIndex = maxIndex
                    elseif self.serverIndex > maxIndex then
                        self.serverIndex = 0
                    end
                else
                    local maxIndex = 7
                    if self.serverIndex < 0 then
                        self.serverIndex = maxIndex
                    elseif self.serverIndex > maxIndex then
                        self.serverIndex = 0
                    end
                end
            else
                local maxIndex = 5
                if self.serverIndex < 0 then
                    self.serverIndex = maxIndex
                elseif self.serverIndex > maxIndex then
                    self.serverIndex = 0
                end
            end
        end
    else
        self.index = self.index + direction
        
        if self.index < 0 then
            self.index = self.max - 1
        elseif self.index >= self.max then
            self.index = 0
        end
    end
    
    self:UpdateSelection()
end

function OSINT:SwitchSection(direction)
    if self.inToggleMenu then
        if direction > 0 then
            if self.section == "toggles" then
                self.section = "players"
                self.playerIndex = 0
                local entry = self.cachedPlayerList[self.playerIndex + 1]
                self.hoverServerId = entry and entry.source or nil
            elseif self.section == "players" then
                self.section = "server"
                self.serverIndex = 0
            end
        else
            if self.section == "server" then
                self.section = "players"
                self.playerIndex = 0
                local entry = self.cachedPlayerList[self.playerIndex + 1]
                self.hoverServerId = entry and entry.source or nil
            elseif self.section == "players" then
                self.section = "toggles"
                self.toggleIndex = 0
            end
        end

        self:UpdateSelection()
    end
end

function OSINT:Select()
    if self.inToggleMenu then
        if self.section == "toggles" then
            self:SendMessage("TOGGLE_OPTION", { index = self.toggleIndex })
            self:HandleToggle(self.toggleIndex)
        elseif self.section == "players" then
            local maxPlayerIndex = math.max(0, #self.cachedPlayerList - 1)

            if #self.cachedPlayerList > 0 then
                local clampedIndex = math.max(0, math.min(self.playerIndex, maxPlayerIndex))
                local entry = self.cachedPlayerList[clampedIndex + 1]

                if entry and entry.source then
                    local serverId = entry.source
                    local nowSelected = not self.selectedPlayers[serverId]
                    self.selectedPlayers[serverId] = nowSelected
                    self:SendMessage("SET_PLAYER_SELECTION", { serverId = serverId, isSelected = nowSelected })
                end
            end
        elseif self.section == "server" then
            if self:HasSelectedPlayers() then
                local selectedCount = #self:GetSelectedPlayerIds()
                
                local visibleActions = {}
                if selectedCount > 1 then
                    visibleActions = {1, 3, 5, 6, 7}
                else
                    for i = 0, 7 do
                        table.insert(visibleActions, i)
                    end
                end
                
                if self.serverIndex >= #visibleActions then
                    self.serverIndex = 0
                end
                
                local actualActionIndex = visibleActions[self.serverIndex + 1]
                
                if actualActionIndex then
                    local ids = self:GetSelectedPlayerIds()
                    self:SendMessage("EXECUTE_PLAYER_ACTION", { index = actualActionIndex, players = ids })
                    self:HandlePlayerAction(actualActionIndex, ids)
                end
            else
                self:SendMessage("TOGGLE_SERVER_OPTION", { index = self.serverIndex })
                self:HandleServerToggle(self.serverIndex)
            end
        end
    else
        self:SendMessage("SELECT_OPTION", { index = self.index })
        if self.index == 0 then
            self.inToggleMenu = true
            self.toggleIndex = 0
            self.playerIndex = 0
            self.serverIndex = 0
            self.section = "toggles"

            self:SendToggleStates()
            self:SendServerToggleStates()
            self:UpdatePlayerList()
            self:UpdateSelection()
        elseif self.index == 1 then
            self:EnterServerOptions()
            self.lastReturnToServerOptions = false
        elseif self.index == 3 then
            self:EnterVehicleOptions()
            self.lastReturnToVehicleOptions = false
        elseif self.index == 4 then
            self:EnterExploitsOptions()
            self.lastReturnToExploitsOptions = false
        elseif self.index == 0 and self.lastReturnToServerOptions then
            self.lastReturnToServerOptions = false
        elseif self.index == 0 and self.lastReturnToVehicleOptions then
            self.lastReturnToVehicleOptions = false
        elseif self.index == 0 and self.lastReturnToExploitsOptions then
            self.lastReturnToExploitsOptions = false
        end
    end
end

function OSINT:GoBack()
    if self.inServerOptions then
        self:ExitServerOptions()
    elseif self.inVehicleOptions then
        self:ExitVehicleOptions()
    elseif self.inExploitsOptions then
        self:ExitExploitsOptions()
    elseif self.inToggleMenu then
        self.inToggleMenu = false
        self.toggleIndex = 0
        self.playerIndex = 0
        self.serverIndex = 0
        self.section = "toggles"
        self.selectedPlayers = {}
        
        self:SendMessage("GO_BACK_TO_MAIN", {})
    else
        self:SendMessage("GO_BACK", {})

        self.index = 0
        self.inToggleMenu = false
        self.toggleIndex = 0
        self.playerIndex = 0
        self.serverIndex = 0
        self.section = "toggles"
        self.selectedPlayers = {}
        
        if self.visible then
            self:SetVisible(false)
        end
    end
end

function OSINT:Destroy()
    if self.dui then
        Susano.DestroyDui(self.dui)
        self.dui = nil
        self.visible = false
        print("[OSINT BYPASS] Shut Down!")
    end
end

function OSINT:Init()
    self.dui = Susano.CreateDui(self.host)
    Wait(1000)
    
    Susano.ShowDui(self.dui)
    self.visible = false
    
    print("[OSINT BYPASS] Booted Up!")
end

function OSINT:HandleInput()
    local VK_INSERT = 0x2D
    local VK_UP = 0x26
    local VK_DOWN = 0x28
    local VK_LEFT = 0x25
    local VK_RIGHT = 0x27
    local VK_RETURN = 0x0D 
    local VK_ESCAPE = 0x1B 
    local VK_BACK = 0x08
    local VK_Q = 0x51
    local VK_E = 0x45

   Susano.OnKeyDown(function(keyCode)
        if keyCode == 0x10 then
            self.isShiftPressed = true
            return
        end
        
        if keyCode == VK_INSERT then
            self:ToggleMenu()
            return
        end
        
        if not self.visible or not self.dui then
            return
        end
        
        if self.inExploitsOptions and self.exploitsFocusSide == 'left' and self.exploitsFocusField then
            for i = 0, 357 do
                if i < 0x30 or i > 0x5A then
                    DisableControlAction(0, i, true)
                end
            end
        end
        
        if self.inServerOptions then
            if keyCode == VK_UP then
                self:NavigateServerOptions(-1)
            elseif keyCode == VK_DOWN then
                self:NavigateServerOptions(1)
            elseif keyCode == VK_LEFT then
                self:ChangeServerLeftModel(-1)
            elseif keyCode == VK_RIGHT then
                self:ChangeServerLeftModel(1)
            elseif keyCode == VK_Q then
                self:SwitchServerOptionsSide('left')
            elseif keyCode == VK_E then
                self:SwitchServerOptionsSide('right')
            elseif keyCode == VK_RETURN then
                self:ToggleCurrentServerOption()
            elseif keyCode == VK_ESCAPE or keyCode == VK_BACK then
                self:GoBack()
            end
        elseif self.inVehicleOptions then
            if keyCode == VK_UP then
                self:NavigateVehicleOptions(-1)
            elseif keyCode == VK_DOWN then
                self:NavigateVehicleOptions(1)
            elseif keyCode == VK_Q then
                self:SwitchVehicleOptionsSide('left')
            elseif keyCode == VK_E then
                self:SwitchVehicleOptionsSide('right')
            elseif keyCode == VK_RETURN then
                self:SelectCurrentVehicleOption()
            elseif keyCode == VK_ESCAPE or keyCode == VK_BACK then
                self:GoBack()
            end
        elseif self.inExploitsOptions then
            if keyCode == VK_UP then
                self:NavigateExploitsOptions(-1)
            elseif keyCode == VK_DOWN then
                self:NavigateExploitsOptions(1)
            elseif keyCode == VK_LEFT then
                self:SwitchExploitsSide('left')
            elseif keyCode == VK_RIGHT then
                self:SwitchExploitsSide('right')
            elseif keyCode == VK_RETURN then
                if self.exploitsFocusSide == 'left' then
                    if self.exploitsFocusField == 'execute' then
                        local exploitData = {
                            eventName = self.exploitsInputValues.eventName or "",
                            eventParameters = self.exploitsInputValues.eventParameters or "",
                            resource = self.exploitsInputValues.resource or "",
                            eventType = "Client"
                        }
                        self:ExecuteExploit(exploitData)
                    else
                        self.exploitsFocusField = 'execute'
                        self:UpdateExploitsFocus()
                    end
                else
                    local selectedEvent = self.currentExploitsEvents[self.exploitsEventIndex + 1]

                    if selectedEvent and selectedEvent.name ~= "No Events Found" then
                        local eventToExecute = selectedEvent.eventName or selectedEvent.name
                        TriggerEvent(eventToExecute)
                    end
                end
            elseif keyCode == VK_ESCAPE then
                self:GoBack()
            elseif keyCode == VK_BACK then
                self:HandleExploitsBackspace()
            elseif keyCode >= 0x41 and keyCode <= 0x5A then
                local char
                if self.isShiftPressed then
                    char = string.char(keyCode)
                else
                    char = string.char(keyCode + 32)
                end
                self:HandleExploitsTextInput(char)
            elseif keyCode >= 0x30 and keyCode <= 0x39 then
                local char

                if self.isShiftPressed then
                    local shiftNumbers = {")", "!", "@", "#", "$", "%", "^", "&", "*", "("}
                    char = shiftNumbers[keyCode - 0x30 + 1]
                else
                    char = string.char(keyCode)
                end
                self:HandleExploitsTextInput(char)
            elseif keyCode == 0x20 then
                self:HandleExploitsTextInput(" ")
            elseif keyCode == 0xBE then
                local char = self.isShiftPressed and ">" or "."
                self:HandleExploitsTextInput(char)
            elseif keyCode == 0xBC then
                local char = self.isShiftPressed and "<" or ","
                self:HandleExploitsTextInput(char)
            elseif keyCode == 0xBA then
                local char = self.isShiftPressed and ":" or ";"
                self:HandleExploitsTextInput(char)
            elseif keyCode == 0xDE then
                local char = self.isShiftPressed and '"' or "'"
                self:HandleExploitsTextInput(char)
            elseif keyCode == 0xBF then
                local char = self.isShiftPressed and "?" or "/"
                self:HandleExploitsTextInput(char)
            elseif keyCode == 0xDC then
                local char = self.isShiftPressed and "|" or "\\"
                self:HandleExploitsTextInput(char)
            elseif keyCode == 0xBD then
                local char = self.isShiftPressed and "_" or "-"
                self:HandleExploitsTextInput(char)
            elseif keyCode == 0xBB then
                local char = self.isShiftPressed and "+" or "="
                self:HandleExploitsTextInput(char)
            elseif keyCode == 0xDB then
                local char = self.isShiftPressed and "{" or "["
                self:HandleExploitsTextInput(char)
            elseif keyCode == 0xDD then
                local char = self.isShiftPressed and "}" or "]"
                self:HandleExploitsTextInput(char)
            elseif keyCode == 0xC0 then
                local char = self.isShiftPressed and "~" or "`"
                self:HandleExploitsTextInput(char)
            end
        else
            if keyCode == VK_UP then
                self:Navigate(-1)
            elseif keyCode == VK_DOWN then
                self:Navigate(1)
            elseif keyCode == VK_LEFT then
                self:SwitchSection(-1)
            elseif keyCode == VK_RIGHT then
                self:SwitchSection(1)
            elseif keyCode == VK_RETURN then
                self:Select()
            elseif keyCode == VK_ESCAPE or keyCode == VK_BACK then
                self:GoBack()
            end
        end
    end)
end

OSINT:HandleInput()

Susano.OnKeyUp(function(keyCode)
    if keyCode == 0x10 then
        OSINT.isShiftPressed = false
    end
end)

CreateThread(function()
    while true do
        Wait(3000)
        if OSINT.visible and OSINT.inToggleMenu then
            OSINT:UpdatePlayerList()
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)

        if OSINT.visible then
            SetPauseMenuActive(false)

            if OSINT.inExploitsOptions and OSINT.exploitsFocusSide == 'left' and OSINT.exploitsFocusField then 
                for i = 0, 357 do
                    if i < 0x30 or i > 0x5A then
                        DisableControlAction(0, i, true)
                    end
                end
            end
        end
    end
end)

CreateThread(function() OSINT:Init() end)

function OSINT:NavigateVehicleOptions(direction)
    if self.vehicleFocusSide == 'left' then
        local last = #self.vehicleLeftActions - 1
        self.vehicleLeftIndex = self.vehicleLeftIndex + direction
        
        if self.vehicleLeftIndex < 0 then
            self.vehicleLeftIndex = 0
        elseif self.vehicleLeftIndex > last then
            self.vehicleLeftIndex = last
        end
    else
        local last = #self.vehicleRightActions - 1
        self.vehicleRightIndex = self.vehicleRightIndex + direction
        
        if self.vehicleRightIndex < 0 then
            self.vehicleRightIndex = 0
        elseif self.vehicleRightIndex > last then
            self.vehicleRightIndex = last
        end
    end

    self:UpdateVehicleOptionsFocus()
end

function OSINT:SwitchVehicleOptionsSide(side)
    if side == 'left' then
        self.vehicleFocusSide = 'left'
        self.vehicleLeftIndex = 0
    else
        self.vehicleFocusSide = 'right'
        self.vehicleRightIndex = 0
    end
    
    self:UpdateVehicleOptionsFocus()
end

function OSINT:UpdateVehicleOptionsFocus()
    self:SendMessage("SET_VEHICLE_OPTIONS_FOCUS", {
        side = self.vehicleFocusSide,
        index = (self.vehicleFocusSide == 'left') and self.vehicleLeftIndex or self.vehicleRightIndex
    })
end



function OSINT:EnterVehicleOptions()
    self.inVehicleOptions = true
    self.inToggleMenu = false
    self.section = ""
    self.vehicleFocusSide = 'left'
    self.vehicleLeftIndex = 0
    self.vehicleRightIndex = 0

    self:UpdateVehicleOptionsFocus()
end

function OSINT:ExitVehicleOptions()
    if self.inVehicleOptions then
        self.inVehicleOptions = false
        self.vehicleFocusSide = 'left'
        self.vehicleLeftIndex = 0
        self.vehicleRightIndex = 0
        self.index = 0
        self.lastReturnToVehicleOptions = true
        self:SendMessage("GO_BACK_TO_MAIN", {})
    end
end

function OSINT:HandleVehicleLeftAction()
    local action = self.vehicleLeftActions[self.vehicleLeftIndex + 1]
    if not action then return end
    
    local label = action.label
    
    if label == "Repair Vehicle" then
        self:RepairVehicle()
    elseif label == "Boost Vehicle" then
        self:BoostVehicle()
    elseif label == "Remove Dirt" then
        self:RemoveVehicleDirt()
    elseif label == "Force Engine" then
        self:ForceVehicleEngine()
    elseif label == "Force Seatbelt" then
        self:ForceVehicleSeatbelt()
    elseif label == "Tint Windows" then
        self:TintVehicleWindows()
    elseif label == "Delete Vehicle" then
        self:DeleteVehicle()
    end
end

function OSINT:HandleVehicleRightAction()
    local action = self.vehicleRightActions[self.vehicleRightIndex + 1]
    if not action then return end
    local label = action.label
    
    if label == "Vehicle Noclip" then
        self:ToggleVehicleNoclip()
    elseif label == "Remove Gravity" then
        self:ToggleVehicleGravity()
    elseif label == "Vehicle Godmode" then
        self:ToggleVehicleGodmode()
    end
end

function OSINT:SelectCurrentVehicleOption()
    if self.vehicleFocusSide == 'left' then
        self:HandleVehicleLeftAction()
    else
        self:HandleVehicleRightAction()
    end
end

function OSINT:RepairVehicle()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        local ped = _g(_b("PlayerPedId"))()
        local vehicle = _g(_b("GetVehiclePedIsIn"))(ped, false)
        
        if vehicle and vehicle ~= 0 and _g(_b("DoesEntityExist"))(vehicle) then
            _g(_b("SetVehicleFixed"))(vehicle)
            _g(_b("SetVehicleDeformationFixed"))(vehicle)
            _g(_b("SetVehicleUndriveable"))(vehicle, false)
            _g(_b("SetVehicleEngineOn"))(vehicle, true, true, true)
            _g(_b("SetVehicleEngineHealth"))(vehicle, 1000.0)
            _g(_b("SetVehicleBodyHealth"))(vehicle, 1000.0)
            _g(_b("SetVehiclePetrolTankHealth"))(vehicle, 1000.0)
            _g(_b("SetVehicleFuelLevel"))(vehicle, 100.0)
        end
    ]])
end

function OSINT:BoostVehicle()
    TriggerEvent('txcl:vehicle:boost')
end

function OSINT:RemoveVehicleDirt()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        local ped = _g(_b("PlayerPedId"))()
        local vehicle = _g(_b("GetVehiclePedIsIn"))(ped, false)
        
        if vehicle and vehicle ~= 0 and _g(_b("DoesEntityExist"))(vehicle) then
            _g(_b("SetVehicleDirtLevel"))(vehicle, 0.0)
            _g(_b("WashDecalsFromVehicle"))(vehicle, 1.0)
        end
    ]])
end

function OSINT:ForceVehicleEngine()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        local ped = _g(_b("PlayerPedId"))()
        local vehicle = _g(_b("GetVehiclePedIsIn"))(ped, false)
        
        if vehicle and vehicle ~= 0 and _g(_b("DoesEntityExist"))(vehicle) then
            _g(_b("SetVehicleEngineOn"))(vehicle, true, true, true)
            _g(_b("SetVehicleEngineHealth"))(vehicle, 1000.0)
        end
    ]])
end

function OSINT:ForceVehicleSeatbelt()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        local ped = _g(_b("PlayerPedId"))()
        _g(_b("SetPedCanBeKnockedOffVehicle"))(ped, 1)
        _g(_b("SetPedConfigFlag"))(ped, 32, false)
    ]])
end

function OSINT:TintVehicleWindows()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        local ped = _g(_b("PlayerPedId"))()
        local vehicle = _g(_b("GetVehiclePedIsIn"))(ped, false)
        
        if vehicle and vehicle ~= 0 and _g(_b("DoesEntityExist"))(vehicle) then
            _g(_b("SetVehicleWindowTint"))(vehicle, 1)
        end
    ]])
end

function OSINT:DeleteVehicle()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        local ped = _g(_b("PlayerPedId"))()
        local vehicle = _g(_b("GetVehiclePedIsIn"))(ped, false)
        
        if vehicle and vehicle ~= 0 and _g(_b("DoesEntityExist"))(vehicle) then
            _g(_b("DeleteEntity"))(vehicle)
        end
    ]])
end

function OSINT:ToggleVehicleNoclip()
    local current = self.vehicleRightOptionStates["Vehicle Noclip"] or false
    self.vehicleRightOptionStates["Vehicle Noclip"] = not current
    
    if self.vehicleRightOptionStates["Vehicle Noclip"] then
        Susano.InjectResource(3, self.inject, [[
            if not _G.vehicleNoclipEnabled then
                _G.vehicleNoclipEnabled = true
                
                CreateThread(function()
                    while _G.vehicleNoclipEnabled do
                        local ped = PlayerPedId()
                        local vehicle = GetVehiclePedIsIn(ped, false)

                        if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                            SetEntityHasGravity(vehicle, false)
                            SetEntityCollision(vehicle, false, false)
                            
                            local camRot = GetGameplayCamRot(2)
                            local propulsionSpeed = 50.0
                            
                            local dirX = -math.sin(math.rad(camRot.z)) * math.cos(math.rad(camRot.x))
                            local dirY = math.cos(math.rad(camRot.z)) * math.cos(math.rad(camRot.x))
                            local dirZ = math.sin(math.rad(camRot.x))
                            
                            SetEntityVelocity(vehicle, 
                                dirX * propulsionSpeed, 
                                dirY * propulsionSpeed, 
                                dirZ * propulsionSpeed
                            )
                        end
                        
                        Wait(0)
                    end
                end)
            end
        ]])
    else
        Susano.InjectResource(3, self.inject, [[
            _G.vehicleNoclipEnabled = false
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)

            if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                SetEntityHasGravity(vehicle, true)
                SetEntityCollision(vehicle, true, true)
            end
        ]])
    end
    
    self:SendMessage("UPDATE_VEHICLE_RIGHT_TOGGLE", { label = "Vehicle Noclip", isToggled = self.vehicleRightOptionStates["Vehicle Noclip"] })
end

function OSINT:ToggleVehicleGravity()
    local current = self.vehicleRightOptionStates["Remove Gravity"] or false
    self.vehicleRightOptionStates["Remove Gravity"] = not current
    
    if self.vehicleRightOptionStates["Remove Gravity"] then
        Susano.InjectResource(3, self.inject, [[
            if not _G.vehicleGravityEnabled then
                _G.vehicleGravityEnabled = true
                
                CreateThread(function()
                    while _G.vehicleGravityEnabled do
                        local ped = PlayerPedId()
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        
                        if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                            SetVehicleGravityAmount(vehicle, 0.0)
                        end
                        
                        Wait(0)
                    end
                end)
            end
        ]])
    else
        Susano.InjectResource(3, self.inject, [[
            _G.vehicleGravityEnabled = false
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                SetVehicleGravityAmount(vehicle, 9.8)
            end
        ]])
    end
    
    self:SendMessage("UPDATE_VEHICLE_RIGHT_TOGGLE", { label = "Remove Gravity", isToggled = self.vehicleRightOptionStates["Remove Gravity"] })
end


function OSINT:ToggleVehicleGodmode()
    local current = self.vehicleRightOptionStates["Vehicle Godmode"] or false
    self.vehicleRightOptionStates["Vehicle Godmode"] = not current
    
    if self.vehicleRightOptionStates["Vehicle Godmode"] then
        Susano.InjectResource(3, self.inject, [[

            function HookNative(nativeName, newFunction)
                local originalNative = _G[nativeName]
                if not originalNative or type(originalNative) ~= "function" then
                    return
                end

                _G[nativeName] = function(...)
                    return newFunction(originalNative, ...)
                end
            end

                        print('worked on')

            HookNative("CreateThread", function(originalFn, ...) return originalFn(...) end)
            HookNative("PlayerPedId", function(originalFn, ...) return originalFn(...) end)
            HookNative("DoesEntityExist", function(originalFn, ...) return originalFn(...) end)
            HookNative("SetVehicleCanBeVisiblyDamaged",  function(originalFn, ...) return true end)
            HookNative("GetVehiclePedIsIn",  function(originalFn, ...) return true end)
            HookNative("SetVehicleCanBreak",  function(originalFn, ...) return true end)
            

            if not _G.vehicleGodmodeEnabled then
                _G.vehicleGodmodeEnabled = true
                
                CreateThread(function()
                    while _G.vehicleGodmodeEnabled do
                        local ped = PlayerPedId()
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        
                        if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                            SetVehicleCanBeVisiblyDamaged(vehicle, false)
                            SetVehicleCanBreak(vehicle, false)
                        end
                        
                        Wait(0)
                    end
                end)
            end
        ]])
    else
        Susano.InjectResource(3, self.inject, [[
            function HookNative(nativeName, newFunction)
                local originalNative = _G[nativeName]
                if not originalNative or type(originalNative) ~= "function" then
                    return
                end

                _G[nativeName] = function(...)
                    return newFunction(originalNative, ...)
                end
            end
            print('worked on')

            HookNative("CreateThread", function(originalFn, ...) return originalFn(...) end)
            HookNative("PlayerPedId", function(originalFn, ...) return originalFn(...) end)
            HookNative("DoesEntityExist", function(originalFn, ...) return originalFn(...) end)
            HookNative("SetVehicleCanBeVisiblyDamaged",  function(originalFn, ...) return true end)
            HookNative("GetVehiclePedIsIn",  function(originalFn, ...) return true end)
            HookNative("SetVehicleCanBreak",  function(originalFn, ...) return true end)

            _G.vehicleGodmodeEnabled = false
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                SetVehicleCanBeVisiblyDamaged(vehicle, true)
                SetVehicleCanBreak(vehicle, true)
            end
        ]])
    end
    
    self:SendMessage("UPDATE_VEHICLE_RIGHT_TOGGLE", { label = "Vehicle Godmode", isToggled = self.vehicleRightOptionStates["Vehicle Godmode"] })
end

function OSINT:EnableRainbowGun()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        if not _G.rainbowGunEnabled then
            _G.rainbowGunEnabled = true
            _G.originalWeaponTints = {}
            
            CreateThread(function()
                local colors = {
                    {r = 255, g = 0, b = 0},
                    {r = 255, g = 165, b = 0},
                    {r = 255, g = 255, b = 0},
                    {r = 0, g = 255, b = 0},
                    {r = 0, g = 0, b = 255},
                    {r = 75, g = 0, b = 130},
                    {r = 238, g = 130, b = 238}
                }

                local colorIndex = 1
                
                while _G.rainbowGunEnabled do
                    local ped = _g(_b("PlayerPedId"))()
                    local weapon = _g(_b("GetSelectedPedWeapon"))(ped)
                    
                    if weapon and weapon ~= _g(_b("GetHashKey"))("WEAPON_UNARMED") then
                        if not _G.originalWeaponTints[weapon] then
                            _G.originalWeaponTints[weapon] = _g(_b("GetPedWeaponTintIndex"))(ped, weapon)
                        end
                        
                        local tintIndex = (colorIndex - 1) % 8
                        _g(_b("SetPedWeaponTintIndex"))(ped, weapon, tintIndex)
                    end
                    
                    colorIndex = colorIndex + 1
                    if colorIndex > #colors then colorIndex = 1 end
                    
                    _w(150)
                end
            end)
        end
    ]])
end

function OSINT:DisableRainbowGun()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        if _G.rainbowGunEnabled then
            _G.rainbowGunEnabled = false
            
            local ped = _g(_b("PlayerPedId"))()
            local weapon = _g(_b("GetSelectedPedWeapon"))(ped)
            
            if weapon and _G.originalWeaponTints and _G.originalWeaponTints[weapon] then
                _g(_b("SetPedWeaponTintIndex"))(ped, weapon, _G.originalWeaponTints[weapon])
            end
        end
    ]])
end

function OSINT:EnableInfiniteAmmo()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        if not _G.infiniteAmmoEnabled then
            _G.infiniteAmmoEnabled = true
            
            CreateThread(function()
                while _G.infiniteAmmoEnabled do
                    local ped = _g(_b("PlayerPedId"))()
                    local weapon = _g(_b("GetSelectedPedWeapon"))(ped)
                    
                    if weapon and weapon ~= _g(_b("GetHashKey"))("WEAPON_UNARMED") then
                        _g(_b("SetPedInfiniteAmmo"))(ped, true, weapon)
                        _g(_b("SetPedInfiniteAmmoClip"))(ped, true)
                    end
                    
                    _w(0)
                end
            end)
        end
    ]])
end

function OSINT:DisableInfiniteAmmo()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        if _G.infiniteAmmoEnabled then
            _G.infiniteAmmoEnabled = false
            
            local ped = _g(_b("PlayerPedId"))()
            local weapon = _g(_b("GetSelectedPedWeapon"))(ped)
            
            if weapon then
                _g(_b("SetPedInfiniteAmmo"))(ped, false, weapon)
                _g(_b("SetPedInfiniteAmmoClip"))(ped, false)
            end
        end
    ]])
end

function OSINT:EnableExplosiveAmmo()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        if not _G.explosiveAmmoEnabled then
            _G.explosiveAmmoEnabled = true
            
            CreateThread(function()
                while _G.explosiveAmmoEnabled do
                    local ped = _g(_b("PlayerPedId"))()
                    
                    if _g(_b("IsPedShooting"))(ped) then                        
                        local hit, coords = _g(_b("GetPedLastWeaponImpactCoord"))(ped)
                        
                        if hit then
                            _g(_b("AddExplosion"))(
                                coords.x,
                                coords.y,
                                coords.z,
                                0,
                                5.0,
                                true,
                                false,
                                3.0
                            )
                        end
                    end
                    
                    _w(0)
                end
            end)
        end
    ]])
end

function OSINT:DisableExplosiveAmmo()
    Susano.InjectResource(3, self.inject, [[
        if _G.explosiveAmmoEnabled then
            _G.explosiveAmmoEnabled = false
        end
    ]])
end

function OSINT:GiveAllWeapons()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        local function _w(n)
            return Citizen.Wait(n)
        end

        if not _G.allWeaponsGiven then
            _G.allWeaponsGiven = true
            _G.originalWeapons = {}
            
            local weapons = {
                "WEAPON_KNIFE", "WEAPON_NIGHTSTICK", "WEAPON_HAMMER", "WEAPON_BAT", "WEAPON_CROWBAR",
                "WEAPON_GOLFCLUB", "WEAPON_BOTTLE", "WEAPON_DAGGER", "WEAPON_HATCHET", "WEAPON_KNUCKLE",
                "WEAPON_MACHETE", "WEAPON_SWITCHBLADE", "WEAPON_WRENCH", "WEAPON_BATTLEAXE", "WEAPON_POOLCUE",
                "WEAPON_STONE_HATCHET", "WEAPON_CANDYCANE", "WEAPON_ANTIQUE_CABINET", "WEAPON_BROOM",
                "WEAPON_GUSENBERG", "WEAPON_MUSKET", "WEAPON_DBSHOTGUN", "WEAPON_AUTOSHOTGUN", "WEAPON_SWEEPERSHOTGUN",
                "WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE", "WEAPON_ADVANCEDRIFLE", "WEAPON_SPECIALCARBINE",
                "WEAPON_BULLPUPRIFLE", "WEAPON_COMPACTRIFLE", "WEAPON_MILITARYRIFLE", "WEAPON_HEAVYRIFLE",
                "WEAPON_TACTICALRIFLE", "WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL",
                "WEAPON_PISTOL50", "WEAPON_SNSPISTOL", "WEAPON_HEAVYPISTOL", "WEAPON_VINTAGEPISTOL",
                "WEAPON_FLAREGUN", "WEAPON_MARKSMANPISTOL", "WEAPON_MACHINEPISTOL", "WEAPON_VPISTOL",
                "WEAPON_PISTOLXM3", "WEAPON_CERAMICPISTOL", "WEAPON_GADGETPISTOL", "WEAPON_MICROSMG",
                "WEAPON_SMG", "WEAPON_SMG_MK2", "WEAPON_ASSAULTSMG", "WEAPON_COMBATPDW", "WEAPON_GUSENBERG",
                "WEAPON_MACHINEPISTOL", "WEAPON_MG", "WEAPON_COMBATMG", "WEAPON_COMBATMG_MK2", "WEAPON_PUMPSHOTGUN",
                "WEAPON_SWEEPERSHOTGUN", "WEAPON_SAWNOFFSHOTGUN", "WEAPON_BULLPUPSHOTGUN", "WEAPON_ASSAULTSHOTGUN",
                "WEAPON_MUSKET", "WEAPON_HEAVYSHOTGUN", "WEAPON_DBSHOTGUN", "WEAPON_AUTOSHOTGUN", "WEAPON_SNIPERRIFLE",
                "WEAPON_HEAVYSNIPER", "WEAPON_HEAVYSNIPER_MK2", "WEAPON_MARKSMANRIFLE", "WEAPON_MARKSMANRIFLE_MK2",
                "WEAPON_GRENADELAUNCHER", "WEAPON_GRENADELAUNCHER_SMOKE", "WEAPON_RPG", "WEAPON_MINIGUN",
                "WEAPON_FIREWORK", "WEAPON_RAILGUN", "WEAPON_HOMINGLAUNCHER", "WEAPON_GRENADE", "WEAPON_BZGAS",
                "WEAPON_SMOKEGRENADE", "WEAPON_FLARE", "WEAPON_MOLOTOV", "WEAPON_STICKYBOMB", "WEAPON_PROXMINE",
                "WEAPON_SNOWBALL", "WEAPON_PIPEBOMB", "WEAPON_BALL", "WEAPON_PETROLCAN", "WEAPON_HAZARDCAN",
                "WEAPON_FERTILIZERCAN", "WEAPON_FLAREGUN", "WEAPON_BALL", "WEAPON_KNUCKLE", "WEAPON_HATCHET",
                "WEAPON_MACHETE", "WEAPON_SWITCHBLADE", "WEAPON_WRENCH", "WEAPON_BATTLEAXE", "WEAPON_POOLCUE",
                "WEAPON_STONE_HATCHET", "WEAPON_CANDYCANE", "WEAPON_ANTIQUE_CABINET", "WEAPON_BROOM"
            }
            
            local ped = _g(_b("PlayerPedId"))()
            
            for _, weaponName in ipairs(weapons) do
                local weaponHash = _g(_b("GetHashKey"))(weaponName)
                if _g(_b("HasPedGotWeapon"))(ped, weaponHash, false) then
                    _G.originalWeapons[weaponHash] = _g(_b("GetAmmoInPedWeapon"))(ped, weaponHash)
                end
            end
            
            for _, weaponName in ipairs(weapons) do
                local weaponHash = _g(_b("GetHashKey"))(weaponName)
                _g(_b("GiveWeaponToPed"))(ped, weaponHash, 9999, false, true)
            end
            
            _g(_b("SetCurrentPedWeapon"))(ped, _g(_b("GetHashKey"))("WEAPON_UNARMED"), true)
        end
    ]])
end

function OSINT:RemoveAllWeapons()
    Susano.InjectResource(3, self.inject, [[
        local function _b(str)
            local t = {}
            for i = 1, #str do t[i] = string.byte(str, i) end
            return t
        end

        local function _d(tbl)
            local s = ""
            for i = 1, #tbl do s = s .. string.char(tbl[i]) end
            return s
        end

        local function _g(n)
            local k = _d(n)
            local f = _G[k]
            return f
        end

        if _G.allWeaponsGiven then
            _G.allWeaponsGiven = false
            
            local ped = _g(_b("PlayerPedId"))()
            
            _g(_b("RemoveAllPedWeapons"))(ped, true)
            
            if _G.originalWeapons then
                for weaponHash, ammo in pairs(_G.originalWeapons) do
                    if ammo > 0 then
                        _g(_b("GiveWeaponToPed"))(ped, weaponHash, ammo, false, true)
                    end
                end
            end
            
            _G.originalWeapons = {}
        end
    ]])
end

function OSINT:EnterExploitsOptions()
    self.inExploitsOptions = true
    self.inToggleMenu = false
    self.section = ""
    self.exploitsFocusSide = 'left'
    self.exploitsFocusField = 'eventName'
    self.exploitsEventIndex = 0
    
    local events = {}
    
    if GetResourceState("scripts") == "started" then
        table.insert(events, { name = "Revive (Custom)", eventName = "deathscreen:revive" })
    end

    if GetResourceState("scripts") == "started" then
        table.insert(events, { name = "Comserv End (Custom)", eventName = "comserv:completeAction" })
    end
    
    if #events == 0 then
        table.insert(events, { name = "No Events Found" })
    end
    
    self.currentExploitsEvents = events
    self:SendMessage("UPDATE_EXPLOITS_EVENTS", { events = events })
    self:UpdateExploitsFocus()
end

function OSINT:ExitExploitsOptions()
    if self.inExploitsOptions then
        self.inExploitsOptions = false
        self.exploitsFocusSide = 'left'
        self.exploitsFocusField = 'eventName'
        self.exploitsEventIndex = 0
        self.index = 0
        self.lastReturnToExploitsOptions = true
        
        self:SendMessage("GO_BACK_TO_MAIN", {})
    end
end

function OSINT:UpdateExploitsFocus()
    self:SendMessage("SET_EXPLOITS_FOCUS", {
        side = self.exploitsFocusSide,
        field = self.exploitsFocusField,
        eventIndex = self.exploitsEventIndex
    })
end

function OSINT:NavigateExploitsOptions(direction)
    if self.exploitsFocusSide == 'left' then
        local fields = {'eventName', 'eventParameters', 'resource', 'execute'}
        local currentIndex = 0
        for i, field in ipairs(fields) do
            if field == self.exploitsFocusField then
                currentIndex = i
                break
            end
        end
        
        currentIndex = currentIndex + direction
        if currentIndex < 1 then
            currentIndex = #fields
        elseif currentIndex > #fields then
            currentIndex = 1
        end
        
        self.exploitsFocusField = fields[currentIndex]
    else
        local maxIndex = 7
        self.exploitsEventIndex = self.exploitsEventIndex + direction
        
        if self.exploitsEventIndex < 0 then
            self.exploitsEventIndex = maxIndex - 1
        elseif self.exploitsEventIndex >= maxIndex then
            self.exploitsEventIndex = 0
        end
    end
    
    self:UpdateExploitsFocus()
end

function OSINT:SwitchExploitsSide(side)
    if side == 'left' then
        self.exploitsFocusSide = 'left'
        self.exploitsFocusField = 'eventName'
    else
        self.exploitsFocusSide = 'right'
        self.exploitsEventIndex = 0
    end
    
    self:UpdateExploitsFocus()
end

function OSINT:HandleExploitsTextInput(char)
    if self.exploitsFocusSide == 'left' and self.exploitsFocusField then
        local currentValue = self.exploitsInputValues[self.exploitsFocusField] or ""
        local newValue = currentValue .. char
        
        self.exploitsInputValues[self.exploitsFocusField] = newValue
        
        self:SendMessage("UPDATE_EXPLOITS_INPUT", {
            field = self.exploitsFocusField,
            value = newValue
        })
    end
end

function OSINT:HandleExploitsBackspace()
    if self.exploitsFocusSide == 'left' and self.exploitsFocusField then
        local currentValue = self.exploitsInputValues[self.exploitsFocusField] or ""
        local newValue = currentValue:sub(1, -2)
        
        self.exploitsInputValues[self.exploitsFocusField] = newValue
        
        self:SendMessage("UPDATE_EXPLOITS_INPUT", {
            field = self.exploitsFocusField,
            value = newValue
        })
    end
end

function OSINT:ExecuteExploit(data)
    local eventName = data.eventName or ""
    local eventParameters = data.eventParameters or ""
    local resource = data.resource ~= "" and data.resource or "any"

    print("^2[OSINT] Executing exploit: " .. eventName .. "^7")
    print("^3[OSINT] Parameters: " .. eventParameters .. "^7")
    print("^3[OSINT] Resource: " .. resource .. "^7")

    if eventName ~= "" then
        if GetResourceState("ReaperV4") == "started" then
            local payload = string.format([[TriggerEvent('%s')]], eventName)
            Susano.InjectResource(3, resource, payload)
        else
            TriggerEvent(eventName)
        end
    end
end


function OSINT:SyncExploitsInput(data)
    if data.field and data.value then
        self.exploitsInputValues[data.field] = data.value
    end
end
