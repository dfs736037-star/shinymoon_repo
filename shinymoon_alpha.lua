local ffi = require("ffi")
local voice_listener = nil
pcall(function()
	voice_listener = require("neverlose/voice_listener")
	if voice_listener and voice_listener.VOSIGNED then
		voice_listener = voice_listener ^ voice_listener.VOSIGNED
	end
end)


local anim_layer_type = ffi.typeof([[
	struct {
		float  m_flLayerAnimtime;
		float  m_flLayerFadeOuttime;
		void  *m_pDispatchedStudioHdr;
		int    m_nDispatchedSrc;
		int    m_nDispatchedDst;
		int    m_nOrder;
		int    m_nSequence;
		float  m_flPrevCycle;
		float  m_flWeight;
		float  m_flWeightDeltaRate;
		float  m_flPlaybackRate;
		float  m_flCycle;
		int    m_pOwner;
		int    m_nInvalidatePhysicsBits;
	} **
]])

local l_pui_0 = require("neverlose/pui")
local l_base64_0 = require("neverlose/base64")
local l_clipboard_0 = require("neverlose/clipboard")
local l_md5_0 = nil
pcall(function()
	l_md5_0 = require("neverlose/md5")
end)

-- ── NL API Wrapper ──
local NL = {
	common = {
		get_username = common.get_username,
	},
	entity = {
		get = entity.get,
		get_local_player = entity.get_local_player,
	},
	globals = {
		curtime = function() return globals.curtime end,
	},
	ui = {
		get_alpha = ui.get_alpha,
		get_icon = ui.get_icon,
		get_style = ui.get_style,
		create = ui.create,
		find = ui.find,
		sidebar = ui.sidebar,
	},
}

-- ── CORE ──
local CORE = {
	SCRIPT = {
		name     = "shinymoon",
		build    = "0.03b",
		user     = NL.common.get_username(),
	},
	log = { vis_setup = nil },
}

local SCRIPT = CORE.SCRIPT
local shinymoon_log = CORE.log

local function shinymoon_accent_hex()
	local vs = shinymoon_log.vis_setup
	if vs and vs.watermark_color then
		local ok, hex = pcall(function() return vs.watermark_color:get():to_hex() end)
		if ok and hex and hex ~= "" then return hex end
	end
	return "4A9EFFFF"
end

function shinymoon_log_print(msg)
	local accent = shinymoon_accent_hex()
	local branded = string.format("[%s] %s", "\a" .. accent .. "shinymoon\aDEFAULT", msg)
	pcall(function() print_raw(branded) end)
	pcall(function() print_dev(branded) end)
end

local function log_action(label, value)
	local accent = shinymoon_accent_hex()
	if value ~= nil and value ~= "" then
		shinymoon_log_print(string.format("\a%s%s\aDEFAULT \a%s%s", accent, label, accent, tostring(value)))
	else
		shinymoon_log_print(string.format("\a%s%s", accent, label))
	end
end

local function log_fail(label, reason)
	local accent = shinymoon_accent_hex()
	shinymoon_log_print(string.format("\a%s%s\aDEFAULT due to \a%s%s", accent, label, accent, tostring(reason)))
end

local THIN = "\226\128\138"

local function pad(n)
	return string.rep(THIN, n)
end

local function icon_label(icon_name, text, pad_left, pad_right)
	pad_left  = pad_left  or 1
	pad_right = pad_right or 5
	return pad(pad_left) .. "\a{Link Active}" .. NL.ui.get_icon(icon_name) .. pad(pad_right) .. "\aDEFAULT" .. text
end

local function sub_label(text, pad_left, pad_right)
	pad_left  = pad_left  or 0
	pad_right = pad_right or 5
	local bullet = "\226\128\186"
	return bullet .. pad(pad_right) .. text
end

local function sub_label_active(text, active, pad_left, pad_right)
	pad_left  = pad_left  or 0
	pad_right = pad_right or 5
	local bullet = "\226\128\186"
	if active then
		bullet = "\a{Link Active}" .. bullet .. "\aDEFAULT"
	end
	return bullet .. pad(pad_right) .. text
end

CORE.pad = pad
CORE.icon_label = icon_label
CORE.sub_label = sub_label
CORE.sub_label_active = sub_label_active

local function listable_has(list, name)
	if not list or name == nil then return false end
	local ok, selected = pcall(function() return list:get() end)
	if not ok or type(selected) ~= "table" then return false end

	local options
	pcall(function() options = list:list() end)

	local function matches(target)
		for k, v in pairs(selected) do
			if v == target then return true end
			if k == target and v then return true end
			if type(v) == "number" and options and options[v] == target then return true end
			if type(k) == "number" and v and options and options[k] == target then return true end
		end
		for _, idx in ipairs(selected) do
			if type(idx) == "number" and options and options[idx] == target then return true end
		end
		return false
	end

	if matches(name) then return true end

	-- ponytail: gingersense selectable / old preset strings
	local aliases = {
		["Warmup AA"] = { "Warmup", "Warmup / Round End AA" },
		["Round end AA"] = { "Round end", "Round End AA" },
	}
	local alt = aliases[name]
	if alt then
		for i = 1, #alt do
			if matches(alt[i]) then return true end
		end
	end

	return false
end

CORE.listable_has = listable_has

local function weapon_is_reloading(weapon)
	if not weapon or not weapon.get_weapon_reload then return false end
	local ok, reload = pcall(function() return weapon:get_weapon_reload() end)
	return ok and reload ~= nil and reload ~= -1
end

CORE.weapon_is_reloading = weapon_is_reloading

-- ── Bucket Tables ──
local UI = { home = {}, antiaim = {}, antiaim_tab = {}, misc = {} }
local AA = {
	refs = {},
	engine = {},
	builder = {},
	states = {},
	builder_schema = {},
	round_reset = {},
	state_labels = {},
	setup_labels = {},
}
local VIS = { setup = {}, state = {}, refs = {}, features = {} }
local MISC = { setup = {}, state = {}, refs = {} }
local CFG = nil

local EVENTS = {
	list = {},
	_registered = false,
	_handlers = {},
}

function EVENTS.add(entry)
	table.insert(EVENTS.list, entry)
end

function EVENTS.set_handler(event, tag, fn)
	for i = 1, #EVENTS.list do
		local e = EVENTS.list[i]
		if e.event == event and e.tag == tag then
			EVENTS.list[i].fn = fn
			return
		end
	end
	EVENTS.add({ event = event, tag = tag, fn = fn, order = 10 })
end

function EVENTS.register_all()
	local by_event = {}
	for _, e in ipairs(EVENTS.list) do
		by_event[e.event] = by_event[e.event] or {}
		table.insert(by_event[e.event], e)
	end

	for name, handlers in pairs(by_event) do
		table.sort(handlers, function(a, b)
			return (a.order or 100) < (b.order or 100)
		end)

		local chain = function(...)
			for _, h in ipairs(handlers) do
				if h.fn then
					local ok, err = pcall(h.fn, ...)
					if not ok and name ~= "shutdown" then
						log_fail(h.tag or name, tostring(err))
					end
				end
			end
		end

		if EVENTS._handlers[name] then
			pcall(function() events[name]:unset(EVENTS._handlers[name]) end)
		end
		EVENTS._handlers[name] = chain
		pcall(function() events[name]:set(chain) end)
	end

	EVENTS._registered = true
end

local NAV = { tabs = {} }

function NAV.subtab_labels(tab_def, selected)
	local labels = {}
	for i = 1, #tab_def.subtabs do
		local st = tab_def.subtabs[i]
		labels[i] = icon_label(st.icon, st.label, st.pad_left, st.pad_right)
	end
	return labels
end

function NAV.install(tab_def)
	local bucket = tab_def.bucket
	bucket.nav_list = tab_def.nav:list(tab_def.list_id, NAV.subtab_labels(tab_def, 1))

	local function update_visibility()
		local sel = bucket.nav_list:get()
		bucket.nav_list:update(NAV.subtab_labels(tab_def, sel))

		if tab_def.update_groups then
			tab_def.update_groups(sel)
		end

		if tab_def.update_extra then
			tab_def.update_extra(sel)
		end
	end

	tab_def.update_visibility = update_visibility

	bucket.nav_list:set_callback(function()
		update_visibility()
		if tab_def.on_select then
			tab_def.on_select(bucket.nav_list:get())
		end
	end, true)

	return update_visibility
end

function VIS.install_switch_feature(def)
	local setup_tbl = VIS.setup
	local parent = def.parent
	setup_tbl[def.key] = parent:switch(
		icon_label(def.icon, def.label, def.pad_left or 1, def.pad_right or 5),
		def.default or false
	)
	local child_grp = setup_tbl[def.key]:create()
	if def.build_children then
		def.build_children(child_grp, setup_tbl)
	end
	local function refresh()
		local on = setup_tbl[def.key]:get()
		child_grp:visibility(on)
		if def.on_refresh then
			def.on_refresh(on, setup_tbl, child_grp)
		end
	end
	setup_tbl[def.key]:set_callback(refresh, true)
	if def.bind_refresh then
		for i = 1, #def.bind_refresh do
			def.bind_refresh[i]:set_callback(refresh, true)
		end
	end
	return child_grp
end

local function reset_table_fields(tbl, spec)
	if not tbl or not spec then return end
	for i = 1, #spec do
		local entry = spec[i]
		if type(entry) == "string" then
			local val = tbl[entry]
			if type(val) == "table" then
				tbl[entry] = {}
			elseif type(val) == "boolean" then
				tbl[entry] = false
			elseif type(val) == "number" then
				tbl[entry] = 0
			elseif type(val) == "string" then
				tbl[entry] = ""
			else
				tbl[entry] = nil
			end
		elseif type(entry) == "table" and entry.field then
			if entry.value ~= nil then
				tbl[entry.field] = entry.value
			elseif entry.reset_fn then
				entry.reset_fn(tbl)
			end
		end
	end
end

NL.ui.sidebar("global_v", "diaspora")

local ICON_HOME = "\a{Link Active}" .. NL.ui.get_icon("house")
local ICON_AA   = "\a{Link Active}" .. NL.ui.get_icon("shield")
local ICON_MISC = "\a{Link Active}" .. NL.ui.get_icon("grid-2")

local COL1 = 1
local COL2 = 2

-- ── AA States (master table) ──
AA.states = {
	{ id = "Global",        label = "Global",        has_override = false, setup = false, builder = true },
	{ id = "Standing",      label = "Standing",      has_override = true,  setup = true,  builder = true },
	{ id = "Moving",        label = "Moving",        has_override = true,  setup = true,  builder = true },
	{ id = "Crouching",     label = "Crouching",     has_override = true,  setup = true,  builder = true },
	{ id = "Crouch Moving", label = "Crouch Moving", has_override = true,  setup = true,  builder = true },
	{ id = "Air",           label = "Air",           has_override = true,  setup = true,  builder = true },
	{ id = "Air + Crouch",  label = "Air + Crouch",  has_override = true,  setup = true,  builder = true },
	{ id = "Slow Walk",     label = "Slow Walk",     has_override = true,  setup = true,  builder = true },
}

AA.state_labels = {}
AA.setup_labels = {}
for i = 1, #AA.states do
	local st = AA.states[i]
	if st.builder then
		AA.state_labels[#AA.state_labels + 1] = st.label
	end
	if st.setup then
		AA.setup_labels[#AA.setup_labels + 1] = st.label
	end
end

local aa_states = AA.state_labels
local setup_states = AA.setup_labels

-- ── tab 1 / home ──
local home = UI.home
home.nav       = NL.ui.create(ICON_HOME, "##HOME_NAV",      COL1)
home.welcome   = NL.ui.create(ICON_HOME, "##HOME_WELCOME",  COL1)
home.profile   = NL.ui.create(ICON_HOME, "##HOME_PROFILE",  COL2)
home.stats     = NL.ui.create(ICON_HOME, "##HOME_STATS",    COL2)
home.config    = NL.ui.create(ICON_HOME, "##HOME_CONFIG",   COL2)
home.config_actions = NL.ui.create(ICON_HOME, "##HOME_CONFIG_ACTIONS", COL2)
home.cloud     = NL.ui.create(ICON_HOME, "##HOME_CLOUD",    COL2)
home.cloud_actions = NL.ui.create(ICON_HOME, "##HOME_CLOUD_ACTIONS", COL2)

local home_update_visibility = NAV.install({
	key = "home",
	bucket = home,
	nav = home.nav,
	list_id = "##HOME_SUBTAB",
	subtabs = {
		{ icon = "moon-cloud", label = "About" },
		{ icon = "airplay", label = "Configs" },
		{ icon = "cloud", label = "Cloud" },
	},
	update_groups = function(sel)
		home.welcome:visibility(sel == 1)
		home.profile:visibility(sel == 1)
		home.stats:visibility(sel == 1)
		home.config:visibility(sel == 2)
		home.config_actions:visibility(sel == 2)
		home.cloud:visibility(sel == 3)
		home.cloud_actions:visibility(sel == 3)
	end,
	on_select = function(sel)
		if sel == 3 and CFG and CFG.cloud then
			CFG.cloud.fetch_list(false)
		end
	end,
})

-- About
home.welcome:label(sub_label("outshine your enemies"))
home.welcome:label(sub_label("nigga'boyz™"))
home.welcome:button(icon_label("right-to-bracket", "Discord", 1, 8), nil, true)

-- Profile
home.profile:label(icon_label("circle-user", "Username", 1, 8))
home.profile:button(SCRIPT.user, nil, true)


home.profile:label(icon_label("brackets-curly", "Build", 1, 8))
home.profile:button(SCRIPT.build, nil, true)

-- Stats
home.stats:label(icon_label("clock", "Session", 1, 6))
home.session_btn = home.stats:button("0s##SESSION_TIME", nil, true)
home.stats:label(icon_label("skull", "Kills", 2, 6))
home.kills_btn = home.stats:button("0##KILLS", nil, true)
home.stats:label(icon_label("arrows-split-up-and-left", "Evaded", 2, 6))
home.evaded_btn = home.stats:button("0##EVADED", nil, true)


-- Configs
local cfg_list = home.config:list("##PRESET_LIST", { "Default" })
local cfg_name = home.config:input("##PRESET_NAME", "")
local cfg_cloud_desc = home.config:input("##CLOUD_DESC", "")
local btn_load = home.config_actions:button(icon_label("download", "Load", 0, 4), nil, true)
local btn_save = home.config_actions:button(icon_label("floppy-disk", "Save", 0, 4), nil, true)
local btn_delete = home.config_actions:button(icon_label("trash", "Delete", 0, 4), nil, true)
local btn_export = home.config_actions:button(icon_label("copy", "Export", 0, 4), nil, true)
local btn_import = home.config_actions:button(icon_label("paste", "Import", 0, 4), nil, true)
local btn_cloud_upload = home.config_actions:button(icon_label("cloud-arrow-up", "Cloud", 0, 4), nil, true)

-- Cloud library
local cloud_list = home.cloud:list("##CLOUD_LIST", { "Refresh to load configs" })
local cloud_sort = home.cloud:combo(icon_label("arrow-down-wide-short", "Sort", 1, 5), { "Newest", "Popular" })
local cloud_status = home.cloud:label(sub_label("Ready"))
local btn_cloud_refresh = home.cloud_actions:button(icon_label("rotate", "Refresh", 0, 4), nil, true)
local btn_cloud_load = home.cloud_actions:button(icon_label("download", "Load", 0, 4), nil, true)
local btn_cloud_delete = home.cloud_actions:button(icon_label("trash", "Delete", 0, 4), nil, true)

--tab 2 # antiaim

local antiaim_tab = UI.antiaim_tab
antiaim_tab.nav = NL.ui.create(ICON_AA, "##AA_NAV")

local builder = AA.builder

local antiaim = UI.antiaim
antiaim.setup       = NL.ui.create(ICON_AA, "##AA_SETUP",       COL1)
antiaim.setup_r     = NL.ui.create(ICON_AA, "##AA_SETUP_R",     COL2)
antiaim.builder        = NL.ui.create(ICON_AA, "##AA_BUILDER",        COL2)
antiaim.builder_states = NL.ui.create(ICON_AA, "##AA_BUILDER_STATES", COL1)
antiaim.builder_events = NL.ui.create(ICON_AA, "##AA_BUILDER_EVENTS", COL1)
antiaim.builder_defensive = NL.ui.create(ICON_AA, "##AA_BUILDER_DEFENSIVE", COL1)
antiaim.builder_protections = NL.ui.create(ICON_AA, "##AA_BUILDER_PROTECTIONS", COL2)
antiaim.builder_actions = NL.ui.create(ICON_AA, "##AA_BUILDER_ACTIONS", COL2)

local antiaim_update_visibility = NAV.install({
	key = "antiaim",
	bucket = antiaim_tab,
	nav = antiaim_tab.nav,
	list_id = "##AA_SUBTAB",
	subtabs = {
		{ icon = "cube", label = "Setup" },
		{ icon = "code", label = "Builder" },
	},
	update_groups = function(sel)
		antiaim.setup:visibility(sel == 1)
		antiaim.setup_r:visibility(sel == 1)
	end,
	update_extra = function(sel)
		local show_builder = (sel == 2)
		antiaim.builder_states:visibility(show_builder)

		local state = "Global"
		if builder.state_list then
			state = builder.state_list:get()
		end

		local override_active = true
		if state ~= "Global" and builder.override_switches and builder.override_switches[state] then
			override_active = builder.override_switches[state]:get()
		end

		local show_controls = show_builder and override_active

		antiaim.builder:visibility(show_controls)
		antiaim.builder_events:visibility(show_controls)
		antiaim.builder_defensive:visibility(show_controls)
		antiaim.builder_protections:visibility(show_controls)
		antiaim.builder_actions:visibility(show_controls)

		if builder.head_behind_chest then
			for state_name, burger_switch in pairs(builder.head_behind_chest) do
				if burger_switch then
					burger_switch:visibility(show_builder and state == state_name)
				end
			end
		end

		if builder.override_switches then
			for k, v in pairs(builder.override_switches) do
				v:visibility(show_builder and k == state)
			end
		end
	end,
})


local function capitalize(s)
	return s:sub(1, 1):upper() .. s:sub(2)
end

-- setup elements
local setup = {}

setup.manual = antiaim.setup:combo(icon_label("arrows-turn-right", "Manual Yaw", 1, 5), { "Off", "Left", "Right", "Backward", "Forward" })
setup.yaw_base = antiaim.setup:combo(icon_label("bullseye", "Yaw Base", 1, 5), { "At Target", "Local view" })

setup.mouse_yaw = antiaim.setup:switch(icon_label("arrow-pointer", "Mouse Yaw Override", 1, 5), false)
local myo_grp = setup.mouse_yaw:create()
setup.mouse_yaw_hotkey = myo_grp:hotkey(icon_label("keyboard", "Hotkey", 1, 4))
setup.mouse_yaw_color = myo_grp:color_picker(icon_label("palette", "Indicator Color", 1, 4), color(74, 158, 255, 255))


local manual_grp = setup.manual:create()
setup.disable_yaw_modifier = manual_grp:switch(icon_label("xmark", "Disable Yaw Modifier", 1, 4))
setup.body_freestanding = manual_grp:switch(icon_label("lock", "Body Freestanding", 1, 4))

setup.freestanding = antiaim.setup:switch(icon_label("person-walking", "Freestanding", 1, 5))
local fs_grp = setup.freestanding:create()
setup.fs_body = fs_grp:list("Body yaw", { "Jitter", "Static" })
setup.fs_disablers = fs_grp:selectable("Disablers", setup_states)
setup.fs_prefer = fs_grp:switch("Prefer manual AA", false)

setup.avoid_knife = antiaim.setup:switch(icon_label("shield", "Avoid Backstab", 1, 5))

setup.lc_defense = antiaim.setup_r:switch(icon_label("shield-halved", "LC & Defensive", 1, 5), false)
local lc_def_grp = setup.lc_defense:create()
setup.break_lc_conditions = lc_def_grp:listable("LC Events", { "Weapon switch", "Weapon reload", "Always" })
setup.break_lc_targets = lc_def_grp:listable("LC Targets", { "Hide Shots Break LC", "DT Lag Always on" })
setup.break_lc_no_quickpeek = lc_def_grp:switch("Don't override LC on Quickpeek", false)
setup.def_conditions = lc_def_grp:selectable("DTC Active States", setup_states)
setup.def_disablers = lc_def_grp:selectable("DTC Disablers", { "Freestanding", "Manual AA", "Peek Assist" })
setup.def_improve_fakelag = lc_def_grp:switch("Improve Fakelag on Defensive", false)
-- ponytail: alias until runtime group drops legacy master names (unify-lc-defensive-ui §2)
setup.break_lc = setup.lc_defense
setup.def_gating = setup.lc_defense

setup.safe_head = antiaim.setup_r:switch(icon_label("brake-warning", "Hide Head", 1, 5))
local sh_grp = setup.safe_head:create()
setup.safe_head_options = sh_grp:listable("Conditions", { "Standing", "Crouching", "Air + Crouch Knife", "Air + Crouch Zeus", "Distance", "Height Advantage" })

setup.aa_debug = antiaim.setup_r:switch(icon_label("bug", "AA Debug Panel", 1, 5))

setup.anims = antiaim.setup_r:switch(icon_label("flower", "Animations", 1, 5))
local an_grp = setup.anims:create()
setup.air_legs = an_grp:combo(icon_label("person-ski-lift", "In Air"), { "Off", "Static", "Walking" })
setup.ground_legs = an_grp:combo(icon_label("person-walking-with-cane", "On Ground"), { "Off", "Static", "Walking", "Jitter", "Earthquake" })
setup.legs_offset_1 = an_grp:slider(icon_label("arrows-up-down-left-right", "Offset 1", 1, 5), 0, 100, 100, 1, function(v) return v == 0 and "Off" or v * 0.01 .. "x" end)
setup.legs_offset_2 = an_grp:slider(icon_label("arrows-up-down-left-right", "Offset 2", 1, 5), 0, 100, 100, 1, function(v) return v == 0 and "Off" or v * 0.01 .. "x" end)
setup.body_lean = an_grp:slider(icon_label("lines-leaning", "Body Lean"), -1, 100, -1, 1, function(v) return v == -1 and "Off" or v * 0.01 .. "x" end)
setup.pitch_on_land = an_grp:switch(icon_label("person-arrow-down-to-line", "Pitch on Land", 1, 5), true)

setup.trollaa = antiaim.setup_r:switch(icon_label("poop", "Troll AA", 1, 5))
local ta_grp = setup.trollaa:create()
setup.ta_options = ta_grp:listable("Enable on", { "Warmup AA", "Round end AA" })
setup.ta_mode = ta_grp:combo("Troll AA", { "Spin", "Half Spin" })
setup.ta_speed = ta_grp:slider("Speed", 1, 10, 0, 1, function(v) return v .. "t" end)

local SETUP_VISIBILITY = {
	{
		switch = setup.ground_legs,
		refresh = function()
			local is_jitter = setup.ground_legs:get() == "Jitter"
			setup.legs_offset_1:visibility(is_jitter)
			setup.legs_offset_2:visibility(is_jitter)
		end,
	},
	{ switch = setup.safe_head, group = sh_grp },
	{ switch = setup.anims, group = an_grp },
	{ switch = setup.trollaa, group = ta_grp },
	{ switch = setup.mouse_yaw, group = myo_grp },
}

for i = 1, #SETUP_VISIBILITY do
	local rule = SETUP_VISIBILITY[i]
	rule.switch:set_callback(function()
		if rule.refresh then
			rule.refresh()
		elseif rule.group then
			rule.group:visibility(rule.switch:get())
		end
	end, true)
end

setup.ta_options:set_callback(function()
	local opts = setup.ta_options:get()
	local any_selected = false
	if type(opts) == "table" then
		for _, v in pairs(opts) do
			if v then
				any_selected = true
				break
			end
		end
	end
	setup.ta_mode:visibility(any_selected)
	setup.ta_speed:visibility(any_selected)
end, true)

local function update_lc_defense_visibility()
	local enabled = setup.lc_defense:get()
	lc_def_grp:visibility(enabled)
	setup.break_lc_conditions:visibility(enabled)
	setup.break_lc_targets:visibility(enabled)
	setup.break_lc_no_quickpeek:visibility(enabled and listable_has(setup.break_lc_conditions, "Always"))
	setup.def_conditions:visibility(enabled)
	setup.def_disablers:visibility(enabled)
	setup.def_improve_fakelag:visibility(enabled)
end

setup.lc_defense:set_callback(update_lc_defense_visibility, true)
setup.break_lc_conditions:set_callback(update_lc_defense_visibility, true)
setup.break_lc_targets:set_callback(update_lc_defense_visibility, true)
update_lc_defense_visibility()


-- builder elements
AA.builder_schema = {
	base_keys = {
		"yaw_mode", "yaw_random_methods", "yaw_left", "yaw_right", "yaw_randomize",
		"frequency", "amplitude", "r_min", "r_max", "scale",
		"antibrute", "antibrute_method", "duration",
		"jitter", "center_options", "yaw_jitter_ovr", "jitter_randomize",
		"center_min", "center_max", "custom_amount",
		"body_yaw", "fake_options", "speed_options", "delay_speed", "amnesia_tick_speed",
		"custom_speed", "custom_speed_method", "custom_speed_amount",
		"ran_speed_1", "ran_speed_2", "slider_random",
		"fake_left", "fake_right", "fake_left_random", "fake_right_random",
		"event_handler", "defensive_tickbase", "head_behind_chest",
	},
	slider_groups = {
		{ prefix = "custom_slider_", count = 22 },
		{ prefix = "custom_speed_slider_", count = 22 },
	},
}

local function aa_build_state_keys()
	local keys = {}
	for i = 1, #AA.builder_schema.base_keys do
		keys[#keys + 1] = AA.builder_schema.base_keys[i]
	end
	for i = 1, #AA.builder_schema.slider_groups do
		local grp = AA.builder_schema.slider_groups[i]
		for n = 1, grp.count do
			keys[#keys + 1] = grp.prefix .. n
		end
	end
	return keys
end

local function init_builder_elements()
local function create_yaw_elements(group, suffix)
	local key = suffix

	builder["yaw_mode" .. key] = group:combo(
		icon_label("arrows-left-right-to-line", "Yaw" .. "\n" .. suffix, 1, 5),
		{ "Off", "Left & Right" ,"Automatic" }
	)

	local yaw_parent = builder["yaw_mode" .. key]

builder["yaw_random_methods" .. key] = yaw_parent:create():combo(
	icon_label("dice", "Random" .. "\n" .. suffix, 1, 5),
	{ "Default", "Sinusoidal", "Chaotic" }
)

for _, dir in ipairs({"left", "right" }) do
		builder["yaw_" .. dir .. key] = yaw_parent:create():slider(
			icon_label("angle-right", capitalize(dir) .. "\n" .. suffix, 1, 5),
			-180, 180, 0, 1, "\194\176"
		)
	end

	-- Randomize
	builder["yaw_randomize" .. key] = yaw_parent:create():slider(
		"Randomize\n" .. suffix, 0, 100, 0, 1, "%"
	)

	builder["frequency" .. key] = yaw_parent:create():slider(
		"Frequency\n" .. suffix, 0, 60, 8, 1
	)
	builder["amplitude" .. key] = yaw_parent:create():slider(
		"Amplitude\n" .. suffix, 0, 30, 15, 1, "\194\176"
	)
	builder["r_min" .. key] = yaw_parent:create():slider(
		"Min\n" .. suffix, 0, 100, 0, 1
	)
	builder["r_max" .. key] = yaw_parent:create():slider(
		"Max\n" .. suffix, 0, 100, 100, 1
	)
	builder["scale" .. key] = yaw_parent:create():slider(
		"Scale\n" .. suffix, 0, 100, 10, 1
	)

	-- Anti-bruteforce
	builder["antibrute" .. key] = yaw_parent:create():switch(
		icon_label("shirt-running", "Anti-bruteforce" .. "\n" .. suffix, 1, 5),
		false
	)
	builder["antibrute_method" .. key] = yaw_parent:create():listable(
		"Modifiers", {"Delay", "Fake limit", "Modifier" }
	)

	-- Duration
	builder["duration" .. key] = yaw_parent:create():slider(
		icon_label("reply-clock", "Duration" .. "\n" .. suffix, 1, 5),
		0, 30, 0, 1,
		function(v) return v == 0 and "Inf." or tostring(v) end
	)
	builder["duration_info" .. key] = yaw_parent:create():label(
		"Duration at 0 keeps changes until round ends or local player dies"
	)

	-- Yaw visibility
	local function update_yaw_visibility()
		local mode = builder["yaw_mode" .. key]:get()
		local is_yaw_on = mode ~= "Off"
		local is_automatic = mode == "Automatic"
		local show_manual = is_yaw_on and not is_automatic
		local enabled = builder["antibrute" .. key]:get()
		local dur = builder["duration" .. key]:get()
		local rand_method = builder["yaw_random_methods" .. key]:get()
		
		builder["yaw_random_methods" .. key]:visibility(show_manual)
		for _, dir in ipairs({"left", "right" }) do
			builder["yaw_" .. dir .. key]:visibility(show_manual)
		end
		builder["yaw_randomize" .. key]:visibility(show_manual and rand_method == "Default")
		builder["frequency" .. key]:visibility(show_manual and rand_method == "Sinusoidal")
		builder["amplitude" .. key]:visibility(show_manual and rand_method == "Sinusoidal")
		builder["r_min" .. key]:visibility(show_manual and rand_method == "Chaotic")
		builder["r_max" .. key]:visibility(show_manual and rand_method == "Chaotic")
		builder["scale" .. key]:visibility(show_manual and rand_method == "Chaotic")
		builder["antibrute" .. key]:visibility(is_yaw_on)
		
		builder["antibrute_method" .. key]:visibility(is_yaw_on and enabled)
		builder["duration" .. key]:visibility(is_yaw_on and enabled)
		builder["duration_info" .. key]:visibility(is_yaw_on and enabled and dur == 0)
	end

	builder["yaw_mode" .. key]:set_callback(update_yaw_visibility, true)
	builder["yaw_random_methods" .. key]:set_callback(update_yaw_visibility, true)
	builder["antibrute" .. key]:set_callback(update_yaw_visibility, true)
	builder["duration" .. key]:set_callback(update_yaw_visibility, true)

	-- Modifier

	builder["jitter" .. key] = group:combo(
		icon_label("align-left", "Modifier" .. "\n" .. suffix, 1, 5),
		{ "Disabled", "Center", "Offset", "Random", "3-Way", "Spin", "Shiny","Hold" }
	)

	local jitter_parent = builder["jitter" .. key]

	builder["center_options" .. key] = jitter_parent:create():combo(
		icon_label("dice", "Random" .. "\n" .. suffix, 1, 5),
		{ "Default", "Min & Max", "Custom" }
	)

	builder["yaw_jitter_ovr" .. key] = jitter_parent:create():slider(
		icon_label("slider", "Amount" .. "\n" .. suffix, 1, 5),
		-180, 180, 0, 1, "\194\176"
	)

	builder["jitter_randomize" .. key] = jitter_parent:create():slider(
		icon_label("angle-right", "Randomize" .. "\n" .. suffix, 1, 5),
		0, 100, 0, 1, "%"
	)

	builder["center_min" .. key] = jitter_parent:create():slider(
		icon_label("angle-right", "Min" .. "\n" .. suffix, 1, 5),
		-180, 180, 0, 1, "\194\176"
	)

	builder["center_max" .. key] = jitter_parent:create():slider(
		icon_label("angle-right", "Max" .. "\n" .. suffix, 1, 5),
		-180, 180, 0, 1, "\194\176"
	)

	-- Custom slider amount
	builder["custom_amount" .. key] = jitter_parent:create():slider(
		icon_label("sliders-simple", "Slider Amount" .. "\n" .. suffix, 1, 5),
		1, 22
	)

	for i = 1, 22 do
		builder["custom_slider_" .. i .. key] = jitter_parent:create():slider(
			icon_label("angle-right", "    " .. i .. "\n" .. suffix, 1, 5),
			-180, 180, 0, 1, "\194\176"
		)
	end

	-- Modifier visibility
	local function update_modifier_visibility()
		local mode = builder["jitter" .. key]:get()
		local is_enabled = mode ~= "Disabled"
		local is_hold = mode == "Hold"

		if is_hold then
			builder["center_options" .. key]:set("Default")
			builder["yaw_jitter_ovr" .. key]:set(0)
			builder["jitter_randomize" .. key]:set(0)
		end
		
		local rand_opt = builder["center_options" .. key]:get()
		
		builder["center_options" .. key]:visibility(is_enabled and not is_hold)
		builder["yaw_jitter_ovr" .. key]:visibility(is_enabled and not is_hold and rand_opt == "Default")
		builder["jitter_randomize" .. key]:visibility(is_enabled and not is_hold and rand_opt == "Default")
		
		builder["center_min" .. key]:visibility(is_enabled and not is_hold and rand_opt == "Min & Max")
		builder["center_max" .. key]:visibility(is_enabled and not is_hold and rand_opt == "Min & Max")
		
		builder["custom_amount" .. key]:visibility(is_enabled and not is_hold and rand_opt == "Custom")
		local amt = builder["custom_amount" .. key]:get()
		for i = 1, 22 do
			builder["custom_slider_" .. i .. key]:visibility(is_enabled and not is_hold and rand_opt == "Custom" and i <= amt)
		end
	end

	builder["jitter" .. key]:set_callback(update_modifier_visibility, true)
	builder["center_options" .. key]:set_callback(update_modifier_visibility, true)
	builder["custom_amount" .. key]:set_callback(update_modifier_visibility, true)
end

local function create_body_elements(group, suffix)
	local key = suffix

	-- Body yaw toggle
	builder["body_yaw" .. key] = group:switch(
		icon_label("user-cowboy", "Desync" .. "\n" .. suffix, 1, 5),
		false
	)

	-- Fake options (Jitter / Static)
	builder["fake_options" .. key] = group:combo(
		icon_label("ellipsis", "Options" .. "\n" .. suffix, 1, 5),
		{"Static", "Jitter"}
	)

	local fake_parent = builder["fake_options" .. key]

	-- Speed method
	builder["speed_options" .. key] = fake_parent:create():combo(
		icon_label("list-radio", "Method" .. "\n" .. suffix, 1, 5),
		{ "Default", "Shiny", "Amnesia" }
	)

	builder["amnesia_tick_speed" .. key] = fake_parent:create():slider(
		icon_label("brain", "Amnesia Tick\n" .. suffix, 1, 5),
		1, 22, 16, 1
	)

	-- Delay speed (Master Speed for Jitter)
	builder["delay_speed" .. key] = fake_parent:create():slider(
		icon_label("gauge-high", "Delay Speed" .. "\n" .. suffix, 1, 5),
		1, 20, 2, 1,
		function(v) return v == 1 and "Off" or tostring(v) end
	)

	-- Custom speed toggle
	builder["custom_speed" .. key] = fake_parent:create():switch(
		icon_label("gear_complex", "Custom Speed" .. "\n" .. suffix, 1, 5),
		false
	)

	-- Custom speed method
	builder["custom_speed_method" .. key] = fake_parent:create():combo(
		icon_label("dice", "Random" .. "\n" .. suffix, 1, 5),
		{ "Default", "Custom" }
	)

	-- Custom speed slider amount + individual sliders
	builder["custom_speed_amount" .. key] = fake_parent:create():slider(
		icon_label("sliders-simple", "Slider Amount" .. "\n" .. suffix, 1, 5),
		1, 22
	)

	for i = 1, 22 do
		builder["custom_speed_slider_" .. i .. key] = fake_parent:create():slider(
			icon_label("angle-right", "    " .. i .. "\n" .. suffix, 1, 5),
			1, 20, 0
		)
	end

	-- Random speed range
	builder["ran_speed_1" .. key] = fake_parent:create():slider(
		icon_label("angle-right", "Min Speed" .. "\n" .. suffix, 1, 5),
		1, 20, 1
	)
	builder["ran_speed_2" .. key] = fake_parent:create():slider(
		icon_label("angle-right", "Max Speed" .. "\n" .. suffix, 1, 5),
		1, 20, 1
	)

	-- Sliders randomization percentage
	builder["slider_random" .. key] = fake_parent:create():slider(
		"Randomize\n" .. suffix, 0, 100, 0, 1, "%"
	)

	-- Left / Right fake yaw + randomize
	local body_parent = builder["body_yaw" .. key]

	for _, dir in ipairs({ "left", "right" }) do
		builder["fake_" .. dir .. key] = body_parent:create():slider(
			icon_label("angle-right", capitalize(dir) .. "\n" .. suffix, 1, 5),
			0, 60, 60, 1, "\194\176"
		)
		builder["fake_" .. dir .. "_random" .. key] = body_parent:create():slider(
			icon_label("dice", "" .. capitalize(dir) .. "\n" .. suffix, 1, 5),
			0, 100, 0, 1, "%"
		)
	end

	-- Body visibility
	local function update_body_visibility()
		local body_enabled = builder["body_yaw" .. key]:get()
		
		builder["fake_options" .. key]:visibility(body_enabled)
		
		local is_jitter = body_enabled and builder["fake_options" .. key]:get() == "Jitter"
		
		builder["speed_options" .. key]:visibility(is_jitter)
		builder["delay_speed" .. key]:visibility(is_jitter)
		builder["custom_speed" .. key]:visibility(is_jitter)

		local speed_opt = builder["speed_options" .. key]:get()
		builder["amnesia_tick_speed" .. key]:visibility(is_jitter and speed_opt == "Amnesia")
		
		local custom_speed_enabled = builder["custom_speed" .. key]:get()
		local csm = builder["custom_speed_method" .. key]:get()
		local show_csm = is_jitter and custom_speed_enabled
		
		builder["custom_speed_method" .. key]:visibility(show_csm)
		builder["ran_speed_1" .. key]:visibility(show_csm and csm == "Default")
		builder["ran_speed_2" .. key]:visibility(show_csm and csm == "Default")
		builder["slider_random" .. key]:visibility(show_csm and csm == "Custom")
		
		builder["custom_speed_amount" .. key]:visibility(show_csm and csm == "Custom")
		local amt = builder["custom_speed_amount" .. key]:get()
		for i = 1, 22 do
			builder["custom_speed_slider_" .. i .. key]:visibility(show_csm and csm == "Custom" and i <= amt)
		end
		
		for _, dir in ipairs({ "left", "right" }) do
			builder["fake_" .. dir .. key]:visibility(body_enabled)
			builder["fake_" .. dir .. "_random" .. key]:visibility(body_enabled)
		end
	end

	builder["body_yaw" .. key]:set_callback(update_body_visibility, true)
	builder["fake_options" .. key]:set_callback(update_body_visibility, true)
	builder["speed_options" .. key]:set_callback(update_body_visibility, true)
	builder["custom_speed" .. key]:set_callback(update_body_visibility, true)
	builder["custom_speed_method" .. key]:set_callback(update_body_visibility, true)
	builder["custom_speed_amount" .. key]:set_callback(update_body_visibility, true)
end

create_yaw_elements(antiaim.builder, "")
create_body_elements(antiaim.builder, "")
end
init_builder_elements()

builder.head_behind_chest = {}
for i = 1, #AA.states do
	local st = AA.states[i]
	if st.builder then
		builder.head_behind_chest[st.id] = antiaim.builder_protections:switch(
			icon_label("burger", "Head Behind Chest\n" .. st.label, 1, 5),
			false
		)
	end
end

-- Action buttons
builder.reset = antiaim.builder_actions:button(
	icon_label("trash", "\aFF0000FFReset", 1, 5), nil, true
)
builder.reset:tooltip("Resets all builder settings to their\ndefault values. This action cannot be undone.")

builder.copy_state = antiaim.builder_actions:button(
	icon_label("copy","Copy"), nil, true
)
builder.copy_state:tooltip("Copies the current builder state configuration\nto clipboard.")

builder.paste_state = antiaim.builder_actions:button(
	icon_label("paste","Paste"), nil, true
)
builder.paste_state:tooltip("Pastes a previously copied builder state\nconfiguration from clipboard.")

builder.state_list = antiaim.builder_states:combo(icon_label("user-group", "Anti-aim states", 1, 5), aa_states)

builder.override_switches = {}
for i = 1, #AA.states do
	local st = AA.states[i]
	if st.has_override then
		builder.override_switches[st.id] = antiaim.builder_states:switch(
			icon_label("lock-open", "Override " .. st.label, 1, 5), false
		)
	end
end


-- Interaction type: createmove (every sent tick) or net_update (Gingersense body-yaw delay gate)
builder.event_handler = antiaim.builder_events:combo(
	icon_label("alarm-clock", "Interaction type", 1, 5),
	{ "createmove", "net_update" }
)
builder.event_handler:set("createmove")

builder.defensive_tickbase = antiaim.builder_defensive:switch(
	icon_label("shield-check", "Defensive Ticks Correction", 1, 5),
	false
)
-- State storage
local state_storage = {}
local current_state = "Global"



-- All builder keys that need per-state storage
local state_keys = aa_build_state_keys()

local function save_state(idx)
	local data = {}
	for _, key in ipairs(state_keys) do
		if key == "head_behind_chest" then
			local burger_switch = builder.head_behind_chest and builder.head_behind_chest[idx]
			if burger_switch then
				data[key] = burger_switch:get()
			end
		elseif builder[key] then
			data[key] = builder[key]:get()
		end
	end
	state_storage[idx] = data
end

local function load_state(idx)
	local data = state_storage[idx]
	if not data then return end
	if data["yaw_random_methods"] == "Smart" then
		data["yaw_random_methods"] = "Default"
	end
	data["resolver_breaker"] = nil
	data["exploit_air_lag"] = nil
	data["exploit_peek_teleport"] = nil
	for _, key in ipairs(state_keys) do
		if key == "head_behind_chest" then
			local burger_switch = builder.head_behind_chest and builder.head_behind_chest[idx]
			if burger_switch and data[key] ~= nil then
				burger_switch:set(data[key])
			end
		elseif builder[key] and data[key] ~= nil then
			builder[key]:set(data[key])
		end
	end
end
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- Initialize all states with current defaults
for i = 1, #AA.states do
	local st = AA.states[i]
	if st.builder then
		save_state(st.id)
		state_storage[st.id].has_been_overridden = false
	end
end

-- Hook override switches callback
for i = 1, #AA.states do
	local st = AA.states[i]
	if st.has_override and builder.override_switches[st.id] then
		builder.override_switches[st.id]:set_callback(function()
			antiaim_update_visibility()
		end, true)
	end
end

-- Store defaults for reset without collecting restored session values
local default_state = {}
for _, key in ipairs(state_keys) do
	if key == "head_behind_chest" then
		default_state[key] = false
	elseif builder[key] then
		local val = builder[key]:get()
		if type(val) == "boolean" then
			default_state[key] = false
		elseif type(val) == "number" then
			default_state[key] = 0
		elseif type(val) == "table" then
			default_state[key] = {}
		elseif type(val) == "string" then
			if key == "yaw_mode" then default_state[key] = "Off"
			elseif key == "yaw_random_methods" then default_state[key] = "Default"
			elseif key == "jitter" then default_state[key] = "Disabled"
			elseif key == "center_options" then default_state[key] = "Default"
			elseif key == "fake_options" then default_state[key] = "Jitter"
			elseif key == "speed_options" then default_state[key] = "Default"
			elseif key == "custom_speed_method" then default_state[key] = "Default"
			elseif key == "event_handler" then default_state[key] = "createmove"
			elseif key == "tickchoke_mode" then default_state[key] = "Default"
			else default_state[key] = "Off" end
		end
	end
end

-- Reset button
builder.reset:set_callback(function()
	for _, key in ipairs(state_keys) do
		if key == "head_behind_chest" then
			local burger_switch = builder.head_behind_chest and builder.head_behind_chest[current_state]
			if burger_switch and default_state[key] ~= nil then
				pcall(function() burger_switch:set(default_state[key]) end)
			end
		elseif builder[key] and default_state[key] ~= nil then
			pcall(function() builder[key]:set(default_state[key]) end)
		end
	end
	save_state(current_state)
	log_action("Builder state reset to defaults:", current_state)
end)

-- Copy button
builder.copy_state:set_callback(function()
	save_state(current_state)
	local data = state_storage[current_state]
	if data then
		local payload = json.stringify({
			origin = current_state,
			state = data,
		})
		l_clipboard_0.set("{shinymoon:state}:" .. l_base64_0.encode(payload))
		log_action("Builder state copied to clipboard:", current_state)
	end
end)

-- Paste button
builder.paste_state:set_callback(function()
	local raw = l_clipboard_0.get()
	if not raw or raw == "" then
		log_fail("Paste failed", "clipboard is empty")
		return
	end

	local encoded = raw:match("^{shinymoon:state}:(.+)$") or raw
	local ok, decoded = pcall(l_base64_0.decode, encoded)
	if not ok or not decoded or decoded == "" then
		log_fail("Paste failed", "invalid clipboard data")
		return
	end

	local ok2, payload = pcall(json.parse, decoded)
	if not ok2 or type(payload) ~= "table" or type(payload.state) ~= "table" then
		log_fail("Paste failed", "could not parse data")
		return
	end

	local origin = payload.origin or "Unknown"
	for _, key in ipairs(state_keys) do
		if builder[key] and payload.state[key] ~= nil then
			pcall(function() builder[key]:set(payload.state[key]) end)
		end
	end
	save_state(current_state)
	local accent = shinymoon_accent_hex()
	shinymoon_log_print(string.format(
		"\a%sBuilder state pasted\aDEFAULT from \a%s%s\aDEFAULT to \a%s%s",
		accent, accent, tostring(origin):lower(), accent, tostring(current_state):lower()
	))
end)

builder.state_list:set_callback(function()
	local new_state = builder.state_list:get()
	save_state(current_state)
	load_state(new_state)
	current_state = new_state
	antiaim_update_visibility()
end, true)

--tab 3 # misc visuals
local misc = UI.misc
misc.nav            = NL.ui.create(ICON_MISC, "##MISC_NAV", COL1)
misc.movement_grp   = NL.ui.create(ICON_MISC, "##MISC_MOVEMENT", COL1)
misc.grenades_grp   = NL.ui.create(ICON_MISC, "##MISC_GRENADES", COL2)
misc.other_grp      = NL.ui.create(ICON_MISC, "##MISC_OTHER", COL2)
misc.vis_widgets_grp = NL.ui.create(ICON_MISC, "##VIS_WIDGETS", COL1)
misc.vis_camera_grp  = NL.ui.create(ICON_MISC, "##VIS_CAMERA", COL2)
misc.vis_world_grp   = NL.ui.create(ICON_MISC, "##VIS_WORLD", COL2)

local misc_update_visibility = NAV.install({
	key = "misc",
	bucket = misc,
	nav = misc.nav,
	list_id = "##MISC_SUBTAB",
	subtabs = {
		{ icon = "brackets-curly", label = "Misc", pad_left = 1, pad_right = 5 },
		{ icon = "palette", label = "Visuals", pad_left = 1, pad_right = 5 },
	},
	update_groups = function(sel)
		local show_misc = (sel == 1)
		misc.movement_grp:visibility(show_misc)
		misc.grenades_grp:visibility(show_misc)
		misc.other_grp:visibility(show_misc)
		local show_vis = (sel == 2)
		misc.vis_widgets_grp:visibility(show_vis)
		misc.vis_camera_grp:visibility(show_vis)
		misc.vis_world_grp:visibility(show_vis)
	end,
})

-- Misc Features
local misc_setup = MISC.setup

-- Movement (left column)


misc_setup.fast_ladder = misc.movement_grp:switch(icon_label("water-ladder", "Fast Ladder", 1, 5), false)

misc_setup.no_fall = misc.movement_grp:switch(icon_label("person-falling", "No Fall Damage", 1, 5), false)

misc_setup.unlock_fd = misc.movement_grp:switch(icon_label("unlock", "Unlock Fakeduck Speed", 1, 5), false)
misc_setup.unlock_fd:tooltip("Removes fakeduck movement speed cap while ducking.")

misc_setup.freeze_fd = misc.movement_grp:switch(icon_label("duck", "Freezetime Fakeduck", 1, 5), false)

misc_setup.air_duck = misc.movement_grp:switch(icon_label("plane-up", "Air Duck Collision", 1, 5), false)
misc_setup.air_duck:tooltip("Ducks on air collision to preserve momentum through gaps.")

misc_setup.ia_peek = misc.movement_grp:switch(icon_label("microchip-ai", "IA Peek", 1, 5), false)
do
	local ia_grp = misc_setup.ia_peek:create()

	misc_setup.ia_peek_weapon_filter = ia_grp:selectable(icon_label("gun", "Allowed weapons", 1, 5), {
		"AWP", "SSG 08", "Auto", "R8 Revolver", "Desert Eagle",
		"Pistol", "Rifle", "SMG", "Shotgun", "Machine Gun", "Zeus x27",
	})

	misc_setup.ia_peek_sim_time = ia_grp:slider(icon_label("hourglass-half", "Peek delay", 1, 5), 100, 500, 280, 10, "ms")
	misc_setup.ia_peek_rate_limit = ia_grp:slider(icon_label("rotate", "Scan cooldown", 1, 5), 0, 300, 20, 10, function(v)
		return v == 0 and "Off" or (v .. "ms")
	end)

	misc_setup.ia_peek_hit_chance = ia_grp:slider(icon_label("bullseye", "Hit chance", 1, 5), 0, 100, 0, 1, function(v)
		return v == 0 and "Ragebot" or v .. "%"
	end)
	misc_setup.ia_peek_unsafety = ia_grp:switch(icon_label("crosshairs", "Aggressive aim", 1, 5))
	misc_setup.ia_peek_push_disarm = ia_grp:switch(icon_label("bolt", "Push on disarm", 1, 5))

	misc_setup.ia_peek_jump_scout = ia_grp:switch(icon_label("person-running", "Jump scout", 1, 5))
	misc_setup.ia_peek_force_jump = ia_grp:switch(icon_label("bolt", "Always jump", 1, 5))
	misc_setup.ia_peek_block_move = ia_grp:combo(icon_label("hand", "Before jump", 1, 5), { "Soft stop", "Full stop" })
	misc_setup.ia_peek_jump_range = ia_grp:slider(icon_label("ruler", "Enemy distance", 1, 5), 5, 50, 25, 1, function(v)
		return math.floor(v * 2) .. "m"
	end)
	misc_setup.ia_peek_jump_height = ia_grp:slider(icon_label("arrow-up", "Min height", 1, 5), 20, 128, 30, 5, function(v)
		return v .. "u"
	end)
	misc_setup.ia_peek_jump_timing = ia_grp:slider(icon_label("stopwatch", "Air window", 1, 5), 1, 9, 3, 1, function(v)
		return string.format("%.1fs", v * 0.1)
	end)
	misc_setup.ia_peek_jump_prefire = ia_grp:switch(icon_label("crosshairs", "Shoot early", 1, 5))

	local ia_peek_jump_controls = {
		misc_setup.ia_peek_force_jump,
		misc_setup.ia_peek_block_move,
		misc_setup.ia_peek_jump_range,
		misc_setup.ia_peek_jump_height,
		misc_setup.ia_peek_jump_timing,
		misc_setup.ia_peek_jump_prefire,
	}

	local function ia_peek_set_jump_visibility(on)
		for i = 1, #ia_peek_jump_controls do
			ia_peek_jump_controls[i]:visibility(on)
		end
	end

	local function ia_peek_init_multi(ctrl, fallback)
		local saved = ctrl:get()
		if #saved == 0 then
			saved = fallback
			ctrl:set(saved)
		end
		ctrl:set_callback(function()
			local cur = ctrl:get()
			if #cur > 0 then
				saved = cur
			else
				ctrl:set(saved)
			end
		end)
	end

	ia_peek_init_multi(misc_setup.ia_peek_weapon_filter, {
		"AWP", "SSG 08", "Autoscoutr", "R8 Revolver", "Desert Eagle",
		"Pistol", "Rifle", "SMG",
	})

	misc_setup.ia_peek:tooltip("Finds a peek angle when hidden, moves out, shoots, then retreats.")
	misc_setup.ia_peek_weapon_filter:tooltip("Only these weapon types trigger IA Peek.")
	misc_setup.ia_peek_sim_time:tooltip("Wait time after a peek spot is found before moving.")
	misc_setup.ia_peek_rate_limit:tooltip("Minimum time between new peek scans. Off = no limit.")
	misc_setup.ia_peek_hit_chance:tooltip("Override hitchance while peeking. Ragebot keeps your normal value.")
	misc_setup.ia_peek_unsafety:tooltip("100% multipoint and body aim during peek. More damage, more misses.")
	misc_setup.ia_peek_push_disarm:tooltip("Peek faster when the target can't shoot (nade, knife, reload). Dampened if other enemies can fire.")
	misc_setup.ia_peek_jump_scout:tooltip("Jump shot when you have no line of sight to the enemy.")
	misc_setup.ia_peek_force_jump:tooltip("Skip normal peek and always use jump scout logic.")
	misc_setup.ia_peek_block_move:tooltip("How movement is stopped before the jump.")
	misc_setup.ia_peek_jump_range:tooltip("Max distance to look for jump scout targets.")
	misc_setup.ia_peek_jump_height:tooltip("Minimum vertical offset used for the jump scan.")
	misc_setup.ia_peek_jump_timing:tooltip("How long to stay in the air before firing.")
	misc_setup.ia_peek_jump_prefire:tooltip("Fire earlier in the jump window.")

	misc_setup.ia_peek_jump_scout:set_callback(function(item)
		ia_peek_set_jump_visibility(item:get())
	end, true)
end

-- Grenades (right column)


misc_setup.super_toss = misc.grenades_grp:switch(icon_label("arrow-up-right-from-square", "Super Toss", 1, 5), false)

misc_setup.nade_release = misc.grenades_grp:switch(icon_label("circle-xmark", "Grenade Release", 1, 5), false)
do
	local nade_release_grp = misc_setup.nade_release:create()
	misc_setup.nade_release_hp = nade_release_grp:slider(icon_label("heart", "Min Damage", 1, 5), 1, 50, 25, 1, "hp")
	misc_setup.nade_release:set_callback(function()
		nade_release_grp:visibility(misc_setup.nade_release:get())
	end, true)
end

-- Other (right column)


misc_setup.fake_latency = misc.other_grp:switch(icon_label("trash-clock", "Fake Latency", 1, 5), false)
do
	local fake_latency_grp = misc_setup.fake_latency:create()
	misc_setup.fake_latency_ms = fake_latency_grp:slider(icon_label("trash-clock", "Amount", 1, 5), 0, 200, 0, 1, "ms")
	misc_setup.fake_latency:set_callback(function()
		fake_latency_grp:visibility(misc_setup.fake_latency:get())
	end, true)
end

misc_setup.clantag = misc.other_grp:switch(icon_label("tag", "Clantag", 1, 5), false)
do
	local clantag_grp = misc_setup.clantag:create()
	misc_setup.clantag_mode = clantag_grp:combo(icon_label("list", "Mode", 1, 5), { "Default", "Custom" })
	misc_setup.clantag_text = clantag_grp:input("Custom Text", "")

	misc_setup.update_clantag_ui = function()
		local on = misc_setup.clantag:get()
		clantag_grp:visibility(on)
		local custom = misc_setup.clantag_mode:get() == "Custom"
		misc_setup.clantag_text:visibility(on and custom)
	end

	misc_setup.clantag:set_callback(misc_setup.update_clantag_ui, true)
	misc_setup.clantag_mode:set_callback(misc_setup.update_clantag_ui, true)
end

misc_setup.log_events = misc.other_grp:selectable(icon_label("calendar-star", "Log Events", 1, 5), {
	[1] = "Aimbot",
	[2] = "Purchases",
})

misc_setup.interpolation = misc.other_grp:switch(icon_label("chart-line", "Interpolation", 1, 5), false)
do
	local interp_grp = misc_setup.interpolation:create()
	misc_setup.interpolation_scale = interp_grp:slider(icon_label("sliders", "Scale", 1, 5), 1, 14, 9, 1)
	misc_setup.interpolation:tooltip("Smooths local pose parameters and animation layer weights.")
	misc_setup.interpolation:set_callback(function()
		interp_grp:visibility(misc_setup.interpolation:get())
	end, true)
end

misc_setup.optimize_cvars = misc.other_grp:switch(icon_label("gauge-high", "Optimize CVars", 1, 5), false)

misc_setup.force_shot = misc.other_grp:switch(icon_label("bolt", "Force Shot", 1, 5), false)

-- Visuals Features
local vis_setup = VIS.setup


vis_setup.watermark = misc.vis_widgets_grp:switch(icon_label("signature", "Watermark", 1, 5), true)
do
	local wm_grp = vis_setup.watermark:create()
	vis_setup.watermark_position = wm_grp:combo(icon_label("arrows-up-down-left-right", "Position", 1, 5), { "Bottom", "Top Right", "Left", "Right", "Custom" })
	vis_setup.watermark_text_mode = wm_grp:combo(icon_label("text", "Label", 1, 5), { "Default", "Custom" })
	vis_setup.watermark_custom_text = wm_grp:input("Custom Text", "")
	vis_setup.watermark_show_build = wm_grp:switch(icon_label("code-branch", "Show Build", 1, 5), false)
	vis_setup.watermark_font = wm_grp:slider(icon_label("font", "Font", 1, 5), 1, 4, 1, 1, function(v)
		if v == 1 then return "Default" end
		if v == 2 then return "Small" end
		if v == 3 then return "Console" end
		return "Bold"
	end)
	vis_setup.watermark_color = wm_grp:color_picker("Accent", color(74, 158, 255, 255))
	vis_setup.watermark_color2 = wm_grp:color_picker("Secondary", color(191, 90, 242, 180))
	vis_setup.watermark_text_gradient = wm_grp:switch(icon_label("palette", "Text Gradient", 1, 5), false)
	vis_setup.watermark_gradient_speed = wm_grp:slider(icon_label("gauge-high", "Gradient Speed", 1, 5), 1, 10, 4, 1)
	vis_setup.watermark:tooltip("Frost-style pill with accent rail. Drag while the Neverlose menu is open.")
	shinymoon_log.vis_setup = vis_setup

	local function vis_wm_update_visibility()
		local on = vis_setup.watermark:get()
		wm_grp:visibility(on)
		if not on then return end

		local text_mode = vis_setup.watermark_text_mode:get()
		local use_grad = vis_setup.watermark_text_gradient:get()

		vis_setup.watermark_custom_text:visibility(text_mode == "Custom")
		vis_setup.watermark_gradient_speed:visibility(use_grad)
	end

	vis_setup.watermark:set_callback(vis_wm_update_visibility, true)
	vis_setup.watermark_text_mode:set_callback(vis_wm_update_visibility, true)
	vis_setup.watermark_text_gradient:set_callback(vis_wm_update_visibility, true)
end

vis_setup.shared_users = misc.vis_widgets_grp:switch(icon_label("share-nodes", "Shared Users", 1, 5), true)
vis_setup.shared_users:tooltip("Shows the shinymoon icon on the scoreboard for you and other script users.")

VIS.install_switch_feature({
	key = "damage_ind",
	parent = misc.vis_widgets_grp,
	icon = "raindrops",
	label = "Damage Indicator",
	default = false,
	build_children = function(grp, vs)
		vs.damage_style = grp:combo(icon_label("eye", "Display", 1, 5), { "Always On", "On Hotkey" })
		vs.damage_animate = grp:switch(icon_label("sparkles", "Animate Value", 1, 5), true)
		vs.damage_color = grp:color_picker("Color", color(255, 255, 255, 255))
	end,
})

vis_setup.hitmarker = misc.vis_widgets_grp:switch(icon_label("crosshairs", "Hitmarker", 1, 5), false)
do
	local hm_grp = vis_setup.hitmarker:create()
	vis_setup.hitmarker_place = hm_grp:combo(icon_label("location-dot", "Placement", 1, 5), { "World", "Screen", "Both" })
	vis_setup.hitmarker_style = hm_grp:combo(icon_label("wand-magic-sparkles", "Style", 1, 5), { "Soft", "Classic" })
	vis_setup.hitmarker_size = hm_grp:slider(icon_label("maximize", "Size", 1, 5), 4, 28, 10, 1, "px")
	vis_setup.hitmarker_gap = hm_grp:slider(icon_label("arrows-to-dot", "Gap", 1, 5), 1, 14, 4, 1, "px")
	vis_setup.hitmarker_thickness = hm_grp:slider(icon_label("grip-lines", "Thickness", 1, 5), 1, 6, 2, 1, "px")
	vis_setup.hitmarker_duration = hm_grp:slider(icon_label("clock", "Duration", 1, 5), 0.15, 2, 0.55, 0.05, "s")
	vis_setup.hitmarker_pop = hm_grp:switch(icon_label("sparkles", "Pop", 1, 5), true)
	vis_setup.hitmarker_drift = hm_grp:switch(icon_label("arrow-up", "Drift", 1, 5), false)
	vis_setup.hitmarker_glow = hm_grp:switch(icon_label("sun", "Glow", 1, 5), true)
	vis_setup.hitmarker_shadow = hm_grp:switch(icon_label("clone", "Shadow", 1, 5), true)
	vis_setup.hitmarker_damage = hm_grp:switch(icon_label("hashtag", "Damage", 1, 5), false)
	vis_setup.hitmarker_headshot = hm_grp:switch(icon_label("bullseye", "Headshot Color", 1, 5), false)
	vis_setup.hitmarker_kill = hm_grp:switch(icon_label("skull", "Kill Color", 1, 5), false)
	vis_setup.hitmarker_color = hm_grp:color_picker("Accent", color(245, 245, 247, 235))
	vis_setup.hitmarker_headshot_color = hm_grp:color_picker("Headshot", color(255, 69, 58, 255))
	vis_setup.hitmarker_kill_color = hm_grp:color_picker("Kill", color(255, 159, 10, 255))
	vis_setup.hitmarker_place:tooltip("World draws at the hit location. Screen draws at crosshair center.")

	local function vis_hitmarker_refresh_colors()
		local on = vis_setup.hitmarker:get()
		vis_setup.hitmarker_headshot_color:visibility(on and vis_setup.hitmarker_headshot:get())
		vis_setup.hitmarker_kill_color:visibility(on and vis_setup.hitmarker_kill:get())
	end

	vis_setup.hitmarker_headshot:set_callback(vis_hitmarker_refresh_colors, true)
	vis_setup.hitmarker_kill:set_callback(vis_hitmarker_refresh_colors, true)
	vis_setup.hitmarker:set_callback(function()
		hm_grp:visibility(vis_setup.hitmarker:get())
		vis_hitmarker_refresh_colors()
	end, true)
end


VIS.install_switch_feature({
	key = "aspect",
	parent = misc.vis_camera_grp,
	icon = "expand-wide",
	label = "Aspect Ratio",
	default = false,
	build_children = function(grp, vs)
		vs.aspect_val = grp:slider(icon_label("sliders", "Value", 1, 5), 50, 200, 133, 1, "%")
		local aspect_presets = {
			{ "4:3", 133 }, { "5:4", 125 }, { "3:2", 150 },
			{ "16:10", 161 }, { "16:9", 177 },
		}
		for i = 1, #aspect_presets do
			local preset = aspect_presets[i]
			grp:button(preset[1], function()
				vs.aspect_val:set(preset[2])
			end)
		end
	end,
})

VIS.install_switch_feature({
	key = "viewmodel",
	parent = misc.vis_camera_grp,
	icon = "street-view",
	label = "Viewmodel",
	default = false,
	build_children = function(grp, vs)
		vs.viewmodel_fov = grp:slider(icon_label("camera", "FOV", 1, 5), 54, 90, 68, 1, "\194\176")
		vs.viewmodel_x = grp:slider(icon_label("arrows-left-right", "X", 1, 5), -300, 300, 250, 1, "u")
		vs.viewmodel_y = grp:slider(icon_label("arrows-up-down", "Y", 1, 5), -300, 300, 0, 1, "u")
		vs.viewmodel_z = grp:slider(icon_label("up-down", "Z", 1, 5), -300, 300, -150, 1, "u")
	end,
})

VIS.install_switch_feature({
	key = "scope",
	parent = misc.vis_camera_grp,
	icon = "grip-lines",
	label = "Custom Scope",
	default = false,
	build_children = function(grp, vs)
		vs.scope_size = grp:slider(icon_label("maximize", "Length", 1, 5), 20, 300, 120, 1, "px")
		vs.scope_gap = grp:slider(icon_label("arrows-left-right", "Gap", 1, 5), 0, 100, 8, 1, "px")
		vs.scope_thickness = grp:slider(icon_label("grip-lines", "Thickness", 1, 5), 1, 6, 1, 1, "px")
		vs.scope_gradient = grp:switch(icon_label("palette", "Gradient", 1, 5), true)
		vs.scope_color1 = grp:color_picker("Color", color(255, 255, 255, 255))
		vs.scope_color2 = grp:color_picker("Fade Color", color(255, 255, 255, 0))
	end,
})

VIS.install_switch_feature({
	key = "molotov_radius",
	parent = misc.vis_world_grp,
	icon = "fire",
	label = "Molotov Radius",
	default = false,
	build_children = function(grp, vs)
		vs.molotov_color = grp:color_picker("Circle Color", color(255, 183, 183, 255))
	end,
})

VIS.install_switch_feature({
	key = "smoke_radius",
	parent = misc.vis_world_grp,
	icon = "cloud",
	label = "Smoke Radius",
	default = false,
	build_children = function(grp, vs)
		vs.smoke_color = grp:color_picker("Circle Color", color(197, 199, 255, 255))
	end,
})

VIS.features = {
	{ id = "watermark", factory = "custom" },
	{ id = "shared_users", factory = "custom" },
	{ id = "damage_ind", factory = "switch" },
	{ id = "hitmarker", factory = "custom" },
	{ id = "aspect", factory = "switch" },
	{ id = "viewmodel", factory = "switch" },
	{ id = "scope", factory = "switch" },
	{ id = "molotov_radius", factory = "switch" },
	{ id = "smoke_radius", factory = "switch" },
}

misc_update_visibility()

home_update_visibility()

local DB_KEY_CONFIGS = "shinymoon_configurations"
local CFG_CREATE_LABEL = "Create new config..."
local CFG_EXPORT_PREFIX = "{shinymoon:config}:"

l_pui_0.setup({
	antiaim.setup,
	antiaim.setup_r,
	antiaim.builder,
	antiaim.builder_states,
	antiaim.builder_defensive,
	antiaim.builder_events,
	antiaim.builder_protections,
	antiaim.builder_actions,
	misc.movement_grp,
	misc.grenades_grp,
	misc.other_grp,
	misc.vis_widgets_grp,
	misc.vis_camera_grp,
	misc.vis_world_grp,
}, true)

CFG = {}

local function init_cfg()
	local CFG_FILE = "shinymoon_configs.json"
	local CFG_VERSION = 1

	local function cfg_deep_copy(value)
		if type(value) ~= "table" then
			return value
		end
		local copy = {}
		for k, v in pairs(value) do
			copy[k] = cfg_deep_copy(v)
		end
		return copy
	end

	local function cfg_clear_table(t)
		for k in pairs(t) do
			t[k] = nil
		end
	end

	local function cfg_normalize_entry(data)
		if type(data) == "table" then
			return data
		end
		if type(data) ~= "string" or data == "" then
			return nil
		end

		local ok, parsed = pcall(json.parse, data)
		if ok and type(parsed) == "table" then
			return parsed
		end

		local ok_decode, decoded = pcall(l_base64_0.decode, data)
		if ok_decode and decoded and decoded ~= "" then
			local ok2, parsed2 = pcall(json.parse, decoded)
			if ok2 and type(parsed2) == "table" then
				return parsed2
			end
		end

		return nil
	end

	local function cfg_decode_clipboard(raw)
		if not raw or raw == "" then
			return nil, "clipboard is empty"
		end

		raw = raw:match("^%s*(.-)%s*$") or raw
		local encoded = raw:match("^{shinymoon:config}:(.+)$")
		if encoded then
			local ok_decode, decoded = pcall(l_base64_0.decode, encoded)
			if not ok_decode or not decoded or decoded == "" then
				return nil, "invalid base64 payload"
			end
			raw = decoded
		end

		local ok, data = pcall(json.parse, raw)
		if ok and type(data) == "table" then
			return data
		end

		local ok_decode, decoded = pcall(l_base64_0.decode, raw)
		if ok_decode and decoded and decoded ~= "" then
			ok, data = pcall(json.parse, decoded)
			if ok and type(data) == "table" then
				return data
			end
		end

		return nil, "invalid JSON"
	end

	local function cfg_refresh_ui()
		antiaim_update_visibility()
		home_update_visibility()
		misc_update_visibility()
		pcall(update_lc_defense_visibility)
	end

local function cfg_persist_store(store)
	db[DB_KEY_CONFIGS] = store
	pcall(function()
		files.write(CFG_FILE, json.stringify(store))
	end)
end

local function cfg_load_store()
	local store = db[DB_KEY_CONFIGS]
	if type(store) == "table" and next(store) ~= nil then
		return store
	end
	local raw = files.read(CFG_FILE)
	if raw and raw ~= "" then
		local ok, parsed = pcall(json.parse, raw)
		if ok and type(parsed) == "table" then
			cfg_persist_store(parsed)
			return parsed
		end
	end
	return {}
end

local function cfg_get_store()
	return cfg_load_store()
end
local function cfg_get_sorted_names()
	local names = {}
	local store = cfg_get_store()
	for name in pairs(store) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

local function cfg_get_override_flags()
	local flags = {}
	for state_name, switch in pairs(builder.override_switches) do
		flags[state_name] = switch:get()
	end
	return flags
end

local function cfg_set_override_flags(flags)
	for state_name, val in pairs(flags or {}) do
		if builder.override_switches[state_name] then
			builder.override_switches[state_name]:set(val)
		end
	end
end

local function cfg_flush_all_states()
	save_state(current_state)
end

function CFG.export_snapshot()
	cfg_flush_all_states()
	return {
		version = CFG_VERSION,
		pui = l_pui_0.save(),
		state_storage = cfg_deep_copy(state_storage),
		current_state = current_state,
		override_switches = cfg_get_override_flags(),
	}
end

function CFG.import_snapshot(data)
	data = cfg_normalize_entry(data)
	if type(data) ~= "table" then
		return false, "unsupported config data"
	end

	local pui_data = data.pui
	if not pui_data and data.version == nil and next(data) ~= nil then
		pui_data = data
	end
	if type(pui_data) ~= "table" then
		return false, "missing pui data"
	end

	local ok_load, load_err = pcall(l_pui_0.load, pui_data)
	if not ok_load then
		return false, load_err or "pui load failed"
	end

	if type(data.state_storage) == "table" then
		cfg_clear_table(state_storage)
		for state_name, stored in pairs(data.state_storage) do
			state_storage[state_name] = cfg_deep_copy(stored)
		end
	end

	for state_name, switch in pairs(builder.override_switches) do
		switch:set(false)
	end
	if type(data.override_switches) == "table" then
		cfg_set_override_flags(data.override_switches)
	end

	if data.current_state and state_storage[data.current_state] then
		current_state = data.current_state
		if builder.state_list then
			builder.state_list:set(data.current_state)
		end
	elseif not state_storage[current_state] then
		current_state = "Global"
		if builder.state_list then
			builder.state_list:set("Global")
		end
	end

	load_state(current_state)
	cfg_refresh_ui()
	return true
end

function CFG.load_default()
	for _, key in ipairs(state_keys) do
		if builder[key] and default_state[key] ~= nil then
			pcall(function() builder[key]:set(default_state[key]) end)
		end
	end
	for state_name, switch in pairs(builder.override_switches) do
		switch:set(false)
	end
	for i = 1, #AA.states do
		local st = AA.states[i]
		if st.builder then
			save_state(st.id)
			if state_storage[st.id] then
				state_storage[st.id].has_been_overridden = false
			end
		end
	end
	current_state = "Global"
	if builder.state_list then
		builder.state_list:set("Global")
	end
	load_state("Global")
	cfg_refresh_ui()
end

function CFG.get_name_from_index(idx)
	if idx == 1 then
		return "Default"
	end
	local names = cfg_get_sorted_names()
	if #names == 0 then
		return nil
	end
	return names[idx - 1]
end

function CFG.is_create_index(idx)
	return #cfg_get_sorted_names() == 0 and idx == 2
end

function CFG.update_list()
	local items = { icon_label("star", "Default", 0, 4) }
	local names = cfg_get_sorted_names()
	if #names == 0 then
		table.insert(items, CFG_CREATE_LABEL)
	else
		for _, name in ipairs(names) do
			table.insert(items, name)
		end
	end
	cfg_list:update(items)
end

function CFG.save_config()
	local name = cfg_name:get()
	if not name or name == "" or not name:match("%w") then
		log_action("Please enter a valid config name")
		return
	end
	if name == "Default" then
		log_action("Cannot overwrite the default preset")
		return
	end

	local store = cfg_get_store()
	store[name] = CFG.export_snapshot()
	cfg_persist_store(store)
	CFG.update_list()
	log_action("Config saved:", name)
end

function CFG.load_config()
	local idx = cfg_list:get()
	if not idx or idx == 0 then
		log_action("Please select a config to load")
		return
	end
	if idx == 1 then
		CFG.load_default()
		cfg_name:set("Default")
		log_action("Default config loaded")
		return
	end
	if CFG.is_create_index(idx) then
		log_action("Save a config first or paste one from clipboard")
		return
	end

	local name = CFG.get_name_from_index(idx)
	if not name then
		log_action("No config found for the selected preset")
		return
	end

	local store = cfg_get_store()
	local data = cfg_normalize_entry(store[name])
	if not data then
		log_fail("Config not found", name)
		return
	end

	local ok, err = CFG.import_snapshot(data)
	if ok then
		cfg_name:set(name)
		log_action("Config loaded:", name)
	else
		log_fail("Failed to load config", err or name)
	end
end

function CFG.delete_config()
	local idx = cfg_list:get()
	if not idx or idx <= 1 or CFG.is_create_index(idx) then
		log_action("Cannot delete this preset")
		return
	end

	local name = CFG.get_name_from_index(idx)
	if not name then
		log_action("No config found for the selected preset")
		return
	end

	local store = cfg_get_store()
	if not store[name] then
		log_fail("Config not found", name)
		return
	end

	store[name] = nil
	cfg_persist_store(store)
	CFG.update_list()
	log_action("Config deleted:", name)
end

function CFG.export_config()
	local payload = json.stringify(CFG.export_snapshot())
	l_clipboard_0.set(CFG_EXPORT_PREFIX .. l_base64_0.encode(payload))
	log_action("Config exported to clipboard")
end

function CFG.import_config()
	local raw = l_clipboard_0.get()
	local data, err = cfg_decode_clipboard(raw)
	if not data then
		log_fail("Import failed", err or "invalid clipboard data")
		return
	end

	local ok, import_err = CFG.import_snapshot(data)
	if ok then
		log_action("Config imported from clipboard")
	else
		log_fail("Import failed", import_err or "unsupported config data")
	end
end

cfg_list:set_callback(function()
	local idx = cfg_list:get()
	local name = CFG.get_name_from_index(idx)
	if name then
		cfg_name:set(name)
	elseif CFG.is_create_index(idx) then
		cfg_name:set("")
	end
end)

CFG.actions = {
	{ btn = btn_save, fn = function() CFG.save_config() end },
	{ btn = btn_load, fn = function() CFG.load_config() end },
	{ btn = btn_delete, fn = function() CFG.delete_config() end },
	{ btn = btn_export, fn = function() CFG.export_config() end },
	{ btn = btn_import, fn = function() CFG.import_config() end },
	{ btn = btn_cloud_upload, fn = function() CFG.cloud.upload(cfg_name:get(), cfg_cloud_desc:get()) end },
	{ btn = btn_cloud_refresh, fn = function() CFG.cloud.fetch_list(true) end },
	{ btn = btn_cloud_load, fn = function()
		local entry = CFG.cloud.get_selected()
		if not entry or not entry.id then
			log_action("Select a cloud config to load")
			return
		end
		CFG.cloud.fetch_config(entry.id)
	end },
	{ btn = btn_cloud_delete, fn = function() CFG.cloud.delete_selected() end },
}

for i = 1, #CFG.actions do
	local action = CFG.actions[i]
	action.btn:set_callback(action.fn)
end

-- Cloudflare Worker proxy → Railway backend (Neverlose cannot use *.up.railway.app)
local CLOUD_API_HOST = "https://shinymoon-cloud-proxy.dfs736037.workers.dev"
local CLOUD_API_BASE = CLOUD_API_HOST .. "/v1"
local CLOUD_API_SECRET = "34954234845069"
local DB_KEY_CLOUD_CACHE = "shinymoon_cloud_cache"
local CLOUD_CACHE_TTL = 60
local CLOUD_CFG_VERSION_MAX = CFG_VERSION

local cloud_entries = {}
local cloud_busy = false
local cloud_api_online = false

local function cloud_is_configured()
	return CLOUD_API_HOST
		and CLOUD_API_HOST ~= ""
		and not CLOUD_API_HOST:find("REPLACE_WITH_YOUR_RAILWAY", 1, true)
		and not CLOUD_API_HOST:find("REPLACE_WITH_YOUR_WORKER", 1, true)
		and CLOUD_API_HOST:find("^https://") == 1
end

local function cloud_is_platform_subdomain_host()
	if not CLOUD_API_HOST then
		return false
	end
	if CLOUD_API_HOST:find("%.up%.railway%.app", 1, true) then
		return true
	end
	if CLOUD_API_HOST:find("%.workers%.dev", 1, true) then
		return true
	end
	return false
end

local function cloud_neverlose_host_hint()
	if cloud_is_platform_subdomain_host() then
		return "Neverlose cannot reach *.railway.app or *.workers.dev — add a custom domain to your Cloudflare Worker (README)"
	end
	return nil
end

local function cloud_unreachable_message(reason)
	if not cloud_is_configured() then
		return "set CLOUD_API_HOST to your Railway HTTPS domain (see shinymoon-cloud/README.md)"
	end
	local host_hint = cloud_neverlose_host_hint()
	if host_hint then
		return host_hint
	end
	if reason and reason ~= "" then
		return reason .. " — check " .. CLOUD_API_HOST
	end
	return "cannot reach " .. CLOUD_API_HOST .. " — deploy API on Railway with HTTPS"
end

local function cloud_set_status(text)
	pcall(function()
		cloud_status:name(sub_label(text or "Ready"))
	end)
end

local function cloud_set_busy(busy)
	cloud_busy = busy == true
	pcall(function()
		btn_cloud_refresh:disabled(cloud_busy)
		btn_cloud_load:disabled(cloud_busy)
		btn_cloud_upload:disabled(cloud_busy)
		btn_cloud_delete:disabled(cloud_busy)
	end)
end

local function cloud_sort_param()
	if cloud_sort:get() == 2 then
		return "downloads"
	end
	return "created_at"
end

local function cloud_get_identity()
	local user = SCRIPT.user or common.get_username() or ""
	local xuid = ""
	local me = entity.get_local_player()
	if me then
		local ok, value = pcall(function()
			return me:get_xuid()
		end)
		if ok and value and value ~= 0 then
			xuid = tostring(value)
		end
	end
	if xuid == "" and user ~= "" and l_md5_0 and l_md5_0.sumhexa then
		xuid = "nl:" .. l_md5_0.sumhexa("shinymoon:" .. user):sub(1, 16)
	end
	return user, xuid
end

local function cloud_sign(timestamp, user, xuid)
	if not l_md5_0 or not l_md5_0.sumhexa then
		return nil
	end
	return l_md5_0.sumhexa(CLOUD_API_SECRET .. timestamp .. user .. xuid)
end

local function cloud_auth_headers()
	local user, xuid = cloud_get_identity()
	if user == "" or xuid == "" then
		return nil, "missing local identity"
	end
	local timestamp = tostring(common.get_unixtime())
	local signature = cloud_sign(timestamp, user, xuid)
	if not signature then
		return nil, "md5 module unavailable"
	end
	return {
		["Content-Type"] = "application/json",
		["Accept"] = "application/json",
		["X-Shinymoon-User"] = user,
		["X-Shinymoon-Xuid"] = xuid,
		["X-Shinymoon-Timestamp"] = timestamp,
		["X-Shinymoon-Signature"] = signature,
	}, user, xuid
end

local function cloud_read_cache()
	local cache = db[DB_KEY_CLOUD_CACHE]
	if type(cache) ~= "table" then
		return nil
	end
	return cache
end

local function cloud_write_cache(items, sort)
	db[DB_KEY_CLOUD_CACHE] = {
		fetched_at = globals.realtime or 0,
		sort = sort,
		items = items,
	}
end

local function cloud_cache_fresh(sort)
	local cache = cloud_read_cache()
	if not cache or type(cache.items) ~= "table" then
		return false
	end
	if cache.sort ~= sort then
		return false
	end
	local now = globals.realtime or 0
	return (now - (cache.fetched_at or 0)) < CLOUD_CACHE_TTL
end

local function cloud_format_item(entry)
	local name = entry.name or "Unnamed"
	local author = entry.author_username or "unknown"
	local dl = entry.downloads or 0
	return string.format("%s — %s (%d dl)", name, author, dl)
end

local function cloud_apply_list(items)
	cloud_entries = {}
	local labels = {}
	if type(items) ~= "table" or #items == 0 then
		table.insert(labels, "No cloud configs yet")
	else
		for i = 1, #items do
			local entry = items[i]
			if type(entry) == "table" and entry.id then
				table.insert(cloud_entries, entry)
				table.insert(labels, cloud_format_item(entry))
			end
		end
	end
	if #labels == 0 then
		table.insert(labels, "No cloud configs yet")
	end
	cloud_list:update(labels)
	if #cloud_entries > 0 then
		cloud_list:set(1)
	end
	CFG.cloud.refresh_delete_visibility()
end

local CLOUD_REQUEST_RETRIES = 5
local CLOUD_REQUEST_RETRY_DELAY = 2.0

local function cloud_get(url, on_body, attempt)
	attempt = attempt or 1

	local function finish(body)
		local empty = body == nil or body == false or body == ""
		if empty and attempt < CLOUD_REQUEST_RETRIES then
			utils.execute_after(CLOUD_REQUEST_RETRY_DELAY, function()
				cloud_get(url, on_body, attempt + 1)
			end)
			return
		end
		on_body(body)
	end

	-- Sync GET (world_15 pattern) — most reliable for simple HTTPS reads in Neverlose.
	if attempt == 1 then
		local ok, sync_body = pcall(network.get, url)
		if ok and sync_body and sync_body ~= "" then
			on_body(sync_body)
			return
		end
	end

	-- Async GET with nil headers (grenade_8 pattern) — custom headers break some hosts.
	network.get(url, nil, finish)
end

local function cloud_post(url, payload, headers, on_body, attempt)
	attempt = attempt or 1
	local data = type(payload) == "table" and payload or { payload }

	local function finish(body)
		local empty = body == nil or body == false or body == ""
		if empty and attempt < CLOUD_REQUEST_RETRIES then
			utils.execute_after(CLOUD_REQUEST_RETRY_DELAY, function()
				cloud_post(url, payload, headers, on_body, attempt + 1)
			end)
			return
		end
		on_body(body)
	end

	network.post(url, data, headers or nil, finish)
end

local function cloud_parse_json(body, on_ok, on_err)
	if body == nil or body == false then
		if on_err then
			on_err(cloud_unreachable_message("no response"))
		end
		return
	end
	if body == "" then
		if on_err then
			on_err(cloud_unreachable_message("empty response"))
		end
		return
	end
	local ok, data = pcall(json.parse, body)
	if not ok or type(data) ~= "table" then
		if on_err then
			on_err("invalid JSON response")
		end
		return
	end
	if data.detail and not data.items and not data.id and data.ok == nil then
		local detail = data.detail
		if type(detail) == "table" then
			if detail[1] and type(detail[1]) == "table" and detail[1].msg then
				local loc = detail[1].loc
				local where = type(loc) == "table" and table.concat(loc, ".") or "body"
				detail = where .. ": " .. tostring(detail[1].msg)
			else
				detail = detail[1] and detail[1].msg or json.stringify(detail)
			end
		end
		if on_err then
			on_err(tostring(detail))
		end
		return
	end
	if on_ok then
		on_ok(data)
	end
end

CFG.cloud = {}

function CFG.cloud.check_health(on_done)
	if not cloud_is_configured() then
		cloud_api_online = false
		cloud_set_status("API not configured")
		log_action("Cloud API not configured — set CLOUD_API_HOST in shinymoon_alpha.lua")
		if on_done then
			on_done(false, "not configured")
		end
		return
	end

	local host_hint = cloud_neverlose_host_hint()
	if host_hint then
		cloud_api_online = false
		cloud_set_status("Wrong host for NL")
		if on_done then
			on_done(false, host_hint)
		end
		return
	end

	cloud_get(CLOUD_API_HOST .. "/health", function(body)
		cloud_parse_json(body, function(data)
			cloud_api_online = data.status == "ok"
			if on_done then
				on_done(cloud_api_online, data)
			end
		end, function(err)
			cloud_api_online = false
			if on_done then
				on_done(false, err)
			end
		end)
	end)
end

function CFG.cloud.get_selected()
	local idx = cloud_list:get()
	if not idx or idx <= 0 then
		return nil
	end
	return cloud_entries[idx]
end

function CFG.cloud.refresh_delete_visibility()
	local entry = CFG.cloud.get_selected()
	local user, xuid = cloud_get_identity()
	local owned = entry
		and entry.author_xuid
		and xuid ~= ""
		and tostring(entry.author_xuid) == xuid
	pcall(function()
		btn_cloud_delete:visibility(owned == true)
	end)
end

function CFG.cloud.apply(data)
	local snapshot = data
	if type(data) == "table" and data.snapshot then
		snapshot = data.snapshot
	end
	if type(snapshot) == "table" and snapshot.version and snapshot.version > CLOUD_CFG_VERSION_MAX then
		log_action(string.format(
			"Cloud config version %s is newer than supported %s",
			tostring(snapshot.version),
			tostring(CLOUD_CFG_VERSION_MAX)
		))
	end
	local ok, err = CFG.import_snapshot(snapshot)
	if ok then
		if type(data) == "table" and data.name then
			cfg_name:set(data.name)
		end
		log_action("Cloud config loaded")
	else
		log_fail("Cloud load failed", err or "unsupported config data")
	end
	return ok, err
end

function CFG.cloud.fetch_list(force_refresh, on_done)
	if cloud_busy then
		return
	end
	if not cloud_is_configured() then
		cloud_set_status("API not configured")
		log_action("Set CLOUD_API_HOST to your Railway HTTPS URL")
		if on_done then
			on_done(false, "not configured")
		end
		return
	end
	local sort = cloud_sort_param()
	if not force_refresh and cloud_cache_fresh(sort) then
		local cache = cloud_read_cache()
		cloud_apply_list(cache.items)
		cloud_set_status("Cached list")
		if on_done then
			on_done(true, cache.items)
		end
		return
	end

	local function fetch_configs()
		cloud_set_busy(true)
		cloud_set_status("Loading list...")
		local url = string.format("%s/configs?limit=50&offset=0&sort=%s", CLOUD_API_BASE, sort)
		cloud_get(url, function(body)
			cloud_parse_json(body, function(data)
				local items = data.items or {}
				cloud_write_cache(items, sort)
				cloud_apply_list(items)
				cloud_set_status(string.format("%d configs", data.total or #items))
				cloud_set_busy(false)
				if on_done then
					on_done(true, items)
				end
			end, function(err)
				cloud_set_status("List failed")
				cloud_set_busy(false)
				log_fail("Cloud refresh failed", err)
				if on_done then
					on_done(false, err)
				end
			end)
		end)
	end

	CFG.cloud.check_health(function(ok, err)
		if not ok then
			local cache = cloud_read_cache()
			if cache and type(cache.items) == "table" and #cache.items > 0 then
				cloud_apply_list(cache.items)
				cloud_set_status("Cached (API waking up)")
				log_action("Cloud API unreachable — showing cached list")
				if on_done then
					on_done(true, cache.items)
				end
				return
			end
			cloud_set_status("API offline")
			log_fail("Cloud API offline", err or cloud_unreachable_message())
			if on_done then
				on_done(false, err)
			end
			return
		end
		fetch_configs()
	end)
end

function CFG.cloud.fetch_config(id, on_done)
	if cloud_busy or not id or id == "" then
		return
	end
	cloud_set_busy(true)
	cloud_set_status("Downloading...")
	local url = CLOUD_API_BASE .. "/configs/" .. id
	cloud_get(url, function(body)
		cloud_parse_json(body, function(data)
			cloud_set_busy(false)
			cloud_set_status("Ready")
			local ok = CFG.cloud.apply(data)
			if on_done then
				on_done(ok, data)
			end
		end, function(err)
			cloud_set_busy(false)
			cloud_set_status("Download failed")
			log_fail("Cloud download failed", err)
			if on_done then
				on_done(false, err)
			end
		end)
	end)
end

function CFG.cloud.upload(name, description, on_done)
	if cloud_busy then
		return
	end
	if not cloud_is_configured() then
		log_action("Set CLOUD_API_HOST to your Railway HTTPS URL before uploading")
		return
	end
	name = name or cfg_name:get()
	description = description or cfg_cloud_desc:get() or ""
	if not name or name == "" or not name:match("%w") then
		log_action("Enter a valid name before cloud upload")
		return
	end
	if name == "Default" then
		log_action("Cannot upload the default preset")
		return
	end

	local function do_upload()
		local headers, auth_user, auth_xuid = cloud_auth_headers()
		if not headers then
			log_fail("Cloud upload failed", auth_user or "auth unavailable")
			return
		end

		local snapshot = CFG.export_snapshot()
		if type(snapshot) ~= "table" or not snapshot.version then
			log_fail("Cloud upload failed", "could not encode config snapshot")
			return
		end

		local payload = {
			name = name,
			description = description,
			author_username = auth_user,
			author_xuid = auth_xuid,
			script_build = SCRIPT.build,
			cfg_version = CFG_VERSION,
			snapshot = snapshot,
		}

		cloud_set_busy(true)
		cloud_set_status("Uploading...")
		cloud_post(CLOUD_API_BASE .. "/configs", payload, headers, function(body)
			cloud_parse_json(body, function(data)
				cloud_set_busy(false)
				cloud_set_status("Upload complete")
				log_action("Cloud config uploaded:", data.name or name)
				CFG.cloud.fetch_list(true, on_done)
			end, function(err)
				cloud_set_busy(false)
				cloud_set_status("Upload failed")
				log_fail("Cloud upload failed", err)
				if on_done then
					on_done(false, err)
				end
			end)
		end)
	end

	CFG.cloud.check_health(function(ok, err)
		if not ok then
			log_fail("Cloud upload failed", err or cloud_unreachable_message())
			return
		end
		do_upload()
	end)
end

function CFG.cloud.delete_selected(on_done)
	if cloud_busy then
		return
	end
	local entry = CFG.cloud.get_selected()
	if not entry or not entry.id then
		log_action("Select a cloud config to delete")
		return
	end
	local user, xuid = cloud_get_identity()
	if xuid == "" or tostring(entry.author_xuid) ~= xuid then
		log_action("You can only delete your own cloud configs")
		return
	end

	local payload = { id = entry.id }
	local headers, auth_err = cloud_auth_headers()
	if not headers then
		log_fail("Cloud delete failed", auth_err or "auth unavailable")
		return
	end

	cloud_set_busy(true)
	cloud_set_status("Deleting...")
	cloud_post(CLOUD_API_BASE .. "/configs/delete", payload, headers, function(body)
		cloud_parse_json(body, function(data)
			cloud_set_busy(false)
			cloud_set_status("Deleted")
			log_action("Cloud config deleted:", entry.name or entry.id)
			CFG.cloud.fetch_list(true, on_done)
		end, function(err)
			cloud_set_busy(false)
			cloud_set_status("Delete failed")
			log_fail("Cloud delete failed", err)
			if on_done then
				on_done(false, err)
			end
		end)
	end)
end

cloud_list:set_callback(function()
	CFG.cloud.refresh_delete_visibility()
end)

cloud_sort:set_callback(function()
	CFG.cloud.fetch_list(true)
end, true)

CFG.cloud.refresh_delete_visibility()

if home.nav_list:get() == 3 then
	CFG.cloud.fetch_list(false)
end

CFG.update_list()

end
init_cfg()

local misc_run
local misc_draw
local misc_on_ia_peek
local misc_on_clantag
local misc_on_player_hurt_log
local visuals_run
local visuals_on_player_hurt
local visuals_shutdown
local aa_engine_run
local register_aa_events
local def_scan_enemies
local def_on_voice_message
local shared_on_voice_message
local shared_sync_icons
local shared_shutdown_icons
local def_calc_choke_target
local def_should_fire
local def_apply_force_defensive
local def_update_state
local save_stats
local draw_mouse_yaw_indicator
local reset_mouse_yaw
local detect_player_state
local resolve_state_config
local is_antibrute_enabled_for_config
local last_cmd
local get_fakelag_limit
local reset_head_burger_state

local aa_engine


local function init_aa_engine()

-- ── antiaim engine ──
local refs = AA.refs
refs.pitch = NL.ui.find("Aimbot", "Anti Aim", "Angles", "Pitch")
refs.base = NL.ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base")
refs.offset = NL.ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset")
refs.backstab = NL.ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Avoid Backstab")
refs.jitter = NL.ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier")
refs.jitter_val = NL.ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset")
refs.body_yaw = {
	NL.ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw"),
	NL.ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"),
	NL.ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"),
	NL.ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"),
	NL.ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"),
	NL.ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding"),
}
refs.freestand = {
	NL.ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"),
	NL.ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Disable Yaw Modifiers"),
	NL.ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Body Freestanding"),
}
refs.def = NL.ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options")
refs.dt_fakelag = NL.ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Fake Lag Limit")
refs.hideshot_config = NL.ui.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options")
refs.slow = NL.ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk")
refs.hidden = NL.ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Hidden")
refs.fakelag = NL.ui.find("Aimbot", "Anti Aim", "Fake Lag", "Limit")
refs.autopeek = NL.ui.find("Aimbot", "Ragebot", "Main", "Peek Assist")
refs.leg_movement = NL.ui.find("Aimbot", "Anti Aim", "Misc", "Leg Movement")

local function apply_setup_yaw_base()
	if not refs.base or not setup.yaw_base then
		return
	end

	local mode = setup.yaw_base:get()
	if mode and mode ~= "" then
		refs.base:override(mode)
	end
end

if refs.base and setup.yaw_base then
	pcall(function()
		refs.base:override(setup.yaw_base:get() or "At Target")
	end)
end

local DEFENSIVE_DEFAULT_FAKELAG = 16

get_fakelag_limit = function()
	if refs.fakelag then
		local limit = refs.fakelag:get()
		if type(limit) == "number" and limit > 0 then
			return math.floor(limit)
		end
	end
	return DEFENSIVE_DEFAULT_FAKELAG
end

local function lc_break_lc_enabled()
	return setup.break_lc and setup.break_lc:get()
end

local function lc_event_conditions_active(me)
	if not lc_break_lc_enabled() or not me or not me:is_alive() then
		return false
	end

	local weapon = me:get_player_weapon(false)
	if listable_has(setup.break_lc_conditions, "Weapon switch")
		and (me.m_flNextAttack or 0) > (globals.curtime or 0) then
		return true
	end
	if listable_has(setup.break_lc_conditions, "Weapon reload") and weapon_is_reloading(weapon) then
		return true
	end
	if listable_has(setup.break_lc_conditions, "Always") then
		local block_quickpeek = setup.break_lc_no_quickpeek and setup.break_lc_no_quickpeek:get()
		local quickpeek_active = refs.autopeek and refs.autopeek:get()
		if not (block_quickpeek and quickpeek_active) then
			return true
		end
	end
	return false
end

is_antibrute_enabled_for_config = function(config)
	return type(config) == "table" and config["antibrute"] == true
end

local function get_active_antibrute_entry()
	local ab = aa_engine and aa_engine.ab
	if not ab or type(ab.time) ~= "table" then return nil end
	local now = globals.curtime or 0
	for enemy, expire in pairs(ab.time) do
		if type(expire) == "number" and expire - now >= 0 then
			return enemy, {
				jitteralgo = ab.jitteralgo[enemy] or 0,
				delay = ab.delay[enemy] or 0,
				fakelimit = ab.fakelimit[enemy] or 0,
				time = expire,
				duration = ab.duration[enemy] or 0,
				needs_swap = ab.should_swap[enemy] == true,
			}
		elseif type(expire) == "number" and expire > 0 and expire - now < 0 then
			ab.should_swap[enemy] = nil
			ab.time[enemy] = nil
			ab.jitteralgo[enemy] = nil
			ab.delay[enemy] = nil
			ab.fakelimit[enemy] = nil
			ab.duration[enemy] = nil
		end
	end
	return nil
end

local function aa_consume_antibrute_swap(enemy, entry)
	if not enemy or not entry or not entry.needs_swap then
		return
	end
	aa_engine.allow_inverter = not aa_engine.allow_inverter
	local ab = aa_engine.ab
	if ab and ab.should_swap then
		ab.should_swap[enemy] = false
	end
end

aa_engine = {
	last_yaw       = 0,
	auto_yaw_last  = 0,
	modifier_index = 0,
	modifier_tick  = 0,
	def_max_tickbase       = 0,
	defensive_ticks        = 0,
	max_defensive_ticks    = 0,
	def_active_config      = nil,
	def_last_sample_source = "createmove",
	def_last_sample_tick   = -1,
	def_last_sampled_base  = 0,
	sent_tick_counter      = 0,
	tick_choke             = 0,
	ab = {
		bruted_last_time = 0,
		time = {},
		jitteralgo = {},
		delay = {},
		fakelimit = {},
		duration = {},
		should_swap = {},
		shooter_name = "Unknown"
	},
	round_ended = false,
	lby_timer      = 0,
	lby_flick_tick = 0,
	last_defensive_fire_tick = -1,
	last_defensive_sim = 0,
	allow_inverter = false,
	switch_delay = 0,
	custom_speed_index = 0,
	delay_custom_target = 0,
	last_aa_state = nil,
	debug_active_state = nil,
	debug_effective_speed = 0,
	debug_config_delay = 0,
	debug_speed_options = "Default",
	debug_antibrute_active = false,
	amnesia_tick = 0,
	amnesia_on = true,
	hold_last_offset = 0,
	mod_last_sent_offset = 0,
	last_exploit_active = nil,
	head_burger = {
		hold_ticks = 0,
		current_yaw = 0,
		activation_delay = 0,
		delay_initialized = false,
		random_buffer = {},
	},
	mouse_yaw = {
		offset = 0,
		target_offset = 0,
		active = false,
		toggled = false,
		hotkey_was_pressed = false,
		last_manual = nil,
		last_alive = false,
		last_enabled = false,
		lock_pitch = nil,
		lock_yaw = nil,
		idle_pitch = nil,
		idle_yaw = nil,
		ind_x = nil,
		ind_y = nil,
		ind_alpha = 0,
		ind_closing = false,
		ind_at_center = false,
		track_x = nil,
		track_y = nil,
		reset_tick = 0,
		reset_reason = "",
		final_yaw = 0,
	},
	def = {
		profiles = {},
		nearest_idx = 0,
		nearest_tag = "unknown",
		nearest_conf = 0,
		nearest_source = "none",
		-- Per-tick scheduling cache
		last_choke_target = 0,
		last_fire_choke = 0,
		prev_choke = 0,
		fire_prev_choke = 0,
		last_shift_tick = -9999,
		air_ticks = 0,
		dtc_air_phase = "ground",
		window_start = false,
		window_fire_armed = false,
		pending_fire_check = false,
		fire_reason = "idle",
		skip_reason = "none",
		early_bias = 0,
		profile_bias = 0,
		last_scan_tick = -1,
		last_force_defensive = false,
		gating_blocked = false,
	},
	shiny = {
		pressure = 0,
		pressure_factors = {},
		visible = false,
		peek_eta = 0,
		last_near_miss = 0,
		last_hurt = 0,
		last_threat_shot = 0,
		threat_dist = 0,
		nearest_dist = 0,
		enemies_near = 0,
		mod_sent_counter = 0,
		mod_offset_buf = {},
		mod_phase = "idle",
		mod_amp_scale = 1,
		mod_self_jitter = false,
		mod_self_jitter_ticks = 0,
		mod_gap_interval = 10,
		delay_target = 0,
		delay_cycle = 0,
	},
}

AA.engine = aa_engine

AA.round_reset = {
	top = {
		{ field = "round_ended", value = false },
		"def_max_tickbase", "defensive_ticks", "max_defensive_ticks",
		{ field = "last_defensive_fire_tick", value = -1 },
		"last_defensive_sim",
		{ field = "def_last_sample_tick", value = -1 },
		"def_last_sampled_base",
		"switch_delay", "delay_custom_target", "hold_last_offset",
		{ field = "amnesia_tick", value = 0 },
		{ field = "amnesia_on", value = true },
		"mod_last_sent_offset", "lby_timer", "lby_flick_tick",
	},
	def = {
		{ field = "profiles", value = {} },
		{ field = "nearest_idx", value = 0 },
		{ field = "nearest_tag", value = "unknown" },
		{ field = "nearest_conf", value = 0 },
		{ field = "nearest_source", value = "none" },
		"last_choke_target", "last_fire_choke", "prev_choke", "fire_prev_choke",
		{ field = "last_shift_tick", value = -9999 },
		"air_ticks",
		{ field = "dtc_air_phase", value = "ground" },
		{ field = "window_start", value = false },
		{ field = "window_fire_armed", value = false },
		{ field = "pending_fire_check", value = false },
		{ field = "fire_reason", value = "idle" },
		{ field = "skip_reason", value = "none" },
		{ field = "last_force_defensive", value = false },
		{ field = "gating_blocked", value = false },
		"early_bias", "profile_bias",
		{ field = "last_scan_tick", value = -1 },
	},
	shiny = {
		"delay_target", "delay_cycle", "mod_sent_counter",
		{ field = "mod_offset_buf", value = {} },
		{ field = "mod_self_jitter", value = false },
		"mod_self_jitter_ticks",
	},
}

-- state detection
local FL_ONGROUND = 1
detect_player_state = function(me, _cmd)
	if not me or not me:is_alive() then return "Standing" end

	local flags = me.m_fFlags or 0
	local velocity = me.m_vecVelocity
	local on_ground = bit.band(flags, FL_ONGROUND) ~= 0
	local duck_amount = me.m_flDuckAmount or 0
	local ducking = me.m_bDucked or duck_amount > 0.55

	local speed_xy = 0
	if velocity then
		speed_xy = math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
	end
	local moving = speed_xy > 1.2

	local slow_walk = refs.slow and refs.slow:get() == true

	if not on_ground then
		return ducking and "Air + Crouch" or "Air"
	elseif slow_walk and not ducking then
		return "Slow Walk"
	elseif ducking then
		return moving and "Crouch Moving" or "Crouching"
	else
		return moving and "Moving" or "Standing"
	end
end
-- config resolution
resolve_state_config = function(player_state)
	local active_state = "Global"
	if player_state ~= "Global" then
		local ovr_switch = builder.override_switches[player_state]
		if ovr_switch and ovr_switch:get() then
			active_state = player_state
		end
	end

	-- Builder UI writes to controls immediately; state_storage only refreshed on
	-- state switch / export before. Sync the open builder state every tick so
	-- slider/combo edits apply without waiting for a tab change.
	save_state(current_state)

	return state_storage[active_state] or state_storage["Global"] or {}
end

local function aa_config_with_overrides(base, overrides)
	if not overrides then return base end
	local copy = nil
	for key, value in pairs(overrides) do
		if base[key] ~= value then
			if not copy then
				copy = {}
				for k, v in pairs(base) do
					copy[k] = v
				end
			end
			copy[key] = value
		end
	end
	return copy or base
end

local function aa_sent_tick()
	return (globals.choked_commands or 0) == 0
end

-- Gingersense handle_side_switching: sent tick only; Net_update throttles ~50% when delay > 1.
local function aa_should_advance_side(config, speed)
	if not aa_sent_tick() then
		return false
	end
	speed = speed or 1
	if speed <= 1 then
		return true
	end
	local interaction = config["event_handler"] or "createmove"
	if interaction ~= "net_update" then
		return true
	end
	return (aa_engine.sent_tick_counter or 0) % 2 == 0
end

local function aa_reset_delay_state()
	aa_engine.switch_delay = 0
	aa_engine.delay_custom_target = 0
	aa_engine.custom_speed_index = 0
	local shiny = aa_engine.shiny
	if shiny then
		shiny.delay_cycle = 0
		shiny.delay_target = 0
	end
end

local function aa_advance_custom_modifier(config, tick)
	local slider_count = config["custom_amount"] or 1
	if aa_sent_tick() and tick ~= aa_engine.modifier_tick then
		aa_engine.modifier_index = aa_engine.modifier_index + 1
		aa_engine.modifier_tick = tick
	end
	return (aa_engine.modifier_index % slider_count) + 1
end
local function table_selection_has(list, val)
	if type(list) == "table" then
		for k, v in pairs(list) do
			if v == val then return true end
			if k == val and v == true then return true end
		end
	end
	return false
end

local calc_shiny_modifier_offset

-- Normalizes a yaw angle into the [-180, 180] range.
local function normalize_yaw(yaw)
	if math.normalize_yaw then
		return math.normalize_yaw(yaw)
	end
	yaw = yaw % 360
	if yaw > 180 then
		yaw = yaw - 360
	elseif yaw < -180 then
		yaw = yaw + 360
	end
	return yaw
end

local MYO_YAW_LIMIT = 90
local MYO_HORIZ_DRAG_MULT = 1
local MYO_CURSOR_RANGE_FRAC = 0.05
local MYO_MIN_CURSOR_RANGE = 30

local MYO_SNAP_DEADZONE = 16
local MYO_IND_CLOSE_RED = color(235, 70, 70, 255)
local MYO_IND_BALL_RADIUS = 13
local MYO_IND_SIDE_EXP = 0.82
local MYO_IND_MOVE_RATE = 15
local MYO_IND_MOVE_POWER = 1.65
local MYO_IND_CLOSE_RATE = 5.5
local MYO_IND_FADE_RATE = 4.0
local MYO_OFFSET_RATE = 18
local MYO_OFFSET_SNAP_POWER = 1.9

local function myo_lerp(a, b, t)
	return a + (b - a) * t
end

local function myo_clamp(val, min_val, max_val)
	if val < min_val then return min_val end
	if val > max_val then return max_val end
	return val
end

local function myo_ease_out(t, power)
	power = power or 2
	t = myo_clamp(t, 0, 1)
	return 1 - (1 - t) ^ power
end

local function myo_exp_lerp(a, b, rate, power)
	local ft = globals.frametime or 0.016
	local t = myo_ease_out(math.min(ft * rate, 1), power)
	return a + (b - a) * t
end

local function myo_smooth_lerp(a, b, rate)
	local ft = globals.frametime or 0.016
	local t = math.min(ft * rate, 1)
	return myo_lerp(a, b, t)
end

local function myo_side_snap_x(center_x, track_x, range)
	local dx = track_x - center_x
	if math.abs(dx) <= MYO_SNAP_DEADZONE then
		return center_x
	end

	local sign = dx > 0 and 1 or -1
	local usable = math.max(range - MYO_SNAP_DEADZONE, 1)
	local norm = myo_clamp((math.abs(dx) - MYO_SNAP_DEADZONE) / usable, 0, 1)
	local smooth = norm * norm * (3 - 2 * norm)
	local curved = smooth ^ MYO_IND_SIDE_EXP
	return center_x + sign * (MYO_SNAP_DEADZONE + curved * usable)
end

local function myo_get_cursor()
	if not ui.get_mouse_position then return nil end
	local ok, mouse = pcall(ui.get_mouse_position)
	if ok and mouse then return mouse end
	return nil
end

local function myo_screen_center(screen)
	return vector(screen.x * 0.5, screen.y * 0.5)
end

local function myo_cursor_range(screen)
	return math.max(MYO_MIN_CURSOR_RANGE, screen.x * MYO_CURSOR_RANGE_FRAC)
end

local function myo_yaw_from_cursor(center, cursor, screen)
	local dx = cursor.x - center.x
	if math.abs(dx) <= MYO_SNAP_DEADZONE then
		return 0
	end
	return dx > 0 and MYO_YAW_LIMIT or -MYO_YAW_LIMIT
end

reset_mouse_yaw = function(reason)
	local state = aa_engine and aa_engine.mouse_yaw
	if not state then return end

	state.offset = 0
	state.target_offset = 0
	state.toggled = false
	state.lock_pitch = nil
	state.lock_yaw = nil
	state.ind_x = nil
	state.ind_y = nil
	state.ind_alpha = 0
	state.ind_closing = false
	state.ind_at_center = false
	state.track_x = nil
	state.track_y = nil
	state.final_yaw = 0
	state.reset_tick = globals.tickcount or 0
	state.reset_reason = reason or "reset"
end

local function deactivate_mouse_yaw_toggle(state)
	state.offset = 0
	state.target_offset = 0
	state.lock_pitch = nil
	state.lock_yaw = nil
	state.track_x = nil
	state.track_y = nil
	state.final_yaw = 0
	state.active = false
	state.ind_closing = true
	state.ind_at_center = false
	state.ind_alpha = math.max(state.ind_alpha or 1, 0.35)
	state.reset_tick = globals.tickcount or 0
	state.reset_reason = "toggle"
end

local function myo_sync_idle_camera(cmd, state)
	local angles = cmd and cmd.view_angles
	if not angles then return end
	state.idle_pitch = angles.x
	state.idle_yaw = angles.y
end

local function myo_begin_capture(state, cmd)
	local angles = cmd and cmd.view_angles
	state.lock_pitch = state.idle_pitch or (angles and angles.x)
	state.lock_yaw = state.idle_yaw or (angles and angles.y)
end

local function myo_end_capture(state)
	state.lock_pitch = nil
	state.lock_yaw = nil
end

local function myo_clear_mouse_delta(cmd)
	if not cmd then return end
	if cmd.mousedx ~= nil then cmd.mousedx = 0 end
	if cmd.mousedy ~= nil then cmd.mousedy = 0 end
end

local function myo_lock_camera(cmd, state)
	local angles = cmd and cmd.view_angles
	if not angles or state.lock_pitch == nil or state.lock_yaw == nil then return end
	angles.x = state.lock_pitch
	angles.y = state.lock_yaw
	myo_clear_mouse_delta(cmd)
end

local function myo_get_effective_cursor(state, cmd, screen)
	local center = myo_screen_center(screen)
	local mouse = myo_get_cursor()
	local range = myo_cursor_range(screen)

	if state.track_x == nil or state.track_y == nil then
		state.track_x = center.x
		state.track_y = center.y
	end

	if cmd then
		local raw_dx = tonumber(cmd.mousedx) or 0
		if raw_dx ~= 0 then
			state.track_x = state.track_x + raw_dx * MYO_HORIZ_DRAG_MULT
		elseif cmd.mousedx == nil and mouse then
			local mouse_dx = mouse.x - center.x
			if math.abs(mouse_dx) > 2 then
				state.track_x = mouse.x
			end
		end
	end

	state.track_x = myo_clamp(state.track_x, center.x - range, center.x + range)
	state.track_y = center.y
	return vector(state.track_x, state.track_y)
end

local function myo_update_offset_from_cursor(state, cmd)
	local screen = render.screen_size()
	if not screen then return end

	local center = myo_screen_center(screen)
	local cursor = myo_get_effective_cursor(state, cmd, screen)
	state.target_offset = myo_yaw_from_cursor(center, cursor, screen)

	state.offset = myo_exp_lerp(state.offset or 0, state.target_offset, MYO_OFFSET_RATE, MYO_OFFSET_SNAP_POWER)
end

local function myo_hotkey_pressed()
	if not setup.mouse_yaw_hotkey then return false end

	local ok, active = pcall(function()
		return setup.mouse_yaw_hotkey:get()
	end)
	if ok and active == true then
		return true
	end

	if ui.get_binds then
		local binds_ok, binds = pcall(ui.get_binds)
		if binds_ok and type(binds) == "table" then
			for _, bind in pairs(binds) do
				if bind and bind.reference == setup.mouse_yaw_hotkey then
					return bind.active == true
				end
			end
		end
	end

	return false
end

local function myo_update_toggle(state)
	if not setup.mouse_yaw or not setup.mouse_yaw:get() then
		state.hotkey_was_pressed = false
		return
	end

	local pressed = myo_hotkey_pressed()
	if pressed and not state.hotkey_was_pressed then
		state.toggled = not state.toggled
	end
	state.hotkey_was_pressed = pressed
end

local function is_mouse_yaw_active()
	local state = aa_engine and aa_engine.mouse_yaw
	return state and state.active == true
end

local function update_mouse_yaw_override(cmd, me)
	local state = aa_engine and aa_engine.mouse_yaw
	if not state then return end

	local enabled = setup.mouse_yaw and setup.mouse_yaw:get() == true
	local alive = me ~= nil and me:is_alive()
	local manual = setup.manual and setup.manual:get() or "Off"
	local was_active = state.active == true

	myo_update_toggle(state)

	local armed = enabled and alive and state.toggled == true

	if state.last_alive and not alive then
		reset_mouse_yaw("death")
	elseif state.last_enabled and not enabled then
		reset_mouse_yaw("disabled")
	elseif state.toggled and not enabled then
		state.toggled = false
	elseif was_active and not armed and alive then
		deactivate_mouse_yaw_toggle(state)
	end

	if state.last_manual ~= nil and state.last_manual ~= manual then
		reset_mouse_yaw("manual")
	end

	state.last_enabled = enabled
	state.last_alive = alive
	state.last_manual = manual

	if not armed then
		myo_end_capture(state)
		myo_sync_idle_camera(cmd, state)
		state.active = false
		return
	end

	if not cmd or not cmd.view_angles then
		state.active = true
		return
	end

	if not was_active then
		state.ind_closing = false
		state.ind_at_center = false
		myo_begin_capture(state, cmd)
		local screen = render.screen_size()
		if screen then
			local center = myo_screen_center(screen)
			local mouse = myo_get_cursor()
			local range = myo_cursor_range(screen)
			state.track_x = mouse and myo_clamp(mouse.x, center.x - range, center.x + range) or center.x
			state.track_y = center.y
			state.ind_x = center.x
			state.ind_y = center.y
			state.ind_alpha = 0
			state.target_offset = 0
		end
	end
	state.active = true

	myo_update_offset_from_cursor(state, cmd)
	myo_lock_camera(cmd, state)
end

local function draw_myo_soft_ball(pos, base_col, ball_radius, alpha_mul)
	if not base_col or not pos then return end
	alpha_mul = alpha_mul or 1

	local inner_a = math.floor((base_col.a or 255) * alpha_mul)
	local inner = color(base_col.r, base_col.g, base_col.b, inner_a)
	local outer = color(base_col.r, base_col.g, base_col.b, 0)
	local mid = color(base_col.r, base_col.g, base_col.b, math.floor(inner_a * 0.45))

	if render.circle_gradient then
		render.circle_gradient(pos, outer, mid, ball_radius * 1.55, 0, 1)
		render.circle_gradient(pos, outer, inner, ball_radius, 0, 1)
	elseif render.circle then
		render.circle(pos, inner, ball_radius, 0, 1)
	end
end

draw_mouse_yaw_indicator = function()
	if not setup.mouse_yaw or not setup.mouse_yaw:get() then return end
	local state = aa_engine and aa_engine.mouse_yaw
	if not state or (not state.active and not state.ind_closing) then return end

	local me = entity.get_local_player()
	if not me or not me:is_alive() then
		state.ind_closing = false
		state.ind_at_center = false
		state.ind_alpha = 0
		state.ind_x = nil
		state.ind_y = nil
		return
	end

	local screen = render.screen_size()
	if not screen then return end

	local center = myo_screen_center(screen)
	local range = myo_cursor_range(screen)

	if state.ind_x == nil or state.ind_y == nil then
		state.ind_x = center.x
		state.ind_y = center.y
	end

	local base_col

	if state.ind_closing then
		state.ind_x = myo_smooth_lerp(state.ind_x, center.x, MYO_IND_CLOSE_RATE)
		state.ind_y = myo_smooth_lerp(state.ind_y, center.y, MYO_IND_CLOSE_RATE)
		state.ind_alpha = myo_smooth_lerp(state.ind_alpha or 1, 0, MYO_IND_FADE_RATE)
		base_col = MYO_IND_CLOSE_RED

		if state.ind_alpha < 0.02 then
			state.ind_closing = false
			state.ind_at_center = false
			state.ind_x = nil
			state.ind_y = nil
			state.ind_alpha = 0
			return
		end
	else
		local target = myo_get_effective_cursor(state, nil, screen)
		local snap_x = myo_side_snap_x(center.x, target.x, range)
		state.ind_x = myo_exp_lerp(state.ind_x, snap_x, MYO_IND_MOVE_RATE, MYO_IND_MOVE_POWER)
		state.ind_y = myo_smooth_lerp(state.ind_y, target.y, MYO_IND_MOVE_RATE)
		state.ind_alpha = myo_smooth_lerp(state.ind_alpha or 0, 1, 10)

		base_col = setup.mouse_yaw_color and setup.mouse_yaw_color:get()
		if not base_col then
			base_col = color(74, 158, 255, 255)
		end
	end

	draw_myo_soft_ball(vector(state.ind_x, state.ind_y), base_col, MYO_IND_BALL_RADIUS, state.ind_alpha)
end


local function get_auto_freestanding_offset()
	local aa = rage and rage.antiaim
	if not aa then return nil end

	local target_yaw = aa:get_target(false)
	local fs_yaw = aa:get_target(true)
	if type(target_yaw) ~= "number" or type(fs_yaw) ~= "number" then return nil end

	return normalize_yaw(fs_yaw - target_yaw)
end

-- Picks the side with the most wall coverage relative to the at-targets yaw.
local function get_auto_cover_offset(me)
	local aa = rage and rage.antiaim
	local target_yaw = aa and aa:get_target(false)
	if not target_yaw then return nil end

	local eye = me:get_eye_position()
	if not eye then return nil end

	local best_side, best_cover = nil, 0
	for _, side in ipairs({ -90, 90, -120, 120, 180 }) do
		local dir = vector():angles(vector(0, target_yaw + side, 0))
		local trace = utils.trace_line(eye, eye + dir * 56, me)
		local cover = 1 - (trace and trace.fraction or 1)
		if cover > best_cover then
			best_cover = cover
			best_side = side
		end
	end

	if best_side and best_cover > 0.12 then
		return best_side
	end
	return nil
end

-- Automatic yaw: At Target base + offset that hides the real head from the threat.
-- Priority: engine freestanding delta â†’ wall-cover side â†’ alternating side offsets.
local function compute_automatic_yaw(config, inverter_on)
	local me = entity.get_local_player()
	if not me or not me:is_alive() then
		return aa_engine.auto_yaw_last or 0
	end

	if not entity.get_threat(false) then
		return aa_engine.auto_yaw_last or 0
	end

	local offset = get_auto_freestanding_offset()
	if not offset or math.abs(offset) < 12 then
		offset = get_auto_cover_offset(me) or offset
	end
	if not offset then
		offset = inverter_on and 90 or -90
	end

	aa_engine.auto_yaw_last = offset
	return offset
end

local function apply_yaw_randomization(base_yaw, config)
	local method = config["yaw_random_methods"] or "Default"
	if method == "Sinusoidal" then
		local freq = config["frequency"] or 8
		local amp = config["amplitude"] or 15
		return base_yaw + math.sin(globals.curtime * freq) * amp
	end
	if method == "Chaotic" then
		local r_min = config["r_min"] or 0
		local r_max = config["r_max"] or 100
		if r_min > r_max then r_min, r_max = r_max, r_min end
		local scale = config["scale"] or 10
		local t = globals.curtime * scale
		return base_yaw + math.random(r_min, r_max) * math.sin(t) * math.cos(t * 2) * math.sin(t * 0.5)
	end

	local randomize = config["yaw_randomize"] or 0
	if randomize > 0 then
		local rand_range = math.abs(base_yaw) * (randomize / 100)
		local rand_offset = (math.random() * 2 - 1) * rand_range
		return base_yaw + rand_offset
	end
	return base_yaw
end

-- Yaw Calculation
local function calculate_yaw(config, tick)
	local yaw_mode = config["yaw_mode"] or "Off"
	if yaw_mode == "Off" then return nil end
	-- Left & Right mode: pick yaw value based on inverter state (syncs with Jitter/Static)
	local inverter_on = aa_engine.allow_inverter == true
	local base_yaw
	
	if yaw_mode == "Left & Right" then
		base_yaw = (not inverter_on) and config["yaw_left"] or config["yaw_right"]
	elseif yaw_mode == "Automatic" then
		base_yaw = compute_automatic_yaw(config, inverter_on)
	else
		-- Fallback for static or other modes if necessary
		base_yaw = config["yaw_left"] or 0
	end
	if yaw_mode ~= "Automatic" then
		base_yaw = apply_yaw_randomization(base_yaw, config)
	end
	return normalize_yaw(base_yaw)
end

-- â”€â”€ Modifier Application â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local function apply_modifier(config, base_yaw, tick)
	local mode = config["jitter"] or "Disabled"
	if mode == "Disabled" then return base_yaw end
	local center_opt = config["center_options"] or "Default"
	local amount     = config["yaw_jitter_ovr"] or 0
	
	local _, antibrute_entry = get_active_antibrute_entry()
	if config["antibrute"] and antibrute_entry then
		if table_selection_has(config["antibrute_method"], "Modifier") then
			amount = amount + antibrute_entry.jitteralgo
		end
	end
	
	local randomize  = config["jitter_randomize"] or 0
	local min_val    = config["center_min"] or -30
	local max_val    = config["center_max"] or 30
	local modifier_offset = 0
	local is_inverter = aa_engine.allow_inverter == true
	
	if mode == "Center" then
		if center_opt == "Default" then
			if aa_sent_tick() then
				local base = amount / 2
				if randomize > 0 then
					base = base + (math.random() * 2 - 1) * math.abs(base) * (randomize / 100)
				end
				modifier_offset = is_inverter and base or -base
				aa_engine.mod_last_sent_offset = modifier_offset
			else
				modifier_offset = aa_engine.mod_last_sent_offset or 0
			end
		elseif center_opt == "Min & Max" then
			if aa_sent_tick() then
				modifier_offset = min_val + math.random() * (max_val - min_val)
				aa_engine.mod_last_sent_offset = modifier_offset
			else
				modifier_offset = aa_engine.mod_last_sent_offset or min_val
			end
		elseif center_opt == "Custom" then
			local idx = aa_advance_custom_modifier(config, tick)
			modifier_offset = config["custom_slider_" .. idx] or 0
		end
	elseif mode == "Offset" then
		if center_opt == "Default" then
			if aa_sent_tick() then
				local base = amount
				if randomize > 0 then
					base = base + (math.random() * 2 - 1) * math.abs(base) * (randomize / 100)
				end
				modifier_offset = is_inverter and base or 0
				aa_engine.mod_last_sent_offset = modifier_offset
			else
				modifier_offset = aa_engine.mod_last_sent_offset or 0
			end
		elseif center_opt == "Min & Max" then
			if aa_sent_tick() then
				modifier_offset = min_val + math.random() * (max_val - min_val)
				aa_engine.mod_last_sent_offset = modifier_offset
			else
				modifier_offset = aa_engine.mod_last_sent_offset or min_val
			end
		elseif center_opt == "Custom" then
			local idx = aa_advance_custom_modifier(config, tick)
			modifier_offset = config["custom_slider_" .. idx] or 0
		end
	elseif mode == "Random" then
		if aa_sent_tick() then
			if center_opt == "Default" then
				modifier_offset = (math.random() * 2 - 1) * math.abs(amount)
			elseif center_opt == "Min & Max" then
				modifier_offset = min_val + math.random() * (max_val - min_val)
			elseif center_opt == "Custom" then
				local slider_count = config["custom_amount"] or 1
				local idx = math.random(1, slider_count)
				modifier_offset = config["custom_slider_" .. idx] or 0
			end
			aa_engine.mod_last_sent_offset = modifier_offset
		else
			modifier_offset = aa_engine.mod_last_sent_offset or 0
		end
	elseif mode == "3-Way" then
		local phase = (aa_engine.sent_tick_counter or 0) % 3
		if center_opt == "Default" then
			if phase == 0 then
				modifier_offset = -math.abs(amount)
			elseif phase == 1 then
				modifier_offset = 0
			else
				modifier_offset = math.abs(amount)
			end
			if randomize > 0 then
				modifier_offset = modifier_offset + (math.random() * 2 - 1) * math.abs(amount) * (randomize / 100)
			end
		elseif center_opt == "Min & Max" then
			local range = max_val - min_val
			if phase == 0 then
				modifier_offset = min_val
			elseif phase == 1 then
				modifier_offset = min_val + range * 0.5
			else
				modifier_offset = max_val
			end
		elseif center_opt == "Custom" then
			local slider_count = config["custom_amount"] or 1
			local idx = (phase % slider_count) + 1
			modifier_offset = config["custom_slider_" .. idx] or 0
		end
	elseif mode == "Spin" then
		if center_opt == "Default" then
			local speed = math.abs(amount) * 2
			modifier_offset = (tick * speed) % 360 - 180
			if randomize > 0 then
				modifier_offset = modifier_offset + (math.random() * 2 - 1) * 20 * (randomize / 100)
			end
		elseif center_opt == "Min & Max" then
			local range = max_val - min_val
			modifier_offset = min_val + ((tick * 5) % range)
		elseif center_opt == "Custom" then
			local slider_count = config["custom_amount"] or 1
			local idx = (tick % slider_count) + 1
			modifier_offset = config["custom_slider_" .. idx] or 0
		end
	elseif mode == "Shiny" then
		if aa_sent_tick() then
			aa_engine.shiny.mod_sent_counter = (aa_engine.shiny.mod_sent_counter or 0) + 1
			modifier_offset = calc_shiny_modifier_offset(
				config, amount, min_val, max_val, tick, is_inverter, center_opt, randomize
			)
			aa_engine.mod_last_sent_offset = modifier_offset
		else
			modifier_offset = aa_engine.mod_last_sent_offset or 0
		end
	elseif mode == "Hold" then
		if not aa_sent_tick() then
			modifier_offset = aa_engine.hold_last_offset or 0
		else
			local chance = math.random(1, 100)

			local function get_randomized(val)
				if randomize > 0 then
					return val + (math.random() * 2 - 1) * math.abs(val) * (randomize / 100)
				end
				return val
			end

			local is_left = aa_engine.allow_inverter ~= true
			if is_left then
				if chance <= 45 then
					modifier_offset = get_randomized(amount)
				elseif chance <= 75 then
					modifier_offset = -math.abs(get_randomized(amount * 0.8))
				else
					modifier_offset = math.random(-5, 0)
				end
			else
				if chance <= 45 then
					modifier_offset = get_randomized(amount)
				elseif chance <= 75 then
					modifier_offset = math.abs(get_randomized(amount * 0.8))
				else
					modifier_offset = math.random(0, 5)
				end
			end
			aa_engine.hold_last_offset = modifier_offset
		end
	end

	local final = base_yaw

	if mode == "Offset" or mode == "Random" then
		if refs.jitter then refs.jitter:override(mode) end
		if refs.jitter_val then refs.jitter_val:override(modifier_offset) end
	else
		if refs.jitter then refs.jitter:override("Disabled") end
		if refs.jitter_val then refs.jitter_val:override(0) end
		final = final + modifier_offset
	end
	
	final = normalize_yaw(final)
	return final
end

-- â”€â”€ Shiny Delay Speed (threat-aware evasion) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local function is_exploit_active()
	return rage and rage.exploit and rage.exploit:get() == 1
end

local SHINY_SNIPE_INDEX = { [9] = true, [40] = true, [38] = true }

-- ── AA.shiny ── pressure model
local SHINY_PRESSURE_WEIGHTS = {
	proximity   = 0.20,
	approach    = 0.10,
	peek        = 0.14,
	visibility  = 0.17,
	shoot_ready = 0.13,
	exposure    = 0.09,
	combat      = 0.13,
	self_risk   = 0.04,
}

local function shiny_clamp01(v)
	return math.max(0, math.min(1, v))
end

local function shiny_smoothstep(edge0, edge1, x)
	if edge1 == edge0 then return x >= edge1 and 1 or 0 end
	local t = shiny_clamp01((x - edge0) / (edge1 - edge0))
	return t * t * (3 - 2 * t)
end

local function shiny_decay_factor(elapsed, window)
	if window <= 0 or elapsed < 0 or elapsed >= window then return 0 end
	return 1 - (elapsed / window)
end

local function shiny_dist_factor(dist)
	if dist == nil or dist >= math.huge then return 0 end
	if dist <= 300 then return 1 end
	if dist >= 2200 then return 0 end
	return 1 - shiny_smoothstep(300, 2200, dist)
end

local function shiny_collect_enemy_distances(me, my_origin, focus_enemy)
	local nearest_dist = math.huge
	local threat_dist = math.huge
	local surround_sum = 0
	local enemies_near = 0

	if not my_origin or not entity.get_players then
		return nearest_dist, threat_dist, surround_sum, enemies_near
	end

	local players = entity.get_players(true)
	if not players then
		return nearest_dist, threat_dist, surround_sum, enemies_near
	end

	for i = 1, #players do
		local enemy = players[i]
		if enemy and enemy ~= me and enemy:is_alive() and enemy:is_enemy() then
			local origin = enemy:get_origin()
			if origin then
				local dist = my_origin:dist(origin)
				if dist < nearest_dist then
					nearest_dist = dist
				end
				if focus_enemy and enemy == focus_enemy then
					threat_dist = dist
				end
				if dist < 1100 then
					enemies_near = enemies_near + 1
					surround_sum = surround_sum + shiny_dist_factor(dist)
				end
			end
		end
	end

	return nearest_dist, threat_dist, surround_sum, enemies_near
end

local function shiny_proximity_factor(me, my_origin, focus_enemy, focus_origin)
	local threat_dist = math.huge
	if focus_origin and my_origin then
		threat_dist = my_origin:dist(focus_origin)
	end

	local nearest_dist, scanned_threat_dist, surround_sum, enemies_near =
		shiny_collect_enemy_distances(me, my_origin, focus_enemy)

	if scanned_threat_dist < math.huge then
		threat_dist = scanned_threat_dist
	end
	if nearest_dist >= math.huge then
		nearest_dist = threat_dist
	end

	local threat_factor = shiny_dist_factor(threat_dist)
	local nearest_factor = shiny_dist_factor(nearest_dist)
	local surround_factor = shiny_clamp01(surround_sum / math.max(1, enemies_near))

	local proximity = nearest_factor * 0.42
		+ threat_factor * 0.38
		+ surround_factor * 0.20

	if enemies_near >= 2 then
		proximity = shiny_clamp01(proximity + 0.08 * math.min(3, enemies_near - 1))
	end

	return shiny_clamp01(proximity), threat_dist, nearest_dist, enemies_near
end

local function shiny_approach_factor(closing)
	if closing <= 0 then return 0 end
	if closing >= 250 then return 1 end
	return shiny_smoothstep(0, 250, closing)
end

local function shiny_peek_factor(eta)
	if eta <= 0 then return 0 end
	if eta <= 0.1 then return 1 end
	if eta >= 1.2 then return 0 end
	return 1 - shiny_smoothstep(0.1, 1.2, eta)
end

local function shiny_exposure_factor(yaw_delta)
	if yaw_delta >= 90 then return 0 end
	if yaw_delta <= 12 then return 1 end
	return 1 - shiny_smoothstep(12, 90, yaw_delta)
end

local function shiny_combat_factor(shiny, curtime)
	local peak = 0
	peak = math.max(peak, shiny_decay_factor(curtime - (shiny.last_hurt or 0), 0.55))
	peak = math.max(peak, shiny_decay_factor(curtime - (shiny.last_near_miss or 0), 0.45) * 0.82)
	peak = math.max(peak, shiny_decay_factor(curtime - (shiny.last_threat_shot or 0), 0.5) * 0.65)
	return shiny_clamp01(peak)
end

local function shiny_self_risk_factor(me)
	local health = me.m_iHealth or 100
	local vel_mod = me.m_flVelocityModifier or 1.0
	local hp_factor = 1 - shiny_smoothstep(20, 100, health)
	local tag_factor = vel_mod < 1 and shiny_clamp01(1 - vel_mod) or 0
	return shiny_clamp01(hp_factor * 0.7 + tag_factor * 0.5)
end

local function shiny_vec_len2d(v)
	if not v then return 0 end
	local x, y = v.x or 0, v.y or 0
	return math.sqrt(x * x + y * y)
end

local function shiny_hash01(seed)
	local x = math.sin((seed or 0) * 12.9898 + 78.233) * 43758.5453
	return x - math.floor(x)
end

local function shiny_hash_range(seed, lo, hi)
	lo = math.floor(lo or 1)
	hi = math.floor(hi or lo)
	if hi <= lo then return lo end
	return lo + math.floor(shiny_hash01(seed) * (hi - lo + 1))
end

local function shiny_uses_pressure(config)
	return config["jitter"] == "Shiny" or config["speed_options"] == "Shiny"
end

local function shiny_pressure_band(pressure)
	pressure = pressure or 0
	if pressure >= 78 then return 4 end
	if pressure >= 58 then return 3 end
	if pressure >= 38 then return 2 end
	if pressure >= 18 then return 1 end
	return 0
end

local function shiny_update_lby_clock(me)
	if not me then return end
	local flags = me.m_fFlags or 0
	local on_ground = bit.band(flags, FL_ONGROUND) ~= 0
	local speed = shiny_vec_len2d(me.m_vecVelocity)
	local sim = me.m_flSimulationTime or globals.curtime or 0

	if not on_ground or speed > 1.0 then
		aa_engine.lby_timer = sim
		return
	end

	local since = sim - (aa_engine.lby_timer or 0)
	if since >= 1.05 then
		aa_engine.lby_flick_tick = sim
		aa_engine.lby_timer = sim
	end
end

local function shiny_has_los(me, threat, my_origin, threat_origin)
	if not utils or not utils.trace_line then
		return true
	end

	local my_eye = me:get_eye_position() or me:get_hitbox_position(0) or my_origin
	local threat_eye = threat:get_eye_position() or threat:get_hitbox_position(0) or threat_origin
	if not my_eye or not threat_eye then
		return true
	end

	local trace = utils.trace_line(my_eye, threat_eye, me)
	return trace and trace.fraction >= 0.97
end

local function shiny_threat_can_fire(threat, curtime)
	local weapon = threat:get_player_weapon(false)
	if not weapon then return false end

	local next_attack = weapon.m_flNextPrimaryAttack or 0
	return next_attack <= curtime + globals.tickinterval
end

local function shiny_update_pressure(me, shiny)
	local threat = entity.get_threat(true)
	local curtime = globals.curtime
	local factors = {}

	if not threat or not threat:is_alive() then
		shiny.visible = false
		shiny.peek_eta = 0
		shiny.holding_sniper = false

		local my_origin = me:get_origin()
		if my_origin then
			local prox, threat_dist, nearest_dist, enemies_near =
				shiny_proximity_factor(me, my_origin, nil, nil)
			factors.proximity = prox
			shiny.threat_dist = threat_dist < math.huge and math.floor(threat_dist) or 0
			shiny.nearest_dist = nearest_dist < math.huge and math.floor(nearest_dist) or 0
			shiny.enemies_near = enemies_near
		else
			shiny.threat_dist = 0
			shiny.nearest_dist = 0
			shiny.enemies_near = 0
		end

		factors.combat = shiny_combat_factor(shiny, curtime)
		factors.self_risk = shiny_self_risk_factor(me)

		local pressure = 0
		for key, weight in pairs(SHINY_PRESSURE_WEIGHTS) do
			pressure = pressure + (factors[key] or 0) * weight
		end
		pressure = math.floor(pressure * 100 + 0.5)

		shiny.pressure_factors = factors
		shiny.pressure = math.max(0, math.min(100, pressure))
		return nil
	end

	local my_origin = me:get_origin()
	local threat_origin = threat:get_origin()
	if not my_origin or not threat_origin then
		shiny.pressure = shiny_clamp01(shiny_combat_factor(shiny, curtime)) * 100
		return threat
	end

	local dist = my_origin:dist(threat_origin)
	local to_me = my_origin - threat_origin
	local flat_len = math.sqrt(to_me.x * to_me.x + to_me.y * to_me.y)
	local dir_x, dir_y = 0, 0
	if flat_len > 1 then
		dir_x = to_me.x / flat_len
		dir_y = to_me.y / flat_len
	end

	local t_vel = threat.m_vecVelocity or { x = 0, y = 0, z = 0 }
	local closing = -(t_vel.x * dir_x + t_vel.y * dir_y)

	local prox, threat_dist, nearest_dist, enemies_near =
		shiny_proximity_factor(me, my_origin, threat, threat_origin)
	factors.proximity = prox
	shiny.threat_dist = math.floor(threat_dist < math.huge and threat_dist or dist)
	shiny.nearest_dist = math.floor(nearest_dist < math.huge and nearest_dist or dist)
	shiny.enemies_near = enemies_near

	factors.approach = shiny_approach_factor(closing)

	if closing > 25 and flat_len > 1 then
		shiny.peek_eta = flat_len / closing
		factors.peek = shiny_peek_factor(shiny.peek_eta)
	else
		shiny.peek_eta = 0
		factors.peek = 0
	end

	local visible = shiny_has_los(me, threat, my_origin, threat_origin)
	shiny.visible = visible
	factors.visibility = visible and 1 or 0

	factors.shoot_ready = 0
	shiny.holding_sniper = false

	if visible then
		local can_fire = shiny_threat_can_fire(threat, curtime)
		local weapon = threat:get_player_weapon(false)
		local widx = weapon and weapon:get_weapon_index() or 0
		local t_speed2d = shiny_vec_len2d(t_vel)

		if SHINY_SNIPE_INDEX[widx] and t_speed2d < 25 then
			shiny.holding_sniper = true
			factors.shoot_ready = can_fire and 0.55 or 0.35
		else
			factors.shoot_ready = can_fire and 1 or 0.2
		end
	end

	local my_eye = me:get_eye_position() or my_origin
	local look = threat_origin - my_eye
	if look:length() > 1 then
		local threat_yaw = look:angles().y
		local my_yaw = (me:get_angles() or { y = 0 }).y
		local yaw_delta = math.abs((my_yaw - threat_yaw + 180) % 360 - 180)
		factors.exposure = shiny_exposure_factor(yaw_delta)
	else
		factors.exposure = 0
	end

	factors.combat = shiny_combat_factor(shiny, curtime)
	factors.self_risk = shiny_self_risk_factor(me)

	if refs.autopeek and refs.autopeek:get() then
		factors.exposure = shiny_clamp01(factors.exposure + 0.35)
		factors.peek = shiny_clamp01(factors.peek + 0.25)
	end

	local pressure = 0
	for key, weight in pairs(SHINY_PRESSURE_WEIGHTS) do
		pressure = pressure + (factors[key] or 0) * weight
	end
	pressure = math.floor(pressure * 100 + 0.5)

	shiny.pressure_factors = factors
	shiny.pressure = math.max(0, math.min(100, pressure))
	return threat
end

local shiny_build_modifier_context
local shiny_modifier_amp_scale
local shiny_modifier_event_layer
local shiny_compute_shift
local shiny_modifier_sdk_layer
local shiny_apply_antiresolver
local shiny_should_gap
local shiny_finalize_offset
local shiny_modifier_minmax_pipeline
local shiny_modifier_custom_pipeline

local function shiny_compute_delay_target(config, me, tick, base_speed, cycle)
	local max_speed = math.max(1, math.floor(base_speed or 3))
	local shiny = aa_engine.shiny
	local choked = globals.choked_commands or 0
	local curtime = globals.curtime or 0
	local fl_limit = get_fakelag_limit()
	local pressure = shiny.pressure or 0
	local band = shiny_pressure_band(pressure)
	local seed = (cycle or 1) * 131 + band * 19 + (tick or 0)

	if choked >= math.max(10, fl_limit - 2)
		or (is_exploit_active() and choked >= math.max(6, fl_limit - 5)) then
		return max_speed
	end

	local since_hurt = curtime - (shiny.last_hurt or 0)
	local since_miss = curtime - (shiny.last_near_miss or 0)
	local since_brute = math.abs((aa_engine.ab.bruted_last_time or 0) - curtime)

	if since_hurt < 0.35 then
		return 1
	end
	if since_miss < 0.22 then
		return shiny_hash_range(seed, 1, math.min(2, max_speed))
	end
	if since_brute < 1.5 then
		return shiny_hash_range(seed + 3, 1, math.min(3, max_speed))
	end

	if shiny.peek_eta > 0 and shiny.peek_eta < 0.10 then
		return 1
	end
	if shiny.peek_eta > 0 and shiny.peek_eta < 0.30 then
		return math.max(1, math.floor(max_speed * 0.35))
	end

	local factors = shiny.pressure_factors or {}
	if shiny.holding_sniper and shiny.visible then
		return math.min(max_speed + 1, shiny_hash_range(seed + 5, math.max(1, max_speed - 1), max_speed + 1))
	end
	if (factors.shoot_ready or 0) >= 0.75 and shiny.visible then
		return math.max(1, math.floor(max_speed * 0.3))
	end

	if band >= 4 then
		return shiny_hash_range(seed + 7, 1, math.min(2, max_speed))
	elseif band >= 3 then
		return math.max(1, math.floor(max_speed * 0.35) + shiny_hash_range(seed + 9, 0, 1))
	elseif band >= 2 then
		return shiny_hash_range(seed + 11, 2, math.max(2, math.floor(max_speed * 0.65)))
	elseif band >= 1 then
		return shiny_hash_range(seed + 13, math.max(2, math.floor(max_speed * 0.5)), max_speed)
	end

	local vel = me.m_vecVelocity or { x = 0, y = 0 }
	local speed2d = shiny_vec_len2d(vel)
	local duck = me.m_flDuckAmount or 0
	local on_ground = bit.band(me.m_fFlags or 0, FL_ONGROUND) ~= 0
	local chaos = shiny_hash01(seed + 19)

	if not on_ground then
		if speed2d > 150 then return max_speed end
		return math.max(1, math.floor(chaos * max_speed * 0.6) + 1)
	end

	if duck >= 0.5 and speed2d < 5 then
		local hold = math.max(1, math.floor(chaos * max_speed * 0.85) + 1)
		if (cycle or 0) % 7 == 0 then return 1 end
		return hold
	end

	if speed2d > 5 then
		local move = math.max(1, math.floor(chaos * max_speed * 0.55) + 1)
		if (cycle or 0) % 5 == 0 then return 1 end
		return move
	end

	local stand = math.max(1, math.floor(chaos * max_speed * 0.75) + 1)
	if (cycle or 0) % 6 == 0 then return 1 end
	if (cycle or 0) % 9 == 0 then return max_speed end
	return stand
end

local function shiny_refresh_delay_target(config, me, tick, base_speed)
	local shiny = aa_engine.shiny
	shiny.delay_cycle = (shiny.delay_cycle or 0) + 1
	shiny.delay_target = shiny_compute_delay_target(
		config, me, tick, base_speed, shiny.delay_cycle
	)
	return shiny.delay_target
end

local function shiny_sent_tick()
	return (globals.choked_commands or 0) == 0
end

local function shiny_threat_side_bias(me, threat)
	if not me or not threat then return 0 end

	local eye = me:get_eye_position() or me:get_origin()
	local t_origin = threat:get_origin()
	if not eye or not t_origin then return 0 end

	local rel = t_origin - eye
	if rel:length() < 1 then return 0 end

	local threat_yaw = rel:angles().y
	local my_yaw = (me:get_angles() or { y = 0 }).y
	local delta = (threat_yaw - my_yaw + 180) % 360 - 180
	return delta
end

local function shiny_angle_diff(a, b)
	if math.angle_diff then
		return math.angle_diff(a, b)
	end
	return (a - b + 180) % 360 - 180
end

local function shiny_direction_sign(ctx, use_side_bias)
	if use_side_bias and ctx.threat and ctx.side_bias ~= 0 then
		return ctx.side_bias >= 0 and 1 or -1
	end
	return ctx.is_inverter and 1 or -1
end

local function shiny_quantize_mag(mag)
	return math.floor(mag / 4 + 0.5) * 4
end

local function shiny_detect_self_jitter(buf)
	if not buf or #buf < 4 then return false end
	local flips = 0
	for i = 2, #buf do
		if math.abs(shiny_angle_diff(buf[i], buf[i - 1])) > 20 then
			flips = flips + 1
		end
	end
	return flips >= 2
end

shiny_build_modifier_context = function(me, config, tick, amount, is_inverter, min_val, max_val, randomize, center_opt)
	local shiny = aa_engine.shiny
	local curtime = globals.curtime
	local sim_time = me.m_flSimulationTime or curtime
	local vel = me.m_vecVelocity or { x = 0, y = 0 }
	local threat = entity.get_threat(true)
	local threat_dist = shiny.threat_dist or 0
	local nearest_dist = shiny.nearest_dist or 0
	local lo = math.min(min_val or -30, max_val or 30)
	local hi = math.max(min_val or -30, max_val or 30)
	center_opt = center_opt or "Default"

	local amp = math.abs(amount or 0)
	if center_opt == "Min & Max" then
		amp = math.max(6, amp, math.abs(hi - lo) * 0.5)
	elseif center_opt == "Custom" then
		local slider_count = config["custom_amount"] or 1
		local peak = 0
		for i = 1, slider_count do
			peak = math.max(peak, math.abs(config["custom_slider_" .. i] or 0))
		end
		amp = math.max(6, peak, amp)
	elseif amp <= 0 then
		amp = math.max(6, (shiny.pressure or 0) * 0.14)
	else
		amp = math.max(4, amp)
	end

	return {
		me = me,
		config = config,
		tick = tick,
		center_opt = center_opt,
		randomize = randomize or 0,
		min_val = lo,
		max_val = hi,
		range_half = math.abs(hi - lo) * 0.5,
		is_inverter = is_inverter,
		shiny = shiny,
		sent = shiny_sent_tick(),
		curtime = curtime,
		phi = 1.6180339887,
		pressure = shiny.pressure or 0,
		factors = shiny.pressure_factors or {},
		player_state = detect_player_state(me, nil),
		speed = shiny_vec_len2d(vel),
		on_ground = bit.band(me.m_fFlags or 0, FL_ONGROUND) ~= 0,
		duck_amount = me.m_flDuckAmount or 0,
		dist = threat_dist > 0 and threat_dist or nearest_dist,
		threat_dist = threat_dist,
		nearest_dist = nearest_dist,
		threat = threat,
		side_bias = threat and shiny_threat_side_bias(me, threat) or 0,
		defensive = (aa_engine.defensive_ticks or 0) > 0,
		since_hurt = curtime - (shiny.last_hurt or 0),
		since_miss = curtime - (shiny.last_near_miss or 0),
		lby_flick_window = (sim_time - (aa_engine.lby_flick_tick or 0)) < 0.15,
		amp = amp,
		amp_scale = 1,
		effective_amp = amp,
		visible = shiny.visible,
		peek_eta = shiny.peek_eta or 0,
		holding_sniper = shiny.holding_sniper,
	}
end

shiny_modifier_amp_scale = function(ctx)
	local pressure = ctx.pressure
	local scale

	if pressure < 38 then
		scale = 0.55 + (pressure / 38) * 0.15
	elseif pressure < 58 then
		scale = 0.70 + ((pressure - 38) / 20) * 0.15
	elseif pressure < 72 then
		scale = 0.85 + ((pressure - 58) / 14) * 0.15
	else
		scale = 1.00 + math.min(0.15, (pressure - 72) / 100 * 0.15)
	end

	local factors = ctx.factors
	scale = scale + (factors.combat or 0) * 0.10
	scale = scale + (factors.shoot_ready or 0) * 0.08
	scale = scale + (factors.visibility or 0) * (ctx.defensive and 0.06 or 0.03)
	scale = scale - (factors.self_risk or 0) * 0.10
	scale = math.max(0.45, math.min(1.15, scale))

	ctx.amp_scale = scale
	ctx.effective_amp = ctx.amp * scale
	ctx.shiny.mod_amp_scale = scale
	return scale
end

shiny_modifier_event_layer = function(ctx)
	local amp = ctx.effective_amp
	local sent = ctx.sent
	local tick = ctx.tick
	local phi = ctx.phi
	local shiny = ctx.shiny
	local config = ctx.config
	local critical_only = ctx.center_opt ~= "Default"

	if ctx.since_hurt < 0.35 then
		if sent then
			return amp * shiny_direction_sign(ctx, true), "hurt"
		end
		return math.sin(tick * 3.1) * amp * 0.12, "hurt_choke"
	end

	if ctx.since_miss < 0.25 then
		if sent then
			local sign = shiny_hash01((shiny.mod_sent_counter or 0) + 41) > 0.35 and 1 or -1
			return amp * sign, "miss"
		end
		return amp * math.sin(tick * 3.1) * 0.45, "miss_choke"
	end

	local _, antibrute_entry = get_active_antibrute_entry()
	if config["antibrute"] and antibrute_entry then
		local brute_amp = amp * (1 + math.abs(antibrute_entry.jitteralgo or 0) * 0.07)
		if sent then
			local sign = (shiny.mod_sent_counter or 0) % 2 == 0 and 1 or -1
			return brute_amp * sign, "antibrute"
		end
		return math.sin(tick * phi) * brute_amp * 0.35, "antibrute_choke"
	end

	if ctx.defensive then
		if sent then
			local sign = shiny_direction_sign(ctx, true)
			return amp * 0.9 * sign, "defensive"
		end
		return math.sin(tick * 2.8) * amp * 0.3, "defensive_choke"
	end

	if critical_only then
		return nil
	end

	if ctx.player_state == "Standing" and ctx.lby_flick_window and sent then
		local flick_seed = (shiny.mod_sent_counter or 0) + math.floor((ctx.curtime or 0) * 10)
		local mag = shiny_quantize_mag(amp * (0.75 + shiny_hash01(flick_seed) * 0.25))
		return mag * shiny_direction_sign(ctx, true), "lby_snap"
	end

	return nil
end

local function shiny_remap_event_offset(ctx, offset, phase)
	if ctx.center_opt == "Min & Max" then
		if offset >= 0 then
			return ctx.max_val
		end
		return ctx.min_val
	end

	if ctx.center_opt == "Custom" then
		local slider_count = math.max(1, ctx.config["custom_amount"] or 1)
		local idx = ((ctx.shiny.mod_sent_counter or 1) - 1) % slider_count + 1
		local base = ctx.config["custom_slider_" .. idx] or 0
		if math.abs(base) > 0 then
			if phase == "hurt" or phase == "miss" or phase == "defensive" then
				return -base
			end
			return base
		end
	end

	return offset
end

shiny_modifier_sdk_layer = function(ctx, amp)
	local sent = ctx.sent
	local tick = ctx.tick
	local phi = ctx.phi
	local shiny = ctx.shiny
	local state = ctx.player_state
	local counter = shiny.mod_sent_counter or 0
	local snap_mod = 5 + (counter % 5)

	if state == "Air" or state == "Air + Crouch" then
		local air_amp = state == "Air + Crouch" and amp * 0.7 or amp
		local wave = math.sin(tick * 2.4) * air_amp * 0.55 + math.cos(ctx.curtime * 4) * air_amp * 0.25
		shiny.mod_phase = state == "Air + Crouch" and "air_crouch" or "air"
		if ctx.pressure >= 58 and sent then
			return air_amp * shiny_direction_sign(ctx, false)
		end
		return sent and wave or wave * (state == "Air + Crouch" and 0.25 or 0.35)
	end

	if state == "Slow Walk" then
		shiny.mod_phase = "slow_walk"
		local hold = sent and ((counter % 4 == 0) and amp * 0.75 * shiny_direction_sign(ctx, true) or amp * 0.5 * math.sin(tick * phi * 0.06)) or amp * 0.375 * math.sin(tick * phi * 0.08)
		return hold
	end

	if state == "Crouching" then
		shiny.mod_phase = "crouch"
		local duck_scale = 0.6 + 0.4 * ctx.duck_amount
		return math.sin(tick * phi * 0.1) * amp * duck_scale * (sent and 1 or 0.5)
	end

	if state == "Crouch Moving" then
		shiny.mod_phase = "crouch_move"
		local move_amp = amp * 0.85
		if sent then
			return move_amp * shiny_direction_sign(ctx, ctx.threat ~= nil)
		end
		return math.sin(tick * 2.6) * move_amp * 0.35
	end

	if state == "Standing" or (ctx.on_ground and ctx.speed < 0.1) then
		shiny.mod_phase = "standing"
		if sent then
			if ctx.pressure >= 72 and ctx.visible then
				return amp * shiny_direction_sign(ctx, true)
			elseif counter % snap_mod == 0 then
				local snap_seed = counter + tick
				local mag = shiny_quantize_mag(amp * (0.65 + shiny_hash01(snap_seed) * 0.35))
				if mag > 20 and tick % 2 == 0 then
					mag = mag * 0.7
				end
				return mag * shiny_direction_sign(ctx, true)
			end
			return math.sin(tick * phi * 0.08) * amp * 0.28
		end
		return math.sin(tick * phi * 0.12) * amp * 0.15
	end

	shiny.mod_phase = "moving"
	if sent then
		return amp * shiny_direction_sign(ctx, ctx.threat ~= nil)
	end
	return math.sin(tick * 2.6) * amp * 0.4
end

shiny_compute_shift = function(ctx, range)
	local sent = ctx.sent
	local tick = ctx.tick
	local phi = ctx.phi
	local factors = ctx.factors
	local shiny = ctx.shiny
	local amp = range
	local shift = 0

	if ctx.peek_eta > 0 and ctx.peek_eta < 0.12 and sent then
		ctx.shiny.mod_phase = "peek_tight"
		return amp * 1.1 * shiny_direction_sign(ctx, true)
	end

	if ctx.pressure >= 72 and ctx.visible then
		ctx.shiny.mod_phase = "pressure_high"
		return sent and amp * shiny_direction_sign(ctx, true) or math.sin(tick * 2.6) * amp * 0.4
	end

	if ctx.peek_eta > 0 and ctx.peek_eta < 0.18 and sent then
		ctx.shiny.mod_phase = "peek"
		return amp * shiny_direction_sign(ctx, false)
	end

	if ctx.holding_sniper and ctx.dist > 550 then
		ctx.shiny.mod_phase = "sniper_hold"
		return sent and ((tick % 3 == 0) and amp or -amp * 0.65) or math.sin(tick * 0.12) * amp * 0.2
	end

	if ctx.threat and ctx.dist > 700 then
		local t_vel = ctx.threat.m_vecVelocity or { x = 0, y = 0 }
		if shiny_vec_len2d(t_vel) < 18 and ctx.visible then
			ctx.shiny.mod_phase = "slow_aim"
			return sent and ((tick % 4 < 2) and amp or -amp) or math.sin(tick * 0.14) * amp * 0.22
		end
	end

	if ctx.threat then
		local t_vel = ctx.threat.m_vecVelocity or { x = 0, y = 0 }
		local t_speed = shiny_vec_len2d(t_vel)

		if t_speed > 110 then
			ctx.shiny.mod_phase = "threat_fast"
			return sent and amp * shiny_direction_sign(ctx, true) or math.sin(tick * 2.4) * amp
		end

		ctx.shiny.mod_phase = "threat_slow"
		local golden = ((shiny.mod_sent_counter or 0) * phi) % 2
		local surround = math.min(3, shiny.enemies_near or 1)
		shift = (golden - 1) * amp * (1 + 0.12 * math.max(0, surround - 1))

		if (factors.approach or 0) > 0.45 and sent then
			shift = shift + amp * 0.28 * shiny_direction_sign(ctx, false)
		end
		if (factors.proximity or 0) > 0.6 and ctx.dist > 0 and ctx.dist < 500 and sent then
			shift = shift + amp * 0.18 * shiny_direction_sign(ctx, true)
		end
		return shift
	end

	if ctx.nearest_dist > 0 and ctx.nearest_dist < 950 then
		ctx.shiny.mod_phase = "prox_wave"
		local wave = math.sin((shiny.mod_sent_counter or 0) * phi * 0.12) * amp
		local burst = shiny_hash01((shiny.mod_sent_counter or 0) + 53) > 0.68
		return sent and (burst and amp * 0.75 or wave) or wave * 0.35
	end

	return shiny_modifier_sdk_layer(ctx, amp)
end

shiny_apply_antiresolver = function(raw, ctx)
	local shiny = ctx.shiny
	local buf = shiny.mod_offset_buf or {}

	if shiny_detect_self_jitter(buf) then
		shiny.mod_self_jitter = true
		shiny.mod_self_jitter_ticks = shiny_hash_range((shiny.mod_sent_counter or 0) + 71, 2, 4)
	end

	if (shiny.mod_self_jitter_ticks or 0) > 0 then
		shiny.mod_self_jitter_ticks = shiny.mod_self_jitter_ticks - 1
		shiny.mod_self_jitter = true
		if ctx.sent then
			if shiny.mod_self_jitter_ticks >= 2 then
				return 0, "antiresolver_gap"
			end
			local micro = shiny_hash_range((shiny.mod_sent_counter or 0) + 79, 4, 8)
			return micro * shiny_direction_sign(ctx, true), "antiresolver_micro"
		end
		return raw * 0.4, "antiresolver_choke"
	end

	shiny.mod_self_jitter = false

	if #buf >= 3 then
		local a, b, c = buf[#buf], buf[#buf - 1], buf[#buf - 2]
		if (a > 0 and b > 0 and c > 0) or (a < 0 and b < 0 and c < 0) then
			if math.abs(a - b) < 8 and math.abs(b - c) < 8 then
				return raw * 0.6 * -1, "repeat_invert"
			end
		end
	end

	if ctx.sent and math.abs(raw) > 4 and ctx.center_opt == "Default" then
		raw = shiny_quantize_mag(math.abs(raw)) * (raw >= 0 and 1 or -1)
	end

	return raw, ctx.shiny.mod_phase
end

shiny_should_gap = function(ctx)
	local shiny = ctx.shiny
	if not ctx.sent then return false end
	local interval = shiny.mod_gap_interval or 10
	if (shiny.mod_sent_counter or 0) > 0 and (shiny.mod_sent_counter % interval) == 0 then
		shiny.mod_gap_interval = shiny_hash_range((shiny.mod_sent_counter or 0) + 67, 8, 12)
		return true
	end
	return false
end

shiny_finalize_offset = function(raw, ctx, phase, randomize, update_buf)
	local shiny = ctx.shiny
	randomize = randomize or ctx.randomize or 0
	update_buf = update_buf ~= false

	if randomize > 0 and ctx.center_opt == "Default" then
		local jitter = (shiny_hash01((shiny.mod_sent_counter or 0) + 91) * 2 - 1)
		raw = raw + jitter * ctx.effective_amp * (randomize / 100) * 0.3
	end

	local boost_base = ctx.center_opt == "Min & Max" and ctx.range_half or ctx.effective_amp
	if (ctx.factors.combat or 0) > 0.35 and ctx.sent and phase ~= "hurt" and phase ~= "miss" then
		raw = raw + boost_base * 0.15 * (ctx.tick % 2 == 0 and 1 or -1)
	end

	raw = math.max(-180, math.min(180, raw))
	shiny.mod_phase = phase or shiny.mod_phase or "idle"

	if update_buf and ctx.sent and math.abs(raw) > 0.5 then
		local buf = shiny.mod_offset_buf or {}
		table.insert(buf, raw)
		if #buf > 8 then
			table.remove(buf, 1)
		end
		shiny.mod_offset_buf = buf
	end

	return raw
end

shiny_modifier_minmax_pipeline = function(ctx)
	local mid = (ctx.min_val + ctx.max_val) * 0.5
	local half = ctx.range_half * (ctx.amp_scale or 1)
	local buf = ctx.shiny.mod_offset_buf or {}

	if ctx.since_hurt < 0.35 then
		if #buf > 0 then
			return buf[#buf] > 0 and ctx.min_val or ctx.max_val, "minmax_hurt"
		end
		if ctx.sent then
			return shiny_direction_sign(ctx, true) >= 0 and ctx.max_val or ctx.min_val, "minmax_hurt"
		end
		return mid, "minmax_hurt_choke"
	end

	if ctx.pressure >= 50 and ctx.sent then
		return ctx.side_bias >= 0 and ctx.max_val or ctx.min_val, "minmax_extreme"
	end

	if ctx.peek_eta > 0 and ctx.peek_eta < 0.18 and ctx.sent then
		return ctx.is_inverter and ctx.max_val or ctx.min_val, "minmax_peek"
	end

	local shift = shiny_compute_shift(ctx, half)
	if ctx.sent then
		if ctx.pressure >= 58 then
			return shift >= 0 and ctx.max_val or ctx.min_val, "minmax_sent"
		end
		return mid + shift, "minmax_drift"
	end

	return mid + shift * 0.35, "minmax_choke"
end

shiny_modifier_custom_pipeline = function(ctx)
	local config = ctx.config
	local shiny = ctx.shiny
	local slider_count = math.max(1, config["custom_amount"] or 1)
	local counter = math.max(1, shiny.mod_sent_counter or 1)
	local phi = ctx.phi
	local tick = ctx.tick

	local idx = ((counter - 1) % slider_count) + 1
	if ctx.pressure >= 58 then
		for attempt = 0, slider_count - 1 do
			local try_idx = ((idx + attempt - 1) % slider_count) + 1
			local val = config["custom_slider_" .. try_idx] or 0
			if math.abs(val) <= 30 then
				idx = try_idx
				break
			end
		end
	end

	local base = config["custom_slider_" .. idx] or 0

	if ctx.pressure >= 72 and ctx.visible and ctx.sent then
		local mag = math.abs(base)
		if mag > 0 then
			return mag * shiny_direction_sign(ctx, true), "custom_pressure"
		end
	end

	if ctx.peek_eta > 0 and ctx.peek_eta < 0.18 and ctx.sent and math.abs(base) > 0 then
		return math.abs(base) * shiny_direction_sign(ctx, false), "custom_peek"
	end

	if ctx.sent then
		return base, "custom_sent"
	end

	local next_idx = (idx % slider_count) + 1
	local cur_val = config["custom_slider_" .. idx] or 0
	local next_val = config["custom_slider_" .. next_idx] or 0
	local blend = (math.sin(tick * phi * 0.1) * 0.5 + 0.5)
	return cur_val + (next_val - cur_val) * blend * 0.35, "custom_choke"
end

calc_shiny_modifier_offset = function(config, amount, min_val, max_val, tick, is_inverter, center_opt, randomize)
	local me = entity.get_local_player()
	if not me or not me:is_alive() then
		return 0
	end

	local ctx = shiny_build_modifier_context(
		me, config, tick, amount, is_inverter, min_val, max_val, randomize, center_opt
	)
	shiny_modifier_amp_scale(ctx)

	if shiny_should_gap(ctx) and center_opt == "Default" then
		return shiny_finalize_offset(0, ctx, "gap", randomize)
	end

	local evt_offset, evt_phase = shiny_modifier_event_layer(ctx)
	if evt_offset ~= nil then
		if center_opt ~= "Default" then
			evt_offset = shiny_remap_event_offset(ctx, evt_offset, evt_phase)
		end
		local adjusted, phase = shiny_apply_antiresolver(evt_offset, ctx)
		return shiny_finalize_offset(adjusted, ctx, evt_phase or phase, randomize)
	end

	local raw, phase
	if center_opt == "Min & Max" then
		raw, phase = shiny_modifier_minmax_pipeline(ctx)
	elseif center_opt == "Custom" then
		raw, phase = shiny_modifier_custom_pipeline(ctx)
	else
		raw = shiny_compute_shift(ctx, ctx.effective_amp)
		phase = ctx.shiny.mod_phase
	end

	local adjusted, ar_phase = shiny_apply_antiresolver(raw, ctx)
	return shiny_finalize_offset(adjusted, ctx, ar_phase or phase, randomize)
end

local function sync_desync_on_exploit_change()
	local exploit_active = is_exploit_active()
	local last = aa_engine.last_exploit_active

	if last == nil then
		aa_engine.last_exploit_active = exploit_active
		return
	end

	if last == exploit_active then
		return
	end

	aa_engine.switch_delay = 0

	-- Leaving DT/HS exploit: resync inverter so desync resumes on the correct side.
	if last and not exploit_active then
		aa_engine.allow_inverter = not (aa_engine.allow_inverter == true)
	end

	aa_engine.last_exploit_active = exploit_active
end

local function apply_yaw_and_desync(config, tick)
	local me = entity.get_local_player()
	local fake_opt = config["fake_options"] or "Jitter"
	local sent_tick = aa_sent_tick()

	sync_desync_on_exploit_change()

	local _, ab_preview = get_active_antibrute_entry()
	aa_engine.debug_antibrute_active = ab_preview ~= nil

	-- 2. Determine Jitter Inverter (allow_inverter)
	local fake_left = config["fake_left"] or 60
	local fake_right = config["fake_right"] or 60
	
	if fake_opt == "Jitter" then
		local speed = math.max(1, math.floor(config["delay_speed"] or 2))
		local shiny = aa_engine.shiny
		local use_shiny_delay = config["speed_options"] == "Shiny" and me
		
		local ab_enemy, antibrute_entry = get_active_antibrute_entry()
		if sent_tick and config["antibrute"] and antibrute_entry then
			aa_consume_antibrute_swap(ab_enemy, antibrute_entry)
			if table_selection_has(config["antibrute_method"], "Delay") then
				speed = math.max(1, speed + antibrute_entry.delay)
			end
			if table_selection_has(config["antibrute_method"], "Fake limit") then
				fake_left = antibrute_entry.fakelimit
				fake_right = antibrute_entry.fakelimit
			end
		end
		
		if use_shiny_delay then
			if sent_tick and (aa_engine.switch_delay or 0) == 0 then
				speed = shiny_refresh_delay_target(config, me, tick, speed)
			else
				speed = shiny.delay_target or speed
				if speed < 1 then
					speed = shiny_refresh_delay_target(
						config, me, tick, math.max(1, math.floor(config["delay_speed"] or 2))
					)
				end
			end
		elseif config["custom_speed"] then
			local csm = config["custom_speed_method"] or "Default"
			if csm == "Default" then
				if sent_tick and (aa_engine.switch_delay or 0) == 0 then
					local min_s = config["ran_speed_1"] or 1
					local max_s = config["ran_speed_2"] or 1
					if min_s > max_s then min_s, max_s = max_s, min_s end
					aa_engine.delay_custom_target = math.random(min_s, max_s)
				end
				speed = aa_engine.delay_custom_target or speed
			elseif csm == "Custom" then
				local amount = config["custom_speed_amount"] or 1
				local idx = (aa_engine.custom_speed_index or 0) % amount + 1
				speed = math.max(1, math.floor(config["custom_speed_slider_" .. idx] or speed))
			end
		end

		aa_engine.debug_config_delay = math.max(1, math.floor(config["delay_speed"] or 2))
		aa_engine.debug_effective_speed = speed
		
		local allow_tick = aa_should_advance_side(config, speed)

		-- Side switching only on sent ticks so DT choke cycles do not desync the delay counter.
		if allow_tick then
			if speed == 1 then
				aa_engine.allow_inverter = not aa_engine.allow_inverter

				if config["custom_speed"] and config["custom_speed_method"] == "Custom" then
					local amount = config["custom_speed_amount"] or 1
					aa_engine.custom_speed_index = ((aa_engine.custom_speed_index or 0) + 1) % amount
				end
			else
				aa_engine.switch_delay = (aa_engine.switch_delay or 0) + 1
				if aa_engine.switch_delay >= speed then
					aa_engine.allow_inverter = not aa_engine.allow_inverter
					aa_engine.switch_delay = 0

					if config["custom_speed"] and config["custom_speed_method"] == "Custom" then
						local amount = config["custom_speed_amount"] or 1
						aa_engine.custom_speed_index = ((aa_engine.custom_speed_index or 0) + 1) % amount
					end
				end
			end
		end
	else
		aa_engine.allow_inverter = false
	end

	if fake_opt == "Random" and sent_tick then
		aa_engine.allow_inverter = math.random(1, 2) == 1
	end
	
	if fake_opt == "Static" or fake_opt == "Random" then
		local ab_enemy, antibrute_entry = get_active_antibrute_entry()
		if sent_tick and config["antibrute"] and antibrute_entry then
			aa_consume_antibrute_swap(ab_enemy, antibrute_entry)
			if table_selection_has(config["antibrute_method"], "Fake limit") then
				fake_left = antibrute_entry.fakelimit
				fake_right = antibrute_entry.fakelimit
			end
		end
	end

	-- 3. Apply Fake Limits
	local enabled = config["body_yaw"]
	if not enabled then
		if refs.body_yaw[1] then refs.body_yaw[1]:override(false) end
		if refs.body_yaw[2] then refs.body_yaw[2]:override(false) end
	else
		local amnesia = config["speed_options"] == "Amnesia" and fake_opt == "Jitter"
		if amnesia and sent_tick then
			aa_engine.amnesia_tick = (aa_engine.amnesia_tick or 0) + 1
			local limit = math.max(1, math.floor(config["amnesia_tick_speed"] or 16))
			if aa_engine.amnesia_tick > limit then
				aa_engine.amnesia_tick = 0
				aa_engine.amnesia_on = not (aa_engine.amnesia_on ~= false)
			end
		end

		if refs.body_yaw[1] then
			if amnesia then
				refs.body_yaw[1]:override(aa_engine.amnesia_on ~= false)
			else
				refs.body_yaw[1]:override(true)
			end
		end
		if refs.body_yaw[2] then refs.body_yaw[2]:override(false) end

		local rand_l = config["fake_left_random"] or 0
		local rand_r = config["fake_right_random"] or 0
		
		if rand_l > 0 then fake_left = fake_left - math.random(0, rand_l) end
		if rand_r > 0 then fake_right = fake_right - math.random(0, rand_r) end
		
		-- Use absolute values to not break the UI sliders
		fake_left = math.max(0, math.min(60, fake_left))
		fake_right = math.max(0, math.min(60, fake_right))
		
		-- We natively flip the fake side by making the opposite limit negative.
		-- This completely avoids touching the Neverlose native Inverter, while achieving
		-- the exact same rapid side-switching behavior.
		local cur_left, cur_right
		if aa_engine.allow_inverter then
			-- Force fake to one side
			cur_left = -fake_left
			cur_right = fake_right
		else
			-- Force fake to the opposite side
			cur_left = fake_left
			cur_right = -fake_right
		end
		
		if refs.body_yaw[3] then refs.body_yaw[3]:override(cur_left) end
		if refs.body_yaw[4] then refs.body_yaw[4]:override(cur_right) end

		if refs.body_yaw[5] then refs.body_yaw[5]:override(fake_opt) end
	end

	-- Return calculated base yaw for the active side
	return calculate_yaw(config, tick)
end

-- Defensive tickbase measurement
local DEFENSIVE_MAX_TICKS = 14
local DEFENSIVE_TICKBASE_RESET = 64
local DEF_VOICE_CONF = 0.92
local DEF_BEHAVIOR_CONF_MAX = 0.55

local DTC_AIR_MIN_TICKS = 3
local DTC_AIR_APEX_Z_VEL = 120
local DTC_STAND_EARLY_BIAS = 2
local DTC_MOVE_EARLY_BIAS = 2
local DTC_FALL_EARLY_BIAS = 3
local DTC_RISE_EARLY_BIAS = 1
local DTC_AIR_CROUCH_BIAS = 3

local function def_at_send_tick()
	return (globals.choked_commands or 0) == 0
end

-- ponytail: DTC logs only when AA debug panel is on
local function def_log_dtc(fmt, ...)
	if not setup.aa_debug or not setup.aa_debug:get() then
		return
	end
	print(string.format("[shinymoon] DTC " .. fmt, ...))
end

local function def_dtc_air_phase_from_z(z_vel)
	if z_vel > DTC_AIR_APEX_Z_VEL then
		return "rising"
	elseif z_vel < -DTC_AIR_APEX_Z_VEL then
		return "falling"
	end
	return "apex"
end

local function def_dtc_air_phase(me)
	local vel = me and me.m_vecVelocity
	return def_dtc_air_phase_from_z(vel and vel.z or 0)
end


local def_voice_decoders = (function()

local M = {}

local DEF_PKT_T = ffi.typeof([[
	struct {
		uint32_t xuid_low;
		uint32_t xuid_high;
		uint32_t sequence_bytes;
		uint32_t section_number;
		uint32_t uncompressed_sample_offset;
	}
]])

local DEF_PRIM_PTR = ffi.typeof([[
	struct {
		char pad[8];
		uint8_t keyp1;
		uint8_t eidp1;
		uint8_t mutualkey;
		uint8_t loc_xor_key;
		uint16_t xored_x;
		uint16_t xored_y;
		uint16_t xored_z;
		uint8_t keyp2;
	} *
]])

local COORD_INT_BITS = 14
local COORD_FRAC_BITS = 5

local DEF_AIRFLOW_TAGS = {
	[250] = "airflow",
	[153] = "airflow",
	[175] = "airflow",
	[102] = "airflow",
	[180] = "airflow",
	[187] = "airflow",
	[220] = "airflow",
	[186] = "airflow",
}

local GS_SBOX = {
	94,4,184,28,143,210,241,56,207,171,136,61,194,59,115,88,65,204,6,249,32,68,121,77,172,47,202,150,217,237,34,247,
	44,244,67,147,13,208,70,45,141,42,180,225,12,53,89,16,114,18,236,165,79,188,174,58,71,102,205,40,160,104,154,181,
	92,99,246,183,36,43,195,51,90,81,76,140,49,212,177,159,122,86,235,82,112,253,2,135,84,151,232,83,10,96,120,29,
	145,179,134,191,98,189,201,199,7,46,80,106,105,62,190,162,166,22,119,26,196,238,87,175,146,164,176,113,9,173,152,41,
	206,25,224,54,198,220,230,107,211,223,148,95,131,21,52,234,153,33,221,192,19,11,254,111,66,155,75,50,64,219,222,109,
	14,27,124,85,255,91,158,39,57,103,138,5,73,193,37,30,31,116,228,8,216,110,127,203,245,242,137,250,38,17,72,169,
	125,167,200,142,243,23,35,93,128,197,48,74,130,1,240,251,182,144,185,108,209,163,0,15,20,215,161,129,170,63,132,60,
	252,126,239,229,187,139,213,186,218,156,149,231,69,157,55,24,101,100,214,117,178,226,133,233,248,78,118,123,168,3,97,227,
}

local function to_uint32(val)
	val = tonumber(val) or 0
	if val < 0 then
		val = val + 4294967296
	end
	return bit.band(val, 0xFFFFFFFF)
end

local function to_int32(val)
	val = tonumber(val) or 0
	if val > 2147483647 then
		val = val - 4294967296
	end
	return val
end

local function split_xuid(xuid)
	xuid = to_uint32(xuid)
	return bit.band(xuid, 0xFFFFFFFF), bit.band(bit.rshift(xuid, 32), 0xFFFFFFFF)
end

local function signed16(bits)
	if bits > 32767 then
		return bits - 65536
	end
	return bits
end

local function rol(val, n)
	n = n % 32
	val = bit.band(val, 0xFFFFFFFF)
	return bit.band(bit.bor(bit.lshift(val, n), bit.rshift(val, 32 - n)), 0xFFFFFFFF)
end

local function gs_ror16(val, n)
	val = bit.band(val, 65535)
	return bit.band(bit.bor(bit.rshift(val, n), bit.lshift(val, 16 - n)), 65535)
end

local function gs_mix(a, b)
	a = bit.band(a, 65535)
	a = bit.bor(a, bit.lshift(a, 16))
	return bit.band(gs_ror16(a, b), 65535)
end

local function gs_hi16(val)
	return bit.band(bit.rshift(val, 16), 65535)
end

local function enemy_client_id(enemy)
	local idx = enemy:get_index()
	if not idx or idx <= 0 then
		return 0
	end
	return idx - 1
end

local function validate_origin(enemy, x, y, z)
	if not enemy or not enemy:is_alive() then
		return false
	end
	local origin = enemy:get_origin()
	if not origin then
		return false
	end
	return math.abs(origin.x - x) <= 256
		and math.abs(origin.y - y) <= 256
		and math.abs(origin.z - z) <= 256
end

function M.build_meta(ctx)
	local low, high = split_xuid(ctx.xuid)
	local pkt = ffi.new(DEF_PKT_T)
	pkt.xuid_low = low
	pkt.xuid_high = high
	pkt.sequence_bytes = ctx.sequence_bytes or 0
	pkt.section_number = ctx.section_number or 0
	pkt.uncompressed_sample_offset = ctx.uncompressed_sample_offset or 0
	return pkt
end

function M.meta_bytes(pkt)
	local raw = ffi.cast("uint8_t*", pkt)
	local bytes = {}
	for i = 0, 19 do
		bytes[i + 1] = raw[i]
	end
	return bytes
end

function M.bf_new(bytes)
	local bf = {
		data = {},
		pos = 0,
		bit_pos = 0,
		size = #bytes,
	}

	for i = 1, #bytes do
		bf.data[i - 1] = bit.band(bytes[i], 255)
	end

	function bf:read_bits(num_bits)
		local value = 0
		local left = num_bits
		while left > 0 do
			if self.bit_pos == 8 then
				self.bit_pos = 0
				self.pos = self.pos + 1
			end
			local byte = self.data[self.pos] or 0
			local take = math.min(left, 8 - self.bit_pos)
			local mask = bit.lshift(1, take) - 1
			value = bit.bor(value, bit.lshift(bit.band(bit.rshift(byte, self.bit_pos), mask), num_bits - left))
			left = left - take
			self.bit_pos = self.bit_pos + take
		end
		return value
	end

	function bf:read_coord()
		local has_int = self:read_bits(1)
		local has_frac = self:read_bits(1)
		if has_int == 0 and has_frac == 0 then
			return 0
		end
		local negative = self:read_bits(1)
		local int_part = 0
		local frac_part = 0
		if has_int == 1 then
			int_part = self:read_bits(COORD_INT_BITS) + 1
		end
		if has_frac == 1 then
			frac_part = self:read_bits(COORD_FRAC_BITS)
		end
		local coord = int_part + frac_part * 0.03125
		if negative == 1 then
			coord = -coord
		end
		return coord
	end

	function bf:reset()
		self.pos = 0
		self.bit_pos = 0
	end

	return bf
end

function M.decode_primordial(pkt, enemy, format)
	if (format or 0) ~= 1 then
		return nil
	end

	local prim = ffi.cast(DEF_PRIM_PTR, pkt)[0]
	local entity_id = bit.bxor(prim.eidp1, prim.mutualkey)
	local idx = enemy:get_index()
	if not idx or entity_id ~= idx then
		return nil
	end

	local function xor_float(bits, key)
		local buf = ffi.new("int16_t[1]")
		buf[0] = bit.bxor(bits, key)
		return tonumber(ffi.cast("float", buf[0]))
	end

	local x = xor_float(prim.xored_x, prim.loc_xor_key)
	local y = xor_float(prim.xored_y, prim.loc_xor_key)
	local z = xor_float(prim.xored_z, prim.loc_xor_key)
	local key = bit.bxor(prim.keyp1, prim.keyp2) - prim.mutualkey

	if key ~= 77 and key ~= 67 then
		return nil
	end
	if x <= -16384 or x >= 16384 or y <= -16384 or y >= 16384 or z <= -16384 or z >= 16384 then
		return nil
	end
	if not validate_origin(enemy, x, y, z) then
		return nil
	end

	return "primordial", 0.9
end

function M.decode_ev0lity(pkt, enemy)
	local idx = enemy:get_index()
	if not idx or idx <= 0 then
		return nil
	end

	local low, high = pkt.xuid_low, pkt.xuid_high
	if low == 0 then
		return nil
	end
	local seed = bit.band(bit.bxor(bit.bxor(high, idx) % low, 0xFFFFFFFF), 0xFFFFFFFF)
	seed = bit.bor(seed, bit.band(bit.bxor(high, low), 65535))

	local raw = ffi.cast("uint8_t*", pkt)
	local bytes = {}
	for i = 0, 19 do
		bytes[i + 1] = raw[i]
	end

	local key = {
		bit.band(seed, 255),
		bit.band(bit.rshift(seed, 8), 255),
		bit.band(bit.rshift(seed, 16), 255),
		bit.band(bit.rshift(seed, 24), 255),
	}

	for i = 1, #bytes do
		bytes[i] = bit.band(bit.bxor(bytes[i], key[(i - 1) % 4 + 1]), 255)
		if (i - 1) % 4 == 3 then
			seed = bit.bor(bit.lshift(seed, 8), bit.band(i - 1, 255))
			key = {
				bit.band(seed, 255),
				bit.band(bit.rshift(seed, 8), 255),
				bit.band(bit.rshift(seed, 16), 255),
				bit.band(bit.rshift(seed, 24), 255),
			}
		end
	end

	local bf = M.bf_new(bytes)
	local packet_id = bf:read_bits(16)
	local entity_id = bf:read_bits(8)
	bf:read_bits(8)
	local x = signed16(bf:read_bits(16))
	local y = signed16(bf:read_bits(16))
	local z = signed16(bf:read_bits(16))
	bf:read_bits(16)

	if packet_id ~= 32762 and packet_id ~= 32763 and packet_id ~= 32764 and packet_id ~= 32765 then
		return nil
	end
	if entity_id ~= idx then
		return nil
	end
	if not validate_origin(enemy, x, y, z) then
		return nil
	end

	if packet_id == 32762 or packet_id == 32763 then
		return "fatality", 0.9
	end
	return "exploit", 0.85
end

function M.decode_airflow(pkt, enemy)
	if (pkt.section_number or 0) == 0
		or (pkt.sequence_bytes or 0) == 0
		or (pkt.uncompressed_sample_offset or 0) == 0 then
		return nil
	end

	local buf = ffi.new("uint8_t[24]")
	local words = ffi.cast("uint32_t*", buf)
	words[0] = pkt.xuid_low
	words[1] = pkt.xuid_high
	words[2] = pkt.sequence_bytes
	words[3] = pkt.section_number
	words[4] = pkt.uncompressed_sample_offset

	local bytes = {}
	for i = 0, 19 do
		bytes[i + 1] = buf[i]
	end

	local bf = M.bf_new(bytes)
	local header = bf:read_bits(8)
	local cheat_id = bf:read_bits(8)
	local magic = bf:read_bits(16)
	local entity_id = bf:read_bits(8)

	local function float16(bits)
		if bits <= 32767 then
			return bits
		end
		return bits - 65536
	end

	local x = float16(bf:read_bits(16))
	local y = float16(bf:read_bits(16))
	local z = float16(bf:read_bits(16))
	bf:read_bits(8)
	local tick_count = bf:read_bits(32)

	if magic ~= 57005 or header ~= 241 then
		return nil
	end
	if not DEF_AIRFLOW_TAGS[cheat_id] then
		return nil
	end
	if entity_id ~= enemy:get_index() then
		return nil
	end
	if not validate_origin(enemy, x, y, z) then
		return nil
	end

	local tick = bit.band(globals.tickcount or 0, 65535)
	if math.abs(tick - tick_count) > 32 then
		return nil
	end

	return "airflow", 0.9
end

function M.decode_rifk7(pkt, enemy)
	local idx = enemy:get_index()
	if not idx or idx <= 0 then
		return nil
	end

	local xuid_low = to_int32(pkt.xuid_low)
	local v2370 = xuid_low + 28
	local v2371 = xuid_low + 31
	if v2370 >= 0 then
		v2371 = v2370
	end
	local v2372 = bit.rshift(v2371, 2) - idx - idx + 54
	local v2373 = bit.bor(v2372, 64)
	if v2373 == 124 or v2373 == 252 then
		return "exploit", 0.82
	end
	return nil
end

function M.decode_nixware(pkt, enemy)
	local bf = M.bf_new(M.meta_bytes(pkt))
	local id = bf:read_bits(16)
	local entity_id = bf:read_bits(7) + 1
	local x = bf:read_coord()
	local y = bf:read_coord()
	local z = bf:read_coord()
	local tick_count = bf:read_bits(32)

	if id ~= 48879 and id ~= 53456 then
		return nil
	end
	if x <= -16384 or x >= 16384 or y <= -16384 or y >= 16384 or z <= -16384 or z >= 16384 then
		return nil
	end
	if entity_id ~= enemy:get_index() then
		return nil
	end
	if not validate_origin(enemy, x, y, z) then
		return nil
	end

	local tick = globals.tickcount or 0
	if math.abs(tick - tick_count) > 32 then
		return nil
	end

	return "exploit", 0.85
end

function M.decode_gamesense(pkt, enemy)
	local idx = enemy:get_index()
	if not idx or idx <= 0 then
		return nil
	end

	local buf = ffi.new("uint8_t[24]")
	local words = ffi.cast("uint32_t*", buf)
	local shorts = ffi.cast("uint16_t*", buf)
	words[0] = pkt.xuid_low
	words[1] = pkt.xuid_high
	words[2] = pkt.section_number
	words[3] = pkt.sequence_bytes
	words[4] = pkt.uncompressed_sample_offset

	local sbox = {}
	for i = 0, 255 do
		sbox[i] = GS_SBOX[i + 1]
	end

	local j = 7
	for i = 0, 20 do
		local tmp = sbox[i + 129]
		local swap_idx = bit.band(j + tmp, 255)
		sbox[i + 129] = sbox[swap_idx]
		sbox[swap_idx] = tmp
		j = bit.band(j + tmp, 255)
		buf[i] = bit.bxor(buf[i], sbox[bit.band(tmp + sbox[i + 129], 255)])
	end

	local a, b, c = 0, 0, 0
	for round = 0, 4 do
		local idx2 = 2 * round + 1
		local w0 = shorts[idx2]
		local w1 = shorts[idx2 + 1]
		local state = 2446691973
		local x, y = w0, w1
		for _ = 1, 15 do
			local r1 = rol(state, 1)
			local m1 = gs_mix(y - state, bit.band(x, 15))
			state = rol(state, 2)
			y = bit.band(bit.bxor(x, m1), 65535)
			local m2 = bit.band(bit.bxor(y, gs_mix(x - r1, bit.band(y, 15))), 65535)
			x = bit.band(m2, 65535)
		end
		shorts[idx2] = bit.bxor(a, x - rol(state, 1))
		shorts[idx2 + 1] = bit.band(bit.bxor(b, y - state), 65535)
		a, b = w0, w1
	end

	local user_id = enemy_client_id(enemy)
	words[1] = bit.bxor(words[1], user_id)
	words[2] = bit.bxor(words[2], idx)

	if bit.bxor(gs_hi16(pkt.xuid_low), gs_hi16(words[0])) ~= 9252 then
		return nil
	end

	local bytes = {}
	for i = 0, 20 do
		bytes[i + 1] = buf[i]
	end

	local bf = M.bf_new(bytes)
	bf:read_bits(32)
	local tick_field = bf:read_bits(32)
	local entity_id = bf:read_bits(7) + 1
	bf:read_bits(9)
	local x = bf:read_coord()
	local y = bf:read_coord()
	local z = bf:read_coord()

	if x <= -16384 or x >= 16384 or y <= -16384 or y >= 16384 or z <= -16384 or z >= 16384 then
		return nil
	end
	if entity_id ~= idx then
		return nil
	end
	if not validate_origin(enemy, x, y, z) then
		return nil
	end

	local tick = globals.tickcount or 0
	if math.abs(tick - tick_field) > 32 then
		return nil
	end

	return "gamesense", 0.9
end

function M.detect(ctx, enemy)
	if not ctx or not enemy or not enemy:is_alive() or not enemy:is_enemy() or enemy:is_dormant() then
		return nil
	end

	local pkt = M.build_meta(ctx)

	local prim_tag, prim_conf = M.decode_primordial(pkt, enemy, ctx.format)
	if prim_tag then
		return prim_tag, prim_conf
	end

	local gs_tag, gs_conf = M.decode_gamesense(pkt, enemy)
	if gs_tag then
		return gs_tag, gs_conf
	end

	local evo_tag, evo_conf = M.decode_ev0lity(pkt, enemy)
	if evo_tag then
		return evo_tag, evo_conf
	end

	local rifk_tag, rifk_conf = M.decode_rifk7(pkt, enemy)
	if rifk_tag then
		return rifk_tag, rifk_conf
	end

	local af_tag, af_conf = M.decode_airflow(pkt, enemy)
	if af_tag then
		return af_tag, af_conf
	end

	local nx_tag, nx_conf = M.decode_nixware(pkt, enemy)
	if nx_tag then
		return nx_tag, nx_conf
	end

	if ctx.is_nl == true then
		return "neverlose", 0.92
	end

	return nil
end

return M
end)()

-- ── AA.def ── defensive profiles / DTC
local function def_get_profile(idx)
	local profiles = aa_engine.def.profiles
	if not profiles[idx] then
		profiles[idx] = {
			tracked_tickbase = 0,
			last_tickbase = 0,
			last_shift_tick = 0,
			defensive_shifts = 0,
			dt_shifts = 0,
			sim_defensive_hits = 0,
			simtime_jumps = 0,
			shots_seen = 0,
			nl_score = 0,
			gs_score = 0,
			exploit_score = 0,
			cheat_tag = "unknown",
			confidence = 0,
			voice_tag = nil,
			voice_conf = 0,
			detect_source = "none",
			last_seen = 0,
			last_sim_old = 0,
			last_sim_cur = 0,
		}
	end
	return profiles[idx]
end

local function def_apply_profile_tag(profile, tag, conf, source)
	if not profile or not tag then
		return
	end

	local use_voice = source == "voice"
	local cur_conf = profile.confidence or 0
	local voice_conf = profile.voice_conf or 0

	if use_voice then
		profile.voice_tag = tag
		profile.voice_conf = conf
		profile.cheat_tag = tag
		profile.confidence = conf
		profile.detect_source = "voice"
		return
	end

	if profile.voice_tag and voice_conf >= DEF_VOICE_CONF then
		profile.cheat_tag = profile.voice_tag
		profile.confidence = voice_conf
		profile.detect_source = "voice"
		return
	end

	if conf > cur_conf then
		profile.cheat_tag = tag
		profile.confidence = conf
		profile.detect_source = source or "behavior"
	end
end

local function def_classify_profile(profile)
	if profile.voice_tag and (profile.voice_conf or 0) >= DEF_VOICE_CONF then
		profile.cheat_tag = profile.voice_tag
		profile.confidence = profile.voice_conf
		profile.detect_source = "voice"
		return profile.cheat_tag, profile.confidence
	end

	local tag = "unknown"
	local conf = 0.2

	if profile.nl_score >= profile.gs_score and profile.nl_score >= profile.exploit_score then
		if profile.defensive_shifts >= 1 or profile.sim_defensive_hits >= 1 then
			tag = "neverlose"
			conf = math.min(DEF_BEHAVIOR_CONF_MAX, 0.35 + profile.defensive_shifts * 0.05 + profile.sim_defensive_hits * 0.04)
		end
	elseif profile.gs_score > profile.nl_score and profile.dt_shifts >= 1 then
		tag = "gamesense"
		conf = math.min(DEF_BEHAVIOR_CONF_MAX, 0.32 + profile.dt_shifts * 0.08)
	elseif profile.exploit_score >= 1 or profile.simtime_jumps >= 1 then
		tag = "exploit"
		conf = math.min(DEF_BEHAVIOR_CONF_MAX, 0.3 + profile.exploit_score * 0.06)
	end

	def_apply_profile_tag(profile, tag, conf, "behavior")
	return profile.cheat_tag, profile.confidence
end

local function def_update_enemy_behavior(enemy, tick)
	if not enemy or not enemy:is_alive() or not enemy:is_enemy() or enemy:is_dormant() then
		return
	end

	local idx = enemy:get_index()
	if not idx or idx <= 0 then
		return
	end

	local profile = def_get_profile(idx)
	if profile.voice_tag and (profile.voice_conf or 0) >= DEF_VOICE_CONF then
		profile.last_seen = globals.curtime or 0
		return
	end

	profile.last_seen = globals.curtime or 0

	local tickbase = enemy.m_nTickBase or 0
	local tracked = profile.tracked_tickbase or 0

	if tracked == 0 then
		profile.tracked_tickbase = tickbase
	elseif math.abs(tickbase - tracked) > DEFENSIVE_TICKBASE_RESET then
		profile.tracked_tickbase = tickbase
	elseif tickbase > tracked then
		profile.tracked_tickbase = tickbase
	elseif tracked > tickbase then
		local shift = tracked - tickbase - 1
		local last_shift_tick = profile.last_shift_tick or 0
		if tick ~= last_shift_tick then
			profile.last_shift_tick = tick
			if shift >= 1 and shift <= DEFENSIVE_MAX_TICKS then
				profile.defensive_shifts = profile.defensive_shifts + 1
				profile.nl_score = profile.nl_score + 2
				profile.exploit_score = profile.exploit_score + 1
			elseif shift > DEFENSIVE_MAX_TICKS then
				profile.dt_shifts = profile.dt_shifts + 1
				profile.gs_score = profile.gs_score + 3
				profile.exploit_score = profile.exploit_score + 2
			end
			profile.tracked_tickbase = tickbase
		end
	end

	profile.last_tickbase = tickbase

	local sim_ok, sim = pcall(function() return enemy:get_simulation_time() end)
	if sim_ok and sim and sim.current and sim.old then
		if sim.current ~= profile.last_sim_cur or sim.old ~= profile.last_sim_old then
			local tickinterval = globals.tickinterval or (1 / 64)
			local delta = sim.current - sim.old
			if delta > tickinterval * 1.2 and delta <= tickinterval * (DEFENSIVE_MAX_TICKS + 1) then
				profile.sim_defensive_hits = profile.sim_defensive_hits + 1
				profile.nl_score = profile.nl_score + 1
			elseif delta > tickinterval * (DEFENSIVE_MAX_TICKS + 1) then
				profile.simtime_jumps = profile.simtime_jumps + 1
				profile.gs_score = profile.gs_score + 2
				profile.exploit_score = profile.exploit_score + 1
			end
			profile.last_sim_old = sim.old
			profile.last_sim_cur = sim.current
		end
	end

	def_classify_profile(profile)
end

local function def_pick_focus_enemy(me, my_origin)
	local threat = entity.get_threat(true)
	if threat and threat ~= me and threat:is_alive() and threat:is_enemy() and not threat:is_dormant() then
		return threat
	end

	if not my_origin or not entity.get_players then
		return nil
	end

	local players = entity.get_players(true)
	if not players then
		return nil
	end

	local nearest_enemy = nil
	local nearest_dist = math.huge

	for i = 1, #players do
		local enemy = players[i]
		if enemy and enemy ~= me and enemy:is_alive() and enemy:is_enemy() and not enemy:is_dormant() then
			local origin = enemy:get_origin()
			if origin then
				local dist = my_origin:dist(origin)
				if dist < nearest_dist then
					nearest_dist = dist
					nearest_enemy = enemy
				end
			end
		end
	end

	return nearest_enemy
end

def_scan_enemies = function(me)
	if not me or not me:is_alive() or not entity.get_players then
		aa_engine.def.nearest_idx = 0
		aa_engine.def.nearest_tag = "unknown"
		aa_engine.def.nearest_conf = 0
		aa_engine.def.nearest_source = "none"
		return
	end

	local my_origin = me:get_origin()
	local tick = globals.tickcount or 0
	local threat = entity.get_threat(true)
	local players = entity.get_players(true)

	if threat and threat ~= me and threat:is_alive() and threat:is_enemy() then
		def_update_enemy_behavior(threat, tick)
	end

	if players then
		for i = 1, #players do
			local enemy = players[i]
			if enemy and enemy ~= me and enemy ~= threat and enemy:is_alive() and enemy:is_enemy() then
				def_update_enemy_behavior(enemy, tick)
			end
		end
	end

	local focus = def_pick_focus_enemy(me, my_origin)
	if focus then
		local idx = focus:get_index()
		local profile = idx and aa_engine.def.profiles[idx]
		if profile then
			aa_engine.def.nearest_idx = idx
			aa_engine.def.nearest_tag = profile.cheat_tag or "unknown"
			aa_engine.def.nearest_conf = profile.confidence or 0
			aa_engine.def.nearest_source = profile.detect_source or "none"
			return
		end
	end

	aa_engine.def.nearest_idx = 0
	aa_engine.def.nearest_tag = "unknown"
	aa_engine.def.nearest_conf = 0
	aa_engine.def.nearest_source = "none"
end

def_on_voice_message = function(ctx)
	if not ctx or not ctx.entity then
		return
	end

	local enemy = ctx.entity
	if not enemy:is_enemy() or not enemy:is_alive() or enemy:is_dormant() then
		return
	end

	local idx = enemy:get_index()
	if not idx or idx <= 0 then
		return
	end

	local tag, conf = def_voice_decoders.detect(ctx, enemy)
	if not tag then
		return
	end

	local profile = def_get_profile(idx)
	profile.last_seen = globals.curtime or 0
	def_apply_profile_tag(profile, tag, conf, "voice")

	local me = entity.get_local_player()
	if me and me:is_alive() then
		local focus = def_pick_focus_enemy(me, me:get_origin())
		if focus and focus:get_index() == idx then
			aa_engine.def.nearest_idx = idx
			aa_engine.def.nearest_tag = tag
			aa_engine.def.nearest_conf = conf
			aa_engine.def.nearest_source = "voice"
		end
	end
end

-- DTC module contract:
--   Inputs:  m_nTickBase, choked_commands, fakelag limit, movement, shiny.pressure, profile focus
--   Outputs: defensive_ticks, max_defensive_ticks, fire_reason, skip_reason, cmd.force_defensive
--   Clock:   defensive_sample_tickbase runs every createmove tick (Gingersense defensive:on_createmove)
--   Authority: only def_apply_force_defensive writes cmd.force_defensive
local function defensive_sample_tickbase(me)
	local tickbase = me.m_nTickBase or 0
	local tracked = aa_engine.def_max_tickbase or 0
	local tick = globals.tickcount or 0

	aa_engine.def_last_sampled_base = tickbase

	if math.abs(tickbase - tracked) > DEFENSIVE_TICKBASE_RESET then
		aa_engine.def_max_tickbase = tickbase
		aa_engine.defensive_ticks = 0
		aa_engine.max_defensive_ticks = 0
		aa_engine.def.window_fire_armed = false
		return
	end

	if tickbase > tracked then
		aa_engine.def_max_tickbase = tickbase
		aa_engine.defensive_ticks = 0
		aa_engine.max_defensive_ticks = 0
		aa_engine.def.window_fire_armed = false
	elseif tracked > tickbase then
		local remaining = math.min(DEFENSIVE_MAX_TICKS, math.max(0, tracked - tickbase - 1))
		if remaining > 0 then
			-- Latch the window size to the LARGEST shift seen while the window is
			-- open. A new, deeper shift inside the same window must grow max so
			-- the consumed/choke math stays aligned with the real boundary.
			if remaining > (aa_engine.max_defensive_ticks or 0) then
				aa_engine.max_defensive_ticks = remaining
				aa_engine.def.last_shift_tick = tick
				aa_engine.def.window_fire_armed = true
			end
			aa_engine.defensive_ticks = remaining
		else
			aa_engine.defensive_ticks = 0
			aa_engine.max_defensive_ticks = 0
			aa_engine.def.window_fire_armed = false
		end
	else
		aa_engine.defensive_ticks = 0
		aa_engine.max_defensive_ticks = 0
		aa_engine.def.window_fire_armed = false
	end
end

local DEF_PROFILE_TAGS_EXPLOIT = {
	neverlose = true,
	gamesense = true,
	exploit = true,
}

local function def_profile_bias()
	local def = aa_engine.def
	local conf = def.nearest_conf or 0
	local tag = def.nearest_tag or "unknown"

	if (def.nearest_idx or 0) == 0 or conf <= 0 then
		return 0
	end

	if conf >= DEF_VOICE_CONF and DEF_PROFILE_TAGS_EXPLOIT[tag] then
		return 2
	end

	local profile = def.profiles and def.profiles[def.nearest_idx]
	if profile and conf >= DEF_BEHAVIOR_CONF_MAX and (profile.defensive_shifts or 0) >= 1 then
		return 1
	end

	if conf >= DEF_BEHAVIOR_CONF_MAX and DEF_PROFILE_TAGS_EXPLOIT[tag] then
		return 1
	end

	return 0
end

local function def_calc_early_bias(me)
	local vel = me.m_vecVelocity
	local speed = vel and math.sqrt(vel.x * vel.x + vel.y * vel.y) or 0
	local flags = me.m_fFlags or 0
	local on_ground = bit.band(flags, FL_ONGROUND) ~= 0
	local z_vel = vel and vel.z or 0
	local air_phase = on_ground and nil or def_dtc_air_phase_from_z(z_vel)
	aa_engine.def.dtc_air_phase = air_phase or "ground"

	local duck = me.m_flDuckAmount or 0
	local crouched = duck > 0.5
	local bias
	if on_ground and speed < 50 then
		bias = DTC_STAND_EARLY_BIAS
	elseif not on_ground and crouched and (air_phase == "apex" or (aa_engine.def.air_ticks or 0) < DTC_AIR_MIN_TICKS) then
		bias = DTC_AIR_CROUCH_BIAS
	elseif not on_ground and ((aa_engine.def.air_ticks or 0) < DTC_AIR_MIN_TICKS or air_phase == "rising") then
		bias = DTC_RISE_EARLY_BIAS
	elseif air_phase == "falling" then
		bias = DTC_FALL_EARLY_BIAS
	else
		bias = DTC_MOVE_EARLY_BIAS
	end

	if (on_ground or air_phase == "falling") and is_exploit_active() and (aa_engine.shiny.pressure or 0) >= 70 then
		bias = bias + 1
	end

	local profile_bias = def_profile_bias()
	aa_engine.def.profile_bias = profile_bias
	bias = bias + profile_bias

	local base_limit = get_fakelag_limit()
	bias = math.min(bias, math.max(0, base_limit - 1))
	aa_engine.def.early_bias = bias
	return bias
end

-- Choke boundary scheduler. Returns the fakelag count at which the defensive
-- command should be sent.
def_calc_choke_target = function(me, config)
	local base_limit = get_fakelag_limit()
	local defensive_ticks = aa_engine.defensive_ticks or 0
	local max_defensive_ticks = aa_engine.max_defensive_ticks or 0
	local target

	-- Mark the first tick of a fresh defensive window (deepest shift available).
	aa_engine.def.window_start = defensive_ticks > 0
		and defensive_ticks == max_defensive_ticks

	if defensive_ticks > 0 and max_defensive_ticks > 0 then
		-- Inside the window: walk the fire point inward as ticks are consumed so
		-- each defensive command lands on the shrinking boundary.
		local consumed = max_defensive_ticks - defensive_ticks
		target = math.max(1, base_limit - consumed)
		aa_engine.def.early_bias = 0
		aa_engine.def.profile_bias = 0
	else
		local bias = def_calc_early_bias(me)
		target = math.max(1, base_limit - bias)
	end

	target = math.max(1, math.min(base_limit, target))
	local fire_choke = math.max(0, target - 1)

	aa_engine.def.last_choke_target = target
	aa_engine.def.last_fire_choke = fire_choke
	return target, fire_choke
end

local function is_holding_grenade(me)
	local weapon = me:get_player_weapon(false)
	if not weapon then
		return false
	end
	local classname = weapon:get_classname()
	return classname and classname:find("Grenade") ~= nil
end

-- Decides whether the tickbase correction wants to fire this tick.
def_should_fire = function(me, tick, config)
	local function skip(reason)
		aa_engine.def.skip_reason = reason
		return false, nil
	end

	if not def_at_send_tick() then
		return skip("not_send_tick")
	end

	local prev_choke = aa_engine.def.fire_prev_choke or 0
	local fire_choke = aa_engine.def.last_fire_choke or 0
	-- Fire on the send tick after the choke target was reached, not while still
	-- building choke (records showed choke=12/12 fails; choke=0 send ticks succeed).
	local at_fire_point = prev_choke >= fire_choke

	local defensive_ticks = aa_engine.defensive_ticks or 0
	local max_defensive_ticks = aa_engine.max_defensive_ticks or 0
	local window_start = defensive_ticks > 0 and defensive_ticks == max_defensive_ticks
	local def = aa_engine.def

	if tick <= (aa_engine.last_defensive_fire_tick or -1) then
		return skip("same_tick")
	end

	local sim_time = me.m_flSimulationTime or globals.curtime
	local sim_ok = (aa_engine.last_defensive_sim or 0) <= 0
		or (sim_time - (aa_engine.last_defensive_sim or 0)) >= globals.tickinterval
	if not sim_ok then
		return skip("sim_cooldown")
	end

	if window_start and def.window_fire_armed and at_fire_point then
		def.window_fire_armed = false
		def.skip_reason = "none"
		return true, "window_start"
	end

	if at_fire_point then
		def.skip_reason = "none"
		return true, "choke_boundary"
	end

	return skip("no_fire_point")
end

local function shiny_safe_exploit_call(fn)
	if not rage or not rage.exploit or not fn then return end
	pcall(fn, rage.exploit)
end

local function def_gating_enabled()
	return setup.def_gating and setup.def_gating:get()
end

local function def_state_allowed(state_name)
	if not def_gating_enabled() then return true end
	local conditions = setup.def_conditions:get()
	if type(conditions) ~= "table" then return true end
	local any = false
	for _, st in pairs(conditions) do
		any = true
		if st == state_name then return true end
	end
	return not any
end

local function def_disabler_blocks(fs_active, manual_active, peek_active)
	if not def_gating_enabled() then return false end
	local disablers = setup.def_disablers:get()
	if type(disablers) ~= "table" then return false end
	for _, name in pairs(disablers) do
		if name == "Freestanding" and fs_active then return true end
		if name == "Manual AA" and manual_active then return true end
		if name == "Peek Assist" and peek_active then return true end
	end
	return false
end

local function lc_fs_active(state_name)
	if not setup.freestanding or not setup.freestanding:get() then
		return false
	end

	local fs_active = true
	local disablers = setup.fs_disablers:get()
	if type(disablers) == "table" then
		for _, d in pairs(disablers) do
			if d == state_name then
				fs_active = false
				break
			end
		end
	end

	if fs_active and setup.fs_prefer and setup.fs_prefer:get() and setup.manual:get() ~= "Off" then
		fs_active = false
	end
	return fs_active
end

local function lc_hs_target_enabled()
	if not setup.break_lc_targets then return true end
	local hs = listable_has(setup.break_lc_targets, "Hide Shots Break LC")
	local dt = listable_has(setup.break_lc_targets, "DT Lag Always on")
	-- ponytail: empty target list keeps legacy HS-only until user picks targets
	if not hs and not dt then return true end
	return hs
end

local function lc_dt_target_enabled()
	return setup.break_lc_targets and listable_has(setup.break_lc_targets, "DT Lag Always on")
end

local function lc_dt_target_allowed(me, state_name)
	local config = resolve_state_config(state_name)
	if not config or not config["defensive_tickbase"] then
		return false
	end
	if not def_state_allowed(state_name) then
		return false
	end
	local peek_active = refs.autopeek and refs.autopeek:get()
	return not def_disabler_blocks(
		lc_fs_active(state_name),
		setup.manual:get() ~= "Off",
		peek_active
	)
end

local function lc_apply_break_lc_overrides(me)
	if not lc_break_lc_enabled() or not me or not me:is_alive() then
		if refs.hideshot_config then refs.hideshot_config:override() end
		return
	end

	local conditions_active = lc_event_conditions_active(me)
	local state_name = detect_player_state(me, last_cmd)

	if conditions_active and lc_hs_target_enabled() and refs.hideshot_config then
		refs.hideshot_config:override("Break LC")
	elseif refs.hideshot_config then
		refs.hideshot_config:override()
	end

	if conditions_active and lc_dt_target_enabled()
		and lc_dt_target_allowed(me, state_name) and refs.def then
		refs.def:override("Always on")
	end
end

local function apply_defensive_runtime_overrides(config)
	if not def_gating_enabled() then return end

	local def_active = config["defensive_tickbase"] and (aa_engine.defensive_ticks or 0) >= 1

	if setup.def_improve_fakelag and setup.def_improve_fakelag:get() and refs.fakelag then
		if def_active then
			refs.fakelag:override(1)
		else
			refs.fakelag:override()
		end
	end
end

-- Single authority that writes cmd.force_defensive.
def_apply_force_defensive = function(cmd, tick, config)
	if not cmd then return end

	local me = entity.get_local_player()

	if not me or not me:is_alive() or is_holding_grenade(me) then
		cmd.force_defensive = false
		if me and me:is_alive() then
			shiny_safe_exploit_call(function(ex) ex:allow_defensive(false) end)
		end
		aa_engine.def.fire_reason = "blocked"
		aa_engine.def.skip_reason = "blocked"
		return
	end

	if not config["defensive_tickbase"] then
		cmd.force_defensive = false
		shiny_safe_exploit_call(function(ex) ex:allow_defensive(false) end)
		aa_engine.def.fire_reason = "idle"
		aa_engine.def.skip_reason = "disabled"
		return
	end

	if not def_state_allowed(aa_engine.def_active_state) then
		cmd.force_defensive = false
		shiny_safe_exploit_call(function(ex) ex:allow_defensive(false) end)
		aa_engine.def.fire_reason = "idle"
		aa_engine.def.skip_reason = "state_gate"
		return
	end

	if aa_engine.def.gating_blocked then
		cmd.force_defensive = false
		shiny_safe_exploit_call(function(ex) ex:allow_defensive(false) end)
		aa_engine.def.fire_reason = "idle"
		aa_engine.def.skip_reason = "disabler"
		return
	end

	shiny_safe_exploit_call(function(ex) ex:allow_defensive(true) end)

	local fire, reason = def_should_fire(me, tick, config)
	local def = aa_engine.def
	local state_name = aa_engine.def_active_state or "?"
	if fire then
		cmd.force_defensive = true
		aa_engine.last_defensive_fire_tick = tick
		aa_engine.last_defensive_sim = me.m_flSimulationTime or globals.curtime
		def.fire_reason = reason
		def.skip_reason = "none"
		def.pending_fire_check = true
		if not def.last_force_defensive then
			def_log_dtc(
				"fire armed [%s] tick=%d choke=%d target=%d shift=%d reason=%s",
				state_name,
				tick,
				globals.choked_commands or 0,
				def.last_choke_target or 0,
				aa_engine.defensive_ticks or 0,
				reason or "?"
			)
		end
		def.last_force_defensive = true
		return
	end

	cmd.force_defensive = false
	def.fire_reason = "idle"
	def.last_force_defensive = false
end

-- Advances the defensive measurement clock for this tick without writing force_defensive.
def_update_state = function(config, tick, cmd, state_name)
	aa_engine.def_active_config = config
	aa_engine.def_active_state = state_name or "?"

	if not config["defensive_tickbase"] then
		return
	end

	local me = entity.get_local_player()
	if not me or not me:is_alive() then return end

	if tick - (aa_engine.def.last_scan_tick or -1) >= 8 then
		def_scan_enemies(me)
		aa_engine.def.last_scan_tick = tick
	end

	aa_engine.def_last_sample_source = "createmove"
	aa_engine.def_last_sample_tick = tick
	defensive_sample_tickbase(me)

	local choke = globals.choked_commands or 0
	aa_engine.def.fire_prev_choke = aa_engine.def.prev_choke or 0
	aa_engine.def.prev_choke = choke
	aa_engine.tick_choke = choke
	local flags = me.m_fFlags or 0
	if bit.band(flags, FL_ONGROUND) == 0 then
		aa_engine.def.air_ticks = (aa_engine.def.air_ticks or 0) + 1
		aa_engine.def.dtc_air_phase = def_dtc_air_phase(me)
	else
		aa_engine.def.air_ticks = 0
		aa_engine.def.dtc_air_phase = "ground"
	end
	if choke == 0 then
		aa_engine.sent_tick_counter = (aa_engine.sent_tick_counter or 0) + 1
	end

	def_calc_choke_target(me, config)

	local def = aa_engine.def
	if def.pending_fire_check and def_at_send_tick() then
		local shift = aa_engine.defensive_ticks or 0
		local ok = shift > 0
		def_log_dtc(
			"sample [%s] %s | shift=%d choke=%d/%d",
			state_name or "?",
			ok and "ok" or "fail",
			shift,
			choke,
			def.last_choke_target or 0
		)
		def.pending_fire_check = false
	end
end

-- ── Setup AA helpers (manual / hide head / backstab) ───────────────
local MANUAL_YAW_OFFSETS = {
	Left = -90,
	Right = 90,
	Backward = 180,
	Forward = 0,
}

local function should_hide_head(me, state_name)
	if not setup.safe_head:get() or not me or not me:is_alive() then
		return false
	end

	local opts = setup.safe_head_options
	if not opts then
		return false
	end

	local function opt_on(name)
		return listable_has(opts, name)
	end

	local weapon = me:get_player_weapon(false)
	local classname = weapon and weapon:get_classname() or ""
	local is_knife = classname:find("Knife") ~= nil
	local is_zeus = classname:find("Taser") ~= nil or classname:find("taser") ~= nil
	local my_origin = me:get_origin()
	local threat = entity.get_threat(false)

	if opt_on("Air + Crouch Knife") and state_name == "Air + Crouch" and is_knife then
		return true
	end

	if opt_on("Air + Crouch Zeus") and state_name == "Air + Crouch" and is_zeus then
		return true
	end

	if not my_origin or not threat then
		return opt_on("Standing") and state_name == "Standing"
	end

	local threat_origin = threat:get_origin()
	if not threat_origin then
		return opt_on("Standing") and state_name == "Standing"
	end

	local height_adv = (my_origin.z - 35) > threat_origin.z

	if opt_on("Standing") and state_name == "Standing" then
		return true
	end

	if opt_on("Crouching") and (state_name == "Crouching" or state_name == "Crouch Moving") and height_adv then
		return true
	end

	if opt_on("Height Advantage") then
		if (my_origin.z - threat_origin.z) >= 24 then
			return true
		end
	end

	if opt_on("Distance") then
		local dx = threat_origin.x - my_origin.x
		local dy = threat_origin.y - my_origin.y
		if (dx * dx + dy * dy) > 1000000 then
			return true
		end
	end

	return false
end

local function ta_option_enabled(name)
	return listable_has(setup.ta_options, name)
end

local function should_troll_aa()
	if not setup.trollaa:get() then
		return false
	end

	local warmup = false
	local rules = entity.get_game_rules()
	if rules and rules.m_bWarmupPeriod then
		warmup = true
	end

	local round_end = aa_engine.round_ended and not entity.get_threat(true)

	if warmup and ta_option_enabled("Warmup AA") then
		return true
	end
	if round_end and ta_option_enabled("Round end AA") then
		return true
	end
	return false
end

local function calc_troll_aa_offset(tick)
	local speed = setup.ta_speed and setup.ta_speed:get() or 0
	if setup.ta_mode and setup.ta_mode:get() == "Half Spin" then
		return math.sin(tick * (speed / 10)) * 135
	end
	return tick * 2 ^ speed % 360
end

local function apply_troll_aa_mode(config, tick)
	if refs.pitch then refs.pitch:override("Disabled") end

	local offset = calc_troll_aa_offset(tick)
	if refs.offset then refs.offset:override(offset) end
	if refs.body_yaw[3] then refs.body_yaw[3]:override(0) end
	if refs.body_yaw[4] then refs.body_yaw[4]:override(0) end
	if refs.body_yaw[1] then refs.body_yaw[1]:override(false) end
	if refs.body_yaw[2] then refs.body_yaw[2]:override(false) end
	if refs.jitter then refs.jitter:override("Offset") end
	if refs.jitter_val then refs.jitter_val:override(0) end
	aa_engine.last_yaw = offset
end

local function apply_hide_head_mode(config, tick)
	if refs.freestand and refs.freestand[1] then refs.freestand[1]:override(false) end
	if refs.pitch then refs.pitch:override("Down") end
	if refs.base then refs.base:override("At Target") end
	if refs.offset then refs.offset:override(30) end
	if refs.jitter then refs.jitter:override("Disabled") end
	if refs.jitter_val then refs.jitter_val:override(0) end

	if refs.body_yaw[1] then refs.body_yaw[1]:override(true) end
	if refs.body_yaw[2] then refs.body_yaw[2]:override(false) end
	if refs.body_yaw[3] then refs.body_yaw[3]:override(0) end
	if refs.body_yaw[4] then refs.body_yaw[4]:override(0) end
	if refs.body_yaw[5] then refs.body_yaw[5]:override("Static") end
	if refs.body_yaw[6] then refs.body_yaw[6]:override("Off") end

	aa_engine.last_yaw = 30
end

reset_head_burger_state = function()
	local hb = aa_engine.head_burger
	if not hb then return end
	hb.hold_ticks = 0
	hb.current_yaw = 0
	hb.activation_delay = 0
	hb.delay_initialized = false
end

local function head_burger_ensure_random_buffer(hb)
	if hb.random_ready then return end
	for i = 1, 100 do
		hb.random_buffer[i] = math.random(-60, 60)
	end
	hb.random_ready = true
end

local function apply_head_burger_desync(speed2d)
	local fake_lim = math.min(60, math.max(58, math.floor(math.max(speed2d or 0, 60))))

	if refs.body_yaw[1] then refs.body_yaw[1]:override(true) end
	if refs.body_yaw[2] then refs.body_yaw[2]:override(false) end
	if refs.body_yaw[3] then refs.body_yaw[3]:override(-fake_lim) end
	if refs.body_yaw[4] then refs.body_yaw[4]:override(fake_lim) end
	if refs.body_yaw[5] then refs.body_yaw[5]:override("Static") end
	if refs.body_yaw[6] then refs.body_yaw[6]:override("Off") end
	if refs.jitter then refs.jitter:override("Disabled") end
	if refs.jitter_val then refs.jitter_val:override(0) end
end

local function handle_head_behind_chest(config, me, final_yaw)
	local hb = aa_engine.head_burger
	if not config["head_behind_chest"] or not me or not me:is_alive() then
		reset_head_burger_state()
		return final_yaw, false
	end

	if globals.choked_commands >= 3 then
		return final_yaw, false
	end

	head_burger_ensure_random_buffer(hb)

	if not hb.delay_initialized and hb.hold_ticks <= 0 then
		hb.activation_delay = 6 + (globals.tickcount % 3)
		hb.delay_initialized = true
	end

	local threat = entity.get_threat(true)
	local threat_visible = threat ~= nil
	local threat_shooting = false
	if threat then
		local threat_wpn = threat:get_player_weapon(false)
		if threat_wpn and (threat_wpn.m_flNextPrimaryAttack or 0) <= globals.curtime + 0.2 then
			threat_shooting = true
		end
	end

	local weapon_ready = (me.m_flNextAttack or 0) <= globals.curtime
	local sent_tick = (globals.choked_commands or 0) == 0

	if hb.activation_delay <= 0 and (threat_visible or threat_shooting) and weapon_ready then
		local vel = me.m_vecVelocity
		local speed2d = 0
		if vel then
			speed2d = math.sqrt(vel.x * vel.x + vel.y * vel.y)
		end

		if hb.hold_ticks > 0 then
			final_yaw = hb.current_yaw
			if sent_tick then
				hb.hold_ticks = hb.hold_ticks - 1
			end
		else
			local buf_idx = (globals.tickcount % 100) + 1
			local rand_off = (hb.random_buffer[buf_idx] or 0) % 11 - 4
			final_yaw = speed2d > 5 and rand_off or (3 + globals.tickcount % 3)
			hb.current_yaw = final_yaw
			hb.hold_ticks = 1 + globals.tickcount % 2
			if sent_tick then
				hb.activation_delay = 6 + math.random(1, 9)
			end
		end

		apply_head_burger_desync(speed2d)
		return final_yaw, true
	end

	if sent_tick and hb.activation_delay > 0 then
		hb.activation_delay = hb.activation_delay - 1
	end

	return final_yaw, false
end

local function apply_manual_yaw_mode(config, tick)
	local mode = setup.manual:get()
	local manual_offset = MANUAL_YAW_OFFSETS[mode] or 0

	if refs.freestand and refs.freestand[1] then refs.freestand[1]:override(false) end
	if refs.base then refs.base:override("local view") end
	if refs.pitch then refs.pitch:override() end

	apply_yaw_and_desync(config, tick)

	local final_yaw = manual_offset
	if not setup.disable_yaw_modifier:get() then
		local mod_yaw = apply_modifier(config, 0, tick)
		final_yaw = manual_offset + mod_yaw
	else
		if refs.jitter then refs.jitter:override("Disabled") end
		if refs.jitter_val then refs.jitter_val:override(0) end
	end

	if refs.offset then refs.offset:override(final_yaw) end
	aa_engine.last_yaw = final_yaw

	if setup.body_freestanding:get() then
		if refs.body_yaw[6] then refs.body_yaw[6]:override("Peek Real") end
	else
		if refs.body_yaw[6] then refs.body_yaw[6]:override() end
	end
end

local function apply_mouse_yaw_mode(config, tick)
	local state = aa_engine.mouse_yaw
	local mouse_offset = state and state.offset or 0

	if refs.freestand and refs.freestand[1] then refs.freestand[1]:override(false) end
	if refs.base then refs.base:override("local view") end
	if refs.pitch then refs.pitch:override() end

	apply_yaw_and_desync(config, tick)

	local final_yaw = mouse_offset
	if not setup.disable_yaw_modifier:get() then
		local mod_yaw = apply_modifier(config, 0, tick)
		final_yaw = mouse_offset + mod_yaw
	else
		if refs.jitter then refs.jitter:override("Disabled") end
		if refs.jitter_val then refs.jitter_val:override(0) end
	end

	final_yaw = normalize_yaw(final_yaw)

	if refs.offset then refs.offset:override(final_yaw) end
	aa_engine.last_yaw = final_yaw
	if state then state.final_yaw = final_yaw end

	if setup.body_freestanding:get() then
		if refs.body_yaw[6] then refs.body_yaw[6]:override("Peek Real") end
	else
		if refs.body_yaw[6] then refs.body_yaw[6]:override() end
	end
end

-- ── Main Engine Tick ───────────────────────────────────────────────
last_cmd = nil
aa_engine_run = function()
	local tick = globals.tickcount
	local me = entity.get_local_player()
	local state_name = detect_player_state(me, last_cmd)
	local fs_active = false

	if state_name ~= aa_engine.last_aa_state then
		aa_reset_delay_state()
		aa_engine.last_aa_state = state_name
	end
	aa_engine.debug_active_state = state_name

	local config = resolve_state_config(state_name)
	aa_engine.debug_speed_options = config["speed_options"] or "Default"
	aa_engine.debug_config_delay = math.max(1, math.floor(config["delay_speed"] or 2))
	local commit_config = config

	if me and me:is_alive() and shiny_uses_pressure(config) then
		shiny_update_pressure(me, aa_engine.shiny)
		shiny_update_lby_clock(me)
	end

	if refs.backstab then
		if setup.avoid_knife:get() then
			refs.backstab:override(true)
		else
			refs.backstab:override()
		end
	end

	def_update_state(config, tick, last_cmd, state_name)

	if is_mouse_yaw_active() then
		reset_head_burger_state()
		apply_mouse_yaw_mode(config, tick)
	elseif setup.manual:get() ~= "Off" then
		reset_head_burger_state()
		apply_manual_yaw_mode(config, tick)
	elseif should_troll_aa() then
		reset_head_burger_state()
		apply_troll_aa_mode(config, tick)
	elseif me and should_hide_head(me, state_name) then
		reset_head_burger_state()
		apply_hide_head_mode(config, tick)
	else
		if refs.pitch then refs.pitch:override() end
		apply_setup_yaw_base()
		if refs.body_yaw[6] then refs.body_yaw[6]:override() end

		fs_active = false
		if setup.freestanding:get() then
			fs_active = true
			local disablers = setup.fs_disablers:get()
			if type(disablers) == "table" then
				for _, d in pairs(disablers) do
					if d == state_name then
						fs_active = false
						break
					end
				end
			end

			if fs_active and setup.fs_prefer:get() and setup.manual:get() ~= "Off" then
				fs_active = false
			end
		end

		if refs.freestand and refs.freestand[1] then
			refs.freestand[1]:override(fs_active)
			if fs_active then
				local fs_body = setup.fs_body:get()
				local fake_override = fs_body == 2 and "Static" or "Jitter"
				local runtime_config = aa_config_with_overrides(config, {
					fake_options = fake_override,
				})

				if refs.freestand[3] then refs.freestand[3]:override(fs_body == 2) end
				if refs.freestand[2] then refs.freestand[2]:override(false) end
				if refs.offset then refs.offset:override(0) end

				commit_config = runtime_config
				apply_yaw_and_desync(runtime_config, tick)
			end
		end

		if not fs_active then
			local yaw_mode = config["yaw_mode"] or "Off"
			if yaw_mode == "Off" then
				if refs.offset then refs.offset:override() end
				apply_yaw_and_desync(config, tick)
				if config["head_behind_chest"] and me then
					local burger_yaw, burger_active = handle_head_behind_chest(config, me, 0)
					if burger_active and refs.offset then
						refs.offset:override(burger_yaw)
						aa_engine.last_yaw = burger_yaw
					end
				else
					reset_head_burger_state()
				end
			else
				local base_yaw = apply_yaw_and_desync(config, tick)
				if not base_yaw then
					if refs.offset then refs.offset:override() end
					reset_head_burger_state()
				else
					local final_yaw = apply_modifier(config, base_yaw, tick)
					final_yaw = handle_head_behind_chest(config, me, final_yaw)

					if refs.offset then
						refs.offset:override(final_yaw)
					end
					aa_engine.last_yaw = final_yaw
				end

				if refs.pitch then refs.pitch:override() end
				if refs.def then refs.def:override() end
				if refs.dt_fakelag then refs.dt_fakelag:override() end
			end
		else
			reset_head_burger_state()
		end
	end

	local peek_active = refs.autopeek and refs.autopeek:get()
	aa_engine.def.gating_blocked = def_disabler_blocks(
		fs_active,
		setup.manual:get() ~= "Off",
		peek_active
	)
	lc_apply_break_lc_overrides(me)
	apply_defensive_runtime_overrides(config)

	def_apply_force_defensive(last_cmd, tick, config)
end
-- ── AA.events ── Event Registration
local aa_cm_handler = nil

local function aa_reset_round()
	reset_table_fields(aa_engine, AA.round_reset.top)
	if aa_engine.def then
		reset_table_fields(aa_engine.def, AA.round_reset.def)
	end
	if aa_engine.shiny then
		reset_table_fields(aa_engine.shiny, AA.round_reset.shiny)
	end
	reset_mouse_yaw("round")
end

register_aa_events = function()
	aa_cm_handler = function(cmd)
		last_cmd = cmd
		local me = NL.entity.get_local_player()
		update_mouse_yaw_override(cmd, me)
		if misc_run then misc_run(cmd) end
		aa_engine_run()
		if is_mouse_yaw_active() then
			myo_lock_camera(cmd, aa_engine.mouse_yaw)
		end
		if misc_on_ia_peek then
			misc_on_ia_peek(cmd, me)
		end
		if is_mouse_yaw_active() then
			myo_lock_camera(cmd, aa_engine.mouse_yaw)
		end
	end
	EVENTS.set_handler("createmove", "aa.cm", aa_cm_handler)
	if EVENTS._registered then
		EVENTS.register_all()
	end
end
register_aa_events()
builder.event_handler:set_callback(function()
	register_aa_events()
end)

EVENTS.add({ event = "voice_message", tag = "aa.voice", order = 10, fn = function(ctx)
	pcall(function()
		if shared_on_voice_message and shared_on_voice_message(ctx) then
			return
		end
		def_on_voice_message(ctx)
	end)
end })

EVENTS.add({ event = "weapon_fire", tag = "aa.weapon_fire", order = 10, fn = function(e)
	local shooter = NL.entity.get(e.userid, true)
	if shooter and shooter:is_enemy() then
		local idx = shooter:get_index()
		if idx and idx > 0 then
			local profile = def_get_profile(idx)
			profile.shots_seen = (profile.shots_seen or 0) + 1
			profile.last_seen = NL.globals.curtime() or 0
			if not profile.voice_tag or (profile.voice_conf or 0) < DEF_VOICE_CONF then
				def_classify_profile(profile)
			end
		end
	end
end })

EVENTS.add({ event = "round_start", tag = "aa.reset", order = 10, fn = aa_reset_round })


EVENTS.add({ event = "net_update_end", tag = "aa.def_scan", order = 10, fn = function()
	local me = NL.entity.get_local_player()
	if me and me:is_alive() then
		def_scan_enemies(me)
	end
	if misc_on_clantag then misc_on_clantag() end
	if shared_sync_icons then shared_sync_icons() end
end })

end
init_aa_engine()



-- Stats Tracking (persistent via database)
local function init_stats_tracking()
	local DB_KEY_KILLS  = "shinymoon_total_kills"
	local DB_KEY_TIME   = "shinymoon_total_time"
	local DB_KEY_EVADED = "shinymoon_total_evaded"

	local total_kills   = tonumber(db[DB_KEY_KILLS]) or 0
	local total_time    = tonumber(db[DB_KEY_TIME])  or 0
	local total_evaded  = tonumber(db[DB_KEY_EVADED]) or 0
	local session_start = globals.realtime
	local last_save     = globals.realtime

	local function format_time(elapsed)
	local h = math.floor(elapsed / 3600)
	local m = math.floor((elapsed % 3600) / 60)
	local s = elapsed % 60

	if h > 0 then
		return string.format("%dh %dm %ds", h, m, s)
	elseif m > 0 then
		return string.format("%dm %ds", m, s)
	else
		return string.format("%ds", s)
	end
end

local function get_session_elapsed()
	local current = globals.realtime
	if not current or not session_start then return 0 end
	return math.floor(current - session_start)
end

	save_stats = function()
	local cumulative_time = total_time + get_session_elapsed()
	db[DB_KEY_TIME] = tostring(cumulative_time)
	db[DB_KEY_KILLS] = tostring(total_kills)
	db[DB_KEY_EVADED] = tostring(total_evaded)
end

local pending_shots = {}
local hits_received = 0

local function reset_anti_bruteforce()
	aa_engine.ab.bruted_last_time = 0
	aa_engine.ab.time = {}
	aa_engine.ab.jitteralgo = {}
	aa_engine.ab.delay = {}
	aa_engine.ab.fakelimit = {}
	aa_engine.ab.duration = {}
	aa_engine.ab.should_swap = {}
	aa_engine.ab.shooter_name = "Unknown"
end

local function reset_head_burger_runtime()
	if reset_head_burger_state then
		reset_head_burger_state()
	end
	local hb = aa_engine.head_burger
	if hb then
		hb.random_ready = false
		hb.random_buffer = {}
		hb.delay_initialized = false
		hb.hold_ticks = 0
		hb.current_yaw = 0
		hb.activation_delay = 0
	end
end

local function resolve_antibrute_config()
	local me = entity.get_local_player()
	if not me then return nil end
	return resolve_state_config(detect_player_state(me, last_cmd))
end

local function ab_shot_fired_at_local(shooter, impact)
	if not shooter or not impact then return false end
	local me = entity.get_local_player()
	if not me or not me:is_alive() then return false end

	local cam = shooter:get_eye_position()
	local head = me:get_hitbox_position(0)
	if not cam or not head then return false end

	local closest = head:closest_ray_point(cam, impact)
	if not closest or head:dist(closest) >= 129 then return false end

	local dmg_from_impact = utils.trace_bullet(shooter, impact, head)
	local dmg_from_closest = utils.trace_bullet(shooter, closest, head)
	return (not (dmg_from_impact <= 0.99)) or dmg_from_closest > 0.99
end

local function trigger_anti_bruteforce(shooter)
	if not shooter or not shooter:is_enemy() then return end
	local config = resolve_antibrute_config()
	if not is_antibrute_enabled_for_config(config) then return end

	local now = globals.curtime or 0
	if math.abs((aa_engine.ab.bruted_last_time or 0) - now) <= 0.25 then return end

	local duration = (config and config["duration"]) or 0
	local expire = duration > 0 and (now + duration) or (now + 86400)

	aa_engine.ab.bruted_last_time = now
	aa_engine.ab.time[shooter] = expire
	aa_engine.ab.duration[shooter] = duration
	aa_engine.ab.jitteralgo[shooter] = math.random(-6, 4)
	aa_engine.ab.delay[shooter] = math.random(-2, 4)
	aa_engine.ab.fakelimit[shooter] = math.random(10, 60)
	aa_engine.ab.should_swap[shooter] = true
	aa_engine.ab.shooter_name = shooter:get_name() or "Unknown"

	local accent = shinymoon_accent_hex()
	local shooter_name = (aa_engine.ab.shooter_name or "unknown"):lower()
	shinymoon_log_print(string.format(
		"\a%sAnti-Bruteforce\aDEFAULT updated by \a%s%s\aDEFAULT's shot [\a%s%d;%d;%d\aDEFAULTt]",
		accent, accent, shooter_name, accent,
		aa_engine.ab.jitteralgo[shooter],
		aa_engine.ab.fakelimit[shooter],
		aa_engine.ab.delay[shooter]
	))
end

local function stats_reset_round()
	reset_anti_bruteforce()
	reset_head_burger_runtime()
	aa_engine.round_ended = false
	reset_mouse_yaw("round")
end

local function stats_reset_level()
	reset_anti_bruteforce()
	reset_head_burger_runtime()
	aa_engine.round_ended = false
	reset_mouse_yaw("level")
end

EVENTS.add({ event = "round_start", tag = "stats.reset", order = 20, fn = stats_reset_round })
EVENTS.add({ event = "level_init", tag = "stats.reset", order = 10, fn = stats_reset_level })
EVENTS.add({ event = "round_end", tag = "stats.round_end", order = 10, fn = function()
	aa_engine.round_ended = true
end })

-- Update display every frame
EVENTS.add({ event = "render", tag = "stats.render", order = 10, fn = function()
	if visuals_run then visuals_run() end
	if misc_draw then misc_draw() end
	draw_mouse_yaw_indicator()
	if not home.session_btn then return end
	local cumulative_time = total_time + get_session_elapsed()
	home.session_btn:name(format_time(cumulative_time) .. "##SESSION_TIME")

	-- Auto-save every 30 seconds
	local now = globals.realtime
	if now and last_save and (now - last_save) >= 30 then
		save_stats()
		last_save = now
	end

	-- Process pending shots for evaded
	for i = #pending_shots, 1, -1 do
		local shot = pending_shots[i]
		if globals.realtime - shot.time > 0.05 then
			-- If 50ms passed and no hit received during that window, it's a miss
			if math.abs(hits_received - shot.time) > 0.05 then
				total_evaded = total_evaded + 1
				db[DB_KEY_EVADED] = tostring(total_evaded)
				if home.evaded_btn then
					home.evaded_btn:name(tostring(total_evaded) .. "##EVADED")
				end
				if is_antibrute_enabled_for_config(resolve_antibrute_config()) then
					trigger_anti_bruteforce(shot.shooter)
				end
			end
			table.remove(pending_shots, i)
		end
	end
	
	-- AA Debug Panel
	if setup.aa_debug and setup.aa_debug:get() then
		local screen = render.screen_size()
		local x, y = 15, screen.y / 2 - 60
		local white = color(255, 255, 255, 255)

		local me = entity.get_local_player()
		if me and me:is_alive() then
			local lines = {}
			local function dbg(fmt, ...)
				lines[#lines + 1] = string.format(fmt, ...)
			end

			dbg("tickcount: %d", globals.tickcount or 0)
			dbg("choked_commands: %d", globals.choked_commands or 0)
			dbg("m_ntickbase: %d", me.m_nTickBase or 0)
			dbg("def_max_tickbase: %d", aa_engine.def_max_tickbase or 0)
			dbg("defensive_ticks: %d", aa_engine.defensive_ticks or 0)
			dbg("max_defensive_ticks: %d", aa_engine.max_defensive_ticks or 0)
			dbg("def_sync_clock: createmove")
			local delay_event = aa_engine.def_active_config and aa_engine.def_active_config["event_handler"]
			if not delay_event and builder.event_handler then
				delay_event = builder.event_handler:get()
			end
			dbg("delay_event: %s", delay_event or "createmove")
			dbg("def_last_sample: %s @%d", aa_engine.def_last_sample_source or "createmove", aa_engine.def_last_sample_tick or -1)
			dbg("def_sampled_base: %d", aa_engine.def_last_sampled_base or 0)
			dbg("m_flsimulationtime: %.3f", me.m_flSimulationTime or 0)
			dbg("tick_choke: %d", aa_engine.tick_choke or 0)
			dbg("fakelag_limit: %d", get_fakelag_limit())

			local def = aa_engine.def
			if def then
				local choke = globals.choked_commands or 0
				dbg("choke_target: %d", def.last_choke_target or 0)
				dbg("fire_choke: %d", def.last_fire_choke or 0)
				dbg("prev_choke: %d", def.fire_prev_choke or 0)
				dbg("at_fire_point: %s", (choke == 0 and (def.fire_prev_choke or 0) >= (def.last_fire_choke or 0)) and "true" or "false")
				dbg("window_start: %s", def.window_start and "true" or "false")
				dbg("window_fire_armed: %s", def.window_fire_armed and "true" or "false")
				dbg("fire_reason: %s", def.fire_reason or "idle")
				dbg("skip_reason: %s", def.skip_reason or "none")
				dbg("dtc_air_phase: %s", def.dtc_air_phase or "ground")
				dbg("air_ticks: %d", def.air_ticks or 0)
				dbg("early_bias: %d", def.early_bias or 0)
				dbg("profile_bias: %d", def.profile_bias or 0)
				dbg("force_defensive: %s", last_cmd and last_cmd.force_defensive and "true" or "false")
				dbg("nearest_cheat: %s", def.nearest_tag or "unknown")
				dbg("nearest_cheat_conf: %.2f", def.nearest_conf or 0)
				dbg("nearest_detect_source: %s", def.nearest_source or "none")
			end

			dbg("aa_state: %s", aa_engine.debug_active_state or "?")
			dbg("delay_speed_ui: %d", aa_engine.debug_config_delay or 0)
			dbg("effective_speed: %d", aa_engine.debug_effective_speed or 0)
			dbg("switch_delay: %d", aa_engine.switch_delay or 0)
			dbg("speed_options: %s", aa_engine.debug_speed_options or "?")
			dbg("antibrute_active: %s", aa_engine.debug_antibrute_active and "true" or "false")

			local shiny = aa_engine.shiny
			if shiny then
				dbg("mod_phase: %s", shiny.mod_phase or "idle")
				dbg("mod_amp_scale: %.2f", shiny.mod_amp_scale or 1)
				dbg("pressure: %d", shiny.pressure or 0)
				dbg("delay_target: %d", shiny.delay_target or 0)
				dbg("delay_cycle: %d", shiny.delay_cycle or 0)
				dbg("mod_sent_counter: %d", shiny.mod_sent_counter or 0)
				local buf = shiny.mod_offset_buf or {}
				dbg("last_offset: %.1f", #buf > 0 and buf[#buf] or 0)
				dbg("self_jitter: %s", shiny.mod_self_jitter and "true" or "false")
			end

			if rage and rage.exploit then
				dbg("exploit: %d", rage.exploit:get() or 0)
			end

			if me.m_flPoseParameter and me.m_flPoseParameter[11] then
				dbg("m_flposeparameter[11]: %.3f", me.m_flPoseParameter[11])
			end

			for i, line in ipairs(lines) do
				render.text(1, vector(x, y + (i - 1) * 14), white, "s", line)
			end
		end
	end
end })

-- Track kills
EVENTS.add({ event = "player_death", tag = "stats.death", order = 10, fn = function(e)
	local local_player = entity.get_local_player()
	if not local_player then return end

	local attacker = entity.get(e.attacker, true)
	local victim = entity.get(e.userid, true)

	if victim == local_player then
		reset_mouse_yaw("death")
	end

	if attacker == local_player and victim ~= local_player then
		total_kills = total_kills + 1
		db[DB_KEY_KILLS] = tostring(total_kills)
		if home.kills_btn then
			home.kills_btn:name(tostring(total_kills) .. "##KILLS")
		end
	end
end })

EVENTS.add({ event = "player_hurt", tag = "stats.hurt", order = 10, fn = function(e)
	local local_player = entity.get_local_player()
	if not local_player then return end
	local victim = entity.get(e.userid, true)
	
	if victim == local_player then
		hits_received = globals.realtime
		aa_engine.shiny.last_hurt = globals.curtime
		if is_antibrute_enabled_for_config(resolve_antibrute_config()) then
			local attacker = entity.get(e.attacker, true)
			trigger_anti_bruteforce(attacker)
		end
	end

	if misc_on_player_hurt_log then
		misc_on_player_hurt_log(e)
	end

	if visuals_on_player_hurt then
		visuals_on_player_hurt(e)
	end
end })

EVENTS.add({ event = "bullet_impact", tag = "stats.impact", order = 10, fn = function(e)
	local me = entity.get_local_player()
	if not me or not me:is_alive() then return end

	local shooter = entity.get(e.userid, true)
	if not shooter or shooter == me or not shooter:is_enemy() then return end

	local my_pos = me:get_hitbox_position(0)
	local my_origin = me:get_origin()
	if not my_pos or not my_origin then return end
	
	local my_center = my_origin:clone()
	my_center.z = my_center.z + 35

	local impact = vector(e.x, e.y, e.z)

	if ab_shot_fired_at_local(shooter, impact) then
		if is_antibrute_enabled_for_config(resolve_antibrute_config()) then
			trigger_anti_bruteforce(shooter)
		end
	end

	local shooter_pos = shooter:get_hitbox_position(0)
	if not shooter_pos then return end

	local closest_head = my_pos:closest_ray_point(shooter_pos, impact)
	local closest_center = my_center:closest_ray_point(shooter_pos, impact)

	local dist_head = my_pos:dist(closest_head)
	local dist_center = my_center:dist(closest_center)

	if math.min(dist_head, dist_center) <= 100 then
		table.insert(pending_shots, { time = globals.realtime, shooter = shooter })
		aa_engine.shiny.last_near_miss = globals.curtime
		aa_engine.shiny.last_threat_shot = globals.curtime
	end
end })

	home.kills_btn:name(tostring(total_kills) .. "##KILLS")
	home.session_btn:name(format_time(total_time) .. "##SESSION_TIME")
	home.evaded_btn:name(tostring(total_evaded) .. "##EVADED")
end
init_stats_tracking()

local function init_animations()
	local function get_anim_layer(player)
		return ffi.cast(anim_layer_type, ffi.cast("uintptr_t", player[0]) + 10640)[0]
	end

	local interp_state = {
		smoothed_pose = {},
		smoothed_layers = {},
	}

	local function reset_interp_state()
		interp_state.smoothed_pose = {}
		interp_state.smoothed_layers = {}
	end

	local function apply_misc_interpolation(player, layer)
		if not misc_setup.interpolation or not misc_setup.interpolation:get() then return end

		local scale = misc_setup.interpolation_scale and misc_setup.interpolation_scale:get() or 0
		if scale <= 0 then return end

		local blend = globals.tickinterval * scale
		local inv = 1 - blend
		local pose = player.m_flPoseParameter

		for i = 0, 12 do
			local current = pose[i] or 0
			local prev = interp_state.smoothed_pose[i]
			if prev == nil then prev = current end
			local smooth = blend * prev + inv * current
			interp_state.smoothed_pose[i] = smooth
			pose[i] = smooth
		end

		for i = 0, 12 do
			local anim_layer = layer[i]
			if anim_layer then
				local current = anim_layer.m_flWeight or 0
				local prev = interp_state.smoothed_layers[i]
				if prev == nil then prev = current end
				local smooth = blend * prev + inv * current
				interp_state.smoothed_layers[i] = smooth
				anim_layer.m_flWeight = smooth
			end
		end
	end

EVENTS.add({ event = "post_update_clientside_animation", tag = "anims.post_update", order = 10, fn = function(player)
	local me = entity.get_local_player()
	if not me or player ~= me or not me:is_alive() then return end

	local layer = get_anim_layer(player)

	if setup.anims:get() and layer then
		local anim_state = player:get_anim_state()
		if anim_state then
		local pose = player.m_flPoseParameter
		if not pose then return end
		local on_ground = bit.band(me.m_fFlags, 1) ~= 0

		if on_ground then
			local ground_mode = setup.ground_legs:get()
			if ground_mode == "Static" then
				player.m_flPoseParameter[0] = 1
				if AA.refs.leg_movement then AA.refs.leg_movement:override("Sliding") end
			elseif ground_mode == "Jitter" then
				local tick = globals.tickcount
				local osc = 1 / (tick % 8 >= 4 and 200 or 400)
				local off1 = setup.legs_offset_1:get()
				local off2 = setup.legs_offset_2:get()
				local j_val = tick % 4 >= 2 and off1 or off2
				if AA.refs.leg_movement then AA.refs.leg_movement:override("Sliding") end
				player.m_flPoseParameter[0] = j_val * osc
			elseif ground_mode == "Walking" then
				player.m_flPoseParameter[7] = 0
				if AA.refs.leg_movement then AA.refs.leg_movement:override("Walking") end
			elseif ground_mode == "Earthquake" then
				player.m_flPoseParameter[3] = math.random()
				player.m_flPoseParameter[6] = math.random()
				player.m_flPoseParameter[7] = math.random()
				if AA.refs.leg_movement then AA.refs.leg_movement:override() end
			else
				if AA.refs.leg_movement then AA.refs.leg_movement:override() end
			end

			if setup.pitch_on_land:get() and anim_state.landing then
				player.m_flPoseParameter[12] = 0.5
			end
		else
			local air_mode = setup.air_legs:get()
			if air_mode == "Static" then
				player.m_flPoseParameter[6] = 0.5
			elseif air_mode == "Walking" then
				layer[6].m_flWeight = 1
				layer[6].m_flCycle = globals.curtime * 0.5 % 1
			end
		end

		local lean = setup.body_lean:get()
		if lean > 0 and layer then
			layer[12].m_flWeight = lean / 100.0
		end
		end
	end

	if layer then
		apply_misc_interpolation(player, layer)
	end
end })

EVENTS.add({ event = "round_start", tag = "anims.reset", order = 30, fn = function()
	reset_interp_state()
end })

EVENTS.add({ event = "level_init", tag = "anims.reset", order = 20, fn = function()
	reset_interp_state()
end })

	setup.anims:set_callback(function()
		if not setup.anims:get() then
			if AA.refs.leg_movement then
				AA.refs.leg_movement:override()
			end
		end
	end)
end
init_animations()

-- ── Visuals Module ──
local function init_visuals()

local vis_refs = VIS.refs
vis_refs.min_damage = NL.ui.find("Aimbot", "Ragebot", "Selection", "Min. Damage")
vis_refs.scope_overlay = NL.ui.find("Visuals", "World", "Main", "Override Zoom", "Scope Overlay")

local vis_cvars = {
	aspect        = cvar.r_aspectratio,
	viewmodel_fov = cvar.viewmodel_fov,
	viewmodel_x   = cvar.viewmodel_offset_x,
	viewmodel_y   = cvar.viewmodel_offset_y,
	viewmodel_z   = cvar.viewmodel_offset_z,
}

local vis_state = VIS.state
vis_state.scope_alpha = 0
vis_state.scope_size_smooth = 120
vis_state.scope_gap_smooth = 8
vis_state.scope_thick_smooth = 1
vis_state.damage_alpha = 0
vis_state.damage_anim = 0
vis_state.hitmarker_master = 0
vis_state.hitmarkers = {}
vis_state.hitmarker_screen = nil
vis_state.molotov_alpha = 0
vis_state.smoke_alpha = 0
vis_state.aspect_smooth = nil
vis_state.aspect_saved = nil
vis_state.vm_smooth = nil
vis_state.vm_saved = nil
vis_state.wm = {
	dragging = false,
	drag_offset = vector(0, 0),
	pos = nil,
	loaded = false,
}

local shared_icon_b64 = [[
/9j/4AAQSkZJRgABAQAAAQABAAD/4gHYSUNDX1BST0ZJTEUAAQEAAAHIAAAAAAQwAABtbnRyUkdC
IFhZWiAH4AABAAEAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAA
AADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlk
ZXNjAAAA8AAAACRyWFlaAAABFAAAABRnWFlaAAABKAAAABRiWFlaAAABPAAAABR3dHB0AAABUAAA
ABRyVFJDAAABZAAAAChnVFJDAAABZAAAAChiVFJDAAABZAAAAChjcHJ0AAABjAAAADxtbHVjAAAA
AAAAAAEAAAAMZW5VUwAAAAgAAAAcAHMAUgBHAEJYWVogAAAAAAAAb6IAADj1AAADkFhZWiAAAAAA
AABimQAAt4UAABjaWFlaIAAAAAAAACSgAAAPhAAAts9YWVogAAAAAAAA9tYAAQAAAADTLXBhcmEA
AAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABtbHVjAAAAAAAAAAEAAAAMZW5VUwAA
ACAAAAAcAEcAbwBvAGcAbABlACAASQBuAGMALgAgADIAMAAxADb/2wBDAAMCAgMCAgMDAwMEAwME
BQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQME
BAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQU
FBQUFBT/wAARCAQABAADASIAAhEBAxEB/8QAHAABAQEBAQEBAQEAAAAAAAAAAAECBgUEBwMJ/8QA
VRABAAECAwYBBQoHDAgGAwEAAAECEQMEMQUGEiFRgsITNUFhcRQiMnJzgZGxssE2QlJ0g6GzFSMz
NERiY6Kj0dLTByUmQ1RVZJIWJEVGU5PD4fDx/8QAGQEBAQEBAQEAAAAAAAAAAAAAAAECAwQF/8QA
MBEBAQEAAQAHBwQCAwEBAAAAAAERAgMEMTNBgbEUITJioeHwEhMVNCIjBSRRQmH/2gAMAwEAAhED
EQA/AP8ANPcfTO9nidS5bcfTO9nidS+91XueP54gBMvUGjM8yZuNY1gAqgAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANMzq1HJKmGEASgAy1BadEWlkqgDIADItW
qDQAKAAAAAAAAAAAAAAAAARzkGo0AGAABmdWp0ZFgAsaAGmQIi6xDSJa68JeIOJcXDhOFLyXkwxq
0FmbyXkwxoZvIYYTzkBpocvvtpk+/wALqHL77aZPv8Ly9a7jl5eqVdyJ5Z3s8TqOJy25Omc7PE6h
nqs/08fzxSQmbgPY0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAA1GhOiRKzowwyAlABlqBGoMq0AMAAJMI1OjI1AAUAAAAAAAAAAAAAAAAWlIi7QlABkAmbQ
DMzzAGgBtKERciLrM2aiLM2Zmbg1I0ANYoAuIAJigBgAJgOX320yff4XUOX320yff4Xl613PLy9U
puTpnOzxOocvuTpnezxOoTqvc8fzxIAPWoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAABGrTMatM1mshOoiADCwAZrTUaCUqM0AEGZ1aJFjIA0AAAAAAAAAAA
AAAAsRcFiLQAMAADMzdZlBYANLQFiLc2oyaQhM3G5GoANmgC4yALgAJgAIugAo5ffbTJ9/hdQ5ff
bTJ9/heTrfc8vL1Kbk6Zzs8TqHL7k6Z3s8TqGeq9zx/PEgA9agAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEatMxq0zWazMWkJ1EQAYWACVojVplqOaM0AEA
ASYRpJgWVABoAAAAAAAAAAC0tW5iakQoDIAATNiZszM3FgAsigERdqMrEEyTNkbkWADotAWIu1Iy
kRdbLonEotoLQzeS64uLNKLxLqiMizCAAMg5ffbTJ9/hdQ5ffbTJd/hePrfc8vL1XTcnTO9nidQ5
fcnTOdnidQz1XueP54rAB61AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAWlSI5DNZrM6gIgAwsAErQtOiLSiVQBkAAABOFJaBdZGk4RdQXhOENQatBaA1ks0
CakQtgEAPagBaxM2UCZskyguGoCyKAatSIarpB8FG5CQAbkUAiLtyMrEXXQ0ZmbtKTNwGmgAAibA
DUTdJi6Xs1E3ZsZsZFmERBy++2mT7/C6hy++2mT7/C8PW+55eXqG5Omc7PE6hy+5Omc7PE6hnqvc
8fzxagA9agAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALT
CIpOglTLKAJQAZWAA0AMjUTcZWKhnFAEAAAAAAA9CWnqgoRFiwFy9wAC9k4lVSZszcDFmpAXFAFw
0BYi7WMpEXXQmbaI1IuADcigDUZGoixEWSZaEmbgNtgBAAawAGQABrVJhImzTLLLl99tMn3+F1Ex
Zy++2mT7/C8XXO45eXqhuTpnOzxOocvuTpnOzxOoc+q9zx/PFqAD1qAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARFwIaIiwzWaaMrVKIgAlABkABoAMUATALgg
vEcSAmNXgvDIGNXLsgY1eC8MgYvEcSBhheS9wXAAMNAFxNAIhrECIutog4lxS0QkzcGpFwAbw0AW
RkWIsRFiZs0EzZAaaAFUAaAAAAABkFplBEamLuV320yff4XVRN4ctvv/ACPv8Lw9c7jl5erKbk6Z
zs8TqHL7k6Zzs8TqHPqvc8fzxagA9agAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFgBYpWyams2leFR
NTU4ThUNNLQnCoiJwnCourrNpJizQaayNTF04V1dQXhSYsAAqgAAAAAAAAAALFKIjURYE1NCZsTN
mUQAAASgAyAAAAugAaAKaABoAGgAaAGGgFjDQXhk4fWuIgvKDiXFS0raEvIuGLeyXBrFwAXDQBrE
0BYpXESIu1EWL2ZmbtYuLMoCqAKoA0AAAAAAAAADIRNnM78aZLv8LpnMb7TeMl3+F4eudxy8vVmp
uTpnOzxOocvuTpnOzxOocuq9zx/PFYAPWoAAAAAAAAAAAAAAAAAAAAAAAAAAAAERdpNTUilQuyyC
TUgLxHEgBeS4AAAXLyAF14kAavBe7IDQzexeQaLJxHEBwkwtxdXWbSWloNNZtI0Gms2leFQ01OEs
oaaBdJqRFSZS9wDUAAAAAAAALSvCCDVjlAMi3g4lxcS0lpXiOKTDDhS0rxJeTDF4ZOFLyXMMXhLI
GGLaDkguLi39RxILhheQFwAFw0AVNADEAtKxSuCLFK6JNSipNSDWNYAKoAAA0AAAAAAAAAAACUHL
77aZPv8AC6hy++2mT7/C8PXO45eXqlNydM52eJ1Dl9ydM52eJ1Dj1XueP54kAHrUAAAAAAAAAAAA
AAAAAAAAAAAAAAWIIhWdZ0E4kRCZAAATQAQAEXAAMAAwADABdQANABdAA0Ll5BReI4kAXiOJAC5c
AAAAAAAAACIusUqBEGiTUi4uLNSXkFxQBrFADEAFw0ADQATQBTQAw0AMQCy8K4ILwrZRleFbpxQB
wronEl7ri4vEcSC4uACqAAALgAKAAAAAAAAAAAAAADl99tMn3+F1Dl99tMn3+F4Oudxy8vVKbk6Z
zs8TqHL7k6Zzs8TqHHqvc8fzxIAPWoAAAAAAAAAAAAAAAAAAAAAAABEXWIssRYZtZtEmUmbiIAJo
AIACNYACgCaABoAGgAaABoALoACYABgAJgAGAAYACAAAAADYLEJEXa0AmbMzNwakaAGsUAVnQBcQ
AtK4AvCcKiDVoLAyWaLwDNpLS1eE4gOE4TiS8ri41aDRm4YY1eE4kFxcXiS4AAKoAAAuAAuAAAAA
AAAAAAAAAAAAAAAA5ffbTJ9/hdQ5ffbTJ9/heHrvccvL1iU3J0znZ4nUOX3J0zvZ4nUOHVe54/ni
QAetQAAAAAAAAAAAAAAAAAAAACOYERdqIsRFhms0ZmbkzcRABNABlcADWgBnQCy8IiDVoA1m0lpa
BNThOGVA1m0lpaA1m0lmgNZsNAayNWThF1BeFLSGgWDVAF0ADQAXQAEABkBYhsWIszM3WZ5IsWAD
pFAFZAtdqIs0JELaEmpL3XFxpLoLi4vEcSBhheS4AAKoAAAAAYAC4ABgAKAAAAAAAAAAAAAAAAAA
AAAAAAAADl99tMn3+F1Dl99tMn3+F4eu9xy8vVKbk6Zzs8TqHL7k6Zzs8TqHDqvc8fzxIAPWoAAA
AAAAAAAAAAAAAAABqBEXaiLERYZ1nSZszM3Jm4iADNoAI1gAmqBEXaiLImpwraAE0AEAAAAAAAAA
AAAAAAAAALQnCoDNpGiwusizCCgDUUAVmixojU8oaRmecgNxsAbZoRFyIu1PJpC9mZm5M3GsawAV
QBcAAwADAAXAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAcvvtpku/wuocvvtpk+/wALw9d7
jl5esSm5Omc7PE6hy+5Omc7PE6hw6r3PH88SAD1qAAAAAAAAAAAAAAAAAANRFkiFZtZtGZm5M3EQ
AZ0AEaAIi7KixCxFgZ0AEAAAAAAALgCTJxC4ozEkzcMaGbl7BjQnFJxBiicRxBihEl4EAAAAAAGZ
izSVCxAFjQA1GatJVqUo3CADpFoC0w1GV0ZmbrMo3GoAKoA0AAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAADl99tMn3+F1Dl99tMn3+F4Ou9xy8vVKbk6Zzs8TqHL7k6Zzs8TqHHqvc8f
zxIAPWoAAAAAAAAAAAAAABqA1EWhIiys2s2jMzcmbiIAM2gAjUAIi7KkRdrQBkAEAAAmbJM8gUZu
C41dm4C4ACgAAAAAAAAAAAF7LdARoSJUZAACdAnQGQFjYA1GF0hFnRHSNQAdEo1olOpU0iANtgDU
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABy++2mT7/C6hy++2mT7/AAvB1zuO
Xl6pTcnTOdnidQ5fcnTOdnidQ49V7nj+eJAB61AAAAAAAAAAAAAIAs1EWBnWdGZm5M3EQAS0AGWp
ACIuypEXaAZABAC4CTKTNwawmbgCgAAAAAAAAAAAAAAAAAAABE2COQjQAyAAyAsbAGowtSLUjrGo
ANxKtJURok6twgA00ANAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA5ffbTJ9/
hdQ5ffbTJ9/heDrnccvL1Sm5Omc7PE6hy+5Omc7PE6hx6r3PH88SAD1qAAAAAAAAAABZYhEIpUJm
zLJM2ZmbkzcAAS0AGVgAlrREXaiLERYRmgAgCTNgJmyANAAoAAAAAAAAAAAAAAAAAAAAAAAC06Kl
KjNABGZ1CdRY0ANRKtSLOiOkWADpEqxok6rSVNwiANNADQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAOX320yff4XUOX320yff4Xg653HLy9UpuT/ACzs8TqHL7k6Zzs8TqHHqvc8
fzxIAPWoAAAAAABEXAWKViLDOs6AkyiEygAAJaADKwAStCxBEKjNABADQCZszPMmbg1AAUAAAAAA
AAAAAAAAAAAAAAAAAAAAjVpmNWhmgAiVItSDUAG4lXWlFpSeUukIANlIm0tTzhlYltEFmEaaAFUA
a0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHL77aZPv8LqHL77aZPv8Lwdc7jl5
eqU3J0znZ4nUOX3J0znZ4nUOPVe54/niQAetQAAAAACzUQkQrNZoAiE6MtTF4ZAAAAYAAbAWmGUW
IsAMgACTKzoyLAAaAAAAAAAAAAAAAAAAAAAAAAAAAAAAGmWo0EoAMk6MtMzyFgA0tIm0rUixzhuM
oA6RoAalZaibpMIsVNCDVrpNLWtagCqAAAAAGgAugAaACgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAA5ffbTJ9/hdQ5ffbTJ9/heDrnccvL1Sm5MXjOdnidRaXMbj6Z3s8TqXDqt/08fzxTWbSsUqPV
pqcJNKhprNpLS0k3NNS0ryhL3FUvzaibshhjQyvEmJiszFliVRGRZhAAGQASti0otLKVQBkABJQn
UGgAUAAAAAAAAAAAAAAAAAAAAAAAAAAAAWnRFibCVQBkSpSecAyAsbCJsDUYWYuixJMNyrEAdNUA
XULrxILqNFoZLqLwnCcRxLq6lpLLxQt7mmsjRaF1dZF4ThNNQBVAAAF0AFAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAABy++2mT7/C6hy++2mS7/AAvB1zuOXl6pV3Im0Z3s8TqOJy25Omc7PE6h5+q9zx/P
FloZvZqJu9QAAJMkyiyLIANNABgALgFwTBYqJi+iETZMTAXlKaM1kAYWC0oRyZVoAZCdAnQGQBsA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAABoSlRgABJhGmZi0jUAGgWJsg1rKzHRCJst4lrV1BZpRrVA
GtMAFTAA0wAXUC4Gi8RxIKNXuWhkuC8KLxLqurrIswmiqAKoAugAoAAAAAAAAAAAAAAAAAAAAAAA
AAAOX320yff4XUOX320yff4Xg653HLy9UpuTpnOzxOocvuTpnOzxOoefqvc8fzxZFpTVqIs9QJM2
WZsysiyADWNADSaALiaBaV4VxEF4UtJgAJi6Lr7UGLF7TQXX2o52MgDFaaibwMxPNpEoToJOgiAD
YAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABE2aZWJEqgDIagDMxYamLszFhoAa0AF1CJst4lBdReFL
F14mtXUFvBaJXV1BeFOGV00CwuqAGoAKYAKmAC6ixUurJeyizSjUTcmLrq6yExYaaAAAGgAAAAAA
AAAAAAAAAAAAAAAAAAcvvtpk+/wuocvvtpk+/wALwdc7jl5eqU3J0znZ4nUOX3Ij+OdnidVEWefq
vc8fzxZIiyTJMo9ci4AN4oBq1iaERdbRCTN2pDF5QcSDci4XkBcULyBgt76luiGjNiYC6+1GLE7B
Z5xdCJs52L2gTFhyqQaibsrSwtUnQBlkAbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWJVmJtLU
TcZoAIExcAZmLDSTFxdQBdaAFTABUwANQuXkF0XiLwgujXKU4UAXhReI4l1dQatEpNK6uoA1oAKm
CxKDWo1qkxZImzUTdpWRZhFUAVQBoAAAAAAAAAAAAAAAAAAAAAAHL77aZPv8LqHL77aZPv8AC8HX
O45eXqlXcjlGd7PE6eZu5fcnTOdnidQ49Un+nj+eJAB7cNAiLrp7WpGS3UmeiTNxuRrABuQAtK8o
axNQtK3S8rh7y0heVvE6mHvQJgZxdF1j1oRNmLAFlHKxIusIRqTylxsKAOdVoSJVGWZFqQaABQAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAibAI1cZhqOYmAAgAAk0qAyNJNI1qAGqALoAKmAAYACYALp
gXBdRbxJNKF7LoC3ukxZqVrQBvTABdZaibpMIsTdoQWYujTQAqgDQAAAAAAAAAAAAAAAAAAAFBy+
+2mT7/C6hy++2mT7/C8HXO45eXqlNydM52eJ1Dl9ydM52eJ1ERdjqk/08fP1QW3U5Qkzd7pDFv0Q
G5FALdWsNIi68o9aXG8MJm4CqALgAARNlmL84QibM2JYBMDFhFjnEwhHIlysSizzhCNJceS0AcaR
aVZjlLTKVJhGmZ1CAA0AAAAAAAAAAAAAAAAAAAAAAAAAAAAA1hYNePiU4eHRViV1TaKaYvMyDI9n
C3Tz88Hl4wsnFUcUe6cWmibfFmb/AKmMbdzFwr2zOWxPi4n/AOmv0cv/AAeSP7Y2Uxcv8Oi0dY5w
/izZZ2gACxKskTYTGgibgyAAAAJwqAzaRomBdZF4ZQUAFAF0ADQAXUABMFipBrUW19EImy8palXU
CYsN6oA1KixJMXRYlpEGpi7MxZpoAVQBoAAAAAAAAAAAAAAAAAEoOX320yff4XUOY320yff4Xh65
3HLy9UpuRpnezxOnmbuX3J0znZ4nUL1Kf6OPn6kAIi73yGhELyj1pM3akTtW9tEBrFAGsUAVNABN
ABdAGaqxziyETYnVis+Iax7Ahyq0I1BxsIBI4VINRoytMsLVSYUGWRZiyDQAKAAPU2fu/i7Qyc5m
MfAwcOK+D99rtMzZ5bo9mz/s9TH/AFE/U3w4zlyyj5at2MSn+WZWfZif/p/Od3sWP5Tl5732j0/t
cVx8P/h/F/4jA/72K9iYtH+9wqvZU9EP2uJjyP3Lxv5v0vmxKJw66qZ1ibS6B4mfonDzmLTPKeJy
6ThOM2FfwAcEAAAAAAAAAAAAAAfbsnZWLtfNeSw5iiimnjxMWr4OHTGsy6PDzmHsqirB2XFWBTMc
NeYn+FxPn/Fj1R893z5HhyW7+DhUW8pmqpxsWfTaJmKafrnufxezo+Ek1ZFmbzedUB2U1fDnNn01
RNeFFqvTTGkvuGeXGcplHOj69pZecHGiuItTXzj2+l8jwWZcZAEBYlARoZibNRNxMABAAAAAtcAT
hOFQXWeGS0tAazaS0tAayNFg1kXhSwugC6ADWpixN9UmLCxPVqUQWYRuVQBvUxYmy2uyRNmkJiw1
ylmYs1K1KAKoAugAoAAAAAAAAAAAAAMg5jfjTJd/hdREOY340yXf4Xh653HLy9WazuTpnOzxOotd
zG5Gmd7PE6eZdeoz/r8fP1otrapMg9+LgA1igDWIACaCxCqYkUllFxWZiw1MXhllKAFUWecIsaS5
0qEag50J1CfQOFSL6EWOiONAjUHOq0EaCMkxdJhQVkasnCLqC8KTFg0e/syr/UsR/Tfc8GKXu7Mi
2yv0v3OvRfEsf0Ae1oAAfDvPhRg7dzdEaRW+58++Mf7SZ74/3OHTdkSvFCw8iAAAAAAAAAAAAAAO
knEpxMDLTTpGDRTPtimLsvi2Xj8eD5OZ506ex9r6HC7xjQA0ANUUVYldNFMTVVVNoiNZkGN4MtVh
7E2ZjzFqcTGx6Ynrwxh3+0550+/c05LN5PZFM+/yGFw5iIm8eXqnir9kxHBTProlzDwdJd5VmgDA
AAEADQkTzUYAAAAAAAAAAAAAAAAJi7NrNAusizT0Q1QBpMImyzF9EImzcqAtro3K0ANJho1E3ZG0
WYRYlZi66ushaw00AAANaAAAAAAAAADIEcxqItCIaOV33/kff4XUzLlt9tMn3+F4eudxy8vVk3J0
znZ4nUOX3J0zvZ4nUPR1H+vx8/WtQAfQxQBWdAXhESzURYGsawAVQABlpJ1SpUAZILTqgxQCdRzp
F1hCNRxqBIsc4caVAHKwixKsrEslUAQAAAAe5s3zV+l+54b3Nm+av0v3OvRfE1x7X9AHtbAAH8d8
fwkzvx/uf2fx3x/CTO/H+5w6bsjPJ4oDyMFkmFASyWs0C6yNWSaRdQAUAAAAABvCxasHEiumecPY
y2cozFPKbVemJeIRMxN4m0unDneA6IeTldrY+VmJtRixHoxabw9jL77V5eOWydmYs9cXAmr73o/e
4rr+2S2fmdpY8YOVwMTMYs/i4dN/p6PUzOcym41Nc8eHnN4Yi2HRRMVYWTn8qqdKsSPRGkTznS0+
Bnt+tsZ3Le5aMzGSylpjyGUojCptOsXjnMT0mXgOfLpd93E1cTEqxa6q66prrqmZqqqm8zPWUB50
AAAAAAGmWoGaACAAAAAAAAAAAAAAAABMXAGRqYuzMWGtAGtML2XVBqVkFvfVJizcrWgDZgRNga1l
q90mlFirqog1a6TS1rWoAqgAABoAAAAAsQiERYmVmbMssjl99tMn3+F1Dl99tMl3+F4uudzy8vUN
ydM52eJ1Dl9ydM52eJ1D19Q/rcfP1q6AsUveIsQsRYXDDQBpoAAAAAASpUq0SpUAZSAGrLS6wj18
luznMxTFeNFGSwZ/3mZnhvyvyjX9T7adjbKysTx4+Pna7RMcFPk6L9JvefoT9HK9kTHNrPV1dONk
8Cu+X2ZlqKbaYsTi/PeVo2tmcCqZwq4won8WmiLR+ovQ2tfp1ylOFXVpRVPsgmiqjWmY9sOor2nm
cWZ4sWZv6ogjP48TfynP2Q53oP8A9MctMelHS4mLONN8SKa/VVTD5sXJYGLe+FFM/wA3k48ug5eF
Z/S8MehjbKmOeHVf1VPixMGvBm1dMw8/Lo+XHtisxUrI5JjQnEcUCYoXgEHubN81fpfueG9zZvmr
9L9zr0XxNce1/QB7WwAB/DfD8I878f7n93yb01+U29nKo53rcOm7IzyeUD7dm7IzW1sSacvh8VNP
OvEqm1FEeufQ8naw+IdLhbG2Zs+qYzOLXtHFj8XAngwr35xNWsx64s/tGcwcGK6cDIZXCpmb0zNH
FXT7Kp5u06LlWsrlB1UbTzNNNoxOXxY/ufyxcziY/wDCTFXtphr9m/8Ap+lzQ93Fy+Dja4VFPrpi
z4sbZes4dXzSxei5QyvPJi7eJhVYVVq4mJYcmWdBpJpGtQAUAAHR7K2Xkp3fpz2YwJzGLXmq8CI4
5piIpoon0fGlasvs2dNn2/TVOs6PlZsMc2OgnJ5GdMpb9LUnuLJf8N/aSv7XJceAPcryGVq0wZp7
5fxnZWFM8pqj5z9rkY8kf1zWFGDj10U6R1fycbMuIAAA6LZWzsl+4tObzGXnMYlWNNH8JNMRER6m
uPG8rkHOjpKsvs2dMhb9NU/nOTyM6ZS36Sp0/a5Ljn2o0e77iyX/AA0//ZL+deQy0/Bwpp7pk/a5
JY8Yer+5mF1q+l5c8pY5cLx7WbMQH3bO2LmtpxVXhURTg0zavGxJ4aKfbP3RzY7UfCOlwtl7KyMU
TiTi7RxeU1Ux+94frjrPo5v7e7MLDw6qMHI5XBi/vaow71090u06LlWv0uUHVRtPMxTaMTl04Y/u
fyxcziY38JMVR0mmGv2b/wCn6XND3cbLYONrg0U/Eiz4sbZdueHVf1Sxei5QyvPG8TCqwqrVUzEs
TLkyJxJM3BrF4jiQDGrjqs1ktlYGJTwZCasOuimuiqrHqvNMxeLvnqy+zp0yFv01Tr+1yp+lzpMX
e9OUyU6ZW36So9yZL/hp/wDsk/a5H6a8G9h7lWSycxyy8x3y/jVs3AmfexNPzn7XI/TXkTCPszuV
py808N5ier5JhzsvG5RADQWJQb1lZjohE2ezsHZuDmsDOZrMYflsLLxTTwcc03qqmbc46Wb47bix
4w6Wcvs2dNn2/TVP5VZTI+jKW/S1O/7fJrHPj3oymSn+Tf2klWRyc6ZeY75anR8k/TXgrxPWr2Zg
VT72Jp+e7583kcPL4E1xMzN7Qt4We8x8V4lOFC8ubK8KWlYqW66usjRaF1dZF4ThNNQ1asWNNSIs
okzZllJm4ADl99tMl3+F1Dl99tMn3+F4et9zy8vUXciLxnezxOos5jcfTO9nidQ9vUJ/1uPn61qA
D6KgAAAAAAAAABIAyE6vr2VszF2vnaMvhWpvzqrq+DRTGtU+qGWDZmy8fauPOHgxERTHFXiVzami
Osy6LLRlNi2jJU+WzUa5vFjT4lPo9upmMfCwcvTk8nTwZWjWqYtVi1flVfdHofI78ejk99dMf0xs
fEzFc14tdWJVPpqm7+YNqJUqToxVhTqrMatOdKAMVBmuiMSJiYiY6S0TCX3q8vNbO4YmrC5x6aXw
uis83aOTiInFoj40fe8XS9Dk/VxZrzwHkxnQBMUvL3dl+av0v3PCe7svzV+l+516Kf5Ef1Ae7GgB
MB5G0sacfPY1c6zU9d52VyEbQ2riUV1cGDTM14lfSmOnr9HzuHTS2RK+jY+xqczh+685NWHkqZtH
D8LFnpT98vTzWfqxqIwcKiMvlafgYGH8GPb1n1yxmsz5eqmKaYw8GiOHDw6dKYh/BvhwnCEmADag
AAAM4mFTi08NUXh5WbydWXm8c6OvR66VUxXTMTF4lz58JySzXgD++by85fFt+LPOJfweKzLlcxJh
RBkaLC66fZtf+x+DT0z+LP8AZ4b+DWzZ/wBnKKf+rxJ/qUMvd0fwx0gA6AADx9qUTh57EielM/TE
S+V6O8NPDtXEj+jw/wBnS858/l8VZAGQdNs6r/ZrDp/6iqf1OZdDs2r/AFHTH9NP1OvRfERQHtaA
AHgTrL33x7FyWHj5irHzFPHlcGb1UXtxz6Kb/X6nn6WbZIzyfVsnYmDh5ejPbRifJVc8HLRNqsb1
zPop9fp9D685tDFzs0xXw0YVEWowsOOGiiOkQxms1iZzGnExJvM8oiNIj0RHqh/F14cJxiyYANqA
AAAxi4VONTw1ReHk5zKVZeq+tE6S9lK6IxKZpqi8S58+E5GOeH9s3l5y+LNP4s84l/F4rMuVkAQe
9kMz7p2bhUz8PAmaO2ecffHzP6PH2bj+SzHDM+9r5T9z2Ht6K7xagA6gAD5NpYfHl+KPxZu8p0E0
Ri0zRNoiqLXlz8xaekvJ00y6xyJi7OjVzVwTWQmLC6o6jJYfuXdrLRNMcWZxasXivztHvbT9F3L6
uv2rh+5sXByvDFM5fBowqrTymYjnPz3enoZ/lqye98ROgPc2zGrSTCXmFlXtaN5stGR2dsyirljZ
mirM1R0o4ppo+zVPzw/vs7J4u1M/lsngU8WNmMSnCojrVVNo+t8W+208Lau8ucry83ymDMZbL2/+
LDiKKJ+eKYn2y5dLyyYxXhgPMxgAuoXlYqQUauMl5BoTiUBmdWp0ZkAABy++2mT7/C6hy++2mT7/
AAvD1vueXl6jW4+md7PE6hy+4+md7PE6h7uof1uPn61qAD6CgAAAAAAAAAAAJU6nI4P7k7Bop0zO
f/fK59NOFEzFNPzzEzPspc5lctVnM1g4FHw8WuKI9szZ1G2cWnF2ljxRbyWHPksO35FMcNP6ohvo
579JPe+IB6GgBmwH37P2FtDatM1ZXK4mJhxynFmOHDj21TaI+l9GRwMpszZdW2NpUxjYVNfk8vlJ
mY90V+m8/kx6foc9t3ezae8NVHurMzGXw+WFlsL3mFhR0ppjlDhz5zj7ktx7c7Cqw4/fc9kMKqJ+
DOZpqn+reHw41FGFVaMfBxPXRXEuaHC9JTddEPFy2dxMvMc+Kj8mXsYeJTi0RVTN4lrjynJWgGrA
JiKomJ5xIMjws1gTl8aqn0ax7H8nv7WyE17Fw89TEWwsfyFc/Gpmqn7NbweJ87nx/TysYsQXkWjq
54yj3dl+av0v3PD4XubM5bJ/S/c6dFP8muPa/qFy7246ABiBhxGFTiRTFpxJvVPXoCWAD0Nn7v7T
2rRx5TIZjHw728pRhzwRPrq0gHnj0cxsDO5WuaMWjDprjWny+HMx80VPgrw6sObVUzTPrYGQAAAA
AfwzuB5bAm3wqecPGdA8bOYPkMzXT6L3h5emnizyfwAedgAB0GzfMFH51X9igNm+YKPzqv7FA93R
/DHSdgA6KAA+DePztifJ4X7Ol5j0944/1tX8nhfs6Xm2fP5fFWUFmCzKI6DZnmWn5afqeBEPf2b5
mp+Wn6nXoviWdrQD2tAALHKSiYw8tRgURw0UzNU89Zn0z+qPmQM8QB6GQ2BtLadHHlcjj42He3lK
aJ4L/G0B549HMbBzuVqqpxMPDpqp1pjGomY+aJfBVRVRNqomPaDIAAAAAPm2hgeWwJmPhU84eM6K
0Tro8LN4M4GYxKJ9EvL008Ur+QDzoUzNMxMaxzdBhYkYuFTXHpi7n3q7KxeLBmidaZ/U79DcuLH2
gPWoAA8fP0eTzmLHWeLl6+b2Hn7WotVhV8ovE0/R/wD64dNN46zy7Hn6npCYu8bAkwsCj793cr7s
21lMO0VRFfHMTpMU++mP1PWzOL5fMYuJEWiuqaojpzfw3YweDD2jnJpvGFgxhxPSqubRP6paezoZ
nHXSAD0qALo9zdm2QwNrbYq5fuflKpwpibT5bE/e8O3riapr7JcDN783ZbxY87M3N2fkItGLtDGq
z2LE0c+Ci+Hhc/b5Wfnhx0Td5el5byxm33oLMI5yoANAArIA0DUMtAFgBOFGrmoMuX320yff4XU8
Ll994tGT7/C8fXO45eXqG4+md7PE6ly24+md7PE6l7Oof1uPn61qAD6CgAAAAAAAAAAAPV3Woire
DIzP4mJ5T/t999z7Jm83nV5+79XDtbAm9vhR/Vl970dH2LAB0sUAQa3yzdOLh7Hy2H73CwcpFU0/
z6qp4p+e0fQ5uJs9TamBXjcOJF6uGOG3qeW8XST/AC97NWY6IRNltfRxsZ7EejsnF+FhzPLWHnCT
/G61K6XDwcTGm2HRVXP82Lvqp2LtCuPe5DM1ezBqn7nIXnqvFPWfpbvSf/i67Knd3atc+92ZnJ9m
Xr/uf2o3Q29ifB2JtGr2ZTEn7nERiVdZ+k8pV+VVHzsfuf8A4mv0TObsbTyW4e38TP7NzeTwsHFy
2NTXmMCrDiauKqjWqI52xJfnLU1VTFpqmY9rNnHlf1XU0Ac8NHu7Mi+yv0v3PCe7svzT+l+516Kf
5LK/pwnCo9eN6lp6nNQw1L9X9MHBrzOLRhYVFWJiV1RTTRRF5qmdIiGHq5PPRu3sbH2pRXw7QxZn
L5O0zE0cvf4kcvRE2ib6zPRjl/jNH9M3tPZ25seTowMLam3Y+HONEV5bKz0iNMSuPTf3sdJ1cvtj
efau38WMTP57GzExM8NNVVqKPVTTHKmPVDzqq5rqmapmZmbzM+lLRLwcuV5drldOKZ9M/S1RjYmH
N6a5j52Jiw59nYj08ptHylUUYtomdKur73OvZyGY8vgc/hU8pejo+f6vdW5dfSA740AID49uYVpy
2La0V0cP0S+xnb9MTsrZ1VucVYlM/TEuXSz/ABS9jwQHicwAHQbN8wUfnVf2KA2b5go/Oq/sUD3d
H8MdJ2ADooAD4t4vOtfyeF+zpeY9PeLzrX8nhfs6XmPn8virne0AZQe9s7zNT8tP1PBe9s7zNT8t
P1OvRfE1x7WgHtbAAG8HBxMxjUYWFRViYtdUU00UReapnSIjqw93Z2ajdnd7N7biqKc/jVTk8hz9
9RVMfvuLEW/FpmKYm8Wmu8c6U5X9M2j+O0M/kN0aasvh4WFtPbcXpxa8WIqy+VnpTGmJXHpmfexO
kTq5ra28W09u4/lc/nsbM1RpFdc2pjpEaRHqh50zNUzMzeZ9KPBy5Xl2udurxTPpn6W6MbEw5vTX
MfO/mM9iPUymf8rMUYloq9E+iX2PA0exksfy+DEz8KOUvX0fP9Xurcr+4Du0AAPP27hRRmMGunSv
Difn9L0Hz7w4XBlNnV2+HRXz9lTl0vwleKA8TI+nZ2L5PMxE6VcnzETNMxMcpjmvG5dHRDOFiRi4
dNcemLtPotAAD5tp4fHk6piOdFUVX9Wn3vpSvD8th14drzVTMR7WeU3jYOfiVZWJfPc8UAR02Swv
c27eDen32ZxqsSKon8Wn3tp+fm/i+7auH7lqy+V4eGcvg0UVc+U1WvM/rfC+hwmcZHWdgA3oP75L
J4u0M5gZXBp4sbHxKcOinrVM2j9cv4Pc3Vxqdm4ue2vXyjZ2WrxcOeG8eVq95h/RVVxdsrbk0eDv
5n6M7vNmsPAr48plOHKYExVxRNGHHDEx7bX+eXPrVVNVUzOszeUfP3brksTcmEaibwoyA3GwBpmg
LENRCIWZskzZGsXC8gNY0ALgXcxvtN4yff4XTuX320yff4Xi65P9HLy9YlXcfTO9nidS5fcfTO9n
idQ9PUP63Hz9aQAfQUAAAAAAAAAAAB/bKYvkM1hYn5NUT+t7cxaZhzz2cljeXy8T+NTyl26O+Cx/
cWIuTDuqAJYD58fIYWPMzbhq60voGbJe0eZXsiv8TEpn43J/KrZmapi8YU1R/M999T2ByvRcamPB
rwq8ObYlFVE/zosxZ0kYtcRbim3S7+deHh4l+PCoqv6eGIn9Tneh/wDKn6XPD2MXZmBX8Hion1Te
Hx42zMWjnTMVx6tXG9HyiZY+MWqmaJtVExPrRyw0LyDOC3S8dATDF5Pc2ZaNlfpfueE9zZvmr9L9
zp0c/wAlk97+1xkerHTGhm9i8mJjRvnjxTi7PyVEYlNGWytF6a6r2rq99VaPRzmU4k39r8pvTnbU
xTTTMUxEeqIcOm7GeXuc+A8WM6sSWidEGLDB6GxrziYtP8y/63wRN9Xqbv03zWNH9DX9S8fdyiTt
faA9roAJYBtqP9R5Wf6aqP1BtvzDlfl6vqcel+Cpexz4kSrwuYADoNm+YKPzqv7FAbN8wUfnVf2K
B7uj+GOk7AB0UAB8W8XnWv5PC/Z0vMenvF51r+Twv2dLzHz+XxVzvaAMoPe2d5mp+Wn6ngve2d5m
p+Wn6nXovia49rQD2tgAD6N+M1TH7kbPw+OKMpkqJqpqvEceJfEqm3fa/qh87f8ApCiI3rzVNPwa
acOmPmohw6a/4s8nOAPIwAAS9DZFV5xafVE/rebMvS2HTxY2N6sOZb6P4o1HoAPe2AALvLFtj7In
rGL9pGt5vMux/Zi/bcul+Glc2A8TIAD1dlYvFg1UTrTP6n2vG2di+TzNMTpV717L29Hd4tQAdQWJ
tMIA8PO4fks3i02tHFeI9U84fxfftjD4cbDxI0qptM+uP/6HwPn8pnKxkiXpbv5T3dtnJ4MRxROJ
EzE+mI5zH6nmve3Vw+CNoZuYmYwcDgiYm0xVXNok4zbImPqzmPGZzWNixeIrrmYifRF+UP4g+g2A
APv27iRs3cvKZeKqfLbSzE5iunneMPDvRR9NU4n0Q+TAwMTNY+Hg4VM14uJVFFNMazMzaIZ/0gZ7
3TvBXlMOqqcts/DpyWFFUxPKiLTMW61cVXzuXS3OKVzYDyM0WlFp0bZSdQnmNxoAiLtxCIuszblB
M2RuQkAG8aAGsTQLStvWuJqOX320yff4XU2jq5ffeOWS5/l+F4euz/r8vL1gu4+md7PE6hy+4+md
7PE6h36h/W4+frVgA+goAAAAAAAAAAAA/vlMzOWxb60zymH8BZ7h0FFcYtMVUzemWpl4mWzdeWq5
c6fTS9TAzWHmPgzarpL0ceUrWv7IqOgAJgAIAAADODGLg0Y0WrpifW8zNZCrAvVT76jr6Yesascu
E5JZrnrR1OGX1bQynkK+OiPeVfql8jx3jZcrOFgvK8TOJ70e7svzV+l+54d46Pc2Z5q/S/c6dHP8
lna/qA9WNloThUTF1OF/DfKqZ3lz3P8AH+59D5t8fwkz3x/ucOlnujNePeJ1SwRNnjsZwF5T7UYs
TsHrbt883j/IYn1PJetu1/G8f83xPqTjP8o1Pe+wB7MaAGQNt+Ycr8vV9Qbb8w5X5er6nLpfgpXO
tMtRo+e50AEdBs3zBR+dV/YoDZvmCj86r+xQPd0fwx0nYAOigAPi3i861/J4X7Ol5j094vOtfyeF
+zpeY+fy+Kud7QBlB72zvM1Py0/U8F72zvM1Py0/U69F8TXHtaAe1sAAXf2eLenNz6qPswib9fhP
m+37MOHTdkZ5PAAnk8jAkykzcGsHqbv/AMNmPkpeW9Xd/wDhsx8lLfD4or7QHvaAAGt5vMux/Zi/
bZa3m8y7H9mL9ty6X4KVzYDxMgAETNMxMcpjm6DCxIxcOmuNKou596uysXiwaqJ1pn9Uu/Q3Lix9
oD1qAA+TatHHlIq5zNFX0RP/APQ8h7+PR5XL4tHWmbR1n0PAePppnLUo6bZ2H7m3bw5mJirM481R
Mfk0xa30y5l1+0sP3LGUylpicDAopqidJqmLzP64Oim8tI+IB7FAAezuvFOXzOZ2liW8ns/L15iO
KJmJxPg4ccv59VM/NLha65xK6qp1qm8u02pjfuVuRRhRMxjbUzHHNqv91h3iOXrqmr/thxTx9Ld5
YzQBzSi6QkarVLcSIA6xaLpBHVJm7pIkAHSRoCIut7NYz2lupfokzcaxcLyAuKOX320yff4XUOX3
20yff4Xh69/X5eXrEq7j6Z3s8TqXLbj6Z3s8TqXTqH9bj5+tIAPoKAAAAAAAAAAAAAALE2m8cpQB
9WDtDFwrRM8cet9mFtHCr5VTNE+t5I3OdhroaLYkXomK460zcmJjWJhz8TNM3ibT1h9GHtHM4emN
VPxvffW6TpP/AFdeuPPo2xXyivCoqjrHKZf0p2rh1a0VU+znC/ri6+wfzwsxh43waomenpf0a7QA
UAAYxsKMbCqon0w8GqmaKppnlMTaXQvK2zg+Rz1VotTXTTXHzxF/13cOlnilfEA8+IPd2X5q/S/c
8J7uy/NP6X7m+jn+RH9QHqxoAQHz75fhJnfj/c+h8++M23kz3x/ucOl7Ga8UXXRHlxNF1Qc7A0et
u1/G8x+b4n2Xlax63rbtfxzMfm+J9TMn+USdr6bysSqTD146qJEqzQNt+Ycr8vV9Qbb8w5X5er6n
DpfgqVzrUaMtRo+e50AEdBs3zBR+dV/YoDZvmCj86r+xQPd0fwx0nYAOigAPi3i861/J4X7Ol5j0
94vOtfyeF+zpeY+fy+Kud7QBlB72zvM1Py0/U8F72zvM1Py0/U69F8TXHtaAe1sAATfr8J832/Zh
WN+5/wBp832fZhw6bsiV4U+1mZB5GQAUeru//DZj5KXlPV3f/hsx8lLfD4oPtAe9oAAa3m8y7H9m
L9tlrebzLsf2Yv23LpfgpXNgPEyAAPp2di+TzNMeir3r5iJmmYmOUxzWXLo6IZwsSMXDprj8aLtP
otAALE2lz+NR5PFrp9ETMPfeNtGjgzVU/lRdw6ae7Ur+2wcnOf2zk8CIvxYkTMeqOc/U9rPY8ZrO
Y2LF+GuuZpidYi/KPofLulh+Trz+cmJtgYExTMeiqr3sS2dDPdpAB3UbwsKvHxaMPDpmquuYpppj
WZnSGHs7r0U4Wexs/iWjC2fg1ZqZnTijlR/XmkvuHkb95imrbU5PDmJwchh05WmYi15pj30/PVef
nc2/pj4tWNi14lc3qrqmqZ9cv5vnW7dYAGolWEWeUWR0kWBEXF0h1kTtSZAdZFCIuRFyZdJE7SZA
axQBrFAFxBy++2mT7/C6hy++2mT7/C8HX/6/Ly9YmruPpnezxOpctuPpnezxOpa6h/W4+frVgA+g
oAAAAAAAAAAAAOt2BVlstuz5evZ+UzeNObqomvMUTVMU8FMxEc49b+tW0svVHmjZsezBn+9ucLZq
440dXVmcvV/6bko9mHP97M42Xn/0/Kf/AFz/AHr+imOWHS4kZfEj+J5en4tMx975qslgVX/eqY9h
+imPDG8WicPEqpnlaWHNAAFiZibxNpens/NVY16KudURe/qeW9fd7LeWrzmJM2pw8G950mZqi0fX
9DfC5SPpGx6daYGuGDhPcMv573YMYVeyqo1xMlTVPt8piR90P68Mpv1RXgbWy2Vr1y+SwKeX86iM
T/8AI5dJn6UvY50LDysD3dl+af0v3PCe7svzT+l+516P4ll97+oD0tgAD5t8fwkz3x/ufS+bfH8J
M98f7nDpexK8Zdfag8tjILrHrRixIPY3a55vMT/0+J9Tx3r7s/xvMfm+J9TMn+UV9YD0NppKpUsa
M1Q235hyvy9X1BtvzDlfl6vqcOmn+FSudaZjVp85zoAI6DZvmCj86r+xQGzfMFH51X9ige7o/hjp
OwAdFAAfFvF51r+Twv2dLzHpbxeda/k8L9nS818/l8Vc6CXOJkV72zvM1Py0/U5+Zu6DZnmWn5af
qdei+JZGgHtbAAGN+/wozfso+zDbG/f4UZv2UfZhw6bsSvAAeRAAB6u7/wDDZj5KXlPV3f8A4bMf
JS3w+KD7QHvaAAGt5vMux/Zi/bZa3m8y7H9mL9ty6X4KVzYDxMgAAAPV2Vi8WDVROtM/qfa8bZ2L
5LM0x6KvevZe3orvFqADqDz9rUcqK/megxj5Wc3g4lFMXrimaqY9MzHoY5zeNhX07Mo9y7sRNpiv
NZiZietNEWt9Mw/i+vO/vOBk8rF/3jBimqP5085+uPofIvCZxkABoHpbQxv3L3KqiJmMbaePblP+
6w/V66pn/tefRRViV000xNVVU2iI9Ms7649P7q0ZLDqirCyOHTgRMRa9Uc6p+eqZculucUvY56pC
dR44yERzF0huMpM3kB1kapHUWeUWR2kIERcXSHWJSZ9CA3FAG8AC1xNBYpWy4Yy5ffbTJ9/hdU5b
fjTJd/heDr8/63Ly9YYbj6Z3s8TqXLbj6Z3s8TqV6h/W4+frVgA+goAAAAAAAAAAAD2tiZv/AMlm
srM61UY1MeuLxP2o+h9LwMvjTgYtNcejX2PepqiumKo5xMXh34X3YsUB0UAB8WeyXl/f0fD6dXl1
UVUTaqJifW6FmvCoxPhUxV7Yc+XDTHPDoMPKZSJ/fMtFcdIqmn6n96YyWDVTVhbPwomP/lmcSJ+a
WP0VMeDkdnZnaWN5PLYVWLV6ZjSPXM+h0c4eFszIe4MGqnFrmvjx8anSqr0Ux6o5/TLWPtPHx8Py
UcODg/8AxYNMUU/RD5G+PHFwAdAAB9+wdl17a2zk8jRMUzj4tNE1VTaKYvzmfVEXn5ngbzbUo23v
DtDPYUVU4GNjVVYVNWtOHe1FPzUxEfM6rDx6d291M7tCqqIz+0aaslk6J1jDmLY2L9H73Hx6vyXB
OHO+/EoA5oPd2ZF9lfpfueE93Zfmqflfub4dpH9eE4VHo1pm0o2Low+bfL8JM98f7n2Pk3y/CXPf
H+5x6XsZrxQHloRNiY9Isc4sxUqPX3Z/jeY/N8T6nkPX3a/jmP8Am+J9lmdqx9YD0VonRKdFSliq
ptvzDlfl6vqDbfmHK/L1fU4dN8FSudjVpmNWnzXOgAjoNm+YKPzqv7FAbN8wUfnVf2KB7uj+GOk7
AB0UAB8G8fnav5PC/Z0vMenvH52xPk8L9nS8x8/l8VZAGQdBszzLT8tP1OfdBszzLT8tP1OvRfER
oB7WgABjfv8ACjN+yj7MNsb9/hRm/ZR9mHDpuxK8AB5EAAHq7v8A8NmPkpeU9Xd/+GzHyUt8Pig+
0B72gABrebzLsf2Yv22Wt5vMux/Zi/bcul+Clc2A8TIAAABEzTMTGsOgwsSMXCprj0xdz71dlYvF
g1UTrTP6nfoblxY+0B61FpqmmYmJmJj0wgC1VTVMzMzMz6ZQAAAelsCKMLO1ZvEt5LJ4dWYm825x
8H+tNLkcxjVZjGxMWub111TVMz1l1G0MWdnbqzHOMTP41v0dH99UzHzOSq0eTpbvLGL2oA4wospG
o6xIEai6Q7QQB2kVYSeazyiyOkIANxQFiFZ7SIUGsUAVRy2/GmS7/C6ly2/GmS7/AAvn9f8A63Ly
9YlNx9M72eJ1Ll9x9M72eJ1B1D+tx8/WkAH0FAAAAAAAAAAAAHobOzkUfvVc8vRPR54suXR0Y8vK
bRnDiKMTnT6Kuj0qK6cSm9MxVHqeiWVpoBoAAAAAAAWiirErimmmaqqptFMReZkEersXZODmaMXO
7QxZymyctEzjY8Rzrm3LDo611aerWeT+37kZTYWHTmNv4tWXi16Nn4U/+YxeXK/5EeuefqczvBvN
mdv1YWHVFOXyOXvGXymFyowon65n0zPOXPlyzsNfz3i29i7w7RnMV0Rg4NFMYWBl6J97g4cfBpj+
/wBMzM+l5YODIAA93Zc/6rmP6X7nhPX2VXfK1UdKrt8O1Y+wB6FAAHzb7U8G8+fify/ufSn+kbD8
lvltKnpifdDj0nYzyc2A86QI1BiqTq9bdurhzeP68DEj9TyqtX27HxfJZuf51FVP0wzO2JHqAPQ2
JGsqkay51VXbdP8As9lav+oqj9SPp27h23RydfXN1R/VcOm+CpXKRq0kSr5rnQAR7+zav9RUx6fd
Nc/1aFfLsvFvkpw+mJNX0xH9z6nu6P4Y6TsAHRQAHwbyxba9cf0WF+zpeY9je2ng25XH9DgT/Y0P
HfP5fFWQBkHv7Mn/AFPTH9LP1PAexsrEvk5o6VXdei+Ij6gHtaAAE3/o4N6s5TPSj7MK+r/SnheQ
33z9HSMP7FLh03YlcmA8iAAD1NgTbGzHrwpeW+7ZFfBmKv51Mw3w+KD1AHvaAAH9N56bbC2LV1jF
+2/m+3e7C4d1d3K/yox/2jl0vwUrkAHiZAAAAH07OxfJ5mmPRVyfMRM0zExrCy5dHRCUVceHRX6K
oiVfR7WgAAABqiirErpppiaqqptERrMsvV3cw6aM7XnMSInByOHVmar31p+D/WmDsHk7549P7qUZ
LDmJwslh04ETEWiatap+ebufq1f1zGPVmcfExq+dddU1T7ZfxfOt26wALEqxpKLOkQjtFgSRqO3F
IEaixyi7tCpM3kBuNADaUiLtJSrUIAKoAA5bfjTJd/hdS5ffjTJd/hfP6/8A1uXl6xKbj6Z3s8Tq
HLbj6Z3s8TqTqH9bj5+tIAPoKAAAAAAAAAAAAAAP6YWNXgzeiqYfzAelg7W9GJT89L7cLMYOP8DF
ov0qnh+t4A6TnYuupjKY1XwcOqv4kcX1M15bGw/h4VdHxqZhzdGLXRMTTXVTMaTEvqp2zn6dM5jR
7K5a/cNes1h4VeLNqKKq56Uxd5Mbf2lGmezEfpJbjeTatOm0czHsxZP1w10FGwNp4kRNOzs1MTpP
karfTZ9VW6mdy+JTTnK8rs+Ji98zmaKZj20xM1fqcfm9sZ/PW90ZzHxraceJM2fLVXVXN6qpqnrM
3T9w12nFu7s+nize08bP18Mz5HIYXDTf0R5SvT/tl8mZ39xMtTOHsTJ4WyKJi3lqff5iY+UnnHba
HKDF5WpreLi14+JNeJXViV1c5qqm8ywDIAAAAPQ2dmcPAw64rq4ZmejzxZcuj3sPN5bEm05iij11
RP3Q+qmMnVrtPK0+2MT/AAOXG/11ddV5PJf82yf0Yn+B/WjK5GvXbeQo+N5X/LcgH66a7SNnbPmP
wi2XHt8v/lPL/wBIWeyu0t8NpZjJ5ijNZavE95jYcTFNcWjnF4ifphz6VMcuWpagDmkAGFWp/bI4
lOFmKaqptERPN/GpGNy6ke3TnsvVNvKxT65iX1Yc5SvXaOWo+Nx/4XNRqF6WxbXVeSyf/Nsn/af4
GqMtkqp57ZyNPt8r/gcms6Q43puRrsqdnZCqOe8OzKfb5b/Lfz3oxsjg7tZLJZfaeWz+PGZqxKoy
0V2pp4bc+KmlyA48+lvKZTdWnVUpV52aEzYZnUI+/ZuYw8GiuK6uGZl9+Hm8viTacxRR66on+54I
68elvGY3rqKKcnVHPaeVp9vlP8LXksn/AM2yf9p/gcqNfvcjXXUZXI167byFPxvK/wCW/tGzdnz/
AO4tlx7fL/5Tiw/e5Gva3xxcvjbfxpy2Zw85gxhYNEY2DxcNU04VETbiiJ1iY09DxQcbduoAID79
nZnDwcOqK6uGZl8A1x5fpuwe9h5vLYk2nMUUeuqJ+6H00U5OqOe08rT7fKf4XMDr+9yXXVeSyf8A
zbJ/2n+B/SjK5GvXbeQo+N5X/LciH73I12kbN2fMfhFsuPb5f/KfJ/pO2nk9r765/M5DM0ZvK1cE
UY2HExTVaiImYvETrHphywxy6S8plQAcwAAfTkMWjBx+KueGLavmFly6PcpzuXqm041NPrmJ/ufV
hzlK457Ry1HxuP8AwuZHb97kuuq8lk/+bZP+0/wN0ZfJVa7ZyNPt8r/gckH73I12dOztn1f+4dmU
+3y3+Wm+2byE7v7AyWU2jl9oY2XjGnFnLxXajirvEe+pp9HRxozy6S8plTQByAAAAAAHv7Njj2RT
XOtGLNEeuLX/AFfe2/v5GMpsjZ2Dw8OJVRVj18/yptH6qYn538Hv4fDGgBsAAHo7Uxp2TuhRhRen
H2ni8UzfXCo5R/Wu+XI5PE2hncDLYVvKYtcURfSLzrPqfw332jh57buJhZeqZyeTpjLYN5v72nlf
55u49LyzjiXsc/OjJMjxxmBGoscou6REnUB2i0jSRZ0iEduJBZ0hI1J1dYniAOkaAFZrURaAGo0A
KAADl9+NMl3+F1Dl9+NMl3+F8/r/APW5eXrEpuPpnezxOoctuRPLO9nidPxSnUL/ANbj5+tTWhOI
4n0NXVE4jiNNUTihbmgAqgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADM6tTyZZrNAEWBGotLFEnUB
zpCAjSRxqeIs6Qi1auNKgDlVi0qlOispRmWp0ZFgAKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA6fK
bH2TTsfZ+YzVGcqxsxRXVVODjU00xbEqpjlNE+iOrXHjeVyDmB0+JsrYU/AnaNPqqqw6vuhmNlbF
pvf3fX6orop+6W/2uRjmns7D2FOainO5uKsLZtFXOvScWY/Eo6z69I9Pr9LAq2dkYpnL7MorxY5x
iZyucaf+20Uz89Ms5vO4+exIrx8Sa5iLUxpFMdIjSI9UOnHoffvJcXPZyrP5vEx66aaZrnlTRFqa
Y0iIjpEWj5nzg9KgAAPr2VszH2xtDAyeXp4sXFq4YvpEemZ9UReZ9gPT2VXRsHYG0Nt4sfv1UTlM
lE6ziVR76uPi0/W4GZdFvntrCz+cwcjkqr7N2fTODgzE3jEm/v8AE7p5+yznJl4ek5fqrF99QBiF
FnoR1R1kSBEXkWOUXdoJOoDtFWEWdEdIQAbihGotLTKgNNAAAADlt+NMl3+F1Ll9+NMl3+F8/r/9
bl5esSs7k6Zzs8TqHL7k6Zzs8TqGeof1+Pn61MAHvXAATAAMC8gC8S3ZFNaGbrxLq6oXFUAAAAAA
AAAAAAAAAAAAAAAAAABJkQmUBhO0AStC6QiyxUqARq50WdIQnUcKkI1J5rGkyjjSgDnVajQBGUq0
RakGoACgAAAAAAAAAAAAAAAAAAAAAAAAAAAAADqoq4tg7HjphYkf2tblXRZfF49k5Gn8imuP69Uu
3Q/EsAHsUAAAABvCwq8fEpw8OirExKptTTTF5mQZiJqmIiLzPKIh7O2sz/4M2Vi7PoqmNt57D4c1
Fv4tgzaeD41UWv0h/TOYuX3EoviVUZneK3vMvaKqMlP5VfomvpT6NZ6OEzGYxMzj4mNjYlWLjYlU
1111zeapnnMzPV5uk6T/AOYzb4P5zKA80TsAXSHSRO0nogOsi9hHMlY5QjrIkCOcixyh2i1J1AbU
AbSjUaMtLEgA00AAAAOX340yXf4XUOX340yXf4Xz+v8A9bl5esSs7k6Zzs8TqHL7k6Zzs8TqLOfU
f6/Hz9aQC0lnu0ABQBdABdABdQAEwImwCNRNxlYldXVC9xpoAAAAAAAAAAAAAAAAAABJlEWZsyCI
AIsAIi7NVY5RdCZuOdZFjlF01WXK1agEauNpFnlEQhM3kcqgtOqLGjmtUAZSrVCdQaABQAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAB7OzqpnJ0R0v8AW8Z9OXz9eXo4IpiYdOj5TjdpHsj4MPa9N/3zDmI6
0zd6GX2nseY/f8TPUz/R4NE/XXD1fucf/WtQfV+6G7vDP7/tS/5th/5j+E7W2Rg41NVOHnM1hxPP
DrinCmY9sTVb6D9zj/6mxhrDw68WrhopmurpTF5f1q3r2fl8x5TKbDw6qJiY8nn8xVjR/Uiibvmx
N99r+Tpw8tmKdn4dN4p9xYdOFXETrHlIjjmPVNUs3puPgfqj3f8AwzVkKKMbbWbwtjYFXOIx7zjV
Ra8TThReqYn0Ta3WYfDn98svs6irL7u4GJlYmJpq2jmLe6a4/mxF4wo9kzP870OTrqmuqaqpmqqZ
vMzPOZYmbuHLpOXJnbVqqmZve8zrMoDlh2ALEeluRCI9MpM3Jm46SKERc1WeUWdZE7UmbgO0ikRc
ldI9aOkSADcaAFZq0qRygaiwAVQAAABy+/GmS7/C6hy+/GmS7/C+f1/+ty8vWJU3Jm0Zzs8Tp7y5
fcnTOdnidQ4dSv8A1+Pn61MLyXkHt1cXiLx0QXUxeRbpKBp7y0hdeJrTUF5T6ksuroAuqALoAKzg
sVICNCRNlibta0AKoAAAAAAAAAAAAEzZmZumpqzUgMsgA1gAypqs8uRp7UYtZ7QCIc7VXSEJm45W
p2i6QkQTN3K0oA5VYNJTCspQkJm0CMgDYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFltzE1LLEWl
QTQC4gkylwXABcUBdG5E7SI9MpM3Jm46SL2ALp7XSRO00hAdZFCCIuTLpInaTNwG2gBpAiLyNRFl
SADTQAAAAAA5bfjTJd/hdS5bfj+Rd/hfP6//AFuXl6xKbk6Zzs8Tp7R1cvuTpnOzxOoePqlzoOPn
6oWjqW9YPZp7yxaQP1GgXkvHRr9RoLaOqWldXQuDUpi3vqW6INanvAv1LdGtXQBrVAGkABFibqys
SumqF7jTQAAAAAAF4Sak1NWZskygiaAIYAGqARF2dUXT2mmiMWs9oBqxapEXJn0LPJHK1AFjlzc7
V7CeUWQHK1kBaWK0ugCMiVKzIsABoAAAAAAAAAAAAAAAAAAAAAAAAAAAAF4V0E1OEsoJoAIF7JNS
C4TNwDFAIi7ciaEQvKEmbtSGLfogOki9gRFy3UmXSRO1b20QHSRewIi5EXWZ6NyJ2kz6IQG8UAbi
gAwsRzUiLDUaAFUAAAAAAcrvvN/cff4XU1S5bfbTJd/hfO6//X5eXrGabk6Z3s8TqLOX3Jm0Z3s8
TqLy+f1W/wCnj+eJpYLyXl6tNBeIvHRdNQXkWX9S+5AsNaYXW0Sg1KnYWsESurcq6hexMWG5Q1Ji
wRLcqdgFr6DWqANaoAqYFwEXiOJBTV4jiQDV4kBAADAA1QBNUBbWZ1CISZ6EzcZtTtANWLVF09pp
7Uc7UAHO1SIuTN1nlFkcrUAGKsGoiyRqrKUAEJZanRkagAKAAAAAAAAAAAAAAAAAAAAAAAWuAWus
QompFKgMgAAEzYCZszM3NQawAaw0CIW9tGpE7S1tUmQdJF7AFtZuRNSIuuiTI6SGADcii26miTN2
5E7SZAaxoAakQAVBqIskQqxYANKAAAAAAAkylRJcvvtpku/wuocvvtpk+/wvndf/AK3Ly9Yybk6Z
zs8TqHL7k6Zzs8TqHzOrX/VPzxaAHp0wAXTABdTC8rylBdFsgt+rUpqBboNyqX6rbog3KnYC6+1J
izpKouuqDcphMWCJsuremoFrDSgC6ABoAGgAaACAC2TURYjqXiNEvdNTVv0QGdMAIhi1SIut7aEz
0RztQAYtWC6QRHpSZu52pQBikAGa0saKCMAAJKNToyNQAFAAAAAAAAAAAAAAAAAAAAAWKREiLtRF
gE0AEAAASZAmUAaAG5EtFtbU09qNyGEzcB0kNCIXT2pM3bkC/QB0kXsAiLryhvE0sX6INYuADSgD
SAAyLEWIhVxqQAaUAAAAAAAAmbMrVKMs0cvvtpk+/wALqHL77aZPv8L5/X/63Ly9YeC7kReM52eJ
1NoctuPpnezxOpfL6v3U/PFC0Jwwo9InCcKgus2kaLXDWReFJiwoAumF7LeJ1QblTsJiwRNlt0bl
NQiQdJTC3QF5T7W5TUCYsOkqkStonRBrUwtYLyt/U1pqC8pLR1NXUFtHU5GmoLyL9DTUtK2tqkzc
TUW/RATTABnVAiLrezFppEW1SZuDNrIAxrUgRFxrSGLSpVKAxWQBlqADKtADAABOjLUsjUABQAAA
AAAAAAAAAAAAAAAGoiwiRFlAZAAAAASZAmboA0ANxLTVZ5GketG5CAERd1kLSIut7aJMjpIYARF3
SRdFtEF7aI1IhM3AaxoAawAFZ0BYgRIi7URYGsawAVQAAAAAAAAEnRKiTzAZQcvvtpk+/wALqHL7
7aZPv8L5/X/6/Ly9YtXcfTO9nidTMuV3J0znZ4nUPmdX7qfnimNXhLoPSuNXGQTGhlbhihEgiTCT
FmgXWRZpQUAalTF1SYsF+rpKaBMDcq9pEra+iDcqdgLE9UtfRuVdAsNaoAupgAumACaACaoFl5Qm
pqWuvKDiRi1NJm4CagAy0AsQzRYiyVSrM6sMgCUAGVgAzWljRWYmzQzQAQSYUBkAbAAAAAAAAAAA
AAAAIgBYi62sDOgAgAAAACTILM2ZAaAGiixHpRam5GUmbgOkjVIi6z0NIR1kSAERd1kWkRcmSZG5
CADeKAKmgEQJ2hENWFwwtYBpoAAAAAAAAAAAASrVWZ5pUoAykHL77aZPv8LqHL77aZPv8L53Xv6/
Ly9YtNydM52eJ1Dl9ydM52eJ1D5vV+6n54kAHpUAAAAIkBGhlYm4mKTFwEZtYaSYsNagDUphE2Xl
KDUrILfqTDcrWoA3KYXlbx0Qa1FtBZBdNXhOFLl101eE4UuGmryOJBNQvICaACLgAmtADILGiNRF
oSpRmYs0kxdllAAAGQARoWJQZGgBkABJi6NJMCyoANAAAAAAAAAERcAiLrEWUZ1OFQEAAAuk1Apd
m4Li8SXkBQBcUAVABYytMJM3WeUI6RYEcxYdIVJ1Adoos8oSNSdXSJ4gDcaAGmaERciLtKYRFgFx
oAUAAAAAAAAAAAAAAJ0ZWrRGazQBKo5ffbTJ9/hdQ5ffbTJ9/hfO69/X5eXrCm5Omc7PE6hy+5Om
c7PE6h83q/dT88SAD0qAAAAAAAA1EjMTZqJuM2AAiTCNJMC6gC6oRNga1F5SkxYWJa01BbRKTFm5
V0AXQAUwAEwAFwAFAE0AEAABYlBEaE4liboiTCNJMXREAAAYWACVpYlWWolGaACAAEwnCoLrI1Yt
yDWRqI5FoF1kaLCazZYpUDSwAgAAJxJcXF4kuBi4ALhoA1iaAGGgBhoAuILTCRF1nlChM80BuNCx
pKL+LLpGUAdo2tKLSjpGYANxoAjVWWrWAajQAoAAAAAAAAAAAAAAAAlSLVqjDPiAJWhzG+/wcl3+
F07mN9/5F3+F87r39fl5esSpuTpnezxOocvuTpnOzxOofO6v3U/PEgA9KgAAAAAAABE2ARoSFGQA
EmEaSYFiALK0ANMmjUTdkaRZpRYlZi66ushMWGlABQA0AAAAAAAAAAC4AsTdWViWcZwmLo0lUIiA
JQAZagAyrWozE2aGQAQAAAAAAAAAACZszM3FxZqS4GKANYaAtratYiFpW9tEvLUhi29ZyQXFxbx0
Lx0QXDFvByQTDF5LyZDDF4k1AABuKLGkotLUYQB1jZGpITq6xmADcaAFZrUc4EiVaigCqAAAAAAA
AAAAAAAAAzOoTqMMgCVojVzG+/8AI+/wunjVy++/8j7/AAvnde7jl5esZpuTpnOzxOocvuTpnezx
OofO6v3U/PFYAPSoAAAAAAAAABGrTLUSM0AEAAZnlIswg0ANAArIsTdCJtLQ0kxZTVVZCYsNNAAA
AAAAAAAAAAAAANRIy1E3ZsZsZmLDUxdlEAGaACNhE2BkaGYmzQyACAAAAAJNQKk1JM3BrABcAFt1
axEW0RqX6I3IYt0BuRQLFmsTQOXRb+prD3oLxF/UYYgclt0TBAsJhoAi6ABRadUGoyTqLUjpGhdY
RY6OkSoA6NADSUjVplqNFiQAaaAAAAAAAAAAAAAAAAZnUBhmADNaWnVy2+38j7/C6mPS5bfbTJd/
hfO693HLy9YzTcnTOdnidQ5fcnTOdnidQ+f1fup+eKwAelQAAAAAAAAABaUIkRoAZAAJ5stMiwAW
NACs0AbRoAGZ1AbbAAAAAAAAAAAAAAAAFp1QRGmZizUaExyZZZASgAysAEsaCJsCDUTcZLjONCcR
xBil2Zm4GEzcAaAGktCIuRF1mbcobkZOUIDcjXYBa68o9bpInakRdeUJM3G5FwuA3IAFpXDQLSGG
gCYqxJa+iDFiYC6pMWZxkAZABYLrSi0pOrcWBoDpFqyi6wjcIAOkBadEWnUSKA20AAAAAAAAAAAA
AAE6BOiUZAZZgAzWiNJcvvtpk+/wup/Fctvtpk+/wvnde/r8vL1jNNydM52eJ1Dl9ydM52eJ1D5/
V+6n54rAB6VAAAAAAAAAAAAagSlRgAAZnVpKhYgCxoAVmgDaNE6EaAMhPKRtsAAAAAAAAAAAAAAA
AABaVZaibs1mpMWRqYuyiADNABGpQBMUAQAAAFwAFS0Ii5EXWZtybkZJn0IDpI12BEXIgmXSRO1b
9EB0kUCIut4jRuREsvKEvcaxcXilLyC4F5XiQMFtE6ILE35SziYgTFhmxYLrCETZzsKCzHJGWQAF
p1KtUjValixAHSNLHpQjUnV0jMAG40EahGqs+LQDbQAAAAAAAAAAAAAAToJUlSoAykAGWl/Fctvt
pk+/wupq9Dlt9tMn3+F87r39fl5esZNydM52eJ1Dl9ydM52eJ1D5/V+6n54rAB6VAAAAAAAAAAAA
IaZajQZoAIE6ADITqDYA0lAGoytOqstRN1EqRqecMtRqACqAAAAAAAAAAAAAAAAEagDSVQRN1YYZ
CYsAAMgAjUoAKAGAAJaAsR6WoyaQhPMdJGuwIi4s8uTpInakzcB1kUW3UiLc5SZu6SJ2kzcBrGgB
rAAVNADAAZVY58kFnqxWUAYrSxKTFpImyzDnWagCIRqtWiRq1OgMgOkbI1J1Fq1dIzEAdI0ARqrP
i0A20AAAAAAAAAAAAAAJVqrM6pUoAyQAjViqtWrlt9tMn3+F1E6uX320yff4Xzuvdxy8vWM+BuTp
nOzxOocvuTpnOzxOoeDq/dT88VgA9KgAAAAAAAAAAADUTdkjURoAZAAJi7LSTAsQBY0AKzQibA2j
RMJEqDIswjTQAqgAAAAAAAAAAAAAAAETZqJuyRNkqVqebOjRMXZZZAAAZABGtAA0AVkjmsyUpOrc
WADpIVY5RdFnojtIsCIFno6REmbgOjQA0gCxSJ2oWasLhjI1MXZAASqLGkoRqxSgSOdINRPJlaXO
lSYtIsxyRlkjVZ0KYKlixAG40LVqi1aukZiAOkaCNQjVWfFoBtoAAAAAAAAAAAAAAmbMrVKMs0AZ
qix1RZ5QxSo5ffbTJ9/hdQ5ffbTJ9/hfO673HLy9Yngbk6Zzs8TqHMbkc4zvZ4nTvD1fup+eKwAe
lQAAAAAAAAAAAAAFibyrMTZqNBmgAgTFwBkWYQaAGgAVkWJQaGkmCJUGQnUbbAAAAAAAAAAAAAAA
AAAWmVZWJZsZsJhGkmERAEABkAAAWmGoE8oRZnmjpGoLCL+K6REAdopAegdIQAbigLTCs9qxFgGm
gBQZnVpKtUqVAGSADFUnUWrVGKzAjUHOtNFoBhgSdVZnmsWADpGhatUjUnVuMwAdI0ARqrPi0A20
AAAAAAAAAAAAGhozM3SoAMpABmtEakzeVjlCMWs+I5ffbTJ9/hdQ5jfaOWS7/C+d13uOXl6rTcfT
O9nidTOjl9x9M72eJ1DxdX7qfniyyE6j0tgAAAAAAAAAAAAACxNkBGhIlRkAASYUBkWYsg0ANAAs
ZGom7JE2aGpi7OjUTcmLrKsrIDTQAAAAAAAAAAAAAAAAACxKsrE3ZsZsJhGmZiyIAAAJgNaQzEXa
nRRkB0jQs6Qi1aukSIA7Ras+hCdR0gANlGoZjm0sSADTQAAlWqpVqlSoAyQAYqrVqi1aoxWYAMVp
qNAjQc2CdGWp0ZajUAG4q06pOq06pOrpGYANxoI1Fp1VnxUBtoAAAAAAAAAAL2SZRnU0mbgInaAJ
aoRFxZ5RZmlSZuA52kIi7mN9+fuPv8LqNIctvtpk+/wvndcv+nl5eqVrcfTO9nidQ5Xcjl7s7PE6
p5Or91PzxQnRlpJiz0rEAGgAAAAAAAAAAAAABYlARoIm4MgADMxZotcVkAjQA0lAGoyRNmmViVCY
RpmYtKxYANNAAAAAAAAAAAAAAAAAANRNxlpms1mYsNTF0mERAssQCxFoSdVZnmsWADcWhOpGpOrr
EgRqDrCk6hOo6RQBspGrTMatNQgAqgADM6tMzqlSgDJACNWKq1aoTqMVmADFaajQI0HNhKkWpGo1
AB0KtPpRY0lG4QAbii06otLTMUBpoAAAAAAAASZSZuMs6AIYAJa0AscubNqGketDUYtQIgjmsz6H
K1akzdy++2mT7/C6hy++2mT7/C+f1vueXl6obk6Zzs8TqYly25Omc7PE6iJ5vP1fup+eJ4NE6A9K
MhMWBsAAAAAAAAAAAAAAAAaibskTYStADIABMXZaSqBYgCxoAVmhHIG0aSY5ESoMhMWG2wAAAAAA
AAAAAAAAAAAAiQBoSJVhgABKtEJm8jUagA3Ckak6kak6ukSADrFpOoTqOkABso0y0sSADTQAAzOr
TM6s1mgCLAjUI1YoTqAxSADnVaAYYSrVFqRqNQAdCr+Ki/io3CADcUWlFpaZigNNAAAAAADMzdZl
GWbQBDABLWgF09rNqGiagxagC6OdqmiA5WoOY33i0ZLv8LqI6uW33m/uPv8AC8PW7/q5fniU3J0z
nZ4nUOX3J0znZ4nUOXV+6n54rGo0EpV6GUqhGmRqAAoAAAAAAAAAAAAAAABEtMrE8xKoAyAAzMWG
pjkyNADQALGSJs0y1GjQlSNTF2Wo1ABVAAAAAAAAAAAAAAAAAAGonkyIjSTNiJsl0xMAGmgBpKRq
tWqLU6RIgDrFqz6EX8WEdIQAbgNRoysaLEigNNAADM6tMzqzWaAJVgRqEasUJAc6QI1CNWKNAMMp
VojU6MtRqADpBY+Cix6UbhABuKLSi06tMxQGmgAAABJkmUZrNoAhIAJa0AuntZtQ09qAxagakRdb
20c7V00QHK1AiC3pkmbudpSZu5ffbTJ9/hdQ5ffbTJ9/heLrPdX88Q3J0znZ4nUOX3J0znZ4nUJ1
bup+eJCNWmWncozOrSVBEAGgAAAAAAAAAAAAAAAAibADQlMqMAADMxaWkqgWIAsaAFZosSg2jTM8
paSpYsQBpoAAAAAAAAAAAAAAAAAAAAAAAAAaSizpCL+K3GUAdY0v4qLGko6QgA3FFp0RaWmYoDTQ
AAzOrTM6s1KAJSBGoRqxQkBikFp1RadXKlUGb82WWmWkmFixAHSNLTqkkcidXSMwAbjQRqCstCRK
tNAFzUEmUmRNTQBDABLWgF09rNqGntQGLQIi5EXJlytLSZ6AOdqYER1W1tU1c7TSZuA52kg5ffbT
J9/hdQ5jfeLRk+/wvH1nur+eK1NydM52eJ1Dl9ydM52eJ1DXVu6n54pBqNGWo0d1olSpVoMoANgA
AAAAAAAAAAAAAAAADTKwJVAGQAGQmOYNADRQBqMrE8lnRmNWlGQkbbAAAAAAAAAAAAAAAAAAAAAA
AAAGogsaIselqMoA6xtYQjUdYzABuNC06oRqrPi0A20AAMzq0zOqVKAMkCNQYqk6hOoxWYLTqi06
udWkyi1IwysSVaI1E3BkJiw6RsXWEIm0txmgTFhtoAbQLgJgAGAAuACaoRFyIut7aMWppogMWgRF
yIuTLnaWkyA52pBdDRNXK0tAHO0kCIuNRFmV0iLOX340yXf4XUOW340yXf4Xm6x3V/PFlNydM52e
J1D8vibLxT1ePo+tft8Jxwfp7UaPy689ZLz1b9s+X6rr9RJ0fl156l56ntny/VH6ePzC89ZJmesr
7Z8v1XX6ePy+89VvPWU9s+X6mv08fmF/XJxT1PbPl+pr9PH5heesnFPU9s+X6mv08fmEzN9Z+kvP
WT2z5fqa/Tx+YXnrJxT1X2z5fqa/Tx+YXnqXnqntny/U1+nj8w4p6yXnqe2fL9TX6ePzC89U4p6r
7Z8v1NfqA/MLz1OKesp7Z8v1Nfp606vy+89S89V9s+X6mv1Efl156yXnqntny/VH6iPy689ZOKes
ntny/UfqFSPzDinqXnqvtny/Vdfp4/MLz1kvPVfbfl+pr9PH5heepeep7b8v1R+nxq0/Lrz1lLz1
X275fr9h+o1ao/L7z1W89ZX275fr9l1+nj8w4p6ycU9V9u+X6/Y1+nj8w4p6kVT1k9u+X6/Y1+nj
8wvPX9ZxT1n6T275fr9jX6ePzDinrJxT1Pbvl+v2Nfp4/MLz1OKY9J7d8v1+xr9PH5hxT1kvPU9u
+X6/Y1+nj8wvPVLz1Pbvl+v2NfqA/L7z1XinrJ7d8v1+xr9PH5heepeesnt3y/X7Gv08fmF56yXn
qe3fL9fsa/Tx+YXnrJxT1Pbvl+v2Nfp4/MOKepMz1Pbvl+v2Nfp4/MLzPpkvPU9v+X6/Y1+nrS/L
7z1Lz1lr+Q+X6/ZH6ePzC89UvPWWv5L5Pr9l1+oRqTq/L7z1W89Zan/J5/8AH1+w/Tx+YcU9ZLz1
a/lPk+v2Nfp5Gr8w4p6l5trK/wAr8n1+w/UR+XXnrJMz1lf5b5Pr9jX6iPy7inrJxT1P5b5Pr9jX
6ilT8vvPU4p6n8r8n1+xr9PH5heepeeqfyvyfX7Gv08fmHFPVLz1Z/lPk+v2NfqMo/L7z1leKeqf
yfyfX7D9PI1fmHFPUvPWWb/yPyfX7Gv1CpH5heesl56s/wAh8n1+yP08ibPzDinrJf1n8h8n1+w/
UZi8MvzC89S89Vn/ACPyfX7Lr9PH5heesl56tfyXyfX7Gv1COiTFn5heepeestfyfyfX7D9PH5he
eqXnrK/ynyfX7Gv1Afl956rf1yfyvyfX7Gv08fmHFPUvPWT+V+T6/Y1+nj8wvPUmZ6yfynyfX7Gv
09bdX5fxT1kvN9Z+lP5T5Pr9jX6fMj8w4p6nFPVP5P5Pr9h+nkRd+YXnqcU9ZZv/ACXyfX7Gv0+Z
H5hxSXnqz/IfL9fsj9PW1tX5fxT1S89WL17f/n6/ZdfqEzcfl956yvFPVn235fqj9PIi78wvPUvP
WU9s+X6rr9R0H5deesl56p7Z8v1R+ouX340yXf4XLcU9ZSZu59J1n9zjeOD/2Q==
]]

local SHARED_PANO_LEGACY_CLEANUP = [=[
return (function() {
	var PANEL = 'shinymoon_shared_icon';
	var ctx = $.GetContextPanel();
	if (!ctx) return;

	if (ctx._shinymoon_guard && ctx._shinymoon_guard.stop) {
		ctx._shinymoon_guard.stop();
		ctx._shinymoon_guard = null;
	}

	if (ctx._shinymoon_shared && ctx._shinymoon_shared.setEnabled) {
		ctx._shinymoon_shared.setEnabled(false);
		ctx._shinymoon_shared.reset();
		ctx._shinymoon_shared = null;
	}

	function fullResetStyle(p) {
		if (!p || !p.style) return;
		p.style.backgroundImage = null;
		p.style.backgroundSize = null;
		p.style.backgroundRepeat = null;
		p.style.backgroundPosition = null;
		p.style.width = null;
		p.style.height = null;
		p.style.opacity = null;
	}

	function clearRow(row) {
		if (!row) return;
		var owned = row.FindChildrenWithAttributeTraverse('id', PANEL);
		if (owned) {
			for (var i = 0; i < owned.length; i++) owned[i].DeleteAsync(0);
		}
		var idPanel = row.FindChildTraverse('id');
		if (idPanel && idPanel.id === 'id') fullResetStyle(idPanel);
		var rankPanel = row.FindChildTraverse('id-sb-skillgroup-image');
		if (rankPanel) fullResetStyle(rankPanel);
		var avatarPanel = row.FindChildTraverse('AvatarImage');
		if (avatarPanel) fullResetStyle(avatarPanel);
	}

	var root = ctx.FindChildTraverse('ScoreboardContainer');
	if (!root) root = ctx.FindChildTraverse('id-eom-scoreboard-container');
	if (root) {
		var rows = root.FindChildrenWithClassTraverse('sb-row');
		if (!rows || !rows.length) rows = root.FindChildrenWithClassTraverse('sb-row__player');
		if (rows) {
			for (var r = 0; r < rows.length; r++) clearRow(rows[r]);
		}
	}
})();
]=]

local function shared_run_legacy_cleanup()
	pcall(function()
		panorama.loadstring(SHARED_PANO_LEGACY_CLEANUP, "CSGOHud")
	end)
end

local SHARED_ICON = {
	raw_url = "https://raw.githubusercontent.com/dfs736037-star/icon/refs/heads/main/mae_do_pf.png",
	path = "nl/shinymoon/shared_icon.jpg",
	pano_path = "materials/panorama/images/icons/ui/shinymoon.jpg",
	pano_url = "file://{images}/icons/ui/shinymoon.jpg",
	users = {},
	applied = {},
	last_broadcast = 0,
	icon_src = nil,
	candidates = nil,
	bytes = nil,
	MAGIC = {
		KEY = ".shinymoon|",
		HASH = 71234,
		ID = 0x53484959,
		SIG = 1,
	},
}

local SHARED_ICON_TICK_MAX = 3.5
local SHARED_ICON_BROADCAST_INTERVAL = 1.0

local function shared_users_enabled()
	return vis_setup.shared_users and vis_setup.shared_users:get()
end

local function shared_tick_to_sec(ticks)
	return math.abs(ticks or 0) * (globals.tickinterval or (1 / 64))
end

local function shared_elapsed(now, last, interval)
	return math.abs((now or 0) - (last or 0)) >= interval
end

local function shared_player_xuid(ply)
	if not ply then
		return nil
	end

	local ok, xuid = pcall(function()
		return ply:get_xuid()
	end)
	if not ok or not xuid or xuid == 0 then
		return nil
	end

	return tostring(xuid)
end

local function shared_reset_icon_cache()
	SHARED_ICON.icon_src = nil
	SHARED_ICON.candidates = nil
	SHARED_ICON.bytes = nil
	SHARED_ICON.applied = {}
end

local function shared_voice_hash(tick, salt)
	local h = bit.bxor(tick, salt)
	return (h + bit.lshift(h, 1) + bit.lshift(h, 4) + bit.lshift(h, 7) + bit.lshift(h, 8) + bit.lshift(h, 24)) % 4294967296
end

local function shared_get_icon_bytes()
	if SHARED_ICON.bytes then
		return SHARED_ICON.bytes
	end
	if not shared_icon_b64 or shared_icon_b64 == "" then
		return nil
	end
	local ok, bytes = pcall(l_base64_0.decode, shared_icon_b64:gsub("%s+", ""))
	if ok and bytes and bytes ~= "" then
		SHARED_ICON.bytes = bytes
		return bytes
	end
	return nil
end

local function shared_ensure_icon_file()
	local bytes = shared_get_icon_bytes()
	if not bytes then
		return false
	end
	pcall(function()
		files.create_folder("nl")
		files.create_folder("nl/shinymoon")
		files.create_folder("materials")
		files.create_folder("materials/panorama")
		files.create_folder("materials/panorama/images")
		files.create_folder("materials/panorama/images/icons")
		files.create_folder("materials/panorama/images/icons/ui")
	end)
	pcall(function()
		files.write(SHARED_ICON.path, bytes, true)
	end)
	pcall(function()
		files.write(SHARED_ICON.pano_path, bytes, true)
	end)
	return true
end

local function shared_get_icon_candidates()
	if SHARED_ICON.candidates then
		return SHARED_ICON.candidates
	end

	local candidates = {}

	if shared_ensure_icon_file() then
		candidates[#candidates + 1] = SHARED_ICON.pano_url
		candidates[#candidates + 1] = SHARED_ICON.pano_path
		candidates[#candidates + 1] = SHARED_ICON.path

		local bytes = shared_get_icon_bytes()
		if bytes then
			local ok, data_url = pcall(function()
				return "data:image/jpeg;base64," .. l_base64_0.encode(bytes)
			end)
			if ok and data_url then
				candidates[#candidates + 1] = data_url
			end
		end
	end

	if SHARED_ICON.raw_url and SHARED_ICON.raw_url ~= "" then
		candidates[#candidates + 1] = SHARED_ICON.raw_url
	end

	SHARED_ICON.candidates = candidates
	return candidates
end

local function shared_get_icon_src()
	if SHARED_ICON.icon_src then
		return SHARED_ICON.icon_src
	end

	local candidates = shared_get_icon_candidates()
	for i = 1, #candidates do
		if candidates[i] and candidates[i] ~= "" then
			SHARED_ICON.icon_src = candidates[i]
			return SHARED_ICON.icon_src
		end
	end

	return nil
end

local function shared_apply_set_icon(ply, xuid)
	if not ply then
		return false
	end

	xuid = xuid or shared_player_xuid(ply)
	if xuid and SHARED_ICON.applied[xuid] then
		return true
	end

	local icon_src = shared_get_icon_src()
	if not icon_src then
		return false
	end

	local ok = pcall(function()
		ply:set_icon(icon_src)
	end)

	if ok and xuid then
		SHARED_ICON.applied[xuid] = true
	end

	return ok
end

local function shared_clear_set_icon(ply, xuid, force)
	if not ply then
		return
	end

	xuid = xuid or shared_player_xuid(ply)
	if xuid and not force and not SHARED_ICON.applied[xuid] then
		return
	end

	pcall(function()
		ply:set_icon()
	end)

	if xuid then
		SHARED_ICON.applied[xuid] = nil
	end
end

local function shared_mark_user(ply, tick)
	local xuid = shared_player_xuid(ply)
	if not xuid then
		return
	end

	SHARED_ICON.users[xuid] = tick or globals.server_tick or 0
end

local function shared_user_fresh(xuid, server_tick, is_local)
	if not xuid then
		return false
	end
	if is_local then
		return true
	end
	local heartbeat = SHARED_ICON.users[xuid]
	return heartbeat ~= nil and shared_tick_to_sec(server_tick - heartbeat) <= SHARED_ICON_TICK_MAX
end

local function shared_prune_users(players, me, server_tick)
	local alive = {}
	local me_xuid = shared_player_xuid(me)
	if me_xuid then
		alive[me_xuid] = true
	end

	if players then
		for i = 1, #players do
			local xuid = shared_player_xuid(players[i])
			if xuid then
				alive[xuid] = true
			end
		end
	end

	for xuid, heartbeat in pairs(SHARED_ICON.users) do
		if not alive[xuid] or shared_tick_to_sec(server_tick - heartbeat) > SHARED_ICON_TICK_MAX then
			SHARED_ICON.users[xuid] = nil
			SHARED_ICON.applied[xuid] = nil
		end
	end
end

local function shared_apply_entity_icons(me, players)
	if not shared_get_icon_src() or not players then
		return
	end

	local server_tick = globals.server_tick or 0
	for i = 1, #players do
		local ply = players[i]
		if ply then
			local xuid = shared_player_xuid(ply)
			local is_local = ply == me
			if shared_user_fresh(xuid, server_tick, is_local) then
				shared_apply_set_icon(ply, xuid)
			else
				shared_clear_set_icon(ply, xuid, false)
			end
		end
	end
end

local function shared_broadcast_presence()
	if not shared_get_icon_src() then
		return
	end

	events.voice_message:call(function(buf)
		local tick = globals.server_tick or 0
		buf:write_bits(tick, 32)
		buf:write_bits(shared_voice_hash(tick, SHARED_ICON.MAGIC.HASH), 32)
		buf:write_bits(SHARED_ICON.MAGIC.ID, 32)
		buf:write_bits(SHARED_ICON.MAGIC.SIG, 4)
		buf:crypt(SHARED_ICON.MAGIC.KEY)
	end)
end

local function shared_restore_voice_buffer(buffer)
	pcall(function()
		if buffer.reset then
			buffer:reset()
		end
		buffer:crypt(SHARED_ICON.MAGIC.KEY)
		if buffer.reset then
			buffer:reset()
		end
	end)
end

local function shared_read_voice_payload(buffer)
	if not buffer then
		return nil
	end

	local ok, payload = pcall(function()
		if buffer.reset then
			buffer:reset()
		end
		buffer:crypt(SHARED_ICON.MAGIC.KEY)
		return {
			tick = buffer:read_bits(32),
			hash = buffer:read_bits(32),
			id = buffer:read_bits(32),
			sig = buffer:read_bits(4),
		}
	end)

	if not ok or not payload then
		shared_restore_voice_buffer(buffer)
		return nil
	end

	if payload.id ~= SHARED_ICON.MAGIC.ID or payload.sig ~= SHARED_ICON.MAGIC.SIG then
		shared_restore_voice_buffer(buffer)
		return nil
	end
	if shared_tick_to_sec((globals.server_tick or 0) - payload.tick) > SHARED_ICON_TICK_MAX then
		shared_restore_voice_buffer(buffer)
		return nil
	end
	if payload.hash ~= shared_voice_hash(payload.tick, SHARED_ICON.MAGIC.HASH) then
		shared_restore_voice_buffer(buffer)
		return nil
	end

	return payload
end

shared_on_voice_message = function(ctx)
	if not shared_users_enabled() or not ctx or not ctx.entity or not ctx.buffer then
		return false
	end

	local ent = ctx.entity
	local me = entity.get_local_player()
	if not ent or ent == me then
		return false
	end

	local payload = shared_read_voice_payload(ctx.buffer)
	if not payload then
		return false
	end

	shared_mark_user(ent, payload.tick)
	return true
end

shared_sync_icons = function()
	if not shared_users_enabled() then
		return
	end

	local me = entity.get_local_player()
	if not me or not shared_get_icon_src() then
		return
	end

	local server_tick = globals.server_tick or 0
	local players = entity.get_players(false, true)

	shared_mark_user(me, server_tick)
	shared_prune_users(players, me, server_tick)

	local now = globals.realtime or 0
	if shared_elapsed(now, SHARED_ICON.last_broadcast, SHARED_ICON_BROADCAST_INTERVAL) then
		SHARED_ICON.last_broadcast = now
		shared_broadcast_presence()
	end

	shared_apply_entity_icons(me, players)
end

shared_shutdown_icons = function()
	shared_run_legacy_cleanup()

	local players = entity.get_players(false, true)
	if players then
		for i = 1, #players do
			shared_clear_set_icon(players[i], nil, true)
		end
	end

	SHARED_ICON.users = {}
	SHARED_ICON.applied = {}
	SHARED_ICON.last_broadcast = 0
end

vis_setup.shared_users:set_callback(function()
	if not vis_setup.shared_users:get() then
		shared_shutdown_icons()
	else
		shared_reset_icon_cache()
		shared_sync_icons()
	end
end, true)

shared_run_legacy_cleanup()
shared_get_icon_src()

EVENTS.add({ event = "round_start", tag = "vis.reset", order = 40, fn = function()
	vis_state.hitmarkers = {}
	vis_state.hitmarker_screen = nil
	vis_state.damage_anim = 0
	if shared_users_enabled() and shared_sync_icons then
		shared_sync_icons()
	end
end })

local VIS_SMOOTH = 0.12
local VIS_SMOOTH_FAST = 0.16
local VIS_SMOOTH_SLOW = 0.09

local function vis_lerp(a, b, t)
	return a + (b - a) * t
end

local function vis_lerp_step(current, target, speed)
	return vis_lerp(current, target, speed or VIS_SMOOTH)
end

local function vis_color_alpha(c, a)
	return color(c.r, c.g, c.b, a)
end

local function vis_bind_min_damage()
	local active = false
	local override_value = nil
	local binds_ok, binds = pcall(ui.get_binds)
	if binds_ok and binds then
		for i = 1, #binds do
			if binds[i].name == "Min. Damage" then
				if binds[i].active then
					active = true
					override_value = binds[i].value
				end
				break
			end
		end
	end
	return active, override_value
end

local function vis_damage_target_value()
	local ref = vis_refs.min_damage
	if not ref then return 0 end

	local _, override_value = vis_bind_min_damage()
	local value = ref:get()
	if value == nil then value = 0 end
	if override_value ~= nil then
		value = override_value
	end
	return tonumber(value) or 0
end

local function vis_damage_format(value)
	if value <= 0 then
		return "AUTO"
	elseif value > 100 then
		return "+" .. tostring(value - 100)
	end
	return tostring(math.floor(value + 0.5))
end

local function vis_damage_text()
	local value = vis_damage_target_value()
	if vis_setup.damage_animate:get() then
		vis_state.damage_anim = vis_lerp_step(vis_state.damage_anim, value, VIS_SMOOTH)
		value = vis_state.damage_anim
	else
		vis_state.damage_anim = value
	end
	return vis_damage_format(value)
end

local function vis_damage_wants_show()
	if not vis_setup.damage_ind:get() then return false end

	local me = entity.get_local_player()
	if not me or not me:is_alive() then return false end

	if vis_setup.damage_style:get() == "Always On" then
		return true
	end

	local bind_active = vis_bind_min_damage()
	local menu_open = ui.get_alpha and ui.get_alpha() > 0
	return bind_active or menu_open
end

local function vis_wm_lerp_color(c1, c2, t)
	return color(
		math.floor(c1.r + (c2.r - c1.r) * t),
		math.floor(c1.g + (c2.g - c1.g) * t),
		math.floor(c1.b + (c2.b - c1.b) * t),
		math.floor(c1.a + (c2.a - c1.a) * t)
	)
end

local function vis_wm_utf8_len(text)
	local len = 0
	text:gsub("(.[\128-\191]*)", function()
		len = len + 1
	end)
	return len
end

local function vis_wm_gradient_text(text, c1, c2, speed)
	local len = vis_wm_utf8_len(text)
	if len <= 0 then return text end

	local wave = (globals.realtime or 0) * speed * 0.1 % 2 - 1
	local step = len > 1 and 1 / (len - 1) or 0
	local index = 0
	local out = {}

	text:gsub("(.[\128-\191]*)", function(ch)
		local t = index * step
		local dist = t - wave
		local blend = 0
		if dist >= 0 and dist <= 1.4 then
			if dist > 0.7 then dist = 1.4 - dist end
			blend = dist / 0.7
		end
		local col = vis_wm_lerp_color(c1, c2, blend)
		out[#out + 1] = "\a" .. col:to_hex() .. ch
		index = index + 1
	end)

	return table.concat(out)
end

local function vis_wm_build_label()
	local mode = vis_setup.watermark_text_mode:get()
	local base = string.format("%s.lua", string.lower(SCRIPT.name))
	if mode == "Custom" then
		local custom = vis_setup.watermark_custom_text:get()
		if custom and custom ~= "" then return custom end
		return base
	end
	return base
end

local function vis_wm_build_display()
	local label = vis_wm_build_label()
	if vis_setup.watermark_show_build:get() then
		label = string.format("%s · %s", label, SCRIPT.build or "")
	end
	return label
end

local DB_KEY_WM_X = "shinymoon_wm_x"
local DB_KEY_WM_Y = "shinymoon_wm_y"
local WM_PAD_X, WM_PAD_Y = 8, 4
local WM_RADIUS = 4
local WM_RAIL_W = 3
local WM_MARGIN = 8
local WM_TEXT = color(255, 255, 255, 255)

local function vis_wm_clamp(v, lo, hi)
	return math.max(lo, math.min(hi, v))
end

local function vis_wm_box_size(font, text)
	local size = render.measure_text(font, nil, text)
	return size.x + WM_PAD_X * 2 + WM_RAIL_W, size.y + WM_PAD_Y * 2
end

local function vis_wm_anchor_pos(mode, box_w, box_h, screen)
	if mode == "Top Right" then
		return vector(screen.x - box_w - 5, 5)
	end
	if mode == "Left" then
		return vector(8, (screen.y - box_h) * 0.5)
	end
	if mode == "Right" then
		return vector(screen.x - box_w - 8, (screen.y - box_h) * 0.5)
	end
	return vector((screen.x - box_w) * 0.5, screen.y - box_h - WM_MARGIN)
end

local function vis_wm_load_pos()
	local wm = vis_state.wm
	if wm.loaded then return end
	wm.loaded = true
	local x, y = db[DB_KEY_WM_X], db[DB_KEY_WM_Y]
	if x ~= nil and y ~= nil then
		wm.pos = vector(tonumber(x) or 0, tonumber(y) or 0)
	end
end

local function vis_wm_save_pos(pos)
	db[DB_KEY_WM_X] = pos.x
	db[DB_KEY_WM_Y] = pos.y
	vis_state.wm.pos = vector(pos.x, pos.y)
end

local function vis_wm_point_in_rect(pt, tl, br)
	return pt.x >= tl.x and pt.x <= br.x and pt.y >= tl.y and pt.y <= br.y
end

local function vis_wm_handle_drag(tl, box_w, box_h, screen)
	local wm = vis_state.wm
	if l_pui_0.get_alpha() <= 0 then
		wm.dragging = false
		return tl
	end

	local mouse = l_pui_0.get_mouse_position()
	local br = vector(tl.x + box_w, tl.y + box_h)
	local inside = vis_wm_point_in_rect(mouse, tl, br)

	if common.is_button_down(1) then
		if inside and not wm.dragging then
			wm.dragging = true
			wm.drag_offset = vector(mouse.x - tl.x, mouse.y - tl.y)
		end
	elseif wm.dragging and common.is_button_released(1) then
		wm.dragging = false
		vis_wm_save_pos(tl)
		if vis_setup.watermark_position:get() ~= "Custom" then
			pcall(function() vis_setup.watermark_position:set("Custom") end)
		end
	end

	if wm.dragging then
		return vector(
			vis_wm_clamp(mouse.x - wm.drag_offset.x, 0, screen.x - box_w),
			vis_wm_clamp(mouse.y - wm.drag_offset.y, 0, screen.y - box_h)
		)
	end

	return tl
end

local function vis_wm_resolve_pos(box_w, box_h, screen)
	vis_wm_load_pos()
	local mode = vis_setup.watermark_position:get()
	local tl

	if mode == "Custom" and vis_state.wm.pos then
		tl = vector(vis_state.wm.pos.x, vis_state.wm.pos.y)
		tl.x = vis_wm_clamp(tl.x, 0, screen.x - box_w)
		tl.y = vis_wm_clamp(tl.y, 0, screen.y - box_h)
	else
		tl = vis_wm_anchor_pos(mode, box_w, box_h, screen)
	end

	return vis_wm_handle_drag(tl, box_w, box_h, screen)
end

local function vis_wm_draw_text(font, pos, text, accent, accent2, use_grad, grad_speed)
	if use_grad then
		local grad_text = vis_wm_gradient_text(text, accent, accent2, grad_speed)
		render.text(font, pos, WM_TEXT, "c", grad_text)
	else
		render.text(font, pos, WM_TEXT, "c", text)
	end
end

local function vis_draw_watermark()
	if not vis_setup.watermark:get() then return end

	local accent = vis_setup.watermark_color:get()
	local accent2 = vis_setup.watermark_color2:get()
	local text = vis_wm_build_display()
	local font = vis_setup.watermark_font:get()
	local use_grad = vis_setup.watermark_text_gradient:get()
	local grad_speed = vis_setup.watermark_gradient_speed:get()
	local screen = render.screen_size()
	local box_w, box_h = vis_wm_box_size(font, text)
	local tl = vis_wm_resolve_pos(box_w, box_h, screen)
	local br = vector(tl.x + box_w, tl.y + box_h)
	local grad_left = color(accent2.r, accent2.g, accent2.b, 0)
	local grad_right = color(accent.r, accent.g, accent.b, accent.a)

	render.gradient(tl, br, grad_left, grad_right, grad_left, grad_right, WM_RADIUS)
	render.gradient(tl, vector(tl.x + WM_RAIL_W, br.y), accent, accent, accent2, accent2)

	local text_x = tl.x + WM_RAIL_W + (box_w - WM_RAIL_W) * 0.5
	local text_y = tl.y + box_h * 0.5
	vis_wm_draw_text(font, vector(text_x, text_y), text, accent, accent2, use_grad, grad_speed)
end

local function vis_draw_damage()
	local want_show = vis_damage_wants_show()
	vis_state.damage_alpha = vis_lerp_step(vis_state.damage_alpha, want_show and 1 or 0, VIS_SMOOTH)
	if vis_state.damage_alpha <= 0.01 then return end

	local col = vis_setup.damage_color:get()
	col = vis_color_alpha(col, math.floor(col.a * vis_state.damage_alpha))
	local text = vis_damage_text()
	local screen = render.screen_size()
	local center = screen * 0.5
	local pos = center + vector(12, -12)
	render.text(1, pos, col, "c", text)
end

local function vis_ease_out_cubic(t)
	t = math.min(1, math.max(0, t))
	return 1 - (1 - t) ^ 3
end

local function vis_ease_out_back(t, overshoot)
	t = math.min(1, math.max(0, t))
	local c1 = overshoot or 1.2
	local c3 = c1 + 1
	return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
end

local function vis_draw_hitmarker_line(from_pos, to_pos, col, thickness)
	thickness = math.max(1, math.floor(thickness or 1))
	if thickness <= 1 then
		render.line(from_pos, to_pos, col)
		return
	end

	local half = math.floor(thickness * 0.5)
	for offset = -half, half do
		render.line(from_pos + vector(offset, 0), to_pos + vector(offset, 0), col)
		if offset ~= 0 then
			render.line(from_pos + vector(0, offset), to_pos + vector(0, offset), col)
		end
	end
end

local function vis_draw_hitmarker_cross(center, size, gap, col, thickness, shadow)
	local function draw_at(origin, draw_col)
		vis_draw_hitmarker_line(origin + vector(-gap, -gap), origin + vector(-size, -size), draw_col, thickness)
		vis_draw_hitmarker_line(origin + vector(gap, -gap), origin + vector(size, -size), draw_col, thickness)
		vis_draw_hitmarker_line(origin + vector(-gap, gap), origin + vector(-size, size), draw_col, thickness)
		vis_draw_hitmarker_line(origin + vector(gap, gap), origin + vector(size, size), draw_col, thickness)
	end

	if shadow then
		draw_at(center + vector(1, 1), shadow)
	end
	draw_at(center, col)
end

local function vis_draw_hitmarker_soft(center, size, gap, col, thickness, shadow)
	local arm = math.max(2, math.floor(thickness))
	local half = arm * 0.5
	local round = math.min(3, math.floor(arm * 0.5 + 0.5))

	local function draw_plus(origin, draw_col)
		render.rect(vector(origin.x - size, origin.y - half), vector(origin.x - gap, origin.y + half), draw_col, round, true)
		render.rect(vector(origin.x + gap, origin.y - half), vector(origin.x + size, origin.y + half), draw_col, round, true)
		render.rect(vector(origin.x - half, origin.y - size), vector(origin.x + half, origin.y - gap), draw_col, round, true)
		render.rect(vector(origin.x - half, origin.y + gap), vector(origin.x + half, origin.y + size), draw_col, round, true)
	end

	if shadow then
		draw_plus(center + vector(1, 1), shadow)
	end
	draw_plus(center, col)
end

local function vis_hitmarker_alpha(age, remaining, duration)
	local fade_in = math.min(0.1, duration * 0.2)
	local fade_out = math.min(0.28, duration * 0.42)
	if age < fade_in then
		return age / fade_in
	end
	if remaining < fade_out then
		return remaining / fade_out
	end
	return 1
end

local function vis_hitmarker_motion(age, duration, use_pop, use_drift)
	local pop_scale = 1
	local gap_scale = 1
	local drift_y = 0

	if use_pop then
		local pop_len = math.min(0.2, duration * 0.34)
		if age < pop_len then
			local t = age / pop_len
			local back = vis_ease_out_back(t, 1.35)
			pop_scale = 0.76 + 0.24 * back
			gap_scale = 1.28 - 0.28 * vis_ease_out_cubic(t)
		end
	end

	if use_drift then
		local t = math.min(1, age / duration)
		drift_y = vis_ease_out_cubic(t) * 10
	end

	return pop_scale, gap_scale, drift_y
end

local function vis_hitmarker_pick_color(hit, base_col, alpha)
	local col = base_col
	if hit.kill and vis_setup.hitmarker_kill:get() then
		col = vis_setup.hitmarker_kill_color:get()
	elseif hit.headshot and vis_setup.hitmarker_headshot:get() then
		col = vis_setup.hitmarker_headshot_color:get()
	end
	return vis_color_alpha(col, math.floor(col.a * alpha))
end

local function vis_hitmarker_world_pos(victim, hitgroup)
	if hitgroup == 1 then
		return victim:get_hitbox_position(0) or victim:get_hitbox_position(3) or victim:get_origin()
	end
	return victim:get_hitbox_position(3) or victim:get_origin()
end

local function vis_hitmarker_spawn(screen, pos, damage, headshot, kill)
	local duration = vis_setup.hitmarker_duration:get()
	local now = globals.realtime
	return {
		screen = screen,
		pos = pos,
		start = now,
		time = now + duration,
		duration = duration,
		damage = damage,
		headshot = headshot,
		kill = kill,
	}
end

local function vis_draw_hitmarker_damage(center, draw_size, text, col, shadow)
	local text_size = render.measure_text(1, nil, text)
	local text_pos = vector(center.x - text_size.x * 0.5, center.y + draw_size + 6)
	if shadow then
		render.text(1, text_pos + vector(1, 1), shadow, nil, text)
	end
	render.text(1, text_pos, col, nil, text)
end

local function vis_draw_hitmarker_entry(hit, center, style, size, gap, thickness, base_col, show_damage, use_shadow, use_pop, use_drift, use_glow, master_alpha)
	local now = globals.realtime
	local remaining = hit.time - now
	local age = now - hit.start
	local alpha = vis_hitmarker_alpha(age, remaining, hit.duration) * (master_alpha or 1)
	if alpha <= 0 then return end

	local pop_scale, gap_scale, drift_y = vis_hitmarker_motion(age, hit.duration, use_pop, use_drift)
	local draw_size = size * pop_scale
	local draw_gap = gap * gap_scale
	center = vector(center.x, center.y - drift_y)

	local c = vis_hitmarker_pick_color(hit, base_col, alpha)
	local shadow = use_shadow and color(0, 0, 0, math.floor(120 * alpha)) or nil

	if style == "Soft" then
		if use_glow then
			local glow = vis_color_alpha(c, math.floor(c.a * 0.3))
			vis_draw_hitmarker_soft(center, draw_size * 1.12, draw_gap, glow, thickness + 1, nil)
		end
		vis_draw_hitmarker_soft(center, draw_size, draw_gap, c, thickness, shadow)
	else
		draw_size = draw_size * 1.12
		draw_gap = draw_gap * 0.85
		if use_glow then
			local glow = vis_color_alpha(c, math.floor(c.a * 0.32))
			vis_draw_hitmarker_cross(center, draw_size * 1.08, draw_gap, glow, thickness + 1, nil)
		end
		vis_draw_hitmarker_cross(center, draw_size, draw_gap, c, thickness, shadow)
	end

	if show_damage and hit.damage and hit.damage > 0 then
		vis_draw_hitmarker_damage(center, draw_size, tostring(hit.damage), c, shadow)
	end
end

local function vis_draw_hitmarkers()
	vis_state.hitmarker_master = vis_lerp_step(
		vis_state.hitmarker_master,
		vis_setup.hitmarker:get() and 1 or 0,
		VIS_SMOOTH
	)

	local now = globals.realtime
	local style = vis_setup.hitmarker_style:get()
	local size = vis_setup.hitmarker_size:get()
	local gap = math.min(vis_setup.hitmarker_gap:get(), math.max(1, size - 2))
	local thickness = vis_setup.hitmarker_thickness:get()
	local base_col = vis_setup.hitmarker_color:get()
	local show_damage = vis_setup.hitmarker_damage:get()
	local use_shadow = vis_setup.hitmarker_shadow:get()
	local use_pop = vis_setup.hitmarker_pop:get()
	local use_drift = vis_setup.hitmarker_drift:get()
	local use_glow = vis_setup.hitmarker_glow:get()
	local place = vis_setup.hitmarker_place:get()
	local show_world = place == "World" or place == "Both"
	local show_screen = place == "Screen" or place == "Both"
	local master = vis_state.hitmarker_master

	for i = #vis_state.hitmarkers, 1, -1 do
		if vis_state.hitmarkers[i].time < now then
			table.remove(vis_state.hitmarkers, i)
		end
	end

	if vis_state.hitmarker_screen and vis_state.hitmarker_screen.time < now then
		vis_state.hitmarker_screen = nil
	end

	if vis_state.hitmarker_master <= 0.01 and #vis_state.hitmarkers == 0 and not vis_state.hitmarker_screen then
		return
	end

	local screen = render.screen_size()
	local screen_center = screen * 0.5

	if show_screen and vis_state.hitmarker_screen then
		vis_draw_hitmarker_entry(
			vis_state.hitmarker_screen,
			screen_center,
			style, size, gap, thickness, base_col,
			show_damage, use_shadow, use_pop, use_drift, use_glow,
			master
		)
	end

	if not show_world then return end

	for i = 1, #vis_state.hitmarkers do
		local hit = vis_state.hitmarkers[i]
		local screen_pos = render.world_to_screen(hit.pos)
		if screen_pos then
			vis_draw_hitmarker_entry(
				hit,
				vector(screen_pos.x, screen_pos.y),
				style, size, gap, thickness, base_col,
				show_damage, use_shadow, use_pop, use_drift, use_glow,
				master
			)
		end
	end
end

local function vis_draw_scope(me)
	local feature_on = vis_setup.scope:get()
	local scoped = feature_on and me and me:is_alive() and me.m_bIsScoped
	vis_state.scope_alpha = vis_lerp_step(vis_state.scope_alpha, scoped and 1 or 0, VIS_SMOOTH_FAST)
	if vis_state.scope_alpha <= 0.01 then return end

	vis_state.scope_size_smooth = vis_lerp_step(vis_state.scope_size_smooth, vis_setup.scope_size:get(), VIS_SMOOTH)
	vis_state.scope_gap_smooth = vis_lerp_step(vis_state.scope_gap_smooth, vis_setup.scope_gap:get(), VIS_SMOOTH)
	vis_state.scope_thick_smooth = vis_lerp_step(vis_state.scope_thick_smooth, vis_setup.scope_thickness:get(), VIS_SMOOTH)

	local screen = render.screen_size()
	local cx = math.floor(screen.x * 0.5 + 0.5)
	local cy = math.floor(screen.y * 0.5 + 0.5)

	local length = vis_state.scope_size_smooth * vis_state.scope_alpha
	local gap = vis_state.scope_gap_smooth * vis_state.scope_alpha
	local half = vis_state.scope_thick_smooth * 0.5

	local raw_c1 = vis_setup.scope_color1:get()
	local raw_c2 = vis_setup.scope_color2:get()
	local c1 = vis_color_alpha(raw_c1, math.floor(raw_c1.a * vis_state.scope_alpha))
	local c2 = vis_color_alpha(raw_c2, math.floor(raw_c2.a * vis_state.scope_alpha))
	local use_grad = vis_setup.scope_gradient:get()

	if use_grad then
		render.gradient(vector(cx - gap - length, cy - half), vector(cx - gap, cy + half), c2, c1, c2, c1)
		render.gradient(vector(cx + gap, cy - half), vector(cx + gap + length, cy + half), c1, c2, c1, c2)
		render.gradient(vector(cx - half, cy - gap - length), vector(cx + half, cy - gap), c2, c2, c1, c1)
		render.gradient(vector(cx - half, cy + gap), vector(cx + half, cy + gap + length), c1, c1, c2, c2)
	else
		render.rect(vector(cx - gap - length, cy - half), vector(cx - gap, cy + half), c1)
		render.rect(vector(cx + gap, cy - half), vector(cx + gap + length, cy + half), c1)
		render.rect(vector(cx - half, cy - gap - length), vector(cx + half, cy - gap), c1)
		render.rect(vector(cx - half, cy + gap), vector(cx + half, cy + gap + length), c1)
	end
end

local function vis_distance_2d(a, b)
	return math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2)
end

local function vis_lerp_vec(a, b, t)
	return vector((b.x - a.x) * t + a.x, (b.y - a.y) * t + a.y, (b.z - a.z) * t + a.z)
end

local function vis_draw_world()
	vis_state.molotov_alpha = vis_lerp_step(
		vis_state.molotov_alpha,
		vis_setup.molotov_radius:get() and 1 or 0,
		VIS_SMOOTH
	)
	vis_state.smoke_alpha = vis_lerp_step(
		vis_state.smoke_alpha,
		vis_setup.smoke_radius:get() and 1 or 0,
		VIS_SMOOTH
	)

	if vis_state.molotov_alpha <= 0.01 and vis_state.smoke_alpha <= 0.01 then return end
	if not entity.get_local_player() then return end

	if vis_state.molotov_alpha > 0.01 then
		local fires = entity.get_entities("CInferno")
		if fires then
			for i = 1, #fires do
				local inferno = fires[i]
				local origin = inferno:get_origin()
				if origin then
					local points = {}
					for j = 1, 64 do
						if inferno.m_bFireIsBurning and inferno.m_bFireIsBurning[j] == true then
							points[#points + 1] = vector(inferno.m_fireXDelta[j], inferno.m_fireYDelta[j], inferno.m_fireZDelta[j])
						end
					end
					local max_dist = 0
					local p1, p2 = nil, nil
					for a = 1, #points do
						for b = a + 1, #points do
							local dist = vis_distance_2d(points[a], points[b])
							if dist > max_dist then
								max_dist = dist
								p1, p2 = points[a], points[b]
							end
						end
					end
					if p1 and p2 then
						local center = origin + vis_lerp_vec(p1, p2, 0.5)
						local col = vis_setup.molotov_color:get()
						local alpha = math.floor(col.a * vis_state.molotov_alpha)
						render.circle_3d_outline(center, color(col.r, col.g, col.b, alpha), max_dist * 0.5 + 40, 0, 1)
					end
				end
			end
		end
	end

	if vis_state.smoke_alpha > 0.01 then
		local smokes = entity.get_entities("CSmokeGrenadeProjectile")
		if smokes then
			local tick = globals.tickcount
			local interval = globals.tickinterval
			local smoke_duration = 17.55
			local smoke_radius = 125

			for i = 1, #smokes do
				local smoke = smokes[i]
				if smoke:get_classname() == "CSmokeGrenadeProjectile" and smoke.m_bDidSmokeEffect == true then
					local begin_tick = smoke.m_nSmokeEffectTickBegin
					if begin_tick then
						local elapsed = interval * (tick - begin_tick)
						if elapsed > 0 and smoke_duration - elapsed > 0 then
							local col = vis_setup.smoke_color:get()
							local alpha = col.a
							local radius = smoke_radius
							if elapsed < 0.3 then
								radius = radius * (0.6 + (elapsed / 0.3) * 0.4)
								alpha = alpha * (elapsed / 0.3)
							end
							if smoke_duration - elapsed < 1 then
								radius = radius * (((smoke_duration - elapsed) / 1) * 0.3 + 0.7)
							end
							alpha = math.floor(alpha * vis_state.smoke_alpha)
							render.circle_3d_outline(smoke:get_origin(), color(col.r, col.g, col.b, alpha), radius, 0, 1)
						end
					end
				end
			end
		end
	end
end

local function vis_aspect_target()
	if not vis_setup.aspect:get() then
		return vis_state.aspect_saved or 0
	end
	local val = vis_setup.aspect_val:get()
	if val <= 50 then return 0 end
	return val * 0.01
end

local function vis_apply_aspect()
	if not vis_setup.aspect:get() then
		if vis_state.aspect_saved == nil then
			vis_state.aspect_smooth = nil
			return
		end

		if vis_state.aspect_smooth == nil then
			vis_state.aspect_smooth = tonumber(vis_cvars.aspect:string()) or vis_state.aspect_saved
		end

		local restore = vis_state.aspect_saved
		vis_state.aspect_smooth = vis_lerp_step(vis_state.aspect_smooth, restore, VIS_SMOOTH)
		vis_cvars.aspect:float(vis_state.aspect_smooth, true)

		if math.abs(vis_state.aspect_smooth - restore) < 0.001 then
			vis_cvars.aspect:float(restore, true)
			vis_state.aspect_saved = nil
			vis_state.aspect_smooth = nil
		end
		return
	end

	if vis_state.aspect_saved == nil then
		vis_state.aspect_saved = tonumber(vis_cvars.aspect:string()) or 0
	end

	local target = vis_aspect_target()
	if vis_state.aspect_smooth == nil then
		vis_state.aspect_smooth = tonumber(vis_cvars.aspect:string()) or target
	end

	vis_state.aspect_smooth = vis_lerp_step(vis_state.aspect_smooth, target, VIS_SMOOTH)
	vis_cvars.aspect:float(vis_state.aspect_smooth, true)
end

local function vis_viewmodel_target()
	return {
		fov = vis_setup.viewmodel_fov:get(),
		x = vis_setup.viewmodel_x:get() * 0.01,
		y = vis_setup.viewmodel_y:get() * 0.01,
		z = vis_setup.viewmodel_z:get() * 0.01,
	}
end

local function vis_vm_close(a, b)
	return math.abs(a.fov - b.fov) < 0.05
		and math.abs(a.x - b.x) < 0.001
		and math.abs(a.y - b.y) < 0.001
		and math.abs(a.z - b.z) < 0.001
end

local function vis_apply_viewmodel()
	if not vis_setup.viewmodel:get() then
		if not vis_state.vm_saved then
			vis_state.vm_smooth = nil
			return
		end

		if vis_state.vm_smooth == nil then
			vis_state.vm_smooth = {
				fov = tonumber(vis_cvars.viewmodel_fov:string()) or vis_state.vm_saved.fov,
				x = tonumber(vis_cvars.viewmodel_x:string()) or vis_state.vm_saved.x,
				y = tonumber(vis_cvars.viewmodel_y:string()) or vis_state.vm_saved.y,
				z = tonumber(vis_cvars.viewmodel_z:string()) or vis_state.vm_saved.z,
			}
		end

		local restore = vis_state.vm_saved
		vis_state.vm_smooth.fov = vis_lerp_step(vis_state.vm_smooth.fov, restore.fov, VIS_SMOOTH)
		vis_state.vm_smooth.x = vis_lerp_step(vis_state.vm_smooth.x, restore.x, VIS_SMOOTH)
		vis_state.vm_smooth.y = vis_lerp_step(vis_state.vm_smooth.y, restore.y, VIS_SMOOTH)
		vis_state.vm_smooth.z = vis_lerp_step(vis_state.vm_smooth.z, restore.z, VIS_SMOOTH)

		vis_cvars.viewmodel_fov:float(vis_state.vm_smooth.fov, false)
		vis_cvars.viewmodel_x:float(vis_state.vm_smooth.x, false)
		vis_cvars.viewmodel_y:float(vis_state.vm_smooth.y, false)
		vis_cvars.viewmodel_z:float(vis_state.vm_smooth.z, false)

		if vis_vm_close(vis_state.vm_smooth, restore) then
			vis_cvars.viewmodel_fov:float(restore.fov, false)
			vis_cvars.viewmodel_x:float(restore.x, false)
			vis_cvars.viewmodel_y:float(restore.y, false)
			vis_cvars.viewmodel_z:float(restore.z, false)
			vis_state.vm_saved = nil
			vis_state.vm_smooth = nil
		end
		return
	end

	if not vis_state.vm_saved then
		vis_state.vm_saved = {
			fov = tonumber(vis_cvars.viewmodel_fov:string()) or 68,
			x = tonumber(vis_cvars.viewmodel_x:string()) or 2.5,
			y = tonumber(vis_cvars.viewmodel_y:string()) or 0,
			z = tonumber(vis_cvars.viewmodel_z:string()) or -1.5,
		}
	end

	local target = vis_viewmodel_target()
	if vis_state.vm_smooth == nil then
		vis_state.vm_smooth = {
			fov = tonumber(vis_cvars.viewmodel_fov:string()) or target.fov,
			x = tonumber(vis_cvars.viewmodel_x:string()) or target.x,
			y = tonumber(vis_cvars.viewmodel_y:string()) or target.y,
			z = tonumber(vis_cvars.viewmodel_z:string()) or target.z,
		}
	end

	vis_state.vm_smooth.fov = vis_lerp_step(vis_state.vm_smooth.fov, target.fov, VIS_SMOOTH)
	vis_state.vm_smooth.x = vis_lerp_step(vis_state.vm_smooth.x, target.x, VIS_SMOOTH)
	vis_state.vm_smooth.y = vis_lerp_step(vis_state.vm_smooth.y, target.y, VIS_SMOOTH)
	vis_state.vm_smooth.z = vis_lerp_step(vis_state.vm_smooth.z, target.z, VIS_SMOOTH)

	vis_cvars.viewmodel_fov:float(vis_state.vm_smooth.fov, true)
	vis_cvars.viewmodel_x:float(vis_state.vm_smooth.x, true)
	vis_cvars.viewmodel_y:float(vis_state.vm_smooth.y, true)
	vis_cvars.viewmodel_z:float(vis_state.vm_smooth.z, true)
end

visuals_run = function()
	vis_apply_aspect()
	vis_apply_viewmodel()

	if vis_setup.scope:get() then
		if vis_refs.scope_overlay then vis_refs.scope_overlay:override("Remove All") end
	else
		if vis_refs.scope_overlay then vis_refs.scope_overlay:override() end
	end

	local me = entity.get_local_player()
	if vis_setup.scope:get() or vis_state.scope_alpha > 0.01 then
		vis_draw_scope(me)
	end

	vis_draw_watermark()
	vis_draw_damage()
	vis_draw_hitmarkers()
	vis_draw_world()
end

visuals_on_player_hurt = function(e)
	if not vis_setup.hitmarker:get() then return end

	local me = entity.get_local_player()
	if not me then return end

	local attacker = entity.get(e.attacker, true)
	if attacker ~= me then return end

	local victim = entity.get(e.userid, true)
	if not victim or victim == me then return end

	local damage = e.dmg_health or 0
	local headshot = e.hitgroup == 1
	local kill = (e.health or 0) <= 0
	local entry = vis_hitmarker_spawn(false, nil, damage, headshot, kill)
	local place = vis_setup.hitmarker_place:get()

	if place == "Screen" or place == "Both" then
		entry.screen = true
		vis_state.hitmarker_screen = entry
	end

	if place == "World" or place == "Both" then
		local pos = vis_hitmarker_world_pos(victim, e.hitgroup)
		if pos then
			local world_entry = vis_hitmarker_spawn(false, pos, damage, headshot, kill)
			vis_state.hitmarkers[#vis_state.hitmarkers + 1] = world_entry
		end
	end
end

visuals_shutdown = function()
	if shared_shutdown_icons then shared_shutdown_icons() end
	shared_run_legacy_cleanup()

	if vis_refs.scope_overlay then vis_refs.scope_overlay:override() end

	if vis_state.aspect_saved ~= nil then
		vis_cvars.aspect:float(vis_state.aspect_saved, true)
		vis_state.aspect_saved = nil
	elseif vis_setup.aspect and not vis_setup.aspect:get() then
		vis_cvars.aspect:float(tonumber(vis_cvars.aspect:string()) or 0, true)
	end
	vis_state.aspect_smooth = nil

	if vis_state.vm_saved then
		vis_cvars.viewmodel_fov:float(vis_state.vm_saved.fov, false)
		vis_cvars.viewmodel_x:float(vis_state.vm_saved.x, false)
		vis_cvars.viewmodel_y:float(vis_state.vm_saved.y, false)
		vis_cvars.viewmodel_z:float(vis_state.vm_saved.z, false)
		vis_state.vm_saved = nil
	end
	vis_state.vm_smooth = nil
end

end
init_visuals()

-- ── Misc Module ──
local function init_misc()

local misc_refs = MISC.refs
misc_refs.fake_latency   = NL.ui.find("Miscellaneous", "Main", "Other", "Fake Latency")
misc_refs.weapon_actions = NL.ui.find("Miscellaneous", "Main", "Other", "Weapon Actions")
misc_refs.air_strafe     = NL.ui.find("Miscellaneous", "Main", "Movement", "Air Strafe")
misc_refs.strafe_assist  = NL.ui.find("Miscellaneous", "Main", "Movement", "Strafe Assist")
misc_refs.fake_duck      = NL.ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck")
misc_refs.clan_tag       = NL.ui.find("Miscellaneous", "Main", "In-Game", "Clan Tag")
misc_refs.log_events     = NL.ui.find("Miscellaneous", "Main", "Other", "Log Events")
misc_refs.hideshots      = NL.ui.find("Aimbot", "Ragebot", "Main", "Hide Shots")
misc_refs.hideshot_config = NL.ui.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options")
misc_refs.doubletap      = NL.ui.find("Aimbot", "Ragebot", "Main", "Double Tap")
misc_refs.peek_assist    = NL.ui.find("Aimbot", "Ragebot", "Main", "Peek Assist")
misc_refs.peek_retreat   = NL.ui.find("Aimbot", "Ragebot", "Main", "Peek Assist", "Retreat Mode")
misc_refs.min_damage     = NL.ui.find("Aimbot", "Ragebot", "Selection", "Min. Damage")
misc_refs.hitchance      = NL.ui.find("Aimbot", "Ragebot", "Selection", "Hit Chance")
misc_refs.autostop_opts  = NL.ui.find("Aimbot", "Ragebot", "Accuracy", "Auto Stop", "Options")
misc_refs.force_shot_hitchance = {}
misc_refs.force_shot_delay     = {}
misc_refs.ia_peek_weapons = {}

local function misc_sync_native_log_events()
	if not misc_refs.log_events then return end
	misc_refs.log_events:override("")
end

local MOVETYPE_LADDER = 9
local WEAPON_TYPE_GRENADE = 9
local KNIFE_INDICES = { 43, 44, 45, 46, 47, 48 }

local misc_state = MISC.state
misc_state.clantag_frames = nil
misc_state.clantag_index = nil
misc_state.clantag_last = nil
misc_state.nade_release_tick = nil
misc_state.nade_release_angles = nil
misc_state.nade_release_lock_until = 0
misc_state.nade_release_hold_until = 0
misc_state.nade_release_weapon = nil
misc_state.nade_release_buttons = {
	attack = false,
	attack2 = false,
}
misc_state.no_fall_duck = false
misc_state.freeze_fd_tick = 0
misc_state.ia_peek_plan = nil
misc_state.ia_peek_rate_cd = 0
misc_state.ia_peek_retreat_pos = nil
misc_state.ia_peek_jump_active = false
misc_state.ia_peek_jump_ctx = nil
misc_state.ia_peek_jump_started = 0
misc_state.ia_peek_jump_phase_at = 0
misc_state.ia_peek_jump_shot = false
misc_state.ia_peek_jump_dt_off = false
misc_state.ia_peek_jump_retry = false
misc_state.ia_peek_jump_retry_at = 0
misc_state.ia_peek_jump_retry_wait = false
misc_state.opt_cvars_saved = {}
misc_state.opt_cvars_active = false
misc_state.force_shot_active_delay = nil

local MISC_FORCE_SHOT_HC = 0
local MISC_FORCE_SHOT_WEAPONS = {
	"Auto Snipers", "AWP", "Scout", "SSG-08", "Desert Eagle",
	"Pistols", "SMG", "Rifles", "Revolver R8",
}

local function misc_init_force_shot_refs()
	misc_refs.force_shot_hitchance = {}
	misc_refs.force_shot_delay = {}

	for i = 1, #MISC_FORCE_SHOT_WEAPONS do
		local name = MISC_FORCE_SHOT_WEAPONS[i]
		local ok, hc_ref = pcall(ui.find, "Aimbot", "Ragebot", "Selection", name, "Hit Chance")
		if ok and hc_ref then
			misc_refs.force_shot_hitchance[name] = hc_ref
		end

		local ok2, delay_ref = pcall(ui.find, "Aimbot", "Ragebot", "Selection", name, "Min. damage", "Delay shot")
		if ok2 and delay_ref then
			misc_refs.force_shot_delay[name] = delay_ref
		end
	end
end

misc_init_force_shot_refs()

local function misc_init_ia_peek_weapon_refs()
	local function add_weapon(name)
		local ok_sel, refs = pcall(function()
			return {
				head_scale = ui.find("Aimbot", "Ragebot", "Selection", name, "Multipoint", "Head Scale"),
				body_scale = ui.find("Aimbot", "Ragebot", "Selection", name, "Multipoint", "Body Scale"),
				hit_chance = ui.find("Aimbot", "Ragebot", "Selection", name, "Hit Chance"),
				body_aim = ui.find("Aimbot", "Ragebot", "Safety", name, "Body Aim"),
				safe_points = ui.find("Aimbot", "Ragebot", "Safety", name, "Safe Points"),
				ensure_hitbox = ui.find("Aimbot", "Ragebot", "Safety", name, "Ensure Hitbox Safety"),
			}
		end)
		if ok_sel and refs then
			misc_refs.ia_peek_weapons[name] = refs
		end
	end
	add_weapon("SSG-08")
	add_weapon("Desert Eagle")
	add_weapon("Pistols")
end
misc_init_ia_peek_weapon_refs()

-- Performance cvars applied by Optimize CVars (name â†’ optimized value).
local MISC_OPT_CVAR_VALUES = {
	violence_hblood = 0,
	r_drawdecals = 0,
	r_drawropes = 0,
	r_drawsprites = 0,
	r_drawparticles = 0,
	r_drawrain = 0,
	r_drawtracers_firstperson = 0,
	mat_disable_bloom = 1,
	mat_disable_fancy_blending = 1,
	dsp_slow_cpu = 1,
	func_break_max_pieces = 0,
	props_break_max_pieces = 0,
	r_shadows = 0,
	cl_csm_static_prop_shadows = 0,
	cl_csm_shadows = 0,
	cl_csm_world_shadows = 0,
	cl_foot_contact_shadows = 0,
	cl_csm_viewmodel_shadows = 0,
	cl_csm_rope_shadows = 0,
	cl_csm_sprite_shadows = 0,
	cl_csm_translucent_shadows = 0,
	cl_csm_entity_shadows = 0,
	cl_csm_world_shadows_in_viewmodelcascade = 0,
	muzzleflash_light = 0,
	r_eyemove = 0,
	r_eyegloss = 0,
	r_dynamic = 0,
	r_dynamiclighting = 0,
	cl_disable_ragdolls = 1,
	cl_disablefreezecam = 1,
	cl_disablehtmlmotd = 1,
	fog_enable = 0,
	fog_enable_water_fog = 0,
	mat_queue_mode = 2,
}

local function misc_opt_cvar_read(ref)
	local ok, val = pcall(function() return ref:int() end)
	if ok and val ~= nil then return val end
	ok, val = pcall(function() return ref:float() end)
	if ok and val ~= nil then return val end
	return nil
end

local function misc_opt_cvar_write(ref, value)
	pcall(function() ref:int(value, true) end)
	pcall(function() ref:float(value, true) end)
end

local function misc_apply_opt_cvars(enable)
	if not misc_state.opt_cvars_saved then
		misc_state.opt_cvars_saved = {}
	end

	for name, target in pairs(MISC_OPT_CVAR_VALUES) do
		local ref = cvar[name]
		if ref then
			if enable then
				if misc_state.opt_cvars_saved[name] == nil then
					misc_state.opt_cvars_saved[name] = misc_opt_cvar_read(ref)
				end
				misc_opt_cvar_write(ref, target)
			else
				local old = misc_state.opt_cvars_saved[name]
				if old ~= nil then
					misc_opt_cvar_write(ref, old)
					misc_state.opt_cvars_saved[name] = nil
				end
			end
		end
	end

	if not enable then
		misc_state.opt_cvars_saved = {}
	end
	misc_state.opt_cvars_active = enable
end

local function misc_on_optimize_cvars()
	if not misc_setup.optimize_cvars then return end

	local on = misc_setup.optimize_cvars:get()
	if on and not misc_state.opt_cvars_active then
		misc_apply_opt_cvars(true)
	elseif not on and misc_state.opt_cvars_active then
		misc_apply_opt_cvars(false)
	end
end

local function misc_restore_opt_cvars()
	if misc_state.opt_cvars_active then
		misc_apply_opt_cvars(false)
	end
end

if misc_setup.optimize_cvars then
	misc_setup.optimize_cvars:set_callback(misc_on_optimize_cvars, true)
end

local function misc_clamp(v, min_v, max_v)
	return math.max(min_v, math.min(max_v, v))
end

local DEFAULT_CLANTAG_FRAMES = {
	"", "g|", ".gl", "glo/", "_glob", "global<", ">global_v", "global_", "/global", "globa|", "_glob",
	"glo/", "<gl", ".g", ""
}

local function misc_build_clantag_frames(text)
	if not text or text == "" then
		return DEFAULT_CLANTAG_FRAMES
	end

	local frames = { "" }
	for i = 1, #text do
		table.insert(frames, text:sub(1, i))
	end
	for _ = 1, 5 do
		table.insert(frames, text)
	end
	for i = 1, #text do
		table.insert(frames, text:sub(i, #text))
	end
	table.insert(frames, "")
	return frames
end

local function misc_refresh_clantag_frames()
	local mode = misc_setup.clantag_mode and misc_setup.clantag_mode:get() or "Default"
	if mode == "Default" then
		misc_state.clantag_frames = DEFAULT_CLANTAG_FRAMES
	else
		local text = misc_setup.clantag_text and misc_setup.clantag_text:get() or ""
		if text == "" then
			text = "shinymoon"
		end
		misc_state.clantag_frames = misc_build_clantag_frames(text)
	end
	misc_state.clantag_index = nil
end

if misc_setup.clantag_text then
	misc_setup.clantag_text:set_callback(function()
		if misc_setup.update_clantag_ui then misc_setup.update_clantag_ui() end
		misc_refresh_clantag_frames()
	end, true)
end
if misc_setup.clantag_mode then
	misc_setup.clantag_mode:set_callback(function()
		if misc_setup.update_clantag_ui then misc_setup.update_clantag_ui() end
		misc_refresh_clantag_frames()
	end, true)
end
if misc_setup.clantag then
	misc_setup.clantag:set_callback(function()
		if misc_setup.update_clantag_ui then misc_setup.update_clantag_ui() end
		misc_refresh_clantag_frames()
	end, true)
end
misc_refresh_clantag_frames()

local function misc_has_knife(weapon)
	if not weapon then return false end
	local idx = weapon:get_weapon_index()
	for i = 1, #KNIFE_INDICES do
		if idx == KNIFE_INDICES[i] then
			return true
		end
	end
	return false
end

local function misc_near_ground(me, height)
	local origin = me:get_origin()
	if not origin or not utils or not utils.trace_line then
		return false
	end

	for angle = 0, math.pi * 2 - 0.01, math.pi * 2 / 8 do
		local offset = vector(10 * math.cos(angle), 10 * math.sin(angle), 0)
		local start_pos = origin + offset
		local end_pos = start_pos - vector(0, 0, height)
		local trace = utils.trace_line(start_pos, end_pos, me)
		if trace and trace.fraction ~= 1 then
			return true
		end
	end
	return false
end

local function misc_is_grenade_weapon(weapon)
	if not weapon then return false end

	local weapon_info = weapon:get_weapon_info()
	if weapon_info and weapon_info.weapon_type == WEAPON_TYPE_GRENADE then
		return true, weapon_info
	end

	local idx = weapon:get_weapon_index()
	return idx == 43 or idx == 44 or idx == 45 or idx == 46 or idx == 47 or idx == 48, weapon_info
end

local function misc_reset_nade_release()
	misc_state.nade_release_tick = nil
	misc_state.nade_release_angles = nil
	misc_state.nade_release_lock_until = 0
	misc_state.nade_release_hold_until = 0
	misc_state.nade_release_weapon = nil
	misc_state.nade_release_buttons.attack = false
	misc_state.nade_release_buttons.attack2 = false
end

local function misc_copy_angles(angles)
	if not angles then return nil end
	return vector(angles.x or 0, angles.y or 0, angles.z or 0)
end

local function misc_super_toss_angles(view_angles, throw_velocity, throw_strength, velocity)
	if not view_angles then return view_angles end

	local pitch = view_angles.x or 0
	pitch = pitch - 10 + math.abs(pitch) / 9

	local throw_dir = vector():angles(vector(pitch, view_angles.y or 0, 0))
	local scaled_vel = misc_clamp((throw_velocity or 0) * 0.9, 15, 750)
	scaled_vel = scaled_vel * (0.3 + 0.7 * misc_clamp(throw_strength or 0, 0, 1))
	local vel_offset = (velocity or vector()) * 1.25

	local solved = throw_dir
	for _ = 1, 8 do
		solved = (throw_dir * (solved * scaled_vel + vel_offset):length() - vel_offset) / scaled_vel
		solved:normalize()
	end

	local result = solved:angles()
	if result.x > -10 then
		result.x = 0.9 * result.x + 9
	else
		result.x = 1.125 * result.x + 11.25
	end
	return result
end

local function misc_on_fast_ladder(cmd, me)
	if not misc_setup.fast_ladder:get() or not cmd or not me then return end
	if me.m_MoveType ~= MOVETYPE_LADDER then return end

	local weapon = me:get_player_weapon()
	if misc_has_knife(weapon) then return end

	local ladder_normal = me.m_vecLadderNormal
	if not ladder_normal then return end

	local ladder_yaw = ladder_normal:angles().y
	cmd.view_angles.x = 89
	cmd.view_angles.y = ladder_yaw + 90

	if cmd.forwardmove > 0 then
		cmd.in_forward = 0
		cmd.in_back = 1
		cmd.in_moveleft = 1
		cmd.in_moveright = 0
	elseif cmd.forwardmove < 0 then
		cmd.in_forward = 1
		cmd.in_back = 0
		cmd.in_moveleft = 0
		cmd.in_moveright = 1
	end
end

local function misc_on_no_fall(cmd, me)
	if not misc_setup.no_fall:get() or not cmd or not me then return end

	local vel_z = me.m_vecVelocity and me.m_vecVelocity.z or 0
	if vel_z >= -500 then
		misc_state.no_fall_duck = false
	elseif misc_near_ground(me, 15) then
		misc_state.no_fall_duck = false
	elseif misc_near_ground(me, 75) then
		misc_state.no_fall_duck = true
	end

	if vel_z < -500 then
		cmd.in_duck = misc_state.no_fall_duck
	end
end

local function misc_on_unlock_fakeduck(cmd)
	if not misc_setup.unlock_fd:get() or not cmd then return end
	if not misc_refs.fake_duck or not misc_refs.fake_duck:get() then return end

	local move = vector(cmd.forwardmove, cmd.sidemove, 0)
	if move:length() < 2 then return end

	move:normalize()
	cmd.forwardmove = move.x * 150
	cmd.sidemove = move.y * 150
end

local function misc_on_freezetime_fakeduck(cmd)
	if not misc_setup.freeze_fd:get() or not cmd then return end
	if not misc_refs.fake_duck or not misc_refs.fake_duck:get() then return end

	local rules = entity.get_game_rules()
	if not rules or not rules.m_bFreezePeriod then
		if misc_refs.hideshots then misc_refs.hideshots:override() end
		if misc_refs.doubletap then misc_refs.doubletap:override() end
		return
	end

	misc_state.freeze_fd_tick = misc_state.freeze_fd_tick + 1
	if misc_state.freeze_fd_tick >= 14 then
		misc_state.freeze_fd_tick = 0
	end

	cmd.in_duck = misc_state.freeze_fd_tick > 7
	cmd.send_packet = misc_state.freeze_fd_tick == 14

	if misc_refs.hideshots then misc_refs.hideshots:override(false) end
	if misc_refs.doubletap then misc_refs.doubletap:override(false) end
end

local function misc_on_air_duck_collision(cmd, me)
	if not misc_setup.air_duck:get() or not cmd or not me then return end

	local vel = me.m_vecVelocity
	if not vel or vel.x < 30 or vel.z <= 0 then return end

	local sim = me:simulate_movement()
	if not sim then return end

	sim:think()
	if sim.did_hit_collision then
		cmd.in_duck = true
	end
end

local function misc_on_super_toss_cmd(cmd, me)
	if misc_refs.air_strafe then misc_refs.air_strafe:override() end
	if misc_refs.strafe_assist then misc_refs.strafe_assist:override() end
	if misc_refs.weapon_actions then misc_refs.weapon_actions:override() end

	if not misc_setup.super_toss:get() or not cmd or not me or not me:is_alive() then return end
	if cmd.jitter_move ~= true then return end

	local weapon = me:get_player_weapon()
	local is_grenade, weapon_info = misc_is_grenade_weapon(weapon)
	if not is_grenade or not weapon_info then return end

	local clock_adj = 0
	pcall(function() clock_adj = to_time(globals.clock_offset) end)
	if (weapon.m_fThrowTime or 0) < (globals.curtime or 0) - clock_adj then
		return
	end

	local sim_vel = me.m_vecVelocity
	local sim = me:simulate_movement()
	if sim then
		sim:think()
		sim_vel = sim.velocity or sim_vel
	end

	cmd.in_speed = true
	cmd.view_angles = misc_super_toss_angles(
		cmd.view_angles,
		weapon_info.throw_velocity,
		weapon.m_flThrowStrength,
		sim_vel
	)

	if misc_refs.air_strafe then misc_refs.air_strafe:override(false) end
	if misc_refs.strafe_assist then misc_refs.strafe_assist:override(false) end
	if misc_refs.weapon_actions then misc_refs.weapon_actions:override("") end
end

local function misc_on_super_toss_view(data)
	if not misc_setup.super_toss:get() then return end

	local me = entity.get_local_player()
	if not me or not me:is_alive() or not data or not data.angles then return end

	local weapon = me:get_player_weapon()
	local is_grenade, weapon_info = misc_is_grenade_weapon(weapon)
	if not is_grenade or not weapon_info then return end

	data.angles = misc_super_toss_angles(
		data.angles,
		weapon_info.throw_velocity,
		weapon.m_flThrowStrength,
		data.velocity or me.m_vecVelocity
	)
end

local function misc_on_nade_release(cmd, me)
	if not misc_setup.nade_release:get() or not cmd or not me or not me:is_alive() then
		misc_reset_nade_release()
		return
	end

	local weapon = me:get_player_weapon()
	local is_grenade, weapon_info = misc_is_grenade_weapon(weapon)
	if not is_grenade or not weapon_info then
		misc_reset_nade_release()
		return
	end

	local tick = globals.tickcount or 0
	local weapon_index = weapon:get_weapon_index()
	local prediction_active = misc_state.nade_release_tick ~= nil
		and misc_state.nade_release_angles ~= nil
		and tick - misc_state.nade_release_tick >= 0
		and tick - misc_state.nade_release_tick <= 2

	if prediction_active then
		if misc_state.nade_release_lock_until <= tick
			or misc_state.nade_release_weapon ~= weapon_index
			or misc_state.nade_release_angles == nil
		then
			misc_state.nade_release_buttons.attack = cmd.in_attack or false
			misc_state.nade_release_buttons.attack2 = cmd.in_attack2 or false
			if not misc_state.nade_release_buttons.attack and not misc_state.nade_release_buttons.attack2 then
				misc_state.nade_release_buttons.attack = true
			end
			misc_state.nade_release_hold_until = tick + 2
		end

		misc_state.nade_release_weapon = weapon_index
		misc_state.nade_release_lock_until = tick + 16
	elseif misc_state.nade_release_lock_until > 0 and tick > misc_state.nade_release_lock_until then
		misc_reset_nade_release()
	end

	local release_locked = misc_state.nade_release_lock_until > tick
		and misc_state.nade_release_weapon == weapon_index
		and misc_state.nade_release_angles ~= nil
	local release_active = prediction_active or release_locked
	if not release_active then return end

	cmd.view_angles = misc_copy_angles(misc_state.nade_release_angles)
	if misc_setup.super_toss:get() then
		cmd.view_angles = misc_super_toss_angles(
			cmd.view_angles,
			weapon_info.throw_velocity,
			weapon.m_flThrowStrength,
			me.m_vecVelocity
		)
	end

	if weapon.m_bPinPulled or (weapon.m_fThrowTime or 0) > 0 then
		if tick <= misc_state.nade_release_hold_until and (weapon.m_fThrowTime or 0) == 0 then
			cmd.in_attack = misc_state.nade_release_buttons.attack
			cmd.in_attack2 = misc_state.nade_release_buttons.attack2
		else
			cmd.in_attack = false
			cmd.in_attack2 = false
		end
	else
		misc_reset_nade_release()
	end
end

local function misc_on_nade_prediction(data)
	if not misc_setup.nade_release:get() or not data then
		misc_state.nade_release_tick = nil
		misc_state.nade_release_angles = nil
		return
	end

	local tick = globals.tickcount or 0
	if misc_state.nade_release_tick ~= nil and misc_state.nade_release_tick ~= tick then
		misc_state.nade_release_tick = nil
		misc_state.nade_release_angles = nil
	end

	local damage = tonumber(data.damage) or 0
	local min_damage = misc_setup.nade_release_hp and misc_setup.nade_release_hp:get() or 50
	if data.fatal or damage >= min_damage then
		misc_state.nade_release_tick = tick
		misc_state.nade_release_angles = render.camera_angles()
	end
end

-- ── IA Peek ───────────────────────────────────────────────────────────────
local IA_PEEK_FL_ONGROUND = bit.lshift(1, 0)
local IA_PEEK_HITBOX = {
	head = 0, chest = 5, stomach = 3,
	l_arm = 17, r_arm = 15, l_leg = 8, r_leg = 7, l_foot = 9, r_foot = 10,
}
local IA_PEEK_ALL_HITBOXES = {
	IA_PEEK_HITBOX.head, IA_PEEK_HITBOX.chest, IA_PEEK_HITBOX.stomach,
	IA_PEEK_HITBOX.l_arm, IA_PEEK_HITBOX.r_arm,
	IA_PEEK_HITBOX.l_leg, IA_PEEK_HITBOX.r_leg,
	IA_PEEK_HITBOX.l_foot, IA_PEEK_HITBOX.r_foot,
}
local IA_PEEK_SCAN_RANGE = 20
local IA_PEEK_RETREAT_DIST = 25
local IA_PEEK_RETREAT_DIST_MIN = 12
local IA_PEEK_DANGER_RADIUS = 1100
local IA_PEEK_PUSH_MIN = 0.35
local IA_PEEK_PUSH_ARRIVE_SQR = 64
local IA_PEEK_GROUP = {
	[IA_PEEK_HITBOX.head] = 1,
	[IA_PEEK_HITBOX.chest] = 2,
	[IA_PEEK_HITBOX.stomach] = 3,
	[IA_PEEK_HITBOX.l_leg] = 7,
	[IA_PEEK_HITBOX.r_leg] = 8,
	[IA_PEEK_HITBOX.l_foot] = 9,
	[IA_PEEK_HITBOX.r_foot] = 10,
	[IA_PEEK_HITBOX.l_arm] = 7,
	[IA_PEEK_HITBOX.r_arm] = 8,
}
local IA_PEEK_WEAPON_TYPES = {
	[1] = "Desert Eagle", [2] = "Pistol", [3] = "Pistol", [4] = "Pistol",
	[7] = "Rifle", [8] = "Rifle", [9] = "AWP", [10] = "Rifle",
	[11] = "Autoscoutr", [13] = "Rifle", [14] = "Machine Gun", [16] = "Rifle",
	[17] = "SMG", [19] = "SMG", [23] = "SMG", [24] = "SMG", [25] = "Shotgun",
	[26] = "SMG", [27] = "Shotgun", [28] = "Machine Gun", [29] = "Shotgun",
	[30] = "Pistol", [31] = "Zeus x27", [32] = "Pistol", [33] = "SMG",
	[34] = "SMG", [35] = "Shotgun", [36] = "Pistol", [38] = "Autoscoutr",
	[39] = "Rifle", [40] = "SSG 08", [43] = "Nades", [44] = "Nades",
	[45] = "Nades", [46] = "Nades", [47] = "Nades", [48] = "Nades",
	[60] = "Rifle", [61] = "Pistol", [63] = "Pistol", [64] = "R8 Revolver",
}

local function ia_peek_weapon_type(idx)
	return IA_PEEK_WEAPON_TYPES[idx] or "Other"
end

local function ia_peek_set_movement_refs(active)
	if active then
		if misc_refs.air_strafe then misc_refs.air_strafe:override(false) end
		if misc_refs.strafe_assist then misc_refs.strafe_assist:override(false) end
	else
		if misc_refs.air_strafe then misc_refs.air_strafe:override() end
		if misc_refs.strafe_assist then misc_refs.strafe_assist:override() end
	end
end

local function ia_peek_reset_state()
	misc_state.ia_peek_plan = nil
	misc_state.ia_peek_rate_cd = 0
	misc_state.ia_peek_retreat_pos = nil
	misc_state.ia_peek_jump_active = false
	misc_state.ia_peek_jump_ctx = nil
	misc_state.ia_peek_jump_started = 0
	misc_state.ia_peek_jump_phase_at = 0
	misc_state.ia_peek_jump_shot = false
	misc_state.ia_peek_jump_dt_off = false
	misc_state.ia_peek_jump_retry = false
	misc_state.ia_peek_jump_retry_at = 0
	misc_state.ia_peek_jump_retry_wait = false
	ia_peek_set_movement_refs(false)
end

local function ia_peek_reset_rage_refs()
	if misc_refs.peek_retreat then misc_refs.peek_retreat:override() end
	if misc_refs.air_strafe then misc_refs.air_strafe:override() end
	if misc_refs.strafe_assist then misc_refs.strafe_assist:override() end
	if misc_refs.autostop_opts then misc_refs.autostop_opts:override() end
	if misc_refs.doubletap then misc_refs.doubletap:override() end
	for _, refs in pairs(misc_refs.ia_peek_weapons or {}) do
		if refs.head_scale then refs.head_scale:override() end
		if refs.body_scale then refs.body_scale:override() end
		if refs.hit_chance then refs.hit_chance:override() end
		if refs.body_aim then refs.body_aim:override() end
		if refs.safe_points then refs.safe_points:override() end
		if refs.ensure_hitbox then refs.ensure_hitbox:override() end
	end
end

local function ia_peek_reset_refs()
	ia_peek_reset_rage_refs()
	if misc_refs.peek_assist then misc_refs.peek_assist:override() end
end

local function ia_peek_sync_peek_assist()
	if misc_setup.ia_peek:get() and misc_refs.peek_assist then
		misc_refs.peek_assist:override(true)
	end
end

local function ia_peek_push_enabled()
	return misc_setup.ia_peek_push_disarm and misc_setup.ia_peek_push_disarm:get()
end

local function ia_peek_retreat_dist()
	return IA_PEEK_RETREAT_DIST
end

local function ia_peek_plan_valid(plan)
	if not plan or not plan.target then return false end
	local ok, alive = pcall(function()
		return not plan.target:is_dormant()
	end)
	return ok and alive
end

local function ia_peek_apply_rage(aggression)
	local hc = misc_setup.ia_peek_hit_chance and misc_setup.ia_peek_hit_chance:get() or 0
	local unsafe = misc_setup.ia_peek_unsafety and misc_setup.ia_peek_unsafety:get()
	if ia_peek_push_enabled() and aggression and aggression >= 0.65 then
		unsafe = true
	end
	if misc_refs.peek_retreat then misc_refs.peek_retreat:override("On Shot") end
	for _, refs in pairs(misc_refs.ia_peek_weapons or {}) do
		if hc ~= 0 and refs.hit_chance then refs.hit_chance:override(hc) end
		if unsafe then
			if refs.head_scale then refs.head_scale:override(100) end
			if refs.body_scale then refs.body_scale:override(100) end
			if refs.body_aim then refs.body_aim:override("Default") end
			if refs.safe_points then refs.safe_points:override("Default") end
			if refs.ensure_hitbox then refs.ensure_hitbox:override({}) end
		end
	end
end

local function ia_peek_group_scale(group)
	if group == 1 then return 4 end
	if group == 3 then return 1.25 end
	if group == 7 or group == 8 then return 0.75 end
	return 1
end

local function ia_peek_apply_armor(enemy, dmg, group, armor_ratio)
	dmg = dmg * ia_peek_group_scale(group)
	if (enemy.m_ArmorValue or 0) > 0 then
		if group == 1 then
			if enemy.m_bHasHelmet then
				dmg = dmg * (armor_ratio * 0.5)
			end
		else
			dmg = dmg * (armor_ratio * 0.5)
		end
	end
	return dmg
end

local function ia_peek_estimate_dmg(from, to, enemy, group, wpn_info)
	local dist = (to - from):length()
	local damage = wpn_info.damage or 0
	local armor_ratio = wpn_info.armor_ratio or 1
	local range = wpn_info.range or 8192
	local range_mod = wpn_info.range_modifier or 1
	local scaled = math.min(range, dist)
	damage = damage * math.pow(range_mod, scaled * 0.002)
	return ia_peek_apply_armor(enemy, damage, group, armor_ratio)
end

local function ia_peek_sim_time()
	local v = misc_setup.ia_peek_sim_time and misc_setup.ia_peek_sim_time:get() or 280
	if v < 100 then v = v * 10 end
	return v * 0.001
end

local function ia_peek_rate_limit()
	local v = misc_setup.ia_peek_rate_limit and misc_setup.ia_peek_rate_limit:get() or 20
	if v > 0 and v <= 50 then v = v * 10 end
	return v * 0.001
end

local function ia_peek_enemy_holding_knife(weapon)
	if not weapon then return false end
	local ok, classname = pcall(function() return weapon:get_classname() end)
	return ok and classname and classname:find("Knife") ~= nil
end

local function ia_peek_enemy_can_fire(enemy, weapon, curtime)
	if not enemy or not weapon then return false end
	local tick = globals.tickinterval or (1 / 64)
	if ia_peek_enemy_holding_knife(weapon) then return false end
	if misc_is_grenade_weapon(weapon) then return false end
	if weapon_is_reloading(weapon) then return false end
	if (enemy.m_flNextAttack or 0) > curtime then return false end
	local next_primary = weapon.m_flNextPrimaryAttack or 0
	if next_primary > curtime + tick then return false end
	local wpn_info = weapon:get_weapon_info()
	if wpn_info and wpn_info.max_clip1 and wpn_info.max_clip1 > 0 then
		if (weapon.m_iClip1 or 0) <= 0 and next_primary > curtime then return false end
	end
	return true
end

local function ia_peek_target_vulnerability(enemy, curtime)
	if not enemy then return 0, "none" end

	local weapon = enemy:get_player_weapon(false)
	local tick = globals.tickinterval or (1 / 64)
	local score, reason = 0, "none"

	if not weapon then
		return 0.9, "no weapon"
	end

	if ia_peek_enemy_holding_knife(weapon) then
		return 1.0, "knife"
	end

	local is_nade = misc_is_grenade_weapon(weapon)
	if is_nade then
		if weapon.m_bPinPulled or (weapon.m_fThrowTime or 0) > 0 then
			return 1.0, "nade throw"
		end
		score = 0.85
		reason = "nade"
	end

	if weapon_is_reloading(weapon) then
		if 0.95 > score then
			score, reason = 0.95, "reload"
		end
	end

	if (enemy.m_flNextAttack or 0) > curtime then
		if 0.8 > score then
			score, reason = 0.8, "swap"
		end
	end

	local wpn_info = weapon:get_weapon_info()
	if wpn_info and wpn_info.max_clip1 and wpn_info.max_clip1 > 0 then
		if (weapon.m_iClip1 or 0) <= 0 then
			if 0.9 > score then
				score, reason = 0.9, "empty"
			end
		end
	end

	if not is_nade then
		local next_primary = weapon.m_flNextPrimaryAttack or 0
		if next_primary > curtime + tick then
			local wait = next_primary - curtime
			local cooldown_score = math.max(0.5, 0.85 - wait * 0.5)
			if cooldown_score > score then
				score, reason = cooldown_score, "cooldown"
			end
		end
	end

	return score, reason
end

local function ia_peek_enemy_can_hit_pos(enemy, target_pos)
	if not enemy or not target_pos then return false, 0 end

	local eye = enemy:get_eye_position()
	if not eye then return false, 0 end

	if utils and utils.trace_bullet then
		local dmg = utils.trace_bullet(enemy, eye, target_pos, function(ent)
			return ent ~= enemy
		end)
		if dmg and dmg > 0 then
			return true, 0.9
		end
	end

	if utils and utils.trace_line then
		local trace = utils.trace_line(eye, target_pos, enemy)
		if trace and trace.fraction >= 0.97 then
			return true, 0.75
		end
	end

	return false, 0
end

local function ia_peek_dangerous_enemies(me, focus, peek_pos, curtime)
	local danger_count = 0
	local max_danger = 0

	if not me or not entity.get_players then
		return danger_count, max_danger
	end

	local my_origin = me:get_origin()
	local players = entity.get_players(true)
	if not my_origin or not players then
		return danger_count, max_danger
	end

	local check_pos = peek_pos or my_origin

	for i = 1, #players do
		local enemy = players[i]
		if enemy and enemy ~= me and enemy ~= focus and enemy:is_alive() and enemy:is_enemy() and not enemy:is_dormant() then
			local origin = enemy:get_origin()
			if origin and my_origin:dist(origin) < IA_PEEK_DANGER_RADIUS then
				local weapon = enemy:get_player_weapon(false)
				if ia_peek_enemy_can_fire(enemy, weapon, curtime) then
					local hit_peek, d_peek = ia_peek_enemy_can_hit_pos(enemy, check_pos)
					local hit_me, d_me = ia_peek_enemy_can_hit_pos(enemy, my_origin)
					if hit_peek or hit_me then
						danger_count = danger_count + 1
						local d = math.max(d_peek, d_me)
						if d > max_danger then
							max_danger = d
						end
					end
				end
			end
		end
	end

	return danger_count, max_danger
end

local function ia_peek_compute_aggression(me, target, peek_pos)
	if not ia_peek_push_enabled() or not target then
		return 0, 0, 0, "none"
	end

	local curtime = globals.curtime
	local vuln_score, reason = ia_peek_target_vulnerability(target, curtime)
	if vuln_score < IA_PEEK_PUSH_MIN then
		return 0, vuln_score, 0, reason
	end

	local danger_count, max_danger = ia_peek_dangerous_enemies(me, target, peek_pos, curtime)
	local aggression = vuln_score

	if danger_count >= 1 then
		aggression = aggression * (1 - 0.30 * math.min(danger_count, 2))
	end
	if danger_count >= 2 and max_danger >= 0.7 then
		aggression = aggression * 0.55
	end

	aggression = math.max(0, math.min(1, aggression))
	return aggression, vuln_score, danger_count, reason
end

local function ia_peek_update_plan_aggression(me, plan)
	if not plan or not plan.target then return end

	local peek_pos = plan.ctx and plan.ctx.origin or nil
	local aggression, vuln_score, danger_count, reason = ia_peek_compute_aggression(me, plan.target, peek_pos)
	plan.aggression = aggression
	plan.vuln_score = vuln_score
	plan.danger_count = danger_count
	plan.vuln_reason = reason
end

local function ia_peek_effective_sim_time(plan)
	local base = ia_peek_sim_time()
	if not plan or not ia_peek_push_enabled() then return base end

	local aggression = plan.aggression or 0
	if aggression < IA_PEEK_PUSH_MIN then return base end

	return base * (1 - aggression)
end

local function ia_peek_effective_retreat_dist(plan)
	local base = ia_peek_retreat_dist()
	if not plan or not ia_peek_push_enabled() then return base end

	local aggression = plan.aggression or 0
	if aggression < IA_PEEK_PUSH_MIN then return base end

	return base - (base - IA_PEEK_RETREAT_DIST_MIN) * aggression
end

local function ia_peek_plan_aggression(me)
	local plan = misc_state.ia_peek_plan
	if plan and ia_peek_plan_valid(plan) then
		ia_peek_update_plan_aggression(me, plan)
		return plan.aggression or 0, plan
	end

	local threat = entity.get_threat()
	if threat and not threat:is_dormant() then
		return ia_peek_compute_aggression(me, threat, nil), nil
	end

	return 0, nil
end

local function ia_peek_move_arrive_sqr(plan)
	if plan and ia_peek_push_enabled() and (plan.aggression or 0) >= 0.75 then
		return IA_PEEK_PUSH_ARRIVE_SQR
	end
	return 25
end

local function ia_peek_jump_fire_window(elapsed, timing, prefire, aggression)
	if prefire then
		return elapsed > 0.1
	end
	if aggression and aggression >= 0.75 then
		return elapsed > timing * 0.45
	end
	return elapsed > timing * 0.6
end

local function ia_peek_block_move_type()
	if not misc_setup.ia_peek_block_move then return 1 end
	return misc_setup.ia_peek_block_move:get() == "Full stop" and 2 or 1
end

local function ia_peek_min_damage()
	if misc_refs.min_damage then
		return misc_refs.min_damage:get()
	end
	return 1
end

local function ia_peek_scan_range()
	return IA_PEEK_SCAN_RANGE
end

local function ia_peek_selected_hitboxes()
	return IA_PEEK_ALL_HITBOXES
end

local function ia_peek_weapon_allowed(weapon)
	if not weapon then return false end
	local idx = weapon:get_weapon_index()
	local wtype = ia_peek_weapon_type(idx)
	local filter = misc_setup.ia_peek_weapon_filter
	if not filter then return true end
	for _, name in pairs(filter:get()) do
		if name == wtype then return true end
	end
	return false
end

local function ia_peek_idle_cmd(cmd)
	return not cmd.in_forward and not cmd.in_back and not cmd.in_moveleft and not cmd.in_moveright
end

local function ia_peek_trace_dmg(me, from, to)
	local dmg, trace = utils.trace_bullet(me, from, to, function(ent)
		return ent ~= me and ent:is_enemy()
	end)
	return dmg or 0, trace
end

local function ia_peek_filter_hitboxes(hitboxes, me, weapon, enemy, min_dmg)
	local out = {}
	local eye = me:get_eye_position()
	local wpn_info = weapon:get_weapon_info()
	if not eye or not wpn_info then return out end
	local hp = enemy.m_iHealth or 100
	for i = 1, #hitboxes do
		local hb = hitboxes[i]
		local pos = enemy:get_hitbox_position(hb)
		if pos then
			local est = ia_peek_estimate_dmg(eye, pos, enemy, IA_PEEK_GROUP[hb] or 0, wpn_info)
			if est >= min_dmg or est >= hp then
				table.insert(out, { index = hb, pos = pos })
			end
		end
	end
	return out
end

local function ia_peek_can_trace(me, enemy, eye, points, min_dmg)
	local hp = enemy.m_iHealth or 100
	for i = 1, #points do
		local pt = points[i]
		local dmg = ia_peek_trace_dmg(me, eye, pt.pos)
		if dmg >= min_dmg or dmg >= hp then
			return true
		end
	end
	return false
end

local function ia_peek_can_shoot(me, weapon, wpn_info)
	if not me or not weapon or not wpn_info then return false end
	if wpn_info.max_clip1 == 0 or weapon.m_iClip1 == 0 then return false end
	if globals.curtime < me.m_flNextAttack then return false end
	if globals.curtime < weapon.m_flNextPrimaryAttack then return false end
	if misc_refs.doubletap and misc_refs.doubletap:get() and rage.exploit:get() ~= 1 then return false end
	if weapon:get_weapon_index() == 64 then
		local ready = weapon.m_flPostponeFireReadyTime
		if ready and globals.curtime < ready then return false end
	end
	return true
end

local function ia_peek_new_plan(ctx, target, me)
	local plan = {
		teleport = 0,
		simtime = 0,
		retreat = -1,
		ctx = ctx,
		target = target,
		aggression = 0,
		vuln_score = 0,
		danger_count = 0,
		vuln_reason = "none",
	}
	if me then
		ia_peek_update_plan_aggression(me, plan)
	end
	return plan
end

local function ia_peek_create_sim(me)
	return me:simulate_movement(nil, vector(), 1)
end

local function ia_peek_sim_eye(sim)
	return sim.origin + vector(0, 0, sim.view_offset or 64)
end

local function ia_peek_sim_hit(sim, me, enemy, points, min_dmg)
	local eye = ia_peek_sim_eye(sim)
	return ia_peek_can_trace(me, enemy, eye, points, min_dmg)
end

local function ia_peek_sim_step(cmd, sim, yaw)
	cmd.view_angles.y = yaw
	cmd.move_yaw = yaw
	cmd.forwardmove = 450
	cmd.sidemove = 0
	sim:think(1)
	if bit.band(sim.flags or 0, IA_PEEK_FL_ONGROUND) == 0 then
		return nil, false
	end
	return sim, true
end

local function ia_peek_move_to(cmd, me, target, arrive_sqr)
	local delta = target - me:get_origin()
	local dist2d = delta:length2dsqr()
	arrive_sqr = arrive_sqr or 25
	if dist2d < arrive_sqr then
		local vel = me.m_vecVelocity or vector(0, 0, 0)
		cmd.move_yaw = vel:angles().y
		cmd.forwardmove = -vel:length()
		cmd.sidemove = 0
		return true, dist2d
	end
	cmd.move_yaw = delta:angles().y
	cmd.forwardmove = 450
	cmd.sidemove = 0
	return false, dist2d
end

local function ia_peek_force_forward(cmd)
	cmd.in_duck = false
	cmd.in_speed = false
	cmd.in_forward = true
	cmd.in_back = false
	cmd.in_moveleft = false
	cmd.in_moveright = false
end

local function ia_peek_jump_scan(me, enemy)
	if not misc_setup.ia_peek_jump_scout or not misc_setup.ia_peek_jump_scout:get() then
		return false
	end
	local origin = me:get_origin()
	local max_dist = (misc_setup.ia_peek_jump_range and misc_setup.ia_peek_jump_range:get() or 25) * 50
	if (enemy:get_origin() - origin):length() > max_dist then return false end
	local height = misc_setup.ia_peek_jump_height and misc_setup.ia_peek_jump_height:get() or 30
	local eye_z = me:get_eye_position().z - origin.z
	local aim = origin + vector(0, 0, height) + vector(0, 0, eye_z)
	local dmg, trace = ia_peek_trace_dmg(me, aim, enemy:get_hitbox_position(IA_PEEK_HITBOX.head))
	return dmg > 0 and trace and not trace.hit_sky
end

local function ia_peek_jump_ready(me, weapon)
	if not misc_setup.ia_peek_jump_scout or not misc_setup.ia_peek_jump_scout:get() then
		return false
	end
	if not ia_peek_weapon_allowed(weapon) then return false end
	if misc_setup.ia_peek_force_jump and misc_setup.ia_peek_force_jump:get() then
		return true
	end
	if weapon:get_weapon_index() ~= 40 then return false end
	local threat = entity.get_threat()
	if not threat or threat:is_dormant() then return false end
	local eye = me:get_eye_position()
	local dmg = ia_peek_trace_dmg(me, eye, threat:get_hitbox_position(IA_PEEK_HITBOX.head))
	if dmg > 0 then return false end
	return ia_peek_jump_scan(me, threat)
end

local function ia_peek_scan(cmd, me, weapon)
	local plan = misc_state.ia_peek_plan
	if plan and ia_peek_plan_valid(plan) then
		ia_peek_update_plan_aggression(me, plan)
		local min_dmg = ia_peek_min_damage()
		local target = plan.target
		local hp = target.m_iHealth or 100
		if min_dmg >= 100 then min_dmg = min_dmg + hp - 100 end
		local points = ia_peek_filter_hitboxes(ia_peek_selected_hitboxes(), me, weapon, target, min_dmg)
		local _, hit = ia_peek_sim_hit(plan.ctx, me, target, points, min_dmg)
		if hit then
			plan.simtime = 0
		end
		plan.simtime = plan.simtime + globals.frametime
		return true
	end

	local threat = entity.get_threat()
	local bypass_rate = false
	if ia_peek_push_enabled() and threat and not threat:is_dormant() then
		local vuln_score = select(1, ia_peek_target_vulnerability(threat, globals.curtime))
		if vuln_score >= IA_PEEK_PUSH_MIN then
			local danger_count = select(1, ia_peek_dangerous_enemies(me, threat, nil, globals.curtime))
			if danger_count == 0 then
				bypass_rate = true
			end
		end
	end

	local rate = ia_peek_rate_limit()
	if rate > 0 and not bypass_rate then
		if misc_state.ia_peek_rate_cd > 0 then
			misc_state.ia_peek_rate_cd = misc_state.ia_peek_rate_cd - globals.frametime
			return false
		end
		misc_state.ia_peek_rate_cd = rate
	end

	if not ia_peek_idle_cmd(cmd) then return false end
	if bit.band(me.m_fFlags or 0, IA_PEEK_FL_ONGROUND) == 0 then return false end

	local max_speed = 6400
	local vel = me.m_vecVelocity or vector(0, 0, 0)
	if vel:length2dsqr() > max_speed then return false end

	if not threat or threat:is_dormant() then return false end

	local min_dmg = ia_peek_min_damage()
	local hp = threat.m_iHealth or 100
	if min_dmg >= 100 then min_dmg = min_dmg + hp - 100 end

	local points = ia_peek_filter_hitboxes(ia_peek_selected_hitboxes(), me, weapon, threat, min_dmg)
	local eye = me:get_eye_position()
	if ia_peek_can_trace(me, threat, eye, points, min_dmg) then return false end

	local saved_yaw = cmd.view_angles.y
	local saved_fwd, saved_side = cmd.forwardmove, cmd.sidemove
	local saved_duck, saved_jump, saved_speed = cmd.in_duck, cmd.in_jump, cmd.in_speed
	cmd.forwardmove = 450
	cmd.sidemove = 0
	cmd.in_duck = false
	cmd.in_jump = false
	cmd.in_speed = false

	local away = (threat:get_origin() - me:get_origin()):angles().y + 180
	local dirs = { away - 90, away + 90, away + 180 }
	local sims = { ia_peek_create_sim(me), ia_peek_create_sim(me), ia_peek_create_sim(me) }
	local active = { 0, 0, 0 }

	for tick = 1, ia_peek_scan_range() do
		for i = 1, 3 do
			if active[i] ~= -1 then
				active[i] = tick
				local sim, ok = ia_peek_sim_step(cmd, sims[i], dirs[i])
				if not ok then
					active[i] = -1
				elseif ia_peek_sim_hit(sim, me, threat, points, min_dmg) then
					misc_state.ia_peek_plan = ia_peek_new_plan(sim, threat, me)
					cmd.view_angles.y = saved_yaw
					cmd.forwardmove, cmd.sidemove = saved_fwd, saved_side
					cmd.in_duck, cmd.in_jump, cmd.in_speed = saved_duck, saved_jump, saved_speed
					return true
				end
			end
		end
	end

	cmd.view_angles.y = saved_yaw
	cmd.forwardmove, cmd.sidemove = saved_fwd, saved_side
	cmd.in_duck, cmd.in_jump, cmd.in_speed = saved_duck, saved_jump, saved_speed
	return false
end

local function ia_peek_jump_tick(cmd, me, weapon)
	local threat = entity.get_threat()
	if not threat then return false end

	ia_peek_set_movement_refs(true)

	local now = globals.curtime
	local aggression = select(1, ia_peek_plan_aggression(me))
	local timing = (misc_setup.ia_peek_jump_timing and misc_setup.ia_peek_jump_timing:get() or 3) * 0.1
	if aggression >= 0.75 then
		timing = timing * 0.75
	end
	local prefire = misc_setup.ia_peek_jump_prefire and misc_setup.ia_peek_jump_prefire:get()
	local force = misc_setup.ia_peek_force_jump and misc_setup.ia_peek_force_jump:get()
	local min_dmg = ia_peek_min_damage()
	local points = ia_peek_selected_hitboxes()
	local on_ground = bit.band(me.m_fFlags or 0, IA_PEEK_FL_ONGROUND) ~= 0
	local arrive_sqr = IA_PEEK_PUSH_ARRIVE_SQR
	if aggression < 0.75 then
		arrive_sqr = 100
	end

	if force and ia_peek_idle_cmd(cmd) then
		if not misc_state.ia_peek_jump_active then
			misc_state.ia_peek_jump_active = true
			misc_state.ia_peek_jump_started = now
			misc_state.ia_peek_jump_phase_at = now + 1
			misc_state.ia_peek_jump_shot = false
			misc_state.ia_peek_jump_ctx = {
				peek_completed = false,
				peek_phase = true,
				target = threat,
				start_pos = me:get_origin(),
			}
		end

		local elapsed = now - misc_state.ia_peek_jump_phase_at
		local ctx = misc_state.ia_peek_jump_ctx
		local plan = misc_state.ia_peek_plan

		if ctx and ctx.peek_phase and not ctx.peek_completed and plan and plan.ctx then
			local dist = (plan.ctx.origin - me:get_origin()):length()
			if dist * dist < arrive_sqr then
				ctx.peek_completed = true
				misc_state.ia_peek_jump_phase_at = now
			else
				ia_peek_move_to(cmd, me, plan.ctx.origin, arrive_sqr)
				ia_peek_force_forward(cmd)
				ia_peek_set_movement_refs(true)
				if misc_refs.autostop_opts then
					misc_refs.autostop_opts:override({ "In Air", "Move between Shots" })
				end
				cmd.in_jump = true
				rage.exploit:allow_charge(false)
				utils.execute_after(0.6, function()
					if misc_refs.autostop_opts then misc_refs.autostop_opts:override() end
					rage.exploit:allow_charge(true)
					if misc_refs.doubletap then misc_refs.doubletap:override() end
				end)
				return true
			end
		end

		if ctx and ctx.peek_completed then
			if elapsed < timing then
				local head = threat:get_hitbox_position(IA_PEEK_HITBOX.head)
				cmd.view_angles = (head - me:get_eye_position()):angles()
				local fire_window = ia_peek_jump_fire_window(elapsed, timing, prefire, aggression)
				if fire_window and plan and ia_peek_plan_valid(plan) then
					local filtered = ia_peek_filter_hitboxes(points, me, weapon, plan.target, min_dmg)
					if ia_peek_can_trace(me, plan.target, me:get_eye_position(), filtered, min_dmg) then
						misc_state.ia_peek_jump_shot = true
						ia_peek_apply_rage(aggression)
					end
				end
				return true
			elseif on_ground then
				ia_peek_reset_state()
				if misc_refs.doubletap then misc_refs.doubletap:override() end
				return false
			end
		end
		return true
	end

	if not misc_state.ia_peek_jump_active then
		misc_state.ia_peek_jump_active = true
		misc_state.ia_peek_jump_started = now
		misc_state.ia_peek_jump_phase_at = now + 0.1
		misc_state.ia_peek_jump_shot = false
		misc_state.ia_peek_jump_ctx = { target = threat, start_pos = me:get_origin() }
	end

	local since_start = now - misc_state.ia_peek_jump_started
	local since_phase = now - misc_state.ia_peek_jump_phase_at

	if since_start < 0.1 then
		cmd.block_movement = ia_peek_block_move_type()
		return true
	elseif since_phase < 0.1 then
		if misc_refs.autostop_opts then
			misc_refs.autostop_opts:override({ "In Air", "Move between Shots" })
		end
		utils.execute_after(0.5, function()
			if misc_refs.autostop_opts then misc_refs.autostop_opts:override() end
		end)
		cmd.in_jump = true
		cmd.in_duck = false
		if not misc_state.ia_peek_jump_dt_off then
			if misc_refs.doubletap then misc_refs.doubletap:override(false) end
			utils.execute_after(0.5, function()
				if misc_refs.doubletap then misc_refs.doubletap:override() end
			end)
			misc_state.ia_peek_jump_dt_off = true
		end
		return true
	elseif since_phase < timing then
		local head = threat:get_hitbox_position(IA_PEEK_HITBOX.head)
		cmd.view_angles = (head - me:get_eye_position()):angles()
		if not on_ground then
			rage.exploit:allow_charge(false)
		else
			rage.exploit:allow_charge(true)
		end
		local fire_window = ia_peek_jump_fire_window(since_phase, timing, prefire, aggression)
		if fire_window then
			local plan = misc_state.ia_peek_plan
			if plan and ia_peek_plan_valid(plan) then
				local filtered = ia_peek_filter_hitboxes(points, me, weapon, plan.target, min_dmg)
				if ia_peek_can_trace(me, plan.target, me:get_eye_position(), filtered, min_dmg) then
					misc_state.ia_peek_jump_shot = true
					ia_peek_apply_rage(aggression)
				end
			end
		end
		return true
	elseif on_ground then
		if not misc_state.ia_peek_jump_shot then
			if not misc_state.ia_peek_jump_retry_wait then
				misc_state.ia_peek_jump_retry_wait = true
				misc_state.ia_peek_jump_retry_at = now
				if misc_refs.doubletap then misc_refs.doubletap:override() end
				rage.exploit:allow_charge(true)
				return true
			elseif now - misc_state.ia_peek_jump_retry_at > 0.2 then
				misc_state.ia_peek_jump_retry_wait = false
				ia_peek_reset_state()
				if ia_peek_jump_ready(me, weapon) then
					return ia_peek_jump_tick(cmd, me, weapon)
				end
			end
			return true
		end
		ia_peek_reset_state()
		if misc_refs.doubletap then misc_refs.doubletap:override() end
		return false
	end
	return true
end

local function ia_peek_tick(cmd, me, weapon, wpn_info)
	local can_shoot = ia_peek_can_shoot(me, weapon, wpn_info)
	local force_jump = misc_setup.ia_peek_force_jump and misc_setup.ia_peek_force_jump:get()
	local jump_scout = misc_setup.ia_peek_jump_scout and misc_setup.ia_peek_jump_scout:get()

	if force_jump and jump_scout then
		local scanned = ia_peek_scan(cmd, me, weapon)
		if misc_state.ia_peek_plan and can_shoot and rage.exploit:get() == 1 and ia_peek_jump_tick(cmd, me, weapon) then
			return
		end
		if not misc_state.ia_peek_plan then return end
	elseif ia_peek_jump_ready(me, weapon) and rage.exploit:get() == 1 and ia_peek_jump_tick(cmd, me, weapon) then
		return
	end

	local scanned = ia_peek_scan(cmd, me, weapon)
	local plan = misc_state.ia_peek_plan
	if not plan then
		if not can_shoot then ia_peek_reset_state() end
		return
	end

	ia_peek_update_plan_aggression(me, plan)

	if ia_peek_effective_sim_time(plan) < plan.simtime then
		scanned = false
	end
	if wpn_info.weapon_type == 5 and not me.m_bIsScoped then
		scanned = false
	end

	local aggression = plan.aggression or 0
	local arrive_sqr = ia_peek_move_arrive_sqr(plan)

	if plan.retreat <= 0 and scanned then
		ia_peek_set_movement_refs(true)
		local arrived, _ = ia_peek_move_to(cmd, me, plan.ctx.origin, arrive_sqr)
		ia_peek_force_forward(cmd)
		ia_peek_apply_rage(aggression)
		plan.retreat = 0
		if arrived then plan.retreat = 1 end
		return
	end

	if not can_shoot then
		ia_peek_reset_state()
		ia_peek_reset_rage_refs()
		return
	end

	if not plan.ctx or plan.retreat == -1 then return end

	plan.retreat = plan.retreat + 1

	if not misc_state.ia_peek_retreat_pos then
		local origin = me:get_origin()
		local delta = plan.ctx.origin - origin
		delta:normalize()
		local retreat_to = plan.ctx.origin - delta * ia_peek_effective_retreat_dist(plan)
		misc_state.ia_peek_retreat_pos = utils.trace_hull(
			origin, retreat_to, plan.ctx.obb_mins, plan.ctx.obb_maxs, me, 33636363, 0
		).end_pos
	end

	ia_peek_set_movement_refs(true)
	local arrived, _ = ia_peek_move_to(cmd, me, misc_state.ia_peek_retreat_pos, arrive_sqr)
	local vel = me.m_vecVelocity or vector(0, 0, 0)
	local retreat_ang = (misc_state.ia_peek_retreat_pos - me:get_origin()):angles() - vel:angles()
	ia_peek_force_forward(cmd)
	ia_peek_apply_rage(aggression)

	if vel:length2dsqr() > 1600 and math.abs(retreat_ang.y) < 20 then
		rage.exploit:force_teleport()
		if misc_refs.doubletap then misc_refs.doubletap:override(false) end
	end

	if can_shoot and arrived then
		ia_peek_reset_state()
		ia_peek_reset_rage_refs()
	end
end

local function misc_draw_ia_peek()
	if not misc_setup.ia_peek:get() or not globals.is_in_game then return end

	local me = entity.get_local_player()
	if not me then return end
	local weapon = me:get_player_weapon()

	local screen = render.screen_size()
	local cx, cy = screen.x / 2, screen.y / 2 + 500
	local label, col = "", color(200, 200, 100, 255)

	if misc_setup.ia_peek_jump_scout and misc_setup.ia_peek_jump_scout:get() then
		local force = misc_setup.ia_peek_force_jump and misc_setup.ia_peek_force_jump:get()
		if force then
			if misc_state.ia_peek_jump_active then
				local ctx = misc_state.ia_peek_jump_ctx
				if ctx and ctx.peek_phase and not ctx.peek_completed then
					label, col = "Jump scout · peeking", color(100, 255, 255, 255)
				elseif ctx and ctx.peek_completed then
					label, col = "Jump scout · in air", color(255, 100, 255, 255)
				else
					label, col = "Jump scout · ready", color(255, 0, 255, 255)
				end
			else
				label, col = "Always jump mode", color(255, 0, 255, 255)
			end
		elseif misc_state.ia_peek_jump_active then
			label, col = "Jump scout active", color(255, 100, 100, 255)
		elseif misc_state.ia_peek_jump_retry_wait then
			label, col = "Recharging DT", color(255, 255, 100, 255)
		elseif weapon and ia_peek_jump_ready(me, weapon) then
			label, col = "Jump scout ready", color(100, 255, 100, 255)
		else
			label, col = "Jump scout on", color(200, 200, 100, 255)
		end

		if label ~= "" then
			render.text(1, vector(cx, cy), col, "c", label)
			cy = cy + 14
		end
	end

	if misc_setup.ia_peek_push_disarm and misc_setup.ia_peek_push_disarm:get() then
		local plan = misc_state.ia_peek_plan
		if plan and ia_peek_plan_valid(plan) then
			ia_peek_update_plan_aggression(me, plan)
			if (plan.aggression or 0) >= IA_PEEK_PUSH_MIN then
				local reason = plan.vuln_reason or "?"
				local backing = plan.danger_count or 0
				local suffix = backing == 0 and "alone" or ("+" .. backing)
				if backing >= 2 and (plan.aggression or 0) < 0.55 then
					suffix = "dampened · +" .. backing
				end
				render.text(1, vector(cx, cy), color(255, 180, 80, 255), "c",
					string.format("Push · %s · %s", reason, suffix))
			end
		end
	end
end

misc_on_ia_peek = function(cmd, me)
	if not misc_setup.ia_peek:get() then
		if misc_state.ia_peek_plan or misc_state.ia_peek_jump_active then
			ia_peek_reset_state()
		end
		ia_peek_reset_refs()
		return
	end

	ia_peek_sync_peek_assist()

	if not cmd or not me or not me:is_alive() then return end

	local weapon = me:get_player_weapon()
	if not weapon then
		ia_peek_reset_rage_refs()
		return
	end
	local wpn_info = weapon:get_weapon_info()
	if not wpn_info then
		ia_peek_reset_rage_refs()
		return
	end
	if not ia_peek_weapon_allowed(weapon) then
		ia_peek_reset_state()
		ia_peek_reset_rage_refs()
		return
	end

	ia_peek_tick(cmd, me, weapon, wpn_info)
end

local function misc_on_fake_latency()
	if not misc_setup.fake_latency:get() then
		if misc_refs.fake_latency then misc_refs.fake_latency:override() end
		return
	end

	local amount = misc_setup.fake_latency_ms and misc_setup.fake_latency_ms:get() or 0
	if misc_refs.fake_latency then
		misc_refs.fake_latency:override(amount)
	end
end

local MISC_LOG_HITGROUPS = {
	[0] = "generic", [1] = "head", [2] = "chest", [3] = "stomach",
	[4] = "left arm", [5] = "right arm", [6] = "left leg", [7] = "right leg",
	[8] = "neck", [9] = "generic", [10] = "gear",
}

local MISC_LOG_WPN_ACTIONS = {
	inferno = "Burned",
	knife = "Knifed",
	hegrenade = "Naded",
}

local MISC_LOG_REASON_REDIRECT = {
	["prediction error"] = "pred. error",
	["correction"] = "?",
	["backtrack failure"] = "?",
}

local function misc_log_aim_ack(shot)
	if not misc_setup.log_events:get(1) then return end

	local target = shot.target
	if target == nil then return end

	local reason = MISC_LOG_REASON_REDIRECT[shot.state] or shot.state
	local name = target:get_name()
	local health = target.m_iHealth
	local spread = shot.spread
	local backtrack = shot.backtrack
	local hitchance = shot.hitchance
	local damage = shot.damage
	local wanted_damage = shot.wanted_damage
	local hitgroup = MISC_LOG_HITGROUPS[shot.hitgroup] or "?"
	local wanted_hitgroup = MISC_LOG_HITGROUPS[shot.wanted_hitgroup] or "?"
	local accent = shinymoon_accent_hex()

	if reason == nil then
		shinymoon_log_print(string.format(
			"\a%sRegistered \aDEFAULTshot at %s's %s for \a%s%d(%d) \aDEFAULTdamage (hp: \a%s%d\aDEFAULT) (aimed: \a%s%s\aDEFAULT) (bt: \a%s%s\aDEFAULT) (spread: \a%s%.1fÂ°\aDEFAULT)",
			accent, name, hitgroup, accent, damage, wanted_damage, accent, health, accent, wanted_hitgroup, accent, backtrack, accent, spread or 0
		))
	else
		local line = string.format(
			"\a%sMissed \aDEFAULTshot at %s's %s due to \a%s%s \aDEFAULT(hc: \a%s%d%%\aDEFAULT) (damage: \a%s%d\aDEFAULT) (bt: \a%s%s\aDEFAULT)",
			accent, name, wanted_hitgroup, accent, reason, accent, hitchance or 0, accent, wanted_damage or 0, accent, backtrack
		)
		if spread ~= nil then
			line = string.format("%s (spread: \a%s%.1fÂ°\aDEFAULT)", line, accent, spread)
		end
		shinymoon_log_print(line)
	end
end

misc_on_player_hurt_log = function(e)
	if not misc_setup.log_events:get(1) then return end

	local me = entity.get_local_player()
	local victim = entity.get(e.userid, true)
	local attacker = entity.get(e.attacker, true)
	if me == nil or victim == nil or attacker == nil then return end
	if victim == me or attacker ~= me then return end

	local action = MISC_LOG_WPN_ACTIONS[e.weapon]
	if action == nil then return end

	local accent = shinymoon_accent_hex()
	shinymoon_log_print(string.format(
		"%s \a%s%s \aDEFAULTfor \a%s%d \aDEFAULTdamage (%d health remaining)",
		action, accent, victim:get_name():lower(), accent, e.dmg_health, e.health
	))
end

local function misc_log_item_purchase(e)
	if not misc_setup.log_events:get(2) then return end

	local buyer = entity.get(e.userid, true)
	if buyer == nil or not buyer:is_enemy() then return end

	local weapon = e.weapon
	if weapon == nil or weapon == "weapon_unknown" then return end

	local accent = shinymoon_accent_hex()
	shinymoon_log_print(string.format(
		"\a%s%s \aDEFAULTbought \a%s%s",
		accent, buyer:get_name():lower(), accent, weapon
	))
end

local function misc_clear_force_shot()
	if misc_refs.hitchance then misc_refs.hitchance:override() end
	if misc_refs.force_shot_hitchance then
		for _, ref in pairs(misc_refs.force_shot_hitchance) do
			ref:override()
		end
	end
	if misc_state.force_shot_active_delay then
		misc_state.force_shot_active_delay:override()
		misc_state.force_shot_active_delay = nil
	end
end

local function misc_get_force_shot_weapon_name(weapon)
	if weapon == nil then return nil end

	local info = weapon:get_weapon_info()
	if info == nil then return nil end

	local weapon_type = info.weapon_type
	local idx = weapon:get_weapon_index()

	if weapon_type == 2 then
		return "SMG"
	elseif weapon_type == 3 then
		return "Rifles"
	elseif weapon_type == 1 then
		if idx == 1 then return "Desert Eagle" end
		if idx == 64 then return "Revolver R8" end
		return "Pistols"
	elseif weapon_type == 5 then
		if idx == 40 then return "Scout" end
		if idx == 9 then return "AWP" end
		return "Auto Snipers"
	end

	return nil
end

local function misc_get_force_shot_config_names(weapon)
	local primary = misc_get_force_shot_weapon_name(weapon)
	if primary == nil then return {} end
	if primary == "Scout" then
		return { "Scout", "SSG-08" }
	end
	return { primary }
end

local function misc_get_force_shot_delay_ref(weapon)
	local names = misc_get_force_shot_config_names(weapon)
	for i = 1, #names do
		local ref = misc_refs.force_shot_delay[names[i]]
		if ref then
			return ref
		end
	end
	return nil
end

local function misc_on_force_shot(me)
	if not misc_setup.force_shot:get() then
		misc_clear_force_shot()
		return
	end

	if me == nil or not me:is_alive() then
		misc_clear_force_shot()
		return
	end

	if misc_refs.hitchance then
		misc_refs.hitchance:override(MISC_FORCE_SHOT_HC)
	end

	local weapon = me:get_player_weapon()
	local config_names = misc_get_force_shot_config_names(weapon)

	for i = 1, #config_names do
		local hc_ref = misc_refs.force_shot_hitchance[config_names[i]]
		if hc_ref then
			hc_ref:override(MISC_FORCE_SHOT_HC)
		end
	end

	local delay_ref = misc_get_force_shot_delay_ref(weapon)
	if misc_state.force_shot_active_delay and misc_state.force_shot_active_delay ~= delay_ref then
		misc_state.force_shot_active_delay:override()
		misc_state.force_shot_active_delay = nil
	end
	if delay_ref then
		delay_ref:override(false)
		misc_state.force_shot_active_delay = delay_ref
	end
end

misc_on_clantag = function()
	if not misc_setup.clantag:get() then
		if misc_state.clantag_index ~= nil then
			common.set_clan_tag("")
			misc_state.clantag_index = nil
		end
		if misc_refs.clan_tag then misc_refs.clan_tag:override() end
		return
	end

	if misc_refs.clan_tag then misc_refs.clan_tag:override(false) end
	if not globals.is_in_game then
		common.set_clan_tag("")
		return
	end

	local frames = misc_state.clantag_frames or DEFAULT_CLANTAG_FRAMES
	local frame_idx = math.floor(globals.curtime * 2.4) % #frames + 1
	local tag = frames[frame_idx] or ""
	if misc_state.clantag_index ~= frame_idx or misc_state.clantag_last ~= tag then
		misc_state.clantag_index = frame_idx
		misc_state.clantag_last = tag
		common.set_clan_tag(tag)
	end
end

local function misc_reset_native_refs()
	if misc_refs.fake_latency then misc_refs.fake_latency:override() end
	if misc_refs.weapon_actions then misc_refs.weapon_actions:override() end
	if misc_refs.air_strafe then misc_refs.air_strafe:override() end
	if misc_refs.strafe_assist then misc_refs.strafe_assist:override() end
	if misc_refs.log_events then misc_refs.log_events:override() end
	if misc_refs.clan_tag then misc_refs.clan_tag:override() end
	if misc_refs.hideshots then misc_refs.hideshots:override() end
	if misc_refs.hideshot_config then misc_refs.hideshot_config:override() end
	if misc_refs.doubletap then misc_refs.doubletap:override() end
	if misc_refs.peek_assist then misc_refs.peek_assist:override() end
	if misc_refs.peek_retreat then misc_refs.peek_retreat:override() end
	if misc_refs.autostop_opts then misc_refs.autostop_opts:override() end
	ia_peek_reset_state()
	ia_peek_reset_refs()
	misc_clear_force_shot()
	common.set_clan_tag("")
end

misc_run = function(cmd)
	local me = entity.get_local_player()
	misc_on_optimize_cvars()
	misc_on_fake_latency()
	misc_on_force_shot(me)
	misc_on_clantag()
	misc_on_fast_ladder(cmd, me)
	misc_on_no_fall(cmd, me)
	misc_on_freezetime_fakeduck(cmd)
	misc_on_air_duck_collision(cmd, me)
	misc_on_super_toss_cmd(cmd, me)
	misc_on_nade_release(cmd, me)
end

misc_draw = function()
	misc_draw_ia_peek()
end

EVENTS.add({ event = "createmove_run", tag = "misc.unlock_fd", order = 10, fn = function(cmd)
	misc_on_unlock_fakeduck(cmd)
	local me = NL.entity.get_local_player()
	if me then
		misc_on_force_shot(me)
	end
end })

EVENTS.add({ event = "net_update_end", tag = "misc.force_shot", order = 20, fn = function()
	if not misc_setup.force_shot:get() then return end
	local me = NL.entity.get_local_player()
	if me then
		misc_on_force_shot(me)
	end
end })

EVENTS.add({ event = "grenade_override_view", tag = "misc.super_toss", order = 10, fn = function(data)
	misc_on_super_toss_view(data)
end })

EVENTS.add({ event = "grenade_prediction", tag = "misc.nade_pred", order = 10, fn = function(data)
	misc_on_nade_prediction(data)
end })

EVENTS.add({ event = "aim_fire", tag = "misc.ia_peek", order = 10, fn = function()
	if misc_setup.ia_peek:get() and misc_state.ia_peek_plan then
		ia_peek_reset_state()
	end
end })

if misc_refs.log_events then
	misc_sync_native_log_events()
	misc_setup.log_events:set_callback(function()
		misc_sync_native_log_events()
	end, true)
end

EVENTS.add({ event = "aim_ack", tag = "misc.log_ack", order = 10, fn = function(shot)
	misc_log_aim_ack(shot)
end })

EVENTS.add({ event = "item_purchase", tag = "misc.log_buy", order = 10, fn = function(e)
	misc_log_item_purchase(e)
end })

EVENTS.add({ event = "level_init", tag = "misc.reset", order = 30, fn = function()
	misc_state.clantag_index = nil
	misc_state.clantag_last = nil
	misc_state.freeze_fd_tick = 0
	ia_peek_reset_state()
	ia_peek_reset_refs()
	misc_refresh_clantag_frames()

	if misc_setup.optimize_cvars and misc_setup.optimize_cvars:get() then
		misc_state.opt_cvars_saved = {}
		misc_state.opt_cvars_active = false
		misc_apply_opt_cvars(true)
	end
end })

EVENTS.add({ event = "shutdown", tag = "misc.shutdown", order = 10, fn = function()
	misc_restore_opt_cvars()
	misc_reset_native_refs()
	if shared_shutdown_icons then shared_shutdown_icons() end
	if save_stats then save_stats() end
	if visuals_shutdown then visuals_shutdown() end
	if AA.refs.base then AA.refs.base:override() end
end })

end
init_misc()

EVENTS.register_all()

antiaim_update_visibility()
misc_update_visibility()