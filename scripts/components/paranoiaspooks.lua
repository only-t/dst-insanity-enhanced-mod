require("mathutil")

local Spooks = require("IEspooks")
local SpookOppurtunityFns = require("IEspookopportunityfns")

local function PickASpook(self)
    local isforest = TheWorld:HasTag("forest")
    local iscave = TheWorld:HasTag("cave")
    local isnight = TheWorld.state.iscavenight
    local isday = TheWorld.state.iscaveday
    local isplayeronboat = self.inst:GetCurrentPlatform() ~= nil
    local isplayerindark = self.inst:IsInLight()
    local canplayerseeindark = CanEntitySeeInDark(self.inst)
    local isincombat = (GetTime() - self.lastfighttime < IE.IN_COMBAT_DURATION)
    local isbusyworking = (GetTime() - self.lastbusytime < IE.BUSY_DURATION)

    -- print(TheWorld.topology.ids[TheWorld.Map:GetNodeIdAtPoint(ThePlayer:GetPosition():Get())])
    local _node_id = TheWorld.topology.ids[TheWorld.Map:GetNodeIdAtPoint(self.inst:GetPosition():Get())]
    local current_room_name = "other"
    if _node_id ~= nil then
        current_room_name = string.split(_node_id, ":")[3]
    end

    local spook_weights = {  }
    local spook_excludes = {  }
    local totalweight = 0
    for spook, weights in pairs(IE.PARANOIA_SPOOK_WEIGHTS) do
        spook_weights[spook] = 0

        if weights["cave"] ~= nil and iscave then
            if weights["cave"] == -1 then
                spook_excludes[spook] = true
            else
                totalweight = totalweight + weights["cave"]
                spook_weights[spook] = spook_weights[spook] + weights["cave"]
            end
        end

        if weights["forest"] ~= nil and isforest then
            if weights["forest"] == -1 then
                spook_excludes[spook] = true
            else
                totalweight = totalweight + weights["forest"]
                spook_weights[spook] = spook_weights[spook] + weights["forest"]
            end
        end

        if weights["night"] ~= nil and isnight then
            if weights["night"] == -1 then
                spook_excludes[spook] = true
            else
                totalweight = totalweight + weights["night"]
                spook_weights[spook] = spook_weights[spook] + weights["night"]
            end
        end

        if weights["day"] ~= nil and isday then
            if weights["day"] == -1 then
                spook_excludes[spook] = true
            else
                totalweight = totalweight + weights["day"]
                spook_weights[spook] = spook_weights[spook] + weights["day"]
            end
        end

        if weights["boat"] ~= nil and isplayeronboat then
            if weights["boat"] == -1 then
                spook_excludes[spook] = true
            else
                totalweight = totalweight + weights["boat"]
                spook_weights[spook] = spook_weights[spook] + weights["boat"]
            end
        end

        if weights["land"] ~= nil and not isplayeronboat then
            if weights["land"] == -1 then
                spook_excludes[spook] = true
            else
                totalweight = totalweight + weights["land"]
                spook_weights[spook] = spook_weights[spook] + weights["land"]
            end
        end

        if weights["isindark"] ~= nil and not isplayerindark then
            if weights["isindark"] == -1 then
                spook_excludes[spook] = true
            else
                totalweight = totalweight + weights["isindark"]
                spook_weights[spook] = spook_weights[spook] + weights["isindark"]
            end
        end

        if weights["canseeindark"] ~= nil and canplayerseeindark then
            if weights["canseeindark"] == -1 then
                spook_excludes[spook] = true
            else
                totalweight = totalweight + weights["canseeindark"]
                spook_weights[spook] = spook_weights[spook] + weights["canseeindark"]
            end
        end

        if weights["isincombat"] ~= nil and isincombat then
            if weights["isincombat"] == -1 then
                spook_excludes[spook] = true
            else
                totalweight = totalweight + weights["isincombat"]
                spook_weights[spook] = spook_weights[spook] + weights["isincombat"]
            end
        end

        if weights["isbusyworking"] ~= nil and isbusyworking then
            if weights["isbusyworking"] == -1 then
                spook_excludes[spook] = true
            else
                totalweight = totalweight + weights["isbusyworking"]
                spook_weights[spook] = spook_weights[spook] + weights["isbusyworking"]
            end
        end

        if weights["biomes"] ~= nil then
            if weights["biomes"][current_room_name] == -1 then
                spook_excludes[spook] = true
            else
                totalweight = totalweight + (weights["biomes"][current_room_name] or weights["biomes"]["other"])
                spook_weights[spook] = spook_weights[spook] + (weights["biomes"][current_room_name] or weights["biomes"]["other"])
            end
        end
    end

    if self.last_spook ~= nil and spook_excludes[self.last_spook] == nil then
        spook_excludes[self.last_spook] = true
    end

    if IE.DEV then
        print("total weight = "..tostring(totalweight))
        print("{")
        for spook, weight in pairs(spook_weights) do
            if spook_excludes[spook] then
                print("    "..spook.." = EXCLUDED!")
            else
                print("    "..spook.." = "..tostring(weight))
            end
        end
        print("}")
    end

    local rnd = math.random() * totalweight
    for spook, weight in pairs(spook_weights) do
        if not spook_excludes[spook] then
            rnd = rnd - weight
            if rnd <= 0 then
                if IE.DEV then
                    print("chosen spook: "..spook)
                end
                
                return spook
            end
        end
    end
end

local function CheckAction(inst)
    if inst:HasTag("attack") then
        local target = inst.replica.combat:GetTarget()
        if target and
        target:HasTag("_combat") and
        not ((target:HasTag("prey") and not target:HasTag("hostile")) or
        target:HasTag("bird") or
        target:HasTag("butterfly") or
        target:HasTag("shadow") or
        target:HasTag("shadowchesspiece") or
        target:HasTag("noepicmusic") or
        target:HasTag("thorny") or
        target:HasTag("smashable") or
        target:HasTag("wall") or
        target:HasTag("engineering") or
        target:HasTag("smoldering") or
        target:HasTag("veggie")) then
            if target:HasTag("shadowminion") or target:HasTag("abigail") then
                local follower = target.replica.follower
                if not (follower and follower:GetLeader() == inst) then
                    inst.components.paranoiaspooks.lastfighttime = GetTime()
                end
            else
                inst.components.paranoiaspooks.lastfighttime = GetTime()
            end
        end
    end

    if inst:HasTag("working") then
        inst.components.paranoiaspooks.lastbusytime = GetTime()
    end
end

local function OnSanityDelta(inst, data)
    local strength = 1 - math.min(1, data.newpercent / IE.PARANOIA_SOURCES.SANITY.START_THRESHOLD)
    if strength > 0 then
        inst.components.paranoiaspooks.is_paranoid = true

        if inst.components.paranoiaspooks.paranoia_sources.sanity == nil then
            inst.components.paranoiaspooks.paranoia_sources.sanity = {  }
        end

        inst.components.paranoiaspooks.paranoia_sources.sanity.additive = IE.PARANOIA_SOURCES.SANITY.GAIN_ADDITIVE * strength
    else
        inst.components.paranoiaspooks.paranoia_sources.sanity = nil
        inst.components.paranoiaspooks.is_paranoid = false
    end
end

local function OnBuildSuccess(inst)
    inst.components.paranoiaspooks.lastbusytime = GetTime()
end

local function OnHealthDelta(inst, data)
    local strength = (1 - math.min(1, data.newpercent / IE.PARANOIA_SOURCES.LOW_HEALTH.START_THRESHOLD))
    if strength > 0 then
        if inst.components.paranoiaspooks.paranoia_sources.low_health == nil then
            inst.components.paranoiaspooks.paranoia_sources.low_health = {  }
        end

        inst.components.paranoiaspooks.paranoia_sources.low_health.additive = IE.PARANOIA_SOURCES.LOW_HEALTH.GAIN_ADDITIVE * strength
        inst.components.paranoiaspooks.paranoia_sources.low_health.multiplicative = 1 + (IE.PARANOIA_SOURCES.LOW_HEALTH.GAIN_MULTIPLICATIVE - 1) * strength
    else
        inst.components.paranoiaspooks.paranoia_sources.low_health = nil
    end
end

local function OnEnterDark(inst)
    if inst.components.paranoiaspooks.paranoia_sources.darkness == nil then
        inst.components.paranoiaspooks.paranoia_sources.darkness = {  }
    end

    inst.components.paranoiaspooks.paranoia_sources.darkness.additive = IE.PARANOIA_SOURCES.DARKNESS.GAIN_ADDITIVE
    inst.components.paranoiaspooks.paranoia_sources.darkness.multiplicative = IE.PARANOIA_SOURCES.DARKNESS.GAIN_MULTIPLICATIVE
end

local function OnEnterLight(inst)
    inst.components.paranoiaspooks.paranoia_sources.darkness = nil
end

local function OnCaveDayState(inst, iscaveday)
    if iscaveday then
        if inst.components.paranoiaspooks.paranoia_sources.notday == nil then
            inst.components.paranoiaspooks.paranoia_sources.notday = {  }
        end

        inst.components.paranoiaspooks.paranoia_sources.notday.multiplicative = IE.PARANOIA_SOURCES.NOTDAY.GAIN_MULTIPLICATIVE
    else
        inst.components.paranoiaspooks.paranoia_sources.notday = nil
    end
end

local function TryToSpook(self)
    if SpookOppurtunityFns[self.next_spook] == nil then
        IE.modprint(IE.WARN, "Trying to trigger a non-existant spook!",
        "next_spook - "..tostring(self.next_spook))
        return
    end

    local rnd = math.random()
    local spook_chance = SpookOppurtunityFns[self.next_spook](self.inst)

    if IE.DEV then
        print("trying to spook:")
        print("    rnd - "..tostring(rnd))
        print("    spook chance - "..tostring(math.pow(spook_chance, IE.E_NUM)))
    end

    if rnd <= math.pow(spook_chance, IE.E_NUM) then
        local spook = self:Spook(IE.PARANOIA_SPOOKS[self.next_spook])
        self.paranoia = self.paranoia - self.paranoia * IE.PARANOIA_SPOOK_COSTS[self.next_spook]
        self.next_spook = nil
        self.pending_spook_timeout_curtime = 0

        self.try_spook_task:Cancel()
        self.try_spook_task = nil
    end
end

local ParanoiaSpooks = Class(function(self, inst)
	self.inst = inst

    if inst.replica.sanity == nil then
        IE.modprint(IE.WARN, "Trying to add ParanoiaSpooks but that entity doesn't have the Sanity replica!",
                             "inst - "..tostring(inst))
        inst:DoTaskInTime(0, function() -- Wait 1 tick to let the component get fully created
            inst:RemoveComponent("paranoiaspooks") -- Then remove it
        end)

        return
    end

    self.debug_update_print = false

    self.spook_intensity = IE.CURRENT_SETTINGS[IE.MOD_SETTINGS.SETTINGS.SPOOK_INTENSITY.ID]

    self.is_paranoid = false -- false == slowly decrease paranoia

    self.paranoia = 0
    self.suspense = 0 -- For better spook timing

    self.paranoia_sources = {  }
    self.paranoia_dropoff = IE.PARANOIA_DROPOFF

    self.next_spook = nil
    self.last_spook = nil -- Try hard to not do the same spook twice in a row
    self.pending_spook_timeout = IE.PARANOIA_SPOOK_TIMEOUT -- We will allow this amount of time to pass until we reset the spook IF it wasn't able to trigger
    self.pending_spook_timeout_curtime = 0
    self.isdead = false

    self.lastfighttime = -IE.IN_COMBAT_DURATION
    self.lastbusytime = -IE.BUSY_DURATION

    inst:StartUpdatingComponent(self)
end)

function ParanoiaSpooks:OnSave()
    return {
        paranoia = self.paranoia,
        next_spook = self.next_spook
    }
end

function ParanoiaSpooks:OnLoad(data)
    self.paranoia = data.paranoia
    self.next_spook = data.next_spook
end

function ParanoiaSpooks:OnRemoveEntity()
    self:OnRemoveFromEntity()
end

function ParanoiaSpooks:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("performaction", CheckAction)
    self.inst:RemoveEventCallback("sanitydelta", OnSanityDelta)
    self.inst:RemoveEventCallback("buildsuccess", OnBuildSuccess)
    self.inst:RemoveEventCallback("healthdelta", OnHealthDelta)
    self.inst:RemoveEventCallback("enterdark", OnEnterDark)
    self.inst:RemoveEventCallback("enterlight", OnEnterLight)

    if self.next_spook then
        self:TimeoutSpook()
    end

    self.paranoia = 0
end

function ParanoiaSpooks:Init()
    self.inst:ListenForEvent("buildsuccess", OnBuildSuccess)
    self.inst:ListenForEvent("performaction", CheckAction)
    self.inst:ListenForEvent("sanitydelta", OnSanityDelta)
    OnSanityDelta(self.inst, { newpercent = self.inst.replica.sanity:GetPercent() })

    self.inst:ListenForEvent("healthdelta", OnHealthDelta)
    OnHealthDelta(self.inst, { newpercent = self.inst.replica.health:GetPercent() })

    self.inst:ListenForEvent("enterdark", OnEnterDark)
    self.inst:ListenForEvent("enterlight", OnEnterLight)

    if TheWorld:HasTag("cave") then
        self.paranoia_sources.caving = { additive = IE.PARANOIA_SOURCES.CAVING.GAIN_ADDITIVE }
    else
        self:WatchWorldState("iscaveday", OnCaveDayState)
        OnCaveDayState(self.inst, TheWorld.state.iscaveday)
    end
end

function ParanoiaSpooks:_OnDeath()
    if not self.isdead then
        self.inst:RemoveEventCallback("performaction", CheckAction)
        self.inst:RemoveEventCallback("sanitydelta", OnSanityDelta)
        self.inst:RemoveEventCallback("buildsuccess", OnBuildSuccess)

        if self.next_spook then
            self:TimeoutSpook()
        end
        
        self.paranoia = 0

        self.inst:StopUpdatingComponent(self)

        self.isdead = true
    end
end

function ParanoiaSpooks:_OnRevive()
    if self.isdead then
        self.inst:ListenForEvent("performaction", CheckAction)
        self.inst:ListenForEvent("sanitydelta", OnSanityDelta)
        self.inst:ListenForEvent("buildsuccess", OnBuildSuccess)

        self.inst:StartUpdatingComponent(self)

        self.isdead = false
    end
end

function ParanoiaSpooks:Start()
    self.is_paranoid = true
end

function ParanoiaSpooks:Stop()
    self.is_paranoid = false
end

function ParanoiaSpooks:TimeoutSpook()
    self.next_spook = nil
    self.last_spook = nil
    self.paranoia = self.paranoia - self.paranoia * 0.1 -- Give the player some time before attempting another spook
    self.pending_spook_timeout_curtime = 0
    
    if self.try_spook_task ~= nil then
        self.try_spook_task:Cancel()
        self.try_spook_task = nil
    end
end

function ParanoiaSpooks:Spook(type)
    -- [TODO] Make this more simple, stupid
    if type == IE.PARANOIA_SPOOKS.TREECHOP then
        return Spooks.TreeChoppingSpook(self)
    elseif type == IE.PARANOIA_SPOOKS.MINING_SOUND then
        return Spooks.MiningSoundSpook(self)
    elseif type == IE.PARANOIA_SPOOKS.FOOTSTEPS then
        return Spooks.FootstepsSpook(self)
    elseif type == IE.PARANOIA_SPOOKS.FOOTSTEPS_RUSH then
        return Spooks.FootstepsRushSpook(self)
    elseif type == IE.PARANOIA_SPOOKS.BIRDSINK then
        return Spooks.OceanSinkBirdSpook(self)
    elseif type == IE.PARANOIA_SPOOKS.SCREECH then
        return Spooks.ScreechSpook(self)
    elseif type == IE.PARANOIA_SPOOKS.WHISPER_QUIET then
        return Spooks.WhisperQuiet(self)
    elseif type == IE.PARANOIA_SPOOKS.WHISPER_LOUD then
        return Spooks.WhisperLoud(self)
    elseif type == IE.PARANOIA_SPOOKS.BERRYBUSH_RUSTLE then
        return Spooks.BerryBushRustleSpook(self)
    elseif type == IE.PARANOIA_SPOOKS.OCEAN_BUBBLES then
        return Spooks.OceanBubblesSpook(self)
    elseif type == IE.PARANOIA_SPOOKS.OCEAN_FOOTSTEPS then
        return Spooks.OceanFootstepsSpook(self)
    elseif type == IE.PARANOIA_SPOOKS.FAKE_PLAYER then
        return Spooks.FakePlayerSpook(self)
    elseif type == IE.PARANOIA_SPOOKS.FAKE_MOB_DEATH then
        return Spooks.FakeMobDeathSpook(self)
    end
end

function ParanoiaSpooks:ForcePickSpook(type)
    if type == IE.PARANOIA_SPOOKS.TREECHOP then
        self.next_spook = "TREECHOP"
        self.last_spook = self.next_spook
    elseif type == IE.PARANOIA_SPOOKS.MINING_SOUND then
        self.next_spook = "MINING_SOUND"
        self.last_spook = self.next_spook
    elseif type == IE.PARANOIA_SPOOKS.FOOTSTEPS then
        self.next_spook = "FOOTSTEPS"
        self.last_spook = self.next_spook
    elseif type == IE.PARANOIA_SPOOKS.FOOTSTEPS_RUSH then
        self.next_spook = "FOOTSTEPS_RUSH"
        self.last_spook = self.next_spook
    elseif type == IE.PARANOIA_SPOOKS.BIRDSINK then
        self.next_spook = "BIRDSINK"
        self.last_spook = self.next_spook
    elseif type == IE.PARANOIA_SPOOKS.SCREECH then
        self.next_spook = "SCREECH"
        self.last_spook = self.next_spook
    elseif type == IE.PARANOIA_SPOOKS.WHISPER_QUIET then
        self.next_spook = "WHISPER_QUIET"
        self.last_spook = self.next_spook
    elseif type == IE.PARANOIA_SPOOKS.WHISPER_LOUD then
        self.next_spook = "WHISPER_LOUD"
        self.last_spook = self.next_spook
    elseif type == IE.PARANOIA_SPOOKS.BERRYBUSH_RUSTLE then
        self.next_spook = "BERRYBUSH_RUSTLE"
        self.last_spook = self.next_spook
    elseif type == IE.PARANOIA_SPOOKS.OCEAN_BUBBLES then
        self.next_spook = "OCEAN_BUBBLES"
        self.last_spook = self.next_spook
    elseif type == IE.PARANOIA_SPOOKS.OCEAN_FOOTSTEPS then
        self.next_spook = "OCEAN_FOOTSTEPS"
        self.last_spook = self.next_spook
    elseif type == IE.PARANOIA_SPOOKS.FAKE_PLAYER then
        self.next_spook = "FAKE_PLAYER"
        self.last_spook = self.next_spook
    elseif type == IE.PARANOIA_SPOOKS.FAKE_MOB_DEATH then
        self.next_spook = "FAKE_MOB_DEATH"
        self.last_spook = self.next_spook
    end

    self.pending_spook_timeout_curtime = 0

    if self.try_spook_task ~= nil then
        self.try_spook_task:Cancel()
        self.try_spook_task = nil
    end

    self.try_spook_task = self.inst:DoPeriodicTask(0.25, function() TryToSpook(self) end)
end

function ParanoiaSpooks:RecalcGhostParanoia()
    -- Shards don't exist on the client, [TODO] fix this >:c
    -- if GetGhostSanityDrain(TheNet:GetServerGameMode()) then
    --     local num_ghosts = TheWorld.shard.components.shard_players:GetNumGhosts()
    --     self.paranoia_sources.player_ghosts = IE.PARANOIA_GHOST_PLAYER_GAIN * num_ghosts
    -- else
    --     self.paranoia_sources.player_ghosts = nil
    -- end

    if self.paranoia_sources.player_ghosts == nil then
        self.paranoia_sources.player_ghosts = {  }
    end
    if self.inst.replica.sanity:IsGhostDrain() then
        self.paranoia_sources.player_ghosts.additive = IE.PARANOIA_SOURCES.PLAYER_GHOSTS.GAIN_ADDITIVE
    else
        self.paranoia_sources.player_ghosts = nil
    end
end

function ParanoiaSpooks:RecalcLonelinessParanoia()
    if #AllPlayers <= 1 then -- Solo players shouldn't be punished
        self.paranoia_sources.loneliness = nil
        return
    end

    for _, player in ipairs(AllPlayers) do
        if self.inst:GetDistanceSqToInst(player) <= IE.PARANOIA_SOURCES.LONELINESS.START_DIST_FROM_OTHERS_SQ then
            self.paranoia_sources.loneliness = nil
            return
        end
    end

    if self.paranoia_sources.loneliness == nil then
        self.paranoia_sources.loneliness = {  }
    end

    self.paranoia_sources.loneliness.additive = IE.PARANOIA_SOURCES.LONELINESS.GAIN_ADDITIVE
end

function ParanoiaSpooks:OnUpdate(dt)
    if self.next_spook ~= nil then
        self.pending_spook_timeout_curtime = self.pending_spook_timeout_curtime + dt

        if self.pending_spook_timeout_curtime >= self.pending_spook_timeout then
            self:TimeoutSpook()
            return
        end

        if self.debug_update_print then
            print("next spook - "..tostring(self.next_spook))
        end

        return
    end

    self:RecalcGhostParanoia()
    self:RecalcLonelinessParanoia()

    if self.debug_update_print then
        print("paranoia sources:")
        for source, amounts in pairs(self.paranoia_sources) do
            print("    "..tostring(source)..":")
            print("        add - "..tostring(amounts.additive))
            print("        mult - "..tostring(amounts.multiplicative))
        end
    end

    if self.is_paranoid and not self.isdead then
        local add = 0
        local multiply = 1
        for _, amounts in pairs(self.paranoia_sources) do
            if amounts.additive ~= nil then
                add = add + amounts.additive
            end

            if amounts.multiplicative then
                multiply = multiply * amounts.multiplicative
            end
        end

        if self.debug_update_print then
            print("current additive - "..tostring(add))
            print("current multiplicative - "..tostring(multiply))
        end

        self.paranoia = self.paranoia + add * multiply * dt

        if self.debug_update_print then
            print("current paranoia - "..tostring(self.paranoia))
        end

        if Lerp(IE.MAX_SPOOK_THRESHOLD, IE.MIN_SPOOK_THRESHOLD, (self.spook_intensity - 1) / IE.MAX_SPOOK_INTENSITY) <= self.paranoia then
            self.next_spook = PickASpook(self)
            self.last_spook = self.next_spook

            if self.try_spook_task ~= nil then
                self.try_spook_task:Cancel()
                self.try_spook_task = nil
            end

            self.try_spook_task = self.inst:DoPeriodicTask(0.4, function() TryToSpook(self) end)
        end
    elseif self.paranoia > 0 then
        self.paranoia = self.paranoia - self.paranoia_dropoff * dt
        if self.paranoia < 0 then
            self.paranoia = 0
        end

        if self.debug_update_print then
            print("current paranoia - "..tostring(self.paranoia))
        end
    end
end

return ParanoiaSpooks