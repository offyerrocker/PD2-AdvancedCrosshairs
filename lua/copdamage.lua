--the only "unprotected" change this makes is adding the "crit" flag to the attack_data.
--so the only way this could cause issues is if another mod relied on this flag,
--or saved the crit value as a non-boolean value and attempted some sort of operation that isn't allowed on bools.

--so yeah don't look at me,
--if you crashed, look further up the script stack before you report this bug to me
local advanced_crosshairs_did_not_crash_you = CopDamage.roll_critical_hit
function CopDamage:roll_critical_hit(attack_data,...)
	local result = {advanced_crosshairs_did_not_crash_you(self,attack_data,...)}
	if result[1] and type(attack_data) == "table" then 
		attack_data.crit = true
	end
	return unpack(result)
end


Hooks:PostHook(CopDamage,"damage_melee","ach_copdamage_melee",function(self,attack_data)
	--damage is applied even if the enemy is already dead, resulting in hitsounds/hitmarkers on meleeing enemy corpses
	--therefore, deaths are detected separately in ACH, from Message.OnEnemyKilled, as a workaround
	if not self._dead then 
		AdvancedCrosshair:OnEnemyHit(self._unit,attack_data)
	end
end)