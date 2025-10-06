local Spooks = require("IEspooks")

local function PickASpook(self)
    local isnight = TheWorld.state.isnight
    local isday = TheWorld.state.isday
    local isplayeronboat = self.inst:GetCurrentPlatform() ~= nil
    local isplayerindark = self.inst:IsInLight()
    local canplayerseeindark = CanEntitySeeInDark(self.inst)
    local isincombat = (GetTime() - self.lastfighttime < IE.IN_COMBAT_DURATION)
    local isbusyworking = (GetTime() - self.lastbusytime < IE.BUSY_DURATION)

    local _node_id = TheWorld.topology.ids[TheWorld.Map:GetNodeIdAtPoint(self.inst:GetPosition():Get())]
    local current_room_name = string.split(_node_id, ":")[3]

    local spook_weights = {  }
    local spook_excludes = {  }
    local totalweight = 0
    for spook, weights in pairs(IE.PARANOIA_SPOOK_WEIGHTS) do
        spook_weights[spook] = 0

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

local function OnParanoiaStageChanged(inst, data)
    if data.newstage >= IE.PARANOIA_STAGES.STAGE1 then
        inst.components.paranoiaspooks:Start()
    else
        inst.components.paranoiaspooks:Stop()
    end
end

local function OnSanityDelta(inst, data)
    inst.components.paranoiaspooks.paranoia_sources.sanity = 1 - math.min(1, data.newpercent / IE.PARANOIA_THRESHOLDS[IE.PARANOIA_STAGES.STAGE1])
end

local function OnDeath(inst)
    inst:StopUpdatingComponent(inst.components.paranoiaspooks)
end

local ParanoiaSpooks = Class(function(self, inst)
	self.inst = inst

    self.is_paranoid = false -- false == stage 0, slowly decrease paranoia

    self.paranoia = 0

    if IE.DEV then
        self.paranoia_threshold = 6
    else
        self.paranoia_threshold = 1200
    end

    self.paranoia_sources = {  }
    self.paranoia_dropoff = 1

    self.next_spook = nil

    self.lastfighttime = -10
    self.lastbusytime = -10

    inst:ListenForEvent("performaction", CheckAction)
    inst:ListenForEvent("sanitydelta", OnSanityDelta)
    inst:ListenForEvent("change_paranoia_stage", OnParanoiaStageChanged)
    inst:ListenForEvent("buildsuccess", function() self.lastbusytime = GetTime() end)

    inst:ListenForEvent("death", OnDeath)

    self.inst:StartUpdatingComponent(self)
end)

function ParanoiaSpooks:OnSave()
    return {
        paranoia = self.paranoia,
        paranoia_threshold = self.paranoia_threshold,
        next_spook = self.next_spook
    }
end

function ParanoiaSpooks:OnLoad(data)
    self.paranoia = data.paranoia
    self.paranoia_threshold = data.paranoia_threshold
    self.next_spook = data.next_spook
end

function ParanoiaSpooks:OnRemoveEntity()
    self:OnRemoveFromEntity()
end

function ParanoiaSpooks:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("performaction", CheckAction)
    self.inst:RemoveEventCallback("sanitydelta", OnSanityDelta)
    self.inst:RemoveEventCallback("change_paranoia_stage", OnParanoiaStageChanged)
    self.inst:RemoveEventCallback("death", OnDeath)
end

function ParanoiaSpooks:Start()
    self.is_paranoid = true
end

function ParanoiaSpooks:Stop()
    self.is_paranoid = false
end

function ParanoiaSpooks:Spook(type)
    if type == IE.PARANOIA_SPOOK_TYPES.TREECHOP then
        Spooks.TreeChoppingSpook(self)
    elseif type == IE.PARANOIA_SPOOK_TYPES.FOOTSTEPS then
        Spooks.FootstepsSpook(self)
    elseif type == IE.PARANOIA_SPOOK_TYPES.FOOTSTEPS_RUSH then
        Spooks.FootstepsRushSpook(self)
    elseif type == IE.PARANOIA_SPOOK_TYPES.BIRDSINK then
        Spooks.OceanSinkBirdSpook(self)
    elseif type == IE.PARANOIA_SPOOK_TYPES.SCREECH then
        Spooks.ScreechSpook(self)
    elseif type == IE.PARANOIA_SPOOK_TYPES.WHISPER_QUIET then
        Spooks.WhisperQuiet(self)
    elseif type == IE.PARANOIA_SPOOK_TYPES.WHISPER_LOUD then
        Spooks.WhisperLoud(self)
    end
end

function ParanoiaSpooks:ForcePickSpook()
    return PickASpook(self)
end

function ParanoiaSpooks:OnUpdate(dt)
    if self.next_spook ~= nil then
        -- [TODO] Add better spook timing picking
        self:Spook(IE.PARANOIA_SPOOK_TYPES[self.next_spook])
        self.next_spook = nil
        self.paranoia = 0

        return
    end

    if self.is_paranoid then
        for source, amount in pairs(self.paranoia_sources) do
            self.paranoia = self.paranoia + amount * dt
        end

        if self.paranoia_threshold <= self.paranoia then
            self.next_spook = PickASpook(self)
        end
    elseif self.paranoia > 0 then
        self.paranoia = self.paranoia - self.paranoia_dropoff * dt
        if self.paranoia < 0 then
            self.paranoia = 0
        end
    end
end

return ParanoiaSpooks