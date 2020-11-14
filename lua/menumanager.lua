		--todo list, loosely sorted by descending priority:


--write up documentation for custom hitmarkers/crosshairs

-- dynamic color callbacks for crosshairs

-- add preview clbks to menu callbacks
	--will require loading setting data for selected weapon type/firemode to memory, since focus_changed_callback does not pass menu id

-- fix crosshair being invisible upon game start in loud, or after refreshing crosshair from menu
	-- call check immediately after generation/check game heist state?

-- add hitmarkers on melee
-- add hook to call wipe crosshair data/refresh crosshair

-- fullscreen/halfscreen/none bg menus for all preview-related menus

-- toggle option for scaling crosshairs with world distance at world position?
-- slider option for scaling hitmarker size?
-- hitsound volume sliders

-- halo reach head aim crosshair dot
-- import special halo reach crosshair + add option to pass relevant data to all crosshairs
-- bloom delay/add values per crosshair

-- test burstfire support
-- hide character + bg menu like how blt mods menu does (and fails to restore after hitting back lol)

-- change menu-changed recreate crosshair callback to also manually wipe existing weapon data in case in-heist weapon changes (eg. through weapon pickup mod)

-- akimbo crosshair support
-- override by slot (needs menu options)
-- override by weapon id (needs menu options)
-- super srs april fool's hitmarkers rain

--************************************************--
		--init mod data
--************************************************--
_G.AdvancedCrosshair = {}
AdvancedCrosshair._animate_targets = {}
AdvancedCrosshair._panel = nil
AdvancedCrosshair._hitmarker_panel = nil
AdvancedCrosshair._crosshair_panel = nil

AdvancedCrosshair.url_colorpicker = "https://modwork.shop/29641"
AdvancedCrosshair.url_ach_github = "https://github.com/offyerrocker/PD2-AdvancedCrosshairs"
AdvancedCrosshair.url_ach_mws = "https://modwork.shop/29585"

AdvancedCrosshair.addons_readme_txt = "This directory is where you can install \"Simple\" add-on folders for Crosshairs, Hitmarkers, or Hitsounds.\nThese must be folders, no archives or files- .texture, .zip, .7zip, .tar, etc. will not be read!\nTo install add-ons, place the add-on folder(s) in one of the three subfolders according to the type of add-on- NOT directly in the same folder as this file.\n\nPlease refer to the documentation for more information: \n$LINK\n\nP.S. You can safely delete this readme file if you wish. It will only be re-generated on launch if ACH is installed and the ACH Addons folder is removed.\nHave a nice day!"

AdvancedCrosshair.DEFAULT_CROSSHAIR_OPTIONS = {
	crosshair_id = "ma37",
	use_bloom = true,
	color = "ffffff",
	alpha = 1,
	overrides_global = true
}
AdvancedCrosshair.DEFAULT_HITMARKER_OPTIONS = { --not used
	hitmarker_id = "destiny",
	use_animate = true,
	default_color = "eeeeee",
	headshot_color = "ff0000",
	crit_color = "0000ff",
	headcrit_color = "ff00ff"
}

AdvancedCrosshair.STATES_CROSSHAIR_ALLOWED = {
	empty = false,
	standard = true,
	mask_off = false,
	bleed_out = true,
	fatal = false,
	arrested = false,
	tased = true,
	incapacitated = false,
	clean = false,
	civilian = false,
	carry = true,
	bipod = true,
	driving = false,
	jerry2 = false,
	jerry1 = false
}

AdvancedCrosshair.BLEND_MODES = { --for getting the blend mode from the number index returned by menu setting callback
	"normal",
	"add",
	"sub",
	"mul"
}

AdvancedCrosshair.VALID_WEAPON_CATEGORIES = {
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

AdvancedCrosshair.VALID_WEAPON_FIREMODES = {
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
	hitsound_enabled = false,
	use_bloom = true,
	use_shake = true,
	use_color = true,
	use_hitpos = true,
	use_hitsound_pos = false,
	hitsound_hit_bodyshot_id = "tf2_hit",
	hitsound_hit_headshot_id = "tf2_hit",
	hitsound_hit_bodyshot_crit_id = "tf2_crit",
	hitsound_hit_headshot_crit_id = "tf2_crit",
	hitsound_kill_headshot_id = "tf2_hit",
	hitsound_kill_bodyshot_id = "tf2_hit",
	hitsound_kill_bodyshot_crit_id = "tf2_crit",
	hitsound_kill_headshot_crit_id = "tf2_crit",
	hitsound_hit_bodyshot_volume = 1,
	hitsound_hit_headshot_volume = 1,
	hitsound_hit_bodyshot_crit_volume = 1,
	hitsound_hit_headshot_crit_volume = 1,
	hitsound_kill_headshot_volume = 1,
	hitsound_kill_bodyshot_volume = 1,
	hitsound_kill_bodyshot_crit_volume = 1,
	hitsound_kill_headshot_crit_volume = 1,
	hitsound_suppress_doublesound = true,
	crosshair_all_override = false,
	crosshair_stability = 1,
	crosshair_enemy_color = "ff0000",
	crosshair_civilian_color = "00ff00",
	crosshair_teammate_color = "00ffff",
	crosshair_misc_color = "ff00ff",
	hitmarker_hit_id = "destiny",
	hitmarker_hit_duration = 0.75,
	hitmarker_hit_alpha = 0.5,
	hitmarker_hit_blend_mode = "normal",
	hitmarker_hit_bodyshot_color = "ffffff",
	hitmarker_hit_bodyshot_crit_color = "00ffff",
	hitmarker_hit_headshot_color = "ff0000",
	hitmarker_hit_headshot_crit_color = "ff00ff",
	hitmarker_kill_id = "destiny",
	hitmarker_kill_duration = 0.25,
	hitmarker_kill_alpha = 1,
	hitmarker_kill_blend_mode = "normal",
	hitmarker_kill_bodyshot_color = "ffffff",
	hitmarker_kill_bodyshot_crit_color = "00ffff",
	hitmarker_kill_headshot_color = "ff0000",
	hitmarker_kill_headshot_crit_color = "ff00ff",
	palettes = { --for colorpicker
		"ff7a7a",
		"ffbd7a",
		"ffff7a",
		"ff7abd",
		"ff7aff",
		"87ff7a",
		"7affb0",
		"7afff2",
		"caff7a",
		"fff27a",
		"7afdff",
		"7abbff",
		"7c7aff",
		"7affbf",
		"7aff7c",
		"7a7eff",
		"b87aff",
		"fb7aff",
		"7ac1ff",
		"7afff8",
		"d57aff",
		"ff7ae7",
		"ff7aa4",
		"937aff",
		"7aa4ff"
	},
	crosshair_global = table.deep_map_copy(AdvancedCrosshair.DEFAULT_CROSSHAIR_OPTIONS),
	crosshairs = {},
	crosshair_weapon_id_overrides = {
	--EG:
--		deagle = {
--			crosshair_id = "m6g",
--			use_bloom = true,
--			color = "ffffff",
--			alpha = 0.9,
--			overrides_global = true
--		}
	},
	crosshair_slot_overrides = {
	--EG:
--		1 = { --overrides all primary slots
--			crosshair_id = "ma37",
--			use_bloom = true,
--			color = "ffffff",
--			alpha = 0.5,
--			overrides_global = true
--		}
	}
}

--init settings for every variation of weapon + firemode (even for combinations that don't exist in-game)
for _,cat in pairs(AdvancedCrosshair.VALID_WEAPON_CATEGORIES) do 
	AdvancedCrosshair.settings.crosshairs[cat] = {}
	for _,firemode in pairs(AdvancedCrosshair.VALID_WEAPON_FIREMODES) do 
		AdvancedCrosshair.settings.crosshairs[cat][firemode] = table.deep_map_copy(AdvancedCrosshair.DEFAULT_CROSSHAIR_OPTIONS)
	end
end

AdvancedCrosshair.path = ModPath
AdvancedCrosshair.hitsound_path = AdvancedCrosshair.path .. "assets/snd/hitsounds/"
AdvancedCrosshair.save_path = SavePath
AdvancedCrosshair.save_data_path = AdvancedCrosshair.save_path .. "AdvancedCrosshair.txt"
AdvancedCrosshair.mod_overrides_path = ""
AdvancedCrosshair.ADDON_PATHS = {
	crosshairs = {
--		AdvancedCrosshair.mod_overrides_path .. "ACH Addons/Crosshairs/",
		AdvancedCrosshair.save_path .. "ACH Addons/Crosshairs/"
	},
	hitmarkers = {
--		AdvancedCrosshair.mod_overrides_path .. "ACH Addons/Hitmarkers/",
		AdvancedCrosshair.save_path .. "ACH Addons/Hitmarkers/"
	},
	hitsounds = {
--		AdvancedCrosshair.mod_overrides_path .. "ACH Addons/Hitsounds/",
		AdvancedCrosshair.save_path .. "ACH Addons/Hitsounds/"
	}
}


--holds some instance-specific stuff to save time + cycles
AdvancedCrosshair._cache = {
	current_crosshair_data = nil, --holds table reference to self._cache.weapons [...] .firemode
	underbarrel = {}, --deprecated
	weapon = {}, --deprecated
	weapons = {},
	bloom = 0,
	bloom_t = -69,
	hitmarkers = {},
	num_hitmarkers = 0
}

_G.queued_delay_advanced_crosshair_data = {}

--do not change this. refer to the guide if you want to add custom crosshairs to this mod
AdvancedCrosshair._crosshair_data = {
	ma37 = { --halo reach assault rifle; four circle subquadrants + four aiming ticks
		name_id = "menu_crosshair_ma37",
		bloom_func = function(index,bitmap,data)
			local bloom = data.bloom
			if index == 1 then 
				bitmap:set_alpha((1.25 - bloom) / 2)
				--main
			else
				local crosshair_data = data.crosshair_data and data.crosshair_data.parts[index] or {}
				local angle = crosshair_data.rotation or 60
				local c_x = data.panel_w/2
				local c_y = data.panel_h/2
				local distance = (crosshair_data.distance or 10) * ((1.5 * bloom) + 1)
				bitmap:set_alpha(bloom + 0.5)
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
				w = 4,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 90,
				distance = 10,
				w = 4,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 180,
				distance = 10,
				w = 4,
				h = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				rotation = 270,
				distance = 10,
				w = 4,
				h = 8
			}
		}
	},
	m392 = { --halo reach dmr; circle w/ four circle subquadrants
		name_id = "menu_crosshair_m392",
		bloom_func = function(index,bitmap,data)
			local bloom = data.bloom
			local max_distance = 48
			if index == 1 then 
				bitmap:set_alpha(1.25 - bloom)
			elseif index == 2 then 
				local size = 16 + (max_distance * bloom)
				bitmap:set_size(size,size)
				bitmap:set_rotation(bloom * 45)
				bitmap:set_alpha(bloom + 0.33)
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
				h = 16,
				alpha = 0.75
			}
		}
	},
	m6g = { --halo reach pistol; similar to dmr
		name_id = "menu_crosshair_m6g",
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
--[[	m319 = { --halo reach grenade launcher; circle with distance markers
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
--]]
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
--please note that the same animation hit_func is called when previewing it from the menu
--so, when you are making your own hitmarker animation functions,
--remember either to not depend too heavily on the attack_data or result tables,
--or add sufficient sanity checks so as not to crash people in the menu
--the rest of the parameters (headshot, crit, result_type, etc) are safe to check/use, since they should be passed to the preview creation in the menu
	destiny_hit = {
		name_id = "menu_hitmarker_destiny_hit",
		hit_anim_distance = 12, --random var i used when creating this hitmarker, to show that you can... do that, since this data table is passed to the animation function
	--beware: these options generally override user settings,
	--so don't set color in the part table, or alpha in your main hitmarker table, unless you want it to be unaffected by settings
	--if you choose not to add a custom animation function, the fadeout alpha animation will automatically be used
	--if you do specify a custom animation function, you will have to provide the alpha fadeout yourself (unless you want your crosshair to disappear suddenly instead of fading out)
		parts = {
			{ --reused from plasma rifle crosshairs
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 2,
				h = 12,
				angle = -45,
				rotation = 180,
				distance = 12
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 2,
				h = 12,
				angle = 45,
				rotation = 180,
				distance = 12
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 2,
				h = 12,
				angle = 135,
				rotation = 180,
				distance = 12
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 2,
				h = 12,
				angle = -135,
				rotation = 180,
				distance = 12
			}
		}
	},
	destiny_kill = {
	--in this case, since i added the ability to choose hit/kill hitmarkers separately,
	--i separated the hit/kill hitmarker animations from the two hitmarkers provided.
	--however, you don't need to do this; since results are passed to the hitmarker, 
	--you could create a hitmarker with explicitly different behavior on kill versus hit.
		name_id = "menu_hitmarker_destiny_kill",
		hit_func = function(index,bitmap,data,t,dt,start_t,duration)
			local part_data = data.hitmarker_data.parts[index]
			local ratio = math.min(1,(t - start_t) / duration)
			
			if ratio < 0.5 then 
				local r_ratio = ratio * 2
				local distance = part_data.distance + (data.hitmarker_data.hit_anim_distance * r_ratio)
				local angle = part_data.angle
				local c_x = data.panel:w() / 2
				local c_y = data.panel:h() / 2
				bitmap:set_center(c_x + math.sin(angle) * distance,c_y - (math.cos(angle) * distance))
			else
				local r_ratio = 2 - (ratio * 2)
				bitmap:set_alpha(r_ratio)
			end
		end,
		hit_anim_distance = 12,
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 2,
				h = 12,
				angle = -45,
				rotation = 180,
				distance = 12
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 2,
				h = 12,
				angle = 45,
				rotation = 180,
				distance = 12
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 2,
				h = 12,
				angle = 135,
				rotation = 180,
				distance = 12
			},
			{
				texture = "guis/textures/advanced_crosshairs/plasma_crosshair_1",
				w = 2,
				h = 12,
				angle = -135,
				rotation = 180,
				distance = 12
			}
		}
	},
	gtfo_hit = {
		name_id = "menu_hitmarker_gtfo_hit",
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 0,
				rotation = 180,
				distance = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 90,
				rotation = 180,
				distance = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 180,
				rotation = 180,
				distance = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 270,
				rotation = 180,
				distance = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 45,
				rotation = 180,
				distance = 22
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 135,
				rotation = 180,
				distance = 22
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 225,
				rotation = 180,
				distance = 22
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 315,
				rotation = 180,
				distance = 22
			}
		}
	},
	gtfo_kill = {
		name_id = "menu_hitmarker_gtfo_kill",
		hit_func = function(index,bitmap,data,t,dt,start_t,duration)
			local ratio = math.min(1,(t - start_t) / duration)
			local part_data = data.hitmarker_data.parts[index]
			local distance = part_data.distance * (1.5 + ratio)
			
			local angle = part_data.angle
			local c_x = data.panel:w() / 2 --should these just get + use bitmap parent's panel size?
			local c_y = data.panel:h() / 2
			bitmap:set_center(c_x + math.sin(angle) * distance,c_y - (math.cos(angle) * distance))
			bitmap:set_alpha(math.pow(1 - ratio,2))
		end,
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 0,
				rotation = 180,
				distance = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 90,
				rotation = 180,
				distance = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 180,
				rotation = 180,
				distance = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 270,
				rotation = 180,
				distance = 16
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 45,
				rotation = 180,
				distance = 22
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 135,
				rotation = 180,
				distance = 22
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 225,
				rotation = 180,
				distance = 22
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 315,
				rotation = 180,
				distance = 22
			}
		}
	},
	none = {
		name_id = "menu_hitmarker_none",
		parts = {
			{
				texture = "",
				w = 0,
				h = 0,
				angle = 0,
				rotation = 0,
				distance = 0,
				alpha = 0
			}
		}
	},
	vanilla = {
		name_id = "menu_hitmarker_vanilla",
		parts = {
			{
				texture = "guis/textures/pd2/hitconfirm",
				w = 16,
				h = 16,
				angle = 0,
				rotation = 0,
				distance = 0
			}
		}
	},
	generic_hit = {
		name_id = "menu_hitmarker_generic_hit",
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 45,
				rotation = 180,
				distance = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 135,
				rotation = 180,
				distance = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 225,
				rotation = 180,
				distance = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 315,
				rotation = 180,
				distance = 8
			}
		}
	},
	generic_kill = {
		name_id = "menu_hitmarker_generic_kill",
		hit_func = function(index,bitmap,data,t,dt,start_t,duration)
			local ratio = math.min(1,(t - start_t) / duration)
			local part_data = data.hitmarker_data.parts[index]
			local distance = part_data.distance * (1 + (math.min(ratio + 0.25,1)))
			--extended fully at 85%, lingers for remaining 15%
			
			local angle = part_data.angle
			local c_x = data.panel:w() / 2
			local c_y = data.panel:h() / 2
			bitmap:set_center(c_x + math.sin(angle) * distance,c_y - (math.cos(angle) * distance))
			bitmap:set_alpha(math.pow(1 - ratio,2))
		end,
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 45,
				rotation = 180,
				distance = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 135,
				rotation = 180,
				distance = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 225,
				rotation = 180,
				distance = 8
			},
			{
				texture = "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 315,
				rotation = 180,
				distance = 8
			}
		}
	},
	tf2_crit = {
		name_id = "menu_hitmarker_tf2_crit",
		hit_func = function(index,bitmap,data,t,dt,start_t,duration)
			local ratio = (t - start_t) / duration
			local col_ratio = math.max(ratio - 0.5,0) / 0.5 --offset start by 50%
			if ratio <= 0.25 then 
				local c_x = data.panel:w() / 2
				local c_y = data.panel:h() / 2
				local part_data = data.hitmarker_data.parts[index]
				bitmap:set_size(part_data.w * (0.75 - ratio),part_data.h * (0.75 - ratio))
				bitmap:set_center(c_x,c_y)
			end
			if ratio > 0.33 then 
				bitmap:move(0,data.hitmarker_data.WANDER_SPEED * dt * -(1+col_ratio)) --movement speed accelerates upward
			end
			bitmap:set_alpha(math.pow(1 - ratio,0))
			bitmap:set_color(AdvancedCrosshair.interp_colors(data.hitmarker_data.COLOR_1,data.hitmarker_data.COLOR_2,col_ratio))
		end,
		COLOR_1 = Color.green,
		COLOR_2 = Color.red,
		WANDER_SPEED = 13, --pixels per second, approx
		parts = {
			{
				texture = "guis/textures/advanced_crosshairs/tf2_crit_text",
				w = 136 / 1.5,
				h = 76 / 1.5,
				angle = 0,
				rotation = 0,
				distance = 32,
				UNRECOLORABLE = true,
				skip_center = true
			}
		}
	}
}

AdvancedCrosshair._hitsound_data = {
	none = {
		name_id = "menu_hitsound_none",
		path = ""
	},
	tf2_hit = {
		name_id = "menu_hitsound_tf2_hit",
		path = AdvancedCrosshair.hitsound_path .. "tf2_hit.ogg"
	},
	tf2_crit = {
		name_id = "menu_hitsound_tf2_crit",
		path = AdvancedCrosshair.hitsound_path .. "tf2_crit.ogg"
	},
	overwatch_hit = {
		name_id = "menu_hitsound_overwatch_hit",
		path = AdvancedCrosshair.hitsound_path .. "overwatch_hit.ogg"
	},
	overwatch_kill = {
		name_id = "menu_hitsound_overwatch_kill",
		path = AdvancedCrosshair.hitsound_path .. "overwatch_kill.ogg"
	},
	quake3 = {
		name_id = "menu_hitsound_quake3",
		path = AdvancedCrosshair.hitsound_path .. "quake3.ogg"
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

function AdvancedCrosshair:GetWeaponCategory(categories)
	local category,is_revolver,is_akimbo
	for _,cat in pairs(categories) do 
		if cat == "revolver" then 
			is_revolver = true
		elseif cat == "akimbo" then 
			is_akimbo = true
		elseif table.contains(self.VALID_WEAPON_CATEGORIES,cat) then
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

function AdvancedCrosshair.interp_colors(one,two,percent) --interpolates colors based on a percentage
--percent is [0,1]
	percent = math.clamp(percent,0,1)
	
--color 1
	local r1 = one.red
	local g1 = one.green
	local b1 = one.blue
	local a1 = one.alpha
	
--color 2
	local r2 = two.red
	local g2 = two.green
	local b2 = two.blue
	local a2 = two.alpha

--delta
	local r3 = r2 - r1
	local g3 = g2 - g1
	local b3 = b2 - b1
	local a3 = a2 - a1
	
	return Color(r1 + (r3 * percent),g1 + (g3 * percent), b1 + (b3 * percent)):with_alpha(a1 + (a3 * percent))
end

--************************************************--

--complex custom add-ons (crosshairs/hitmarkers/hitsounds) should be added before MenuManagerPopulateCustomMenus is called
--simple custom add-ons should simply be added inside the assets/mod_overrides/AdvancedCrosshairs or mods/saves/AdvancedCrosshairs folder, and this mod will take care of adding them








--[[
	for file in savepath/hitsounds/ do 
		addHitsound(file,generatedata())
	end
	for file in savepath/hitmarkers/ do 
		addhitmarker(file,hitmarkers())
	end
	for file in savepath/crosshairs/ do 
		addcrosshair(file,hitmarkers())
	end

--]]

function AdvancedCrosshair:LoadAllAddons()
	
	self:LoadCrosshairAddons()
	self:LoadHitmarkerAddons()
	self:LoadHitsoundAddons()
end

function AdvancedCrosshair:AddCustomCrosshair(id,data)
	if self._crosshair_data[id] then 
		self:log("Warning! Crosshair with id " .. id .. " already exists. Replacing existing data...",{color=Color(1,0.5,0)})
	end
	if id then 
		AdvancedCrosshair._crosshair_data[id] = data
		self:log("Added custom crosshair addon: " .. (data.name_id and managers.localization:text(data.name_id) or "[ERROR]"))
	else
		self:log("Error: Could not load crosshair add-on. (reason: invalid id)")
		if type(data) == "table" then 
			self:log("Dumping crosshair addon data to BLT log for identification...")
			PrintTable(data)
			self:log("Crosshair addon data dump complete.")
		else
			self:log("Crosshair addon data invalid: " .. tostring(data))
		end
	end
end

function AdvancedCrosshair:LoadCrosshairAddons()
	local extension = "texture"
	for _,addon_path in pairs(self.ADDON_PATHS.crosshairs) do 
		if SystemFS:exists(Application:nice_path(addon_path,true)) then 
			for _,foldername in pairs(SystemFS:list(addon_path,true)) do 
				local parts = {}
				for _,filename in pairs(SystemFS:list(BeardLib.Utils.Path:Combine(addon_path,foldername))) do 
					if string.find(filename,"%." .. extension) then
						local raw_path = BeardLib.Utils.Path:Combine(addon_path,foldername,filename)
						local texture_path = string.gsub(raw_path,"%." .. extension,"")
						texture_path = string.gsub(texture_path,AdvancedCrosshair.save_path,"")
						texture_path = string.gsub(texture_path,AdvancedCrosshair.mod_overrides_path,"")
						
						DB:create_entry(Idstring(extension),Idstring(texture_path),raw_path)
						
						table.insert(parts,#parts+1,{
							texture = texture_path
						})
					end
				end
				
				if #parts > 0 then 
					local string_id = "menu_crosshair_addon_" .. foldername
					managers.localization:add_localized_strings({
						[string_id] = foldername
					})
					self:AddCustomCrosshair(foldername,{
						name_id = string_id,
						parts = parts,
						is_addon = true
					})
				end
			end
		end
	end
end

function AdvancedCrosshair:AddCustomHitmarker(id,data)
	if self._hitmarker_data[id] then 
		self:log("Warning! Hitmarker with id " .. id .. " already exists. Replacing existing data...",{color=Color(1,0.5,0)})
	end
	if id then 
		AdvancedCrosshair._hitmarker_data[id] = data
		self:log("Added custom hitmarker addon: " .. (data.name_id and managers.localization:text(data.name_id) or "[ERROR]"))
	else
		self:log("Error: Could not load hitmarker add-on. (reason: invalid id)")
		if type(data) == "table" then 
			self:log("Dumping hitmarker addon data to BLT log for identification...")
			PrintTable(data)
			self:log("Hitmarker addon data dump complete.")
		else
			self:log("Hitmarker addon data invalid: " .. tostring(data))
		end
	end
end

function AdvancedCrosshair:LoadHitmarkerAddons()
	local extension = "texture"
	for _,addon_path in pairs(self.ADDON_PATHS.hitmarkers) do 
		if SystemFS:exists(Application:nice_path(addon_path,true)) then 
			for _,foldername in pairs(SystemFS:list(addon_path,true)) do 
				local parts = {}
				for _,filename in pairs(SystemFS:list(BeardLib.Utils.Path:Combine(addon_path,foldername))) do 
					if string.find(filename,"%." .. extension) then
						local raw_path = BeardLib.Utils.Path:Combine(addon_path,foldername,filename)
						local texture_path = string.gsub(raw_path,"%." .. extension,"")
						texture_path = string.gsub(texture_path,AdvancedCrosshair.save_path,"")
						texture_path = string.gsub(texture_path,AdvancedCrosshair.mod_overrides_path,"")
						
						DB:create_entry(Idstring(extension),Idstring(texture_path),raw_path)
						
						table.insert(parts,#parts+1,{
							texture = texture_path
						})
					end
				end
				
				if #parts > 0 then 
					local string_id = "menu_hitmarker_addon_" .. foldername
					managers.localization:add_localized_strings({
						[string_id] = foldername
					})
					self:AddCustomHitmarker(foldername,{
						name_id = string_id,
						parts = parts,
						is_addon = true
					})
				end
			end
		end
	end
end

function AdvancedCrosshair:AddCustomHitsound(id,data)
	if self._hitsound_data[id] then 
		self:log("Warning! Hitsound with id " .. id .. " already exists. Replacing existing data...",{color=Color(1,0.5,0)})
	end
	if id then 
		AdvancedCrosshair._hitsound_data[id] = data
		self:log("Added custom hitsound addon: " .. (data.name_id and managers.localization:text(data.name_id) or "[ERROR]"))
	else
		self:log("Error: Could not load hitsound add-on. (reason: invalid id)")
		if type(data) == "table" then 
			self:log("Dumping hitsound addon data to BLT log for identification...")
			PrintTable(data)
			self:log("Hitsound addon data dump complete.")
		else
			self:log("Hitsound addon data invalid: " .. tostring(data))
		end
	end
end

function AdvancedCrosshair:LoadHitsoundAddons()
	local extension = "ogg"
	for _,addon_path in pairs(self.ADDON_PATHS.hitsounds) do 
		if SystemFS:exists(Application:nice_path(addon_path,true)) then 
			for _,foldername in pairs(SystemFS:list(addon_path,true)) do 
				local is_randomized = SystemFS:exists(Application:nice_path(BeardLib.Utils.Path:Combine(addon_path,foldername,"random.txt")))
				local variations = {}
				for _,filename in pairs(SystemFS:list(BeardLib.Utils.Path:Combine(addon_path,foldername))) do 
					if string.find(filename,"%." .. extension) then 
						local raw_path = BeardLib.Utils.Path:Combine(addon_path,foldername,filename)
						
						if is_randomized then
							table.insert(variations,#variations + 1,raw_path)
						else
							local clean_filename = string.sub(filename,1,string.len(filename) - string.len("." .. extension))
							local string_id = "menu_hitsound_addon_" .. clean_filename
							managers.localization:add_localized_strings({
								[string_id] = clean_filename
							})
							
							self:AddCustomHitsound(clean_filename,{
								name_id = string_id,
								path = raw_path,
								is_addon = true
							})
						end
					end
				end
				if is_randomized then 
					local string_id = "menu_hitsound_addon_" .. foldername
					managers.localization:add_localized_strings({
						[string_id] = foldername
					})
					self:AddCustomHitsound(foldername,{
						name_id = string_id,
						path = "",
						variations = variations
					})
				end
			end
			
		end
	end
end



--local extension = "ogg"; local duck = "Bumper_car_quack5.ogg"; return string.sub(duck,1,string.len(duck) - string.len("." .. extension))







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
function AdvancedCrosshair:UseBloom() --deprecated
	return self.settings.use_bloom
end
function AdvancedCrosshair:UseCrosshairShake()
	return self.settings.use_shake
end
function AdvancedCrosshair:UseDynamicColor() --not used
	return self.settings.use_color
end
function AdvancedCrosshair:IsCrosshairEnabled()
	return self.settings.crosshair_enabled
end
function AdvancedCrosshair:IsHitmarkerEnabled()
	return self.settings.hitmarker_enabled
end
function AdvancedCrosshair:UseHitmarkerHitPosition()
	return self.settings.use_hitpos
end
function AdvancedCrosshair:GetColorByTeam(team)
	local result = self.settings.crosshair_misc_color
	
	if team == "law1" then 
		result = self.settings.crosshair_enemy_color
	elseif team == "neutral1" then 
		result = self.settings.crosshair_civilian_color
	elseif team == "mobster1" then 
		result = self.settings.crosshair_misc_color
	elseif team == "criminal1" then 
		result = self.settings.crosshair_teammate_color
	elseif team == "converted_enemy" then
		result = self.settings.crosshair_teammate_color
	elseif team == "hacked_turret" then 
		result = self.settings.crosshair_teammate_color
	end
	
	return result and Color(result) or Color.white
end
function AdvancedCrosshair:IsHitsoundEnabled()
	return self.settings.hitsound_enabled
end

function AdvancedCrosshair:ShouldSuppressDoubleSound() --determines whether hit+critsounds should both be played, or just one
	return self.settings.hitsound_suppress_doublesound
end

function AdvancedCrosshair:GetHitmarkerDuration() --deprecated
	return 1
end
function AdvancedCrosshair:GetHitmarkerType() --deprecated
	return "destiny"
end
function AdvancedCrosshair:GetHitmarkerBlendMode() --deprecated
	return "normal" --"add"
end
function AdvancedCrosshair:GetHitmarkerAlpha() --deprecated
	return 1
end

function AdvancedCrosshair:GetPaletteColors()
	local result = {}
	for i,hex in ipairs(self.settings.palettes) do 
		result[i] = Color(hex)
	end
	return result
end

function AdvancedCrosshair:SetPaletteCodes(tbl)
	if type(tbl) == "table" then 
		for i,color in ipairs(tbl) do 
			self.settings.palettes[i] = color:to_hex()
		end
	else
		self:log("Error: SetPaletteCodes(" .. tostring(tbl) .. ") Bad palettes table from ColorPicker callback")
	end
end

function AdvancedCrosshair:UseGlobalCrosshair()
	return self.settings.crosshair_all_override
end

function AdvancedCrosshair:GetBloomCooldown()
	return 0.05
end

function AdvancedCrosshair:GetHitmarkerSettings(hitmarker_type)
	if (hitmarker_type == "kill") or (hitmarker_type == "death") then 
		return {
			hitmarker_id = self.settings.hitmarker_kill_id,
			duration = self.settings.hitmarker_kill_duration,
			alpha = self.settings.hitmarker_kill_alpha,
			blend_mode = self.settings.hitmarker_kill_blend_mode,
			bodyshot_color = Color(self.settings.hitmarker_kill_bodyshot_color),
			bodyshot_crit_color = Color(self.settings.hitmarker_kill_bodyshot_crit_color),
			headshot_color = Color(self.settings.hitmarker_kill_headshot_color),
			headshot_crit_color = Color(self.settings.hitmarker_kill_headshot_crit_color)
		} 
	end
	return {
		hitmarker_id = self.settings.hitmarker_hit_id,
		duration = self.settings.hitmarker_hit_duration,
		alpha = self.settings.hitmarker_hit_alpha,
		blend_mode = self.settings.hitmarker_hit_blend_mode,
		bodyshot_color = Color(self.settings.hitmarker_hit_bodyshot_color),
		bodyshot_crit_color = Color(self.settings.hitmarker_hit_bodyshot_crit_color),
		headshot_color = Color(self.settings.hitmarker_hit_headshot_color),
		headshot_crit_color = Color(self.settings.hitmarker_hit_headshot_crit_color)
	}
end	

function AdvancedCrosshair:CrosshairAllowedInState(state_name)
	return state_name and self.STATES_CROSSHAIR_ALLOWED[state_name]
end

function AdvancedCrosshair:UseHitsoundHitPosition()
	return self.settings.use_hitsound_pos
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
--[[

--		local fire_mode = (weaponbase.fire_mode and weaponbase:fire_mode()) or weaponbase.FIRE_MODE


cache.weapon = {
	Unit12345 = { --underbarrels are created as their own unit entry
		name_id = "wa2000",
		panel = Panel,
		firemodes = {
			single = {
				crosshair_id = "ma37",
				panel = Panel,
				parts = {
					Bitmap1,
					Bitmap2,
					Bitmap3,
					Bitmap4,
					Bitmap5
				}
			},
			auto = {
				crosshair_id = "ma37",
				panel = Panel,
				parts = {
					Bitmap1,
					Bitmap2,
					Bitmap3,
					Bitmap4,
					Bitmap5
				},
			}
			burst = {
				crosshair_id = "ma37",
				panel = Panel,
				parts = {
					Bitmap1,
					Bitmap2,
					Bitmap3,
					Bitmap4,
					Bitmap5
				}
			}
		}
	}
}
--]]
	--**********************--
		--init hud items
	--**********************--
--these should only run once, when the player spawns
function AdvancedCrosshair:Init()
	BeardLib:AddUpdater("advancedcrosshairs_update",callback(AdvancedCrosshair,AdvancedCrosshair,"Update"),true)
--	managers.hud:remove_updator("advancedcrosshairs_update")
--	managers.hud:add_updator("advancedcrosshairs_update",callback(AdvancedCrosshair,AdvancedCrosshair,"Update"))
--	managers.hud:add_updator("advc_create_hud_delayed",callback(AdvancedCrosshair,AdvancedCrosshair,"CreateHUD"))
	BeardLib:AddUpdater("advc_create_hud_delayed",callback(AdvancedCrosshair,AdvancedCrosshair,"CreateHUD"))
	if blt.xaudio then
        blt.xaudio.setup()
	end
end

function AdvancedCrosshair:CreateHUD(t,dt) --try to create hud each run until both required elements are initiated.
--...it's not ideal.
	local hud = managers.hud and managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2) --managers.hud._hud_hit_confirm and managers.hud._hud_hit_confirm._hud_panel
	if alive(managers.player:local_player()) and hud and hud.panel then 
		BeardLib:RemoveUpdater("advc_create_hud_delayed")
--		managers.hud:add_updator("advancedcrosshairs_update",callback(AdvancedCrosshair,AdvancedCrosshair,"Update"))
		self:CreateCrosshairPanel(hud.panel)
		self:CreateCrosshairs()
	end
end


--crosshairs
function AdvancedCrosshair:CreateCrosshairPanel(parent_panel)
	if not alive(parent_panel) then 
		self:log("ERROR: CreateCrosshairPanel() No parent HUD found!",{color=Color.red})
		return
	end
	
	if alive(parent_panel:child("advanced_crosshair_panel")) then 
		parent_panel:remove(parent_panel:child("advanced_crosshair_panel"))
	end
	
	local advanced_crosshair_panel = parent_panel:panel({
		name = "advanced_crosshair_panel"
	})
	self._panel = advanced_crosshair_panel
	self._crosshair_panel = advanced_crosshair_panel:panel({
		name = "ach_crosshair_panel",
		layer = 1
	})
	self._hitmarker_panel = advanced_crosshair_panel:panel({
		name = "ach_hitmarker_panel",
		layer = 2
	})
end

function AdvancedCrosshair:CreateCrosshairs()
	local player = managers.player:local_player()
	local inventory = player:inventory()
	local equipped_unit = inventory:equipped_unit()
	for i,selection_data in pairs(inventory:available_selections()) do 
		self:CreateCrosshairByWeapon(selection_data.unit,i)
		if selection_data.unit == equipped_unit then 
			self._cache.current_crosshair_data = self._cache.weapons[tostring(equipped_unit:key())].firemodes[equipped_unit:base():fire_mode()]
		end
	end
	self:CheckCrosshair()
end

function AdvancedCrosshair:RemoveCrosshairByWeapon(unit)
	local unit_key = tostring(unit:key())
	local data = self._cache.weapons[unit_key] 
	if data then 
		if alive(data.panel) then 
			data.panel:parent():remove(data.panel)
			data.panel = nil
		end
	end
	self._cache.weapons[unit_key] = nil
end

function AdvancedCrosshair:CreateCrosshairByWeapon(unit,weapon_index)
	local weapon_base = unit and unit:base()
	if not weapon_base then 
		self:log("ERROR: Bad weapon unit/base to CreateCrosshairByWeapon(" .. tostring(unit) ..")")
		return
	end
	self:RemoveCrosshairByWeapon(unit)
	
	local unit_key = tostring(unit:key())
	local weapon_panel = self._crosshair_panel:panel({
		name = unit_key
	})
	local weapon_id = weapon_base:get_name_id()
	local firemodes_data = {}
	local weapon_category,is_revolver,is_akimbo = self:GetWeaponCategory(weapon_base:categories())
	for _,firemode in pairs(self.VALID_WEAPON_FIREMODES) do
		local crosshair_id = self:GetCrosshairType(weapon_index,weapon_id,weapon_category,firemode,is_revolver,is_akimbo)
		local crosshair_tweakdata = self._crosshair_data[crosshair_id]
		local crosshair_setting = self.settings.crosshairs[weapon_category][firemode]
		crosshair_setting = (self:UseGlobalCrosshair() or not (crosshair_setting and crosshair_setting.overrides_global)) and self.settings.crosshair_global or crosshair_setting or self.DEFAULT_CROSSHAIR_OPTIONS
		local firemode_panel = weapon_panel:panel({
			name = firemode,
			visible = false,
			alpha = crosshair_setting.alpha
		})
		local parts = self:CreateCrosshair(firemode_panel,crosshair_tweakdata)
		firemodes_data[firemode] = {
			base = weapon_base,
			crosshair_id = crosshair_id,
			panel = firemode_panel,
			parts = parts,
--			settings = self.DEFAULT_CROSSHAIR_OPTIONS
			color = Color(crosshair_setting.color),
			settings = crosshair_setting
		}
	end
	
	local underbarrels_data = {}
	local underbarrel_weapons = weapon_base:get_all_override_weapon_gadgets()
	if #underbarrel_weapons > 0 then 
		for underbarrel_index,underbarrel in ipairs(underbarrel_weapons) do 
			local underbarrel_tweakdata = underbarrel._tweak_data
			local underbarrel_id = underbarrel_tweakdata.name_id
			
			local underbarrel_panel = weapon_panel:panel({
				name = "underbarrel_" .. tostring(underbarrel_index),
				visible = true
			})
			underbarrels_data[tostring(underbarrel)] = {
				name = underbarrel_id,
				base = underbarrel,
				panel = underbarrel_panel,
				firemodes = {}
			}
			for _,firemode in pairs(self.VALID_WEAPON_FIREMODES) do
				local underbarrel_category,underbarrel_is_revolver,underbarrel_is_akimbo = self:GetWeaponCategory(underbarrel_tweakdata.categories)
				local underbarrel_crosshair_id = self:GetCrosshairType(nil,underbarrel_id,underbarrel_category,firemode,underbarrel_is_revolver,underbarrel_is_akimbo)
				local crosshair_setting = self.settings.crosshairs[underbarrel_category][firemode]
				crosshair_setting = (self:UseGlobalCrosshair() or not (crosshair_setting and crosshair_setting.overrides_global)) and self.settings.crosshair_global or crosshair_setting or self.DEFAULT_CROSSHAIR_OPTIONS
				local underbarrel_firemode_panel = underbarrel_panel:panel({
					name = firemode,
					visible = false,
					alpha = crosshair_setting.alpha
				})
local _crosshair_data = self._crosshair_data[underbarrel_crosshair_id]
_crosshair_data = _crosshair_data or self._crosshair_data.ma37

				underbarrels_data[tostring(underbarrel)].firemodes[firemode] = { --using a tostring(table) as an index is gross but i gotta
					underbarrel_index = underbarrel_index,
					crosshair_id = underbarrel_crosshair_id,
					base = underbarrel,
					panel = underbarrel_firemode_panel,
					parts = self:CreateCrosshair(underbarrel_firemode_panel,_crosshair_data),
--					settings = self.DEFAULT_CROSSHAIR_OPTIONS
					color = Color(crosshair_setting.color),
					settings = crosshair_setting,
				}
			end
		end
	end
	
	self._cache.weapons[unit_key] = {
		name = weapon_base:get_name_id(),
		base = weapon_base,
		panel = weapon_panel,
		firemodes = firemodes_data,
		underbarrels = underbarrels_data
	}
end

function AdvancedCrosshair:CreateCrosshair(panel,data)
	--if data.special_crosshair then 
	--	do stuff here
	--end
	local results = {}
	for i,part_data in ipairs(data.parts) do 
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

function AdvancedCrosshair:SetCrosshairColor(primary_color) --todo support secondary colors?
	local current_crosshair_data = self:GetCurrentCrosshair()
	local crosshair_data = self._crosshair_data[tostring(current_crosshair_data.crosshair_id)]
	if crosshair_data then 
		if not crosshair_data.special_crosshair then 
			for i=1,#crosshair_data.parts,1 do 
				if not crosshair_data.parts[i].UNRECOLORABLE then 
					local part = current_crosshair_data.parts[i]
					if part then 
						part:set_color(primary_color)
					end
				end
			end
		else
			--todo special crosshair like gl
		end
	end
end

function AdvancedCrosshair:SetCrosshairBloom(bloom)
	local player = managers.player:local_player()

	if player then 
		local current_crosshair_data = self:GetCurrentCrosshair()
		
		local crosshair_data = self._crosshair_data[current_crosshair_data.crosshair_id] or {}
		local data = {bloom = bloom,crosshair_data = crosshair_data,panel_w = current_crosshair_data.panel:w(),panel_h = current_crosshair_data.panel:h()}
		local a = crosshair_data.bloom_func
		
		self:GetCurrentCrosshairParts(a,data)
	end
end

function AdvancedCrosshair:GetCurrentCrosshairParts(func,...)
	local result = {}
	local current_crosshair_data,crosshair_id = self:GetCurrentCrosshair()
	local crosshair_data = self._crosshair_data[tostring(crosshair_id)]
	local crosshair_panel = current_crosshair_data and current_crosshair_data.panel
	if alive(crosshair_panel) and crosshair_data then 
		if not crosshair_data.special_crosshair then 
			for i=1,#crosshair_data.parts,1 do 
				local bitmap = current_crosshair_data.parts[i]
				if bitmap and type(func) == "function" then 
					func(i,bitmap,...)
				end
			end
		else
			--todo
		end
		return current_crosshair_data.parts
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
	return self._cache.current_crosshair_data,self._cache.current_crosshair_data.crosshair_id
end


--hitmarkers

function AdvancedCrosshair:CreateHitmarker(panel,data)
	local results = {}
	for i,part_data in ipairs(data.parts) do 
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
			alpha = part_data.alpha,
			blend_mode = part_data.blend_mode or data.blend_mode,
			color = part_data.color or data.color,
			render_template = part_data.render_template,
			layer = 5 + (part_data.layer or 0)
		})
		if not part_data.skip_center then 
			bitmap:set_center(x + (panel:w()/2),y + (panel:h()/2))
		end
		table.insert(results,i,bitmap)
	end
	return results
end

function AdvancedCrosshair:RemoveHitmarker(num_id)
	if not num_id then return end
	
	for index,hitmarkers_data in pairs(self._cache.hitmarkers) do 
		if hitmarkers_data.num_id == num_id then 
			table.remove(self._cache.hitmarkers,index)
			return true
		end
	end
end

function AdvancedCrosshair:ActivateHitmarker(attack_data)
--unit is just passed because it's called from Message.OnEnemyShot, i don't actually need it
	local attacker_unit = attack_data and attack_data.attacker_unit
	if attacker_unit == managers.player:local_player() then 
		local result = attack_data.result
		local result_type = result and result.type
		local pos = attack_data.pos
		local headshot = attack_data.headshot
		local crit = attack_data.crit --flag indicating crit is added from the mod, not here in vanilla

		local hitmarker_setting = self:GetHitmarkerSettings(result_type)
		
		local hitmarker_id = hitmarker_setting.hitmarker_id
		if not (hitmarker_id and self._hitmarker_data[hitmarker_id]) then
			self:log("ERROR: CreateHitmarker(): Bad hitmarker_id (" .. tostring(hitmarker_id) .. "); Aborting!",{color=Color.red})
			return
		end
		local hitmarker_data = self._hitmarker_data[hitmarker_id]
		
		local color = hitmarker_setting.bodyshot_color
		if headshot and crit then 
			color = hitmarker_setting.headshot_crit_color
		elseif headshot then 
			color = hitmarker_setting.headshot_color
		elseif crit then 
			color = hitmarker_setting.bodyshot_crit_color
		end
		
		local hitmarker_duration = hitmarker_setting.duration
		local hitmarker_alpha = hitmarker_setting.alpha
		
		local num_id = self._cache.num_hitmarkers + 1
		
		local panel = self._hitmarker_panel:panel({
			alpha = (hitmarker_data.alpha or 1) * hitmarker_setting.alpha,
			name = "hitmarker_" .. tostring(num_id)
		})
		if alive(panel) then 
			local parts = self:CreateHitmarker(panel,{
				parts = hitmarker_data.parts,
				color = color,
				blend_mode = self.BLEND_MODES[hitmarker_setting.blend_mode]
			})
			table.insert(self._cache.hitmarkers,#self._cache.hitmarkers + 1,
				{ --this is only used for the "3D hitmarkers" feature
					num_id = num_id,
					panel = panel,
					parts = parts,
					position = attack_data.pos
				}
			)
			local function remove_panel(o)
				o:parent():remove(o)
				self:RemoveHitmarker(num_id)
			end
			
			if hitmarker_data and type(hitmarker_data.hit_func) == "function" then 
				self:animate(panel,"animate_hitmarker_parts",remove_panel,hitmarker_duration,parts,hitmarker_data.hit_func,
					{
						panel = panel,
						result_type = result_type,
						position = pos,
						headshot = headshot,
						crit = crit,
						attack_data = attack_data,
						hitmarker_data = hitmarker_data
					}
				)
			else
				self:animate(panel,"animate_fadeout",remove_panel,hitmarker_duration,hitmarker_alpha,nil,nil)
			end
			self._cache.num_hitmarkers = num_id
		end
		
	end
end

function AdvancedCrosshair:animate_hitmarker_parts(o,t,dt,start_t,duration,parts,hit_func,data)
	for index,bitmap in ipairs(parts) do 
		if not alive(bitmap) then 
			--this usually only happens when game state changes during hitmarker animation
			return true
		end
		hit_func(index,bitmap,data,t,dt,start_t,duration)
	end
	
	if t - start_t >= duration then 
		return true
	end
end


function AdvancedCrosshair:OnEnemyShot(unit,attack_data)
	if self:IsHitmarkerEnabled() then 
		self:ActivateHitmarker(attack_data)
	end
	if self:IsHitsoundEnabled() then 
		AdvancedCrosshair:ActivateHitsound(attack_data,unit)
		--screw your existing argument order, i'm a loose cannon who got nothing to lose and don't play by the rules
	end
end

function AdvancedCrosshair:GetHitsoundData(attack_data)
	local result = attack_data.result
	local result_type = result and result.type
	local headshot = attack_data.headshot
	local crit = attack_data.crit --flag indicating crit is added from the mod, not here in vanilla
	local volume
	local snd_name
	
	if result_type == "death" then
		if headshot and crit then 
			snd_name = self.settings.hitsound_kill_headshot_crit_id
			volume = self.settings.hitsound_kill_headshot_crit_volume
		elseif headshot then
			snd_name = self.settings.hitsound_kill_headshot_id
			volume = self.settings.hitsound_kill_headshot_volume
		elseif crit then 
			snd_name = self.settings.hitsound_kill_bodyshot_crit_id
			volume = self.settings.hitsound_kill_bodyshot_crit_volume
		else
			snd_name = self.settings.hitsound_kill_bodyshot_id
			volume = self.settings.hitsound_kill_bodyshot_volume
		end
	else
		if headshot and crit then 
			snd_name = self.settings.hitsound_hit_headshot_crit_id
			volume = self.settings.hitsound_hit_headshot_crit_volume
		elseif headshot then
			snd_name = self.settings.hitsound_hit_headshot_id
			volume = self.settings.hitsound_hit_headshot_volume
		elseif crit then 
			snd_name = self.settings.hitsound_hit_bodyshot_crit_id
			volume = self.settings.hitsound_hit_bodyshot_crit_volume
		else
			snd_name = self.settings.hitsound_hit_bodyshot_id
			volume = self.settings.hitsound_hit_bodyshot_volume
		end
	end
	
	local snd_data = snd_name and self._hitsound_data[snd_name]
	if not snd_data then 
		return
	end
	
	local snd_path = snd_data.path
	if snd_data.variations then 
		snd_path = snd_data.variations[math.random(#snd_data.variations)] or snd_path
	end
	if (not snd_path) or (snd_path == "") or (snd_path == "none") then 
		return
	end
	
	return snd_path,volume
end

function AdvancedCrosshair:ActivateHitsound(attack_data,unit)
	local snd_path,volume = self:GetHitsoundData(attack_data)
	if snd_path then 
		local snd_path_2,volume_2
		if (not self:ShouldSuppressDoubleSound()) and (attack_data.crit or attack_data.headshot) then 
			snd_path_2,volume_2 = self:GetHitsoundData({
				result = {
					type = attack_data.result and attack_data.result.type or "hurt"
				},
				headshot = false,
				crit = false,
			})
		end
		
		if managers.player:local_player() then 
			if self:UseHitsoundHitPosition() then 
				if unit then 
					XAudio.UnitSource:new(unit, XAudio.Buffer:new(snd_path)):set_volume(volume)
					if snd_path_2 then 
						XAudio.UnitSource:new(unit, XAudio.Buffer:new(snd_path_2)):set_volume(volume_2)
					end
				else
					XAudio.Source:new(XAudio.Buffer:new(snd_path)):set_volume(volume)
					if snd_path_2 then 
						XAudio.UnitSource:new(unit, XAudio.Buffer:new(snd_path_2)):set_volume(volume_2)
					end
				end
			else
				XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path)):set_volume(volume)
				if snd_path_2 then 
					XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path_2)):set_volume(volume_2)
				end
			end
		else
			if snd_path_2 then 
				XAudio.Source:new(XAudio.Buffer:new(snd_path_2)):set_volume(volume_2)
			end
			XAudio.Source:new(XAudio.Buffer:new(snd_path)):set_volume(volume)
		end
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
--ideally, should only be called on certain events, not in update
function AdvancedCrosshair:CheckCrosshair()
	if not self:IsCrosshairEnabled() then 
		return
	end
	local player = managers.player:local_player()
	if player then 
		local state_name = player:movement():current_state_name()
		
		local inventory = player:inventory()
		local equipped_index = inventory:equipped_selection()
		local equipped_unit = inventory:equipped_unit()
		local current_firemode = equipped_unit:base():fire_mode()
		local weapon_base = equipped_unit:base()
		if weapon_base.in_burst_mode and weapon_base:in_burst_mode() then
			current_firemode = "burst"
		end
		
		local new_current_data
		
		local weapon_data = self._cache.weapons[tostring(equipped_unit:key())]
		if not weapon_data then 
			self:log("ERROR! Weapon data for weapon " .. tostring(weapon_base:get_name_id()) .. " in slot " .. tostring(equipped_index) .. " not found! Aborting",{color=Color.red})
			return
		end
		local underbarrel_base = weapon_base:gadget_overrides_weapon_functions()
		if underbarrel_base then 
			local underbarrel = weapon_data.underbarrels[tostring(underbarrel_base)]
			if underbarrel and underbarrel_base and underbarrel_base._tweak_data then
				current_firemode = underbarrel_base._tweak_data.FIRE_MODE
				--currently no other way to get the firemode of an underbarrel, since i don't believe switching firemodes independently of parent weapon is possible?
				
				new_current_data = underbarrel.firemodes[current_firemode]
			end
		end
		new_current_data = new_current_data or weapon_data.firemodes[current_firemode]
		
		if new_current_data and (new_current_data ~= self._cache.current_crosshair_data) then 
			self._cache.current_crosshair_data.panel:hide()
--			self:log("Hiding " .. tostring(self._cache.current_crosshair_data.panel))
			self._cache.current_crosshair_data = new_current_data
--			self:log("Swapped to " .. tostring(new_current_data.base:get_name_id()))
		end
--		self:log("Showing " .. tostring(self._cache.current_crosshair_data.panel))
		self._cache.current_crosshair_data.panel:show()
		
		local state_allowed = self:CrosshairAllowedInState(state_name) 
		if state_allowed ~= nil then 
			self._crosshair_panel:set_visible(state_allowed)
		end
	end
end

function AdvancedCrosshair:AddBloom(amt)
	if true then 
		local weapon = self:GetCurrentCrosshair().base
		local stats = weapon and weapon._current_stats
		local stability = stats and stats.recoil
		if stability then 
			amt = math.max(amt or (0.5 * (24 - stability) / 24) or 0,0)
		else
			amt = amt or 0.3
		end
	else
		amt = amt or 0.3
	end
	self._cache.bloom_t = Application:time()
	self._cache.bloom = math.clamp(self._cache.bloom + amt,0,1)
end

function AdvancedCrosshair:DecayBloom(bloom,t,dt)
	if t - self._cache.bloom_t < self:GetBloomCooldown() then 
		return bloom
	end
	local decay_mul = 2
	return math.clamp(self._cache.bloom - (decay_mul * dt),0,1)
end

function AdvancedCrosshair:Update(t,dt)
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
	

	local player = managers.player:local_player()
	
	--do crosshair
		--if crosshair enabled then 
	local current_crosshair_data = self._cache.current_crosshair_data
	if alive(player) and alive(self._crosshair_panel) and current_crosshair_data then 
		
		local viewport_cam = managers.viewport:get_current_camera()
		if not viewport_cam then 
			return 
		end
		local viewport_cam_pos = managers.viewport:get_current_camera_position()
		local viewport_cam_rot = managers.viewport:get_current_camera_rotation()
		local viewport_cam_fwd = viewport_cam_rot:y()
		local ws = managers.hud._workspace
		
		if not player:inventory():equipped_unit() then 
			--this can happen when restarting the level
			return
		end
		
		
		if self:IsHitmarkerEnabled() then
			if self:UseHitmarkerHitPosition() then 
				for hitmarker_index,hitmarker in pairs(self._cache.hitmarkers) do 
				
					local h_dir = Vector3()
					local h_dir_normalized = Vector3()
					local h_p = ws:world_to_screen(viewport_cam,hitmarker.position)
					--angle check here
					mvector3.set(h_dir, hitmarker.position)
					mvector3.subtract(h_dir, viewport_cam_pos)
					mvector3.set(h_dir_normalized, h_dir)
					mvector3.normalize(h_dir_normalized)
					
					local dot = mvector3.dot(viewport_cam_fwd, h_dir_normalized)
					if alive(hitmarker.panel) then 
						if dot < 0 or hitmarker.panel:outside(mvector3.x(h_p),mvector3.y(h_p)) then 
							hitmarker.panel:hide()
						else
							hitmarker.panel:show()
							hitmarker.panel:set_center(h_p.x,h_p.y)
						end
					end
				end
			end
		end
		
		local state = player:movement():current_state()
		local is_reloading = state:_is_reloading() 
		local fire_forbidden = state:_changing_weapon() or state:_is_meleeing() or state._use_item_expire_t or state:_interacting() or state:_is_throwing_projectile() or state:_is_deploying_bipod() or state._menu_closed_fire_cooldown > 0 or state:is_switching_stances()



		
		--[[
--for special altimeter crosshair
		local player_pos = player:position()
			local cam_aim = viewport_cam:rotation():yaw()
			local cam_rot_a = viewport_cam:rotation():y()

			local compass_yaw = ((cam_aim + 90) / 180) - 1
	--]]

			
			
			
		local fwd_ray = state._fwd_ray	
		local focused_person = fwd_ray and fwd_ray.unit
		local crosshair_color = current_crosshair_data.color
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
			local crosshair_stability = (fwd_ray and fwd_ray.distance or 1000) * self:GetCrosshairStability() --fwd_ray.length
			--theoretically, the raycast position (assuming perfect accuracy) at [crosshair_stability] meters;
			--practically, the higher the number, the less sway shake
			local c_p = ws:world_to_screen(viewport_cam,state:get_fire_weapon_position() + (state:get_fire_weapon_direction() * crosshair_stability))
			local c_w = (c_p.x or 0)
			local c_h = (c_p.y or 0)
			self:SetCrosshairCenter(c_w,c_h)
		end

		--bloom
		if current_crosshair_data.settings.use_bloom then 
--			Console:SetTrackerValue("trackera",tostring(self._cache.bloom))
			if self._cache.bloom > 0 then 
				self._cache.bloom = self:DecayBloom(self._cache.bloom,t,dt)
				self:SetCrosshairBloom(self._cache.bloom)
			end
		end
			
	end
end

function AdvancedCrosshair:GetCrosshairType(slot,weapon_id,category,firemode,is_revolver,is_akimbo)
	local result
	if weapon_id then
		result = self.settings.crosshair_weapon_id_overrides[weapon_id]
	end

--	if slot and not result then --todo override by slot
--		result = self.settings.crosshair_slot_overrides[slot]
--	end

	if not result then 
		if category then 
			if is_akimbo then 
				--todo akimbo check [category .. "_akimbo"]
			end
			if not (self.settings.crosshairs[category] and self.settings.crosshairs[category][firemode]) then 
				self:log("ERROR: GetCrosshairType() Bad category " .. tostring(category) .. "/firemode " .. tostring(firemode))
				return self.DEFAULT_CROSSHAIR_OPTIONS.crosshair_id
			end
			
			local crosshair_setting = self.settings.crosshairs[category][firemode]
			if not crosshair_setting.overrides_global or self:UseGlobalCrosshair() then 
				result = self.settings.crosshair_global.crosshair_id
			else
				result = crosshair_setting.crosshair_id
			end
		end
	end
	if result and self._crosshair_data[result] then
		return result 
	end
	return self.DEFAULT_CROSSHAIR_OPTIONS.crosshair_id
end


--************************************************--
		--I/O
--************************************************--
function AdvancedCrosshair:Save()
	local file = io.open(self.save_data_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function AdvancedCrosshair:Load()
	local file = io.open(self.save_data_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:Save()
	end
end

--************************************************--
		--Menu Creation
--************************************************--

--todo refactor menu tables to allow for organized localization
AdvancedCrosshair.main_menu_id = "ach_menu_main"
AdvancedCrosshair.crosshairs_menu_id = "ach_menu_crosshairs"
AdvancedCrosshair.hitmarkers_menu_id = "ach_menu_hitmarkers"
AdvancedCrosshair.hitsounds_menu_id = "ach_menu_hitsounds"
AdvancedCrosshair.crosshairs_categories_submenu_id = "ach_menu_crosshairs_categories"
AdvancedCrosshair.crosshairs_categories_global_id = "ach_menu_crosshairs_global"
AdvancedCrosshair.customization_menus = {}
AdvancedCrosshair.crosshair_preview_data = nil
--AdvancedCrosshair.customization_menu_callbacks = {}
AdvancedCrosshair.crosshair_id_by_index = {}
AdvancedCrosshair.hitmarker_id_by_index = {}
AdvancedCrosshair.hitsound_id_by_index = {}
Hooks:Add("MenuManagerSetupCustomMenus", "advc_MenuManagerSetupCustomMenus", function(menu_manager, nodes)

	MenuHelper:NewMenu(AdvancedCrosshair.main_menu_id)
	MenuHelper:NewMenu(AdvancedCrosshair.crosshairs_menu_id)
	MenuHelper:NewMenu(AdvancedCrosshair.hitmarkers_menu_id)
	MenuHelper:NewMenu(AdvancedCrosshair.crosshairs_categories_submenu_id)
	MenuHelper:NewMenu(AdvancedCrosshair.crosshairs_categories_global_id)
	for _,cat in ipairs(AdvancedCrosshair.VALID_WEAPON_CATEGORIES) do 
		local cat_menu_name = "ach_crosshair_category_" .. tostring(cat)
		AdvancedCrosshair.customization_menus[cat_menu_name] = {
			category_name = cat,
			child_menus = {}
		}
		MenuHelper:NewMenu(cat_menu_name)
		for _,firemode in ipairs(AdvancedCrosshair.VALID_WEAPON_FIREMODES) do 
			local firemode_menu_name = cat_menu_name .. "_firemode_" .. tostring(firemode)
			AdvancedCrosshair.customization_menus[cat_menu_name].child_menus[firemode_menu_name] = {menu = MenuHelper:NewMenu(firemode_menu_name),firemode = firemode}
		end
	end
	
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "advc_MenuManagerPopulateCustomMenus", function(menu_manager, nodes)

	AdvancedCrosshair:LoadAllAddons() --load custom crosshairs, hitmarkers, and hitsounds

--crosshair/hitmarker selections are saved as string keys to the data in question instead of indices, since the order is not guaranteed
--so generate a number index/string key lookup table for the menu to reference,
--since multiplechoice menus can only use number indices (afaik)

--for crosshairs:
	local items = {}
	local i = 1
	for id,crosshair_data in pairs(AdvancedCrosshair._crosshair_data) do 
		table.insert(items,i,crosshair_data.name_id)
		table.insert(AdvancedCrosshair.crosshair_id_by_index,i,id)
		i = i + 1
	end

--for hitmarkers:
	local hitmarker_kill_bitmap_index = 1
	local hitmarker_hit_bitmap_index = 1
	local hitmarker_items = {}
	local h_i = 1
	for id,hitmarker_data in pairs(AdvancedCrosshair._hitmarker_data) do 
		if id == AdvancedCrosshair.settings.hitmarker_kill_id then
			hitmarker_kill_bitmap_index = h_i
		end
		if id == AdvancedCrosshair.settings.hitmarker_hit_id then 
			hitmarker_hit_bitmap_index = h_i
		end
		table.insert(hitmarker_items,h_i,hitmarker_data.name_id)
		table.insert(AdvancedCrosshair.hitmarker_id_by_index,h_i,id)
		h_i = h_i + 1
	end
	
	local hs_i = 1
	local hitsound_items = {}
	local hitsound_hit_bodyshot_index = 1
	local hitsound_hit_headshot_index = 1
	local hitsound_hit_bodyshot_crit_index = 1
	local hitsound_hit_headshot_crit_index = 1
	local hitsound_kill_headshot_index = 1
	local hitsound_kill_bodyshot_index = 1
	local hitsound_kill_bodyshot_crit_index = 1
	local hitsound_kill_headshot_crit_index = 1
	for id,hitsound_data in pairs(AdvancedCrosshair._hitsound_data) do 
		if id == AdvancedCrosshair.settings.hitsound_hit_bodyshot_id then 
			hitsound_hit_bodyshot_index = hs_i
		end
		if id == AdvancedCrosshair.settings.hitsound_hit_headshot_id then 
			hitsound_hit_headshot_index = hs_i
		end
		if id == AdvancedCrosshair.settings.hitsound_hit_bodyshot_crit_id then 
			hitsound_hit_bodyshot_crit_index = hs_i
		end
		if id == AdvancedCrosshair.settings.hitsound_hit_headshot_crit_id then 
			hitsound_hit_headshot_crit_index = hs_i
		end
		if id == AdvancedCrosshair.settings.hitsound_kill_bodyshot_id then 
			hitsound_kill_bodyshot_index = hs_i
		end
		if id == AdvancedCrosshair.settings.hitsound_kill_headshot_id then 
			hitsound_kill_headshot_index = hs_i
		end
		if id == AdvancedCrosshair.settings.hitsound_kill_bodyshot_crit_id then 
			hitsound_kill_bodyshot_crit_index = hs_i
		end
		if id == AdvancedCrosshair.settings.hitsound_kill_headshot_crit_id then 
			hitsound_kill_headshot_crit_index = hs_i
		end
		table.insert(hitsound_items,hs_i,hitsound_data.name_id)
		table.insert(AdvancedCrosshair.hitsound_id_by_index,hs_i,id)
		hs_i = hs_i + 1
	end
	
--hitmarker menus	
	MenuHelper:AddToggle({
		id = "ach_hitmarkers_master_enable",
		title = "menu_ach_hitmarkers_master_enable_title",
		desc = "menu_ach_hitmarkers_master_enable_desc",
		callback = "callback_ach_hitmarkers_master_enable",
		value = AdvancedCrosshair.settings.hitmarker_enabled,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 25
	})
	MenuHelper:AddToggle({
		id = "ach_hitmarkers_set_3d_enabled",
		title = "menu_ach_hitmarkers_set_3d_enabled_title",
		desc = "menu_ach_hitmarkers_set_3d_enabled_desc",
		callback = "callback_ach_hitmarkers_set_3d_enabled",
		value = AdvancedCrosshair.settings.use_hitpos,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 24
	})
	MenuHelper:AddDivider({
		id = "ach_hitmarkers_div_1",
		size = 16,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 23
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitmarkers_hit_set_bitmap",
		title = "menu_ach_hitmarkers_hit_set_bitmap_title",
		desc = "menu_ach_hitmarkers_hit_set_bitmap_desc",
		callback = "callback_ach_hitmarkers_hit_set_bitmap",
		items = table.deep_map_copy(hitmarker_items),
		value = hitmarker_hit_bitmap_index,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 22
	})
	MenuHelper:AddSlider({
		id = "ach_hitmarkers_hit_set_alpha",
		title = "menu_ach_hitmarkers_hit_set_alpha_title",
		desc = "menu_ach_hitmarkers_hit_set_alpha_desc",
		callback = "callback_ach_hitmarkers_hit_set_alpha",
		value = AdvancedCrosshair.settings.hitmarker_hit_alpha,
		default_value = 1,
		min = 0,
		max = 1,
		step = 0.01,
		show_value = true,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 21
	})
	MenuHelper:AddSlider({
		id = "ach_hitmarkers_hit_set_duration",
		title = "menu_ach_hitmarkers_hit_set_duration_title",
		desc = "menu_ach_hitmarkers_hit_set_duration_desc",
		callback = "callback_ach_hitmarkers_hit_set_duration",
		value = AdvancedCrosshair.settings.hitmarker_hit_duration,
		default_value = 1,
		min = 0,
		max = 3,
		step = 0.25,
		show_value = true,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 20
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitmarkers_hit_set_blend_mode",
		title = "menu_ach_hitmarkers_hit_set_blend_mode_title",
		desc = "menu_ach_hitmarkers_hit_set_blend_mode_desc",
		callback = "callback_ach_hitmarkers_hit_set_blend_mode",
		items = {
			"menu_ach_blend_mode_normal",
			"menu_ach_blend_mode_add",
			"menu_ach_blend_mode_sub",
			"menu_ach_blend_mode_mul"
		},
		value = AdvancedCrosshair.settings.hitmarker_hit_blend_mode,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 19
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_hit_set_bodyshot_color",
		title = "menu_ach_hitmarkers_hit_set_bodyshot_color_title",
		desc = "menu_ach_hitmarkers_hit_set_bodyshot_color_desc",
		callback = "callback_ach_hitmarkers_hit_set_bodyshot_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 18
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_hit_set_bodyshot_crit_color",
		title = "menu_ach_hitmarkers_hit_set_bodyshot_crit_color_title",
		desc = "menu_ach_hitmarkers_hit_set_bodyshot_crit_color_desc",
		callback = "callback_ach_hitmarkers_hit_set_bodyshot_crit_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 17
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_hit_set_headshot_color",
		title = "menu_ach_hitmarkers_hit_set_headshot_color_title",
		desc = "menu_ach_hitmarkers_hit_set_headshot_color_desc",
		callback = "callback_ach_hitmarkers_hit_set_headshot_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 16
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_hit_set_headshot_crit_color",
		title = "menu_ach_hitmarkers_hit_set_headshot_crit_color_title",
		desc = "menu_ach_hitmarkers_hit_set_headshot_crit_color_desc",
		callback = "callback_ach_hitmarkers_hit_set_headshot_crit_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 15
	})
	MenuHelper:AddDivider({
		id = "ach_hitmarkers_div_2",
		size = 8,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 14
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitmarkers_kill_set_bitmap",
		title = "menu_ach_hitmarkers_kill_set_bitmap_title",
		desc = "menu_ach_hitmarkers_kill_set_bitmap_desc",
		callback = "callback_ach_hitmarkers_kill_set_bitmap",
		items = table.deep_map_copy(hitmarker_items),
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		value = hitmarker_kill_bitmap_index,
		priority = 13
	})
	MenuHelper:AddSlider({
		id = "ach_hitmarkers_kill_set_alpha",
		title = "menu_ach_hitmarkers_kill_set_alpha_title",
		desc = "menu_ach_hitmarkers_kill_set_alpha_desc",
		callback = "callback_ach_hitmarkers_kill_set_alpha",
		value = AdvancedCrosshair.settings.hitmarker_kill_alpha,
		default_value = 1,
		min = 0,
		max = 1,
		step = 0.01,
		show_value = true,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 12
	})
	MenuHelper:AddSlider({
		id = "ach_hitmarkers_kill_set_duration",
		title = "menu_ach_hitmarkers_kill_set_duration_title",
		desc = "menu_ach_hitmarkers_kill_set_duration_desc",
		callback = "callback_ach_hitmarkers_kill_set_duration",
		value = AdvancedCrosshair.settings.hitmarker_kill_duration,
		default_value = 1,
		min = 0,
		max = 5,
		step = 0.25,
		show_value = true,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 11
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitmarkers_kill_set_blend_mode",
		title = "menu_ach_hitmarkers_kill_set_blend_mode_title",
		desc = "menu_ach_hitmarkers_kill_set_blend_mode_desc",
		callback = "callback_ach_hitmarkers_kill_set_blend_mode",
		items = {
			"menu_ach_blend_mode_normal",
			"menu_ach_blend_mode_add",
			"menu_ach_blend_mode_sub",
			"menu_ach_blend_mode_mul"
		},
		value = AdvancedCrosshair.settings.hitmarker_kill_blend_mode,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 10
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_kill_set_bodyshot_color",
		title = "menu_ach_hitmarkers_kill_set_bodyshot_color_title",
		desc = "menu_ach_hitmarkers_kill_set_bodyshot_color_desc",
		callback = "callback_ach_hitmarkers_kill_set_bodyshot_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 9
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_kill_set_bodyshot_crit_color",
		title = "menu_ach_hitmarkers_kill_set_bodyshot_crit_color_title",
		desc = "menu_ach_hitmarkers_kill_set_bodyshot_crit_color_desc",
		callback = "callback_ach_hitmarkers_kill_set_bodyshot_crit_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 8
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_kill_set_headshot_color",
		title = "menu_ach_hitmarkers_kill_set_headshot_color_title",
		desc = "menu_ach_hitmarkers_kill_set_headshot_color_desc",
		callback = "callback_ach_hitmarkers_kill_set_headshot_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 7
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_kill_set_headshot_crit_color",
		title = "menu_ach_hitmarkers_kill_set_headshot_crit_color_title",
		desc = "menu_ach_hitmarkers_kill_set_headshot_crit_color_desc",
		callback = "callback_ach_hitmarkers_kill_set_headshot_crit_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 6
	})	
	MenuHelper:AddDivider({
		id = "ach_hitmarkers_div_3",
		size = 8,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 5
	})
	MenuHelper:AddToggle({
		id = "ach_hitmarkers_preview_toggle_headshot",
		title = "menu_ach_hitmarkers_preview_toggle_headshot_title",
		desc = "menu_ach_hitmarkers_preview_toggle_headshot_desc",
		callback = "callback_ach_hitmarkers_preview_toggle_headshot",
		value = false,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 4
	})
	MenuHelper:AddToggle({
		id = "ach_hitmarkers_preview_toggle_crit",
		title = "menu_ach_hitmarkers_preview_toggle_crit_title",
		desc = "menu_ach_hitmarkers_preview_toggle_crit_desc",
		callback = "callback_ach_hitmarkers_preview_toggle_crit",
		value = false,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 3
	})
	MenuHelper:AddToggle({
		id = "ach_hitmarkers_preview_toggle_lethal",
		title = "menu_ach_hitmarkers_preview_toggle_lethal_title",
		desc = "menu_ach_hitmarkers_preview_toggle_lethal_desc",
		callback = "callback_ach_hitmarkers_preview_toggle_lethal",
		value = false,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 2
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_preview_show",
		title = "menu_ach_hitmarkers_preview_show_title",
		desc = "menu_ach_hitmarkers_preview_show_desc",
		callback = "callback_ach_hitmarkers_preview_show",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 1
	})
	
	
	
	
	
	
	--define open preview clbk (not specific to any submenu; shown on interacting with any firemode menu option)
	
	for cat_menu_name,cat_menu_data in pairs(AdvancedCrosshair.customization_menus) do 
		local i = 1 --?
		local category = cat_menu_data.category_name
		
		for firemode_menu_name,firemode_menu_data in pairs(cat_menu_data.child_menus) do 
			local firemode = firemode_menu_data.firemode
			local crosshair_setting = AdvancedCrosshair.settings.crosshairs[category] and AdvancedCrosshair.settings.crosshairs[category][firemode]
			if not crosshair_setting then 
				AdvancedCrosshair:log("FATAL ERROR: Invalid crosshair settings for [category " .. tostring(category) .. " | firemode " .. tostring(firemode) .. "], aborting menu generation",{color=Color.red})
				return 
			end
			
		--define menu callbacks
			
			--set override global settings
			local set_crosshair_override_global_callback_name = firemode_menu_name .. "_set_override_global_enabled"
			MenuCallbackHandler[set_crosshair_override_global_callback_name] = function(self,item)
				crosshair_setting.overrides_global = item:value() == "on"
				
				AdvancedCrosshair:Save()
			end
			
			--set crosshair type
			local set_crosshair_type_callback_name = firemode_menu_name .. "_set_crosshair_type"
			MenuCallbackHandler[set_crosshair_type_callback_name] = function(self,item)
				--multiple choice
				local index = tonumber(item:value())
				local crosshair_id = AdvancedCrosshair.crosshair_id_by_index[index]
				crosshair_setting.crosshair_id = crosshair_id
				AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
				
				AdvancedCrosshair:Save()
			end
			
			--set color
			local set_crosshair_color_callback_name = firemode_menu_name .. "_set_crosshair_color"
			MenuCallbackHandler[set_crosshair_color_callback_name] = function(self)
				AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
				
				if AdvancedCrosshair._colorpicker then
					local function clbk_colorpicker (color,palettes)
						--set preview color here
						local preview_data = AdvancedCrosshair.crosshair_preview_data
						local parent_panel = preview_data and preview_data.panel
						local crosshair_data = preview_data and AdvancedCrosshair._crosshair_data[tostring(preview_data.crosshair_id)]
						if preview_data and crosshair_data and preview_data.parts and alive(parent_panel) then 
							for part_index,part in ipairs(preview_data.parts) do
								if not crosshair_data.parts[part_index].UNRECOLORABLE then 
									part:set_color(color)
								end
							end
						end
						
						--save color to settings
						crosshair_setting.color = color:to_hex()

						--save palette swatches to settings
						if palettes then 
							AdvancedCrosshair:SetPaletteCodes(palettes)
						end
					end
					
					AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(Color(crosshair_setting.color),clbk_colorpicker,clbk_colorpicker)
					
					AdvancedCrosshair:Save()
				elseif not _G.ColorPicker then
					AdvancedCrosshair.clbk_missing_colorpicker_prompt()
				end
			end
			
			--set alpha
			local set_crosshair_alpha_callback_name = firemode_menu_name .. "_set_crosshair_alpha"
			MenuCallbackHandler[set_crosshair_alpha_callback_name] = function(self,item)
				local alpha = tonumber(item:value())
				AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
				local preview_data = AdvancedCrosshair.crosshair_preview_data
				local parent_panel = preview_data and preview_data.panel
				local crosshair_data = preview_data and AdvancedCrosshair._crosshair_data[tostring(preview_data.crosshair_id)]
				if preview_data and crosshair_data and preview_data.parts and alive(parent_panel) then 
					parent_panel:child("crosshair_preview_panel"):set_alpha(alpha)
				end
				crosshair_setting.alpha = alpha
			end
			
			--enable/disable bloom
			local enable_crosshair_bloom_callback_name = firemode_menu_name .. "_set_bloom_enabled"
			MenuCallbackHandler[enable_crosshair_bloom_callback_name] = function(self,item)
				local enabled = item:value() == "on"
				crosshair_setting.use_bloom = enabled
				AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
			end
			
			--preview bloom
			local preview_crosshair_bloom_callback_name = firemode_menu_name .. "_preview_bloom"
			MenuCallbackHandler[preview_crosshair_bloom_callback_name] = function(self)
				AdvancedCrosshair.clbk_bloom_preview(crosshair_setting)
			end
			
			--add menu items
			local crosshair_index = 1
			for _crosshair_index,_crosshair_id in ipairs(AdvancedCrosshair.crosshair_id_by_index) do 
				if _crosshair_id == crosshair_setting.crosshair_id then 
					crosshair_index = _crosshair_index
					break
				end
			end
			
			MenuHelper:AddToggle({
				id = "id_" .. set_crosshair_override_global_callback_name,
				title = "menu_ach_set_override_title",
				desc = "menu_ach_set_override_desc",
				callback = set_crosshair_override_global_callback_name,
				value = crosshair_setting.overrides_global,
				menu_id = firemode_menu_name,
				priority = 8
			})
			
			MenuHelper:AddMultipleChoice({
				id = "id_" .. set_crosshair_type_callback_name,
				title = "menu_ach_set_bitmap_title",
				desc = "menu_ach_set_bitmap_desc",
				callback = set_crosshair_type_callback_name,
				items = items,
				value = crosshair_index,
				menu_id = firemode_menu_name,
				priority = 7
			})
			
			MenuHelper:AddButton({
				id = "id_" .. set_crosshair_color_callback_name,
				title = "menu_ach_set_color_title",
				desc = "menu_ach_set_color_desc",
				callback = set_crosshair_color_callback_name,
				menu_id = firemode_menu_name,
				priority = 6
			})
			
			MenuHelper:AddSlider({
				id = "id_" .. set_crosshair_alpha_callback_name,
				title = "menu_ach_set_alpha_title",
				desc = "menu_ach_set_alpha_desc",
				callback = set_crosshair_alpha_callback_name,
				value = crosshair_setting.alpha,
				min = 0,
				max = 1,
				step = 0.05,
				show_value = true,
				menu_id = firemode_menu_name,
				priority = 5
			})
			
			MenuHelper:AddToggle({
				id = "id_" .. enable_crosshair_bloom_callback_name,
				title = "menu_ach_set_bloom_enabled_title",
				desc = "menu_ach_set_bloom_enabled_desc",
				callback = enable_crosshair_bloom_callback_name,
				value = crosshair_setting.use_bloom,
				menu_id = firemode_menu_name,
				priority = 4
			})
			
			MenuHelper:AddDivider({
				id = "divider_1_" .. firemode_menu_name,
				size = 24,
				menu_id = firemode_menu_name,
				priority = 3
			})
			
			MenuHelper:AddButton({
				id = "id_" .. preview_crosshair_bloom_callback_name,
				title = "menu_ach_preview_bloom_title",
				desc = "menu_ach_preview_bloom_desc",
				callback = preview_crosshair_bloom_callback_name,
				menu_id = firemode_menu_name,
				priority = 2
			})
		end
		
		local global_crosshair_index = 1
		for _crosshair_index,_crosshair_id in ipairs(AdvancedCrosshair.crosshair_id_by_index) do 
			if _crosshair_id == AdvancedCrosshair.settings.crosshair_global.crosshair_id then 
				global_crosshair_index = _crosshair_index
				break
			end
		end
	end
	
	MenuHelper:AddMultipleChoice({
		id = "id_ach_menu_crosshairs_categories_global_type",
		title = "menu_ach_set_bitmap_title",
		desc = "menu_ach_set_bitmap_desc",
		callback = "callback_ach_crosshairs_categories_global_type",
		items = table.deep_map_copy(items),
		value = global_crosshair_index,
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		priority = 6
	})
	MenuHelper:AddButton({
		id = "id_ach_menu_crosshairs_categories_global_color",
		title = "menu_ach_set_color_title",
		desc = "menu_ach_set_color_desc",
		callback = "callback_ach_crosshairs_categories_global_color",
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		priority = 5
	})
	
	MenuHelper:AddSlider({
		id = "id_ach_menu_crosshairs_categories_global_alpha",
		title = "menu_ach_set_alpha_title",
		desc = "menu_ach_set_alpha_desc",
		callback = "callback_ach_crosshairs_categories_global_alpha",
		value = AdvancedCrosshair.settings.crosshair_global.alpha,
		min = 0,
		max = 1,
		step = 0.05,
		show_value = true,
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		priority = 4
	})
	
	MenuHelper:AddToggle({
		id = "id_ach_menu_crosshairs_categories_global_set_bloom_enabled",
		title = "menu_ach_set_bloom_enabled_title",
		desc = "menu_ach_set_bloom_enabled_desc",
		callback = "callback_ach_crosshairs_categories_global_bloom_enabled",
		value = AdvancedCrosshair.settings.crosshair_global.use_bloom,
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		priority = 3
	})
	
	MenuHelper:AddDivider({
		id = "divider_1_ach_menu_crosshairs_categories_global",
		size = 24,
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		priority = 2
	})
	
	MenuHelper:AddButton({
		id = "id_ach_menu_crosshairs_categories_global_preview_bloom",
		title = "menu_ach_preview_bloom_title",
		desc = "menu_ach_preview_bloom_desc",
		callback = "callback_ach_crosshairs_categories_global_preview_bloom",
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		priority = 1
	})
	
	
	MenuHelper:AddDivider({
		id = "ach_crosshairs_general_divider_1",
		size = 16,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 8
	})
	MenuHelper:AddToggle({
		id = "ach_crosshairs_general_master_enable",
		title = "menu_ach_crosshairs_general_master_enable_title",
		desc = "menu_ach_crosshairs_general_master_enable_desc",
		callback = "callback_ach_crosshairs_general_master_enable",
		value = AdvancedCrosshair.settings.crosshair_enabled,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 7
	})
	MenuHelper:AddToggle({
		id = "ach_crosshairs_general_enable_shake",
		title = "menu_ach_crosshairs_general_enable_shake_title",
		desc = "menu_ach_crosshairs_general_enable_shake_desc",
		callback = "callback_ach_crosshairs_general_enable_shake",
		value = AdvancedCrosshair.settings.use_shake,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 6
	})
	MenuHelper:AddToggle({
		id = "ach_crosshairs_general_enable_dynamic_color",
		title = "menu_ach_crosshairs_general_enable_dynamic_color_title",
		desc = "menu_ach_crosshairs_general_enable_dynamic_color_desc",
		callback = "callback_ach_crosshairs_general_enable_dynamic_color",
		value = AdvancedCrosshair.settings.use_color,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 5
	})
	MenuHelper:AddButton({
		id = "ach_crosshairs_general_set_dynamic_color_enemy",
		title = "menu_ach_crosshairs_general_set_dynamic_color_enemy_title",
		desc = "menu_ach_crosshairs_general_set_dynamic_color_enemy_desc",
		callback = "callback_ach_crosshairs_general_set_dynamic_color_enemy",
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 4
	})
	MenuHelper:AddButton({
		id = "ach_crosshairs_general_set_dynamic_color_civilian",
		title = "menu_ach_crosshairs_general_set_dynamic_color_civilian_title",
		desc = "menu_ach_crosshairs_general_set_dynamic_color_civilian_desc",
		callback = "callback_ach_crosshairs_general_set_dynamic_color_civilian",
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 3
	})
	MenuHelper:AddButton({
		id = "ach_crosshairs_general_set_dynamic_color_teammate",
		title = "menu_ach_crosshairs_general_set_dynamic_color_teammate_title",
		desc = "menu_ach_crosshairs_general_set_dynamic_color_teammate_desc",
		callback = "callback_ach_crosshairs_general_set_dynamic_color_teammate",
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 2
	})
	MenuHelper:AddButton({
		id = "ach_crosshairs_general_set_dynamic_color_misc",
		title = "menu_ach_crosshairs_general_set_dynamic_color_misc_title",
		desc = "menu_ach_crosshairs_general_set_dynamic_color_misc_desc",
		callback = "callback_ach_crosshairs_general_set_dynamic_color_misc",
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 1
	})
	
	
	--hitsounds	
	
	MenuHelper:AddToggle({
		id = "ach_hitsounds_master_enable",
		title = "menu_ach_hitsounds_master_enable_title",
		desc = "menu_ach_hitsounds_master_enable_desc",
		callback = "callback_ach_hitsounds_master_enable",
		value = AdvancedCrosshair.settings.hitsound_enabled,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 10
	})
	
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_hit_bodyshot_type",
		title = "menu_ach_hitsounds_set_hit_bodyshot_type_title",
		desc = "menu_ach_hitsounds_set_hit_bodyshot_type_desc",
		callback = "callback_ach_hitsounds_set_hit_bodyshot_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_hit_bodyshot_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 9
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_hit_headshot_type",
		title = "menu_ach_hitsounds_set_hit_headshot_type_title",
		desc = "menu_ach_hitsounds_set_hit_headshot_type_desc",
		callback = "callback_ach_hitsounds_set_hit_headshot_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_hit_headshot_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 8
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_hit_bodyshot_crit_type",
		title = "menu_ach_hitsounds_set_hit_bodyshot_crit_type_title",
		desc = "menu_ach_hitsounds_set_hit_bodyshot_crit_type_desc",
		callback = "callback_ach_hitsounds_set_hit_bodyshot_crit_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_hit_bodyshot_crit_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 7
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_hit_headshot_crit_type",
		title = "menu_ach_hitsounds_set_hit_headshot_crit_type_title",
		desc = "menu_ach_hitsounds_set_hit_headshot_crit_type_desc",
		callback = "callback_ach_hitsounds_set_hit_headshot_crit_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_hit_headshot_crit_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 6
	})
	MenuHelper:AddDivider({
		id = "ach_hitsounds_divider_1",
		size = 16,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 5
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_kill_bodyshot_type",
		title = "menu_ach_hitsounds_set_kill_bodyshot_type_title",
		desc = "menu_ach_hitsounds_set_kill_bodyshot_type_desc",
		callback = "callback_ach_hitsounds_set_kill_bodyshot_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_kill_bodyshot_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 4
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_kill_headshot_type",
		title = "menu_ach_hitsounds_set_kill_headshot_type_title",
		desc = "menu_ach_hitsounds_set_kill_headshot_type_desc",
		callback = "callback_ach_hitsounds_set_kill_headshot_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_kill_headshot_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 3
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_kill_bodyshot_crit_type",
		title = "menu_ach_hitsounds_set_kill_bodyshot_crit_type_title",
		desc = "menu_ach_hitsounds_set_kill_bodyshot_crit_type_desc",
		callback = "callback_ach_hitsounds_set_kill_bodyshot_crit_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_kill_bodyshot_crit_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 2
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_kill_headshot_crit_type",
		title = "menu_ach_hitsounds_set_kill_headshot_crit_type_title",
		desc = "menu_ach_hitsounds_set_kill_headshot_crit_type_desc",
		callback = "callback_ach_hitsounds_set_kill_headshot_crit_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_kill_headshot_crit_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 1
	})
end)

Hooks:Add("MenuManagerBuildCustomMenus", "ach_MenuManagerBuildCustomMenus", function( menu_manager, nodes )
--	local blt_options_menu = MenuHelper:GetMenu("blt_options")
--	local lm = managers.localization
	local crosshairs_menu = MenuHelper:GetMenu(AdvancedCrosshair.crosshairs_menu_id)
	nodes[AdvancedCrosshair.main_menu_id] = MenuHelper:BuildMenu(
		AdvancedCrosshair.main_menu_id,{
			area_bg = "none",
			back_callback = "callback_ach_main_close",
			focus_changed_callback = "callback_ach_main_focus"
		}
	)
--	MenuHelper:AddMenuItem(blt_options_menu,AdvancedCrosshair.main_menu_id,"menu_ach_hitmarkers_menu_main_title","menu_ach_hitmarkers_menu_main_desc")
	
--	nodes[AdvancedCrosshair.
	
	
	nodes[AdvancedCrosshair.crosshairs_categories_global_id] = MenuHelper:BuildMenu(AdvancedCrosshair.crosshairs_categories_global_id,{back_callback = MenuCallbackHandler.callback_ach_crosshairs_categories_global_close,focus_changed_callback = "callback_ach_crosshairs_categories_global_focus"})
	MenuHelper:AddMenuItem(crosshairs_menu,AdvancedCrosshair.crosshairs_categories_global_id,"menu_ach_crosshairs_global_menu_title","menu_ach_crosshairs_global_menu_desc",2)
	MenuHelper:AddMenuItem(crosshairs_menu,AdvancedCrosshair.crosshairs_categories_submenu_id,"menu_ach_crosshairs_categories_menu_title","menu_ach_crosshairs_categories_menu_desc",1)
	for cat_menu_name,cat_menu_data in pairs(AdvancedCrosshair.customization_menus) do 
		local cat_menu = MenuHelper:GetMenu(cat_menu_name)
		
		local cat_name_id = "menu_weapon_category_" .. tostring(cat_menu_data.category_name)
		local cat_name_desc = "menu_ach_change_crosshair_weapon_category_desc"
		local i = 1
		for firemode_menu_name,firemode_menu in pairs(cat_menu_data.child_menus) do
			local firemode = tostring(firemode_menu.firemode)
			local name_id = "menu_weapon_firemode_" .. firemode
			local desc_id = cat_name_id
			nodes[firemode_menu_name] = MenuHelper:BuildMenu(firemode_menu_name,{area_bg = "none",back_callback = MenuCallbackHandler.callback_ach_crosshairs_close,focus_changed_callback = "callback_ach_crosshairs_focus"})
			MenuHelper:AddMenuItem(cat_menu,firemode_menu_name,name_id,desc_id,i) --add each firemode menu to its weaponcategory parent menu
			i = i + 1
		end
		nodes[cat_menu_name] = MenuHelper:BuildMenu(cat_menu_name,{area_bg = "half",back_callback = MenuCallbackHandler.callback_ach_hitmarkers_close,focus_changed_callback = "callback_ach_hitmarkers_focus"})
		nodes[AdvancedCrosshair.crosshairs_categories_submenu_id] = MenuHelper:BuildMenu(AdvancedCrosshair.crosshairs_categories_submenu_id,{back_callback = MenuCallbackHandler.callback_ach_crosshairs_categories_close,focus_changed_callback = "callback_ach_crosshairs_categories_focus"})
		MenuHelper:AddMenuItem(MenuHelper:GetMenu(AdvancedCrosshair.crosshairs_categories_submenu_id),cat_menu_name,cat_name_id,cat_name_desc)
	end
end)

Hooks:Add("MenuManagerInitialize", "advc_initmenu", function(menu_manager)
	MenuCallbackHandler.callback_ach_main_close = function(self)
		log("Close mainmenu")
		AdvancedCrosshair.clbk_refresh_crosshairs()
	end
	
	MenuCallbackHandler.callback_ach_main_focus = function(self,item)
	--nonfunctional
		log("Changed main focus")
	end
	
	
	--**************** crosshairs options ****************
	
	
	MenuCallbackHandler.callback_ach_crosshairs_close = function(self)
		log("Close ch") --functional
		AdvancedCrosshair:Save()
		AdvancedCrosshair.clbk_remove_crosshair_preview()
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_close = function(self)
		log("Ch cat close")
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_focus = function(self)
		log("Changed ch cat focus")
	end
	MenuCallbackHandler.callback_ach_crosshairs_focus = function(self,item)
		--todo check for if any options were actually changed before recreating?
		if item == false then 
			if game_state_machine:verify_game_state(GameStateFilters.any_ingame) and managers.player and alive(managers.player:local_player()) then
				AdvancedCrosshair:CreateCrosshairs()
	--			AdvancedCrosshair.clbk_create_crosshair_preview()
			end
		end
		log("changed ch focus " .. tostring(item))
	end
	
	MenuCallbackHandler.callback_ach_crosshairs_general_master_enable = function(self,item)
		AdvancedCrosshair.settings.crosshair_enabled = item:value() == "on"
		if alive (AdvancedCrosshair._crosshair_panel) then 
			AdvancedCrosshair._crosshair_panel:hide()
		end
	end
	
	MenuCallbackHandler.callback_ach_crosshairs_general_enable_shake = function(self,item)
		AdvancedCrosshair.settings.use_shake = item:value() == "on"
		if alive(AdvancedCrosshair._crosshair_panel) then 
			AdvancedCrosshair:SetCrosshairCenter(AdvancedCrosshair._panel:center())
			AdvancedCrosshair:CheckCrosshair()
		end
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_enable_dynamic_color = function(self,item)
		AdvancedCrosshair.settings.use_color = item:value() == "on"
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_set_dynamic_color_enemy = function(self)
		local crosshair_setting = AdvancedCrosshair.settings.crosshair_global
		
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
		
		if AdvancedCrosshair._colorpicker then
			local function clbk_colorpicker (color,palettes,success)
				--set preview color here
				local preview_data = AdvancedCrosshair.crosshair_preview_data
				local parent_panel = preview_data and preview_data.panel
				local crosshair_data = preview_data and AdvancedCrosshair._crosshair_data[tostring(preview_data.crosshair_id)]
				if preview_data and crosshair_data and preview_data.parts and alive(parent_panel) then 
					for part_index,part in ipairs(preview_data.parts) do
						if not crosshair_data.parts[part_index].UNRECOLORABLE then 
							part:set_color(color)
						end
					end
				end
				
				--save color to settings
				if success then 
					AdvancedCrosshair.settings.crosshair_enemy_color = color:to_hex()
				end
				--save palette swatches to settings
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(Color(AdvancedCrosshair.settings.crosshair_enemy_color),clbk_colorpicker,clbk_colorpicker)
			
			AdvancedCrosshair:Save()
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end	
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_set_dynamic_color_civilian = function(self)
			local crosshair_setting = AdvancedCrosshair.settings.crosshair_global
		
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
		
		if AdvancedCrosshair._colorpicker then
			local function clbk_colorpicker (color,palettes,success)
				--set preview color here
				local preview_data = AdvancedCrosshair.crosshair_preview_data
				local parent_panel = preview_data and preview_data.panel
				local crosshair_data = preview_data and AdvancedCrosshair._crosshair_data[tostring(preview_data.crosshair_id)]
				if preview_data and crosshair_data and preview_data.parts and alive(parent_panel) then 
					for part_index,part in ipairs(preview_data.parts) do
						if not crosshair_data.parts[part_index].UNRECOLORABLE then 
							part:set_color(color)
						end
					end
				end
				
				--save color to settings
				if success then 
					AdvancedCrosshair.settings.crosshair_civilian_color = color:to_hex()
				end
				--save palette swatches to settings
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(Color(AdvancedCrosshair.settings.crosshair_civilian_color),clbk_colorpicker,clbk_colorpicker)
			
			AdvancedCrosshair:Save()
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end	
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_set_dynamic_color_teammate = function(self)
		local crosshair_setting = AdvancedCrosshair.settings.crosshair_global
		
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
		
		if AdvancedCrosshair._colorpicker then
			local function clbk_colorpicker (color,palettes,success)
				--set preview color here
				local preview_data = AdvancedCrosshair.crosshair_preview_data
				local parent_panel = preview_data and preview_data.panel
				local crosshair_data = preview_data and AdvancedCrosshair._crosshair_data[tostring(preview_data.crosshair_id)]
				if preview_data and crosshair_data and preview_data.parts and alive(parent_panel) then 
					for part_index,part in ipairs(preview_data.parts) do
						if not crosshair_data.parts[part_index].UNRECOLORABLE then 
							part:set_color(color)
						end
					end
				end
				
				--save color to settings
				if success then 
					AdvancedCrosshair.settings.crosshair_teammate_color = color:to_hex()
				end
				--save palette swatches to settings
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(Color(AdvancedCrosshair.settings.crosshair_teammate_color),clbk_colorpicker,clbk_colorpicker)
			
			AdvancedCrosshair:Save()
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end	
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_set_dynamic_color_misc = function(self)
		local crosshair_setting = AdvancedCrosshair.settings.crosshair_global
		
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
		
		if AdvancedCrosshair._colorpicker then
			local function clbk_colorpicker (color,palettes,success)
				--set preview color here
				local preview_data = AdvancedCrosshair.crosshair_preview_data
				local parent_panel = preview_data and preview_data.panel
				local crosshair_data = preview_data and AdvancedCrosshair._crosshair_data[tostring(preview_data.crosshair_id)]
				if preview_data and crosshair_data and preview_data.parts and alive(parent_panel) then 
					for part_index,part in ipairs(preview_data.parts) do
						if not crosshair_data.parts[part_index].UNRECOLORABLE then 
							part:set_color(color)
						end
					end
				end
				
				--save color to settings
				if success then 
					AdvancedCrosshair.settings.crosshair_misc_color = color:to_hex()
				end
				--save palette swatches to settings
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(Color(AdvancedCrosshair.settings.crosshair_misc_color),clbk_colorpicker,clbk_colorpicker)
			
			AdvancedCrosshair:Save()
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end	
	end
	
	MenuCallbackHandler.callback_ach_menu_crosshairs_categories_global_enable_override = function(self,item)
		AdvancedCrosshair.settings.crosshair_all_override = item:value() == "on"
		
	end
	
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_type = function(self,item)
		local index = tonumber(item:value())
		local crosshair_id = AdvancedCrosshair.crosshair_id_by_index[index]
		AdvancedCrosshair.settings.crosshair_global.crosshair_id = crosshair_id
		--don't check for existing preview data; rebuild bitmap on crosshair type change clbk
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		AdvancedCrosshair:Save()
		log("Saved global type " .. tostring(crosshair_id))
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_color = function(self,item)
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		
		if AdvancedCrosshair._colorpicker then
			local crosshair_setting = AdvancedCrosshair.settings.crosshair_global

			local function clbk_colorpicker (color,palettes)
				--set preview color here
				local preview_data = AdvancedCrosshair.crosshair_preview_data
				local parent_panel = preview_data and preview_data.panel
				local crosshair_data = preview_data and AdvancedCrosshair._crosshair_data[tostring(preview_data.crosshair_id)]
				if preview_data and crosshair_data and preview_data.parts and alive(parent_panel) then 
					for part_index,part in ipairs(preview_data.parts) do
						if not crosshair_data.parts[part_index].UNRECOLORABLE then 
							part:set_color(color)
						end
					end
				end
				
				--save color to settings
				crosshair_setting.color = color:to_hex()

				--save palette swatches to settings
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(Color(crosshair_setting.color),clbk_colorpicker,clbk_colorpicker)
			
			AdvancedCrosshair:Save()
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_alpha = function(self,item)
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		AdvancedCrosshair.settings.crosshair_global.alpha = tonumber(item:value())
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_bloom_enabled = function(self,item)
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		AdvancedCrosshair.settings.crosshair_global.use_bloom = item:value() == "on"
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_preview_bloom = function(self)
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		AdvancedCrosshair.clbk_bloom_preview(AdvancedCrosshair.settings.crosshair_global)
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_close = function(self)
		log("ch global close")
		AdvancedCrosshair.clbk_remove_crosshair_preview()
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_focus = function(self,active)
		if active then
			AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		end
		log("ch global focus change")
		
	end
	
	
	
	
	
	
	
	
	--**************** hitmarkers options ****************
	
	MenuCallbackHandler.callback_ach_hitmarkers_focus = function(self,is_focused)
		log("Changed hm focus")
		local fullscreen_ws = managers.menu_component and managers.menu_component._fullscreen_ws
		if alive(fullscreen_ws) then 
			local menupanel = fullscreen_ws:panel()
			
			if alive(menupanel:child("ach_preview")) then 
				menupanel:child("ach_preview"):set_visible(is_focused)
			end
		end
		if is_focused == true then 
			AdvancedCrosshair.clbk_hitmarker_preview({
				headshot = AdvancedCrosshair.hitmarker_preview_data.headshot,
				crit = AdvancedCrosshair.hitmarker_preview_data.crit,
				result_type = AdvancedCrosshair.hitmarker_preview_data.result_type
			})
		end
	end
	
	
	
	local hitmarker_preview_is_headshot	= true
	local hitmarker_preview_is_crit = true
	local hitmarker_preview_is_lethal = true
	MenuCallbackHandler.callback_ach_hitmarkers_close = function(self)
		log("Close hm")
		--remove preview here
		AdvancedCrosshair:Save()
	end
	
	MenuCallbackHandler.callback_ach_hitmarkers_master_enable = function(self,item)
		AdvancedCrosshair.settings.hitmarker_enabled = item:value() == "on"
	end
	MenuCallbackHandler.callback_ach_hitmarkers_set_3d_enabled = function(self,item)
		AdvancedCrosshair.settings.use_hitpos = item:value() == "on"
	end
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_bitmap = function(self,item)
		AdvancedCrosshair.settings.hitmarker_hit_id = AdvancedCrosshair.hitmarker_id_by_index[tonumber(item:value())]
	end
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_duration = function(self,item)
		AdvancedCrosshair.settings.hitmarker_hit_duration = tonumber(item:value())
	end
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_alpha = function(self,item)
		AdvancedCrosshair.settings.hitmarker_hit_alpha = tonumber(item:value())
	end
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_blend_mode = function(self,item)
		AdvancedCrosshair.settings.hitmarker_hit_blend_mode = tonumber(item:value())
	end
	
	
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_bodyshot_color = function(self)
		if AdvancedCrosshair._colorpicker then 
			local function changed_cb(color,palettes,success)
				AdvancedCrosshair.clbk_hitmarker_preview({
					headshot = AdvancedCrosshair.hitmarker_preview_data.headshot,
					crit = AdvancedCrosshair.hitmarker_preview_data.crit,
					result_type = AdvancedCrosshair.hitmarker_preview_data.result_type,
					preview_color_override = color
				})
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
				if success then 
					AdvancedCrosshair.settings.hitmarker_hit_bodyshot_color = color:to_hex()
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(AdvancedCrosshair:GetHitmarkerSettings("hit").bodyshot_color,changed_cb,changed_cb)
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end
	end
	
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_bodyshot_crit_color = function(self)
		if AdvancedCrosshair._colorpicker then 
			local function changed_cb(color,palettes,success)
				AdvancedCrosshair.clbk_hitmarker_preview({
					headshot = AdvancedCrosshair.hitmarker_preview_data.headshot,
					crit = AdvancedCrosshair.hitmarker_preview_data.crit,
					result_type = AdvancedCrosshair.hitmarker_preview_data.result_type,
					preview_color_override = color
				})
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
				if success then 
					AdvancedCrosshair.settings.hitmarker_hit_bodyshot_crit_color = color:to_hex()
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(AdvancedCrosshair:GetHitmarkerSettings("hit").bodyshot_crit_color,changed_cb,changed_cb)
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end
	end
	
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_headshot_color = function(self)
		if AdvancedCrosshair._colorpicker then 
			local function changed_cb(color,palettes,success)
				AdvancedCrosshair.clbk_hitmarker_preview({
					headshot = AdvancedCrosshair.hitmarker_preview_data.headshot,
					crit = AdvancedCrosshair.hitmarker_preview_data.crit,
					result_type = AdvancedCrosshair.hitmarker_preview_data.result_type,
					preview_color_override = color
				})
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
				if success then 
					AdvancedCrosshair.settings.hitmarker_hit_headshot_color = color:to_hex()
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(AdvancedCrosshair:GetHitmarkerSettings("hit").headshot_color,changed_cb,changed_cb)
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end
	end
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_headshot_crit_color = function(self)
		if AdvancedCrosshair._colorpicker then 
			local function changed_cb(color,palettes,success)
				AdvancedCrosshair.clbk_hitmarker_preview({
					headshot = AdvancedCrosshair.hitmarker_preview_data.headshot,
					crit = AdvancedCrosshair.hitmarker_preview_data.crit,
					result_type = AdvancedCrosshair.hitmarker_preview_data.result_type,
					preview_color_override = color
				})
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
				if success then 
					AdvancedCrosshair.settings.hitmarker_hit_headshot_crit_color = color:to_hex()
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(AdvancedCrosshair:GetHitmarkerSettings("hit").headshot_crit_color,changed_cb,changed_cb)
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end
	end
	
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_bitmap = function(self,item)
		AdvancedCrosshair.settings.hitmarker_kill_id = AdvancedCrosshair.hitmarker_id_by_index[tonumber(item:value())]
	end
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_duration = function(self,item)
		AdvancedCrosshair.settings.hitmarker_kill_duration = tonumber(item:value())
	end
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_alpha = function(self,item)
		AdvancedCrosshair.settings.hitmarker_kill_alpha = tonumber(item:value())
	end
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_blend_mode = function(self,item)
		AdvancedCrosshair.settings.hitmarker_kill_blend_mode = tonumber(item:value())
	end
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_bodyshot_color = function(self)
		if AdvancedCrosshair._colorpicker then 
			local function changed_cb(color,palettes,success)
				AdvancedCrosshair.clbk_hitmarker_preview({
					headshot = AdvancedCrosshair.hitmarker_preview_data.headshot,
					crit = AdvancedCrosshair.hitmarker_preview_data.crit,
					result_type = AdvancedCrosshair.hitmarker_preview_data.result_type,
					preview_color_override = color
				})
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
				if success then 
					AdvancedCrosshair.settings.hitmarker_kill_bodyshot_color = color:to_hex()
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(AdvancedCrosshair:GetHitmarkerSettings("kill").bodyshot_color,changed_cb,changed_cb)
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end
	end
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_bodyshot_crit_color = function(self)
		if AdvancedCrosshair._colorpicker then 
			local function changed_cb(color,palettes,success)
				AdvancedCrosshair.clbk_hitmarker_preview({
					headshot = AdvancedCrosshair.hitmarker_preview_data.headshot,
					crit = AdvancedCrosshair.hitmarker_preview_data.crit,
					result_type = AdvancedCrosshair.hitmarker_preview_data.result_type,
					preview_color_override = color
				})
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
				if success then 
					AdvancedCrosshair.settings.hitmarker_kill_bodyshot_crit_color = color:to_hex()
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(AdvancedCrosshair:GetHitmarkerSettings("kill").bodyshot_crit_color,changed_cb,changed_cb)
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end
	end
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_headshot_color = function(self)
		if AdvancedCrosshair._colorpicker then 
			local function changed_cb(color,palettes,success)
				AdvancedCrosshair.clbk_hitmarker_preview({
					headshot = AdvancedCrosshair.hitmarker_preview_data.headshot,
					crit = AdvancedCrosshair.hitmarker_preview_data.crit,
					result_type = AdvancedCrosshair.hitmarker_preview_data.result_type,
					preview_color_override = color
				})
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
				if success then 
					AdvancedCrosshair.settings.hitmarker_kill_headshot_color = color:to_hex()
				end
			end
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(AdvancedCrosshair:GetHitmarkerSettings("kill").headshot_color,changed_cb,changed_cb)
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end
	end
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_headshot_crit_color = function(self)
		if AdvancedCrosshair._colorpicker then 
			local function changed_cb(color,palettes,success)
				AdvancedCrosshair.clbk_hitmarker_preview({
					headshot = AdvancedCrosshair.hitmarker_preview_data.headshot,
					crit = AdvancedCrosshair.hitmarker_preview_data.crit,
					result_type = AdvancedCrosshair.hitmarker_preview_data.result_type,
					preview_color_override = color
				})
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
				if success then 
					AdvancedCrosshair.settings.hitmarker_kill_headshot_crit_color = color:to_hex()
				end
			end
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(AdvancedCrosshair:GetHitmarkerSettings("kill").headshot_crit_color,changed_cb,changed_cb)
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end
	end
	
	MenuCallbackHandler.callback_ach_hitmarkers_preview_toggle_headshot = function(self,item)
		AdvancedCrosshair.hitmarker_preview_data.headshot = item:value() == "on"
	end
	MenuCallbackHandler.callback_ach_hitmarkers_preview_toggle_crit = function(self,item)
		AdvancedCrosshair.hitmarker_preview_data.crit = item:value() == "on"
	end
	MenuCallbackHandler.callback_ach_hitmarkers_preview_toggle_lethal = function(self,item)
		AdvancedCrosshair.hitmarker_preview_data.result_type = ((item:value() == "on") and "death") or "hurt"
	end
	MenuCallbackHandler.callback_ach_hitmarkers_preview_show = function(self)
		AdvancedCrosshair.clbk_hitmarker_preview({
			headshot = AdvancedCrosshair.hitmarker_preview_data.headshot,
			crit = AdvancedCrosshair.hitmarker_preview_data.crit,
			result_type = AdvancedCrosshair.hitmarker_preview_data.result_type
		})
	end
	
	
	--hitsounds
	MenuCallbackHandler.callback_ach_hitsounds_close = function(self)
		
	end
	
	MenuCallbackHandler.callback_ach_hitsounds_focus = function(self)
		
	end
	MenuCallbackHandler.callback_ach_hitsounds_master_enable = function(self,item)
		AdvancedCrosshair.settings.hitsound_enabled = item:value() == "on"
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_hit_bodyshot_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_hit_bodyshot_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		if not Application:paused() then 
			AdvancedCrosshair:ActivateHitsound({
				result = {
					type = "hurt"
				},
				headshot = false,
				crit = false
			})
		end
	end
	
	MenuCallbackHandler.callback_ach_hitsounds_set_hit_headshot_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_hit_headshot_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]	
			
		if not Application:paused() then 
			AdvancedCrosshair:ActivateHitsound({
				result = {
					type = "hurt"
				},
				headshot = true,
				crit = false
			})
		end
	end
	
	MenuCallbackHandler.callback_ach_hitsounds_set_hit_bodyshot_crit_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_hit_bodyshot_crit_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]	
		if not Application:paused() then 
			AdvancedCrosshair:ActivateHitsound({
				result = {
					type = "hurt"
				},
				headshot = false,
				crit = true
			})
		end
	end
	
	MenuCallbackHandler.callback_ach_hitsounds_set_hit_headshot_crit_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_hit_headshot_crit_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		if not Application:paused() then 
			AdvancedCrosshair:ActivateHitsound({
				result = {
					type = "hurt"
				},
				headshot = true,
				crit = true
			})
		end
	end
	
	MenuCallbackHandler.callback_ach_hitsounds_set_kill_bodyshot_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_kill_bodyshot_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		if not Application:paused() then 
			AdvancedCrosshair:ActivateHitsound({
				result = {
					type = "death"
				},
				headshot = false,
				crit = false
			})
		end
	end
	
	MenuCallbackHandler.callback_ach_hitsounds_set_kill_headshot_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_kill_headshot_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		if not Application:paused() then 
			AdvancedCrosshair:ActivateHitsound({
				result = {
					type = "death"
				},
				headshot = true,
				crit = false
			})
		end
	end
	
	MenuCallbackHandler.callback_ach_hitsounds_set_kill_bodyshot_crit_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_kill_bodyshot_crit_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		if not Application:paused() then 
			AdvancedCrosshair:ActivateHitsound({
				result = {
					type = "death"
				},
				headshot = false,
				crit = true
			})
		end
	end
	
	MenuCallbackHandler.callback_ach_hitsounds_set_kill_headshot_crit_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_kill_headshot_crit_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		if not Application:paused() then 
			AdvancedCrosshair:ActivateHitsound({
				result = {
					type = "death"
				},
				headshot = true,
				crit = true
			})
		end
	end
	
	
	--creates colorpicker menu for AdvancedCrosshair mod; this menu is reused for all color-related callbacks in this mod,
	--so it's also necessary to also update the callback whenever calling the menu
	AdvancedCrosshair._colorpicker = AdvancedCrosshair._colorpicker or (ColorPicker and ColorPicker:new("advancedcrosshairs",{},callback(AdvancedCrosshair,AdvancedCrosshair,"set_colorpicker_menu")))

	
	MenuHelper:LoadFromJsonFile(AdvancedCrosshair.path .. "menu/menu_main.json", AdvancedCrosshair, AdvancedCrosshair.settings)
	MenuHelper:LoadFromJsonFile(AdvancedCrosshair.path .. "menu/menu_crosshairs.json", AdvancedCrosshair, AdvancedCrosshair.settings)
	MenuHelper:LoadFromJsonFile(AdvancedCrosshair.path .. "menu/menu_hitmarkers.json", AdvancedCrosshair, AdvancedCrosshair.settings)
	MenuHelper:LoadFromJsonFile(AdvancedCrosshair.path .. "menu/menu_hitsounds.json", AdvancedCrosshair, AdvancedCrosshair.settings)
end)



--these callback functions all related to menus
--i was planning to pass them directly as menu callbacks, but apparently 
--focus_changed_callback can only be the string-type name/key to the function inside menucallbackhandler itself, 
--not a function type

AdvancedCrosshair.hitmarker_preview_data = {
	headshot = false,
	crit = false,
	result_type = "hurt"
}
function AdvancedCrosshair.clbk_hitmarker_preview(preview_data)
	local fullscreen_ws = managers.menu_component and managers.menu_component._fullscreen_ws
	if alive(fullscreen_ws) then 
		local headshot = preview_data.headshot
		local crit = preview_data.crit
	
		local menupanel = fullscreen_ws:panel()
		local preview_panel = menupanel:child("ach_preview")
		if not alive(preview_panel) then 
			preview_panel = menupanel:panel({
				name = "ach_preview"
			})
			local screenshot_bg = preview_panel:bitmap({
				name = "screenshot_bg",
				color = Color(0.7,0.7,0.7),
				layer = -101,
				w = 200,
				h = 200,
				texture = "guis/textures/pd2/mission_briefing/assets/assets_risklevel_4",
				texture_rect = {
					450,532,260,260
				}
			})
			screenshot_bg:set_center(preview_panel:center())
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
			local preview_label = preview_panel:text({
				name = "preview_label",
				text = managers.localization:text("menu_ach_preview_label_title"),
				layer = 2,
				align = "center",
				y = blur_bg:top() + 4,
				font = tweak_data.hud.medium_font,
				font_size = 16,
				color = Color.white,
				alpha = 0.5
			})
			
		end

		local hitmarker_setting = AdvancedCrosshair:GetHitmarkerSettings(preview_data.result_type)
		local hitmarker_id = hitmarker_setting.hitmarker_id
		if not (hitmarker_id and AdvancedCrosshair._hitmarker_data[hitmarker_id]) then
			AdvancedCrosshair:log("ERROR: clbk_hitmarker_preview(): Bad hitmarker_id (" .. tostring(hitmarker_id) .. "); Aborting!",{color=Color.red})
			return
		end
		local hitmarker_data = AdvancedCrosshair._hitmarker_data[hitmarker_id]
		
		local color = hitmarker_setting.bodyshot_color
		if preview_data.preview_color_override then 
			color = preview_data.preview_color_override
		elseif headshot and crit then 
			color = hitmarker_setting.headshot_crit_color
		elseif headshot then 
			color = hitmarker_setting.headshot_color
		elseif crit then 
			color = hitmarker_setting.bodyshot_crit_color
		end
		
		local hitmarker_duration = hitmarker_setting.duration
		local hitmarker_alpha = hitmarker_setting.alpha

		local panel = preview_panel:panel({
			alpha = (hitmarker_data.alpha or 1) * hitmarker_setting.alpha,
			name = "hitmarker_preview"
		})
		if alive(panel) then 
			local parts = AdvancedCrosshair:CreateHitmarker(panel,{
				parts = hitmarker_data.parts,
				color = color,
				blend_mode = AdvancedCrosshair.BLEND_MODES[hitmarker_setting.blend_mode]
			})
			
			local function remove_panel(o)
				o:parent():remove(o)
			end
			
			if hitmarker_data and type(hitmarker_data.hit_func) == "function" then 
				AdvancedCrosshair:animate(panel,"animate_hitmarker_parts",remove_panel,hitmarker_duration,parts,hitmarker_data.hit_func,
					{
						panel = panel,
						result_type = preview_data.result_type,
						position = pos,
						headshot = headshot,
						crit = crit,
						attack_data = nil,
						hitmarker_data = hitmarker_data
					}
				)
			else
				AdvancedCrosshair:animate(panel,"animate_fadeout",remove_panel,hitmarker_duration,hitmarker_alpha,nil,nil)
			end
		end
	end

end

function AdvancedCrosshair.clbk_refresh_crosshairs() -- not used
	--apply changes from settings to existing crosshairs
	--todo
	--[[
	
		for _,weapon_unit in pairs(inventory:available_selections()) do
			create_weapon(weapon_unit)
		end
	--]]
end

function AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(color,changed_callback,done_callback)
	AdvancedCrosshair._colorpicker:Show({color = color,changed_callback = changed_callback,done_callback = done_callback,palettes = AdvancedCrosshair:GetPaletteColors(),blur_bg_x = 750})
end

function AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
	local crosshair_id = crosshair_setting.crosshair_id
--		BeardLib:RemoveUpdater("ach_preview_bloom")
	local fullscreen_ws = managers.menu_component and managers.menu_component._fullscreen_ws
	if alive(fullscreen_ws) then 
		local menupanel = fullscreen_ws:panel()
		
		local crosshair_data = AdvancedCrosshair._crosshair_data[crosshair_id] or AdvancedCrosshair._crosshair_data[AdvancedCrosshair.DEFAULT_CROSSHAIR_OPTIONS.crosshair_id]
		if alive(menupanel:child("ach_preview")) then 
			menupanel:remove(menupanel:child("ach_preview"))
		end
		local preview_panel = menupanel:panel({
			name = "ach_preview"
		})
		local screenshot_bg = preview_panel:bitmap({
			name = "screenshot_bg",
			color = Color(0.7,0.7,0.7),
			layer = -101,
			w = 200,
			h = 200,
			texture = "guis/textures/pd2/mission_briefing/assets/assets_risklevel_4",
			texture_rect = {
				450,532,260,260
			}
		})
		screenshot_bg:set_center(preview_panel:center())
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
		local preview_label = preview_panel:text({
			name = "preview_label",
			text = managers.localization:text("menu_ach_preview_label_title"),
			layer = 2,
			align = "center",
			y = blur_bg:top() + 4,
			font = tweak_data.hud.medium_font,
			font_size = 16,
			color = Color.white,
			alpha = 0.5
		})
		local crosshair_preview_panel = preview_panel:panel({
			name = "crosshair_preview_panel",
			layer = 1,
			alpha = crosshair_setting.alpha
		})
		AdvancedCrosshair.crosshair_preview_data = {
			panel = preview_panel,
			parts = AdvancedCrosshair:CreateCrosshair(crosshair_preview_panel,crosshair_data),
			crosshair_id = crosshair_id,
			bloom = 0
		}
		
		--set color here
		for part_index,part in ipairs(AdvancedCrosshair.crosshair_preview_data.parts) do 
			if not crosshair_data.parts[part_index].UNRECOLORABLE then
				part:set_color(Color:from_hex(crosshair_setting.color))
			end
		end
		
	end
	return AdvancedCrosshair.crosshair_preview_data
end

function AdvancedCrosshair.clbk_remove_crosshair_preview()
	BeardLib:RemoveUpdater("ach_preview_bloom")
	if AdvancedCrosshair.crosshair_preview_data then
		local panel = AdvancedCrosshair.crosshair_preview_data.panel
		if alive(panel) then
			panel:parent():remove(panel)
		end
	end
	AdvancedCrosshair.crosshair_preview_data = nil
end

function AdvancedCrosshair.clbk_bloom_preview(crosshair_setting)
	AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
	local preview_data = AdvancedCrosshair.crosshair_preview_data
	local parent_panel = preview_data and preview_data.panel
	local crosshair_data = preview_data and AdvancedCrosshair._crosshair_data[tostring(preview_data.crosshair_id)]
	if preview_data and crosshair_data and preview_data.parts and alive(parent_panel) and type(crosshair_data.bloom_func) == "function" then 
		preview_data.bloom = preview_data.bloom + 0.5 --todo
		BeardLib:AddUpdater("ach_preview_bloom", --needs to use beardlib updater since managers.hud isn't initialized in the main menu
			function(t,dt)
				if not (crosshair_data and preview_data.parts and alive(parent_panel) and type(crosshair_data.bloom_func) == "function") then 
					BeardLib:RemoveUpdater("ach_preview_bloom")
					return
				else
					preview_data.bloom = AdvancedCrosshair:DecayBloom(preview_data.bloom,t,dt)
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

function AdvancedCrosshair.clbk_missing_colorpicker_prompt()
	QuickMenu:new(managers.localization:text("menu_ach_prompt_missing_colorpicker_title"),string.gsub(managers.localization:text("menu_ach_prompt_missing_colorpicker_desc"),"$URL",AdvancedCrosshair.url_colorpicker),{
		text = managers.localization:text("menu_ach_prompt_ok")
	},true)
end

AdvancedCrosshair:Init()
AdvancedCrosshair:Load()

--make addons folders
local addons_path_saves = AdvancedCrosshair.save_path .. "ACH Addons/"
for i,path in ipairs({
	addons_path_saves,
	addons_path_saves .. "Crosshairs/",
	addons_path_saves .. "Hitmarkers/",
	addons_path_saves .. "Hitsounds/"
}) do 
	local addon_path = Application:nice_path(path,true)
	if not SystemFS:exists(addon_path,true) then 
		SystemFS:make_dir(addon_path)
		if i == 1 then
			
			local file = io.open(addon_path .. "README.txt","w+")
			if file then
				--this is executed on startup, before localizationmanager is loaded
				local readme = string.gsub(AdvancedCrosshair.addons_readme_txt,"$LINK",AdvancedCrosshair.url_ach_github)
				file:write(readme)
				file:flush()
				file:close()
			end
		end
	end
end