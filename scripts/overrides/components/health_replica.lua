local Health = require("components/health_replica")
local old_Health_SetIsDead = Health.SetIsDead
Health.SetIsDead = function(self, isdead, ...)
    old_Health_SetIsDead(self, isdead, ...)

    if self.inst.components.paranoiaspooks then
        if isdead then
            self.inst.components.paranoiaspooks:_OnDeath()
        else
            self.inst.components.paranoiaspooks:_OnRevive()
        end
    end
end