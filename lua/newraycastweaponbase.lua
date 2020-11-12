Hooks:PostHook(NewRaycastWeaponBase,"toggle_firemode","ach_toggle_firemode",function(self,skip_post_event)
	AdvancedCrosshair:CheckCrosshair()
end)

Hooks:PostHook(NewRaycastWeaponBase,"reset_cached_gadget","ach_reset_cached_gadget",function(self)
--called on toggle underbarrel
	AdvancedCrosshair:CheckCrosshair()
end)