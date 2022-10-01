--the only "unprotected" change this makes is adding the "ach_crit" flag to the attack_data.
--so the only way this could cause issues is if another mod relied on this flag,
--or saved it as a non-boolean value and attempted some sort of operation that isn't allowed on bools.

--so yeah don't look at me,
--if you crashed, look elsewhere in the script stack before you report this bug to me

local advanced_crosshairs_did_not_crash_you = Hooks:GetFunction(CopDamage,"roll_critical_hit")
CopDamage.ach_orig_roll_critical_hit = advanced_crosshairs_did_not_crash_you
function CopDamage:roll_critical_hit(attack_data,...)
	local result = {advanced_crosshairs_did_not_crash_you(self,attack_data,...)}
	if attack_data then 
		attack_data.ach_crit = result[1]
	end
	return unpack(result)
end


Hooks:PostHook(CopDamage,"damage_melee","ach_copdamage_melee",function(self,attack_data)
	if not AdvancedCrosshair:UseCompatibility_CopDamageMelee() then 
		AdvancedCrosshair.hook_CopDamage_damage_melee(self,attack_data)
	end
end)