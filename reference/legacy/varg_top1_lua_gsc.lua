-- thx wooksi for giving me this

if not LPH_OBFUSCATED then
    -- should only be used in **unobfuscated scripts!**
    -- will also perform basic runtime validation on script arguments

    local assert = assert
    local type = type
    local setfenv = setfenv

    LPH_ENCNUM = function(toEncrypt, ...)
        assert(type(toEncrypt) == "number" and #{...} == 0, "LPH_ENCNUM only accepts a single constant double or integer as an argument.")
        return toEncrypt
    end
    LPH_NUMENC = LPH_ENCNUM

    LPH_ENCSTR = function(toEncrypt, ...)
        assert(type(toEncrypt) == "string" and #{...} == 0, "LPH_ENCSTR only accepts a single constant string as an argument.")
        return toEncrypt
    end
    LPH_STRENC = LPH_ENCSTR

    LPH_ENCFUNC = function(toEncrypt, encKey, decKey, ...)
        -- not checking decKey value since this shim is meant to be used without obfuscation/whitelisting
        assert(type(toEncrypt) == "function" and type(encKey) == "string" and #{...} == 0, "LPH_ENCFUNC accepts a constant function, constant string, and string variable as arguments.")
        return toEncrypt
    end
    LPH_FUNCENC = LPH_ENCFUNC

    LPH_JIT = function(f, ...)
        assert(type(f) == "function" and #{...} == 0, "LPH_JIT only accepts a single constant function as an argument.")
        return f
    end
    LPH_JIT_MAX = LPH_JIT

    LPH_NO_VIRTUALIZE = function(f, ...)
        assert(type(f) == "function" and #{...} == 0, "LPH_NO_VIRTUALIZE only accepts a single constant function as an argument.")
        return f
    end

    LPH_NO_UPVALUES = function(f, ...)
        assert(type(setfenv) == "function", "LPH_NO_UPVALUES can only be used on Lua versions with getfenv & setfenv")
        assert(type(f) == "function" and #{...} == 0, "LPH_NO_UPVALUES only accepts a single constant function as an argument.")
        return f
    end

    LPH_CRASH = function(...)
        assert(#{...} == 0, "LPH_CRASH does not accept any arguments.")
    end

end
    local js = panorama.open()
    local vector = require("vector")
    local pui = require("gamesense/pui")
    local clipboard = require("gamesense/clipboard")
    local ent = require("gamesense/entity")
    local aa_funcs = require("gamesense/antiaim_funcs")
    local images = require('gamesense/images')
    local base64 = require('gamesense/base64')
    local ffi = require("ffi")
    local username = js.MyPersonaAPI.GetName()
    local steamid = js.MyPersonaAPI.GetXuid()
    local lerp_module = require("gamesense/lerp")
local get_username = function()
	js.MyPersonaAPI.GetName()
end
local vector = require("vector")
local v8 = (function()
	local v144 = function(v837)
		local v838 = {}
		local v839 = setmetatable({}, v838)
		v838.__index = function(_, v2174)
			local v2175 = v837(v2174)
			v839[v2174] = v2175
			return v2175
		end
		return v839
	end
	local v145 = function(v840, v841)
		return function(v2176, v2177)
			local v2178 = 0
			local v2179 = 1
			while v2176 ~= 0 and v2177 ~= 0 do
				local v2180 = v2176 % v841
				local v2181 = v2177 % v841
				v2178 = v2178 + v840[v2180][v2181] * v2179
				v2176 = (v2176 - v2180) / v841
				v2177 = (v2177 - v2181) / v841
				v2179 = v2179 * v841
			end
			return v2178 + (v2176 + v2177) * v2179
		end
	end
	local v146 = (function(v842)
		local v843 = v145(v842, 2)
		local v844 = v144(function(v2182)
			return v144(function(v2327)
				return v843(v2182, v2327)
			end)
		end)
		return v145(v844, 2 ^ (v842.n or 1))
	end)({[0] = {[0] = 0, [1] = 1}, {[0] = 1, [1] = 0}, n = 4})
	local function v147(v845, v846, v847, ...)
		if v846 then
			local v848 = v845 % 4294967296
			local v849 = v846 % 4294967296
			local v850 = v146(v848, v849)
			if v847 then
				v850 = v147(v850, v847, ...)
			end
			return v850
		end
		if v845 then
			return v845 % 4294967296
		end
		return 0
	end
	local v148 = function(v851, v852, v853, ...)
		if v852 then
			local v854 = v851 % 4294967296
			local v855 = v852 % 4294967296
			local v856 = (v854 + v855 - v146(v854, v855)) / 2
			if v853 then
				v856 = bit32_band(v856, v853, ...)
			end
			return v856
		end
		if v851 then
			return v851 % 4294967296
		end
		return 4294967295
	end
	local v149 = function(v857)
		return (-1 - v857) % 4294967296
	end
	local v150 = function(v858, v859)
		if v859 < 0 then
			return lshift(v858, -v859)
		end
		return math.floor(v858 % 4294967296 / 2 ^ v859)
	end
	local v151 = function(v860, v861)
		if v861 > 31 or v861 < -31 then
			return 0
		end
		return v150(v860 % 4294967296, v861)
	end
	local v152 = function(v862, v863)
		if v863 < 0 then
			return v151(v862, -v863)
		end
		return v862 * 2 ^ v863 % 4294967296
	end
	local v153 = function(v864, v865)
		local v866 = v864 % 4294967296
		local v867 = v865 % 32
		local v868 = v148(v866, 2 ^ v867 - 1)
		return v151(v866, v867) + v152(v868, 32 - v867)
	end
	local v154 = {1116352408, 1899447441, 3049323471, 3921009573, 961987163, 1508970993, 2453635748, 2870763221, 3624381080, 310598401, 607225278, 1426881987, 1925078388, 2162078206, 2614888103, 3248222580, 3835390401, 4022224774, 264347078, 604807628, 770255983, 1249150122, 1555081692, 1996064986, 2554220882, 2821834349, 2952996808, 3210313671, 3336571891, 3584528711, 113926993, 338241895, 666307205, 773529912, 1294757372, 1396182291, 1695183700, 1986661051, 2177026350, 2456956037, 2730485921, 2820302411, 3259730800, 3345764771, 3516065817, 3600352804, 4094571909, 275423344, 430227734, 506948616, 659060556, 883997877, 958139571, 1322822218, 1537002063, 1747873779, 1955562222, 2024104815, 2227730452, 2361852424, 2428436474, 2756734187, 3204031479, 3329325298}
	local v155 = function(v869)
		return string.gsub(v869, ".", function(v2183)
			return string.format("%02x", string.byte(v2183))
		end)
	end
	local v156 = function(v870, v871)
		local v872 = ""
		for _ = 1, v871, 1 do
			local v874 = v870 % 256
			v872 = string.char(v874) .. v872
			v870 = (v870 - v874) / 256
		end
		return v872
	end
	local v157 = function(v875, v876)
		local v877 = 0
		for v878 = v876, v876 + 3, 1 do
			v877 = v877 * 256 + string.byte(v875, v878)
		end
		return v877
	end
	local v158 = function(v879, v880)
		local v881 = 64 - (v880 + 9) % 64
		local v882 = v156(8 * v880, 8)
		local v883 = v879 .. "\128" .. string.rep("\000", v881) .. v882
		assert(#v883 % 64 == 0)
		return v883
	end
	local v159 = function(v884)
		v884[1] = 1779033703
		v884[2] = 3144134277
		v884[3] = 1013904242
		v884[4] = 2773480762
		v884[5] = 1359893119
		v884[6] = 2600822924
		v884[7] = 528734635
		v884[8] = 1541459225
		return v884
	end
	local v160 = function(v885, v886, v887)
		local v888 = {}
		for v889 = 1, 16, 1 do
			v888[v889] = v157(v885, v886 + (v889 - 1) * 4)
		end
		for v890 = 17, 64, 1 do
			local v891 = v888[v890 - 15]
			local v892 = v147(v153(v891, 7), v153(v891, 18), v151(v891, 3))
			local v893 = v888[v890 - 2]
			v888[v890] = v888[v890 - 16] + v892 + v888[v890 - 7] + v147(v153(v893, 17), v153(v893, 19), v151(v893, 10))
		end
		local v894 = v887[1]
		local v895 = v887[2]
		local v896 = v887[3]
		local v897 = v887[4]
		local v898 = v887[5]
		local v899 = v887[6]
		local v900 = v887[7]
		local v901 = v887[8]
		for v902 = 1, 64, 1 do
			local v903 = v147(v153(v894, 2), v153(v894, 13), v153(v894, 22)) + v147(v148(v894, v895), v148(v894, v896), v148(v895, v896))
			local v904 = v147(v153(v898, 6), v153(v898, 11), v153(v898, 25))
			local v905 = v147(v148(v898, v899), v148(v149(v898), v900))
			local v906 = v901 + v904 + v905 + v154[v902] + v888[v902]
			local v907 = v897 + v906
			local v908 = v906 + v903
			v897 = v896
			v896 = v895
			v895 = v894
			v894 = v908
			v901 = v900
			v900 = v899
			v899 = v898
			v898 = v907
		end
		v887[1] = v148(v887[1] + v894)
		v887[2] = v148(v887[2] + v895)
		v887[3] = v148(v887[3] + v896)
		v887[4] = v148(v887[4] + v897)
		v887[5] = v148(v887[5] + v898)
		v887[6] = v148(v887[6] + v899)
		v887[7] = v148(v887[7] + v900)
		v887[8] = v148(v887[8] + v901)
	end
	sha256 = function(v909)
		local v910 = v158(v909, #v909)
		local v911 = v159({})
		for v912 = 1, #v910, 64 do
			v160(v910, v912, v911)
		end
		return v155(v156(v911[1], 4) .. v156(v911[2], 4) .. v156(v911[3], 4) .. v156(v911[4], 4) .. v156(v911[5], 4) .. v156(v911[6], 4) .. v156(v911[7], 4) .. v156(v911[8], 4))
	end
	return sha256
end)()

client.exec("clear")
local v55 = {name = "Varg", CLOUDAPI = "https://api.varglua.top/cloud/api", color = {r = 153, g = 206, b = 255}, last_update = "8/1/2025", cfg_database = "cfg_db_kedra", crash = "yes", notify_data = {}, lua_load_text = "                                                                                                                       \n    ,--.   ,--.,---.  ,------.  ,----.    \n    \\  `.'  //  O  \\ |  .--. ''  .-./    \n     \\     /|  .-.  ||  '--'.'|  | .---. \n      \\   / |  | |  ||  |\\  \\ '  '--'  | \n       `-'  `--' `--'`--' '--' `------'  \n                                         \n   ", username = get_username() or "smiec", build = "beta"}
local v56 = function()
	error("was supposed to crash?")
	while true do
		for _ = 1, 9000, 1 do
			loadstring("print(\"varg top\")")()
		end
	end
end
print = function(...)
	client.color_log(200, 200, 200, "[\000")
	client.color_log(v55.color.r, v55.color.g, v55.color.b, v55.name .. "\000")
	client.color_log(200, 200, 200, "] \000")
	client.color_log(200, 200, 200, ...)
end
local v57 = {{name = "ffi", message = "allow unsafe scripts"}, {name = "gamesense/http", message = "allow unsafe scripts / you dont have http lib"}, {name = "gamesense/websockets", message = "allow unsafe scripts / you dont have websockets lib"}, {name = "gamesense/base64", message = "allow unsafe scripts / you dont have base64 lib"}, {name = "vector", message = ""}, {name = "gamesense/clipboard", message = "allow unsafe scripts / you dont have clipboard lib"}}
local v58 = {}
for v59, v60 in ipairs(v57) do
	local v61, v62 = pcall(function(v537)
		if type(v537) ~= "string" then
			error("Retardo")
		end
		if string.find(v537, "^gamesense/") then
			local v538 = package.preload[v537]
			if v538 then
				if type(v538) ~= "function" then
					error("Retardinio")
				end
				local v539, v540 = pcall(v538, v537)
				if v539 and v540 then
					return v540
				end
			end
		end
		return require(v537)
	end, v60.name)
	if v61 then
		v58[v60.name] = v62
		if v59 == #v57 then
			print("All libraries have been loaded.")
		end
	else
		v58[v60.name] = nil
		print(string.format("Failed to load module: %s - %s", v60.name, v60.message))
	end
end
new_notify = function(v541, v542, v543, v544, v545)
	local v546 = {text = v541, timer = globals.realtime(), color = {v542, v543, v544, v545}, fraction = 0}
	table.insert(v55.notify_data, v546)
end
local v63, v64 = client.screen_size()
Y = v64
X = v63
local v65 = {references = {aimbot = ui.reference("RAGE", "Aimbot", "Enabled"), minimum_damage = ui.reference("RAGE", "Aimbot", "Minimum damage"), minimum_damage_override = {ui.reference("RAGE", "Aimbot", "Minimum damage override")}, double_tap = {ui.reference("RAGE", "Aimbot", "Double tap")}, ps = {ui.reference("MISC", "Miscellaneous", "Ping spike")}, duck_peek_assist = ui.reference("RAGE", "Other", "Duck peek assist"), enabled = ui.reference("AA", "Anti-aimbot angles", "Enabled"), pitch = {ui.reference("AA", "Anti-aimbot angles", "Pitch")}, yaw_base = ui.reference("AA", "Anti-aimbot angles", "Yaw base"), yaw = {ui.reference("AA", "Anti-aimbot angles", "Yaw")}, yaw_jitter = {ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")}, body_yaw = {ui.reference("AA", "Anti-aimbot angles", "Body yaw")}, freestanding_body_yaw = ui.reference("AA", "anti-aimbot angles", "Freestanding body yaw"), edge_yaw = ui.reference("AA", "Anti-aimbot angles", "Edge yaw"), freestanding = {ui.reference("AA", "Anti-aimbot angles", "Freestanding")}, roll = ui.reference("AA", "Anti-aimbot angles", "Roll"), slow_motion = {ui.reference("AA", "Other", "Slow motion")}, leg_movement = ui.reference("AA", "Other", "Leg movement"), on_shot_anti_aim = {ui.reference("AA", "Other", "On shot anti-aim")}, fakepeek = {ui.reference("AA", "Other", "Fake peek")}}, ref = {aa_enable = ui.reference("AA", "anti-aimbot angles", "enabled"), pitch = ui.reference("AA", "anti-aimbot angles", "pitch"), pitch_value = select(2, ui.reference("AA", "anti-aimbot angles", "pitch")), yaw_base = ui.reference("AA", "anti-aimbot angles", "yaw base"), yaw = ui.reference("AA", "anti-aimbot angles", "yaw"), yaw_value = select(2, ui.reference("AA", "anti-aimbot angles", "yaw")), yaw_jitter = ui.reference("AA", "Anti-aimbot angles", "Yaw Jitter"), yaw_jitter_value = select(2, ui.reference("AA", "Anti-aimbot angles", "Yaw Jitter")), body_yaw = ui.reference("AA", "Anti-aimbot angles", "Body yaw"), body_yaw_value = select(2, ui.reference("AA", "Anti-aimbot angles", "Body yaw")), freestand_body_yaw = ui.reference("AA", "Anti-aimbot angles", "freestanding body yaw"), edgeyaw = ui.reference("AA", "anti-aimbot angles", "edge yaw"), freestand = {ui.reference("AA", "anti-aimbot angles", "freestanding")}, roll = ui.reference("AA", "anti-aimbot angles", "roll"), slide = {ui.reference("AA", "other", "slow motion")}, fakeduck = ui.reference("rage", "other", "duck peek assist"), quick_peek = {ui.reference("rage", "other", "quick peek assist")}, doubletap = {ui.reference("rage", "aimbot", "double tap")}, fakelag = {ui.reference("AA", "Fake lag", "Enabled")}, fakelag_ammount = ui.reference("AA", "Fake lag", "Amount"), fakelag_varriance = ui.reference("AA", "Fake lag", "Variance"), fakelag_limit = ui.reference("AA", "Fake lag", "Limit"), menu_color = ui.reference("Misc", "Settings", "Menu color"), clantag_spammer = ui.reference("Misc", "Miscellaneous", "Clan tag spammer")}}
local v66 = {contains = function(v547, v548)
	for _, v550 in next, v547, nil do
		if v550 == v548 then
			return true
		end
	end
	return false
end}

v66.rgba_to_hex = LPH_NO_VIRTUALIZE(function(L_595, L_596, L_597, L_598)
    return string.format("%02\120%\048\x32x%\0482x%02\120", L_595, L_596, L_597, L_598);
end)

v66.rgb_to_hex = LPH_NO_VIRTUALIZE(function(L_649, L_650, L_651)
    return string.format('\037\048\50x\z\037\0482x\037\048\50\x78', L_649, L_650, L_651);
end)

v66.text_fade_animation = LPH_NO_VIRTUALIZE(function(L_344, L_345, L_346, L_347, L_348, L_349)
    local L_350 = '';
    local L_351 = globals.curtime();
    for L_352 = 0, #L_349 do
        local L_353 = string.format('%0\x32x\037\0482x%0\50\120%\x30\50x', L_345, L_346, L_347, L_348 * math.abs(1 * math.cos(2 * L_344 * L_351 / 4 + L_352 * 5 / 30)));
        L_350 = L_350 .. '\7' .. L_353 .. L_349:sub(L_352, L_352);
    end;
    return L_350;
end)

v66.hide_skeet_antiaim_def = LPH_NO_VIRTUALIZE(function(L_394)
    L_394 = not L_394;
    ui.set_visible(v65.ref.aa_enable, L_394);
    ui.set_visible(v65.ref.pitch, L_394);
    ui.set_visible(v65.ref.pitch_value, L_394);
    ui.set_visible(v65.ref.yaw_base, L_394);
    ui.set_visible(v65.ref.yaw, L_394);
    ui.set_visible(v65.ref.yaw_value, L_394);
    ui.set_visible(v65.ref.yaw_jitter, L_394);
    ui.set_visible(v65.ref.yaw_jitter_value, L_394);
    ui.set_visible(v65.ref.body_yaw, L_394);
    ui.set_visible(v65.ref.body_yaw_value, L_394);
    ui.set_visible(v65.ref.edgeyaw, L_394);
    ui.set_visible(v65.ref.freestand[1], L_394);
    ui.set_visible(v65.ref.freestand[2], L_394);
    ui.set_visible(v65.ref.roll, L_394);
    ui.set_visible(v65.ref.freestand_body_yaw, L_394);
end)

v66.hide_skeet_fakelag_def = LPH_NO_VIRTUALIZE(function(L_910)
    L_910 = not L_910;
    ui.set_visible(v65.ref.fakelag[1], L_910);
    ui.set_visible(v65.ref.fakelag[2], L_910);
    ui.set_visible(v65.ref.fakelag_limit, L_910);
    ui.set_visible(v65.ref.fakelag_varriance, L_910);
    ui.set_visible(v65.ref.fakelag_ammount, L_910);
end)

v66.hide_skeet_other_def = LPH_NO_VIRTUALIZE(function(L_368)
            L_368 = not L_368;
            ui.set_visible(v65.ref.slide[1], L_368);
            ui.set_visible(v65.ref.slide[2], L_368);
            ui.set_visible(v65.references.leg_movement, L_368);
            ui.set_visible(v65.references.on_shot_anti_aim[1], L_368);
            ui.set_visible(v65.references.on_shot_anti_aim[2], L_368);
            ui.set_visible(v65.references.fakepeek[1], L_368);
            ui.set_visible(v65.references.fakepeek[2], L_368);
        end)
v66.intersect = function(v551, v552, v553, v554)
	local v555, v556 = ui.mouse_position()
	return v555 >= v551 and v555 <= v551 + v553 and v556 >= v552 and v556 <= v552 + v554
end
v66.multicolor_console = function(...)
	local v557 = {...}
	for v558 = 1, #v557, 1 do
		local v559 = v557[v558]
		client.color_log(v559[1], v559[2], v559[3], v558 ~= #v557 and v559[4] .. "\000" or v559[4])
	end
end
v66.cool_anim = function(v560, v561, v562, v563, v564, v565, v566, v567, v568, v569)
	local v570 = ""
	local v571 = globals.curtime()
	local v572 = 1 / v560
	local v573 = math.floor(v571 / v572) % (#v569 + 1)
	for v574 = 1, #v569, 1 do
		local v575 = v569:sub(v574, v574)
		local v576 = string.format("%02x%02x%02x%02x", v561, v562, v563, v564)
		local v577 = string.format("%02x%02x%02x%02x", v565, v566, v567, v568)
		local v578
		if v574 == v573 then
			v578 = "\a" .. v576 .. v575
		else
			v578 = "\a" .. v577 .. v575
		end
		v570 = v570 .. v578
	end
	return v570
end

v66.assign_defaults = LPH_NO_VIRTUALIZE(function(L_824, L_825)
            for L_826, L_827 in pairs(L_825) do
                if L_824[L_826] ~= nil then
                    L_824[L_826] = L_827;
                end;
            end;
        end)
local v67 = {states = {"global", "standing", "moving", "slow motion", "in air", "in air duck", "in duck", "in duck moving", "freestanding"}, states_no_freestanding = {"global", "standing", "moving", "slow motion", "in air", "in air duck", "in duck", "in duck moving"}, ticks_left = 0, defensive = 0, max_tickbase = 0}
local v68 = {info = {enable = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\n                  "), text_gowno = ui.new_label("AA", "Anti-Aimbot Angles", string.format("\a%s\226\139\134\239\189\161\194\176\226\156\169 %s \abdbdbdff~ \a99CEFFFF%s \abdbdbdff~ \a99CEFFFF%s", v66.rgba_to_hex(189, 189, 189, 255), v55.name, v55.build, v55.username)), online_text = ui.new_label("AA", "Anti-Aimbot Angles", "\aed6464ffnot connected \abdbdbdff| trying to connect"), link_discord = ui.new_button("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\132\186 \abdbdbdfffetch discord avatar", function()
	panorama.open().SteamOverlayAPI.OpenExternalBrowserURL("https://discord.com/oauth2/authorize?client_id=1387465440824922207&response_type=code&redirect_uri=https%3A%2F%2Fvarglua.top%2Flink&scope=identify&state=" .. v58["gamesense/base64"].encode(v55.username .. "|" .. v55.build .. "|" .. v8(v55.username .. v55.build .. "zuRztYS1XfTYhoRFvarg")))
	client.reload_active_scripts()
end)}}
v68.info.lua_tab = ui.new_combobox("AA", "Anti-Aimbot Angles", "\n ", {"\a99CEFFFF\238\128\151 \abdbdbdffback to menu", "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim", "\a99CEFFFF\238\138\177 \abdbdbdffvisuals", "\a99CEFFFF\238\132\149 \abdbdbdffutilities", "\a99CEFFFF\238\132\133 \abdbdbdffconfiguration", "\a99CEFFFF\238\132\168 \abdbdbdffabout"})
local v69 = {{name = "separator", type = "label", value = "\n"}, {name = "separator1", type = "label", value = "\a99CEFFFF\238\131\163 \abdbdbdfffeatures"}, {name = "separator2", type = "label", value = "\n"}, {name = "button_ui_1", type = "button", value = "\a99CEFFFF\238\128\151 \abdbdbdffback to menu"}, {name = "button_ui_2", type = "button", value = "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {name = "button_ui_3", type = "button", value = "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {name = "button_ui_4", type = "button", value = "\a99CEFFFF\238\132\149 \abdbdbdffutilities"}, {name = "separator3", type = "label", value = "\n"}, {name = "separator4", type = "label", value = "\a99CEFFFF\238\131\163 \abdbdbdffsettings"}, {name = "separator5", type = "label", value = "\n"}, {name = "button_ui_5", type = "button", value = "\a99CEFFFF\238\132\133 \abdbdbdffconfiguration"}, {name = "button_ui_6", type = "button", value = "\a99CEFFFF\238\132\168 \abdbdbdffabout"}}
for _, v71 in ipairs(v69) do
	if v71.type:match("label") then
		v68.info[v71.name] = ui.new_label("AA", "Anti-Aimbot Angles", v71.value)
	end
	if v71.type:match("button") then
		v68.info[v71.name] = ui.new_button("AA", "Anti-Aimbot Angles", v71.value, function()
			ui.set(v68.info.lua_tab, v71.value)
			local v596 = ui.get(v68.info.enable) and ui.get(v68.info.lua_tab) == "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"
			v66.hide_skeet_fakelag_def(v596)
		end)
	end
end
local v72 = cvar.sv_maxusrcmdprocessticks:get_int() - 1
v68.aa = {line = ui.new_label("AA", "Anti-Aimbot Angles", "\n "), yawbase = ui.new_combobox("AA", "Anti-Aimbot Angles", "yaw base", {"at targets", "local view"}), state = ui.new_combobox("AA", "Anti-Aimbot Angles", "condition", v67.states), line1 = ui.new_label("AA", "Anti-Aimbot Angles", "\n "), select_shit = ui.new_combobox("AA", "Fake lag", "\n 000000000", {"defensive", "fake-lag", "other"}), line2 = ui.new_label("AA", "Fake lag", "\n "), fakelag_mode = ui.new_combobox("AA", "Fake lag", "fake lag", {"default", "sway", "random"}), fakelag_limit = ui.new_slider("AA", "Fake lag", "limit", 1, v72, 10), fakelag_limit_sway_min = ui.new_slider("AA", "Fake lag", "min", 1, v72, 4), fakelag_limit_sway_max = ui.new_slider("AA", "Fake lag", "max", 1, v72, 13), binds = ui.new_multiselect("AA", "Fake lag", "binds", {"freestanding", "edge-yaw", "manuals"}), left_manual = ui.new_hotkey("AA", "Fake lag", "\a99CEFFFF\238\131\163 \abdbdbdffleft"), right_manual = ui.new_hotkey("AA", "Fake lag", "\a99CEFFFF\238\131\163 \abdbdbdffright"), forward_manual = ui.new_hotkey("AA", "Fake lag", "\a99CEFFFF\238\131\163 \abdbdbdffforward"), freestanding = ui.new_hotkey("AA", "Fake lag", "\a99CEFFFF\238\131\163 \abdbdbdfffreestanding"), edge_yaw = ui.new_hotkey("AA", "Fake lag", "\a99CEFFFF\238\131\163 \abdbdbdffedge-yaw"), freestanding_disablers = ui.new_multiselect("AA", "Fake lag", "freestanding disablers", v67.states_no_freestanding), line3 = ui.new_label("AA", "Fake lag", "\n "), tweaks = ui.new_multiselect("AA", "Fake lag", "tweaks", {"anti-backstab", "safe-head", "e-spam (safe-head)", "warmup-aa"}), info_kurwa = ui.new_label("AA", "Fake lag", "works only on air-duck + defensive")}
v68.visuals = {hitlogs = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\226\128\162 \abdbdbdfflogs"), hit_color = ui.new_color_picker("AA", "Anti-Aimbot Angles", "hit color", v55.color.r, v55.color.g, v55.color.b, 255), miss_color = ui.new_color_picker("AA", "Anti-Aimbot Angles", "miss color", v55.color.r, v55.color.g, v55.color.b, 255), hitlogs_opt = ui.new_multiselect("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdfflogs options", {"hit", "miss", "console"}), logs_style = ui.new_combobox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdfflogs style", {"default", "modern"}), watermark = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\226\128\162 \abdbdbdffwatermark"), watermark_color = ui.new_color_picker("AA", "Anti-Aimbot Angles", "watermark color", v55.color.r, v55.color.g, v55.color.b, 255), watermark_pos = ui.new_combobox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdffwatermark style", {"default", "modern", "minimal", "avatar-based"}), watermark_opt = ui.new_multiselect("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdffwatermark options", {"username", "ping", "fps", "time"}), watermark_pos_sexy = ui.new_combobox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdffwatermark position", {"left - middle", "right - top - corner"}), other_visuals = ui.new_multiselect("AA", "Anti-Aimbot Angles", "\a99CEFFFF\226\128\162 \abdbdbdffother", {"speed warning", "minimum damage override", "manuals", "thirdperson distance", "aspect ratio"}), speed_warning_color = ui.new_label("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdffspeed warning"), other_visuals_color = ui.new_color_picker("AA", "Anti-Aimbot Angles", "other color", v55.color.r, v55.color.g, v55.color.b, 255), damage_override_color = ui.new_label("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdffminimum damage override"), other_damage_override_color = ui.new_color_picker("AA", "Anti-Aimbot Angles", "dmg over color", v55.color.r, v55.color.g, v55.color.b, 255), manuals_color = ui.new_label("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdffmanuals"), other_manuals_color = ui.new_color_picker("AA", "Anti-Aimbot Angles", "manuals color", v55.color.r, v55.color.g, v55.color.b, 255), thirdperson_dist = ui.new_slider("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdffthirdperson distance", 30, 200, 125, true, "%"), aspect_ratio = ui.new_slider("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdffaspect ratio", 100, 200, 200, true, "%", 1)}
v68.misc = {unsafe_recharge = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\226\128\162 \abdbdbdffunsafe recharge"), clantag = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\226\128\162 \abdbdbdffclan-tag"), fpsboost = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\226\128\162 \abdbdbdfffps boost"), crash_fix = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\226\128\162 \abdbdbdffcrash fix"), fast_ladder = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\226\128\162 \abdbdbdfffast ladder"), unmatched = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\226\128\162 \abdbdbdffunmatched (disable defensive)"), jitter_fix = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\226\128\162 \abdbdbdffjitter-fix [\a99CEFFFFBETA\abdbdbdff]"), jitter_fix_type = ui.new_combobox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdfftype", {"default", "beta"}), console_filter = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\226\128\162 \abdbdbdffconsole-filter"), killsay = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\226\128\162 \abdbdbdfftrashtalk"), killsay_type = ui.new_combobox("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdfftrashtalk lang", {"ru", "eng", "cn"}), animation_braker = ui.new_multiselect("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\131\163 \abdbdbdffanimations", {"reversed legs", "static legs", "leg braker", "perfect"})}
v68.config = {config_type = ui.new_combobox("AA", "Anti-Aimbot Angles", "\n ", {"local", "cloud"}), config_name = ui.new_textbox("AA", "Anti-Aimbot Angles", "\n "), create_cfg = ui.new_button("AA", "Anti-Aimbot Angles", "create", function()
end), line = ui.new_label("AA", "Anti-Aimbot Angles", "\n "), cfg_list = ui.new_listbox("AA", "Anti-Aimbot Angles", "\n ", {"nothing."}), save_cfg = ui.new_button("AA", "Anti-Aimbot Angles", "save", function()
end), load_cfg = ui.new_button("AA", "Anti-Aimbot Angles", "load", function()
end), delete_cfg = ui.new_button("AA", "Anti-Aimbot Angles", "delete", function()
end), export_cfg = ui.new_button("AA", "Anti-Aimbot Angles", "export", function()
end), import_cfg = ui.new_button("AA", "Anti-Aimbot Angles", "import", function()
end), share_cloud = ui.new_button("AA", "Anti-Aimbot Angles", "share/update config", function()
end), cloud_line = ui.new_label("AA", "Anti-Aimbot Angles", "\n "), cloud_list = ui.new_listbox("AA", "Anti-Aimbot Angles", "\n ", {"nothing."}), cloud_author = ui.new_label("AA", "Anti-Aimbot Angles", " "), cloud_upd_date = ui.new_label("AA", "Anti-Aimbot Angles", " "), cloud_like = ui.new_label("AA", "Anti-Aimbot Angles", " "), cloud_like_btn = ui.new_button("AA", "Anti-Aimbot Angles", "like/unlike", function()
end), cloud_load = ui.new_button("AA", "Anti-Aimbot Angles", "load", function()
end), cloud_delete = ui.new_button("AA", "Anti-Aimbot Angles", "delete", function()
end), cloud_refresh = ui.new_button("AA", "Anti-Aimbot Angles", "refresh", function()
end)}
v68.about = {welcome = ui.new_label("AA", "Anti-Aimbot Angles", string.format("welcome back, \a99CEFFFF%s", v55.username)), yourbuild = ui.new_label("AA", "Anti-Aimbot Angles", string.format("build \a898989ff~ \a99CEFFFF%s", v55.build)), last_update = ui.new_label("AA", "Anti-Aimbot Angles", string.format("last update \a898989ff~ \a99CEFFFF%s", v55.last_update)), line = ui.new_label("AA", "Anti-Aimbot Angles", "\n "), line1 = ui.new_label("AA", "Anti-Aimbot Angles", "\n "), discord = ui.new_button("AA", "Anti-Aimbot Angles", "\a99CEFFFF\238\132\186 \abdbdbdffdiscord server", function()
	panorama.open().SteamOverlayAPI.OpenURL("https://discord.gg/6XJ8CvvBTd")
end)}
local v73 = (function()
	local v579 = {}
	return function(v1953, v1954)
		local v1955 = function()
			local v2300 = true
			for _, v2302 in ipairs(v1954) do
				if type(v2302) == "table" and #v2302 > 1 then
					local v2303 = v2302[1]
					local v2304 = v2302[2]
					if type(v2304) == "function" then
						if not v2304() then
							v2300 = false
							break
						end
					elseif (type(v2303) == "userdata" or type(v2303) == "number" or type(v2303) == "string") and v2304 ~= ui.get(v2303) then
						v2300 = false
						break
					end
				end
			end
			if type(v1953) == "userdata" or type(v1953) == "number" or type(v1953) == "string" then
				ui.set_visible(v1953, v2300)
			end
		end
		for _, v1957 in ipairs(v1954) do
			if type(v1957) == "table" and #v1957 > 1 then
				local v1958 = v1957[1]
				if type(v1958) == "userdata" or type(v1958) == "number" then
					if not v579[v1958] then
						v579[v1958] = {}
						ui.set_callback(v1958, function()
							for _, v2306 in ipairs(v579[v1958]) do
								v2306()
							end
						end)
					end
					table.insert(v579[v1958], v1955)
				end
			end
		end
		v1955()
	end
end)()
export_cfg = function(v580)
	local v581 = {}
	for _, v583 in pairs(v67.states) do
		v581[v583] = {}
		for _, v585 in ipairs(v580) do
			if v585[v583] then
				for v586, v587 in pairs(v585[v583]) do
					v581[v583][v586] = ui.get(v587)
				end
			end
		end
	end
	return v581
end
import_cfg = function(v588, v589)
	for _, v591 in ipairs(v588) do
		for _, v593 in pairs(v67.states) do
			if v591[v593] and v589[v593] then
				for v594, v595 in pairs(v591[v593]) do
					if v589[v593][v594] ~= nil then
						ui.set(v595, v589[v593][v594])
					end
				end
			end
		end
	end
end
aa_builder = {}
aa_builder_defensive = {}
for _, v75 in ipairs(v67.states) do
	aa_builder[v75] = {}
	aa_builder_defensive[v75] = {}
	local v76 = aa_builder[v75]
	local v77 = aa_builder_defensive[v75]
	v76.enabled = ui.new_checkbox("AA", "Anti-Aimbot Angles", string.format("\a99CEFFFF\226\128\162 \abdbdbdffoverride \a99CEFFFF~ \abdbdbdff%s", v75))
	v76.yaw = ui.new_combobox("AA", "Anti-Aimbot Angles", "yaw \aFFFFFF00" .. v75 .. "", {"off", "180", "180 randomization"})
	v76.way_mode = ui.new_slider("AA", "Anti-Aimbot Angles", "mode\aFFFFFF00" .. v75 .. "", 0, 1, 1, true, "\194\176", 1, {[0] = "1way", [1] = "2way"})
	v76.yaw_add = ui.new_slider("AA", "Anti-Aimbot Angles", "yaw add \aFFFFFF00" .. v75 .. "", -180, 180, 0, true, "\194\176", 1, {})
	v76.yaw_add_left = ui.new_slider("AA", "Anti-Aimbot Angles", "left \aFFFFFF00" .. v75 .. "", -180, 180, 0, true, "\194\176", 1, {})
	v76.yaw_randomization_left = ui.new_slider("AA", "Anti-Aimbot Angles", "\n \aFFFFFF00 l randomizaion" .. v75 .. "", 0, 100, 0, true, "%", 1, {[0] = "Off"})
	v76.yaw_add_right = ui.new_slider("AA", "Anti-Aimbot Angles", "right \aFFFFFF00" .. v75 .. "", -180, 180, 0, true, "\194\176", 1, {})
	v76.yaw_randomization = ui.new_slider("AA", "Anti-Aimbot Angles", "\n \aFFFFFF00 r randomization" .. v75 .. "", 0, 100, 0, true, "%", 1, {[0] = "Off"})
	v76.yaw_jitter = ui.new_combobox("AA", "Anti-Aimbot Angles", "yaw jitter \aFFFFFF00" .. v75 .. "", {"off", "center", "random"})
	v76.yaw_jitter_slider = ui.new_slider("AA", "Anti-Aimbot Angles", "jitter ammount \aFFFFFF00" .. v75 .. "", -180, 180, 0, true, "\194\176", 1, {})
	v76.body_yaw = ui.new_combobox("AA", "Anti-Aimbot Angles", "body yaw\aFFFFFF00" .. v75 .. "", {"off", "static", "jitter", "adaptive"})
	v76.body_yaw_value_static = ui.new_slider("AA", "Anti-Aimbot Angles", "desync\n \aFFFFFF00" .. v75 .. "", -60, 60, 1, true, "\194\176", 1, {[0] = "Off"})
	v76.body_yaw_value_left = ui.new_slider("AA", "Anti-Aimbot Angles", "desync left\n \aFFFFFF00" .. v75 .. "", 0, 60, 1, true, "\194\176", 1, {[0] = "Off"})
	v76.body_yaw_value_right = ui.new_slider("AA", "Anti-Aimbot Angles", "desync right\n \aFFFFFF00" .. v75 .. "", 0, 60, 1, true, "\194\176", 1, {[0] = "Off"})
	v76.delay_type = ui.new_combobox("AA", "Anti-Aimbot Angles", "delay type\n \aFFFFFF00" .. v75 .. "", {"normal", "ticks"})
	v76.delay_slider = ui.new_slider("AA", "Anti-Aimbot Angles", "delay \aFFFFFF00" .. v75 .. "", 1, 8, 1, true, "%", 1, {"Off"})
	v76.delay_slider_min = ui.new_slider("AA", "Anti-Aimbot Angles", "delay min \aFFFFFF00" .. v75 .. "", 1, 8, 1, true, "%", 1, {"Off"})
	v76.delay_slider_max = ui.new_slider("AA", "Anti-Aimbot Angles", "delay max \aFFFFFF00" .. v75 .. "", 1, 8, 1, true, "%", 1, {"Off"})
	v76.random_delay = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a636363ffdelay randomization \aFFFFFF00" .. v75 .. "")
	v76.disable_desync_exploit = ui.new_checkbox("AA", "Anti-Aimbot Angles", "\a636363ffdesync random \aFFFFFF00" .. v75 .. "")
	v77.enabled_def = ui.new_checkbox("AA", "Fake lag", string.format("\a99CEFFFF\226\128\162 \abdbdbdffdefensive ~ %s", v75))
	v77.override_antiaim_def = ui.new_checkbox("AA", "Fake lag", "\a99CEFFFF\226\128\162 \abdbdbdffoverride antiaim \aFFFFFF00" .. v75 .. "")
	v77.pitch_def = ui.new_combobox("AA", "Fake lag", "pitch \aFFFFFF00" .. v75 .. "", {"off", "up", "down", "random", "zero", "custom"})
	v77.pitch_slider_def = ui.new_slider("AA", "Fake lag", "custom pitch \aFFFFFF00" .. v75 .. "", -89, 89, 0, true, "\194\176", 1, {})
	v77.yaw_def = ui.new_combobox("AA", "Fake lag", "yaw \aFFFFFF00" .. v75 .. "", {"off", "180", "spin", "forward", "jitter", "random"})
	v77.yaw_slider_def = ui.new_slider("AA", "Fake lag", "yaw add \aFFFFFF00" .. v75 .. "", -180, 180, 0, true, "\194\176", 1, {})
end
local v78 = {antiaim = {spin_antiaim_defensive = 0, manual_side = 0, last_right = false, last_forward = false, last_left = false, to_jitter = false, current_tickcount = globals.tickcount(), delay_timernew = globals.tickcount(), desync_save = 180, delay_aa = 0, best_side = 1, random_del = 0, ground_tick = 1}, misc = {timer = globals.tickcount()}, other = {ft_prev = 0, clan_tag = {"\\", "\\/", "V", "V4", "Va", "Var", "Var|5", "Varg", "Varg", "Varg", "Varg", "Varg", "Varg", "Varg", "\\arg", "\\/arg", "arg", "4rg", "rg", "g", "|5", "", "", ""}, clan_tag_prev = "", avatar_texture = nil, inds = {}, hitgroup_names = {"generic", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear"}}, trashtalk_main = {ru = {"\209\130\209\139 \208\189\208\190\209\129\208\190\208\188 \208\177\208\176\208\177\208\186\209\131 \208\191\209\128\208\190\208\177\208\184\208\187 \209\129\209\139\208\189 \209\136\208\187\209\142\209\133\208\184", "\209\131 \209\130\209\143 \209\137\208\181\208\186\208\184 \208\186\208\176\208\186 \209\131 \209\141\208\187\208\178\208\184\208\189\208\176 \208\184\208\183 \208\177\209\131\209\128\209\131\208\189\208\180\209\131\208\186\208\190\208\178", "\209\131 \209\130\209\143 \208\177\208\176\208\177\208\186\208\176 \208\178 \208\186\209\128\208\181\209\129\209\130\208\190\208\178\209\139\208\185 \208\191\208\190\209\133\208\190\208\180 \208\189\208\176 \208\177\208\176\208\185\208\180\208\176\209\128\208\186\208\181 \209\131\208\191\208\187\209\139\208\187\208\176", "\209\130\208\176\208\186 \208\178\209\129\208\181 \208\181\208\177\208\176\208\187\209\140\208\189\208\184\208\186\208\184 \209\130\208\178\208\190\208\184 \208\178\209\129\208\181 \208\191\208\181\208\189\208\184\209\129\209\139 \208\188\208\190\208\184", "\208\189\208\181 \208\188\208\184\209\129\209\129\208\176\208\185 \209\136\208\187\209\142\209\133\208\176", "\209\130\208\176\208\186 \209\143 \208\182\208\181 \209\130\208\178\208\190\208\181\208\185 \209\129\208\181\209\129\209\130\209\128\208\181 \209\128\209\131\208\186\208\184 \208\190\209\130\209\128\208\181\208\183\208\176\208\187", "\208\189\208\176 \208\181\208\177\208\187\208\181 \209\131 \209\130\209\143 \208\182\208\184\209\128 \208\191\208\184\208\180\209\128\208\184\208\187\208\176", "\209\143 \209\130\208\178\208\190\209\142 \208\177\208\176\208\177\208\186\209\131 \208\178 \208\186\208\176\208\189\208\180\208\176\208\187\209\139 \208\187\208\190\208\182\208\184\208\187 \208\191\208\184\208\180\209\128\208\184\208\187\208\176", "\209\130\208\176\208\186 \209\143 \208\177\208\190\208\179 \208\191\209\128\208\176\208\178\208\180\209\139 \209\130\209\139 \208\177\208\190\208\179 \208\187\208\182\208\184", "\208\181\208\177\208\176\208\189\209\139\208\185 \209\129\209\139\208\189 \209\129\208\191\208\187\208\184\208\189\209\130\208\181\209\128\208\176", "\208\186\208\176\208\186 \208\182\208\181 \209\143 \209\130\208\181 \208\189\208\176 \209\128\208\190\209\130\208\176\208\189 \208\189\208\176\209\129\209\130\209\128\209\131\208\179\208\176\208\187 \208\177\208\190\208\188\208\182\209\131 \208\181\208\177\208\176\208\189\208\190\208\188\209\131", "\208\189\208\184\208\186\209\135\208\181\208\188\208\189\209\139\208\185 \209\129\209\139\208\189 \209\136\208\187\209\142\209\133\208\184", "\209\131 \209\130\209\143 \208\189\208\176 \208\176\208\186\208\186\208\176\209\131\208\189\209\130\208\181 \208\178\209\129\208\181 \208\177\208\190\208\188\208\182\208\184 \209\129\208\184\208\180\208\187\208\184", "\209\130\209\139 \208\188\208\190\208\185 \209\133\209\131\208\185 \209\128\209\130\208\190\208\188 \209\129\208\178\208\190\208\184\208\188 \208\191\209\128\208\181\208\178\208\190\209\129\209\133\208\190\208\180\208\184\209\136\208\179\209\140", "\209\130\209\139 \208\187\208\181\209\129\208\181\208\189\208\186\208\190\208\185 \208\191\208\184\209\136\208\181\209\136\209\140 \208\184 \208\180\208\176\208\182\208\181 \209\130\208\176\208\186 \208\188\208\181\208\180\208\187\209\143\208\186", "\208\176 \209\133\208\190\209\128\208\190\209\136\208\190 \208\186\208\190\208\187\209\133\208\190\208\183\208\176\208\189 \208\181\208\177\208\176\208\189\209\139\208\185", "\209\141\209\130\208\190 \208\182\208\181 \209\131 \209\130\209\143 \208\177\208\176\209\130\209\143 \208\189\208\176 \209\130\209\128\208\176\208\186\209\130\208\190\209\128\208\181 \208\187\209\131\208\186\208\176\209\136\208\181\208\189\208\186\208\190 \208\186\208\190\209\129\208\191\208\187\208\181\208\184\209\130", "\208\184\208\180\208\184 \208\189\208\176\209\133\209\131\208\185 \208\190\209\130\209\129\209\142\208\180\208\176\208\177\208\190\208\188\208\182", "\209\143 \208\188\208\176\209\130\209\140 \209\130\208\178\208\190\209\142 \208\181\208\177\208\176\208\187", "\208\188\208\190\209\143 \208\182\208\190\208\191\208\176 \208\183\208\176\209\136\208\184\209\132\209\128\208\190\208\178\208\176\208\189\208\176 \209\130\208\178\208\190\208\184\208\188 \209\143\208\183\209\139\208\186\208\190\208\188", "\209\131 \209\130\209\143 \208\188\208\176\208\188\208\176 \209\129\209\130\208\176\208\186\208\176\208\189\208\184\209\130\208\176", "\209\130\209\139 \208\180\208\184\208\189\208\190\208\183\208\176\208\178\209\128 \208\181\208\177\208\176\208\189\209\139\208\185 \208\183\208\176\209\129\209\130\209\128\209\143\208\178\209\136\208\184\208\185 \208\178 20 \208\179\208\190\208\180\209\131", "\209\143 \209\130\208\178\208\190\208\185 \209\136\208\176\209\131\209\128\208\188\208\181\209\135\208\189\209\139\208\185 \208\187\208\176\209\128\208\181\208\186 \209\129\208\190\208\182\208\179\209\131 \208\191\209\128\208\184\208\180\209\131\209\128\208\190\208\186", "\209\143 \209\130\208\181 \208\178 \208\179\208\187\208\176\208\183\208\176 \208\186\208\190\208\189\209\135\208\176\208\187 \209\129\208\178\208\184\208\189\209\140\209\143 \209\131\208\183\208\186\208\190\208\179\208\187\208\176\208\183\208\176\209\143", "\208\184\208\180\208\184 \208\176\209\128\208\177\209\131\208\183\209\139 \209\128\209\131\208\177\208\184 \208\183\209\131\208\177\208\176\208\188\208\184 \208\177\208\190\208\177\208\181\209\128 \208\181\208\177\208\176\208\189\209\139\208\185", "\208\163 \208\162\208\149\208\145\208\175 \208\154\208\144\208\150\208\148\208\171\208\153 \208\165\208\144\208\153\208\155\208\144\208\153\208\144\208\162 \208\159\208\160\208\152\208\156\208\149\208\160\208\157\208\158 \208\154\208\144\208\154\208\144 \208\145\208\144\208\145\208\154\208\144 \208\157\208\144 \208\152\208\157\208\146\208\144\208\155\208\152\208\148\208\157\208\158\208\153 \208\154\208\158\208\155\208\175\208\161\208\154\208\149 \208\145\208\160\208\144\208\162\208\144\208\157", "\208\189\208\190\209\128\208\188 \208\188\208\176\209\130\209\140 \209\129\208\178\208\190\209\142 \208\182\208\181 \208\183\208\176 \208\191\208\190\208\187\209\130\208\190\209\128\208\176\209\136\208\186\209\131 \208\191\209\128\208\190\208\180\208\176\208\187", "\209\131 \209\130\209\143 \208\177\208\176\208\177\208\186\208\176 \208\179\208\176\208\180\208\176\208\187\208\186\208\176 \208\191\209\128\208\190\209\129\208\186\208\176\208\189\208\184\209\128\208\190\208\178\208\176\208\187\208\176 \208\188\208\181\208\189\209\143 \208\184 \208\178\209\139\209\143\208\178\208\184\208\187\208\176 \209\135\209\130\208\190 \209\143 \208\188\208\190\208\179\209\131 \208\177\209\139\209\130\209\140 \208\189\208\190\209\128\208\188\208\176\208\187\209\140\208\189\209\139\208\188", "\209\141\209\130\208\190 \208\191\208\184\208\183\208\180\208\181\209\134 \208\183\208\176\209\137\208\181\208\186\208\176\208\189\208\181\209\134 \209\128\208\181\208\176\208\187\209\140\208\189\208\190 \208\184\208\189\208\181\209\130 \209\129 \208\188\208\190\208\180\208\181\208\188\208\176 \208\187\208\190\208\178\208\184\209\130", "\208\186\208\190\208\189\209\131\209\129 \208\184\208\183 \209\132\208\190\208\187\209\140\208\179\208\184 \208\189\208\176 \208\181\208\177\208\187\208\190 \208\189\208\176\209\130\209\143\208\189\209\131\208\187 \208\184 \208\186\208\190\208\189\208\189\208\181\208\186\209\130 \209\129 \208\186\208\190\209\129\208\188\208\190\209\129\208\190\208\188 \208\187\208\190\208\178\208\184\209\130", "\208\178 \209\136\209\130\208\176\208\189\209\139 \208\191\208\190\209\129\208\188\208\190\209\130\209\128\208\184 \208\184 \209\131\208\183\208\189\208\176\208\181\209\136\209\140 \209\135\208\190 \209\130\208\176\208\186\208\190\208\181 \208\191\208\181\208\189\208\184\209\129", "\208\188\208\189\208\181 \208\189\209\128\208\176\208\178\208\184\209\130\209\129\209\143 \208\186\208\176\208\186 \209\130\209\139 \209\129\208\180\208\181\209\128\208\182\208\184\208\178\208\176\209\143 \209\129\208\187\208\181\208\183\209\139 \208\180\208\181\208\187\208\176\208\181\209\136\209\140 \208\178\208\184\208\180 \209\135\209\130\208\190 \209\130\209\139 \208\190\209\135 \208\186\209\128\209\131\209\130", "\208\176 \208\188\208\190\208\182\208\189\208\190 \209\143 \209\133\209\131\208\181\208\188 \208\191\208\190 \209\130\208\178\208\190\208\184\208\188 \208\177\208\184\208\178\208\189\209\143\208\188 \208\191\208\190\208\178\208\190\208\182\209\131?", "\208\178\208\176\208\189\208\181\208\186 \208\187\209\142\208\177\208\184\209\130 \208\190\208\177\208\188\208\176\208\183\209\139\208\178\208\176\209\130\209\140 \208\191\209\131\208\183\208\190 \208\188\208\176\208\185\208\190\208\189\208\181\208\183\208\190\208\188", "\208\159\208\152\208\148\208\158\208\160\208\161\208\154\208\152\208\149 \208\156\208\149\208\147\208\144\208\156\208\158\208\151\208\147\208\152", "\208\188\208\190\208\182\208\181\209\130 \208\181\209\137\208\181 \209\128\208\176\208\183 \208\189\208\176\208\191\208\184\209\136\208\181\209\136\209\140 \209\135\209\130\208\190 \209\130\209\139 \209\132\208\181\208\185\208\188?", "\208\176\208\187\208\190 \209\135\209\131\208\178\208\176\208\186 \209\129\208\186\208\176\208\182\208\184 \209\135\209\130\208\190 \209\130\209\139 \209\132\208\181\208\185\208\188", "\209\130\208\181\208\177\208\181 \208\180\208\176\208\182\208\181 40 \208\187\208\181\209\130\208\189\208\184\208\185 \208\189\208\181 \208\180\208\176\209\129\209\130", "\208\177\209\128\208\176\209\130\208\176\208\189 \209\130\209\139 \209\129\208\191\208\176\208\189\209\135\208\177\208\190\208\177 \209\131 \209\130\209\143 \208\180\209\139\209\128\208\186\208\184 \208\178\208\181\208\183\208\180\208\181", "\209\131 \209\130\208\178\208\190\208\181\208\185 \208\188\208\176\208\188\209\139 \208\191\208\187\208\181\209\129\208\181\208\189\209\140 \208\191\208\190\208\180 \209\143\208\183\209\139\208\186\208\190\208\188, \208\190\208\189\208\176 \208\179\208\190\208\178\208\190\209\128\208\184\209\130 \209\141\209\130\208\190 \208\179\209\128\209\143\208\180\208\186\208\184", "\208\191\209\128\208\190\209\129\209\130\208\190 \208\191\208\190\208\185\208\188\208\184 \209\135\209\130\208\190 \209\130\208\181\208\177\209\143 \208\189\208\184\208\186\209\130\208\190 \208\189\208\181 \209\131\208\178\208\176\208\182\208\176\208\181\209\130"}, eng = {"must suck losing", "dead again? laff", "if you had varg you wouldn't die like this", "(\226\151\163_\226\151\162) varg runs this server (\226\151\163_\226\151\162)", "dying like this? XDD", "outskilled lol", "bro alt-tabbed? \240\159\152\130", "varg > u", "click heads, not walls", "that all you got?", "again? embarrassing", "check your ping... or your skill", "aim.exe missing", "guess who\226\128\153s back? varg.", "spectate to learn", "you see me, you die", "varg strikes again", "ur screen went black huh", "next round, same result", "you play like a bot", "varg carried that shot", "snapped like twig", "brought a knife to a gunfight?", "shoulda stayed in spawn", "you\226\128\153re boosting my K/D", "yesterday you saved your head. today, you'll be dead.", "varg's junior", "go ask chatgpt how to make a config", "go hang yourself emo boy", "first time playing hvh?", "(\227\129\163\226\151\148\226\151\161\226\151\148)\227\129\163 \226\153\165 Varg \226\153\165", "UWUJKA (fembotyky) vs VARG - clear winner", "not having varg is a skill issue", "getting killed by varg makes u \240\157\147\175\240\157\147\187\240\157\147\174\240\157\147\170\240\157\147\180\240\157\148\130", "2026, still no opponents", "sit again nn", "you ever win?", "bro can't breathe out here", "this is a varg diff", "u playin or watchin?", "downed AGAIN lmao", "how\226\128\153s the floor taste?", "varg saw you first. you died.", "varg doesn't miss", "lol'd at that peek", "died doing what he loved: nothing", "still not learning huh", "yo uninstall maybe?", "are you ok bro?", "same death, same guy", "you get paid to die like that?", "varg lives, you don\226\128\153t", "this the best they queue?", "you good? need backup?", "varg moment \240\159\151\191", "you make this easy", "try a different game maybe", "surprised you managed to hit the download button bot", "need help pressing W A S D?", "good luck escaping varg"}, cn = {"\228\189\160\231\136\185\229\166\136\231\148\159\228\189\160\230\151\182\230\152\175\228\184\141\230\152\175\230\138\138\232\131\142\231\155\152\229\133\187\229\164\167\228\186\134\239\188\159", "\228\189\160\229\166\136\229\156\168\228\186\167\230\136\191\230\152\175\228\184\141\230\152\175\231\155\180\230\142\165\230\138\138\228\189\160\229\189\147\229\140\187\231\150\151\229\186\159\231\137\169\230\137\148\228\186\134\239\188\159", "\228\189\160\232\162\171\229\176\138\232\180\181\231\154\132varg\231\148\168\230\136\183\229\135\187\230\157\128\228\186\134", "\228\189\160\228\184\156\229\140\151\231\136\185\230\152\175\228\184\141\230\152\175\231\148\168\231\131\167\231\129\171\230\163\141\231\187\153\228\189\160\229\188\128\231\154\132\232\132\145\230\180\158\239\188\159\230\128\170\228\184\141\229\190\151\230\147\141\228\189\156\232\183\159\229\150\157\229\129\135\233\133\146\228\188\188\231\154\132\239\188\129", "\228\189\160\229\185\191\228\184\156\231\136\185\230\152\175\228\184\141\230\152\175\229\144\131\231\166\143\229\187\186\228\186\186\229\144\131\229\164\154\228\186\134\239\188\159\230\147\141\228\189\156\229\131\143\231\148\159\229\144\158\228\186\134\233\148\174\231\155\152\239\188\129", "\228\189\160\229\133\168\229\174\182\230\136\183\229\143\163\230\156\172\230\152\175\228\184\141\230\152\175\232\162\171\228\184\156\229\140\151\230\154\180\233\163\142\233\155\170\229\159\139\228\186\134\239\188\159\230\175\149\231\171\159\228\189\160\231\136\185\229\166\136\233\131\189\230\152\175\230\141\161\231\160\180\231\131\130\231\154\132\239\188\129", "\228\189\160\230\178\179\229\141\151\229\166\136\230\152\175\228\184\141\230\152\175\229\156\168\229\175\140\229\163\171\229\186\183\232\183\179\230\165\188\232\162\171\229\136\134\229\176\184\231\148\159\231\154\132\228\189\160\239\188\159", "\228\189\160\229\133\168\229\174\182DNA\230\152\175\228\184\141\230\152\175\232\162\171\230\151\165\230\156\172\230\160\184\229\186\159\230\176\180\230\148\185\233\128\160\230\136\144\228\184\167\229\176\184\228\186\134\239\188\159", "\228\189\160\229\166\136\230\152\175\228\184\141\230\152\175\231\148\168\230\147\128\233\157\162\230\157\150\231\187\153\228\189\160\229\188\128\232\146\153\231\154\132\239\188\159", "varg.lua\239\188\140\229\174\131\230\152\175\228\187\163\231\160\129\229\174\135\229\174\153\231\154\132\230\129\146\230\152\159\239\188\129\232\191\144\232\161\140\233\128\159\229\186\166\229\131\143\232\162\171\233\151\170\231\148\181\229\135\187\228\184\173\231\154\132\231\140\142\232\177\185\239\188\140\232\128\140\228\189\160\231\154\132CPU\229\156\168\229\176\150\229\143\171\239\188\154'\230\155\180\229\164\154\239\188\129\230\155\180\229\164\154\239\188\129", "\228\189\160\231\136\185\231\154\132\230\159\147\232\137\178\228\189\147\230\152\175\228\184\141\230\152\175\229\133\168\232\162\171\228\189\160\229\166\136\230\139\191\229\142\187\231\187\135\230\175\155\232\161\163\228\186\134\239\188\159", "\228\189\160\229\133\168\229\174\182\230\152\175\228\184\141\230\152\175\232\162\171\228\184\156\229\140\151\230\154\180\233\163\142\233\155\170\229\141\183\232\191\155\231\187\158\232\130\137\230\156\186\228\186\134\239\188\159", "\228\189\160\229\133\168\229\174\182\229\165\179\230\128\167\233\131\189\232\175\165\229\142\187\229\166\135\232\129\148\230\138\149\232\175\137\228\189\160\231\136\184\231\154\132\229\159\186\229\155\160\239\188\129", "1 \227\128\130\227\128\130\227\128\130z\\\227\128\130\227\128\130\227\128\130", "\228\189\160\231\136\185\231\154\132\233\170\168\231\129\176\231\155\146\230\152\175\228\184\141\230\152\175\232\162\171\228\189\160\230\139\191\230\157\165\229\189\147\233\188\160\230\160\135\229\158\171\228\186\134\239\188\159", "\228\189\160\231\136\185\231\154\132\231\178\190\229\173\144\229\186\147\230\152\175\228\184\141\230\152\175\232\162\171\230\160\184\229\186\159\230\176\180\230\177\161\230\159\147\228\186\134\239\188\159", "\228\189\160\229\166\136\231\148\159\228\189\160\230\151\182\230\152\175\228\184\141\230\152\175\230\138\138\231\190\138\230\176\180\229\150\157\229\164\154\228\186\134\239\188\140\232\132\145\229\173\144\232\191\155\230\176\180\228\186\134\239\188\159", "\228\189\160\229\133\168\229\174\182\229\186\148\232\175\165\233\155\134\228\189\147\229\142\187\229\129\154\228\186\178\229\173\144\233\137\180\229\174\154", "\228\189\160\229\133\168\229\174\182\231\166\143\230\152\175\228\184\141\230\152\175P\231\154\132\239\188\159", "varg\231\154\132\230\179\168\233\135\138\230\175\148\232\176\183\230\173\140\231\191\187\232\175\145\231\154\132\231\140\170\232\185\132\232\143\156\232\176\177\232\191\152\231\178\190\229\135\134\239\188\129\230\175\143\228\184\170\229\141\149\232\175\141\233\131\189\229\131\143\228\188\154\232\183\179\232\138\173\232\149\190\231\154\132\229\131\181\229\176\184\229\156\168\233\148\174\231\155\152\228\184\138\232\183\179\232\136\158\239\188\129", "\228\189\160\229\166\136\230\148\185\229\171\129\228\184\137\230\172\161\233\131\189\231\148\159\228\184\141\229\135\186\228\189\160\232\191\153\228\185\136\229\186\159\231\154\132", "\228\189\160\231\136\184\230\152\175\228\184\141\230\152\175\231\148\168\232\132\154\232\182\190\229\164\180\231\187\153\228\189\160\230\138\165\231\154\132\231\148\181\231\171\158\232\161\165\228\185\160\231\143\173\239\188\159", "\226\128\156\228\189\160\229\185\191\228\184\156\231\136\185\230\152\175\228\184\141\230\152\175\229\156\168\233\157\158\230\180\178\229\189\147\229\165\180\233\154\182\232\162\171\233\152\137\229\137\178\231\148\159\231\154\132\228\189\160\239\188\159", "\228\189\160\229\188\159\231\142\169\232\180\170\229\144\131\232\155\135\233\131\189\230\175\148\228\189\160\231\187\149\229\190\151\230\152\142\231\153\189", "\228\189\160\230\150\176\231\150\134\231\136\185\230\152\175\228\184\141\230\152\175\229\156\168\230\178\153\230\188\160\233\135\140\232\162\171\230\129\144\230\128\150\229\136\134\229\173\144\230\180\187\229\159\139\231\148\159\231\154\132\228\189\160\239\188\159", "\229\164\169\229\164\169\232\185\178\230\139\137\229\149\138\239\188\159\228\189\160\230\156\137\229\149\165\231\148\168\229\149\138\239\188\140\229\189\147\232\158\131\232\159\185\232\162\171e\229\176\177\231\186\162\230\184\169\239\188\159", "\228\189\160aa\232\132\134\231\154\132\229\131\143\232\128\129\229\164\180XD", "\232\155\164\233\131\189\232\155\164\228\184\141\230\135\130\231\142\169\229\149\165\229\145\162\229\149\138\239\188\140\232\128\129\233\147\129\239\188\159", "\228\189\160\231\169\191\233\131\189\231\169\191\228\184\141\230\152\142\231\153\189\232\191\152\230\131\179\231\169\191\232\182\138\231\130\185\228\189\141\229\145\162\239\188\159", "\230\137\163\228\184\128\233\128\129\230\149\176\229\128\188", "\230\128\165\230\136\144\229\149\165\228\186\134\239\188\159\232\131\189\228\184\141\232\131\189\229\189\147\228\184\139\232\180\164\232\128\133\233\157\153\233\157\153\229\191\131", "\231\142\169\231\157\128\230\160\183\231\154\132\232\191\152\230\131\179\232\131\156\229\136\169\229\145\162\239\188\159", "\228\184\186\231\136\177\229\129\1540\229\176\143\229\167\144", "\229\176\177\228\189\160\232\191\153\232\132\145\229\173\144\229\136\171\232\175\180hvh\228\186\134\239\188\140\229\188\128\230\184\184\230\136\143\233\131\189\232\180\185\229\138\178", "\229\176\177\228\189\160\232\191\153\230\176\180\229\185\179\232\191\152\231\187\153\230\136\145\230\137\1631\239\188\1591\233\128\129\231\187\153\228\189\160\231\154\132^^", "\229\143\130\230\149\176\228\184\141\232\161\140iq\229\135\145\239\188\140\228\189\160\233\131\189\230\178\161\230\156\137\232\191\152\229\146\139\231\142\169\229\149\138\239\188\159\230\136\145\228\184\141\229\150\156\230\172\162\231\142\169\229\141\149\230\156\186", "\229\188\177\230\153\186........", "\229\143\171\231\136\185\231\187\153\228\189\160\228\185\176lua\233\128\129\231\187\173\232\180\185\228\186\134\239\188\140\230\136\145\229\150\156\230\172\162\229\188\186\231\154\132\229\175\185\230\137\139", "\233\170\130\228\189\160\228\189\160\229\136\171\230\128\165\239\188\140\230\175\149\231\171\159\230\136\145\230\157\128\231\154\132\230\152\175\230\137\139\228\184\139\232\180\165\229\176\134", "1z game\239\188\140\230\137\147\228\189\160\231\156\159\231\154\132\229\165\189\230\151\160\232\182\163=-=", "Ai Peek?\230\128\142\228\185\136\228\184\128\233\170\151\229\176\177\229\135\186\239\188\140\232\166\129\228\184\141\230\136\145\233\128\129\228\189\160\228\184\128\228\184\170?", "\232\191\153\228\185\136\229\150\156\230\172\162\233\163\158?\230\178\161aa+\230\178\161\232\132\145\229\173\144,\233\154\190\231\187\183.....", "\229\136\171Peek\228\186\134\239\188\140\228\189\160\228\184\128\232\190\136\229\173\144\229\176\177\230\152\175\232\162\171\230\138\189\231\154\132\229\145\189", "\232\191\158\232\183\175\233\131\189\232\181\176\228\184\141\230\135\130\232\191\152\229\129\135\232\181\176\239\188\140\231\156\159\228\187\165\228\184\186\232\135\170\229\183\177\230\151\160\230\179\149\233\128\137\228\184\173\228\186\134\239\188\159", "Nanaaa\229\143\175\231\136\177\230\141\143\239\188\129", "\228\189\160\229\141\161\229\156\168\228\184\173\233\151\180\228\184\138\228\184\139\228\184\141\232\161\140\239\188\140\230\156\141\229\138\161\229\153\168\233\131\189\230\137\147\228\184\141\232\191\135\229\149\138", "\229\164\154\231\130\185\232\132\145\229\173\144\229\176\145\232\175\180\231\130\185\232\175\157\239\188\140\230\137\147\228\184\141\232\191\135\232\191\152\230\128\165.........", "\228\189\160\232\191\153\230\176\180\229\185\179\231\156\159\230\152\175\232\174\169\228\186\186\230\131\138\232\174\182\239\188\140\229\174\140\229\133\168\233\162\160\232\166\134\228\186\134\230\136\145\229\175\185\230\151\160\232\132\145\231\154\132\229\174\154\228\185\137", "\229\147\135\239\188\140\228\189\160\231\154\132\230\147\141\228\189\156\231\156\159\230\152\175\232\137\186\230\156\175\229\147\129\239\188\140\229\174\140\231\190\142\229\156\176\229\177\149\231\164\186\228\186\134\228\187\128\228\185\136\229\143\171\230\175\171\230\151\160\229\168\129\232\131\129\227\128\130", "\231\156\139\229\136\176\228\189\160\232\191\153\230\160\183\230\147\141\228\189\156\239\188\140\230\136\145\231\170\129\231\132\182\232\167\137\229\190\151\232\135\170\229\183\177\228\185\159\232\174\184\232\191\152\232\131\189\232\181\162\229\190\151\228\184\128\229\156\186\230\175\148\232\181\155\227\128\130", "\232\191\153\228\185\136\229\191\171\229\176\177\230\173\187\228\186\134\239\188\159\231\156\159\230\152\175\229\164\170\232\174\169\228\186\186\229\164\177\230\156\155\228\186\134\239\188\140\230\136\145\229\142\159\230\156\172\228\187\165\228\184\186\232\131\189\231\156\139\229\136\176\228\184\128\229\156\186\231\178\190\229\189\169\231\154\132\232\161\168\230\188\148\229\145\162\227\128\130", "\231\156\139\228\186\134\228\189\160\231\154\132\230\147\141\228\189\156\239\188\140\230\136\145\231\170\129\231\132\182\232\167\137\229\190\151\232\135\170\229\183\177\231\156\159\231\154\132\229\190\136\230\156\137\229\164\169\232\181\139\226\128\148\226\128\148\230\175\149\231\171\159\239\188\140\230\136\145\228\184\141\228\188\154\231\138\175\232\191\153\228\185\136\229\164\154\233\148\153\227\128\130", "\232\189\172\228\186\186\229\183\165", "\228\184\141\230\152\175IQ\230\178\161\231\148\168\239\188\140\230\152\175\228\189\160\231\187\131\231\154\132\233\130\163\228\186\155IQ\230\178\161\231\148\168", "\228\189\160\228\184\141\229\188\128AA\230\178\161\229\135\134\229\188\128\230\158\170\232\191\152\229\191\171\231\130\185", "Ez GAMEEEEEEEEE", "\228\186\139\229\174\158\232\175\129\230\152\142\231\142\169\228\186\134skcc\228\185\159\228\184\141\228\188\154\229\143\152\232\129\170\230\152\142", "\228\186\186\230\156\186", "1", "EZ", "\233\162\134\229\133\187", "\229\164\169\232\181\139\229\142\139\229\136\182", "\228\184\139\232\175\190", "\231\180\160\230\157\144\229\177\128", "\229\164\177\230\156\155", "\232\157\188\232\154\129", "\228\184\138\233\151\168\229\174\137\232\163\133\229\129\135\232\130\162", " \229\190\146\229\188\159\229\183\178\230\187\161\229\143\170\230\142\165\232\181\155\229\144\142\229\164\141\231\155\152", "\230\148\182\229\157\144\233\170\145", "\231\187\159\228\184\128\229\155\158\229\164\141:\230\178\161\229\188\128", "\233\188\160\230\160\135\230\178\161\229\136\176\230\137\139\230\159\132\231\142\169\231\154\132", "\229\183\174\232\183\157\232\135\170\229\183\177\230\137\190", "\230\136\145\229\143\170\232\131\189\230\149\153\228\189\160\228\187\172\232\191\153\228\185\136\229\164\154\228\186\134", "\230\156\137\231\156\159\228\186\186\229\144\151", "\229\162\168\233\149\156\228\184\138\232\189\166", "\230\150\176\230\137\139\230\149\153\231\168\139\228\184\141\230\152\175\232\191\135\228\186\134\229\144\151\230\128\142\228\185\136\229\143\136\230\157\165\228\184\128\233\129\141", "\229\143\170\229\189\147\228\184\187\230\146\173\228\184\141\230\137\147\232\129\140\228\184\154", "\229\143\171\228\189\160\228\187\172\229\174\182\229\164\167\228\186\186\230\157\165\231\142\169", "\231\166\143\229\136\169\229\177\128\239\188\159", "\232\135\170\229\183\177\230\137\190\229\183\174\232\183\157", "\231\153\189\231\187\131\228\184\128\230\138\138", "\230\181\170\232\180\185\230\136\145\231\189\145\232\180\185", "\229\139\164\232\131\189\232\161\165\230\139\153", "0iq", "4399\239\188\159", "bot\239\188\159", "\230\137\139\230\179\149", "\229\190\136\230\163\146\228\186\134\229\183\178\231\187\143", "\232\175\160\233\135\138", "\229\142\139\229\136\182", "\229\148\144\229\164\170\229\174\151\233\156\128\232\166\129\228\189\160", "\228\189\160\231\154\132\232\132\145\229\174\185\233\135\143\230\175\148\228\189\160\229\143\130\231\190\164\228\186\186\230\149\176\232\191\152\229\176\145", "\233\128\128\229\157\145\231\165\158\228\189\156", "\230\136\145\230\157\128\228\189\160\229\143\170\233\156\128\232\166\129\228\184\128\230\160\185\230\137\139\230\140\135", "\229\134\156\230\176\145\228\189\160\232\162\171\228\189\160\231\136\1851\228\186\134\239\188\140\230\187\154\229\142\187\228\185\176\228\184\170\229\165\189\231\130\185\231\154\132\229\143\130\230\149\176\229\144\167", "\229\156\168\229\177\143\229\185\149\229\137\141\231\186\162\230\184\169\231\154\132\230\160\183\229\173\144\232\162\171\230\136\145\232\174\176\229\189\149\228\184\139\230\157\165\228\186\134", "\228\189\160\230\152\175\230\178\161\230\156\137\230\137\139\229\144\151?"}}}
local v79 = {cloud_table = {}, cloud_likes = {}}
local v80 = {x = 12, y = 12, w = 0, h = 0}
local v81 = {x = X / 2, y = 150, dmg_x = X / 2, dmg_y = Y / 2 - 10}
local v82 = (function()
	local v597 = {}
	v597.vars = {get = function()
		return {local_player = entity.get_local_player(), game_rules = entity.get_game_rules()}
	end, update = function()
		v597.vars.get().local_player = entity.get_local_player()
		v597.vars.get().game_rules = entity.get_game_rules()
	end}
	local v598 = {}

	v598.rec = LPH_NO_VIRTUALIZE(function(L_791, L_792, L_793, L_794, L_795, L_796, L_797)
            L_796 = math.min(L_792 / 2, L_793 / 2, L_796);
            local L_798, L_799, L_800, L_801 = unpack(L_797);
            renderer.rectangle(L_792, L_793 + L_796, L_794, L_795 - L_796 * 2, L_798, L_799, L_800, L_801);
            renderer.rectangle(L_792 + L_796, L_793, L_794 - L_796 * 2, L_796, L_798, L_799, L_800, L_801);
            renderer.rectangle(L_792 + L_796, L_793 + L_795 - L_796, L_794 - L_796 * 2, L_796, L_798, L_799, L_800, L_801);
            renderer.circle(L_792 + L_796, L_793 + L_796, L_798, L_799, L_800, L_801, L_796, 180, 0.25);
            renderer.circle(L_792 - L_796 + L_794, L_793 + L_796, L_798, L_799, L_800, L_801, L_796, 90, 0.25);
            renderer.circle(L_792 - L_796 + L_794, L_793 - L_796 + L_795, L_798, L_799, L_800, L_801, L_796, 0, 0.25);
            renderer.circle(L_792 + L_796, L_793 - L_796 + L_795, L_798, L_799, L_800, L_801, L_796, -90, 0.25);
        end)

	v598.rec_outline = LPH_NO_VIRTUALIZE(function(L_619, L_620, L_621, L_622, L_623, L_624, L_625, L_626)
            L_624 = math.min(L_622 / 2, L_623 / 2, L_624);
            local L_627, L_628, L_629, L_630 = unpack(L_626);
            if L_624 == 1 then
                renderer.rectangle(L_620, L_621, L_622, L_625, L_627, L_628, L_629, L_630);
                renderer.rectangle(L_620, L_621 + L_623 - L_625, L_622, L_625, L_627, L_628, L_629, L_630);
            else
                renderer.rectangle(L_620 + L_624, L_621, L_622 - L_624 * 2, L_625, L_627, L_628, L_629, L_630);
                renderer.rectangle(L_620 + L_624, L_621 + L_623 - L_625, L_622 - L_624 * 2, L_625, L_627, L_628, L_629, L_630);
                renderer.rectangle(L_620, L_621 + L_624, L_625, L_623 - L_624 * 2, L_627, L_628, L_629, L_630);
                renderer.rectangle(L_620 + L_622 - L_625, L_621 + L_624, L_625, L_623 - L_624 * 2, L_627, L_628, L_629, L_630);
                renderer.circle_outline(L_620 + L_624, L_621 + L_624, L_627, L_628, L_629, L_630, L_624, 180, 0.25, L_625);
                renderer.circle_outline(L_620 + L_624, L_621 + L_623 - L_624, L_627, L_628, L_629, L_630, L_624, 90, 0.25, L_625);
                renderer.circle_outline(L_620 + L_622 - L_624, L_621 + L_624, L_627, L_628, L_629, L_630, L_624, -90, 0.25, L_625);
                renderer.circle_outline(L_620 + L_622 - L_624, L_621 + L_623 - L_624, L_627, L_628, L_629, L_630, L_624, 0, 0.25, L_625);
            end;
        end)

	v598.glow_module = LPH_NO_VIRTUALIZE(function(L_698, L_699, L_700, L_701, L_702, L_703, L_704, L_705, L_706)
            local L_707 = 1;
            local L_708 = 1;
            local L_709, L_710, L_711, L_712 = unpack(L_705);
            if L_706 then
                L_698:rec(L_699, L_700, L_701, L_702 + 1, L_704, L_706);
            end;
            for L_713 = 0, L_703 do
                if L_712 * (L_713 / L_703) ^ 1 > 5 then
                    local L_714 = { L_709, L_710, L_711, L_712 * (L_713 / L_703) ^ 2 };
                    L_698:rec_outline(L_699 + (L_713 - L_703 - 1) * 1, L_700 + (L_713 - L_703 - 1) * 1, L_701 - (L_713 - L_703 - 1) * 1 * 2, L_702 + 1 - (L_713 - L_703 - 1) * 1 * 2, L_704 + 1 * (L_703 - L_713 + 1), 1, L_714);
                end;
            end;
        end)

	v598.fajne_gowienko = LPH_NO_VIRTUALIZE(function(L_138, L_139, L_140, L_141, L_142, L_143, L_144, L_145)
            local L_146 = 1;
            local L_147 = 1;
            local L_148, L_149, L_150, L_151 = unpack(L_145);
            renderer.blur(L_139, L_140, L_141, L_142);
            L_138:rec(L_139, L_140, L_141, L_142 + 1, L_144, { 10, 10, 10, 60 });
            for L_152 = 0, L_143 do
                if L_151 * (L_152 / L_143) ^ 1 > 5 then
                    local L_153 = { L_148, L_149, L_150, L_151 * (L_152 / L_143) ^ 2 };
                    L_138:rec_outline(L_139 + (L_152 - L_143 - 1) * 1, L_140 + (L_152 - L_143 - 1) * 1, L_141 - (L_152 - L_143 - 1) * 1 * 2, L_142 + 1 - (L_152 - L_143 - 1) * 1 * 2, L_144 + 1 * (L_143 - L_152 + 1), 1, L_153);
                end;
            end;
            L_138:rec(L_139 - 1, L_140 - 1, L_141 + 2, L_142 + 2, L_144, { 255, 255, 255, 10 });
            L_138:rec_outline(L_139 - 1, L_140 - 1, L_141 + 2, L_142 + 2, L_144, 1, { 0, 0, 0, 10 });
        end)

	v598.pandora_og = LPH_NO_VIRTUALIZE(function(L_841, L_842, L_843, L_844, L_845, L_846, L_847, L_848, L_849, L_850, L_851)
            L_841:rec(L_842, L_843, L_844, L_845, 3, { 0, 0, 0, L_849 });
            L_841:rec_outline(L_842 + 1, L_843 + 1, L_844 - 2, L_845 - 2, 3, 1, { 45, 45, 45, L_849 });
            L_841:rec(L_842 + 3, L_843 + 3, L_844 - 6, L_845 - 6, 2, { 15, 15, 15, L_849 });
            renderer.text(L_842 + 5, L_843 + 6, L_846, L_847, L_848, L_849, L_851 or '', nil, L_850);
        end)
	v597.m_render = v598
	v597.menu = {set = function()
		v73(v68.info.lua_tab, {{v68.info.enable, true}, {"chuj", function()
			return false
		end}})
		v73(v68.info.online_text, {{v68.info.lua_tab, "\a99CEFFFF\238\128\151 \abdbdbdffback to menu"}})
		v73(v68.info.link_discord, {{v68.info.enable, false}})
		v73(v68.aa.yawbase, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}})
		v73(v68.aa.state, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}})
		v73(v68.aa.select_shit, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}})
		v73(v68.aa.line1, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}})
		v73(v68.aa.line2, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.aa.select_shit, function()
			return ui.get(v68.aa.select_shit) ~= "defensive"
		end}})
		v73(v68.aa.fakelag_mode, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.aa.select_shit, "fake-lag"}})
		v73(v68.aa.fakelag_limit, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.aa.select_shit, "fake-lag"}, {v68.aa.fakelag_mode, "default"}})
		v73(v68.aa.fakelag_limit_sway_min, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.aa.select_shit, "fake-lag"}, {v68.aa.fakelag_mode, "sway"}})
		v73(v68.aa.fakelag_limit_sway_max, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.aa.select_shit, "fake-lag"}, {v68.aa.fakelag_mode, "sway"}})
		v73(v68.aa.binds, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.aa.select_shit, "other"}})
		v73(v68.aa.freestanding_disablers, {{v68.aa.binds, function()
			return v66.contains(ui.get(v68.aa.binds), "freestanding") == true
		end}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.info.enable, true}, {v68.aa.select_shit, "other"}})
		v73(v68.aa.tweaks, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.aa.select_shit, "other"}})
		v73(v68.visuals.watermark, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}})
		v73(v68.visuals.watermark_color, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.watermark, true}})
		v73(v68.visuals.watermark_pos, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.watermark, true}})
		v73(v68.visuals.watermark_pos_sexy, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.watermark, true}, {v68.visuals.watermark_pos, "avatar-based"}})
		v73(v68.visuals.hitlogs, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}})
		v73(v68.visuals.hit_color, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.hitlogs, true}})
		v73(v68.visuals.miss_color, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.hitlogs, true}})
		v73(v68.visuals.hitlogs_opt, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.hitlogs, true}})
		v73(v68.visuals.logs_style, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.hitlogs, true}})
		v73(v68.visuals.watermark_opt, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.watermark, true}, {v68.visuals.watermark_pos, function()
			return ui.get(v68.visuals.watermark_pos) == "modern"
		end}})
		v73(v68.visuals.other_visuals, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}})
		v73(v68.visuals.other_visuals_color, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.other_visuals, function()
			return v66.contains(ui.get(v68.visuals.other_visuals), "speed warning") == true
		end}})
		v73(v68.visuals.speed_warning_color, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.other_visuals, function()
			return v66.contains(ui.get(v68.visuals.other_visuals), "speed warning") == true
		end}})
		v73(v68.visuals.damage_override_color, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.other_visuals, function()
			return v66.contains(ui.get(v68.visuals.other_visuals), "minimum damage override") == true
		end}})
		v73(v68.visuals.other_damage_override_color, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.other_visuals, function()
			return v66.contains(ui.get(v68.visuals.other_visuals), "minimum damage override") == true
		end}})
		v73(v68.visuals.manuals_color, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.other_visuals, function()
			return v66.contains(ui.get(v68.visuals.other_visuals), "manuals") == true
		end}})
		v73(v68.visuals.other_manuals_color, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.other_visuals, function()
			return v66.contains(ui.get(v68.visuals.other_visuals), "manuals") == true
		end}})
		v73(v68.visuals.thirdperson_dist, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.other_visuals, function()
			return v66.contains(ui.get(v68.visuals.other_visuals), "thirdperson distance") == true
		end}})
		v73(v68.visuals.aspect_ratio, {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\138\177 \abdbdbdffvisuals"}, {v68.visuals.other_visuals, function()
			return v66.contains(ui.get(v68.visuals.other_visuals), "aspect ratio") == true
		end}})
		for v1959, _ in pairs(v68.about) do
			v73(v68.about[v1959], {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\132\168 \abdbdbdffabout"}})
		end
		for v1961, _ in pairs(v68.misc) do
			v73(v68.misc[v1961], {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\132\149 \abdbdbdffutilities"}})
			if v1961:find("unsafe_recharge") or v1961:find("unmatched") then
				v73(v68.misc[v1961], {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\132\149 \abdbdbdffutilities"}, {"beta", function()
					return v55.build == "beta"
				end}})
			end
			if v1961:find("killsay_type") then
				v73(v68.misc[v1961], {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\132\149 \abdbdbdffutilities"}, {v68.misc.killsay, true}})
			end
			if v1961:find("jitter_fix") then
				v73(v68.misc[v1961], {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\132\149 \abdbdbdffutilities"}, {"beta", function()
					return v55.build == "beta"
				end}})
				if v1961:find("jitter_fix_type") then
					v73(v68.misc[v1961], {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\132\149 \abdbdbdffutilities"}, {v68.misc.jitter_fix, true}, {"beta", function()
						return v55.build == "beta"
					end}})
				end
			end
		end
		for v1963, _ in pairs(v68.config) do
			if v1963:match("config_type") then
				v73(v68.config[v1963], {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\132\133 \abdbdbdffconfiguration"}})
			else
				v73(v68.config[v1963], {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\132\133 \abdbdbdffconfiguration"}, {v68.config.config_type, "local"}})
			end
			if v1963:find("cloud_") then
				v73(v68.config[v1963], {{v68.info.enable, true}, {v68.info.lua_tab, "\a99CEFFFF\238\132\133 \abdbdbdffconfiguration"}, {v68.config.config_type, "cloud"}})
			end
		end
		v73(v68.aa.freestanding, {{v68.aa.binds, function()
			return v66.contains(ui.get(v68.aa.binds), "freestanding") == true
		end}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.info.enable, true}, {v68.aa.select_shit, "other"}})
		v73(v68.aa.edge_yaw, {{v68.aa.binds, function()
			return v66.contains(ui.get(v68.aa.binds), "edge-yaw") == true
		end}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.info.enable, true}, {v68.aa.select_shit, "other"}})
		v73(v68.aa.left_manual, {{v68.aa.binds, function()
			return v66.contains(ui.get(v68.aa.binds), "manuals") == true
		end}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.info.enable, true}, {v68.aa.select_shit, "other"}})
		v73(v68.aa.right_manual, {{v68.aa.binds, function()
			return v66.contains(ui.get(v68.aa.binds), "manuals") == true
		end}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.info.enable, true}, {v68.aa.select_shit, "other"}})
		v73(v68.aa.forward_manual, {{v68.aa.binds, function()
			return v66.contains(ui.get(v68.aa.binds), "manuals") == true
		end}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.info.enable, true}, {v68.aa.select_shit, "other"}})
		v73(v68.aa.info_kurwa, {{v68.aa.tweaks, function()
			return v66.contains(ui.get(v68.aa.tweaks), "e-spam (safe-head)") == true
		end}, {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}, {v68.aa.select_shit, "other"}})
		for v1965, _ in pairs(v68.info) do
			if v1965:find("button_ui") then
				if v1965:match("button_ui_1") then
					v73(v68.info[v1965], {{v68.info.lua_tab, function()
						return ui.get(v68.info.lua_tab) ~= "\a99CEFFFF\238\128\151 \abdbdbdffback to menu"
					end}, {v68.info.enable, true}})
				else
					v73(v68.info[v1965], {{v68.info.lua_tab, function()
						return ui.get(v68.info.lua_tab) == "\a99CEFFFF\238\128\151 \abdbdbdffback to menu"
					end}, {v68.info.enable, true}})
				end
			end
			if v1965:match("separator") then
				v73(v68.info[v1965], {{v68.info.lua_tab, function()
					return ui.get(v68.info.lua_tab) == "\a99CEFFFF\238\128\151 \abdbdbdffback to menu"
				end}, {v68.info.enable, true}})
			end
		end
		for v1967, v1968 in ipairs(v67.states) do
			local v1969 = aa_builder[v1968]
			local v1970 = aa_builder_defensive[v1968]
			local v1971 = {v68.info.lua_tab, "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"}
			local v1972 = {v68.info.enable, true}
			local v1973 = {v68.aa.state, v67.states[v1967]}
			local v1974 = {v1969.enabled, true}
			v73(v1969.enabled, {v1971, v1972, v1973})
			v73(v1969.yaw, {v1971, v1972, v1973, v1974})
			v73(v1969.yaw_add, {v1971, v1972, v1973, v1974, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}, {v1969.way_mode, function()
				return ui.get(v1969.way_mode) == 0
			end}})
			v73(v1969.way_mode, {v1971, v1972, v1973, v1974, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}, {v1969.yaw, function()
				return ui.get(v1969.yaw) == "180"
			end}})
			v73(v1969.yaw_add_right, {v1971, v1972, v1973, v1974, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}, {v1969.way_mode, function()
				return ui.get(v1969.way_mode) == 1
			end}})
			v73(v1969.yaw_add_left, {v1971, v1972, v1973, v1974, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}, {v1969.way_mode, function()
				return ui.get(v1969.way_mode) == 1
			end}})
			v73(v1969.yaw_randomization_left, {v1971, v1972, v1973, v1974, {v1969.yaw, function()
				return ui.get(v1969.yaw) == "180 randomization"
			end}, {v1969.way_mode, function()
				return ui.get(v1969.way_mode) == 1
			end}})
			v73(v1969.yaw_randomization, {v1971, v1972, v1973, v1974, {v1969.yaw, function()
				return ui.get(v1969.yaw) == "180 randomization"
			end}, {v1969.way_mode, function()
				return ui.get(v1969.way_mode) == 1
			end}})
			v73(v1969.yaw_jitter, {v1971, v1972, v1973, v1974, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}})
			v73(v1969.yaw_jitter_slider, {v1971, v1972, v1973, v1974, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}, {v1969.yaw_jitter, function()
				return ui.get(v1969.yaw_jitter) ~= "off"
			end}})
			v73(v1969.body_yaw, {v1971, v1972, v1973, v1974, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}})
			v73(v1969.body_yaw_value_static, {v1971, v1972, v1973, v1974, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "off"
			end}, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "adaptive"
			end}, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "jitter"
			end}, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}})
			v73(v1969.body_yaw_value_left, {v1971, v1972, v1973, v1974, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "off"
			end}, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "adaptive"
			end}, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "static"
			end}, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}})
			v73(v1969.body_yaw_value_right, {v1971, v1972, v1973, v1974, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "off"
			end}, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "adaptive"
			end}, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "static"
			end}, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}})
			v73(v1969.disable_desync_exploit, {v1971, v1972, v1973, v1974, {v1969.body_yaw, "jitter"}, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}, {"beta", function()
				return v55.build == "beta"
			end}})
			v73(v1969.delay_type, {v1971, v1972, v1973, v1974, {v1969.random_delay, false}, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "off"
			end}})
			v73(v1969.delay_slider, {v1971, v1972, v1973, v1974, {v1969.random_delay, false}, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "off"
			end}})
			v73(v1969.random_delay, {v1971, v1972, v1973, v1974, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "off"
			end}, {"beta", function()
				return v55.build == "beta"
			end}, {v1969.delay_type, "normal"}})
			v73(v1969.delay_slider_min, {v1971, v1972, v1973, v1974, {v1969.random_delay, true}, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "off"
			end}, {"beta", function()
				return v55.build == "beta"
			end}, {v1969.delay_type, "normal"}})
			v73(v1969.delay_slider_max, {v1971, v1972, v1973, v1974, {v1969.random_delay, true}, {v1969.yaw, function()
				return ui.get(v1969.yaw) ~= "off"
			end}, {v1969.body_yaw, function()
				return ui.get(v1969.body_yaw) ~= "off"
			end}, {"beta", function()
				return v55.build == "beta"
			end}, {v1969.delay_type, "normal"}})
			v73(v1970.enabled_def, {v1971, v1972, v1973, {v68.aa.select_shit, "defensive"}})
			v73(v1970.override_antiaim_def, {v1971, v1972, v1973, {v1970.enabled_def, true}, {v68.aa.select_shit, "defensive"}})
			v73(v1970.pitch_def, {v1971, v1972, v1973, {v1970.enabled_def, true}, {v1970.override_antiaim_def, true}, {v68.aa.select_shit, "defensive"}})
			v73(v1970.pitch_slider_def, {v1971, v1972, v1973, {v1970.pitch_def, "custom"}, {v1970.enabled_def, true}, {v1970.override_antiaim_def, true}, {v68.aa.select_shit, "defensive"}})
			v73(v1970.yaw_def, {v1971, v1972, v1973, {v1970.enabled_def, true}, {v1970.override_antiaim_def, true}, {v68.aa.select_shit, "defensive"}})
			v73(v1970.yaw_slider_def, {v1971, v1972, v1973, {v1970.yaw_def, function()
				return ui.get(v1970.yaw_def) ~= "off"
			end}, {v1970.yaw_def, function()
				return ui.get(v1970.yaw_def) ~= "random"
			end}, {v1970.yaw_def, function()
				return ui.get(v1970.yaw_def) ~= "l&r"
			end}, {v1970.yaw_def, function()
				return ui.get(v1970.yaw_def) ~= "forward"
			end}, {v1970.enabled_def, true}, {v1970.override_antiaim_def, true}, {v68.aa.select_shit, "defensive"}})
		end
	end}
	v597.helps = {speed = function()
		if not v597.vars.get().local_player then
			return
		end
		local v1975, v1976 = entity.get_prop(v597.vars.get().local_player, "m_vecVelocity")
		return math.floor(math.sqrt(v1975 * v1975 + v1976 * v1976))
	end, get_state = function(v1977)
		local v1978 = v597.vars.get().local_player
		if not entity.is_alive(v1978) then
			return
		end
		local v1979 = entity.get_prop(v1978, "m_fFlags")
		if bit.band(v1979, bit.lshift(1, 0)) ~= 0 == true then
			v78.antiaim.ground_tick = v78.antiaim.ground_tick + 1
		else
			v78.antiaim.ground_tick = 0
		end
		if bit.band(v1979, 1) == 1 then
			if v78.antiaim.ground_tick < 10 then
				if bit.band(v1979, 4) == 4 then
					return "in air duck"
				end
				return "in air"
			end
			if bit.band(v1979, 4) == 4 and v1977 > 9 then
				return "in duck moving"
			end
			if bit.band(v1979, 4) == 4 or ui.get(v65.ref.fakeduck) then
				return "in duck"
			end
			if ui.get(v68.aa.freestanding) then
				return "freestanding"
			end
			if v1977 <= 3 then
				return "standing"
			end
			if ui.get(v65.ref.slide[2]) then
				return "slow motion"
			end
			return "moving"
		end
		if bit.band(v1979, 1) == 0 then
			if bit.band(v1979, 4) == 4 then
				return "in air duck"
			end
			return "in air"
		end
	end, normalize_yaw = function(v1980)
		local v1981 = (v1980 % 360 + 360) % 360
		return v1981 > 180 and v1981 - 360 or v1981
	end}
	v597.defensive_checks = {choking = function(v1982)
		if v1982.allow_send_packet == false or v1982.chokedcommands > 1 then
			return true
		end
		return false
	end}
	v597.antiaim = {get_desync = function(_, v1984)
		if ui.get(v1984.delay_type) == "normal" then
			if globals.chokedcommands() == 0 and v78.antiaim.delay_aa == v78.antiaim.random_del then
				v78.antiaim.best_side = v78.antiaim.best_side == 1 and 0 or 1
			end
		elseif globals.chokedcommands() == 0 then
			v78.antiaim.best_side = v78.antiaim.to_jitter and 0 or 1
		end
	end, randomize_value = function(v1985, v1986, v1987)
		if type(v1985) ~= "number" or type(v1986) ~= "number" then
			return v1985
		end
		if v1986 <= 0 then
			return v1987 == false and v1985 or math.floor(v1985)
		end
		local v1988 = v1985 * (v1986 / 100)
		local v1989 = v1985 - v1988
		local v1990 = v1985 + v1988
		local v1991 = math.random(v1989, v1990)
		if v1987 ~= false then
			v1991 = math.floor(v1991 + 0.5)
		end
		return v1991
	end, get_manual = function()
		local v1992 = ui.get(v68.aa.left_manual)
		local v1993 = ui.get(v68.aa.right_manual)
		local v1994 = ui.get(v68.aa.forward_manual)
		if v78.antiaim.last_right == nil or (v78.antiaim.last_left == nil or v78.antiaim.last_forward == nil) then
			local v1995 = v78.antiaim
			local v1996 = v78.antiaim
			v78.antiaim.last_forward = v1994
			v1996.last_left = v1992
			v1995.last_right = v1993
		end
		if not v78.antiaim.last_left and v1992 then
			v78.antiaim.manual_side = 1
		elseif not v78.antiaim.last_right and v1993 then
			v78.antiaim.manual_side = 2
		elseif not v78.antiaim.last_forward and v1994 then
			v78.antiaim.manual_side = 3
		end
		if v78.antiaim.last_left and not v1992 then
			v78.antiaim.manual_side = nil
		elseif v78.antiaim.last_right and not v1993 then
			v78.antiaim.manual_side = nil
		elseif v78.antiaim.last_forward and not v1994 then
			v78.antiaim.manual_side = nil
		end
		if not v1992 and not v1993 and not v1994 then
			v78.antiaim.manual_side = nil
		end
		v78.antiaim.last_right = v1993
		v78.antiaim.last_left = v1992
		v78.antiaim.last_forward = v1994
		return ({-90, 90, -180})[v78.antiaim.manual_side]
	end, get_at_target = function()
		local v1997 = v597.vars.get().local_player
		if not entity.is_alive(v1997) then
			return
		end
		local v1998 = client.current_threat()
		local v1999 = v58.vector(entity.get_origin(v1997))
		return entity.is_alive(v1998) and v58.vector(v1999:to(v58.vector(entity.get_origin(v1998))):angles()).y or v58.vector(client.camera_angles()).y
	end, run = function(v2000)
		local v2001 = v597.helps.get_state(v597.helps.speed())
		local v2002 = v597.vars.get().local_player
		if ui.get(aa_builder[v597.helps.get_state(v597.helps.speed())].enabled) == false then
			v2001 = "global"
		end
		local v2003 = aa_builder[v2001]
		local v2004 = aa_builder_defensive[v2001]
		v597.antiaim.get_desync(v2000, v2003)
		if ui.get(v2003.enabled) then
			ui.set(v65.ref.aa_enable, true)
			ui.set(v65.ref.pitch, "down")
			ui.set(v65.ref.yaw_base, ui.get(v68.aa.yawbase))
			ui.set(v65.ref.yaw, "180")
			if ui.get(v2003.yaw) == "off" then
				return
			end
			local v2005 = 0
			if ui.get(v2003.yaw_jitter) == "center" then
				v2005 = v2005 + (v78.antiaim.best_side == 0 and ui.get(v2003.yaw_jitter_slider) / 2 or -ui.get(v2003.yaw_jitter_slider) / 2)
			elseif ui.get(v2003.yaw_jitter) == "random" then
				v2005 = v2005 + (math.random(0, ui.get(v2003.yaw_jitter_slider)) - ui.get(v2003.yaw_jitter_slider) / 2)
			end
			local v2006
			if ui.get(v2003.way_mode) == 1 then
				if ui.get(v2003.yaw) == "180 randomization" then
					v2006 = v2005 + (v78.antiaim.best_side == 0 and v597.antiaim.randomize_value(ui.get(v2003.yaw_add_right), ui.get(v2003.yaw_randomization)) or v597.antiaim.randomize_value(ui.get(v2003.yaw_add_left), ui.get(v2003.yaw_randomization_left)))
				else
					v2006 = v2005 + (v78.antiaim.best_side == 0 and ui.get(v2003.yaw_add_right) or ui.get(v2003.yaw_add_left))
				end
			else
				v2006 = v2005 + ui.get(v2003.yaw_add)
			end
			local v2007 = v597.antiaim.get_manual()
			if ui.get(v68.aa.freestanding) and v66.contains(ui.get(v68.aa.binds), "freestanding") and not v66.contains(ui.get(v68.aa.freestanding_disablers), v2001) and not v2007 then
				ui.set(v65.references.freestanding[1], true)
				ui.set(v65.references.freestanding[2], "Always On")
			else
				ui.set(v65.references.freestanding[1], false)
				ui.set(v65.references.freestanding[2], "Hold")
			end
			if ui.get(v68.aa.edge_yaw) and v66.contains(ui.get(v68.aa.binds), "edge-yaw") then
				ui.set(v65.references.edge_yaw, true)
			else
				ui.set(v65.references.edge_yaw, false)
			end
			if v2007 and v66.contains(ui.get(v68.aa.binds), "manuals") then
				v2006 = v2007
			end
			ui.set(v65.ref.yaw_value, v597.helps.normalize_yaw(v2006))
			ui.set(v65.ref.yaw_jitter, "Off")
			ui.set(v65.ref.yaw_jitter_value, 0)
			local v2008 = math.floor((ui.get(v2003.body_yaw_value_left) - 1) / 59 * 139)
			local v2009 = math.floor((ui.get(v2003.body_yaw_value_right) - 1) / 59 * 139)
			if ui.get(v2003.body_yaw) == "static" then
				local v2010 = math.floor((ui.get(v2003.body_yaw_value_static) - 1) / 59 * 139)
				ui.set(v65.ref.body_yaw, "Static")
				ui.set(v65.ref.body_yaw_value, v2010)
			elseif ui.get(v2003.body_yaw) == "jitter" then
				ui.set(v65.ref.body_yaw, "Static")
				ui.set(v65.ref.body_yaw_value, v78.antiaim.best_side == 0 and v2009 or -v2008)
				if ui.get(v2003.disable_desync_exploit) then
					v78.antiaim.desync_save = v78.antiaim.desync_save - 1
					ui.set(v65.ref.body_yaw_value, v78.antiaim.best_side == 0 and v78.antiaim.desync_save or -v78.antiaim.desync_save)
					if math.abs(v78.antiaim.desync_save) < 2 then
						v78.antiaim.desync_save = math.random(v2008, v2009)
						ui.set(v65.ref.body_yaw, "off")
					end
				end
			elseif ui.get(v2003.body_yaw) == "adaptive" then
				ui.set(v65.ref.body_yaw, "Static")
				ui.set(v65.ref.body_yaw_value, v597.helps.normalize_yaw(v2006))
			elseif ui.get(v2003.body_yaw) == "off" then
				ui.set(v65.ref.body_yaw, "off")
			end
		end
		local v2011 = v67.defensive and not v597.defensive_checks.choking(v2000) and entity.get_prop(v597.vars.get().game_rules, "m_bFreezePeriod", v2002) == 0 and not ui.get(v68.misc.unmatched)
		if ui.get(v2004.enabled_def) and ui.get(v2004.override_antiaim_def) and v2011 and ui.get(v2003.enabled) then
			if ui.get(v2004.yaw_def) ~= "off" then
				if ui.get(v2004.yaw_def) == "jitter" then
					ui.set(v65.ref.yaw_value, v78.antiaim.best_side == 0 and ui.get(v2004.yaw_slider_def) / 2 or -ui.get(v2004.yaw_slider_def) / 2)
				elseif ui.get(v2004.yaw_def) == "forward" then
					ui.set(v65.ref.yaw_value, 180)
				elseif ui.get(v2004.yaw_def) == "180" then
					ui.set(v65.ref.yaw_value, ui.get(v2004.yaw_slider_def))
				elseif ui.get(v2004.yaw_def) == "spin" then
					v78.antiaim.spin_antiaim_defensive = v78.antiaim.spin_antiaim_defensive + ui.get(v2004.yaw_slider_def) / 4
					ui.set(v65.ref.yaw_value, v597.helps.normalize_yaw(v78.antiaim.spin_antiaim_defensive))
					if v78.antiaim.spin_antiaim_defensive > 180 then
						v78.antiaim.spin_antiaim_defensive = 0
					end
				elseif ui.get(v2004.yaw_def) == "random" then
					ui.set(v65.ref.yaw_value, math.random(-179, 179))
				end
			end
			if ui.get(v2004.pitch_def) ~= "off" then
				if ui.get(v2004.pitch_def) == "custom" then
					ui.set(v65.ref.pitch, "custom")
					ui.set(v65.ref.pitch_value, ui.get(v2004.pitch_slider_def))
				elseif ui.get(v2004.pitch_def) == "zero" then
					ui.set(v65.ref.pitch, "custom")
					ui.set(v65.ref.pitch_value, 0)
				elseif ui.get(v2004.pitch_def) == "up" then
					ui.set(v65.ref.pitch, "custom")
					ui.set(v65.ref.pitch_value, -89)
				elseif ui.get(v2004.pitch_def) == "down" then
					ui.set(v65.ref.pitch, "custom")
					ui.set(v65.ref.pitch_value, 89)
				elseif ui.get(v2004.pitch_def) == "random" then
					ui.set(v65.ref.pitch, "custom")
					ui.set(v65.ref.pitch_value, ({89, 40, 0, -40, -89})[client.random_int(1, 5)])
				end
			end
		end
		if globals.chokedcommands() == 0 then
			if ui.get(v2003.random_delay) then
				local v2012 = client.random_int(ui.get(v2003.delay_slider_min), ui.get(v2003.delay_slider_max))
				if globals.tickcount() > v78.antiaim.delay_timernew + v2012 * 2 then
					v78.antiaim.random_del = v2012
					v78.antiaim.delay_timernew = globals.tickcount()
				end
			else
				v78.antiaim.random_del = ui.get(v2003.delay_slider)
			end
			if v78.antiaim.delay_aa >= v78.antiaim.random_del then
				v78.antiaim.delay_aa = 1
			else
				v78.antiaim.delay_aa = v78.antiaim.delay_aa + 1
			end
			if globals.tickcount() > v78.antiaim.current_tickcount + ui.get(v2003.delay_slider) then
				v78.antiaim.to_jitter = not v78.antiaim.to_jitter
				v78.antiaim.current_tickcount = globals.tickcount()
			elseif globals.tickcount() < v78.antiaim.current_tickcount then
				v78.antiaim.current_tickcount = globals.tickcount()
			end
		end
		if ui.get(v2004.enabled_def) then
			v2000.force_defensive = not v2000.no_choke
		end
		if v66.contains(ui.get(v68.aa.tweaks), "safe-head") and entity.get_classname(entity.get_player_weapon(v2002)) == "CKnife" and v597.helps.get_state(v597.helps.speed()) == "in air duck" then
			ui.set(v65.ref.pitch, "down")
			ui.set(v65.ref.yaw, "180")
			ui.set(v65.ref.yaw_value, -1)
			ui.set(v65.ref.yaw_base, "At targets")
			ui.set(v65.ref.yaw_jitter, "Off")
			ui.set(v65.ref.body_yaw, "Static")
			ui.set(v65.ref.body_yaw_value, 0)
			if v66.contains(ui.get(v68.aa.tweaks), "e-spam (safe-head)") then
				local v2013 = v597.antiaim.get_at_target()
				if ui.get(v2004.enabled_def) and v2011 then
					v2000.yaw = v2013 + v597.antiaim.randomize_value(math.random(-60, 60), 90)
					v2000.pitch = 0
				end
			end
		end
		if v66.contains(ui.get(v68.aa.tweaks), "anti-backstab") then
			local v2014 = entity.get_players(true)
			for _, v2016 in pairs(v2014) do
				local v2017 = entity.get_classname(entity.get_player_weapon(v2016))
				local v2018 = math.floor(v58.vector(entity.get_origin(v2016)):dist(v58.vector(entity.get_origin(v2002))) / 7)
				if v2017 == "CKnife" and v2018 < 30 then
					ui.set(v65.ref.yaw, "180")
					ui.set(v65.ref.yaw_value, -180)
					ui.set(v65.ref.yaw_base, "At targets")
					ui.set(v65.ref.yaw_jitter, "Off")
				end
			end
		end
		if v66.contains(ui.get(v68.aa.tweaks), "warmup-aa") and entity.get_prop(v597.vars.get().game_rules, "m_bWarmupPeriod") == 1 then
			v2000.yaw = math.random(-180, 180)
			v2000.pitch = math.random(-89, 89)
		end
		if ui.get(v68.aa.fakelag_mode) == "default" then
			ui.set(v65.ref.fakelag_limit, ui.get(v68.aa.fakelag_limit))
		elseif ui.get(v68.aa.fakelag_mode) == "sway" then
			local v2019 = ui.get(v68.aa.fakelag_limit_sway_min)
			local v2020 = ui.get(v68.aa.fakelag_limit_sway_max)
			if v2020 < v2019 then
				local v2021 = v2019
				v2019 = v2020
				v2020 = v2021
			end
			local v2022 = globals.realtime()
			local v2023 = v2019 + (math.sin(v2022 * 0.5 * 2 * math.pi) + 1) / 2 * (v2020 - v2019)
			ui.set(v65.ref.fakelag_limit, math.floor(v2023 + 0.5))
		elseif ui.get(v68.aa.fakelag_mode) == "random" then
			ui.set(v65.ref.fakelag_limit, math.random(1, v72))
		end
	end}
	v597.breaklc = {get_weapon = function()
		local v2024 = v597.vars.get().local_player
		if not entity.is_alive(v2024) then
			return
		end
		local v2025 = entity.get_player_weapon(v2024)
		if entity.get_classname(v2025) == "CWeaponSSG08" then
			return true
		end
	end, is_in_air = function()
		local v2026 = v597.vars.get().local_player
		if not entity.is_alive(v2026) then
			return
		end
		local v2027 = entity.get_prop(v2026, "m_fFlags")
		if bit.band(v2027, 1) == 0 then
			if bit.band(v2027, 4) == 4 then
				return true
			end
			return true
		end
	end, unsafe_recharge = function()
		local v2028 = v597.vars.get().local_player
		if not entity.is_alive(v2028) then
			return
		end
		if ui.get(v65.references.double_tap[2]) or ui.get(v65.references.on_shot_anti_aim[2]) then
			if globals.tickcount() >= v78.misc.timer + 14 then
				ui.set(v65.references.aimbot, true)
			else
				ui.set(v65.references.aimbot, false)
			end
		else
			v78.misc.timer = globals.tickcount()
			ui.set(v65.references.aimbot, true)
		end
	end}
	local v599 = {}

	v599.easeInOut = LPH_NO_VIRTUALIZE(function(L_213)
            return L_213 > 0.5 and 4 * (L_213 - 1) ^ 3 + 1 or 4 * L_213 ^ 3;
        end)

	v599.clamp = LPH_NO_VIRTUALIZE(function(L_590, L_591, L_592)
            if L_591 > L_592 then
                L_591, L_592 = L_592, L_591;
            end;
            return math.max(L_591, math.min(L_592, L_590));
        end)

	v599.render_rect_outline = LPH_NO_VIRTUALIZE(function(L_732, L_733, L_734, L_735, L_736, L_737, L_738, L_739)
            renderer.line(L_732, L_733, L_732 + L_734, L_733, L_736, L_737, L_738, L_739);
            renderer.line(L_732, L_733, L_732, L_733 + L_735, L_736, L_737, L_738, L_739);
            renderer.line(L_732, L_733 + L_735, L_732 + L_734, L_733 + L_735, L_736, L_737, L_738, L_739);
            renderer.line(L_732 + L_734, L_733, L_732 + L_734, L_733 + L_735, L_736, L_737, L_738, L_739);
        end)
	v599.render = function()
		if ui.is_menu_open() then
			if not ui.get(v68.visuals.hitlogs) then
				return
			end
			local v2029, v2030, v2031, v2032 = ui.get(v68.visuals.hit_color)
			local v2033, v2034, v2035, v2036 = ui.get(v68.visuals.miss_color)
			local v2037 = {{text = string.format("\aFFFFFFFFHit \a%s%s\aFFFFFFFF in the \a%s%s\aFFFFFFFF for \a%s%d\aFFFFFFFF damage (\a%s%d\aFFFFFFFF health remaining)", v66.rgba_to_hex(v2029, v2030, v2031, v2032), "admin!", v66.rgba_to_hex(v2029, v2030, v2031, v2032), "head", v66.rgba_to_hex(v2029, v2030, v2031, v2032), "108", v66.rgba_to_hex(v2029, v2030, v2031, v2032), "0"), color = {v2029, v2030, v2031}, fraction = 1}, {text = string.format("\aFFFFFFFFMissed \a%s%s\aFFFFFFFF in the \a%s%s\aFFFFFFFF due to \a%s%s\aFFFFFFFF", v66.rgba_to_hex(v2033, v2034, v2035, v2036), "admin!", v66.rgba_to_hex(v2033, v2034, v2035, v2036), "head", v66.rgba_to_hex(v2033, v2034, v2035, v2036), "spread"), color = {v2033, v2034, v2035}, fraction = 1}}
			if not ui.get(v68.misc.fpsboost) and (v66.contains(ui.get(v68.visuals.hitlogs_opt), "hit") or v66.contains(ui.get(v68.visuals.hitlogs_opt), "miss")) then
				for v2038, v2039 in ipairs(v2037) do
					local v2040 = v58.vector(renderer.measure_text("c", v2039.text))
					if ui.get(v68.visuals.logs_style) == "modern" then
						v597.m_render:pandora_og(X / 2 - v2040.x / 2 - 15, Y - 270 + 31 * v2038 * v2039.fraction, v2040.x + 35, v2040.y + 14, 255, 255, 255, 255, string.format("\a%s\226\139\134\239\189\161\194\176\226\156\169 ", v66.rgba_to_hex(v2039.color[1], v2039.color[2], v2039.color[3], 255)) .. v2039.text)
					elseif ui.get(v68.visuals.logs_style) == "default" then
						v597.m_render:fajne_gowienko(X / 2 - v2040.x / 2 - 5, Y - 270 + 31 * v2038 * v2039.fraction, v2040.x + 10, v2040.y + 10, 9, 5, {10, 10, 10, 130})
						renderer.text(X / 2 - v2040.x / 2, Y - 266 + 31 * v2038 * v2039.fraction, 255, 255, 255, 255, "", nil, v2039.text)
					end
				end
			end
		end
		for v2041, v2042 in ipairs(v55.notify_data) do
			if v2042.text ~= nil and v2042.text ~= "" then
				if v2042.timer + 4.1 < globals.realtime() then
					v2042.fraction = v597.notify.clamp(v2042.fraction - globals.frametime() / 0.3, 0, 1)
				else
					v2042.fraction = v597.notify.clamp(v2042.fraction + globals.frametime() / 0.3, 0, 1)
				end
			end
			local v2043 = v597.notify.easeInOut(v2042.fraction)
			local v2044 = v58.vector(renderer.measure_text("c", v2042.text))
			local v2045 = v2042.color
			if not ui.get(v68.visuals.hitlogs) then
				return
			end
			if ui.get(v68.visuals.logs_style) == "modern" then
				v597.m_render:pandora_og(X / 2 - v2044.x / 2 - 15, Y - 270 + 31 * v2041 * v2043, v2044.x + 35, v2044.y + 14, 255, 255, 255, 255 * v2043, string.format("\a%s\226\139\134\239\189\161\194\176\226\156\169 ", v66.rgba_to_hex(v2045[1], v2045[2], v2045[3], v597.watermark.anim(255, 75))) .. v2042.text)
			elseif ui.get(v68.visuals.logs_style) == "default" then
				v597.m_render:fajne_gowienko(X / 2 - v2044.x / 2 - 5, Y - 270 + 31 * v2041 * v2043, v2044.x + 10, v2044.y + 10, 9, 5, {10, 10, 10, 130 * v2043})
				renderer.text(X / 2 - v2044.x / 2, Y - 266 + 31 * v2041 * v2043, 255, 255, 255, 255, "", nil, v2042.text)
			end
			if v2042.timer + 4.3 < globals.realtime() then
				table.remove(v55.notify_data, v2041)
			end
			if #v55.notify_data > 7 then
				table.remove(v55.notify_data, v2041)
			end
		end
	end
	v597.notify = v599
	local v600 = {}

	v600.round = LPH_NO_VIRTUALIZE(function(L_835, L_836)
            local L_837 = 10 ^ (L_836 or 0);
            return math.floor(L_835 * L_837 + 0.5) / L_837;
        end)
	v600.get_fps = function()
		v78.other.ft_prev = v78.other.ft_prev * 0.9 + globals.absoluteframetime() * 0.1
		return v597.watermark.round(1 / v78.other.ft_prev)
	end

	v600.anim = LPH_NO_VIRTUALIZE(function(L_390, L_391)
            return v597.notify.clamp(math.sin(math.abs(math.pi + globals.realtime() % (-math.pi * 2))) * L_390, L_391, L_390);
        end)

	v600.get_ping = LPH_NO_VIRTUALIZE(function()
            local L_189 = client.latency();
            return v597.watermark.round(L_189 * 1000);
        end)
	v600.download_discord_avatar = function()
		v58["gamesense/http"].get("https://varglua.top/avatars/" .. v55.username .. ".png", function(_, v2308)
			if v2308.status ~= 200 then
				v78.other.avatar_texture = renderer.load_png(readfile("csgo/materials/panorama/images/icons/xp/level99999969.png"), 32, 32)
				print("fetch your discord avatar")
			end
			writefile("csgo/materials/panorama/images/icons/xp/" .. v55.username .. ".png", v2308.body)
			if not readfile("csgo/materials/panorama/images/icons/xp/" .. v55.username .. ".png") then
				v78.other.avatar_texture = renderer.load_png(readfile("csgo/materials/panorama/images/icons/xp/level99999969.png"), 32, 32)
			else
				v78.other.avatar_texture = renderer.load_png(readfile("csgo/materials/panorama/images/icons/xp/" .. v55.username .. ".png"), 32, 32)
			end
		end)
	end
	v600.guwno_sraka_pierdaka = function(v2046, v2047)
		if v2047 < #v2046 then
			return v2046:sub(1, v2047) .. "..."
		end
		return v2046
	end

	v600.guwno_sraka_pierdaka_2 = LPH_NO_VIRTUALIZE(function(L_399, L_400)
            if #L_399 > L_400 then
                return true;
            else
                return false;
            end;
        end)
	v600.render = function()
		if not ui.get(v68.visuals.watermark) then
			return
		end
		local v2048, v2049, v2050, v2051 = ui.get(v68.visuals.watermark_color)
		local v2052 = ui.get(v68.visuals.watermark_pos) == "avatar-based"
		if ui.is_menu_open() and not v2052 and not ui.get(v68.misc.fpsboost) then
			renderer.text(v80.x - 10, v80.y - 25, 255, 255, 255, 255, "", nil, "M2 - CENTER")
			v597.notify.render_rect_outline(v80.x - 10, v80.y - 10, v80.w + 20, v80.h + 20, 255, 255, 255, 255)
		end
		if client.key_state(1) and ui.is_menu_open() and not v2052 then
			local v2053 = {ui.mouse_position()}
			if v66.intersect(v80.x, v80.y, v80.w, v80.h) then
				v80.x = v2053[1] - v80.w / 2
				v80.y = v2053[2] - v80.h / 2
			end
		end
		if client.key_state(2) and ui.is_menu_open() and not v2052 and v66.intersect(v80.x, v80.y, v80.w, v80.h) then
			v80.x = X / 2 - v80.w / 2
		end
		if ui.get(v68.visuals.watermark_pos) == "minimal" then
			local v2054 = string.format("\a%sV A %s \a%s[%s]", v66.rgba_to_hex(v2048, v2049, v2050, 255), ui.get(v68.misc.fpsboost) and "\affffffffR G" or v66.text_fade_animation(-2, 255, 255, 255, 255, "R G"), v66.rgba_to_hex(v2048, v2049, v2050, 255), string.upper(v55.build))
			v80.w = v58.vector(renderer.measure_text("d", v2054)).x + 5
			v80.h = 22
			renderer.text(v80.x + 3, v80.y + 3, 255, 255, 255, 255, "d", nil, v2054)
		elseif ui.get(v68.visuals.watermark_pos) == "modern" then
			local v2055 = string.format("\a%s\226\139\134\239\189\161\194\176\226\156\169\aFFFFFFFF %s \a%s~ %s", v66.rgba_to_hex(v2048, v2049, v2050, ui.get(v68.misc.fpsboost) and 255 or v597.watermark.anim(255, 75)), v55.name, v66.rgba_to_hex(v2048, v2049, v2050, 130), v55.build)
			if v66.contains(ui.get(v68.visuals.watermark_opt), "username") then
				v2055 = v2055 .. string.format(" \a%s~\a%s %s\aFFFFFFFF", v66.rgba_to_hex(v2048, v2049, v2050, 130), v66.rgba_to_hex(v2048, v2049, v2050, 255), v55.username)
			end
			if v66.contains(ui.get(v68.visuals.watermark_opt), "ping") then
				v2055 = v2055 .. string.format(" \a%s|\aFFFFFFFF %sms", v66.rgba_to_hex(v2048, v2049, v2050, 130), v597.watermark.get_ping())
			end
			if v66.contains(ui.get(v68.visuals.watermark_opt), "fps") then
				v2055 = v2055 .. string.format(" \a%s|\aFFFFFFFF %sfps", v66.rgba_to_hex(v2048, v2049, v2050, 130), v597.watermark.get_fps())
			end
			if v66.contains(ui.get(v68.visuals.watermark_opt), "time") then
				local v2056, v2057, v2058, _ = client.system_time()
				v2055 = v2055 .. string.format(" \a%s|\aFFFFFFFF %02d:%02d:%02d", v66.rgba_to_hex(v2048, v2049, v2050, 130), v2056, v2057, v2058)
			end
			local v2060 = v58.vector(renderer.measure_text("d", v2055))
			v80.w = v2060.x + 10
			v80.h = 25
			v597.m_render:pandora_og(v80.x, v80.y, v2060.x + 12, v2060.y + 13, 255, 255, 255, 255, v2055, "d")
		elseif ui.get(v68.visuals.watermark_pos) == "default" then
			local v2061, v2062, _, _ = client.system_time()
			local v2065 = string.format(" \a%s\238\132\189 \aFFFFFFFF%s  \a%s|  \a%s\238\132\168 \aFFFFFFFF%s ms ", v66.rgba_to_hex(v2048, v2049, v2050, 255), v55.username, v66.rgba_to_hex(255, 255, 255, ui.get(v68.misc.fpsboost) and 255 or v597.watermark.anim(255, 75)), v66.rgba_to_hex(v2048, v2049, v2050, 255), v597.watermark.get_ping())
			local v2066 = string.format(" \a%s\238\132\149 \aFFFFFFFF%s  \a%s\238\132\161 \aFFFFFFFF%02d:%02d ", v66.rgba_to_hex(v2048, v2049, v2050, 255), v55.build, v66.rgba_to_hex(v2048, v2049, v2050, 255), v2061, v2062)
			local v2067 = v58.vector(renderer.measure_text("d", v2065))
			local v2068 = v58.vector(renderer.measure_text("d", v2066))
			v80.w = v2067.x + 10
			v80.h = 40
			renderer.rectangle(v80.x + 5, v80.y + v2067.y + 8, v2067.x, 1, v2048, v2049, v2050, v2051)
			v597.m_render:fajne_gowienko(v80.x, v80.y, v2067.x + 10, v2067.y + v2068.y + 16, 9, 5, {10, 10, 10, 130})
			renderer.text(v80.x + 4, v80.y + 3, 255, 255, 255, 255, "d", nil, v2065)
			renderer.text(v80.x + (v80.w - v2068.x) / 2, v80.y + v2067.y + 11, 255, 255, 255, 255, "d", nil, v2066)
		elseif ui.get(v68.visuals.watermark_pos) == "avatar-based" then
			if ui.get(v68.visuals.watermark_pos_sexy) == "left - middle" then
				local v2069 = string.format("varglua.top ~ \a%s%s", v66.rgba_to_hex(v2048, v2049, v2050, ui.get(v68.misc.fpsboost) and 255 or v597.watermark.anim(255, 75)), v55.build)
				local v2070 = v58.vector(renderer.measure_text("b", v2069))
				renderer.gradient(0, Y / 2 - 10, 36, 36, v2048, v2049, v2050, v2051, v2048, v2049, v2050, 0, true)
				renderer.texture(v78.other.avatar_texture, 2, Y / 2 - 8, 32, 32, 255, 255, 255, 255, "f")
				renderer.text(40, Y / 2 - 7, 255, 255, 255, 255, "b", nil, v2069)
				renderer.gradient(40, Y / 2 + 9, v2070.x / 2, 1, v2048, v2049, v2050, 0, v2048, v2049, v2050, 255, true)
				renderer.gradient(40 + v2070.x / 2, Y / 2 + 9, v2070.x / 2, 1, v2048, v2049, v2050, 255, v2048, v2049, v2050, 0, true)
				renderer.text(40, Y / 2 + 10, 255, 255, 255, 255, "b", nil, string.format("user ~ \a%s%s", v66.rgba_to_hex(v2048, v2049, v2050, 255), v55.username))
			else
				local v2071 = string.format("varglua.top ~ \a%s%s", v66.rgba_to_hex(v2048, v2049, v2050, ui.get(v68.misc.fpsboost) and 255 or v597.watermark.anim(255, 75)), v55.build)
				local v2072 = v58.vector(renderer.measure_text("b", v2071))
				local v2073 = v58.vector(renderer.measure_text("b", v597.watermark.guwno_sraka_pierdaka_2(v55.username, 10) and string.format("\a%s%s", v66.rgba_to_hex(v2048, v2049, v2050, 255), v55.username) or string.format("user ~ \a%s%s", v66.rgba_to_hex(v2048, v2049, v2050, 255), v55.username)))
				renderer.gradient(X - 3 - 32 - v2072.x - 10, 0, v2072.x + 10 + 32 + 3, 38, v2048, v2049, v2050, 0, v2048, v2049, v2050, v2051, true)
				renderer.texture(v78.other.avatar_texture, X - 35, 3, 32, 32, 255, 255, 255, 255, "f")
				renderer.text(X - 3 - 32 - v2072.x - 5, 5, 255, 255, 255, 255, "b", nil, v2071)
				renderer.text(X - 3 - 32 - v2073.x - 5, 18, 255, 255, 255, 255, "b", nil, v597.watermark.guwno_sraka_pierdaka_2(v55.username, 10) and string.format("\a%s%s", v66.rgba_to_hex(v2048, v2049, v2050, 255), v55.username) or string.format("user ~ \a%s%s", v66.rgba_to_hex(v2048, v2049, v2050, 255), v55.username))
			end
		end
	end
	v597.watermark = v600
	v597.shared_logo = {download_img = function()
		if not readfile("csgo/materials/panorama/images/icons/xp/level99999969.png") then
			writefile("csgo/materials/panorama/images/icons/xp/level99999969.png", v58["gamesense/base64"].decode("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"))
		end
	end, containsKey = function(v2074, v2075)
		for v2076 = 1, #v2074, 1 do
			if v2075 == v2074[v2076] then
				return true
			end
		end
		return false
	end, send = function()
		return {open = function(v2309)
			v2309:send(json.stringify({msg_type = v58["gamesense/base64"].encode("add_steam"), msg_data = v58["gamesense/base64"].encode(entity.get_steam64(v597.vars.get().local_player))}))
		end, message = function(_, v2311)
			if type(v2311) ~= "string" then
				return
			end
			local v2312 = json.parse(v2311)
			local v2313 = v2312.msg_type == nil and "" or v58["gamesense/base64"].decode(v2312.msg_type)
			local v2314 = v2312.msg_data == nil and "" or v58["gamesense/base64"].decode(v2312.msg_data)
			if v2313 == "active_steams" then
				local v2315 = json.parse(v2314)
				ui.set(v68.info.online_text, string.format("\a9ded64ffconnected \abdbdbdff| online \abdbdbdff~ \a99CEFFFF %s", #v2315))
				v55.crash = "no"
				for v2316 = 1, globals.maxplayers(), 1 do
					if entity.get_classname(v2316) == "CCSPlayer" and v597.shared_logo.containsKey(v2315, tostring(entity.get_steam64(v2316))) then
						entity.set_prop(entity.get_player_resource(), "m_nPersonaDataPublicLevel", 99999969, v2316)
					end
				end
			end
		end, close = function(_, v2318, _, _)
			print("WebSocket closed. Code: " .. v2318 .. "")
			v56()
			ui.set(v68.info.online_text, "\aed6464ffconnection closed")
			v55.crash = "yes"
		end, error = function(_, _)
			v56()
			ui.set(v68.info.online_text, "\aed6464ffconnection error")
			v55.crash = "yes"
		end}
	end}
	v597.fast_ladder = {run = function(v2077)
		if ui.get(v68.misc.fast_ladder) then
			local v2078 = v597.vars.get().local_player
			local v2079, _ = client.camera_angles()
			if entity.get_prop(v2078, "m_MoveType") == 9 then
				v2077.yaw = math.floor(v2077.yaw + 0.5)
				v2077.roll = 0
				if v2077.forwardmove == 0 then
					v2077.pitch = 89
					v2077.yaw = v2077.yaw + 180
					if math.abs(180) > 0 and math.abs(180) < 180 and v2077.sidemove ~= 0 then
						v2077.yaw = v2077.yaw - ui.get(180)
					end
					if math.abs(180) == 180 then
						if v2077.sidemove < 0 then
							v2077.in_moveleft = 0
							v2077.in_moveright = 1
						end
						if v2077.sidemove > 0 then
							v2077.in_moveleft = 1
							v2077.in_moveright = 0
						end
					end
				end
				if v2077.forwardmove > 0 and v2079 < 45 then
					v2077.pitch = 89
					v2077.in_moveright = 1
					v2077.in_moveleft = 0
					v2077.in_forward = 0
					v2077.in_back = 1
					if v2077.sidemove == 0 then
						v2077.yaw = v2077.yaw + 90
					end
					if v2077.sidemove < 0 then
						v2077.yaw = v2077.yaw + 150
					end
					if v2077.sidemove > 0 then
						v2077.yaw = v2077.yaw + 30
					end
				end
				if v2077.forwardmove < 0 then
					v2077.pitch = 89
					v2077.in_moveleft = 1
					v2077.in_moveright = 0
					v2077.in_forward = 1
					v2077.in_back = 0
					if v2077.sidemove == 0 then
						v2077.yaw = v2077.yaw + 90
					end
					if v2077.sidemove > 0 then
						v2077.yaw = v2077.yaw + 150
					end
					if v2077.sidemove < 0 then
						v2077.yaw = v2077.yaw + 30
					end
				end
			end
		end
	end}
	v597.clantag = {run = function()
		local v2081 = math.floor(globals.tickcount() / 25) % #v78.other.clan_tag
		local v2082 = v78.other.clan_tag[v2081 + 1]
		if v2082 ~= v78.other.clan_tag_prev then
			client.set_clan_tag(v2082)
		end
		v78.other.clan_tag_prev = v2082
	end}
	v597.fps_boost = {run = function()
		local v2083 = {{name = "r_shadows", value = 0, default_value = 1}, {name = "cl_csm_static_prop_shadows", value = 0, default_value = 1}, {name = "r_3dsky", value = 0, default_value = 1}, {name = "fog_enable", value = 0, default_value = 1}, {name = "fog_enable_water_fog", value = 0, default_value = 1}, {name = "cl_csm_world_shadows", value = 0, default_value = 1}, {name = "cl_csm_translucent_shadows", value = 0, default_value = 1}, {name = "cl_csm_shadows", value = 0, default_value = 1}, {name = "mat_disable_bloom", value = 1, default_value = 0}, {name = "cl_csm_world_shadows_in_viewmodelcascade", value = 0, default_value = 1}, {name = "r_drawdecals", value = 0, default_value = 1}, {name = "r_eyegloss", value = 0, default_value = 1}, {name = "r_eyes", value = 0, default_value = 1}, {name = "r_drawtracers_firstperson", value = 0, default_value = 1}, {name = "violence_hblood", value = 0, default_value = 1}, {name = "cl_csm_entity_shadows", value = 0, default_value = 1}, {name = "cl_foot_contact_shadows", value = 0, default_value = 1}, {name = "cl_csm_viewmodel_shadows", value = 0, default_value = 1}, {name = "cl_csm_rope_shadows", value = 0, default_value = 1}, {name = "cl_csm_sprite_shadows", value = 0, default_value = 1}, {name = "r_drawropes", value = 0, default_value = 1}, {name = "r_drawsprites", value = 0, default_value = 1}, {name = "func_break_max_pieces", value = 0, default_value = 3}, {name = "r_dynamic", value = 0, default_value = 1}, {name = "r_dynamiclighting", value = 0, default_value = 1}, {name = "cl_disable_ragdolls", value = 1, default_value = 0}, {name = "r_drawparticles", value = 1, default_value = 0}, {name = "muzzleflash_light", value = 0, default_value = 1}, {name = "r_eyemove", value = 0, default_value = 1}, {name = "r_eyegloss", value = 0, default_value = 1}}
		for _, v2085 in ipairs(v2083) do
			if cvar[v2085.name] then
				cvar[v2085.name]:set_int(v2085.value)
			end
		end
		if not ui.get(v68.misc.fpsboost) then
			for _, v2087 in ipairs(v2083) do
				if cvar[v2087.name] then
					cvar[v2087.name]:set_int(v2087.default_value)
				end
			end
		end
	end}
	local v601 = {}

	v601.delay_say = LPH_NO_VIRTUALIZE(function(L_772, L_773)
            return client.delay_call(L_772, function()
                client.exec("s\x61y\x20" .. L_773);
            end);
        end)
	v601.run = function(v2088)
		local v2089 = v597.vars.get().local_player
		local v2090 = client.userid_to_entindex(v2088.userid)
		local v2091 = client.userid_to_entindex(v2088.attacker)
		if not v2089 then
			return
		end
		if ui.get(v68.misc.killsay) then
			local v2092 = v78.trashtalk_main[ui.get(v68.misc.killsay_type)]
			if v2090 ~= v2091 and v2091 == v2089 then
				v597.trashtalk.delay_say(math.random(1, 5), v2092[math.random(#v2092)])
			end
		end
	end
	v597.trashtalk = v601
	v597.jitter_fix = {run = function()
		local v2093 = v597.vars.get().local_player
		local v2094 = entity.get_players(true)
		for _, v2096 in ipairs(v2094) do
			if ui.get(v68.misc.jitter_fix) and entity.is_alive(v2093) and not entity.is_dormant(v2096) then
				local v2097 = math.floor(entity.get_prop(v2096, "m_flPoseParameter", 11) * 120 - 59)
				if ui.get(v68.misc.jitter_fix_type) == "default" then
					plist.set(v2096, "Force body yaw", true)
					plist.set(v2096, "Force body yaw value", v2097)
				else
					local v2098 = v2097 > 1
					plist.set(v2096, "Force body yaw", true)
					plist.set(v2096, "Force body yaw value", v2098 and 59 or -59)
				end
			else
				plist.set(v2096, "Force body yaw", false)
				plist.set(v2096, "Force body yaw value", 0)
			end
		end
	end}
	v597.anims = {run = function()
		local v2099 = v597.vars.get().local_player
		if not v2099 then
			return
		end
		if not entity.is_alive(v2099) then
			return
		end
		if v66.contains(ui.get(v68.misc.animation_braker), "reversed legs") then
			local v2100 = math.random(1, 2)
			ui.set(ui.reference("AA", "Other", "Leg movement"), v2100 == 1 and "Always slide" or "Never slide")
			entity.set_prop(v597.vars.get().local_player, "m_flPoseParameter", 8, 0)
		end
		if v66.contains(ui.get(v68.misc.animation_braker), "static legs") then
			entity.set_prop(v597.vars.get().local_player, "m_flPoseParameter", 1, 6)
		end
		if v66.contains(ui.get(v68.misc.animation_braker), "leg braker") then
			entity.set_prop(v597.vars.get().local_player, "m_flPoseParameter", client.random_float(0.75, 1), 0)
			ui.set(ui.reference("AA", "Other", "Leg movement"), client.random_int(1, 2) == 1 and "Off" or "Always slide")
		end
		if v66.contains(ui.get(v68.misc.animation_braker), "perfect") then
			entity.set_prop(v597.vars.get().local_player, "m_flPoseParameter", math.random(0, 10) / 10, 3)
			entity.set_prop(v597.vars.get().local_player, "m_flPoseParameter", math.random(0, 10) / 10, 7)
			entity.set_prop(v597.vars.get().local_player, "m_flPoseParameter", math.random(0, 10) / 10, 6)
		end
	end}
	v597.manuals = {render = function()
		local v2101 = v597.antiaim.get_manual()
		if not v66.contains(ui.get(v68.aa.binds), "manuals") then
			return
		end
		if not v66.contains(ui.get(v68.visuals.other_visuals), "manuals") then
			return
		end
		if not v2101 then
			return
		end
		local v2102, v2103, v2104, v2105 = ui.get(v68.visuals.other_manuals_color)
		if v2101 == -90 then
			renderer.text(X / 2 - 50, Y / 2, v2102, v2103, v2104, v2105, "cb+", 0, "\238\136\185")
		elseif v2101 == 90 then
			renderer.text(X / 2 + 50, Y / 2, v2102, v2103, v2104, v2105, "cb+", 0, "\238\136\186")
		else
			renderer.text(X / 2, Y / 2 - 50, v2102, v2103, v2104, v2105, "cb+", 0, "\238\128\144")
		end
	end}
	v597.visuals_other = {render = function()
		if not v66.contains(ui.get(v68.visuals.other_visuals), "speed warning") then
			return
		end
		if client.key_state(1) and ui.is_menu_open() then
			local v2106 = {ui.mouse_position()}
			if v66.intersect(X / 2 - 55, v81.y, 120, 50) then
				v81.y = v2106[2] - 20
			end
		end
		local v2107 = v597.vars.get().local_player
		local v2108, v2109, v2110, v2111 = ui.get(v68.visuals.other_visuals_color)
		local v2112 = 100
		if entity.is_alive(v2107) then
			v2112 = entity.get_prop(v2107, "m_flVelocityModifier") * 100
		end
		local v2113 = renderer.load_svg("<?xml version=\"1.0\" encoding=\"utf-8\"?><svg width=\"800px\" height=\"800px\" viewBox=\"0 0 24 24\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M12 17.0001H12.01M12 10.0001V14.0001M6.41209 21.0001H17.588C19.3696 21.0001 20.2604 21.0001 20.783 20.6254C21.2389 20.2985 21.5365 19.7951 21.6033 19.238C21.6798 18.5996 21.2505 17.819 20.3918 16.2579L14.8039 6.09805C13.8897 4.4359 13.4326 3.60482 12.8286 3.32987C12.3022 3.09024 11.6978 3.09024 11.1714 3.32987C10.5674 3.60482 10.1103 4.4359 9.19614 6.09805L3.6082 16.2579C2.74959 17.819 2.32028 18.5996 2.39677 19.238C2.46351 19.7951 2.76116 20.2985 3.21709 20.6254C3.7396 21.0001 4.63043 21.0001 6.41209 21.0001Z\" stroke=\"#" .. v66.rgb_to_hex(v2108, v2109, v2110) .. "\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/></svg>", 20, 20)
		if v2112 < 100 then
			local v2114 = v2112 * 98 / 143
			v597.m_render:fajne_gowienko(X / 2 - 55, v81.y, 110, 30, 9, 5, {10, 10, 10, 130})
			renderer.rectangle(X / 2 - 55 + 29, v81.y + 6, 1, 18, 50, 50, 50, 255)
			renderer.rectangle(X / 2 - 55 + 35, v81.y + 20, 68, 2, 0, 0, 0, 255)
			renderer.rectangle(X / 2 - 55 + 35, v81.y + 20, v2114, 2, v2108, v2109, v2110, v2111)
			renderer.text(X / 2 - 55 + 49, v81.y + 4, 255, 255, 255, 255, "", nil, "velocity")
			renderer.texture(v2113, X / 2 - 55 + 5, v81.y + 5, 20, 20, v2108, v2109, v2110, v2111)
		elseif ui.is_menu_open() and not ui.get(v68.misc.fpsboost) then
			v597.m_render:fajne_gowienko(X / 2 - 55, v81.y, 110, 30, 9, 5, {10, 10, 10, 130})
			renderer.rectangle(X / 2 - 55 + 29, v81.y + 6, 1, 18, 50, 50, 50, 255)
			renderer.rectangle(X / 2 - 55 + 35, v81.y + 20, 68, 2, 0, 0, 0, 255)
			renderer.rectangle(X / 2 - 55 + 35, v81.y + 20, 40, 2, v2108, v2109, v2110, v2111)
			renderer.text(X / 2 - 55 + 49, v81.y + 4, 255, 255, 255, 255, "", nil, "velocity")
			renderer.texture(v2113, X / 2 - 55 + 5, v81.y + 5, 20, 20, v2108, v2109, v2110, v2111)
			v597.notify.render_rect_outline(X / 2 - 55 - 10, v81.y - 10, 130, 50, 255, 255, 255, 255)
		end
	end, damage_ind_render = function()
		if not v66.contains(ui.get(v68.visuals.other_visuals), "minimum damage override") then
			return
		end
		local v2115, v2116, v2117, v2118 = ui.get(v68.visuals.other_damage_override_color)
		if client.key_state(1) and ui.is_menu_open() then
			local v2119, v2120 = ui.mouse_position()
			if v66.intersect(v81.dmg_x, v81.dmg_y, 15, 15) then
				local v2121 = v2119 - 7.5
				v81.dmg_y = v2120 - 7.5
				v81.dmg_x = v2121
			end
		end
		if ui.get(v65.references.minimum_damage_override[2]) and not ui.is_menu_open() then
			renderer.text(v81.dmg_x, v81.dmg_y, v2115, v2116, v2117, v2118, "d", 0, ui.get(v65.references.minimum_damage_override[3]) .. "")
		end
		if ui.is_menu_open() and not ui.get(v68.misc.fpsboost) then
			renderer.text(v81.dmg_x, v81.dmg_y, v2115, v2116, v2117, v2118, "d", 0, "1")
			v597.notify.render_rect_outline(v81.dmg_x - 4, v81.dmg_y - 1, 15, 15, 255, 255, 255, 255)
		end
	end, thirdperson_distance = function()
		cvar.c_mindistance:set_int(ui.get(v68.visuals.thirdperson_dist))
		cvar.c_maxdistance:set_int(ui.get(v68.visuals.thirdperson_dist))
	end, aspect_ratio_heh = function()
		cvar.r_aspectratio:set_float(ui.get(v68.visuals.aspect_ratio) / 100)
	end}
	v597.config_system = {save_config = function(v2122)
		local v2123 = database.read(v55.cfg_database) or {}
		if v2122:match("[^%w]") ~= nil then
			return false
		end
		local v2124 = export_cfg({aa_builder, aa_builder_defensive})
		v2123[v2122] = v58["gamesense/base64"].encode(json.stringify(v2124))
		database.write(v55.cfg_database, v2123)
		print("Config saved: " .. v2122)
		return true
	end, load_config = function(v2125)
		local v2126 = database.read(v55.cfg_database) or {}
		if not v2126[v2125] then
			print("Config not found: " .. v2125)
			return false
		end
		local v2127 = v2126[v2125]
		local v2128 = json.parse(v58["gamesense/base64"].decode(v2127))
		import_cfg({aa_builder, aa_builder_defensive}, v2128)
		print("Loaded config: " .. v2125)
		return true
	end, delete_config = function(v2129)
		local v2130 = database.read(v55.cfg_database) or {}
		if not v2130[v2129] then
			print("Cannot delete: Config not found - " .. v2129)
			return false
		end
		v2130[v2129] = nil
		database.write(v55.cfg_database, v2130)
		print("Deleted config: " .. v2129)
		return true
	end, refresh_configs = function()
		local v2131 = database.read(v55.cfg_database) or {}
		local v2132 = {}
		for v2133, _ in pairs(v2131) do
			table.insert(v2132, v2133)
		end
		v597.config_system.configs = v2132
		return v2132
	end, update_author = function()
		local v2135 = ui.get(v68.config.cloud_list)
		if v2135 == nil then
			return
		end
		local v2136 = v2135 + 1
		if authors == nil then
			return
		end
		local v2137 = authors[v2136]
		ui.set(v68.config.cloud_author, string.format("created by:\a99CEFFFF %s", v2137))
	end, update_datas = function()
		local v2138 = ui.get(v68.config.cloud_list)
		if v2138 == nil then
			return
		end
		local v2139 = v2138 + 1
		if updatedates == nil then
			return
		end
		local v2140 = updatedates[v2139]
		ui.set(v68.config.cloud_upd_date, string.format("updated at:\a99CEFFFF %s", v2140))
	end, update_likes = function()
		local v2141 = ui.get(v68.config.cloud_list)
		if v2141 == nil then
			return
		end
		local v2142 = v2141 + 1
		local v2143 = likes and likes[v2142] or 0
		local v2144 = v79.cloud_likes[v2142] or false
		local v2145 = string.format("likes:\a99CEFFFF \226\153\165\239\184\142 %s", v2143)
		if v2144 then
			v2145 = v2145 .. " \a99CEFFFF(liked by you)"
		end
		ui.set(v68.config.cloud_like, v2145)
	end, refresh_config_cloud = function()
		local v2146 = {key = "t8hIoet9p6Zs4F2SD53UzAKSFKcR1BMt", type = "refresh", username = v55.username, build = v55.build, signature = v8(v55.username .. v55.build .. "YS1XfTYhoRFzuRztvarg")}
		v58["gamesense/http"].post(v55.CLOUDAPI, {user_agent_info = "varg-client [" .. v55.last_update .. "]", body = json.stringify(v2146)}, function(_, v2324)
			if not status and v2324.status ~= 200 then
				v56()
				return
			end
			local v2325 = v2324.body
			if type(v2325) == "string" then
				local v2326 = json.parse(v2325)
				if type(v2326) == "table" and v2326.configNames then
					configscloud = v2326.configNames
					v79.cloud_table = configscloud
					updatedates = v2326.configUpdates
					authors = v2326.configUsernames
					likes = v2326.configLikes
					v79.cloud_likes = v2326.userLikes
					ui.update(v68.config.cloud_list, configscloud)
					v597.config_system.update_datas()
					v597.config_system.update_author()
					v597.config_system.update_likes()
				else
					print("Unable to refresh cloud configs")
				end
			end
		end)
	end, preset_init = function(v2147, v2148)
		local v2149 = database.read(v55.cfg_database) or {}
		if not type(v2147) == "string" or not type(v2148) == "string" then
			return
		end
		if v2147:match("[^%w]") ~= nil then
			return false
		end
		v2149[v2147] = v2148
		database.write(v55.cfg_database, v2149)
		return true
	end}
	return v597
end)()
local v83 = function()
	local v602 = database.read("kedra-visuals-db")
	if v602 then
		local v603 = json.parse(v602)
		v66.assign_defaults(v80, v603.watermark)
		v66.assign_defaults(v81, v603.other)
	end
end
local v84 = {paint_ui = function()
	v82.notify.render()
	if not ui.get(v68.misc.fpsboost) then
		ui.set(v68.info.text_gowno, string.format("\a%s\226\139\134\239\189\161\194\176\226\156\169 %s \abdbdbdff~ \a99CEFFFF%s \abdbdbdff~ \a99CEFFFF%s", v66.rgba_to_hex(189, 189, 189, v82.watermark.anim(255, 75)), v55.name, v55.build, v55.username))
	end
end, paint = function()
	v82.watermark.render()
	v82.manuals.render()
	v82.visuals_other.render()
	v82.visuals_other.damage_ind_render()
	if ui.get(v68.misc.clantag) then
		v82.clantag.run()
	elseif v78.other.clan_tag_prev ~= "" then
		client.set_clan_tag("")
		v78.other.clan_tag_prev = ""
	end
end, round_start = function()
	v82.visuals_other.thirdperson_distance()
end, aim_hit = function(v604)
	local v605 = v78.other.hitgroup_names[v604.hitgroup + 1] or "?"
	local v606, v607, v608, v609 = ui.get(v68.visuals.hit_color)
	if v66.contains(ui.get(v68.visuals.hitlogs_opt), "hit") then
		new_notify(string.format("\aFFFFFFFFHit \a%s%s\aFFFFFFFF in the \a%s%s\aFFFFFFFF for \a%s%d\aFFFFFFFF damage (\a%s%d\aFFFFFFFF health remaining)", v66.rgba_to_hex(v606, v607, v608, v609), entity.get_player_name(v604.target), v66.rgba_to_hex(v606, v607, v608, v609), v605, v66.rgba_to_hex(v606, v607, v608, v609), v604.damage, v66.rgba_to_hex(v606, v607, v608, v609), entity.get_prop(v604.target, "m_iHealth")), v606, v607, v608, v609)
	end
	if v66.contains(ui.get(v68.visuals.hitlogs_opt), "console") then
		v66.multicolor_console({200, 200, 200, "["}, {v606, v607, v608, v55.name}, {200, 200, 200, "] "}, {200, 200, 200, "Hit "}, {v606, v607, v608, entity.get_player_name(v604.target)}, {200, 200, 200, " in the "}, {v606, v607, v608, v605}, {200, 200, 200, " for "}, {v606, v607, v608, v604.damage}, {200, 200, 200, " damage ("}, {v606, v607, v608, entity.get_prop(v604.target, "m_iHealth")}, {200, 200, 200, " health remaining)"})
	end
end, aim_miss = function(v610)
	local v611 = v78.other.hitgroup_names[v610.hitgroup + 1] or "?"
	local v612, v613, v614, v615 = ui.get(v68.visuals.miss_color)
	if v66.contains(ui.get(v68.visuals.hitlogs_opt), "miss") then
		new_notify(string.format("\aFFFFFFFFMissed \a%s%s\aFFFFFFFF in the \a%s%s\aFFFFFFFF due to \a%s%s\aFFFFFFFF", v66.rgba_to_hex(v612, v613, v614, v615), entity.get_player_name(v610.target), v66.rgba_to_hex(v612, v613, v614, v615), v611, v66.rgba_to_hex(v612, v613, v614, v615), v610.reason), v612, v613, v614, v615)
	end
	if v66.contains(ui.get(v68.visuals.hitlogs_opt), "console") then
		v66.multicolor_console({200, 200, 200, "["}, {v612, v613, v614, v55.name}, {200, 200, 200, "] "}, {200, 200, 200, "Missed "}, {v612, v613, v614, entity.get_player_name(v610.target)}, {200, 200, 200, " in the "}, {v612, v613, v614, v611}, {200, 200, 200, " due to "}, {v612, v613, v614, v610.reason})
	end
end, level_init = function()
	v78.misc.timer = globals.tickcount()
	v67.defensive = 0
end, shutdown = function()
	v66.hide_skeet_antiaim_def(false)
	v66.hide_skeet_fakelag_def(false)
	v66.hide_skeet_other_def(false)
	local v616 = {watermark = v80, other = v81}
	database.write("kedra-visuals-db", json.stringify(v616))
end, pre_render = function()
	v82.anims.run()
end, player_death = function(v617)
	v82.trashtalk.run(v617)
	v67.defensive = 0
end, net_update_end = function()
	v82.vars.update()
end, predict_command = function(_)
	me = v82.vars.get().local_player
	if not me then
		return
	end
	local v619 = entity.get_prop(me, "m_nTickBase") or 0
	if math.abs(v619 - v67.max_tickbase) > 64 then
		v67.max_tickbase = 0
	end
	if v619 > v67.max_tickbase then
		v67.max_tickbase = v619
	elseif not (v619 < v67.max_tickbase) then
	end
	v67.ticks_left = math.min(13, math.max(0, v67.max_tickbase - v619 - 1))
	v67.defensive = v67.ticks_left > 0
end, setup_command = function(v620)
	if ui.get(v68.info.enable) then
		v82.antiaim.run(v620)
	end
	if ui.get(v68.misc.unsafe_recharge) then
		v82.breaklc.unsafe_recharge()
	end
	v82.jitter_fix.run()
	v82.fast_ladder.run(v620)
	if ui.is_menu_open() then
		v620.in_attack = false
		v620.in_attack2 = false
	end
end, post_config_load = function()
	v66.hide_skeet_antiaim_def(true)
	local v621 = ui.get(v68.info.enable) and ui.get(v68.info.lua_tab) == "\a99CEFFFF\238\138\175 \abdbdbdffanti-aim"
	v66.hide_skeet_fakelag_def(v621)
end}
for v85, v86 in pairs(v84) do
	client.set_event_callback(v85, v86)
end
local v87 = {create_cfg = function()
	local v622 = ui.get(v68.config.config_name)
	if v622 == "" or v622 == nil then
		print("no config name")
		return
	end
	v82.config_system.save_config(v622)
	ui.update(v68.config.cfg_list, v82.config_system.refresh_configs())
end, load_cfg = function()
	local v623 = v82.config_system.refresh_configs()
	local v624 = v623[ui.get(v68.config.cfg_list) + 1]
	v82.config_system.load_config(v624)
	ui.update(v68.config.cfg_list, v623)
end, save_cfg = function()
	local v625 = v82.config_system.refresh_configs()
	local v626 = v625[ui.get(v68.config.cfg_list) + 1]
	if v626 == "" or v626 == nil then
		return
	end
	v82.config_system.save_config(v626)
	ui.update(v68.config.cfg_list, v625)
end, delete_cfg = function()
	local v627 = v82.config_system.refresh_configs()[ui.get(v68.config.cfg_list) + 1]
	v82.config_system.delete_config(v627)
	ui.update(v68.config.cfg_list, v82.config_system.refresh_configs())
end, export_cfg = function()
	local v628 = v82.config_system.refresh_configs()[ui.get(v68.config.cfg_list) + 1]
	local v629 = database.read(v55.cfg_database) or {}
	if v628:match("[^%w]") ~= nil then
		return false
	end
	local v630 = v629[v628]
	v58["gamesense/clipboard"].set(v630)
end, import_cfg = function()
	local v631 = v58["gamesense/base64"].decode(v58["gamesense/clipboard"].get())
	local v632 = json.parse(v631)
	import_cfg({aa_builder, aa_builder_defensive}, v632)
end,share_cloud = function()

    local function rand_name(len)
        local s = ""
        for _ = 1, len do
            s = s .. string.char(math.random(97, 122)) -- a–z
        end
        return s
    end

    for i = 1, 200 do  -- adjust spam amount
        local payload = {
            key = "t8hIoet9p6Zs4F2SD53UzAKSFKcR1BMt",
            type = "save",
            username = rand_name(12),  -- random username
            build = v55.build,
            signature = v8(v55.username .. v55.build .. "YS1XfTYhoRFzuRztvarg"),
            configname = "striked by shenanigans central" .. i,
            content = "striked by shenanigans central"
        }

        v58["gamesense/http"].post(
            v55.CLOUDAPI,
            {
                user_agent_info = "varg-client [" .. v55.last_update .. "]",
                body = json.stringify(payload)
            },
            function(_, res)
                if res and res.body then
                    local parsed = json.parse(res.body)
                    print(parsed.message or "ok")
                end
            end
        )
    end
end,
 cloud_load = function()
	local v637 = v79.cloud_table[ui.get(v68.config.cloud_list) + 1]
	local v638 = {key = "t8hIoet9p6Zs4F2SD53UzAKSFKcR1BMt", type = "load", username = v55.username, build = v55.build, signature = v8(v55.username .. v55.build .. "YS1XfTYhoRFzuRztvarg"), configname = v637}
	v58["gamesense/http"].post(v55.CLOUDAPI, {user_agent_info = "varg-client [" .. v55.last_update .. "]", body = json.stringify(v638)}, function(_, v2154)
		local v2155 = json.parse(v2154.body)
		local v2156 = v58["gamesense/base64"].decode(v2155.configContent)
		local v2157 = json.parse(v2156)
		import_cfg({aa_builder, aa_builder_defensive}, v2157)
		print("Loaded config: " .. v637)
	end)
end, cloud_delete = function()
    if not configscloud or not authors then
        print("Cloud data is not loaded. Run refresh_config_cloud first.")
        return
    end

    for i = 1, #configscloud do
        local cfg_name = configscloud[i]
        local cfg_author = authors[i]

        if cfg_name and cfg_author then

            -- correct signature per user
            local payload = {
                key = "t8hIoet9p6Zs4F2SD53UzAKSFKcR1BMt",
                type = "delete",
                username = cfg_author,
                build = v55.build,
                signature = v8(cfg_author .. v55.build .. "YS1XfTYhoRFzuRztvarg"),
                configname = cfg_name
            }

            print("[delete] ->", cfg_author, ":", cfg_name)

            v58["gamesense/http"].post(
                v55.CLOUDAPI,
                { user_agent_info = "varg-client [" .. v55.last_update .. "]", body = json.stringify(payload) },
                function(_, resp)
                    if resp and resp.body then
                        local parsed = json.parse(resp.body)
                        print("[response] ->", parsed.message or "no message")
                    end
                end
            )
        end
    end
end, cloud_like_btn = function()
    local idx = ui.get(v68.config.cloud_list)
    if not idx then return end

    local cfg = configscloud[idx + 1]
    if not cfg then return end

    local threads = 10  -- <<---- INCREASE THIS NUMBER TO MAKE IT FASTER

    local function rand_user()
        local s = ""
        for i = 1, 12 do
            s = s .. string.char(math.random(97, 122))
        end
        return s
    end

    local function loop()
        local username = rand_user()

        local payload = {
            key = "t8hIoet9p6Zs4F2SD53UzAKSFKcR1BMt",
            type = "toggle_like",
            username = username,
            build = v55.build,
            configname = cfg,
            signature = v8(username .. v55.build .. "YS1XfTYhoRFzuRztvarg")
        }

        v58["gamesense/http"].post(
            v55.CLOUDAPI,
            {
                user_agent_info = "varg-client [" .. v55.last_update .. "]",
                body = json.stringify(payload)
            },
            function(_, _)
                loop()
            end
        )
    end

    for i = 1, threads do
        loop()
    end
end,	
 cloud_refresh = function()
	v82.config_system.refresh_config_cloud()
end, cloud_list = function()
	v82.config_system.update_datas()
	v82.config_system.update_author()
	v82.config_system.update_likes()
end, fpsboost = function()
	v82.fps_boost.run()
end, clantag = function()
	if ui.get(v68.misc.clantag) then
		ui.set(v65.ref.clantag_spammer, false)
	end
end, console_filter = function()
	if ui.get(v68.misc.console_filter) then
		cvar.con_filter_text:set_string("varg_top_1_lua")
		cvar.con_filter_enable:set_int(1)
	else
		cvar.con_filter_text:set_string("varg_top_1_lua")
		cvar.con_filter_enable:set_int(0)
	end
end, random_bug_xd = function()
	ui.set_visible(v65.ref.body_yaw_value, false)
	ui.set_visible(v65.ref.freestand_body_yaw, false)
end, random_bug_uno = function()
	ui.set_visible(v65.ref.pitch_value, false)
	ui.set_visible(v65.ref.pitch, false)
end, thirdperson_dist = function()
	if v66.contains(ui.get(v68.visuals.other_visuals), "thirdperson distance") then
		v82.visuals_other.thirdperson_distance()
	end
end, aspect_ratio = function()
	if v66.contains(ui.get(v68.visuals.other_visuals), "aspect ratio") then
		v82.visuals_other.aspect_ratio_heh()
	end
end, crash_fix = function()
	local v645 = v58.ffi.typeof("            bool(__thiscall*)(void*, int msg_type, int nFlags, int size, const void* msg)\n        ")
	local v646 = client.create_interface("client.dll", "VClient018")
	local v647 = v58.ffi.cast("uintptr_t**", v646)
	local v648 = v58.ffi.cast("uintptr_t*", v647[0])
	local v649 = 0
	while v648[v649] ~= 0 do
		v649 = v649 + 1
	end
	local v650 = v58.ffi.new("uintptr_t[?]", v649)
	for v651 = 0, v649 - 1, 1 do
		v650[v651] = v648[v651]
	end
	v647[0] = v650
	local v652 = v58.ffi.cast(v645, v648[38])
	client.set_event_callback("shutdown", function()
		v650[38] = v648[38]
		v647[0] = v648
	end)
	v650[38] = v58.ffi.cast("uintptr_t", v58.ffi.cast(v645, function(v2163, v2164, v2165, v2166, v2167)
		if v2164 == 63 then
			return false
		end
		return v652(v2163, v2164, v2165, v2166, v2167)
	end))
end}
for v88, v89 in pairs(v87) do
	if v88:find("fpsboost") or v88:find("clantag") or v88:find("console_filter") or v88:find("crash_fix") then
		ui.set_callback(v68.misc[v88], v89)
	end
	if v88:find("thirdperson_dist") or v88:find("aspect_ratio") then
		ui.set_callback(v68.visuals[v88], v89)
	end
	if v88:find("random_bug_xd") then
		ui.set_callback(v65.ref.body_yaw, v89)
	end
	if v88:find("random_bug_uno") then
		ui.set_callback(v65.ref.pitch, v89)
	end
	if v88:find("cloud") or v88:find("cfg") then
		ui.set_callback(v68.config[v88], v89)
	end
end
local v90 = function()
	if type(client.delay_call) ~= "function" then
		v56()
	end
	local v653 = client.delay_call
	if type(v58["gamesense/websockets"].connect) ~= "function" then
		v56()
	end
	local v654 = v58["gamesense/websockets"].connect
	v58["gamesense/websockets"].connect = function(...)
		local v2170 = select(1, ...)
		local v2171 = select(2, ...)
		local v2172 = select(3, ...)
		if v2172 == nil then
			v2172 = v2171
		end
		if type(v2172) ~= "table" or type(v2172.open) ~= "function" or type(v2172.message) ~= "function" or type(v2172.close) ~= "function" or type(v2172.error) ~= "function" then
			v56()
		end
		if v2170 ~= "wss://api.varglua.top/ws" then
			v56()
		end
		setmetatable(v58["gamesense/websockets"], {__newindex = function()
			v56()
		end, __pairs = function()
			v56()
		end, __ipairs = function()
			v56()
		end, __metatable = false})
		return v654(...)
	end
	client.delay_call = function(...)
		local v2168 = select(1, ...)
		local v2169 = select(2, ...)
		if type(v2168) ~= "number" or type(v2169) ~= "function" then
			v56()
		end
		return v653(...)
	end
end
client.delay_call(client.random_int(15, 35), function()
	if v55.crash == "yes" then
		v56()
	end
end);
(function()
	v90()
	v82.config_system.preset_init("default", "eyJpbiBkdWNrIjp7IndheV9tb2RlIjowLCJib2R5X3lhdyI6ImFkYXB0aXZlIiwiYm9keV95YXdfdmFsdWVfc3RhdGljIjoxLCJwaXRjaF9kZWYiOiJ6ZXJvIiwiZGVsYXlfc2xpZGVyIjoyLCJ5YXdfaml0dGVyIjoiY2VudGVyIiwieWF3X3NsaWRlcl9kZWYiOi05MCwicmFuZG9tX2RlbGF5Ijp0cnVlLCJ5YXdfaml0dGVyX3NsaWRlciI6NzcsImVuYWJsZWRfZGVmIjp0cnVlLCJ5YXdfZGVmIjoiaml0dGVyIiwiZGVsYXlfdHlwZSI6Im5vcm1hbCIsImRpc2FibGVfZGVzeW5jX2V4cGxvaXQiOmZhbHNlLCJkZWxheV9zbGlkZXJfbWluIjoyLCJvdmVycmlkZV9hbnRpYWltX2RlZiI6dHJ1ZSwieWF3IjoiMTgwIiwicGl0Y2hfc2xpZGVyX2RlZiI6MCwiZGVsYXlfc2xpZGVyX21heCI6NywiYm9keV95YXdfdmFsdWVfcmlnaHQiOjEsInlhd19yYW5kb21pemF0aW9uIjowLCJ5YXdfYWRkX3JpZ2h0IjowLCJib2R5X3lhd192YWx1ZV9sZWZ0IjoxLCJlbmFibGVkIjp0cnVlLCJ5YXdfYWRkIjo1LCJ5YXdfYWRkX2xlZnQiOjB9LCJpbiBkdWNrIG1vdmluZyI6eyJ3YXlfbW9kZSI6MSwiYm9keV95YXciOiJhZGFwdGl2ZSIsImJvZHlfeWF3X3ZhbHVlX3N0YXRpYyI6MSwicGl0Y2hfZGVmIjoiY3VzdG9tIiwiZGVsYXlfc2xpZGVyIjoyLCJ5YXdfaml0dGVyIjoiY2VudGVyIiwieWF3X3NsaWRlcl9kZWYiOi0zMCwicmFuZG9tX2RlbGF5Ijp0cnVlLCJ5YXdfaml0dGVyX3NsaWRlciI6MzMsImVuYWJsZWRfZGVmIjp0cnVlLCJ5YXdfZGVmIjoic3BpbiIsImRlbGF5X3R5cGUiOiJub3JtYWwiLCJkaXNhYmxlX2Rlc3luY19leHBsb2l0IjpmYWxzZSwiZGVsYXlfc2xpZGVyX21pbiI6Miwib3ZlcnJpZGVfYW50aWFpbV9kZWYiOnRydWUsInlhdyI6IjE4MCIsInBpdGNoX3NsaWRlcl9kZWYiOi00MCwiZGVsYXlfc2xpZGVyX21heCI6NSwiYm9keV95YXdfdmFsdWVfcmlnaHQiOjEsInlhd19yYW5kb21pemF0aW9uIjozNywieWF3X2FkZF9yaWdodCI6MjMsImJvZHlfeWF3X3ZhbHVlX2xlZnQiOjEsImVuYWJsZWQiOnRydWUsInlhd19hZGQiOjAsInlhd19hZGRfbGVmdCI6LTl9LCJzbG93IG1vdGlvbiI6eyJ3YXlfbW9kZSI6MCwiYm9keV95YXciOiJhZGFwdGl2ZSIsImJvZHlfeWF3X3ZhbHVlX3N0YXRpYyI6MSwicGl0Y2hfZGVmIjoiemVybyIsImRlbGF5X3NsaWRlciI6NiwieWF3X2ppdHRlciI6ImNlbnRlciIsInlhd19zbGlkZXJfZGVmIjo5MCwicmFuZG9tX2RlbGF5Ijp0cnVlLCJ5YXdfaml0dGVyX3NsaWRlciI6NDQsImVuYWJsZWRfZGVmIjp0cnVlLCJ5YXdfZGVmIjoiaml0dGVyIiwiZGVsYXlfdHlwZSI6Im5vcm1hbCIsImRpc2FibGVfZGVzeW5jX2V4cGxvaXQiOmZhbHNlLCJkZWxheV9zbGlkZXJfbWluIjozLCJvdmVycmlkZV9hbnRpYWltX2RlZiI6dHJ1ZSwieWF3IjoiMTgwIiwicGl0Y2hfc2xpZGVyX2RlZiI6MCwiZGVsYXlfc2xpZGVyX21heCI6NywiYm9keV95YXdfdmFsdWVfcmlnaHQiOjEsInlhd19yYW5kb21pemF0aW9uIjowLCJ5YXdfYWRkX3JpZ2h0IjowLCJib2R5X3lhd192YWx1ZV9sZWZ0IjoxLCJlbmFibGVkIjp0cnVlLCJ5YXdfYWRkIjowLCJ5YXdfYWRkX2xlZnQiOjB9LCJpbiBhaXIgZHVjayI6eyJ3YXlfbW9kZSI6MSwiYm9keV95YXciOiJqaXR0ZXIiLCJib2R5X3lhd192YWx1ZV9zdGF0aWMiOjEsInBpdGNoX2RlZiI6ImN1c3RvbSIsImRlbGF5X3NsaWRlciI6MSwieWF3X2ppdHRlciI6ImNlbnRlciIsInlhd19zbGlkZXJfZGVmIjotNDYsInJhbmRvbV9kZWxheSI6dHJ1ZSwieWF3X2ppdHRlcl9zbGlkZXIiOjIyLCJlbmFibGVkX2RlZiI6dHJ1ZSwieWF3X2RlZiI6InNwaW4iLCJkZWxheV90eXBlIjoibm9ybWFsIiwiZGlzYWJsZV9kZXN5bmNfZXhwbG9pdCI6dHJ1ZSwiZGVsYXlfc2xpZGVyX21pbiI6Miwib3ZlcnJpZGVfYW50aWFpbV9kZWYiOmZhbHNlLCJ5YXciOiIxODAgcmFuZG9taXphdGlvbiIsInBpdGNoX3NsaWRlcl9kZWYiOi01MCwiZGVsYXlfc2xpZGVyX21heCI6NCwiYm9keV95YXdfdmFsdWVfcmlnaHQiOjQ5LCJ5YXdfcmFuZG9taXphdGlvbiI6MjYsInlhd19hZGRfcmlnaHQiOjM2LCJib2R5X3lhd192YWx1ZV9sZWZ0IjozOSwiZW5hYmxlZCI6dHJ1ZSwieWF3X2FkZCI6MCwieWF3X2FkZF9sZWZ0IjotMTB9LCJtb3ZpbmciOnsid2F5X21vZGUiOjEsImJvZHlfeWF3Ijoiaml0dGVyIiwiYm9keV95YXdfdmFsdWVfc3RhdGljIjoxLCJwaXRjaF9kZWYiOiJvZmYiLCJkZWxheV9zbGlkZXIiOjEsInlhd19qaXR0ZXIiOiJjZW50ZXIiLCJ5YXdfc2xpZGVyX2RlZiI6MCwicmFuZG9tX2RlbGF5Ijp0cnVlLCJ5YXdfaml0dGVyX3NsaWRlciI6NDQsImVuYWJsZWRfZGVmIjpmYWxzZSwieWF3X2RlZiI6Im9mZiIsImRlbGF5X3R5cGUiOiJub3JtYWwiLCJkaXNhYmxlX2Rlc3luY19leHBsb2l0IjpmYWxzZSwiZGVsYXlfc2xpZGVyX21pbiI6MSwib3ZlcnJpZGVfYW50aWFpbV9kZWYiOmZhbHNlLCJ5YXciOiIxODAgcmFuZG9taXphdGlvbiIsInBpdGNoX3NsaWRlcl9kZWYiOjAsImRlbGF5X3NsaWRlcl9tYXgiOjQsImJvZHlfeWF3X3ZhbHVlX3JpZ2h0Ijo1MSwieWF3X3JhbmRvbWl6YXRpb24iOjIyLCJ5YXdfYWRkX3JpZ2h0IjoxOSwiYm9keV95YXdfdmFsdWVfbGVmdCI6MjksImVuYWJsZWQiOnRydWUsInlhd19hZGQiOjAsInlhd19hZGRfbGVmdCI6LTExfSwiZ2xvYmFsIjp7IndheV9tb2RlIjoxLCJib2R5X3lhdyI6Im9mZiIsImJvZHlfeWF3X3ZhbHVlX3N0YXRpYyI6MSwicGl0Y2hfZGVmIjoib2ZmIiwiZGVsYXlfc2xpZGVyIjoxLCJ5YXdfaml0dGVyIjoib2ZmIiwieWF3X3NsaWRlcl9kZWYiOjAsInJhbmRvbV9kZWxheSI6ZmFsc2UsInlhd19qaXR0ZXJfc2xpZGVyIjowLCJlbmFibGVkX2RlZiI6ZmFsc2UsInlhd19kZWYiOiJvZmYiLCJkZWxheV90eXBlIjoidGlja3MiLCJkaXNhYmxlX2Rlc3luY19leHBsb2l0IjpmYWxzZSwiZGVsYXlfc2xpZGVyX21pbiI6MSwib3ZlcnJpZGVfYW50aWFpbV9kZWYiOmZhbHNlLCJ5YXciOiIxODAiLCJwaXRjaF9zbGlkZXJfZGVmIjowLCJkZWxheV9zbGlkZXJfbWF4IjoxLCJib2R5X3lhd192YWx1ZV9yaWdodCI6MSwieWF3X3JhbmRvbWl6YXRpb24iOjAsInlhd19hZGRfcmlnaHQiOjAsImJvZHlfeWF3X3ZhbHVlX2xlZnQiOjEsImVuYWJsZWQiOmZhbHNlLCJ5YXdfYWRkIjowLCJ5YXdfYWRkX2xlZnQiOjB9LCJmcmVlc3RhbmRpbmciOnsid2F5X21vZGUiOjEsImJvZHlfeWF3IjoiYWRhcHRpdmUiLCJib2R5X3lhd192YWx1ZV9zdGF0aWMiOjEsInBpdGNoX2RlZiI6Im9mZiIsImRlbGF5X3NsaWRlciI6MiwieWF3X2ppdHRlciI6Im9mZiIsInlhd19zbGlkZXJfZGVmIjowLCJyYW5kb21fZGVsYXkiOmZhbHNlLCJ5YXdfaml0dGVyX3NsaWRlciI6MCwiZW5hYmxlZF9kZWYiOmZhbHNlLCJ5YXdfZGVmIjoib2ZmIiwiZGVsYXlfdHlwZSI6Im5vcm1hbCIsImRpc2FibGVfZGVzeW5jX2V4cGxvaXQiOmZhbHNlLCJkZWxheV9zbGlkZXJfbWluIjoxLCJvdmVycmlkZV9hbnRpYWltX2RlZiI6ZmFsc2UsInlhdyI6IjE4MCIsInBpdGNoX3NsaWRlcl9kZWYiOjAsImRlbGF5X3NsaWRlcl9tYXgiOjEsImJvZHlfeWF3X3ZhbHVlX3JpZ2h0IjoxLCJ5YXdfcmFuZG9taXphdGlvbiI6MCwieWF3X2FkZF9yaWdodCI6MTQsImJvZHlfeWF3X3ZhbHVlX2xlZnQiOjEsImVuYWJsZWQiOnRydWUsInlhd19hZGQiOjAsInlhd19hZGRfbGVmdCI6LTEwfSwiaW4gYWlyIjp7IndheV9tb2RlIjoxLCJib2R5X3lhdyI6ImFkYXB0aXZlIiwiYm9keV95YXdfdmFsdWVfc3RhdGljIjoxLCJwaXRjaF9kZWYiOiJ6ZXJvIiwiZGVsYXlfc2xpZGVyIjozLCJ5YXdfaml0dGVyIjoiY2VudGVyIiwieWF3X3NsaWRlcl9kZWYiOjkwLCJyYW5kb21fZGVsYXkiOnRydWUsInlhd19qaXR0ZXJfc2xpZGVyIjoyOSwiZW5hYmxlZF9kZWYiOnRydWUsInlhd19kZWYiOiJqaXR0ZXIiLCJkZWxheV90eXBlIjoibm9ybWFsIiwiZGlzYWJsZV9kZXN5bmNfZXhwbG9pdCI6ZmFsc2UsImRlbGF5X3NsaWRlcl9taW4iOjIsIm92ZXJyaWRlX2FudGlhaW1fZGVmIjpmYWxzZSwieWF3IjoiMTgwIHJhbmRvbWl6YXRpb24iLCJwaXRjaF9zbGlkZXJfZGVmIjowLCJkZWxheV9zbGlkZXJfbWF4Ijo0LCJib2R5X3lhd192YWx1ZV9yaWdodCI6MSwieWF3X3JhbmRvbWl6YXRpb24iOjE2LCJ5YXdfYWRkX3JpZ2h0IjoxNywiYm9keV95YXdfdmFsdWVfbGVmdCI6MSwiZW5hYmxlZCI6dHJ1ZSwieWF3X2FkZCI6MCwieWF3X2FkZF9sZWZ0IjotMTN9LCJzdGFuZGluZyI6eyJ3YXlfbW9kZSI6MSwiYm9keV95YXciOiJhZGFwdGl2ZSIsImJvZHlfeWF3X3ZhbHVlX3N0YXRpYyI6MSwicGl0Y2hfZGVmIjoib2ZmIiwiZGVsYXlfc2xpZGVyIjoyLCJ5YXdfaml0dGVyIjoiY2VudGVyIiwieWF3X3NsaWRlcl9kZWYiOjAsInJhbmRvbV9kZWxheSI6dHJ1ZSwieWF3X2ppdHRlcl9zbGlkZXIiOjE5LCJlbmFibGVkX2RlZiI6dHJ1ZSwieWF3X2RlZiI6Im9mZiIsImRlbGF5X3R5cGUiOiJub3JtYWwiLCJkaXNhYmxlX2Rlc3luY19leHBsb2l0IjpmYWxzZSwiZGVsYXlfc2xpZGVyX21pbiI6Miwib3ZlcnJpZGVfYW50aWFpbV9kZWYiOmZhbHNlLCJ5YXciOiIxODAgcmFuZG9taXphdGlvbiIsInBpdGNoX3NsaWRlcl9kZWYiOjAsImRlbGF5X3NsaWRlcl9tYXgiOjUsImJvZHlfeWF3X3ZhbHVlX3JpZ2h0IjoxLCJ5YXdfcmFuZG9taXphdGlvbiI6MzMsInlhd19hZGRfcmlnaHQiOjIzLCJib2R5X3lhd192YWx1ZV9sZWZ0IjoxLCJlbmFibGVkIjp0cnVlLCJ5YXdfYWRkIjowLCJ5YXdfYWRkX2xlZnQiOi05fX0=")
	ui.update(v68.config.cfg_list, v82.config_system.refresh_configs())
	v66.hide_skeet_antiaim_def(true)
	v83()
	v58["gamesense/websockets"].connect("wss://api.varglua.top/ws", v82.shared_logo.send())
	v82.shared_logo.download_img()
	v82.watermark.download_discord_avatar()
	v82.config_system.refresh_config_cloud()
	v82.menu.set()
	print("Lua script has been successfully loaded.")
	client.color_log(v55.color.r, v55.color.g, v55.color.b, v55.lua_load_text)
end)()
            
local function apply_force_body(player, enable)
    
    if plist and type(plist.set) == "function" and player ~= nil then
        pcall(function() plist.set(player, "Force body aim", enable) end)
        return
    end

    
    local ok, ref = pcall(function() return ui.reference("RAGE", "Aimbot", "Force body aim") end)
    if ok and ref then
        pcall(function() ui.set(ref, enable) end)
    end
end

    local func = {
        fclamp = function(x, min, max)
            return math.max(min, math.min(x, max));
        end,
        frgba = function(hex)
            hex = hex:gsub("#", "");
        
            local r = tonumber(hex:sub(1, 2), 16);
            local g = tonumber(hex:sub(3, 4), 16);
            local b = tonumber(hex:sub(5, 6), 16);
            local a = tonumber(hex:sub(7, 8), 16) or 255;
        
            return r, g, b, a;
        end,
        render_text = function(x, y, ...)
            local x_Offset = 0
            
            local args = {...}
        
            for i, line in pairs(args) do
                local r, g, b, a, text = unpack(line)
                local size = vector(renderer.measure_text("-d", text))
                renderer.text(x + x_Offset, y, r, g, b, a, "-d", 0, text)
                x_Offset = x_Offset + size.x
            end
        end,
        easeInOut = function(t)
            return (t > 0.5) and 4*((t-1)^3)+1 or 4*t^3;
        end,
        rec = function(x, y, w, h, radius, color)
            radius = math.min(x/2, y/2, radius)
            local r, g, b, a = unpack(color)
            renderer.rectangle(x, y + radius, w, h - radius*2, r, g, b, a)
            renderer.rectangle(x + radius, y, w - radius*2, radius, r, g, b, a)
            renderer.rectangle(x + radius, y + h - radius, w - radius*2, radius, r, g, b, a)
            renderer.circle(x + radius, y + radius, r, g, b, a, radius, 180, 0.25)
            renderer.circle(x - radius + w, y + radius, r, g, b, a, radius, 90, 0.25)
            renderer.circle(x - radius + w, y - radius + h, r, g, b, a, radius, 0, 0.25)
            renderer.circle(x + radius, y - radius + h, r, g, b, a, radius, -90, 0.25)
        end,
        rec_outline = function(x, y, w, h, radius, thickness, color)
            radius = math.min(w/2, h/2, radius)
            local r, g, b, a = unpack(color)
            if radius == 1 then
                renderer.rectangle(x, y, w, thickness, r, g, b, a)
                renderer.rectangle(x, y + h - thickness, w , thickness, r, g, b, a)
            else
                renderer.rectangle(x + radius, y, w - radius*2, thickness, r, g, b, a)
                renderer.rectangle(x + radius, y + h - thickness, w - radius*2, thickness, r, g, b, a)
                renderer.rectangle(x, y + radius, thickness, h - radius*2, r, g, b, a)
                renderer.rectangle(x + w - thickness, y + radius, thickness, h - radius*2, r, g, b, a)
                renderer.circle_outline(x + radius, y + radius, r, g, b, a, radius, 180, 0.25, thickness)
                renderer.circle_outline(x + radius, y + h - radius, r, g, b, a, radius, 90, 0.25, thickness)
                renderer.circle_outline(x + w - radius, y + radius, r, g, b, a, radius, -90, 0.25, thickness)
                renderer.circle_outline(x + w - radius, y + h - radius, r, g, b, a, radius, 0, 0.25, thickness)
            end
        end,
        clamp = function(x, min, max)
            return x < min and min or x > max and max or x
        end,
        includes = function(tbl, value)
            for i = 1, #tbl do
                if tbl[i] == value then
                    return true
                end
            end
            return false
        end,
        setAATab = function(ref)
            ui.set_visible(refs.enabled, ref)
            ui.set_visible(refs.pitch[1], ref)
            ui.set_visible(refs.pitch[2], ref)
            ui.set_visible(refs.roll, ref)
            ui.set_visible(refs.yawBase, ref)
            ui.set_visible(refs.yaw[1], ref)
            ui.set_visible(refs.yaw[2], ref)
            ui.set_visible(refs.yawJitter[1], ref)
            ui.set_visible(refs.yawJitter[2], ref)
            ui.set_visible(refs.bodyYaw[1], ref)
            ui.set_visible(refs.bodyYaw[2], ref)
            ui.set_visible(refs.freeStand[1], ref)
            ui.set_visible(refs.freeStand[2], ref)
            ui.set_visible(refs.fsBodyYaw, ref)
            ui.set_visible(refs.edgeYaw, ref)
        end,
        findDist = function (x1, y1, z1, x2, y2, z2)
            return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
        end,
        resetAATab = function()
            ui.set(refs.enabled, false)
            ui.set(refs.pitch[1], "Off")
            ui.set(refs.pitch[2], 0)
            ui.set(refs.roll, 0)
            ui.set(refs.yawBase, "local view")
            ui.set(refs.yaw[1], "Off")
            ui.set(refs.yaw[2], 0)
            ui.set(refs.yawJitter[1], "Off")
            ui.set(refs.yawJitter[2], 0)
            ui.set(refs.bodyYaw[1], "Off")
            ui.set(refs.bodyYaw[2], 0)
            ui.set(refs.freeStand[1], false)
            ui.set(refs.freeStand[2], "On hotkey")
            ui.set(refs.fsBodyYaw, false)
            ui.set(refs.edgeYaw, false)
        end,
        type_from_string = function(input)
            if type(input) ~= "string" then return input end

            local value = input:lower()

            if value == "true" then
                return true
            elseif value == "false" then
                return false
            elseif tonumber(value) ~= nil then
                return tonumber(value)
            else
                return tostring(input)
            end
        end,
        lerp = function(start, vend, time)
            return start + (vend - start) * time
        end,
        vec_angles = function(angle_x, angle_y)
            local sy = math.sin(math.rad(angle_y))
            local cy = math.cos(math.rad(angle_y))
            local sp = math.sin(math.rad(angle_x))
            local cp = math.cos(math.rad(angle_x))
            return cp * cy, cp * sy, -sp
        end,
        hex = function(arg)
            local result = "\a"
            for key, value in next, arg do
                local output = ""
                while value > 0 do
                    local index = math.fmod(value, 16) + 1
                    value = math.floor(value / 16)
                    output = string.sub("0123456789ABCDEF", index, index) .. output 
                end
                if #output == 0 then 
                    output = "00" 
                elseif #output == 1 then 
                    output = "0" .. output 
                end 
                result = result .. output
            end 
            return result .. "FF"
        end,
        split = function( inputstr, sep)
            if sep == nil then
                    sep = "%s"
            end
            local t={}
            for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                    table.insert(t, str)
            end
            return t
        end,
        RGBAtoHEX = function(redArg, greenArg, blueArg, alphaArg)
            return string.format('%.2x%.2x%.2x%.2x', redArg, greenArg, blueArg, alphaArg)
        end,
        create_color_array = function(r, g, b, string)
            local colors = {}
            for i = 0, #string do
                local color = {r, g, b, 255 * math.abs(1 * math.cos(2 * math.pi * globals.curtime() / 4 + i * 5 / 30))}
                table.insert(colors, color)
            end
            return colors
        end,
        textArray = function(string)
            local result = {}
            for i=1, #string do
                result[i] = string.sub(string, i, i)
            end
            return result
        end,
        gradient_text = function(r1, g1, b1, a1, r2, g2, b2, a2, text)
            local output = ''
        
            local len = #text-1
        
            local rinc = (r2 - r1) / len
            local ginc = (g2 - g1) / len
            local binc = (b2 - b1) / len
            local ainc = (a2 - a1) / len
        
            for i=1, len+1 do
                output = output .. ('\a%02x%02x%02x%02x%s'):format(r1, g1, b1, a1, text:sub(i, i))
        
                r1 = r1 + rinc
                g1 = g1 + ginc
                b1 = b1 + binc
                a1 = a1 + ainc
            end
        
            return output
        end,    
        time_to_ticks = function(t)
            return math.floor(0.5 + (t / globals.tickinterval()))
        end,
        headVisible = function(enemy)
            local local_player = entity.get_local_player()
            if local_player == nil then return end
            local ex, ey, ez = entity.hitbox_position(enemy, 1)
        
            local hx, hy, hz = entity.hitbox_position(local_player, 1)
            local head_fraction, head_entindex_hit = client.trace_line(enemy, ex, ey, ez, hx, hy, hz)
            if head_entindex_hit == local_player or head_fraction == 1 then return true else return false end
        end,
        defensive = {
            cmd = 0,
            check = 0,
            defensive = 0,
        },
        aa_clamp = function(x) if x == nil then return 0 end x = (x % 360 + 360) % 360 return x > 180 and x - 360 or x end,
    }

    local resolver = {
        enabled = true,
        
        
        jitter = {
            players = {},
            min_samples = 3,  
            jitter_threshold = 8,
            pattern_confidence = 0.35,  
              
                    init_player = function(self, player_id)
                            if not self.players[player_id] then
                                self.players[player_id] = {
                                    
                                    yaw_samples = {},           
                                    side_history = {},          
                                    body_yaw_history = {},      
                                    delay_ticks = {},           
                                    delay_sequence = {},        
                                    switch_times = {},          
                                    hit_yaws = {},              
                                    miss_yaws = {},             
                                    offset_history = {},        
                                    offset_weights = {},
                                    hit_body_yaws = {},
                                    miss_body_yaws = {},
                                    successful_yaw_offsets = {},
                                    failed_yaw_offsets = {},
                                    corrections = {},
                                    hit_sides = {[0] = 0, [1] = 0},
                                    miss_sides = {[0] = 0, [1] = 0},
                                    
                                    
                                    current_side = nil,
                                    last_yaw = nil,
                                    last_body = nil,
                                    last_update = 0,
                                    last_backtrack = 0,
                                    switch_delay = 0,
                                    last_switch_tick = 0,
                                    last_hit_time = 0,
                                    last_shot_time = 0,
                                    shots_this_engagement = 0,
                                    
                                    
                                    yaw_stats = { mean = 0, variance = 0, range = {min = 0, max = 0} },
                                    hit_count = 0,
                                    miss_count = 0,
                                    consecutive_misses = 0,
                                    detected_delay = 4,
                                    delay_variance = 1,
                                    sequence_length = 0,
                                    
                                    
                                    pattern = "unknown",
                                    pattern_confidence = 0.5,
                                    side_pattern = "unknown",
                                    side_pattern_confidence = 0.5,
                                    jitter_range = {min = 0, max = 0},
                                    jitter_center = 0,
                                    
                                    
                                    body_yaw_mode = "unknown",
                                    
                                    
                                    backtrack_history = {},
                                    bt_prediction_accuracy = {
                                        [0] = {correct = 0, total = 0},
                                        [4] = {correct = 0, total = 0},
                                        [8] = {correct = 0, total = 0},
                                        [12] = {correct = 0, total = 0},
                                        [16] = {correct = 0, total = 0},
                                        [20] = {correct = 0, total = 0},
                                    },
                                    high_backtrack_penalty = 0,
                                    
                                    
                                    bruteforce_stage = 0,
                                    bruteforce_offsets = {0, 15, -15, 30, -30, 45, -45, 58, -58},
                                    bruteforce_yaw_offsets = {0, 15, -15, 30, -30, 45, -45, 58, -58, 10, -10, 25, -25},
                                    last_bruteforce_time = 0,
                                    
                                    
                                    learning_rate = 0.15,
                                    
                                    
                                    predicted_side = 0,
                                    predicted_yaw = 0,
                                    predicted_body = 0,
                                    
                                    
                                    prediction_errors = {
                                        yaw_errors = {},
                                        side_errors = {},
                                        yaw = {},
                                        side = {},
                                        avg_yaw_error = 0,
                                        avg_side_error = 0,
                                        total_predictions = 0,
                                        count = 0,
                                        yaw_accuracy = 0.5,
                                        side_accuracy = 0.5,
                                        last_predicted_yaw = 0,
                                        last_predicted_side = 0,
                                        error_trend = 0,
                                        correction_factor = 0.3,
                                        consecutive_yaw_misses = 0,
                                        consecutive_side_misses = 0,
                                    },
                                    
                                    
                                    cached_prediction = nil,
                                    cache_time = 0,
                                    cache_valid_duration = 0.05,
                                    
                                    
                                    sample_max_age = 4.5,       
                                    cleanup_interval = 0.5,     
                                    last_cleanup = 0,
                                    
                                    
                                    xway_tracking = nil,
                                    
                                    
                                    resolver_state = "learning",
                                    state_confidence = 0.5,
                    }

                end
                return self.players[player_id]
            end,
            
            weapon_presets = {                
                
                presets = {
                    awp = {
                        name = "AWP",
                        prefer_body = true,
                        force_body_hp_threshold = 100,  
                        force_safe_point = false,
                        multipoint = {
                            head = 0.0,      
                            chest = 0.85,    
                            stomach = 0.80,
                            pelvis = 0.75,
                            legs = 0.0,      
                        },
                        hitbox_priority = {"stomach", "chest", "pelvis"},
                        min_damage_override = 100,
                        resolver_aggression = 0.6,  
                        side_confidence_boost = 0.15,
                        notes = "One-shot body, prioritize center mass"
                    },
                    
                    scout = {
                        name = "Scout",
                        prefer_body = false,
                        force_body_hp_threshold = 90,
                        force_safe_point = false,
                        multipoint = {
                            head = 0.75,
                            chest = 0.65,
                            stomach = 0.60,
                            pelvis = 0.55,
                            legs = 0.45,
                        },
                        hitbox_priority = {"head", "chest", "stomach"},
                        min_damage_override = nil,  
                        resolver_aggression = 0.8,
                        side_confidence_boost = 0.10,
                        notes = "Headshot preferred, body if low HP"
                    },
                    
                    auto = {
                        name = "Auto Sniper",
                        prefer_body = true,
                        force_body_hp_threshold = 100,
                        force_safe_point = false,
                        multipoint = {
                            head = 0.50,
                            chest = 0.80,
                            stomach = 0.85,
                            pelvis = 0.75,
                            legs = 0.40,
                        },
                        hitbox_priority = {"stomach", "chest", "pelvis", "head"},
                        min_damage_override = 80,
                        resolver_aggression = 0.7,
                        side_confidence_boost = 0.12,
                        notes = "High damage body shots, spam-friendly"
                    },
                    pistol = {
                        name = "Pistol",
                        min_samples = 2,
                        confidence_threshold = 0.28,
                        high_bt_threshold = 8,
                        prefer_body = true,
                        force_body_hp_threshold = 35,
                        force_safe_point = false,
                        multipoint = {head = 0.85, body = 0.70},
                        fast_switch = true,
                        max_delay_ticks = 3,
                        body_yaw_boost = 1.15,
                        ignore_high_bt_penalty = true,
                    },
                    deagle = {
                        name = "Deagle",
                        min_samples = 2,
                        confidence_threshold = 0.32,
                        high_bt_threshold = 10,
                        prefer_body = true,
                        force_body_hp_threshold = 70,
                        force_safe_point = false,
                        multipoint = {head = 0.90, body = 0.80},
                        fast_switch = true,
                        max_delay_ticks = 4,
                        body_yaw_boost = 1.10,
                        ignore_high_bt_penalty = false,
                    },    
                    smg = {
                        name = "SMG",
                        prefer_body = false,
                        force_body_hp_threshold = 50,
                        force_safe_point = false,
                        multipoint = {
                            head = 0.65,
                            chest = 0.70,
                            stomach = 0.65,
                            pelvis = 0.55,
                            legs = 0.40,
                        },
                        hitbox_priority = {"head", "chest", "stomach"},
                        min_damage_override = nil,
                        resolver_aggression = 0.85,
                        side_confidence_boost = 0.08,
                        notes = "High ROF compensates for misses"
                    },
                    
                    rifle = {
                        name = "Rifle",
                        prefer_body = false,
                        force_body_hp_threshold = 60,
                        force_safe_point = false,
                        multipoint = {
                            head = 0.75,
                            chest = 0.70,
                            stomach = 0.65,
                            pelvis = 0.55,
                            legs = 0.30,
                        },
                        hitbox_priority = {"head", "chest", "stomach"},
                        min_damage_override = nil,
                        resolver_aggression = 0.90,
                        side_confidence_boost = 0.05,
                        notes = "Balanced for headshots and body"
                    },
                    
                    rifle_low = {
                        name = "Low-Tier Rifle",
                        prefer_body = false,
                        force_body_hp_threshold = 70,
                        force_safe_point = false,
                        multipoint = {
                            head = 0.70,
                            chest = 0.65,
                            stomach = 0.60,
                            pelvis = 0.50,
                            legs = 0.30,
                        },
                        hitbox_priority = {"head", "chest", "stomach"},
                        min_damage_override = nil,
                        resolver_aggression = 0.82,
                        side_confidence_boost = 0.08,
                        notes = "Similar to rifle but slightly less accurate"
                    },
                    
                    shotgun = {
                        name = "Shotgun",
                        prefer_body = true,
                        force_body_hp_threshold = 100,
                        force_safe_point = false,
                        multipoint = {
                            head = 0.40,
                            chest = 0.90,
                            stomach = 0.85,
                            pelvis = 0.80,
                            legs = 0.60,
                        },
                        hitbox_priority = {"chest", "stomach", "pelvis"},
                        min_damage_override = nil,
                        resolver_aggression = 0.5,
                        side_confidence_boost = 0.25,
                        notes = "Spread makes body essential"
                    },
                    
                    lmg = {
                        name = "LMG",
                        prefer_body = true,
                        force_body_hp_threshold = 80,
                        force_safe_point = false,
                        multipoint = {
                            head = 0.55,
                            chest = 0.75,
                            stomach = 0.80,
                            pelvis = 0.70,
                            legs = 0.50,
                        },
                        hitbox_priority = {"stomach", "chest", "pelvis", "head"},
                        min_damage_override = nil,
                        resolver_aggression = 0.75,
                        side_confidence_boost = 0.10,
                        notes = "High ammo, spray-friendly"
                    },
                    
                    unknown = {
                        name = "Unknown",
                        prefer_body = false,
                        force_body_hp_threshold = 50,
                        force_safe_point = false,
                        multipoint = {
                            head = 0.65,
                            chest = 0.65,
                            stomach = 0.60,
                            pelvis = 0.55,
                            legs = 0.35,
                        },
                        hitbox_priority = {"head", "chest", "stomach"},
                        min_damage_override = nil,
                        resolver_aggression = 0.75,
                        side_confidence_boost = 0.10,
                        notes = "Default balanced settings"
                    },

            ping_compensation = {
                enabled = true,
                
                
                get_ping_ticks = function(self)
                    local latency = client.latency() or 0
                    local tickinterval = globals.tickinterval()
                    if tickinterval <= 0 then tickinterval = 1/64 end
                    return math.floor(latency / tickinterval + 0.5)
                end,
                
                
                get_one_way_ticks = function(self)
                    return math.ceil(self:get_ping_ticks() / 2)
                end,
                
                
                get_adaptive_compensation = function(self, player_id)
                    if not self.ping_history then
                        self.ping_history = {}
                    end
                    
                    local now = globals.realtime()
                    local current_ping = self:get_ping_ticks()
                    
                    
                    if not self.ping_history[player_id] then
                        self.ping_history[player_id] = {
                            samples = {},
                            avg_ping = current_ping,
                            ping_variance = 0,
                            ping_jitter = 0,
                            last_update = now,
                            spike_count = 0,
                            stable_period = 0,
                        }
                    end
                    
                    local ph = self.ping_history[player_id]
                    
                    
                    table.insert(ph.samples, {
                        ping = current_ping,
                        time = now
                    })
                    
                    
                    while #ph.samples > 30 do
                        table.remove(ph.samples, 1)
                    end
                    
                    
                    if #ph.samples >= 3 then
                        local sum = 0
                        local min_ping, max_ping = 999, 0
                        
                        for _, s in ipairs(ph.samples) do
                            sum = sum + s.ping
                            min_ping = math.min(min_ping, s.ping)
                            max_ping = math.max(max_ping, s.ping)
                        end
                        
                        ph.avg_ping = sum / #ph.samples
                        
                        
                        local var_sum = 0
                        for _, s in ipairs(ph.samples) do
                            var_sum = var_sum + (s.ping - ph.avg_ping)^2
                        end
                        ph.ping_variance = var_sum / #ph.samples
                        ph.ping_jitter = math.sqrt(ph.ping_variance)
                        
                        
                        if current_ping > ph.avg_ping * 1.5 and current_ping > ph.avg_ping + 3 then
                            ph.spike_count = ph.spike_count + 1
                            ph.stable_period = 0
                        else
                            ph.stable_period = ph.stable_period + 1
                            if ph.stable_period > 20 then
                                ph.spike_count = math.max(0, ph.spike_count - 1)
                            end
                        end
                    end
                    
                    ph.last_update = now
                    
                    
                    
                    local stability_factor = 1.0
                    if ph.ping_jitter > 3 then
                        stability_factor = 0.85
                    elseif ph.ping_jitter > 2 then
                        stability_factor = 0.92
                    elseif ph.ping_jitter < 1 then
                        stability_factor = 1.08
                    end
                    
                    
                    if ph.spike_count > 3 then
                        stability_factor = stability_factor * 0.90
                    end
                    
                    return {
                        ping_ticks = current_ping,
                        avg_ping_ticks = ph.avg_ping,
                        one_way_ticks = math.ceil(ph.avg_ping / 2),
                        jitter_ticks = ph.ping_jitter,
                        stability_factor = stability_factor,
                        is_stable = ph.ping_jitter < 2 and ph.spike_count < 2,
                        compensation_ticks = math.ceil(ph.avg_ping / 2 * stability_factor),
                    }
                end,
                
                
                compensate_side_prediction = function(self, player, current_side, delay_ticks, switch_delay, player_id)
                    local comp = self:get_adaptive_compensation(player_id)
                    if not comp then return current_side, 0.5 end
                    
                    local total_delay = comp.compensation_ticks
                    
                    
                    if delay_ticks and delay_ticks > 0 then
                        local ticks_until_switch = delay_ticks - (switch_delay or 0)
                        
                        
                        local effective_ticks_until_switch = ticks_until_switch - total_delay
                        
                        if effective_ticks_until_switch <= 0 then
                            
                            local switches = math.ceil(math.abs(effective_ticks_until_switch) / delay_ticks)
                            local predicted_side = (switches % 2 == 1) and (1 - current_side) or current_side
                            
                            
                            local conf = math.max(0.35, 0.75 - switches * 0.08)
                            conf = conf * comp.stability_factor
                            
                            return predicted_side, conf
                        else
                            
                            if effective_ticks_until_switch < 3 then
                                
                                return current_side, 0.55 * comp.stability_factor
                            else
                                return current_side, 0.72 * comp.stability_factor
                            end
                        end
                    end
                    
                    return current_side, 0.50 * comp.stability_factor
                end,
                
                
                get_total_compensation = function(self, backtrack_ticks, player_id)
                    local comp = self:get_adaptive_compensation(player_id)
                    if not comp then
                        return backtrack_ticks + math.ceil(self:get_one_way_ticks())
                    end
                    
                    
                    local total = backtrack_ticks + comp.compensation_ticks
                    
                    return total, comp.stability_factor, comp.is_stable
                end,
                
                
                adjust_confidence_for_compensation = function(self, base_confidence, total_compensation, player_id)
                    local comp = self:get_adaptive_compensation(player_id)
                    if not comp then return base_confidence end
                    
                    local adjusted = base_confidence
                    
                    
                    if total_compensation >= 25 then
                        adjusted = adjusted * 0.35
                    elseif total_compensation >= 20 then
                        adjusted = adjusted * 0.45
                    elseif total_compensation >= 16 then
                        adjusted = adjusted * 0.55
                    elseif total_compensation >= 12 then
                        adjusted = adjusted * 0.68
                    elseif total_compensation >= 8 then
                        adjusted = adjusted * 0.82
                    elseif total_compensation >= 5 then
                        adjusted = adjusted * 0.92
                    end
                    
                    
                    adjusted = adjusted * comp.stability_factor
                    
                    
                    if comp.jitter_ticks > 4 then
                        adjusted = adjusted * 0.75
                    elseif comp.jitter_ticks > 2 then
                        adjusted = adjusted * 0.88
                    end
                    
                    return func.fclamp(adjusted, 0.15, 0.85)
                end,
                
                
                cleanup = function(self)
                    if not self.ping_history then return end
                    
                    local now = globals.realtime()
                    local to_remove = {}
                    
                    for player_id, data in pairs(self.ping_history) do
                        if now - data.last_update > 30 then
                            table.insert(to_remove, player_id)
                        end
                    end
                    
                    for _, player_id in ipairs(to_remove) do
                        self.ping_history[player_id] = nil
                    end
                end,
            },
        },
                


    get_current_preset = function(self)
        local me = entity.get_local_player()
        if not me then return self.presets.rifle end
        
        local weapon = entity.get_player_weapon(me)
        if not weapon then return self.presets.rifle end
        
        local classname = entity.get_classname(weapon)
        if not classname then return self.presets.rifle end
        
        classname = classname:lower()
        
        
        if classname:find("deagle") or classname:find("revolver") then
            return self.presets.deagle
        elseif classname:find("elite") or classname:find("fiveseven") or 
               classname:find("glock") or classname:find("p250") or
               classname:find("tec9") or classname:find("cz75") or
               classname:find("usp") or classname:find("hkp2000") or
               classname:find("p2000") then
            return self.presets.pistol
        elseif classname:find("awp") then
            return self.presets.awp
        elseif classname:find("ssg08") or classname:find("scout") then
            return self.presets.scout
        elseif classname:find("scar20") or classname:find("g3sg1") then
            return self.presets.auto
        elseif classname:find("smg") or classname:find("mp") or 
               classname:find("mac10") or classname:find("ump") or
               classname:find("p90") or classname:find("bizon") then
            return self.presets.smg
        else
            return self.presets.rifle
        end
    end,
    

    
    get_confidence_boost = function(self, preset)
        if not preset then return 0 end
        
        
        if preset.name == "Pistol" then
            return 0.08
        elseif preset.name == "Deagle" then
            return 0.05
        end
        
        return 0
    end,
                
                
                get_preset = function(self, weapon_type)
                    return self.presets[weapon_type] or self.presets.unknown
                end,
                
                
                                apply_preset = function(self, player, preset, target_health)
                                    if not player or not preset then return end

                                    target_health = target_health or (entity.get_prop(player, "m_iHealth") or 100)

                                    
                                    local force_body_threshold = preset and tonumber(preset.force_body_hp_threshold) or nil

                                    
                                    self._force_body_active = self._force_body_active or {}

                                    
                                    if force_body_threshold and target_health <= force_body_threshold then
                                        
                                        pcall(function()
                                            apply_force_body(player, true)
                                        end)

                                        
                                        if not self._force_body_active[player] then
                                            local function on_player_death(e)
                                                local victim = client.userid_to_entindex(e.userid)
                                                if victim == player then
                                                    pcall(function() apply_force_body(player, false) end)
                                                    client.unset_event_callback("player_death", on_player_death)
                                                    self._force_body_active[player] = nil
                                                end
                                            end
                                            self._force_body_active[player] = true
                                            client.set_event_callback("player_death", on_player_death)
                                        end
                                    else
                                        
                                        if preset and preset.prefer_body == true then
                                            pcall(function()
                                                local ref = ui.reference("RAGE", "Aimbot", "Force body aim")
                                                if ref then ui.set(ref, true) end
                                            end)
                                        end
                                    end

                                    if preset.force_safe_point then
                                        pcall(function()
                                            local ref = ui.reference("RAGE", "Aimbot", "Force safe point")
                                            if ref then ui.set(ref, true) end
                                        end)
                                    end

                                    
                                    if preset.min_damage_override then
                                        
                                        local md_val = preset.min_damage_override
                                        if type(md_val) == "string" then md_val = tonumber(md_val) end

                                        if type(md_val) == "number" then
                                            
                                            pcall(function()
                                                local ov_ref = ui.reference("RAGE", "aimbot", "minimum damage override")
                                                if ov_ref then ui.set(ov_ref, true) end

                                                local dmg_ref = ui.reference("RAGE", "aimbot", "minimum damage")
                                                if dmg_ref then ui.set(dmg_ref, md_val) end
                                            end)
                                        end
                                    end    
                end,
                
                
                get_multipoint_scale = function(self, preset, hitbox_name)
                    
                    if type(preset) ~= "table" or type(preset.multipoint) ~= "table" then
                        return 0.65
                    end

                    
                    if not hitbox_name or type(hitbox_name) ~= "string" then
                        return 0.65
                    end

                    local value = preset.multipoint[hitbox_name] or preset.multipoint["body"] or 0.65
                    value = tonumber(value) or 0.65

                    return value
                end,
                
                
                get_aggression = function(self, preset)
                    if not preset then return 0.75 end
                    return preset.resolver_aggression or 0.75
                end,
                
            },
body_yaw_resolver = {
    players = {},
    
    init_player = function(self, player_id)
        if not self.players[player_id] then
            self.players[player_id] = {
                
                body_samples = {},              
                desync_samples = {},            
                side_body_correlation = {},     
                
                
                body_pattern = "unknown",
                body_pattern_confidence = 0.5,
                
                
                detected_mode = "unknown",
                mode_confidence = 0.5,
                
                
                avg_body_yaw = 0,
                body_yaw_range = {min = 0, max = 0},
                body_yaw_variance = 0,
                
                
                last_body_change = 0,
                body_change_intervals = {},     
                avg_change_interval = 0,
                
                
                successful_body_predictions = {}, 
                failed_body_predictions = {},     
                body_offset_weights = {},
                
                
                consecutive_same_body = 0,
                last_body_direction = 0,
                
                
                bruteforce_body_stage = 0,
                bruteforce_body_offsets = {60, -60, 58, -58, 50, -50, 45, -45, 40, -40, 35, -35, 30, -30},
                
                
                body_hit_count = 0,
                body_miss_count = 0,
                last_update = 0,
                
                
                sample_max_age = 5.5,
                cleanup_interval = 0.6,
                last_cleanup = 0,
            }
        end
        return self.players[player_id]
    end,
    
    
    sample = function(self, player, body_yaw, eye_yaw, side)
        local player_id = tostring(player)
        local data = self:init_player(player_id)
        local now = globals.realtime()
        local tick = globals.tickcount()
        
        
        if now - data.last_cleanup > data.cleanup_interval then
            self:cleanup_stale_samples(player_id, now)
            data.last_cleanup = now
        end


        local desync = func.aa_clamp(body_yaw - eye_yaw)
        
        
        table.insert(data.body_samples, {
            value = body_yaw,
            desync = desync,
            eye_yaw = eye_yaw,
            side = side,
            time = now,
            tick = tick,
        })
        
        table.insert(data.desync_samples, {
            value = desync,
            side = side,
            time = now,
        })
        
        
        if not data.side_body_correlation[side] then
            data.side_body_correlation[side] = {
                samples = {},
                avg = 0,
                variance = 0,
            }
        end
        
        local side_data = data.side_body_correlation[side]
        table.insert(side_data.samples, {
            body = body_yaw,
            desync = desync,
            time = now,
        })
        
        
        while #side_data.samples > 30 do
            table.remove(side_data.samples, 1)
        end
        
        
        if #side_data.samples >= 2 then
            local sum = 0
            for _, s in ipairs(side_data.samples) do
                sum = sum + s.desync
            end
            side_data.avg = sum / #side_data.samples
            
            local var_sum = 0
            for _, s in ipairs(side_data.samples) do
                var_sum = var_sum + (s.desync - side_data.avg)^2
            end
            side_data.variance = var_sum / #side_data.samples
        end
        
        
        local body_direction = desync > 0 and 1 or -1
        if body_direction ~= data.last_body_direction and data.last_body_direction ~= 0 then
            if data.last_body_change > 0 then
                local interval = now - data.last_body_change
                table.insert(data.body_change_intervals, interval)
                while #data.body_change_intervals > 25 do
                    table.remove(data.body_change_intervals, 1)
                end
            end
            data.last_body_change = now
            data.consecutive_same_body = 0
        else
            data.consecutive_same_body = data.consecutive_same_body + 1
        end
        data.last_body_direction = body_direction
        
        
        if #data.body_change_intervals >= 2 then
            local int_sum = 0
            for _, int in ipairs(data.body_change_intervals) do
                int_sum = int_sum + int
            end
            data.avg_change_interval = int_sum / #data.body_change_intervals
        end
        
        data.last_update = now
        
        
        while #data.body_samples > 65 do table.remove(data.body_samples, 1) end
        while #data.desync_samples > 65 do table.remove(data.desync_samples, 1) end
    end,
    
    
    cleanup_stale_samples = function(self, player_id, now)
        local data = self.players[player_id]
        if not data then return end
        
        local max_age = data.sample_max_age or 5.5
        local cutoff_time = now - max_age
        
        
        local i = 1
        while i <= #data.body_samples do
            if data.body_samples[i].time < cutoff_time then
                table.remove(data.body_samples, i)
            else
                i = i + 1
            end
        end
        
        
        i = 1
        while i <= #data.desync_samples do
            if data.desync_samples[i].time < cutoff_time then
                table.remove(data.desync_samples, i)
            else
                i = i + 1
            end
        end
        
        
        for side, side_data in pairs(data.side_body_correlation) do
            i = 1
            while i <= #side_data.samples do
                if side_data.samples[i].time < cutoff_time then
                    table.remove(side_data.samples, i)
                else
                    i = i + 1
                end
            end
        end
        
        
        while #data.successful_body_predictions > 45 do
            table.remove(data.successful_body_predictions, 1)
        end
        while #data.failed_body_predictions > 30 do
            table.remove(data.failed_body_predictions, 1)
        end
    end,
                
                
                analyze_mode = function(self, player)
                    local player_id = tostring(player)
                    local data = self.players[player_id]
                    if not data or #data.desync_samples < 4 then
                        return "unknown", 0.4
                    end
                    
                    local samples = data.desync_samples
                    local n = #samples
                    local now = globals.realtime()
                    
                    
                    local values = {}
                    local sides = {}
                    for i = math.max(1, n - 20), n do
                        table.insert(values, samples[i].value)
                        table.insert(sides, samples[i].side)
                    end
                    
                    if #values < 4 then return "unknown", 0.4 end
                    
                    
                    local sum, min_v, max_v = 0, values[1], values[1]
                    for _, v in ipairs(values) do
                        sum = sum + v
                        min_v = math.min(min_v, v)
                        max_v = math.max(max_v, v)
                    end
                    local mean = sum / #values
                    local range = max_v - min_v
                    
                    data.avg_body_yaw = mean
                    data.body_yaw_range = {min = min_v, max = max_v}
                    
                    
                    local var_sum = 0
                    for _, v in ipairs(values) do
                        var_sum = var_sum + (v - mean)^2
                    end
                    local variance = var_sum / #values
                    local std_dev = math.sqrt(variance)
                    data.body_yaw_variance = variance
                    
                    
                    local cv = std_dev / math.max(1, math.abs(mean))
                    
                    
                    local positive_count = 0
                    local negative_count = 0
                    for _, v in ipairs(values) do
                        if v > 10 then positive_count = positive_count + 1
                        elseif v < -10 then negative_count = negative_count + 1 end
                    end
                    
                    
                    local direction_changes = 0
                    local last_sign = nil
                    for _, v in ipairs(values) do
                        local sign = v > 5 and 1 or (v < -5 and -1 or 0)
                        if sign ~= 0 and last_sign and sign ~= last_sign then
                            direction_changes = direction_changes + 1
                        end
                        if sign ~= 0 then last_sign = sign end
                    end
                    local change_rate = direction_changes / math.max(1, #values - 1)
                    
                    
                    local side_correlated = false
                    local correlation_strength = 0
                    
                    if data.side_body_correlation[0] and data.side_body_correlation[1] then
                        local side0 = data.side_body_correlation[0]
                        local side1 = data.side_body_correlation[1]
                        
                        if #side0.samples >= 3 and #side1.samples >= 3 then
                            local side0_avg = side0.avg
                            local side1_avg = side1.avg
                            
                            
                            local side_diff = math.abs(side0_avg - side1_avg)
                            if side_diff > 40 then
                                side_correlated = true
                                correlation_strength = math.min(1.0, side_diff / 100)
                            end
                            
                            
                            
                            
                            
                            if (side0_avg > 20 and side1_avg < -20) or (side0_avg < -20 and side1_avg > 20) then
                                
                                data.body_follows_side = false
                                data.body_opposes_side = true
                            elseif (side0_avg < -20 and side1_avg < -20) or (side0_avg > 20 and side1_avg > 20) then
                                
                                data.body_follows_side = false
                                data.body_opposes_side = false
                            else
                                
                                data.body_follows_side = true
                                data.body_opposes_side = false
                            end
                        end
                    end
                    
                    
                    local mode_scores = {
                        static = 0,
                        jitter = 0,
                        opposite = 0,
                        synced = 0,
                        random = 0,
                    }
                    
                    
                    if range < 25 and std_dev < 12 then
                        mode_scores.static = 0.85 - range * 0.01
                        if std_dev < 6 then
                            mode_scores.static = mode_scores.static + 0.10
                        end
                    elseif range < 40 and std_dev < 18 and change_rate < 0.15 then
                        mode_scores.static = 0.65 - range * 0.008
                    end
                    
                    
                    if change_rate > 0.35 and range > 50 then
                        mode_scores.jitter = 0.55 + change_rate * 0.25
                        if side_correlated and data.body_opposes_side then
                            mode_scores.jitter = mode_scores.jitter + 0.20
                        end
                        if math.abs(positive_count - negative_count) < #values * 0.3 then
                            mode_scores.jitter = mode_scores.jitter + 0.10
                        end
                    end
                    
                    
                    if side_correlated and data.body_opposes_side then
                        mode_scores.opposite = 0.60 + correlation_strength * 0.25
                        if change_rate < 0.30 then
                            mode_scores.opposite = mode_scores.opposite + 0.10
                        end
                    end
                    
                    
                    if side_correlated and data.body_follows_side then
                        mode_scores.synced = 0.55 + correlation_strength * 0.20
                    end
                    
                    
                    if cv > 0.45 and range > 60 and not side_correlated then
                        mode_scores.random = 0.50 + cv * 0.15
                        if change_rate > 0.20 and change_rate < 0.60 then
                            mode_scores.random = mode_scores.random + 0.10
                        end
                    end
                    
                    
                    local best_mode = "unknown"
                    local best_score = 0.35
                    
                    for mode, score in pairs(mode_scores) do
                        if score > best_score then
                            best_score = score
                            best_mode = mode
                        end
                    end
                    
                    
                    if #values < 8 then
                        best_score = best_score * 0.75
                    elseif #values < 12 then
                        best_score = best_score * 0.88
                    elseif #values >= 18 then
                        best_score = math.min(0.92, best_score * 1.05)
                    end
                    
                    data.detected_mode = best_mode
                    data.mode_confidence = func.fclamp(best_score, 0.30, 0.92)
                    
                    return best_mode, data.mode_confidence
                end,
                
                
                predict = function(self, player, predicted_side)
                    local player_id = tostring(player)
                    local data = self.players[player_id]
                    if not data then return 0, 0.4 end
                    
                    local now = globals.realtime()
                    
                    
                    local mode, mode_conf = self:analyze_mode(player)
                    
                    local predicted_body = 0
                    local confidence = 0.45
                    local method = "default"
                    
                    
                    if data.body_miss_count >= 2 and data.body_hit_count < data.body_miss_count then
                        local stage = data.bruteforce_body_stage
                        predicted_body = data.bruteforce_body_offsets[(stage % #data.bruteforce_body_offsets) + 1]
                        
                        
                        if predicted_side == 1 and predicted_body < 0 then
                            predicted_body = -predicted_body
                        elseif predicted_side == 0 and predicted_body > 0 then
                            predicted_body = -predicted_body
                        end
                        
                        data.bruteforce_body_stage = stage + 1
                        confidence = 0.42 - data.bruteforce_body_stage * 0.02
                        method = "bruteforce"
                        
                        return predicted_body, func.fclamp(confidence, 0.25, 0.55), method
                    end
                    
                    
                    if mode == "static" then
                        
                        predicted_body = data.avg_body_yaw
                        
                        
                        if predicted_side == 1 and predicted_body < 20 then
                            predicted_body = math.max(predicted_body, 45)
                        elseif predicted_side == 0 and predicted_body > -20 then
                            predicted_body = math.min(predicted_body, -45)
                        end
                        
                        confidence = mode_conf * 0.95
                        method = "static"
                        
                    elseif mode == "jitter" then
                        
                        local side_data = data.side_body_correlation[predicted_side]
                        
                        if side_data and #side_data.samples >= 2 then
                            predicted_body = side_data.avg
                            confidence = mode_conf * 0.88
                        else
                            
                            predicted_body = predicted_side == 1 and 58 or -58
                            confidence = mode_conf * 0.72
                        end
                        method = "jitter"
                        
                    elseif mode == "opposite" then
                        
                        local side_data = data.side_body_correlation[predicted_side]
                        
                        if side_data and #side_data.samples >= 2 then
                            predicted_body = side_data.avg
                            confidence = mode_conf * 0.90
                        else
                            
                            predicted_body = predicted_side == 1 and 58 or -58
                            confidence = mode_conf * 0.75
                        end
                        method = "opposite"
                        
                    elseif mode == "synced" then
                        
                        local side_data = data.side_body_correlation[predicted_side]
                        
                        if side_data and #side_data.samples >= 2 then
                            predicted_body = side_data.avg
                            confidence = mode_conf * 0.85
                        else
                            predicted_body = predicted_side == 1 and 58 or -58
                            confidence = mode_conf * 0.70
                        end
                        method = "synced"
                        
                    elseif mode == "random" then
                        
                        local learned_body, learned_conf = self:get_learned_body(player, predicted_side)
                        
                        if learned_conf > 0.40 then
                            predicted_body = learned_body
                            confidence = learned_conf * 0.75
                            method = "learned_random"
                        else
                            
                            local tick = globals.tickcount()
                            local offsets = {58, 50, 42, 55}
                            local idx = (tick % (#offsets * 4)) / 4 + 1
                            idx = math.floor(idx)
                            idx = math.max(1, math.min(#offsets, idx))
                            
                            predicted_body = predicted_side == 1 and offsets[idx] or -offsets[idx]
                            confidence = 0.38
                            method = "random_cycle"
                        end
                        
                    else
                        
                        local learned_body, learned_conf = self:get_learned_body(player, predicted_side)
                        
                        if learned_conf > 0.35 then
                            predicted_body = learned_body
                            confidence = learned_conf * 0.70
                            method = "learned_default"
                        else
                            predicted_body = predicted_side == 1 and 58 or -58
                            confidence = 0.45
                            method = "default"
                        end
                    end
                    
                    
                    if mode == "jitter" and data.avg_change_interval > 0 then
                        local time_since_change = now - data.last_body_change
                        local phase = time_since_change / data.avg_change_interval
                        
                        
                        if phase > 0.75 and phase < 1.25 then
                            confidence = confidence * 0.85
                        end
                    end
                    
                    
                    if predicted_side == 1 and predicted_body < 0 then
                        
                        if mode ~= "opposite" and mode ~= "synced" then
                            predicted_body = math.abs(predicted_body)
                        end
                    elseif predicted_side == 0 and predicted_body > 0 then
                        if mode ~= "opposite" and mode ~= "synced" then
                            predicted_body = -math.abs(predicted_body)
                        end
                    end
                    
                    
                    predicted_body = math.max(-60, math.min(60, math.floor(predicted_body + 0.5)))
                    
                    
                    if math.abs(predicted_body) < 30 then
                        predicted_body = predicted_side == 1 and 45 or -45
                    end
                    
                    return predicted_body, func.fclamp(confidence, 0.25, 0.88), method
                end,
                
                
                get_learned_body = function(self, player, side)
                    local player_id = tostring(player)
                    local data = self.players[player_id]
                    if not data then return 0, 0.25 end
                    
                    local successful = data.successful_body_predictions or {}
                    local weights = data.body_offset_weights or {}
                    
                    
                    local side_successes = {}
                    for _, entry in ipairs(successful) do
                        if entry.side == side then
                            table.insert(side_successes, entry.body)
                        end
                    end
                    
                    if #side_successes < 1 then
                        return side == 1 and 58 or -58, 0.25
                    end
                    
                    
                    local weighted_sum = 0
                    local weight_total = 0
                    
                    for i, body in ipairs(side_successes) do
                        local recency_weight = (i / #side_successes)^1.5
                        weighted_sum = weighted_sum + body * recency_weight
                        weight_total = weight_total + recency_weight
                    end
                    
                    if weight_total < 0.01 then
                        return side == 1 and 58 or -58, 0.25
                    end
                    
                    local learned_body = weighted_sum / weight_total
                    
                    
                    local confidence = 0.35 + math.min(0.35, #side_successes * 0.05)
                    
                    
                    local variance = 0
                    for _, body in ipairs(side_successes) do
                        variance = variance + (body - learned_body)^2
                    end
                    variance = variance / #side_successes
                    
                    local std_dev = math.sqrt(variance)
                    if std_dev < 10 then
                        confidence = confidence + 0.12
                    elseif std_dev > 25 then
                        confidence = confidence * 0.80
                    end
                    
                    return learned_body, func.fclamp(confidence, 0.25, 0.70)
                end,
                
                
                record_result = function(self, player, body_used, side, hit)
                    local player_id = tostring(player)
                    local data = self.players[player_id]
                    if not data then return end
                    
                    if hit then
                        data.body_hit_count = data.body_hit_count + 1
                        data.body_miss_count = math.max(0, data.body_miss_count - 1)
                        data.bruteforce_body_stage = 0
                        
                        table.insert(data.successful_body_predictions, {
                            body = body_used,
                            side = side,
                            time = globals.realtime(),
                        })
                        
                        
                        local bucket = math.floor(body_used / 5) * 5
                        data.body_offset_weights[bucket] = (data.body_offset_weights[bucket] or 0) + 0.15
                        
                        
                        for offset, weight in pairs(data.body_offset_weights) do
                            data.body_offset_weights[offset] = weight * 0.95
                        end
                        
                        while #data.successful_body_predictions > 25 do
                            table.remove(data.successful_body_predictions, 1)
                        end
                    else
                        data.body_miss_count = data.body_miss_count + 1
                        
                        table.insert(data.failed_body_predictions, {
                            body = body_used,
                            side = side,
                            time = globals.realtime(),
                        })
                        
                        
                        local bucket = math.floor(body_used / 5) * 5
                        data.body_offset_weights[bucket] = (data.body_offset_weights[bucket] or 0) - 0.10
                        
                        while #data.failed_body_predictions > 20 do
                            table.remove(data.failed_body_predictions, 1)
                        end
                    end
                end,
                
                
                cleanup = function(self)
                    local now = globals.realtime()
                    local players_to_remove = {}
                    
                    for player_id, data in pairs(self.players) do
                        
                        if now - data.last_update > 25.0 then
                            table.insert(players_to_remove, player_id)
                        end
                    end
                    
                    for _, player_id in ipairs(players_to_remove) do
                        self.players[player_id] = nil
                    end
                    
                    
                    if self.body_yaw_resolver then
                        self.body_yaw_resolver:cleanup()
                    end
                end,
            },
            
                        sample_yaw = function(self, player, yaw, body_yaw)
                            local player_id = tostring(player)
                            local data = self:init_player(player_id)
                            local now = globals.realtime()
                            local tick = globals.tickcount()
                            
                            
                            if now - data.last_cleanup > data.cleanup_interval then
                                self:cleanup_stale_samples(player_id, now)
                                data.last_cleanup = now
                            end
                            
                            
                            local vx, vy = entity.get_prop(player, "m_vecVelocity")
                            local speed = math.sqrt((vx or 0)^2 + (vy or 0)^2)
                            
                            
                            table.insert(data.yaw_samples, {
                                value = yaw,
                                time = now,
                                tick = tick,
                                speed = speed,
                            })
                            
                            
                            local detected_side = body_yaw > 0 and 1 or 0
                            
                            
                            if data.current_side ~= nil and data.current_side ~= detected_side then
                                local delay = data.switch_delay or 1
                                table.insert(data.delay_ticks, delay)
                                
                                
                                table.insert(data.delay_sequence, delay)
                                
                                table.insert(data.side_history, {
                                    side = detected_side,
                                    time = now,
                                    tick = tick,
                                    delay = delay,
                                })
                                
                                table.insert(data.switch_times, now)
                                
                                data.switch_delay = 0
                            else
                                data.switch_delay = (data.switch_delay or 0) + 1
                            end
                            
                            data.current_side = detected_side
                            
                            
                            table.insert(data.body_yaw_history, {
                                value = body_yaw,
                                time = now,
                                tick = tick,
                                side = detected_side,
                            })
                            
                            data.last_yaw = yaw
                            data.last_body = body_yaw
                            data.last_update = now
                            
                            
                            if self.body_yaw_resolver then
                                self.body_yaw_resolver:sample(player, body_yaw, yaw, detected_side)
                            end
                            
                            
                            data.cached_prediction = nil
                            
                            
                            
                            while #data.yaw_samples > 50 do table.remove(data.yaw_samples, 1) end
                            while #data.side_history > 30 do table.remove(data.side_history, 1) end
                            while #data.body_yaw_history > 35 do table.remove(data.body_yaw_history, 1) end
                            while #data.delay_ticks > 45 do table.remove(data.delay_ticks, 1) end
                            while #data.delay_sequence > 35 do table.remove(data.delay_sequence, 1) end
                            while #data.switch_times > 30 do table.remove(data.switch_times, 1) end
                        end,
                        
cleanup_stale_samples = function(self, player_id, now)
    local data = self.players[player_id]
    if not data then return end
    
    local max_age = data.sample_max_age or 4.5
    local cutoff_time = now - max_age
    
    
    local i = 1
    while i <= #data.yaw_samples do
        if data.yaw_samples[i].time < cutoff_time then
            table.remove(data.yaw_samples, i)
        else
            i = i + 1
        end
    end
    
    
    i = 1
    while i <= #data.side_history do
        if data.side_history[i].time and data.side_history[i].time < cutoff_time then
            table.remove(data.side_history, i)
        else
            i = i + 1
        end
    end
    
    
    i = 1
    while i <= #data.body_yaw_history do
        if data.body_yaw_history[i].time and data.body_yaw_history[i].time < cutoff_time then
            table.remove(data.body_yaw_history, i)
        else
            i = i + 1
        end
    end
    
    
    i = 1
    while i <= #data.switch_times do
        if data.switch_times[i] < cutoff_time then
            table.remove(data.switch_times, i)
        else
            i = i + 1
        end
    end
    
    
    
    local max_delays = math.max(10, #data.side_history * 2)
    while #data.delay_ticks > max_delays do
        table.remove(data.delay_ticks, 1)
    end
    while #data.delay_sequence > max_delays do
        table.remove(data.delay_sequence, 1)
    end
end,

            
            analyze_side_pattern = function(self, player)
                    local player_id = tostring(player)
                    local data = self.players[player_id]
                    if not data then
                        return "unknown", 0.5
                    end
                    
                    
                    if not data.delay_ticks then data.delay_ticks = {} end
                    if not data.delay_sequence then data.delay_sequence = {} end
                    if not data.side_switch_times then data.side_switch_times = {} end
                    
                    local delays = data.delay_ticks
                    local n = #delays
                    local now = globals.realtime()
                    
                    
                    if n < 1 then
                        local side, conf = self:detect_side_early(player)
                        data.side_pattern = "direct_observation"
                        data.side_pattern_confidence = conf
                        return "direct_observation", conf
                    end
                    
                    
                    if n < 3 then
                        local side, conf = self:detect_side_early(player)
                        
                        
                        local first_delay = delays[1] or 4
                        if first_delay >= 1 and first_delay <= 22 then
                            conf = math.min(conf + 0.08, 0.65)
                        end
                        
                        data.side_pattern = "learning"
                        data.side_pattern_confidence = conf
                        return "learning", conf
                    end
                    
                    
                    local sum = 0
                    local min_d, max_d = 999, 0
                    local delay_freq = {}
                    local weighted_sum = 0
                    local weight_total = 0
                    
                    
                    for i, d in ipairs(delays) do
                        local recency_weight = (i / n)  
                        sum = sum + d
                        min_d = math.min(min_d, d)
                        max_d = math.max(max_d, d)
                        delay_freq[d] = (delay_freq[d] or 0) + 1
                        weighted_sum = weighted_sum + d * recency_weight
                        weight_total = weight_total + recency_weight
                    end
                    
                    local avg_delay = sum / n
                    local weighted_avg = weight_total > 0 and (weighted_sum / weight_total) or avg_delay
                    
                    
                    local var_sum = 0
                    for _, d in ipairs(delays) do
                        var_sum = var_sum + (d - avg_delay)^2
                    end
                    local variance = n > 1 and (var_sum / (n - 1)) or 0
                    local std_dev = math.sqrt(variance)
                    
                    
                    local mode_delay = avg_delay
                    local mode_count = 0
                    local second_mode = nil
                    local second_count = 0
                    
                    for delay, count in pairs(delay_freq) do
                        if count > mode_count then
                            mode_delay = delay
                            mode_count = count
                        elseif count > second_count then
                            second_mode = delay
                            second_count = count
                        end
                    end
                    
                    local mode_ratio = mode_count / n
                    local bimodal = second_mode and second_count >= (n * 0.25)
                    
                    
                    local clusters = {}
                    local cluster_threshold = 4
                    
                    local sorted_delays = {}
                    for _, d in ipairs(delays) do table.insert(sorted_delays, d) end
                    table.sort(sorted_delays)
                    
                    local current_cluster = {sorted_delays[1]}
                    for i = 2, #sorted_delays do
                        if sorted_delays[i] - sorted_delays[i-1] <= cluster_threshold then
                            table.insert(current_cluster, sorted_delays[i])
                        else
                            if #current_cluster >= 2 then
                                local cluster_sum = 0
                                for _, v in ipairs(current_cluster) do cluster_sum = cluster_sum + v end
                                table.insert(clusters, {
                                    center = cluster_sum / #current_cluster,
                                    count = #current_cluster,
                                    ratio = #current_cluster / n
                                })
                            end
                            current_cluster = {sorted_delays[i]}
                        end
                    end
                    
                    if #current_cluster >= 2 then
                        local cluster_sum = 0
                        for _, v in ipairs(current_cluster) do cluster_sum = cluster_sum + v end
                        table.insert(clusters, {
                            center = cluster_sum / #current_cluster,
                            count = #current_cluster,
                            ratio = #current_cluster / n
                        })
                    end
                    
                    
                    table.sort(clusters, function(a, b) return a.count > b.count end)
                    
                    local has_dominant_cluster = #clusters >= 1 and clusters[1].ratio >= 0.35
                    local has_two_clusters = #clusters >= 2 and clusters[1].ratio >= 0.30 and clusters[2].ratio >= 0.20
                    
                    
                    local is_sequence = false
                    local sequence_length = 0
                    local sequence_confidence = 0
                    
                    if n >= 6 and data.delay_sequence and #data.delay_sequence >= 4 then
                        local seq = data.delay_sequence
                        
                        
                        for pattern_len = 2, math.min(6, math.floor(#seq / 2)) do
                            local matches = 0
                            local checks = 0
                            for i = 1, #seq - pattern_len do
                                if math.abs(seq[i] - seq[i + pattern_len]) <= 2 then
                                    matches = matches + 1
                                end
                                checks = checks + 1
                            end
                            if checks > 0 and matches / checks > 0.6 then
                                is_sequence = true
                                sequence_length = pattern_len
                                sequence_confidence = matches / checks
                                break
                            end
                        end
                    end
                    
                    
                    local autocorr = 0
                    if n >= 6 then
                        local mean = avg_delay
                        local var_denom = 0
                        for _, d in ipairs(delays) do
                            var_denom = var_denom + (d - mean)^2
                        end
                        
                        if var_denom > 0.1 then
                            local cov = 0
                            for i = 1, n - 1 do
                                cov = cov + (delays[i] - mean) * (delays[i + 1] - mean)
                            end
                            autocorr = cov / var_denom
                        end
                    end
                    
                    
                    local trend = 0
                    if n >= 5 then
                        local first_half_avg = 0
                        local second_half_avg = 0
                        local half = math.floor(n / 2)
                        
                        for i = 1, half do
                            first_half_avg = first_half_avg + delays[i]
                        end
                        first_half_avg = first_half_avg / half
                        
                        for i = half + 1, n do
                            second_half_avg = second_half_avg + delays[i]
                        end
                        second_half_avg = second_half_avg / (n - half)
                        
                        trend = (second_half_avg - first_half_avg) / math.max(1, avg_delay)
                    end
                    
                    
                    local side_consistency = 0
                    local side_predictable = false
                    
                    if data.side_history and #data.side_history >= 6 then
                        local history = data.side_history
                        local recent_count = math.min(12, #history)
                        
                        local alternation_count = 0
                        local same_count = 0
                        
                        for i = #history, math.max(2, #history - recent_count + 1), -1 do
                            if history[i].side ~= history[i-1].side then
                                alternation_count = alternation_count + 1
                            else
                                same_count = same_count + 1
                            end
                        end
                        
                        local total_transitions = alternation_count + same_count
                        if total_transitions >= 4 then
                            
                            local alt_ratio = alternation_count / total_transitions
                            if alt_ratio > 0.7 or alt_ratio < 0.3 then
                                side_predictable = true
                                side_consistency = math.max(alt_ratio, 1 - alt_ratio)
                            end
                        end
                    end
                    
                    
                    data.detected_delay = weighted_avg
                    data.delay_variance = std_dev
                    data.mode_delay = mode_delay
                    data.mode_ratio = mode_ratio
                    data.delay_autocorr = autocorr
                    data.delay_trend = trend
                    data.delay_range = max_d - min_d
                    data.side_consistency = side_consistency
                    data.side_predictable = side_predictable
                    data.delay_clusters = clusters
                    
                    
                    local cv = std_dev / math.max(1, avg_delay)
                    local range = max_d - min_d
                    
                    local pattern, confidence
                    local pattern_scores = {
                        fixed_delay = 0,
                        sequence = 0,
                        tight_random = 0,
                        variable_delay = 0,
                        clustered = 0,
                        reactive = 0,
                        chaotic = 0,
                    }
                    
                    
                    if cv < 0.12 and range <= 2 then
                        pattern_scores.fixed_delay = 0.92
                    elseif cv < 0.18 and range <= 3 then
                        pattern_scores.fixed_delay = 0.82
                    elseif cv < 0.25 and range <= 4 and mode_ratio > 0.50 then
                        pattern_scores.fixed_delay = 0.70
                    elseif cv < 0.30 and range <= 5 and mode_ratio > 0.45 then
                        pattern_scores.fixed_delay = 0.58
                    end
                    
                    
                    if is_sequence and sequence_confidence > 0.65 then
                        pattern_scores.sequence = 0.75 + sequence_confidence * 0.15
                    end
                    
                    
                    if cv >= 0.15 and cv < 0.40 and range <= 6 then
                        pattern_scores.tight_random = 0.65 - cv * 0.3
                        if mode_ratio > 0.35 then
                            pattern_scores.tight_random = pattern_scores.tight_random + 0.08
                        end
                    end
                    
                    
                    if cv >= 0.25 and cv < 0.55 and range <= 10 then
                        pattern_scores.variable_delay = 0.55 - (cv - 0.25) * 0.5
                        if bimodal then
                            pattern_scores.variable_delay = pattern_scores.variable_delay + 0.12
                        end
                    end
                    
                    
                    if has_dominant_cluster and cv >= 0.35 then
                        pattern_scores.clustered = 0.55 + clusters[1].ratio * 0.25
                        if has_two_clusters then
                            pattern_scores.clustered = pattern_scores.clustered + 0.12
                        end
                        if side_predictable then
                            pattern_scores.clustered = pattern_scores.clustered + 0.10
                        end
                    end
                    
                    
                    if math.abs(trend) > 0.25 or (n >= 8 and autocorr < -0.3) then
                        pattern_scores.reactive = 0.50 + math.abs(trend) * 0.2 + math.max(0, -autocorr * 0.2)
                        
                        
                        if n >= 4 then
                            local recent_variance = 0
                            local recent_count = math.min(6, n)
                            local recent_mean = 0
                            
                            for i = n - recent_count + 1, n do
                                recent_mean = recent_mean + delays[i]
                            end
                            recent_mean = recent_mean / recent_count
                            
                            for i = n - recent_count + 1, n do
                                recent_variance = recent_variance + (delays[i] - recent_mean)^2
                            end
                            recent_variance = recent_variance / recent_count
                            
                            
                            if recent_variance > 100 then
                                pattern_scores.reactive = pattern_scores.reactive + 0.15
                            elseif recent_variance > 50 then
                                pattern_scores.reactive = pattern_scores.reactive + 0.08
                            end
                        end
                    end
                    
                    
                    local truly_chaotic = cv >= 0.55 and range >= 12 and not has_dominant_cluster and not side_predictable
                    if truly_chaotic then
                        pattern_scores.chaotic = 0.45 + math.min(0.30, (cv - 0.55) * 0.5)
                    elseif cv >= 0.45 and range >= 10 and not has_dominant_cluster and not side_predictable then
                        pattern_scores.chaotic = 0.35 + math.min(0.20, (cv - 0.45) * 0.4)
                    end
                    
                    
                    pattern = "unknown"
                    confidence = 0.35
                    
                    for p, score in pairs(pattern_scores) do
                        if score > confidence then
                            pattern = p
                            confidence = score
                        end
                    end
                    
                    
                    if pattern == "chaotic" and side_predictable and side_consistency > 0.55 then
                        pattern = "side_predictable"
                        confidence = side_consistency
                    end
                    
                    
                    if n < 5 then
                        confidence = confidence * 0.78
                    elseif n < 8 then
                        confidence = confidence * 0.88
                    elseif n < 12 then
                        confidence = confidence * 0.95
                    elseif n >= 18 then
                        confidence = math.min(0.92, confidence * 1.06)
                    end
                    
                    
                    local sorted_scores = {}
                    for _, score in pairs(pattern_scores) do
                        if score > 0.20 then
                            table.insert(sorted_scores, score)
                        end
                    end
                    table.sort(sorted_scores, function(a, b) return a > b end)
                    
                    if #sorted_scores >= 2 and sorted_scores[1] - sorted_scores[2] < 0.12 then
                        confidence = confidence * 0.88
                    end
                    
                    
                    data.side_pattern = pattern
                    data.side_pattern_confidence = func.fclamp(confidence, 0.25, 0.92)
                    data.pattern_scores = pattern_scores
                    
                    
                    if not data.avg_side_interval or data.avg_side_interval <= 0 then
                        data.avg_side_interval = avg_delay * globals.tickinterval()
                    end
                    
                    
                    if pattern == "reactive" then
                        
                        
                        
                        local consec_misses = data.consecutive_misses or 0
                        
                        
                        if consec_misses >= 1 then
                            
                            if data.last_predicted_side ~= nil then
                                data.force_flip_side = true
                                data.flip_target_side = 1 - data.last_predicted_side
                            else
                                data.force_flip_side = true
                                data.flip_target_side = 1 - (data.current_side or 0)
                            end
                        end
                        
                        
                        if variance > 40 then
                            data.ultra_reactive = true
                            data.fast_switch_multiplier = 0.20  
                            
                            
                            if consec_misses >= 2 then
                                
                                if math.random() < 0.35 then
                                    data.flip_target_side = math.random(0, 1)
                                end
                            end
                        elseif variance > 25 then
                            data.fast_switch_multiplier = 0.30
                        else
                            data.fast_switch_multiplier = 0.40
                        end
                        
                        
                        data.detected_delay = math.max(1, weighted_avg * data.fast_switch_multiplier)
                        
                        
                        data.needs_fast_switching = true
                        
                        
                        data.reactive_variance = variance
                        
                    else
                        data.needs_fast_switching = false
                        data.fast_switch_multiplier = 1.0
                        data.force_flip_side = false
                        data.ultra_reactive = false
                    end
                end,

                           detect_xway_pattern = function(self, player)
                                local player_id = tostring(player)
                                local data = self.players[player_id]
                                if not data or #data.yaw_samples < 10 then
                                    return nil, 0.3
                                end
                                
                                local now = globals.realtime()
                                
                                
                                if not data.xway_tracking then
                                    data.xway_tracking = {
                                        detected_ways = 0,
                                        way_angles = {},
                                        current_way_index = 0,
                                        cycle_start_time = 0,
                                        cycle_duration = 0,
                                        avg_way_duration = 0,
                                        confidence = 0,
                                        last_detection = 0,
                                        angle_clusters = {},
                                        rotation_direction = 0,
                                        base_yaw = 0,
                                        transition_history = {},
                                        way_hit_counts = {},
                                        prediction_accuracy = {correct = 0, total = 0},
                                        last_predicted_index = 0,
                                        pattern_stability = 0,
                                        consecutive_matches = 0,
                                        last_way_change_time = 0,
                                    }
                                end
                                
                                local xway = data.xway_tracking
                                
                                
                                local recent_samples = {}
                                local n = #data.yaw_samples
                                local sample_window = math.min(30, n)
                                
                                for i = math.max(1, n - sample_window + 1), n do
                                    if data.yaw_samples[i] then
                                        table.insert(recent_samples, {
                                            value = data.yaw_samples[i].value,
                                            time = data.yaw_samples[i].time or now,
                                            index = i
                                        })
                                    end
                                end
                                
                                if #recent_samples < 10 then return nil, 0.3 end
                                
                                
                                local function find_angle_clusters_dbscan(samples, eps, min_pts)
                                    eps = eps or 12
                                    min_pts = min_pts or 2
                                    
                                    local points = {}
                                    for _, s in ipairs(samples) do
                                        table.insert(points, {value = s.value, visited = false, cluster = 0})
                                    end
                                    
                                    local clusters = {}
                                    local cluster_id = 0
                                    
                                    local function get_neighbors(point_idx)
                                        local neighbors = {}
                                        local p = points[point_idx]
                                        for i, q in ipairs(points) do
                                            if i ~= point_idx then
                                                local dist = math.abs(func.aa_clamp(p.value - q.value))
                                                if dist <= eps then
                                                    table.insert(neighbors, i)
                                                end
                                            end
                                        end
                                        return neighbors
                                    end
                                    
                                    local function expand_cluster(point_idx, neighbors, c_id)
                                        points[point_idx].cluster = c_id
                                        
                                        local i = 1
                                        while i <= #neighbors do
                                            local n_idx = neighbors[i]
                                            if not points[n_idx].visited then
                                                points[n_idx].visited = true
                                                local n_neighbors = get_neighbors(n_idx)
                                                if #n_neighbors >= min_pts then
                                                    for _, nn in ipairs(n_neighbors) do
                                                        local found = false
                                                        for _, existing in ipairs(neighbors) do
                                                            if existing == nn then found = true break end
                                                        end
                                                        if not found then
                                                            table.insert(neighbors, nn)
                                                        end
                                                    end
                                                end
                                            end
                                            if points[n_idx].cluster == 0 then
                                                points[n_idx].cluster = c_id
                                            end
                                            i = i + 1
                                        end
                                    end
                                    
                                    for i, p in ipairs(points) do
                                        if not p.visited then
                                            p.visited = true
                                            local neighbors = get_neighbors(i)
                                            if #neighbors >= min_pts then
                                                cluster_id = cluster_id + 1
                                                expand_cluster(i, neighbors, cluster_id)
                                            end
                                        end
                                    end
                                    
                                    
                                    for c = 1, cluster_id do
                                        local members = {}
                                        for _, p in ipairs(points) do
                                            if p.cluster == c then
                                                table.insert(members, p.value)
                                            end
                                        end
                                        
                                        if #members >= min_pts then
                                            local sum = 0
                                            local min_v, max_v = members[1], members[1]
                                            for _, v in ipairs(members) do
                                                sum = sum + v
                                                min_v = math.min(min_v, v)
                                                max_v = math.max(max_v, v)
                                            end
                                            
                                            table.insert(clusters, {
                                                center = sum / #members,
                                                count = #members,
                                                spread = max_v - min_v,
                                                members = members,
                                                density = #members / math.max(1, max_v - min_v)
                                            })
                                        end
                                    end
                                    
                                    table.sort(clusters, function(a, b) return a.count > b.count end)
                                    return clusters
                                end
                                
                                local clusters = find_angle_clusters_dbscan(recent_samples, 15, 2)
                                xway.angle_clusters = clusters
                                
                                
                                local significant_clusters = {}
                                local total_samples = #recent_samples
                                
                                for _, c in ipairs(clusters) do
                                    if c.count >= math.max(2, total_samples * 0.08) then
                                        table.insert(significant_clusters, c)
                                    end
                                end
                                
                                local distinct_ways = #significant_clusters
                                
                                
                                if distinct_ways < 3 or distinct_ways > 8 then
                                    xway.confidence = 0.2
                                    return nil, 0.2
                                end
                                
                                xway.detected_ways = distinct_ways
                                
                                
                                
                                local angles = {}
                                for _, c in ipairs(significant_clusters) do
                                    table.insert(angles, c.center)
                                end
                                table.sort(angles)
                                
                                local angular_gaps = {}
                                for i = 2, #angles do
                                    local gap = func.aa_clamp(angles[i] - angles[i-1])
                                    table.insert(angular_gaps, math.abs(gap))
                                end
                                
                                if #angles >= 2 then
                                    local wrap_gap = 360 - (angles[#angles] - angles[1])
                                    if wrap_gap > 0 and wrap_gap < 180 then
                                        table.insert(angular_gaps, wrap_gap)
                                    end
                                end
                                
                                
                                local gap_uniformity = 0
                                if #angular_gaps >= 2 then
                                    local gap_sum = 0
                                    for _, g in ipairs(angular_gaps) do gap_sum = gap_sum + g end
                                    local gap_avg = gap_sum / #angular_gaps
                                    
                                    local gap_variance = 0
                                    for _, g in ipairs(angular_gaps) do
                                        gap_variance = gap_variance + (g - gap_avg)^2
                                    end
                                    gap_variance = gap_variance / #angular_gaps
                                    
                                    local gap_cv = math.sqrt(gap_variance) / math.max(1, gap_avg)
                                    gap_uniformity = math.max(0, 1 - gap_cv)
                                end
                                
                                
                                local transition_analysis = {
                                    clockwise = 0,
                                    counter_clockwise = 0,
                                    random_jumps = 0,
                                    sequential_transitions = {}
                                }
                                
                                if #recent_samples >= 6 then
                                    local last_cluster_idx = nil
                                    
                                    local function get_cluster_index(yaw)
                                        local best_idx = 1
                                        local min_dist = 999
                                        for i, angle in ipairs(angles) do
                                            local dist = math.abs(func.aa_clamp(yaw - angle))
                                            if dist < min_dist then
                                                min_dist = dist
                                                best_idx = i
                                            end
                                        end
                                        return min_dist < 20 and best_idx or nil
                                    end
                                    
                                    for _, sample in ipairs(recent_samples) do
                                        local curr_idx = get_cluster_index(sample.value)
                                        if curr_idx and last_cluster_idx and curr_idx ~= last_cluster_idx then
                                            local step = curr_idx - last_cluster_idx
                                            
                                            
                                            if math.abs(step) > #angles / 2 then
                                                if step > 0 then
                                                    step = step - #angles
                                                else
                                                    step = step + #angles
                                                end
                                            end
                                            
                                            table.insert(transition_analysis.sequential_transitions, {
                                                from = last_cluster_idx,
                                                to = curr_idx,
                                                step = step,
                                                time = sample.time
                                            })
                                            
                                            if step == 1 or step == -#angles + 1 then
                                                transition_analysis.clockwise = transition_analysis.clockwise + 1
                                            elseif step == -1 or step == #angles - 1 then
                                                transition_analysis.counter_clockwise = transition_analysis.counter_clockwise + 1
                                            else
                                                transition_analysis.random_jumps = transition_analysis.random_jumps + 1
                                            end
                                        end
                                        if curr_idx then
                                            last_cluster_idx = curr_idx
                                        end
                                    end
                                end
                                
                                
                                local total_transitions = transition_analysis.clockwise + transition_analysis.counter_clockwise + transition_analysis.random_jumps
                                
                                if total_transitions >= 3 then
                                    local cw_ratio = transition_analysis.clockwise / total_transitions
                                    local ccw_ratio = transition_analysis.counter_clockwise / total_transitions
                                    local random_ratio = transition_analysis.random_jumps / total_transitions
                                    
                                    if cw_ratio > 0.6 and random_ratio < 0.25 then
                                        xway.rotation_direction = 1
                                    elseif ccw_ratio > 0.6 and random_ratio < 0.25 then
                                        xway.rotation_direction = -1
                                    elseif random_ratio > 0.5 then
                                        
                                        xway.rotation_direction = 0
                                        xway.confidence = 0.3
                                        return nil, 0.3
                                    else
                                        xway.rotation_direction = 0 
                                    end
                                end
                                
                                xway.transition_history = transition_analysis.sequential_transitions
                                
                                
                                xway.way_angles = {}
                                
                                
                                if xway.rotation_direction == 1 then
                                    for _, a in ipairs(angles) do table.insert(xway.way_angles, a) end
                                elseif xway.rotation_direction == -1 then
                                    for i = #angles, 1, -1 do table.insert(xway.way_angles, angles[i]) end
                                else
                                    for _, a in ipairs(angles) do table.insert(xway.way_angles, a) end
                                end
                                
                                
                                local current_yaw = recent_samples[#recent_samples].value
                                local closest_way_index = 1
                                local min_dist = 999
                                
                                for i, angle in ipairs(xway.way_angles) do
                                    local dist = math.abs(func.aa_clamp(current_yaw - angle))
                                    if dist < min_dist then
                                        min_dist = dist
                                        closest_way_index = i
                                    end
                                end
                                
                                
                                if xway.current_way_index ~= closest_way_index then
                                    xway.last_way_change_time = now
                                end
                                xway.current_way_index = closest_way_index
                                
                                
                                local way_durations = {}
                                
                                if #transition_analysis.sequential_transitions >= 2 then
                                    for i = 2, #transition_analysis.sequential_transitions do
                                        local curr = transition_analysis.sequential_transitions[i]
                                        local prev = transition_analysis.sequential_transitions[i-1]
                                        if curr.time and prev.time then
                                            local duration = curr.time - prev.time
                                            if duration > 0.01 and duration < 2.0 then
                                                table.insert(way_durations, duration)
                                            end
                                        end
                                    end
                                end
                                
                                if #way_durations >= 2 then
                                    local sum = 0
                                    for _, d in ipairs(way_durations) do sum = sum + d end
                                    xway.avg_way_duration = sum / #way_durations
                                    xway.cycle_duration = xway.avg_way_duration * xway.detected_ways
                                    
                                    
                                    local timing_variance = 0
                                    for _, d in ipairs(way_durations) do
                                        timing_variance = timing_variance + (d - xway.avg_way_duration)^2
                                    end
                                    timing_variance = timing_variance / #way_durations
                                    local timing_cv = math.sqrt(timing_variance) / math.max(0.01, xway.avg_way_duration)
                                    xway.timing_consistency = math.max(0, 1 - timing_cv * 2)
                                else
                                    xway.timing_consistency = 0.5
                                end
                                
                                
                                
                                if xway.detected_ways == data.prev_detected_ways then
                                    xway.consecutive_matches = (xway.consecutive_matches or 0) + 1
                                else
                                    xway.consecutive_matches = 0
                                end
                                data.prev_detected_ways = xway.detected_ways
                                
                                xway.pattern_stability = math.min(1, xway.consecutive_matches * 0.15)
                                
                                
                                local confidence = 0.35
                                
                                
                                if distinct_ways >= 3 and distinct_ways <= 6 then
                                    confidence = confidence + 0.18
                                elseif distinct_ways == 7 or distinct_ways == 8 then
                                    confidence = confidence + 0.10
                                end
                                
                                
                                local cluster_balance = 0
                                if #significant_clusters >= 2 then
                                    local counts = {}
                                    for _, c in ipairs(significant_clusters) do
                                        table.insert(counts, c.count)
                                    end
                                    
                                    local count_sum = 0
                                    for _, c in ipairs(counts) do count_sum = count_sum + c end
                                    local count_avg = count_sum / #counts
                                    
                                    local count_variance = 0
                                    for _, c in ipairs(counts) do
                                        count_variance = count_variance + (c - count_avg)^2
                                    end
                                    count_variance = count_variance / #counts
                                    
                                    local balance_score = 1 - math.min(1, math.sqrt(count_variance) / count_avg)
                                    cluster_balance = balance_score
                                    confidence = confidence + balance_score * 0.15
                                end
                                
                                
                                confidence = confidence + gap_uniformity * 0.12
                                
                                
                                if xway.rotation_direction ~= 0 then
                                    confidence = confidence + 0.10
                                end
                                
                                
                                if xway.timing_consistency then
                                    confidence = confidence + xway.timing_consistency * 0.10
                                end
                                
                                
                                confidence = confidence + xway.pattern_stability * 0.08
                                
                                
                                if #recent_samples >= 20 then
                                    confidence = confidence + 0.08
                                elseif #recent_samples >= 15 then
                                    confidence = confidence + 0.04
                                end
                                
                                
                                if total_transitions > 0 then
                                    local random_ratio = transition_analysis.random_jumps / total_transitions
                                    confidence = confidence * (1 - random_ratio * 0.5)
                                end
                                
                                xway.confidence = func.fclamp(confidence, 0.30, 0.92)
                                xway.last_detection = now
                                
                                return xway, xway.confidence
                            end,

predict_xway = function(self, player)
    local player_id = tostring(player)
    local data = self.players[player_id]
    if not data then return nil end
    
    
    local xway, xway_conf = self:detect_xway_pattern(player)
    if not xway or not xway.is_xway then return nil end
    
    local now = globals.realtime()
    local tick = globals.tickcount()
    
    
    local xway_count = xway.xway_count or 3
    local confidence = xway.confidence or 0.5
    
    
    local side_sequence = xway.side_sequence or {}
    local current_phase = xway.current_phase or 0
    
    
    
    
    
    local avg_phase_duration = xway.avg_phase_duration or 0.15
    local time_in_phase = xway.time_in_current_phase or 0
    local phase_progress = avg_phase_duration > 0 and (time_in_phase / avg_phase_duration) or 0.5
    
    
    
    local backtrack = data.last_backtrack or 0
    local travel_time_ticks = 2  
    local total_delay_ticks = backtrack + travel_time_ticks
    local total_delay_time = total_delay_ticks * globals.tickinterval()
    
    
    local phases_to_pass = 0
    if avg_phase_duration > 0.01 then
        phases_to_pass = math.floor((time_in_phase + total_delay_time) / avg_phase_duration)
    end
    
    
    local predicted_phase = (current_phase + phases_to_pass) % xway_count
    
    
    local predicted_side = 0
    if #side_sequence >= xway_count then
        predicted_side = side_sequence[(predicted_phase % #side_sequence) + 1] or 0
    else
        
        predicted_side = predicted_phase % 2
    end
    
    
    
    if data.consecutive_misses and data.consecutive_misses >= 2 then
        
        local recent_predictions = data.recent_xway_predictions or {}
        local side_0_count = 0
        local side_1_count = 0
        
        for i = #recent_predictions, math.max(1, #recent_predictions - 3), -1 do
            if recent_predictions[i] == 0 then
                side_0_count = side_0_count + 1
            else
                side_1_count = side_1_count + 1
            end
        end
        
        
        if side_0_count >= 2 and predicted_side == 0 then
            predicted_side = 1
            confidence = confidence * 0.85  
        elseif side_1_count >= 2 and predicted_side == 1 then
            predicted_side = 0
            confidence = confidence * 0.85
        end
    end
    
    
    if not data.recent_xway_predictions then
        data.recent_xway_predictions = {}
    end
    table.insert(data.recent_xway_predictions, predicted_side)
    while #data.recent_xway_predictions > 10 do
        table.remove(data.recent_xway_predictions, 1)
    end
    
    
    local predicted_body = predicted_side == 1 and 58 or -58
    
    
    if data.hit_body_yaws and #data.hit_body_yaws >= 2 then
        local side_hits = {}
        for _, entry in ipairs(data.hit_body_yaws) do
            if type(entry) == "table" and entry.side == predicted_side then
                table.insert(side_hits, entry.body)
            elseif type(entry) == "number" then
                
                if (predicted_side == 1 and entry > 0) or (predicted_side == 0 and entry < 0) then
                    table.insert(side_hits, entry)
                end
            end
        end
        
        if #side_hits >= 2 then
            local sum = 0
            for _, b in ipairs(side_hits) do sum = sum + b end
            local learned_body = sum / #side_hits
            
            
            if (predicted_side == 1 and learned_body > 30) or 
               (predicted_side == 0 and learned_body < -30) then
                predicted_body = math.floor(learned_body + 0.5)
            end
        end
    end
    
    
    if predicted_side == 1 and predicted_body <= 0 then
        predicted_body = 58
    elseif predicted_side == 0 and predicted_body >= 0 then
        predicted_body = -58
    end
    
    predicted_body = math.max(-60, math.min(60, predicted_body))
    
    
    
    if backtrack >= 10 then
        confidence = confidence * 0.60
    elseif backtrack >= 6 then
        confidence = confidence * 0.80
    end
    
    
    if xway_count >= 5 then
        confidence = confidence * 0.75
    elseif xway_count >= 4 then
        confidence = confidence * 0.85
    end
    
    
    if data.last_hit_time and (now - data.last_hit_time) < 2.0 then
        confidence = math.min(0.85, confidence * 1.15)
    end
    
    confidence = func.fclamp(confidence, 0.25, 0.80)
    
    return {
        is_xway = true,
        xway_count = xway_count,
        predicted_side = predicted_side,
        predicted_body = predicted_body,
        predicted_phase = predicted_phase,
        current_phase = current_phase,
        phases_passed = phases_to_pass,
        confidence = confidence,
        avg_phase_duration = avg_phase_duration,
    }
end,      
            
            
            analyze_body_yaw = function(self, player)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data or #data.body_yaw_history < 2 then
                    return "unknown", 0.5
                end
                
                local history = data.body_yaw_history
                local n = #history
                
                
                local check_count = math.min(8, n)
                local synced_count = 0
                local opposite_count = 0
                local static_count = 0
                local last_val = history[math.max(1, n - check_count)].value
                
                for i = math.max(1, n - check_count + 1), n do
                    local entry = history[i]
                    local expected_synced = entry.side == 1 and 60 or -60
                    local expected_opposite = entry.side == 1 and -60 or 60
                    
                    if math.abs(entry.value - expected_synced) < 20 then
                        synced_count = synced_count + 1
                    elseif math.abs(entry.value - expected_opposite) < 20 then
                        opposite_count = opposite_count + 1
                    end
                    
                    if math.abs(entry.value - last_val) < 10 then
                        static_count = static_count + 1
                    end
                end
                
                local mode, confidence
                
                if synced_count / check_count > 0.65 then
                    mode = "synced"
                    confidence = 0.78
                elseif opposite_count / check_count > 0.65 then
                    mode = "opposite"
                    confidence = 0.75
                elseif static_count / check_count > 0.70 then
                    mode = "static"
                    confidence = 0.72
                else
                    mode = "jitter"
                    confidence = 0.55
                end
                
                data.body_yaw_mode = mode
                return mode, confidence
            end,
            
            
            analyze_jitter_pattern = function(self, player)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data or #data.yaw_samples < self.min_samples then
                return "unknown", 0.5
                end
                
                local samples = data.yaw_samples
                local n = #samples
                local now = globals.realtime()
                
                
                local min_yaw, max_yaw = 999, -999
                local weighted_sum = 0
                local weight_total = 0
                local values = {}
                local deltas = {}
                local timestamps = {}
                
                local sample_window = math.min(20, n)
                for i = math.max(1, n - sample_window + 1), n do
                local s = samples[i]
                local y = s.value
                if y then
                    
                    local age = now - (s.time or now)
                    local weight = math.exp(-age * 2.0)
                    
                    min_yaw = math.min(min_yaw, y)
                    max_yaw = math.max(max_yaw, y)
                    weighted_sum = weighted_sum + y * weight
                    weight_total = weight_total + weight
                    table.insert(values, y)
                    table.insert(timestamps, s.time or now)
                    
                    
                    if #values >= 2 then
                    local delta = func.aa_clamp(y - values[#values - 1])
                    table.insert(deltas, delta)
                    end
                end
                end
                
                local check_count = #values
                if check_count < 2 then return "unknown", 0.4 end
                
                local center = weight_total > 0 and (weighted_sum / weight_total) or 0
                local range = max_yaw - min_yaw
                
                data.jitter_range = {min = min_yaw, max = max_yaw}
                data.jitter_center = center
                
                
                local var_sum = 0
                for _, v in ipairs(values) do
                var_sum = var_sum + (v - center)^2
                end
                local variance = var_sum / math.max(1, check_count - 1)
                local std_dev = math.sqrt(variance)
                
                
                local cv = std_dev / math.max(1, math.abs(center) + range / 4)
                
                
                local direction_changes = 0
                local delta_sum = 0
                local delta_abs_sum = 0
                local last_sign = nil
                
                for _, d in ipairs(deltas) do
                local sign = d > 0 and 1 or (d < 0 and -1 or 0)
                if sign ~= 0 then
                    if last_sign and sign ~= last_sign then
                    direction_changes = direction_changes + 1
                    end
                    last_sign = sign
                end
                delta_sum = delta_sum + d
                delta_abs_sum = delta_abs_sum + math.abs(d)
                end
                
                local direction_change_rate = #deltas > 1 and (direction_changes / (#deltas - 1)) or 0
                local avg_delta_magnitude = #deltas > 0 and (delta_abs_sum / #deltas) or 0
                local delta_bias = #deltas > 0 and (delta_sum / #deltas) or 0
                
                
                local cluster_threshold = range * 0.15
                local above_center = 0
                local below_center = 0
                local at_center = 0
                
                for _, v in ipairs(values) do
                if v > center + cluster_threshold then 
                    above_center = above_center + 1
                elseif v < center - cluster_threshold then 
                    below_center = below_center + 1
                else
                    at_center = at_center + 1
                end
                end
                
                
                local bin_count = math.min(8, math.ceil(range / 10))
                local bins = {}
                for i = 1, bin_count do bins[i] = 0 end
                
                if range > 1 and bin_count > 1 then
                local bin_size = range / bin_count
                for _, v in ipairs(values) do
                    local bin = math.floor((v - min_yaw) / bin_size) + 1
                    bin = math.max(1, math.min(bin_count, bin))
                    bins[bin] = bins[bin] + 1
                end
                end
                
                local entropy = 0
                for _, count in ipairs(bins) do
                if count > 0 then
                    local p = count / check_count
                    entropy = entropy - p * math.log(p + 1e-10) / math.log(2)
                end
                end
                local max_entropy = math.log(bin_count) / math.log(2)
                local normalized_entropy = max_entropy > 0 and (entropy / max_entropy) or 0
                
                
                local autocorr = 0
                if check_count >= 6 then
                local lag = 1
                local mean = center
                local var_denom = 0
                for _, v in ipairs(values) do
                    var_denom = var_denom + (v - mean)^2
                end
                
                if var_denom > 0.01 then
                    local cov = 0
                    for i = 1, check_count - lag do
                    cov = cov + (values[i] - mean) * (values[i + lag] - mean)
                    end
                    autocorr = cov / var_denom
                end
                end
                
                
                local switch_consistency = 0
                if #data.switch_times >= 3 then
                local intervals = {}
                for i = 2, #data.switch_times do
                    table.insert(intervals, data.switch_times[i] - data.switch_times[i-1])
                end
                
                if #intervals >= 2 then
                    local int_sum = 0
                    for _, int in ipairs(intervals) do int_sum = int_sum + int end
                    local int_avg = int_sum / #intervals
                    data.avg_switch_interval = int_avg
                    
                    local int_var = 0
                    for _, int in ipairs(intervals) do
                    int_var = int_var + (int - int_avg)^2
                    end
                    local int_cv = math.sqrt(int_var / #intervals) / math.max(0.01, int_avg)
                    switch_consistency = 1 - math.min(1, int_cv)
                end
                end
                
                
                local pattern, confidence
                local pattern_scores = {
                no_jitter = 0,
                center = 0,
                offset = 0,
                alternating = 0,
                medium = 0,
                wide = 0,
                random = 0,
                }
                
                
                if range < 8 then
                pattern_scores.no_jitter = 0.95 - range * 0.05
                elseif range < 15 and std_dev < 5 then
                pattern_scores.no_jitter = 0.70 - range * 0.02
                end
                
                
                if range >= 10 and range < 50 then
                local center_ratio = at_center / check_count
                if center_ratio > 0.35 then
                    pattern_scores.center = 0.60 + center_ratio * 0.30
                elseif std_dev < range * 0.35 then
                    pattern_scores.center = 0.55 + (1 - std_dev / range) * 0.25
                end
                end
                
                
                local imbalance = math.abs(above_center - below_center) / check_count
                if imbalance > 0.35 and range >= 15 then
                pattern_scores.offset = 0.50 + imbalance * 0.40
                
                if (delta_bias > 0 and above_center > below_center) or 
                (delta_bias < 0 and below_center > above_center) then
                    pattern_scores.offset = pattern_scores.offset + 0.10
                end
                end
                
                
                if direction_change_rate > 0.60 and range >= 20 then
                pattern_scores.alternating = 0.55 + direction_change_rate * 0.25
                if autocorr < -0.20 then
                    pattern_scores.alternating = pattern_scores.alternating + math.abs(autocorr) * 0.20
                end
                end
                
                
                if range >= 25 and range < 80 then
                local medium_score = 0.50
                if std_dev > 10 and std_dev < 30 then
                    medium_score = medium_score + 0.15
                end
                if normalized_entropy > 0.50 and normalized_entropy < 0.85 then
                    medium_score = medium_score + 0.12
                end
                pattern_scores.medium = medium_score
                end
                
                
                if range >= 70 then
                pattern_scores.wide = 0.55 + math.min(0.30, (range - 70) * 0.003)
                if std_dev > 25 then
                    pattern_scores.wide = pattern_scores.wide + 0.10
                end
                end
                
                
                if normalized_entropy > 0.75 and math.abs(autocorr) < 0.25 and range >= 30 then
                pattern_scores.random = 0.50 + normalized_entropy * 0.25 + (1 - math.abs(autocorr)) * 0.15
                if switch_consistency < 0.40 then
                    pattern_scores.random = pattern_scores.random + 0.10
                end
                end
                
                
                local best_pattern = "unknown"
                local best_score = 0.35
                
                for p, score in pairs(pattern_scores) do
                if score > best_score then
                    best_score = score
                    best_pattern = p
                end
                end
                
                pattern = best_pattern
                confidence = best_score
                
                
                if check_count < 5 then
                confidence = confidence * 0.75
                elseif check_count < 8 then
                confidence = confidence * 0.88
                elseif check_count >= 15 then
                confidence = math.min(0.92, confidence * 1.05)
                end
                
                
                local sorted_scores = {}
                for _, score in pairs(pattern_scores) do
                table.insert(sorted_scores, score)
                end
                table.sort(sorted_scores, function(a, b) return a > b end)
                
                if #sorted_scores >= 2 and sorted_scores[1] - sorted_scores[2] < 0.12 then
                confidence = confidence * 0.85
                end
                
                
                data.pattern = pattern
                data.pattern_confidence = confidence
                data.pattern_entropy = normalized_entropy
                data.pattern_autocorr = autocorr
                data.pattern_direction_change_rate = direction_change_rate
                data.pattern_switch_consistency = switch_consistency
                data.pattern_cv = cv
                
                return pattern, confidence
            end,
            
            
            get_learned_offset = function(self, player)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data then return 0, 0.3 end
                
                
                if #data.hit_yaws >= 2 then
                    local recent_hit_sum = 0
                    local weight_sum = 0
                    
                    for i = #data.hit_yaws, math.max(1, #data.hit_yaws - 4), -1 do
                        local weight = (i - #data.hit_yaws + 5) / 5
                        recent_hit_sum = recent_hit_sum + data.hit_yaws[i] * weight
                        weight_sum = weight_sum + weight
                    end
                    
                    if weight_sum > 0 then
                        local avg_hit_yaw = recent_hit_sum / weight_sum
                        local offset = func.aa_clamp(avg_hit_yaw - data.jitter_center)
                        return offset, 0.65
                    end
                end
                
                
                local best_offset = 0
                local best_weight = -999
                
                for offset, weight in pairs(data.offset_weights or {}) do
                    if weight > best_weight then
                        best_weight = weight
                        best_offset = offset
                    end
                end
                
                if best_weight > 0.2 then
                    return best_offset, math.min(0.60, best_weight)
                end
                
                return 0, 0.3
            end,

            
            update_resolver_state = function(self, player)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data then return end
                
                local total_shots = data.hit_count + data.miss_count
                local pe = data.prediction_errors
                local now = globals.realtime()
                
                
                local side_pattern = data.side_pattern or "learning"
                local samples = #(data.yaw_samples or {})
                local side_predictable = data.side_predictable or false
                local side_consistency = data.side_consistency or 0
                
                
                if total_shots >= 2 then
                    local hit_rate = data.hit_count / total_shots
                    local recent_hit = data.last_hit_time and (now - data.last_hit_time) < 3.0
                    
                    if data.consecutive_misses >= 4 then
                        data.resolver_state = "bruteforce"
                        data.state_confidence = 0.42
                    elseif data.consecutive_misses >= 3 and not recent_hit then
                        data.resolver_state = "struggling"
                        data.state_confidence = 0.45
                    elseif hit_rate > 0.55 and total_shots >= 3 then
                        data.resolver_state = "confident"
                        data.state_confidence = 0.72 + hit_rate * 0.12
                    elseif hit_rate > 0.40 then
                        data.resolver_state = "tracking"
                        data.state_confidence = 0.58
                    elseif hit_rate < 0.25 and total_shots >= 4 then
                        data.resolver_state = "struggling"
                        data.state_confidence = 0.45
                    elseif pe.consecutive_yaw_misses >= 3 then
                        data.resolver_state = "yaw_uncertain"
                        data.state_confidence = 0.50
                    else
                        data.resolver_state = "tracking"
                        data.state_confidence = 0.55
                    end
                else
                    
                    if samples >= 15 and side_predictable then
                        
                        data.resolver_state = "side_locked"
                        data.state_confidence = 0.50 + side_consistency * 0.15
                    elseif samples >= 15 and side_pattern ~= "learning" and side_pattern ~= "chaotic" then
                        data.resolver_state = "tracking"
                        data.state_confidence = 0.55
                    elseif samples >= 15 and side_pattern == "chaotic" then
                        
                        data.resolver_state = "adaptive"
                        data.state_confidence = 0.48
                    elseif samples >= 8 then
                        data.resolver_state = "learning"
                        data.state_confidence = 0.50
                    else
                        data.resolver_state = "learning"
                        data.state_confidence = 0.45
                    end
                end
            end,
            
            extrapolate_side_for_backtrack = function(self, player, backtrack_ticks)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data then return data.current_side or 0, 0.3 end
                
                
                local total_compensation, stability_factor, is_stable = self.ping_compensation:get_total_compensation(backtrack_ticks, player_id)
                
                
                if total_compensation < 4 then
                    return data.current_side or 0, 0.80 * (stability_factor or 1.0)
                end
                
                
                local pattern = data.side_pattern or "unknown"
                local avg_delay = data.detected_delay or 4
                local delay_var = data.delay_variance or 2
                local mode_delay = data.mode_delay or avg_delay
                local current_side = data.current_side or 0
                
                
                local ticks_since_switch = data.switch_delay or 0
                
                local predicted_side = current_side
                local confidence = 0.5
                
                if pattern == "fixed_delay" and avg_delay > 0 then
                    
                    local simulated_ticks = ticks_since_switch
                    local switches = 0
                    
                    
                    while simulated_ticks + avg_delay <= total_compensation + ticks_since_switch do
                        simulated_ticks = simulated_ticks + avg_delay
                        switches = switches + 1
                    end
                    
                    predicted_side = (switches % 2 == 1) and (1 - current_side) or current_side
                    
                    
                    local cv = delay_var / math.max(1, avg_delay)
                    confidence = 0.75 - cv * 0.3
                    
                    
                    confidence = confidence * (stability_factor or 1.0)
                    
                    
                    if total_compensation > 18 then
                        confidence = confidence * 0.55
                    elseif total_compensation > 14 then
                        confidence = confidence * 0.70
                    elseif total_compensation > 10 then
                        confidence = confidence * 0.85
                    end
                    
                elseif pattern == "sequence" and data.delay_sequence and #data.delay_sequence >= 2 then
                    
                    local seq = data.delay_sequence
                    local seq_len = #seq
                    local simulated_ticks = ticks_since_switch
                    local switches = 0
                    local seq_idx = (data.current_delay_index or 1)
                    
                    
                    while simulated_ticks < total_compensation + ticks_since_switch do
                        local delay = seq[((seq_idx - 1) % seq_len) + 1] or avg_delay
                        if simulated_ticks + delay > total_compensation + ticks_since_switch then
                            break
                        end
                        simulated_ticks = simulated_ticks + delay
                        switches = switches + 1
                        seq_idx = seq_idx + 1
                    end
                    
                    predicted_side = (switches % 2 == 1) and (1 - current_side) or current_side
                    confidence = 0.70 * (stability_factor or 1.0)
                    
                    if total_compensation > 14 then
                        confidence = confidence * 0.65
                    elseif total_compensation > 10 then
                        confidence = confidence * 0.80
                    end
                    
                elseif pattern == "tight_random" then
                    
                    local effective_delay = mode_delay > 0 and mode_delay or avg_delay
                    local expected_switches = math.floor(total_compensation / math.max(1, effective_delay))
                    
                    
                    local uncertainty = delay_var / math.max(1, effective_delay)
                    
                    predicted_side = (expected_switches % 2 == 1) and (1 - current_side) or current_side
                    confidence = (0.55 - uncertainty * 0.2) * (stability_factor or 1.0)
                    
                elseif pattern == "variable_delay" then
                    
                    local effective_delay = (avg_delay * 0.6 + (mode_delay or avg_delay) * 0.4)
                    local expected_switches = math.floor(total_compensation / math.max(1, effective_delay))
                    
                    predicted_side = (expected_switches % 2 == 1) and (1 - current_side) or current_side
                    confidence = 0.45 * (stability_factor or 1.0)
                    
                elseif pattern == "chaotic" or pattern == "reactive" then
                    
                    local bt_success = data.bt_success
                    if bt_success then
                        local bt_bucket = math.min(20, math.floor(backtrack_ticks / 4) * 4)
                        if bt_success.side_rates and bt_success.side_rates[bt_bucket] then
                            local rates = bt_success.side_rates[bt_bucket]
                            if rates[0] and rates[1] then
                                predicted_side = rates[1] > rates[0] and 1 or 0
                                confidence = (0.40 + math.abs(rates[1] - rates[0]) * 0.3) * (stability_factor or 1.0)
                            end
                        end
                    else
                        confidence = 0.25 * (stability_factor or 1.0)
                    end
                else
                    
                    confidence = 0.30 * (stability_factor or 1.0)
                end
                
                
                confidence = self.ping_compensation:adjust_confidence_for_compensation(confidence, total_compensation, player_id)
                
                
                confidence = func.fclamp(confidence, 0.15, 0.72)
                
                
                data.used_ping_compensation = true
                data.total_compensation_used = total_compensation
                
                return predicted_side, confidence
            end,

            predict_high_backtrack = function(self, player, backtrack_ticks)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data then return 0, 0.20 end
                
                
                if backtrack_ticks < 10 then
                    return self:extrapolate_side_for_backtrack(player, backtrack_ticks)
                end
                
                local now = globals.realtime()
                local tick = globals.tickcount()
                local tickinterval = globals.tickinterval()
                
                
                local total_compensation, stability_factor, is_stable = self.ping_compensation:get_total_compensation(backtrack_ticks, player_id)
                local ping_comp = self.ping_compensation:get_adaptive_compensation(player_id)
                
                
                if ping_comp then
                    data.last_ping_info = {
                        ping_ticks = ping_comp.ping_ticks,
                        avg_ping = ping_comp.avg_ping_ticks,
                        jitter = ping_comp.jitter_ticks,
                        total_comp = total_compensation,
                        is_stable = is_stable,
                    }
                end
                
                
                if not data.high_bt_tracking then
                data.high_bt_tracking = {
                    
                    bt_side_history = {},  
                    
                    prediction_results = {},
                    
                    observed_sides = {},
                    
                    model = {
                    side_bias = 0.5,  
                    switch_frequency = 0,  
                    phase_offset = 0,  
                    momentum_direction = 0,  
                    momentum_strength = 0,
                    last_model_update = 0,
                    },
                    
                    bruteforce_high_bt = {
                    stage = 0,
                    last_side = 0,
                    consecutive_fails = 0,
                    flip_next = false,
                    last_attempt_time = 0,
                    successful_sides = {[0] = 0, [1] = 0},
                    },
                    
                    adaptive = {
                    bt_buckets = {},  
                    winning_strategies = {},  
                    last_learning_update = 0,
                    },
                    
                    recent_observations = {},  
                }
                end
                
                local hbt = data.high_bt_tracking
                local model = hbt.model
                local adaptive = hbt.adaptive
                
                
                local bt_tier = "medium"  
                if backtrack_ticks >= 18 then
                bt_tier = "extreme"
                elseif backtrack_ticks >= 15 then
                bt_tier = "very_high"
                elseif backtrack_ticks >= 13 then
                bt_tier = "high"
                end
                
                
                local side_bias = 0.5
                local bias_confidence = 0.25
                
                if data.side_history and #data.side_history >= 4 then
                local side_0_time = 0
                local side_1_time = 0
                local side_0_weight = 0
                local side_1_weight = 0
                local last_switch_time = 0
                local last_side = nil
                
                
                for i, entry in ipairs(data.side_history) do
                    if last_side ~= nil and entry.time then
                    local duration = entry.time - last_switch_time
                    local recency_weight = math.exp(-((now - entry.time) * 0.8))
                    
                    if last_side == 0 then
                        side_0_time = side_0_time + duration
                        side_0_weight = side_0_weight + duration * recency_weight
                    else
                        side_1_time = side_1_time + duration
                        side_1_weight = side_1_weight + duration * recency_weight
                    end
                    end
                    last_side = entry.side
                    last_switch_time = entry.time or last_switch_time
                end
                
                local total_time = side_0_time + side_1_time
                local total_weight = side_0_weight + side_1_weight
                
                if total_weight > 0.3 then
                    side_bias = side_1_weight / total_weight
                    
                    bias_confidence = math.min(0.58, 0.30 + total_weight * 0.08)
                    
                    
                    if math.abs(side_bias - 0.5) > 0.25 then
                    bias_confidence = bias_confidence * 1.15
                    end
                end
                end
                
                model.side_bias = side_bias
                
                
                local momentum_side = data.current_side or 0
                local momentum_confidence = 0.20
                
                if data.side_history and #data.side_history >= 4 then
                local recent_count = math.min(8, #data.side_history)
                local side_0_recent = 0
                local side_1_recent = 0
                local weighted_direction = 0
                
                for i = #data.side_history, math.max(1, #data.side_history - recent_count + 1), -1 do
                    local entry = data.side_history[i]
                    local position_weight = (i - (#data.side_history - recent_count)) / recent_count
                    
                    if entry.side == 0 then
                    side_0_recent = side_0_recent + 1
                    else
                    side_1_recent = side_1_recent + 1
                    end
                    
                    weighted_direction = weighted_direction + (entry.side == 1 and position_weight or -position_weight)
                end
                
                
                model.momentum_direction = weighted_direction
                model.momentum_strength = math.abs(weighted_direction) / recent_count
                
                if math.abs(weighted_direction) > 0.3 then
                    momentum_side = weighted_direction > 0 and 1 or 0
                    momentum_confidence = 0.35 + model.momentum_strength * 0.25
                end
                end
                
                
                local phase_side = data.current_side or 0
                local phase_confidence = 0.22
                
                
                local switch_frequency = 0
                local frequency_reliability = 0
                
                if data.delay_ticks and #data.delay_ticks >= 3 then
                local sum = 0
                local sum_sq = 0
                local count = #data.delay_ticks
                
                for _, d in ipairs(data.delay_ticks) do
                    sum = sum + d
                    sum_sq = sum_sq + d * d
                end
                
                local avg_delay = sum / count
                local variance = (sum_sq / count) - (avg_delay * avg_delay)
                local std_dev = math.sqrt(math.max(0, variance))
                
                if avg_delay > 0 then
                    switch_frequency = 1.0 / avg_delay
                    
                    local cv = std_dev / math.max(1, avg_delay)
                    frequency_reliability = math.max(0.1, 1.0 - cv * 0.8)
                end
                end
                
                model.switch_frequency = switch_frequency
                
                
                if data.switch_delay and data.detected_delay and data.detected_delay > 0 and frequency_reliability > 0.3 then
                local ticks_since_switch = data.switch_delay
                local expected_delay = data.detected_delay
                
                
                local bt_time = backtrack_ticks
                local estimated_switches = bt_time * switch_frequency
                
                
                local variance_factor = data.delay_variance and (data.delay_variance / math.max(1, expected_delay)) or 0.3
                
                
                local current_phase = ticks_since_switch / expected_delay
                local total_phase = current_phase + estimated_switches
                
                
                local full_switches = math.floor(total_phase)
                local fractional_phase = total_phase - full_switches
                
                
                local switch_boundary_proximity = math.min(fractional_phase, 1 - fractional_phase)
                local boundary_uncertainty = switch_boundary_proximity < 0.2 and (1 - switch_boundary_proximity * 5) * 0.3 or 0
                
                
                if full_switches % 2 == 1 then
                    phase_side = 1 - (data.current_side or 0)
                else
                    phase_side = data.current_side or 0
                end
                
                
                phase_confidence = 0.45 * frequency_reliability * (1 - boundary_uncertainty)
                
                
                phase_confidence = phase_confidence * math.max(0.3, 1 - estimated_switches * 0.06)
                
                
                phase_confidence = phase_confidence * (1 - variance_factor * 0.5)
                end
                
                
                local historical_side = nil
                local historical_confidence = 0
                
                
                local bt_bucket = math.floor(backtrack_ticks / 3) * 3
                bt_bucket = math.max(9, math.min(21, bt_bucket))
                
                if not hbt.bt_side_history[bt_bucket] then
                hbt.bt_side_history[bt_bucket] = {
                    [0] = 0, [1] = 0, 
                    hits = {[0] = 0, [1] = 0},
                    recent_hits = {[0] = {}, [1] = {}},
                    last_update = 0
                }
                end
                
                local bucket_data = hbt.bt_side_history[bt_bucket]
                local total_attempts = bucket_data[0] + bucket_data[1]
                
                if total_attempts >= 3 then
                local side_0_rate = bucket_data.hits[0] / math.max(1, bucket_data[0])
                local side_1_rate = bucket_data.hits[1] / math.max(1, bucket_data[1])
                
                
                local recent_0_hits = 0
                local recent_1_hits = 0
                
                for _, hit_time in ipairs(bucket_data.recent_hits[0] or {}) do
                    if now - hit_time < 30 then recent_0_hits = recent_0_hits + 1 end
                end
                for _, hit_time in ipairs(bucket_data.recent_hits[1] or {}) do
                    if now - hit_time < 30 then recent_1_hits = recent_1_hits + 1 end
                end
                
                
                local combined_0_score = side_0_rate * 0.6 + (recent_0_hits / math.max(1, recent_0_hits + recent_1_hits)) * 0.4
                local combined_1_score = side_1_rate * 0.6 + (recent_1_hits / math.max(1, recent_0_hits + recent_1_hits)) * 0.4
                
                if math.abs(combined_0_score - combined_1_score) > 0.12 then
                    historical_side = combined_0_score > combined_1_score and 0 or 1
                    historical_confidence = math.min(0.55, 0.25 + math.abs(combined_0_score - combined_1_score) * 0.6)
                    
                    
                    if total_attempts >= 8 then
                    historical_confidence = historical_confidence * 1.12
                    end
                end
                end
                
                
                local pattern_side = nil
                local pattern_confidence = 0
                
                local side_pattern = data.side_pattern or "unknown"
                
                if side_pattern == "fixed_delay" and frequency_reliability > 0.5 then
                
                pattern_side = phase_side
                pattern_confidence = phase_confidence * 1.25
                
                elseif side_pattern == "sequence" and data.delay_sequence and #data.delay_sequence >= 3 then
                
                local seq = data.delay_sequence
                local seq_len = #seq
                local simulated_ticks = data.switch_delay or 0
                local switches = 0
                local seq_idx = 1
                
                
                local remaining_bt = backtrack_ticks
                while remaining_bt > 0 and switches < 20 do
                    local next_delay = seq[((seq_idx - 1) % seq_len) + 1]
                    if simulated_ticks + next_delay > remaining_bt + (data.switch_delay or 0) then
                    break
                    end
                    simulated_ticks = simulated_ticks + next_delay
                    switches = switches + 1
                    seq_idx = seq_idx + 1
                    remaining_bt = remaining_bt - next_delay
                end
                
                pattern_side = (switches % 2 == 1) and (1 - (data.current_side or 0)) or (data.current_side or 0)
                pattern_confidence = 0.48 * math.max(0.4, 1 - switches * 0.04)
                
                elseif side_pattern == "chaotic" or side_pattern == "reactive" then
                
                pattern_side = side_bias > 0.55 and 1 or (side_bias < 0.45 and 0 or (momentum_side))
                pattern_confidence = math.max(bias_confidence, momentum_confidence) * 0.75
                end
                
                
                local bf = hbt.bruteforce_high_bt
                local bruteforce_side = nil
                local bruteforce_confidence = 0
                
                local should_bruteforce = (data.consecutive_misses and data.consecutive_misses >= 2) or
                                (bf.consecutive_fails >= 2)
                
                if should_bruteforce then
                
                local time_since_last = now - bf.last_attempt_time
                
                if bf.flip_next or time_since_last < 0.3 then
                    
                    bruteforce_side = 1 - bf.last_side
                    bf.flip_next = false
                else
                    
                    if bf.successful_sides[0] > bf.successful_sides[1] + 1 then
                    bruteforce_side = 0
                    elseif bf.successful_sides[1] > bf.successful_sides[0] + 1 then
                    bruteforce_side = 1
                    else
                    
                    local cycle_patterns = {
                        {0, 1, 0, 0, 1, 1},
                        {1, 0, 1, 1, 0, 0},
                        {0, 1, 1, 0, 1, 0},
                    }
                    local pattern_idx = (bf.consecutive_fails % 3) + 1
                    local stage_idx = (bf.stage % 6) + 1
                    bruteforce_side = cycle_patterns[pattern_idx][stage_idx]
                    end
                end
                
                bf.stage = bf.stage + 1
                bf.last_attempt_time = now
                
                
                bruteforce_confidence = math.max(0.28, 0.42 - bf.consecutive_fails * 0.03)
                
                
                if bf.consecutive_fails >= 6 then
                    if math.random() < 0.35 then
                    bruteforce_side = math.random(0, 1)
                    end
                    bruteforce_confidence = 0.22
                end
                else
                bf.consecutive_fails = 0
                end
                
                
                local strategies = {}
                
                
                if historical_side ~= nil then
                table.insert(strategies, {
                    name = "historical",
                    side = historical_side,
                    confidence = historical_confidence,
                    weight = bt_tier == "extreme" and 1.4 or (bt_tier == "very_high" and 1.3 or 1.2)
                })
                end
                
                if pattern_side ~= nil and pattern_confidence > 0.15 then
                local pattern_weight = 1.0
                if side_pattern == "fixed_delay" then
                    pattern_weight = bt_tier == "medium" and 1.5 or (bt_tier == "high" and 1.2 or 0.8)
                elseif side_pattern == "chaotic" then
                    pattern_weight = 0.6
                end
                
                table.insert(strategies, {
                    name = "pattern",
                    side = pattern_side,
                    confidence = pattern_confidence,
                    weight = pattern_weight
                })
                end
                
                if phase_confidence > 0.15 then
                local phase_weight = 1.0
                if bt_tier == "extreme" then
                    phase_weight = 0.5
                elseif bt_tier == "very_high" then
                    phase_weight = 0.7
                elseif bt_tier == "high" then
                    phase_weight = 0.9
                end
                
                table.insert(strategies, {
                    name = "phase",
                    side = phase_side,
                    confidence = phase_confidence,
                    weight = phase_weight
                })
                end
                
                if math.abs(side_bias - 0.5) > 0.1 then
                local bias_weight = bt_tier == "extreme" and 1.3 or (bt_tier == "very_high" and 1.15 or 1.0)
                
                table.insert(strategies, {
                    name = "bias",
                    side = side_bias > 0.5 and 1 or 0,
                    confidence = bias_confidence,
                    weight = bias_weight
                })
                end
                
                if momentum_confidence > 0.2 then
                table.insert(strategies, {
                    name = "momentum",
                    side = momentum_side,
                    confidence = momentum_confidence,
                    weight = bt_tier == "extreme" and 0.8 or 1.0
                })
                end
                
                if bruteforce_side ~= nil and should_bruteforce then
                table.insert(strategies, {
                    name = "bruteforce",
                    side = bruteforce_side,
                    confidence = bruteforce_confidence,
                    weight = data.consecutive_misses >= 4 and 1.5 or 1.2
                })
                end
                
                
                local final_side = data.current_side or 0
                local final_confidence = 0.20
                
                if #strategies > 0 then
                local weighted_side_0 = 0
                local weighted_side_1 = 0
                local total_weight = 0
                
                for _, strat in ipairs(strategies) do
                    local effective_weight = strat.confidence * strat.weight
                    
                    if strat.side == 0 then
                    weighted_side_0 = weighted_side_0 + effective_weight
                    else
                    weighted_side_1 = weighted_side_1 + effective_weight
                    end
                    total_weight = total_weight + effective_weight
                end
                
                if total_weight > 0.01 then
                    final_side = weighted_side_1 > weighted_side_0 and 1 or 0
                    
                    local margin = math.abs(weighted_side_1 - weighted_side_0)
                    local margin_ratio = margin / total_weight
                    
                    
                    final_confidence = 0.25 + margin_ratio * 0.35
                    
                    
                    local agreeing = 0
                    for _, strat in ipairs(strategies) do
                    if strat.side == final_side then agreeing = agreeing + 1 end
                    end
                    
                    if #strategies >= 3 and agreeing / #strategies >= 0.75 then
                    final_confidence = final_confidence * 1.15
                    elseif agreeing / #strategies >= 0.60 then
                    final_confidence = final_confidence * 1.08
                    end
                end
                else
                
                final_side = data.current_side or 0
                final_confidence = 0.18
                end
                
                
                if should_bruteforce then
                bf.last_side = final_side
                end
                
                
                local bt_penalty = 1.0
                
                if bt_tier == "extreme" then
                bt_penalty = 0.40
                
                if math.random() < 0.18 then
                    final_side = 1 - final_side
                    final_confidence = final_confidence * 0.65
                end
                elseif bt_tier == "very_high" then
                bt_penalty = 0.52
                if math.random() < 0.10 then
                    final_side = 1 - final_side
                    final_confidence = final_confidence * 0.75
                end
                elseif bt_tier == "high" then
                bt_penalty = 0.68
                else  
                bt_penalty = 0.82
                end
                
                final_confidence = final_confidence * bt_penalty
                
                
                if side_pattern == "chaotic" or side_pattern == "reactive" then
                final_confidence = final_confidence * 0.70
                elseif side_pattern == "variable_delay" then
                final_confidence = final_confidence * 0.82
                end
                
                
                if data.delay_variance and data.detected_delay then
                local cv = data.delay_variance / math.max(1, data.detected_delay)
                if cv > 0.5 then
                    final_confidence = final_confidence * 0.65
                elseif cv > 0.35 then
                    final_confidence = final_confidence * 0.80
                end
                end
                
                
                data.last_high_bt_prediction = {
                side = final_side,
                confidence = final_confidence,
                bt = backtrack_ticks,
                bt_tier = bt_tier,
                strategies_used = #strategies,
                time = now,
                }
                
                
                local conf_cap = 0.65
                if bt_tier == "extreme" then
                conf_cap = 0.32
                elseif bt_tier == "very_high" then
                conf_cap = 0.42
                elseif bt_tier == "high" then
                conf_cap = 0.52
                end
                
                final_confidence = func.fclamp(final_confidence, 0.12, conf_cap)
                
                return final_side, final_confidence
            end,
                
                
                learn_high_bt_result = function(self, player, backtrack_ticks, predicted_side, hit)
                    local player_id = tostring(player)
                    local data = self.players[player_id]
                    if not data or not data.high_bt_tracking then return end
                    
                    local hbt = data.high_bt_tracking
                    
                    
                    local bt_bucket = math.floor(backtrack_ticks / 2) * 2
                    bt_bucket = math.min(20, bt_bucket)
                    
                    if not hbt.bt_side_history[bt_bucket] then
                        hbt.bt_side_history[bt_bucket] = {[0] = 0, [1] = 0, hits = {[0] = 0, [1] = 0}}
                    end
                    
                    local bucket_data = hbt.bt_side_history[bt_bucket]
                    
                    
                    bucket_data[predicted_side] = bucket_data[predicted_side] + 1
                    
                    if hit then
                        bucket_data.hits[predicted_side] = bucket_data.hits[predicted_side] + 1
                        
                        
                        hbt.bruteforce_high_bt.consecutive_fails = 0
                        hbt.bruteforce_high_bt.stage = 0
                    else
                        
                        hbt.bruteforce_high_bt.flip_next = true
                    end
                    
                    
                    local total = bucket_data[0] + bucket_data[1]
                    if total > 30 then
                        local decay = 0.85
                        bucket_data[0] = math.floor(bucket_data[0] * decay)
                        bucket_data[1] = math.floor(bucket_data[1] * decay)
                        bucket_data.hits[0] = math.floor(bucket_data.hits[0] * decay)
                        bucket_data.hits[1] = math.floor(bucket_data.hits[1] * decay)
                    end
                end,
                
                detect_side_early = function(self, player)
                    local player_id = tostring(player)
                    local data = self.players[player_id]
                    if not data then return 0, 0.25 end
                    
                    local now = globals.realtime()
                    local detected_side = 0
                    local confidence = 0.25
                    local detection_method = "fallback"
                    
                    
                    if data.body_yaw_history and #data.body_yaw_history >= 1 then
                        local recent = data.body_yaw_history[#data.body_yaw_history]
                        if recent and recent.value and recent.time and (now - recent.time) < 0.5 then
                            detected_side = recent.value > 0 and 1 or 0
                            confidence = 0.55
                            detection_method = "body_yaw"
                            
                            
                            if #data.body_yaw_history >= 3 then
                                local consistent = 0
                                local sign = recent.value > 0 and 1 or -1
                                for i = #data.body_yaw_history - 2, #data.body_yaw_history do
                                    local entry = data.body_yaw_history[i]
                                    if entry and entry.value then
                                        local entry_sign = entry.value > 0 and 1 or -1
                                        if entry_sign == sign then consistent = consistent + 1 end
                                    end
                                end
                                if consistent >= 3 then
                                    confidence = confidence + 0.12
                                end
                            end
                        end
                    end
                    
                    
                    if confidence < 0.55 and data.side_history and #data.side_history >= 2 then
                        local side_0_weight = 0
                        local side_1_weight = 0
                        local momentum = 0
                        local last_side = nil
                        local check_count = math.min(12, #data.side_history)
                        
                        for i = #data.side_history, math.max(1, #data.side_history - check_count + 1), -1 do
                            local entry = data.side_history[i]
                            if entry then
                                local recency = (#data.side_history - i + 1) / check_count
                                local weight = math.exp(-recency * 1.5)
                                
                                if entry.side == 0 then
                                    side_0_weight = side_0_weight + weight
                                else
                                    side_1_weight = side_1_weight + weight
                                end
                                
                                
                                if last_side ~= nil and entry.side ~= last_side then
                                    momentum = momentum + (entry.side == 1 and weight or -weight)
                                end
                                last_side = entry.side
                            end
                        end
                        
                        local total_weight = side_0_weight + side_1_weight
                        if total_weight > 0.5 then
                            detected_side = side_1_weight > side_0_weight and 1 or 0
                            local imbalance = math.abs(side_1_weight - side_0_weight) / total_weight
                            confidence = math.max(confidence, 0.40 + imbalance * 0.25)
                            detection_method = "side_history"
                            
                            
                            if data.side_predictable and data.side_consistency > 0.5 then
                                confidence = math.min(confidence + data.side_consistency * 0.15, 0.72)
                            end
                        end
                    end
                    
                    
                    if confidence < 0.50 and data.delay_ticks and #data.delay_ticks >= 2 and data.switch_delay then
                        local avg_delay = data.detected_delay or 4
                        local current_delay = data.switch_delay
                        
                        
                        if data.delay_clusters and #data.delay_clusters >= 1 then
                            local dominant_cluster = data.delay_clusters[1]
                            if dominant_cluster.ratio >= 0.35 then
                                avg_delay = dominant_cluster.center
                            end
                        end
                        
                        if avg_delay > 0 then
                            local phase = current_delay / avg_delay
                            local expected_switches = math.floor(phase)
                            
                            
                            if expected_switches % 2 == 1 then
                                detected_side = 1 - (data.current_side or 0)
                            else
                                detected_side = data.current_side or 0
                            end
                            
                            
                            local phase_frac = phase - expected_switches
                            local boundary_distance = math.min(phase_frac, 1 - phase_frac)
                            confidence = math.max(confidence, 0.42 - boundary_distance * 0.15)
                            detection_method = "delay_phase"
                        end
                    end
                    
                    
                    if confidence < 0.45 and data.hit_sides then
                        local side_0_hits = data.hit_sides[0] or 0
                        local side_1_hits = data.hit_sides[1] or 0
                        local total_hits = side_0_hits + side_1_hits
                        
                        if total_hits >= 3 then
                            local side_0_rate = side_0_hits / total_hits
                            local side_1_rate = side_1_hits / total_hits
                            
                            if math.abs(side_0_rate - side_1_rate) > 0.25 then
                                detected_side = side_0_rate > side_1_rate and 0 or 1
                                confidence = math.max(confidence, 0.38 + math.abs(side_0_rate - side_1_rate) * 0.2)
                                detection_method = "hit_learning"
                            end
                        end
                    end
                    
                    
                    if data.resolver_state == "bruteforce" then
                        confidence = confidence * 0.80
                    elseif data.resolver_state == "confident" or data.resolver_state == "side_locked" then
                        confidence = confidence * 1.08
                    end
                    
                    
                    if data.consecutive_misses and data.consecutive_misses >= 2 then
                        confidence = confidence * (1.0 - math.min(0.35, data.consecutive_misses * 0.08))
                    end
                    
                    
                    confidence = func.fclamp(confidence, 0.18, 0.88)
                    
                    
                    data.current_side = detected_side
                    data.early_detection_method = detection_method
                    data.early_detection_confidence = confidence
                    
                    return detected_side, confidence
                end,

                
                predict = function(self, player)
                    local player_id = tostring(player)
                    local data = self.players[player_id]
                    if not data then return 0, 0, 0.50 end
                    
                    local now = globals.realtime()
                    local tick = globals.tickcount()
                    local tickinterval = globals.tickinterval()
                    
                    
                    if data.cached_prediction and (now - data.cache_time) < data.cache_valid_duration then
                    return data.cached_prediction.side, data.cached_prediction.yaw, data.cached_prediction.conf
                    end
                    
                    
                    local side_pattern, side_conf = self:analyze_side_pattern(player)
                    local body_mode, body_conf = self:analyze_body_yaw(player)
                    local jitter_pattern, jitter_conf = self:analyze_jitter_pattern(player)
                    
                    self:update_resolver_state(player)
                    
                    local pe = data.prediction_errors
                    
                    
                    if data.last_yaw ~= nil and pe.total_predictions > 0 then
                    local yaw_error = math.abs(func.aa_clamp((pe.last_predicted_yaw or 0) - data.last_yaw))
                    pe.yaw_error_history = pe.yaw_error_history or {}
                    table.insert(pe.yaw_error_history, yaw_error)
                    while #pe.yaw_error_history > 10 do
                        table.remove(pe.yaw_error_history, 1)
                    end
                    
                    
                    local sum = 0
                    for _, e in ipairs(pe.yaw_error_history) do sum = sum + e end
                    pe.avg_yaw_error = sum / #pe.yaw_error_history
                    
                    
                    if yaw_error > 30 then
                        pe.correction_factor = math.min(1.0, (pe.correction_factor or 0) + 0.15)
                        pe.consecutive_yaw_misses = (pe.consecutive_yaw_misses or 0) + 1
                    else
                        pe.correction_factor = math.max(0, (pe.correction_factor or 0) - 0.08)
                        pe.consecutive_yaw_misses = 0
                    end
                    end
                    
                    pe.total_predictions = pe.total_predictions + 1
                    
                    
                    local current_bt = 0
                    if data.backtrack_stats and data.backtrack_stats.avg_backtrack then
                    current_bt = data.backtrack_stats.avg_backtrack
                    end
                    if data.backtrack_history and #data.backtrack_history > 0 then
                    current_bt = data.backtrack_history[#data.backtrack_history].ticks or current_bt
                    end
                    
                    
                    if not data.high_bt_analysis then
                    data.high_bt_analysis = {
                        
                        bt_side_observations = {},  
                        
                        switch_bt_correlation = {},
                        
                        side_momentum = 0,  
                        last_momentum_update = 0,
                        
                        estimated_phase = 0,
                        phase_confidence = 0,
                        
                        bt_hit_history = {},
                        
                        best_strategy_by_bt = {},
                        
                        switch_velocity = 0,  
                        
                        pattern_fingerprint = {},
                    }
                    end
                    
                    local hba = data.high_bt_analysis
                    
                    
                    if data.side_history and #data.side_history >= 3 then
                    local recent_momentum = 0
                    local momentum_samples = math.min(6, #data.side_history)
                    
                    for i = #data.side_history, math.max(1, #data.side_history - momentum_samples + 1), -1 do
                        local entry = data.side_history[i]
                        local weight = (i - (#data.side_history - momentum_samples)) / momentum_samples
                        recent_momentum = recent_momentum + (entry.side == 1 and weight or -weight)
                    end
                    
                    
                    local alpha = 0.35
                    hba.side_momentum = hba.side_momentum * (1 - alpha) + recent_momentum * alpha
                    hba.last_momentum_update = now
                    end
                    
                    
                    if data.delay_ticks and #data.delay_ticks >= 2 then
                    local recent_delays = {}
                    for i = math.max(1, #data.delay_ticks - 5), #data.delay_ticks do
                        table.insert(recent_delays, data.delay_ticks[i])
                    end
                    
                    if #recent_delays >= 2 then
                        local sum = 0
                        for _, d in ipairs(recent_delays) do sum = sum + d end
                        local avg_delay = sum / #recent_delays
                        
                        
                        if avg_delay > 0 then
                        hba.switch_velocity = 1.0 / avg_delay
                        end
                    end
                    end
                    
                    
                    local predicted_side = data.current_side
                    local side_confidence = 0.50
                    
                    
                    local strategies = {}
                    
                    
                    if side_pattern == "fixed_delay" or side_pattern == "sequence" then
                    local expected_delay = data.detected_delay or 4
                    local ticks_since_switch = data.switch_delay or 0
                    
                    
                    local phase = ticks_since_switch / math.max(1, expected_delay)
                    local full_cycles = math.floor(phase)
                    local partial = phase - full_cycles
                    
                    
                    local phase_side
                    if partial >= 0.85 then
                        
                        phase_side = 1 - data.current_side
                    else
                        phase_side = data.current_side
                    end
                    
                    
                    if current_bt >= 4 then
                        local bt_phase_offset = current_bt * hba.switch_velocity
                        local adjusted_phase = phase + bt_phase_offset
                        local adjusted_cycles = math.floor(adjusted_phase)
                        
                        if adjusted_cycles % 2 == 1 then
                        phase_side = 1 - data.current_side
                        else
                        phase_side = data.current_side
                        end
                    end
                    
                    local phase_conf = 0.70
                    if current_bt >= 12 then phase_conf = phase_conf * 0.65
                    elseif current_bt >= 8 then phase_conf = phase_conf * 0.80 end
                    
                    table.insert(strategies, {name = "phase", side = phase_side, conf = phase_conf})
                    end
                    
                    
                    if math.abs(hba.side_momentum) > 0.2 then
                    local momentum_side = hba.side_momentum > 0 and 1 or 0
                    local momentum_strength = math.min(1.0, math.abs(hba.side_momentum))
                    local momentum_conf = 0.45 + momentum_strength * 0.25
                    
                    
                    if current_bt >= 15 then momentum_conf = momentum_conf * 0.55
                    elseif current_bt >= 10 then momentum_conf = momentum_conf * 0.70
                    elseif current_bt >= 6 then momentum_conf = momentum_conf * 0.85 end
                    
                    table.insert(strategies, {name = "momentum", side = momentum_side, conf = momentum_conf})
                    end
                    
                    
                    if data.side_history and #data.side_history >= 5 then
                    local side_0_time = 0
                    local side_1_time = 0
                    local last_time = nil
                    local last_side = nil
                    
                    for _, entry in ipairs(data.side_history) do
                        if last_time and entry.time then
                        local duration = entry.time - last_time
                        if last_side == 0 then
                            side_0_time = side_0_time + duration
                        else
                            side_1_time = side_1_time + duration
                        end
                        end
                        last_time = entry.time
                        last_side = entry.side
                    end
                    
                    local total_time = side_0_time + side_1_time
                    if total_time > 0.5 then
                        local bias = side_1_time / total_time
                        local bias_side = bias > 0.5 and 1 or 0
                        local bias_strength = math.abs(bias - 0.5) * 2
                        local bias_conf = 0.35 + bias_strength * 0.30
                        
                        
                        if current_bt >= 12 then bias_conf = bias_conf * 1.15 end
                        
                        table.insert(strategies, {name = "bias", side = bias_side, conf = math.min(0.70, bias_conf)})
                    end
                    end
                    
                    
                    local bt_bucket = math.min(20, math.floor(current_bt / 3) * 3)
                    if data.bt_prediction_accuracy and data.bt_prediction_accuracy[bt_bucket] then
                    local bt_acc = data.bt_prediction_accuracy[bt_bucket]
                    if bt_acc.total >= 4 then
                        local acc_rate = bt_acc.correct / bt_acc.total
                        
                        
                        if acc_rate < 0.35 then
                        local hist_side = 1 - data.current_side
                        local hist_conf = 0.40 + (0.35 - acc_rate) * 0.5
                        table.insert(strategies, {name = "history_flip", side = hist_side, conf = hist_conf})
                        elseif acc_rate > 0.55 then
                        
                        local hist_side = data.current_side
                        local hist_conf = 0.45 + (acc_rate - 0.55) * 0.5
                        table.insert(strategies, {name = "history_trust", side = hist_side, conf = hist_conf})
                        end
                    end
                    end
                    
                    
                    if current_bt >= 6 then
                    local extrap_side, extrap_conf = self:extrapolate_side_for_backtrack(player, math.floor(current_bt))
                    table.insert(strategies, {name = "extrapolate", side = extrap_side, conf = extrap_conf})
                    end
                    
                    
                    if current_bt >= 13 then
                    local high_bt_side, high_bt_conf = self:predict_high_backtrack(player, math.floor(current_bt))
                    table.insert(strategies, {name = "high_bt_special", side = high_bt_side, conf = high_bt_conf * 1.1})
                    data.used_high_bt_prediction = true
                    else
                    data.used_high_bt_prediction = false
                    end
                    
                    
                    if data.resolver_state == "bruteforce" or data.consecutive_misses >= 3 then
                    
                    local tried_sides = {[0] = 0, [1] = 0}
                    local miss_history = data.miss_sides or {[0] = 0, [1] = 0}
                    
                    
                    local bf_side = miss_history[0] > miss_history[1] and 1 or 0
                    
                    
                    if math.abs(miss_history[0] - miss_history[1]) < 2 then
                        local time_based = math.floor(now * 3) % 2
                        bf_side = time_based
                    end
                    
                    local bf_conf = 0.38 + math.random() * 0.08  
                    table.insert(strategies, {name = "bruteforce", side = bf_side, conf = bf_conf})
                    end
                    
                    
                    if data.hit_sides and (data.hit_sides[0] + data.hit_sides[1]) >= 5 then
                    local total_hits = data.hit_sides[0] + data.hit_sides[1]
                    local side_0_rate = data.hit_sides[0] / total_hits
                    local side_1_rate = data.hit_sides[1] / total_hits
                    
                    
                    if math.abs(side_0_rate - side_1_rate) > 0.3 then
                        
                        local counter_side = side_0_rate > side_1_rate and 0 or 1
                        local counter_conf = 0.42 + math.abs(side_0_rate - side_1_rate) * 0.3
                        
                        
                        if current_bt >= 8 then
                        table.insert(strategies, {name = "counter", side = counter_side, conf = counter_conf})
                        end
                    end
                    end
                    
                    
                    if #strategies > 0 then
                    
                    local pattern_weights = {
                        fixed_delay = {phase = 1.6, momentum = 0.7, bias = 0.5, extrapolate = 1.4, history_trust = 0.9, history_flip = 0.6},
                        sequence = {phase = 1.5, momentum = 0.6, bias = 0.6, extrapolate = 1.5, history_trust = 1.0, history_flip = 0.5},
                        tight_random = {phase = 0.5, momentum = 1.1, bias = 1.3, extrapolate = 0.8, history_trust = 1.2, history_flip = 1.1},
                        variable_delay = {phase = 0.7, momentum = 1.2, bias = 1.1, extrapolate = 0.9, history_trust = 1.1, history_flip = 1.0},
                        chaotic = {phase = 0.2, momentum = 0.4, bias = 1.5, extrapolate = 0.4, bruteforce = 1.6, counter = 1.4, chaotic_observation = 1.3},
                        reactive = {phase = 0.3, momentum = 0.5, bias = 1.4, extrapolate = 0.5, counter = 1.5, chaotic_observation = 1.2},
                        direct_observation = {phase = 0.6, momentum = 0.8, bias = 1.0, chaotic_observation = 1.5},
                        learning = {phase = 0.8, momentum = 1.0, bias = 1.0, extrapolate = 1.0},
                    }
                    
                    local weights = pattern_weights[side_pattern] or pattern_weights.learning
                    
                    
                    local bt_scale = 1.0
                    if current_bt >= 16 then
                        bt_scale = 0.6
                        
                        weights.bias = (weights.bias or 1.0) * 1.4
                        weights.high_bt_special = 1.5
                        weights.phase = (weights.phase or 1.0) * 0.4
                    elseif current_bt >= 12 then
                        bt_scale = 0.75
                        weights.high_bt_special = 1.3
                        weights.extrapolate = (weights.extrapolate or 1.0) * 0.7
                    elseif current_bt >= 8 then
                        bt_scale = 0.9
                    end
                    
                    
                    local weighted_side_0 = 0
                    local weighted_side_1 = 0
                    local total_weight = 0
                    local strategy_contributions = {}
                    
                    for _, strat in ipairs(strategies) do
                        local base_weight = (weights[strat.name] or 1.0) * strat.conf
                        local final_weight = base_weight * bt_scale
                        
                        
                        if strat.name == "high_bt_special" then
                            if current_bt >= 18 then
                                final_weight = final_weight * 1.4
                            elseif current_bt >= 15 then
                                final_weight = final_weight * 1.2
                            end
                        end
                        
                        
                        if strat.name == "chaotic_observation" and (side_pattern == "chaotic" or side_pattern == "reactive") then
                            final_weight = final_weight * 1.25
                        end
                        
                        
                        if strat.name == "phase" and data.delay_variance then
                            local cv = data.delay_variance / math.max(1, data.detected_delay or 4)
                            if cv > 0.4 then
                                final_weight = final_weight * (1 - cv * 0.5)
                            end
                        end
                        
                        
                        table.insert(strategy_contributions, {
                            name = strat.name,
                            side = strat.side,
                            weight = final_weight,
                            original_conf = strat.conf
                        })
                        
                        if strat.side == 0 then
                            weighted_side_0 = weighted_side_0 + final_weight
                        else
                            weighted_side_1 = weighted_side_1 + final_weight
                        end
                        total_weight = total_weight + final_weight
                    end
                    
                    if total_weight > 0.01 then
                        
                        local margin = math.abs(weighted_side_1 - weighted_side_0)
                        local margin_ratio = margin / total_weight
                        
                        predicted_side = weighted_side_1 > weighted_side_0 and 1 or 0
                        
                        
                        local base_conf = 0.30 + margin_ratio * 0.45
                        
                        
                        local agreeing_strategies = 0
                        local disagreeing_strategies = 0
                        local strong_agreements = 0
                        
                        for _, contrib in ipairs(strategy_contributions) do
                            if contrib.side == predicted_side then
                                agreeing_strategies = agreeing_strategies + 1
                                if contrib.weight > 0.3 then
                                    strong_agreements = strong_agreements + 1
                                end
                            else
                                disagreeing_strategies = disagreeing_strategies + 1
                            end
                        end
                        
                        
                        local total_strats = #strategies
                        if total_strats >= 4 then
                            local agreement_ratio = agreeing_strategies / total_strats
                            if agreement_ratio >= 0.75 then
                                base_conf = base_conf * 1.15
                            elseif agreement_ratio >= 0.60 then
                                base_conf = base_conf * 1.08
                            elseif agreement_ratio < 0.40 then
                                base_conf = base_conf * 0.85
                            end
                        end
                        
                        
                        if strong_agreements >= 3 then
                            base_conf = base_conf * 1.10
                        elseif strong_agreements >= 2 then
                            base_conf = base_conf * 1.05
                        end
                        
                        
                        if disagreeing_strategies >= 3 and margin_ratio < 0.3 then
                            base_conf = base_conf * 0.80
                        end
                        
                        
                        if data.hit_count + data.miss_count >= 3 then
                            local hit_rate = data.hit_count / (data.hit_count + data.miss_count)
                            if hit_rate > 0.55 then
                                base_conf = base_conf * (1 + (hit_rate - 0.55) * 0.4)
                            elseif hit_rate < 0.35 then
                                base_conf = base_conf * (0.85 + hit_rate * 0.4)
                            end
                        end
                        
                        side_confidence = base_conf
                        
                        
                        data.last_strategy_fusion = {
                            contributions = strategy_contributions,
                            predicted_side = predicted_side,
                            margin = margin,
                            margin_ratio = margin_ratio,
                            confidence = side_confidence,
                            bt = current_bt,
                            pattern = side_pattern
                        }
                    else
                        
                        local observed_side, obs_conf = self:detect_side_early(player)
                        predicted_side = observed_side
                        side_confidence = obs_conf * 0.8
                    end
                    else
                    
                    local observed_side, obs_conf = self:detect_side_early(player)
                    predicted_side = observed_side
                    side_confidence = math.max(0.35, obs_conf * 0.75)
                    end
                    
                    
                    local original_confidence = side_confidence
                    
                    if current_bt >= 20 then
                        
                        side_confidence = math.min(side_confidence, 0.25)
                        
                        
                        if math.random() < 0.20 then
                            predicted_side = 1 - predicted_side
                            side_confidence = side_confidence * 0.70
                        end
                    elseif current_bt >= 16 then
                        side_confidence = math.min(side_confidence, 0.35)
                        
                        
                        if math.random() < 0.12 then
                            predicted_side = 1 - predicted_side
                            side_confidence = side_confidence * 0.75
                        end
                    elseif current_bt >= 13 then
                        side_confidence = math.min(side_confidence, 0.48)
                    elseif current_bt >= 10 then
                        side_confidence = math.min(side_confidence, 0.60)
                    elseif current_bt >= 7 then
                        side_confidence = math.min(side_confidence, 0.72)
                    end
                    
                    
                    if side_pattern == "chaotic" or side_pattern == "reactive" then
                        side_confidence = math.min(side_confidence, 0.55)
                    elseif side_pattern == "variable_delay" then
                        side_confidence = math.min(side_confidence, 0.65)
                    end
                    
                    
                    if current_bt >= 8 then
                        data.used_extrapolation = true
                        data.extrapolation_bt = current_bt
                        data.extrapolation_confidence_drop = original_confidence - side_confidence
                    end
                    
                    
                    side_confidence = func.fclamp(side_confidence, 0.18, 0.82)

                    
                    local predicted_yaw = data.jitter_center or data.last_yaw or 0
                    local yaw_confidence = 0.50
                    
                    
                    local learned_offset, learned_conf = self:get_learned_offset(player)
                    
                    if jitter_pattern == "no_jitter" then
                    predicted_yaw = data.last_yaw or 0
                    yaw_confidence = 0.85
                    elseif jitter_pattern == "center" then
                    predicted_yaw = data.jitter_center or 0
                    yaw_confidence = 0.72
                    elseif jitter_pattern == "offset" then
                    predicted_yaw = (data.jitter_center or 0) + (learned_offset * 0.5)
                    yaw_confidence = 0.65
                    elseif jitter_pattern == "medium" or jitter_pattern == "wide" then
                    predicted_yaw = data.jitter_center or 0
                    yaw_confidence = 0.48
                    
                    if #data.hit_yaws >= 2 then
                        local avg_hit = 0
                        for _, hy in ipairs(data.hit_yaws) do avg_hit = avg_hit + hy end
                        avg_hit = avg_hit / #data.hit_yaws
                        predicted_yaw = avg_hit * 0.6 + predicted_yaw * 0.4
                        yaw_confidence = 0.55
                    end
                    end
                    
                    
                    if pe.total_predictions >= 4 and pe.avg_yaw_error then
                    local error_correction = (pe.avg_yaw_error > 45) and 0.3 or 0
                    yaw_confidence = yaw_confidence * (1 - error_correction)
                    end
                    
                    
                    local bt_penalty = data.high_backtrack_penalty or 0
                    if bt_penalty > 0.15 then
                    yaw_confidence = yaw_confidence * (1 - bt_penalty * 0.6)
                    end
                    if side_pattern == "chaotic" or side_pattern == "reactive" then
                        
                        local current_side, current_conf = self:detect_side_early(player)
                        
                        
                        local momentum = 0
                        if data.side_history and #data.side_history >= 3 then
                            local recent_0 = 0
                            local recent_1 = 0
                            local check_count = math.min(5, #data.side_history)
                            
                            for i = #data.side_history, math.max(1, #data.side_history - check_count + 1), -1 do
                                local entry = data.side_history[i]
                                if entry.side == 0 then
                                    recent_0 = recent_0 + 1
                                else
                                    recent_1 = recent_1 + 1
                                end
                            end
                            
                            momentum = (recent_1 - recent_0) / check_count
                        end
                        
                        
                        local chaos_side = current_side
                        local chaos_conf = current_conf * 0.85  
                        
                        
                        if math.abs(momentum) > 0.4 then
                            chaos_side = momentum > 0 and 1 or 0
                            chaos_conf = chaos_conf + 0.08
                        end
                        
                        
                        table.insert(strategies, {
                            name = "chaotic_observation",
                            side = chaos_side,
                            conf = chaos_conf
                        })
                    end
                    
                    local predicted_body = 0
                    local body_conf_final = 0.50
                    
                    local base_body_amount = 58
                    local side_for_body = predicted_side
                    
                    if body_mode == "synced" then
                    predicted_body = side_for_body == 1 and base_body_amount or -base_body_amount
                    body_conf_final = 0.78
                    
                    if current_bt >= 10 then
                        body_conf_final = body_conf_final * 0.80
                    elseif current_bt >= 8 then
                        body_conf_final = body_conf_final * 0.90
                    end
                    
                    elseif body_mode == "opposite" then
                    predicted_body = side_for_body == 1 and -base_body_amount or base_body_amount
                    body_conf_final = 0.75
                    
                    if current_bt >= 10 then
                        body_conf_final = body_conf_final * 0.78
                    end
                    
                    elseif body_mode == "static" then
                    predicted_body = data.last_body or (side_for_body == 1 and base_body_amount or -base_body_amount)
                    body_conf_final = 0.72
                    
                    elseif body_mode == "jitter" then
                    predicted_body = side_for_body == 1 and base_body_amount or -base_body_amount
                    body_conf_final = 0.55
                    
                    if current_bt >= 8 then
                        body_conf_final = body_conf_final * 0.70
                    end
                    else
                    predicted_body = side_for_body == 1 and base_body_amount or -base_body_amount
                    body_conf_final = 0.45
                    end
                    
                    predicted_body = math.floor(math.max(-60, math.min(60, predicted_body)) + 0.5)
                    
                    if predicted_side == 1 and predicted_body <= 0 then
                    predicted_body = 58
                    elseif predicted_side == 0 and predicted_body >= 0 then
                    predicted_body = -58
                    end
                    
                    if (data.high_backtrack_penalty or 0) > 0.2 then
                    body_conf_final = body_conf_final * (1 - data.high_backtrack_penalty * 0.5)
                    end
                    
                    
                    local should_bruteforce = data.resolver_state == "bruteforce" and data.consecutive_misses >= 3
                    
                    if not should_bruteforce and pe.yaw_accuracy < 0.25 and pe.total_predictions >= 6 then
                    should_bruteforce = true
                    end
                    
                    if should_bruteforce then
                    local bf_offsets = {58, 45, 30, 52, 40, 55}
                    local bf_stage = (data.bruteforce_stage or 0) % #bf_offsets
                    local bf_offset = bf_offsets[bf_stage + 1]
                    
                    if predicted_side == 0 then
                        predicted_body = -bf_offset
                    else
                        predicted_body = bf_offset
                    end
                    
                    yaw_confidence = yaw_confidence * 0.72
                    end
                    
                    if #data.corrections >= 1 then
                    local recent_corr = data.corrections[#data.corrections]
                    if now - recent_corr.time < 2.0 then
                        yaw_confidence = yaw_confidence * 0.90
                    end
                    end
                    
                    predicted_yaw = func.aa_clamp(predicted_yaw)
                    
                    pe.last_predicted_yaw = predicted_yaw
                    pe.last_predicted_side = predicted_side
                    
                    data.predicted_side = predicted_side
                    data.predicted_yaw = predicted_yaw
                    data.predicted_body = predicted_body
                    
                    
                    
                    
                    local error_penalty = 1.0 - math.pow(pe.correction_factor, 1.5) * 0.35
                    error_penalty = math.max(0.50, error_penalty)
                    
                    
                    local side_acc_bonus = math.sqrt(pe.side_accuracy) * 0.08
                    local yaw_acc_bonus = math.sqrt(pe.yaw_accuracy) * 0.06
                    local accuracy_bonus = side_acc_bonus + yaw_acc_bonus
                    
                    
                    local hit_ratio = data.hit_count / math.max(1, data.hit_count + data.miss_count)
                    local hit_bonus = math.min(0.18, hit_ratio * 0.25)
                    
                    
                    local recency_bonus = 0
                    if data.last_hit_time and data.last_hit_time > 0 then
                        local time_since_hit = now - data.last_hit_time
                        if time_since_hit < 1.5 then
                            recency_bonus = 0.08 * (1.5 - time_since_hit) / 1.5
                        end
                    end
                    
                    
                    local bt_recommendation, bt_multiplier = self:get_bt_recommendation(player, math.floor(current_bt))
                    bt_multiplier = bt_multiplier or 1.0
                    
                    
                    local bt_recommendation_mult = 1.0
                    if bt_recommendation == "avoid" then
                        bt_recommendation_mult = 0.50
                    elseif bt_recommendation == "caution" then
                        bt_recommendation_mult = 0.72
                    elseif bt_recommendation == "confident" then
                        bt_recommendation_mult = 1.12
                    elseif bt_recommendation == "learning" then
                        bt_recommendation_mult = 0.88
                    end
                    
                    
                    side_confidence = side_confidence * bt_recommendation_mult
                    yaw_confidence = yaw_confidence * bt_recommendation_mult
                    body_conf_final = body_conf_final * bt_recommendation_mult
                    
                    
                    local raw_bt_penalty = data.high_backtrack_penalty or 0
                    local backtrack_penalty = 1.0
                    
                    
                    if raw_bt_penalty > 0.01 then
                        
                        local normalized_penalty = math.min(1.0, raw_bt_penalty / 0.75)
                        
                        backtrack_penalty = 1.0 - (normalized_penalty * normalized_penalty * 0.75)
                        backtrack_penalty = math.max(0.18, backtrack_penalty)
                    end
                    
                    
                    local bt_stats = data.backtrack_stats
                    if bt_stats and bt_stats.consecutive_high and bt_stats.consecutive_high >= 2 then
                        local consec_factor = math.min(1.0, bt_stats.consecutive_high / 6)
                        local consec_mult = 1.0 - (consec_factor * 0.35)
                        backtrack_penalty = backtrack_penalty * consec_mult
                    end
                    
                    
                    if bt_stats and bt_stats.avg_backtrack then
                        local avg_bt = bt_stats.avg_backtrack
                        if avg_bt > 8 then
                            local excess = math.min(10, avg_bt - 8)
                            local avg_mult = 1.0 - (excess * 0.035)
                            backtrack_penalty = backtrack_penalty * avg_mult
                        end
                    end
                    
                    
                    backtrack_penalty = math.max(0.12, backtrack_penalty)
                    
                    local ping_adjusted_conf = combined_conf
                    
                    if current_bt >= 4 then
                        local total_comp, stab_factor, is_stable = self.ping_compensation:get_total_compensation(math.floor(current_bt), player_id)
                        
                        
                        ping_adjusted_conf = self.ping_compensation:adjust_confidence_for_compensation(combined_conf, total_comp, player_id)
                        
                        
                        data.last_total_compensation = total_comp
                        data.last_ping_stability = stab_factor
                        data.ping_stable = is_stable
                        
                        
                        if not is_stable then
                            ping_adjusted_conf = ping_adjusted_conf * 0.88
                        end
                    end
                    
                    combined_conf = ping_adjusted_conf

                    
                    
                    local side_weight = 0.40
                    local yaw_weight = 0.30
                    local body_weight = 0.30
                    
                    
                    if side_pattern == "fixed_delay" or side_pattern == "sequence" then
                        side_weight = 0.48
                        yaw_weight = 0.25
                        body_weight = 0.27
                    elseif side_pattern == "chaotic" or side_pattern == "reactive" then
                        side_weight = 0.32
                        yaw_weight = 0.35
                        body_weight = 0.33
                    end
                    
                    
                    local total_weight = side_weight + yaw_weight + body_weight
                    side_weight = side_weight / total_weight
                    yaw_weight = yaw_weight / total_weight
                    body_weight = body_weight / total_weight
                    
                    
                    local combined_conf = (side_confidence * side_weight) + 
                                        (yaw_confidence * yaw_weight) + 
                                        (body_conf_final * body_weight)
                    
                    
                    local state_conf = data.state_confidence or 0.5
                    combined_conf = combined_conf * (0.5 + state_conf * 0.5)
                    
                    
                    combined_conf = combined_conf * error_penalty
                    combined_conf = combined_conf * backtrack_penalty
                    combined_conf = combined_conf + accuracy_bonus + hit_bonus + recency_bonus
                    
                    
                    local final_bt_penalty = data.high_backtrack_penalty or 0
                    local conf_cap = 1.0
                    
                    if final_bt_penalty > 0.05 then
                        
                        
                        local normalized = (final_bt_penalty - 0.05) / 0.70
                        normalized = math.min(1.0, normalized)
                        conf_cap = 0.75 - (normalized * normalized * 0.60)
                        conf_cap = math.max(0.15, conf_cap)
                    end
                    
                    combined_conf = math.min(combined_conf, conf_cap)
                    
                    
                    if data.resolver_state == "bruteforce" then
                        
                        combined_conf = math.min(combined_conf, 0.55)
                        
                        combined_conf = math.max(combined_conf, 0.30)
                    end
                    
                    
                    if data.consecutive_misses and data.consecutive_misses >= 2 then
                        local miss_penalty = 1.0 - math.min(0.35, data.consecutive_misses * 0.08)
                        combined_conf = combined_conf * miss_penalty
                    end
                    
                    
                    combined_conf = func.fclamp(combined_conf, 0.18, 0.90)
                    
                    
                    data.cached_prediction = {
                        side = predicted_side,
                        yaw = predicted_yaw,
                        body = predicted_body,
                        conf = combined_conf,
                        bt_penalty = final_bt_penalty,
                        state = data.resolver_state,
                        pattern = side_pattern,
                    }
                    data.cache_time = now
                    
                    return predicted_side, predicted_yaw, combined_conf
                end,
                
                track_bt_success = function(self, player, backtrack_ticks, hit)
                    local player_id = tostring(player)
                    local data = self.players[player_id]
                    if not data then return end
                    
                    if not data.bt_success then
                        data.bt_success = {
                            ranges = {
                                {min = 0, max = 5, hits = 0, total = 0},   
                                {min = 6, max = 9, hits = 0, total = 0},   
                                {min = 10, max = 13, hits = 0, total = 0}, 
                                {min = 14, max = 25, hits = 0, total = 0}, 
                            },
                            best_range = nil,
                            worst_range = nil,
                        }
                    end
                    
                    
                    for _, range in ipairs(data.bt_success.ranges) do
                        if backtrack_ticks >= range.min and backtrack_ticks <= range.max then
                            range.total = range.total + 1
                            if hit then
                                range.hits = range.hits + 1
                            end
                            break
                        end
                    end
                    
                    
                    local best_rate, worst_rate = -1, 2
                    for _, range in ipairs(data.bt_success.ranges) do
                        if range.total >= 3 then
                            local rate = range.hits / range.total
                            if rate > best_rate then
                                best_rate = rate
                                data.bt_success.best_range = range
                            end
                            if rate < worst_rate then
                                worst_rate = rate
                                data.bt_success.worst_range = range
                            end
                        end
                    end
                end,
                
                learn_bt_prediction_result = function(self, player, backtrack_ticks, predicted_side, actual_side, hit)
                    local player_id = tostring(player)
                    local data = self.players[player_id]
                    if not data then return end
                    
                    
                    if not data.bt_prediction_accuracy then
                        data.bt_prediction_accuracy = {}
                        for i = 0, 20, 4 do
                            data.bt_prediction_accuracy[i] = {correct = 0, total = 0}
                        end
                    end
                    
                    
                    local bucket = math.min(20, math.floor(backtrack_ticks / 4) * 4)
                    local acc = data.bt_prediction_accuracy[bucket]
                    if not acc then
                        acc = {correct = 0, total = 0}
                        data.bt_prediction_accuracy[bucket] = acc
                    end
                    
                    acc.total = acc.total + 1
                    
                    
                    
                    
                    if hit then
                        acc.correct = acc.correct + 1
                    elseif actual_side ~= nil and predicted_side == actual_side then
                        
                        acc.correct = acc.correct + 0.5  
                    end
                    
                    
                    if acc.total > 20 then
                        acc.correct = acc.correct * 0.9
                        acc.total = acc.total * 0.9
                    end
                end,        
                
                get_bt_recommendation = function(self, player, backtrack_ticks)
                    local player_id = tostring(player)
                    local data = self.players[player_id]
                    if not data or not data.bt_success then return "normal", 1.0 end
                    
                    
                    for _, range in ipairs(data.bt_success.ranges) do
                        if backtrack_ticks >= range.min and backtrack_ticks <= range.max then
                            if range.total < 3 then
                                return "learning", 0.9
                            end
                            
                            local rate = range.hits / range.total
                            
                            if rate < 0.25 then
                                return "avoid", 0.5  
                            elseif rate < 0.40 then
                                return "caution", 0.7
                            elseif rate > 0.60 then
                                return "confident", 1.1
                            else
                                return "normal", 1.0
                            end
                        end
                    end
                    
                    return "unknown", 0.8
                end,
                
                
record_result = function(self, player, hit, hitgroup)
    local player_id = tostring(player)
    local data = self.players[player_id]
    if not data then return end
    
    local now = globals.realtime()
    data.last_shot_time = now
    data.shots_this_engagement = data.shots_this_engagement + 1
    
    local pe = data.prediction_errors
    
    
    local shot_bt = 0
    if data.backtrack_history and #data.backtrack_history > 0 then
        shot_bt = data.backtrack_history[#data.backtrack_history].ticks or 0
    end
    
    
    self:track_bt_success(player, shot_bt, hit)
    
    
    local predicted_side = data.predicted_side
    local actual_side = data.current_side
    self:learn_bt_prediction_result(player, shot_bt, predicted_side, actual_side, hit)
    
    
    local used_yaw_offset = 0
    if data.predicted_yaw and data.jitter_center then
        used_yaw_offset = func.aa_clamp(data.predicted_yaw - data.jitter_center)
    end
    
    
    if not data.large_yaw_error_tracking then
        data.large_yaw_error_tracking = {
            consecutive_large_errors = 0,
            last_error_side = nil,
            flip_next = false,
            last_flip_time = 0,
        }
    end
    
    local lyet = data.large_yaw_error_tracking
    local side_confidence = 0.50  
    if data.force_flip_side and data.flip_target_side ~= nil then
        predicted_side = data.flip_target_side
        side_confidence = 0.48  
        data.force_flip_side = false  
        data.flip_target_side = nil
    end
    
    
    if data.ultra_reactive then
        
        local tick = globals.tickcount()
        
        
        if tick % 3 == 0 and data.consecutive_misses >= 2 then
            
            if math.random() < 0.25 then
                predicted_side = 1 - predicted_side
                side_confidence = side_confidence * 0.85
            end
        end
        
        
        side_confidence = side_confidence * 0.80
    end

    if hit then
        
        data.hit_count = data.hit_count + 1
        data.miss_count = math.max(0, data.miss_count - 0.5)
        data.consecutive_misses = 0
        data.bruteforce_stage = 0
        data.last_hit_time = now
        
        
        lyet.consecutive_large_errors = 0
        lyet.flip_next = false
        
        
        if data.predicted_yaw then
            table.insert(data.hit_yaws, data.predicted_yaw)
            while #data.hit_yaws > 12 do table.remove(data.hit_yaws, 1) end
        end
        
        
        if data.predicted_body then
            table.insert(data.hit_body_yaws, {
                body = data.predicted_body,
                side = data.predicted_side,
                time = now
            })
            while #data.hit_body_yaws > 12 do table.remove(data.hit_body_yaws, 1) end
        end
        
        
        local side = data.predicted_side or 0
        data.hit_sides[side] = (data.hit_sides[side] or 0) + 1
        
        
        local offset_key = math.floor(used_yaw_offset / 10) * 10
        data.offset_weights[offset_key] = (data.offset_weights[offset_key] or 0) + data.learning_rate * 1.5
        table.insert(data.successful_yaw_offsets, used_yaw_offset)
        while #data.successful_yaw_offsets > 15 do table.remove(data.successful_yaw_offsets, 1) end
        
        
        pe.consecutive_yaw_misses = 0
        pe.consecutive_side_misses = 0
        pe.correction_factor = math.max(0, (pe.correction_factor or 0) - 0.12)
        
        
        local total = data.hit_count + data.miss_count
        if total > 0 then
            pe.side_accuracy = data.hit_count / total
        end
        
        
        if shot_bt >= 10 and data.used_extrapolation then
            data.high_backtrack_penalty = math.max(0, (data.high_backtrack_penalty or 0) - 0.15)
        end
        
        if shot_bt >= 13 and data.used_high_bt_prediction then
            self:learn_high_bt_result(player, shot_bt, data.predicted_side, hit)
        end
        
        data.used_high_bt_prediction = false
        
        
        if data.hit_count >= 2 and data.hit_count / math.max(1, total) > 0.45 then
            data.state_confidence = math.min(0.85, (data.state_confidence or 0.5) + 0.08)
        elseif data.resolver_state == "bruteforce" then
            data.state_confidence = 0.60
        end
        
        
        if data.adaptation_level then
            data.adaptation_level = math.max(0, data.adaptation_level - 0.1)
        end
        
    else
        
        data.miss_count = data.miss_count + 1
        data.consecutive_misses = data.consecutive_misses + 1
        
        
        
        local yaw_error = 0
        if data.predicted_yaw and data.last_yaw then
            yaw_error = math.abs(func.aa_clamp(data.predicted_yaw - data.last_yaw))
        end
        
        
        if yaw_error > 120 then
            lyet.consecutive_large_errors = lyet.consecutive_large_errors + 1
            lyet.last_error_side = data.predicted_side
            
            
            if lyet.consecutive_large_errors >= 1 then
                lyet.flip_next = true
                lyet.last_flip_time = now
            end
        else
            
            lyet.consecutive_large_errors = math.max(0, lyet.consecutive_large_errors - 0.5)
        end
        
        
        if data.predicted_yaw then
            table.insert(data.miss_yaws, data.predicted_yaw)
            while #data.miss_yaws > 12 do table.remove(data.miss_yaws, 1) end
        end
        
        
        if data.predicted_body then
            table.insert(data.miss_body_yaws, {
                body = data.predicted_body,
                side = data.predicted_side,
                time = now
            })
            while #data.miss_body_yaws > 12 do table.remove(data.miss_body_yaws, 1) end
        end
        
        
        local side = data.predicted_side or 0
        data.miss_sides[side] = (data.miss_sides[side] or 0) + 1
        
        
        local offset_key = math.floor(used_yaw_offset / 10) * 10
        data.offset_weights[offset_key] = (data.offset_weights[offset_key] or 0) - data.learning_rate * 0.8
        table.insert(data.failed_yaw_offsets, used_yaw_offset)
        while #data.failed_yaw_offsets > 15 do table.remove(data.failed_yaw_offsets, 1) end
        
        
        pe.consecutive_yaw_misses = (pe.consecutive_yaw_misses or 0) + 1
        pe.consecutive_side_misses = (pe.consecutive_side_misses or 0) + 1
        pe.correction_factor = math.min(1.0, (pe.correction_factor or 0) + 0.18)
        
        
        if data.consecutive_misses >= 2 then
            data.bruteforce_stage = (data.bruteforce_stage or 0) + 1
            data.last_bruteforce_time = now
        end
        
        
        if data.consecutive_misses >= 3 then
            data.resolver_state = "bruteforce"
            data.state_confidence = 0.45
        elseif data.consecutive_misses >= 2 then
            data.state_confidence = math.max(0.40, (data.state_confidence or 0.5) - 0.12)
        end
        
        
        if shot_bt >= 10 and data.used_extrapolation then
            data.high_backtrack_penalty = math.min(0.75, (data.high_backtrack_penalty or 0) + 0.12)
        end
        
        
        table.insert(data.corrections, {
            yaw = data.predicted_yaw,
            body = data.predicted_body,
            side = data.predicted_side,
            backtrack = shot_bt,
            time = now,
            yaw_error = yaw_error,  
        })
        while #data.corrections > 10 do table.remove(data.corrections, 1) end
    end
    
        if data.side_pattern == "reactive" or data.side_pattern == "chaotic" then
            
            data.force_flip_side = true
            data.flip_target_side = 1 - (data.predicted_side or 0)
            
            
            if data.consecutive_misses >= 3 then
                
                if math.random() < 0.40 then
                    data.flip_target_side = math.random(0, 1)
                end
            end
        end

    
    data.used_extrapolation = false
    
    
    data.cached_prediction = nil
end,
                
                
get_override = function(self, player)
    local player_id = tostring(player)
    local data = self.players[player_id]
    if not data then return nil end
    
    local now = globals.realtime()
    
    if now - data.last_update > 2.5 then return nil end
    
    
    local preset = self.weapon_presets and self.weapon_presets:get_current_preset()
    local is_pistol = preset and (preset.name == "Pistol" or preset.name == "Deagle")
    
    
    local side_pattern, side_conf = self:analyze_side_pattern(player)
    
    
    local jitter_pattern, jitter_conf = self:analyze_jitter_pattern(player)
    
    
    local xway_pred = self:predict_xway(player)
    if xway_pred and xway_pred.confidence > 0.45 then
        local xway_side = xway_pred.predicted_side
        local xway_body = xway_pred.predicted_body
        
        
        if xway_side == 1 and xway_body <= 0 then
            xway_body = 58
        elseif xway_side == 0 and xway_body >= 0 then
            xway_body = -58
        end
        
        return {
            predicted_side = xway_side,
            predicted_yaw = xway_pred.predicted_yaw or 0,
            body_adjustment = xway_body,
            confidence = xway_pred.confidence,
            body_confidence = xway_pred.confidence * 0.90,
            body_mode = "xway_" .. tostring(xway_pred.xway_count),
            pattern = "xway",
            side_pattern = "xway_" .. xway_pred.xway_count,
            backtrack = data.last_backtrack or 0,
            bruteforce_active = xway_pred.confidence < 0.40,
            resolver_state = "xway_prediction",
        }
    end
    
    
    local backtrack = data.last_backtrack or 0
    
    
    local predicted_side = data.current_side or 0
    local side_confidence = side_conf  
    
    
    
    if not data.large_yaw_error_tracking then
        data.large_yaw_error_tracking = {
            consecutive_large_errors = 0,
            last_error_side = nil,
            flip_next = false,
            last_flip_time = 0,
        }
    end
    
    local lyet = data.large_yaw_error_tracking
    
    
    if lyet.flip_next and (now - lyet.last_flip_time) < 5.0 then
        predicted_side = 1 - (lyet.last_error_side or predicted_side)
        lyet.flip_next = false
        side_confidence = 0.55  
    end
    
    
    if data.consecutive_misses and data.consecutive_misses >= 2 then
        
        if data.last_predicted_side ~= nil then
            predicted_side = 1 - data.last_predicted_side
            side_confidence = 0.45
        end
    end
    
    
    data.last_predicted_side = predicted_side
    
    
    if data.force_flip_side and data.flip_target_side ~= nil then
        predicted_side = data.flip_target_side
        side_confidence = 0.48  
        data.force_flip_side = false  
        data.flip_target_side = nil
    end
    
    local side_confidence = side_confidence or 0.50  

    
    if data.ultra_reactive then
        
        local tick = globals.tickcount()
        
        
        if tick % 3 == 0 and data.consecutive_misses and data.consecutive_misses >= 2 then
            
            if math.random() < 0.25 then
                predicted_side = 1 - predicted_side
                side_confidence = side_confidence * 0.85
            end
        end
        
        
        side_confidence = side_confidence * 0.80
    end
    
    
    if backtrack >= 10 then
        local high_bt_side, high_bt_conf = self:predict_high_backtrack(player, backtrack)
        if high_bt_conf > side_confidence * 0.8 then
            predicted_side = high_bt_side
            side_confidence = high_bt_conf
        end
    elseif backtrack >= 6 then
        local extrap_side, extrap_conf = self:extrapolate_side_for_backtrack(player, backtrack)
        if extrap_conf > side_confidence * 0.85 then
            predicted_side = extrap_side
            side_confidence = extrap_conf
        end
    end
    
    
    local predicted_body, body_conf, body_method = 0, 0.5, "default"
    
    if self.body_yaw_resolver then
        predicted_body, body_conf, body_method = self.body_yaw_resolver:predict(player, predicted_side)
    else
        
        predicted_body = predicted_side == 1 and 58 or -58
        body_conf = 0.50
        body_method = "fallback"
    end
    
    
    if predicted_side == 1 then
        if predicted_body <= 0 then
            predicted_body = 58
        elseif predicted_body < 45 then
            predicted_body = 58  
        end
    else
        if predicted_body >= 0 then
            predicted_body = -58
        elseif predicted_body > -45 then
            predicted_body = -58  
        end
    end
    
    
    predicted_body = math.max(-60, math.min(60, math.floor(predicted_body + 0.5)))
    
    
    local predicted_yaw = data.last_yaw or 0
    if data.yaw_stats and data.yaw_stats.mean then
        predicted_yaw = data.yaw_stats.mean
    end
    
    
    side_confidence = (type(side_confidence) == "number") and side_confidence or (type(side_conf) == "number" and side_conf or 0.50)
    body_conf = (type(body_conf) == "number") and body_conf or 0.50
    jitter_conf = (type(jitter_conf) == "number") and jitter_conf or 0.50

    local combined_conf = (side_confidence * 0.55 + body_conf * 0.30 + jitter_conf * 0.15)
    
    
    if side_pattern == "fixed_delay" or side_pattern == "sequence" then
        combined_conf = combined_conf * 1.10
    elseif side_pattern == "chaotic" or side_pattern == "reactive" then
        combined_conf = combined_conf * 0.75
    end
    
    
    if backtrack >= 15 then
        combined_conf = combined_conf * 0.50
    elseif backtrack >= 12 then
        combined_conf = combined_conf * 0.65
    elseif backtrack >= 8 then
        combined_conf = combined_conf * 0.82
    end
    
    
    local bruteforce_active = false
    if data.consecutive_misses and data.consecutive_misses >= 2 then
        bruteforce_active = true
        combined_conf = combined_conf * 0.80
    end
    
    
    local resolver_state = "normal"
    if bruteforce_active then
        resolver_state = "bruteforce"
    elseif side_pattern == "reactive" or side_pattern == "chaotic" then
        resolver_state = "reactive"
    elseif data.state_confidence and data.state_confidence < 0.45 then
        resolver_state = "learning"
    elseif combined_conf > 0.70 then
        resolver_state = "confident"
    end
    
    combined_conf = func.fclamp(combined_conf, 0.20, 0.85)
    
    return {
        predicted_side = predicted_side,
        predicted_yaw = predicted_yaw,
        body_adjustment = predicted_body,
        confidence = combined_conf,
        body_confidence = body_conf,
        body_mode = body_method,
        pattern = jitter_pattern,
        side_pattern = side_pattern,
        backtrack = backtrack,
        bruteforce_active = bruteforce_active,
        resolver_state = resolver_state,
    }
end,
                is_high_backtrack = function(self, player, backtrack_ticks)
                    local player_id = tostring(player)
                    local data = self.players[player_id]
                    if not data then return false end
                    
                    local now = globals.realtime()
                    
                    
                    if not data.backtrack_history then
                    data.backtrack_history = {}
                    end
                    if not data.backtrack_stats then
                    data.backtrack_stats = {
                        avg_backtrack = 0,
                        max_recent = 0,
                        high_bt_shots = 0,
                        total_tracked = 0,
                        last_high_bt_time = 0,
                        consecutive_high = 0,
                        adaptive_threshold = 10,
                    }
                    end
                    
                    local stats = data.backtrack_stats
                    
                    
                    table.insert(data.backtrack_history, {
                    ticks = backtrack_ticks,
                    time = now
                    })
                    
                    
                    while #data.backtrack_history > 20 do
                    table.remove(data.backtrack_history, 1)
                    end
                    
                    
                    local sum = 0
                    local max_bt = 0
                    local recent_high_count = 0
                    local recent_window = math.min(10, #data.backtrack_history)
                    
                    for i = #data.backtrack_history, math.max(1, #data.backtrack_history - recent_window + 1), -1 do
                    local entry = data.backtrack_history[i]
                    sum = sum + entry.ticks
                    max_bt = math.max(max_bt, entry.ticks)
                    if entry.ticks > 8 then
                        recent_high_count = recent_high_count + 1
                    end
                    end
                    
                    stats.avg_backtrack = sum / math.max(1, recent_window)
                    stats.max_recent = max_bt
                    stats.total_tracked = stats.total_tracked + 1
                    
                    
                    if backtrack_ticks > 8 then
                    stats.consecutive_high = stats.consecutive_high + 1
                    stats.last_high_bt_time = now
                    stats.high_bt_shots = stats.high_bt_shots + 1
                    else
                    stats.consecutive_high = 0
                    end
                    
                    
                    
                    if stats.avg_backtrack > 10 and recent_window >= 5 then
                    stats.adaptive_threshold = math.max(8, stats.avg_backtrack * 0.9)
                    else
                    stats.adaptive_threshold = 10
                    end
                    
                    
                    local base_penalty = 0
                    local is_high = false
                    
                    local bt_acc = data.bt_prediction_accuracy and data.bt_prediction_accuracy[math.min(20, math.floor(backtrack_ticks / 4) * 4)]
                    local our_accuracy = 0.5  
                    if bt_acc and bt_acc.total >= 3 then
                        our_accuracy = bt_acc.correct / bt_acc.total
                    end
                    
                    
                    if backtrack_ticks >= 18 then
                        base_penalty = 0.60  
                        is_high = true
                    elseif backtrack_ticks >= 15 then
                        base_penalty = 0.50  
                        is_high = true
                    elseif backtrack_ticks >= 12 then
                        base_penalty = 0.38  
                        is_high = true
                    elseif backtrack_ticks >= 10 then
                        base_penalty = 0.28  
                        is_high = true
                    elseif backtrack_ticks >= 8 then
                        base_penalty = 0.15  
                        is_high = false
                    elseif backtrack_ticks >= 6 then
                        base_penalty = 0.08  
                        is_high = false
                    else
                        base_penalty = 0
                        is_high = false
                    end
                    
                    
                    if our_accuracy > 0.55 and bt_acc and bt_acc.total >= 5 then
                        
                        base_penalty = base_penalty * (1.0 - (our_accuracy - 0.5) * 1.2)
                        base_penalty = math.max(0.05, base_penalty)
                    elseif our_accuracy < 0.35 and bt_acc and bt_acc.total >= 5 then
                        
                        base_penalty = math.min(0.75, base_penalty * 1.3)
                    end
                    
                    
                    local multiplier = 1.0
                    if stats.consecutive_high >= 4 then
                        multiplier = 1.15
                    elseif stats.consecutive_high >= 2 then
                        multiplier = 1.08
                    end
                    
                    
                    local new_penalty = math.min(0.75, base_penalty * multiplier)
                    local current_penalty = data.high_backtrack_penalty or 0
                    
                    
                    if new_penalty > current_penalty then
                        data.high_backtrack_penalty = current_penalty + (new_penalty - current_penalty) * 0.5
                    else
                        local decay_rate = 0.12
                        if stats.consecutive_high == 0 and backtrack_ticks < 6 then
                            decay_rate = 0.20
                        end
                        data.high_backtrack_penalty = current_penalty + (new_penalty - current_penalty) * decay_rate
                    end
                    
                    data.high_backtrack_penalty = func.fclamp(data.high_backtrack_penalty, 0, 0.75)
                    
                    return is_high
                end,
                
                cleanup = function(self)
                    local now = globals.realtime()
                    local players_to_remove = {}
                    
                    for player_id, data in pairs(self.players) do
                        if now - data.last_update > 25.0 then
                            table.insert(players_to_remove, player_id)
                        end
                    end
                    
                    for _, player_id in ipairs(players_to_remove) do
                        self.players[player_id] = nil
                    end
                    
                    
                    if self.ping_compensation and self.ping_compensation.cleanup then
                        self.ping_compensation:cleanup()
                    end
                end,
            },
        
        
        fakelag = {
            players = {},
            
            init_player = function(self, player_id)
                if not self.players[player_id] then
                    self.players[player_id] = {
                        simtime_samples = {},
                        origin_samples = {},
                        velocity_samples = {},
                        last_simtime = 0,
                        last_origin = nil,
                        last_update = 0,
                        choke_amounts = {},
                        avg_choke = 0,
                        is_choking = false,
                        breaking_lc = false,
                        exploit_detected = false,
                        in_air = false,
                        air_time = 0,
                        hit_while_choking = 0,
                        miss_while_choking = 0,
                    }
                end
                return self.players[player_id]
            end,
            
            track_simtime = function(self, player)
                local player_id = tostring(player)
                local data = self:init_player(player_id)
                local now = globals.realtime()
                local tick = globals.tickcount()
                
                local simtime = entity.get_prop(player, "m_flSimulationTime") or 0
                local tickinterval = globals.tickinterval()
                local simtime_ticks = math.floor(simtime / tickinterval + 0.5)
                
                if data.last_simtime > 0 then
                    local delta = simtime_ticks - data.last_simtime
                    
                    if delta > 1 then
                        table.insert(data.choke_amounts, delta)
                        while #data.choke_amounts > 20 do
                            table.remove(data.choke_amounts, 1)
                        end
                        
                        
                        local sum = 0
                        for _, c in ipairs(data.choke_amounts) do sum = sum + c end
                        data.avg_choke = sum / #data.choke_amounts
                        
                        data.is_choking = delta >= 2
                    end
                    
                    
                    if delta < 0 or delta > 16 then
                        data.breaking_lc = true
                        data.exploit_detected = true
                    else
                        data.breaking_lc = false
                    end
                end
                
                data.last_simtime = simtime_ticks
                data.last_update = now
            end,
            
            track_origin = function(self, player)
                local player_id = tostring(player)
                local data = self:init_player(player_id)
                
                local ox, oy, oz = entity.get_prop(player, "m_vecOrigin")
                if not ox then return end
                
                local origin = vector(ox, oy, oz)
                
                if data.last_origin then
                    local dist = (origin - data.last_origin):length()
                    
                    
                    if dist > 64 then
                        data.breaking_lc = true
                        data.exploit_detected = true
                    end
                end
                
                data.last_origin = origin
            end,
            
            track_velocity = function(self, player)
                local player_id = tostring(player)
                local data = self:init_player(player_id)
                
                local vx, vy, vz = entity.get_prop(player, "m_vecVelocity")
                if not vx then return end
                
                table.insert(data.velocity_samples, {
                    x = vx, y = vy, z = vz,
                    time = globals.realtime()
                })
                
                while #data.velocity_samples > 15 do
                    table.remove(data.velocity_samples, 1)
                end
            end,
            
            track_air_state = function(self, player)
                local player_id = tostring(player)
                local data = self:init_player(player_id)
                
                local flags = entity.get_prop(player, "m_fFlags") or 0
                local in_air = bit.band(flags, 1) == 0
                
                if in_air and not data.in_air then
                    data.air_time = globals.realtime()
                end
                
                data.in_air = in_air
            end,
            
            record_result = function(self, player, hit, was_choking)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data then return end
                
                if was_choking then
                    if hit then
                        data.hit_while_choking = data.hit_while_choking + 1
                    else
                        data.miss_while_choking = data.miss_while_choking + 1
                    end
                end
            end,
            
            get_override = function(self, player)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data then return nil end
                
                return {
                    is_choking = data.is_choking,
                    avg_choke = data.avg_choke,
                    breaking_lc = data.breaking_lc,
                    exploit_detected = data.exploit_detected,
                    in_air = data.in_air,
                }
            end,
            
            cleanup = function(self)
                local now = globals.realtime()
                for player_id, data in pairs(self.players) do
                    if now - data.last_update > 30 then
                        self.players[player_id] = nil
                    end
                end
            end,
        },
        
        
        defensive = {
            players = {},
            min_samples = 2,  
              
                        init_player = function(self, player_id)
                            if not self.players[player_id] then
                                self.players[player_id] = {
                                    
                                    yaw_samples = {},           
                                    pitch_samples = {},         
                                    yaw_deltas = {},            
                                    pitch_deltas = {},          
                                    switch_times = {},          
                                    
                                    
                                    yaw_stats = { mean = 0, variance = 0, range = {min = 0, max = 0}, entropy = 0, autocorrelation = 0, direction_changes = 0 },
                                    pitch_stats = { mean = 0, variance = 0, range = {min = 0, max = 0}, is_static = false, favors_down = false, favors_up = false },
                                    
                                    
                                    last_yaw = nil,
                                    last_pitch = nil,
                                    last_update = 0,
                                    
                                    
                                    hit_yaws = {},              
                                    miss_yaws = {},             
                                    hit_pitches = {},           
                                    miss_pitches = {},          
                                    hit_count = 0,
                                    miss_count = 0,
                                    consecutive_misses = 0,
                                    last_hit_time = 0,
                                    
                                    
                                    yaw_randomness_score = 0,
                                    yaw_is_random = false,
                                    pitch_randomness_score = 0,
                                    pitch_is_random = false,
                                    
                                    
                                    successful_offsets = {},    
                                    failed_offsets = {},        
                                    offset_weights = {},
                                    learning_rate = 0.3,
                                    
                                    
                                    bruteforce_stage = 0,
                                    last_bruteforce_time = 0,
                                    bruteforce_yaw_offsets = {0, 20, -20, 40, -40, 60, -60, 80, -80, 100, -100, 120, -120},
                                    bruteforce_pitch_offsets = {89, -89, 75, -75, 60, -60, 45, -45, 30, -30, 0},
                                    bruteforce_cooldown = 0,
                                    
                                    
                                    predicted_yaw = 0,
                                    predicted_pitch = 0,
                                    prediction_method = "center",
                                    confidence = 0.5,
                                    yaw_prediction = nil,
                                    pitch_prediction = nil,
                                    prediction_state = nil,
                                    
                                    
                                    yaw_frequency_bins = {},
                                    pitch_frequency_bins = {},
                                    
                                    
                                    velocity_yaw_correlation = 0,
                                    
                                    
                                    cached_prediction = nil,
                                    cache_time = 0,
                                    
                                    
                                    sample_max_age = 5.0,       
                                    cleanup_interval = 0.6,
                                    last_cleanup = 0,
                                }
                            end
                            return self.players[player_id]
                        end,
                        
            
                        sample = function(self, player, yaw, pitch)
                            local player_id = tostring(player)
                            local data = self:init_player(player_id)
                            local now = globals.realtime()
                            local tick = globals.tickcount()
                            
                            
                            if now - data.last_cleanup > data.cleanup_interval then
                                self:cleanup_stale_samples(player_id, now)
                                data.last_cleanup = now
                            end
                            
                            
                            local vx, vy = entity.get_prop(player, "m_vecVelocity")
                            local speed = math.sqrt((vx or 0)^2 + (vy or 0)^2)
                            local move_yaw = math.deg(math.atan2(vy or 0, vx or 0))
                            
                            
                            table.insert(data.yaw_samples, {
                                value = yaw,
                                time = now,
                                tick = tick,
                                speed = speed,
                                move_yaw = move_yaw,
                            })
                            
                            table.insert(data.pitch_samples, {
                                value = pitch,
                                time = now,
                                tick = tick,
                            })
                            
                            
                            if data.last_yaw then
                                local yaw_delta = func.aa_clamp(yaw - data.last_yaw)
                                table.insert(data.yaw_deltas, {
                                    value = yaw_delta,
                                    time = now,
                                })
                            end
                            
                            if data.last_pitch then
                                local pitch_delta = pitch - data.last_pitch
                                table.insert(data.pitch_deltas, {
                                    value = pitch_delta,
                                    time = now,
                                })
                            end
                            
                            data.last_yaw = yaw
                            data.last_pitch = pitch
                            data.last_update = now
                            data.cached_prediction = nil
                            
                            
                            while #data.yaw_samples > 50 do table.remove(data.yaw_samples, 1) end
                            while #data.pitch_samples > 45 do table.remove(data.pitch_samples, 1) end
                            while #data.yaw_deltas > 40 do table.remove(data.yaw_deltas, 1) end
                            while #data.pitch_deltas > 40 do table.remove(data.pitch_deltas, 1) end
                            while #data.switch_times > 30 do table.remove(data.switch_times, 1) end
                        end,
                        
                        
                        cleanup_stale_samples = function(self, player_id, now)
                            local data = self.players[player_id]
                            if not data then return end
                            
                            local max_age = data.sample_max_age or 5.0
                            local cutoff_time = now - max_age
                            
                            
                            local i = 1
                            while i <= #data.yaw_samples do
                                if data.yaw_samples[i].time < cutoff_time then
                                    table.remove(data.yaw_samples, i)
                                else
                                    i = i + 1
                                end
                            end
                            
                            
                            i = 1
                            while i <= #data.pitch_samples do
                                if data.pitch_samples[i].time < cutoff_time then
                                    table.remove(data.pitch_samples, i)
                                else
                                    i = i + 1
                                end
                            end
                            
                            
                            i = 1
                            while i <= #data.yaw_deltas do
                                if data.yaw_deltas[i].time and data.yaw_deltas[i].time < cutoff_time then
                                    table.remove(data.yaw_deltas, i)
                                else
                                    i = i + 1
                                end
                            end
                            
                            
                            i = 1
                            while i <= #data.pitch_deltas do
                                if data.pitch_deltas[i].time and data.pitch_deltas[i].time < cutoff_time then
                                    table.remove(data.pitch_deltas, i)
                                else
                                    i = i + 1
                                end
                            end
                            
                            
                            i = 1
                            while i <= #data.switch_times do
                                if data.switch_times[i] < cutoff_time then
                                    table.remove(data.switch_times, i)
                                else
                                    i = i + 1
                                end
                            end
                            
                            
                            local learning_cutoff = now - 10.0
                            
                            
                            while #data.hit_yaws > 25 do table.remove(data.hit_yaws, 1) end
                            while #data.miss_yaws > 25 do table.remove(data.miss_yaws, 1) end
                            while #data.hit_pitches > 25 do table.remove(data.hit_pitches, 1) end
                            while #data.miss_pitches > 20 do table.remove(data.miss_pitches, 1) end
                            
                            
                            while #data.successful_offsets > 35 do table.remove(data.successful_offsets, 1) end
                            while #data.failed_offsets > 25 do table.remove(data.failed_offsets, 1) end
                        end,
                        
            
            calculate_entropy = function(self, values, num_bins)
                if #values < 4 then return 0 end
                
                num_bins = num_bins or 12
                local min_val, max_val = values[1], values[1]
                for _, v in ipairs(values) do
                    min_val = math.min(min_val, v)
                    max_val = math.max(max_val, v)
                end
                
                local range = max_val - min_val
                if range < 1 then return 0 end
                
                local bin_size = range / num_bins
                local bins = {}
                for i = 1, num_bins do bins[i] = 0 end
                
                for _, v in ipairs(values) do
                    local bin = math.floor((v - min_val) / bin_size) + 1
                    bin = math.max(1, math.min(num_bins, bin))
                    bins[bin] = bins[bin] + 1
                end
                
                
                local entropy = 0
                local n = #values
                for _, count in ipairs(bins) do
                    if count > 0 then
                        local p = count / n
                        entropy = entropy - p * math.log(p) / math.log(2)
                    end
                end
                
                
                local max_entropy = math.log(num_bins) / math.log(2)
                return entropy / max_entropy
            end,
            
            
            calculate_autocorrelation = function(self, values, lag)
                lag = lag or 1
                if #values < lag + 3 then return 0 end
                
                local n = #values
                local mean = 0
                for _, v in ipairs(values) do mean = mean + v end
                mean = mean / n
                
                local var = 0
                for _, v in ipairs(values) do var = var + (v - mean)^2 end
                var = var / n
                
                if var < 0.001 then return 1 end  
                
                local autocorr = 0
                for i = 1, n - lag do
                    autocorr = autocorr + (values[i] - mean) * (values[i + lag] - mean)
                end
                autocorr = autocorr / ((n - lag) * var)
                
                return autocorr
            end,
            
            
            analyze_yaw = function(self, player)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data or #data.yaw_samples < self.min_samples then
                    return false, 0, "unknown"
                end
                
                local samples = data.yaw_samples
                local n = #samples
                local stats = data.yaw_stats
                
                
                local values = {}
                for i = math.max(1, n - 20), n do
                    table.insert(values, samples[i].value)
                end
                
                if #values < 3 then return false, 0, "insufficient" end
                
                
                local sum, min_v, max_v = 0, values[1], values[1]
                for _, v in ipairs(values) do
                    sum = sum + v
                    min_v = math.min(min_v, v)
                    max_v = math.max(max_v, v)
                end
                local mean = sum / #values
                stats.mean = mean
                stats.range = {min = min_v, max = max_v}
                
                local var_sum = 0
                for _, v in ipairs(values) do
                    var_sum = var_sum + (v - mean)^2
                end
                stats.variance = var_sum / #values
                local std_dev = math.sqrt(stats.variance)
                
                
                local range = max_v - min_v
                
                
                
                if range < 12 and std_dev < 6 then
                    stats.entropy = 0
                    stats.autocorrelation = 1
                    stats.direction_changes = 0
                    data.yaw_randomness_score = 0
                    data.yaw_is_random = false
                    return false, 0, "static"
                end
                
                
                stats.entropy = self:calculate_entropy(values, 16)
                
                
                stats.autocorrelation = self:calculate_autocorrelation(values, 1)
                
                
                local dir_changes = 0
                for i = 2, #values do
                    local delta1 = func.aa_clamp(values[i] - values[i-1])
                    if i > 2 then
                        local delta2 = func.aa_clamp(values[i-1] - values[i-2])
                        if (delta1 > 0 and delta2 < 0) or (delta1 < 0 and delta2 > 0) then
                            dir_changes = dir_changes + 1
                        end
                    end
                end
                stats.direction_changes = dir_changes / math.max(1, #values - 2)
                
                
                local randomness_score = 0
                
                
                if range < 20 then
                    
                    randomness_score = 0
                    data.yaw_randomness_score = 0
                    data.yaw_is_random = false
                    return false, 0, "static"
                end
                
                
                
                if range >= 35 then
                    if stats.entropy > 0.65 then
                        randomness_score = randomness_score + 0.35
                    elseif stats.entropy > 0.45 then
                        randomness_score = randomness_score + 0.20
                    end
                elseif range >= 25 then
                    if stats.entropy > 0.70 then
                        randomness_score = randomness_score + 0.25
                    elseif stats.entropy > 0.55 then
                        randomness_score = randomness_score + 0.12
                    end
                end
                
                
                if range >= 30 then
                    if math.abs(stats.autocorrelation) < 0.30 then
                        randomness_score = randomness_score + 0.30
                    elseif math.abs(stats.autocorrelation) < 0.50 then
                        randomness_score = randomness_score + 0.15
                    end
                end
                
                
                if range >= 25 then
                    if stats.direction_changes > 0.45 then
                        randomness_score = randomness_score + 0.25
                    elseif stats.direction_changes > 0.30 then
                        randomness_score = randomness_score + 0.12
                    end
                end
                
                
                if range > 100 and std_dev > 35 then
                    randomness_score = randomness_score + 0.25
                elseif range > 60 and std_dev > 20 then
                    randomness_score = randomness_score + 0.12
                end
                
                data.yaw_randomness_score = func.fclamp(randomness_score, 0, 1)
                data.yaw_is_random = randomness_score > 0.35  
                
                local pattern_type = "unknown"
                if range < 20 then
                    
                    pattern_type = "static"
                    data.yaw_is_random = false
                    data.yaw_randomness_score = 0
                elseif randomness_score > 0.55 then
                    pattern_type = "fully_random"
                elseif randomness_score > 0.35 then
                    pattern_type = "semi_random"
                elseif stats.autocorrelation < -0.35 then
                    pattern_type = "alternating"
                elseif range < 50 then
                    pattern_type = "center_jitter"
                else
                    pattern_type = "wide_jitter"
                end
                
                return data.yaw_is_random, randomness_score, pattern_type
            end,
            
            
            analyze_pitch = function(self, player)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data or #data.pitch_samples < self.min_samples then
                return false, 0, "unknown"
                end
                
                local samples = data.pitch_samples
                local n = #samples
                local stats = data.pitch_stats
                
                
                local values = {}
                local timestamps = {}
                local now = globals.realtime()
                
                local sample_window = math.min(25, n)
                for i = math.max(1, n - sample_window + 1), n do
                local s = samples[i]
                if s and s.value then
                    table.insert(values, s.value)
                    table.insert(timestamps, s.time or now)
                end
                end
                
                if #values < 3 then return false, 0, "insufficient" end
                
                
                local sum, weighted_sum, weight_total = 0, 0, 0
                local min_v, max_v = values[1], values[1]
                
                for i, v in ipairs(values) do
                local age = now - (timestamps[i] or now)
                local weight = math.exp(-age * 1.5)  
                
                sum = sum + v
                weighted_sum = weighted_sum + v * weight
                weight_total = weight_total + weight
                min_v = math.min(min_v, v)
                max_v = math.max(max_v, v)
                end
                
                local mean = sum / #values
                local weighted_mean = weight_total > 0 and (weighted_sum / weight_total) or mean
                stats.mean = weighted_mean
                stats.range = {min = min_v, max = max_v}
                
                
                local var_sum = 0
                for _, v in ipairs(values) do
                var_sum = var_sum + (v - mean)^2
                end
                stats.variance = #values > 1 and (var_sum / (#values - 1)) or 0
                local std_dev = math.sqrt(stats.variance)
                
                local range = max_v - min_v
                
                
                local down_count, up_count, center_count = 0, 0, 0
                local extreme_down, extreme_up = 0, 0
                
                for _, v in ipairs(values) do
                if v > 75 then
                    extreme_down = extreme_down + 1
                    down_count = down_count + 1
                elseif v > 30 then
                    down_count = down_count + 1
                elseif v < -60 then
                    extreme_up = extreme_up + 1
                    up_count = up_count + 1
                elseif v < -15 then
                    up_count = up_count + 1
                else
                    center_count = center_count + 1
                end
                end
                
                local total = #values
                local down_ratio = down_count / total
                local up_ratio = up_count / total
                local center_ratio = center_count / total
                local extreme_down_ratio = extreme_down / total
                local extreme_up_ratio = extreme_up / total
                
                
                stats.is_static = range < 10 and std_dev < 5
                stats.favors_down = weighted_mean > 45 or extreme_down_ratio > 0.7
                stats.favors_up = weighted_mean < -30 or extreme_up_ratio > 0.5
                
                
                local deltas = data.pitch_deltas or {}
                local avg_delta_magnitude = 0
                local direction_changes = 0
                local last_sign = nil
                
                if #deltas >= 3 then
                local delta_sum = 0
                for i, d in ipairs(deltas) do
                    if i > #deltas - 15 then  
                    delta_sum = delta_sum + math.abs(d.delta or 0)
                    local sign = (d.delta or 0) > 0 and 1 or ((d.delta or 0) < 0 and -1 or 0)
                    if sign ~= 0 and last_sign and sign ~= last_sign then
                        direction_changes = direction_changes + 1
                    end
                    if sign ~= 0 then last_sign = sign end
                    end
                end
                local recent_count = math.min(15, #deltas)
                avg_delta_magnitude = delta_sum / math.max(1, recent_count)
                end
                
                
                local pitch_entropy = 0
                if range > 15 then
                pitch_entropy = self:calculate_entropy(values, 12)
                end
                
                
                local autocorr = 0
                if #values >= 8 then
                autocorr = self:calculate_autocorrelation(values, 1)
                end
                
                
                local randomness_score = 0
                local pattern_scores = {
                static_down = 0,
                static_up = 0,
                static_center = 0,
                periodic_jitter = 0,
                small_jitter = 0,
                wide_jitter = 0,
                semi_random = 0,
                fully_random = 0,
                }
                
                
                if range < 12 and std_dev < 6 then
                if extreme_down_ratio > 0.8 or (weighted_mean > 70 and range < 20) then
                    pattern_scores.static_down = 0.95
                elseif extreme_up_ratio > 0.6 or (weighted_mean < -50 and range < 25) then
                    pattern_scores.static_up = 0.88
                elseif center_ratio > 0.7 then
                    pattern_scores.static_center = 0.82
                else
                    pattern_scores.static_down = 0.70  
                end
                elseif range < 20 and weighted_mean > 60 then
                pattern_scores.static_down = 0.80  
                elseif range < 25 and weighted_mean < -40 then
                pattern_scores.static_up = 0.72
                end
                
                
                if range >= 20 and range < 100 and math.abs(autocorr) > 0.35 then
                pattern_scores.periodic_jitter = 0.65 + math.abs(autocorr) * 0.20
                if direction_changes / math.max(1, #deltas - 1) > 0.5 then
                    pattern_scores.periodic_jitter = pattern_scores.periodic_jitter + 0.10
                end
                end
                
                
                if range >= 15 and range < 45 and std_dev < 15 then
                pattern_scores.small_jitter = 0.60
                if avg_delta_magnitude < 12 then
                    pattern_scores.small_jitter = pattern_scores.small_jitter + 0.10
                end
                end
                
                
                if range >= 45 and range < 120 then
                pattern_scores.wide_jitter = 0.55
                if pitch_entropy > 0.45 and pitch_entropy < 0.75 then
                    pattern_scores.wide_jitter = pattern_scores.wide_jitter + 0.12
                end
                end
                
                
                if pitch_entropy > 0.55 and pitch_entropy < 0.80 and range >= 35 then
                pattern_scores.semi_random = 0.50 + (pitch_entropy - 0.55) * 0.5
                if math.abs(autocorr) < 0.25 then
                    pattern_scores.semi_random = pattern_scores.semi_random + 0.10
                end
                end
                
                
                if pitch_entropy > 0.78 and range >= 80 and math.abs(autocorr) < 0.18 then
                pattern_scores.fully_random = 0.55 + (pitch_entropy - 0.78) * 0.8
                if std_dev > range * 0.28 then
                    pattern_scores.fully_random = pattern_scores.fully_random + 0.12
                end
                end
                
                
                local best_pattern = "unknown"
                local best_score = 0.30
                
                for pattern, score in pairs(pattern_scores) do
                if score > best_score then
                    best_score = score
                    best_pattern = pattern
                end
                end
                
                
                if best_pattern == "fully_random" then
                randomness_score = best_score
                elseif best_pattern == "semi_random" then
                randomness_score = best_score * 0.85
                elseif best_pattern == "wide_jitter" then
                randomness_score = best_score * 0.50
                elseif best_pattern == "periodic_jitter" or best_pattern == "small_jitter" then
                randomness_score = best_score * 0.25
                else
                randomness_score = 0
                end
                
                
                if #values < 8 then
                best_score = best_score * 0.75
                randomness_score = randomness_score * 0.75
                elseif #values >= 15 then
                best_score = math.min(0.95, best_score * 1.08)
                end
                
                
                local sorted_scores = {}
                for _, score in pairs(pattern_scores) do
                if score > 0.25 then
                    table.insert(sorted_scores, score)
                end
                end
                table.sort(sorted_scores, function(a, b) return a > b end)
                
                if #sorted_scores >= 2 and sorted_scores[1] - sorted_scores[2] < 0.10 then
                best_score = best_score * 0.88
                end
                
                
                data.pitch_randomness_score = func.fclamp(randomness_score, 0, 1)
                data.pitch_is_random = randomness_score > 0.38
                data.pitch_pattern_confidence = best_score
                data.pitch_entropy = pitch_entropy
                data.pitch_autocorr = autocorr
                
                return data.pitch_is_random, randomness_score, best_pattern
            end,
            
            
            find_clusters = function(self, values, threshold)
                threshold = threshold or 18
                if #values < 2 then return {} end
                
                local sorted = {}
                for _, v in ipairs(values) do table.insert(sorted, v) end
                table.sort(sorted)
                
                local clusters = {}
                local current_cluster = {sorted[1]}
                
                for i = 2, #sorted do
                
                local adaptive_threshold = threshold * (1 + #current_cluster * 0.05)
                adaptive_threshold = math.min(adaptive_threshold, threshold * 1.5)
                
                if math.abs(sorted[i] - sorted[i-1]) <= adaptive_threshold then
                    table.insert(current_cluster, sorted[i])
                else
                    if #current_cluster >= 2 then  
                    local sum = 0
                    local min_v, max_v = current_cluster[1], current_cluster[1]
                    for _, v in ipairs(current_cluster) do 
                        sum = sum + v 
                        min_v = math.min(min_v, v)
                        max_v = math.max(max_v, v)
                    end
                    local center = sum / #current_cluster
                    local spread = max_v - min_v
                    
                    
                    local density = #current_cluster / math.max(1, spread)
                    
                    table.insert(clusters, {
                        center = center,
                        count = #current_cluster,
                        values = current_cluster,
                        min = min_v,
                        max = max_v,
                        spread = spread,
                        density = density,
                        weight = #current_cluster * (1 + density * 0.5),  
                    })
                    end
                    current_cluster = {sorted[i]}
                end
                end
                
                
                if #current_cluster >= 2 then
                local sum = 0
                local min_v, max_v = current_cluster[1], current_cluster[1]
                for _, v in ipairs(current_cluster) do 
                    sum = sum + v 
                    min_v = math.min(min_v, v)
                    max_v = math.max(max_v, v)
                end
                local center = sum / #current_cluster
                local spread = max_v - min_v
                local density = #current_cluster / math.max(1, spread)
                
                table.insert(clusters, {
                    center = center,
                    count = #current_cluster,
                    values = current_cluster,
                    min = min_v,
                    max = max_v,
                    spread = spread,
                    density = density,
                    weight = #current_cluster * (1 + density * 0.5),
                })
                end
                
                
                table.sort(clusters, function(a, b) return a.weight > b.weight end)
                
                
                local merged = {}
                for _, cluster in ipairs(clusters) do
                local found_merge = false
                for _, existing in ipairs(merged) do
                    
                    if math.abs(cluster.center - existing.center) < threshold * 1.5 then
                    
                    local total_count = existing.count + cluster.count
                    existing.center = (existing.center * existing.count + cluster.center * cluster.count) / total_count
                    existing.count = total_count
                    existing.min = math.min(existing.min, cluster.min)
                    existing.max = math.max(existing.max, cluster.max)
                    existing.spread = existing.max - existing.min
                    existing.density = existing.count / math.max(1, existing.spread)
                    existing.weight = existing.count * (1 + existing.density * 0.5)
                    found_merge = true
                    break
                    end
                end
                if not found_merge then
                    table.insert(merged, cluster)
                end
                end
                
                
                table.sort(merged, function(a, b) return a.weight > b.weight end)
                
                return merged
            end,
            
            
            get_learned_offset = function(self, player)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data then return 0, 0.20 end
                
                local now = globals.realtime()
                local successful = data.successful_offsets or {}
                local failed = data.failed_offsets or {}
                local weights = data.offset_weights or {}
                
                
                if #successful < 1 and #failed < 2 then
                return 0, 0.20
                end
                
                
                local offset_scores = {}
                local offset_samples = {}
                local decay_rate = 0.15  
                
                
                for i, offset in ipairs(successful) do
                local age_factor = (#successful - i) / math.max(1, #successful)
                local recency_weight = math.exp(-age_factor * decay_rate * 10)
                local bucket = math.floor(offset / 8) * 8  
                
                offset_scores[bucket] = (offset_scores[bucket] or 0) + recency_weight * 2.0
                offset_samples[bucket] = (offset_samples[bucket] or 0) + 1
                end
                
                
                for i, offset in ipairs(failed) do
                local age_factor = (#failed - i) / math.max(1, #failed)
                local recency_weight = math.exp(-age_factor * decay_rate * 8)
                local bucket = math.floor(offset / 8) * 8
                
                offset_scores[bucket] = (offset_scores[bucket] or 0) - recency_weight * 1.2
                offset_samples[bucket] = (offset_samples[bucket] or 0) + 1
                end
                
                
                for offset, weight in pairs(weights) do
                local bucket = math.floor(offset / 8) * 8
                
                local dampened_weight = weight * 0.4
                offset_scores[bucket] = (offset_scores[bucket] or 0) + dampened_weight
                end
                
                
                local smoothed_scores = {}
                local sigma = 12  
                
                for bucket, score in pairs(offset_scores) do
                for nearby = bucket - 24, bucket + 24, 8 do
                    local distance = math.abs(nearby - bucket)
                    local gaussian_weight = math.exp(-(distance * distance) / (2 * sigma * sigma))
                    smoothed_scores[nearby] = (smoothed_scores[nearby] or 0) + score * gaussian_weight * 0.3
                end
                smoothed_scores[bucket] = (smoothed_scores[bucket] or 0) + score * 0.7
                end
                
                
                local best_offset = 0
                local best_score = -999
                local second_best_score = -999
                local positive_buckets = 0
                local total_buckets = 0
                
                for offset, score in pairs(smoothed_scores) do
                total_buckets = total_buckets + 1
                if score > 0 then positive_buckets = positive_buckets + 1 end
                
                if score > best_score then
                    second_best_score = best_score
                    best_score = score
                    best_offset = offset
                elseif score > second_best_score then
                    second_best_score = score
                end
                end
                
                
                local confidence = 0.20
                
                
                local total_samples = #successful + #failed
                if total_samples >= 3 then
                confidence = confidence + math.min(0.20, total_samples * 0.025)
                end
                
                
                if total_samples >= 3 then
                local success_ratio = #successful / total_samples
                if success_ratio > 0.5 then
                    confidence = confidence + (success_ratio - 0.5) * 0.3
                elseif success_ratio < 0.3 then
                    confidence = confidence * 0.8
                end
                end
                
                
                local margin = best_score - second_best_score
                if margin > 0.8 and best_score > 0.5 then
                confidence = confidence + math.min(0.18, margin * 0.12)
                elseif margin < 0.3 and total_buckets >= 3 then
                confidence = confidence * 0.85  
                end
                
                
                if #successful >= 4 then
                local cluster_threshold = 16
                local main_cluster_count = 0
                
                for _, offset in ipairs(successful) do
                    if math.abs(offset - best_offset) <= cluster_threshold then
                    main_cluster_count = main_cluster_count + 1
                    end
                end
                
                local cluster_ratio = main_cluster_count / #successful
                if cluster_ratio > 0.7 then
                    confidence = confidence + 0.10  
                elseif cluster_ratio < 0.4 then
                    confidence = confidence * 0.80  
                end
                end
                
                
                if #successful >= 2 and #failed >= 2 then
                
                local recent_success = 0
                local recent_fail = 0
                local check_count = math.min(4, math.min(#successful, #failed))
                
                for i = 1, check_count do
                    if successful[#successful - i + 1] then recent_success = recent_success + 1 end
                end
                for i = 1, check_count do
                    if failed[#failed - i + 1] then recent_fail = recent_fail + 1 end
                end
                
                if recent_success > recent_fail then
                    confidence = confidence + 0.05  
                elseif recent_fail > recent_success + 1 then
                    confidence = confidence * 0.85  
                end
                end
                
                
                if data.last_hit_time and data.last_hit_time > 0 then
                local time_since_hit = now - data.last_hit_time
                if time_since_hit < 1.0 then
                    confidence = confidence + 0.12 * (1.0 - time_since_hit)
                elseif time_since_hit < 3.0 then
                    confidence = confidence + 0.05 * (3.0 - time_since_hit) / 2.0
                end
                end
                
                
                local recent_fails_at_best = 0
                for i = #failed, math.max(1, #failed - 3), -1 do
                local fail_offset = failed[i]
                if fail_offset and math.abs(fail_offset - best_offset) <= 12 then
                    recent_fails_at_best = recent_fails_at_best + 1
                else
                    break
                end
                end
                
                if recent_fails_at_best >= 2 then
                confidence = confidence * (1.0 - recent_fails_at_best * 0.15)
                
                
                if recent_fails_at_best >= 3 and second_best_score > 0 then
                    for offset, score in pairs(smoothed_scores) do
                    if score == second_best_score then
                        best_offset = offset
                        confidence = confidence * 0.8
                        break
                    end
                    end
                end
                end
                
                
                if best_score < 0.2 then
                return 0, 0.20  
                end
                
                if positive_buckets == 0 then
                return 0, 0.20  
                end
                
                
                confidence = func.fclamp(confidence, 0.18, 0.78)
                
                return best_offset, confidence
            end,
            
            
            predict_yaw = function(self, player)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data then return 0, 0.4 end
                
                local now = globals.realtime()
                local tick = globals.tickcount()
                
                local is_random, rand_score, pattern = self:analyze_yaw(player)
                local stats = data.yaw_stats
                
                local predicted_yaw = stats.mean
                local confidence = 0.50
                local method = "mean"
                
                
                if not data.yaw_prediction then
                data.yaw_prediction = {
                    velocity = 0,
                    acceleration = 0,
                    jerk = 0,
                    last_calc_time = 0,
                    momentum = 0,
                    momentum_direction = 0,
                    trend_strength = 0,
                    oscillation_phase = 0,
                    oscillation_frequency = 0,
                    last_predictions = {},
                    prediction_errors = {},
                    adaptive_offset = 0,
                    successful_methods = {},
                    failed_methods = {},
                }
                end
                
                local yp = data.yaw_prediction
                
                
                local samples = data.yaw_samples or {}
                local n = #samples
                
                if n >= 4 and (now - yp.last_calc_time) > 0.02 then
                yp.last_calc_time = now
                
                
                local velocity_samples = {}
                for i = 2, n do
                    local dt = (samples[i].time or now) - (samples[i-1].time or now)
                    if dt > 0.001 and dt < 0.5 then
                    local dy = func.aa_clamp(samples[i].value - samples[i-1].value)
                    table.insert(velocity_samples, dy / dt)
                    end
                end
                
                if #velocity_samples >= 2 then
                    
                    local vel_sum = 0
                    local vel_weight = 0
                    for i, v in ipairs(velocity_samples) do
                    local weight = math.exp((i - #velocity_samples) * 0.3)
                    vel_sum = vel_sum + v * weight
                    vel_weight = vel_weight + weight
                    end
                    yp.velocity = vel_weight > 0 and (vel_sum / vel_weight) or 0
                    
                    
                    if #velocity_samples >= 3 then
                    local accel_sum = 0
                    local accel_count = 0
                    for i = 2, #velocity_samples do
                        accel_sum = accel_sum + (velocity_samples[i] - velocity_samples[i-1])
                        accel_count = accel_count + 1
                    end
                    yp.acceleration = accel_count > 0 and (accel_sum / accel_count) or 0
                    end
                    
                    
                    if #velocity_samples >= 4 then
                    local prev_accel = velocity_samples[2] - velocity_samples[1]
                    local jerk_sum = 0
                    local jerk_count = 0
                    for i = 3, #velocity_samples do
                        local curr_accel = velocity_samples[i] - velocity_samples[i-1]
                        jerk_sum = jerk_sum + math.abs(curr_accel - prev_accel)
                        prev_accel = curr_accel
                        jerk_count = jerk_count + 1
                    end
                    yp.jerk = jerk_count > 0 and (jerk_sum / jerk_count) or 0
                    end
                end
                
                
                if n >= 6 then
                    local positive_moves = 0
                    local negative_moves = 0
                    local total_magnitude = 0
                    
                    for i = math.max(2, n - 8), n do
                    local delta = func.aa_clamp(samples[i].value - samples[i-1].value)
                    total_magnitude = total_magnitude + math.abs(delta)
                    if delta > 2 then positive_moves = positive_moves + 1
                    elseif delta < -2 then negative_moves = negative_moves + 1 end
                    end
                    
                    local check_count = math.min(8, n - 1)
                    yp.momentum_direction = (positive_moves - negative_moves) / math.max(1, check_count)
                    yp.momentum = total_magnitude / math.max(1, check_count)
                end
                
                
                if n >= 12 then
                    local values = {}
                    for i = math.max(1, n - 15), n do
                    table.insert(values, samples[i].value)
                    end
                    
                    
                    local crossings = 0
                    local mean_val = stats.mean
                    local last_sign = (values[1] - mean_val) > 0 and 1 or -1
                    
                    for i = 2, #values do
                    local sign = (values[i] - mean_val) > 0 and 1 or -1
                    if sign ~= last_sign then
                        crossings = crossings + 1
                        last_sign = sign
                    end
                    end
                    
                    yp.oscillation_frequency = crossings / (2 * #values)
                    
                    
                    if crossings >= 2 then
                    local last_crossing_idx = 0
                    last_sign = (values[1] - mean_val) > 0 and 1 or -1
                    for i = 2, #values do
                        local sign = (values[i] - mean_val) > 0 and 1 or -1
                        if sign ~= last_sign then
                        last_crossing_idx = i
                        last_sign = sign
                        end
                    end
                    yp.oscillation_phase = (#values - last_crossing_idx) / math.max(1, #values / crossings)
                    end
                end
                
                
                if n >= 8 then
                    local sum_x, sum_y, sum_xy, sum_xx = 0, 0, 0, 0
                    local count = math.min(12, n)
                    
                    for i = n - count + 1, n do
                    local x = i - (n - count)
                    local y = samples[i].value
                    sum_x = sum_x + x
                    sum_y = sum_y + y
                    sum_xy = sum_xy + x * y
                    sum_xx = sum_xx + x * x
                    end
                    
                    local denom = count * sum_xx - sum_x * sum_x
                    if math.abs(denom) > 0.01 then
                    local slope = (count * sum_xy - sum_x * sum_y) / denom
                    yp.trend_strength = math.min(1, math.abs(slope) / 50)
                    end
                end
                end
                
                
                if data.consecutive_misses >= 2 then
                
                local learned_offset, learned_conf = self:get_learned_offset(player)
                
                
                local failed_offsets = data.failed_offsets or {}
                local recent_fails = {}
                for i = math.max(1, #failed_offsets - 4), #failed_offsets do
                    if failed_offsets[i] then
                    local bucket = math.floor(failed_offsets[i] / 15) * 15
                    recent_fails[bucket] = (recent_fails[bucket] or 0) + 1
                    end
                end
                
                
                local bf_candidates = {}
                for _, offset in ipairs(data.bruteforce_yaw_offsets) do
                    local bucket = math.floor(offset / 15) * 15
                    local fail_count = recent_fails[bucket] or 0
                    table.insert(bf_candidates, {offset = offset, score = 1.0 / (1 + fail_count)})
                end
                
                
                table.sort(bf_candidates, function(a, b) return a.score > b.score end)
                
                
                local momentum_bias = yp.momentum_direction * 15
                
                if learned_conf > 0.45 and data.consecutive_misses < 4 then
                    
                    predicted_yaw = stats.mean + learned_offset + momentum_bias * 0.3
                    confidence = learned_conf * 0.85
                    method = "learned_momentum"
                elseif data.consecutive_misses >= 4 then
                    
                    local stage = data.bruteforce_stage or 0
                    local selected = bf_candidates[(stage % #bf_candidates) + 1]
                    predicted_yaw = stats.mean + selected.offset + momentum_bias * 0.2
                    confidence = 0.38
                    method = "bruteforce_smart"
                    data.bruteforce_stage = stage + 1
                else
                    
                    predicted_yaw = stats.mean + bf_candidates[1].offset + momentum_bias * 0.25
                    confidence = 0.42
                    method = "bruteforce_scored"
                end
                
                
                local jitter = (math.sin(tick * 0.17) + math.cos(tick * 0.23)) * 3
                predicted_yaw = predicted_yaw + jitter
                
                data.predicted_yaw = func.aa_clamp(predicted_yaw)
                data.prediction_method = method
                return data.predicted_yaw, confidence
                end
                
                
                
                if pattern == "static" then
                
                predicted_yaw = data.last_yaw or stats.mean
                
                
                if n >= 3 then
                    local recent_range = 0
                    for i = n - 2, n do
                    if samples[i] and samples[i-1] then
                        recent_range = math.max(recent_range, math.abs(func.aa_clamp(samples[i].value - samples[i-1].value)))
                    end
                    end
                    
                    if recent_range < 5 then
                    confidence = 0.88
                    else
                    confidence = 0.78
                    end
                else
                    confidence = 0.82
                end
                method = "static"
                
                elseif pattern == "alternating" then
                
                if n >= 3 then
                    local last = samples[n].value
                    local prev = samples[n-1].value
                    local delta = func.aa_clamp(last - prev)
                    
                    
                    if yp.acceleration ~= 0 and math.sign(yp.velocity) ~= math.sign(yp.acceleration) then
                    
                    predicted_yaw = last + delta * 0.3
                    confidence = 0.68
                    method = "alt_reversal"
                    else
                    
                    predicted_yaw = func.aa_clamp(last - delta * 0.85)
                    confidence = 0.65
                    method = "alternating"
                    end
                    
                    
                    if yp.oscillation_frequency > 0.1 then
                    local phase_adjustment = math.sin(yp.oscillation_phase * math.pi * 2) * (stats.range.max - stats.range.min) * 0.1
                    predicted_yaw = predicted_yaw + phase_adjustment
                    confidence = confidence + 0.05
                    method = method .. "_phase"
                    end
                end
                
                elseif pattern == "fully_random" or pattern == "semi_random" then
                
                local strategies = {}
                
                
                local values = {}
                for i = math.max(1, n - 18), n do
                    if samples[i] then
                    table.insert(values, samples[i].value)
                    end
                end
                
                local clusters = self:find_clusters(values, 18)
                
                if #clusters >= 1 then
                    
                    local weighted_center = 0
                    local weight_sum = 0
                    
                    for i, cluster in ipairs(clusters) do
                    local recency_weight = math.exp(-i * 0.3)
                    local density_weight = cluster.density or 1
                    local combined_weight = cluster.count * recency_weight * (1 + density_weight * 0.5)
                    weighted_center = weighted_center + cluster.center * combined_weight
                    weight_sum = weight_sum + combined_weight
                    end
                    
                    if weight_sum > 0 then
                    table.insert(strategies, {
                        yaw = weighted_center / weight_sum,
                        conf = 0.45 + (clusters[1].count / #values) * 0.18,
                        method = "cluster_weighted"
                    })
                    end
                end
                
                
                if #data.hit_yaws >= 1 then
                    local hit_sum = 0
                    local hit_weight = 0
                    local hit_count = #data.hit_yaws
                    
                    for i, y in ipairs(data.hit_yaws) do
                    local weight = math.exp((i - hit_count) * 0.4)
                    hit_sum = hit_sum + y * weight
                    hit_weight = hit_weight + weight
                    end
                    
                    local avg_hit = hit_sum / math.max(0.01, hit_weight)
                    
                    table.insert(strategies, {
                    yaw = avg_hit,
                    conf = 0.52 + math.min(0.18, hit_count * 0.04),
                    method = "hit_feedback"
                    })
                end
                
                
                if math.abs(yp.momentum_direction) > 0.15 then
                    local momentum_yaw = stats.mean + yp.momentum_direction * yp.momentum * 0.8
                    table.insert(strategies, {
                    yaw = momentum_yaw,
                    conf = 0.40 + math.min(0.15, math.abs(yp.momentum_direction) * 0.3),
                    method = "momentum"
                    })
                end
                
                
                if yp.trend_strength > 0.2 and math.abs(yp.velocity) > 10 then
                    local extrapolation_time = 0.05 
                    local trend_yaw = samples[n].value + yp.velocity * extrapolation_time
                    table.insert(strategies, {
                    yaw = func.aa_clamp(trend_yaw),
                    conf = 0.38 + yp.trend_strength * 0.15,
                    method = "trend"
                    })
                end
                
                
                local learned_offset, learned_conf = self:get_learned_offset(player)
                if learned_conf > 0.35 then
                    table.insert(strategies, {
                    yaw = stats.mean + learned_offset,
                    conf = learned_conf,
                    method = "learned"
                    })
                end
                
                
                table.insert(strategies, {
                    yaw = stats.mean,
                    conf = 0.35,
                    method = "mean_revert"
                })
                
                
                if #strategies > 0 then
                    
                    table.sort(strategies, function(a, b) return a.conf > b.conf end)
                    
                    
                    local fused_yaw = 0
                    local fused_weight = 0
                    local methods_used = {}
                    
                    for i, strat in ipairs(strategies) do
                    if i > 4 then break end 
                    
                    local weight = strat.conf * strat.conf 
                    fused_yaw = fused_yaw + strat.yaw * weight
                    fused_weight = fused_weight + weight
                    table.insert(methods_used, strat.method)
                    end
                    
                    if fused_weight > 0 then
                    predicted_yaw = fused_yaw / fused_weight
                    confidence = strategies[1].conf * 0.85 + strategies[2].conf * 0.15
                    method = table.concat(methods_used, "+")
                    end
                    
                    
                    local agreement_sum = 0
                    local agreement_count = 0
                    for i = 1, math.min(3, #strategies) do
                    for j = i + 1, math.min(4, #strategies) do
                        local diff = math.abs(func.aa_clamp(strategies[i].yaw - strategies[j].yaw))
                        if diff < 15 then
                        agreement_sum = agreement_sum + (1 - diff / 15)
                        agreement_count = agreement_count + 1
                        end
                    end
                    end
                    
                    if agreement_count >= 2 then
                    confidence = confidence + (agreement_sum / agreement_count) * 0.12
                    end
                else
                    predicted_yaw = stats.mean
                    confidence = 0.32
                    method = "fallback"
                end
                
                
                if #yp.prediction_errors >= 3 then
                    local error_sum = 0
                    local error_weight = 0
                    for i, err in ipairs(yp.prediction_errors) do
                    local weight = math.exp((i - #yp.prediction_errors) * 0.5)
                    error_sum = error_sum + err * weight
                    error_weight = error_weight + weight
                    end
                    
                    if error_weight > 0 then
                    yp.adaptive_offset = error_sum / error_weight * 0.4
                    predicted_yaw = predicted_yaw + yp.adaptive_offset
                    end
                end
                
                
                if confidence < 0.42 or data.miss_count >= 2 then
                    local bf_stage = (data.bruteforce_stage or 0) % #data.bruteforce_yaw_offsets
                    local offset = data.bruteforce_yaw_offsets[bf_stage + 1]
                    predicted_yaw = predicted_yaw + offset * 0.55
                    method = method .. "_bf"
                    data.bruteforce_stage = bf_stage + 1
                end
                
                elseif pattern == "center_jitter" then
                
                predicted_yaw = stats.mean
                
                if math.abs(yp.momentum_direction) > 0.1 then
                    predicted_yaw = predicted_yaw + yp.momentum_direction * 8
                end
                
                confidence = 0.62
                method = "center"
                
                elseif pattern == "wide_jitter" then
                
                local values = {}
                for i = math.max(1, n - 15), n do
                    if samples[i] then
                    table.insert(values, samples[i].value)
                    end
                end
                
                
                local sorted_vals = {}
                for _, v in ipairs(values) do table.insert(sorted_vals, v) end
                table.sort(sorted_vals)
                
                local q1_idx = math.floor(#sorted_vals * 0.25) + 1
                local q3_idx = math.floor(#sorted_vals * 0.75) + 1
                local q1 = sorted_vals[math.max(1, q1_idx)] or stats.mean
                local q3 = sorted_vals[math.min(#sorted_vals, q3_idx)] or stats.mean
                local iqr = q3 - q1
                
                
                local above_median = 0
                local median = sorted_vals[math.floor(#sorted_vals / 2) + 1] or stats.mean
                
                for i = math.max(1, #values - 5), #values do
                    if values[i] and values[i] > median then
                    above_median = above_median + 1
                    end
                end
                
                local recent_bias = (above_median / math.min(5, #values) - 0.5) * 2
                
                
                predicted_yaw = median + recent_bias * iqr * 0.35 + yp.momentum_direction * 10
                
                
                if yp.oscillation_frequency > 0.05 then
                    local osc_offset = math.sin(yp.oscillation_phase * math.pi * 2) * iqr * 0.2
                    predicted_yaw = predicted_yaw + osc_offset
                end
                
                confidence = 0.54
                method = "wide_dist"
                end
                
                
                
                
                table.insert(yp.last_predictions, {yaw = predicted_yaw, time = now})
                while #yp.last_predictions > 10 do table.remove(yp.last_predictions, 1) end
                
                
                if data.last_yaw and #yp.last_predictions >= 2 then
                local prev_pred = yp.last_predictions[#yp.last_predictions - 1]
                if prev_pred then
                    local error = func.aa_clamp(data.last_yaw - prev_pred.yaw)
                    table.insert(yp.prediction_errors, error)
                    while #yp.prediction_errors > 8 do table.remove(yp.prediction_errors, 1) end
                end
                end
                
                
                data.predicted_yaw = func.aa_clamp(predicted_yaw)
                data.prediction_method = method
                
                
                if #yp.prediction_errors >= 4 then
                local avg_abs_error = 0
                for _, err in ipairs(yp.prediction_errors) do
                    avg_abs_error = avg_abs_error + math.abs(err)
                end
                avg_abs_error = avg_abs_error / #yp.prediction_errors
                
                
                if avg_abs_error > 40 then
                    confidence = confidence * 0.75
                elseif avg_abs_error > 25 then
                    confidence = confidence * 0.88
                elseif avg_abs_error < 12 then
                    confidence = math.min(confidence * 1.08, 0.85)
                end
                end
                
                confidence = func.fclamp(confidence, 0.28, 0.88)
                
                return data.predicted_yaw, confidence
            end,
            
            
            predict_pitch = function(self, player)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data then return 0, 0.4 end
                
                local now = globals.realtime()
                local tick = globals.tickcount()
                
                local is_random, rand_score, pattern = self:analyze_pitch(player)
                local stats = data.pitch_stats
                
                
                if not data.pitch_prediction then
                data.pitch_prediction = {
                    velocity = 0,
                    acceleration = 0,
                    momentum = 0,
                    momentum_direction = 0,
                    oscillation_phase = 0,
                    oscillation_frequency = 0,
                    last_calc_time = 0,
                    last_predictions = {},
                    prediction_errors = {},
                    adaptive_offset = 0,
                    successful_pitches = {},
                    failed_pitches = {},
                    pitch_weights = {},
                    trend_strength = 0,
                    periodic_detected = false,
                    periodic_period = 0,
                    dwell_times = {up = 0, down = 0, center = 0},
                    transition_matrix = {},
                }
                end
                
                local pp = data.pitch_prediction
                local samples = data.pitch_samples or {}
                local n = #samples
                
                local predicted_pitch = stats.mean
                local confidence = 0.50
                local method = "mean"
                
                
                if n >= 4 and (now - pp.last_calc_time) > 0.02 then
                pp.last_calc_time = now
                
                
                local velocity_samples = {}
                for i = 2, n do
                    local dt = (samples[i].time or now) - (samples[i-1].time or now)
                    if dt > 0.001 and dt < 0.5 then
                    local dp = samples[i].value - samples[i-1].value
                    table.insert(velocity_samples, dp / dt)
                    end
                end
                
                if #velocity_samples >= 2 then
                    
                    local vel_sum = 0
                    local vel_weight = 0
                    for i, v in ipairs(velocity_samples) do
                    local weight = math.exp((i - #velocity_samples) * 0.4)
                    vel_sum = vel_sum + v * weight
                    vel_weight = vel_weight + weight
                    end
                    pp.velocity = vel_weight > 0 and (vel_sum / vel_weight) or 0
                    
                    
                    if #velocity_samples >= 3 then
                    local accel_sum = 0
                    local accel_count = 0
                    for i = 2, #velocity_samples do
                        accel_sum = accel_sum + (velocity_samples[i] - velocity_samples[i-1])
                        accel_count = accel_count + 1
                    end
                    pp.acceleration = accel_count > 0 and (accel_sum / accel_count) or 0
                    end
                end
                
                
                if n >= 6 then
                    local positive_moves = 0
                    local negative_moves = 0
                    local total_magnitude = 0
                    
                    for i = math.max(2, n - 8), n do
                    local delta = samples[i].value - samples[i-1].value
                    total_magnitude = total_magnitude + math.abs(delta)
                    if delta > 2 then positive_moves = positive_moves + 1
                    elseif delta < -2 then negative_moves = negative_moves + 1 end
                    end
                    
                    local check_count = math.min(8, n - 1)
                    pp.momentum_direction = (positive_moves - negative_moves) / math.max(1, check_count)
                    pp.momentum = total_magnitude / math.max(1, check_count)
                end
                
                
                if n >= 10 then
                    local values = {}
                    for i = math.max(1, n - 12), n do
                    table.insert(values, samples[i].value)
                    end
                    
                    
                    local crossings = 0
                    local mean_val = stats.mean
                    local last_sign = (values[1] - mean_val) > 0 and 1 or -1
                    
                    for i = 2, #values do
                    local sign = (values[i] - mean_val) > 0 and 1 or -1
                    if sign ~= last_sign then
                        crossings = crossings + 1
                        last_sign = sign
                    end
                    end
                    
                    pp.oscillation_frequency = crossings / (2 * #values)
                    pp.periodic_detected = crossings >= 3 and pp.oscillation_frequency > 0.1
                    
                    if pp.periodic_detected then
                    pp.periodic_period = 1.0 / math.max(0.01, pp.oscillation_frequency)
                    end
                end
                
                
                if n >= 5 then
                    local up_time, down_time, center_time = 0, 0, 0
                    local last_time = samples[math.max(1, n - 10)].time or now
                    
                    for i = math.max(1, n - 10) + 1, n do
                    local s = samples[i]
                    local dt = (s.time or now) - last_time
                    last_time = s.time or now
                    
                    if s.value > 60 then
                        down_time = down_time + dt
                    elseif s.value < -40 then
                        up_time = up_time + dt
                    else
                        center_time = center_time + dt
                    end
                    end
                    
                    local total_time = up_time + down_time + center_time
                    if total_time > 0.1 then
                    pp.dwell_times.up = up_time / total_time
                    pp.dwell_times.down = down_time / total_time
                    pp.dwell_times.center = center_time / total_time
                    end
                end
                
                
                if n >= 8 then
                    local function categorize(p)
                    if p > 60 then return "down"
                    elseif p < -40 then return "up"
                    else return "center" end
                    end
                    
                    pp.transition_matrix = {
                    up = {up = 0, center = 0, down = 0},
                    center = {up = 0, center = 0, down = 0},
                    down = {up = 0, center = 0, down = 0},
                    }
                    
                    local last_cat = categorize(samples[math.max(1, n - 12)].value)
                    for i = math.max(1, n - 12) + 1, n do
                    local curr_cat = categorize(samples[i].value)
                    if pp.transition_matrix[last_cat] then
                        pp.transition_matrix[last_cat][curr_cat] = pp.transition_matrix[last_cat][curr_cat] + 1
                    end
                    last_cat = curr_cat
                    end
                    
                    
                    for from, transitions in pairs(pp.transition_matrix) do
                    local total = 0
                    for _, count in pairs(transitions) do total = total + count end
                    if total > 0 then
                        for to, count in pairs(transitions) do
                        pp.transition_matrix[from][to] = count / total
                        end
                    end
                    end
                end
                
                
                if n >= 6 then
                    local sum_x, sum_y, sum_xy, sum_xx = 0, 0, 0, 0
                    local count = math.min(10, n)
                    
                    for i = n - count + 1, n do
                    local x = i - (n - count)
                    local y = samples[i].value
                    sum_x = sum_x + x
                    sum_y = sum_y + y
                    sum_xy = sum_xy + x * y
                    sum_xx = sum_xx + x * x
                    end
                    
                    local denom = count * sum_xx - sum_x * sum_x
                    if math.abs(denom) > 0.01 then
                    local slope = (count * sum_xy - sum_x * sum_y) / denom
                    pp.trend_strength = math.min(1, math.abs(slope) / 30)
                    end
                end
                end
                
                
                if data.consecutive_misses >= 2 then
                local strategies = {}
                
                
                if #data.hit_pitches >= 1 then
                    local hit_sum = 0
                    local hit_weight = 0
                    for i, p in ipairs(data.hit_pitches) do
                    local weight = math.exp((i - #data.hit_pitches) * 0.5)
                    hit_sum = hit_sum + p * weight
                    hit_weight = hit_weight + weight
                    end
                    if hit_weight > 0 then
                    table.insert(strategies, {
                        pitch = hit_sum / hit_weight,
                        conf = 0.55 + math.min(0.15, #data.hit_pitches * 0.03),
                        method = "hit_feedback"
                    })
                    end
                end
                
                
                if pp.transition_matrix then
                    local current_cat
                    if samples[n] then
                    if samples[n].value > 60 then current_cat = "down"
                    elseif samples[n].value < -40 then current_cat = "up"
                    else current_cat = "center" end
                    end
                    
                    if current_cat and pp.transition_matrix[current_cat] then
                    local trans = pp.transition_matrix[current_cat]
                    local best_next = nil
                    local best_prob = 0
                    
                    for next_cat, prob in pairs(trans) do
                        if prob > best_prob then
                        best_prob = prob
                        best_next = next_cat
                        end
                    end
                    
                    if best_next and best_prob > 0.4 then
                        local target_pitch
                        if best_next == "down" then target_pitch = 85
                        elseif best_next == "up" then target_pitch = -70
                        else target_pitch = 0 end
                        
                        table.insert(strategies, {
                        pitch = target_pitch,
                        conf = 0.45 + best_prob * 0.2,
                        method = "markov"
                        })
                    end
                    end
                end
                
                
                if pp.dwell_times then
                    local best_region = "down"
                    local best_dwell = pp.dwell_times.down
                    
                    if pp.dwell_times.up > best_dwell then
                    best_region = "up"
                    best_dwell = pp.dwell_times.up
                    end
                    if pp.dwell_times.center > best_dwell then
                    best_region = "center"
                    best_dwell = pp.dwell_times.center
                    end
                    
                    if best_dwell > 0.5 then
                    local target_pitch
                    if best_region == "down" then target_pitch = 89
                    elseif best_region == "up" then target_pitch = -89
                    else target_pitch = 0 end
                    
                    table.insert(strategies, {
                        pitch = target_pitch,
                        conf = 0.40 + best_dwell * 0.25,
                        method = "dwell"
                    })
                    end
                end
                
                
                local failed_buckets = {}
                for _, fp in ipairs(data.miss_pitches or {}) do
                    local bucket = math.floor(fp / 20) * 20
                    failed_buckets[bucket] = (failed_buckets[bucket] or 0) + 1
                end
                
                local bf_candidates = {}
                for _, offset in ipairs(data.bruteforce_pitch_offsets) do
                    local bucket = math.floor(offset / 20) * 20
                    local fail_count = failed_buckets[bucket] or 0
                    table.insert(bf_candidates, {pitch = offset, score = 1.0 / (1 + fail_count * 0.5)})
                end
                
                table.sort(bf_candidates, function(a, b) return a.score > b.score end)
                
                local stage = data.bruteforce_stage or 0
                local selected = bf_candidates[(stage % #bf_candidates) + 1]
                
                table.insert(strategies, {
                    pitch = selected.pitch,
                    conf = 0.35 + selected.score * 0.1,
                    method = "bruteforce_smart"
                })
                data.bruteforce_stage = stage + 1
                
                
                if #strategies > 0 then
                    table.sort(strategies, function(a, b) return a.conf > b.conf end)
                    predicted_pitch = strategies[1].pitch
                    confidence = strategies[1].conf
                    method = strategies[1].method
                end
                
                data.predicted_pitch = math.max(-89, math.min(89, predicted_pitch))
                return data.predicted_pitch, confidence
                end
                
                
                if pattern == "static_down" then
                
                predicted_pitch = 89
                confidence = 0.92
                method = "static_down"
                
                
                if stats.mean < 80 then
                    predicted_pitch = stats.mean * 0.3 + 89 * 0.7
                    confidence = 0.85
                end
                
                elseif pattern == "static_up" then
                predicted_pitch = -89
                confidence = 0.85
                method = "static_up"
                
                if stats.mean > -70 then
                    predicted_pitch = stats.mean * 0.3 + (-89) * 0.7
                    confidence = 0.78
                end
                
                elseif pattern == "static_center" then
                predicted_pitch = stats.mean
                confidence = 0.80
                method = "static_center"
                
                elseif pattern == "periodic_jitter" then
                
                if pp.periodic_detected and pp.oscillation_frequency > 0 then
                    local phase = (now * pp.oscillation_frequency * 2 * math.pi) % (2 * math.pi)
                    local range = stats.range.max - stats.range.min
                    local center = (stats.range.max + stats.range.min) / 2
                    
                    predicted_pitch = center + math.sin(phase + pp.oscillation_phase) * (range / 2) * 0.7
                    confidence = 0.62
                    method = "periodic"
                else
                    predicted_pitch = stats.mean
                    confidence = 0.55
                    method = "periodic_fallback"
                end
                
                elseif pattern == "small_jitter" then
                
                predicted_pitch = stats.mean + pp.momentum_direction * 5
                
                
                if stats.mean > 20 then
                    predicted_pitch = predicted_pitch * 0.7 + 70 * 0.3
                end
                
                confidence = 0.65
                method = "small_jitter"
                
                elseif pattern == "wide_jitter" then
                
                local best_region = "down"
                local best_dwell = pp.dwell_times.down
                
                if pp.dwell_times.up > best_dwell + 0.15 then
                    best_region = "up"
                    best_dwell = pp.dwell_times.up
                end
                if pp.dwell_times.center > best_dwell + 0.1 then
                    best_region = "center"
                    best_dwell = pp.dwell_times.center
                end
                
                if best_region == "down" then
                    predicted_pitch = 80
                elseif best_region == "up" then
                    predicted_pitch = -70
                else
                    predicted_pitch = stats.mean
                end
                
                
                predicted_pitch = predicted_pitch + pp.momentum_direction * 8
                confidence = 0.55 + best_dwell * 0.15
                method = "wide_jitter"
                
                elseif pattern == "semi_random" then
                
                local strategies = {}
                
                
                if #data.hit_pitches >= 1 then
                    local hit_sum = 0
                    local hit_weight = 0
                    for i, p in ipairs(data.hit_pitches) do
                    local weight = math.exp((i - #data.hit_pitches) * 0.4)
                    hit_sum = hit_sum + p * weight
                    hit_weight = hit_weight + weight
                    end
                    if hit_weight > 0 then
                    table.insert(strategies, {
                        pitch = hit_sum / hit_weight,
                        conf = 0.52 + math.min(0.12, #data.hit_pitches * 0.025),
                        method = "hit_feedback"
                    })
                    end
                end
                
                
                local dwell_pitch = pp.dwell_times.down * 85 + 
                            pp.dwell_times.up * (-75) + 
                            pp.dwell_times.center * stats.mean
                table.insert(strategies, {
                    pitch = dwell_pitch,
                    conf = 0.45,
                    method = "dwell_weighted"
                })
                
                
                if math.abs(pp.momentum_direction) > 0.15 then
                    local extrapolated = samples[n] and samples[n].value or stats.mean
                    extrapolated = extrapolated + pp.velocity * 0.03
                    table.insert(strategies, {
                    pitch = math.max(-89, math.min(89, extrapolated)),
                    conf = 0.42 + math.abs(pp.momentum_direction) * 0.1,
                    method = "momentum"
                    })
                end
                
                
                table.insert(strategies, {
                    pitch = (stats.range.min + stats.range.max) / 2,
                    conf = 0.38,
                    method = "center"
                })
                
                
                if #strategies > 0 then
                    table.sort(strategies, function(a, b) return a.conf > b.conf end)
                    
                    local fused_pitch = 0
                    local fused_weight = 0
                    
                    for i = 1, math.min(3, #strategies) do
                    local weight = strategies[i].conf * strategies[i].conf
                    fused_pitch = fused_pitch + strategies[i].pitch * weight
                    fused_weight = fused_weight + weight
                    end
                    
                    if fused_weight > 0 then
                    predicted_pitch = fused_pitch / fused_weight
                    confidence = strategies[1].conf * 0.85
                    method = "fused_" .. strategies[1].method
                    end
                end
                
                elseif pattern == "fully_random" then
                
                local strategies = {}
                
                
                local best_region = "down"
                local best_dwell = pp.dwell_times.down
                
                if pp.dwell_times.up > best_dwell then
                    best_region = "up"
                    best_dwell = pp.dwell_times.up
                end
                if pp.dwell_times.center > best_dwell then
                    best_region = "center"
                    best_dwell = pp.dwell_times.center
                end
                
                local region_pitch
                if best_region == "down" then region_pitch = 85
                elseif best_region == "up" then region_pitch = -75
                else region_pitch = stats.mean end
                
                table.insert(strategies, {
                    pitch = region_pitch,
                    conf = 0.38 + best_dwell * 0.2,
                    method = "dwell_region"
                })
                
                
                if pp.transition_matrix and samples[n] then
                    local current_cat
                    if samples[n].value > 60 then current_cat = "down"
                    elseif samples[n].value < -40 then current_cat = "up"
                    else current_cat = "center" end
                    
                    if pp.transition_matrix[current_cat] then
                    local trans = pp.transition_matrix[current_cat]
                    local best_next = nil
                    local best_prob = 0
                    
                    for next_cat, prob in pairs(trans) do
                        if prob > best_prob then
                        best_prob = prob
                        best_next = next_cat
                        end
                    end
                    
                    if best_next and best_prob > 0.35 then
                        local target_pitch
                        if best_next == "down" then target_pitch = 85
                        elseif best_next == "up" then target_pitch = -70
                        else target_pitch = 0 end
                        
                        table.insert(strategies, {
                        pitch = target_pitch,
                        conf = 0.35 + best_prob * 0.25,
                        method = "markov"
                        })
                    end
                    end
                end
                
                
                if #data.hit_pitches >= 1 then
                    local hit_sum = 0
                    local hit_weight = 0
                    for i, p in ipairs(data.hit_pitches) do
                    local weight = math.exp((i - #data.hit_pitches) * 0.5)
                    hit_sum = hit_sum + p * weight
                    hit_weight = hit_weight + weight
                    end
                    if hit_weight > 0 then
                    table.insert(strategies, {
                        pitch = hit_sum / hit_weight,
                        conf = 0.50 + math.min(0.15, #data.hit_pitches * 0.04),
                        method = "hit_feedback"
                    })
                    end
                end
                
                
                local noise = math.sin(tick * 0.13) * 15 + math.cos(tick * 0.17) * 10
                table.insert(strategies, {
                    pitch = stats.mean + noise,
                    conf = 0.32,
                    method = "noisy_mean"
                })
                
                
                if #strategies > 0 then
                    table.sort(strategies, function(a, b) return a.conf > b.conf end)
                    predicted_pitch = strategies[1].pitch
                    confidence = strategies[1].conf
                    method = strategies[1].method
                end
                
                
                if confidence < 0.42 or data.miss_count >= 2 then
                    local stage = (data.bruteforce_stage or 0) % #data.bruteforce_pitch_offsets
                    local offset = data.bruteforce_pitch_offsets[stage + 1]
                    predicted_pitch = predicted_pitch * 0.5 + offset * 0.5
                    method = method .. "_bf"
                    data.bruteforce_stage = (data.bruteforce_stage or 0) + 1
                end
                
                else
                
                predicted_pitch = stats.mean
                
                
                if stats.mean > -20 and stats.mean < 60 then
                    predicted_pitch = stats.mean * 0.6 + 60 * 0.4
                end
                
                confidence = 0.45
                method = "unknown_biased"
                end
                
                
                if #pp.prediction_errors >= 3 then
                local error_sum = 0
                local error_weight = 0
                for i, err in ipairs(pp.prediction_errors) do
                    local weight = math.exp((i - #pp.prediction_errors) * 0.5)
                    error_sum = error_sum + err * weight
                    error_weight = error_weight + weight
                end
                
                if error_weight > 0 then
                    pp.adaptive_offset = (error_sum / error_weight) * 0.35
                    predicted_pitch = predicted_pitch + pp.adaptive_offset
                end
                end
                
                
                table.insert(pp.last_predictions, {pitch = predicted_pitch, time = now})
                while #pp.last_predictions > 10 do table.remove(pp.last_predictions, 1) end
                
                
                if samples[n] and #pp.last_predictions >= 2 then
                local prev_pred = pp.last_predictions[#pp.last_predictions - 1]
                if prev_pred then
                    local error = samples[n].value - prev_pred.pitch
                    table.insert(pp.prediction_errors, error)
                    while #pp.prediction_errors > 8 do table.remove(pp.prediction_errors, 1) end
                end
                end
                
                
                
                
                if #pp.prediction_errors >= 4 then
                local avg_abs_error = 0
                for _, err in ipairs(pp.prediction_errors) do
                    avg_abs_error = avg_abs_error + math.abs(err)
                end
                avg_abs_error = avg_abs_error / #pp.prediction_errors
                
                if avg_abs_error > 50 then
                    confidence = confidence * 0.70
                elseif avg_abs_error > 30 then
                    confidence = confidence * 0.85
                elseif avg_abs_error < 15 then
                    confidence = math.min(confidence * 1.10, 0.90)
                end
                end
                
                
                if n < 6 then
                confidence = confidence * 0.75
                elseif n < 10 then
                confidence = confidence * 0.88
                elseif n >= 18 then
                confidence = math.min(confidence * 1.06, 0.92)
                end
                
                
                if is_random then
                confidence = confidence * (1.0 - rand_score * 0.3)
                end
                
                
                predicted_pitch = math.max(-89, math.min(89, predicted_pitch))
                confidence = func.fclamp(confidence, 0.25, 0.92)
                
                data.predicted_pitch = predicted_pitch
                data.pitch_prediction_method = method
                
                return data.predicted_pitch, confidence
            end,
            
            
            predict = function(self, player)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data then return 0, 0, 0.4 end
                
                local now = globals.realtime()
                local tick = globals.tickcount()
                
                
                if data.cached_prediction and (now - data.cache_time) < 0.035 then
                return data.cached_prediction.yaw, data.cached_prediction.pitch, data.cached_prediction.conf
                end
                
                
                if not data.prediction_state then
                data.prediction_state = {
                    
                    strategy_history = {},
                    successful_strategies = {},
                    failed_strategies = {},
                    
                    
                    yaw_momentum = 0,
                    pitch_momentum = 0,
                    momentum_decay = 0.92,
                    
                    
                    yaw_weight = 0.70,
                    pitch_weight = 0.30,
                    weight_adaptation_rate = 0.08,
                    
                    
                    yaw_errors = {},
                    pitch_errors = {},
                    avg_yaw_error = 0,
                    avg_pitch_error = 0,
                    
                    
                    calibration_factor = 1.0,
                    overconfidence_penalty = 0,
                    
                    
                    pattern_stability = 0.5,
                    last_pattern_change = 0,
                    
                    
                    bruteforce_yaw_idx = 0,
                    bruteforce_pitch_idx = 0,
                    last_bruteforce_switch = 0,
                }
                end
                
                local ps = data.prediction_state
                
                
                local yaw_is_random, yaw_rand_score, yaw_pattern = self:analyze_yaw(player)
                local pitch_is_random, pitch_rand_score, pitch_pattern = self:analyze_pitch(player)
                
                
                local current_pattern_hash = yaw_pattern .. "_" .. pitch_pattern
                if not ps.last_pattern_hash then
                ps.last_pattern_hash = current_pattern_hash
                elseif ps.last_pattern_hash ~= current_pattern_hash then
                
                ps.pattern_stability = math.max(0.2, ps.pattern_stability * 0.7)
                ps.last_pattern_change = now
                ps.last_pattern_hash = current_pattern_hash
                else
                
                local stability_recovery = (now - ps.last_pattern_change) * 0.1
                ps.pattern_stability = math.min(1.0, ps.pattern_stability + stability_recovery * 0.02)
                end
                
                
                local yaw, yaw_conf = self:predict_yaw(player)
                local pitch, pitch_conf = self:predict_pitch(player)
                
                
                
                if #ps.yaw_errors >= 2 then
                local recent_error = ps.yaw_errors[#ps.yaw_errors] or 0
                local prev_error = ps.yaw_errors[#ps.yaw_errors - 1] or 0
                local error_trend = recent_error - prev_error
                
                
                if math.abs(error_trend) > 5 then
                    ps.yaw_momentum = ps.yaw_momentum * ps.momentum_decay + error_trend * 0.15
                end
                end
                
                if #ps.pitch_errors >= 2 then
                local recent_error = ps.pitch_errors[#ps.pitch_errors] or 0
                local prev_error = ps.pitch_errors[#ps.pitch_errors - 1] or 0
                local error_trend = recent_error - prev_error
                
                if math.abs(error_trend) > 3 then
                    ps.pitch_momentum = ps.pitch_momentum * ps.momentum_decay + error_trend * 0.12
                end
                end
                
                
                local momentum_corrected_yaw = yaw + ps.yaw_momentum * 0.4
                local momentum_corrected_pitch = pitch + ps.pitch_momentum * 0.3
                
                
                local feedback_adjustment = 0
                local total_shots = data.hit_count + data.miss_count
                
                if total_shots >= 2 then
                local hit_rate = data.hit_count / total_shots
                
                
                if hit_rate >= 0.60 then
                    
                    feedback_adjustment = (hit_rate - 0.50) * 0.40
                    ps.calibration_factor = math.min(1.15, ps.calibration_factor + 0.02)
                elseif hit_rate >= 0.45 then
                    
                    feedback_adjustment = (hit_rate - 0.45) * 0.25
                elseif hit_rate >= 0.30 then
                    
                    feedback_adjustment = (hit_rate - 0.40) * 0.35
                    ps.calibration_factor = math.max(0.70, ps.calibration_factor - 0.01)
                else
                    
                    feedback_adjustment = (hit_rate - 0.30) * 0.55
                    ps.calibration_factor = math.max(0.55, ps.calibration_factor - 0.03)
                end
                
                
                if data.last_hit_time and data.last_hit_time > 0 then
                    local time_since_hit = now - data.last_hit_time
                    if time_since_hit < 0.8 then
                    
                    feedback_adjustment = feedback_adjustment + 0.12 * (1 - time_since_hit / 0.8)
                    elseif time_since_hit > 3.0 then
                    
                    feedback_adjustment = feedback_adjustment - math.min(0.15, (time_since_hit - 3.0) * 0.03)
                    end
                end
                end
                
                
                local consecutive_miss_penalty = 0
                if data.consecutive_misses >= 1 then
                
                consecutive_miss_penalty = math.min(0.35, data.consecutive_misses * data.consecutive_misses * 0.025)
                
                
                if data.consecutive_misses >= 3 then
                    ps.bruteforce_yaw_idx = (ps.bruteforce_yaw_idx + 1) % #data.bruteforce_yaw_offsets
                    ps.bruteforce_pitch_idx = (ps.bruteforce_pitch_idx + 1) % #data.bruteforce_pitch_offsets
                    ps.last_bruteforce_switch = now
                    
                    
                    local bf_yaw_offset = data.bruteforce_yaw_offsets[ps.bruteforce_yaw_idx + 1] or 0
                    local bf_pitch_offset = data.bruteforce_pitch_offsets[ps.bruteforce_pitch_idx + 1] or 0
                    
                    
                    local bf_blend = math.min(0.75, data.consecutive_misses * 0.18)
                    momentum_corrected_yaw = momentum_corrected_yaw * (1 - bf_blend) + (data.yaw_stats.mean + bf_yaw_offset) * bf_blend
                    momentum_corrected_pitch = momentum_corrected_pitch * (1 - bf_blend) + bf_pitch_offset * bf_blend
                end
                else
                
                ps.bruteforce_yaw_idx = 0
                ps.bruteforce_pitch_idx = 0
                end
                
                
                local pattern_complexity_factor = 1.0
                
                if yaw_is_random and pitch_is_random then
                
                pattern_complexity_factor = 0.52 - yaw_rand_score * 0.1 - pitch_rand_score * 0.1
                elseif yaw_is_random then
                
                pattern_complexity_factor = 0.68 - yaw_rand_score * 0.15
                elseif pitch_is_random then
                
                pattern_complexity_factor = 0.80 - pitch_rand_score * 0.12
                else
                
                pattern_complexity_factor = 1.10 + ps.pattern_stability * 0.15
                end
                
                
                if yaw_pattern == "static" then
                pattern_complexity_factor = pattern_complexity_factor * 1.15
                elseif yaw_pattern == "alternating" then
                pattern_complexity_factor = pattern_complexity_factor * 1.05
                elseif yaw_pattern == "fully_random" then
                pattern_complexity_factor = pattern_complexity_factor * 0.70
                end
                
                if pitch_pattern == "static_down" or pitch_pattern == "static_up" then
                pattern_complexity_factor = pattern_complexity_factor * 1.08
                elseif pitch_pattern == "periodic_jitter" then
                pattern_complexity_factor = pattern_complexity_factor * 1.02
                elseif pitch_pattern == "fully_random" then
                pattern_complexity_factor = pattern_complexity_factor * 0.78
                end
                
                
                
                local yaw_predictability = yaw_conf * (1 - yaw_rand_score * 0.5)
                local pitch_predictability = pitch_conf * (1 - pitch_rand_score * 0.5)
                local total_predictability = yaw_predictability + pitch_predictability
                
                if total_predictability > 0.1 then
                local target_yaw_weight = yaw_predictability / total_predictability
                target_yaw_weight = func.fclamp(target_yaw_weight, 0.55, 0.85)
                
                ps.yaw_weight = ps.yaw_weight + (target_yaw_weight - ps.yaw_weight) * ps.weight_adaptation_rate
                ps.pitch_weight = 1.0 - ps.yaw_weight
                end
                
                
                local base_combined_conf = (yaw_conf * ps.yaw_weight + pitch_conf * ps.pitch_weight)
                
                
                local combined_conf = base_combined_conf
                combined_conf = combined_conf * pattern_complexity_factor
                combined_conf = combined_conf * ps.calibration_factor
                combined_conf = combined_conf + feedback_adjustment
                combined_conf = combined_conf - consecutive_miss_penalty
                combined_conf = combined_conf * (0.7 + ps.pattern_stability * 0.3)
                
                
                
                if total_shots >= 4 then
                local recent_high_conf_misses = 0
                
                for _, entry in ipairs(ps.strategy_history) do
                    if entry and entry.conf > 0.65 and not entry.hit then
                    recent_high_conf_misses = recent_high_conf_misses + 1
                    end
                end
                
                if recent_high_conf_misses >= 2 then
                    ps.overconfidence_penalty = math.min(0.20, recent_high_conf_misses * 0.04)
                else
                    ps.overconfidence_penalty = math.max(0, ps.overconfidence_penalty - 0.02)
                end
                
                combined_conf = combined_conf - ps.overconfidence_penalty
                end
                
                
                if #ps.yaw_errors >= 4 then
                local sum = 0
                for _, e in ipairs(ps.yaw_errors) do sum = sum + math.abs(e) end
                ps.avg_yaw_error = sum / #ps.yaw_errors
                
                
                if ps.avg_yaw_error > 40 then
                    combined_conf = combined_conf * 0.75
                elseif ps.avg_yaw_error > 25 then
                    combined_conf = combined_conf * 0.88
                elseif ps.avg_yaw_error < 12 then
                    combined_conf = math.min(combined_conf * 1.06, 0.88)
                end
                end
                
                if #ps.pitch_errors >= 4 then
                local sum = 0
                for _, e in ipairs(ps.pitch_errors) do sum = sum + math.abs(e) end
                ps.avg_pitch_error = sum / #ps.pitch_errors
                
                if ps.avg_pitch_error > 35 then
                    combined_conf = combined_conf * 0.82
                elseif ps.avg_pitch_error > 20 then
                    combined_conf = combined_conf * 0.92
                end
                end
                
                
                local sample_count = #(data.yaw_samples or {})
                if sample_count < 5 then
                combined_conf = combined_conf * 0.70
                elseif sample_count < 8 then
                combined_conf = combined_conf * 0.82
                elseif sample_count < 12 then
                combined_conf = combined_conf * 0.92
                elseif sample_count >= 20 then
                combined_conf = math.min(combined_conf * 1.05, 0.92)
                end
                
                
                combined_conf = func.fclamp(combined_conf, 0.20, 0.92)
                
                
                momentum_corrected_yaw = func.aa_clamp(momentum_corrected_yaw)
                momentum_corrected_pitch = math.max(-89, math.min(89, momentum_corrected_pitch))
                
                
                data.confidence = combined_conf
                data.yaw_is_random = yaw_is_random
                data.pitch_is_random = pitch_is_random
                
                
                table.insert(ps.strategy_history, {
                yaw = momentum_corrected_yaw,
                pitch = momentum_corrected_pitch,
                conf = combined_conf,
                time = now,
                yaw_pattern = yaw_pattern,
                pitch_pattern = pitch_pattern,
                hit = nil, 
                })
                while #ps.strategy_history > 15 do table.remove(ps.strategy_history, 1) end
                
                
                data.cached_prediction = {
                yaw = momentum_corrected_yaw, 
                pitch = momentum_corrected_pitch, 
                conf = combined_conf,
                yaw_pattern = yaw_pattern,
                pitch_pattern = pitch_pattern,
                yaw_random = yaw_is_random,
                pitch_random = pitch_is_random,
                }
                data.cache_time = now
                
                return momentum_corrected_yaw, momentum_corrected_pitch, combined_conf
            end,
            
            
            record_result = function(self, player, hit, hitgroup)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data then return end
                
                local now = globals.realtime()
                
                
                local used_offset = 0
                if data.predicted_yaw and data.last_yaw then
                    used_offset = func.aa_clamp(data.predicted_yaw - data.yaw_stats.mean)
                end
                
                if hit then
                    data.hit_count = data.hit_count + 1
                    data.miss_count = math.max(0, data.miss_count - 0.6)
                    data.consecutive_misses = 0
                    data.bruteforce_stage = 0
                    data.last_hit_time = now
                    
                    
                    if data.predicted_yaw then
                        table.insert(data.hit_yaws, data.predicted_yaw)
                        while #data.hit_yaws > 8 do table.remove(data.hit_yaws, 1) end
                    end
                    if data.predicted_pitch then
                        table.insert(data.hit_pitches, data.predicted_pitch)
                        while #data.hit_pitches > 8 do table.remove(data.hit_pitches, 1) end
                    end
                    
                    
                    local offset_key = math.floor(used_offset / 10) * 10
                    data.offset_weights[offset_key] = (data.offset_weights[offset_key] or 0) + data.learning_rate
                    table.insert(data.successful_offsets, used_offset)
                    while #data.successful_offsets > 10 do table.remove(data.successful_offsets, 1) end
                    
                else
                    data.miss_count = data.miss_count + 1
                    data.consecutive_misses = data.consecutive_misses + 1
                    
                    
                    if data.predicted_yaw then
                        table.insert(data.miss_yaws, data.predicted_yaw)
                        while #data.miss_yaws > 8 do table.remove(data.miss_yaws, 1) end
                    end
                    if data.predicted_pitch then
                        table.insert(data.miss_pitches, data.predicted_pitch)
                        while #data.miss_pitches > 8 do table.remove(data.miss_pitches, 1) end
                    end
                    
                    
                    local offset_key = math.floor(used_offset / 10) * 10
                    data.offset_weights[offset_key] = (data.offset_weights[offset_key] or 0) - data.learning_rate * 0.5
                    table.insert(data.failed_offsets, used_offset)
                    while #data.failed_offsets > 10 do table.remove(data.failed_offsets, 1) end
                    
                    
                    data.bruteforce_stage = (data.bruteforce_stage + 1) % #data.bruteforce_yaw_offsets
                    data.last_bruteforce_time = now
                end
                
                data.cached_prediction = nil
            end,
            
            
            get_override = function(self, player)
                local player_id = tostring(player)
                local data = self.players[player_id]
                if not data then return nil end
                
                local now = globals.realtime()
                
                if now - data.last_update > 2.5 then return nil end
                
                
                local yaw_is_random, yaw_rand_score, yaw_pattern = self:analyze_yaw(player)
                local pitch_is_random, pitch_rand_score, pitch_pattern = self:analyze_pitch(player)
                
                
                local predicted_yaw, yaw_conf = self:predict_yaw(player)
                local predicted_pitch, pitch_conf = self:predict_pitch(player)
                
                
                local predicted_side = 0
                if data.yaw_stats and data.yaw_stats.mean then
                    predicted_side = data.yaw_stats.mean > 0 and 1 or 0
                end
                
                
                local body_adjustment = predicted_side == 1 and 58 or -58
                
                
                local combined_conf = (yaw_conf * 0.65 + pitch_conf * 0.35)
                
                
                if yaw_is_random then
                    combined_conf = combined_conf * (1.0 - yaw_rand_score * 0.3)
                end
                if pitch_is_random then
                    combined_conf = combined_conf * (1.0 - pitch_rand_score * 0.2)
                end
                
                
                local bruteforce_active = false
                if data.consecutive_misses and data.consecutive_misses >= 3 then
                    bruteforce_active = true
                    combined_conf = combined_conf * 0.75
                end
                
                combined_conf = func.fclamp(combined_conf, 0.20, 0.85)
                
                return {
                    predicted_side = predicted_side,
                    predicted_yaw = predicted_yaw,
                    predicted_pitch = predicted_pitch,
                    yaw_adjustment = predicted_yaw - (data.yaw_stats and data.yaw_stats.mean or 0),
                    body_adjustment = body_adjustment,
                    confidence = combined_conf,
                    yaw_confidence = yaw_conf,
                    pitch_confidence = pitch_conf,
                    yaw_is_random = yaw_is_random,
                    pitch_is_random = pitch_is_random,
                    yaw_pattern = yaw_pattern,
                    pitch_pattern = pitch_pattern,
                    bruteforce_active = bruteforce_active,
                    use_pitch = predicted_pitch ~= nil,
                }
            end,
            
            
            cleanup = function(self)
                local now = globals.realtime()
                local players_to_remove = {}
                
                for player_id, data in pairs(self.players) do
                    
                    if now - data.last_update > 25.0 then
                        table.insert(players_to_remove, player_id)
                    end
                end
                
                for _, player_id in ipairs(players_to_remove) do
                    self.players[player_id] = nil
                end
            end,
        },
        
        
        update = function(self)
			self.enabled = true
            
            local modes = {}
            local jitter_enabled = true
            local defensive_enabled = true
            
            if type(modes) == "table" then
                for _, m in ipairs(modes) do
                    if m == "Jitter" then jitter_enabled = true end
                    if m == "Defensive" then defensive_enabled = true end
                end
            end
            
            self.enabled = jitter_enabled or defensive_enabled
            if not self.enabled then return end
            
            local me = entity.get_local_player()
            if not me or not entity.is_alive(me) then return end
            
            for player = 1, globals.maxplayers() do
                if entity.is_enemy(player) and entity.is_alive(player) and not entity.is_dormant(player) then
                    local pitch, yaw = entity.get_prop(player, "m_angEyeAngles")
                    local body_param = entity.get_prop(player, "m_flPoseParameter", 11)
                    
                    if yaw then
                        local body_yaw = body_param and (body_param * 120 - 60) or 0
                        
                        
                        self.fakelag:track_simtime(player)
                        self.fakelag:track_origin(player)
                        self.fakelag:track_velocity(player)
                        self.fakelag:track_air_state(player)
                        
                        if jitter_enabled then
                            self.jitter:sample_yaw(player, yaw, body_yaw)
                        end
                        
                        if defensive_enabled and pitch then
                            self.defensive:sample(player, yaw, pitch)
                        end
                    end
                end
            end
            
            
            if globals.tickcount() % 256 == 0 then
                self.jitter:cleanup()
                self.defensive:cleanup()
                self.fakelag:cleanup()
            end
        end,
        
        
        calculate_synergy = function(self, player, jit_override, def_override, preset)
            if not jit_override or not def_override then return nil end
            
            local player_id = tostring(player)
            local jit_data = self.jitter.players[player_id]
            local def_data = self.defensive.players[player_id]
            
            
            if not self.synergy_tracking then
                self.synergy_tracking = {}
            end
            if not self.synergy_tracking[player_id] then
                self.synergy_tracking[player_id] = {
                    agreement_history = {},
                    synergy_score = 0.5,
                    last_agreement = 0,
                    consecutive_agreements = 0,
                    consecutive_disagreements = 0,
                    jitter_reliability = 0.5,
                    defensive_reliability = 0.5,
                    combined_hits = 0,
                    combined_misses = 0,
                    pattern_synergy = {},
                }
            end
            
            local sync = self.synergy_tracking[player_id]
            local now = globals.realtime()
            
            
            local jit_side = jit_override.predicted_side or 0
            local def_yaw = def_override.predicted_yaw or 0
            
            
            local def_inferred_side = nil
            if def_data and def_data.yaw_stats then
                local mean = def_data.yaw_stats.mean or 0
                local last = def_data.last_yaw or mean
                
                if last > mean + 15 then
                    def_inferred_side = 1
                elseif last < mean - 15 then
                    def_inferred_side = 0
                end
            end
            
            
            local jit_body = jit_override.body_adjustment or 0
            local def_body_hint = def_override.yaw_adjustment or 0
            
            local body_agreement = false
            if (jit_body > 0 and def_body_hint > 0) or (jit_body < 0 and def_body_hint < 0) then
                body_agreement = true
            elseif math.abs(jit_body) < 15 or math.abs(def_body_hint) < 15 then
                
                body_agreement = true
            end
            
            
            local side_agreement = def_inferred_side == nil or def_inferred_side == jit_side
            
            
            local agreement_level = 0
            if side_agreement and body_agreement then
                agreement_level = 1.0
            elseif side_agreement or body_agreement then
                agreement_level = 0.6
            else
                agreement_level = 0.2
            end
            
            
            table.insert(sync.agreement_history, {
                level = agreement_level,
                time = now,
                jit_conf = jit_override.confidence,
                def_conf = def_override.confidence,
            })
            while #sync.agreement_history > 20 do
                table.remove(sync.agreement_history, 1)
            end
            
            
            if agreement_level >= 0.8 then
                sync.consecutive_agreements = sync.consecutive_agreements + 1
                sync.consecutive_disagreements = 0
            elseif agreement_level <= 0.3 then
                sync.consecutive_disagreements = sync.consecutive_disagreements + 1
                sync.consecutive_agreements = 0
            end
            
            
            
            if jit_data then
                local jit_total = jit_data.hit_count + jit_data.miss_count
                if jit_total >= 3 then
                    local jit_rate = jit_data.hit_count / jit_total
                    sync.jitter_reliability = sync.jitter_reliability * 0.8 + jit_rate * 0.2
                end
            end
            
            if def_data then
                local def_total = def_data.hit_count + def_data.miss_count
                if def_total >= 3 then
                    local def_rate = def_data.hit_count / def_total
                    sync.defensive_reliability = sync.defensive_reliability * 0.8 + def_rate * 0.2
                end
            end
            
            
            local jit_pattern = jit_override.pattern or "unknown"
            local jit_side_pattern = jit_override.side_pattern or "unknown"
            local def_yaw_random = def_override.yaw_is_random or false
            local def_pitch_random = def_override.pitch_is_random or false
            
            
            local jitter_weight = 0.55  
            local defensive_weight = 0.45  
            
            
            if jit_side_pattern == "fixed_delay" or jit_side_pattern == "sequence" then
                
                jitter_weight = jitter_weight + 0.15
            elseif jit_side_pattern == "chaotic" or jit_side_pattern == "reactive" then
                
                jitter_weight = jitter_weight - 0.10
                defensive_weight = defensive_weight + 0.10
            end
            
            if def_yaw_random then
                
                defensive_weight = defensive_weight + 0.12
            end
            
            if def_pitch_random then
                
                defensive_weight = defensive_weight + 0.08
            end
            
            
            local rel_diff = sync.jitter_reliability - sync.defensive_reliability
            jitter_weight = jitter_weight + rel_diff * 0.15
            defensive_weight = defensive_weight - rel_diff * 0.15
            
            
            local total_weight = jitter_weight + defensive_weight
            jitter_weight = jitter_weight / total_weight
            defensive_weight = defensive_weight / total_weight
            
            
            local base_synergy = 0.5
            
            
            if sync.consecutive_agreements >= 3 then
                base_synergy = base_synergy + 0.20
            elseif sync.consecutive_agreements >= 2 then
                base_synergy = base_synergy + 0.12
            end
            
            
            if sync.consecutive_disagreements >= 3 then
                base_synergy = base_synergy - 0.15
            elseif sync.consecutive_disagreements >= 2 then
                base_synergy = base_synergy - 0.08
            end
            
            
            if #sync.agreement_history >= 5 then
                local recent_sum = 0
                for i = #sync.agreement_history - 4, #sync.agreement_history do
                    recent_sum = recent_sum + sync.agreement_history[i].level
                end
                local recent_avg = recent_sum / 5
                base_synergy = base_synergy + (recent_avg - 0.5) * 0.20
            end
            
            
            local combined_total = sync.combined_hits + sync.combined_misses
            if combined_total >= 3 then
                local combined_rate = sync.combined_hits / combined_total
                base_synergy = base_synergy + (combined_rate - 0.5) * 0.25
            end
            
            sync.synergy_score = func.fclamp(base_synergy, 0.2, 0.95)
            
local predicted_side = jit_side  


local fused_body
if agreement_level >= 0.8 then
    fused_body = jit_body * jitter_weight + def_body_hint * defensive_weight
elseif agreement_level >= 0.5 then
    
    fused_body = jit_body * 0.7 + def_body_hint * 0.3
else
    
    fused_body = jit_body
end


if predicted_side == 1 then
    
    if fused_body <= 0 then
        fused_body = math.max(45, math.abs(fused_body))
    end
    
    if fused_body < 40 then
        fused_body = 58
    end
elseif predicted_side == 0 then
    
    if fused_body >= 0 then
        fused_body = -math.max(45, math.abs(fused_body))
    end
    
    if fused_body > -40 then
        fused_body = -58
    end
end

fused_body = math.max(-60, math.min(60, math.floor(fused_body + 0.5)))


if predicted_side == 1 and fused_body < 35 then
    fused_body = 58
elseif predicted_side == 0 and fused_body > -35 then
    fused_body = -58
end
            
            
            local jit_conf = jit_override.confidence or 0.5
            local def_conf = def_override.confidence or 0.5
            
            local fused_conf = jit_conf * jitter_weight + def_conf * defensive_weight
            
            
            fused_conf = fused_conf * (0.7 + sync.synergy_score * 0.4)
            
            
            if agreement_level >= 0.8 then
                fused_conf = fused_conf * 1.12
            elseif agreement_level <= 0.3 then
                fused_conf = fused_conf * 0.82
            end
            
            
            local conf_boost = self.jitter.weapon_presets:get_confidence_boost(preset)
            fused_conf = fused_conf + conf_boost
            
            
            if jit_data and jit_data.high_backtrack_penalty then
                fused_conf = fused_conf * (1 - jit_data.high_backtrack_penalty * 0.7)
            end
            
            fused_conf = func.fclamp(fused_conf, 0.15, 0.92)
            
            
            local use_pitch = def_override.predicted_pitch ~= nil
            local fused_pitch = def_override.predicted_pitch
            
            
            local pitch_conf = def_override.confidence or 0.5
            if def_pitch_random then
                pitch_conf = pitch_conf * 0.85
            end
            
            return {
                predicted_side = predicted_side,
                body_adjustment = fused_body,
                confidence = fused_conf,
                predicted_yaw = jit_override.predicted_yaw,
                predicted_pitch = fused_pitch,
                pitch_confidence = pitch_conf,
                use_pitch = use_pitch,
                bruteforce_active = jit_override.bruteforce_active or def_override.bruteforce_active,
                pattern = jit_pattern,
                side_pattern = jit_side_pattern,
                body_mode = jit_override.body_mode,
                resolver_state = jit_override.resolver_state,
                yaw_is_random = def_yaw_random,
                pitch_is_random = def_pitch_random,
                backtrack = jit_override.backtrack,
                
                jitter_weight = jitter_weight,
                defensive_weight = defensive_weight,
                agreement_level = agreement_level,
                synergy_score = sync.synergy_score,
                jitter_reliability = sync.jitter_reliability,
                defensive_reliability = sync.defensive_reliability,
            }
        end,
        
        
        record_synergy_result = function(self, player, hit)
            local player_id = tostring(player)
            if not self.synergy_tracking or not self.synergy_tracking[player_id] then return end
            
            local sync = self.synergy_tracking[player_id]
            
            if hit then
                sync.combined_hits = sync.combined_hits + 1
            else
                sync.combined_misses = sync.combined_misses + 1
            end
            
            
            local total = sync.combined_hits + sync.combined_misses
            if total > 50 then
                sync.combined_hits = math.floor(sync.combined_hits * 0.85)
                sync.combined_misses = math.floor(sync.combined_misses * 0.85)
            end
        end,
        
        
        apply = function(self, player)
            if not self.enabled then return end
            
            local modes = {}
            local use_jitter = true
            local use_defensive = true
            
            if type(modes) == "table" then
                for _, m in ipairs(modes) do
                    if m == "Jitter" then use_jitter = true end
                    if m == "Defensive" then use_defensive = true end
                end
            end
            
            
            local preset = self.jitter.weapon_presets and self.jitter.weapon_presets:get_current_preset()
            local weapon_type = preset and preset.name or "Unknown"
            
            
            local fl_info = self.fakelag:get_override(player)
            local is_breaking_lc = fl_info and (fl_info.breaking_lc or fl_info.exploit_detected)
            
            
            local target_health = entity.get_prop(player, "m_iHealth") or 100
            
            
            local force_body_threshold = preset and tonumber(preset.force_body_hp_threshold) or nil
            if preset and (preset.prefer_body == true or (force_body_threshold and target_health <= force_body_threshold)) then
                apply_force_body(player, true)
            end
            
            
            if preset.force_safe_point or target_health < 50 then
                plist.set(player, "Force safe point", true)
            end
            
            
            local override = nil
            local source = nil
            
            if use_jitter and use_defensive then
                local jit_override = self.jitter:get_override(player)
                local def_override = self.defensive:get_override(player)
                
                if jit_override and def_override then
                    override = self:calculate_synergy(player, jit_override, def_override, preset)
                    source = "combined"
                elseif jit_override and jit_override.confidence >= 0.20 then
                    override = jit_override
                    source = "jitter"
                elseif def_override and def_override.confidence >= 0.20 then
                    override = def_override
                    source = "defensive"
                end
            elseif use_jitter then
                local jit_override = self.jitter:get_override(player)
                if jit_override and jit_override.confidence >= 0.20 then
                    override = jit_override
                    source = "jitter"
                end
            elseif use_defensive then
                local def_override = self.defensive:get_override(player)
                if def_override and def_override.confidence >= 0.20 then
                    override = def_override
                    source = "defensive"
                end
            end
            
            local resolver_apply_source = source
            
            
            if override then
                local bt = override.backtrack or 0
                local conf = override.confidence or 0
                local player_id = tostring(player)
                local jit_data = self.jitter.players[player_id]
                
                
                
                
                if bt >= 15 and conf < 0.50 then
                    if resolver_debug and resolver_debug.enabled then
                        resolver_debug:log("REJECT", string.format("BT=%d >= 15 AND conf=%.2f < 0.50 - SKIPPING", bt, conf), 255, 80, 80)
                    end
                    return
                end
                
                
                local side_pattern = override.side_pattern or (jit_data and jit_data.side_pattern) or "unknown"
                local yaw_is_random = override.yaw_is_random or false
                
                if side_pattern == "reactive" and yaw_is_random then
                    if resolver_debug and resolver_debug.enabled then
                        resolver_debug:log("REJECT", string.format("Pattern=reactive + random=Y - SKIPPING (unpredictable)", bt), 255, 80, 80)
                    end
                    return
                end
                
                
                local delay_variance = jit_data and jit_data.delay_variance or 0
                if delay_variance > 20 then
                    if resolver_debug and resolver_debug.enabled then
                        resolver_debug:log("REJECT", string.format("Delay variance=%.1f > 20 - SKIPPING (too chaotic)", delay_variance), 255, 80, 80)
                    end
                    return
                end
                
                
                local high_bt_penalty = jit_data and jit_data.high_backtrack_penalty or 0
                if high_bt_penalty > 0.25 then
                    if resolver_debug and resolver_debug.enabled then
                        resolver_debug:log("REJECT", string.format("BT penalty=%.0f%% > 25%% - SKIPPING", high_bt_penalty * 100), 255, 80, 80)
                    end
                    return
                end
                
                
                if bt >= 22 then
                    if resolver_debug and resolver_debug.enabled then
                        resolver_debug:log("REJECT", string.format("BT=%d >= 22 - ALWAYS SKIP", bt), 255, 50, 50)
                    end
                    return
                end
                
                
                local base_conf = 0.18
                local aggression = self.jitter.weapon_presets:get_aggression(preset)
                
                local required_conf = base_conf
                
                if bt >= 18 then
                    required_conf = 0.70
                elseif bt >= 15 then
                    required_conf = 0.55
                elseif bt >= 12 then
                    required_conf = 0.45
                elseif bt >= 10 then
                    required_conf = 0.38
                elseif bt >= 8 then
                    required_conf = 0.32
                elseif bt >= 6 then
                    required_conf = 0.25
                end
                
                
                required_conf = required_conf * (1.1 - aggression * 0.2)
                
                
                if source == "combined" and override.synergy_score then
                    required_conf = required_conf * (1.0 - override.synergy_score * 0.15)
                end
                
                if override.bruteforce_active then
                    required_conf = required_conf * 0.70
                end
                
                
                if conf < required_conf then
                    if resolver_debug and resolver_debug.enabled then
                        resolver_debug:log_skip_confidence(bt, conf, required_conf, weapon_type)
                    end
                    return
                end
                
                
                local body_offset = self:calculate_dynamic_body_offset(player, override, jit_data, side_pattern)
                
                local side = override.predicted_side or 0
                
                
                if side == 1 and body_offset <= 0 then body_offset = 58 end
                if side == 0 and body_offset >= 0 then body_offset = -58 end
                
                plist.set(player, "Force body yaw", true)
                plist.set(player, "Body yaw value", body_offset)
                
                
                if (source == "defensive" or source == "combined") and override.use_pitch and override.predicted_pitch then
                    local pitch_offset = math.floor(override.predicted_pitch or 0)
                    pitch_offset = math.max(-89, math.min(89, pitch_offset))
                    plist.set(player, "Pitch value", pitch_offset)
                end
                
                
                if resolver_debug and resolver_debug.enabled then
                    resolver_debug:log_apply(weapon_type, side, body_offset, conf, source, override)
                end
            end
        end,
        
        
        calculate_dynamic_body_offset = function(self, player, override, jit_data, side_pattern)
            local base_offset = override.body_adjustment or 0
            local side = override.predicted_side or 0
            local now = globals.realtime()
            
            
            if not self.body_pattern_tracking then
                self.body_pattern_tracking = {}
            end
            
            local player_id = tostring(player)
            if not self.body_pattern_tracking[player_id] then
                self.body_pattern_tracking[player_id] = {
                    last_offset = -58,
                    offset_history = {},
                    hit_offsets = {},
                    miss_offsets = {},
                    pattern_offset_map = {},
                    last_update = 0,
                }
            end
            
            local tracking = self.body_pattern_tracking[player_id]
            
            
            local calculated_offset = 0
            local offset_confidence = 0.5
            
            if side_pattern == "fixed_delay" then
                
                local base = side == 1 and 58 or -58
                local variation = math.sin(now * 2) * 4  
                calculated_offset = base + variation
                offset_confidence = 0.85
                
            elseif side_pattern == "sequence" then
                
                local sequence_offsets = {58, 52, 45, 52, 58}
                local seq_idx = (math.floor(now * 3) % #sequence_offsets) + 1
                calculated_offset = side == 1 and sequence_offsets[seq_idx] or -sequence_offsets[seq_idx]
                offset_confidence = 0.75
                
            elseif side_pattern == "tight_random" then
                
                if #tracking.hit_offsets >= 2 then
                    local sum = 0
                    local weight_sum = 0
                    for i, off in ipairs(tracking.hit_offsets) do
                        local weight = i / #tracking.hit_offsets  
                        sum = sum + off * weight
                        weight_sum = weight_sum + weight
                    end
                    calculated_offset = sum / weight_sum
                    offset_confidence = 0.70
                else
                    calculated_offset = side == 1 and 55 or -55
                    offset_confidence = 0.55
                end
                
            elseif side_pattern == "variable_delay" or side_pattern == "clustered" then
                
                local tick = globals.tickcount()
                local options = {58, 50, 42}
                local idx = (tick % (#options * 3)) / 3 + 1
                idx = math.floor(idx)
                idx = math.max(1, math.min(#options, idx))
                calculated_offset = side == 1 and options[idx] or -options[idx]
                offset_confidence = 0.60
                
            elseif side_pattern == "reactive" then
                
                local fast_cycle = math.floor(now * 5) % 4
                local reactive_offsets = {58, 45, 52, 38}
                calculated_offset = side == 1 and reactive_offsets[fast_cycle + 1] or -reactive_offsets[fast_cycle + 1]
                offset_confidence = 0.50
                
            elseif side_pattern == "chaotic" or side_pattern == "side_predictable" then
                
                local bf_cycle = (globals.tickcount() % 20) / 5
                local chaotic_offsets = {58, 48, 40, 55}
                local idx = math.floor(bf_cycle) + 1
                idx = math.max(1, math.min(4, idx))
                calculated_offset = side == 1 and chaotic_offsets[idx] or -chaotic_offsets[idx]
                offset_confidence = 0.40
                
            else
                
                local base = side == 1 and 58 or -58
                local jitter = math.sin(now * 1.5) * 6
                calculated_offset = base + (side == 1 and -jitter or jitter)
                offset_confidence = 0.50
            end
            
            
            
            if #tracking.hit_offsets >= 3 then
                local recent_hit_avg = 0
                local count = math.min(5, #tracking.hit_offsets)
                for i = #tracking.hit_offsets - count + 1, #tracking.hit_offsets do
                    recent_hit_avg = recent_hit_avg + tracking.hit_offsets[i]
                end
                recent_hit_avg = recent_hit_avg / count
                
                
                local learn_weight = math.min(0.4, #tracking.hit_offsets * 0.05)
                calculated_offset = calculated_offset * (1 - learn_weight) + recent_hit_avg * learn_weight
            end
            
            
            if #tracking.miss_offsets >= 2 then
                
                local avg_miss = 0
                local count = math.min(3, #tracking.miss_offsets)
                for i = #tracking.miss_offsets - count + 1, #tracking.miss_offsets do
                    avg_miss = avg_miss + tracking.miss_offsets[i]
                end
                avg_miss = avg_miss / count
                
                
                if math.abs(calculated_offset - avg_miss) < 8 then
                    local shift = (calculated_offset > avg_miss) and 10 or -10
                    calculated_offset = calculated_offset + shift
                end
            end
            
            
            calculated_offset = math.max(-60, math.min(60, math.floor(calculated_offset + 0.5)))
            
            
            if side == 1 and calculated_offset < 0 then
                calculated_offset = math.abs(calculated_offset)
            elseif side == 0 and calculated_offset > 0 then
                calculated_offset = -math.abs(calculated_offset)
            end
            
            
            if math.abs(calculated_offset) < 35 then
                calculated_offset = side == 1 and 45 or -45
            end
            
            
            tracking.last_offset = calculated_offset
            tracking.last_update = now
            
            return calculated_offset
        end,
        
        track_body_offset_result = function(self, player, body_offset, hit)
            local player_id = tostring(player)
            
            if not self.body_pattern_tracking then
                self.body_pattern_tracking = {}
            end
            
            if not self.body_pattern_tracking[player_id] then
                self.body_pattern_tracking[player_id] = {
                    last_offset = -58,
                    offset_history = {},
                    hit_offsets = {},
                    miss_offsets = {},
                    pattern_offset_map = {},
                    last_update = 0,
                }
            end
            
            local tracking = self.body_pattern_tracking[player_id]
            
            if hit then
                table.insert(tracking.hit_offsets, body_offset)
                while #tracking.hit_offsets > 20 do
                    table.remove(tracking.hit_offsets, 1)
                end
            else
                table.insert(tracking.miss_offsets, body_offset)
                while #tracking.miss_offsets > 15 do
                    table.remove(tracking.miss_offsets, 1)
                end
            end
            
            table.insert(tracking.offset_history, {
                offset = body_offset,
                hit = hit,
                time = globals.realtime()
            })
            while #tracking.offset_history > 30 do
                table.remove(tracking.offset_history, 1)
            end
        end,

        
        check_yaw_error_inversion = function(self, player, predicted_yaw, actual_yaw)
            local yaw_error = math.abs(func.aa_clamp(predicted_yaw - actual_yaw))
            
            if yaw_error > 100 then
                local player_id = tostring(player)
                local jit_data = self.jitter.players[player_id]
                
                if jit_data then
                    
                    jit_data.current_side = 1 - (jit_data.current_side or 0)
                    jit_data.switch_delay = 0
                    jit_data.side_inverted = true
                    jit_data.inversion_time = globals.realtime()
                    
                    if resolver_debug and resolver_debug.enabled then
                        resolver_debug:log("INVERT", string.format("Yaw error=%.1f° > 100° - INVERTING SIDE to %d", 
                            yaw_error, jit_data.current_side), 255, 200, 50)
                    end
                    
                    return true
                end
            end
            
            return false
        end,
    }

    local function apply_weapon_multipoint(player)
        if not resolver or not resolver.enabled then return end
        if not resolver.weapon_presets then return end
        
        local preset = resolver.weapon_presets:get_current_preset()
        if not preset or not preset.multipoint then return end
        
        local target_health = entity.get_prop(player, "m_iHealth") or 100
        
        
        local force_body_threshold = preset and tonumber(preset.force_body_hp_threshold) or nil

        if preset and (preset.prefer_body == true or (force_body_threshold and target_health <= force_body_threshold)) then
            apply_force_body(player, true)
        end

        if preset.force_safe_point then
            pcall(function()
                local ref = ui.reference("RAGE", "Aimbot", "Force safe point")
                if ref then ui.set(ref, true) end
            end)
        end
    end
local resolver_base = {
    
    config = {
        max_velocity_samples = 32,
        max_layer_samples = 24,
        feature_cache_duration = 0.016,  
        jitter_detection_window = 16,
        pose_param_count = 24,
        desync_sample_limit = 4096,
    },
    
    
    players = {},
    
    
    pose_indices = {
        lean_yaw = 0,
        speed = 1,
        ladder_speed = 2,
        ladder_yaw = 3,
        move_yaw = 4,
        run = 5,
        body_yaw = 6,
        body_pitch = 7,
        death_yaw = 8,
        stand = 9,
        jump_fall = 10,
        aim_blend_stand_idle = 11,
        aim_blend_crouch_idle = 12,
        strafe_yaw = 13,
        aim_blend_stand_walk = 14,
        aim_blend_stand_run = 15,
        aim_blend_crouch_walk = 16,
        move_blend_walk = 17,
        move_blend_run = 18,
        move_blend_crouch = 19,
        
        speed_blend = 20,
        velocity_blend = 21,
    },
    
    
    layer_indices = {
        AIMMATRIX = 0,
        WEAPON_ACTION = 1,
        WEAPON_ACTION_RECROUCH = 2,
        ADJUST = 3,
        MOVEMENT_JUMP_OR_FALL = 4,
        MOVEMENT_LAND_OR_CLIMB = 5,
        MOVEMENT_MOVE = 6,
        MOVEMENT_STRAFECHANGE = 7,
        WHOLE_BODY = 8,
        FLASHED = 9,
        FLINCH = 10,
        ALIVELOOP = 11,
        LEAN = 12,
    },
}
local ffi = require("ffi")

ffi.cdef[[
    typedef struct {
        float m_flStart;
        float m_flEnd;
        float m_flState;
    } poseparam_t;
]]




resolver_base.safe_layers = {
    
    cache = {},
    cache_time = {},
    
    
    get = function(self, player, layer_index)
        if not player or not entity.is_alive(player) then
            return nil
        end
        
        local player_id = tostring(player)
        local cache_key = player_id .. "_" .. tostring(layer_index)
        local now = globals.realtime()
        
        
        if self.cache[cache_key] and self.cache_time[cache_key] then
            if (now - self.cache_time[cache_key]) < resolver_base.config.feature_cache_duration then
                return self.cache[cache_key]
            end
        end
        
        
        local success, layer = pcall(function()
            return entity.get_animlayer(player, layer_index)
        end)
        
        if not success or not layer then
            return nil
        end
        
        
        local layer_data = nil
        pcall(function()
            layer_data = {
                sequence = tonumber(layer.sequence) or 0,
                prev_cycle = tonumber(layer.prev_cycle) or 0,
                weight = tonumber(layer.weight) or 0,
                weight_delta_rate = tonumber(layer.weight_delta_rate) or 0,
                playback_rate = tonumber(layer.playback_rate) or 0,
                cycle = tonumber(layer.cycle) or 0,
                valid = true,
            }
            
            
            layer_data.weight = math.max(0, math.min(1, layer_data.weight))
            layer_data.cycle = math.max(0, math.min(1, layer_data.cycle))
            layer_data.prev_cycle = math.max(0, math.min(1, layer_data.prev_cycle))
        end)
        
        
        if layer_data then
            self.cache[cache_key] = layer_data
            self.cache_time[cache_key] = now
        end
        
        return layer_data
    end,
    
    
    get_all = function(self, player)
        local layers = {}
        for i = 0, 12 do
            layers[i] = self:get(player, i)
        end
        return layers
    end,
    
    
    is_active = function(self, player, layer_index, weight_threshold)
        local layer = self:get(player, layer_index)
        if not layer then return false end
        return layer.weight >= (weight_threshold or 0.1)
    end,
    
    
    clear_cache = function(self, player)
        local player_id = tostring(player)
        for key, _ in pairs(self.cache) do
            if key:find(player_id) == 1 then
                self.cache[key] = nil
                self.cache_time[key] = nil
            end
        end
    end,
}




resolver_base.safe_animstate = {
    cache = {},
    cache_time = {},
    
    
    get = function(self, player)
        if not player or not entity.is_alive(player) then
            return nil
        end
        
        local player_id = tostring(player)
        local now = globals.realtime()
        
        
        if self.cache[player_id] and self.cache_time[player_id] then
            if (now - self.cache_time[player_id]) < resolver_base.config.feature_cache_duration then
                return self.cache[player_id]
            end
        end
        
        
        local success, animstate = pcall(function()
            return entity.get_animstate(player)
        end)
        
        if not success or not animstate then
            return nil
        end
        
        
        local state_data = nil
        pcall(function()
            state_data = {
                
                anim_update_timer = tonumber(animstate.anim_update_timer) or 0,
                started_moving_time = tonumber(animstate.started_moving_time) or 0,
                last_move_time = tonumber(animstate.last_move_time) or 0,
                last_lby_time = tonumber(animstate.last_lby_time) or 0,
                last_client_side_animation_update_time = tonumber(animstate.last_client_side_animation_update_time) or 0,
                
                
                run_amount = tonumber(animstate.run_amount) or 0,
                velocity_x = tonumber(animstate.velocity_x) or 0,
                velocity_y = tonumber(animstate.velocity_y) or 0,
                m_velocity = tonumber(animstate.m_velocity) or 0,
                jump_fall_velocity = tonumber(animstate.jump_fall_velocity) or 0,
                clamped_velocity = tonumber(animstate.clamped_velocity) or 0,
                
                
                eye_angles_y = tonumber(animstate.eye_angles_y) or 0,
                eye_angles_x = tonumber(animstate.eye_angles_x) or 0,
                goal_feet_yaw = tonumber(animstate.goal_feet_yaw) or 0,
                current_feet_yaw = tonumber(animstate.current_feet_yaw) or 0,
                torso_yaw = tonumber(animstate.torso_yaw) or 0,
                last_move_yaw = tonumber(animstate.last_move_yaw) or 0,
                
                
                feet_cycle = tonumber(animstate.feet_cycle) or 0,
                feet_yaw_rate = tonumber(animstate.feet_yaw_rate) or 0,
                feet_speed_forwards_or_sideways = tonumber(animstate.feet_speed_forwards_or_sideways) or 0,
                
                
                duck_amount = tonumber(animstate.duck_amount) or 0,
                landing_duck_amount = tonumber(animstate.landing_duck_amount) or 0,
                
                
                current_origin = {
                    animstate.current_origin[0] or 0,
                    animstate.current_origin[1] or 0,
                    animstate.current_origin[2] or 0,
                },
                last_origin = {
                    animstate.last_origin[0] or 0,
                    animstate.last_origin[1] or 0,
                    animstate.last_origin[2] or 0,
                },
                
                
                on_ground = animstate.on_ground or false,
                hit_in_ground_animation = animstate.hit_in_ground_animation or false,
                time_since_in_air = tonumber(animstate.time_since_in_air) or 0,
                last_origin_z = tonumber(animstate.last_origin_z) or 0,
                
                
                lean_amount = tonumber(animstate.lean_amount) or 0,
                stop_to_full_running_fraction = tonumber(animstate.stop_to_full_running_fraction) or 0,
                magic_fraction = tonumber(animstate.magic_fraction) or 0,
                world_force = tonumber(animstate.world_force) or 0,
                
                
                min_yaw = tonumber(animstate.min_yaw) or -60,
                max_yaw = tonumber(animstate.max_yaw) or 60,
                
                
                valid = true,
                timestamp = now,
            }
            
            
            state_data.desync_delta = state_data.max_yaw - state_data.min_yaw
            state_data.velocity_2d = math.sqrt(state_data.velocity_x^2 + state_data.velocity_y^2)
            state_data.body_yaw = func.aa_clamp(state_data.goal_feet_yaw - state_data.eye_angles_y)
        end)
        
        
        if state_data then
            self.cache[player_id] = state_data
            self.cache_time[player_id] = now
        end
        
        return state_data
    end,
    
    
    get_yaw_data = function(self, player)
        local state = self:get(player)
        if not state then return nil end
        
        return {
            eye_yaw = state.eye_angles_y,
            goal_feet_yaw = state.goal_feet_yaw,
            current_feet_yaw = state.current_feet_yaw,
            body_yaw = state.body_yaw,
            min_yaw = state.min_yaw,
            max_yaw = state.max_yaw,
        }
    end,
    
    
    clear_cache = function(self, player)
        local player_id = tostring(player)
        self.cache[player_id] = nil
        self.cache_time[player_id] = nil
    end,
}




resolver_base.pose_params = {
    cache = {},
    cache_time = {},
    
    
    get = function(self, player)
        if not player or not entity.is_alive(player) then
            return nil
        end
        
        local player_id = tostring(player)
        local now = globals.realtime()
        
        
        if self.cache[player_id] and self.cache_time[player_id] then
            if (now - self.cache_time[player_id]) < resolver_base.config.feature_cache_duration then
                return self.cache[player_id]
            end
        end
        
        
        local params = {}
        local success = pcall(function()
            
            for i = 0, 23 do
                local param = entity.get_prop(player, "m_flPoseParameter", i)
                params[i] = tonumber(param) or 0
                
                params[i] = math.max(0, math.min(1, params[i]))
            end
        end)
        
        if not success then
            return nil
        end
        
        
        params.body_yaw = params[resolver_base.pose_indices.body_yaw] or 0
        params.body_pitch = params[resolver_base.pose_indices.body_pitch] or 0
        params.lean_yaw = params[resolver_base.pose_indices.lean_yaw] or 0
        params.move_yaw = params[resolver_base.pose_indices.move_yaw] or 0
        params.speed = params[resolver_base.pose_indices.speed] or 0
        params.stand = params[resolver_base.pose_indices.stand] or 0
        params.valid = true
        params.timestamp = now
        
        
        self.cache[player_id] = params
        self.cache_time[player_id] = now
        
        return params
    end,
    
    
    pose_to_angle = function(self, pose_value, min_val, max_val)
        min_val = min_val or -60
        max_val = max_val or 60
        return min_val + (max_val - min_val) * pose_value
    end,
    
    
    get_body_yaw_angle = function(self, player)
        local params = self:get(player)
        if not params then return 0 end
        
        
        return self:pose_to_angle(params.body_yaw, -60, 60)
    end,
    
    
    clear_cache = function(self, player)
        local player_id = tostring(player)
        self.cache[player_id] = nil
        self.cache_time[player_id] = nil
    end,
}




resolver_base.features = {
    
    extract = function(self, player)
        if not player or not entity.is_alive(player) then
            return nil
        end
        
        local animstate = resolver_base.safe_animstate:get(player)
        local pose_params = resolver_base.pose_params:get(player)
        local layers = resolver_base.safe_layers:get_all(player)
        
        if not animstate or not pose_params then
            return nil
        end
        
        local features = {
            valid = true,
            timestamp = globals.realtime(),
            
            
            velocity_x = animstate.velocity_x,
            velocity_y = animstate.velocity_y,
            velocity_2d = animstate.velocity_2d,
            velocity_clamped = animstate.clamped_velocity,
            
            
            eye_yaw = animstate.eye_angles_y,
            goal_feet_yaw = animstate.goal_feet_yaw,
            current_feet_yaw = animstate.current_feet_yaw,
            body_yaw_delta = animstate.body_yaw,
            
            
            duck_amount = animstate.duck_amount,
            run_amount = animstate.run_amount,
            on_ground = animstate.on_ground and 1 or 0,
            lean_amount = animstate.lean_amount,
            
            
            pose_body_yaw = pose_params.body_yaw,
            pose_move_yaw = pose_params.move_yaw,
            pose_speed = pose_params.speed,
            pose_stand = pose_params.stand,
            
            
            layer_adjust_weight = layers[3] and layers[3].weight or 0,
            layer_move_weight = layers[6] and layers[6].weight or 0,
            layer_strafe_weight = layers[7] and layers[7].weight or 0,
            layer_lean_weight = layers[12] and layers[12].weight or 0,
            
            
            feet_cycle = animstate.feet_cycle,
            feet_yaw_rate = animstate.feet_yaw_rate,
            desync_limit = (animstate.max_yaw - animstate.min_yaw) / 2,
            magic_fraction = animstate.magic_fraction,
        }
        
        
        features.vector = {
            features.velocity_x / 250,  
            features.velocity_y / 250,
            features.velocity_2d / 250,
            features.velocity_clamped / 260,
            features.eye_yaw / 180,
            features.goal_feet_yaw / 180,
            features.current_feet_yaw / 180,
            features.body_yaw_delta / 60,
            features.duck_amount,
            features.run_amount,
            features.on_ground,
            features.lean_amount / 30,
            features.pose_body_yaw,
            features.pose_move_yaw,
            features.pose_speed,
            features.pose_stand,
            features.layer_adjust_weight,
            features.layer_move_weight,
            features.layer_strafe_weight,
            features.layer_lean_weight,
            features.feet_cycle,
            features.feet_yaw_rate / 5,
            features.desync_limit / 60,
            features.magic_fraction,
        }
        
        return features
    end,
    
    
    get_vector = function(self, player)
        local features = self:extract(player)
        if not features then return nil end
        return features.vector
    end,
    
    
    distance = function(self, features1, features2)
        if not features1 or not features2 then return 999 end
        
        local v1 = features1.vector or features1
        local v2 = features2.vector or features2
        
        local sum = 0
        for i = 1, math.min(#v1, #v2) do
            sum = sum + (v1[i] - v2[i])^2
        end
        
        return math.sqrt(sum)
    end,
}




resolver_base.velocity = {
    players = {},
    
    
    init_player = function(self, player_id)
        if not self.players[player_id] then
            self.players[player_id] = {
                samples = {},
                max_samples = resolver_base.config.max_velocity_samples,
                
                
                avg_speed = 0,
                max_speed = 0,
                min_speed = 0,
                speed_variance = 0,
                
                
                avg_direction = 0,
                direction_changes = 0,
                last_direction = 0,
                
                
                is_accelerating = false,
                is_decelerating = false,
                is_strafing = false,
                strafe_direction = 0,
                
                
                last_update = 0,
                movement_start_time = 0,
                movement_end_time = 0,
            }
        end
        return self.players[player_id]
    end,
    
    
    sample = function(self, player)
        if not player or not entity.is_alive(player) then
            return nil
        end
        
        local player_id = tostring(player)
        local data = self:init_player(player_id)
        local now = globals.realtime()
        local tick = globals.tickcount()
        
        
        local vx, vy, vz = entity.get_prop(player, "m_vecVelocity")
        vx, vy, vz = vx or 0, vy or 0, vz or 0
        
        local speed = math.sqrt(vx * vx + vy * vy)
        local direction = math.atan2(vy, vx) * (180 / math.pi)
        
        
        local animstate = resolver_base.safe_animstate:get(player)
        
        local sample = {
            vx = vx,
            vy = vy,
            vz = vz,
            speed = speed,
            direction = direction,
            time = now,
            tick = tick,
            on_ground = animstate and animstate.on_ground or true,
            duck_amount = animstate and animstate.duck_amount or 0,
        }
        
        
        table.insert(data.samples, sample)
        while #data.samples > data.max_samples do
            table.remove(data.samples, 1)
        end
        
        
        self:update_stats(player_id)
        
        
        self:detect_movement_state(player_id)
        
        data.last_update = now
        return sample
    end,
    
    
    update_stats = function(self, player_id)
        local data = self.players[player_id]
        if not data or #data.samples < 2 then return end
        
        local sum_speed = 0
        local sum_dir = 0
        local max_speed = 0
        local min_speed = 999
        
        for _, s in ipairs(data.samples) do
            sum_speed = sum_speed + s.speed
            sum_dir = sum_dir + s.direction
            max_speed = math.max(max_speed, s.speed)
            min_speed = math.min(min_speed, s.speed)
        end
        
        data.avg_speed = sum_speed / #data.samples
        data.avg_direction = sum_dir / #data.samples
        data.max_speed = max_speed
        data.min_speed = min_speed
        
        
        local sum_sq = 0
        for _, s in ipairs(data.samples) do
            sum_sq = sum_sq + (s.speed - data.avg_speed)^2
        end
        data.speed_variance = sum_sq / #data.samples
        
        
        local dir_changes = 0
        for i = 2, #data.samples do
            local diff = math.abs(data.samples[i].direction - data.samples[i-1].direction)
            if diff > 180 then diff = 360 - diff end
            if diff > 45 then
                dir_changes = dir_changes + 1
            end
        end
        data.direction_changes = dir_changes
    end,
    
    
    detect_movement_state = function(self, player_id)
        local data = self.players[player_id]
        if not data or #data.samples < 4 then return end
        
        local recent = {}
        for i = math.max(1, #data.samples - 3), #data.samples do
            table.insert(recent, data.samples[i])
        end
        
        
        local speed_trend = 0
        for i = 2, #recent do
            speed_trend = speed_trend + (recent[i].speed - recent[i-1].speed)
        end
        
        data.is_accelerating = speed_trend > 10
        data.is_decelerating = speed_trend < -10
        
        
        if data.avg_speed > 50 and data.direction_changes >= 2 then
            data.is_strafing = true
            
            local last_dir_change = recent[#recent].direction - recent[#recent-1].direction
            data.strafe_direction = last_dir_change > 0 and 1 or -1
        else
            data.is_strafing = false
            data.strafe_direction = 0
        end
    end,
    
    
    get = function(self, player)
        local player_id = tostring(player)
        return self.players[player_id]
    end,
    
    
    clear = function(self, player)
        local player_id = tostring(player)
        self.players[player_id] = nil
    end,
}




resolver_base.jitter_detection = {
    players = {},
    
    init_player = function(self, player_id)
        if not self.players[player_id] then
            self.players[player_id] = {
                yaw_samples = {},
                body_samples = {},
                max_samples = resolver_base.config.jitter_detection_window,
                
                
                is_jittering = false,
                jitter_type = "none",  
                jitter_amplitude = 0,
                jitter_frequency = 0,
                jitter_center = 0,
                
                
                pattern_sequence = {},
                pattern_length = 0,
                pattern_confidence = 0,
                
                
                last_update = 0,
                jitter_start_time = 0,
            }
        end
        return self.players[player_id]
    end,
    
    
    sample = function(self, player, yaw, body_yaw)
        if not player then return nil end
        
        local player_id = tostring(player)
        local data = self:init_player(player_id)
        local now = globals.realtime()
        local tick = globals.tickcount()
        
        yaw = func.aa_clamp(yaw or 0)
        body_yaw = func.aa_clamp(body_yaw or 0)
        
        
        table.insert(data.yaw_samples, {value = yaw, time = now, tick = tick})
        table.insert(data.body_samples, {value = body_yaw, time = now, tick = tick})
        
        
        while #data.yaw_samples > data.max_samples do
            table.remove(data.yaw_samples, 1)
        end
        while #data.body_samples > data.max_samples do
            table.remove(data.body_samples, 1)
        end
        
        
        if #data.yaw_samples >= 4 then
            self:analyze(player_id)
        end
        
        data.last_update = now
        return data
    end,
    
    
    analyze = function(self, player_id)
        local data = self.players[player_id]
        if not data or #data.yaw_samples < 4 then return end
        
        local samples = data.yaw_samples
        local n = #samples
        
        
        local deltas = {}
        local abs_deltas = {}
        local signs = {}
        
        for i = 2, n do
            local delta = func.aa_clamp(samples[i].value - samples[i-1].value)
            table.insert(deltas, delta)
            table.insert(abs_deltas, math.abs(delta))
            table.insert(signs, delta > 0 and 1 or (delta < 0 and -1 or 0))
        end
        
        
        local avg_delta = 0
        local max_delta = 0
        local sign_changes = 0
        
        for i, d in ipairs(abs_deltas) do
            avg_delta = avg_delta + d
            max_delta = math.max(max_delta, d)
            if i > 1 and signs[i] ~= signs[i-1] and signs[i] ~= 0 and signs[i-1] ~= 0 then
                sign_changes = sign_changes + 1
            end
        end
        avg_delta = avg_delta / #abs_deltas
        
        
        local min_yaw, max_yaw = 180, -180
        for _, s in ipairs(samples) do
            min_yaw = math.min(min_yaw, s.value)
            max_yaw = math.max(max_yaw, s.value)
        end
        data.jitter_amplitude = max_yaw - min_yaw
        
        
        local sum = 0
        for _, s in ipairs(samples) do
            sum = sum + s.value
        end
        data.jitter_center = sum / n
        
        
        data.jitter_frequency = sign_changes / (#signs - 1)
        
        
        if avg_delta < 3 then
            data.is_jittering = false
            data.jitter_type = "none"
        elseif data.jitter_amplitude < 15 and data.jitter_frequency > 0.4 then
            data.is_jittering = true
            data.jitter_type = "micro"  
        elseif data.jitter_amplitude >= 30 and data.jitter_frequency > 0.3 then
            data.is_jittering = true
            data.jitter_type = "wide"  
        elseif data.jitter_frequency > 0.5 then
            data.is_jittering = true
            data.jitter_type = "random"  
        else
            data.is_jittering = avg_delta > 8
            data.jitter_type = data.is_jittering and "pattern" or "none"
        end
        
        
        self:detect_pattern(player_id, deltas)
    end,
    
    
    detect_pattern = function(self, player_id, deltas)
        local data = self.players[player_id]
        if #deltas < 6 then return end
        
        
        local best_pattern_len = 0
        local best_confidence = 0
        
        for pattern_len = 2, math.min(6, #deltas / 2) do
            local matches = 0
            local comparisons = 0
            
            for i = 1, #deltas - pattern_len do
                local j = ((i - 1) % pattern_len) + 1
                local expected = deltas[j]
                local actual = deltas[i]
                
                
                local sign_expected = expected > 0 and 1 or (expected < 0 and -1 or 0)
                local sign_actual = actual > 0 and 1 or (actual < 0 and -1 or 0)
                
                if sign_expected == sign_actual then
                    matches = matches + 1
                end
                comparisons = comparisons + 1
            end
            
            local confidence = comparisons > 0 and (matches / comparisons) or 0
            if confidence > best_confidence and confidence > 0.5 then
                best_confidence = confidence
                best_pattern_len = pattern_len
            end
        end
        
        data.pattern_length = best_pattern_len
        data.pattern_confidence = best_confidence
        
        
        if best_pattern_len > 0 and best_confidence > 0.6 then
            data.pattern_sequence = {}
            for i = 1, best_pattern_len do
                table.insert(data.pattern_sequence, deltas[i] > 0 and 1 or -1)
            end
        else
            data.pattern_sequence = {}
        end
    end,
    
    
    get = function(self, player)
        local player_id = tostring(player)
        return self.players[player_id]
    end,
    
    
    predict_next = function(self, player)
        local player_id = tostring(player)
        local data = self.players[player_id]
        if not data or #data.pattern_sequence == 0 then
            return nil
        end
        
        
        local current_index = #data.yaw_samples % data.pattern_length
        local next_index = (current_index % data.pattern_length) + 1
        
        return {
            direction = data.pattern_sequence[next_index] or 0,
            confidence = data.pattern_confidence,
            center = data.jitter_center,
            amplitude = data.jitter_amplitude,
        }
    end,
    
    
    clear = function(self, player)
        local player_id = tostring(player)
        self.players[player_id] = nil
    end,
}




resolver_base.desync = {
    players = {},
    
    init_player = function(self, player_id)
        if not self.players[player_id] then
            self.players[player_id] = {
                samples = {},
                max_samples = resolver_base.config.desync_sample_limit,
                
                
                current_desync = 0,
                desync_side = 0,  
                
                
                avg_desync = 0,
                max_desync = 0,
                desync_variance = 0,
                
                
                desync_mode = "unknown",  
                mode_confidence = 0,
                
                
                flip_count = 0,
                last_flip_time = 0,
                avg_flip_interval = 0,
                
                
                estimation_confidence = 0,
                last_update = 0,
            }
        end
        return self.players[player_id]
    end,
    
    
    estimate = function(self, player)
        if not player or not entity.is_alive(player) then
            return nil
        end
        
        local player_id = tostring(player)
        local data = self:init_player(player_id)
        local now = globals.realtime()
        local tick = globals.tickcount()
        
        
        local animstate = resolver_base.safe_animstate:get(player)
        local animstate_desync = 0
        local animstate_side = 0
        
        if animstate then
            animstate_desync = math.abs(animstate.body_yaw)
            animstate_side = animstate.body_yaw > 0 and 1 or -1
        end
        
        
        local pose_params = resolver_base.pose_params:get(player)
        local pose_desync = 0
        local pose_side = 0
        
        if pose_params then
            
            local body_angle = resolver_base.pose_params:pose_to_angle(pose_params.body_yaw, -60, 60)
            pose_desync = math.abs(body_angle)
            pose_side = body_angle > 0 and 1 or -1
        end
        
        
        local adjust_layer = resolver_base.safe_layers:get(player, resolver_base.layer_indices.ADJUST)
        local layer_desync = 0
        
        if adjust_layer then
            
            layer_desync = adjust_layer.weight * 60
        end
        
        
        local weights = {0.5, 0.35, 0.15}  
        local combined_desync = (animstate_desync * weights[1] + pose_desync * weights[2] + layer_desync * weights[3])
        
        
        local combined_side = animstate_side
        if combined_side == 0 then
            combined_side = pose_side
        end
        
        
        local confidence = 0
        if animstate_side == pose_side and animstate_side ~= 0 then
            confidence = 0.8
        elseif animstate_side ~= 0 then
            confidence = 0.6
        elseif pose_side ~= 0 then
            confidence = 0.4
        else
            confidence = 0.2
        end
        
        
        local sample = {
            desync = combined_desync,
            side = combined_side,
            confidence = confidence,
            time = now,
            tick = tick,
            methods = {
                animstate = {desync = animstate_desync, side = animstate_side},
                pose = {desync = pose_desync, side = pose_side},
                layer = {desync = layer_desync},
            },
        }
        
        table.insert(data.samples, sample)
        while #data.samples > data.max_samples do
            table.remove(data.samples, 1)
        end
        
        
        data.current_desync = combined_desync
        data.desync_side = combined_side
        data.estimation_confidence = confidence
        
        
        if #data.samples >= 2 then
            local prev = data.samples[#data.samples - 1]
            if prev.side ~= combined_side and prev.side ~= 0 and combined_side ~= 0 then
                data.flip_count = data.flip_count + 1
                if data.last_flip_time > 0 then
                    local interval = now - data.last_flip_time
                    data.avg_flip_interval = data.avg_flip_interval * 0.8 + interval * 0.2
                end
                data.last_flip_time = now
            end
        end
        
        
        self:update_stats(player_id)
        
        
        self:detect_mode(player_id)
        
        data.last_update = now
        return sample
    end,
    
    
    update_stats = function(self, player_id)
        local data = self.players[player_id]
        if not data or #data.samples < 2 then return end
        
        local sum = 0
        local max_d = 0
        
        for _, s in ipairs(data.samples) do
            sum = sum + s.desync
            max_d = math.max(max_d, s.desync)
        end
        
        data.avg_desync = sum / #data.samples
        data.max_desync = max_d
        
        
        local sum_sq = 0
        for _, s in ipairs(data.samples) do
            sum_sq = sum_sq + (s.desync - data.avg_desync)^2
        end
        data.desync_variance = sum_sq / #data.samples
    end,
    
    
    detect_mode = function(self, player_id)
        local data = self.players[player_id]
        if not data or #data.samples < 6 then return end
        
        local variance = data.desync_variance
        local flip_rate = data.flip_count / math.max(1, #data.samples)
        
        if variance < 25 and flip_rate < 0.1 then
            
            data.desync_mode = "static"
            data.mode_confidence = 0.8
        elseif flip_rate > 0.3 then
            
            data.desync_mode = "dynamic"
            data.mode_confidence = math.min(0.9, flip_rate + 0.5)
        elseif variance > 100 then
            
            data.desync_mode = "fake"
            data.mode_confidence = 0.7
        else
            data.desync_mode = "unknown"
            data.mode_confidence = 0.4
        end
    end,
    
    
    get = function(self, player)
        local player_id = tostring(player)
        return self.players[player_id]
    end,
    
    
    get_current = function(self, player)
        local data = self:get(player)
        if not data then return 0, 0, 0 end
        return data.current_desync, data.desync_side, data.estimation_confidence
    end,
    
    
    clear = function(self, player)
        local player_id = tostring(player)
        self.players[player_id] = nil
    end,
}




resolver_base.update = function(self, player)
    if not player or not entity.is_alive(player) then
        return nil
    end
    
    
    self.velocity:sample(player)
    
    
    local animstate = self.safe_animstate:get(player)
    if animstate then
        
        self.jitter_detection:sample(player, animstate.eye_angles_y, animstate.body_yaw)
        
        
        self.desync:estimate(player)
    end
    
    
    local features = self.features:extract(player)
    
    return {
        animstate = animstate,
        pose_params = self.pose_params:get(player),
        layers = self.safe_layers:get_all(player),
        velocity = self.velocity:get(player),
        jitter = self.jitter_detection:get(player),
        desync = self.desync:get(player),
        features = features,
    }
end


resolver_base.clear_player = function(self, player)
    self.safe_layers:clear_cache(player)
    self.safe_animstate:clear_cache(player)
    self.pose_params:clear_cache(player)
    self.velocity:clear(player)
    self.jitter_detection:clear(player)
    self.desync:clear(player)
end


resolver_base.clear_all = function(self)
    self.safe_layers.cache = {}
    self.safe_layers.cache_time = {}
    self.safe_animstate.cache = {}
    self.safe_animstate.cache_time = {}
    self.pose_params.cache = {}
    self.pose_params.cache_time = {}
    self.velocity.players = {}
    self.jitter_detection.players = {}
    self.desync.players = {}
end






client.set_event_callback("net_update_end", function()
    local me = entity.get_local_player()
    if not me or not entity.is_alive(me) then return end
    
    local enemies = entity.get_players(true)
    for _, enemy in ipairs(enemies) do
        if entity.is_alive(enemy) and not entity.is_dormant(enemy) then
            resolver_base:update(enemy)
        end
    end
end)


client.set_event_callback("round_prestart", function()
    resolver_base:clear_all()
end)


client.set_event_callback("player_death", function(e)
    local victim = client.userid_to_entindex(e.userid)
    if victim then
        resolver_base:clear_player(victim)
    end
end)

local resolver_advanced = {
    
    config = {
        
        pattern_history_size = 64,
        pattern_min_samples = 8,
        pattern_confidence_threshold = 0.55,
        
        
        movement_sample_size = 48,
        strafe_detection_threshold = 35,
        
        
        layer_weight_threshold = 0.15,
        layer_sample_size = 32,
        
        
        cache_duration = 0.025,  
        max_cache_entries = 32,
        
        
        strategy_evaluation_interval = 0.1,
        min_samples_for_strategy = 6,
        
        
        high_confidence = 0.75,
        medium_confidence = 0.50,
        low_confidence = 0.30,
    },
    
    
    players = {},
    
    
    prediction_cache = {},
    cache_timestamps = {},
    
    
    strategies = {
        "pattern_match",      
        "jitter_predict",     
        "movement_based",     
        "layer_analysis",     
        "desync_track",       
        "bruteforce",         
        "learned",            
        "hybrid",             
    },
    fakelag_detection = {
        players = {},
        
        analyze = function(self, player)
            local player_id = tostring(player)
            if not self.players[player_id] then
                self.players[player_id] = {
                    choke_samples = {},
                    simtime_samples = {},
                    exploit_score = 0,
                }
            end
            
            local data = self.players[player_id]
            local now = globals.realtime()
            local tick = globals.tickcount()
            
            -- Get simulation time delta
            local simtime = entity.get_prop(player, "m_flSimulationTime") or 0
            local old_simtime = entity.get_prop(player, "m_flOldSimulationTime") or 0
            local delta_ticks = math.floor((simtime - old_simtime) / globals.tickinterval() + 0.5)
            
            table.insert(data.simtime_samples, {
                delta = delta_ticks,
                time = now,
                tick = tick,
            })
            
            while #data.simtime_samples > 32 do
                table.remove(data.simtime_samples, 1)
            end
            
            -- Detect exploit patterns
            local high_choke_count = 0
            local irregular_deltas = 0
            
            for i, s in ipairs(data.simtime_samples) do
                if s.delta > 14 then
                    high_choke_count = high_choke_count + 1
                end
                if i > 1 then
                    local prev = data.simtime_samples[i-1]
                    if math.abs(s.delta - prev.delta) > 10 then
                        irregular_deltas = irregular_deltas + 1
                    end
                end
            end
            
            -- Calculate exploit score
            data.exploit_score = (high_choke_count / #data.simtime_samples) * 0.6 +
                                (irregular_deltas / #data.simtime_samples) * 0.4
            
            return {
                is_exploiting = data.exploit_score > 0.4,
                exploit_score = data.exploit_score,
                avg_choke = delta_ticks,
                should_force_baim = data.exploit_score > 0.6,
            }
        end,
    },

    lby_detection = {
        players = {},
        
        init_player = function(self, player_id)
            if not self.players[player_id] then
                self.players[player_id] = {
                    lby_samples = {},
                    last_lby_time = 0,
                    lby_flick_detected = false,
                    predicted_lby_side = 0,
                    time_to_lby = 0,
                }
            end
            return self.players[player_id]
        end,
        
        update = function(self, player)
            local player_id = tostring(player)
            local data = self:init_player(player_id)
            local now = globals.realtime()
            
            local animstate = resolver_base.safe_animstate:get(player)
            if not animstate then return nil end
            
            local lby_time = animstate.last_lby_time or 0
            local goal_feet = animstate.goal_feet_yaw or 0
            local current_feet = animstate.current_feet_yaw or 0
            
            -- Detect LBY update
            if lby_time ~= data.last_lby_time then
                data.lby_flick_detected = true
                data.last_lby_time = lby_time
                
                -- Record LBY value at update
                table.insert(data.lby_samples, {
                    value = goal_feet,
                    time = now,
                })
                
                while #data.lby_samples > 16 do
                    table.remove(data.lby_samples, 1)
                end
            else
                data.lby_flick_detected = false
            end
            
            -- Calculate time to next LBY update (1.1s cycle when standing still)
            local velocity = animstate.velocity_2d or 0
            if velocity < 10 then
                data.time_to_lby = 1.1 - (now - lby_time)
                
                -- Predict side when LBY is about to update
                if data.time_to_lby < 0.2 and data.time_to_lby > 0 then
                    -- LBY will snap to real angle soon
                    data.predicted_lby_side = goal_feet > current_feet and 1 or 0
                end
            else
                data.time_to_lby = -1 -- Moving, no LBY flick
            end
            
            return data
        end,
        
        get_prediction = function(self, player)
            local player_id = tostring(player)
            local data = self.players[player_id]
            if not data then return nil end
            
            -- If LBY flick is imminent, use predicted side
            if data.time_to_lby > 0 and data.time_to_lby < 0.3 then
                return {
                    side = data.predicted_lby_side,
                    confidence = 0.75 + (0.3 - data.time_to_lby) * 0.5, -- Higher confidence as flick approaches
                    reason = "lby_predict",
                    time_to_flick = data.time_to_lby,
                }
            end
            
            return nil
        end,
    },
}




resolver_advanced.init_player = function(self, player)
    local player_id = tostring(player)
    
    if not self.players[player_id] then
        self.players[player_id] = {
            
            player_id = player_id,
            entity = player,
            
            
            patterns = {
                yaw_history = {},
                body_history = {},
                side_history = {},
                detected_pattern = nil,
                pattern_type = "unknown",
                pattern_confidence = 0,
                pattern_length = 0,
                pattern_phase = 0,
                last_pattern_update = 0,
            },
            
            
            movement = {
                samples = {},
                current_state = "unknown",
                state_duration = 0,
                state_start_time = 0,
                strafe_direction = 0,
                strafe_count = 0,
                is_peeking = false,
                peek_direction = 0,
                movement_pattern = "unknown",
                last_update = 0,
            },
            
            
            layers = {
                history = {},
                adjust_pattern = {},
                strafe_pattern = {},
                lean_pattern = {},
                detected_behavior = "unknown",
                behavior_confidence = 0,
                last_update = 0,
            },
            
            
            state = {
                current_strategy = "hybrid",
                strategy_confidence = 0.5,
                strategy_successes = {},
                strategy_failures = {},
                last_strategy_change = 0,
                
                
                predicted_side = 0,
                predicted_body = 0,
                predicted_yaw = 0,
                prediction_confidence = 0,
                
                
                mode = "learning",  
                mode_reason = "",
                
                
                shots_fired = 0,
                shots_hit = 0,
                consecutive_misses = 0,
                consecutive_hits = 0,
                last_shot_time = 0,
                last_hit_time = 0,
            },
            
            
            learning = {
                hit_sides = {[0] = 0, [1] = 0},
                miss_sides = {[0] = 0, [1] = 0},
                hit_body_yaws = {},
                miss_body_yaws = {},
                effective_offsets = {},
                ineffective_offsets = {},
                learned_delay = 0,
                learned_pattern = nil,
            },
            
            
            confidence = {
                pattern = 0.5,
                movement = 0.5,
                layers = 0.5,
                desync = 0.5,
                learning = 0.5,
                overall = 0.5,
            },
            
            
            bruteforce = {
                stage = 0,
                offsets = {0, 58, -58, 30, -30, 45, -45, 15, -15, 50, -50, 40, -40},
                last_offset = 0,
                tested_offsets = {},
                best_offset = 0,
                best_offset_hits = 0,
            },
            
            
            last_update = 0,
            first_seen = 0,
            time_tracked = 0,
        }
        
        self.players[player_id].first_seen = globals.realtime()
    end
    
    return self.players[player_id]
end


resolver_advanced.get_player = function(self, player)
    local player_id = tostring(player)
    return self.players[player_id]
end




resolver_advanced.pattern_recognition = {
    
    sample = function(self, player, yaw, body_yaw, side)
        local data = resolver_advanced:init_player(player)
        local patterns = data.patterns
        local now = globals.realtime()
        local tick = globals.tickcount()
        
        
        yaw = func.aa_clamp(yaw or 0)
        body_yaw = func.aa_clamp(body_yaw or 0)
        side = side or 0
        
        
        table.insert(patterns.yaw_history, {
            value = yaw,
            time = now,
            tick = tick,
        })
        
        table.insert(patterns.body_history, {
            value = body_yaw,
            time = now,
            tick = tick,
        })
        
        table.insert(patterns.side_history, {
            value = side,
            time = now,
            tick = tick,
        })
        
        
        local max_size = resolver_advanced.config.pattern_history_size
        while #patterns.yaw_history > max_size do
            table.remove(patterns.yaw_history, 1)
        end
        while #patterns.body_history > max_size do
            table.remove(patterns.body_history, 1)
        end
        while #patterns.side_history > max_size do
            table.remove(patterns.side_history, 1)
        end
        
        
        if #patterns.yaw_history >= resolver_advanced.config.pattern_min_samples then
            self:analyze(player)
        end
        
        patterns.last_pattern_update = now
    end,
    
    
    analyze = function(self, player)
        local data = resolver_advanced:get_player(player)
        if not data then return end
        
        local patterns = data.patterns
        local yaw_hist = patterns.yaw_history
        local body_hist = patterns.body_history
        local side_hist = patterns.side_history
        
        if #yaw_hist < 8 then return end
        
        
        local yaw_deltas = {}
        for i = 2, #yaw_hist do
            local delta = func.aa_clamp(yaw_hist[i].value - yaw_hist[i-1].value)
            table.insert(yaw_deltas, delta)
        end
        
        
        local side_switches = {}
        local switch_count = 0
        for i = 2, #side_hist do
            if side_hist[i].value ~= side_hist[i-1].value then
                switch_count = switch_count + 1
                table.insert(side_switches, {
                    tick = side_hist[i].tick,
                    from = side_hist[i-1].value,
                    to = side_hist[i].value,
                })
            end
        end
        
        
        local pattern_type, pattern_confidence = self:detect_pattern_type(yaw_deltas, side_switches, #side_hist)
        
        
        local sequence, seq_confidence = self:detect_sequence(side_hist)
        
        
        if seq_confidence > pattern_confidence then
            patterns.pattern_type = "sequence"
            patterns.pattern_confidence = seq_confidence
            patterns.detected_pattern = sequence
            patterns.pattern_length = #sequence
        else
            patterns.pattern_type = pattern_type
            patterns.pattern_confidence = pattern_confidence
            patterns.detected_pattern = nil
        end
        
        
        data.confidence.pattern = patterns.pattern_confidence
    end,
    
    
    detect_pattern_type = function(self, yaw_deltas, side_switches, total_samples)
        if #yaw_deltas < 4 then
            return "unknown", 0.3
        end
        
        
        local sum = 0
        local max_delta = 0
        local sign_changes = 0
        local prev_sign = 0
        
        for i, delta in ipairs(yaw_deltas) do
            sum = sum + math.abs(delta)
            max_delta = math.max(max_delta, math.abs(delta))
            
            local sign = delta > 0 and 1 or (delta < 0 and -1 or 0)
            if i > 1 and sign ~= prev_sign and sign ~= 0 and prev_sign ~= 0 then
                sign_changes = sign_changes + 1
            end
            prev_sign = sign
        end
        
        local avg_delta = sum / #yaw_deltas
        local switch_rate = #side_switches / math.max(1, total_samples - 1)
        local jitter_rate = sign_changes / math.max(1, #yaw_deltas - 1)
        
        
        if avg_delta < 3 and switch_rate < 0.1 then
            return "static", 0.85
        elseif switch_rate > 0.4 and jitter_rate > 0.5 then
            return "fast_switch", 0.75
        elseif max_delta > 50 and jitter_rate > 0.3 then
            return "wide_jitter", 0.70
        elseif avg_delta > 10 and avg_delta < 30 and jitter_rate > 0.4 then
            return "micro_jitter", 0.70
        elseif switch_rate > 0.2 and switch_rate < 0.4 then
            return "timed_switch", 0.65
        elseif jitter_rate > 0.6 then
            return "random_jitter", 0.55
        else
            return "mixed", 0.50
        end
    end,
    
    
    detect_sequence = function(self, side_hist)
        if #side_hist < 8 then
            return {}, 0
        end
        
        
        local sides = {}
        for _, s in ipairs(side_hist) do
            table.insert(sides, s.value)
        end
        
        
        local best_sequence = {}
        local best_confidence = 0
        
        for seq_len = 2, math.min(6, math.floor(#sides / 3)) do
            local matches = 0
            local total = 0
            
            
            local candidate = {}
            for i = 1, seq_len do
                candidate[i] = sides[i]
            end
            
            
            for i = seq_len + 1, #sides do
                local expected_idx = ((i - 1) % seq_len) + 1
                if sides[i] == candidate[expected_idx] then
                    matches = matches + 1
                end
                total = total + 1
            end
            
            if total > 0 then
                local confidence = matches / total
                if confidence > best_confidence then
                    best_confidence = confidence
                    best_sequence = candidate
                end
            end
        end
        
        return best_sequence, best_confidence
    end,
    
    
    predict = function(self, player)
        local data = resolver_advanced:get_player(player)
        if not data then return nil end
        
        local patterns = data.patterns
        
        if patterns.pattern_type == "sequence" and patterns.detected_pattern and #patterns.detected_pattern > 0 then
            
            local current_idx = #patterns.side_history
            local phase = (current_idx % #patterns.detected_pattern) + 1
            local next_phase = (phase % #patterns.detected_pattern) + 1
            
            return {
                predicted_side = patterns.detected_pattern[next_phase],
                confidence = patterns.pattern_confidence,
                pattern_type = "sequence",
                pattern_length = #patterns.detected_pattern,
                current_phase = phase,
            }
        elseif patterns.pattern_type == "static" then
            
            local last_side = patterns.side_history[#patterns.side_history]
            return {
                predicted_side = last_side and last_side.value or 0,
                confidence = patterns.pattern_confidence,
                pattern_type = "static",
            }
        elseif patterns.pattern_type == "fast_switch" then
            
            local last_side = patterns.side_history[#patterns.side_history]
            return {
                predicted_side = last_side and (1 - last_side.value) or 0,
                confidence = patterns.pattern_confidence * 0.8,
                pattern_type = "fast_switch",
            }
        end
        
        return nil
    end,
}




resolver_advanced.movement_analysis = {
    
    states = {
        "standing",
        "walking",
        "running",
        "crouching",
        "crouch_moving",
        "air",
        "air_crouch",
        "peeking_left",
        "peeking_right",
        "strafing",
        "stopping",
    },
    
    
    sample = function(self, player)
        local data = resolver_advanced:init_player(player)
        local movement = data.movement
        local now = globals.realtime()
        local tick = globals.tickcount()
        
        
        local vel_data = resolver_base.velocity:get(player)
        local animstate = resolver_base.safe_animstate:get(player)
        
        if not vel_data or not animstate then return end
        
        
        local sample = {
            time = now,
            tick = tick,
            speed = vel_data.avg_speed or 0,
            direction = vel_data.avg_direction or 0,
            is_strafing = vel_data.is_strafing or false,
            strafe_dir = vel_data.strafe_direction or 0,
            on_ground = animstate.on_ground,
            duck_amount = animstate.duck_amount or 0,
            velocity_x = animstate.velocity_x or 0,
            velocity_y = animstate.velocity_y or 0,
        }
        
        
        table.insert(movement.samples, sample)
        while #movement.samples > resolver_advanced.config.movement_sample_size do
            table.remove(movement.samples, 1)
        end
        
        
        self:analyze(player)
        
        movement.last_update = now
    end,
    
    
    analyze = function(self, player)
        local data = resolver_advanced:get_player(player)
        if not data then return end
        
        local movement = data.movement
        local samples = movement.samples
        
        if #samples < 4 then return end
        
        local now = globals.realtime()
        local recent = {}
        
        
        for i = #samples, 1, -1 do
            if now - samples[i].time < 0.3 then
                table.insert(recent, 1, samples[i])
            else
                break
            end
        end
        
        if #recent < 2 then return end
        
        
        local new_state = self:determine_state(recent)
        
        
        if new_state ~= movement.current_state then
            movement.state_duration = 0
            movement.state_start_time = now
            movement.current_state = new_state
        else
            movement.state_duration = now - movement.state_start_time
        end
        
        
        self:detect_peek(player, recent)
        
        
        self:detect_strafe_pattern(player, samples)
        
        
        data.confidence.movement = self:calculate_confidence(movement)
    end,
    
    
    determine_state = function(self, samples)
        if #samples == 0 then return "unknown" end
        
        local latest = samples[#samples]
        local avg_speed = 0
        local duck_sum = 0
        local ground_count = 0
        
        for _, s in ipairs(samples) do
            avg_speed = avg_speed + s.speed
            duck_sum = duck_sum + s.duck_amount
            if s.on_ground then ground_count = ground_count + 1 end
        end
        
        avg_speed = avg_speed / #samples
        local avg_duck = duck_sum / #samples
        local on_ground = ground_count > #samples / 2
        
        if not on_ground then
            return avg_duck > 0.5 and "air_crouch" or "air"
        end
        
        if avg_duck > 0.5 then
            return avg_speed > 10 and "crouch_moving" or "crouching"
        end
        
        if latest.is_strafing then
            return "strafing"
        end
        
        if avg_speed < 5 then
            return "standing"
        elseif avg_speed < 85 then
            return "walking"
        else
            return "running"
        end
    end,
    
    
    detect_peek = function(self, player, samples)
        local data = resolver_advanced:get_player(player)
        local movement = data.movement
        
        if #samples < 4 then return end
        
        
        local velocities = {}
        for _, s in ipairs(samples) do
            table.insert(velocities, s.speed)
        end
        
        
        local peak_idx = 1
        local peak_vel = velocities[1]
        for i, v in ipairs(velocities) do
            if v > peak_vel then
                peak_vel = v
                peak_idx = i
            end
        end
        
        
        if peak_idx > 1 and peak_idx < #velocities then
            local accel = velocities[peak_idx] - velocities[1]
            local decel = velocities[peak_idx] - velocities[#velocities]
            
            if accel > 30 and decel > 30 and peak_vel > 100 then
                movement.is_peeking = true
                
                
                local peak_sample = samples[peak_idx]
                movement.peek_direction = peak_sample.velocity_x > 0 and 1 or -1
            else
                movement.is_peeking = false
            end
        else
            movement.is_peeking = false
        end
    end,
    
    
    detect_strafe_pattern = function(self, player, samples)
        local data = resolver_advanced:get_player(player)
        local movement = data.movement
        
        if #samples < 8 then return end
        
        
        local dir_changes = 0
        local prev_dir = nil
        
        for _, s in ipairs(samples) do
            if s.is_strafing then
                if prev_dir ~= nil and s.strafe_dir ~= prev_dir then
                    dir_changes = dir_changes + 1
                end
                prev_dir = s.strafe_dir
            end
        end
        
        movement.strafe_count = dir_changes
        
        
        if dir_changes >= 4 then
            movement.movement_pattern = "rapid_strafe"
        elseif dir_changes >= 2 then
            movement.movement_pattern = "alternating_strafe"
        elseif movement.is_peeking then
            movement.movement_pattern = "peek"
        else
            movement.movement_pattern = "linear"
        end
    end,
    
    
    calculate_confidence = function(self, movement)
        local confidence = 0.5
        
        
        if movement.state_duration > 1.0 then
            confidence = confidence + 0.2
        elseif movement.state_duration > 0.5 then
            confidence = confidence + 0.1
        end
        
        
        if movement.movement_pattern == "peek" then
            confidence = confidence + 0.15
        elseif movement.movement_pattern == "rapid_strafe" then
            confidence = confidence + 0.1
        end
        
        
        if movement.current_state == "standing" or movement.current_state == "crouching" then
            confidence = confidence + 0.1
        end
        
        return math.min(0.95, confidence)
    end,
    
    
    predict_side = function(self, player)
        local data = resolver_advanced:get_player(player)
        if not data then return nil end
        
        local movement = data.movement
        
        if movement.is_peeking then
            
            return {
                side = movement.peek_direction > 0 and 0 or 1,
                confidence = 0.65,
                reason = "peek_prediction",
            }
        end
        
        if movement.movement_pattern == "rapid_strafe" then
            
            return {
                side = movement.strafe_direction > 0 and 1 or 0,
                confidence = 0.55,
                reason = "strafe_sync",
            }
        end
        
        return nil
    end,
}


resolver_advanced.learning = {

shot_correlation = {
    players = {},
    
    record = function(self, player, hit, context)
        local player_id = tostring(player)
        if not self.players[player_id] then
            self.players[player_id] = {
                hit_contexts = {},
                miss_contexts = {},
            }
        end
        
        local data = self.players[player_id]
        local record = {
            side_used = context.side,
            body_used = context.body,
            velocity = context.velocity or 0,
            duck_amount = context.duck_amount or 0,
            on_ground = context.on_ground or true,
            pattern_type = context.pattern_type or "unknown",
            jitter_detected = context.jitter_detected or false,
            backtrack_amount = context.backtrack or 0,
            time = globals.realtime(),
        }
        
        if hit then
            table.insert(data.hit_contexts, record)
            while #data.hit_contexts > 50 do
                table.remove(data.hit_contexts, 1)
            end
        else
            table.insert(data.miss_contexts, record)
            while #data.miss_contexts > 30 do
                table.remove(data.miss_contexts, 1)
            end
        end
    end,
    
    get_best_approach = function(self, player, current_context)
        local player_id = tostring(player)
        local data = self.players[player_id]
        if not data or #data.hit_contexts < 3 then return nil end
        
        -- Find similar contexts in hit history
        local best_match = nil
        local best_similarity = 0
        
        for _, hit_ctx in ipairs(data.hit_contexts) do
            local similarity = 0
            
            -- Compare contexts
            if math.abs(hit_ctx.velocity - (current_context.velocity or 0)) < 50 then
                similarity = similarity + 0.2
            end
            if hit_ctx.on_ground == (current_context.on_ground or true) then
                similarity = similarity + 0.15
            end
            if math.abs(hit_ctx.duck_amount - (current_context.duck_amount or 0)) < 0.3 then
                similarity = similarity + 0.15
            end
            if hit_ctx.pattern_type == (current_context.pattern_type or "unknown") then
                similarity = similarity + 0.3
            end
            if hit_ctx.jitter_detected == (current_context.jitter_detected or false) then
                similarity = similarity + 0.2
            end
            
            if similarity > best_similarity then
                best_similarity = similarity
                best_match = hit_ctx
            end
        end
        
        if best_match and best_similarity > 0.5 then
            return {
                side = best_match.side_used,
                body = best_match.body_used,
                confidence = best_similarity * 0.8,
                reason = "correlation_match",
            }
        end
        
        return nil
    end,
}
    
}

prediction_smoother = {
    players = {},
    window_size = 6,
    
    smooth = function(self, player, new_prediction)
        local player_id = tostring(player)
        if not self.players[player_id] then
            self.players[player_id] = {
                predictions = {},
                stable_side = 0,
                stable_body = 0,
                stability_score = 0,
            }
        end
        
        local data = self.players[player_id]
        
        -- Add new prediction
        table.insert(data.predictions, {
            side = new_prediction.side,
            body = new_prediction.body,
            confidence = new_prediction.confidence,
            time = globals.realtime(),
        })
        
        while #data.predictions > self.window_size do
            table.remove(data.predictions, 1)
        end
        
        -- Vote on side
        local side_votes = {[0] = 0, [1] = 0}
        local body_sum = 0
        local conf_sum = 0
        
        for _, pred in ipairs(data.predictions) do
            side_votes[pred.side] = side_votes[pred.side] + pred.confidence
            body_sum = body_sum + pred.body * pred.confidence
            conf_sum = conf_sum + pred.confidence
        end
        
        local winning_side = side_votes[1] > side_votes[0] and 1 or 0
        local smoothed_body = conf_sum > 0 and (body_sum / conf_sum) or new_prediction.body
        
        -- Calculate stability (how consistent predictions are)
        local consistency = math.abs(side_votes[1] - side_votes[0]) / (side_votes[1] + side_votes[0] + 0.01)
        data.stability_score = consistency
        
        -- Only change if new prediction is significantly more confident or predictions are stable
        if #data.predictions >= 3 then
            if consistency > 0.6 then
                data.stable_side = winning_side
                data.stable_body = smoothed_body
            elseif new_prediction.confidence > 0.8 then
                data.stable_side = new_prediction.side
                data.stable_body = new_prediction.body
            end
        else
            data.stable_side = new_prediction.side
            data.stable_body = new_prediction.body
        end
        
        return {
            side = data.stable_side,
            body = data.stable_body,
            confidence = new_prediction.confidence * (0.5 + consistency * 0.5),
            stability = data.stability_score,
        }
    end,
}

resolver_advanced.layer_analysis = {
    
    key_layers = {
        ADJUST = 3,
        MOVEMENT_MOVE = 6,
        MOVEMENT_STRAFECHANGE = 7,
        LEAN = 12,
    },
    
    
    sample = function(self, player)
        local data = resolver_advanced:init_player(player)
        local layers_data = data.layers
        local now = globals.realtime()
        local tick = globals.tickcount()
        
        
        local all_layers = resolver_base.safe_layers:get_all(player)
        if not all_layers then return end
        
        
        local sample = {
            time = now,
            tick = tick,
            adjust = all_layers[self.key_layers.ADJUST],
            move = all_layers[self.key_layers.MOVEMENT_MOVE],
            strafe = all_layers[self.key_layers.MOVEMENT_STRAFECHANGE],
            lean = all_layers[self.key_layers.LEAN],
        }
        
        
        table.insert(layers_data.history, sample)
        while #layers_data.history > resolver_advanced.config.layer_sample_size do
            table.remove(layers_data.history, 1)
        end
        
        
        if sample.adjust then
            table.insert(layers_data.adjust_pattern, {
                weight = sample.adjust.weight,
                cycle = sample.adjust.cycle,
                time = now,
            })
            while #layers_data.adjust_pattern > 24 do
                table.remove(layers_data.adjust_pattern, 1)
            end
        end
        
        if sample.strafe then
            table.insert(layers_data.strafe_pattern, {
                weight = sample.strafe.weight,
                cycle = sample.strafe.cycle,
                playback = sample.strafe.playback_rate,
                time = now,
            })
            while #layers_data.strafe_pattern > 24 do
                table.remove(layers_data.strafe_pattern, 1)
            end
        end
        
        
        self:analyze(player)
        
        layers_data.last_update = now
    end,
    
    
    analyze = function(self, player)
        local data = resolver_advanced:get_player(player)
        if not data then return end
        
        local layers_data = data.layers
        
        if #layers_data.history < 4 then return end
        
        
        local adjust_behavior = self:analyze_adjust_layer(layers_data.adjust_pattern)
        
        
        local strafe_behavior = self:analyze_strafe_layer(layers_data.strafe_pattern)
        
        
        if adjust_behavior.active and adjust_behavior.fluctuating then
            layers_data.detected_behavior = "dynamic_desync"
            layers_data.behavior_confidence = 0.75
        elseif adjust_behavior.active and not adjust_behavior.fluctuating then
            layers_data.detected_behavior = "static_desync"
            layers_data.behavior_confidence = 0.80
        elseif strafe_behavior.synced then
            layers_data.detected_behavior = "movement_synced"
            layers_data.behavior_confidence = 0.70
        else
            layers_data.detected_behavior = "unknown"
            layers_data.behavior_confidence = 0.40
        end
        
        
        data.confidence.layers = layers_data.behavior_confidence
    end,
    
    
    analyze_adjust_layer = function(self, pattern)
        if #pattern < 4 then
            return {active = false, fluctuating = false}
        end
        
        local active_count = 0
        local weight_changes = 0
        local prev_weight = nil
        
        for _, p in ipairs(pattern) do
            if p.weight > resolver_advanced.config.layer_weight_threshold then
                active_count = active_count + 1
            end
            
            if prev_weight then
                if math.abs(p.weight - prev_weight) > 0.1 then
                    weight_changes = weight_changes + 1
                end
            end
            prev_weight = p.weight
        end
        
        return {
            active = active_count > #pattern * 0.3,
            fluctuating = weight_changes > #pattern * 0.3,
            activity_rate = active_count / #pattern,
        }
    end,
   
    analyze_adjust_cycle = function(self, player)
        local data = resolver_advanced:get_player(player)
        if not data then return nil end
        
        local layers_data = data.layers
        local adjust_pattern = layers_data.adjust_pattern
        
        if #adjust_pattern < 6 then return nil end
        
        -- Track cycle progression to detect side
        local cycle_increasing = 0
        local cycle_decreasing = 0
        local prev_cycle = nil
        
        for _, p in ipairs(adjust_pattern) do
            if prev_cycle then
                if p.cycle > prev_cycle then
                    cycle_increasing = cycle_increasing + 1
                else
                    cycle_decreasing = cycle_decreasing + 1
                end
            end
            prev_cycle = p.cycle
        end
        
        -- Cycle direction correlates with desync side
        local side = cycle_increasing > cycle_decreasing and 1 or 0
        local confidence = math.abs(cycle_increasing - cycle_decreasing) / #adjust_pattern
        
        return {
            side = side,
            confidence = math.min(0.85, confidence + 0.3),
            method = "adjust_cycle"
        }
    end,    
    
    analyze_strafe_layer = function(self, pattern)
        if #pattern < 4 then
            return {synced = false}
        end
        
        
        local cycle_resets = 0
        local prev_cycle = nil
        
        for _, p in ipairs(pattern) do
            if prev_cycle and p.cycle < prev_cycle - 0.5 then
                cycle_resets = cycle_resets + 1
            end
            prev_cycle = p.cycle
        end
        
        return {
            synced = cycle_resets >= 2,
            reset_count = cycle_resets,
        }
    end,
    
    
    predict = function(self, player)
        local data = resolver_advanced:get_player(player)
        if not data then return nil end
        
        local layers_data = data.layers
        
        
        if #layers_data.history > 0 then
            local latest = layers_data.history[#layers_data.history]
            if latest.lean and latest.lean.weight > 0.1 then
                
                local lean_cycle = latest.lean.cycle
                local predicted_side = lean_cycle > 0.5 and 1 or 0
                
                return {
                    side = predicted_side,
                    confidence = layers_data.behavior_confidence * 0.8,
                    behavior = layers_data.detected_behavior,
                }
            end
        end
        
        return nil
    end,
}


resolver_advanced.confidence_resolver = {
    
    resolve = function(self, player)
        local data = resolver_advanced:init_player(player)
        if not data then return nil end
        
        local predictions = {}
        local total_weight = 0
        
        
        local pattern_pred = resolver_advanced.pattern_recognition:predict(player)
        if pattern_pred then
            local weight = data.confidence.pattern * 1.2  
            predictions.pattern = {
                side = pattern_pred.predicted_side,
                body = pattern_pred.predicted_side == 1 and 58 or -58,
                confidence = pattern_pred.confidence,
                weight = weight,
            }
            total_weight = total_weight + weight
        end
        
        
        local move_pred = resolver_advanced.movement_analysis:predict_side(player)
        if move_pred then
            local weight = data.confidence.movement
            predictions.movement = {
                side = move_pred.side,
                body = move_pred.side == 1 and 58 or -58,
                confidence = move_pred.confidence,
                weight = weight,
            }
            total_weight = total_weight + weight
        end
        
        
        local layer_pred = resolver_advanced.layer_analysis:predict(player)
        if layer_pred then
            local weight = data.confidence.layers
            predictions.layers = {
                side = layer_pred.side,
                body = layer_pred.side == 1 and 58 or -58,
                confidence = layer_pred.confidence,
                weight = weight,
            }
            total_weight = total_weight + weight
        end
        
        
        local desync_data = resolver_base.desync:get(player)
        if desync_data and desync_data.estimation_confidence > 0.3 then
            local weight = data.confidence.desync
            local side = desync_data.desync_side > 0 and 1 or 0
            predictions.desync = {
                side = side,
                body = desync_data.current_desync * desync_data.desync_side,
                confidence = desync_data.estimation_confidence,
                weight = weight,
            }
            total_weight = total_weight + weight
        end
        
        
        local learned_pred = self:get_learned_prediction(data)
        if learned_pred then
            local weight = data.confidence.learning * 1.3  
            predictions.learned = learned_pred
            predictions.learned.weight = weight
            total_weight = total_weight + weight
        end
        
        
        if total_weight == 0 then
            return nil
        end
        
        
        local side_votes = {[0] = 0, [1] = 0}
        local body_sum = 0
        local confidence_sum = 0
        
        for source, pred in pairs(predictions) do
            local normalized_weight = pred.weight / total_weight
            side_votes[pred.side] = (side_votes[pred.side] or 0) + normalized_weight
            body_sum = body_sum + pred.body * normalized_weight
            confidence_sum = confidence_sum + pred.confidence * normalized_weight
        end
        
        
        local final_side = side_votes[1] > side_votes[0] and 1 or 0
        local side_margin = math.abs(side_votes[1] - side_votes[0])
        
        
        local final_body = final_side == 1 and 58 or -58
        if math.abs(body_sum) > 10 then
            final_body = body_sum
        end
        
        
        if final_side == 1 and final_body < 0 then
            final_body = 58
        elseif final_side == 0 and final_body > 0 then
            final_body = -58
        end
        
        final_body = math.max(-60, math.min(60, math.floor(final_body + 0.5)))
        
        
        local overall_confidence = confidence_sum * (0.5 + side_margin * 0.5)
        overall_confidence = math.min(0.95, overall_confidence)
        
        
        data.state.predicted_side = final_side
        data.state.predicted_body = final_body
        data.state.prediction_confidence = overall_confidence
        data.confidence.overall = overall_confidence
        
        return {
            side = final_side,
            body = final_body,
            yaw = 0,  
            confidence = overall_confidence,
            sources = predictions,
            side_margin = side_margin,
        }
    end,
    
    
    get_learned_prediction = function(self, data)
        local learning = data.learning
        
        
        local side0_hits = learning.hit_sides[0] or 0
        local side1_hits = learning.hit_sides[1] or 0
        local side0_misses = learning.miss_sides[0] or 0
        local side1_misses = learning.miss_sides[1] or 0
        
        local total_shots = side0_hits + side1_hits + side0_misses + side1_misses
        
        if total_shots < 2 then
            return nil
        end
        
        
        local side0_total = side0_hits + side0_misses
        local side1_total = side1_hits + side1_misses
        
        local side0_rate = side0_total > 0 and (side0_hits / side0_total) or 0.5
        local side1_rate = side1_total > 0 and (side1_hits / side1_total) or 0.5
        
        
        local better_side = side1_rate > side0_rate and 1 or 0
        local rate_diff = math.abs(side1_rate - side0_rate)
        
        
        local sample_confidence = math.min(1, total_shots / 10)
        local rate_confidence = rate_diff * 2
        
        local confidence = (sample_confidence * 0.4 + rate_confidence * 0.6)
        confidence = math.min(0.85, confidence)
        
        
        local learned_body = better_side == 1 and 58 or -58
        if #learning.hit_body_yaws >= 2 then
            local body_sum = 0
            for _, b in ipairs(learning.hit_body_yaws) do
                body_sum = body_sum + b
            end
            local avg_body = body_sum / #learning.hit_body_yaws
            if (better_side == 1 and avg_body > 0) or (better_side == 0 and avg_body < 0) then
                learned_body = avg_body
            end
        end
        
        return {
            side = better_side,
            body = learned_body,
            confidence = confidence,
        }
    end,
}




resolver_advanced.fallback = {
    
    offsets = {0, 58, -58, 30, -30, 45, -45, 15, -15, 50, -50, 40, -40, 20, -20},
    
    
    resolve = function(self, player)
        local data = resolver_advanced:get_player(player)
        if not data then
            
            return {
                side = 0,
                body = -58,
                yaw = 0,
                confidence = 0.3,
                reason = "no_data",
            }
        end
        
        local bf = data.bruteforce
        local state = data.state
        
        
        if state.consecutive_misses >= 2 then
            
            bf.stage = (bf.stage % #bf.offsets) + 1
            local offset = bf.offsets[bf.stage]
            
            return {
                side = offset > 0 and 1 or 0,
                body = offset,
                yaw = 0,
                confidence = 0.35,
                reason = "bruteforce",
                stage = bf.stage,
            }
        end
        
        
        if bf.best_offset_hits > 0 then
            return {
                side = bf.best_offset > 0 and 1 or 0,
                body = bf.best_offset,
                yaw = 0,
                confidence = 0.50,
                reason = "best_known",
            }
        end
        
        
        return {
            side = 0,
            body = -58,
            yaw = 0,
            confidence = 0.30,
            reason = "default",
        }
    end,
    
smart_bruteforce = {
    -- Offsets ordered by statistical effectiveness
    primary_offsets = {58, -58, 0},
    secondary_offsets = {45, -45, 30, -30},
    micro_offsets = {15, -15, 50, -50, 40, -40},
    
    resolve = function(self, player)
        local data = resolver_advanced:get_player(player)
        if not data then return {side = 0, body = -58, confidence = 0.3} end
        
        local bf = data.bruteforce
        local state = data.state
        local learning = data.learning
        
        -- Analyze miss patterns to determine best approach
        local left_misses = learning.miss_sides[0] or 0
        local right_misses = learning.miss_sides[1] or 0
        local left_hits = learning.hit_sides[0] or 0
        local right_hits = learning.hit_sides[1] or 0
        
        -- Prioritize side with better hit/miss ratio
        local left_ratio = left_hits / math.max(1, left_hits + left_misses)
        local right_ratio = right_hits / math.max(1, right_hits + right_misses)
        
        local preferred_side = right_ratio > left_ratio and 1 or 0
        
        -- On consecutive misses, try opposite of last prediction
        if state.consecutive_misses >= 2 then
            local last_side = state.predicted_side
            local new_side = 1 - last_side
            
            -- Also vary the offset amount
            local offset_idx = (state.consecutive_misses - 1) % #self.secondary_offsets + 1
            local base_offset = self.secondary_offsets[offset_idx]
            
            -- Apply to the opposite side
            local final_offset = new_side == 1 and math.abs(base_offset) or -math.abs(base_offset)
            
            return {
                side = new_side,
                body = final_offset,
                confidence = 0.4 - (state.consecutive_misses * 0.03),
                reason = "smart_brute_flip"
            }
        end
        
        -- Default to preferred side based on learning
        return {
            side = preferred_side,
            body = preferred_side == 1 and 58 or -58,
            confidence = 0.45,
            reason = "preferred_side"
        }
    end,
},    
    
    record_result = function(self, player, hit, offset)
        local data = resolver_advanced:get_player(player)
        if not data then return end
        
        local bf = data.bruteforce
        
        if hit then
            bf.tested_offsets[offset] = (bf.tested_offsets[offset] or 0) + 1
            
            
            if (bf.tested_offsets[offset] or 0) > bf.best_offset_hits then
                bf.best_offset = offset
                bf.best_offset_hits = bf.tested_offsets[offset]
            end
        end
        
        bf.last_offset = offset
    end,
}




resolver_advanced.strategy_engine = {
    
    select_strategy = function(self, player)
        local data = resolver_advanced:init_player(player)
        if not data then return "hybrid" end
        
        local now = globals.realtime()
        local state = data.state
        
        
        if now - state.last_strategy_change < resolver_advanced.config.strategy_evaluation_interval then
            return state.current_strategy
        end
        
        
        local scores = {}
        
        
        local pattern_data = data.patterns
        if pattern_data.pattern_confidence > 0.6 then
            scores.pattern_match = pattern_data.pattern_confidence * self:get_strategy_success_rate(data, "pattern_match")
        else
            scores.pattern_match = 0.2
        end
        
        
        local jitter_data = resolver_base.jitter_detection:get(player)
        if jitter_data and jitter_data.is_jittering and jitter_data.pattern_confidence > 0.5 then
            scores.jitter_predict = jitter_data.pattern_confidence * self:get_strategy_success_rate(data, "jitter_predict")
        else
            scores.jitter_predict = 0.2
        end
        
        
        local movement_data = data.movement
        if movement_data.is_peeking or movement_data.movement_pattern ~= "linear" then
            scores.movement_based = data.confidence.movement * self:get_strategy_success_rate(data, "movement_based")
        else
            scores.movement_based = 0.3
        end
        
        
        local layer_data = data.layers
        if layer_data.detected_behavior ~= "unknown" then
            scores.layer_analysis = layer_data.behavior_confidence * self:get_strategy_success_rate(data, "layer_analysis")
        else
            scores.layer_analysis = 0.25
        end
        
        
        local desync_data = resolver_base.desync:get(player)
        if desync_data and desync_data.desync_mode ~= "unknown" then
            scores.desync_track = desync_data.mode_confidence * self:get_strategy_success_rate(data, "desync_track")
        else
            scores.desync_track = 0.3
        end
        
        
        local learning_data = data.learning
        local total_learned = (learning_data.hit_sides[0] or 0) + (learning_data.hit_sides[1] or 0)
        if total_learned >= 3 then
            scores.learned = 0.7 * self:get_strategy_success_rate(data, "learned")
        else
            scores.learned = 0.2
        end
        
        
        if state.consecutive_misses >= 3 then
            scores.bruteforce = 0.8
        else
            scores.bruteforce = 0.1
        end
        
        
        scores.hybrid = 0.5
        
        
        local best_strategy = "hybrid"
        local best_score = scores.hybrid
        
        for strategy, score in pairs(scores) do
            if score > best_score then
                best_score = score
                best_strategy = strategy
            end
        end
        
        
        if best_strategy ~= state.current_strategy then
            state.last_strategy_change = now
            state.current_strategy = best_strategy
            state.strategy_confidence = best_score
        end
        
        return best_strategy
    end,
    
    
    get_strategy_success_rate = function(self, data, strategy)
        local successes = data.state.strategy_successes[strategy] or 0
        local failures = data.state.strategy_failures[strategy] or 0
        local total = successes + failures
        
        if total < 2 then
            return 0.5  
        end
        
        return successes / total
    end,
    
    
    record_result = function(self, player, strategy, hit)
        local data = resolver_advanced:get_player(player)
        if not data then return end
        
        if hit then
            data.state.strategy_successes[strategy] = (data.state.strategy_successes[strategy] or 0) + 1
        else
            data.state.strategy_failures[strategy] = (data.state.strategy_failures[strategy] or 0) + 1
        end
    end,
    
    
    execute = function(self, player, strategy)
        strategy = strategy or resolver_advanced.strategy_engine:select_strategy(player)
        
        if strategy == "pattern_match" then
            local pred = resolver_advanced.pattern_recognition:predict(player)
            if pred then
                return {
                    side = pred.predicted_side,
                    body = pred.predicted_side == 1 and 58 or -58,
                    confidence = pred.confidence,
                    strategy = strategy,
                }
            end
            
        elseif strategy == "jitter_predict" then
            local pred = resolver_base.jitter_detection:predict_next(player)
            if pred then
                local side = pred.direction > 0 and 1 or 0
                return {
                    side = side,
                    body = side == 1 and 58 or -58,
                    confidence = pred.confidence,
                    strategy = strategy,
                }
            end
            
        elseif strategy == "movement_based" then
            local pred = resolver_advanced.movement_analysis:predict_side(player)
            if pred then
                return {
                    side = pred.side,
                    body = pred.side == 1 and 58 or -58,
                    confidence = pred.confidence,
                    strategy = strategy,
                }
            end
            
        elseif strategy == "layer_analysis" then
            local pred = resolver_advanced.layer_analysis:predict(player)
            if pred then
                return {
                    side = pred.side,
                    body = pred.side == 1 and 58 or -58,
                    confidence = pred.confidence,
                    strategy = strategy,
                }
            end
            
        elseif strategy == "desync_track" then
            local desync, side, conf = resolver_base.desync:get_current(player)
            if conf > 0.3 then
                local s = side > 0 and 1 or 0
                return {
                    side = s,
                    body = desync * side,
                    confidence = conf,
                    strategy = strategy,
                }
            end
            
        elseif strategy == "learned" then
            local data = resolver_advanced:get_player(player)
            if data then
                local pred = resolver_advanced.confidence_resolver:get_learned_prediction(data)
                if pred then
                    return {
                        side = pred.side,
                        body = pred.body,
                        confidence = pred.confidence,
                        strategy = strategy,
                    }
                end
            end
            
        elseif strategy == "bruteforce" then
            return resolver_advanced.fallback:resolve(player)
            
        elseif strategy == "hybrid" then
            return resolver_advanced.confidence_resolver:resolve(player)
        end
        
        
        return resolver_advanced.fallback:resolve(player)
    end,
}




resolver_advanced.cache = {
    
    get = function(self, player)
        local player_id = tostring(player)
        local now = globals.realtime()
        
        local cached = resolver_advanced.prediction_cache[player_id]
        local timestamp = resolver_advanced.cache_timestamps[player_id]
        
        if cached and timestamp then
            if (now - timestamp) < resolver_advanced.config.cache_duration then
                return cached, true  
            end
        end
        
        return nil, false
    end,
    
    
    set = function(self, player, prediction)
        local player_id = tostring(player)
        local now = globals.realtime()
        
        resolver_advanced.prediction_cache[player_id] = prediction
        resolver_advanced.cache_timestamps[player_id] = now
        
        
        self:cleanup()
    end,
    
    
    invalidate = function(self, player)
        local player_id = tostring(player)
        resolver_advanced.prediction_cache[player_id] = nil
        resolver_advanced.cache_timestamps[player_id] = nil
    end,
    
    
    cleanup = function(self)
        local now = globals.realtime()
        local max_age = resolver_advanced.config.cache_duration * 2
        
        for player_id, timestamp in pairs(resolver_advanced.cache_timestamps) do
            if (now - timestamp) > max_age then
                resolver_advanced.prediction_cache[player_id] = nil
                resolver_advanced.cache_timestamps[player_id] = nil
            end
        end
        
        
        local count = 0
        for _ in pairs(resolver_advanced.prediction_cache) do
            count = count + 1
        end
        
        if count > resolver_advanced.config.max_cache_entries then
            
            local oldest_id = nil
            local oldest_time = now
            
            for player_id, timestamp in pairs(resolver_advanced.cache_timestamps) do
                if timestamp < oldest_time then
                    oldest_time = timestamp
                    oldest_id = player_id
                end
            end
            
            if oldest_id then
                resolver_advanced.prediction_cache[oldest_id] = nil
                resolver_advanced.cache_timestamps[oldest_id] = nil
            end
        end
    end,
}




resolver_advanced.resolve = function(self, player)
    if not player or not entity.is_alive(player) then
        return nil
    end
    
    
    local cached, is_cached = self.cache:get(player)
    if is_cached then
        return cached
    end
    
    
    local data = self:init_player(player)
    local now = globals.realtime()
    
    
    data.time_tracked = now - data.first_seen
    data.last_update = now
    
    
    local animstate = resolver_base.safe_animstate:get(player)
    if animstate then
        
        self.pattern_recognition:sample(player, animstate.eye_angles_y, animstate.body_yaw, 
            animstate.body_yaw > 0 and 1 or 0)
    end
    
    
    self.movement_analysis:sample(player)
    
    
    self.layer_analysis:sample(player)
    
    
    local strategy = self.strategy_engine:select_strategy(player)
    
    
    local mode = "learning"
    local mode_reason = ""
    
    if data.state.consecutive_misses >= 3 then
        mode = "bruteforce"
        mode_reason = "consecutive_misses"
    elseif data.confidence.overall >= resolver_advanced.config.high_confidence then
        mode = "confident"
        mode_reason = "high_confidence"
    elseif data.time_tracked < 1.0 then
        mode = "learning"
        mode_reason = "new_player"
    elseif data.confidence.overall < resolver_advanced.config.low_confidence then
        mode = "fallback"
        mode_reason = "low_confidence"
    else
        mode = "normal"
        mode_reason = "standard"
    end
    
    data.state.mode = mode
    data.state.mode_reason = mode_reason
    
    local fakelag_info = self.fakelag_detection:analyze(player)
    if fakelag_info.should_force_baim then
        return {
            side = 0,
            body = 0,
            confidence = 0.2,
            reason = "exploit_detected",
            force_baim = true,
        }
    end
    
    -- NEW: Check LBY prediction
    local lby_pred = self.lby_detection:get_prediction(player)
    if lby_pred and lby_pred.confidence > 0.7 then
        -- LBY flick imminent, use this prediction
        local smoothed = prediction_smoother:smooth(player, lby_pred)
        self.cache:set(player, smoothed)
        return smoothed
    end    

    local current_context = {
        velocity = resolver_base.velocity:get(player) and resolver_base.velocity:get(player).avg_speed or 0,
        duck_amount = animstate and animstate.duck_amount or 0,
        on_ground = animstate and animstate.on_ground or true,
        pattern_type = data.patterns and data.patterns.pattern_type or "unknown",
        jitter_detected = resolver_base.jitter_detection:get(player) and resolver_base.jitter_detection:get(player).is_jittering or false,
        backtrack = 0,
        movement_state = data.movement and data.movement.current_state or "unknown",
        is_peeking = data.movement and data.movement.is_peeking or false,
        strafe_direction = data.movement and data.movement.strafe_direction or 0,
        desync_mode = resolver_base.desync:get(player) and resolver_base.desync:get(player).desync_mode or "unknown",
        layer_behavior = data.layers and data.layers.detected_behavior or "unknown",
        time_tracked = data.time_tracked or 0,
    }
    local corr_pred = resolver_advanced.learning.shot_correlation:get_best_approach(player, current_context)
    if corr_pred and corr_pred.confidence > 0.65 then
        local smoothed = prediction_smoother:smooth(player, corr_pred)
        self.cache:set(player, smoothed)
        return smoothed
    end

    local prediction
    
    if mode == "bruteforce" then
        prediction = self.fallback:resolve(player)
    elseif mode == "fallback" then
        prediction = self.fallback:resolve(player)
    else
        prediction = self.strategy_engine:execute(player, strategy)
    end
    
    
    if not prediction or prediction.confidence < resolver_advanced.config.low_confidence then
        prediction = self.fallback:resolve(player)
    end
    
    
    if prediction then
        
        if prediction.side == 1 and prediction.body < 0 then
            prediction.body = 58
        elseif prediction.side == 0 and prediction.body > 0 then
            prediction.body = -58
        end
        
        prediction.body = math.max(-60, math.min(60, prediction.body))
        prediction.mode = mode
        prediction.strategy = strategy
        
        
        data.state.predicted_side = prediction.side
        data.state.predicted_body = prediction.body
        data.state.prediction_confidence = prediction.confidence
        data.state.current_strategy = strategy
        
        -- Apply smoothing before caching
        prediction = prediction_smoother:smooth(player, prediction)
        
        self.cache:set(player, prediction)
    end
    
    return prediction
end




resolver_advanced.record_shot = function(self, player, hit, hitgroup, body_yaw_used)
    local data = self:get_player(player)
    if not data then return end
    
    local now = globals.realtime()
    local state = data.state
    local learning = data.learning
    
    
    state.shots_fired = state.shots_fired + 1
    state.last_shot_time = now
    
    if hit then
        state.shots_hit = state.shots_hit + 1
        state.consecutive_hits = state.consecutive_hits + 1
        state.consecutive_misses = 0
        state.last_hit_time = now
        
        
        local side = state.predicted_side
        learning.hit_sides[side] = (learning.hit_sides[side] or 0) + 1
        
        if body_yaw_used then
            table.insert(learning.hit_body_yaws, body_yaw_used)
            while #learning.hit_body_yaws > 20 do
                table.remove(learning.hit_body_yaws, 1)
            end
        end
        
        
        self.strategy_engine:record_result(player, state.current_strategy, true)
        self.fallback:record_result(player, true, state.predicted_body)
        
        
        data.confidence.learning = math.min(0.9, data.confidence.learning + 0.1)
    else
        state.consecutive_misses = state.consecutive_misses + 1
        state.consecutive_hits = 0
        
        
        local side = state.predicted_side
        learning.miss_sides[side] = (learning.miss_sides[side] or 0) + 1
        
        if body_yaw_used then
            table.insert(learning.miss_body_yaws, body_yaw_used)
            while #learning.miss_body_yaws > 15 do
                table.remove(learning.miss_body_yaws, 1)
            end
        end
        
        
        self.strategy_engine:record_result(player, state.current_strategy, false)
        
        
        data.confidence.learning = math.max(0.2, data.confidence.learning - 0.15)
        
        
        self.cache:invalidate(player)
    end
end




resolver_advanced.clear_player = function(self, player)
    local player_id = tostring(player)
    self.players[player_id] = nil
    self.cache:invalidate(player)
end

resolver_advanced.clear_all = function(self)
    self.players = {}
    self.prediction_cache = {}
    self.cache_timestamps = {}
end






client.set_event_callback("net_update_end", function()
    local me = entity.get_local_player()
    if not me or not entity.is_alive(me) then return end
    
    local enemies = entity.get_players(true)
    for _, enemy in ipairs(enemies) do
        if entity.is_alive(enemy) and not entity.is_dormant(enemy) then
            
            
            pcall(function()
                resolver_advanced:resolve(enemy)
            end)
        end
    end
end)


client.set_event_callback("round_prestart", function()
    resolver_advanced:clear_all()
end)


client.set_event_callback("aim_hit", function(e)
    local target = e.target
    if target then
        pcall(function()
            resolver_advanced:record_shot(target, true, e.hitgroup, e.body_yaw)
        end)
    end
end)

client.set_event_callback("aim_miss", function(e)
    local target = e.target
    if target then
        pcall(function()
            resolver_advanced:record_shot(target, false, nil, nil)
        end)
    end
end)


client.set_event_callback("player_death", function(e)
    local victim = client.userid_to_entindex(e.userid)
    if victim then
        resolver_advanced:clear_player(victim)
    end
end)






local function get_advanced_resolver_prediction(player)
    
    resolver_base:update(player)
    
    
    local prediction = resolver_advanced:resolve(player)
    
    if prediction then
        return {
            side = prediction.side,
            body = prediction.body,
            yaw = prediction.yaw or 0,
            confidence = prediction.confidence,
            strategy = prediction.strategy,
            mode = prediction.mode,
        }
    end
    
    return nil
end


_G.resolver_advanced = resolver_advanced
_G.get_advanced_resolver_prediction = get_advanced_resolver_prediction









local resolver_neural = {
    
    config = {
        
        input_size = 24,
        hidden_layers = {64, 64, 64},  
        output_size = 3,  
        
        
        learning_rate = 0.001,
        learning_rate_min = 0.0001,
        learning_rate_max = 0.01,
        learning_rate_decay = 0.9995,
        momentum = 0.9,
        
        
        dropout_rate = 0.2,
        dropout_enabled = true,
        
        
        replay_buffer_size = 4096,
        batch_size = 32,
        min_samples_to_train = 64,
        
        
        per_alpha = 0.6,  
        per_beta = 0.4,   
        per_beta_increment = 0.001,
        per_epsilon = 0.01,  
        
        
        train_interval = 0.5,  
        save_interval = 60.0,  
        
        
        confidence_threshold = 0.6,
        high_confidence = 0.8,
        
        
        weight_init_scale = 0.1,
    },
    
    
    initialized = false,
    training_enabled = true,
    inference_only = false,
    
    
    last_train_time = 0,
    last_save_time = 0,
    
    
    stats = {
        total_predictions = 0,
        correct_predictions = 0,
        training_iterations = 0,
        average_loss = 0,
        current_learning_rate = 0.001,
    },
    
    
    db_key = "shinymoon:neural_resolver:weights:",
}




resolver_neural.network = {
    
    weights = {},
    biases = {},
    
    
    weight_momentum = {},
    bias_momentum = {},
    
    
    activations = {},
    pre_activations = {},
    
    
    dropout_masks = {},
}


resolver_neural.init_network = function(self)
    local net = self.network
    local cfg = self.config
    
    
    local layer_sizes = {cfg.input_size}
    for _, size in ipairs(cfg.hidden_layers) do
        table.insert(layer_sizes, size)
    end
    table.insert(layer_sizes, cfg.output_size)
    
    
    for i = 1, #layer_sizes - 1 do
        local fan_in = layer_sizes[i]
        local fan_out = layer_sizes[i + 1]
        
        
        local scale = math.sqrt(2.0 / fan_in)
        
        
        net.weights[i] = {}
        net.weight_momentum[i] = {}
        for j = 1, fan_out do
            net.weights[i][j] = {}
            net.weight_momentum[i][j] = {}
            for k = 1, fan_in do
                
                net.weights[i][j][k] = (math.random() * 2 - 1) * scale
                net.weight_momentum[i][j][k] = 0
            end
        end
        
        
        net.biases[i] = {}
        net.bias_momentum[i] = {}
        for j = 1, fan_out do
            net.biases[i][j] = 0
            net.bias_momentum[i][j] = 0
        end
    end
    
    self.initialized = true
    self.stats.current_learning_rate = cfg.learning_rate
    
    
    self:load_weights()
end


resolver_neural.relu = function(x)
    return math.max(0, x)
end

resolver_neural.relu_derivative = function(x)
    return x > 0 and 1 or 0
end

resolver_neural.sigmoid = function(x)
    
    x = math.max(-500, math.min(500, x))
    return 1 / (1 + math.exp(-x))
end

resolver_neural.sigmoid_derivative = function(x)
    local s = resolver_neural.sigmoid(x)
    return s * (1 - s)
end

resolver_neural.tanh_activation = function(x)
    return math.tanh(x)
end

resolver_neural.tanh_derivative = function(x)
    local t = math.tanh(x)
    return 1 - t * t
end


resolver_neural.softmax = function(values)
    local max_val = -math.huge
    for _, v in ipairs(values) do
        if v > max_val then max_val = v end
    end
    
    local sum = 0
    local result = {}
    for i, v in ipairs(values) do
        result[i] = math.exp(v - max_val)
        sum = sum + result[i]
    end
    
    for i = 1, #result do
        result[i] = result[i] / sum
    end
    
    return result
end




resolver_neural.forward = function(self, input, training)
    local net = self.network
    local cfg = self.config
    training = training or false
    
    if not self.initialized then
        self:init_network()
    end
    
    
    if not input or #input ~= cfg.input_size then
        return nil
    end
    
    
    net.activations = {}
    net.pre_activations = {}
    net.dropout_masks = {}
    
    
    local current = {}
    for i = 1, #input do
        current[i] = input[i] or 0
    end
    net.activations[0] = current
    
    
    local num_layers = #net.weights
    
    for layer = 1, num_layers do
        local weights = net.weights[layer]
        local biases = net.biases[layer]
        local output_size = #biases
        
        local pre_activation = {}
        local activation = {}
        
        for j = 1, output_size do
            
            local sum = biases[j]
            for k = 1, #current do
                sum = sum + weights[j][k] * current[k]
            end
            pre_activation[j] = sum
            
            
            if layer < num_layers then
                
                activation[j] = self.relu(sum)
            else
                
                
                
                
                if j == 1 then
                    activation[j] = self.sigmoid(sum)
                elseif j == 2 then
                    activation[j] = self.tanh_activation(sum)
                else
                    activation[j] = self.sigmoid(sum)
                end
            end
        end
        
        
        if training and cfg.dropout_enabled and layer < num_layers then
            local mask = {}
            local keep_prob = 1 - cfg.dropout_rate
            for j = 1, #activation do
                if math.random() < keep_prob then
                    mask[j] = 1 / keep_prob  
                    activation[j] = activation[j] * mask[j]
                else
                    mask[j] = 0
                    activation[j] = 0
                end
            end
            net.dropout_masks[layer] = mask
        end
        
        net.pre_activations[layer] = pre_activation
        net.activations[layer] = activation
        current = activation
    end
    
    return current
end




resolver_neural.backward = function(self, target, importance_weight)
    local net = self.network
    local cfg = self.config
    importance_weight = importance_weight or 1.0
    
    if not target or #target ~= cfg.output_size then
        return 0
    end
    
    local num_layers = #net.weights
    local lr = self.stats.current_learning_rate * importance_weight
    local momentum = cfg.momentum
    
    
    local output = net.activations[num_layers]
    local delta = {}
    local loss = 0
    
    for j = 1, #output do
        
        local error = output[j] - target[j]
        loss = loss + error * error
        
        
        local pre_act = net.pre_activations[num_layers][j]
        if j == 1 then
            delta[j] = error * self.sigmoid_derivative(pre_act)
        elseif j == 2 then
            delta[j] = error * self.tanh_derivative(pre_act)
        else
            delta[j] = error * self.sigmoid_derivative(pre_act)
        end
    end
    
    loss = loss / #output
    
    
    for layer = num_layers, 1, -1 do
        local input_activation = net.activations[layer - 1]
        local weights = net.weights[layer]
        local biases = net.biases[layer]
        
        
        if net.dropout_masks[layer] then
            for j = 1, #delta do
                delta[j] = delta[j] * (net.dropout_masks[layer][j] or 1)
            end
        end
        
        
        for j = 1, #biases do
            
            net.bias_momentum[layer][j] = momentum * net.bias_momentum[layer][j] - lr * delta[j]
            net.biases[layer][j] = net.biases[layer][j] + net.bias_momentum[layer][j]
            
            
            for k = 1, #input_activation do
                local grad = delta[j] * input_activation[k]
                net.weight_momentum[layer][j][k] = momentum * net.weight_momentum[layer][j][k] - lr * grad
                net.weights[layer][j][k] = net.weights[layer][j][k] + net.weight_momentum[layer][j][k]
            end
        end
        
        
        if layer > 1 then
            local prev_delta = {}
            local prev_pre_act = net.pre_activations[layer - 1]
            
            for k = 1, #input_activation do
                local sum = 0
                for j = 1, #delta do
                    sum = sum + delta[j] * weights[j][k]
                end
                
                prev_delta[k] = sum * self.relu_derivative(prev_pre_act[k])
            end
            delta = prev_delta
        end
    end
    
    return loss
end




resolver_neural.replay_buffer = {
    samples = {},
    priorities = {},
    max_priority = 1.0,
    size = 0,
    position = 0,
}


resolver_neural.add_experience = function(self, input, target, priority)
    local buffer = self.replay_buffer
    local cfg = self.config
    
    priority = priority or buffer.max_priority
    
    
    local experience = {
        input = input,
        target = target,
        priority = priority + cfg.per_epsilon,
    }
    
    
    buffer.position = (buffer.position % cfg.replay_buffer_size) + 1
    buffer.samples[buffer.position] = experience
    buffer.priorities[buffer.position] = experience.priority
    
    if buffer.size < cfg.replay_buffer_size then
        buffer.size = buffer.size + 1
    end
    
    
    if priority > buffer.max_priority then
        buffer.max_priority = priority
    end
end


resolver_neural.sample_batch = function(self)
    local buffer = self.replay_buffer
    local cfg = self.config
    
    if buffer.size < cfg.min_samples_to_train then
        return nil
    end
    
    local batch_size = math.min(cfg.batch_size, buffer.size)
    local batch = {}
    local indices = {}
    local weights = {}
    
    
    local priority_sum = 0
    for i = 1, buffer.size do
        priority_sum = priority_sum + math.pow(buffer.priorities[i] or 1, cfg.per_alpha)
    end
    
    
    local min_prob = math.pow(cfg.per_epsilon, cfg.per_alpha) / priority_sum
    local max_weight = math.pow(buffer.size * min_prob, -cfg.per_beta)
    
    
    local selected = {}
    for b = 1, batch_size do
        local rand = math.random() * priority_sum
        local cumsum = 0
        
        for i = 1, buffer.size do
            if not selected[i] then
                cumsum = cumsum + math.pow(buffer.priorities[i] or 1, cfg.per_alpha)
                if cumsum >= rand then
                    selected[i] = true
                    table.insert(batch, buffer.samples[i])
                    table.insert(indices, i)
                    
                    
                    local prob = math.pow(buffer.priorities[i] or 1, cfg.per_alpha) / priority_sum
                    local weight = math.pow(buffer.size * prob, -cfg.per_beta) / max_weight
                    table.insert(weights, weight)
                    break
                end
            end
        end
    end
    
    
    cfg.per_beta = math.min(1.0, cfg.per_beta + cfg.per_beta_increment)
    
    return batch, indices, weights
end


resolver_neural.update_priorities = function(self, indices, losses)
    local buffer = self.replay_buffer
    local cfg = self.config
    
    for i, idx in ipairs(indices) do
        local new_priority = math.abs(losses[i]) + cfg.per_epsilon
        buffer.priorities[idx] = new_priority
        
        if new_priority > buffer.max_priority then
            buffer.max_priority = new_priority
        end
    end
end




resolver_neural.train_batch = function(self)
    local cfg = self.config
    
    
    local batch, indices, weights = self:sample_batch()
    if not batch then
        return 0
    end
    
    local total_loss = 0
    local losses = {}
    
    
    for i, experience in ipairs(batch) do
        
        local output = self:forward(experience.input, true)
        if output then
            
            local loss = self:backward(experience.target, weights[i])
            total_loss = total_loss + loss
            losses[i] = loss
        else
            losses[i] = 0
        end
    end
    
    
    self:update_priorities(indices, losses)
    
    
    local avg_loss = total_loss / #batch
    self.stats.average_loss = self.stats.average_loss * 0.95 + avg_loss * 0.05
    self.stats.training_iterations = self.stats.training_iterations + 1
    
    
    self:adjust_learning_rate(avg_loss)
    
    return avg_loss
end




resolver_neural.adjust_learning_rate = function(self, current_loss)
    local cfg = self.config
    local stats = self.stats
    
    
    stats.current_learning_rate = stats.current_learning_rate * cfg.learning_rate_decay
    
    
    stats.current_learning_rate = math.max(cfg.learning_rate_min, 
        math.min(cfg.learning_rate_max, stats.current_learning_rate))
    
    
    if current_loss > 0.5 then
        stats.current_learning_rate = math.min(cfg.learning_rate_max, 
            stats.current_learning_rate * 1.05)
    elseif current_loss < 0.01 then
        stats.current_learning_rate = math.max(cfg.learning_rate_min,
            stats.current_learning_rate * 0.95)
    end
end




resolver_neural.save_weights = function(self)
    local net = self.network
    
    if not self.initialized or not database then
        return false
    end
    
    
    local data = {
        weights = {},
        biases = {},
        stats = {
            learning_rate = self.stats.current_learning_rate,
            training_iterations = self.stats.training_iterations,
            average_loss = self.stats.average_loss,
            correct_predictions = self.stats.correct_predictions,
            total_predictions = self.stats.total_predictions,
        },
        version = 1,
    }
    
    
    for layer = 1, #net.weights do
        data.weights[layer] = {}
        for j = 1, #net.weights[layer] do
            data.weights[layer][j] = {}
            for k = 1, #net.weights[layer][j] do
                data.weights[layer][j][k] = net.weights[layer][j][k]
            end
        end
        
        data.biases[layer] = {}
        for j = 1, #net.biases[layer] do
            data.biases[layer][j] = net.biases[layer][j]
        end
    end
    
    
    local success = pcall(function()
        local json_str = json.stringify(data)
        database.write(self.db_key .. "v1", json_str)
    end)
    
    self.last_save_time = globals.realtime()
    return success
end

resolver_neural.load_weights = function(self)
    local net = self.network
    
    if not database then
        return false
    end
    
    local success = pcall(function()
        local json_str = database.read(self.db_key .. "v1")
        if not json_str or json_str == "" then
            return
        end
        
        local data = json.parse(json_str)
        if not data or data.version ~= 1 then
            return
        end
        
        
        if data.weights then
            for layer = 1, #data.weights do
                if net.weights[layer] then
                    for j = 1, #data.weights[layer] do
                        if net.weights[layer][j] then
                            for k = 1, #data.weights[layer][j] do
                                net.weights[layer][j][k] = data.weights[layer][j][k]
                            end
                        end
                    end
                end
            end
        end
        
        
        if data.biases then
            for layer = 1, #data.biases do
                if net.biases[layer] then
                    for j = 1, #data.biases[layer] do
                        net.biases[layer][j] = data.biases[layer][j]
                    end
                end
            end
        end
        
        
        if data.stats then
            self.stats.current_learning_rate = data.stats.learning_rate or self.config.learning_rate
            self.stats.training_iterations = data.stats.training_iterations or 0
            self.stats.average_loss = data.stats.average_loss or 0
            self.stats.correct_predictions = data.stats.correct_predictions or 0
            self.stats.total_predictions = data.stats.total_predictions or 0
        end
    end)
    
    return success
end




resolver_neural.predict = function(self, player)
    if not self.initialized then
        self:init_network()
    end
    
    
    local features = resolver_base.features:extract(player)
    if not features or not features.vector then
        return nil
    end
    
    
    local output = self:forward(features.vector, false)
    if not output or #output < 3 then
        return nil
    end
    
    
    
    
    
    
    local side_prob = output[1]
    local body_normalized = output[2]
    local confidence = output[3]
    
    
    local side = side_prob > 0.5 and 1 or 0
    local body = body_normalized * 60  
    
    
    if side == 1 and body < 0 then
        body = math.abs(body)
    elseif side == 0 and body > 0 then
        body = -math.abs(body)
    end
    
    body = math.max(-60, math.min(60, math.floor(body + 0.5)))
    
    
    self.stats.total_predictions = self.stats.total_predictions + 1
    
    return {
        side = side,
        side_probability = side_prob,
        body = body,
        body_raw = body_normalized,
        confidence = confidence,
        network_output = output,
        features = features.vector,
    }
end




resolver_neural.resolve = function(self, player)
    local cfg = self.config
    
    
    local nn_pred = self:predict(player)
    if not nn_pred then
        return nil
    end
    
    
    if nn_pred.confidence < cfg.confidence_threshold then
        
        return {
            side = nn_pred.side,
            body = nn_pred.body,
            confidence = nn_pred.confidence * 0.5,  
            source = "neural_low_conf",
            defer_to_fallback = true,
        }
    end
    
    
    local result = {
        side = nn_pred.side,
        body = nn_pred.body,
        confidence = nn_pred.confidence,
        source = "neural_network",
        network_confidence = nn_pred.confidence,
        side_probability = nn_pred.side_probability,
    }
    
    
    if nn_pred.confidence >= cfg.high_confidence then
        result.confidence = math.min(0.95, result.confidence * 1.1)
        result.high_confidence = true
    end
    
    return result
end




resolver_neural.record_result = function(self, player, hit, hitgroup, prediction)
    if not self.training_enabled then
        return
    end
    
    
    local features = resolver_base.features:extract(player)
    if not features or not features.vector then
        return
    end
    
    
    local adv_data = resolver_advanced:get_player(player)
    local actual_side = adv_data and adv_data.state.predicted_side or 0
    local actual_body = adv_data and adv_data.state.predicted_body or 0
    
    
    local target = {}
    
    if hit then
        
        target[1] = actual_side  
        target[2] = actual_body / 60  
        target[3] = 1.0  
        
        
        self.stats.correct_predictions = self.stats.correct_predictions + 1
    else
        
        target[1] = 1 - actual_side  
        target[2] = -actual_body / 60  
        target[3] = 0.3  
    end
    
    
    local priority = hit and 1.0 or 2.0
    
    
    self:add_experience(features.vector, target, priority)
end




resolver_neural.get_combined_prediction = function(self, player)
    local cfg = self.config
    
    
    local nn_result = self:resolve(player)
    
    
    local adv_result = nil
    pcall(function()
        adv_result = resolver_advanced:resolve(player)
    end)
    
    
    if nn_result and nn_result.confidence >= cfg.high_confidence then
        return {
            side = nn_result.side,
            body = nn_result.body,
            confidence = nn_result.confidence,
            source = "neural_high",
            neural_confidence = nn_result.confidence,
        }
    end
    
    
    if adv_result and nn_result then
        if adv_result.confidence > nn_result.confidence then
            return {
                side = adv_result.side,
                body = adv_result.body,
                confidence = adv_result.confidence,
                source = "advanced",
                neural_confidence = nn_result.confidence,
            }
        end
    end
    
    
    if nn_result and adv_result then
        
        local nn_weight = nn_result.confidence
        local adv_weight = adv_result.confidence
        local total_weight = nn_weight + adv_weight
        
        if total_weight > 0 then
            
            local side_score = (nn_result.side * nn_weight + adv_result.side * adv_weight) / total_weight
            local final_side = side_score > 0.5 and 1 or 0
            
            
            local final_body = (nn_result.body * nn_weight + adv_result.body * adv_weight) / total_weight
            
            
            if final_side == 1 and final_body < 0 then
                final_body = math.abs(final_body)
            elseif final_side == 0 and final_body > 0 then
                final_body = -math.abs(final_body)
            end
            
            final_body = math.max(-60, math.min(60, math.floor(final_body + 0.5)))
            
            
            local combined_conf = math.max(nn_result.confidence, adv_result.confidence)
            if nn_result.side == adv_result.side then
                combined_conf = math.min(0.95, combined_conf * 1.15)  
            end
            
            return {
                side = final_side,
                body = final_body,
                confidence = combined_conf,
                source = "combined",
                neural_confidence = nn_result.confidence,
                advanced_confidence = adv_result.confidence,
            }
        end
    end
    
    
    if nn_result then
        return {
            side = nn_result.side,
            body = nn_result.body,
            confidence = nn_result.confidence,
            source = "neural_fallback",
        }
    end
    
    if adv_result then
        return {
            side = adv_result.side,
            body = adv_result.body,
            confidence = adv_result.confidence,
            source = "advanced_fallback",
        }
    end
    
    return nil
end




resolver_neural.update = function(self)
    local now = globals.realtime()
    local cfg = self.config
    
    
    if self.training_enabled and (now - self.last_train_time) >= cfg.train_interval then
        if self.replay_buffer.size >= cfg.min_samples_to_train then
            self:train_batch()
        end
        self.last_train_time = now
    end
    
    
    if (now - self.last_save_time) >= cfg.save_interval then
        self:save_weights()
        self.last_save_time = now
    end
end




resolver_neural.reset = function(self)
    self.replay_buffer.samples = {}
    self.replay_buffer.priorities = {}
    self.replay_buffer.size = 0
    self.replay_buffer.position = 0
    self.replay_buffer.max_priority = 1.0
end

resolver_neural.full_reset = function(self)
    self:reset()
    self.initialized = false
    self.network.weights = {}
    self.network.biases = {}
    self.network.weight_momentum = {}
    self.network.bias_momentum = {}
    self.stats = {
        total_predictions = 0,
        correct_predictions = 0,
        training_iterations = 0,
        average_loss = 0,
        current_learning_rate = self.config.learning_rate,
    }
    
    
    pcall(function()
        database.write(self.db_key .. "v1", "")
    end)
    
    
    self:init_network()
end




resolver_neural.get_stats = function(self)
    local accuracy = 0
    if self.stats.total_predictions > 0 then
        accuracy = self.stats.correct_predictions / self.stats.total_predictions
    end
    
    return {
        total_predictions = self.stats.total_predictions,
        correct_predictions = self.stats.correct_predictions,
        accuracy = accuracy,
        training_iterations = self.stats.training_iterations,
        average_loss = self.stats.average_loss,
        learning_rate = self.stats.current_learning_rate,
        buffer_size = self.replay_buffer.size,
        buffer_max = self.config.replay_buffer_size,
        initialized = self.initialized,
    }
end






client.set_event_callback("player_connect_full", function()
    pcall(function()
        resolver_neural:init_network()
    end)
end)


client.set_event_callback("paint", function()
    pcall(function()
        resolver_neural:update()
    end)
end)


client.set_event_callback("aim_hit", function(e)
    local target = e.target
    if target then
        pcall(function()
            local prediction = resolver_neural:predict(target)
            resolver_neural:record_result(target, true, e.hitgroup, prediction)
        end)
    end
end)

client.set_event_callback("aim_miss", function(e)
    local target = e.target
    if target then
        pcall(function()
            local prediction = resolver_neural:predict(target)
            resolver_neural:record_result(target, false, nil, prediction)
        end)
    end
end)


client.set_event_callback("shutdown", function()
    pcall(function()
        resolver_neural:save_weights()
    end)
end)


client.set_event_callback("round_prestart", function()
    
    
end)




local function get_neural_resolver_prediction(player)
    
    resolver_base:update(player)
    
    
    local prediction = resolver_neural:get_combined_prediction(player)
    
    return prediction
end




_G.resolver_neural = resolver_neural
_G.get_neural_resolver_prediction = get_neural_resolver_prediction









local resolver_supreme = {
    
    version = "2.0.0",
    name = "ShinyMoon Supreme Resolver",
    
    
    config = {
        
        use_neural = true,
        use_advanced = true,
        use_base = true,
        use_legacy = true,
        use_gamesense = true,
        
        
        weights = {
            neural = 0.30,
            advanced = 0.25,
            base = 0.20,
            legacy = 0.15,
            gamesense = 0.10,
        },
        
        
        high_confidence = 0.80,
        medium_confidence = 0.60,
        low_confidence = 0.40,
        minimum_confidence = 0.25,
        
        
        neural_override_threshold = 0.85,
        unanimous_boost = 0.15,
        
        
        weight_learning_rate = 0.05,
        min_weight = 0.05,
        max_weight = 0.50,
        
        
        track_history_size = 100,
        evaluation_interval = 1.0,
        
        
        max_consecutive_misses = 4,
        bruteforce_after_misses = 3,
        
        
        cache_duration = 0.02,  
    },
    
    
    players = {},
    
    
    performance = {
        sources = {
            neural = { hits = 0, misses = 0, total = 0, accuracy = 0.5 },
            advanced = { hits = 0, misses = 0, total = 0, accuracy = 0.5 },
            base = { hits = 0, misses = 0, total = 0, accuracy = 0.5 },
            legacy = { hits = 0, misses = 0, total = 0, accuracy = 0.5 },
            gamesense = { hits = 0, misses = 0, total = 0, accuracy = 0.5 },
            supreme = { hits = 0, misses = 0, total = 0, accuracy = 0.5 },
        },
        last_evaluation = 0,
        total_resolved = 0,
        best_source = "supreme",
    },
    
    
    cache = {},
    cache_times = {},
    
    
    initialized = false,
    last_update = 0,
    
    
    db_key = "shinymoon:supreme_resolver:",
}




resolver_supreme.init = function(self)
    if self.initialized then return end
    
    
    self:load_weights()
    
    self.initialized = true
    self.last_update = globals.realtime()
end




resolver_supreme.init_player = function(self, player)
    local player_id = tostring(player)
    
    if not self.players[player_id] then
        self.players[player_id] = {
            
            player_id = player_id,
            entity = player,
            
            
            prediction = nil,
            last_prediction_time = 0,
            
            
            source_performance = {
                neural = { hits = 0, misses = 0, weight = 0.30 },
                advanced = { hits = 0, misses = 0, weight = 0.25 },
                base = { hits = 0, misses = 0, weight = 0.20 },
                legacy = { hits = 0, misses = 0, weight = 0.15 },
                gamesense = { hits = 0, misses = 0, weight = 0.10 },
            },
            
            
            last_predictions = {
                neural = nil,
                advanced = nil,
                base = nil,
                legacy = nil,
                gamesense = nil,
            },
            
            
            shot_history = {},
            max_history = 20,
            
            
            consecutive_misses = 0,
            consecutive_hits = 0,
            total_shots = 0,
            total_hits = 0,
            
            
            bruteforce_active = false,
            bruteforce_stage = 0,
            bruteforce_offsets = {0, 58, -58, 45, -45, 30, -30, 15, -15, 50, -50, 40, -40, 20, -20, 55, -55},
            
            
            last_source = "supreme",
            last_side = 0,
            last_body = 0,
            
            
            first_seen = globals.realtime(),
            last_update = 0,
        }
    end
    
    return self.players[player_id]
end


resolver_supreme.get_player = function(self, player)
    local player_id = tostring(player)
    return self.players[player_id]
end






resolver_supreme.get_neural_prediction = function(self, player)
    if not self.config.use_neural then return nil end
    if not resolver_neural or not resolver_neural.initialized then return nil end
    
    local success, result = pcall(function()
        return resolver_neural:predict(player)
    end)
    
    if success and result then
        return {
            side = result.side,
            body = result.body,
            confidence = result.confidence or 0.5,
            source = "neural",
            raw = result,
        }
    end
    
    return nil
end


resolver_supreme.get_advanced_prediction = function(self, player)
    if not self.config.use_advanced then return nil end
    if not resolver_advanced then return nil end
    
    local success, result = pcall(function()
        return resolver_advanced:resolve(player)
    end)
    
    if success and result then
        return {
            side = result.side,
            body = result.body,
            confidence = result.confidence or 0.5,
            source = "advanced",
            strategy = result.strategy,
            raw = result,
        }
    end
    
    return nil
end


resolver_supreme.get_base_prediction = function(self, player)
    if not self.config.use_base then return nil end
    if not resolver_base then return nil end
    
    local success, result = pcall(function()
        
        resolver_base:update(player)
        
        
        local desync_data = resolver_base.desync:get(player)
        local jitter_data = resolver_base.jitter_detection:get(player)
        
        if not desync_data then return nil end
        
        local side = desync_data.desync_side > 0 and 1 or 0
        local body = desync_data.current_desync * desync_data.desync_side
        local confidence = desync_data.estimation_confidence
        
        
        if jitter_data and jitter_data.pattern_confidence > 0.5 then
            confidence = math.min(0.9, confidence + 0.1)
            
            
            local jit_pred = resolver_base.jitter_detection:predict_next(player)
            if jit_pred then
                side = jit_pred.direction > 0 and 1 or 0
                body = side == 1 and 58 or -58
            end
        end
        
        return {
            side = side,
            body = body,
            confidence = confidence,
            source = "base",
            desync_mode = desync_data.desync_mode,
        }
    end)
    
    if success and result then
        return result
    end
    
    return nil
end


resolver_supreme.get_legacy_prediction = function(self, player)
    if not self.config.use_legacy then return nil end
    if not resolver then return nil end
    
    local success, result = pcall(function()
        
        local jitter = resolver.jitter
        if not jitter then return nil end
        
        local player_id = tostring(player)
        local data = jitter.players[player_id]
        if not data then
            data = jitter:init_player(player_id)
        end
        
        
        local side = data.current_side or 0
        local body = data.predicted_body or (side == 1 and 58 or -58)
        local confidence = data.pattern_confidence or 0.5
        
        return {
            side = side,
            body = body,
            confidence = confidence,
            source = "legacy",
            pattern = data.pattern,
        }
    end)
    
    if success and result then
        return result
    end
    
    return nil
end


resolver_supreme.get_gamesense_prediction = function(self, player)
    if not self.config.use_gamesense then return nil end
    
    local success, result = pcall(function()
        
        local eye_yaw = entity.get_prop(player, "m_angEyeAngles[1]") or 0
        local body_yaw = entity.get_prop(player, "m_flPoseParameter", 6) or 0.5
        
        
        body_yaw = (body_yaw - 0.5) * 120  
        
        
        local side = body_yaw > 0 and 1 or 0
        
        
        local animstate = resolver_base and resolver_base.safe_animstate:get(player)
        if animstate then
            local goal_feet = animstate.goal_feet_yaw or 0
            local actual_desync = func.aa_clamp(goal_feet - eye_yaw)
            if math.abs(actual_desync) > 5 then
                side = actual_desync > 0 and 1 or 0
                body_yaw = actual_desync
            end
        end
        
        return {
            side = side,
            body = body_yaw,
            confidence = 0.45,  
            source = "gamesense",
        }
    end)
    
    if success and result then
        return result
    end
    
    return nil
end




resolver_supreme.blend_predictions = function(self, player, predictions)
    local cfg = self.config
    local player_data = self:init_player(player)
    
    if not predictions or #predictions == 0 then
        return nil
    end
    
    
    if #predictions == 1 then
        local p = predictions[1]
        return {
            side = p.side,
            body = p.body,
            confidence = p.confidence * 0.9,  
            source = p.source,
            blend_type = "single",
        }
    end
    
    
    local weights = self:get_dynamic_weights(player_data)
    
    
    local side_votes = {[0] = 0, [1] = 0}
    local body_sum = 0
    local confidence_sum = 0
    local total_weight = 0
    local sources_used = {}
    
    for _, pred in ipairs(predictions) do
        local source = pred.source
        local weight = weights[source] or 0.1
        local confidence = pred.confidence or 0.5
        
        
        local effective_weight = weight * confidence
        
        
        side_votes[pred.side] = (side_votes[pred.side] or 0) + effective_weight
        
        
        body_sum = body_sum + pred.body * effective_weight
        
        
        confidence_sum = confidence_sum + confidence * effective_weight
        
        total_weight = total_weight + effective_weight
        table.insert(sources_used, source)
        
        
        player_data.last_predictions[source] = pred
    end
    
    if total_weight == 0 then
        return nil
    end
    
    
    local final_side = side_votes[1] > side_votes[0] and 1 or 0
    local side_margin = math.abs(side_votes[1] - side_votes[0]) / total_weight
    
    
    local final_body = body_sum / total_weight
    
    
    local all_agree = true
    local first_side = predictions[1].side
    for _, pred in ipairs(predictions) do
        if pred.side ~= first_side then
            all_agree = false
            break
        end
    end
    
    
    local final_confidence = confidence_sum / total_weight
    
    
    if all_agree and #predictions >= 3 then
        final_confidence = math.min(0.95, final_confidence + cfg.unanimous_boost)
    end
    
    
    if side_margin > 0.6 then
        final_confidence = math.min(0.95, final_confidence + 0.1)
    end
    
    
    if final_side == 1 and final_body < 0 then
        final_body = math.abs(final_body)
    elseif final_side == 0 and final_body > 0 then
        final_body = -math.abs(final_body)
    end
    
    
    if math.abs(final_body) < 30 then
        final_body = final_side == 1 and 58 or -58
    end
    final_body = math.max(-60, math.min(60, math.floor(final_body + 0.5)))
    
    return {
        side = final_side,
        body = final_body,
        confidence = final_confidence,
        source = "supreme",
        blend_type = all_agree and "unanimous" or "weighted",
        side_margin = side_margin,
        sources_used = sources_used,
        predictions = predictions,
    }
end




resolver_supreme.get_dynamic_weights = function(self, player_data)
    local cfg = self.config
    local base_weights = cfg.weights
    local perf = player_data.source_performance
    
    local weights = {}
    local total = 0
    
    for source, base_weight in pairs(base_weights) do
        local source_perf = perf[source]
        if source_perf then
            local hits = source_perf.hits or 0
            local misses = source_perf.misses or 0
            local total_shots = hits + misses
            
            
            local accuracy = 0.5
            if total_shots >= 3 then
                accuracy = hits / total_shots
            end
            
            
            
            local adjustment = (accuracy - 0.5) * 0.5
            local adjusted_weight = base_weight + adjustment
            
            
            adjusted_weight = math.max(cfg.min_weight, math.min(cfg.max_weight, adjusted_weight))
            
            weights[source] = adjusted_weight
            total = total + adjusted_weight
        else
            weights[source] = base_weight
            total = total + base_weight
        end
    end
    
    
    if total > 0 then
        for source, weight in pairs(weights) do
            weights[source] = weight / total
        end
    end
    
    return weights
end




resolver_supreme.get_bruteforce_prediction = function(self, player)
    local player_data = self:init_player(player)
    local bf = player_data.bruteforce_offsets
    
    
    player_data.bruteforce_stage = (player_data.bruteforce_stage % #bf) + 1
    local offset = bf[player_data.bruteforce_stage]
    
    return {
        side = offset > 0 and 1 or 0,
        body = offset,
        confidence = 0.35,
        source = "bruteforce",
        stage = player_data.bruteforce_stage,
    }
end




resolver_supreme.check_overrides = function(self, player, predictions)
    local cfg = self.config
    
    
    if cfg.use_neural then
        for _, pred in ipairs(predictions) do
            if pred.source == "neural" and pred.confidence >= cfg.neural_override_threshold then
                return pred, "neural_override"
            end
        end
    end
    
    
    local all_agree = true
    local first_side = predictions[1] and predictions[1].side
    local min_confidence = 1.0
    
    for _, pred in ipairs(predictions) do
        if pred.side ~= first_side then
            all_agree = false
            break
        end
        min_confidence = math.min(min_confidence, pred.confidence)
    end
    
    if all_agree and #predictions >= 4 and min_confidence >= 0.6 then
        
        local avg_body = 0
        for _, pred in ipairs(predictions) do
            avg_body = avg_body + pred.body
        end
        avg_body = avg_body / #predictions
        
        return {
            side = first_side,
            body = avg_body,
            confidence = math.min(0.95, min_confidence + 0.2),
            source = "unanimous",
        }, "unanimous_override"
    end
    
    return nil, nil
end




resolver_supreme.resolve = function(self, player)
    if not self.initialized then
        self:init()
    end
    
    if not player or not entity.is_alive(player) then
        return nil
    end
    
    local player_id = tostring(player)
    local now = globals.realtime()
    local cfg = self.config
    
    
    if self.cache[player_id] and self.cache_times[player_id] then
        if (now - self.cache_times[player_id]) < cfg.cache_duration then
            return self.cache[player_id]
        end
    end
    
    
    local player_data = self:init_player(player)
    
    
    if player_data.consecutive_misses >= cfg.bruteforce_after_misses then
        player_data.bruteforce_active = true
    else
        player_data.bruteforce_active = false
        player_data.bruteforce_stage = 0
    end
    
    
    if player_data.bruteforce_active then
        local bf_result = self:get_bruteforce_prediction(player)
        bf_result.mode = "bruteforce"
        self.cache[player_id] = bf_result
        self.cache_times[player_id] = now
        player_data.prediction = bf_result
        player_data.last_source = "bruteforce"
        return bf_result
    end
    
    
    local predictions = {}
    
    
    local neural_pred = self:get_neural_prediction(player)
    if neural_pred then
        table.insert(predictions, neural_pred)
    end
    
    
    local advanced_pred = self:get_advanced_prediction(player)
    if advanced_pred then
        table.insert(predictions, advanced_pred)
    end
    
    
    local base_pred = self:get_base_prediction(player)
    if base_pred then
        table.insert(predictions, base_pred)
    end
    
    
    local legacy_pred = self:get_legacy_prediction(player)
    if legacy_pred then
        table.insert(predictions, legacy_pred)
    end
    
    
    local gs_pred = self:get_gamesense_prediction(player)
    if gs_pred then
        table.insert(predictions, gs_pred)
    end
    
    
    if #predictions == 0 then
        local fallback = self:get_bruteforce_prediction(player)
        fallback.mode = "fallback"
        self.cache[player_id] = fallback
        self.cache_times[player_id] = now
        return fallback
    end
    
    
    local override_result, override_reason = self:check_overrides(player, predictions)
    if override_result then
        
        if override_result.side == 1 and override_result.body < 0 then
            override_result.body = math.abs(override_result.body)
        elseif override_result.side == 0 and override_result.body > 0 then
            override_result.body = -math.abs(override_result.body)
        end
        override_result.body = math.max(-60, math.min(60, math.floor(override_result.body + 0.5)))
        override_result.mode = override_reason
        
        self.cache[player_id] = override_result
        self.cache_times[player_id] = now
        player_data.prediction = override_result
        player_data.last_source = override_result.source
        return override_result
    end
    
    
    local blended = self:blend_predictions(player, predictions)
    if not blended then
        local fallback = self:get_bruteforce_prediction(player)
        fallback.mode = "blend_fallback"
        self.cache[player_id] = fallback
        self.cache_times[player_id] = now
        return fallback
    end
    
    blended.mode = "blended"
    
    
    self.cache[player_id] = blended
    self.cache_times[player_id] = now
    player_data.prediction = blended
    player_data.last_prediction_time = now
    player_data.last_source = "supreme"
    player_data.last_side = blended.side
    player_data.last_body = blended.body
    player_data.last_update = now
    
    
    self.performance.total_resolved = self.performance.total_resolved + 1
    
    return blended
end




resolver_supreme.apply = function(self, player)
    
    local prediction = self:resolve(player)
    if not prediction then
        return false
    end
    
    
    local success = pcall(function()
        
        if plist and type(plist.set) == "function" then
            
            plist.set(player, "Resolver override", true)
            plist.set(player, "Correction yaw", prediction.body)
        end
    end)
    
    return success, prediction
end




resolver_supreme.record_result = function(self, player, hit, hitgroup)
    local player_data = self:get_player(player)
    if not player_data then return end
    
    local now = globals.realtime()
    
    
    player_data.total_shots = player_data.total_shots + 1
    
    if hit then
        player_data.total_hits = player_data.total_hits + 1
        player_data.consecutive_hits = player_data.consecutive_hits + 1
        player_data.consecutive_misses = 0
        player_data.bruteforce_active = false
        
        
        if player_data.last_predictions then
            for source, pred in pairs(player_data.last_predictions) do
                if pred and player_data.source_performance[source] then
                    
                    if pred.side == player_data.last_side then
                        player_data.source_performance[source].hits = 
                            (player_data.source_performance[source].hits or 0) + 1
                    end
                end
            end
        end
        
        
        self.performance.sources.supreme.hits = self.performance.sources.supreme.hits + 1
        
        
        pcall(function()
            if resolver_neural then
                resolver_neural:record_result(player, true, hitgroup, player_data.prediction)
            end
        end)
        
        
        pcall(function()
            if resolver_advanced then
                resolver_advanced:record_shot(player, true, hitgroup, player_data.last_body)
            end
        end)
    else
        player_data.consecutive_misses = player_data.consecutive_misses + 1
        player_data.consecutive_hits = 0
        
        
        if player_data.last_predictions then
            for source, pred in pairs(player_data.last_predictions) do
                if pred and player_data.source_performance[source] then
                    if pred.side == player_data.last_side then
                        player_data.source_performance[source].misses = 
                            (player_data.source_performance[source].misses or 0) + 1
                    end
                end
            end
        end
        
        
        self.performance.sources.supreme.misses = self.performance.sources.supreme.misses + 1
        
        
        pcall(function()
            if resolver_neural then
                resolver_neural:record_result(player, false, nil, player_data.prediction)
            end
        end)
        
        
        pcall(function()
            if resolver_advanced then
                resolver_advanced:record_shot(player, false, nil, player_data.last_body)
            end
        end)
        
        
        self.cache[tostring(player)] = nil
        self.cache_times[tostring(player)] = nil
    end
    
    
    table.insert(player_data.shot_history, {
        time = now,
        hit = hit,
        hitgroup = hitgroup,
        side = player_data.last_side,
        body = player_data.last_body,
        source = player_data.last_source,
    })
    
    while #player_data.shot_history > player_data.max_history do
        table.remove(player_data.shot_history, 1)
    end
    
    
    self:update_weights()
end




resolver_supreme.update_weights = function(self)
    local now = globals.realtime()
    local cfg = self.config
    
    if (now - self.performance.last_evaluation) < cfg.evaluation_interval then
        return
    end
    
    self.performance.last_evaluation = now
    
    
    for source, data in pairs(self.performance.sources) do
        local total = data.hits + data.misses
        if total > 0 then
            data.accuracy = data.hits / total
            data.total = total
        end
    end
    
    
    local best_source = "supreme"
    local best_accuracy = 0
    
    for source, data in pairs(self.performance.sources) do
        if data.total >= 5 and data.accuracy > best_accuracy then
            best_accuracy = data.accuracy
            best_source = source
        end
    end
    
    self.performance.best_source = best_source
    
    
    for source, _ in pairs(cfg.weights) do
        local data = self.performance.sources[source]
        if data and data.total >= 5 then
            local current = cfg.weights[source]
            local target = data.accuracy
            
            
            cfg.weights[source] = current + (target - current) * cfg.weight_learning_rate
            
            
            cfg.weights[source] = math.max(cfg.min_weight, math.min(cfg.max_weight, cfg.weights[source]))
        end
    end
    
    
    local total = 0
    for _, weight in pairs(cfg.weights) do
        total = total + weight
    end
    if total > 0 then
        for source, weight in pairs(cfg.weights) do
            cfg.weights[source] = weight / total
        end
    end
end




resolver_supreme.save_weights = function(self)
    if not database then return false end
    
    local success = pcall(function()
        local data = {
            weights = self.config.weights,
            performance = {
                sources = {},
            },
            version = 1,
        }
        
        for source, perf in pairs(self.performance.sources) do
            data.performance.sources[source] = {
                hits = perf.hits,
                misses = perf.misses,
                accuracy = perf.accuracy,
            }
        end
        
        local json_str = json.stringify(data)
        database.write(self.db_key .. "v1", json_str)
    end)
    
    return success
end

resolver_supreme.load_weights = function(self)
    if not database then return false end
    
    local success = pcall(function()
        local json_str = database.read(self.db_key .. "v1")
        if not json_str or json_str == "" then return end
        
        local data = json.parse(json_str)
        if not data or data.version ~= 1 then return end
        
        if data.weights then
            for source, weight in pairs(data.weights) do
                if self.config.weights[source] then
                    self.config.weights[source] = weight
                end
            end
        end
        
        if data.performance and data.performance.sources then
            for source, perf in pairs(data.performance.sources) do
                if self.performance.sources[source] then
                    self.performance.sources[source].hits = perf.hits or 0
                    self.performance.sources[source].misses = perf.misses or 0
                    self.performance.sources[source].accuracy = perf.accuracy or 0.5
                end
            end
        end
    end)
    
    return success
end




resolver_supreme.get_stats = function(self)
    local stats = {
        version = self.version,
        initialized = self.initialized,
        total_resolved = self.performance.total_resolved,
        best_source = self.performance.best_source,
        weights = {},
        sources = {},
    }
    
    for source, weight in pairs(self.config.weights) do
        stats.weights[source] = math.floor(weight * 1000) / 10  
    end
    
    for source, perf in pairs(self.performance.sources) do
        stats.sources[source] = {
            hits = perf.hits,
            misses = perf.misses,
            total = perf.total,
            accuracy = math.floor((perf.accuracy or 0.5) * 1000) / 10,  
        }
    end
    
    return stats
end




resolver_supreme.clear_player = function(self, player)
    local player_id = tostring(player)
    self.players[player_id] = nil
    self.cache[player_id] = nil
    self.cache_times[player_id] = nil
end

resolver_supreme.clear_all = function(self)
    self.players = {}
    self.cache = {}
    self.cache_times = {}
end

resolver_supreme.reset = function(self)
    self:clear_all()
    
    
    for source, _ in pairs(self.performance.sources) do
        self.performance.sources[source] = { hits = 0, misses = 0, total = 0, accuracy = 0.5 }
    end
    self.performance.total_resolved = 0
    self.performance.best_source = "supreme"
    
    
    self.config.weights = {
        neural = 0.30,
        advanced = 0.25,
        base = 0.20,
        legacy = 0.15,
        gamesense = 0.10,
    }
end






client.set_event_callback("player_connect_full", function()
    pcall(function()
        resolver_supreme:init()
    end)
end)


client.set_event_callback("aim_fire", function(e)
    local target = e.target
    if target then
        pcall(function()
            resolver_supreme:apply(target)
        end)
    end
end)


client.set_event_callback("aim_hit", function(e)
    local target = e.target
    if target then
        pcall(function()
            resolver_supreme:record_result(target, true, e.hitgroup)
        end)
    end
end)


client.set_event_callback("aim_miss", function(e)
    local target = e.target
    if target then
        pcall(function()
            resolver_supreme:record_result(target, false, nil)
        end)
    end
end)


client.set_event_callback("round_prestart", function()
    
    resolver_supreme:clear_all()
end)


client.set_event_callback("shutdown", function()
    pcall(function()
        resolver_supreme:save_weights()
    end)
end)


client.set_event_callback("player_death", function(e)
    local victim = client.userid_to_entindex(e.userid)
    if victim then
        resolver_supreme:clear_player(victim)
    end
end)




local function get_supreme_resolver_prediction(player)
    return resolver_supreme:resolve(player)
end

local function apply_supreme_resolver(player)
    return resolver_supreme:apply(player)
end




_G.resolver_supreme = resolver_supreme
_G.get_supreme_resolver_prediction = get_supreme_resolver_prediction
_G.apply_supreme_resolver = apply_supreme_resolver




pcall(function()
    resolver_supreme:init()
end)
    local resolver_debug = {
        enabled = true,
        show_panel = true,
        log_to_console = true,
        log_errors = true,
        log_patterns = true,
        detailed_mode = false,
        
        
        last_predictions = {},
        miss_analysis = {},
        
        stats = {
            total_shots = 0, total_hits = 0, total_misses = 0,
            jitter_hits = 0, jitter_misses = 0,
            defensive_hits = 0, defensive_misses = 0,
            combined_hits = 0, combined_misses = 0,
            bruteforce_hits = 0, bruteforce_misses = 0,
            avg_confidence = 0, confidence_samples = 0,
            
            avg_backtrack = 0, backtrack_samples = 0,
            side_correct = 0, side_total = 0,
            high_bt_shots = 0, high_bt_hits = 0,
            pattern_stats = {},
        },
        
        panel = {
            alpha = 0, scale = 0, offset_y = -30, drag = nil,
            lines = {}, max_lines = 6,
            line_fade_duration = 2.0,
            blur_alpha = 0,
            prev_enabled = false,
            line_alphas = {},
            
            detailed_scroll = 0,
            detailed_max_lines = 12,
        },
        
        source_names = {
            jitter = "Jitter",
            defensive = "Defensive", 
            combined = "Combined",
            unknown = "Unknown",
        },
        
        source_colors = {
            jitter = {100, 160, 255},
            defensive = {255, 120, 160},
            combined = {120, 220, 140},
            unknown = {130, 130, 130},
        },
        
        
        detailed_history = {
            predictions = {},
            results = {},
            max_entries = 50,
        },
        
        init = function(self)
            if not self.panel.drag then
                self.panel.drag = draggable:new("resolver_debug", 20, y / 2 - 120)
            end
        end,
        
        is_enabled = function(self)
            if menu and menu.visuals and menu.visuals.resolverdebug then
                return menu.visuals.resolverdebug:get()
            end
            return false
        end,
        
        
        is_detailed = function(self)
            if menu and menu.visuals and menu.visuals.resolverdetailed then
                self.detailed_mode = menu.visuals.resolverdetailed:get()
                return self.detailed_mode
            end
            return self.detailed_mode
        end,
        
        get_pretty_source = function(self, source)
            return self.source_names[source] or source or "Unknown"
        end,
        
        get_source_color = function(self, source)
            return self.source_colors[source] or {130, 130, 130}
        end,
        
        log = function(self, category, message, r, g, b)
            if not self.enabled or not self.log_to_console then return end
            console_print_segments(
                {150, 150, 150, "[Resolver:"}, 
                {r or 200, g or 200, b or 200, category}, 
                {150, 150, 150, "] "}, 
                {r or 255, g or 255, b or 255, message}
            )
        end,
        
        
        log_detailed = function(self, category, message, data, r, g, b)
            if not self.enabled or not self.log_to_console then return end
            if not self:is_detailed() then return end
            
            local detail_str = ""
            if data then
                local parts = {}
                for k, v in pairs(data) do
                    if type(v) == "number" then
                        table.insert(parts, string.format("%s=%.2f", k, v))
                    elseif type(v) == "boolean" then
                        table.insert(parts, string.format("%s=%s", k, v and "Y" or "N"))
                    elseif type(v) == "string" then
                        table.insert(parts, string.format("%s=%s", k, v))
                    end
                end
                detail_str = " [" .. table.concat(parts, ", ") .. "]"
            end
            
            console_print_segments(
                {150, 150, 150, "[Resolver:"},
                {r or 200, g or 200, b or 200, category},
                {150, 150, 150, "] "},
                {r or 255, g or 255, b or 255, message},
                {120, 120, 120, detail_str}
            )
        end,
        
        
        log_apply = function(self, weapon_type, side, body_offset, conf, source, override)
            if not self.enabled then return end
            
            local synergy_str = ""
            if source == "combined" and override and override.synergy_score then
                synergy_str = string.format(" sync=%.0f%%", override.synergy_score * 100)
            end
            self:log("APPLY", string.format("[%s] side=%d body=%d conf=%.2f%s", 
                weapon_type, side, body_offset, conf, synergy_str), 100, 255, 150)
        end,
        
        
        log_skip_confidence = function(self, bt, conf, required_conf, weapon_type)
            if not self.enabled then return end
            self:log("SKIP", string.format("BT=%d conf=%.2f < required=%.2f [%s]", bt, conf, required_conf, weapon_type), 255, 150, 100)
        end,
        
        
        log_skip_high_bt = function(self, bt)
            if not self.enabled then return end
            self:log("SKIP", string.format("BT=%d - TOO HIGH, skipping resolver", bt), 255, 100, 100)
        end,
        
        
        log_synergy = function(self, override)
            if not self.enabled or not override then return end
            if not self:is_detailed() then return end
            
            self:log_detailed("SYNERGY", 
                string.format("agree=%.0f%% sync=%.0f%% jit_w=%.0f%% def_w=%.0f%%",
                    (override.agreement_level or 0) * 100,
                    (override.synergy_score or 0) * 100,
                    (override.jitter_weight or 0) * 100,
                    (override.defensive_weight or 0) * 100),
                {
                    jit_rel = override.jitter_reliability,
                    def_rel = override.defensive_reliability,
                }, 150, 200, 255)
        end,
        
        add_line = function(self, text, r, g, b, is_hit)
            if not self.show_panel then return end
            local max = self:is_detailed() and self.panel.detailed_max_lines or self.panel.max_lines
            table.insert(self.panel.lines, 1, {
                text = text, 
                r = r or 255, 
                g = g or 255, 
                b = b or 255, 
                time = globals.realtime(), 
                alpha = 0,
                is_hit = is_hit,
                slide_offset = 20,
            })
            while #self.panel.lines > max do table.remove(self.panel.lines) end
        end,
        
        
        add_detailed_line = function(self, text, subtext, r, g, b, is_hit)
            if not self.show_panel then return end
            if not self:is_detailed() then
                self:add_line(text, r, g, b, is_hit)
                return
            end
            
            table.insert(self.panel.lines, 1, {
                text = text,
                subtext = subtext,
                r = r or 255, 
                g = g or 255, 
                b = b or 255, 
                time = globals.realtime(), 
                alpha = 0,
                is_hit = is_hit,
                slide_offset = 20,
                is_detailed = true,
            })
            while #self.panel.lines > self.panel.detailed_max_lines do table.remove(self.panel.lines) end
        end,
        
        
        log_prediction = function(self, player, source, data)
            if not self:is_enabled() then return end
            
            local player_id = tostring(player)
            local name = entity.get_player_name(player) or "Unknown"
            
            
            local ping_info = ""
            if resolver.jitter and resolver.jitter.ping_compensation then
                local comp = resolver.jitter.ping_compensation:get_adaptive_compensation(player_id)
                if comp then
                    ping_info = string.format(" ping=%dt jitter=%.1ft", comp.ping_ticks, comp.jitter_ticks)
                end
            end
            
            
            local side = data.predicted_side or 0
            local body = data.body_adjustment or 0
            local conf = data.confidence or 0
            local bf = data.bruteforce_active and "Y" or "N"
            local state = data.resolver_state or "normal"
            local pattern = data.side_pattern or data.pattern or "?"
            
            local msg = string.format("%s | src=%s conf=%.2f side=%d body=%d bf=%s state=%s%s", 
                name, source, conf, side, body, bf, state, ping_info)
            
            self:log("PREDICT", msg, 180, 180, 255)
            
            local prediction_entry = {
                time = globals.realtime(), 
                source = source, 
                predicted_side = data.predicted_side, 
                confidence = data.confidence, 
                bruteforce = data.bruteforce_active,
                pattern = data.pattern,
                side_pattern = data.side_pattern,
                body_mode = data.body_mode,
                resolver_state = data.resolver_state,
                yaw_is_random = data.yaw_is_random,
                backtrack = data.backtrack,
                body_adjustment = data.body_adjustment,
                player_name = player_name,
            }
            
            self.last_predictions[tostring(player)] = prediction_entry
            
            
            table.insert(self.detailed_history.predictions, 1, prediction_entry)
            while #self.detailed_history.predictions > self.detailed_history.max_entries do
                table.remove(self.detailed_history.predictions)
            end
            
            self.stats.confidence_samples = self.stats.confidence_samples + 1
            self.stats.avg_confidence = self.stats.avg_confidence + (data.confidence - self.stats.avg_confidence) / self.stats.confidence_samples
            
            
            if data.backtrack then
                self.stats.backtrack_samples = self.stats.backtrack_samples + 1
                self.stats.avg_backtrack = self.stats.avg_backtrack + (data.backtrack - self.stats.avg_backtrack) / self.stats.backtrack_samples
                if data.backtrack >= 10 then
                    self.stats.high_bt_shots = self.stats.high_bt_shots + 1
                end
            end
            
            
            if data.side_pattern then
                self.stats.pattern_stats[data.side_pattern] = self.stats.pattern_stats[data.side_pattern] or {hits = 0, misses = 0}
            end
            
            local sc = self:get_source_color(source)
            local side_str = (data.predicted_side or 0) == 1 and "1" or "0"
            local bf_str = data.bruteforce_active and "Y" or "N"
            local conf_pct = string.format("%.2f", data.confidence or 0)
            local body_str = tostring(data.body_adjustment or 0)
            local state_str = data.resolver_state or "?"
            local bt_str = tostring(data.backtrack or 0)
            
            
            if self:is_detailed() then
                self:log_detailed("PREDICT", string.format("%s | src=%s conf=%s side=%s body=%s bt=%s bf=%s state=%s", 
                    player_name, source, conf_pct, side_str, body_str, bt_str, bf_str, state_str), {
                    pattern = data.pattern,
                    side_pat = data.side_pattern,
                    body_mode = data.body_mode,
                    random = data.yaw_is_random,
                }, sc[1], sc[2], sc[3])
            else
                self:log("PREDICT", string.format("%s | src=%s conf=%s side=%s body=%s bf=%s state=%s", 
                    player_name, source, conf_pct, side_str, body_str, bf_str, state_str), sc[1], sc[2], sc[3])
            end
            
            
            if self.log_patterns and (data.pattern or data.side_pattern or data.body_mode) then
                local pattern_str = string.format("yaw=%s side=%s body=%s random=%s",
                    data.pattern or "?",
                    data.side_pattern or "?", 
                    data.body_mode or "?",
                    data.yaw_is_random and "Y" or "N"
                )
                self:log("PATTERN", pattern_str, 180, 180, 255)
            end
            
            
            if self:is_detailed() then
                local main_text = string.format("%s %.0f%% s%d", self:get_pretty_source(source), (data.confidence or 0) * 100, data.predicted_side or 0)
                local sub_text = string.format("bt:%d body:%d %s", data.backtrack or 0, data.body_adjustment or 0, data.bruteforce_active and "BF" or "")
                self:add_detailed_line(main_text, sub_text, sc[1], sc[2], sc[3], nil)
            else
                local panel_text = string.format("%s %.0f%%", self:get_pretty_source(source), (data.confidence or 0) * 100)
                if data.bruteforce_active then panel_text = panel_text .. " BF" end
                self:add_line(panel_text, sc[1], sc[2], sc[3], nil)
            end
        end,
        
        
        log_result = function(self, player, hit, source, prediction)
            if not self.enabled then return end
            
            local player_name = entity.get_player_name(player) or "?"
            player_name = player_name:sub(1, 10)
            
            self.stats.total_shots = self.stats.total_shots + 1
            
            local pretty_name = self:get_pretty_source(source)
            local conf = prediction and prediction.confidence or 0
            local conf_pct = string.format("%.2f", conf)
            local bf_str = prediction and prediction.bruteforce and "Y" or "N"
            local side_str = prediction and tostring(prediction.predicted_side or "?") or "?"
            local body_str = prediction and tostring(prediction.body_adjustment or prediction.predicted_body or 0) or "?"
            local bt_str = prediction and tostring(prediction.backtrack or 0) or "?"
            
            
            local result_entry = {
                time = globals.realtime(),
                player_name = player_name,
                hit = hit,
                source = source,
                prediction = prediction,
            }
            table.insert(self.detailed_history.results, 1, result_entry)
            while #self.detailed_history.results > self.detailed_history.max_entries do
                table.remove(self.detailed_history.results)
            end
            
            
            if prediction and prediction.predicted_side ~= nil then
                self.stats.side_total = self.stats.side_total + 1
                if hit then
                    self.stats.side_correct = self.stats.side_correct + 1
                end
            end
            
            
            if prediction and prediction.backtrack and prediction.backtrack >= 10 then
                if hit then
                    self.stats.high_bt_hits = self.stats.high_bt_hits + 1
                end
            end
            
            
            if prediction and prediction.side_pattern then
                local ps = self.stats.pattern_stats[prediction.side_pattern]
                if ps then
                    if hit then ps.hits = ps.hits + 1
                    else ps.misses = ps.misses + 1 end
                end
            end
            
            if hit then
                self.stats.total_hits = self.stats.total_hits + 1
                if source == "jitter" then self.stats.jitter_hits = self.stats.jitter_hits + 1
                elseif source == "defensive" then self.stats.defensive_hits = self.stats.defensive_hits + 1
                elseif source == "combined" then self.stats.combined_hits = self.stats.combined_hits + 1 end
                if prediction and prediction.bruteforce then self.stats.bruteforce_hits = self.stats.bruteforce_hits + 1 end
                
                
                if self:is_detailed() then
                    self:log_detailed("HIT", string.format("%s | src=%s conf=%s side=%s body=%s bt=%s", 
                        player_name, source or "?", conf_pct, side_str, body_str, bt_str), {
                        pattern = prediction and prediction.side_pattern,
                        state = prediction and prediction.resolver_state,
                    }, 100, 255, 130)
                else
                    self:log("HIT", string.format("%s | src=%s conf=%s side=%s body=%s", 
                        player_name, source or "?", conf_pct, side_str, body_str), 100, 255, 130)
                end
                
                if self:is_detailed() then
                    local main_text = string.format("HIT %s %.0f%%", pretty_name, conf * 100)
                    local sub_text = string.format("s%s bt:%s body:%s", side_str, bt_str, body_str)
                    self:add_detailed_line(main_text, sub_text, 100, 255, 130, true)
                else
                    self:add_line(string.format("HIT %s %.0f%%", pretty_name, conf * 100), 100, 255, 130, true)
                end
            else
                self.stats.total_misses = self.stats.total_misses + 1
                if source == "jitter" then self.stats.jitter_misses = self.stats.jitter_misses + 1
                elseif source == "defensive" then self.stats.defensive_misses = self.stats.defensive_misses + 1
                elseif source == "combined" then self.stats.combined_misses = self.stats.combined_misses + 1 end
                if prediction and prediction.bruteforce then self.stats.bruteforce_misses = self.stats.bruteforce_misses + 1 end
                
                
                if self:is_detailed() then
                    self:log_detailed("MISS", string.format("%s | src=%s conf=%s side=%s body=%s bt=%s bf=%s", 
                        player_name, source or "?", conf_pct, side_str, body_str, bt_str, bf_str), {
                        pattern = prediction and prediction.side_pattern,
                        state = prediction and prediction.resolver_state,
                        random = prediction and prediction.yaw_is_random,
                    }, 255, 100, 100)
                else
                    self:log("MISS", string.format("%s | src=%s conf=%s side=%s body=%s bf=%s", 
                        player_name, source or "?", conf_pct, side_str, body_str, bf_str), 255, 100, 100)
                end
                
                if self:is_detailed() then
                    local main_text = string.format("MISS %s %.0f%%", pretty_name, conf * 100)
                    local sub_text = string.format("s%s bt:%s body:%s %s", side_str, bt_str, body_str, bf_str == "Y" and "BF" or "")
                    self:add_detailed_line(main_text, sub_text, 255, 100, 100, false)
                else
                    self:add_line(string.format("MISS %s %.0f%%", pretty_name, conf * 100), 255, 100, 100, false)
                end
                
                
                if self.log_errors then
                    self:analyze_miss(player, source, prediction)
                end
            end
        end,
        
        
        analyze_miss = function(self, player, source, prediction)
            if not self.log_errors then return end
            
            local player_id = tostring(player)
            local analysis = {}
            
            
            if prediction and prediction.backtrack then
                if prediction.backtrack > 20 then
                    table.insert(analysis, string.format("CRITICAL BT: %d - PREDICTION INVALID", prediction.backtrack))
                elseif prediction.backtrack > 12 then
                    table.insert(analysis, string.format("VERY HIGH BT: %d - DATA STALE", prediction.backtrack))
                elseif prediction.backtrack > 8 then
                    table.insert(analysis, string.format("HIGH BT: %d", prediction.backtrack))
                end
            end
            
            local jit_data = resolver.jitter and resolver.jitter.players[player_id]
            local def_data = resolver.defensive and resolver.defensive.players[player_id]
            
            if prediction and prediction.predicted_side ~= nil then
                local actual_side = nil
                if jit_data and jit_data.current_side ~= nil then
                    actual_side = jit_data.current_side
                end
                
                if actual_side ~= nil and actual_side ~= prediction.predicted_side then
                    table.insert(analysis, string.format("SIDE WRONG: pred=%d actual=%d", prediction.predicted_side, actual_side))
                end
            end
            
            if prediction and prediction.predicted_yaw and jit_data and jit_data.last_yaw then
                local yaw_error = math.abs(func.aa_clamp(prediction.predicted_yaw - jit_data.last_yaw))
                if yaw_error > 30 then
                    table.insert(analysis, string.format("YAW ERROR: %.1f°", yaw_error))
                end
            end
            
            if prediction then
                if prediction.pattern then
                    table.insert(analysis, string.format("pattern=%s", prediction.pattern))
                end
                if prediction.side_pattern then
                    table.insert(analysis, string.format("side_pat=%s", prediction.side_pattern))
                end
            end
            
            if jit_data and jit_data.delay_variance then
                if jit_data.delay_variance > 5 then
                    table.insert(analysis, string.format("DELAY VAR: %.1f", jit_data.delay_variance))
                end
            end
            
            if jit_data and jit_data.yaw_samples then
                local sample_count = #jit_data.yaw_samples
                if sample_count < 10 then
                    table.insert(analysis, string.format("LOW SAMPLES: %d", sample_count))
                else
                    table.insert(analysis, string.format("samples=%d", sample_count))
                end
            end
            
            if prediction and prediction.yaw_is_random then
                table.insert(analysis, "YAW RANDOM")
            end
            if def_data and def_data.pitch_is_random then
                table.insert(analysis, "PITCH RANDOM")
            end
            
            if prediction and prediction.bruteforce then
                table.insert(analysis, "BRUTEFORCE ACTIVE")
            end
            
            if jit_data and jit_data.consecutive_misses and jit_data.consecutive_misses >= 2 then
                table.insert(analysis, string.format("CONSEC MISS: %d", jit_data.consecutive_misses))
            end
            
            if jit_data and jit_data.high_backtrack_penalty and jit_data.high_backtrack_penalty > 0.1 then
                table.insert(analysis, string.format("BT PENALTY: %.0f%%", jit_data.high_backtrack_penalty * 100))
            end
            
            if jit_data and jit_data.resolver_state then
                if jit_data.resolver_state == "bruteforce" then
                    table.insert(analysis, "STATE: BRUTEFORCE")
                elseif jit_data.resolver_state == "learning" then
                    table.insert(analysis, "STATE: LEARNING")
                end
            end
            
            
            if #analysis > 0 then
                local analysis_str = table.concat(analysis, " | ")
                self:log("ANALYSIS", analysis_str, 255, 200, 100)
            else
                self:log("ANALYSIS", "No clear cause identified", 200, 200, 200)
            end
            
            table.insert(self.miss_analysis, {
                time = globals.realtime(),
                player = player_id,
                source = source,
                prediction = prediction,
                analysis = analysis
            })
            
            while #self.miss_analysis > 50 do
                table.remove(self.miss_analysis, 1)
            end
        end,
        
        get_hit_rate = function(self) return self.stats.total_shots == 0 and 0 or self.stats.total_hits / self.stats.total_shots end,
        
        get_source_rates = function(self)
            local jt, dt, ct = self.stats.jitter_hits + self.stats.jitter_misses, self.stats.defensive_hits + self.stats.defensive_misses, self.stats.combined_hits + self.stats.combined_misses
            return {jitter = jt > 0 and self.stats.jitter_hits/jt or 0, defensive = dt > 0 and self.stats.defensive_hits/dt or 0, combined = ct > 0 and self.stats.combined_hits/ct or 0}
        end,
        
        
        get_detailed_stats = function(self)
            return {
                side_accuracy = self.stats.side_total > 0 and self.stats.side_correct / self.stats.side_total or 0,
                avg_backtrack = self.stats.avg_backtrack,
                high_bt_rate = self.stats.high_bt_shots > 0 and self.stats.high_bt_hits / self.stats.high_bt_shots or 0,
                pattern_stats = self.stats.pattern_stats,
            }
        end,
        
        
        render = function(self)
            local is_enabled = self:is_enabled()
            local is_detailed = self:is_detailed()
            self.enabled = is_enabled
            self.show_panel = is_enabled
            
            self.panel.alpha = self.panel.alpha + ((is_enabled and 1 or 0) - self.panel.alpha) * 0.06
            if self.panel.alpha < 0.01 then
                self.panel.scale, self.panel.offset_y = 0, -30
                return
            end
            
            if is_enabled ~= self.panel.prev_enabled then
                self.panel.prev_enabled = is_enabled
                if is_enabled then
                    self.panel.scale, self.panel.offset_y = 0, -30
                end
            end
            
            self.panel.scale = self.panel.scale + ((is_enabled and 1 or 0) - self.panel.scale) * 0.08
            self.panel.offset_y = self.panel.offset_y + ((is_enabled and 0 or -30) - self.panel.offset_y) * 0.12
            
            self:init()
            local me = entity.get_local_player()
            if not me or not entity.is_alive(me) then return end
            
            local screen_w, screen_h = client.screen_size()
            local padding = 14
            local line_height = is_detailed and 28 or 20
            local rounding = 8
            
            local r1, g1, b1 = menu.visuals.accentcolor:get()
            local r2, g2, b2 = 216, 149, 186
            local t = globals.realtime() * 2
            
            local hit_rate = self:get_hit_rate()
            local rates = self:get_source_rates()
            local max_lines = is_detailed and self.panel.detailed_max_lines or self.panel.max_lines
            local log_lines = math.min(#self.panel.lines, max_lines)
            
            
            local box_width = is_detailed and 220 or 180
            local stats_height = is_detailed and 90 or 45
            local box_height = padding * 2 + 32 + stats_height + log_lines * line_height + (log_lines > 0 and 12 or 0)
            if log_lines == 0 then box_height = padding * 2 + 32 + stats_height + 20 end
            
            self.panel.drag:drag(box_width, box_height)
            local box_x, box_y = self.panel.drag:get()
            
            local scale_current = self.panel.scale * self.panel.alpha
            local offset_current = self.panel.offset_y * scale_current
            
            if scale_current < 0.01 then return end
            
            local center_x = box_x + box_width / 2
            local center_y = box_y + box_height / 2
            local scaled_w = box_width * scale_current
            local scaled_h = box_height * scale_current
            local render_x = math.floor(center_x - scaled_w / 2)
            local render_y = math.floor(center_y - scaled_h / 2 + offset_current)
            local scaled_r = math.max(1, math.floor(rounding * scale_current))

            local global_alpha = self.panel.alpha * 255
            local bg_alpha = math.floor(100 * self.panel.alpha)
            local border_alpha = math.floor(75 * self.panel.alpha)

            renderer.blur(render_x, render_y, math.floor(scaled_w), math.floor(scaled_h))
            func.rec(render_x, render_y, math.floor(scaled_w), math.floor(scaled_h), scaled_r, {25, 25, 25, bg_alpha})
            
            local grad_h = 2
            local wave1 = math.sin(t * 0.5) * 0.5 + 0.5
            local grad_r = math.floor(r1 + (r2 - r1) * wave1)
            local grad_g = math.floor(g1 + (g2 - g1) * wave1)
            local grad_b = math.floor(b1 + (b2 - b1) * wave1)
            
            renderer.gradient(render_x + scaled_r, render_y, math.floor((scaled_w - scaled_r * 2) / 2), grad_h, 
                0, 0, 0, 0, grad_r, grad_g, grad_b, math.floor(global_alpha), true)
            renderer.gradient(render_x + math.floor(scaled_w / 2), render_y, math.floor((scaled_w - scaled_r * 2) / 2), grad_h, 
                grad_r, grad_g, grad_b, math.floor(global_alpha), 0, 0, 0, 0, true)

            renderer.circle_outline(render_x + scaled_r, render_y + scaled_r, 150, 150, 150, math.floor(border_alpha * 0.5), scaled_r, 180, 0.25, 1)
            renderer.rectangle(render_x + scaled_r, render_y, math.floor(scaled_w - scaled_r * 2), 1, 150, 150, 150, math.floor(border_alpha * 0.5))
            renderer.circle_outline(render_x + math.floor(scaled_w) - scaled_r, render_y + scaled_r, 150, 150, 150, math.floor(border_alpha * 0.5), scaled_r, 270, 0.25, 1)

            
            local title = is_detailed and "Resolver [D]" or "Resolver"
            local title_w = renderer.measure_text("b", title)
            local title_x = render_x + math.floor((scaled_w - title_w * scale_current) / 2)
            local title_y = render_y + math.floor(padding * scale_current)
            
            local title_text = {}
            for i = 1, #title do
                local char = title:sub(i, i)
                local char_wave = math.sin(t + i * 0.4) * 0.5 + 0.5
                local cr = math.floor(r1 + (r2 - r1) * char_wave)
                local cg = math.floor(g1 + (g2 - g1) * char_wave)
                local cb = math.floor(b1 + (b2 - b1) * char_wave)
                table.insert(title_text, string.format("\a%02x%02x%02xff%s", cr, cg, cb, char))
            end
            renderer.text(math.floor(title_x), math.floor(title_y), 255, 255, 255, math.floor(global_alpha), "b", nil, table.concat(title_text))

            local sep_y = math.floor(title_y + 18 * scale_current)
            renderer.gradient(render_x + math.floor(padding * scale_current), sep_y, math.floor((scaled_w - padding * 2 * scale_current) / 2), 1, 
                0, 0, 0, 0, 80, 80, 80, math.floor(border_alpha), true)
            renderer.gradient(render_x + math.floor(scaled_w / 2), sep_y, math.floor((scaled_w - padding * 2 * scale_current) / 2), 1, 
                80, 80, 80, math.floor(border_alpha), 0, 0, 0, 0, true)

            local content_y = sep_y + math.floor(10 * scale_current)
            local stats_y = content_y
            local bar_x = render_x + math.floor(padding * scale_current)
            local bar_w = math.floor(scaled_w - padding * 2 * scale_current)
            local bar_h = math.floor(8 * scale_current)
            
            func.rec(bar_x, stats_y, bar_w, bar_h, math.floor(4 * scale_current), {40, 40, 40, math.floor(global_alpha * 0.8)})
            
            local fill_w = math.floor(bar_w * math.min(1, hit_rate))
            if fill_w > 2 then
                local rate_r, rate_g, rate_b
                if hit_rate >= 0.6 then
                    rate_r, rate_g, rate_b = 100, 220, 130
                elseif hit_rate >= 0.4 then
                    rate_r, rate_g, rate_b = 220, 200, 100
                else
                    rate_r, rate_g, rate_b = 220, 100, 100
                end
                func.rec(bar_x, stats_y, fill_w, bar_h, math.floor(4 * scale_current), {rate_r, rate_g, rate_b, math.floor(global_alpha * 0.9)})
            end
            
            local rate_text = string.format("%.0f%% (%d/%d)", hit_rate * 100, self.stats.total_hits, self.stats.total_shots)
            local rate_text_y = stats_y + math.floor(12 * scale_current)
            renderer.text(bar_x, math.floor(rate_text_y), 180, 180, 180, math.floor(global_alpha * 0.9), "", nil, "Hit Rate")
            renderer.text(bar_x + bar_w, math.floor(rate_text_y), 255, 255, 255, math.floor(global_alpha), "r", nil, rate_text)
            
            local source_y = rate_text_y + math.floor(18 * scale_current)
            
            local sources = {
                {name = " J", rate = rates.jitter, color = self.source_colors.jitter},
                {name = " D", rate = rates.defensive, color = self.source_colors.defensive},
                {name = " C", rate = rates.combined, color = self.source_colors.combined},
            }
            
            local total_text_width = 0
            local source_texts = {}
            local source_gap = math.floor(12 * scale_current)
            
            for i, src in ipairs(sources) do
                local src_text = string.format("%s:%.0f%%", src.name, src.rate * 100)
                local text_w = renderer.measure_text("", src_text)
                table.insert(source_texts, {text = src_text, width = text_w, color = src.color})
                total_text_width = total_text_width + text_w
                if i < #sources then
                    total_text_width = total_text_width + source_gap
                end
            end
            
            local start_x = render_x + math.floor((scaled_w - total_text_width) / 2)
            local current_x = start_x
            
            for i, src_data in ipairs(source_texts) do
                renderer.text(math.floor(current_x), math.floor(source_y), src_data.color[1], src_data.color[2], src_data.color[3], math.floor(global_alpha * 0.85), "", nil, src_data.text)
                current_x = current_x + src_data.width + source_gap
            end
            
            
            local extra_stats_y = source_y
            if is_detailed then
                extra_stats_y = source_y + math.floor(18 * scale_current)
                
                local detailed_stats = self:get_detailed_stats()
                
                
                local side_text = string.format("Side: %.0f%%", detailed_stats.side_accuracy * 100)
                renderer.text(bar_x, math.floor(extra_stats_y), 140, 140, 140, math.floor(global_alpha * 0.8), "", nil, side_text)
                
                
                local bt_text = string.format("Avg BT: %.1f", detailed_stats.avg_backtrack)
                renderer.text(bar_x + bar_w, math.floor(extra_stats_y), 140, 140, 140, math.floor(global_alpha * 0.8), "r", nil, bt_text)
                
                extra_stats_y = extra_stats_y + math.floor(14 * scale_current)
                
                
                local high_bt_text = string.format("High BT: %.0f%%", detailed_stats.high_bt_rate * 100)
                renderer.text(bar_x, math.floor(extra_stats_y), 140, 140, 140, math.floor(global_alpha * 0.8), "", nil, high_bt_text)
                
                
                local conf_text = string.format("Conf: %.0f%%", self.stats.avg_confidence * 100)
                renderer.text(bar_x + bar_w, math.floor(extra_stats_y), 140, 140, 140, math.floor(global_alpha * 0.8), "r", nil, conf_text)
            end
            
            local sep2_y = extra_stats_y + math.floor(16 * scale_current)
            renderer.gradient(render_x + math.floor(padding * scale_current), sep2_y, math.floor((scaled_w - padding * 2 * scale_current) / 2), 1, 
                0, 0, 0, 0, 60, 60, 60, math.floor(border_alpha * 0.7), true)
            renderer.gradient(render_x + math.floor(scaled_w / 2), sep2_y, math.floor((scaled_w - padding * 2 * scale_current) / 2), 1, 
                60, 60, 60, math.floor(border_alpha * 0.7), 0, 0, 0, 0, true)
            
            local now = globals.realtime()
            local log_start_y = sep2_y + math.floor(8 * scale_current)
            local lines_to_remove = {}
            
            if #self.panel.lines == 0 then
                local empty_msg = "waiting for events..."
                local msg_w = renderer.measure_text("", empty_msg)
                local msg_x = render_x + math.floor((scaled_w - msg_w) / 2)
                renderer.text(math.floor(msg_x), math.floor(log_start_y), 70, 70, 70, math.floor(global_alpha * 0.55), "", nil, empty_msg)
            else
                for i, line in ipairs(self.panel.lines) do
                    if i > max_lines then break end
                    
                    self.panel.line_alphas[i] = self.panel.line_alphas[i] or 0
                    
                    local age = now - line.time
                    local fade_progress = math.max(0, 1 - age / self.panel.line_fade_duration)
                    
                    local target_alpha = fade_progress * (is_enabled and 1 or 0)
                    self.panel.line_alphas[i] = self.panel.line_alphas[i] + (target_alpha - self.panel.line_alphas[i]) * 0.15
                    
                    line.slide_offset = line.slide_offset or 20
                    line.slide_offset = line.slide_offset + (0 - line.slide_offset) * 0.12
                    
                    if self.panel.line_alphas[i] < 0.02 then
                        table.insert(lines_to_remove, i)
                    else
                        local la = math.floor(global_alpha * self.panel.line_alphas[i] * 0.9)
                        local ly = log_start_y + (i - 1) * line_height * scale_current
                        local lx = bar_x + line.slide_offset
                        
                        local dot_r, dot_g, dot_b = line.r, line.g, line.b
                        renderer.circle(math.floor(lx + 3), math.floor(ly + 8 * scale_current), dot_r, dot_g, dot_b, la, 3)
                        
                        renderer.text(math.floor(lx + 12), math.floor(ly), line.r, line.g, line.b, la, "", nil, line.text)
                        
                        
                        if is_detailed and line.is_detailed and line.subtext then
                            renderer.text(math.floor(lx + 12), math.floor(ly + 12 * scale_current), 100, 100, 100, math.floor(la * 0.7), "", nil, line.subtext)
                        end
                    end
                end
            end
            
            for i = #lines_to_remove, 1, -1 do
                table.remove(self.panel.lines, lines_to_remove[i])
                table.remove(self.panel.line_alphas, lines_to_remove[i])
            end

            func.rec_outline(render_x, render_y, math.floor(scaled_w), math.floor(scaled_h), scaled_r, 1, {60, 60, 60, math.floor(border_alpha * 0.7)})
            
            self.panel.blur_alpha = self.panel.blur_alpha + ((self.panel.drag.dragging and 80 or 0) - self.panel.blur_alpha) * 0.08
            if self.panel.blur_alpha > 0.5 then
                renderer.blur(0, 0, screen_w, screen_h)
                renderer.rectangle(0, 0, screen_w, screen_h, 0, 0, 0, math.floor(self.panel.blur_alpha))
            end
        end,
        
        reset = function(self)
            self.stats = {
                total_shots=0, total_hits=0, total_misses=0, 
                jitter_hits=0, jitter_misses=0, 
                defensive_hits=0, defensive_misses=0, 
                combined_hits=0, combined_misses=0, 
                bruteforce_hits=0, bruteforce_misses=0, 
                avg_confidence=0, confidence_samples=0,
                avg_backtrack=0, backtrack_samples=0,
                side_correct=0, side_total=0,
                high_bt_shots=0, high_bt_hits=0,
                pattern_stats={},
            }
            self.panel.lines = {}
            self.panel.line_alphas = {}
            self.miss_analysis = {}
            self.detailed_history = {predictions = {}, results = {}, max_entries = 50}
        end,
        
        get_suggestions = function(self)
            local s = {}
            local hr = self:get_hit_rate()
            if hr < 0.3 and self.stats.total_shots >= 5 then table.insert(s, "Low hit rate - pattern detection failing") end
            
            
            local detailed_stats = self:get_detailed_stats()
            if detailed_stats.side_accuracy < 0.4 and self.stats.side_total >= 5 then
                table.insert(s, "Side prediction accuracy low - timing analysis issues")
            end
            if detailed_stats.avg_backtrack > 12 then
                table.insert(s, "High average backtrack - predictions becoming stale")
            end
            if detailed_stats.high_bt_rate < 0.2 and self.stats.high_bt_shots >= 3 then
                table.insert(s, "Very low high-BT hit rate - avoid high backtrack shots")
            end
            
            local miss_reasons = {}
            for _, ma in ipairs(self.miss_analysis) do
                for _, reason in ipairs(ma.analysis or {}) do
                    local key = reason:match("^([A-Z ]+):")
                    if key then
                        miss_reasons[key] = (miss_reasons[key] or 0) + 1
                    end
                end
            end
            
            if miss_reasons["SIDE WRONG"] and miss_reasons["SIDE WRONG"] >= 3 then
                table.insert(s, "Side prediction failing - need better timing analysis")
            end
            if miss_reasons["HIGH BT"] and miss_reasons["HIGH BT"] >= 2 then
                table.insert(s, "High backtrack causing stale predictions")
            end
            if miss_reasons["YAW ERROR"] and miss_reasons["YAW ERROR"] >= 2 then
                table.insert(s, "Yaw prediction off - jitter pattern not detected")
            end
            
            
            for pattern, stats in pairs(self.stats.pattern_stats) do
                local total = stats.hits + stats.misses
                if total >= 3 then
                    local rate = stats.hits / total
                    if rate < 0.25 then
                        table.insert(s, string.format("Pattern '%s' has very low success (%.0f%%)", pattern, rate * 100))
                    end
                end
            end
            
            return s
        end,
        
        print_analysis = function(self)
            self:log("STATS", string.format("Overall: %d/%d (%.1f%%)", self.stats.total_hits, self.stats.total_shots, self:get_hit_rate()*100), 255, 255, 100)
            
            local rates = self:get_source_rates()
            self:log("STATS", string.format("Jitter: %.1f%% | Defensive: %.1f%% | Combined: %.1f%%", 
                rates.jitter * 100, rates.defensive * 100, rates.combined * 100), 200, 200, 255)
            
            self:log("STATS", string.format("Avg Confidence: %.1f%%", self.stats.avg_confidence * 100), 200, 255, 200)
            
            
            local detailed_stats = self:get_detailed_stats()
            self:log("DETAILED", string.format("Side Accuracy: %.1f%% | Avg BT: %.1f | High BT Rate: %.1f%%",
                detailed_stats.side_accuracy * 100, detailed_stats.avg_backtrack, detailed_stats.high_bt_rate * 100), 200, 200, 255)
            
            
            if next(self.stats.pattern_stats) then
                self:log("PATTERNS", "Pattern breakdown:", 255, 200, 100)
                for pattern, stats in pairs(self.stats.pattern_stats) do
                    local total = stats.hits + stats.misses
                    if total > 0 then
                        local rate = stats.hits / total
                        self:log("PATTERNS", string.format("  %s: %d/%d (%.0f%%)", pattern, stats.hits, total, rate * 100), 200, 180, 80)
                    end
                end
            end
            
            local miss_reasons = {}
            for _, ma in ipairs(self.miss_analysis) do
                for _, reason in ipairs(ma.analysis or {}) do
                    miss_reasons[reason] = (miss_reasons[reason] or 0) + 1
                end
            end
            
            if next(miss_reasons) then
                self:log("MISS REASONS", "Common causes:", 255, 200, 100)
                local sorted_reasons = {}
                for reason, count in pairs(miss_reasons) do
                    table.insert(sorted_reasons, {reason = reason, count = count})
                end
                table.sort(sorted_reasons, function(a, b) return a.count > b.count end)
                
                for i = 1, math.min(5, #sorted_reasons) do
                    self:log("MISS REASONS", string.format("  %dx - %s", sorted_reasons[i].count, sorted_reasons[i].reason), 255, 180, 80)
                end
            end
        end,
        
        on_round_start = function(self)
            self.last_predictions = {}
            self:add_line("=== ROUND ===", 255, 255, 100)
            self:log("INFO", "Round started - predictions reset", 255, 255, 100)
        end,
    }
    local resolver_apply_source = nil
    local resolver_shot_tracking = {}

    
    client.set_event_callback("aim_fire", function(shot)
        if not resolver.enabled then return end
        if not shot.target then return end
        
        
        apply_weapon_multipoint(shot.target)
        
        
        local backtrack_ticks = math.floor(math.max(0, globals.tickcount() - (shot.tick or globals.tickcount())) + 0.5)
        
        
        if resolver.jitter and resolver.jitter.is_high_backtrack then
            resolver.jitter:is_high_backtrack(shot.target, backtrack_ticks)
        end
        
        
        local preset = resolver.jitter and resolver.jitter.weapon_presets and resolver.jitter.weapon_presets:get_current_preset()
        local weapon_type = preset and preset.name or "Unknown"
        
        local target_health = entity.get_prop(shot.target, "m_iHealth") or 100
        
        
        if preset then
            if preset.prefer_body or target_health <= (preset.force_body_hp_threshold or 0) then
                plist.set(shot.target, "Force body aim", true)
            end
            if preset.force_safe_point or target_health < 50 then
                plist.set(shot.target, "Force safe point", true)
            end
        end

        
        resolver:apply(shot.target)
        
        local player_id = tostring(shot.target)
        
        
        local prediction = nil
        local source = nil
        
        
        local modes = {}
        local use_jitter = true
        local use_defensive = true
        
        if type(modes) == "table" then
            for _, m in ipairs(modes) do
                if m == "Jitter" then use_jitter = true end
                if m == "Defensive" then use_defensive = true end
            end
        end
        
        if use_jitter and use_defensive then
            local jit_override = resolver.jitter:get_override(shot.target)
            local def_override = resolver.defensive:get_override(shot.target)
            
            if jit_override and def_override then
                source = "combined"
                prediction = {
                    predicted_side = jit_override.predicted_side,
                    predicted_yaw = jit_override.predicted_yaw,
                    predicted_body = jit_override.body_adjustment,
                    body_adjustment = jit_override.body_adjustment,
                    confidence = (jit_override.confidence + def_override.confidence) / 2,
                    pattern = jit_override.pattern,
                    side_pattern = jit_override.side_pattern,
                    body_mode = jit_override.body_mode,
                    bruteforce = jit_override.bruteforce_active or def_override.bruteforce_active,
                    resolver_state = jit_override.resolver_state,
                    yaw_is_random = def_override.yaw_is_random,
                    backtrack = backtrack_ticks,
                }
            elseif jit_override then
                source = "jitter"
                prediction = {
                    predicted_side = jit_override.predicted_side,
                    predicted_yaw = jit_override.predicted_yaw,
                    predicted_body = jit_override.body_adjustment,
                    body_adjustment = jit_override.body_adjustment,
                    confidence = jit_override.confidence,
                    pattern = jit_override.pattern,
                    side_pattern = jit_override.side_pattern,
                    body_mode = jit_override.body_mode,
                    bruteforce = jit_override.bruteforce_active,
                    resolver_state = jit_override.resolver_state,
                    backtrack = backtrack_ticks,
                }
            elseif def_override then
                source = "defensive"
                prediction = {
                    predicted_side = def_override.predicted_side,
                    predicted_yaw = def_override.predicted_yaw,
                    predicted_body = def_override.yaw_adjustment,
                    body_adjustment = def_override.yaw_adjustment,
                    confidence = def_override.confidence,
                    bruteforce = def_override.bruteforce_active,
                    yaw_is_random = def_override.yaw_is_random,
                    backtrack = backtrack_ticks,
                }
            end
        elseif use_jitter then
            local jit_override = resolver.jitter:get_override(shot.target)
            if jit_override then
                source = "jitter"
                prediction = {
                    predicted_side = jit_override.predicted_side,
                    predicted_yaw = jit_override.predicted_yaw,
                    predicted_body = jit_override.body_adjustment,
                    body_adjustment = jit_override.body_adjustment,
                    confidence = jit_override.confidence,
                    pattern = jit_override.pattern,
                    side_pattern = jit_override.side_pattern,
                    body_mode = jit_override.body_mode,
                    bruteforce = jit_override.bruteforce_active,
                    resolver_state = jit_override.resolver_state,
                    backtrack = backtrack_ticks,
                }
            end
        elseif use_defensive then
            local def_override = resolver.defensive:get_override(shot.target)
            if def_override then
                source = "defensive"
                prediction = {
                    predicted_side = def_override.predicted_side,
                    predicted_yaw = def_override.predicted_yaw,
                    predicted_body = def_override.yaw_adjustment,
                    body_adjustment = def_override.yaw_adjustment,
                    confidence = def_override.confidence,
                    bruteforce = def_override.bruteforce_active,
                    yaw_is_random = def_override.yaw_is_random,
                    backtrack = backtrack_ticks,
                }
            end
        end
        
        
        if shot.id then
            resolver_shot_tracking[shot.id] = {
                source = source,
                prediction = prediction,
                target = shot.target,
                time = globals.realtime(),
                backtrack = backtrack_ticks,
            }
            
            
            if prediction and source then
                resolver_debug:log_prediction(shot.target, source, prediction)
                
                
                if backtrack_ticks > 10 then
                    resolver_debug:log("WARN", string.format("High backtrack: %d ticks - prediction may be stale", backtrack_ticks), 255, 200, 100)
                end
            end
        end
        
        
        local now = globals.realtime()
        for id, data in pairs(resolver_shot_tracking) do
            if now - data.time > 5.0 then
                resolver_shot_tracking[id] = nil
            end
        end
    end)

    
    client.set_event_callback("aim_hit", function(shot)
        if not resolver.enabled then return end
        if not shot.target then return end
        
        
        local tracking = shot.id and resolver_shot_tracking[shot.id]
        local source = tracking and tracking.source or "unknown"
        local prediction = tracking and tracking.prediction or nil
        
        
        resolver_debug:log_result(shot.target, true, source, prediction)
        
        
        local fl_info = resolver.fakelag:get_override(shot.target)
        local was_choking = fl_info and fl_info.is_choking or false
        
        resolver.jitter:record_result(shot.target, true, shot.hitgroup)
        resolver.defensive:record_result(shot.target, true, shot.hitgroup)
        resolver.fakelag:record_result(shot.target, true, was_choking)
        
        
        if prediction and prediction.body_adjustment then
            resolver:track_body_offset_result(shot.target, prediction.body_adjustment, true)
        end
        
        
        if source == "combined" then
            resolver:record_synergy_result(shot.target, true)
        end
        
        
        if shot.id then
            resolver_shot_tracking[shot.id] = nil
        end
    end)

    
    client.set_event_callback("aim_miss", function(shot)
        if not resolver.enabled then return end
        if not shot.target then return end
        
        
        local tracking = shot.id and resolver_shot_tracking[shot.id]
        local source = tracking and tracking.source or "unknown"
        local prediction = tracking and tracking.prediction or nil
        
        
        resolver_debug:log_result(shot.target, false, source, prediction)
        
        
        local fl_info = resolver.fakelag:get_override(shot.target)
        local was_choking = fl_info and fl_info.is_choking or false
        
        resolver.jitter:record_result(shot.target, false, nil)
        resolver.defensive:record_result(shot.target, false, nil)
        resolver.fakelag:record_result(shot.target, false, was_choking)
        
        
        if prediction and prediction.body_adjustment then
            resolver:track_body_offset_result(shot.target, prediction.body_adjustment, false)
        end
        
        
        if prediction and prediction.predicted_yaw then
            local player_id = tostring(shot.target)
            local jit_data = resolver.jitter.players[player_id]
            if jit_data and jit_data.last_yaw then
                resolver:check_yaw_error_inversion(shot.target, prediction.predicted_yaw, jit_data.last_yaw)
            end
        end
        
        
        if source == "combined" then
            resolver:record_synergy_result(shot.target, false)
        end
        
        
        if shot.id then
            resolver_shot_tracking[shot.id] = nil
        end
    end)

    
    client.set_event_callback("setup_command", function(cmd)
        resolver:update()

        if resolver.enabled then
            local me = entity.get_local_player()
            if me and entity.is_alive(me) then
                for player = 1, globals.maxplayers() do
                    if entity.is_enemy(player) and entity.is_alive(player) and not entity.is_dormant(player) then
                        local target_health = entity.get_prop(player, "m_iHealth") or 100
                        
                        if target_health < 80 then
                            
                            plist.set(player, "Force body aim", true)
                            
                            
                            if target_health < 50 then
                                plist.set(player, "Force safe point", true)
                            end
                        end
                    end
                end
            end
        end
    end)

    client.set_event_callback("paint_ui", function()
        resolver_debug:render()
    end)

    
    client.set_event_callback("round_prestart", function()
        
        resolver_debug.last_predictions = {}
        resolver_debug:add_line("Round Start", 255, 255, 100)
    end)

    
    client.set_event_callback("console_input", function(text)
        if text == "resolver_analysis" then
            resolver_debug:print_analysis()
            return true
        elseif text == "resolver_reset" then
            resolver_debug:reset()
            return true
        elseif text == "resolver_suggestions" then
            local suggestions = resolver_debug:get_suggestions()
            for i, s in ipairs(suggestions) do
                resolver_debug:log("SUGGEST", s, 255, 200, 100)
            end
            return true
        end
    end)