Hooks:PostHook(PlayerStandard,"_start_action_equip_weapon","ach_init_plyst",function(self,t)
	if not AdvancedCrosshair:UseCompatibility_PlayerStandardStartEquipWeapon() then 
		AdvancedCrosshair.hook_PlayerStandard_start_action_equip_weapon(self,t)
	end
end)

Hooks:PostHook(PlayerStandard,"_start_action_steelsight","ach_start_steelsight",function(self,t,gadget_state)
	if not AdvancedCrosshair:UseCompatibility_PlayerStandardOnSteelsight() then 
		AdvancedCrosshair:CheckCrosshair()
	end
end)
Hooks:PostHook(PlayerStandard,"_end_action_steelsight","ach_end_steelsight",function(self,t)
	if not AdvancedCrosshair:UseCompatibility_PlayerStandardOnSteelsight() then 
		AdvancedCrosshair:CheckCrosshair()
	end
end)

