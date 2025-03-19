Hooks:PostHook(PlayerManager,"check_skills","ach_init_pm",function(self)
	if not AdvancedCrosshair:UseCompatibility_PlayerManagerCheckSkill() then 
		AdvancedCrosshair:OnPlayerManagerCheckSkills(self)
	end
end)

Hooks:PostHook(PlayerManager,"spawned_player","ach_respawn_pm",function(self,id,unit)
	-- on local player respawn from custody,
	-- recreate crosshairs;
	-- hopefully fixes the bug causing crosshairs to not reappear after custody
	-- honestly if this doesn't fix it i'm just adding a toggle to allow crosshairs in custody.
	if id == 1 then
		AdvancedCrosshair:RemoveAllCrosshairs(true)
	end
end)