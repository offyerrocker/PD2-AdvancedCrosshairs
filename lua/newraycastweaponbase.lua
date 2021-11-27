Hooks:PostHook(NewRaycastWeaponBase,"toggle_firemode","ach_toggle_firemode",function(self,skip_post_event)
	AdvancedCrosshair:CheckCrosshair()
end)

local ids_auto = Idstring("auto")
local ids_single = Idstring("single")
Hooks:PostHook(NewRaycastWeaponBase,"reset_cached_gadget","ach_reset_cached_gadget",function(self)
--called on toggle underbarrel
	local firemode
	local recorded_firemode = self:get_recorded_fire_mode()
	if recorded_firemode == ids_single then 
		firemode = "single"
	elseif recorded_firemode == ids_auto then 
		firemode = "auto"
	end


	AdvancedCrosshair:CheckCrosshair({
		firemode = firemode
	})
end)