require("behaviours/faceentity")

local STOP_RUN_DIST = 60
local SEE_PLAYER_DIST = 60

local function GetPlayer(inst)
    return ThePlayer
end

local function ShouldWork(inst)
    return inst.started and inst.action_target ~= nil
end

local function GetTarget(inst)
    return inst.action_target
end

local function ShouldRunAway(inst)
    return inst.runaway
end

local function ShouldWander(inst)
    return inst.started and inst.position_target ~= nil
end

local FakePlayerBrain = Class(Brain, function(self, inst)
    Brain._ctor(self,inst)
end)

function FakePlayerBrain:OnStart()
    local root = PriorityNode({
        WhileNode(function() return ShouldRunAway(self.inst) end, "RunAway",
            RunAway(self.inst, "player", SEE_PLAYER_DIST, STOP_RUN_DIST)
        ),
        WhileNode(function() return ShouldWork(self.inst) end, "Work",
            FaceEntity(self.inst, GetTarget, GetTarget)
        ),
        WhileNode(function() return not ShouldWander(self.inst) end, "Observing",
            FaceEntity(self.inst, GetPlayer, GetPlayer)
        )
    }, 0.25)

    self.bt = BT(self.inst, root)
end

return FakePlayerBrain