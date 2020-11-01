

Hooks:PostHook(PlayerManager,"check_skills","advancedcrosshair_init_pm",function(self)

--	AdvancedCrosshair:Init(managers.hud._hud_hit_confirm._hud_panel,nil,unit)
	
	
	self._message_system:unregister(Message.OnWeaponFired,"advancedcrosshair_OnWeaponFired")
	self._message_system:unregister(Message.OnEnemyShot,"advancedcrosshair_OnEnemyShot")
--	pm._message_system:unregister(Message.OnEnemyKilled,"advancedcrosshair_OnEnemyKilled")
--	pm._message_system:unregister(Message.OnHeadShot,"advancedcrosshair_OnHeadShot")
--	pm._message_system:unregister(Message.OnLethalHeadShot,"advancedcrosshair_OnLethalHeadShot")
	
	
	--enemy
	self._message_system:register(Message.OnWeaponFired,"advancedcrosshair_OnWeaponFired",
		function(weapon_unit,result)
			local weapon_base = weapon_unit:base()
			if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base._setup.user_unit == managers.player:local_player() then 
				AdvancedCrosshair:AddBloom()
			end
		end
	)
	self._message_system:register(Message.OnEnemyShot,"advancedcrosshair_OnEnemyShot",callback(AdvancedCrosshair,AdvancedCrosshair,"ActivateHitmarker"))
	--[[
	function(attacker_unit,attack_data)
		if attack_data and attacker_unit == self:local_player() then 
			local result = attack_data.result
			local result_type = result and result.type
			local pos = attack_data.pos
			local headshot = attack_data.headshot
			local crit = attack_data.crit --flag indicating crit is added from the mod, not here in vanilla

			local weapon_unit = attack_data.weapon_unit
			local base = weapon_unit and weapon_unit:base()
			
			
			if result_type == "death" then 
--				AdvancedCrosshair:ShowHitmarker(result)
				--
			else
				AdvancedCrosshair:log("Result type " .. tostring(result_type))
			end
		end
	end)
	--]]
--	pm._message_system:register(Message.OnEnemyShot,"advancedcrosshair_OnEnemyShot",callback(AdvancedCrosshair,AdvancedCrosshair,"OnEnemyShot"))
--	pm._message_system:register(Message.OnEnemyKilled,"advancedcrosshair_OnEnemyKilled",callback(AdvancedCrosshair,AdvancedCrosshair,"OnEnemyKilled"))
--	pm._message_system:register(Message.OnHeadShot,"advancedcrosshair_OnHeadShot",callback(AdvancedCrosshair,AdvancedCrosshair,"OnHeadShot"))
--	pm._message_system:register(Message.OnLethalHeadShot,"advancedcrosshair_OnLethalHeadShot",callback(AdvancedCrosshair,AdvancedCrosshair,"OnLethalHeadShot"))



--	self._message_system:unregister(Message.OnSwitchWeapon,"advancedcrosshair_OnSwitchWeapon")
--	self._message_system:register(Message.OnSwitchWeapon,"advancedcrosshair_OnSwitchWeapon",callback(AdvancedCrosshair,AdvancedCrosshair,"CheckCrosshair"))
end)
