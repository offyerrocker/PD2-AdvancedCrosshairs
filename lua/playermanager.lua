
Hooks:PostHook(PlayerManager,"check_skills","ach_init_pm",function(self)
	if not AdvancedCrosshair:UseCompatibility_PlayerManagerCheckSkill() then 
		AdvancedCrosshair:OnPlayerManagerCheckSkills(self)
	end
end)

Hooks:PreHook(PlayerManager,"on_enter_custody","ach_on_player_enter_custody",function(self,player_unit,already_dead)
	if player_unit == self:local_player() then 
		AdvancedCrosshair:ClearCache()
		AdvancedCrosshair:RemoveAllCrosshairs(true)
	end
end)