HUDHitConfirm._orig_on_hit_confirmed = HUDHitConfirm.on_hit_confirmed
function HUDHitConfirm:on_hit_confirmed(...)
	if not AdvancedCrosshair:IsHitmarkerEnabled() then 
		return self:_orig_on_hit_confirmed(...)
	end
end

HUDHitConfirm._orig_on_hs_confirmed = HUDHitConfirm.on_headshot_confirmed
function HUDHitConfirm:on_headshot_confirmed(...)
	if not AdvancedCrosshair:IsHitmarkerEnabled() then 
		return self:_orig_on_hs_confirmed(...)
	end
end

HUDHitConfirm._orig_on_crit_confirmed = HUDHitConfirm.on_crit_confirmed
function HUDHitConfirm:on_crit_confirmed(...)
	if not AdvancedCrosshair:IsHitmarkerEnabled() then 
		return self:_orig_on_crit_confirmed(...)
	end
end