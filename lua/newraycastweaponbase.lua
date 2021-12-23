Hooks:PostHook(NewRaycastWeaponBase,"toggle_firemode","ach_toggle_firemode",function(self,skip_post_event)
	if AdvancedCrosshair:UseCompatibility_NewRaycastWeaponBaseToggleFiremode() then
		AdvancedCrosshair:CheckCrosshair()
	end
end)

Hooks:PostHook(NewRaycastWeaponBase,"reset_cached_gadget","ach_reset_cached_gadget",function(self)
--called on toggle underbarrel
	if AdvancedCrosshair:UseCompatibility_NewRaycastWeaponBaseResetCachedGadget() then
		AdvancedCrosshair.hook_NewRaycastWeaponBase_reset_cached_gadget(self)
	end
end)