Hooks:PostHook(PlayerStandard,"_start_action_equip_weapon","ach_init_plyst",function(self,t)
	AdvancedCrosshair:CheckCrosshair()
	AdvancedCrosshair:SetCrosshairBloom(0)
	--Message.OnSwitchWeapon is called on UNEQUIP, not on weapon equip. so hooking this is what we gotta do.
end)
