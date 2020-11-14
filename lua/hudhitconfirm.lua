
Hooks:PostHook(HUDHitConfirm,"init","advc_init_hud",function(self,hud)
--	AdvancedCrosshair:Init()
end)

HUDHitConfirm._orig_on_hit_confirmed = HUDHitConfirm.on_hit_confirmed
function HUDHitConfirm:on_hit_confirmed(...)
	if not AdvancedCrosshair:IsHitmarkerEnabled() then 
		return self:_orig_on_hit_confirmed(self,...)
	end
end

HUDHitConfirm._orig_on_hs_confirmed = HUDHitConfirm.on_headshot_confirmed
function HUDHitConfirm:on_headshot_confirmed(...)
	if not AdvancedCrosshair:IsHitmarkerEnabled() then 
		return self:_orig_on_hs_confirmed(self,...)
	end
end

HUDHitConfirm._orig_on_crit_confirmed = HUDHitConfirm.on_crit_confirmed
function HUDHitConfirm:on_crit_confirmed(...)
	if not AdvancedCrosshair:IsHitmarkerEnabled() then 
		return self:_orig_on_crit_confirmed(self,...)
	end
end