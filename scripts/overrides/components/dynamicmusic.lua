local DynamicMusic = require("components/dynamicmusic")
local old_DynamicMusic_ctor = DynamicMusic._ctor
DynamicMusic._ctor = function(self, ...)
    old_DynamicMusic_ctor(self, ...)

    _G.IE.OverrideListenForEventFn(self.inst, "playeractivated", nil, function(old_fn, inst, player, ...)
        if old_fn then
            old_fn(inst, player, ...)
        end

        _G.IE.OverrideListenForEventFn(self.inst, "goinsane", player, function(old_fn, ...)
            if old_fn then
                -- old_fn(...) -- I guess this will suffice for now
            end
        end, -1)
    end, -1)
end