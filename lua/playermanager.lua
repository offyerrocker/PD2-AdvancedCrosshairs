
Hooks:PostHook(PlayerManager,"check_skills","ach_init_pm",function(self)
	if not AdvancedCrosshair:UseCompatibility_PlayerManagerCheckSkill() then 
		AdvancedCrosshair:OnPlayerManagerCheckSkills(self)
	end
end)
