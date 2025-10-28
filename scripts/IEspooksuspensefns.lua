local function TREECHOP(player)
    local params = IE.PARANOIA_SPOOK_PARAMS.TREECHOP

    local suspense = 0

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, params.MAX_DIST_FROM_PLAYER, params.TREE_MUST_TAGS)

    if #ents > 0 then
        if #ents > 20 then
            suspense = suspense + 0.001 * 20
        else
            suspense = suspense + 0.001 * 20
        end
    else
        return 0 -- Don't allow the spook to happen if the player is not near a tree
    end

    if player.replica.inventory ~= nil then
        local handitem = player.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if handitem ~= nil and handitem:HasTag("tool") then
            suspense = suspense + 0.005
        end
    end

    return suspense * 0.1
end

return {
    TREECHOP = TREECHOP
}