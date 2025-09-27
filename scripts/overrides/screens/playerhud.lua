local PlayerHud = require("screens/playerhud")
local old_GoInsane = PlayerHud.GoInsane
PlayerHud.GoInsane = function(self, ...)
    old_GoInsane(self, ...) -- Run the function in case some other mod is using it
    self.vig:GetAnimState():PlayAnimation("basic", true) -- But override the "insane" animation of the vignette
end