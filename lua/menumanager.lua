--todo localization
--todo hitmarkers + positioning + queue
--todo alpha
--todo bloom based on weapon kick
--todo bloom delay for things like focus rifle
--todo akimbo support
--todo override by slot
--todo override by weapon id
--todo super srs april fool's hitmarkers rain
--todo settings are multipliers/modifiers of crosshair/hitmarker-specific data, when possible

--if you're looking for examples on how to add custom crosshairs, scroll down




--************************************************--
		--init mod data
--************************************************--
_G.AdvancedCrosshair = {}

AdvancedCrosshair._animate_targets = {}
AdvancedCrosshair._hitmarker_panel = nil
AdvancedCrosshair._crosshair_panel = nil --todo both parented to one ach panel

AdvancedCrosshair.valid_weapon_categories = {
	"assault_rifle",
	"pistol",
	"smg",
	"shotgun",
	"lmg",
	"snp",
	"minigun",
	"flamethrower",
	"saw",
	"grenade_launcher",
	"bow",
	"crossbow"
}

AdvancedCrosshair.valid_weapon_firemodes = {
	"single",
	"auto",
	"burst"
}
--revolver and akimbo are subtypes; akimbo is checked but revolver is ignored

--init default settings values
--these are later overwritten by values read from save data, if present
AdvancedCrosshair.settings = {
	crosshair_enabled = true,
	hitmarker_enabled = true,
	use_bloom = true,
	use_shake = true,
	use_color = true,
	use_hitpos = true,
	crosshair_stability = 1,
	default_color = "ffffff",
	enemy_color = "ff0000",
	civ_color = "00ff00",
	teammate_color = "00ffff",
	misc_color = "ff00ff"
	--crosshairs by weapon type are here
}
--init settings for every variation of weapon + firemode (even for combinations that don't exist in-game)
for _,cat in pairs(AdvancedCrosshair.valid_weapon_categories) do 
	for _,firemode in pairs(AdvancedCrosshair.valid_weapon_firemodes) do 
		AdvancedCrosshair.settings["crosshair_type_" .. cat .. "_" .. firemode] = "ma37"
		AdvancedCrosshair.settings["crosshair_type_" .. cat .. "_" .. firemode .. "_akimbo"] = "ma37"
	end
end

	
	

AdvancedCrosshair.path = ModPath
AdvancedCrosshair.save_path = SavePath .. "AdvancedCrosshair.txt"

--holds some instance-specific stuff to save time + cycles
AdvancedCrosshair._cache = {
	underbarrel = {},
	weapon = {},
	bloom = 0,
	hitmarkers = {},
	num_hitmarkers = 0
}

_G.queued_delay_advanced_crosshair_data = {}

--do not change this. refer to the guide if you want to add custom crosshairs to this mod
AdvancedCrosshair._crosshair_data = {
	ma37 = { --halo reach assault rifle; four circle subquadrants + four aiming ticks
		name_id = "menu_crosshair_ma37",
		bloom_func = function(index,bitmap,data)
			local bloom = data.bloom * 1.5
			local crosshair_data = data.crosshair_data and data.crosshair_data.parts[index] or {}
			local distance = (crosshair_data.distance or 10) * (1 + bloom)
			local angle = crosshair_data.rotation or 60
			local c_x = data.panel_w/2
			local c_y = data.panel_h/2
			if index == 1 then 
				--main
			else
				bitmap:set_center(c_x + (math.sin(angle) * distance),c_y - (math.cos(angle) * distance))
			end
		end,
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_1",
				w = 48,
				h = 48
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 0,
				distance = 10,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 90,
				distance = 10,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 180,
				distance = 10,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 270,
				distance = 10,
				w = 2,
				h = 8
			}
		}
	},
	m392 = { --halo reach dmr; circle w/ four circle subquadrants
		name_id = "menu_crosshair_m392",
		bloom_func = function(index,bitmap,data)
			local bloom = data.bloom
			local max_distance = 32
			if index == 1 then 
				bitmap:set_alpha(0.75 - bloom)
			elseif index == 2 then 
				bitmap:set_size(16 + (max_distance * bloom),16 + (max_distance * bloom))
				bitmap:set_rotation(bloom * 90)
			end
			bitmap:set_center(data.panel_w/2,data.panel_h/2)
		end,
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/dmr_crosshair_1",
				w = 32,
				h = 32
			},
			{
				texture = "guis/textures/advanced_crosshairs/dmr_crosshair_2",
				w = 16,
				h = 16
			}
		}
	},
	m6g = { --halo reach pistol; similar to dmr
		name_id = "menu_crosshair_m6g",
		bloom_func = function(index,bitmap,data)
			local bloom = data.bloom * 2
			local crosshair_data = data.crosshair_data and data.crosshair_data.parts[index] or {}
			local distance = (crosshair_data.distance or 10) * (1 + bloom)
			local angle = crosshair_data.rotation or 60
			local c_x = data.panel_w/2
			local c_y = data.panel_h/2
			if index == 1 then 
				--main
			else
				bitmap:set_center(c_x + (math.sin(angle) * distance),c_y - (math.cos(angle) * distance))
			end
		end,
		parts = {
			{
				is_center = true,
				texture = "guis/textures/advanced_crosshairs/pis_crosshair_1",
				w = 28,
				h = 28
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 0,
				distance = 8,
				w = 2,
				h = 6
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 90,
				distance = 8,
				w = 2,
				h = 6
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 180,
				distance = 8,
				w = 2,
				h = 6
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 270,
				distance = 8,
				w = 2,
				h = 6
			}
		}
	},
	m7 = { --halo 2/3 smg
		name_id = "menu_crosshair_m7",
		--[[
		bloom_func = function(index,bitmap,data) 
		--not sure what to do for the bloom, since the SMG was not in reach, 
		--and other games do not feature reticle bloom.
		--this one's a bit of a placeholder.
		--in fact, i don't even like it that much. it's TOO bloom-y. no bloom for you.

			local bloom = data.bloom 
			local crosshair_data = data.crosshair_data and data.crosshair_data.parts[index] or {}
			local distance = (crosshair_data.distance or 16) * (1 + (bloom * 1.5))
			local angle = crosshair_data.rotation or 60
			local c_x = data.panel_w/2
			local c_y = data.panel_h/2
			bitmap:set_size((crosshair_data.w or 1) * (1 + bloom),(crosshair_data.h or 1) * (1 + bloom))
			bitmap:set_center(c_x + (math.sin(angle) * distance),c_y - (math.cos(angle) * distance))
			
		end,
		--]]
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/smg_crosshair",
				w = 24,
				h = 8,
				distance = 16,
				rotation = 0
			},
			{
				texture = "guis/textures/advanced_crosshairs/smg_crosshair",
				w = 24,
				h = 8,
				distance = 16,
				rotation = 90
			},
			{
				texture = "guis/textures/advanced_crosshairs/smg_crosshair",
				w = 24,
				h = 8,
				distance = 16,
				rotation = 180
			},
			{
				texture = "guis/textures/advanced_crosshairs/smg_crosshair",
				w = 24,
				h = 8,
				distance = 16,
				rotation = 270
			}
		}
	},
	m90 = { --halo reach shotgun; big circle
		name_id = "menu_crosshair_m90",
		--no bloom func
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/crosshair_circle_64",
				w = 64,
				h = 64
			}
		}
	},
	srs99 = { --halo reach sniper; small dot
		name_id = "menu_crosshair_srs99",
		bloom_func = function(index,bitmap,data)
			local bloom = data.bloom
			if index == 1 then 
				
			elseif index == 2 then
				bitmap:set_size(16 + (64 * bloom),16 + (64 * bloom))
				bitmap:set_center(data.panel_w/2,data.panel_h/2)
			end
		end,
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/crosshair_circle_64",
				w = 8,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/dmr_crosshair_2",
				w = 16,
				h = 16
			}
		}
	},
	m319 = { --halo reach grenade launcher; circle with distance markers
		name_id = "menu_crosshair_m319",
		special_crosshair = "altimeter", --used for special altitude display for grenade launcher specifically
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/grenadelauncher_crosshair_1"
--				w = 20,
--				h = 40
			},
			{
				texture = "guis/textures/advanced_crosshairs/grenadelauncher_crosshair_2"
--				w = 20,
--				h = 80
			}
		}
	},
	spnkr = { --halo reach m41 rocket launcher; circle with distance markers
		name_id = "menu_crosshair_spnkr",
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/rocket_crosshair",
				w = 48,
				h = 48
			}
		}
	},
	m247h = { --halo reach unsc turret
		name_id = "menu_crosshair_m247h",
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/trt_crosshair",
				w = 48,
				h = 48
			}
		}
	},
	m7057 = { --halo flamethrower; starburst ring of oblongs
		name_id = "menu_crosshair_m7057",
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 0,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 2 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 3 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 4 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 5 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 6 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 7 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 8 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 9 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 10 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 11 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 12 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 13 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 14 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 15 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 16 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 17 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 18 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 19 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 20 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 21 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 22 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 23 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 24 * 360/25,
				distance = 20,
				w = 2,
				h = 8
			}
		}
	},
	h165 = { --halo reach target designator; four chevrons, offset by 45*, with pointy bit pointing outward, forming a diamond
		name_id = "menu_crosshair_h165",
		bloom_func = function(index,bitmap,data)
			local bloom = data.bloom
			local crosshair_data = data.crosshair_data and data.crosshair_data.parts[index] or {}
			local distance = (crosshair_data.distance or 10) * (1 + bloom)
			local angle = crosshair_data.rotation or 60
			local c_x = data.panel_w/2
			local c_y = data.panel_h/2
			bitmap:set_center(c_x + (math.sin(angle) * distance),c_y - (math.cos(angle) * distance))
		end,
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/targeting_crosshair",
				w = 16,
				h = 12,
				distance = 12,
				rotation = 0
			},
			{
				texture = "guis/textures/advanced_crosshairs/targeting_crosshair",
				w = 16,
				h = 12,
				distance = 12,
				rotation = 90
			},
			{
				texture = "guis/textures/advanced_crosshairs/targeting_crosshair",
				w = 16,
				h = 12,
				distance = 12,
				rotation = 180
			},
			{
				texture = "guis/textures/advanced_crosshairs/targeting_crosshair",
				w = 16,
				h = 12,
				distance = 12,
				rotation = 270
			}
		}
	},
	halo_chevron = { --vehicle chevron
		name_id = "menu_crosshair_halo_chevron",
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/car_crosshair",
				w = 24,
				h = 8
			}
		}
	},
	type25_pistol = { --halo plasma pistol; tri arrow
		name_id = "menu_crosshair_type25_pistol",
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 12,
				distance = 16,
				rotation = 0
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 12,
				distance = 16,
				rotation = 125 --120 for perfect third
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 12,
				distance = 16,
				rotation = 235 --240 for perfect third
			}
		}
	},
	type25_rifle = { --halo reach plasma rifle; quad arrow
		name_id = "menu_crosshair_type25_rifle",
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 16,
				distance = 16,
				rotation = 45 + 180 --180 is to offset the angle of the source texture cause i made it upside-down
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 16,
				distance = 16,
				rotation = 135 + 180
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 16,
				distance = 16,
				rotation = 225 + 180
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 16,
				distance = 16,
				rotation = 315 + 180
			}
		}
	},
	type51_rifle = { --halo reach plasma repeater
		name_id = "menu_crosshair_type51_rifle",
		bloom_func = function(index,bitmap,data)
			local bloom = data.bloom
			local crosshair_data = data.crosshair_data and data.crosshair_data.parts[index] or {}
			local distance = (crosshair_data.distance or 10) * (1 + bloom)
			local angle = crosshair_data.rotation or 60
			local c_x = data.panel_w/2
			local c_y = data.panel_h/2
			if index == 1 then 
				--main
			else
				bitmap:set_center(c_x + (math.sin(angle) * distance),c_y - (math.cos(angle) * distance))
			end
		end,
		parts = {
			{
				alpha = 0.6,
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_2",
				w = 36,
				h = 36
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 4,
				h = 12,
				distance = 12,
				rotation = 45
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 4,
				h = 12,
				distance = 12,
				rotation = 135
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 4,
				h = 12,
				distance = 12,
				rotation = 225
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 4,
				h = 12,
				distance = 12,
				rotation = 315
			}
		}
	},
	type33_needler = { --halo needler
		name_id = "menu_crosshair_type33_needler",
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/needler_crosshair_1",
				x = -12,
				rotation = 0,
				w = 8,
				h = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/needler_crosshair_2",
				distance = 8,
				rotation = 90,
				w = 8,
				h = 4
			},
			{
				texture = "guis/textures/advanced_crosshairs/needler_crosshair_1",
				x = 12,
				rotation = 180,
				w = 8,
				h = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/needler_crosshair_2",
				distance = 8,
				rotation = 270,
				w = 8,
				h = 4
			}
		}
	},
	type31 = { --halo reach needle rifle
		name_id = "menu_crosshair_type31",
		bloom_func = function(index,bitmap,data)
			local crosshair_data = data.crosshair_data and data.crosshair_data.parts[index] or {}
			local angle = crosshair_data.rotation or 45
			local c_x = data.panel_w/2
			local c_y = data.panel_h/2
			if index <= 4 then 
				local bloom = data.bloom * 2
				--bitmap:set_center(data.panel_w/2,data.panel_h/2)
				local distance = (crosshair_data.distance or 10) * (1 + bloom)
				bitmap:set_size((crosshair_data.w or 6) * (1 + bloom),(crosshair_data.h or 3) * (1 + bloom))
				bitmap:set_center(c_x + (math.sin(angle) * distance),c_y - (math.cos(angle) * distance))
			else
			end
		end,
		parts = {
			{ --center
				texture = "guis/textures/advanced_crosshairs/nrif_crosshair_2",
				w = 2,
				h = 1,
				distance = 4,
				rotation = 45
			},
			{ --center
				texture = "guis/textures/advanced_crosshairs/nrif_crosshair_2",
				w = 2,
				h = 1,
				distance = 4,
				rotation = 135
			},
			{ --center
				texture = "guis/textures/advanced_crosshairs/nrif_crosshair_2",
				w = 2,
				h = 1,
				distance = 4,
				rotation = 225
			},
			{ --center
				texture = "guis/textures/advanced_crosshairs/nrif_crosshair_2",
				w = 2,
				h = 1,
				distance = 4,
				rotation = 315
			},
			{
				texture = "guis/textures/advanced_crosshairs/nrif_crosshair_2",
				w = 12,
				h = 6,
				distance = 8,
				rotation = 0
			},
			{
				texture = "guis/textures/advanced_crosshairs/nrif_crosshair_2",
				w = 12,
				h = 6,
				distance = 8,
				rotation = 90
			},
			{
				texture = "guis/textures/advanced_crosshairs/nrif_crosshair_2",
				w = 12,
				h = 6,
				distance = 8,
				rotation = 180
			},
			{
				texture = "guis/textures/advanced_crosshairs/nrif_crosshair_2",
				w = 12,
				h = 6,
				distance = 8,
				rotation = 270
			}
		}
	},
	type50 = { --halo reach concussion rifle
		name_id = "menu_crosshair_type50",
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/concussion_crosshair",
				w = 32,
				h = 16,
				x = -18,
				y = -8
			},
			{
				texture = "guis/textures/advanced_crosshairs/concussion_crosshair",
				w = -32,
				h = 16,
				x = 18,
				y = -8
			},
			{
				texture = "guis/textures/advanced_crosshairs/concussion_crosshair",
				w = -32,
				h = -16,
				x = 18,
				y = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/concussion_crosshair",
				w = 32,
				h = -16,
				x = -18,
				y = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				y = 24,
				w = 4,
				h = 16,
				rotation = 90,
				alpha = 0.6
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				y = 32,
				w = 4,
				h = 12,
				rotation = 90,
				alpha = 0.4
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				y = 40,
				w = 4,
				h = 8,
				rotation = 90,
				alpha = 0.2
			}
		}
	},
	type1_sword = { --halo sword; crescent with arrow, used for melee
		name_id = "menu_crosshair_type1_sword",
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/sword_crosshair",
				w = 48,
				h = 48
			}
		}
	},
	type2_hammer = { --halo reach gravity hammer
		name_id = "menu_crosshair_type2_hammer",
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/hammer_crosshair",
				w = 64,
				h = 64
			}
		}
	},
	type52_launcher = { --halo reach plasma launcher; four arrows
		name_id = "menu_crosshair_type52_launcher",
		bloom_func = function(index,bitmap,data)
			local bloom = data.bloom
			local crosshair_data = data.crosshair_data and data.crosshair_data.parts[index] or {}
			local distance = (crosshair_data.distance or 12) * (1 + bloom)
			local angle = crosshair_data.rotation or 0
			local c_x = data.panel_w/2
			local c_y = data.panel_h/2
			if index >= 5 then 
				bitmap:set_center(c_x + (math.sin(angle) * distance),c_y - (math.cos(angle) * distance))
			end
		end,
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 4,
				h = 8,
				distance = 16,
				rotation = 0
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 4,
				h = 8,
				distance = 16,
				rotation = 180
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 4,
				h = 8,
				distance = 16,
				rotation = 270
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 4,
				h = 8,
				distance = 16,
				rotation = 90
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 2,
				h = 4,
				alpha = 0.33,
				distance = 12,
				rotation = 45
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 2,
				h = 4,
				alpha = 0.33,
				distance = 12,
				rotation = 135
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 2,
				h = 4,
				alpha = 0.33,
				distance = 12,
				rotation = 225
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 2,
				h = 4,
				alpha = 0.33,
				distance = 12,
				rotation = 315
			}
		}
	},
	type52_rifle = { --halo reach focus rifle
		name_id = "menu_crosshair_type52_rifle",
		bloom_func = function(index,bitmap,data)
			local bloom = data.bloom * 2
			local crosshair_data = data.crosshair_data and data.crosshair_data.parts[index] or {}
			local distance = (crosshair_data.distance or 8) * (1 + bloom)
			local angle = crosshair_data.rotation or 0
			local c_x = data.panel_w/2
			local c_y = data.panel_h/2
			bitmap:set_center(c_x + (math.sin(angle) * distance),c_y - (math.cos(angle) * distance))
		end,
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/nrif_crosshair_2",
				w = 12,
				h = 6,
				distance = 6,
				rotation = 180
			},
			{
				texture = "guis/textures/advanced_crosshairs/nrif_crosshair_2",
				w = 12,
				h = 6,
				distance = 6,
				rotation = 60
			},
			{
				texture = "guis/textures/advanced_crosshairs/nrif_crosshair_2",
				w = 12,
				h = 6,
				distance = 6,
				rotation = 300
			}
		}
	},
	type25_carbine = { --halo spiker
		name_id = "menu_crosshair_type25_carbine",
		bloom_func = function(index,bitmap,data)
			local bloom = data.bloom
			local crosshair_data = data.crosshair_data and data.crosshair_data.parts[index] or {}
			local distance = (crosshair_data.distance or 12) * (1 + bloom)
			local angle = crosshair_data.rotation or 0
			local c_x = data.panel_w/2
			local c_y = data.panel_h/2
			if index >= 5 then 
				bitmap:set_center(c_x + (math.sin(angle) * distance),c_y - (math.cos(angle) * distance))
			end
		end,
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/spiker_crosshair_1",
				x = -14,
				y = -14,
				rotation = 0,
				w = 16,
				h = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/spiker_crosshair_2",
				x = 14,
				y = -14,
				rotation = 0,
				w = 16,
				h = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/spiker_crosshair_1",
				x = 14,
				y = 14,
				rotation = 180,
				w = 16,
				h = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/spiker_crosshair_2",
				x = -14,
				y = 14,
				rotation = 180,
				w = 16,
				h = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2", --top 
				distance = 20,
				rotation = 0,
				h = 10,
				w = 2
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2", --right
				distance = 22,
				rotation = 90,
				h = 14,
				w = 2
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2", --bottom
				distance = 20,
				rotation = 180,
				h = 10,
				w = 2
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2", --left
				distance = 22,
				rotation = 270,
				h = 14,
				w = 2
			}
		}
	},
	type33_aa = { --halo fuel rod
		name_id = "menu_crosshair_type33_aa",
		parts = {
			{ -- 1 big, bottom
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 16,
				distance = 20,
				rotation = 180
			},
			{ -- 2
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 170
			},
			{ -- 3
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 160
			},
			{ -- 4
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 150
			},
			{ -- 5
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 140
			},
			{ -- 6
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 130
			},
			{ -- 7
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 120
			},
			{ -- 8
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 110
			},
			{ -- 9
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 100
			},
			{ -- 10 big
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 16,
				distance = 20,
				rotation = 90
			},
			{ -- 11 big; left
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 16,
				distance = 20,
				rotation = 270
			},
			{ -- 12
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 280
			},
			{ -- 13
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 290
			},
			{ -- 14
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 300
			},
			{ -- 15
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 310
			},
			{ -- 16
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 320
			},
			{ -- 17
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 330
			},
			{ -- 18
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 340
			},
			{ -- 19
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 24,
				rotation = 350
			},
			{ -- 20 big
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 16,
				distance = 20,
				rotation = 0
			}
		}
	},
	type52_turret = { --halo covenant turret
		name_id = "menu_crosshair_type52_turret",
		parts = {
			{ -- 1 top
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 16,
				rotation = 90,
				alpha = 0.5
			},
			{ -- 2
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 16,
				rotation = 22.5,
				alpha = 0.5
			},
			{ -- 3 big
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 12,
				distance = 20,
				rotation = 45
			},
			{ -- 4
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 16,
				rotation = 67.5,
				alpha = 0.5
			},
			{ -- 5 right
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 16,
				rotation = 90,
				alpha = 0.5
			},
			{ -- 6
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 16,
				rotation = 112.5,
				alpha = 0.5
			},
			{ -- 7 big
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 12,
				distance = 20,
				rotation = 135
			},
			{ -- 8
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 16,
				rotation = 157.5,
				alpha = 0.5
			},
			{ -- 9 bottom
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 16,
				rotation = 180,
				alpha = 0.5
			},
			{ -- 10
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 16,
				rotation = 202.5,
				alpha = 0.5
			},
			{ -- 11 big
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 12,
				distance = 20,
				rotation = 225
			},
			{ -- 12
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 16,
				rotation = 247.5,
				alpha = 0.5
			},
			{ -- 13 left
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 16,
				rotation = 270,
				alpha = 0.5
			},
			{ -- 14
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 16,
				rotation = 292.5,
				alpha = 0.5
			},
			{ -- 15 big
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 6,
				h = 12,
				distance = 20,
				rotation = 315
			},
			{ -- 16
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 3,
				h = 6,
				distance = 16,
				rotation = 337.5,
				alpha = 0.5
			}
		}
	}
}

AdvancedCrosshair._hitmarker_data = {
	destiny = {
		name_id = "menu_hitmarker_destiny",
		hit_func = function(index,bitmap,data,t,dt,start_t,duration)
			if data.result_type == "death" then 
				--kill
				local part_data = data.hitmarker_data and data.hitmarker_data.parts[index] or {}
				
				local ratio = math.min(1,(t - start_t) / duration)
				
				if ratio < 0.5 then 
					local r_ratio = ratio * 2
					local distance = (part_data.distance or 0) + (data.hitmarker_data.hit_anim_distance * r_ratio)
					local angle = part_data.angle
					local c_x = data.panel:w() / 2 --should these just get + use bitmap parent's panel size?
					local c_y = data.panel:h() / 2
					bitmap:set_center(c_x + math.sin(angle) * distance,c_y - (math.cos(angle) * distance))
				else
					local r_ratio = 2 - (ratio * 2)
					bitmap:set_alpha(r_ratio * part_data.alpha)
				end
			else
				--hit
				local ratio = math.min(1,(t - start_t) / duration)
				local part_data = data.hitmarker_data and data.hitmarker_data.parts[index] or {}
				bitmap:set_alpha((1 - ratio) * part_data.alpha)
			end
		end,
		hit_anim_distance = 12,
	--for those of you looking to make your own hitmarkers- beware, these options generally override user settings,
	--so don't set color in the part table, or alpha in your main hitmarker table, unless you want it to be unaffected by settings
		parts = {
			{ --reused from plasma rifle crosshairs
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 4,
				h = 12,
				angle = -45,
				rotation = 180,
				distance = 12,
				alpha = 0.75
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 4,
				h = 12,
				angle = 45,
				rotation = 180,
				distance = 12,
				alpha = 0.75
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 4,
				h = 12,
				angle = 135,
				rotation = 180,
				distance = 12,
				alpha = 0.75
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 4,
				h = 12,
				angle = -135,
				rotation = 180,
				distance = 12,
				alpha = 0.75
			}
		}
	}
}


--************************************************--
		--utils
--************************************************--
function AdvancedCrosshair:log(a,...)
	if Console then 
		return Console:log(a,...)
	else
		return log("[AdvancedCrosshair] " .. tostring(a))
	end
end

function AdvancedCrosshair.logtbl(tbl)
	if _G.logall then 
		return logall(tbl)
	else 
		return PrintTable(tbl)
	end
end

function AdvancedCrosshair.concat_tbl_with_keys(a,pairsep,setsep,...)
	local s = ""
	if type(a) == "table" then 
		pairsep = pairsep or " = "
		setsetp = setsetp or ", "
		for k,v in pairs(a) do 
			if s ~= "" then 
				s = s .. setsetp
			end
			s = s .. tostring(k) .. pairsep .. tostring(v)
		end
	else
		return AdvancedCrosshair.concat_tbl(a,sep,sep2,...)
	end
	return s
end

function AdvancedCrosshair.getst()
	return string.format("%0.2f",Application:time())
end
--simple concat (just input, no options)
function AdvancedCrosshair.concat_tbl(a)
	local s = ""
	for _,v in ipairs(a) do 
		if s ~= "" then 
			s = s .. ","
		end
		s = s .. tostring(v)
	end
	return s
end

function AdvancedCrosshair.concat(...)
	return AdvancedCrosshair.concat_tbl({...})
end

function AdvancedCrosshair.GetWeaponCategory(weaponbase)
	local category
	for _,cat in pairs(weaponbase:categories()) do 
		if cat == "revolver" then 
			is_revolver = true
		elseif cat == "akimbo" then 
			is_akimbo = true
		elseif table.contains(AdvancedCrosshair.valid_weapon_categories,cat) then
			category = cat
		else
			self:log("ERROR: GetWeaponCategory(" .. tostring(cat) .."): Invalid category!",{color=Color.red})
		end
	end
	return category,is_revolver,is_akimbo
end

--for ColorPicker mod support
function AdvancedCrosshair:set_colorpicker_menu(colorpicker)
	self._colorpicker = colorpicker
end

--************************************************--
	--custom crosshair support
Hooks:Register("AdvancedCrosshair_RegisterCustomCrosshair") --this is intended as safe way to add custom crosshairs since it's safe to call hooks that aren't defined
--this way, it won't crash if you use this method and uninstall advanced crosshairs but forget to uninstall the custom crosshair add-on (even though uninstalling this mod would make me sad :'( )
Hooks:Add("AdvancedCrosshair_RegisterCustomCrosshair","advc_onregistercustomcrosshair",function(id,data)
	AdvancedCrosshair._crosshair_data[id] = data
end)

--[[
--Example of custom crosshair implementation
Hooks:Call("AdvancedCrosshair_RegisterCustomCrosshair","advc_register_default_crosshair","reach_assault_rifle",
	{ --this is your crosshair_data table
		name_id = "menu_crosshair_ma37", --(optional) this is the localized name to show when selecting the crosshair in the menu
		bloom_func = function(index,bitmap,data) --(optional) this is the bloom function. if you don't want your crosshair to have bloom, you can ignore this
			local bloom = data.bloom * 1.5
			local crosshair_data = data.crosshair_data and data.crosshair_data.parts[index] or {}
			local distance = (crosshair_data.distance or 10) * (1 + bloom)
			local angle = crosshair_data.angle or 60
			local c_x = data.panel_w/2
			local c_y = data.panel_h/2
			if index == 1 then 
				--this is the outer circle section that doesn't move when firing
			else
				--these are the small lines that make up the cross, which does move when firing
				bitmap:set_center(c_x + (math.sin(angle) * distance),c_y - (math.cos(angle) * distance))
			end
		end,
		parts = { --this tells the mod where your crosshair texture file is and how to position it on the screen
--ma37 is four circle subquadrants + four aiming tick lines
			{
				texture = "guis/textures/advanced_crosshairs/ma37_crosshair_1", --this is the asset path to your crosshair texture file. make sure it matches the path in your xml file or wherever you loaded the textures from. THIS SHOULD NOT INCLUDE THE MOD PATH!
				w = 48, --w and h stand for width and height, respectively, and represent how big the crosshair will be on your screen.
				h = 48 --this is separate from your file's dimensions! the image will be scaled to fit these width/height values, so make sure that the aspect ratio is the same between these values and your file dimensions.
			},
			{
				texture = "guis/textures/advanced_crosshairs/ma37_crosshair_2",
				angle = 0, --(optional) if you want your crosshair to be rotated, you should include a 
				distance = 10, --(optional) all crosshairs are automatically centered, so if you want to offset any part of your crosshair, you can use distance and angle. x and y can also be used as offsets from the center of the screen, but this is not shown here.
				w = 2, --you can also add most other common parameters you might use in bitmap object creation, such as render_template, blend_mode, alpha, or color
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ma37_crosshair_2",
				angle = 90,
				distance = 10,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ma37_crosshair_2",
				angle = 180,
				distance = 10,
				w = 2,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ma37_crosshair_2",
				angle = 270,
				distance = 10,
				w = 2,
				h = 8
			}
		}
	}
)
--]]

--************************************************--


--************************************************--
		--settings getters
--************************************************--
function AdvancedCrosshair:GetCrosshairStability()
	return self.settings.crosshair_stability
end
function AdvancedCrosshair:UseBloom()
	return self.settings.use_bloom
end
function AdvancedCrosshair:UseCrosshairShake()
	return self.settings.use_shake
end
function AdvancedCrosshair:UseDynamicColor()
	return self.settings.use_color
end
function AdvancedCrosshair:IsCrosshairEnabled()
	return self.settings.crosshair_enabled
end
function AdvancedCrosshair:IsHitmarkerEnabled()
	return self.settings.hitmarker_enabled
end
function AdvancedCrosshair:UseHitmarkerWorldPosition()
	return true
end
function AdvancedCrosshair:UseHitmarkerHitPosition()
	return self.settings.use_hitpos
end
function AdvancedCrosshair:GetColorByTeam(team)
	local result = self.settings.misc_color
	
	if team == "law1" then 
		result = self.settings.enemy_color
	elseif team == "neutral1" then 
		result = self.settings.civ_color
	elseif team == "mobster1" then 
		result = self.settings.misc_color
	elseif team == "criminal1" then 
		result = self.settings.teammate_color
	elseif team == "converted_enemy" then
		result = self.settings.teammate_color
	elseif team == "hacked_turret" then 
		result = self.settings.teammate_color
	end
	
	return result and Color(result) or Color.white
end
function AdvancedCrosshair:GetHitmarkerDuration()
	return 1
end
function AdvancedCrosshair:GetHitmarkerType()
	return "destiny"
end
function AdvancedCrosshair:GetHitmarkerBlendMode()
	return "normal" --"add"
end
function AdvancedCrosshair:GetHitmarkerAlpha()
	return 1
end

--************************************************--
		--hud animate functions
--************************************************--

	-- hud animation manager --
	
function AdvancedCrosshair:animate(object,func,done_cb,...)
	AdvancedCrosshair._animate_targets[tostring(object)] = {
		object = object,
		start_t = Application:time(),
		func = func,
		done_cb = done_cb,
		args = {...}
	}
end

function AdvancedCrosshair:animate_remove_done_cb(object,new)
	local o = AdvancedCrosshair._animate_targets[tostring(object)]
	if o then 
		o.done_cb = new
		return true
	end
	return false
end

function AdvancedCrosshair:animate_stop(object)
	AdvancedCrosshair._animate_targets[tostring(object)] = nil
end

	--hud animations
function AdvancedCrosshair:animate_fadeout(o,t,dt,start_t,duration,from_alpha,exit_x,exit_y)
	duration = duration or 1
	from_alpha = from_alpha or 1
	local ratio = math.pow((t - start_t) / duration,2)
	
	if ratio >= 1 then 
		o:set_alpha(0)
		return true
	end
	o:set_alpha(from_alpha * (1 - ratio))
	if exit_y then 
		o:set_y(o:y() + (exit_y * dt / duration))
	end
	if exit_x then 
		o:set_x(o:x() + (exit_x * dt / duration))
	end
end




--************************************************--
		--stuff that happens during gameplay
--************************************************--

	--**********************--
		--init hud items
	--**********************--
--these should only run once, when the player spawns
function AdvancedCrosshair:Init()
	managers.hud:remove_updator("advancedcrosshairs_update")
	managers.hud:add_updator("advc_create_hud_delayed",callback(AdvancedCrosshair,AdvancedCrosshair,"CreateHUD"))
end

function AdvancedCrosshair:CreateHUD(t,dt) --try to create hud each run until both required elements are initiated.
--...it's not ideal.
	local hud = managers.hud and managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)--managers.hud._hud_hit_confirm and managers.hud._hud_hit_confirm._hud_panel
	if alive(managers.player:local_player()) and hud and hud.panel then 
		managers.hud:remove_updator("advc_create_hud_delayed")
		managers.hud:add_updator("advancedcrosshairs_update",callback(AdvancedCrosshair,AdvancedCrosshair,"Update"))
		self:CheckWeapon(1)
		self:CheckWeapon(2)
		self:CheckUnderbarrel(1)
		self:CheckUnderbarrel(2)
		self:CreateCrosshairPanel(hud.panel) -- or managers.hud._hud_temp._hud_panel)
		self:CreateCrosshairs()
	end
end

function AdvancedCrosshair:CheckWeapon(slot,underbarrel_slot)
	slot = tonumber(slot)
	local player = managers.player:local_player()
	if not slot then 
		self:log("ERROR: CheckWeapon(" .. self.concat_tbl({slot,underbarrel_slot}) .. "): Slot invalid",{color=Color.red})
		return
	elseif not alive(player) then 
		self:log("ERROR: CheckWeapon(" .. self.concat_tbl({slot,underbarrel_slot}) .. "): Player invalid",{color=Color.red})
		return
	end
	local equipped_in_slot = player:inventory():unit_by_selection(slot)
	local weaponbase = equipped_in_slot:base()

	local crosshair_single = self:GetCrosshairType(slot,weaponbase,"single")
	local crosshair_auto = self:GetCrosshairType(slot,weaponbase,"auto")
	local crosshair_burst = self:GetCrosshairType(slot,weaponbase,"burst") --todo burstfire support
	
	self._cache.weapon[slot] = self._cache.weapon[slot] or {}
	
	self._cache.weapon[slot].single = crosshair_single
	self._cache.weapon[slot].auto = crosshair_auto
	self._cache.weapon[slot].burst = crosshair_burst
end

function AdvancedCrosshair:CheckUnderbarrel(slot,underbarrel_slot)
	--there is currently no precedent for multiple underbarrel gadgets on a single weapon... yet
	underbarrel_slot = tonumber(underbarrel_slot) or 1
	slot = tonumber(slot)
	--remember, secondary is 1, primary is 2, because pdth
	local player = managers.player:local_player()
	if not (slot and player) then return end
	local equipped_in_slot = player:inventory():unit_by_selection(slot)
	if not equipped_in_slot then return end	
	local weapon_id = equipped_in_slot:get_name_id()
	if self._cache.underbarrel[slot] == nil then 
		local underbarrel_weapons = equipped_in_slot:base():get_all_override_weapon_gadgets()
		if #underbarrel_weapons > 0 then 
			self._cache.underbarrel[slot] = underbarrel_weapons
			local categories = underbarrel_weapons[underbarrel_slot]._tweak_data.categories
			--get underbarrel tweakdata categories and set underbarrel icon
		else
			--set flag not to check for underbarrels anymore
			self._cache.underbarrel[slot] = false
		end
	end
	if type(self._cache.underbarrel[slot]) == "table" then 
		return self._cache.underbarrel[slot][underbarrel_slot]
	end
end

function AdvancedCrosshair:CreateCrosshairPanel(hud)
	if not alive(hud) then 
		self:log("ERROR: CreateCrosshairPanel() No parent HUD found!",{color=Color.red})
		return
	end
	
	if alive(hud:child("ach_crosshair_panel")) then 
		hud:remove(hud:child("ach_crosshair_panel"))
	end
	local crosshair_panel = hud:panel({
		name = "ach_crosshair_panel"
	})
	self._crosshair_panel = crosshair_panel
	self._hitmarker_panel = crosshair_panel:panel({
		name = "ach_hitmarker_panel"
	})
	crosshair_panel:set_center(hud:w()/2,hud:h()/2)

	local debug_crosshair = crosshair_panel:rect({
		color = Color.yellow,
		visible = false,
		alpha = 0.1
	})
	local NUM_WEAPONS = 3
	for slot=1,NUM_WEAPONS,1 do 
		local slotpanel = crosshair_panel:panel({
			name = "slot_" .. tostring(slot),
			visible = false
		})
		for _,firemode in pairs(self.valid_weapon_firemodes) do 
			local firemode_panel = slotpanel:panel({
				name = "firemode_" .. tostring(firemode),
				visible = false
			})
		end
		local underbarrel_panel = slotpanel:panel({
			name = "underbarrel_" .. tostring(slot),
			visible = false
		})
	end
end

function AdvancedCrosshair:CreateCrosshairs()
--	for _,child in pairs(self._crosshair_panel) do
--		self._crosshair_panel:remove(child)
--	end
	for slot,data in pairs(self._cache.underbarrel) do 
		--todo
	end
	
	for slot,firemodes_data in pairs(self._cache.weapon) do 
		for firemode,crosshair_type in pairs(firemodes_data) do 
			local crosshair_data = self._crosshair_data[crosshair_type]
			if crosshair_data then 
				local slotpanel = self._crosshair_panel:child("slot_" .. tostring(slot))
				local firemode_panel = slotpanel:child("firemode_" .. tostring(firemode))
				self:CreateCrosshair(firemode_panel,crosshair_data)
				--if crosshair_data.special_crosshair then
			else
				self:log("ERROR: CreateCrosshairs() Bad crosshair data for weapon " .. self.concat_tbl(slot,firemode),{color=Color.red})
			end
		end
	end
end

function AdvancedCrosshair:CreateCrosshair(panel,data)
	--if data.special_crosshair then 
	--	do stuff here
	--end
	local results = {}
	for i,part_data in pairs(data.parts) do 
		local x = (part_data.x or 0)
		local y = (part_data.y or 0)
		local angle = part_data.angle or part_data.rotation
		if part_data.distance and angle then 
			x = x + (math.sin(angle) * part_data.distance)
			y = y + (-math.cos(angle) * part_data.distance)
		end
		local bitmap = panel:bitmap({
			name = tostring(i),
			texture = part_data.texture,
			texture_rect = part_data.texture_rect,
			x = x,
			y = y,
			rotation = part_data.rotation,
			w = part_data.w,
			h = part_data.h,
			alpha = part_data.alpha or data.alpha,
			blend_mode = part_data.blend_mode or data.blend_mode,
			color = part_data.color or data.alpha,
			render_template = part_data.render_template or data.render_template,
			layer = (part_data.layer or data.layer or 0)
		})
		table.insert(results,i,bitmap)
		bitmap:set_center(x + (panel:w()/2),y + (panel:h()/2))
	end
	return results
end

function AdvancedCrosshair:SetCrosshairCenter(x,y)
	self._crosshair_panel:set_center(x,y)
end


function AdvancedCrosshair:SetCrosshairColor(primary_color) --todo secondary color?
	local current_crosshair,crosshair_type = self:GetCurrentCrosshair()
	local crosshair_data = self._crosshair_data[tostring(crosshair_type)]
	if crosshair_data then 
		if not crosshair_data.special_crosshair then 
			for i=1,#crosshair_data.parts,1 do 
				if not crosshair_data.parts[i].UNRECOLORABLE then 
					local part = current_crosshair:child(tostring(i))
					if part then 
						part:set_color(primary_color)
					end
				end
			end
		else
			--todo
		end
	end
end

function AdvancedCrosshair:SetCrosshairBloom(bloom)
	local player = managers.player:local_player()

	if player then 
		local firemode_panel,crosshair_type = self:GetCurrentCrosshair()
		local crosshair_data = self._crosshair_data[crosshair_type] or {}
		local data = {bloom = bloom,crosshair_data = crosshair_data,panel_w = self._crosshair_panel:w(),panel_h = self._crosshair_panel:h()}
		local a = crosshair_data.bloom_func
		
	--	for i = 1,
		
		self:GetCurrentCrosshairParts(a,data)
	end
end


function AdvancedCrosshair:GetCurrentCrosshairParts(func,...)
	local result = {}
	local current_crosshair,crosshair_type = self:GetCurrentCrosshair()
	local crosshair_data = self._crosshair_data[tostring(crosshair_type)]
	if current_crosshair and crosshair_data then 
		if not crosshair_data.special_crosshair then 
			for i=1,#crosshair_data.parts,1 do 
				local bitmap = current_crosshair:child(tostring(i))
				if bitmap and type(func) == "function" then 
					func(i,bitmap,...)
				end
			end
		else
			--todo
		end
		return current_crosshair:children()
	end
	
	--[[
	local slot,mode_name = self:get_slot_and_firemode()
	local modepanel = self._crosshair_by_info(slot,mode_name)
	--	self:get_current_crosshair()

	if alive(modepanel) then 
		for i=1,(self.weapon_data[slot][mode_name].num_parts or 1) do 
			local bitmap = modepanel:child(tostring(i))
			if func and alive(bitmap) then 
				func(i,bitmap,...)
			end
			result[i] = bitmap
		end
		return result
	end
	--]]
end

function AdvancedCrosshair:GetCurrentCrosshair()
	local player = managers.player:local_player()
	if player and self._crosshair_panel then 
		local inventory = player:inventory()
		local slot = inventory:equipped_selection()
		local equipped_unit = inventory:equipped_unit()
		local firemode = equipped_unit:base():fire_mode()
		local slot_panel = self._crosshair_panel:child("slot_" .. tostring(slot))
		local firemode_panel = slot_panel and slot_panel:child("firemode_" .. tostring(firemode))
		
		return firemode_panel,self._cache.weapon[slot] and self._cache.weapon[slot][firemode]
	end
end

function AdvancedCrosshair:CreateHitmarker(attack_data)
	if not (attack_data and type(attack_data) == "table") then 
		self:log("ERROR: CreateHitmarker(" .. tostring(attack_data) .. "): Invalid data provided!",{color=Color.red})
		return 
	end
	
	local result = attack_data.result
	local result_type = result and result.type
	local pos = attack_data.pos
	local headshot = attack_data.headshot
	local crit = attack_data.crit --flag indicating crit is added from the mod, not here in vanilla

	local weapon_unit = attack_data.weapon_unit
	local base = weapon_unit and weapon_unit:base()
	
	local color = Color.white
	local headshot_color = Color.red
	local headcrit_color = Color(0.5,0,1)
	local crit_color = Color(0,0,1)
	if headshot and crit then 
		color = headcrit_color
	elseif headshot then 
		color = headshot_color
	elseif crit then 
		color = crit_color
	end
	
	local hitmarker_type = self:GetHitmarkerType()
	local hitmarker_data = hitmarker_type and self._hitmarker_data[hitmarker_type]
	if not hitmarker_data then 
		--todo reset if bad hitmarker? or check elsewhere/on startup for validity?
		self:log("ERROR: CreateHitmarker(): Bad Hitmarker type (" .. tostring(hitmarker_type) .. ")")
	end
	
	self._cache.num_hitmarkers = self._cache.num_hitmarkers + 1 --presume that creation was successful when incrementing; todo fix this
	
	local panel = self._hitmarker_panel:panel({
		alpha = hitmarker_data.alpha,
		name = "hitmarker_" .. tostring(self._cache.num_hitmarkers)
	})
	
--	local panel_debug = panel:rect({
--		name = "debug",
--		color = Color.blue,
--		alpha = 0.25,
--		visible = false
--	})
	
	local result = {}
	for i,part_data in pairs(hitmarker_data.parts) do 
		local x = (part_data.x or 0)
		local y = (part_data.y or 0)
		local angle = part_data.angle
		local rotation = (part_data.rotation or 0) + (angle or 0)
		if part_data.distance and angle then 
			x = x + math.sin(angle) * part_data.distance
			y = y + -math.cos(angle) * part_data.distance
		end
		local bitmap = panel:bitmap({
			name = tostring(i),
			texture = part_data.texture,
			texture_rect = part_data.texture_rect,
			x = x,
			y = y,
			rotation = rotation,
			w = part_data.w,
			h = part_data.h,
--			alpha = part_data.alpha or hitmarker_data.alpha,
			blend_mode = part_data.blend_mode or hitmarker_data.blend_mode or self:GetHitmarkerBlendMode(),
			color = part_data.color or hitmarker_data.alpha or color,
			render_template = part_data.render_template or hitmarker_data.render_template,
			layer = 5 + (part_data.layer or hitmarker_data.layer or 0)
		})
		bitmap:set_center(x + (panel:w()/2),y + (panel:h()/2))
		table.insert(result,i,bitmap)
	end
	return panel,result
end

function AdvancedCrosshair:RemoveHitmarker(id)
	if not id then return end
	
	for index,hitmarkers_data in pairs(self._cache.hitmarkers) do 
		if hitmarkers_data.id == id then 
			table.remove(self._cache.hitmarkers,index)
			return true
		end
	end
end

function AdvancedCrosshair:ActivateHitmarker(unit,attack_data)
	local attacker_unit = attack_data and attack_data.attacker_unit
	if attacker_unit == managers.player:local_player() then 
		local result = attack_data.result
		butt = attack_data
		local result_type = result and result.type
		local pos = attack_data.pos
--		if pos then 
--			Draw:brush(Color.red:with_alpha(0.1),60):sphere(pos,50)
--		end
		
		local headshot = attack_data.headshot
		local crit = attack_data.crit --flag indicating crit is added from the mod, not here in vanilla	
	
		local hitmarker_type = self:GetHitmarkerType()
		local hitmarker_data = hitmarker_type and self._hitmarker_data[hitmarker_type]
		local hitmarker_duration = self:GetHitmarkerDuration()
		local hitmarker_alpha = self:GetHitmarkerAlpha()
		
		local hitmarker_id = self._cache.num_hitmarkers
		
		local panel,parts = self:CreateHitmarker(attack_data)
		if alive(panel) then 
			table.insert(self._cache.hitmarkers,#self._cache.hitmarkers + 1,
				{ --this is only used for the "3D hitmarkers" feature
					id = hitmarker_id,
					panel = panel,
					parts = parts,
					position = attack_data.pos
				}
			)
			local function remove_panel(o)
				o:parent():remove(o)
				self:RemoveHitmarker(hitmarker_id)
			end
			
			if hitmarker_data and type(hitmarker_data.hit_func) == "function" then 
				self:animate(panel,"animate_hitmarker_parts",remove_panel,hitmarker_duration,parts,hitmarker_data.hit_func,
					{
						panel = panel,
						result_type = result_type,
						position = pos,
						headshot = headshot,
						crit = attack_data.crit,
						attack_data = attack_data,
						hitmarker_data = hitmarker_data
					}
				)
			else
				self:animate(panel,"animate_fadeout",remove_panel,hitmarker_duration,hitmarker_alpha,nil,nil)
			end
		end
		
	end
end

function AdvancedCrosshair:animate_hitmarker_parts(o,t,dt,start_t,duration,parts,hit_func,data)
	for index,bitmap in ipairs(parts) do 
		hit_func(index,bitmap,data,t,dt,start_t,duration)
	end
	
	if t - start_t >= duration then 
		return true
	end
end

function AdvancedCrosshair:ClearCache(skip_destroy)
	local cache = self._cache
	local num_active_hitmarkers = #cache.hitmarkers
	if not skip_destroy then 
		if num_active_hitmarkers > 0 then 
			for i=1,num_active_hitmarkers,1 do 
				table.remove(cache.hitmarkers,i)
			end
		else
			for i=1,num_active_hitmarkers,1 do 
				local panel = cache.hitmarkers[i].panel
				if alive(panel) then 
					panel:parent():remove(panel)
				end
				table.remove(cache.hitmarkers,i)
			end
		end
	end
	cache.underbarrel = {}
	cache.weapon = {}
	cache.bloom = 0
	cache.num_hitmarkers = 0
end

--sets the correct crosshair visible according to current weapon data 
function AdvancedCrosshair:CheckCrosshair()
	local player = managers.player:local_player()
	if player then 
		local inventory = player:inventory()
		local equipped_index = inventory:equipped_selection()
		local equipped_unit = inventory:equipped_unit()
		local current_firemode = equipped_unit:base():fire_mode()
		for slot,firemodes_data in pairs(self._cache.weapon) do 
			local slot_panel = self._crosshair_panel:child("slot_" .. tostring(slot))
			if slot == equipped_index then 
				slot_panel:show()
				for _,firemode in pairs(self.valid_weapon_firemodes) do 
					local firemode_panel = slot_panel:child("firemode_" .. tostring(firemode))
					if firemode == current_firemode then 
						firemode_panel:show()
					else
						firemode_panel:hide()
					end
				end
			else
				slot_panel:hide()
			end
		end
	else
		--hide all 
	end
end

function AdvancedCrosshair:AddBloom(amt)
	amt = amt or 0.3
	self._cache.bloom = self._cache.bloom + amt
end

function AdvancedCrosshair:Update(t,dt)
	local player = managers.player:local_player()
	
	--do crosshair
		--if crosshair enabled then 
	if alive(player) and alive(self._crosshair_panel) then 
	
		local viewport_cam = managers.viewport:get_current_camera()
		if not viewport_cam then 
			return 
		end
		local ws = managers.hud._workspace
		
		if not player:inventory():equipped_unit() then 
			--this can happen when restarting the level
			return
		end
		
		
		if self:IsHitmarkerEnabled() then
			if self:UseHitmarkerWorldPosition() then 
				for hitmarker_index,hitmarker in pairs(self._cache.hitmarkers) do 
					local h_p = ws:world_to_screen(viewport_cam,hitmarker.position)
					if h_p then 
						if alive(hitmarker.panel) then 
							hitmarker.panel:set_center(h_p.x,h_p.y)
						end
					end
				end
			end

				--[[
			for i = #self._cache.hitmarkers,1,-1 do 
				local hitmarker_data = self._cache.hitmarkers[i]
				local bitmap = hitmarker_data.bitmap
				hitmarker_data.duration = hitmarker_data.duration - dt
				if hitmarker_data.duration <= 0 then 
					bitmap:parent():remove(bitmap)
					table.remove(self._cache.hitmarkers,i)
				else
					if hitmarker_data.duration <= 1 then 
						bitmap:set_alpha(1-math.pow(hitmarker_data.duration,2))
					end
					
					--todo angle check
					local h_p = ws:world_to_screen(viewport_cam,hitmarker_data.position)
					if h_p then 
						hitmarker_data.panel:set_position(h_p.x,h_p.y)
					end
--				end
			end
				--]]
		end
		
		--animate update
		for object_id,data in pairs(self._animate_targets) do 
			local result
			if type(data and data.func) == "string" then 
				if self[data.func] then 					
					result = self[data.func](self,data.object,t,dt,data.start_t,unpack(data.args))
				else
					self:log("ERROR: Unknown animate function:" .. tostring(data.func) .. "()")
					self._animate_targets[object_id] = nil
				end
			elseif type(data.func) == "function" then
				result = data.func(data.object,t,dt,data.start_t,unpack(data.args))
			else
				self._animate_targets[object_id] = nil --remove from animate targets table
				result = nil --don't do done_cb, that's illegal
			end
			if result then
				self._animate_targets[object_id] = nil
				if data.done_cb and type(data.done_cb) == "function" then 
					data.done_cb(data.object,result,unpack(data.args))
				end
			end
		end				
		
		--set visible by firemode and unit
		--on firemode switch or weapon switch, 
			--change visible crosshair
		
		--on weapon fired,
			--increase bloom
		
		
		--in update:
			--decay bloom
		local state = player:movement():current_state()
		local is_reloading = state:_is_reloading() 
		local fire_forbidden = state:_changing_weapon() or state:_is_meleeing() or state._use_item_expire_t or state:_interacting() or state:_is_throwing_projectile() or state:_is_deploying_bipod() or state._menu_closed_fire_cooldown > 0 or state:is_switching_stances()



		
		--[[
		local player_pos = player:position()
			local cam_aim = viewport_cam:rotation():yaw()
			local cam_rot_a = viewport_cam:rotation():y()

			local compass_yaw = ((cam_aim + 90) / 180) - 1
	--]]

			
			
			
		local fwd_ray = state._fwd_ray	
		local focused_person = fwd_ray and fwd_ray.unit
		--			local crosshair = self._crosshair_panel:child("crosshair_subparts"):child("crosshair_1") --todo function to handle crosshair modifications
		local crosshair_color = Color.white
		if alive(focused_person) then
			
--			Console:SetTrackerValue("trackere",tostring(focused_person))
			if focused_person:character_damage() then 
				if not focused_person:character_damage():dead() then 
					local f_m = focused_person:movement()
					local f_t = f_m and f_m:team() and f_m:team().id
					if f_t then 
						if focused_person.brain and focused_person:brain() and focused_person:brain().is_current_logic and focused_person:brain():is_current_logic("intimidated") then 
							f_t = "converted_enemy"
						end
						crosshair_color = self:GetColorByTeam(f_t)
					elseif not f_m then --old color determination method
		--							self:log("NO CROSSHAIR UNIT TEAM")
		--							if managers.enemy:is_enemy(focused_person) then 
		--							elseif managers.enemy:is_civilian(focused_person) then
		--							elseif managers.criminals:character_name_by_unit(focused_person) then
						--else, is probably a car.
					end
				end
			elseif focused_person:base() and focused_person:base().can_apply_tape_loop and focused_person:base():can_apply_tape_loop() then 	
				crosshair_color = self:GetColorByTeam("law1")
			end
			self:SetCrosshairColor(crosshair_color)
		end


		if self:UseCrosshairShake() then 
			--if settings.allow_crosshair_shake then 
			local crosshair_stability = (fwd_ray and fwd_ray.distance or 1000) * self:GetCrosshairStability() --fwd_ray.length
			--theoretically, the raycast position (assuming perfect accuracy) at [crosshair_stability] meters;
			--practically, the higher the number, the less sway shake
			local c_p = ws:world_to_screen(viewport_cam,state:get_fire_weapon_position() + (state:get_fire_weapon_direction() * crosshair_stability))
			local c_w = (c_p.x or 0)
			local c_h = (c_p.y or 0)
			self:SetCrosshairCenter(c_w,c_h)	
		end

		--bloom
		if true then 
			local bloom_decay_mul = 3 -- 1.5
			if self._cache.bloom > 0 then 
				self._cache.bloom = math.max(self._cache.bloom - (bloom_decay_mul * dt),0)
				self:SetCrosshairBloom(self._cache.bloom)

				if true then 
					
		--							self.weapon_data.bloom = 1 - math.pow((dt + 1 - self.weapon_data.bloom) * 0.5,2)
				
		--							local bloom_duration = 2
		--							self.weapon_data.bloom = math.pow(math.clamp((self.weapon_data.bloom - dt),0,1) * bloom_duration,2)
					
				elseif false then
					self._cache.bloom = self._cache.bloom * 0.97
					if self._cache.bloom - 0.001 < 0 then
						self._cache.bloom = 0
					end
				else
					self._cache.bloom = math.max(self._cache.bloom - 0.01,0)
				end
			end
			
						
		end
			
	end
end

function AdvancedCrosshair:GetCrosshairType(slot,weaponbase,fire_mode) --not strictly a settings getter since it depends on the equipped weapon
	if override_by_slot and slot then --todo
		return override_by_slot and slot
	elseif override_by_id and weaponbase then --todo
		return lookup_table and weaponbase:get_name_id()
	else
		local weapon_type,is_revolver,is_akimbo = self.GetWeaponCategory(weaponbase)
--		local fire_mode = (weaponbase.fire_mode and weaponbase:fire_mode()) or weaponbase.FIRE_MODE
		if weapon_type then 
			local result
			if is_akimbo then 
				result = self.settings["crosshair_type_" .. weapon_type .. "_" .. fire_mode .. "_akimbo"]
			end
			result = result or self.settings["crosshair_type_" .. weapon_type .. "_" .. fire_mode] or "ma37"
			return result
		end
	end
end



--************************************************--
		--io
--************************************************--
function AdvancedCrosshair:Save()
	local file = io.open(self.save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function AdvancedCrosshair:Load()
	local file = io.open(self.save_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:Save()
	end
end



--************************************************--
		--loc
--************************************************--
Hooks:Add("LocalizationManagerPostInit", "advc_addlocalization", function( loc )
	loc:add_localized_strings({
		menu_weapon_category_assault_rifle = "Assault Rifle",
		menu_weapon_category_pistol = "Pistol",
		menu_weapon_category_smg = "Submachine Gun",
		menu_weapon_category_lmg = "Light Machine Gun",
		menu_weapon_category_snp = "Sniper Rifle",
		menu_weapon_category_minigun = "Minigun",
		menu_weapon_category_flamethrower = "Flamethrower",
		menu_weapon_category_saw = "Saw",
		menu_weapon_category_shotgun = "Shotgun",
		menu_weapon_category_grenade_launcher = "Grenade Launcher",
		menu_weapon_category_bow = "Bow",
		menu_weapon_category_crossbow = "Crossbow",
		menu_weapon_firemode_single = "Single",
		menu_weapon_firemode_auto = "Auto",
		menu_weapon_firemode_burst = "Burst",
		menu_crosshair_type2_hammer = "Gravity Hammer",
		menu_crosshair_m247h = "UNSC Turret",
		menu_crosshair_halo_chevron = "Vehicle Chevron",
		menu_crosshair_type52_turret = "Covenant Turret",
		menu_crosshair_srs99 = "SRS99",
		menu_crosshair_type52_rifle = "Focus Rifle",
		menu_crosshair_type25_rifle = "Plasma Rifle",
		menu_crosshair_type31 = "Needle Rifle",
		menu_crosshair_type51_rifle = "Plasma Repeater",
		menu_crosshair_type33_aa = "Fuel Rod Launcher",
		menu_crosshair_h165 = "Target Designator",
		menu_crosshair_type25_pistol = "Plasma Pistol",
		menu_crosshair_type25_carbine = "Spiker",
		menu_crosshair_type52_launcher = "Plasma Launcher",
		menu_crosshair_type1_sword = "Energy Sword",
		menu_crosshair_type50 = "Concussion Rifle",
		menu_crosshair_type33_needler = "Needler",
		menu_crosshair_m319 = "Grenade Launcher (Halo)",
		menu_crosshair_m392 = "DMR (Halo)",
		menu_crosshair_m6g = "M6G",
		menu_crosshair_m90 = "Shotgun (Halo)",
		menu_crosshair_ma37 = "MA37 (Halo)",
		menu_crosshair_spnkr = "SPNKr",
		menu_crosshair_m7057 = "Flamethrower (Halo)",
		menu_crosshair_m7 = "SMG (Halo)",
		menu_hitmarker_destiny = "Destiny",
		menu_ach_hitmarkers_menu_main_title = "Advanced Crosshairs and Hitmarkers",
		menu_ach_hitmarkers_menu_title = "Hitmarker Customization...",
		menu_ach_crosshairs_menu_title = "Crosshair Customization...",
		menu_ach_set_color_title = "Set Color",
		menu_ach_set_color_desc = "Change the color of your crosshair",
		menu_ach_set_alpha_title = "Set Alpha",
		menu_ach_set_alpha_desc = "Change the opacity of your crosshair",
		menu_ach_set_bitmap_title = "Set Image",
		menu_ach_set_bitmap_desc = "Select the bitmap you want to use",
		menu_ach_preview_bloom_title = "Preview Bloom",
		menu_ach_preview_bloom_desc = "Click to simulate firing reticle bloom",
		menu_ach_change_crosshair_weapon_category_desc = "Edit the crosshair for this weapon category...",
		menu_ach_change_crosshair_weapon_firemode_desc = "Edit the crosshair for this firemode..." --not used
	})
end)


--************************************************--
		--menu
--************************************************--

--todo refactor menu tables to allow for organized localization
AdvancedCrosshair.main_menu_id = "ach_menu_main"
AdvancedCrosshair.crosshairs_menu_id = "ach_menu_crosshairs"
AdvancedCrosshair.hitmarkers_menu_id = "ach_menu_hitmarkers"
AdvancedCrosshair.customization_menus = {}
AdvancedCrosshair.crosshair_preview_data = nil
--AdvancedCrosshair.customization_menu_callbacks = {}
AdvancedCrosshair.crosshair_id_by_index = {}
Hooks:Add("MenuManagerSetupCustomMenus", "advc_MenuManagerSetupCustomMenus", function(menu_manager, nodes)

--	MenuHelper:NewMenu(AdvancedCrosshair.crosshairs_menu_id)
--	MenuHelper:NewMenu(AdvancedCrosshair.hitmarkers_menu_id)
	for _,cat in ipairs(AdvancedCrosshair.valid_weapon_categories) do 
		local cat_menu_name = "ach_crosshair_category_" .. tostring(cat)
		AdvancedCrosshair.customization_menus[cat_menu_name] = {
			category_name = cat,
			child_menus = {}
		}
		MenuHelper:NewMenu(cat_menu_name)
		for _,firemode in ipairs(AdvancedCrosshair.valid_weapon_firemodes) do 
			local firemode_menu_name = cat_menu_name .. "_firemode_" .. tostring(firemode)
			AdvancedCrosshair.customization_menus[cat_menu_name].child_menus[firemode_menu_name] = {menu = MenuHelper:NewMenu(firemode_menu_name),firemode = firemode}
		end
	end
	
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "advc_MenuManagerPopulateCustomMenus", function(menu_manager, nodes)
	local lm = managers.localization
--generate available crosshairs here, in the items subtable, along with a number index/name reverse lookup table?
	local items = {}
	local i = 1
	for id,crosshair_data in pairs(AdvancedCrosshair._crosshair_data) do 
		table.insert(items,i,crosshair_data.name_id)
		AdvancedCrosshair.crosshair_id_by_index[i] = id
		i = i + 1
	end

--create customization options here


--crosshair:
	--image
	--scale
	--alpha
	--default color? or in master crosshhair options?
	--preview bloom
	for cat_menu_name,cat_menu_data in pairs(AdvancedCrosshair.customization_menus) do 
		local i = 1
		local select_crosshair_type_callback_name = cat_menu_name .. "_select_crosshair_type"
		MenuCallbackHandler[select_crosshair_type_callback_name] = function(self,item) 
			local index = tonumber(item:value())
			local crosshair_id = AdvancedCrosshair.crosshair_id_by_index[index]
--			log("Selected " .. tostring(crosshair_id))

	--create crosshair preview
			local fullscreen_ws = managers.menu_component and managers.menu_component._fullscreen_ws
			if alive(fullscreen_ws) then 
				local menupanel = fullscreen_ws:panel()
				
				local crosshair_data = AdvancedCrosshair._crosshair_data[crosshair_id]
				if alive(menupanel:child("ach_preview")) then 
					menupanel:remove(menupanel:child("ach_preview"))
				end
				local preview_panel = menupanel:panel({
					name = "ach_preview"
				})
				local blur_bg = preview_panel:bitmap({
					name = "blur_bg",
					color = Color.white,
					layer = -100,
					w = 200,
					h = 200,
					texture = "guis/textures/test_blur_df",
					render_template = "VertexColorTexturedBlur3D"
				})
				blur_bg:set_center(preview_panel:center())
				AdvancedCrosshair.crosshair_preview_data = {
					panel = preview_panel,
					parts = AdvancedCrosshair:CreateCrosshair(preview_panel,crosshair_data),
					crosshair_type = crosshair_id,
					bloom = 0
				}
			end
		end
		
		local open_color_callback_name = cat_menu_name .. "_set_color"
		MenuCallbackHandler[open_color_callback_name] = function(self)
			--todo open set color dialog
			
			local color = Color(math.random(),math.random(),math.random())
			
			
			local function clbk_colorpicker (color,palettes)
			--set preview color
				--todo save palettes
				local preview_data = AdvancedCrosshair.crosshair_preview_data
				local parent_panel = preview_data and preview_data.panel
				local crosshair_data = preview_data and AdvancedCrosshair._crosshair_data[tostring(preview_data.crosshair_type)]
				if preview_data and crosshair_data and preview_data.parts and alive(parent_panel) then 
					for part_index,part in ipairs(preview_data.parts) do
						part:set_color(color)
					end
				end
			end
			
			if AdvancedCrosshair._colorpicker then 
--				self:get_palettes()
				AdvancedCrosshair._colorpicker:Show({changed_callback = clbk_colorpicker,done_callback = clbk_colorpicker})
			end
			
		end
		
		local preview_bloom_callback_name = cat_menu_name .. "_preview_bloom"
		MenuCallbackHandler[preview_bloom_callback_name] = function(self)
			--todo if preview data does not exist,
			--then create preview crosshair
		
			local preview_data = AdvancedCrosshair.crosshair_preview_data
			local parent_panel = preview_data and preview_data.panel
			local crosshair_data = preview_data and AdvancedCrosshair._crosshair_data[tostring(preview_data.crosshair_type)]
			if preview_data and crosshair_data and preview_data.parts and alive(parent_panel) and type(crosshair_data.bloom_func) == "function" then 
				preview_data.bloom = preview_data.bloom + 0.5 --todo
				BeardLib:AddUpdater("ach_preview_bloom", --needs to use beardlib updater since managers.hud isn't initialized in the main menu
					function(t,dt)
						if not (crosshair_data and preview_data.parts and alive(parent_panel) and type(crosshair_data.bloom_func) == "function") then 
							BeardLib:RemoveUpdater("ach_preview_bloom")
							return
						else
							local bloom_decay_mul = 2 --todo 
							preview_data.bloom = math.max(preview_data.bloom - (bloom_decay_mul * dt),0)
							for part_index,part in ipairs(preview_data.parts) do
								crosshair_data.bloom_func(part_index,part,
									{
										crosshair_data = crosshair_data,
										bloom = preview_data.bloom,
										panel_w = parent_panel:w(),
										panel_h = parent_panel:h()
									}
								)
							end
							if preview_data.bloom <= 0 then 
								--done doing bloom, so stop updating
								BeardLib:RemoveUpdater("ach_preview_bloom")
							end
						end
					end,
				true)
			end
		end
		
--		AdvancedCrosshair.customization_menu_callbacks[callback_name] = true
		for firemode_menu_name,firemode_menu in pairs(cat_menu_data.child_menus) do 
			MenuHelper:AddMultipleChoice({
				id = "set_bitmap_" .. firemode_menu_name,
				title = "menu_ach_set_bitmap_title",
				desc = "menu_ach_set_bitmap_desc",
				callback = select_crosshair_type_callback_name,
				items = items,
				value = 1,
				menu_id = firemode_menu_name,
				priority = 2
			})
			
			MenuHelper:AddButton({
				id = "preview_bloom_" .. firemode_menu_name,
				title = "menu_ach_preview_bloom_title",
				desc = "menu_ach_preview_bloom_desc",
				callback = preview_bloom_callback_name,
				menu_id = firemode_menu_name,
				priority = 3
			})
			
			MenuHelper:AddButton({
				id = "set_color_" .. firemode_menu_name,
				title = "menu_ach_set_color_title",
				desc = "menu_ach_set_color_desc",
				callback = open_color_callback_name,
				menu_id = firemode_menu_name,
				priority = 4
			})
			i = i + 1
		end
		
		local preview_hitmarker_callback_name = ""
		
		
	end
	
--hitmarker:
	--...stuff
	
end)

Hooks:Add("MenuManagerBuildCustomMenus", "ach_MenuManagerBuildCustomMenus", function( menu_manager, nodes )
	local lm = managers.localization
	for cat_menu_name,cat_menu_data in pairs(AdvancedCrosshair.customization_menus) do 
		local cat_menu = MenuHelper:GetMenu(cat_menu_name)
		local i = 1
		
		local cat_name_id = "menu_weapon_category_" .. tostring(cat_menu_data.category_name)
		local cat_name_desc = "menu_ach_change_crosshair_weapon_category_desc"
		
		for firemode_menu_name,firemode_menu in pairs(cat_menu_data.child_menus) do
			local firemode = tostring(firemode_menu.firemode)
			local name_id = "menu_weapon_firemode_" .. firemode
			local desc_id = cat_name_id
			nodes[firemode_menu_name] = MenuHelper:BuildMenu(firemode_menu_name,{area_bg = "none",back_callback = MenuCallbackHandler.callback_ach_crosshairs_close,focus_changed_callback=MenuCallbackHandler.callback_ach_crosshairs_focus})
			MenuHelper:AddMenuItem(cat_menu,firemode_menu_name,name_id,desc_id,i) --add each firemode menu to its weaponcategory parent menu
			i = i + 1
		end
		nodes[cat_menu_name] = MenuHelper:BuildMenu(cat_menu_name,{area_bg = "half",back_callback = MenuCallbackHandler.callback_ach_hitmarkers_close,focus_changed_callback = MenuCallbackHandler.callback_ach_hitmarkers_focus})
		MenuHelper:AddMenuItem(MenuHelper:GetMenu(AdvancedCrosshair.crosshairs_menu_id),cat_menu_name,cat_name_id,cat_name_desc,1)
	end
end)

Hooks:Add("MenuManagerInitialize", "advc_initmenu", function(menu_manager)
	MenuCallbackHandler.callback_ach_main_close = function(self)
		log("Close mainmenu")
	end
	MenuCallbackHandler.callback_ach_hitmarkers_close = function(self)
		log("Close hm")
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_close = function(self)
		log("Close ch") --functional
		if AdvancedCrosshair.crosshair_preview_data then 
			local panel = AdvancedCrosshair.crosshair_preview_data.panel
			if alive(panel) then 
				panel:parent():remove(panel)
			end
			AdvancedCrosshair.crosshair_preview_data = nil
		end
		
		
		AdvancedCrosshair:Save()
	end
	
	--nonfunctional
	MenuCallbackHandler.callback_ach_main_focus = function(self,item)
		log("Changed main focus")
	end
	MenuCallbackHandler.callback_ach_hitmarkers_focus = function(self,item)
		log("Changed hm focus")
	end
	MenuCallbackHandler.callback_ach_crosshairs_focus = function(self,item)
		log("changed ch focus")
	end

	AdvancedCrosshair._colorpicker = AdvancedCrosshair._colorpicker or (ColorPicker and ColorPicker:new("advancedcrosshairs",{},callback(AdvancedCrosshair,AdvancedCrosshair,"set_colorpicker_menu")))

	AdvancedCrosshair:Load()
	
	MenuHelper:LoadFromJsonFile(AdvancedCrosshair.path .. "menu/menu_main.json", AdvancedCrosshair, AdvancedCrosshair.settings)
	MenuHelper:LoadFromJsonFile(AdvancedCrosshair.path .. "menu/menu_crosshairs.json", AdvancedCrosshair, AdvancedCrosshair.settings)
	MenuHelper:LoadFromJsonFile(AdvancedCrosshair.path .. "menu/menu_hitmarkers.json", AdvancedCrosshair, AdvancedCrosshair.settings)
end)

