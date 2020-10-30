Hooks:PostHook(PlayerMaskOff,"exit","advc_maskup",function(self,state_data, new_state_name)
	AdvancedCrosshair:CheckCrosshair()
end)