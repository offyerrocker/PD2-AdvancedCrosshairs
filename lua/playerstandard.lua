Hooks:PostHook(PlayerStandard,"_start_action_equip_weapon","advc_init_plyst",function(self,t)
--	AdvancedCrosshair:Init(managers.hud._hud_hit_confirm._hud_panel,nil,unit)
	AdvancedCrosshair:CheckCrosshair()
	AdvancedCrosshair:SetBloom(0)
	--Message.OnSwitchWeapon is called on UNEQUIP, not on weapon equip. so hooking this is what we gotta do.
end)
