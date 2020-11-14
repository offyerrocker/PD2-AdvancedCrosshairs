Hooks:PostHook(PlayerMovementState,"enter","ach_enter_player_state",function(self,state_data,enter_data)
	AdvancedCrosshair:CheckCrosshair()
end)