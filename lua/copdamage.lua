Hooks:PostHook(CopDamage,"damage_melee","ach_copdamage_melee",function(self,attack_data)
	if not AdvancedCrosshair:UseCompatibility_CopDamageMelee() then 
		AdvancedCrosshair.hook_CopDamage_damage_melee(self,attack_data)
	end
end)