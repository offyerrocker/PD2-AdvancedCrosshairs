		--todo list, loosely sorted by descending priority:

-- option to allow hitsounds for sentries
-- more hitsound options 
	--separate option for sentries/non-player damage
	-- crits
	-- melee


-- override by slot (needs menu options)
-- override by weapon id (needs menu options)
	-- ranc_heavy_machine_gun 

--migrate the more obscure options to "Advanced Settings" menus

--selection parity for hitmarkers



--"force check validity" button to manually call CheckSaveDataForDeprecatedValues()

--fadeout for tf2 crit

-- the division crosshairs?

--hide crosshair when interacting/when weapon is not available (chk action forbidden in playerstandard)

--"trickle-down" options, eg "unchanged" inherit global setting (requires conversion from most option types to multiple choice, or else the addition of a toggle checkbox to enable global override any given option)

--bug znix about pitch hitsounds with set_velocity() (currently does nothing from what testing i've done)
	-- choice of pitch shift based on:
	--damage
	--enemy health remaining
	--and up or down

--screen blend mode 
--save hitsound preview and stop others when new hitsound is selected
--sanity check hitsounds on load addons
--get mod_overrides path to support addons in mod_overrides?

-- add more example crosshairs

-- better workaround for copmelee + integrate suppressdoublesound to cop melee damage

-- hitmarker data overrides for some settings such as force worldposition hitmarkers

-- halo reach head aim crosshair dot
-- import special halo reach crosshair + add option to pass relevant data to all crosshairs
-- bloom delay/add values per crosshair

--toggle hitmarker scaling with world distance at world position?

-- hide character + bg menu like how blt mods menu does (and fails to restore after hitting back lol)




--shortcuts to some commonly mvector3/mrot library functions for performance reasons
local mvector3_set = mvector3.set
local mvector3_subtract = mvector3.subtract
local mvector3_normalize = mvector3.normalize
local mvector3_dot = mvector3.dot
local mvector3_x = mvector3.x
local mvector3_y = mvector3.y


--************************************************--
		--init mod data
--************************************************--
_G.AdvancedCrosshair = {}
--AdvancedCrosshair._animate_targets = {}
AdvancedCrosshair._panel = nil
AdvancedCrosshair._hitmarker_panel = nil
AdvancedCrosshair._crosshair_panel = nil

AdvancedCrosshair.url_colorpicker = "https://modworkshop.net/mod/29641"
AdvancedCrosshair.url_ach_github = "https://github.com/offyerrocker/PD2-AdvancedCrosshairs"
AdvancedCrosshair.url_ach_mws = "https://modworkshop.net/mod/29585"

AdvancedCrosshair.addon_xml_file_name = "mod.xml"
AdvancedCrosshair.addon_lua_file_name = "addon.lua"
AdvancedCrosshair.addons_readme_txt = "README - generated from AdvancedCrosshair v2 - \n\nThis directory is where you can install add-on folders for Crosshairs, Hitmarkers, or Hitsounds.\nThese must be folders, no archives or files- .texture, .zip, .7zip, .tar, etc. will not be read!\nTo install add-ons, place the add-on folder(s) in one of the three subfolders according to the type of add-on- NOT directly in the same folder as this file.\n\nPlease refer to the documentation for more information: \n$LINK\n\nP.S. You can safely delete this readme file if you wish. It will only be re-generated on launch if ACH is installed and the ACH Addons folder is removed.\nHave a nice day!"

AdvancedCrosshair.CLEAN_SOUNDS_THRESHOLD = 15 -- when this many or greater total sound sources (open or closed) are present in cache, clean the cache of any dead/closed sound sources on hitsound event
AdvancedCrosshair.HITMARKER_RAIN_SPAWN_DELAY_INTERVAL_MIN = 0.01 --seconds
AdvancedCrosshair.HITMARKER_RAIN_SPAWN_DELAY_INTERVAL_MAX = 0.1 --seconds
AdvancedCrosshair.HITMARKER_RAIN_TRAVEL_DURATION_MAX = 1 --seconds
AdvancedCrosshair.HITMARKER_RAIN_TRAVEL_DURATION_MIN = 0.25 --seconds
AdvancedCrosshair.HITMARKER_RAIN_COUNT_MIN = 48
AdvancedCrosshair.HITMARKER_RAIN_COUNT_MAX = 64
AdvancedCrosshair.HITMARKER_RAIN_PROC_CHANCE = 0.01 --chance to proc hitmarker rain on any kill
AdvancedCrosshair.HITMARKER_RAIN_TEXT_FLASH_SPEED = 600

--color and alpha are disabled because they don't work so well with bloom/hitmarker animations etc
AdvancedCrosshair.OUTOFRANGE_DISPLAY_MODES = {
	crosshair = {
		disabled = 1,
		size = 2,
		color = 3,
		alpha = 4
	},
	hitmarker = {
		disabled = 1,
		size = 2,
		color = 3,
		alpha = 4
	}
}
--todo menu options for these
AdvancedCrosshair.OUTOFRANGE_CROSSHAIR_SCALE = 0.66
AdvancedCrosshair.OUTOFRANGE_HITMARKER_SCALE = 0.66
AdvancedCrosshair.OUTOFRANGE_CROSSHAIR_ALPHA = 0.33
AdvancedCrosshair.OUTOFRANGE_HITMARKER_ALPHA = 0.33
AdvancedCrosshair.OUTOFRANGE_CROSSHAIR_COLOR = Color(0.3,0.3,0.3)
AdvancedCrosshair.OUTOFRANGE_HITMARKER_COLOR = Color(0.3,0.3,0.3)
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

AdvancedCrosshair.CROSSHAIR_BLOOM_STATE_VALUES = {
	BLOOM_SPEED = 3,
	STEELSIGHT_ADD = -0.15,
	
	WALKING_AIR_MAX = 1, --cap on the penalty from this state
	WALKING_STANDARD_MAX = 0.66,
	WALKING_CROUCH_MAX = 0.2,
	RUNNING_AIR_MAX = 1.33,
	RUNNING_STANDARD_MAX = 1,
	STATION_STANDARD_MAX = 0,
	STATION_CROUCH_MAX = -0.1,
	ZIPLINING_STANDARD_MAX = 2
}

AdvancedCrosshair.BLEND_MODES = { --for getting the blend mode from the number index returned by menu setting callback
	"normal",
	"add",
	"sub",
	"mul"
--	"screen" --doesn't appear to be implemented as a valid blend_mode
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

--akimbo compatibility, by duplicating all weapon categories as akimbos
for i=#AdvancedCrosshair.VALID_WEAPON_CATEGORIES,1,-1 do 
	local category = AdvancedCrosshair.VALID_WEAPON_CATEGORIES[i]
	table.insert(AdvancedCrosshair.VALID_WEAPON_CATEGORIES,#AdvancedCrosshair.VALID_WEAPON_CATEGORIES + 1,"akimbo_" .. category)
end

AdvancedCrosshair.VALID_WEAPON_FIREMODES = {
	"single",
	"auto",
	"burst",
	"volley"
}
--revolver and akimbo are subtypes; akimbo is checked but revolver is ignored

AdvancedCrosshair.DEFAULT_CROSSHAIR_OPTIONS = {
	crosshair_id = "pdth_classic",
	use_bloom = true,
	color = "ffffff",
	alpha = 1,
	overrides_global = false,
	--hide_on_ads = false, --added in v2, deprecated in v21
	ads_behavior = 1, --1: no special behavior. 2: hide on ads. 3: only show on ads. added in v21
	scale = 1
}
AdvancedCrosshair.DEFAULT_HITMARKER_OPTIONS = {
	hitmarker_id = "generic_hit",
	hitmarker_kill_id = "destiny_kill",
	hitmarker_hit_id = "vanilla",
	use_animate = true,
	default_color = "eeeeee",
	headshot_color = "ff0000",
	crit_color = "0000ff",
	headcrit_color = "ff00ff"
}

--session-based settings checker
AdvancedCrosshair.auto_compatibility_settings = {}

--init default settings values
--these are later overwritten by values read from save data, if present
AdvancedCrosshair.default_settings = {
	ach_save_version = 4,
	--[[
		this is the save version, not to be confused with the mod version. this is here to identify which save version the mod was created with/
			[version lookup]
			ACH version	range	:	save version (reason for change)
						<19		: 	nil/0
						19-20	:	1
						21-25	:	2	(Hide on ADS behavior change)
						26-		:	3	(U228, Volley firemode)
						
	--]]
	logs_enabled = false,
	crosshair_enabled = true,
	hitmarker_enabled = true,
	hitsound_enabled = false,
	easter_eggs_enabled = true, --enables hitmarker rain (currently the only easter egg)
	assets_always_loaded_enabled = false,
	compatibility_auto_detection = true,
	compatibility_hook_playermanager_checkskill = false,
	compatibility_hook_playerstandard_onsteelsight = false, --deprecated in v33
	compatibility_hook_playerstandard_startactionequipweapon = false, --deprecated in v33
	compatibility_hook_playermovementstate_enter = false, --deprecated in v33
	compatibility_hook_copdamage_damagemelee = false,
	compatibility_hook_copdamage_rollcriticalhit = false,
	compatibility_hook_newraycastweaponbase_togglefiremode = false, --deprecated in v33
	compatibility_hook_newraycastweaponbase_resetcachedgadget = false, --deprecated in v33
	can_check_melee_headshots = false,
	allow_messages = 1, -- (unused) 1: yes; 2: yes but no compatibility messages; 3: do not. none. never. get out of my house. die.
	palettes = { --for colorpicker
		"ff0000",
		"ffff00",
		"00ff00",
		"00ffff",
		"0000ff",
		"880000",
		"888800",
		"008800",
		"008888",
		"000088",
		"ff8800",
		"88ff00",
		"00ff88",
		"0088ff",
		"8800ff",
		"884400",
		"448800",
		"008844",
		"004488",
		"440088",
		"ffffff",
		"bbbbbb",
		"888888",
		"444444",
		"000000"
	},
	use_shake = false,
	use_color = true,
	use_hitpos = true,
	use_hitsound_pos = false,
	use_movement_bloom = true,
	crosshair_outofrange_mode = 1,
	crosshair_all_override = false,
	crosshair_stability = 1,
	crosshair_enemy_color = "e11a1a",
	crosshair_civilian_color = "7ff77f",
	crosshair_teammate_color = "0171ff",
	crosshair_misc_color = "f51b83",
	crosshair_global = table.deep_map_copy(AdvancedCrosshair.DEFAULT_CROSSHAIR_OPTIONS),
	crosshairs = {},
	crosshair_hide_while_interacting = false,
	crosshair_hide_while_meleeing = false,
	crosshair_hide_while_grenading = false,
	crosshair_hide_while_reloading = false,
	crosshair_hide_while_running = false,
	crosshair_hide_while_inspecting = false,
	crosshair_hide_while_hitmarker = false,
	crosshair_weapon_id_overrides = { --no menu yet
	--EG:
--		deagle = {
--			crosshair_id = "pdth_classic",
--			use_bloom = true,
--			color = "ffffff",
--			alpha = 0.9,
--			overrides_global = true
--		}
	},
	crosshair_slot_overrides = { --no menu yet/not implemented
	--EG:
--		1 = { --overrides all primary slots
--			crosshair_id = "pdth_classic",
--			use_bloom = true,
--			color = "ffffff",
--			alpha = 0.5,
--			overrides_global = true
--		}
	},
	hitmarker_allow_melee = true,
	hitmarker_outofrange_mode = 2,
	hitmarker_max_count = 5,
	hitmarker_limit_behavior = 1,
	hitmarker_hit_id = "destiny_hit",
	hitmarker_hit_duration = 0.4,
	hitmarker_hit_alpha = 1,
	hitmarker_hit_scale = 1,
	hitmarker_hit_blend_mode = 1,
	hitmarker_hit_bodyshot_color = "ffffff",
	hitmarker_hit_bodyshot_crit_color = "00ffff",
	hitmarker_hit_headshot_color = "ff0000",
	hitmarker_hit_headshot_crit_color = "ff00ff",
	hitmarker_kill_id = "destiny_kill",
	hitmarker_kill_duration = 0.4,
	hitmarker_kill_alpha = 1,
	hitmarker_kill_scale = 1,
	hitmarker_kill_blend_mode = 1, --normal
	hitmarker_kill_bodyshot_color = "ffffff",
	hitmarker_kill_bodyshot_crit_color = "00ffff",
	hitmarker_kill_headshot_color = "ff0000",
	hitmarker_kill_headshot_crit_color = "ff00ff",
	hitsound_allow_melee = true,
	hitsound_limit_behavior = 1,
	hitsound_max_count = 1,
	hitsound_hit_bodyshot_id = "tf2_hit",
	hitsound_hit_headshot_id = "tf2_hit",
	hitsound_hit_bodyshot_crit_id = "tf2_crit",
	hitsound_hit_headshot_crit_id = "tf2_crit",
	hitsound_kill_headshot_id = "tf2_hit",
	hitsound_kill_bodyshot_id = "tf2_hit",
	hitsound_kill_bodyshot_crit_id = "tf2_crit",
	hitsound_kill_headshot_crit_id = "tf2_crit",
	hitsound_hit_bodyshot_volume = 0.5,
	hitsound_hit_headshot_volume = 0.5,
	hitsound_hit_bodyshot_crit_volume = 0.5,
	hitsound_hit_headshot_crit_volume = 0.5,
	hitsound_kill_headshot_volume = 0.5,
	hitsound_kill_bodyshot_volume = 0.5,
	hitsound_kill_bodyshot_crit_volume = 0.5,
	hitsound_kill_headshot_crit_volume = 0.5,
	hitsound_suppress_doublesound = true
}

AdvancedCrosshair.setting_categories = {
	crosshair = {
		"crosshairs",
		"crosshair_global",
		"crosshair_weapon_id_overrides",
		"crosshair_slot_overrides",
		"use_shake",
		"use_color"
	},
	hitmarker = {
		"use_hitpos",
		"hitmarker_limit_behavior",
		"hitmarker_max_count",
		"hitmarker_hit_id",
		"hitmarker_hit_duration",
		"hitmarker_hit_alpha",
		"hitmarker_hit_blend_mode",
		"hitmarker_hit_bodyshot_color",
		"hitmarker_hit_bodyshot_crit_color",
		"hitmarker_hit_headshot_color",
		"hitmarker_hit_headshot_crit_color",
		"hitmarker_kill_id",
		"hitmarker_kill_duration",
		"hitmarker_kill_alpha",
		"hitmarker_kill_blend_mode",
		"hitmarker_kill_bodyshot_color",
		"hitmarker_kill_bodyshot_crit_color",
		"hitmarker_kill_headshot_color"
	},
	hitmarker_ids = {
		"hitmarker_hit_id",
		"hitmarker_kill_id"
	},
	hitsound_ids = {
		"hitsound_hit_bodyshot_id",
		"hitsound_hit_headshot_id",
		"hitsound_hit_bodyshot_crit_id",
		"hitsound_hit_headshot_crit_id",
		"hitsound_kill_headshot_id",
		"hitsound_kill_bodyshot_id",
		"hitsound_kill_bodyshot_crit_id",
		"hitsound_kill_headshot_crit_id"
	},
	hitsound = {
		"use_hitsound_pos",
		"hitsound_limit_behavior",
		"hitsound_max_count",
		"hitsound_hit_bodyshot_id",
		"hitsound_hit_headshot_id",
		"hitsound_hit_bodyshot_crit_id",
		"hitsound_hit_headshot_crit_id",
		"hitsound_kill_headshot_id",
		"hitsound_kill_bodyshot_id",
		"hitsound_kill_bodyshot_crit_id",
		"hitsound_kill_headshot_crit_id",
		"hitsound_hit_bodyshot_volume",
		"hitsound_hit_headshot_volume",
		"hitsound_hit_bodyshot_crit_volume",
		"hitsound_hit_headshot_crit_volume",
		"hitsound_kill_headshot_volume",
		"hitsound_kill_bodyshot_volume",
		"hitsound_kill_bodyshot_crit_volume",
		"hitsound_kill_headshot_crit_volume",
		"hitsound_suppress_doublesound"
	},
	palettes = {
		"palettes"
	}
}

--init settings for every variation of weapon + firemode (even for combinations that don't exist in-game)
for _,cat in pairs(AdvancedCrosshair.VALID_WEAPON_CATEGORIES) do 
	AdvancedCrosshair.default_settings.crosshairs[cat] = {}
	for _,firemode in pairs(AdvancedCrosshair.VALID_WEAPON_FIREMODES) do 
		AdvancedCrosshair.default_settings.crosshairs[cat][firemode] = table.deep_map_copy(AdvancedCrosshair.DEFAULT_CROSSHAIR_OPTIONS)
	end
end

AdvancedCrosshair.settings = table.deep_map_copy(AdvancedCrosshair.default_settings)

AdvancedCrosshair.path = ModPath
AdvancedCrosshair.assets_path = AdvancedCrosshair.path .. "assets/"
AdvancedCrosshair.hitsound_path = AdvancedCrosshair.assets_path .. "snd/hitsounds/"
AdvancedCrosshair.save_path = SavePath
AdvancedCrosshair.save_data_path = AdvancedCrosshair.save_path .. "AdvancedCrosshair.txt"
AdvancedCrosshair.TEXTURE_PATH = "guis/textures/advanced_crosshairs/" --this is the internal asset path that is prefixed to addons' assets
AdvancedCrosshair.mod_overrides_path = "PAYDAY 2/assets/mod_overrides/"

--init QuickAnimate util
dofile(AdvancedCrosshair.path .. "classes/QuickAnimate.lua")
AdvancedCrosshair.animator = QuickAnimate:new("ACH_Animator",{parent = AdvancedCrosshair,updater_type = QuickAnimate.updater_types.BeardLib,paused = true})

AdvancedCrosshair.ALLOWED_SOUND_EXTENSIONS = {
	ogg = true
}
AdvancedCrosshair.ALLOWED_TEXTURE_EXTENSIONS = {
	texture = true,
	png = true
}

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
	weapons = {},
	stance_bloom = 0, --bloom from moving, tracked separately from normal bloom
	bloom = 0,
	bloom_t = -69,
	hitmarkers = {},
	num_hitmarkers = 0,
	sound_sources = {},
	is_in_steelsight = false, --only set/used when compatibility mode for "playerstandard on steelsight" is enabled
	HITMARKER_RAIN_ENABLED = nil, -- bool; if true, allow easter egg where hitmarkers have a chance to "rain" down from the top of the screen on kill, and flash "MOM GET THE CAMERA" on screen
	_hitmarker_rain_count_remaining = nil, -- int; number of rain hitmarkers left to spawn
	_next_hitmarker_rain_t = nil -- float; time delay to next rain hitmarker spawn
}

--do not change this. refer to the github wiki if you want to add custom crosshairs to this mod (see above for the link)
AdvancedCrosshair._crosshair_data = {
	none = {
		name_id = "menu_crosshair_none",
		parts = {
			{
				texture = "",
				alpha = 0,
				UNRECOLORABLE = true
			}
		}
	}
}

AdvancedCrosshair._hitmarker_data = {}

AdvancedCrosshair._default_crosshairs = {
	pdth_classic = {
		name_id = "menu_crosshair_pdth_classic",
		bloom_func = function(index,bitmap,data)
			local crosshair_data = data.crosshair_data
			local bloom = data.bloom * (crosshair_data.bloom_mul or 1)
			local part_data = crosshair_data.parts[index] or {}
			local angle = part_data.angle or 60
			local c_x = data.panel_w/2
			local c_y = data.panel_h/2
			local scale = (data.scale or 1) * (part_data.scale or 1)
			local distance = scale * part_data.distance * (bloom + 1)
			bitmap:set_center(c_x + (math.sin(angle) * distance),c_y - (math.cos(angle) * distance))
		end,
		bloom_mul = 1.5,
		parts = {
			{
				rotation = 270,
				angle = 0,
				distance = 24,
				texture = "guis/textures/hud_icons",
				texture_rect = {
					481,
					33,
					23,
					4
				}
			},
			{
				rotation = 0,
				angle = 90,
				distance = 24,
				texture = "guis/textures/hud_icons",
				texture_rect = {
					481,
					33,
					23,
					4
				}
			},
			{
				rotation = 90,
				angle = 180,
				distance = 24,
				texture = "guis/textures/hud_icons",
				texture_rect = {
					481,
					33,
					23,
					4
				}
			},
			{
				rotation = 180,
				angle = 270,
				distance = 24,
				texture = "guis/textures/hud_icons",
				texture_rect = {
					481,
					33,
					23,
					4
				}
			}
		}
	}
}

AdvancedCrosshair._default_hitmarkers = {
--please note that the same animation hit_func is called when previewing it from the menu
--so, when you are making your own hitmarker animation functions,
--remember either to not depend too heavily on the attack_data or result tables,
--or add sufficient sanity checks so as not to crash people in the menu
--the rest of the parameters (headshot, crit, result_type, etc) are safe to check/use, since they should be passed to the preview creation in the menu
	destiny_hit = {
		name_id = "menu_hitmarker_destiny_hit",
		hit_anim_distance = 6, --random var i used when creating this hitmarker, to show that you can... do that, since this data table is passed to the animation function
	--beware: these options generally override user settings,
	--so don't set color in the part table, or alpha in your main hitmarker table, unless you want it to be unaffected by settings
	--if you choose not to add a custom animation function, the fadeout alpha animation will automatically be used
	--if you do specify a custom animation function, you will have to provide the alpha fadeout yourself (unless you want your crosshair to disappear suddenly instead of fading out)
		parts = {
			{ --reused from plasma rifle crosshairs
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/destiny_hitmarker",
				w = 2,
				h = 6,
				angle = -45,
				rotation = 0,
				distance = 6
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/destiny_hitmarker",
				w = 2,
				h = 6,
				angle = 45,
				rotation = 0,
				distance = 6
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/destiny_hitmarker",
				w = 2,
				h = 6,
				angle = 135,
				rotation = 0,
				distance = 6
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/destiny_hitmarker",
				w = 2,
				h = 6,
				angle = -135,
				rotation = 0,
				distance = 6
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
		hit_anim_distance = 6,
		parts = {
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/destiny_hitmarker",
				w = 2,
				h = 6,
				angle = -45,
				rotation = 0,
				distance = 6
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/destiny_hitmarker",
				w = 2,
				h = 6,
				angle = 45,
				rotation = 0,
				distance = 6
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/destiny_hitmarker",
				w = 2,
				h = 6,
				angle = 135,
				rotation = 0,
				distance = 6
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/destiny_hitmarker",
				w = 2,
				h = 6,
				angle = -135,
				rotation = 0,
				distance = 6
			}
		}
	},
	gtfo_hit = {
		name_id = "menu_hitmarker_gtfo_hit",
		parts = {
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 0,
				rotation = 180,
				distance = 16
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 90,
				rotation = 180,
				distance = 16
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 180,
				rotation = 180,
				distance = 16
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 270,
				rotation = 180,
				distance = 16
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 45,
				rotation = 180,
				distance = 22
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 135,
				rotation = 180,
				distance = 22
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 225,
				rotation = 180,
				distance = 22
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
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
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 0,
				rotation = 180,
				distance = 16
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 90,
				rotation = 180,
				distance = 16
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 180,
				rotation = 180,
				distance = 16
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 18,
				angle = 270,
				rotation = 180,
				distance = 16
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 45,
				rotation = 180,
				distance = 22
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 135,
				rotation = 180,
				distance = 22
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 20,
				angle = 225,
				rotation = 180,
				distance = 22
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
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
				alpha = 0,
				UNRECOLORABLE = true
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
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 45,
				rotation = 180,
				distance = 8
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 135,
				rotation = 180,
				distance = 8
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 225,
				rotation = 180,
				distance = 8
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
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
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 45,
				rotation = 180,
				distance = 8
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 135,
				rotation = 180,
				distance = 8
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
				w = 2,
				h = 16,
				angle = 225,
				rotation = 180,
				distance = 8
			},
			{
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/ar_crosshair_2",
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
				texture_path = AdvancedCrosshair.assets_path .. "guis/textures/advanced_crosshairs/tf2_crit_text",
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

AdvancedCrosshair.hitmarker_menu_preview_loops = true

--************************************************--
--					Utils
--************************************************--
function AdvancedCrosshair:log(a,...)
	if not self:LogsEnabled() then 
		return
	end
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
	local category = "assault_rifle"
	local is_revolver = false
	local is_akimbo = false
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

function AdvancedCrosshair:LogsEnabled()
	return self.settings.logs_enabled
end

--************************************************--
--				Add-on Support
--************************************************--

--complex custom add-ons (crosshairs/hitmarkers/hitsounds) should be added before MenuManagerPopulateCustomMenus is called
--simple custom add-ons should simply be added inside the mods/saves/AdvancedCrosshairs folder, and this mod will take care of adding them

function AdvancedCrosshair:LoadAllAddons()
	if not BeardLib.Frameworks.Base then 
		self:log("Error loading addon xml: BeardLib AddFramework missing!")
	end
	
	self:LoadCrosshairAddons(self.ADDON_PATHS.crosshairs)
	self:LoadHitmarkerAddons(self.ADDON_PATHS.hitmarkers)
	self:LoadHitsoundAddons(self.ADDON_PATHS.hitsounds)
	
--	local modsmenu = BeardLib.Menus.Mods
--	if modsmenu then
--		--organize the list of beardlib mods now that any mods from ACH have been added
--		modsmenu._list:AlignItems(true)
--	end
end

function AdvancedCrosshair:LoadAddonXML(foldername,full_addon_path)
	local path_util = BeardLib.Utils.Path
	local bl_framework_base = BeardLib.Frameworks.Base
	local bl_framework_base_class = FrameworkBase
	local file_util = _G.FileIO
	
	local bl_menus_mods = BeardLib.Menus and BeardLib.Menus.Mods
	--temporarily disabled because it inexplicably broke as soon as i pushed the branch live i guess
	
	local xml_file_path = path_util:Combine(full_addon_path,self.addon_xml_file_name)
	if file_util:FileExists(Application:nice_path(xml_file_path)) then 
		if bl_framework_base then
			bl_framework_base:LoadMod(foldername,full_addon_path,xml_file_path)
			local mod = bl_framework_base:GetModByDir(foldername)
			if mod then
				
				--load modules (namely, assetupdates)
				mod:PreInitModules(mod._auto_init_modules)
				
				--manually call version check
				local assetsupdates = mod:GetModule("AssetUpdates")
				if assetsupdates then
					assetsupdates:CheckVersion()
				end
				
				--visually add the new beardlib mod to the menu list
				if bl_menus_mods then
					if not game_state_machine or GameStateFilters.menu[game_state_machine:current_state_name()] then
						bl_menus_mods:AddMod(mod,bl_framework_base)
					end
				end
			end
		else
			self:log("Skipped loading " .. tostring(self.addon_xml_file_name) .. " for hitsound addon: [" .. tostring(foldername) .. "]")
		end
	end
end

function AdvancedCrosshair:AddCustomCrosshair(id,data)
	if self._crosshair_data[id] then 
		self:log("Warning! Crosshair with id " .. id .. " already exists. Replacing existing data...",{color=Color(1,0.5,0)})
	end
	if id then 
		if type(data) == "table" then 
			local path_util = BeardLib.Utils.Path
			local extension = "texture"
			data.is_addon = true
			if type(data.parts) == "table" then 
				for part_index,part in ipairs(data.parts) do 
					if part.texture then 
						--assumes that you're either using textures that are already loaded (eg. textures from PAYDAY 2 itself, or loaded as part of another mod, or if you did it yourself)
					elseif part.texture_path then 
						--if using part.texture_path, ACH will handle loading your addon textures for you
						local folder_name = path_util:GetFileName(path_util:GetDirectory(part.texture_path))
						local filename = path_util:GetFileName(part.texture_path)
						local final_path = path_util:Combine(self.TEXTURE_PATH,folder_name,filename)
						local file_extension = part.file_extension or extension
						part.texture = final_path
						--and by that I mean pawn off the work of loading your addon textures to BeardLib, which will pawn off the work to SuperBLT, which w
						if self:ShouldAlwaysLoadAssets() then
							BeardLib.managers.file:AddFile(Idstring(extension),Idstring(final_path),part.texture_path .. "." .. file_extension)
						end
					else
						self:log("Error: Invalid texture/texture path when reading crosshair part data for part #" .. tostring(part_index) .. " in addon: " .. tostring(id).. ". Aborting addon.")
						return
					end
				end
			else
				self:log("Error: Could not load crosshair add-on (" .. tostring(id) .. "). Reason: Invalid parts data type: " .. tostring(data.parts) .. " (table expected, got " .. type(data) .. ")") 
				return
			end
			if data.name_id then 
			elseif data.name then 
				local name_id = "menu_crosshair_addon_" .. id
				managers.localization:add_localized_strings({
					[name_id] = data.name
				})
				data.name_id = name_id
			end
		else
			self:log("Error: Could not load crosshair add-on (" .. tostring(id) .. "). Reason: Invalid addon data type: " .. tostring(data) .. " (table expected, got " .. type(data) .. ")")
			return
		end
		AdvancedCrosshair._crosshair_data[id] = data
		self:log("Added custom crosshair addon: " .. (data.name_id and managers.localization:text(data.name_id) or (id .. " (No localized name found)")))
	else
		self:log("Error: Could not load crosshair add-on. (reason: invalid id)")
		if type(data) == "table" then 
			self:log("Dumping crosshair addon data to BLT log for identification...")
			AdvancedCrosshair.logtbl(data)
			self:log("Crosshair addon data dump complete.")
		else
			self:log("Crosshair addon data invalid: " .. tostring(data))
		end
	end
end

function AdvancedCrosshair:LoadCrosshairAddons(addons_dir)
	local path_util = BeardLib.Utils.Path
	local file_util = _G.FileIO
	local bl_framework_base = BeardLib.Frameworks.Base
	local bl_framework_base_class = FrameworkBase
	
	local function load_addon_textures(addon_path,foldername,parts)
		for part_index,part in ipairs(parts) do 
			if part.texture then 
			elseif part.texture_path then 
				part.texture_path = path_util:Combine(addon_path,foldername,part.texture_path)
			end
		end
	end

	for _,addon_path in pairs(addons_dir) do 
		if file_util:DirectoryExists(addon_path) then 
			for _,foldername in pairs(file_util:GetFolders(addon_path)) do 
				local full_addon_path = path_util:Combine(addon_path,foldername)
				
				local parts = {}
				local is_advanced
				local addon_lua_file_path = path_util:Combine(full_addon_path,self.addon_lua_file_name)
				
				-- load the addon xml file as if it were a beardlib mod (if xml file is present)
				--self:LoadAddonXML(foldername,full_addon_path)
			
				if file_util:FileExists(addon_lua_file_path) then
					is_advanced = true
					local addon_lua,s_error = blt.vm.loadfile(addon_lua_file_path) --thanks znix (non-sarcastic)
					if s_error then 
						self:log("FATAL ERROR: LoadCrosshairAddons(): " .. tostring(s_error),{color=Color.red})
					elseif addon_lua then 
						local addon_id,addon_data = addon_lua()
						if addon_id and type(addon_data) == "table" then 
							if addon_id == true then --megapack
								self:log("Loading Crosshairs megapack " .. foldername .. "...")
								for crosshair_id,crosshair_data in pairs(addon_data) do 
									if type(crosshair_data.parts) == "table" then 
										load_addon_textures(addon_path,foldername,crosshair_data.parts)
									else
										self:log("Error: LoadCrosshairAddons() megapack " .. addon_lua_file_path .. " contains invalid parts data: " .. tostring(addon_data.parts) .. " (table expected, got " .. type(addon_data.parts) .. ").")
										break
									end
									self:AddCustomCrosshair(crosshair_id,crosshair_data)
								end
								self:log("Done loading Crosshairs megapack " .. foldername .. ".")
							else
								if type(addon_data.parts) == "table" then 
									load_addon_textures(addon_path,foldername,addon_data.parts)
								else
									self:log("Error: LoadCrosshairAddons() " .. addon_lua_file_path .. " contains invalid parts data: " .. tostring(addon_data.parts) .. " (table expected, got " .. type(addon_data.parts) .. ").")
									break
								end
								self:AddCustomCrosshair(addon_id,addon_data)
							end
						else
							self:log("Error: LoadCrosshairAddons() " .. addon_lua_file_path .. " returned invalid data. Expected results: [string],[table]. Got: [" .. type(id) .. "] " .. tostring(id) .. ", [" .. type(addon_data) .. "] " .. tostring(addon_data) .. ".")
						end
					end
				end
				if not is_advanced then 
					for _,filename in pairs(file_util:GetFiles(full_addon_path)) do 
						local raw_path = path_util:Combine(full_addon_path,filename)
						
						local file_extension = path_util:GetFileExtension(filename)
						if file_extension and self.ALLOWED_TEXTURE_EXTENSIONS[utf8.to_lower(file_extension)] then 
							local texture_path = string.gsub(raw_path,"%." .. file_extension,"")
							
							table.insert(parts,#parts+1,{
								texture_path = texture_path,
								file_extension = file_extension
							})
						end
					end
					if #parts > 0 then 
						self:AddCustomCrosshair(string.gsub(foldername,"%s","_"),{
							name = foldername,
							parts = parts
						})
					else 
						self:log("Could not load crosshair add-on for: " .. foldername .. " (no valid files)")
					end
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
		if type(data) == "table" then 
			local path_util = BeardLib.Utils.Path
			local extension = "texture"
			data.is_addon = true
			if type(data.parts) == "table" then 
				for part_index,part in ipairs(data.parts) do 
					if part.texture then 
						--assumes that you're either using textures that are already loaded (eg. textures from PAYDAY 2 itself, or loaded as part of another mod, or if you did it yourself)
					elseif part.texture_path then 
						--if using part.texture_path, ACH will handle loading your addon textures for you
						local folder_name = path_util:GetFileName(path_util:GetDirectory(part.texture_path))
						local filename = path_util:GetFileName(part.texture_path)
						local final_path = path_util:Combine(self.TEXTURE_PATH,folder_name,filename)
						part.texture = final_path
						local file_extension = part.file_extension or extension
						if self:ShouldAlwaysLoadAssets() then
							BeardLib.managers.file:AddFile(Idstring(extension),Idstring(final_path),part.texture_path .. "." .. file_extension)
						end
					else
						self:log("Error: Invalid texture/texture path when reading hitmarker part data for part #" .. tostring(part_index) .. " in addon: " .. tostring(id).. ". Aborting addon.")
						return
					end
				end
			else
				self:log("Error: Could not load hitmarker add-on (" .. tostring(id) .. "). Reason: Invalid parts data type: " .. tostring(data.parts) .. " (table expected, got " .. type(data) .. ")") 
				return
			end
			if data.name_id then 
			elseif data.name then 
				local name_id = "menu_hitmarker_addon_" .. id
				managers.localization:add_localized_strings({
					[name_id] = data.name
				})
				data.name_id = name_id
			end
		else
			self:log("Error: Could not load hitmarker add-on (" .. tostring(id) .. "). Reason: Invalid addon data type: " .. tostring(data) .. " (table expected, got " .. type(data) .. ")")
			return
		end
		AdvancedCrosshair._hitmarker_data[id] = data
		self:log("Added custom hitmarker addon: " .. (data.name_id and managers.localization:text(data.name_id) or (id .. " (No localized name found)")))
	else
		self:log("Error: Could not load hitmarker add-on. (reason: invalid id)")
		if type(data) == "table" then 
			self:log("Dumping hitmarker addon data to BLT log for identification...")
			AdvancedCrosshair.logtbl(data)
			self:log("Hitmarker addon data dump complete.")
		else
			self:log("Hitmarker addon data invalid: " .. tostring(data))
		end
	end
end

function AdvancedCrosshair:LoadHitmarkerAddons(addons_dir)
	local path_util = BeardLib.Utils.Path
	local file_util = _G.FileIO
	local bl_framework_base = BeardLib.Frameworks.Base
	local bl_framework_base_class = FrameworkBase
	
	local function load_addon_textures(addon_path,foldername,parts)
		for part_index,part in ipairs(parts) do 
			if part.texture then 
			elseif part.texture_path then 
				part.texture_path = path_util:Combine(addon_path,foldername,part.texture_path)
			end
		end
	end
	
	for _,addon_path in pairs(addons_dir) do 
		if file_util:DirectoryExists(addon_path) then 
			for _,foldername in pairs(file_util:GetFolders(addon_path)) do 
				local full_addon_path = path_util:Combine(addon_path,foldername)
				
				local parts = {}
				local is_advanced
				local addon_lua_file_path = path_util:Combine(full_addon_path,self.addon_lua_file_name)
				
				-- load the addon xml file as if it were a beardlib mod (if xml file is present)
				--self:LoadAddonXML(foldername,full_addon_path)
					
				if file_util:FileExists(addon_lua_file_path) then 
					is_advanced = true
					local addon_lua = blt.vm.loadfile(addon_lua_file_path)
					if s_error then 
						self:log("FATAL ERROR: LoadHitmarkerAddons(): " .. tostring(s_error),{color=Color.red})
					elseif addon_lua then 
						local addon_id,addon_data = addon_lua()
						if addon_id and type(addon_data) == "table" then 
							if addon_id == true then --megapack
								self:log("Loading Hitmarkers megapack " .. foldername .. "...")
								for hitmarker_id,hitmarker_data in pairs(addon_data) do 
									if type(hitmarker_data.parts) == "table" then 
										load_addon_textures(addon_path,foldername,hitmarker_data.parts)
									else
										self:log("Error: LoadHitmarkerAddons() megapack " .. addon_lua_file_path .. " returned invalid data. Expected results: [string],[table]. Got: [" .. type(id) .. "] " .. tostring(id) .. ", [" .. type(addon_data) .. "] " .. tostring(addon_data) .. ".")
										break
									end
									self:AddCustomHitmarker(hitmarker_id,hitmarker_data)
								end
								self:log("Done loading Hitmarkers megapack " .. foldername .. ".")
							else
								if type(addon_data.parts) == "table" then 
									load_addon_textures(addon_path,foldername,addon_data.parts)
								else
									self:log("Error: LoadHitmarkerAddons() " .. addon_lua_file_path .. " contains invalid parts data: " .. tostring(addon_data.parts) .. " (table expected, got " .. type(addon_data.parts) .. ").")
									break
								end
								self:AddCustomHitmarker(addon_id,addon_data)
							end
						else
							self:log("Error: LoadHitmarkerAddons() " .. addon_lua_file_path .. " returned invalid data. Expected results: [string],[table]. Got: [" .. type(id) .. "] " .. tostring(id) .. ", [" .. type(addon_data) .. "] " .. tostring(addon_data) .. ".")
						end
					end
				end
				if not is_advanced then 
					for _,filename in pairs(file_util:GetFiles(full_addon_path)) do 
						local raw_path = path_util:Combine(full_addon_path,filename)
						local file_extension = path_util:GetFileExtension(filename)
						if file_extension and self.ALLOWED_TEXTURE_EXTENSIONS[utf8.to_lower(file_extension)] then 
							local texture_path = string.gsub(raw_path,"%." .. file_extension,"")
							
							table.insert(parts,#parts+1,{
								texture_path = texture_path,
								file_extension = file_extension
							})
						end
					end
					
					if #parts > 0 then 
						self:AddCustomHitmarker(string.gsub(foldername,"%s","_"),{
							name = foldername,
							parts = parts
						})
					else
						self:log("Could not load hitmarker add-on for: " .. foldername .. " (no valid files)")
					end
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
		if data.name_id then 
		elseif data.name then 
			local name_id = "menu_hitmarker_addon_" .. id
			managers.localization:add_localized_strings({
				[name_id] = data.name
			})
			data.name_id = name_id
		end
		AdvancedCrosshair._hitsound_data[id] = data
		self:log("Added custom hitsound addon: " .. (data.name_id and managers.localization:text(data.name_id) or "[ERROR]"))
	else
		self:log("Error: Could not load hitsound add-on. (reason: invalid id)")
		if type(data) == "table" then 
			self:log("Dumping hitsound addon data to BLT log for identification...")
			AdvancedCrosshair.logtbl(data)
			self:log("Hitsound addon data dump complete.")
		else
			self:log("Hitsound addon data invalid: " .. tostring(data))
		end
	end
end

function AdvancedCrosshair:LoadHitsoundAddons(addons_dir)
	local path_util = BeardLib.Utils.Path
	local file_util = _G.FileIO
	
	for _,addon_path in pairs(addons_dir) do
		if file_util:DirectoryExists(Application:nice_path(addon_path,true)) then 
			for _,foldername in pairs(file_util:GetFolders(addon_path)) do 
				local full_addon_path = path_util:Combine(addon_path,foldername)
				
				local variations = {}
				local is_advanced
				local addon_lua_file_path = path_util:Combine(full_addon_path,self.addon_lua_file_name)
				
				-- load the addon xml file as if it were a beardlib mod (if xml file is present)
				--self:LoadAddonXML(foldername,full_addon_path)
				
				if file_util:FileExists(Application:nice_path(addon_lua_file_path)) then
					is_advanced = true
					local addon_lua,s_error = blt.vm.loadfile(addon_lua_file_path)
					if s_error then 
						self:log("FATAL ERROR: LoadHitsoundAddons(): " .. tostring(s_error),{color=Color.red})
					elseif addon_lua then 
						local addon_id,addon_data = addon_lua()
						if addon_id == true then 
							--assume loading is handled by the addon
						elseif addon_id and type(addon_data) == "table" then 
							if type(addon_data.variations_paths) == "table" then 
								addon_data.variations = addon_data.variations or {}
								for i,variation in pairs(addon_data.variations_paths) do
									--write full path to soundfile which includes addon path
									addon_data.variations[#addon_data.variations + 1] = path_util:Combine(full_addon_path,variation)
								end
							end
							if addon_data.path_local then 
								addon_data.path = path_util:Combine(full_addon_path,addon_data.path_local)
							end
							self:AddCustomHitsound(addon_id,addon_data)
						else
							self:log("Error: LoadHitsoundAddons() " .. addon_lua_file_path .. " returned invalid data. Expected results: [string],[table]. Got: [" .. type(id) .. "] " .. tostring(id) .. ", [" .. type(addon_data) .. "] " .. tostring(addon_data) .. ".")
						end
					end
				end
				if not is_advanced then
					local is_randomized = file_util:FileExists(Application:nice_path(path_util:Combine(full_addon_path,"random.txt")))
					
					for _,filename in pairs(file_util:GetFiles(full_addon_path)) do 
						local file_extension = path_util:GetFileExtension(filename)
						if self.ALLOWED_SOUND_EXTENSIONS[utf8.to_lower(file_extension)] then
							local raw_path = path_util:Combine(full_addon_path,filename)
							
							if is_randomized then
								table.insert(variations,#variations + 1,raw_path)
							else
								local clean_filename = string.sub(filename,1,string.len(filename) - string.len("." .. file_extension))
								local clean_filename_no_spaces = string.gsub(clean_filename,"%s","_")
								local string_id = "menu_hitsound_addon_" .. clean_filename_no_spaces
								managers.localization:add_localized_strings({
									[string_id] = clean_filename
								})
								
								self:AddCustomHitsound(clean_filename_no_spaces,{
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
							variations = variations
						})
					end
				end
			end
		end
	end
end


function AdvancedCrosshair:UnloadHitmarkers()
	
end

function AdvancedCrosshair:UnloadCrosshairs()
	--[[ todo
	collect all used crosshair ids
	
	for all registered crosshairs:
		if crosshair is not used,
			if crosshair is loaded,
				unload crosshair
	
	for all used crosshairs:
		if crosshair is not loaded,
			load crosshair
	
	
	--]]
end


function AdvancedCrosshair:LoadPartsAssets(parts)
	-- for each part,
	-- if not loaded, load it
	
	local bl_filemgr = BeardLib.managers.file
	local pending_parts = {}
	local file_extension = "texture"
	local texture_ids = Idstring(file_extension)
	for part_index,part in pairs(parts) do 
		local texture_path = part.texture_path
		if texture_path then
			if bl_filemgr:Has(texture_ids,part.texture) then
				-- already loaded
			elseif pending_parts[texture_path] then
				-- already loading
			else
				-- load it
				pending_parts[texture_path] = true
				bl_filemgr:AddFile(texture_ids,Idstring(part.texture),texture_path .. "." .. file_extension)
			end
		else
			-- does not require load
		end
	end
end

Hooks:Register("ACH_LoadAddon_Crosshair") 
Hooks:Register("ACH_LoadAddon_Hitmarker") 
Hooks:Register("ACH_LoadAddon_Hitsound") 
--this is intended as safe way to add custom crosshairs since it's safe to call hooks that aren't defined
--this hook is called just before the hook "MenuManagerPopulateCustomMenus"

Hooks:Add("ACH_LoadAddon_Crosshair","advc_onregistercustomcrosshair",function(id,addon_data)
	AdvancedCrosshair:AddCustomCrosshair(id,addon_data)
end)
Hooks:Add("ACH_LoadAddon_Hitmarker","advc_onregistercustomhitmarker",function(id,addon_data)
	AdvancedCrosshair:AddCustomHitmarker(id,addon_data)
end)
Hooks:Add("ACH_LoadAddon_Hitsound","advc_onregistercustomhitsound",function(id,addon_data)
	AdvancedCrosshair:AddCustomHitsound(id,addon_data)
end)

--this way, it won't crash if you use this method and uninstall advanced crosshairs but forget to uninstall the custom crosshair add-on (even though uninstalling this mod would make me sad :'( )

--************************************************--
		--settings getters (and a few setters)
--************************************************--
	--General
	
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

function AdvancedCrosshair:UseCompatibilityAutoDetection()
	return self.settings.compatibility_auto_detection
end

function AdvancedCrosshair:UseCompatibility_PlayerManagerCheckSkill()
	local autodetect_compatibility_override
	if self:UseCompatibilityAutoDetection() then 
		autodetect_compatibility_override = self.auto_compatibility_settings.compatibility_hook_playermanager_checkskill
	end
	return autodetect_compatibility_override or self.settings.compatibility_hook_playermanager_checkskill
end

function AdvancedCrosshair:UseCompatibility_PlayerStandardOnSteelsight() --deprecated in v33
end

function AdvancedCrosshair:UseCompatibility_PlayerStandardStartEquipWeapon() --deprecated in v33
end

function AdvancedCrosshair:UseCompatibility_PlayerMovementStateEnter() --deprecated in v33
end

function AdvancedCrosshair:UseCompatibility_CopDamageMelee()
	local autodetect_compatibility_override
	if self:UseCompatibilityAutoDetection() then 
		autodetect_compatibility_override = self.auto_compatibility_settings.compatibility_hook_copdamage_damagemelee
	end
	return autodetect_compatibility_override or self.settings.compatibility_hook_copdamage_damagemelee
end

function AdvancedCrosshair:UseCompatibility_CopDamageRollCrit()
	local autodetect_compatibility_override
	if self:UseCompatibilityAutoDetection() then 
		autodetect_compatibility_override = self.auto_compatibility_settings.compatibility_hook_copdamage_rollcriticalhit
	end
	return autodetect_compatibility_override or self.settings.compatibility_hook_copdamage_rollcriticalhit
end

function AdvancedCrosshair:UseCompatibility_NewRaycastWeaponBaseToggleFiremode() --deprecated in v33
end

function AdvancedCrosshair:UseCompatibility_NewRaycastWeaponBaseResetCachedGadget() --deprecated in v33
end

function AdvancedCrosshair:IsEasterEggsEnabled()
	return self.settings.easter_eggs_enabled
end

function AdvancedCrosshair:CanCheckMeleeHeadshots()
	return self.settings.can_check_melee_headshots
end

function AdvancedCrosshair:CheckCreateAddonFolder()
	--make addons folders
	local file_util = _G.FileIO
	local addons_path_saves = AdvancedCrosshair.save_path .. "ACH Addons/"
	if not file_util:DirectoryExists(Application:nice_path(addons_path_saves,true)) then 
		file_util:MakeDir(addons_path_saves)
		local file = io.open(addons_path_saves .. "README.txt","w+")
		if file then
			--this is executed on startup, before localizationmanager is loaded
			local readme = string.gsub(AdvancedCrosshair.addons_readme_txt,"$LINK",AdvancedCrosshair.url_ach_github)
			file:write(readme)
			file:flush()
			file:close()
		end
		for addon_type,paths_tbl in pairs(AdvancedCrosshair.ADDON_PATHS) do 
			for _,path in pairs(paths_tbl) do 
				if not file_util:DirectoryExists(path) then 
					file_util:MakeDir(path)
				end
			end
		end
	end
end

function AdvancedCrosshair:SortAddons(reference_table,organization)
	if organization == 1 or organization == "alphabetical" then 
		local result = {}
		local result_by_localized = {}
		for id,addon_data in pairs(reference_table) do 
			local addon_name = addon_data.name_id and managers.localization:text(addon_data.name_id)
			if not addon_name then 
				self:log("ERROR: SortAddons(" .. self.concat(reference_table,organization) .. "): Bad addon data! [" .. tostring(id) .. "] Aborting sort operation...")
				return {},{}
			end
			
			
			local s1 = string.sub(addon_name,1,1)
			local c1 = s1 and string.byte(s1)
			if not c1 then
				self:log("ERROR: SortAddons(" .. self.concat(reference_table,organization) .. "): Bad sort input! [" .. tostring(id) .. "]")
				return {},{}
			end
			local done_insert
			for i,other_id in ipairs(result) do 
				local other_data = reference_table[other_id]
				if not other_data then 
					self:log("ERROR: SortAddons(" .. self.concat(reference_table,organization) .. "): Bad addon data in result table! " .. tostring(id) .. " / " .. tostring(reference_table))
					return {},{}
				end
				local s2 = string.sub(managers.localization:text(other_data.name_id),1,1)
				local c2 = string.byte(s2)
				if c1 <= c2 then 
					done_insert = true
					table.insert(result,i,id)
					table.insert(result_by_localized,i,addon_data.name_id)
					break
				end
			end
			if not done_insert then 
				done_insert = true
				table.insert(result,#result + 1,id)
				table.insert(result_by_localized,#result_by_localized + 1,addon_data.name_id)
			end
		end
		return result,result_by_localized
	end
end

function AdvancedCrosshair:ShouldAlwaysLoadAssets()
	return self.settings.assets_always_loaded_enabled
end



--Compatibility Checking and Resolution

AdvancedCrosshair.blt_hooks_source = "@mods/base/req/core/Hooks.lua"
AdvancedCrosshair.ach_hooks_source = AdvancedCrosshair.path .. "lua/menumanager.lua" 

AdvancedCrosshair.compatibility_checks = {
	compatibility_hook_playermanager_checkskill = {
		disabled = false,
		check_func = function()
			--generally, first check for mods that have known incompatibilities
			if _G.SC then 
				--SC's Restoration Mod (https://modworkshop.net/mod/428)
				return true
			end
			
			--then perform actual source checking
			if managers.player then 
				local debuginfo = debug and debug.getinfo and debug.getinfo(PlayerManager.check_skills)
					--you're not supposed to use this for anything but debugging your own software locally,
					--since lua environments/installations are not guaranteed to have the debug library shipped with release version software.
					--i gotta tho
				if type(debuginfo) == "table" then 
					local source = debuginfo.source
					if (source ~= AdvancedCrosshair.blt_hooks_source) and (source ~= AdvancedCrosshair.ach_hooks_source) then 
						return true
					end
				end
			end
			return false
		end
	},
	compatibility_hook_playerstandard_onsteelsight = {
		disabled = false,
		check_func = function()
			if _G.InFmenu then 
				--Rokk's IReNFIST (https://modworkshop.net/mod/28585)
				return true
			end
			
			if PlayerStandard then 
				do 
					local debuginfo = debug and debug.getinfo and debug.getinfo(PlayerStandard._start_action_steelsight)
					if type(debuginfo) == "table" then 
						local source = debuginfo.source
						if (source ~= AdvancedCrosshair.blt_hooks_source) and (source ~= AdvancedCrosshair.ach_hooks_source) then 
							return true
						end
					end
				end
				
				do 
					local debuginfo = debug and debug.getinfo and debug.getinfo(PlayerStandard._end_action_steelsight)
					if type(debuginfo) == "table" then 
						if (source ~= AdvancedCrosshair.blt_hooks_source) and (source ~= AdvancedCrosshair.ach_hooks_source) then 
							return true
						end
					end
				end
			end
			return false
		end
	},
	compatibility_hook_playermovementstate_enter = {
		disabled = false,
		check_func = function()
			if NewRaycastWeaponBase then 
				local debuginfo = debug and debug.getinfo and debug.getinfo(NewRaycastWeaponBase.reset_cached_gadget)
				if type(debuginfo) == "table" then 
					local source = debuginfo.source
					if (source ~= AdvancedCrosshair.blt_hooks_source) and (source ~= AdvancedCrosshair.ach_hooks_source) then 
						return true
					end
				end
			end
			return false
		end
	},
	compatibility_hook_playerstandard_startactionequipweapon = {
		disabled = false,
		check_func = function()
			if PlayerMovementState then 
				local debuginfo = debug and debug.getinfo and debug.getinfo(PlayerMovementState.enter)
				if type(debuginfo) == "table" then 
					local source = debuginfo.source
					if (source ~= AdvancedCrosshair.blt_hooks_source) and (source ~= AdvancedCrosshair.ach_hooks_source) then 
						return true
					end
				end
			end
			return false
		end
	},
	compatibility_hook_copdamage_damagemelee = {
		disabled = false,
		check_func = function()
			if _G.SC then 
				return true
			end
			
			if CopDamage then 
				local debuginfo = debug and debug.getinfo and debug.getinfo(CopDamage.damage_melee)
				if type(debuginfo) == "table" then 
					local source = debuginfo.source
					if (source ~= AdvancedCrosshair.blt_hooks_source) and (source ~= AdvancedCrosshair.ach_hooks_source) then 
						return true
					end
				end
			end
			return false
		end
	},
	compatibility_hook_copdamage_rollcriticalhit = {
		disabled = false,
		check_func = function()
			if _G.SC then 
				return true
			end
			
			if CopDamage then 
				local debuginfo = debug and debug.getinfo and debug.getinfo(CopDamage.roll_critical_hit)
				if type(debuginfo) == "table" then 
					local source = debuginfo.source
					if (source ~= AdvancedCrosshair.blt_hooks_source) and (source ~= AdvancedCrosshair.ach_hooks_source) then 
						return true
					end
				end
			end
			return false
		end
	},
	compatibility_hook_newraycastweaponbase_togglefiremode = {
		disabled = false,
		check_func = function()
			if NewRaycastWeaponBase then 
				local debuginfo = debug and debug.getinfo and debug.getinfo(NewRaycastWeaponBase.toggle_firemode)
				if type(debuginfo) == "table" then 
					local source = debuginfo.source
					if (source ~= AdvancedCrosshair.blt_hooks_source) and (source ~= AdvancedCrosshair.ach_hooks_source) then 
						return true
					end
				end
			end
			return false
		end
	},
	compatibility_hook_newraycastweaponbase_resetcachedgadget = {
		disabled = false,
		check_func = function()
			if NewRaycastWeaponBase then 
				local debuginfo = debug and debug.getinfo and debug.getinfo(NewRaycastWeaponBase.toggle_firemode)
				if type(debuginfo) == "table" then 
					local source = debuginfo.source
					if (source ~= AdvancedCrosshair.blt_hooks_source) and (source ~= AdvancedCrosshair.ach_hooks_source) then 
						return true
					end
				end
			end
			return false
		end
	}
}

function AdvancedCrosshair:CheckCompatibilityIssues()
	local any_found
	for setting_name,compatibility_data in pairs(self.compatibility_checks) do 
		if not compatibility_data.disabled then 
			local check_result = compatibility_data.check_func and compatibility_data.check_func()
			if check_result and setting_name and (self.settings[setting_name] ~= nil) then 
				any_found = any_found or check_result
			end
			self.auto_compatibility_settings[setting_name] = check_result
		end
	end
	return any_found
end

function AdvancedCrosshair:ApplyCompatibilityFixes()
	if self:UseCompatibility_PlayerManagerCheckSkill() then
		self:OnPlayerManagerCheckSkills(managers.player)
	end
	
	self:ApplyCompatibility_CopDamage_DamageMelee(self:UseCompatibility_CopDamageMelee())
	self:ApplyCompatibility_NewRaycastWeaponBaseResetCachedGadget(self:UseCompatibility_NewRaycastWeaponBaseResetCachedGadget())
end

function AdvancedCrosshair:ApplyCompatibility_PlayerMovementStateEnter(enabled) --deprecated in v33
end

function AdvancedCrosshair:ApplyCompatibility_PlayerStandardStartEquipWeapon(enabled) --deprecated in v33
end

	--we'll make our own hooks! with blackjack! and hooks! wait no
function AdvancedCrosshair:ApplyCompatibility_CopDamage_DamageMelee(enabled)

	--remove prior posthook just in case since this is a case where running twice could be annoying for the user
	--eg proccing duplicate hitmarkers or hitsounds
--	Hooks:RemovePostHook("ach_copdamage_melee")

	if CopDamage then 
		local orig_damage_melee = CopDamage._ach_orig_damage_melee
		if not (orig_damage_melee and type(orig_damage_melee) == "function") then 
			orig_damage_melee = CopDamage.damage_melee
			CopDamage._ach_orig_damage_melee = orig_damage_melee
		end
		
		if enabled then 
			--ersatz post-hook
			function CopDamage.damage_melee(dmg_ext,attack_data,...)
				local result = {orig_damage_melee(dmg_ext,attack_data,...)}
				AdvancedCrosshair.hook_CopDamage_damage_melee(dmg_ext,attack_data)
				return unpack(result)
			end
		else
			--effectively unhooking said ersatz post-hook
			CopDamage.damage_melee = orig_damage_melee
		end
	end
end

-- deprecated in v40; critical_hit is now added as a flag to attack_data in vanilla 
function AdvancedCrosshair:ApplyCompatibility_CopDamage_RollCriticalHit(enabled)
end

function AdvancedCrosshair:ApplyCompatibility_NewRaycastWeaponBaseToggleFiremode(enabled) --deprecated in v33
end

function AdvancedCrosshair:ApplyCompatibility_NewRaycastWeaponBaseResetCachedGadget(enabled) --deprecated in v33
end

function AdvancedCrosshair.hook_PlayerMovementState_enter(...) --deprecated in v33
end

function AdvancedCrosshair.hook_PlayerStandard_start_action_equip_weapon(state,t) --deprecated in v33
end

function AdvancedCrosshair.hook_CopDamage_damage_melee(dmg_ext,attack_data)
	--damage is applied even if the enemy is already dead, resulting in hitsounds/hitmarkers on meleeing enemy corpses
	--therefore, deaths are detected separately in ACH, from Message.OnEnemyKilled, as a workaround
	if attack_data.result then 
		
		if AdvancedCrosshair:CanCheckMeleeHeadshots() then 
			local is_headshot
			if attack_data.headshot == nil then 
				if _G.SC then 
					is_headshot = dmg_ext._head_body_name
						and not dmg_ext._unit:in_slot(16)
						and not dmg_ext._char_tweak.ignore_headshot
						and attack_data.col_ray.body
						and attack_data.col_ray.body:name() == dmg_ext._ids_head_body_name
				else
					is_headshot = dmg_ext._head_body_name
						and attack_data.col_ray.body
						and attack_data.col_ray.body:name() == dmg_ext._ids_head_body_name
				end
				--attack_data initially contains only the data "sent" when calculating enemy damage
				--but attack_data is changed by the execution of damage_melee(),
				--including the addition of the subtable attack_data.result
				
				attack_data.ach_headshot = is_headshot 
				--use a separate flag from the actual flag, attack_data.headshot, to determine if the melee was a headshot
			end
		end
		
		AdvancedCrosshair:OnEnemyHit(dmg_ext._unit,attack_data)
	end
end

function AdvancedCrosshair.hook_NewRaycastWeaponBase_toggle_firemode(wpnbase,skip_post_event) --deprecated in v33
end

function AdvancedCrosshair.hook_NewRaycastWeaponBase_reset_cached_gadget(wpnbase) --deprecated in v33
end

--this doesn't need an ApplyCompatibility function since its contents are run manually at the same time as the other ApplyCompatibility functions
function AdvancedCrosshair:OnPlayerManagerCheckSkills(pm,...)
	if pm then 
		pm._message_system:unregister(Message.OnWeaponFired,"advancedcrosshair_OnWeaponFired")
		pm._message_system:unregister(Message.OnEnemyShot,"advancedcrosshair_OnEnemyShot")
		pm._message_system:unregister(Message.OnEnemyKilled,"advancedcrosshair_OnEnemyKilled")

		pm._message_system:register(Message.OnWeaponFired,"advancedcrosshair_OnWeaponFired",
			function(weapon_unit,result)
				local weapon_base = alive(weapon_unit) and weapon_unit:base()
				if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base._setup.user_unit == pm:local_player() then 
					self:AddBloom()
				end
			end
		)
		pm._message_system:register(Message.OnEnemyShot,"advancedcrosshair_OnEnemyShot",function(unit,attack_data,...) 
			if alive(unit) and attack_data and attack_data.attacker_unit and (attack_data.attacker_unit == pm:local_player()) then 
				self:OnEnemyHit(unit,attack_data,...)
			end
		end)
		pm._message_system:register(Message.OnEnemyKilled,"advancedcrosshair_OnEnemyKilled",
			function(equipped_unit,variant,killed_unit)
				if alive(equipped_unit) and alive(killed_unit) and (variant == "fire" or variant == "poison") then 
					self:OnEnemyHit(killed_unit,{
						result = {
							type = "death"
						},
						headshot = false, --melee can't headshot anyway
						crit = false, --but i can't detect crits this way
						attacker_unit = equipped_unit:base()._setup.user_unit
					})
				end
			end
		)
		pm._listener_holder:remove("advancedcrosshair_OnEnterCustody")
		pm._listener_holder:add("advancedcrosshair_OnEnterCustody",{pm._custody_state},callback(self,self,"OnPlayerManagerOnEnterCustody"))
	end
end

	--Crosshairs
function AdvancedCrosshair:GetCrosshairStability()
	return self.settings.crosshair_stability
end
function AdvancedCrosshair:UseCrosshairShake()
	return self.settings.use_shake
end
function AdvancedCrosshair:UseCrosshairMovementBloom()
	return self.settings.use_movement_bloom
end
function AdvancedCrosshair:UseDynamicColor()
	return self.settings.use_color
end
function AdvancedCrosshair:IsCrosshairEnabled()
	return self.settings.crosshair_enabled
end
function AdvancedCrosshair:UseGlobalCrosshair() --deprecated; returns false
	return false --self.settings.crosshair_all_override
end
function AdvancedCrosshair:GetBloomCooldown() --no menu option; returns constant
	return 0.05
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
function AdvancedCrosshair:CrosshairAllowedInState(state_name)
	return state_name and self.STATES_CROSSHAIR_ALLOWED[state_name]
end

function AdvancedCrosshair:GetCrosshairRangeMode()
	return self.settings.crosshair_outofrange_mode
end

function AdvancedCrosshair:GetHitmarkerRangeMode()
	return self.settings.hitmarker_outofrange_mode
end

	--Hitmarkers
function AdvancedCrosshair:IsHitmarkerEnabled()
	return self.settings.hitmarker_enabled
end
function AdvancedCrosshair:UseHitmarkerHitPosition()
	return self.settings.use_hitpos
end
function AdvancedCrosshair:GetHitmarkerSettings(hitmarker_type)
	if (hitmarker_type == "kill") or (hitmarker_type == "death") then 
		return {
			hitmarker_id = self.settings.hitmarker_kill_id,
			duration = self.settings.hitmarker_kill_duration,
			alpha = self.settings.hitmarker_kill_alpha,
			scale = self.settings.hitmarker_kill_scale,
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
		scale = self.settings.hitmarker_hit_scale,
		blend_mode = self.settings.hitmarker_hit_blend_mode,
		bodyshot_color = Color(self.settings.hitmarker_hit_bodyshot_color),
		bodyshot_crit_color = Color(self.settings.hitmarker_hit_bodyshot_crit_color),
		headshot_color = Color(self.settings.hitmarker_hit_headshot_color),
		headshot_crit_color = Color(self.settings.hitmarker_hit_headshot_crit_color)
	}
end	
function AdvancedCrosshair:GetHitmarkerMaxCount()
	return self.settings.hitmarker_max_count
end
function AdvancedCrosshair:GetHitmarkerLimitBehavior()
	return self.settings.hitmarker_limit_behavior
end
function AdvancedCrosshair:AllowMeleeHitmarkers()
	return self.settings.hitmarker_allow_melee
end

	--Hitsounds
function AdvancedCrosshair:IsHitsoundEnabled()
	return self.settings.hitsound_enabled
end
function AdvancedCrosshair:GetHitsoundLimitBehavior()
	return self.settings.hitsound_limit_behavior
end

function AdvancedCrosshair:GetHitsoundMaxCount()
	return self.settings.hitsound_max_count
end

function AdvancedCrosshair:UseHitsoundHitPosition() -- no menu option
	return self.settings.use_hitsound_pos
end
function AdvancedCrosshair:ShouldSuppressDoubleSound() --determines whether hit+critsounds should both be played, or just one
	return self.settings.hitsound_suppress_doublesound
end
function AdvancedCrosshair:AllowMeleeHitsounds()
	return self.settings.hitsound_allow_melee
end

--************************************************--
		--hud animate functions
--************************************************--

	-- hud animation manager --
	
function AdvancedCrosshair:animate(object,func,done_cb,...)
	return self.animator:animate(object,func,done_cb,...)
end

function AdvancedCrosshair:animate_stop(object,do_cb,...)
	return self.animator:animate_stop(object,do_cb,...)
end

function AdvancedCrosshair:is_animating(object,...)
	return self.animator:is_animating(object,...)
end

	--hud animations
	
function AdvancedCrosshair.animate_move_linear_endpoints(o,t,dt,start_t,duration,from_x,from_y,exit_x,exit_y)
	local ratio = (t - start_t) / duration
	local d_x = (exit_x - from_x)
	local d_y = (exit_y - from_y)
	if ratio >= 1 then 
		o:set_position(exit_x,exit_y)
		return true
	else
		o:set_position(from_x + (d_x * ratio),from_y + (d_y * ratio))
	end
end

function AdvancedCrosshair:StartHitmarkerRain()
	if (self._cache._hitmarker_rain_count_remaining and self._cache._hitmarker_rain_count_remaining > 0) or not alive(self._hitmarker_panel) then 
		return
	end

	self._cache._hitmarker_rain_count_remaining = math.max(self.HITMARKER_RAIN_COUNT_MIN,math.random(self.HITMARKER_RAIN_COUNT_MAX))
	self._cache._next_hitmarker_rain_t = 0

	local gamer_text = self._hitmarker_panel:text({
		name = "preview_label",
		text = managers.localization:text("hud_ach_proc_easteregg_text"),
		layer = 69, --haha nice
		align = "center",
		vertical = "center",
		font = tweak_data.hud.medium_font,
		font_size = 48,
		color = Color.red
	})

	BeardLib:AddUpdater("ach_hitmarker_rain_update",function(t,dt)
		if alive(self._hitmarker_panel) and self._cache._hitmarker_rain_count_remaining and self._cache._hitmarker_rain_count_remaining > 0 then 
			if alive(gamer_text) then 
				gamer_text:set_visible(math.sin(t * self.HITMARKER_RAIN_TEXT_FLASH_SPEED) > 0)
			end
			if self._cache._next_hitmarker_rain_t and (t >= self._cache._next_hitmarker_rain_t) then 
				self._cache._next_hitmarker_rain_t = t + math.max(self.HITMARKER_RAIN_SPAWN_DELAY_INTERVAL_MIN,(math.random(self.HITMARKER_RAIN_SPAWN_DELAY_INTERVAL_MAX * 100) / 100))
				self._cache._hitmarker_rain_count_remaining = self._cache._hitmarker_rain_count_remaining - 1
				local size = 32
				local start_x = math.random(self._hitmarker_panel:w())
				local start_y = -size
				local panel = self._hitmarker_panel:panel({
					name = "hitmarker_rain_" .. tostring(self._cache._hitmarker_rain_count_remaining),
					x = start_x,
					y = start_y,
					w = size,
					h = size
				})
				local parts = self:CreateHitmarker(panel,self._hitmarker_data.generic_hit)
				local function remove_panel(o)
					o:parent():remove(o)
				end
				self:animate(panel,"animate_move_linear_endpoints",remove_panel,math.max(self.HITMARKER_RAIN_TRAVEL_DURATION_MIN,math.random(self.HITMARKER_RAIN_TRAVEL_DURATION_MAX)),start_x,start_y,start_x,self._hitmarker_panel:height() + 1)				
			end
		else
			if alive(gamer_text) then 
				self._hitmarker_panel:remove(gamer_text)
			end
			
			self._cache._hitmarker_rain_count_remaining = nil
			self._cache._next_hitmarker_rain_t = nil
			BeardLib:RemoveUpdater("ach_hitmarker_rain_update")
		end
		
		
	end)
	
	
	
end


--************************************************--
		--stuff that happens during gameplay
--************************************************--


	--**********************--
		--init hud items
	--**********************--
--these should only run once, when the player spawns
function AdvancedCrosshair:Init()
	if BeardLib then
		BeardLib:AddUpdater("advancedcrosshairs_update",callback(AdvancedCrosshair,AdvancedCrosshair,"Update"),true)
		BeardLib:AddUpdater("advc_create_hud_delayed",callback(AdvancedCrosshair,AdvancedCrosshair,"CreateHUD"))
	else
		managers.hud:remove_updator("advancedcrosshairs_update")
		managers.hud:remove_updator("advc_create_hud_delayed")
		managers.hud:add_updator("advancedcrosshairs_update",callback(AdvancedCrosshair,AdvancedCrosshair,"Update"))
		managers.hud:add_updator("advc_create_hud_delayed",callback(AdvancedCrosshair,AdvancedCrosshair,"CreateHUD"))
	end
	
	if blt.xaudio then
        blt.xaudio.setup()
	end
	if self:IsEasterEggsEnabled() then
		local datea = os.date("*t",os.time()) -- get it? date data? i'm an underappreciated comedic genius in my time
		if datea.month == 4 and datea.day == 1 then -- trigger on april fool's
			self._cache.HITMARKER_RAIN_ENABLED = true
		end
	end
end

function AdvancedCrosshair:OnPlayerManagerOnEnterCustody(player_unit)
	self:ClearCache()
	self:RemoveAllCrosshairs(true)
end

function AdvancedCrosshair:CreateHUD(t,dt) --try to create hud each run until both required elements are initiated.

--...it's not ideal.
	local hud = managers.hud and managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2) --managers.hud._hud_hit_confirm and managers.hud._hud_hit_confirm._hud_panel
	if managers.player and alive(managers.player:local_player()) and hud and hud.panel then 
	
		if self:UseCompatibilityAutoDetection() then
			self:CheckCompatibilityIssues()
		end
		self:ApplyCompatibilityFixes()
		
		self:CreateCrosshairPanel(hud.panel)
		self:CreateCrosshairs()
		
		if BeardLib then
			BeardLib:RemoveUpdater("advc_create_hud_delayed")
			BeardLib:AddUpdater("ach_update_crosshair",callback(self,self,"UpdateCrosshair"))
		else
			managers.hud:remove_updator("advancedcrosshairs_update",callback(AdvancedCrosshair,AdvancedCrosshair,"Update"))
			managers.hud:add_updator("advancedcrosshairs_update",callback(AdvancedCrosshair,AdvancedCrosshair,"Update"))
		end
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
	self:RemoveAllCrosshairs(false)
	local player = managers.player:local_player()
	local inventory = player:inventory()
	local equipped_unit = inventory:equipped_unit()
	local done_any
	for i,selection_data in pairs(inventory:available_selections()) do 
		self:CreateCrosshairByWeapon(selection_data.unit,i)
		if selection_data.unit == equipped_unit then 
			self._cache.current_crosshair_data = self._cache.weapons[tostring(equipped_unit:key())].firemodes[equipped_unit:base():fire_mode()]
		end
		done_any = true
	end
	return done_any
end

function AdvancedCrosshair:RemoveCrosshairByWeapon(unit)
	local unit_key = tostring(unit:key())
	local data = self._cache.weapons[unit_key] 
	if data then 
		if alive(data.panel) then 
			self:animate_stop(data.panel)
			data.panel:parent():remove(data.panel)
			data.panel = nil
		end
	end
	self._cache.weapons[unit_key] = nil
end

function AdvancedCrosshair:RemoveAllCrosshairs(queue_recreation)
	for unit_key,data in pairs(self._cache.weapons) do 
		self:animate_stop(data.panel)
		for firemode_name,firemode_data in pairs(data.firemodes) do 
			self:animate_stop(firemode_data.panel)
		end
		for underbarrel_name,underbarrel_data in pairs(data.underbarrels) do 
			for firemode_name,firemode_data in pairs(underbarrel_data) do 
				self:animate_stop(firemode_data.panel)
			end
		end
		data.panel:parent():remove(data.panel)
		data.panel = nil
		self._cache.weapons[unit_key] = nil
	end
	if queue_recreation then
		BeardLib:RemoveUpdater("ach_queue_crosshair_creation")
		BeardLib:AddUpdater("ach_queue_crosshair_creation",function(t,dt)
			if alive(managers.player:local_player()) and alive(self._crosshair_panel) then 
				if self:CreateCrosshairs() then
					BeardLib:RemoveUpdater("ach_queue_crosshair_creation")
				end
			end
		end)
	end
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
	if is_akimbo then 
		weapon_category = "akimbo_" .. weapon_category
	end
	for _,firemode in pairs(self.VALID_WEAPON_FIREMODES) do
		local crosshair_id = self:GetCrosshairType(weapon_index,weapon_id,weapon_category,firemode,is_revolver,is_akimbo)
		local crosshair_tweakdata = self._crosshair_data[crosshair_id]
		local crosshair_setting = weapon_category and self.settings.crosshairs[weapon_category] and self.settings.crosshairs[weapon_category][firemode]
		if crosshair_setting then 
			if crosshair_setting.overrides_global then 
				--crosshair_setting = crosshair_setting --boy i sure hope it do
			else
				crosshair_setting = self.settings.crosshair_global
			end
		else
			crosshair_setting = self.DEFAULT_CROSSHAIR_OPTIONS
		end
		
		local firemode_panel = weapon_panel:panel({
			name = firemode,
			visible = false,
			alpha = crosshair_setting.alpha
		})
		local parts = self:CreateCrosshair(firemode_panel,crosshair_tweakdata,crosshair_setting)
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
				if underbarrel_is_akimbo then 
					underbarrel_category = "akimbo_" .. underbarrel_category 
				end
				local underbarrel_crosshair_id = self:GetCrosshairType(nil,underbarrel_id,underbarrel_category,firemode,underbarrel_is_revolver,underbarrel_is_akimbo)
				local crosshair_setting = self.settings.crosshairs[underbarrel_category][firemode]
				if crosshair_setting then 
					if crosshair_setting.overrides_global then 
						--no nothing, everything is in order
					else
						crosshair_setting = self.settings.crosshair_global
					end
				else
					crosshair_setting = self.DEFAULT_CROSSHAIR_OPTIONS
				end			
				local underbarrel_firemode_panel = underbarrel_panel:panel({
					name = firemode,
					visible = false,
					alpha = crosshair_setting.alpha
				})
				local _crosshair_data = self._crosshair_data[underbarrel_crosshair_id]
				_crosshair_data = _crosshair_data or self._crosshair_data.pdth_classic

				underbarrels_data[tostring(underbarrel)].firemodes[firemode] = { --using a table as an index is gross but i gotta
					underbarrel_index = underbarrel_index,
					crosshair_id = underbarrel_crosshair_id,
					base = underbarrel,
					panel = underbarrel_firemode_panel,
					parts = self:CreateCrosshair(underbarrel_firemode_panel,_crosshair_data,crosshair_setting),
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

function AdvancedCrosshair:CreateCrosshair(panel,data,user_settings)
	--if data.special_crosshair then 
	--	do stuff here
	--end
	local results = {}
	user_settings = user_settings or {}
	local scale_setting = (user_settings.scale or 1)
	local color = data.color or (user_settings.color and Color(user_settings.color))
	if not self:ShouldAlwaysLoadAssets() then
		self:LoadPartsAssets(data.parts)
	end
	for i,part_data in ipairs(data.parts) do 
		local scale = scale_setting * (data.scale or 1)
		local x = (part_data.x or 0) * scale
		local y = (part_data.y or 0) * scale
		local w,h
		local angle = part_data.angle or part_data.rotation
		if part_data.distance and angle then 
			x = x + (math.sin(angle) * part_data.distance * scale)
			y = y + (-math.cos(angle) * part_data.distance * scale)
		end
		if part_data.w then 
			w = part_data.w * scale
		end
		if part_data.h then 
			h = part_data.h * scale
		end
		local bitmap = panel:bitmap({
			name = tostring(i),
			texture = part_data.texture,
			texture_rect = part_data.texture_rect,
			x = x,
			y = y,
			rotation = part_data.rotation,
			w = w,
			h = h,
			visible = part_data.visible,
			valign = part_data.valign,
			halign = part_data.halign,
			alpha = part_data.alpha or data.alpha,
			blend_mode = part_data.blend_mode or data.blend_mode,
			color = color,
			render_template = part_data.render_template or data.render_template,
			layer = (part_data.layer or data.layer or 0)
		})
		if not w then 
			bitmap:set_w((part_data.texture_rect and part_data.texture_rect[3] or bitmap:texture_width()) * scale)
		end
		if not h then 
			bitmap:set_h((part_data.texture_rect and part_data.texture_rect[4] or bitmap:texture_height()) * scale)
		end
		table.insert(results,i,bitmap)
		bitmap:set_center(x + (panel:w()/2),y + (panel:h()/2))
	end
	return results
end

function AdvancedCrosshair:SetCrosshairScale(scale_mul,scale_setting_override)
	--scale_mul argument is meant for use with pd2's new range mechanic; this is separate from the crosshair scale setting, which is applied on top of this
	scale_mul = scale_mul or 1
	local current_crosshair_data = self:GetCurrentCrosshair()
	local scale_setting = (scale_setting_override or current_crosshair_data.settings.scale or 1) * scale_mul
	local crosshair_data = self._crosshair_data[tostring(current_crosshair_data.crosshair_id)]
	if crosshair_data then 
		if not crosshair_data.special_crosshair then 
			for i=1,#current_crosshair_data.parts,1 do 
				local part = current_crosshair_data.parts[i]
				if alive(part) then 
					local parent = part:parent()
					local part_data = crosshair_data.parts[i]
					local scale = scale_setting * (crosshair_data.scale or 1)
					local x = (part_data.x or 0) * scale
					local y = (part_data.y or 0) * scale
					local w,h
					local angle = part_data.angle or part_data.rotation
					if part_data.distance and angle then 
						x = x + (math.sin(angle) * part_data.distance * scale)
						y = y + (-math.cos(angle) * part_data.distance * scale)
					end
					if part_data.w then 
						w = part_data.w * scale
					end
					if part_data.h then 
						h = part_data.h * scale
					end
					part:set_position(x,y)

					if w then 
						part:set_w(w)
					else
						part:set_w((part_data.texture_rect and part_data.texture_rect[3] or part:texture_width()) * scale)
					end
					if h then 
						part:set_h(h)
					else
						part:set_h((part_data.texture_rect and part_data.texture_rect[4] or part:texture_height()) * scale)
					end
					part:set_center(x + (parent:w()/2),y + (parent:h()/2))
				end
			end
		end
	end
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
					if alive(part) then 
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
		if alive(current_crosshair_data.panel) then 
			local crosshair_data = self._crosshair_data[current_crosshair_data.crosshair_id] or {}
			local data = {bloom = bloom,crosshair_data = crosshair_data,scale = current_crosshair_data.settings.scale,panel_w = current_crosshair_data.panel:w(),panel_h = current_crosshair_data.panel:h()}
			local a = crosshair_data.bloom_func
			
			self:GetCurrentCrosshairParts(a,data)
		end
	end
end

function AdvancedCrosshair:SetCrosshairAlpha(alpha_mul,alpha_setting_override)
	local current_crosshair_data,current_crosshair_id = self:GetCurrentCrosshair()
	local alpha_setting = (alpha_mul or 1) * (alpha_setting_override or current_crosshair_data.settings.alpha or 1)
	local crosshair_data = self._crosshair_data[tostring(current_crosshair_data.crosshair_id)]
	if crosshair_data then 
		if not crosshair_data.special_crosshair then 
			for i=1,#crosshair_data.parts,1 do 
				local part_data = crosshair_data.parts[i]
				local part = current_crosshair_data.parts[i]
				if alive(part) then 
					local alpha = alpha_setting * (part_data.alpha or 1)
					part:set_alpha(alpha)
				end
			end
		else
			--todo
		end
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
	local scale_setting = data.scale or 1
	for i,part_data in ipairs(data.parts) do 
		local scale = scale_setting * (part_data.scale or 1)
		local x = (part_data.x or 0) * scale
		local y = (part_data.y or 0) * scale
		local w
		local h
		local angle = part_data.angle
		local rotation = (part_data.rotation or 0) + (angle or 0)
		if part_data.distance and angle then 
			x = x + (math.sin(angle) * part_data.distance * scale)
			y = y + (-math.cos(angle) * part_data.distance * scale)
		end
		if part_data.w then 
			w = part_data.w * scale
		end
		if part_data.h then 
			h = part_data.h * scale
		end
		local bitmap = panel:bitmap({
			name = tostring(i),
			texture = part_data.texture,
			texture_rect = part_data.texture_rect,
			x = x,
			y = y,
			rotation = rotation,
			w = w,
			h = h,
			visible = part_data.visible,
			valign = part_data.valign,
			halign = part_data.halign,
			alpha = part_data.alpha,
			blend_mode = part_data.blend_mode or data.blend_mode,
			color = part_data.color or data.color,
			render_template = part_data.render_template,
			layer = 5 + (part_data.layer or 0)
		})
		if not w then
			bitmap:set_w((part_data.texture_rect and part_data.texture_rect[3] or bitmap:texture_width()) * scale)
		end
		if not h then 
			bitmap:set_h((part_data.texture_rect and part_data.texture_rect[4] or bitmap:texture_height()) * scale)
		end
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
			return table.remove(self._cache.hitmarkers,index)
		end
	end
end

function AdvancedCrosshair:RemoveHitmarkerByIndex(index)
	return index and table.remove(self._cache.hitmarkers,index)
end

function AdvancedCrosshair:ActivateHitmarker(attack_data)
	local limit_behavior = self:GetHitmarkerLimitBehavior()
	if (#self._cache.hitmarkers >= self:GetHitmarkerMaxCount()) then 
		--unlike hitsounds, hitmarkers are already managed in update(), so we just need to check the table count
		if limit_behavior == 1 then
			--hard cap, so leave if cap reached
			return
		elseif limit_behavior == 2 then 
			--remove others to make room
			local replaced_hitmarker = self:RemoveHitmarkerByIndex(1)
			if replaced_hitmarker and alive(replaced_hitmarker.panel) then
				self:animate_stop(replaced_hitmarker.panel)
				replaced_hitmarker.panel:parent():remove(replaced_hitmarker.panel)
			end
		--if limit_behavior == 3 then hitmaker count is uncapped, so do nothing
		end
	end
	
	
	local result = attack_data.result
	local result_type = result and result.type
	local pos = attack_data.pos
	local headshot = attack_data.headshot or attack_data.ach_headshot
	local crit = attack_data.crit or attack_data.critical_hit

	local outofrange_display_mode = self:GetHitmarkerRangeMode()

	local outofrange_scale = 1
	local outofrange_color
	local outofrange_alpha = 1
	local weak_hit
	local weapon_unit = attack_data.weapon_unit
	if outofrange_display_mode == self.OUTOFRANGE_DISPLAY_MODES.hitmarker.disabled then
		--rien
	else
		if alive(weapon_unit) and attack_data.col_ray then 
			local ad_distance = attack_data.col_ray.distance
			local ad_attacker = attack_data.attacker_unit
			local ad_weaponbase = weapon_unit.base and weapon_unit:base()
			if ad_distance and ad_attacker then 
				if ad_weaponbase and ad_weaponbase.is_weak_hit then 
					weak_hit = ad_weaponbase:is_weak_hit(ad_distance, ad_attacker)
				else
--					self:log("Weaponbase or is_weak_hit() does not exist!")
				end
			else
--				self:log("ad_distance or ad_attacker does not exist")
			end
		else
--			self:log("Attack data weapon unit or col_ray does not exist!")
		end
		
		if weak_hit then 
			if outofrange_display_mode == self.OUTOFRANGE_DISPLAY_MODES.hitmarker.size then
				outofrange_scale = self.OUTOFRANGE_HITMARKER_SCALE
			elseif outofrange_display_mode == self.OUTOFRANGE_DISPLAY_MODES.hitmarker.color then
				outofrange_color = self.OUTOFRANGE_HITMARKER_COLOR
			elseif outofrange_display_mode == self.OUTOFRANGE_DISPLAY_MODES.hitmarker.alpha then
				outofrange_alpha = self.OUTOFRANGE_HITMARKER_ALPHA
			end
		end
	end

	local hitmarker_setting = self:GetHitmarkerSettings(result_type)
	
	local hitmarker_id = hitmarker_setting.hitmarker_id
	if not (hitmarker_id and self._hitmarker_data[hitmarker_id]) then
		self:log("ERROR: CreateHitmarker(): Bad hitmarker_id (" .. tostring(hitmarker_id) .. "); Aborting!",{color=Color.red})
		return
	end
	local hitmarker_data = self._hitmarker_data[hitmarker_id]
	
	if not self:ShouldAlwaysLoadAssets() then
		self:LoadPartsAssets(hitmarker_data.parts)
	end
	
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
		alpha = (hitmarker_data.alpha or 1) * hitmarker_setting.alpha * outofrange_alpha,
		name = "hitmarker_" .. tostring(num_id)
	})
	if alive(panel) then 
		local parts = self:CreateHitmarker(panel,{
			parts = hitmarker_data.parts,
			color = outofrange_color or color,
			blend_mode = self.BLEND_MODES[hitmarker_setting.blend_mode],
			scale = (hitmarker_data.scale or 1) * (hitmarker_setting.scale or 1) * outofrange_scale
		})
		table.insert(self._cache.hitmarkers,#self._cache.hitmarkers + 1,
			{ --this is only used for the "3D hitmarkers" feature
				num_id = num_id,
				panel = panel,
				parts = parts,
				position = attack_data.pos or (attack_data.col_ray and attack_data.col_ray.position)
			}
		)
		local function remove_panel(o)
--			self:animate_stop(o)
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

function AdvancedCrosshair.animate_hitmarker_parts(o,t,dt,start_t,duration,parts,hit_func,data)
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

function AdvancedCrosshair:OnEnemyHit(unit,attack_data)
	if attack_data.attacker_unit and (attack_data.attacker_unit == managers.player:local_player()) then 
		local variant = attack_data.variant
		if self:IsHitmarkerEnabled() and (self:AllowMeleeHitmarkers() or variant ~= "melee") then
			self:ActivateHitmarker(attack_data)
		end
		if self:IsHitsoundEnabled() and (self:AllowMeleeHitsounds() or variant ~= "melee") then 
			AdvancedCrosshair:ActivateHitsound(attack_data,unit)
			--screw your existing argument order, i'm a loose cannon who got nothing to lose and don't play by the rules
		end
		if self._cache.HITMARKER_RAIN_ENABLED and attack_data and attack_data.result and attack_data.result.type == "death" then 
			if (not self._cache._hitmarker_rain_count_remaining) and (math.random() <= self.HITMARKER_RAIN_PROC_CHANCE) then 
				self:StartHitmarkerRain()
			end
		end
	end
end

-- hitsounds

function AdvancedCrosshair:GetHitsoundData(attack_data)
	local result = attack_data.result
	local result_type = result and result.type
	local headshot = attack_data.headshot or attack_data.ach_headshot
	local crit = attack_data.crit or attack_data.critical_hit
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

function AdvancedCrosshair:CleanHitsounds()
	local sources = self._cache.sound_sources
	local num_sources = #sources
	for i=num_sources,1,-1 do 
		local sound_source = sources[i]
		if (not sound_source) or sound_source:is_closed() then
			table.remove(sources,i)
			num_sources = num_sources - 1
		end
	end
	return num_sources
end

function AdvancedCrosshair:RemoveAllHitsounds()
	for i=#self._cache.sound_sources,1,-1 do 
		local replaced_source = table.remove(self._cache.sound_sources,1)
		if replaced_source and not replaced_source:is_closed() then
			replaced_source:set_volume(0)
		--	replaced_source:stop()
			replaced_source:close()
			replaced_source._buffer:close()
		end
	end
end

function AdvancedCrosshair:RemoveOldestHitsound()
	local replaced_source = table.remove(self._cache.sound_sources,1)
	if replaced_source and not replaced_source:is_closed() then
		replaced_source:set_volume(0)
	--	replaced_source:stop()
		replaced_source:close()
		replaced_source._buffer:close()
	end
	return replaced_source
end

function AdvancedCrosshair:ActivateHitsound(attack_data,unit,no_pause)
	local snd_path,volume = self:GetHitsoundData(attack_data)
	if snd_path then 
		local snd_path_2,volume_2
		if (not self:ShouldSuppressDoubleSound()) and (attack_data.critical_hit or attack_data.headshot or attack_data.ach_headshot) then 
			snd_path_2,volume_2 = self:GetHitsoundData({
				result = {
					type = attack_data.result and attack_data.result.type or "hurt"
				},
				headshot = false,
				crit = false,
			})
			if snd_path_2 == snd_path then 
				-- if both sounds would be identical, 
				-- only play the first one, 
				-- as playing the same sound at increased volume probably isn't desirable for most people
				snd_path_2 = nil
				volume_2 = nil
			end
			--note: secondary hitsounds can temporarily exceed the hitsound count since i consider them part of the primary hitsound
		end
		
		local num_sources = #self._cache.sound_sources
		-- if this many sound sources are in the table,
		-- clean any closed sound sources, regardless of settings
		local limit_behavior = self:GetHitsoundLimitBehavior()
		if (limit_behavior == 1) or (num_sources >= self.CLEAN_SOUNDS_THRESHOLD) then 
			num_sources = self:CleanHitsounds()
		end
		if limit_behavior == 3 then -- no limit
			-- carry on then
		elseif limit_behavior == 1 then -- hard cap (don't play if over limit)
			if num_sources >= self:GetHitsoundMaxCount() then 
				-- if at user setting cap, don't play hitsounds
				return
			end
		elseif limit_behavior == 2 then -- replace oldest
			local overage = num_sources - self:GetHitsoundMaxCount()
			if snd_path_2 then
				-- need to account for an extra sound slot requirement if playing two sounds
				overage = overage + 1
			end
			if overage >= 0 then
			-- remove sounds until there's space
				for i=0,overage,1 do 
					self:RemoveOldestHitsound()
				end
			end
		end
		
		local source_1,source_2
		if managers.player:local_player() then 
			if self:UseHitsoundHitPosition() then 
				if unit then 
					if snd_path_2 then 
						source_2 = XAudio.UnitSource:new(unit, XAudio.Buffer:new(snd_path_2))
					end
					source_1 = XAudio.UnitSource:new(unit, XAudio.Buffer:new(snd_path))
				else
					if snd_path_2 then 
						source_2 = XAudio.UnitSource:new(unit, XAudio.Buffer:new(snd_path_2))
					end
					source_1 = XAudio.Source:new(XAudio.Buffer:new(snd_path))
				end
			else
				if snd_path_2 then 
					source_2 = XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path_2))
				end
				source_1 = XAudio.UnitSource:new(XAudio.PLAYER, XAudio.Buffer:new(snd_path))
			end
		else
			if snd_path_2 then 
				source_2 = XAudio.Source:new(XAudio.Buffer:new(snd_path_2))
			end
			source_1 = XAudio.Source:new(XAudio.Buffer:new(snd_path))
		end
		
		
		if source_1 then 
			source_1:set_auto_pause(not no_pause)
			source_1:set_volume(volume)
			table.insert(self._cache.sound_sources,#self._cache.sound_sources + 1,source_1)
		end
		if source_2 then 
			source_2:set_auto_pause(not no_pause)
			source_2:set_volume(volume_2)
			table.insert(self._cache.sound_sources,#self._cache.sound_sources + 1,source_2)
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
					self:animate_stop(panel)
					panel:parent():remove(panel)
				end
				table.remove(cache.hitmarkers,i)
			end
		end
	end
	
	self:RemoveAllHitsounds()
	
	cache.player_unit = nil
	cache.underbarrel = {}
--	cache.weapons = {}
	cache.bloom = 0
	cache.num_hitmarkers = 0
end

function AdvancedCrosshair:CheckCrosshair(override_params) --deprecated in v33; use UpdateCrosshair() instead from now on
end

function AdvancedCrosshair:UpdateCrosshair(t,dt,override_params)
	if not self:IsCrosshairEnabled() then 
		return
	end
	override_params = override_params or {}
	
	local gsm = _G.game_state_machine
	if gsm and gsm:verify_game_state(GameStateFilters.any_ingame) then
		local player = managers.player:local_player()
		if alive(player) then 
			local hidden = false
			
			local current_state = override_params.current_state or player:movement():current_state()
			local state_name = override_params.state_name or player:movement():current_state_name()
			local is_in_steelsight = current_state:in_steelsight() 
			
			local inventory = player:inventory()
			local equipped_index = inventory:equipped_selection()
			local equipped_unit = inventory:equipped_unit()
			
			if equipped_unit then 
				local current_firemode = equipped_unit:base():fire_mode()
				local weapon_base = equipped_unit:base()
							
				--for the burstfire mod
				--probably obsolete now that burstfire is a game feature
				if weapon_base.in_burst_mode and weapon_base:in_burst_mode() then
					current_firemode = "burst"
				end
				
				local new_current_data
				
				local weapon_data = self._cache.weapons[tostring(equipped_unit:key())]
				if not weapon_data then 
		--			self:log("ERROR! Weapon data for weapon " .. tostring(weapon_base:get_name_id()) .. " in slot " .. tostring(equipped_index) .. " not found!",{color=Color.red})
	--this can happen at the start of the heist when the playerstate is changed for the first time, before AdvancedCrosshair is initialized
					return
				end
				--fire_mode
				local underbarrel_base = weapon_base:gadget_overrides_weapon_functions()
				if underbarrel_base then 
					local underbarrel = weapon_data.underbarrels[tostring(underbarrel_base)]
					if underbarrel then 
						current_firemode = underbarrel_base:fire_mode()
						new_current_data = underbarrel.firemodes[current_firemode]
					end
				end
				current_firemode = override_params.firemode or current_firemode

				new_current_data = new_current_data or weapon_data.firemodes[current_firemode]
				
				if new_current_data and (new_current_data ~= self._cache.current_crosshair_data) then 
					self._cache.current_crosshair_data.panel:hide()
					self._cache.current_crosshair_data = new_current_data
					
				end
				
				local ads_behavior = self._cache.current_crosshair_data.settings.ads_behavior
				if ads_behavior == 2 and is_in_steelsight then 
					hidden = true
				elseif ads_behavior == 3 and not is_in_steelsight then
					hidden = true
				elseif self.settings.crosshair_hide_while_interacting and (current_state:_interacting() or current_state._use_item_expire_t) then
					hidden = true
				elseif self.settings.crosshair_hide_while_meleeing and current_state:_is_meleeing() then
					hidden = true
				elseif self.settings.crosshair_hide_while_grenading and current_state:_is_throwing_projectile() then
					hidden = true
				elseif self.settings.crosshair_hide_while_inspecting and current_state:_is_cash_inspecting(t) then
					hidden = true
				elseif self.settings.crosshair_hide_while_hitmarker and #self._cache.hitmarkers > 0 then
					hidden = true
	--			elseif is_changing_weapon then 
				elseif self.settings.crosshair_hide_while_reloading and current_state:_is_reloading() then
					hidden = true
				elseif self.settings.crosshair_hide_while_running and current_state:running() and not weapon_base:run_and_shoot_allowed() then 
					hidden = true
				end
				
	--			hidden = hidden or current_state:_is_reloading() or current_state:_changing_weapon() or current_state:_is_meleeing() or current_state._use_item_expire_t or current_state:_interacting() or current_state:_is_throwing_projectile() or current_state:_is_deploying_bipod() or current_state._menu_closed_fire_cooldown > 0 or current_state:is_switching_stances()

				local state_allowed = self:CrosshairAllowedInState(state_name)
				if state_allowed ~= nil then 
					hidden = hidden or not state_allowed
				end
			end
			
			
			
			self._cache.current_crosshair_data.panel:set_visible(not hidden)
			return
		end
	end
	if self._cache.current_crosshair_data and self._cache.current_crosshair_data.panel and alive(self._cache.current_crosshair_data.panel) then
		self._cache.current_crosshair_data.panel:set_visible(false)
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
	return math.clamp(bloom - (decay_mul * dt),0,1)
end

function AdvancedCrosshair:Update(t,dt)
--[[
	--animate update
	for object_id,data in pairs(self._animate_targets) do 
		local result
		if data.object and alive(data.object) then 
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
	end				
	--]]

	local player = self._cache.player_unit --this is checked after execution due to the apparent vanilla code execution order on custody:
	--1. on entered custody, playermanager listeners for "custody" are called, including ACH's custody listener, which removes all current crosshairs and their associated cached data
	--2. player unit is prepared and queued for deletion
	--3. in this update function, the player alive() check still passes for this frame; the premise that the crosshair is present when the player is present is broken, so ACH tries to modify (change color of, move, set visible, other panel/gui functions etc.) an invalid object
	--4. game crashes :(
	
	--this is speculation, mind you, but it's my hypothesis after receiving multiple user reports of crashing on entering custody, which for whatever reason I can't replicate. so. 
	if alive(player) then 
		
		local viewport_cam = managers.viewport:get_current_camera()
		if not viewport_cam then 
			return 
		end
		local viewport_cam_pos = managers.viewport:get_current_camera_position()
		local viewport_cam_rot = managers.viewport:get_current_camera_rotation()
		local viewport_cam_fwd = viewport_cam_rot:y()
		local ws = managers.hud._workspace
		
		local weapon_unit = player:inventory():equipped_unit()
		if not weapon_unit then 
			--this can happen when restarting the level
			return
		end
		
		
		if self:IsHitmarkerEnabled() then
			if self:UseHitmarkerHitPosition() then 
				for hitmarker_index,hitmarker in pairs(self._cache.hitmarkers) do 
					if hitmarker.position then 
						local h_dir = Vector3()
						local h_dir_normalized = Vector3()
						local h_p = ws:world_to_screen(viewport_cam,hitmarker.position)
						mvector3_set(h_dir, hitmarker.position)
						mvector3_subtract(h_dir, viewport_cam_pos)
						mvector3_set(h_dir_normalized, h_dir)
						mvector3_normalize(h_dir_normalized)
						
						local dot = mvector3_dot(viewport_cam_fwd, h_dir_normalized)
						if alive(hitmarker.panel) then 
							if dot < 0 or hitmarker.panel:outside(mvector3_x(h_p),mvector3_y(h_p)) then 
								hitmarker.panel:hide()
							else
								hitmarker.panel:show()
								hitmarker.panel:set_center(h_p.x,h_p.y)
							end
						end
					end
				end
			end
		end
		
		local state = player:movement():current_state()
--		local is_reloading = state:_is_reloading() 
--		local fire_forbidden = state:_changing_weapon() or state:_is_meleeing() or state._use_item_expire_t or state:_interacting() or state:_is_throwing_projectile() or state:_is_deploying_bipod() or state._menu_closed_fire_cooldown > 0 or state:is_switching_stances()
--i haven't decided whether or not to make bloom maximized for the duration of a reload like how halo reach/noblehud do


		
		--[[
--for special altimeter crosshair
		local player_pos = player:position()
			local cam_aim = viewport_cam:rotation():yaw()
			local cam_rot_a = viewport_cam:rotation():y()

			local compass_yaw = ((cam_aim + 90) / 180) - 1
	--]]

			
			
		
		if self:IsCrosshairEnabled() then 
			local current_crosshair_data = self._cache.current_crosshair_data
			if alive(self._crosshair_panel) and current_crosshair_data then
				local crosshair_td = self._crosshair_data[current_crosshair_data.crosshair_id]
				if crosshair_td and type(crosshair_td.update_func) == "function" then 
					local current_crosshair_panel = current_crosshair_data.panel
					crosshair_td.update_func(t,dt,{
						crosshair_data = crosshair_td,
						settings = current_crosshair_data.settings,
						weapon_base = current_crosshair_data.base,
						parts = current_crosshair_data.parts,
						panel_w = current_crosshair_panel:w(),
						panel_h = current_crosshair_panel:h()
					})
				end
				
				local outofrange_display_mode = self:GetCrosshairRangeMode()
				local use_dynamic_color = self:UseDynamicColor()
				local fwd_ray = state._fwd_ray	
				local focused_person = fwd_ray and fwd_ray.unit
				local weak_hit
				if outofrange_display_mode ~= self.OUTOFRANGE_DISPLAY_MODES.crosshair.disabled then 
					if alive(focused_person) and focused_person:character_damage() then 
						local weaponbase = weapon_unit:base()
						if weaponbase and weaponbase.is_weak_hit and fwd_ray and fwd_ray.distance then 
							weak_hit = weaponbase:is_weak_hit(fwd_ray.distance,player)
						end
					end
				end
				
				if outofrange_display_mode == self.OUTOFRANGE_DISPLAY_MODES.crosshair.color then 

					if weak_hit then 
						self:SetCrosshairColor(self.OUTOFRANGE_CROSSHAIR_COLOR)
					else
						self:SetCrosshairColor(current_crosshair_data.color)
					end
				else
					if use_dynamic_color then 
						local crosshair_color = current_crosshair_data.color
						if alive(focused_person) then
							if focused_person:character_damage() then 
								if not focused_person:character_damage():dead() then 
									crosshair_color = current_crosshair_data.color
									local f_m = focused_person:movement()
									local f_t = f_m and f_m:team() and f_m:team().id
									if f_t then 
										if focused_person.brain and focused_person:brain() and focused_person:brain().is_current_logic and focused_person:brain():is_current_logic("intimidated") then 
											f_t = "converted_enemy"
										end
										crosshair_color = self:GetColorByTeam(f_t)
									end
								end
							elseif focused_person:base() and focused_person:base().can_apply_tape_loop and focused_person:base():can_apply_tape_loop() then 	
								crosshair_color = self:GetColorByTeam("law1")
							end
						end
						self:SetCrosshairColor(crosshair_color)
					end
					if outofrange_display_mode == self.OUTOFRANGE_DISPLAY_MODES.crosshair.size then
						if weak_hit then 
							local outofrange_scale = self.OUTOFRANGE_CROSSHAIR_SCALE
							if current_crosshair_data.range_scale ~= outofrange_scale then 
								current_crosshair_data.range_scale = outofrange_scale
								self:SetCrosshairScale(outofrange_scale)
							end
						else
							if current_crosshair_data.range_scale then 
								current_crosshair_data.range_scale = nil
								self:SetCrosshairScale(1)
							end
						end
					elseif outofrange_display_mode == self.OUTOFRANGE_DISPLAY_MODES.crosshair.alpha then 
						--not implemented
						if weak_hit then 
							local outofrange_alpha = self.OUTOFRANGE_CROSSHAIR_ALPHA
							if current_crosshair_data.range_alpha ~= outofrange_alpha then 
								current_crosshair_data.range_alpha = outofrange_alpha
								self:SetCrosshairAlpha(outofrange_alpha)
							end
						else
							if current_crosshair_data.range_alpha then 
								current_crosshair_data.range_alpha = nil
								self:SetCrosshairAlpha(1)
							end
						end
					end
				end

				if self:UseCrosshairShake() then 
					local crosshair_stability = (fwd_ray and fwd_ray.distance or 1000) * self:GetCrosshairStability() --fwd_ray.length
					--theoretically, the raycast position (assuming perfect accuracy) at [crosshair_stability] meters;
					--practically, the higher the number, the less sway shake (to a certain extent)
					local c_p = ws:world_to_screen(viewport_cam,state:get_fire_weapon_position() + (state:get_fire_weapon_direction() * crosshair_stability))
					local c_w = (c_p.x or 0)
					local c_h = (c_p.y or 0)
					--[[
						local screen_center_x,screen_center_y = self._crosshair_panel:center()
						if math.abs(screen_center_x - c_w) < 1 then 
							c_w = 0
						end
						if math.abs(screen_center_y - c_h) < 1 then 
							c_h = 0
						end
					--]]
					self:SetCrosshairCenter(c_w,c_h)
				end

				--crosshair bloom
				local recoil_bloom = 0
				local stance_bloom = 0
				local bloom_any
				if current_crosshair_data.settings.use_bloom then 
					bloom_any = true
					
					recoil_bloom = self._cache.bloom
					if self._cache.bloom > 0 then 
						recoil_bloom = self:DecayBloom(recoil_bloom,t,dt)
						self._cache.bloom = recoil_bloom
					end
					
					if state:_changing_weapon() then
						recoil_bloom = 0
					end
				end
				if self:UseCrosshairMovementBloom() then
					bloom_any = true
					
					stance_bloom = self._cache.stance_bloom
					
					local BLOOM_STATE_VALUES = self.CROSSHAIR_BLOOM_STATE_VALUES
					local state_data = state._state_data
					local is_moving = state._moving
					
					local bloom_rate
					local bloom_max = 0
					if state:running() then
						if state._is_jumping then
							bloom_max = BLOOM_STATE_VALUES.RUNNING_AIR_MAX
						else
							bloom_max = BLOOM_STATE_VALUES.RUNNING_STANDARD_MAX
						end
					elseif state_data.on_zipline then
						is_moving = true
						bloom_rate = 100
						bloom_max = BLOOM_STATE_VALUES.ZIPLINING_STANDARD_MAX
					else
						if is_moving then
							if state._is_jumping then
								bloom_max = BLOOM_STATE_VALUES.WALKING_AIR_MAX
							elseif state_data.ducking then
								bloom_max = BLOOM_STATE_VALUES.WALKING_CROUCH_MAX
							else
								bloom_max = BLOOM_STATE_VALUES.WALKING_STANDARD_MAX
							end
						else
							if state._is_jumping then
								bloom_max = BLOOM_STATE_VALUES.WALKING_AIR_MAX
							elseif state_data.ducking then
								bloom_max = BLOOM_STATE_VALUES.STATION_CROUCH_MAX
							else
								bloom_max = BLOOM_STATE_VALUES.STATION_STANDARD_MAX
							end
						end
					end
					if state:in_steelsight() then
						bloom_max = bloom_max + BLOOM_STATE_VALUES.STEELSIGHT_ADD
					end
					
					local delta_bloom = bloom_max - stance_bloom
					local delta_abs = math.abs(delta_bloom)
					bloom_rate = bloom_rate or (BLOOM_STATE_VALUES.BLOOM_SPEED * dt * math.sign(delta_bloom))
					
					if delta_abs > 0 then
						--not at target state bloom
						if math.abs(bloom_rate) > delta_abs then
							stance_bloom = bloom_max
						else
							stance_bloom = stance_bloom + bloom_rate
						end
					else
						--at target state bloom
					end
					self._cache.stance_bloom = stance_bloom
				end
				
				if bloom_any then
					self:SetCrosshairBloom(recoil_bloom + stance_bloom)
				end
			end
			
		end
	else
	--[[
		if self:IsCrosshairEnabled() then 
			self:OnPlayerManagerOnEnterCustody()
		end
		--]]
	end
	self._cache.player_unit = managers.player:local_player()
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
			if not (self.settings.crosshairs[category] and self.settings.crosshairs[category][firemode]) then 
				self:log("ERROR: GetCrosshairType() Bad category [" .. tostring(category) .. "] / firemode [" .. tostring(firemode) .. "]")
				return self.DEFAULT_CROSSHAIR_OPTIONS.crosshair_id
			end
			
			local crosshair_setting = self.settings.crosshairs[category][firemode]
			if not crosshair_setting.overrides_global then 
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
		--settings I/O
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
	local prev_version = 0
	local new_version = self.default_settings.ach_save_version
	if file then
		local settings_from_file = json.decode(file:read("*all"))
		prev_version = settings_from_file.ach_save_version or prev_version
		
		self:CheckSaveDataForDeprecatedValues(prev_version,new_version,settings_from_file)
		
		for k, v in pairs(settings_from_file) do
			self.settings[k] = v
		end
		
	else
		self:Save()
	end
end

--if i ever need to make changes to ACH save data, here is where i'll do it
function AdvancedCrosshair:CheckSaveDataForDeprecatedValues(prev_version,new_version,save_data)

	--version-to-version specific changes are also possible
	if prev_version ~= new_version then 
	
		--check for missing categories (namely akimbos, in ACH v27)
		if prev_version < 4 then 
			for _,category in ipairs(AdvancedCrosshair.VALID_WEAPON_CATEGORIES) do 
				if not save_data.crosshairs[category] then 
					save_data.crosshairs[category] = {}
					for _,firemode in pairs(self.VALID_WEAPON_FIREMODES) do 
						save_data.crosshairs[category][firemode] = table.deep_map_copy(self.DEFAULT_CROSSHAIR_OPTIONS)
					end
				end
			end
		end
		if save_data.crosshairs then 
			for category,category_data in pairs(save_data.crosshairs) do
				
				if prev_version < 3 then
					for _,firemode in pairs(self.VALID_WEAPON_FIREMODES) do 
						--add firemode-specific preferences for any missing firemodes pre-v26 (specifically volley from U228)
						if not category_data[firemode] then 
							category_data[firemode] = table.deep_map_copy(self.DEFAULT_CROSSHAIR_OPTIONS)
						end
					end
				end
				
				if prev_version < 2 then
					for firemode,firemode_data in pairs(category_data) do 
						--transfer "hide on ads" settings for users with save data pre-v21
						local hide_on_ads = firemode_data.hide_on_ads
						if hide_on_ads then 
							firemode_data.hide_on_ads = nil
							firemode_data.ads_behavior = 2 --hide when ads
						else
							firemode_data.ads_behavior = 1 --no special ads behavior
						end
					end
				end
			end
		end
		
		--transfer "hide on ads" settings for users with save data pre-v21
		--(for global crosshair, which is stored at a different depth)
		if prev_version < 2 then 
			local global_crosshair_data = save_data.crosshair_global
			if global_crosshair_data then 
				local hide_on_ads = global_crosshair_data.hide_on_ads
				if hide_on_ads then 
					global_crosshair_data.hide_on_ads = nil
					global_crosshair_data.ads_behavior = 2 --hide when ads
				else
					global_crosshair_data.ads_behavior = 1 --no special ads behavior
				end
			end
		end
		
		
		
		
		save_data.ach_save_version = new_version
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
AdvancedCrosshair.misc_menu_id = "ach_menu_misc" --made with json, this is just for reference
AdvancedCrosshair.compat_menu_id = "ach_menu_compat" --made with json, this is just for reference
AdvancedCrosshair.reset_menu_id = "ach_menu_reset" --made with json, this is just for reference
AdvancedCrosshair.crosshairs_categories_submenu_id = "ach_menu_crosshairs_categories"
AdvancedCrosshair.crosshairs_categories_global_id = "ach_menu_crosshairs_global"
AdvancedCrosshair.customization_menus = {}
AdvancedCrosshair.crosshair_preview_data = nil
--AdvancedCrosshair.customization_menu_callbacks = {}
AdvancedCrosshair.crosshair_id_by_index = {}
AdvancedCrosshair.hitmarker_id_by_index = {}
AdvancedCrosshair.hitsound_id_by_index = {}
Hooks:Add("MenuManagerSetupCustomMenus", "ach_MenuManagerSetupCustomMenus", function(menu_manager, nodes)
	
	MenuHelper:NewMenu(AdvancedCrosshair.main_menu_id)
	MenuHelper:NewMenu(AdvancedCrosshair.crosshairs_menu_id)
	MenuHelper:NewMenu(AdvancedCrosshair.hitmarkers_menu_id)
	MenuHelper:NewMenu(AdvancedCrosshair.hitsounds_menu_id)
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

Hooks:Add("MenuManagerPopulateCustomMenus", "ach_MenuManagerPopulateCustomMenus", function(menu_manager, nodes)

	AdvancedCrosshair:log("Loading default addons...")
	
	for id,data in pairs(AdvancedCrosshair._default_crosshairs) do 
		AdvancedCrosshair:AddCustomCrosshair(id,data)
	end
	
	for id,data in pairs(AdvancedCrosshair._default_hitmarkers) do 
		AdvancedCrosshair:AddCustomHitmarker(id,data)
	end
	
	AdvancedCrosshair:log("Loading custom addons...")
	
	Hooks:Call("ACH_LoadAllAddons")
	AdvancedCrosshair:LoadAllAddons() --load custom crosshairs, hitmarkers, and hitsounds


	
	AdvancedCrosshair:log("Addon loading complete.")
	for category,category_data in pairs(AdvancedCrosshair.settings.crosshairs) do 
		for firemode,firemode_data in pairs(category_data) do 
			if not (firemode_data.crosshair_id and AdvancedCrosshair._crosshair_data[firemode_data.crosshair_id]) then 
				AdvancedCrosshair:log("Replacing invalid crosshair setting " .. category .. "/" .. firemode .. " from " .. tostring(firemode_data.crosshair_id) .. " to " .. AdvancedCrosshair.DEFAULT_CROSSHAIR_OPTIONS.crosshair_id)
				firemode_data.crosshair_id = AdvancedCrosshair.DEFAULT_CROSSHAIR_OPTIONS.crosshair_id
			end
		end
	end
	if not AdvancedCrosshair._crosshair_data[AdvancedCrosshair.settings.crosshair_global.crosshair_id] then 
		AdvancedCrosshair.settings.crosshair_global.crosshair_id = AdvancedCrosshair.DEFAULT_CROSSHAIR_OPTIONS.crosshair_id
		AdvancedCrosshair:log("Replacing invalid global crosshair setting from " .. tostring(AdvancedCrosshair.settings.crosshair_global.crosshair_id) .. " to " .. AdvancedCrosshair.DEFAULT_CROSSHAIR_OPTIONS.crosshair_id)
	end
	
	
	for _,key in pairs(AdvancedCrosshair.setting_categories.hitmarker_ids) do 
		if not (AdvancedCrosshair.settings[key] and AdvancedCrosshair._hitmarker_data[AdvancedCrosshair.settings[key]]) then 
			AdvancedCrosshair:log("Replacing invalid hitmarker setting from " .. key .. " = " .. tostring(AdvancedCrosshair.settings[key]) .. " to " ..  AdvancedCrosshair.default_settings[key])
			AdvancedCrosshair.settings[key] = AdvancedCrosshair.default_settings[key]
		end
	end
	
	for _,key in pairs(AdvancedCrosshair.setting_categories.hitsound_ids) do 
		if not (AdvancedCrosshair.settings[key] and AdvancedCrosshair._hitsound_data[AdvancedCrosshair.settings[key]]) then 
			AdvancedCrosshair:log("Replacing invalid hitmarker setting from " .. key .. " = " .. tostring(AdvancedCrosshair.settings[key]) .. " to " ..  AdvancedCrosshair.default_settings[key])
			AdvancedCrosshair.settings[key] = AdvancedCrosshair.default_settings[key]
		end
	end
	
	
	
	
--crosshair/hitmarker selections are saved as string keys to the data in question instead of indices, since the order is not guaranteed
--so generate a number index/string key lookup table for the menu to reference,
--since multiplechoice menus can only use number indices (afaik)


--for crosshairs:
	local crosshair_items
	AdvancedCrosshair.crosshair_id_by_index,crosshair_items = AdvancedCrosshair:SortAddons(AdvancedCrosshair._crosshair_data,"alphabetical")
	
--for hitmarkers:
	local hitmarker_kill_bitmap_index = 1
	local hitmarker_hit_bitmap_index = 1
	local hitmarker_items
	AdvancedCrosshair.hitmarker_id_by_index,hitmarker_items = AdvancedCrosshair:SortAddons(AdvancedCrosshair._hitmarker_data,"alphabetical")
	
	for h_i,id in ipairs(AdvancedCrosshair.hitmarker_id_by_index) do 
		if id == AdvancedCrosshair.settings.hitmarker_kill_id then
			hitmarker_kill_bitmap_index = h_i
		end
		if id == AdvancedCrosshair.settings.hitmarker_hit_id then 
			hitmarker_hit_bitmap_index = h_i
		end
	end
	
	local hs_i = 1
	local hitsound_items
	AdvancedCrosshair.hitsound_id_by_index,hitsound_items = AdvancedCrosshair:SortAddons(AdvancedCrosshair._hitsound_data,"alphabetical")
	local hitsound_hit_bodyshot_index = 1
	local hitsound_hit_headshot_index = 1
	local hitsound_hit_bodyshot_crit_index = 1
	local hitsound_hit_headshot_crit_index = 1
	local hitsound_kill_headshot_index = 1
	local hitsound_kill_bodyshot_index = 1
	local hitsound_kill_bodyshot_crit_index = 1
	local hitsound_kill_headshot_crit_index = 1
	for hs_i,id in ipairs(AdvancedCrosshair.hitsound_id_by_index) do 
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
	end
	
--hitmarker menus	
	MenuHelper:AddToggle({
		id = "ach_hitmarkers_master_enable",
		title = "menu_ach_hitmarkers_master_enable_title",
		desc = "menu_ach_hitmarkers_master_enable_desc",
		callback = "callback_ach_hitmarkers_master_enable",
		value = AdvancedCrosshair.settings.hitmarker_enabled,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 31
	})
	
	MenuHelper:AddMultipleChoice({
		id = "ach_hitmarkers_outofrange_mode",
		title = "menu_ach_hitmarkers_outofrange_mode_title",
		desc = "menu_ach_hitmarkers_outofrange_mode_desc",
		callback = "callback_ach_hitmarkers_set_outofrange_mode",
		items = {
			"menu_ach_outofrange_disabled",
			"menu_ach_outofrange_size"
--,			"menu_ach_outofrange_color",
--			"menu_ach_outofrange_alpha"
		},
		value = AdvancedCrosshair.settings.hitmarker_outofrange_mode,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 30
	})
	
	MenuHelper:AddToggle({
		id = "ach_hitmarkers_set_3d_enabled",
		title = "menu_ach_hitmarkers_set_3d_enabled_title",
		desc = "menu_ach_hitmarkers_set_3d_enabled_desc",
		callback = "callback_ach_hitmarkers_set_3d_enabled",
		value = AdvancedCrosshair.settings.use_hitpos,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 29
	})
	
	MenuHelper:AddToggle({
		id = "ach_hitmarkers_set_melee_enabled",
		title = "menu_ach_hitmarkers_set_melee_enabled_title",
		desc = "menu_ach_hitmarkers_set_melee_enabled_desc",
		callback = "callback_ach_hitmarkers_set_melee_enabled",
		value = AdvancedCrosshair.settings.hitmarker_allow_melee,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 28
	})
	
	MenuHelper:AddMultipleChoice({
		id = "ach_hitmarkers_set_limit_behavior",
		title = "menu_ach_hitmarkers_set_limit_behavior_title",
		desc = "menu_ach_hitmarkers_set_limit_behavior_desc",
		callback = "callback_ach_hitmarkers_set_limit_behavior",
		items = {
			"menu_ach_limit_hard",
			"menu_ach_limit_replace",
			"menu_ach_limit_unlimited"
		},
		value = AdvancedCrosshair.settings.hitmarker_limit_behavior,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 27
	})
	
	MenuHelper:AddSlider({
		id = "ach_hitmarkers_set_max_count",
		title = "menu_ach_hitmarkers_set_max_count_title",
		desc = "menu_ach_hitmarkers_set_max_count_desc",
		callback = "callback_ach_hitmarkers_set_max_count",
		value = AdvancedCrosshair.settings.hitmarker_max_count,
		default_value = AdvancedCrosshair.default_settings.hitmarker_max_count,
		min = 1,
		max = 10,
		step = 1,
		show_value = true,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 26
	})
	
	
	MenuHelper:AddDivider({
		id = "ach_hitmarkers_div_1",
		size = 16,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 25
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitmarkers_hit_set_bitmap",
		title = "menu_ach_hitmarkers_hit_set_bitmap_title",
		desc = "menu_ach_hitmarkers_hit_set_bitmap_desc",
		callback = "callback_ach_hitmarkers_hit_set_bitmap",
		items = table.deep_map_copy(hitmarker_items),
		value = hitmarker_hit_bitmap_index,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 24
	})
	MenuHelper:AddSlider({
		id = "ach_hitmarkers_hit_set_alpha",
		title = "menu_ach_hitmarkers_hit_set_alpha_title",
		desc = "menu_ach_hitmarkers_hit_set_alpha_desc",
		callback = "callback_ach_hitmarkers_hit_set_alpha",
		value = AdvancedCrosshair.settings.hitmarker_hit_alpha,
		default_value = AdvancedCrosshair.default_settings.hitmarker_hit_alpha,
		min = 0,
		max = 1,
		step = 0.01,
		show_value = true,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 23
	})
	MenuHelper:AddSlider({
		id = "ach_hitmarkers_hit_set_scale",
		title = "menu_ach_hitmarkers_hit_set_scale_title",
		desc = "menu_ach_hitmarkers_hit_set_scale_desc",
		callback = "callback_ach_hitmarkers_hit_set_scale",
		value = AdvancedCrosshair.settings.hitmarker_hit_scale,
		default_value = AdvancedCrosshair.default_settings.hitmarker_hit_scale,
		min = 0,
		max = 3,
		step = 0.1,
		show_value = true,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 22
	})
	MenuHelper:AddSlider({
		id = "ach_hitmarkers_hit_set_duration",
		title = "menu_ach_hitmarkers_hit_set_duration_title",
		desc = "menu_ach_hitmarkers_hit_set_duration_desc",
		callback = "callback_ach_hitmarkers_hit_set_duration",
		value = AdvancedCrosshair.settings.hitmarker_hit_duration,
		default_value = AdvancedCrosshair.default_settings.hitmarker_hit_duration,
		min = 0,
		max = 3,
		step = 0.25,
		show_value = true,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 21
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
--			"menu_ach_blend_mode_screen"
		},
		value = AdvancedCrosshair.settings.hitmarker_hit_blend_mode,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 20
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_hit_set_bodyshot_color",
		title = "menu_ach_hitmarkers_hit_set_bodyshot_color_title",
		desc = "menu_ach_hitmarkers_hit_set_bodyshot_color_desc",
		callback = "callback_ach_hitmarkers_hit_set_bodyshot_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 19
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_hit_set_bodyshot_crit_color",
		title = "menu_ach_hitmarkers_hit_set_bodyshot_crit_color_title",
		desc = "menu_ach_hitmarkers_hit_set_bodyshot_crit_color_desc",
		callback = "callback_ach_hitmarkers_hit_set_bodyshot_crit_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 18
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_hit_set_headshot_color",
		title = "menu_ach_hitmarkers_hit_set_headshot_color_title",
		desc = "menu_ach_hitmarkers_hit_set_headshot_color_desc",
		callback = "callback_ach_hitmarkers_hit_set_headshot_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 17
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_hit_set_headshot_crit_color",
		title = "menu_ach_hitmarkers_hit_set_headshot_crit_color_title",
		desc = "menu_ach_hitmarkers_hit_set_headshot_crit_color_desc",
		callback = "callback_ach_hitmarkers_hit_set_headshot_crit_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 16
	})
	MenuHelper:AddDivider({
		id = "ach_hitmarkers_div_2",
		size = 8,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 15
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitmarkers_kill_set_bitmap",
		title = "menu_ach_hitmarkers_kill_set_bitmap_title",
		desc = "menu_ach_hitmarkers_kill_set_bitmap_desc",
		callback = "callback_ach_hitmarkers_kill_set_bitmap",
		items = table.deep_map_copy(hitmarker_items),
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		value = hitmarker_kill_bitmap_index,
		priority = 14
	})
	MenuHelper:AddSlider({
		id = "ach_hitmarkers_kill_set_alpha",
		title = "menu_ach_hitmarkers_kill_set_alpha_title",
		desc = "menu_ach_hitmarkers_kill_set_alpha_desc",
		callback = "callback_ach_hitmarkers_kill_set_alpha",
		value = AdvancedCrosshair.settings.hitmarker_kill_alpha,
		default_value = AdvancedCrosshair.default_settings.hitmarker_kill_alpha,
		min = 0,
		max = 1,
		step = 0.01,
		show_value = true,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 13
	})
	MenuHelper:AddSlider({
		id = "ach_hitmarkers_kill_set_scale",
		title = "menu_ach_hitmarkers_kill_set_scale_title",
		desc = "menu_ach_hitmarkers_kill_set_scale_desc",
		callback = "callback_ach_hitmarkers_kill_set_scale",
		value = AdvancedCrosshair.settings.hitmarker_kill_scale,
		default_value = AdvancedCrosshair.default_settings.hitmarker_kill_scale,
		min = 0,
		max = 3,
		step = 0.1,
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
		default_value = AdvancedCrosshair.default_settings.hitmarker_kill_duration,
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
--			"menu_ach_blend_mode_screen"
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
	MenuHelper:AddToggle({
		id = "ach_hitmarkers_preview_toggle_loop",
		title = "menu_ach_hitmarkers_preview_toggle_loop_title",
		desc = "menu_ach_hitmarkers_preview_toggle_loop_desc",
		callback = "callback_ach_hitmarkers_preview_toggle_loop",
		value = AdvancedCrosshair.hitmarker_menu_preview_loops,
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
					local function clbk_colorpicker (color,palettes,success)
						--set preview color
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
							crosshair_setting.color = color:to_hex()
							AdvancedCrosshair:Save()
						end
						
						--save palette swatches to settings
						if palettes then 
							AdvancedCrosshair:SetPaletteCodes(palettes)
						end
					end
					
					AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(Color(crosshair_setting.color),clbk_colorpicker,clbk_colorpicker)
					
				elseif not _G.ColorPicker then
					AdvancedCrosshair.clbk_missing_colorpicker_prompt()
				end
			end
			
			--set alpha
			local set_crosshair_alpha_callback_name = firemode_menu_name .. "_set_crosshair_alpha"
			MenuCallbackHandler[set_crosshair_alpha_callback_name] = function(self,item)
				local alpha = tonumber(item:value())
				crosshair_setting.alpha = alpha
				AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
				local preview_data = AdvancedCrosshair.crosshair_preview_data
				local parent_panel = preview_data and preview_data.panel
				local crosshair_data = preview_data and AdvancedCrosshair._crosshair_data[tostring(preview_data.crosshair_id)]
				if preview_data and crosshair_data and preview_data.parts and alive(parent_panel) then 
					parent_panel:child("crosshair_preview_panel"):set_alpha(alpha)
				end
				AdvancedCrosshair:Save()
			end
			
			--set size scale
			local set_crosshair_scale_callback_name = firemode_menu_name .. "_set_crosshair_scale"
			MenuCallbackHandler[set_crosshair_scale_callback_name] = function(self,item)
				local scale = tonumber(item:value())
				crosshair_setting.scale = scale
				AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
				AdvancedCrosshair:Save()
			end
			
			--enable/disable bloom
			local enable_crosshair_bloom_callback_name = firemode_menu_name .. "_set_bloom_enabled"
			MenuCallbackHandler[enable_crosshair_bloom_callback_name] = function(self,item)
				crosshair_setting.use_bloom = item:value() == "on"
				AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
				AdvancedCrosshair:Save()
			end
			
			--set ads behavior
			local set_ads_behavior_callback_name = firemode_menu_name .. "_set_ads_behavior"
			MenuCallbackHandler[set_ads_behavior_callback_name] = function(self,item)
				crosshair_setting.ads_behavior = tonumber(item:value())
				AdvancedCrosshair:Save()
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
			
			MenuHelper:AddButton({
				id = "id_header_empty_button_" .. firemode_menu_name,
				title = managers.localization:text("menu_weapon_category_" .. category) .. ": " .. managers.localization:text("menu_weapon_firemode_" .. firemode),
				desc = managers.localization:text("menu_ach_crosshair_generic_header_desc"),
				localized = false,
				callback = "callback_ach_empty_button",
				menu_id = firemode_menu_name,
				disabled = true,
				priority = 12
			})
			
			MenuHelper:AddDivider({
				id = "divider_1_" .. firemode_menu_name,
				size = 8,
				menu_id = firemode_menu_name,
				priority = 11
			})
			
			MenuHelper:AddToggle({
				id = "id_" .. set_crosshair_override_global_callback_name,
				title = "menu_ach_set_override_title",
				desc = "menu_ach_set_override_desc",
				callback = set_crosshair_override_global_callback_name,
				value = crosshair_setting.overrides_global,
				menu_id = firemode_menu_name,
				priority = 10
			})
			
			MenuHelper:AddMultipleChoice({
				id = "id_" .. set_crosshair_type_callback_name,
				title = "menu_ach_set_bitmap_title",
				desc = "menu_ach_set_bitmap_desc",
				callback = set_crosshair_type_callback_name,
				items = table.deep_map_copy(crosshair_items),
				value = crosshair_index,
				menu_id = firemode_menu_name,
				priority = 9
			})
			
			MenuHelper:AddButton({
				id = "id_" .. set_crosshair_color_callback_name,
				title = "menu_ach_set_color_title",
				desc = "menu_ach_set_color_desc",
				callback = set_crosshair_color_callback_name,
				menu_id = firemode_menu_name,
				priority = 8
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
				priority = 7
			})
			
			MenuHelper:AddSlider({
				id = "id_" .. set_crosshair_scale_callback_name,
				title = "menu_ach_set_scale_title",
				desc = "menu_ach_set_scale_desc",
				callback = set_crosshair_scale_callback_name,
				value = crosshair_setting.scale or 1,
				min = 0,
				max = 3,
				step = 0.1,
				show_value = true,
				menu_id = firemode_menu_name,
				priority = 6
			})
			
			MenuHelper:AddToggle({
				id = "id_" .. enable_crosshair_bloom_callback_name,
				title = "menu_ach_set_bloom_enabled_title",
				desc = "menu_ach_set_bloom_enabled_desc",
				callback = enable_crosshair_bloom_callback_name,
				value = crosshair_setting.use_bloom,
				menu_id = firemode_menu_name,
				priority = 5
			})
			
			MenuHelper:AddMultipleChoice({
				id = "id_" .. set_ads_behavior_callback_name,
				title = "menu_ach_set_ads_behavior_title",
				desc = "menu_ach_set_ads_behavior_desc",
				callback = set_ads_behavior_callback_name,
				items = {
					"menu_ach_crosshair_ads_behavior_none",
					"menu_ach_crosshair_ads_behavior_hide",
					"menu_ach_crosshair_ads_behavior_show"
				},
				value = crosshair_setting.ads_behavior,
				menu_id = firemode_menu_name,
				priority = 4
			})
			
			MenuHelper:AddDivider({
				id = "divider_2_" .. firemode_menu_name,
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
	end
	
	local global_crosshair_index = 1
	for _crosshair_index,_crosshair_id in ipairs(AdvancedCrosshair.crosshair_id_by_index) do 
		if _crosshair_id == AdvancedCrosshair.settings.crosshair_global.crosshair_id then 
			global_crosshair_index = _crosshair_index
			break
		end
	end
	
				
	MenuHelper:AddButton({
		id = "id_header_empty_button_global",
		title = "menu_ach_crosshair_global_header_title",
		desc = "menu_ach_crosshair_global_header_desc",
		callback = "callback_ach_empty_button",
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		disabled = true,
		priority = 10
	})
	
	MenuHelper:AddDivider({
		id = "divider_1_ach_menu_crosshairs_categories_global",
		size = 8,
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		priority = 9
	})
	
	MenuHelper:AddMultipleChoice({
		id = "id_ach_menu_crosshairs_categories_global_type",
		title = "menu_ach_set_bitmap_title",
		desc = "menu_ach_set_bitmap_desc",
		callback = "callback_ach_crosshairs_categories_global_type",
		items = table.deep_map_copy(crosshair_items),
		value = global_crosshair_index,
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		priority = 8
	})
	
	MenuHelper:AddButton({
		id = "id_ach_menu_crosshairs_categories_global_color",
		title = "menu_ach_set_color_title",
		desc = "menu_ach_set_color_desc",
		callback = "callback_ach_crosshairs_categories_global_color",
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		priority = 7
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
		priority = 6
	})
	
	MenuHelper:AddSlider({
		id = "id_ach_menu_crosshairs_categories_global_scale",
		title = "menu_ach_set_scale_title",
		desc = "menu_ach_set_scale_desc",
		callback = "callback_ach_crosshairs_categories_global_scale",
		value = AdvancedCrosshair.settings.crosshair_global.scale or 1,
		min = 0,
		max = 3,
		step = 0.1,
		show_value = true,
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		priority = 5
	})
	
	MenuHelper:AddToggle({
		id = "id_ach_menu_crosshairs_categories_global_set_bloom_enabled",
		title = "menu_ach_set_bloom_enabled_title",
		desc = "menu_ach_set_bloom_enabled_desc",
		callback = "callback_ach_crosshairs_categories_global_bloom_enabled",
		value = AdvancedCrosshair.settings.crosshair_global.use_bloom,
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		priority = 4
	})

	MenuHelper:AddMultipleChoice({
		id = "id_ach_menu_crosshairs_categories_global_set_ads_behavior",
		title = "menu_ach_set_ads_behavior_title",
		desc = "menu_ach_set_ads_behavior_desc",
		callback = "callback_ach_crosshairs_categories_global_ads_behavior",
		items = {
			"menu_ach_crosshair_ads_behavior_none",
			"menu_ach_crosshair_ads_behavior_hide",
			"menu_ach_crosshair_ads_behavior_show"
		},
		value = AdvancedCrosshair.settings.crosshair_global.ads_behavior,
		menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
		priority = 3
	})
	
	MenuHelper:AddDivider({
		id = "divider_2_ach_menu_crosshairs_categories_global",
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
		priority = 18
	})
	MenuHelper:AddToggle({
		id = "ach_crosshairs_general_master_enable",
		title = "menu_ach_crosshairs_general_master_enable_title",
		desc = "menu_ach_crosshairs_general_master_enable_desc",
		callback = "callback_ach_crosshairs_general_master_enable",
		value = AdvancedCrosshair.settings.crosshair_enabled,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 17
	})
	
	MenuHelper:AddMultipleChoice({
		id = "ach_crosshairs_general_outofrange_mode",
		title = "menu_ach_crosshairs_general_outofrange_mode_title",
		desc = "menu_ach_crosshairs_general_outofrange_mode_desc",
		callback = "callback_ach_crosshairs_general_set_outofrange_mode",
		items = {
			"menu_ach_outofrange_disabled",
			"menu_ach_outofrange_size"
--,			"menu_ach_outofrange_color",
--			"menu_ach_outofrange_alpha"
		},
		value = AdvancedCrosshair.settings.crosshair_outofrange_mode,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 16
	})
	
	
	MenuHelper:AddToggle({
		id = "ach_crosshairs_general_enable_shake",
		title = "menu_ach_crosshairs_general_enable_shake_title",
		desc = "menu_ach_crosshairs_general_enable_shake_desc",
		callback = "callback_ach_crosshairs_general_enable_shake",
		value = AdvancedCrosshair.settings.use_shake,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 15
	})
	MenuHelper:AddToggle({
		id = "ach_crosshairs_general_enable_use_movement_bloom",
		title = "menu_ach_crosshairs_general_enable_movement_bloom_title",
		desc = "menu_ach_crosshairs_general_enable_movement_bloom_desc",
		callback = "callback_ach_crosshairs_general_enable_movement_bloom",
		value = AdvancedCrosshair.settings.use_movement_bloom,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 14
	})
	MenuHelper:AddToggle({
		id = "ach_crosshairs_general_enable_dynamic_color",
		title = "menu_ach_crosshairs_general_enable_dynamic_color_title",
		desc = "menu_ach_crosshairs_general_enable_dynamic_color_desc",
		callback = "callback_ach_crosshairs_general_enable_dynamic_color",
		value = AdvancedCrosshair.settings.use_color,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 13
	})
	MenuHelper:AddButton({
		id = "ach_crosshairs_general_set_dynamic_color_enemy",
		title = "menu_ach_crosshairs_general_set_dynamic_color_enemy_title",
		desc = "menu_ach_crosshairs_general_set_dynamic_color_enemy_desc",
		callback = "callback_ach_crosshairs_general_set_dynamic_color_enemy",
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 12
	})
	MenuHelper:AddButton({
		id = "ach_crosshairs_general_set_dynamic_color_civilian",
		title = "menu_ach_crosshairs_general_set_dynamic_color_civilian_title",
		desc = "menu_ach_crosshairs_general_set_dynamic_color_civilian_desc",
		callback = "callback_ach_crosshairs_general_set_dynamic_color_civilian",
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 11
	})
	MenuHelper:AddButton({
		id = "ach_crosshairs_general_set_dynamic_color_teammate",
		title = "menu_ach_crosshairs_general_set_dynamic_color_teammate_title",
		desc = "menu_ach_crosshairs_general_set_dynamic_color_teammate_desc",
		callback = "callback_ach_crosshairs_general_set_dynamic_color_teammate",
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 10
	})
	MenuHelper:AddButton({
		id = "ach_crosshairs_general_set_dynamic_color_misc",
		title = "menu_ach_crosshairs_general_set_dynamic_color_misc_title",
		desc = "menu_ach_crosshairs_general_set_dynamic_color_misc_desc",
		callback = "callback_ach_crosshairs_general_set_dynamic_color_misc",
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 9
	})
	
	
	MenuHelper:AddDivider({
		id = "ach_crosshairs_general_divider_2",
		size = 16,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 8
	})
	
	MenuHelper:AddToggle({
		id = "ach_crosshair_general_hide_when_interacting",
		title = "menu_ach_crosshair_general_hide_when_interacting_title",
		desc = "menu_ach_crosshair_general_hide_when_interacting_desc",
		callback = "callback_ach_crosshairs_general_hide_while_interacting",
		value = AdvancedCrosshair.settings.crosshair_hide_while_interacting,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 7
	})
	MenuHelper:AddToggle({
		id = "ach_crosshair_general_hide_when_meleeing",
		title = "menu_ach_crosshair_general_hide_when_meleeing_title",
		desc = "menu_ach_crosshair_general_hide_when_meleeing_desc",
		callback = "callback_ach_crosshairs_general_hide_while_meleeing",
		value = AdvancedCrosshair.settings.crosshair_hide_while_meleeing,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 6
	})
	MenuHelper:AddToggle({
		id = "ach_crosshair_general_hide_when_grenading",
		title = "menu_ach_crosshair_general_hide_when_grenading_title",
		desc = "menu_ach_crosshair_general_hide_when_grenading_desc",
		callback = "callback_ach_crosshairs_general_hide_while_grenading",
		value = AdvancedCrosshair.settings.crosshair_hide_while_grenading,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 5
	})
	MenuHelper:AddToggle({
		id = "ach_crosshair_general_hide_when_reloading",
		title = "menu_ach_crosshair_general_hide_when_reloading_title",
		desc = "menu_ach_crosshair_general_hide_when_reloading_desc",
		callback = "callback_ach_crosshairs_general_hide_while_reloading",
		value = AdvancedCrosshair.settings.crosshair_hide_while_reloading,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 4
	})
	MenuHelper:AddToggle({
		id = "ach_crosshair_general_hide_when_running",
		title = "menu_ach_crosshair_general_hide_when_running_title",
		desc = "menu_ach_crosshair_general_hide_when_running_desc",
		callback = "callback_ach_crosshairs_general_hide_while_running",
		value = AdvancedCrosshair.settings.crosshair_hide_while_running,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 3
	})
	MenuHelper:AddToggle({
		id = "ach_crosshair_general_hide_when_inspecting",
		title = "menu_ach_crosshair_general_hide_when_inspecting_title",
		desc = "menu_ach_crosshair_general_hide_when_inspecting_desc",
		callback = "callback_ach_crosshairs_general_hide_while_inspecting",
		value = AdvancedCrosshair.settings.crosshair_hide_while_inspecting,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 2
	})
	MenuHelper:AddToggle({
		id = "ach_crosshair_general_hide_when_hitmarker",
		title = "menu_ach_crosshair_general_hide_when_hitmarker_title",
		desc = "menu_ach_crosshair_general_hide_when_hitmarker_desc",
		callback = "callback_ach_crosshairs_general_hide_while_hitmarker",
		value = AdvancedCrosshair.settings.crosshair_hide_while_hitmarker,
		menu_id = AdvancedCrosshair.crosshairs_menu_id,
		priority = 1
	})
	
	
	
	
	
	
	
	--all custom keybinds, except for those specified in a mod.txt, or those whose parent menus are a direct child of the blt mod options menu, will cause a crash when binding the key (reason unknown)
	--the calback does not seem to activate even when defined in the ach main menu
	--so this keybind will be defined in mod.txt until this issue is fixed
	--[[
	MenuHelper:AddKeybinding({
		id = "ach_crosshairs_toggle_crosshair_visibility",
		title = "menu_ach_toggle_crosshair_visibility_title",
		desc = "menu_ach_toggle_crosshair_visibility_desc",
		callback = "callback_ach_toggle_crosshair_visibility",
		connection_name = "ach_keybind_toggle_crosshair",
		binding = "num *",
		button = "num *",
		menu_id = AdvancedCrosshair.hitsounds_menu_id
		priority = 1
	})
	--]]
	
	
	--hitsounds	
	
	MenuHelper:AddToggle({
		id = "ach_hitsounds_master_enable",
		title = "menu_ach_hitsounds_master_enable_title",
		desc = "menu_ach_hitsounds_master_enable_desc",
		callback = "callback_ach_hitsounds_master_enable",
		value = AdvancedCrosshair.settings.hitsound_enabled,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 30
	})
	
	MenuHelper:AddToggle({
		id = "ach_hitsounds_set_suppress_doublesound_enabled",
		title = "menu_ach_hitsounds_set_suppress_doublesound_enabled_title",
		desc = "menu_ach_hitsounds_set_suppress_doublesound_enabled_desc",
		callback = "callback_ach_hitsounds_set_suppress_doublesound_enabled",
		value = AdvancedCrosshair.settings.hitsound_suppress_doublesound,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 29
	})
	
	MenuHelper:AddToggle({
		id = "ach_hitsounds_set_melee_enabled",
		title = "menu_ach_hitsounds_set_melee_enabled_title",
		desc = "menu_ach_hitsounds_set_melee_enabled_desc",
		callback = "callback_ach_hitsounds_set_melee_enabled",
		value = AdvancedCrosshair.settings.hitmarker_allow_melee,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 28
	})
	
	MenuHelper:AddToggle({
		id = "ach_hitsounds_set_positional_enabled",
		title = "menu_ach_hitsounds_set_positional_enabled_title",
		desc = "menu_ach_hitsounds_set_positional_enabled_desc",
		callback = "callback_ach_hitsounds_set_positional_enabled",
		value = AdvancedCrosshair.settings.use_hitsound_pos,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 27
	})
	
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_limit_behavior",
		title = "menu_ach_hitsounds_set_limit_behavior_title",
		desc = "menu_ach_hitsounds_set_limit_behavior_desc",
		callback = "callback_ach_hitsounds_set_limit_behavior",
		items = {
			"menu_ach_limit_hard",
			"menu_ach_limit_replace",
			"menu_ach_limit_unlimited"
		},
		value = AdvancedCrosshair.settings.hitsound_limit_behavior,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 26
	})
	
	
	MenuHelper:AddSlider({
		id = "ach_hitsounds_max_count",
		title = "menu_ach_hitsounds_max_count_title",
		desc = "menu_ach_hitsounds_max_count_desc",
		callback = "callback_ach_hitsounds_max_count",
		value = AdvancedCrosshair.settings.hitsound_max_count,
		min = 1,
		max = 10,
		step = 1,
		show_value = true,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 25
	})
	
	
	MenuHelper:AddDivider({
		id = "ach_hitsounds_divider_1",
		size = 24,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 24
	})
	
	
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_hit_bodyshot_type",
		title = "menu_ach_hitsounds_set_hit_bodyshot_type_title",
		desc = "menu_ach_hitsounds_set_hit_bodyshot_type_desc",
		callback = "callback_ach_hitsounds_set_hit_bodyshot_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_hit_bodyshot_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 23
	})
	MenuHelper:AddSlider({
		id = "ach_hitsounds_set_hit_bodyshot_volume",
		title = "menu_ach_hitsounds_set_hit_bodyshot_volume_title",
		desc = "menu_ach_hitsounds_set_hit_bodyshot_volume_desc",
		callback = "callback_ach_hitsounds_set_hit_bodyshot_volume",
		value = AdvancedCrosshair.settings.hitsound_hit_bodyshot_volume,
		min = 0,
		max = 1,
		step = 0.1,
		show_value = true,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 22
	})
	
	
	MenuHelper:AddDivider({
		id = "ach_hitsounds_divider_1",
		size = 8,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 21
	})
	
	
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_hit_headshot_type",
		title = "menu_ach_hitsounds_set_hit_headshot_type_title",
		desc = "menu_ach_hitsounds_set_hit_headshot_type_desc",
		callback = "callback_ach_hitsounds_set_hit_headshot_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_hit_headshot_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 20
	})
	MenuHelper:AddSlider({
		id = "ach_hitsounds_set_hit_headshot_volume",
		title = "menu_ach_hitsounds_set_hit_headshot_volume_title",
		desc = "menu_ach_hitsounds_set_hit_headshot_volume_desc",
		callback = "callback_ach_hitsounds_set_hit_headshot_volume",
		value = AdvancedCrosshair.settings.hitsound_hit_headshot_volume,
		min = 0,
		max = 1,
		step = 0.1,
		show_value = true,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 19
	})
	
	MenuHelper:AddDivider({
		id = "ach_hitsounds_divider_1",
		size = 8,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 18
	})
	
	
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_hit_bodyshot_crit_type",
		title = "menu_ach_hitsounds_set_hit_bodyshot_crit_type_title",
		desc = "menu_ach_hitsounds_set_hit_bodyshot_crit_type_desc",
		callback = "callback_ach_hitsounds_set_hit_bodyshot_crit_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_hit_bodyshot_crit_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 17
	})
	MenuHelper:AddSlider({
		id = "ach_hitsounds_set_hit_bodyshot_crit_volume",
		title = "menu_ach_hitsounds_set_hit_bodyshot_crit_volume_title",
		desc = "menu_ach_hitsounds_set_hit_bodyshot_crit_volume_desc",
		callback = "callback_ach_hitsounds_set_hit_bodyshot_crit_volume",
		value = AdvancedCrosshair.settings.hitsound_hit_bodyshot_crit_volume,
		min = 0,
		max = 1,
		step = 0.1,
		show_value = true,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 16
	})
	
	MenuHelper:AddDivider({
		id = "ach_hitsounds_divider_1",
		size = 8,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 15
	})
	
	
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_hit_headshot_crit_type",
		title = "menu_ach_hitsounds_set_hit_headshot_crit_type_title",
		desc = "menu_ach_hitsounds_set_hit_headshot_crit_type_desc",
		callback = "callback_ach_hitsounds_set_hit_headshot_crit_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_hit_headshot_crit_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 14
	})
	MenuHelper:AddSlider({
		id = "ach_hitsounds_set_hit_headshot_crit_volume",
		title = "menu_ach_hitsounds_set_hit_headshot_crit_volume_title",
		desc = "menu_ach_hitsounds_set_hit_headshot_crit_volume_desc",
		callback = "callback_ach_hitsounds_set_hit_headshot_crit_volume",
		value = AdvancedCrosshair.settings.hitsound_hit_headshot_crit_volume,
		min = 0,
		max = 1,
		step = 0.1,
		show_value = true,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 13
	})
	
	MenuHelper:AddDivider({
		id = "ach_hitsounds_divider_1",
		size = 16,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 12
	})
	
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_kill_bodyshot_type",
		title = "menu_ach_hitsounds_set_kill_bodyshot_type_title",
		desc = "menu_ach_hitsounds_set_kill_bodyshot_type_desc",
		callback = "callback_ach_hitsounds_set_kill_bodyshot_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_kill_bodyshot_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 11
	})
	MenuHelper:AddSlider({
		id = "ach_hitsounds_set_kill_bodyshot_volume",
		title = "menu_ach_hitsounds_set_kill_bodyshot_volume_title",
		desc = "menu_ach_hitsounds_set_kill_bodyshot_volume_desc",
		callback = "callback_ach_hitsounds_set_kill_bodyshot_volume",
		value = AdvancedCrosshair.settings.hitsound_kill_bodyshot_volume,
		min = 0,
		max = 1,
		step = 0.1,
		show_value = true,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 10
	})
	
	MenuHelper:AddDivider({
		id = "ach_hitsounds_divider_1",
		size = 8,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 9
	})
	
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_kill_headshot_type",
		title = "menu_ach_hitsounds_set_kill_headshot_type_title",
		desc = "menu_ach_hitsounds_set_kill_headshot_type_desc",
		callback = "callback_ach_hitsounds_set_kill_headshot_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_kill_headshot_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 8
	})
	MenuHelper:AddSlider({
		id = "ach_hitsounds_set_kill_headshot_volume",
		title = "menu_ach_hitsounds_set_kill_headshot_volume_title",
		desc = "menu_ach_hitsounds_set_kill_headshot_volume_desc",
		callback = "callback_ach_hitsounds_set_kill_headshot_volume",
		value = AdvancedCrosshair.settings.hitsound_kill_headshot_volume,
		min = 0,
		max = 1,
		step = 0.1,
		show_value = true,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 7
	})
	
	MenuHelper:AddDivider({
		id = "ach_hitsounds_divider_1",
		size = 8,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 6
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_kill_bodyshot_crit_type",
		title = "menu_ach_hitsounds_set_kill_bodyshot_crit_type_title",
		desc = "menu_ach_hitsounds_set_kill_bodyshot_crit_type_desc",
		callback = "callback_ach_hitsounds_set_kill_bodyshot_crit_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_kill_bodyshot_crit_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 5
	})
	MenuHelper:AddSlider({
		id = "ach_hitsounds_set_kill_bodyshot_crit_volume",
		title = "menu_ach_hitsounds_set_kill_bodyshot_crit_volume_title",
		desc = "menu_ach_hitsounds_set_kill_bodyshot_crit_volume_desc",
		callback = "callback_ach_hitsounds_set_kill_bodyshot_crit_volume",
		value = AdvancedCrosshair.settings.hitsound_kill_bodyshot_crit_volume,
		min = 0,
		max = 1,
		step = 0.1,
		show_value = true,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 4
	})

	MenuHelper:AddDivider({
		id = "ach_hitsounds_divider_1",
		size = 8,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 3
	})
	MenuHelper:AddMultipleChoice({
		id = "ach_hitsounds_set_kill_headshot_crit_type",
		title = "menu_ach_hitsounds_set_kill_headshot_crit_type_title",
		desc = "menu_ach_hitsounds_set_kill_headshot_crit_type_desc",
		callback = "callback_ach_hitsounds_set_kill_headshot_crit_type",
		items = table.deep_map_copy(hitsound_items),
		value = hitsound_kill_headshot_crit_index,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 2
	})
	MenuHelper:AddSlider({
		id = "ach_hitsounds_set_kill_headshot_crit_volume",
		title = "menu_ach_hitsounds_set_kill_headshot_crit_volume_title",
		desc = "menu_ach_hitsounds_set_kill_headshot_crit_volume_desc",
		callback = "callback_ach_hitsounds_set_kill_headshot_crit_volume",
		value = AdvancedCrosshair.settings.hitsound_kill_headshot_crit_volume,
		min = 0,
		max = 1,
		step = 0.1,
		show_value = true,
		menu_id = AdvancedCrosshair.hitsounds_menu_id,
		priority = 1
	})
end)

Hooks:Add("MenuManagerBuildCustomMenus", "ach_MenuManagerBuildCustomMenus", function( menu_manager, nodes )
	local crosshairs_menu = MenuHelper:GetMenu(AdvancedCrosshair.crosshairs_menu_id)
	
	--create main menu
	local ach_main_menu = MenuHelper:BuildMenu(
		AdvancedCrosshair.main_menu_id,{
			area_bg = "none",
			back_callback = "callback_ach_main_close",
			focus_changed_callback = "callback_ach_main_focus"
		}
	)
	nodes[AdvancedCrosshair.main_menu_id] = ach_main_menu
	MenuHelper:AddMenuItem(nodes.blt_options,AdvancedCrosshair.main_menu_id,"menu_ach_menu_main_title","menu_ach_menu_main_desc")
	
	--create crosshairs menu
	nodes[AdvancedCrosshair.crosshairs_menu_id] = MenuHelper:BuildMenu(
		AdvancedCrosshair.crosshairs_menu_id,{
			area_bg = "none",
			back_callback = "callback_ach_crosshairs_close",
			focus_changed_callback = "callback_ach_crosshairs_focus"
		}
	)
	MenuHelper:AddMenuItem(ach_main_menu,AdvancedCrosshair.crosshairs_menu_id,"menu_ach_crosshairs_menu_title","menu_ach_crosshairs_menu_desc")
	
	--create hitmarkers menu
	nodes[AdvancedCrosshair.hitmarkers_menu_id] = MenuHelper:BuildMenu(
		AdvancedCrosshair.hitmarkers_menu_id,{
			area_bg = "none",
			back_callback = "callback_ach_hitmarkers_close",
			focus_changed_callback = "callback_ach_hitmarkers_focus"
		}
	)
	MenuHelper:AddMenuItem(ach_main_menu,AdvancedCrosshair.hitmarkers_menu_id,"menu_ach_hitmarkers_menu_title","menu_ach_hitmarkers_menu_desc")
	
	--create hitsounds menu
	nodes[AdvancedCrosshair.hitsounds_menu_id] = MenuHelper:BuildMenu(
		AdvancedCrosshair.hitsounds_menu_id,{
			area_bg = "none",
			back_callback = "callback_ach_hitsounds_close",
			focus_changed_callback = "callback_ach_hitsounds_focus"
		}
	)
	MenuHelper:AddMenuItem(ach_main_menu,AdvancedCrosshair.hitsounds_menu_id,"menu_ach_hitsounds_menu_title","menu_ach_hitsounds_menu_desc")
	
	
	nodes[AdvancedCrosshair.crosshairs_categories_global_id] = MenuHelper:BuildMenu(AdvancedCrosshair.crosshairs_categories_global_id,
		{
			area_bg = "none",
			back_callback = MenuCallbackHandler.callback_ach_crosshairs_categories_global_close,
			focus_changed_callback = "callback_ach_crosshairs_categories_global_focus"
		}
	)
	MenuHelper:AddMenuItem(crosshairs_menu,AdvancedCrosshair.crosshairs_categories_global_id,"menu_ach_crosshairs_global_menu_title","menu_ach_crosshairs_global_menu_desc",2)
	
	
	nodes[AdvancedCrosshair.crosshairs_categories_submenu_id] = MenuHelper:BuildMenu(AdvancedCrosshair.crosshairs_categories_submenu_id,
		{
			area_bg = "none",
			back_callback = MenuCallbackHandler.callback_ach_crosshairs_categories_close,
			focus_changed_callback = "callback_ach_crosshairs_categories_focus"
		}
	)
	MenuHelper:AddMenuItem(crosshairs_menu,AdvancedCrosshair.crosshairs_categories_submenu_id,"menu_ach_crosshairs_categories_menu_title","menu_ach_crosshairs_categories_menu_desc",1)
	
	--alphabetically sort firemode and weapon categories 
	local sorted_customization_menus = {} 
	for cat_menu_name,cat_menu_data in pairs(AdvancedCrosshair.customization_menus) do 
		table.insert(sorted_customization_menus,cat_menu_name)
	end
	local function get_category_name_id(cat_menu_name)
		local cat_menu_data = AdvancedCrosshair.customization_menus[cat_menu_name]
		local category = tostring(cat_menu_data.category_name)
		local cat_name_id = "menu_weapon_category_" .. category
		return cat_name_id
	end
	table.sort(sorted_customization_menus,function(a,b)
		return managers.localization:text(get_category_name_id(a)) < managers.localization:text(get_category_name_id(b))
	end)
	
	local function get_firemode(cat_menu_data,firemode_menu_name)
		local firemode_menu = cat_menu_data.child_menus[firemode_menu_name]
		local firemode = tostring(firemode_menu.firemode)
		return firemode
	end
	
	for _,cat_menu_name in ipairs(sorted_customization_menus) do 
		local cat_menu_data = AdvancedCrosshair.customization_menus[cat_menu_name]
		
		local cat_menu = MenuHelper:GetMenu(cat_menu_name)
		local category = tostring(cat_menu_data.category_name)
		local cat_name_id = "menu_weapon_category_" .. category
		local cat_name_desc = "menu_ach_change_crosshair_weapon_category_desc"
		
		--sort firemode menus according to the order of VALID_WEAPON_FIREMODES
		local sorted_firemode_menus = {}
		for firemode_menu_name,firemode_menu in pairs(cat_menu_data.child_menus) do 
			table.insert(sorted_firemode_menus,firemode_menu_name)
		end
		table.sort(sorted_firemode_menus,function(a,b)
			return (table.index_of(AdvancedCrosshair.VALID_WEAPON_FIREMODES,get_firemode(cat_menu_data,a)) or 0) < (table.index_of(AdvancedCrosshair.VALID_WEAPON_FIREMODES,get_firemode(cat_menu_data,b)) or 0)
		end)
		
		for i,firemode_menu_name in ipairs(sorted_firemode_menus) do
			local firemode_menu = cat_menu_data.child_menus[firemode_menu_name]
			
			local firemode = tostring(firemode_menu.firemode)
			local name_id = "menu_weapon_firemode_" .. firemode
			local desc_id = cat_name_id
			local callback_category_firemode_focus_name = "callback_ach_menu_crosshairs_category_" .. category .. "_firemode_" .. firemode .. "_focus"
			MenuCallbackHandler[callback_category_firemode_focus_name] = function(self,item)
				if item == false then 
					if game_state_machine:verify_game_state(GameStateFilters.any_ingame) and managers.player and alive(managers.player:local_player()) then
						AdvancedCrosshair:CreateCrosshairs()
			--			AdvancedCrosshair.clbk_create_crosshair_preview()
					end
				elseif item == true then
					local crosshair_setting = AdvancedCrosshair.settings.crosshairs[category] and AdvancedCrosshair.settings.crosshairs[category][firemode]
					if not crosshair_setting then 
						AdvancedCrosshair:log("FATAL ERROR: Hook MenuManagerBuildCustomMenus: Invalid crosshair settings for [category " .. tostring(category) .. " | firemode " .. tostring(firemode) .. "], aborting menu generation",{color=Color.red})
						return 
					end
					AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
				end
			end
			nodes[firemode_menu_name] = MenuHelper:BuildMenu(firemode_menu_name,
				{
					area_bg = "none",
					back_callback = MenuCallbackHandler.callback_ach_crosshairs_close,
					focus_changed_callback = callback_category_firemode_focus_name
				}
			)
			MenuHelper:AddMenuItem(cat_menu,firemode_menu_name,name_id,desc_id,i) --add each firemode menu to its weaponcategory parent menu
			
		end
		nodes[cat_menu_name] = MenuHelper:BuildMenu(cat_menu_name,
			{
				area_bg = "none",
				back_callback = MenuCallbackHandler.callback_ach_crosshairs_category_close,
				focus_changed_callback = "callback_ach_crosshairs_category_focus"
			}
		)
		MenuHelper:AddMenuItem(MenuHelper:GetMenu(AdvancedCrosshair.crosshairs_categories_submenu_id),cat_menu_name,cat_name_id,cat_name_desc)
	end
	
--	MenuHelper:AddMenuItem(MenuHelper:GetMenu(crosshairs_menu),AdvancedCrosshair.crosshairs_categories_submenu_id,title,desc]
end)

Hooks:Add("MenuManagerInitialize", "ach_initmenu", function(menu_manager)
	MenuCallbackHandler.callback_ach_main_close = function(self)
	end
	
	MenuCallbackHandler.callback_ach_main_focus = function(self,item)
	end
	
	MenuCallbackHandler.callback_ach_empty_button = function(self)
		--this is an empty callback for the "header" buttons
	end
	--**************** crosshairs options ****************
	
	
	MenuCallbackHandler.callback_ach_crosshairs_close = function(self)
		AdvancedCrosshair.clbk_remove_crosshair_preview()
		AdvancedCrosshair:UnloadCrosshairs()
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_close = function(self)
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_focus = function(self)
		
	end
	MenuCallbackHandler.callback_ach_crosshairs_category_close = function(self)
	end
	MenuCallbackHandler.callback_ach_crosshairs_category_focus = function(self)
	end
	MenuCallbackHandler.callback_ach_crosshairs_focus = function(self,item)
		--todo check for if any options were actually changed before recreating?
		if item == false then 
			if game_state_machine:verify_game_state(GameStateFilters.any_ingame) and managers.player and alive(managers.player:local_player()) then
				AdvancedCrosshair:CreateCrosshairs()
	--			AdvancedCrosshair.clbk_create_crosshair_preview()
			end
		end
	end
	
	MenuCallbackHandler.callback_ach_crosshairs_general_master_enable = function(self,item)
		local state = item:value() == "on"
		AdvancedCrosshair.settings.crosshair_enabled = state
		if alive(AdvancedCrosshair._crosshair_panel) then 
			AdvancedCrosshair._crosshair_panel:set_visible(state)
		end
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_toggle_crosshair_visibility = function(self)
		local state = not AdvancedCrosshair:IsCrosshairEnabled()
		AdvancedCrosshair.settings.crosshair_enabled = state
		if alive(AdvancedCrosshair._crosshair_panel) then 
			AdvancedCrosshair._crosshair_panel:set_visible(state)
		end
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_set_outofrange_mode = function(self,item)
		local value = tonumber(item:value())
		AdvancedCrosshair.settings.crosshair_outofrange_mode = value
		AdvancedCrosshair:Save()
	end	
	MenuCallbackHandler.callback_ach_crosshairs_general_enable_shake = function(self,item)
		AdvancedCrosshair.settings.use_shake = item:value() == "on"
		if alive(AdvancedCrosshair._crosshair_panel) then 
			AdvancedCrosshair:SetCrosshairCenter(AdvancedCrosshair._panel:center())
		end
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_enable_movement_bloom = function(self,item)
		AdvancedCrosshair.settings.use_movement_bloom = item:value() == "on"
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_enable_dynamic_color = function(self,item)
		AdvancedCrosshair.settings.use_color = item:value() == "on"
		AdvancedCrosshair:Save()
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
					AdvancedCrosshair:Save()
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
				--set preview color
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
					AdvancedCrosshair:Save()
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
				--set preview color
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
					AdvancedCrosshair:Save()
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
				--set preview color
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
					AdvancedCrosshair:Save()
				end
				--save palette swatches to settings
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(Color(AdvancedCrosshair.settings.crosshair_misc_color),clbk_colorpicker,clbk_colorpicker)
			
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end	
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_ads_behavior = function(self,item)
		local value = tonumber(item:value())
		AdvancedCrosshair.settings.crosshair_global.ads_behavior = value
		AdvancedCrosshair:Save()
	end
	
	MenuCallbackHandler.callback_ach_crosshairs_general_hide_while_interacting = function(self,item)
		local value = item:value() == "on"
		AdvancedCrosshair.settings.crosshair_hide_while_interacting = value
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_hide_while_running = function(self,item)
		local value = item:value() == "on"
		AdvancedCrosshair.settings.crosshair_hide_while_running = value
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_hide_while_meleeing = function(self,item)
		local value = item:value() == "on"
		AdvancedCrosshair.settings.crosshair_hide_while_meleeing = value
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_hide_while_grenading = function(self,item)
		local value = item:value() == "on"
		AdvancedCrosshair.settings.crosshair_hide_while_grenading = value
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_hide_while_reloading = function(self,item)
		local value = item:value() == "on"
		AdvancedCrosshair.settings.crosshair_hide_while_reloading = value
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_hide_while_inspecting = function(self,item)
		local value = item:value() == "on"
		AdvancedCrosshair.settings.crosshair_hide_while_inspecting = value
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_general_hide_while_hitmarker = function(self,item)
		local value = item:value() == "on"
		AdvancedCrosshair.settings.crosshair_hide_while_hitmarker = value
		AdvancedCrosshair:Save()
	end
	
	MenuCallbackHandler.callback_ach_menu_crosshairs_categories_global_enable_override = function(self,item)
		AdvancedCrosshair.settings.crosshair_all_override = item:value() == "on"
		--not used
		AdvancedCrosshair:Save()
	end
	
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_type = function(self,item)
		local index = tonumber(item:value())
		local crosshair_id = AdvancedCrosshair.crosshair_id_by_index[index]
		AdvancedCrosshair.settings.crosshair_global.crosshair_id = crosshair_id
		--don't check for existing preview data; rebuild bitmap on crosshair type change clbk
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_color = function(self,item)
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		
		if AdvancedCrosshair._colorpicker then
			local crosshair_setting = AdvancedCrosshair.settings.crosshair_global

			local function clbk_colorpicker (color,palettes,success)
				--set preview color
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
					crosshair_setting.color = color:to_hex()
					AdvancedCrosshair:Save()
				end
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
		AdvancedCrosshair.settings.crosshair_global.alpha = tonumber(item:value())
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_scale = function(self,item)
		AdvancedCrosshair.settings.crosshair_global.scale = tonumber(item:value())
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_bloom_enabled = function(self,item)
		AdvancedCrosshair.settings.crosshair_global.use_bloom = item:value() == "on"
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_preview_bloom = function(self)
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		AdvancedCrosshair.clbk_bloom_preview(AdvancedCrosshair.settings.crosshair_global)
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_close = function(self)
		AdvancedCrosshair.clbk_remove_crosshair_preview()
	end
	MenuCallbackHandler.callback_ach_crosshairs_categories_global_focus = function(self,active)
		if active then
			AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(AdvancedCrosshair.settings.crosshair_global)
		end
	end
	
	
	
	
	
	
	
	
	--**************** hitmarkers options ****************
	
	MenuCallbackHandler.callback_ach_hitmarkers_focus = function(self,is_focused)
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
	MenuCallbackHandler.callback_ach_hitmarkers_close = function(self)
		AdvancedCrosshair.clbk_remove_crosshair_preview()
		AdvancedCrosshair:UnloadHitmarkers()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_master_enable = function(self,item)
		AdvancedCrosshair.settings.hitmarker_enabled = item:value() == "on"
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_set_outofrange_mode = function(self,item)
		local value = tonumber(item:value())
		AdvancedCrosshair.settings.hitmarker_outofrange_mode = value
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_set_3d_enabled = function(self,item)
		AdvancedCrosshair.settings.use_hitpos = item:value() == "on"
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_set_limit_behavior = function(self,item)
		AdvancedCrosshair.settings.hitmarker_limit_behavior = tonumber(item:value())
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_set_melee_enabled = function(self,item)
		AdvancedCrosshair.settings.hitmarker_allow_melee = item:value() == "on"
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_set_max_count = function(self,item)
		AdvancedCrosshair.settings.hitmarker_max_count = math.round(tonumber(item:value()))
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_bitmap = function(self,item)
		AdvancedCrosshair.settings.hitmarker_hit_id = AdvancedCrosshair.hitmarker_id_by_index[tonumber(item:value())]
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_duration = function(self,item)
		AdvancedCrosshair.settings.hitmarker_hit_duration = tonumber(item:value())
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_alpha = function(self,item)
		AdvancedCrosshair.settings.hitmarker_hit_alpha = tonumber(item:value())
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_scale = function(self,item)
		AdvancedCrosshair.settings.hitmarker_hit_scale = tonumber(item:value())
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_hit_set_blend_mode = function(self,item)
		AdvancedCrosshair.settings.hitmarker_hit_blend_mode = tonumber(item:value())
		AdvancedCrosshair:Save()
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
					AdvancedCrosshair:Save()
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
					AdvancedCrosshair:Save()
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
					AdvancedCrosshair:Save()
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
					AdvancedCrosshair:Save()
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(AdvancedCrosshair:GetHitmarkerSettings("hit").headshot_crit_color,changed_cb,changed_cb)
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end
	end
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_bitmap = function(self,item)
		AdvancedCrosshair.settings.hitmarker_kill_id = AdvancedCrosshair.hitmarker_id_by_index[tonumber(item:value())]
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_duration = function(self,item)
		AdvancedCrosshair.settings.hitmarker_kill_duration = tonumber(item:value())
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_alpha = function(self,item)
		AdvancedCrosshair.settings.hitmarker_kill_alpha = tonumber(item:value())
		AdvancedCrosshair:Save()
	end	
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_scale = function(self,item)
		AdvancedCrosshair.settings.hitmarker_kill_scale = tonumber(item:value())
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitmarkers_kill_set_blend_mode = function(self,item)
		AdvancedCrosshair.settings.hitmarker_kill_blend_mode = tonumber(item:value())
		AdvancedCrosshair:Save()
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
					AdvancedCrosshair:Save()
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
					AdvancedCrosshair:Save()
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
					AdvancedCrosshair:Save()
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
					AdvancedCrosshair:Save()
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
	MenuCallbackHandler.callback_ach_hitmarkers_preview_toggle_loop = function(self,item)
		AdvancedCrosshair.hitmarker_menu_preview_loops = item:value() == "on"
	end
	
	--hitsounds
	MenuCallbackHandler.callback_ach_hitsounds_close = function(self)
		
	end	
	MenuCallbackHandler.callback_ach_hitsounds_focus = function(self)
		
	end
	MenuCallbackHandler.callback_ach_hitsounds_master_enable = function(self,item)
		AdvancedCrosshair.settings.hitsound_enabled = item:value() == "on"
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_suppress_doublesound_enabled = function(self,item)
		AdvancedCrosshair.settings.hitsound_suppress_doublesound = item:value() == "on"
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_positional_enabled = function(self,item)
		AdvancedCrosshair.settings.use_hitsound_pos = item:value() == "on"
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_limit_behavior = function(self,item)
		AdvancedCrosshair.settings.hitsound_limit_behavior = tonumber(item:value())
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_max_count = function(self,item)
		AdvancedCrosshair.settings.hitsound_max_count = math.round(tonumber(item:value()))
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_melee_enabled = function(self,item)
		AdvancedCrosshair.settings.hitsound_allow_melee = item:value() == "on"
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_hit_bodyshot_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_hit_bodyshot_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "hurt"
				},
				headshot = false,
				crit = false
			},
			nil,
			true
		)
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_hit_bodyshot_volume = function(self,item)
		AdvancedCrosshair.settings.hitsound_hit_bodyshot_volume = tonumber(item:value())
		AdvancedCrosshair:Save()
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "hurt"
				},
				headshot = false,
				crit = false
			},
			nil,
			true
		)
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_hit_headshot_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_hit_headshot_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]	
			
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "hurt"
				},
				headshot = true,
				crit = false
			},
			nil,
			true
		)
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_hit_headshot_volume = function(self,item)
		AdvancedCrosshair.settings.hitsound_hit_headshot_volume = tonumber(item:value())
		AdvancedCrosshair:Save()
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "hurt"
				},
				headshot = true,
				crit = false
			},
			nil,
			true
		)
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_hit_bodyshot_crit_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_hit_bodyshot_crit_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "hurt"
				},
				headshot = false,
				crit = true
			},
			nil,
			true
		)
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_hit_bodyshot_crit_volume = function(self,item)
		AdvancedCrosshair.settings.hitsound_hit_bodyshot_crit_volume = tonumber(item:value())
		AdvancedCrosshair:Save()
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "hurt"
				},
				headshot = false,
				crit = true
			},
			nil,
			true
		)
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_hit_headshot_crit_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_hit_headshot_crit_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "hurt"
				},
				headshot = true,
				crit = true
			},
			nil,
			true
		)
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_hit_headshot_crit_volume = function(self,item)
		AdvancedCrosshair.settings.hitsound_hit_headshot_crit_volume = tonumber(item:value())
		AdvancedCrosshair:Save()
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "hurt"
				},
				headshot = true,
				crit = true
			},
			nil,
			true
		)
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_kill_bodyshot_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_kill_bodyshot_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "death"
				},
				headshot = false,
				crit = false
			},
			nil,
			true
		)
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_kill_bodyshot_volume = function(self,item)
		AdvancedCrosshair.settings.hitsound_kill_bodyshot_volume = tonumber(item:value())
		AdvancedCrosshair:Save()
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "death"
				},
				headshot = false,
				crit = false
			},
			nil,
			true
		)
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_kill_headshot_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_kill_headshot_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "death"
				},
				headshot = true,
				crit = false
			},
			nil,
			true
		)
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_kill_headshot_volume = function(self,item)
		AdvancedCrosshair.settings.hitsound_kill_headshot_volume = tonumber(item:value())
		AdvancedCrosshair:Save()
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "death"
				},
				headshot = true,
				crit = false
			},
			nil,
			true
		)
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_kill_bodyshot_crit_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_kill_bodyshot_crit_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "death"
				},
				headshot = false,
				crit = true
			},
			nil,
			true
		)
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_kill_bodyshot_crit_volume = function(self,item)
		AdvancedCrosshair.settings.hitsound_kill_bodyshot_crit_volume = tonumber(item:value())
		AdvancedCrosshair:Save()
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "death"
				},
				headshot = false,
				crit = true
			},
			nil,
			true
		)
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_kill_headshot_crit_type = function(self,item)
		AdvancedCrosshair.settings.hitsound_kill_headshot_crit_id = AdvancedCrosshair.hitsound_id_by_index[tonumber(item:value())]
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "death"
				},
				headshot = true,
				crit = true
			},
			nil,
			true
		)
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_hitsounds_set_kill_headshot_crit_volume = function(self,item)
		AdvancedCrosshair.settings.hitsound_kill_headshot_crit_volume = tonumber(item:value())
		AdvancedCrosshair:Save()
		AdvancedCrosshair:ActivateHitsound(
			{
				result = {
					type = "death"
				},
				headshot = true,
				crit = true
			},
			nil,
			true
		)
	end
	
	MenuCallbackHandler.callback_ach_menu_misc_enable_logs = function(self,item)
		local enabled = item:value() == "on"
		AdvancedCrosshair.settings.logs_enabled = enabled
		AdvancedCrosshair:Save()
	end
	
	MenuCallbackHandler.callback_ach_menu_misc_can_check_melee_headshots = function(self,item)
		local enabled = item:value() == "on"
		AdvancedCrosshair.settings.can_check_melee_headshots = enabled
		AdvancedCrosshair:Save()
	end
	
	MenuCallbackHandler.callback_ach_menu_misc_easter_eggs_enabled = function(self,item)
		local enabled = item:value() == "on"
		AdvancedCrosshair.settings.easter_eggs_enabled = enabled
		
		if enabled then 
			if os.date("%d/%m") == "1/4" then 
				AdvancedCrosshair._cache.HITMARKER_RAIN_ENABLED = true
			else
				AdvancedCrosshair._cache.HITMARKER_RAIN_ENABLED = false
			end
		else
			AdvancedCrosshair._cache.HITMARKER_RAIN_ENABLED = false
		end
		
		AdvancedCrosshair:Save()
	end
	
	--compatibility settings
	MenuCallbackHandler.callback_ach_menu_compat_compatibility_auto_detection = function(self,item)
		local enabled = item:value() == "on"
		AdvancedCrosshair.settings.compatibility_auto_detection = enabled
		AdvancedCrosshair:Save()
	end
	
	MenuCallbackHandler.callback_ach_menu_compat_compatibility_playermanager_checkskill = function(self,item)
		local enabled = item:value() == "on"
		AdvancedCrosshair.settings.compatibility_hook_playermanager_checkskill = enabled
		AdvancedCrosshair:Save()
	end
	
	MenuCallbackHandler.callback_ach_menu_compat_compatibility_playerstandard_startactionequipweapon = function(self,item) --deprecated in v33
	end
	
	MenuCallbackHandler.callback_ach_menu_compat_compatibility_playerstandard_onsteelsight = function(self,item) --deprecated in v33
	end
	
	MenuCallbackHandler.callback_ach_menu_compat_compatibility_playermovementstate_enter = function(self,item) --deprecated in v33
	end
	
	MenuCallbackHandler.callback_ach_menu_compat_compatibility_newraycastweaponbase_togglefiremode = function(self,item) --deprecated in v33
	end
	
	MenuCallbackHandler.callback_ach_menu_compat_compatibility_newraycastweaponbase_resetcachedgadget = function(self,item) --deprecated in v33
	end
	
	MenuCallbackHandler.callback_ach_menu_compat_compatibility_copdamage_damagemelee = function(self,item)
		local enabled = item:value() == "on"
		AdvancedCrosshair.settings.compatibility_hook_copdamage_damagemelee = enabled
		AdvancedCrosshair:Save()
	end
	
	MenuCallbackHandler.callback_ach_menu_compat_compatibility_copdamage_rollcriticalhit = function(self,item)
		local enabled = item:value() == "on"
		AdvancedCrosshair.settings.compatibility_hook_copdamage_rollcriticalhit = enabled
		AdvancedCrosshair:Save()
	end
	
	MenuCallbackHandler.callback_ach_reset_crosshair_settings = function(self)
		local function confirm_reset()
			for _,key in pairs(AdvancedCrosshair.setting_categories.crosshair) do 
				AdvancedCrosshair.settings[key] = AdvancedCrosshair.default_settings[key]
			end
			QuickMenu:new(
				managers.localization:text("menu_ach_reset_crosshair_settings_prompt_success_title"),managers.localization:text("menu_ach_reset_crosshair_settings_prompt_success_desc"),{
					{
						text = managers.localization:text("menu_ach_prompt_ok"),
						is_cancel_button = true,
						is_focused_button = true
					}
				}
			,true)
			AdvancedCrosshair:Save()
		end
		QuickMenu:new(
			managers.localization:text("menu_ach_reset_crosshair_settings_prompt_confirm_title"),managers.localization:text("menu_ach_reset_crosshair_settings_prompt_confirm_desc"),{
				{
					text = managers.localization:text("menu_ach_prompt_confirm"),
					callback = confirm_reset
				},
				{
					text = managers.localization:text("menu_ach_prompt_cancel"),
					is_focused_button = true,
					is_cancel_button = true
				}
			}
		,true)
	end
	MenuCallbackHandler.callback_ach_reset_hitmarker_settings = function(self)
		local function confirm_reset()
			for _,key in pairs(AdvancedCrosshair.setting_categories.hitmarker) do 
				AdvancedCrosshair.settings[key] = AdvancedCrosshair.default_settings[key]
			end
			QuickMenu:new(
				managers.localization:text("menu_ach_reset_hitmarker_settings_prompt_success_title"),
				managers.localization:text("menu_ach_reset_hitmarker_settings_prompt_success_desc"),
				{
					{
						text = managers.localization:text("menu_ach_prompt_ok"),
						is_cancel_button = true
					}
				}
			,true)
		end
		AdvancedCrosshair:Save()
		QuickMenu:new(
			managers.localization:text("menu_ach_reset_hitmarker_settings_prompt_confirm_title"),managers.localization:text("menu_ach_reset_hitmarker_settings_prompt_confirm_desc"),{
				{
					text = managers.localization:text("menu_ach_prompt_confirm"),
					callback = confirm_reset
				},
				{
					text = managers.localization:text("menu_ach_prompt_cancel"),
					is_focused_button = true,
					is_cancel_button = true
				}
			}
		,true)
	end
	MenuCallbackHandler.callback_ach_reset_hitsound_settings = function(self)
		local function confirm_reset()
			for _,key in pairs(AdvancedCrosshair.setting_categories.hitsound) do 
				AdvancedCrosshair.settings[key] = AdvancedCrosshair.default_settings[key]
			end
			QuickMenu:new(
				managers.localization:text("menu_ach_reset_hitsound_settings_prompt_success_title"),managers.localization:text("menu_ach_reset_hitsound_settings_prompt_success_desc"),{
					{
						text = managers.localization:text("menu_ach_prompt_ok"),
						is_cancel_button = true,
						is_focused_button = true
					}
				}
			,true)
		end
		AdvancedCrosshair:Save()
		QuickMenu:new(
			managers.localization:text("menu_ach_reset_hitsound_settings_prompt_confirm_title"),managers.localization:text("menu_ach_reset_hitsound_settings_prompt_confirm_desc"),{
				{
					text = managers.localization:text("menu_ach_prompt_confirm"),
					callback = confirm_reset
				},
				{
					text = managers.localization:text("menu_ach_prompt_cancel"),
					is_focused_button = true,
					is_cancel_button = true
				}
			}
		,true)
	end
	MenuCallbackHandler.callback_ach_reset_palettes = function(self)
		local function confirm_reset()
			for _,key in pairs(AdvancedCrosshair.setting_categories.palettes) do 
				AdvancedCrosshair.settings[key] = AdvancedCrosshair.default_settings[key]
			end
			QuickMenu:new(
				managers.localization:text("menu_ach_reset_palettes_prompt_success_title"),managers.localization:text("menu_ach_reset_palettes_prompt_success_desc"),{
					{
						text = managers.localization:text("menu_ach_prompt_ok"),
						is_cancel_button = true,
						is_focused_button = true
					}
				}
			,true)
		end
		AdvancedCrosshair:Save()
		QuickMenu:new(
			managers.localization:text("menu_ach_reset_palettes_prompt_confirm_title"),managers.localization:text("menu_ach_reset_palettes_prompt_confirm_desc"),{
				{
					text = managers.localization:text("menu_ach_prompt_confirm"),
					callback = confirm_reset
				},
				{
					text = managers.localization:text("menu_ach_prompt_cancel"),
					is_focused_button = true,
					is_cancel_button = true
				}
			}
		,true)
	end
	MenuCallbackHandler.callback_ach_reset_all_settings = function(self)
		--open confirm dialogue
		local function confirm_reset()
			AdvancedCrosshair.settings = table.deep_map_copy(AdvancedCrosshair.default_settings)
			AdvancedCrosshair:Save()
			QuickMenu:new(
				managers.localization:text("menu_ach_reset_all_settings_prompt_success_title"),managers.localization:text("menu_ach_reset_all_settings_prompt_success_desc"),{
					{
						text = managers.localization:text("menu_ach_prompt_ok"),
						is_cancel_button = true,
						is_focused_button = true
					}
				}
			,true)
		end
		QuickMenu:new(
			managers.localization:text("menu_ach_reset_all_settings_prompt_confirm_title"),managers.localization:text("menu_ach_reset_all_settings_prompt_confirm_desc"),{
				{
					text = managers.localization:text("menu_ach_prompt_confirm"),
					callback = confirm_reset
				},
				{
					text = managers.localization:text("menu_ach_prompt_cancel"),
					is_focused_button = true,
					is_cancel_button = true
				}
			}
		,true)
	end
	MenuCallbackHandler.callback_ach_reset_close = function(self)
		--
	end
	MenuCallbackHandler.callback_ach_reset_focus = function(self,focused)
		--
	end
	MenuCallbackHandler.callback_ach_menu_misc_enable_assets_always_loaded = function(self,item)
		local enabled = item:value() == "on" and true or false
		AdvancedCrosshair.settings.assets_always_loaded_enabled = enabled
		AdvancedCrosshair:Save()
	end
	MenuCallbackHandler.callback_ach_misc_close = function(self)
	
	end
	MenuCallbackHandler.callback_ach_misc_focus = function(self,item)
	end

	MenuCallbackHandler.callback_ach_compat_close = function(self,item)
		AdvancedCrosshair:ApplyCompatibilityFixes()
	end
	MenuCallbackHandler.callback_ach_compat_focus = function(self)
	
	end
	
	--creates colorpicker menu for AdvancedCrosshair mod; this menu is reused for all color-related callbacks in this mod,
	--so it's also necessary to also update the callback whenever calling the menu
	if _G.ColorPicker then 
		AdvancedCrosshair._colorpicker = AdvancedCrosshair._colorpicker or ColorPicker:new("advancedcrosshairs",{},callback(AdvancedCrosshair,AdvancedCrosshair,"set_colorpicker_menu"))
	end
	
	MenuHelper:LoadFromJsonFile(AdvancedCrosshair.path .. "menu/menu_compat.json", AdvancedCrosshair, AdvancedCrosshair.settings)
	MenuHelper:LoadFromJsonFile(AdvancedCrosshair.path .. "menu/menu_misc.json", AdvancedCrosshair, AdvancedCrosshair.settings)
	MenuHelper:LoadFromJsonFile(AdvancedCrosshair.path .. "menu/menu_reset.json", AdvancedCrosshair, AdvancedCrosshair.settings)
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
		preview_data = preview_data or AdvancedCrosshair.hitmarker_preview_data
		if not preview_data then return end
		local headshot = preview_data.headshot
		local crit = preview_data.crit
	

		local hitmarker_setting = AdvancedCrosshair:GetHitmarkerSettings(preview_data.result_type)
		local hitmarker_id = hitmarker_setting.hitmarker_id
		if not (hitmarker_id and AdvancedCrosshair._hitmarker_data[hitmarker_id]) then
			AdvancedCrosshair:log("ERROR: clbk_hitmarker_preview(): Bad hitmarker_id (" .. tostring(hitmarker_id) .. "); Aborting!",{color=Color.red})
			return
		end
		local hitmarker_data = AdvancedCrosshair._hitmarker_data[hitmarker_id]
		
		if not AdvancedCrosshair:ShouldAlwaysLoadAssets() then
			AdvancedCrosshair:LoadPartsAssets(hitmarker_data.parts)
		end
		
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
		if hitmarker_data.name_id and preview_panel:child("preview_label") then 
			preview_panel:child("preview_label"):set_text(managers.localization:text(hitmarker_data.name_id))
		end
		
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

		local panel_name = "hitmarker_preview_" .. tostring(preview_data.result_type)
		local panel = preview_panel:child(panel_name)
		if not (panel and alive(panel)) then
			panel = preview_panel:panel({
				alpha = (hitmarker_data.alpha or 1) * hitmarker_setting.alpha,
				name = panel_name,
				layer = 999
			})
		end
		
		if alive(panel) then 
			local parts = AdvancedCrosshair:CreateHitmarker(panel,{
				parts = hitmarker_data.parts,
				color = color,
				blend_mode = AdvancedCrosshair.BLEND_MODES[hitmarker_setting.blend_mode],
				scale = (hitmarker_data.scale or 1) * (hitmarker_setting.scale or 1)
			})
			
			local function remove_panel(o)
				local can_animate = not (o and alive(o) and AdvancedCrosshair:is_animating(o))
				if alive(o) then 
					o:parent():remove(o)
				end
				if AdvancedCrosshair.hitmarker_menu_preview_loops and can_animate then
					AdvancedCrosshair.clbk_hitmarker_preview() --use previous setting
				end
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
		
		if not AdvancedCrosshair:ShouldAlwaysLoadAssets() then
			AdvancedCrosshair:LoadPartsAssets(crosshair_data.parts)
		end
		
		if alive(menupanel:child("ach_preview")) then 
			menupanel:remove(menupanel:child("ach_preview"))
		end
		local preview_panel = menupanel:panel({
			name = "ach_preview", 
			layer = 999
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
			text = crosshair_data.name_id and managers.localization:text(crosshair_data.name_id) or managers.localization:text("menu_ach_preview_label_title"),
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
			parts = AdvancedCrosshair:CreateCrosshair(crosshair_preview_panel,crosshair_data,crosshair_setting),
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
			AdvancedCrosshair:animate_stop(panel)
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
								scale = crosshair_setting.scale,
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





--MenuLobbyRenderer
--MenuKitRenderer

--allow "none" as an option for menu backgrounds, so that players can see the crosshair/hitmarker that they are customizing
local orig_set_bg_area = MenuPauseRenderer.set_bg_area
function MenuPauseRenderer:set_bg_area(area, ...)
    if self._menu_bg and area == "none" then
        self._menu_bg:set_size(0,0)
		self._menu_bg:set_top(0)
		self._menu_bg:set_right(0)
		if self._blur_bg then
			self._blur_bg:set_x(self._fullscreen_panel:w())
		end
    else
		if self._blur_bg then
			self._blur_bg:set_x(0)
		end
        return orig_set_bg_area(self,area,...)
    end
end




AdvancedCrosshair:Init()
AdvancedCrosshair:Load()

AdvancedCrosshair:CheckCreateAddonFolder()