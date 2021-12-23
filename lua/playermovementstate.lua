Hooks:PostHook(PlayerMovementState,"enter","ach_enter_player_state",function(self,state_data,enter_data)
	if AdvancedCrosshair:UseCompatibility_PlayerMovementStateEnter() then
		AdvancedCrosshair:CheckCrosshair()
	end
end)