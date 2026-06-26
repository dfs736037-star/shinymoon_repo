local l_pui_0 = require("neverlose/pui");
local l_base64_0 = require("neverlose/base64");
local l_clipboard_0 = require("neverlose/clipboard");
point = "\226\128\162";
local v813 = new_class():struct("string")({
    globals = {
        space_char = "\226\128\138", 
        ZWSP = "\226\128\139"
    }, 
    calculate_padding = function(_, v4)
        local v5 = 0;
        local v6 = 0;
        while v4 >= 6 do
            v5 = v5 + 1;
            v4 = v4 - 3;
        end;
        while v4 >= 4 do
            v6 = v6 + 1;
            v4 = v4 - 2;
        end;
        if v4 == 3 then
            v5 = v5 + 1;
        elseif v4 == 2 then
            v6 = v6 + 1;
        end;
        return v5, v6;
    end, 
    format = function(v7, v8, v9, v10, v11, v12, v13)
        if not v10 then
            v10 = 0;
        end;
        if not v11 then
            v11 = 0;
        end;
        if not v12 then
            v12 = 0;
        end;
        local l_ZWSP_0 = v7.globals.ZWSP;
        local l_space_char_0 = v7.globals.space_char;
        local v16 = 0;
        local v17 = 0;
        local v18 = 0;
        local v19 = 0;
        local v20 = 0;
        local v21 = 0;
        if v10 >= 2 then
            local v22, v23 = v7:calculate_padding(v10);
            v17 = v23;
            v16 = v22;
        end;
        if v11 >= 2 then
            local v24, v25 = v7:calculate_padding(v11);
            v19 = v25;
            v18 = v24;
        end;
        if v12 >= 2 then
            local v26, v27 = v7:calculate_padding(v12);
            v21 = v27;
            v20 = v26;
        end;
        local v28 = "" .. string.rep(l_space_char_0, v16) .. string.rep(l_ZWSP_0, v17);
        if type(v13) == "userdata" then
            v13 = "\a" .. v13:to_hex();
        end;
        if v8 then
            local v29 = not v13 and "\a{Link Active}" or v13;
            local v30 = ui.get_icon(v8);
            if #v30 == 0 then
                v30 = tostring(v8);
            end;
            v28 = v28 .. string.format("%s%s\aDEFAULT", v29, v30);
        end;
        return ((v28 .. string.rep(l_space_char_0, v18) .. string.rep(l_ZWSP_0, v19)) .. (v9 or "")) .. string.rep(l_space_char_0, v20) .. string.rep(l_ZWSP_0, v21);
    end, 
    lerp = function(_, v32, v33, v34)
        return v32[v33]:lerp(v32[v33 + 1], v34);
    end, 
    wave = function(v35, v36, v37, ...)
        local v38 = {};
        local v39 = #v36;
        if v39 < 2 then
            return v36;
        else
            local v40 = {
                ...
            };
            local v41 = 1 / (v39 - 1);
            local v42 = #v40 - 1;
            local v43 = 0;
            for v44 in v36:gmatch(".[\128-\191]*") do
                local v45 = (v37 + v43 * v41) % 2;
                if v45 > 1 then
                    v45 = 2 - v45;
                end;
                local v46 = math.floor(v45 * v42) + 1;
                if #v40 <= v46 then
                    v46 = #v40 - 1;
                end;
                local v47 = v35:lerp(v40, v46, v45 * v42 % 1);
                v38[#v38 + 1] = "\a" .. v47:to_hex();
                v38[#v38 + 1] = v44;
                v43 = v43 + 1;
            end;
            return table.concat(v38);
        end;
    end, 
    animate = function(_, v49, v50, v51, v52)
        if not v52 or v52:gsub(" ", "") == "" then
            return v52;
        else
            local v53 = "";
            local v54 = globals.realtime * v49;
            local v55 = 1;
            local v56 = #v52;
            while v55 <= v56 do
                local v57 = v52:byte(v55);
                if (not (v57 ~= 208) or v57 == 209) and v52:byte(v55 + 1) then
                    local v58 = v52:sub(v55, v55 + 1);
                    local v59 = (math.sin(v54 + v55 / 3) + 1) / 2;
                    v53 = v53 .. "\a" .. v50:lerp(v51, math.clamp(v59, 0, 1)):to_hex() .. v58;
                    v55 = v55 + 2;
                else
                    local v60 = (math.sin(v54 + v55 / 3) + 1) / 2;
                    v53 = v53 .. "\a" .. v50:lerp(v51, math.clamp(v60, 0, 1)):to_hex() .. v52:sub(v55, v55);
                    v55 = v55 + 1;
                end;
            end;
            return v53;
        end;
    end, 
    colored = function(_, ...)
        local v62 = "";
        for _, v64 in pairs({
            ...
        }) do
            local v65 = v64[2];
            local v66 = v64[1];
            v62 = v62 .. "\a" .. v65:to_hex() .. v66;
        end;
        return v62;
    end
}):struct("refs")({
    rage = {
        main = {
            dt = l_pui_0.find("Aimbot", "Ragebot", "Main", "Double Tap"), 
            dt_lag = l_pui_0.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"), 
            hs_lag = l_pui_0.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options"), 
            hs = l_pui_0.find("Aimbot", "Ragebot", "Main", "Hide Shots")
        }
    }, 
    antiaim = {
        enabled = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Enabled"), 
        angles = {
            pitch = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Pitch"), 
            yaw_add = {
                yaw = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "yaw"), 
                offset = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "yaw", "Offset"), 
                base = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "yaw", "Base"), 
                snap = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "yaw", "Hidden"), 
                avoid_backstab = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "yaw", "Avoid Backstab"), 
                roll = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Extended Angles")
            }, 
            modifier = {
                mode = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "yaw Modifier"), 
                offset = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "yaw Modifier", "Offset")
            }, 
            desync = {
                switch = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Body yaw"), 
                left_limit = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Body yaw", "left Limit"), 
                right_limit = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Body yaw", "Right Limit"), 
                tweaks = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Body yaw", "Options"), 
                inverter = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"), 
                freestanding = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding")
            }, 
            freestanding = {
                switch = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Freestanding"), 
                disable_jitter = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Disable yaw Modifiers"), 
                body = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Freestanding", "Body Freestanding")
            }
        }, 
        misc = {
            fake_duck = l_pui_0.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"), 
            slow_walk = l_pui_0.find("Aimbot", "Anti Aim", "Misc", "Slow Walk"), 
            slidewalk_directory = l_pui_0.find("Aimbot", "Anti Aim", "Misc", "Leg Movement")
        }
    }, 
    visuals = {
        zoom_scope = l_pui_0.find("Visuals", "World", "Main", "Override Zoom"), 
        scope_overlay = l_pui_0.find("Visuals", "World", "Main", "Override Zoom", "Scope Overlay")
    }, 
    misc = {
        ping_spike = l_pui_0.find("Miscellaneous", "Main", "Other", "Fake Latency")
    }
}):struct("localplayer")({
    flags = 0, 
    pre_predict_command = function(v67, v68)
        v67.flags = entity.get_local_player().m_fFlags;
        v67.is_in_air = v68.in_jump or bit.band(v67.flags, bit.lshift(1, 0)) == 0;
    end, 
    is_in_duck = function(_, v70)
        return bit.band(v70.m_fFlags, 4) == 4;
    end, 
    side = function(_)
        return rage.antiaim:inverter();
    end, 
    state = function(v72, _)
        local v74 = entity.get_local_player();
        if not v74 or not v74:is_alive() then
            return;
        else
            local v75 = v74.m_vecVelocity:length();
            local v76 = v74.m_iTeamNum == 2 and 1 or 2;
            local v77 = 1;
            if v72.is_in_air then
                v77 = v72:is_in_duck(v74) and 7 or 6;
            elseif v75 > 3 then
                v77 = v72:is_in_duck(v74) and 5 or v72.refs.antiaim.misc.slow_walk:get() and 3 or 2;
            else
                v77 = v72:is_in_duck(v74) and 4 or 1;
            end;
            if v72.antiaim.elements.options_gear.freestanding:get() and v72.antiaim.elements.fs_allowes:get() and v72.refs.antiaim.angles.freestanding.switch:get() then
                v77 = 8;
            end;
            if v72.antiaim.elements.options_gear.manuals:get() ~= "Disabled" then
                v77 = 9;
            end;
            return v77, v76;
        end;
    end, 
    disabler_state = function(v78, _)
        local v80 = entity.get_local_player();
        if not v80 or not v80:is_alive() then
            return;
        else
            local v81 = v80.m_vecVelocity:length();
            local v82 = 1;
            if v78.is_in_air then
                v82 = v78:is_in_duck(v80) and 7 or 6;
            elseif v81 > 3 then
                v82 = v78:is_in_duck(v80) and 5 or v78.refs.antiaim.misc.slow_walk:get() and 3 or 2;
            else
                v82 = v78:is_in_duck(v80) and 4 or 1;
            end;
            return v82;
        end;
    end, 
    init = function(v83)
        events.createmove(function(v84)
            -- upvalues: v83 (ref)
            v83:pre_predict_command(v84);
        end);
    end
}):struct("home")({
    elements = {}, 
    init = function(v85)
        -- upvalues: l_pui_0 (ref)
        if #v85.elements ~= 0 then
            return;
        else
            local v86 = {
                l_pui_0.create(v85.string:format("user", "", 0, 0, 0), "Presets", 1), 
                l_pui_0.create(v85.string:format("user", "", 0, 0, 0), "About user", 2), 
                l_pui_0.create(v85.string:format("user", "", 0, 0, 0), "Socials", 2), 
                l_pui_0.create(v85.string:format("user", "", 0, 0, 0), "Customization", 2)
            };
            v85.elements = {
                user_info = v86[2]:label(v85.string:format("user-check", "Welcome back, \v" .. common.get_username() .. "\r!", 0, 10, 2, "\a{Small Text}")), 
                version = v86[2]:label(v85.string:format("send-back", "Build: \vBeta", 0, 10, 2, "\a{Small Text}")), 
                author = v86[2]:label(v85.string:format("users-rays", "Author script: \vuwuplayer\r \a{Small Text}(crewqx)", 2, 10, 0, "\a{Small Text}")), 
                discord = v86[2]:button(v85.string:format("gears", "Discord", 143, 10, 143, "\a{Small Text}"), function()
                    panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://discord.gg/WJJFJPbuZ5");
                end, true), 
                watermark = v86[4]:label(v85.string:format("layer-plus", "Watermark", 0, 10, 2, "\a{Small Text}")), 
                watermark_gear = {}, 
                crewcfg = v86[3]:button(v85.string:format("gears", "Crewqx Fig", 10, 10, 10, "\a{Small Text}"), function()
                    panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://neverlose.cc/market/item?id=w8hKN5");
                end, true), 
                crewyt = v86[3]:button(v85.string:format("youtube", "Crewqx Youtube", 13, 11, 14, "\a{Small Text}"), function()
                    panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://www.youtube.com/@crewqx");
                end, true), 
                godsense_stable = v86[3]:button(v85.string:format("link", "Godsense", 13, 11, 14, "\a{Small Text}"), function()
                    panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://neverlose.cc/market/item?id=mWvUWf");
                end, true), 
                godsense_beta = v86[3]:button(v85.string:format("lasso-sparkles", "\vGodsense Beta", 13, 11, 13, "\a{Small Text}"), function()
                    panorama.SteamOverlayAPI.OpenExternalBrowserURL("https://neverlose.cc/market/item?id=fsWy2H");
                end, true)
            };
            v85.elements.preset_buttons = {};
            v85.elements.preset_list = v86[1]:list("", {});
            v85.elements.preset_input = v86[1]:input("");
            v85.elements.preset_buttons.hidden_switch = v86[1]:switch(" ", false);
            v85.elements.preset_buttons.hidden_switch:visibility(false);
            v85.elements.preset_buttons.save_switch = v86[1]:switch(" ", false);
            v85.elements.preset_buttons.save_switch:visibility(false);
            local l_hidden_switch_0 = v85.elements.preset_buttons.hidden_switch;
            local l_save_switch_0 = v85.elements.preset_buttons.save_switch;
            v85.elements.preset_buttons.create = v86[1]:button(v85.string:format("layer-plus", "", 8, 8, 0), nil, true, "Create preset"):depend({
                [1] = nil, 
                [2] = false, 
                [1] = l_hidden_switch_0
            }):depend({
                [1] = nil, 
                [2] = false, 
                [1] = l_save_switch_0
            });
            v85.elements.preset_buttons.load = v86[1]:button(v85.string:format("cloud-arrow-down", "", 8, 8, 0), nil, true, "Load preset"):depend({
                [1] = nil, 
                [2] = false, 
                [1] = l_hidden_switch_0
            }):depend({
                [1] = nil, 
                [2] = false, 
                [1] = l_save_switch_0
            });
            v85.elements.preset_buttons.save = v86[1]:button(v85.string:format("floppy-disk", "", 8, 8, 0), function()
                -- upvalues: l_save_switch_0 (ref)
                l_save_switch_0:set(true);
            end, true, "Save preset"):depend({
                [1] = nil, 
                [2] = false, 
                [1] = l_hidden_switch_0
            }):depend({
                [1] = nil, 
                [2] = false, 
                [1] = l_save_switch_0
            });
            v85.elements.preset_buttons.import = v86[1]:button(v85.string:format("file-import", "", 8, 11, 0), nil, true, "Import preset"):depend({
                [1] = nil, 
                [2] = false, 
                [1] = l_hidden_switch_0
            }):depend({
                [1] = nil, 
                [2] = false, 
                [1] = l_save_switch_0
            });
            v85.elements.preset_buttons.export = v86[1]:button(v85.string:format("file-export", "", 12, 8, 0), nil, true, "Export preset"):depend({
                [1] = nil, 
                [2] = false, 
                [1] = l_hidden_switch_0
            }):depend({
                [1] = nil, 
                [2] = false, 
                [1] = l_save_switch_0
            });
            v85.elements.preset_buttons.delete = v86[1]:button(v85.string:format("trash-can", "", 43, 44, 0, "\aF9A19AFF"), function()
                -- upvalues: l_hidden_switch_0 (ref)
                l_hidden_switch_0:set(true);
            end, true, "Delete preset"):depend({
                [1] = nil, 
                [2] = false, 
                [1] = l_hidden_switch_0
            }):depend({
                [1] = nil, 
                [2] = false, 
                [1] = l_save_switch_0
            });
            v85.elements.preset_buttons.delete_confirm = v86[1]:button(v85.string:format("trash-check", "", 85, 86, 0, "\a45ec4aFF"), function()
                -- upvalues: l_hidden_switch_0 (ref)
                l_hidden_switch_0:set(false);
            end, true, "Confirm delete"):depend({
                [1] = nil, 
                [2] = true, 
                [1] = l_hidden_switch_0
            });
            v85.elements.preset_buttons.delete_cancel = v86[1]:button(v85.string:format("trash-xmark", "", 85, 86, 0, "\aF9A19AFF"), function()
                -- upvalues: l_hidden_switch_0 (ref)
                l_hidden_switch_0:set(false);
            end, true, "Cancel delete"):depend({
                [1] = nil, 
                [2] = true, 
                [1] = l_hidden_switch_0
            });
            v85.elements.preset_buttons.save_confirm = v86[1]:button(v85.string:format("check", "", 86, 86, 0, "\a45ec4aFF"), function()
                -- upvalues: l_save_switch_0 (ref)
                l_save_switch_0:set(false);
            end, true, "Confirm save"):depend({
                [1] = nil, 
                [2] = true, 
                [1] = l_save_switch_0
            });
            v85.elements.preset_buttons.save_cancel = v86[1]:button(v85.string:format("xmark", "", 86, 86, 0, "\aF9A19AFF"), function()
                -- upvalues: l_save_switch_0 (ref)
                l_save_switch_0:set(false);
            end, true, "Cancel save"):depend({
                [1] = nil, 
                [2] = true, 
                [1] = l_save_switch_0
            });
            local v89 = v85.elements.watermark:create();
            v85.elements.watermark_gear = {
                pos_x = v89:slider("x", 0, render.screen_size().x, render.screen_size().x / 2):visibility(false), 
                pos_y = v89:slider("y", 0, render.screen_size().y, render.screen_size().y - 20):visibility(false), 
                font = v89:combo(v85.string:format("object-subtract", "Font", 0, 10, 2), {
                    [1] = "Default", 
                    [2] = "Bold", 
                    [3] = "Console", 
                    [4] = "Pixel"
                }), 
                mode = v89:selectable(v85.string:format("layer-plus", "Mods", 0, 10, 2), {
                    [1] = "Rainbow", 
                    [2] = "Encode", 
                    [3] = "Pulse"
                }), 
                input = v89:input(v85.string:format("wand-magic-sparkles", "Text", 0, 10, 2), "godsense"), 
                accent_color = v89:color_picker(v85.string:format("angles-right", "Accent", 0, 10, 2), {
                    Static = {
                        color(255, 255, 255, 255)
                    }, 
                    Gradient = {
                        color(255, 255, 255, 255), 
                        color(255, 255, 255, 50)
                    }
                })
            };
            v85.elements.watermark_gear.accent_color:depend({
                [1] = nil, 
                [2] = "Rainbow", 
                [3] = true, 
                [1] = v85.elements.watermark_gear.mode
            });
            return;
        end;
    end
}):struct("presets")({
    utf8_len = function(_, v91)
        local _, v93 = v91:gsub("[^\128-\193]", "");
        return v93;
    end, 
    clean_name = function(_, v95)
        return (v95:gsub("[%z\001-\031]", ""):gsub("{.-}", ""):match("^%s*(.-)%s*$") or ""):gsub("^DEFAULT", ""):match("^%s*(.-)%s*$") or "";
    end, 
    is_system_preset = function(v96, v97)
        for _, v99 in ipairs(v96.system_presets) do
            if v97 == v99 then
                return true;
            end;
        end;
        return false;
    end, 
    is_separator = function(v100, v101)
        return v101 == v100.separator;
    end, 
    save_database = function(v102)
        db.godsense_recode666 = v102.database;
    end, 
    update = function(v103)
        local v104 = {};
        for v105 in pairs(v103.database) do
            if not v103:is_system_preset(v105) then
                table.insert(v104, v105);
            end;
        end;
        table.sort(v104);
        local v106 = {};
        for _, v108 in ipairs(v103.system_presets) do
            table.insert(v106, v108);
        end;
        if #v104 > 0 then
            table.insert(v106, v103.separator);
        end;
        for _, v110 in ipairs(v104) do
            table.insert(v106, v110);
        end;
        v103.home.elements.preset_list:update(v106);
    end, 
    disabler = function(v111)
        local l_preset_list_0 = v111.home.elements.preset_list;
        local v113 = l_preset_list_0:list()[l_preset_list_0:get()];
        local v114 = v111:is_system_preset(v113 or "");
        local v115 = v111:is_separator(v113 or "");
        local v116 = v114 or v115;
        local l_preset_buttons_0 = v111.home.elements.preset_buttons;
        l_preset_buttons_0.save:disabled(v116);
        l_preset_buttons_0.delete:disabled(v116);
        l_preset_buttons_0.import:disabled(v116);
        l_preset_buttons_0.export:disabled(v116);
        l_preset_buttons_0.load:disabled(v115);
    end, 
    make_setup = function(v118)
        -- upvalues: l_pui_0 (ref)
        local v119 = {};
        local v120 = {
            preset_input = true, 
            preset_list = true, 
            preset_buttons = true, 
            watermark_gear = true
        };
        for v121, v122 in pairs(v118.home.elements) do
            if not v120[v121] then
                v119[v121] = v122;
            end;
        end;
        local v123 = {
            [1] = v119, 
            [2] = v118.antiaim.elements, 
            [3] = v118.misc.elements
        };
        for v124 = 1, 9 do
            if v118.antiaim.data[v124] then
                for v125 = 1, 2 do
                    if v118.antiaim.data[v124][v125] then
                        table.insert(v123, v118.antiaim.data[v124][v125]);
                        if v118.antiaim.data[v124][v125].modifier_options then
                            table.insert(v123, v118.antiaim.data[v124][v125].modifier_options);
                        end;
                        if v118.antiaim.data[v124][v125].body_options then
                            table.insert(v123, v118.antiaim.data[v124][v125].body_options);
                        end;
                        if v118.antiaim.data[v124][v125].yaw_mode_ex then
                            table.insert(v123, v118.antiaim.data[v124][v125].yaw_mode_ex);
                        end;
                    end;
                end;
            end;
        end;
        return l_pui_0.setup(v123, true);
    end, 
    save = function(v126)
        -- upvalues: l_base64_0 (ref)
        local l_preset_list_1 = v126.home.elements.preset_list;
        local v128 = l_preset_list_1:list()[l_preset_list_1:get()];
        if not v128 or v128 == "" then
            common.add_event("Invalid preset name", "ban");
            cvar.playvol:call("ui\\weapon_cant_buy", 1);
            return;
        elseif v126:is_system_preset(v128) then
            common.add_event("Cannot modify system preset", "ban");
            cvar.playvol:call("ui\\weapon_cant_buy", 1);
            return;
        else
            local l_status_0, l_result_0 = pcall(function()
                -- upvalues: v126 (ref), l_base64_0 (ref)
                local v129 = v126:make_setup():save();
                local l_watermark_gear_0 = v126.home.elements.watermark_gear;
                v129.__watermark_x = l_watermark_gear_0.pos_x:get();
                v129.__watermark_y = l_watermark_gear_0.pos_y:get();
                return l_base64_0.encode(msgpack.pack(v129));
            end);
            if not l_status_0 or not l_result_0 then
                common.add_event("Failed to save. (Encode error)", "ban");
                cvar.playvol:call("ui\\weapon_cant_buy", 1);
                return;
            else
                v126.database[v128] = l_result_0;
                v126:save_database();
                common.add_event("Preset saved successfully", "check");
                cvar.playvol:call("ui\\beepclear", 1);
                v126:update();
                local v133 = v126.home.elements.preset_list:list();
                for v134, v135 in ipairs(v133) do
                    if v135 == v128 then
                        v126.home.elements.preset_list:set(v134);
                        break;
                    end;
                end;
                return;
            end;
        end;
    end, 
    load = function(v136)
        -- upvalues: l_base64_0 (ref)
        local l_preset_list_2 = v136.home.elements.preset_list;
        local v138 = l_preset_list_2:list()[l_preset_list_2:get()];
        if not v138 or not v136.database[v138] then
            common.add_event("Failed to load. (Preset not found)", "ban");
            cvar.playvol:call("ui\\weapon_cant_buy", 1);
            return;
        else
            local l_status_1, l_result_1 = pcall(function()
                -- upvalues: v136 (ref), l_base64_0 (ref), v138 (ref)
                local v139 = v136:make_setup();
                local v140 = l_base64_0.decode(v136.database[v138]);
                local v141 = msgpack.unpack(v140);
                local l_watermark_gear_1 = v136.home.elements.watermark_gear;
                if v141 and v141.__watermark_x then
                    l_watermark_gear_1.pos_x:set(v141.__watermark_x);
                    l_watermark_gear_1.pos_y:set(v141.__watermark_y);
                    db.godsense_watermark_x = v141.__watermark_x;
                    db.godsense_watermark_y = v141.__watermark_y;
                else
                    local v143 = render.screen_size();
                    local v144 = l_watermark_gear_1.input:get() or "";
                    local v145 = l_watermark_gear_1.font:get();
                    local v146 = ({
                        Bold = 4, 
                        Default = 1, 
                        Pixel = 2, 
                        Console = 3
                    })[v145] or 1;
                    if v145 == "Pixel" then
                        v144 = v144:upper();
                    end;
                    local v147 = render.measure_text(v146, "c", v144);
                    local v148 = v143.x * 0.5;
                    local v149 = v143.y - v147.y * 0.5 - 8;
                    l_watermark_gear_1.pos_x:set(v148);
                    l_watermark_gear_1.pos_y:set(v149);
                    db.godsense_watermark_x = v148;
                    db.godsense_watermark_y = v149;
                end;
                if v141 then
                    v141.__watermark_x = nil;
                    v141.__watermark_y = nil;
                end;
                v139:load(v141 or {});
            end);
            if not l_status_1 then
                common.add_event("Failed to load. (" .. tostring(l_result_1) .. ")", "ban");
                cvar.playvol:call("ui\\weapon_cant_buy", 1);
                return;
            else
                common.add_event("Preset loaded successfully", "check");
                cvar.playvol:call("ui\\beepclear", 1);
                return;
            end;
        end;
    end, 
    delete = function(v152)
        local l_preset_list_3 = v152.home.elements.preset_list;
        local v154 = l_preset_list_3:list()[l_preset_list_3:get()];
        if not v154 or v154 == "" then
            common.add_event("Invalid selection", "ban");
            cvar.playvol:call("ui\\weapon_cant_buy", 1);
            return;
        elseif v152:is_system_preset(v154) then
            common.add_event("Cannot delete system preset", "ban");
            cvar.playvol:call("ui\\weapon_cant_buy", 1);
            return;
        elseif not v152.database[v154] then
            common.add_event("Preset doesn't exist", "ban");
            cvar.playvol:call("ui\\weapon_cant_buy", 1);
            return;
        else
            v152.database[v154] = nil;
            v152:save_database();
            common.add_event("Preset deleted successfully", "check");
            cvar.playvol:call("ui\\beepclear", 1);
            v152:update();
            return;
        end;
    end, 
    export = function(v155)
        -- upvalues: l_clipboard_0 (ref)
        local l_preset_list_4 = v155.home.elements.preset_list;
        local v157 = l_preset_list_4:list()[l_preset_list_4:get()];
        if not v157 or not v155.database[v157] then
            common.add_event("Preset doesn't exist", "ban");
            cvar.playvol:call("ui\\weapon_cant_buy", 1);
            return;
        else
            l_clipboard_0.set(v155.database[v157]);
            common.add_event("Preset exported to clipboard", "check");
            cvar.playvol:call("ui\\beepclear", 1);
            return;
        end;
    end, 
    import = function(v158)
        -- upvalues: l_clipboard_0 (ref), l_base64_0 (ref)
        local v159 = l_clipboard_0.get();
        if not v159 or v159 == "" then
            common.add_event("Clipboard is empty", "ban");
            cvar.playvol:call("ui\\weapon_cant_buy", 1);
            return;
        else
            local v160 = v158.home.elements.preset_input:get();
            if not v160 or v160 == "" then
                common.add_event("Please enter a name for the imported preset", "ban");
                cvar.playvol:call("ui\\weapon_cant_buy", 1);
                return;
            elseif v158:is_system_preset(v160) then
                common.add_event("Cannot import to system preset", "ban");
                cvar.playvol:call("ui\\weapon_cant_buy", 1);
                return;
            elseif not pcall(function()
                -- upvalues: l_base64_0 (ref), v159 (ref)
                local v161 = l_base64_0.decode(v159);
                local v162 = msgpack.unpack(v161);
                assert(type(v162) == "table", "not a table");
            end) then
                common.add_event("Failed to import. (Invalid preset format)", "ban");
                cvar.playvol:call("ui\\weapon_cant_buy", 1);
                return;
            else
                v158.database[v160] = v159;
                v158:save_database();
                common.add_event("Imported successfully", "check");
                cvar.playvol:call("ui\\beepclear", 1);
                v158:update();
                local v163 = v158.home.elements.preset_list:list();
                for v164, v165 in ipairs(v163) do
                    if v165 == v160 then
                        v158.home.elements.preset_list:set(v164);
                        break;
                    end;
                end;
                v158:disabler();
                return;
            end;
        end;
    end, 
    init = function(v166)
        -- upvalues: l_base64_0 (ref)
        v166.system_presets = {
            v166.string:format("", "\a{Link Active}Advanced " .. point, 0, 0, 0), 
            v166.string:format("", "\a{Link Active}Agressive " .. point, 0, 0, 0), 
            v166.string:format("", "\a{Link Active}Experemental " .. point, 0, 0, 0)
        };
        v166.separator = v166.string:format("", string.rep("\226\148\128", 39), 0, 0, 0);
        v166.database = db.godsense_recode666 or {};
        for _, v168 in ipairs(v166.system_presets) do
            do
                local l_v168_0 = v168;
                if v166.database[l_v168_0] and not pcall(function()
                    -- upvalues: l_base64_0 (ref), v166 (ref), l_v168_0 (ref)
                    local v170 = l_base64_0.decode(v166.database[l_v168_0]);
                    msgpack.unpack(v170);
                end) then
                    v166.database[l_v168_0] = nil;
                end;
            end;
        end;
        local v171 = {
            [1] = "3gBMAoiqc2VsZWN0YWJsZQGtd2FybXVwX2FhX3RibIelcGl0Y2ioRGlzYWJsZWSlc3BlZWQKpG1vZGWRoX6rbGVmdF9vZmZzZXQArHJpZ2h0X29mZnNldACjeWF3qVJhbmRvbWl6ZaVyYW5nZc0BaK5mb3JjZV9icmVha19sY5fZJAd7TGluayBBY3RpdmV94oCiICAgB0RFRkFVTFRTdGFuZGluZ9klB3tMaW5rIEFjdGl2ZX3igKIgICAHREVGQVVMVENyb3VjaGluZ9knB3tMaW5rIEFjdGl2ZX3igKIgICAHREVGQVVMVE1vdmUgQ3JvdWNo2SYHe0xpbmsgQWN0aXZlfeKAoiAgIAdERUZBVUxUQWlyIENyb3VjaNkoB3tMaW5rIEFjdGl2ZX3igKIgICAHREVGQVVMVEZyZWVzdGFuZGluZ9kjB3tMaW5rIEFjdGl2ZX3igKIgICAHREVGQVVMVE1hbnVhbHOhfqxvcHRpb25zX2dlYXKGrGZyZWVzdGFuZGluZ8KnYm9keV9mc8OuYXZvaWRfYmFja3N0YWLDqWRpc2FibGVyc5GhfqlzYWZlX2hlYWSTpkNyb3VjaKtNb3ZlIENyb3VjaKF+p21hbnVhbHOoRGlzYWJsZWSqZnNfYWxsb3dlc8O2Zm9yY2VfYnJlYWtfbGNfb3B0aW9uc4KyZGlzYWJsZV9vbl9ncmVuYWRlw6poaWRlX3Nob3Rzr0Zhdm9yIEZpcmUgUmF0ZaV0ZWFtcwKmc3RhdGVzBwPeACyrZmFzdF9sYWRkZXLDrmhpdG1hcmtlcl90aW1lAq1kbWdfaW5kaWNhdG9yw6xhc3BlY3RfcmF0aW/DrnVubG9ja19sYXRlbmN5w69oaXRtYXJrZXJfdGltZTICtXNjb3BlX292ZXJsYXlfb3B0aW9uc5GhfrRzY29wZV9vdmVybGF5X2xlbmd0aMy5r3VubG9ja19mZF9zcGVlZMOxc2NvcGVfb3ZlcmxheV9nYXAFrXNjb3BlX292ZXJsYXnDqmxvZ19ldmVudHPDqXN1cGVydG9zc8KtYXJyb3dzX2FjY2VudKkjRkZGRkZGRkapdmlld21vZGVsw6tqaXR0ZXJfbGVnc8OtaW50ZXJwb2xhdGluZ8KrYXJyb3dzX2ZvbnSnRGVmYXVsdK5hcnJvd3NfZm9yd2FyZKFerW1hbnVhbF9hcnJvd3PDq2Fycm93c19sZWZ0oTynbGVhbmluZ2StfmFzcGVjdF9yYXRpb4Glc2NhbGXMgKp+dmlld21vZGVsh6hvZmZzZXRfeeajZm92PKhvZmZzZXRfeg6qcmlnaHRfaGFuZMKpbWFpbl9oYW5kqlJpZ2h0IHNpZGWpbGVmdF9oYW5kwqhvZmZzZXRfeASnZmFsbGluZwCufmludGVycG9sYXRpbmeBpXNjYWxlCaplYXJ0aHF1YWtlwrJkbWdfaW5kaWNhdG9yX21vZGWoQWR2YW5jZWSsYXJyb3dzX3JpZ2h0oT6vbG9nX2V2ZW50c19tb2Rlk7BQdXJjaGFzZXMgRXZlbnRzrlJhZ2Vib3QgRXZlbnRzoX6paGl0bWFya2Vyk6IyRKIzRKF+rH5qaXR0ZXJfbGVnc4KidG9apGZyb20Kt2xvZ19ldmVudHNfcHJlZml4X2NvbG9yqSNGRkZGRkZGRrNzY29wZV9vdmVybGF5X2NvbG9yqSNGRkZGRkZGRrVsb2dfZXZlbnRzX21haW5fY29sb3KpI0IxOEU4RUFGsWxvZ19ldmVudHNfcHJlZml4qGdvZHNlbnNlr2dyZW5hZGVfcmVsZWFzZcKzZnJlZXpldGltZV9mYWtlZHVja8O2bG9nX2V2ZW50c19hbHRlcm5hdGl2ZcOwaGl0bWFya2VyX2NvbG9yMqkjRkZGRkZGRka3a2VlcF9tb2RlbF90cmFuc3BhcmVuY3nDrm5vX2ZhbGxfZGFtYWdlw7JzY29wZV9vdmVybGF5X2VkZ2WpI0ZGRkZGRjAwr2hpdG1hcmtlcl9jb2xvcqkjRkZGRkZGOEME3gAeqnRpY2tiYXNlXzECp2RlbGF5XzMCqnRpY2tiYXNlXzICp2RlbGF5XzQCqnRpY2tiYXNlXzQCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl8yAKhzbGlkZXJfMwCoc2xpZGVyXzQAqHNsaWRlcl81AKlyYW5kb21pemXCqHNsaWRlcl82AKZvZmZzZXQApG1vZGWnRGVmYXVsdKNtaW4Ao21heACoc2xpZGVyXzEArmN1c3RvbV9zbGlkZXJzAqp0aWNrYmFzZV8zAqdkZWxheV81Aqxib2R5X29wdGlvbnOPrWppdHRlcl9idXR0b27Dq3RpY2tfc2xpZGVyBKpsZWZ0X2xpbWl0PK9sZWZ0X3RpY2tfbGltaXQ8q3JpZ2h0X2xpbWl0PLByaWdodF90aWNrX2xpbWl0PLF0eXBlX3JhbmRvbV92YWx1ZQKidG88o21heDyvdHlwZV90aWNrX3ZhbHVlBKRmcm9tPKR0eXBlplN0YXRpY6hpbnZlcnRlcsKjbWluPKtkZXN5bmNfdHlwZaZTdGF0aWOoeWF3X21vZGWqTGVmdC9SaWdodKh0aWNrYmFzZalOZXZlcmxvc2WnZGVsYXlfNgKqeWF3X29mZnNldACobW9kaWZpZXKoRGlzYWJsZWSqdGlja2Jhc2VfNQKydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNgKnZGVsYXlfOAKnZGVsYXlfMQOydGlja2Jhc2Vfcm5kbV90eXBlp0RlZmF1bHSqdGlja2Jhc2VfNwKreWF3X21vZGVfZXiIsGRlbGF5X3JhbmRvbV9tYXgHqmRlbGF5X21vZGUCq29mZnNldF9sZWZ07bNkZWxheV9zbGlkZXJfY3JlYXRlAqxvZmZzZXRfcmlnaHQdrWRlbGF5X2RlZmF1bHQEqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4Dr3RpY2tiYXNlX3JuZG1fMhCwdGlja2Jhc2Vfc2xpZGVycwOqdGlja2Jhc2VfOAKtdGlja2Jhc2Vfcm5kbRCnZGVsYXlfMgekYm9kecOnZGVsYXlfNwIFjKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80AKhzbGlkZXJfNQCpcmFuZG9taXplwqhzbGlkZXJfNgCmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSjbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwIGj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmU3RhdGljB4iwZGVsYXlfcmFuZG9tX21heAeqZGVsYXlfbW9kZQKrb2Zmc2V0X2xlZnTts2RlbGF5X3NsaWRlcl9jcmVhdGUCrG9mZnNldF9yaWdodB2tZGVsYXlfZGVmYXVsdASqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgMI3gAeqnRpY2tiYXNlXzECp2RlbGF5XzMCqnRpY2tiYXNlXzICp2RlbGF5XzQCqnRpY2tiYXNlXzQCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl8yAKhzbGlkZXJfMwCoc2xpZGVyXzQAqHNsaWRlcl81AKlyYW5kb21pemXCqHNsaWRlcl82AKZvZmZzZXQApG1vZGWnRGVmYXVsdKNtaW4Ao21heACoc2xpZGVyXzEArmN1c3RvbV9zbGlkZXJzAqp0aWNrYmFzZV8zAqdkZWxheV81Aqxib2R5X29wdGlvbnOPrWppdHRlcl9idXR0b27Dq3RpY2tfc2xpZGVyBKpsZWZ0X2xpbWl0PK9sZWZ0X3RpY2tfbGltaXQ8q3JpZ2h0X2xpbWl0PLByaWdodF90aWNrX2xpbWl0PLF0eXBlX3JhbmRvbV92YWx1ZQKidG88o21heDyvdHlwZV90aWNrX3ZhbHVlBKRmcm9tG6R0eXBlplN0YXRpY6hpbnZlcnRlcsKjbWluPKtkZXN5bmNfdHlwZaZTdGF0aWOoeWF3X21vZGWqTGVmdC9SaWdodKh0aWNrYmFzZalOZXZlcmxvc2WnZGVsYXlfNgKqeWF3X29mZnNldACobW9kaWZpZXKoRGlzYWJsZWSqdGlja2Jhc2VfNQKydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNgKnZGVsYXlfOAKnZGVsYXlfMQOydGlja2Jhc2Vfcm5kbV90eXBlp0RlZmF1bHSqdGlja2Jhc2VfNwKreWF3X21vZGVfZXiIsGRlbGF5X3JhbmRvbV9tYXgHqmRlbGF5X21vZGUCq29mZnNldF9sZWZ07bNkZWxheV9zbGlkZXJfY3JlYXRlAqxvZmZzZXRfcmlnaHQdrWRlbGF5X2RlZmF1bHQEqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4Dr3RpY2tiYXNlX3JuZG1fMhCwdGlja2Jhc2Vfc2xpZGVycwOqdGlja2Jhc2VfOAKtdGlja2Jhc2Vfcm5kbRCnZGVsYXlfMgekYm9kecOnZGVsYXlfNwIJjKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80AKhzbGlkZXJfNQCpcmFuZG9taXplwqhzbGlkZXJfNgCmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSjbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwIKj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbRukdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmU3RhdGljC4iwZGVsYXlfcmFuZG9tX21heAeqZGVsYXlfbW9kZQKrb2Zmc2V0X2xlZnTts2RlbGF5X3NsaWRlcl9jcmVhdGUCrG9mZnNldF9yaWdodB2tZGVsYXlfZGVmYXVsdASqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgMM3gAeqnRpY2tiYXNlXzECp2RlbGF5XzMCqnRpY2tiYXNlXzICp2RlbGF5XzQCqnRpY2tiYXNlXzQCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl8yAKhzbGlkZXJfMwCoc2xpZGVyXzQAqHNsaWRlcl81AKlyYW5kb21pemXDqHNsaWRlcl82AKZvZmZzZXQApG1vZGWmQ3VzdG9to21pbgCjbWF4AKhzbGlkZXJfMQCuY3VzdG9tX3NsaWRlcnMGqnRpY2tiYXNlXzMCp2RlbGF5XzUCrGJvZHlfb3B0aW9uc4+taml0dGVyX2J1dHRvbsOrdGlja19zbGlkZXIEqmxlZnRfbGltaXQ8r2xlZnRfdGlja19saW1pdBurcmlnaHRfbGltaXQ8sHJpZ2h0X3RpY2tfbGltaXQ8sXR5cGVfcmFuZG9tX3ZhbHVlAqJ0bzyjbWF4PK90eXBlX3RpY2tfdmFsdWUEpGZyb20bpHR5cGWmU3RhdGljqGludmVydGVywqNtaW4bq2Rlc3luY190eXBlp0Zyb20vVG+oeWF3X21vZGWqTGVmdC9SaWdodKh0aWNrYmFzZalOZXZlcmxvc2WnZGVsYXlfNgKqeWF3X29mZnNldACobW9kaWZpZXKkU3Bpbqp0aWNrYmFzZV81ArJ0aWNrYmFzZV9yYW5kb21pemXDrnRpY2tiYXNlX2Nob2tlEKp0aWNrYmFzZV82AqdkZWxheV84AqdkZWxheV8xArJ0aWNrYmFzZV9ybmRtX3R5cGWnRGVmYXVsdKp0aWNrYmFzZV83Aqt5YXdfbW9kZV9leIiwZGVsYXlfcmFuZG9tX21heAWqZGVsYXlfbW9kZQKrb2Zmc2V0X2xlZnTms2RlbGF5X3NsaWRlcl9jcmVhdGUCrG9mZnNldF9yaWdodCStZGVsYXlfZGVmYXVsdAOqeWF3X3JhbmRvbRywZGVsYXlfcmFuZG9tX21pbgOvdGlja2Jhc2Vfcm5kbV8yELB0aWNrYmFzZV9zbGlkZXJzA6p0aWNrYmFzZV84Aq10aWNrYmFzZV9ybmRtEKdkZWxheV8yAqRib2R5w6dkZWxheV83Ag2MqHNsaWRlcl8yAKhzbGlkZXJfMwCoc2xpZGVyXzQAqHNsaWRlcl81AKlyYW5kb21pemXDqHNsaWRlcl82AKZvZmZzZXQApG1vZGWmQ3VzdG9to21pbgCjbWF4AKhzbGlkZXJfMQCuY3VzdG9tX3NsaWRlcnMGDo+taml0dGVyX2J1dHRvbsOrdGlja19zbGlkZXIEqmxlZnRfbGltaXQ8r2xlZnRfdGlja19saW1pdBurcmlnaHRfbGltaXQ8sHJpZ2h0X3RpY2tfbGltaXQ8sXR5cGVfcmFuZG9tX3ZhbHVlAqJ0bzyjbWF4PK90eXBlX3RpY2tfdmFsdWUEpGZyb20bpHR5cGWmU3RhdGljqGludmVydGVywqNtaW4bq2Rlc3luY190eXBlp0Zyb20vVG8PiLBkZWxheV9yYW5kb21fbWF4BapkZWxheV9tb2RlAqtvZmZzZXRfbGVmdOazZGVsYXlfc2xpZGVyX2NyZWF0ZQKsb2Zmc2V0X3JpZ2h0JK1kZWxheV9kZWZhdWx0A6p5YXdfcmFuZG9tHLBkZWxheV9yYW5kb21fbWluAxDeAB6qdGlja2Jhc2VfMQKnZGVsYXlfMwKqdGlja2Jhc2VfMgKnZGVsYXlfNAKqdGlja2Jhc2VfNAKwbW9kaWZpZXJfb3B0aW9uc4yoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNACoc2xpZGVyXzUAqXJhbmRvbWl6ZcOoc2xpZGVyXzYApm9mZnNldACkbW9kZaZDdXN0b22jbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwaqdGlja2Jhc2VfMwKnZGVsYXlfNQKsYm9keV9vcHRpb25zj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0G6tyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbhurZGVzeW5jX3R5cGWnRnJvbS9Ub6h5YXdfbW9kZapMZWZ0L1JpZ2h0qHRpY2tiYXNlqU5ldmVybG9zZadkZWxheV82Aqp5YXdfb2Zmc2V0AKhtb2RpZmllcqRTcGluqnRpY2tiYXNlXzUCsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzYCp2RlbGF5XzgCp2RlbGF5XzECsnRpY2tiYXNlX3JuZG1fdHlwZadEZWZhdWx0qnRpY2tiYXNlXzcCq3lhd19tb2RlX2V4iLBkZWxheV9yYW5kb21fbWF4BapkZWxheV9tb2RlAqtvZmZzZXRfbGVmdOazZGVsYXlfc2xpZGVyX2NyZWF0ZQKsb2Zmc2V0X3JpZ2h0JK1kZWxheV9kZWZhdWx0A6p5YXdfcmFuZG9tHLBkZWxheV9yYW5kb21fbWluA690aWNrYmFzZV9ybmRtXzIQsHRpY2tiYXNlX3NsaWRlcnMDqnRpY2tiYXNlXzgCrXRpY2tiYXNlX3JuZG0Qp2RlbGF5XzICpGJvZHnDp2RlbGF5XzcCEYyoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNACoc2xpZGVyXzUAqXJhbmRvbWl6ZcOoc2xpZGVyXzYApm9mZnNldACkbW9kZaZDdXN0b22jbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwYSj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0G6tyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbhurZGVzeW5jX3R5cGWnRnJvbS9UbxOIsGRlbGF5X3JhbmRvbV9tYXgFqmRlbGF5X21vZGUCq29mZnNldF9sZWZ05rNkZWxheV9zbGlkZXJfY3JlYXRlAqxvZmZzZXRfcmlnaHQkrWRlbGF5X2RlZmF1bHQDqnlhd19yYW5kb20csGRlbGF5X3JhbmRvbV9taW4DFN4AHqp0aWNrYmFzZV8xAqdkZWxheV8zAqp0aWNrYmFzZV8yAqdkZWxheV80Aqp0aWNrYmFzZV80ArBtb2RpZmllcl9vcHRpb25zjKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80AKhzbGlkZXJfNQCpcmFuZG9taXplwqhzbGlkZXJfNgCmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSjbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwKqdGlja2Jhc2VfMwKnZGVsYXlfNQKsYm9keV9vcHRpb25zj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmU3RhdGljqHlhd19tb2RlplN0YXRpY6h0aWNrYmFzZalOZXZlcmxvc2WnZGVsYXlfNgKqeWF3X29mZnNldACobW9kaWZpZXKoRGlzYWJsZWSqdGlja2Jhc2VfNQKydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNgKnZGVsYXlfOAKnZGVsYXlfMQKydGlja2Jhc2Vfcm5kbV90eXBlp0RlZmF1bHSqdGlja2Jhc2VfNwKreWF3X21vZGVfZXiIsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUAq29mZnNldF9sZWZ0ALNkZWxheV9zbGlkZXJfY3JlYXRlAqxvZmZzZXRfcmlnaHQArWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4Cr3RpY2tiYXNlX3JuZG1fMhCwdGlja2Jhc2Vfc2xpZGVycwOqdGlja2Jhc2VfOAKtdGlja2Jhc2Vfcm5kbRCnZGVsYXlfMgKkYm9kecOnZGVsYXlfNwIVjKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80AKhzbGlkZXJfNQCpcmFuZG9taXplwqhzbGlkZXJfNgCmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSjbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwIWj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmU3RhdGljF4iwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQCrb2Zmc2V0X2xlZnQAs2RlbGF5X3NsaWRlcl9jcmVhdGUCrG9mZnNldF9yaWdodACtZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgIY3gAeqnRpY2tiYXNlXzECp2RlbGF5XzMCqnRpY2tiYXNlXzICp2RlbGF5XzQCqnRpY2tiYXNlXzQCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl8yAKhzbGlkZXJfMwCoc2xpZGVyXzQAqHNsaWRlcl81AKlyYW5kb21pemXCqHNsaWRlcl82AKZvZmZzZXQApG1vZGWnRGVmYXVsdKNtaW4Ao21heACoc2xpZGVyXzEArmN1c3RvbV9zbGlkZXJzAqp0aWNrYmFzZV8zAqdkZWxheV81Aqxib2R5X29wdGlvbnOPrWppdHRlcl9idXR0b27Dq3RpY2tfc2xpZGVyBKpsZWZ0X2xpbWl0PK9sZWZ0X3RpY2tfbGltaXQ8q3JpZ2h0X2xpbWl0PLByaWdodF90aWNrX2xpbWl0PLF0eXBlX3JhbmRvbV92YWx1ZQKidG88o21heDyvdHlwZV90aWNrX3ZhbHVlBKRmcm9tPKR0eXBlplN0YXRpY6hpbnZlcnRlcsKjbWluPKtkZXN5bmNfdHlwZaZTdGF0aWOoeWF3X21vZGWmU3RhdGljqHRpY2tiYXNlqU5ldmVybG9zZadkZWxheV82Aqp5YXdfb2Zmc2V0AKhtb2RpZmllcqhEaXNhYmxlZKp0aWNrYmFzZV81ArJ0aWNrYmFzZV9yYW5kb21pemXDrnRpY2tiYXNlX2Nob2tlEKp0aWNrYmFzZV82AqdkZWxheV84AqdkZWxheV8xArJ0aWNrYmFzZV9ybmRtX3R5cGWnRGVmYXVsdKp0aWNrYmFzZV83Aqt5YXdfbW9kZV9leIiwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQCrb2Zmc2V0X2xlZnQAs2RlbGF5X3NsaWRlcl9jcmVhdGUCrG9mZnNldF9yaWdodACtZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgKvdGlja2Jhc2Vfcm5kbV8yELB0aWNrYmFzZV9zbGlkZXJzA6p0aWNrYmFzZV84Aq10aWNrYmFzZV9ybmRtEKdkZWxheV8yAqRib2R5w6dkZWxheV83AhmMqHNsaWRlcl8yAKhzbGlkZXJfMwCoc2xpZGVyXzQAqHNsaWRlcl81AKlyYW5kb21pemXCqHNsaWRlcl82AKZvZmZzZXQApG1vZGWnRGVmYXVsdKNtaW4Ao21heACoc2xpZGVyXzEArmN1c3RvbV9zbGlkZXJzAhqPrWppdHRlcl9idXR0b27Dq3RpY2tfc2xpZGVyBKpsZWZ0X2xpbWl0PK9sZWZ0X3RpY2tfbGltaXQ8q3JpZ2h0X2xpbWl0PLByaWdodF90aWNrX2xpbWl0PLF0eXBlX3JhbmRvbV92YWx1ZQKidG88o21heDyvdHlwZV90aWNrX3ZhbHVlBKRmcm9tPKR0eXBlplN0YXRpY6hpbnZlcnRlcsKjbWluPKtkZXN5bmNfdHlwZaZTdGF0aWMbiLBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAKtvZmZzZXRfbGVmdACzZGVsYXlfc2xpZGVyX2NyZWF0ZQKsb2Zmc2V0X3JpZ2h0AK1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluAhzeAB6qdGlja2Jhc2VfMQKnZGVsYXlfMwKqdGlja2Jhc2VfMgKnZGVsYXlfNAKqdGlja2Jhc2VfNAKwbW9kaWZpZXJfb3B0aW9uc4yoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNACoc2xpZGVyXzUAqXJhbmRvbWl6ZcOoc2xpZGVyXzYApm9mZnNldACkbW9kZaZDdXN0b22jbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwaqdGlja2Jhc2VfMwKnZGVsYXlfNQKsYm9keV9vcHRpb25zj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcg2qbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQekZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmUmFuZG9tqHlhd19tb2RlqkxlZnQvUmlnaHSodGlja2Jhc2WpTmV2ZXJsb3Nlp2RlbGF5XzYCqnlhd19vZmZzZXQAqG1vZGlmaWVypFNwaW6qdGlja2Jhc2VfNQKydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNgKnZGVsYXlfOAKnZGVsYXlfMQKydGlja2Jhc2Vfcm5kbV90eXBlp0RlZmF1bHSqdGlja2Jhc2VfNwKreWF3X21vZGVfZXiIsGRlbGF5X3JhbmRvbV9tYXgRqmRlbGF5X21vZGUCq29mZnNldF9sZWZ06rNkZWxheV9zbGlkZXJfY3JlYXRlAqxvZmZzZXRfcmlnaHQsrWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20bsGRlbGF5X3JhbmRvbV9taW4Ir3RpY2tiYXNlX3JuZG1fMhCwdGlja2Jhc2Vfc2xpZGVycwOqdGlja2Jhc2VfOAKtdGlja2Jhc2Vfcm5kbRCnZGVsYXlfMgKkYm9kecOnZGVsYXlfNwIdjKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80AKhzbGlkZXJfNQCpcmFuZG9taXplw6hzbGlkZXJfNgCmb2Zmc2V0AKRtb2RlpkN1c3RvbaNtaW4Ao21heACoc2xpZGVyXzEArmN1c3RvbV9zbGlkZXJzBh6PrWppdHRlcl9idXR0b27Dq3RpY2tfc2xpZGVyDapsZWZ0X2xpbWl0PK9sZWZ0X3RpY2tfbGltaXQ8q3JpZ2h0X2xpbWl0PLByaWdodF90aWNrX2xpbWl0PLF0eXBlX3JhbmRvbV92YWx1ZQKidG88o21heDyvdHlwZV90aWNrX3ZhbHVlB6Rmcm9tPKR0eXBlplN0YXRpY6hpbnZlcnRlcsKjbWluPKtkZXN5bmNfdHlwZaZSYW5kb20fiLBkZWxheV9yYW5kb21fbWF4EapkZWxheV9tb2RlAqtvZmZzZXRfbGVmdOqzZGVsYXlfc2xpZGVyX2NyZWF0ZQKsb2Zmc2V0X3JpZ2h0LK1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tG7BkZWxheV9yYW5kb21fbWluCCDeAB6qdGlja2Jhc2VfMQKnZGVsYXlfMwKqdGlja2Jhc2VfMgKnZGVsYXlfNAKqdGlja2Jhc2VfNAKwbW9kaWZpZXJfb3B0aW9uc4yoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNACoc2xpZGVyXzUAqXJhbmRvbWl6ZcOoc2xpZGVyXzYEpm9mZnNldACkbW9kZaZDdXN0b22jbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwaqdGlja2Jhc2VfMwKnZGVsYXlfNQKsYm9keV9vcHRpb25zj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcg2qbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQekZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmUmFuZG9tqHlhd19tb2RlqkxlZnQvUmlnaHSodGlja2Jhc2WpTmV2ZXJsb3Nlp2RlbGF5XzYCqnlhd19vZmZzZXQAqG1vZGlmaWVypFNwaW6qdGlja2Jhc2VfNQKydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNgKnZGVsYXlfOAKnZGVsYXlfMQKydGlja2Jhc2Vfcm5kbV90eXBlp0RlZmF1bHSqdGlja2Jhc2VfNwKreWF3X21vZGVfZXiIsGRlbGF5X3JhbmRvbV9tYXgRqmRlbGF5X21vZGUCq29mZnNldF9sZWZ06rNkZWxheV9zbGlkZXJfY3JlYXRlAqxvZmZzZXRfcmlnaHQsrWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20bsGRlbGF5X3JhbmRvbV9taW4Ir3RpY2tiYXNlX3JuZG1fMhCwdGlja2Jhc2Vfc2xpZGVycwOqdGlja2Jhc2VfOAKtdGlja2Jhc2Vfcm5kbRCnZGVsYXlfMgKkYm9kecOnZGVsYXlfNwIhjKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80AKhzbGlkZXJfNQCpcmFuZG9taXplw6hzbGlkZXJfNgSmb2Zmc2V0AKRtb2RlpkN1c3RvbaNtaW4Ao21heACoc2xpZGVyXzEArmN1c3RvbV9zbGlkZXJzBiKPrWppdHRlcl9idXR0b27Dq3RpY2tfc2xpZGVyDapsZWZ0X2xpbWl0PK9sZWZ0X3RpY2tfbGltaXQ8q3JpZ2h0X2xpbWl0PLByaWdodF90aWNrX2xpbWl0PLF0eXBlX3JhbmRvbV92YWx1ZQKidG88o21heDyvdHlwZV90aWNrX3ZhbHVlB6Rmcm9tPKR0eXBlplN0YXRpY6hpbnZlcnRlcsKjbWluPKtkZXN5bmNfdHlwZaZSYW5kb20jiLBkZWxheV9yYW5kb21fbWF4EapkZWxheV9tb2RlAqtvZmZzZXRfbGVmdOqzZGVsYXlfc2xpZGVyX2NyZWF0ZQKsb2Zmc2V0X3JpZ2h0LK1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tG7BkZWxheV9yYW5kb21fbWluCCTeAB6qdGlja2Jhc2VfMQenZGVsYXlfMwiqdGlja2Jhc2VfMgOnZGVsYXlfNAOqdGlja2Jhc2VfNBSwbW9kaWZpZXJfb3B0aW9uc4yoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNACoc2xpZGVyXzUEqXJhbmRvbWl6ZcOoc2xpZGVyXzb0pm9mZnNldACkbW9kZaZDdXN0b22jbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwWqdGlja2Jhc2VfMwKnZGVsYXlfNQKsYm9keV9vcHRpb25zj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmUmFuZG9tqHlhd19tb2RlqkxlZnQvUmlnaHSodGlja2Jhc2WoQWR2YW5jZWSnZGVsYXlfNgKqeWF3X29mZnNldACobW9kaWZpZXKlMy1XYXmqdGlja2Jhc2VfNQqydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNgKnZGVsYXlfOAKnZGVsYXlfMQeydGlja2Jhc2Vfcm5kbV90eXBlpFdheXOqdGlja2Jhc2VfNwKreWF3X21vZGVfZXiIsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUDq29mZnNldF9sZWZ07rNkZWxheV9zbGlkZXJfY3JlYXRlBKxvZmZzZXRfcmlnaHQnrWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4Cr3RpY2tiYXNlX3JuZG1fMhCwdGlja2Jhc2Vfc2xpZGVycwWqdGlja2Jhc2VfOAKtdGlja2Jhc2Vfcm5kbRCnZGVsYXlfMgSkYm9kecOnZGVsYXlfNwIljKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80AKhzbGlkZXJfNQSpcmFuZG9taXplw6hzbGlkZXJfNvSmb2Zmc2V0AKRtb2RlpkN1c3RvbaNtaW4Ao21heACoc2xpZGVyXzEArmN1c3RvbV9zbGlkZXJzBSaPrWppdHRlcl9idXR0b27Dq3RpY2tfc2xpZGVyBKpsZWZ0X2xpbWl0PK9sZWZ0X3RpY2tfbGltaXQ8q3JpZ2h0X2xpbWl0PLByaWdodF90aWNrX2xpbWl0PLF0eXBlX3JhbmRvbV92YWx1ZQKidG88o21heDyvdHlwZV90aWNrX3ZhbHVlBKRmcm9tPKR0eXBlplN0YXRpY6hpbnZlcnRlcsKjbWluPKtkZXN5bmNfdHlwZaZSYW5kb20niLBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlA6tvZmZzZXRfbGVmdO6zZGVsYXlfc2xpZGVyX2NyZWF0ZQSsb2Zmc2V0X3JpZ2h0J61kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluAijeAB6qdGlja2Jhc2VfMQenZGVsYXlfMwiqdGlja2Jhc2VfMgOnZGVsYXlfNAOqdGlja2Jhc2VfNBSwbW9kaWZpZXJfb3B0aW9uc4yoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNASoc2xpZGVyXzX0qXJhbmRvbWl6ZcOoc2xpZGVyXzYApm9mZnNldACkbW9kZaZDdXN0b22jbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwWqdGlja2Jhc2VfMwKnZGVsYXlfNQKsYm9keV9vcHRpb25zj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmUmFuZG9tqHlhd19tb2RlqkxlZnQvUmlnaHSodGlja2Jhc2WoQWR2YW5jZWSnZGVsYXlfNgKqeWF3X29mZnNldACobW9kaWZpZXKlMy1XYXmqdGlja2Jhc2VfNQqydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNgKnZGVsYXlfOAKnZGVsYXlfMQeydGlja2Jhc2Vfcm5kbV90eXBlpFdheXOqdGlja2Jhc2VfNwKreWF3X21vZGVfZXiIsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUDq29mZnNldF9sZWZ07rNkZWxheV9zbGlkZXJfY3JlYXRlBKxvZmZzZXRfcmlnaHQnrWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4Cr3RpY2tiYXNlX3JuZG1fMhCwdGlja2Jhc2Vfc2xpZGVycwWqdGlja2Jhc2VfOAKtdGlja2Jhc2Vfcm5kbRCnZGVsYXlfMgSkYm9kecOnZGVsYXlfNwIpjKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80BKhzbGlkZXJfNfSpcmFuZG9taXplw6hzbGlkZXJfNgCmb2Zmc2V0AKRtb2RlpkN1c3RvbaNtaW4Ao21heACoc2xpZGVyXzEArmN1c3RvbV9zbGlkZXJzBSqPrWppdHRlcl9idXR0b27Dq3RpY2tfc2xpZGVyBKpsZWZ0X2xpbWl0PK9sZWZ0X3RpY2tfbGltaXQ8q3JpZ2h0X2xpbWl0PLByaWdodF90aWNrX2xpbWl0PLF0eXBlX3JhbmRvbV92YWx1ZQKidG88o21heDyvdHlwZV90aWNrX3ZhbHVlBKRmcm9tPKR0eXBlplN0YXRpY6hpbnZlcnRlcsKjbWluPKtkZXN5bmNfdHlwZaZSYW5kb20riLBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlA6tvZmZzZXRfbGVmdO6zZGVsYXlfc2xpZGVyX2NyZWF0ZQSsb2Zmc2V0X3JpZ2h0J61kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluAizeAB6qdGlja2Jhc2VfMQKnZGVsYXlfMwKqdGlja2Jhc2VfMgKnZGVsYXlfNAKqdGlja2Jhc2VfNAKwbW9kaWZpZXJfb3B0aW9uc4yoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNACoc2xpZGVyXzUAqXJhbmRvbWl6ZcKoc2xpZGVyXzYApm9mZnNldACkbW9kZadEZWZhdWx0o21pbgCjbWF4AKhzbGlkZXJfMQCuY3VzdG9tX3NsaWRlcnMCqnRpY2tiYXNlXzMCp2RlbGF5XzUCrGJvZHlfb3B0aW9uc4+taml0dGVyX2J1dHRvbsOrdGlja19zbGlkZXIEqmxlZnRfbGltaXQ8r2xlZnRfdGlja19saW1pdDyrcmlnaHRfbGltaXQ8sHJpZ2h0X3RpY2tfbGltaXQ8sXR5cGVfcmFuZG9tX3ZhbHVlAqJ0bzyjbWF4PK90eXBlX3RpY2tfdmFsdWUEpGZyb208pHR5cGWmU3RhdGljqGludmVydGVywqNtaW48q2Rlc3luY190eXBlplN0YXRpY6h5YXdfbW9kZaZTdGF0aWOodGlja2Jhc2WpTmV2ZXJsb3Nlp2RlbGF5XzYCqnlhd19vZmZzZXQAqG1vZGlmaWVyqERpc2FibGVkqnRpY2tiYXNlXzUCsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzYCp2RlbGF5XzgCp2RlbGF5XzECsnRpY2tiYXNlX3JuZG1fdHlwZadEZWZhdWx0qnRpY2tiYXNlXzcCq3lhd19tb2RlX2V4iLBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAatvZmZzZXRfbGVmdO6zZGVsYXlfc2xpZGVyX2NyZWF0ZQKsb2Zmc2V0X3JpZ2h0H61kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluAq90aWNrYmFzZV9ybmRtXzIQsHRpY2tiYXNlX3NsaWRlcnMDqnRpY2tiYXNlXzgCrXRpY2tiYXNlX3JuZG0Qp2RlbGF5XzICpGJvZHnDp2RlbGF5XzcCLYyoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNACoc2xpZGVyXzUAqXJhbmRvbWl6ZcKoc2xpZGVyXzYApm9mZnNldACkbW9kZadEZWZhdWx0o21pbgCjbWF4AKhzbGlkZXJfMQCuY3VzdG9tX3NsaWRlcnMCLo+taml0dGVyX2J1dHRvbsOrdGlja19zbGlkZXIEqmxlZnRfbGltaXQ8r2xlZnRfdGlja19saW1pdDyrcmlnaHRfbGltaXQ8sHJpZ2h0X3RpY2tfbGltaXQ8sXR5cGVfcmFuZG9tX3ZhbHVlAqJ0bzyjbWF4PK90eXBlX3RpY2tfdmFsdWUEpGZyb208pHR5cGWmU3RhdGljqGludmVydGVywqNtaW48q2Rlc3luY190eXBlplN0YXRpYy+IsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUBq29mZnNldF9sZWZ07rNkZWxheV9zbGlkZXJfY3JlYXRlAqxvZmZzZXRfcmlnaHQfrWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4CMN4AHqp0aWNrYmFzZV8xAqdkZWxheV8zAqp0aWNrYmFzZV8yAqdkZWxheV80Aqp0aWNrYmFzZV80ArBtb2RpZmllcl9vcHRpb25zjKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80AKhzbGlkZXJfNQCpcmFuZG9taXplwqhzbGlkZXJfNgCmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSjbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwKqdGlja2Jhc2VfMwKnZGVsYXlfNQKsYm9keV9vcHRpb25zj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmU3RhdGljqHlhd19tb2RlplN0YXRpY6h0aWNrYmFzZalOZXZlcmxvc2WnZGVsYXlfNgKqeWF3X29mZnNldACobW9kaWZpZXKoRGlzYWJsZWSqdGlja2Jhc2VfNQKydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNgKnZGVsYXlfOAKnZGVsYXlfMQKydGlja2Jhc2Vfcm5kbV90eXBlp0RlZmF1bHSqdGlja2Jhc2VfNwKreWF3X21vZGVfZXiIsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUBq29mZnNldF9sZWZ07rNkZWxheV9zbGlkZXJfY3JlYXRlAqxvZmZzZXRfcmlnaHQfrWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4Cr3RpY2tiYXNlX3JuZG1fMhCwdGlja2Jhc2Vfc2xpZGVycwOqdGlja2Jhc2VfOAKtdGlja2Jhc2Vfcm5kbRCnZGVsYXlfMgKkYm9kecOnZGVsYXlfNwIxjKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80AKhzbGlkZXJfNQCpcmFuZG9taXplwqhzbGlkZXJfNgCmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSjbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwIyj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmU3RhdGljM4iwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQGrb2Zmc2V0X2xlZnTus2RlbGF5X3NsaWRlcl9jcmVhdGUCrG9mZnNldF9yaWdodB+tZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgI03gAeqnRpY2tiYXNlXzEQp2RlbGF5XzMCqnRpY2tiYXNlXzISp2RlbGF5XzQCqnRpY2tiYXNlXzQJsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl8yAKhzbGlkZXJfMwCoc2xpZGVyXzQAqHNsaWRlcl81AKlyYW5kb21pemXDqHNsaWRlcl82AKZvZmZzZXQApG1vZGWnRGVmYXVsdKNtaW74o21heAyoc2xpZGVyXzEArmN1c3RvbV9zbGlkZXJzBqp0aWNrYmFzZV8zBqdkZWxheV81Aqxib2R5X29wdGlvbnOPrWppdHRlcl9idXR0b27Dq3RpY2tfc2xpZGVyBKpsZWZ0X2xpbWl0PK9sZWZ0X3RpY2tfbGltaXQ8q3JpZ2h0X2xpbWl0PLByaWdodF90aWNrX2xpbWl0PLF0eXBlX3JhbmRvbV92YWx1ZQKidG88o21heDyvdHlwZV90aWNrX3ZhbHVlBKRmcm9tPKR0eXBlplN0YXRpY6hpbnZlcnRlcsKjbWluPKtkZXN5bmNfdHlwZaZTdGF0aWOoeWF3X21vZGWqTGVmdC9SaWdodKh0aWNrYmFzZahBZHZhbmNlZKdkZWxheV82Aqp5YXdfb2Zmc2V0AKhtb2RpZmllcqRTcGluqnRpY2tiYXNlXzURsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzYFp2RlbGF5XzgCp2RlbGF5XzECsnRpY2tiYXNlX3JuZG1fdHlwZaRXYXlzqnRpY2tiYXNlXzcIq3lhd19tb2RlX2V4iLBkZWxheV9yYW5kb21fbWF4CKpkZWxheV9tb2RlAqtvZmZzZXRfbGVmdOyzZGVsYXlfc2xpZGVyX2NyZWF0ZQKsb2Zmc2V0X3JpZ2h0KK1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tGLBkZWxheV9yYW5kb21fbWluBa90aWNrYmFzZV9ybmRtXzIWsHRpY2tiYXNlX3NsaWRlcnMIqnRpY2tiYXNlXzgKrXRpY2tiYXNlX3JuZG0Cp2RlbGF5XzICpGJvZHnDp2RlbGF5XzcCNYyoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNACoc2xpZGVyXzUAqXJhbmRvbWl6ZcOoc2xpZGVyXzYApm9mZnNldACkbW9kZadEZWZhdWx0o21pbvijbWF4DKhzbGlkZXJfMQCuY3VzdG9tX3NsaWRlcnMGNo+taml0dGVyX2J1dHRvbsOrdGlja19zbGlkZXIEqmxlZnRfbGltaXQ8r2xlZnRfdGlja19saW1pdDyrcmlnaHRfbGltaXQ8sHJpZ2h0X3RpY2tfbGltaXQ8sXR5cGVfcmFuZG9tX3ZhbHVlAqJ0bzyjbWF4PK90eXBlX3RpY2tfdmFsdWUEpGZyb208pHR5cGWmU3RhdGljqGludmVydGVywqNtaW48q2Rlc3luY190eXBlplN0YXRpYzeIsGRlbGF5X3JhbmRvbV9tYXgIqmRlbGF5X21vZGUCq29mZnNldF9sZWZ07LNkZWxheV9zbGlkZXJfY3JlYXRlAqxvZmZzZXRfcmlnaHQorWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20YsGRlbGF5X3JhbmRvbV9taW4FON4AHqp0aWNrYmFzZV8xEKdkZWxheV8zAqp0aWNrYmFzZV8yEqdkZWxheV80Aqp0aWNrYmFzZV80CbBtb2RpZmllcl9vcHRpb25zjKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80AKhzbGlkZXJfNQCpcmFuZG9taXplw6hzbGlkZXJfNgCmb2Zmc2V0+6Rtb2Rlp0RlZmF1bHSjbWlu+KNtYXgMqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwaqdGlja2Jhc2VfMwanZGVsYXlfNQKsYm9keV9vcHRpb25zj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmU3RhdGljqHlhd19tb2RlqkxlZnQvUmlnaHSodGlja2Jhc2WoQWR2YW5jZWSnZGVsYXlfNgKqeWF3X29mZnNldACobW9kaWZpZXKkU3Bpbqp0aWNrYmFzZV81EbJ0aWNrYmFzZV9yYW5kb21pemXDrnRpY2tiYXNlX2Nob2tlEKp0aWNrYmFzZV82BadkZWxheV84AqdkZWxheV8xArJ0aWNrYmFzZV9ybmRtX3R5cGWkV2F5c6p0aWNrYmFzZV83CKt5YXdfbW9kZV9leIiwZGVsYXlfcmFuZG9tX21heAiqZGVsYXlfbW9kZQKrb2Zmc2V0X2xlZnTss2RlbGF5X3NsaWRlcl9jcmVhdGUCrG9mZnNldF9yaWdodCitZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbRiwZGVsYXlfcmFuZG9tX21pbgWvdGlja2Jhc2Vfcm5kbV8yFrB0aWNrYmFzZV9zbGlkZXJzCKp0aWNrYmFzZV84Cq10aWNrYmFzZV9ybmRtAqdkZWxheV8yAqRib2R5w6dkZWxheV83AjmMqHNsaWRlcl8yAKhzbGlkZXJfMwCoc2xpZGVyXzQAqHNsaWRlcl81AKlyYW5kb21pemXDqHNsaWRlcl82AKZvZmZzZXT7pG1vZGWnRGVmYXVsdKNtaW74o21heAyoc2xpZGVyXzEArmN1c3RvbV9zbGlkZXJzBjqPrWppdHRlcl9idXR0b27Dq3RpY2tfc2xpZGVyBKpsZWZ0X2xpbWl0PK9sZWZ0X3RpY2tfbGltaXQ8q3JpZ2h0X2xpbWl0PLByaWdodF90aWNrX2xpbWl0PLF0eXBlX3JhbmRvbV92YWx1ZQKidG88o21heDyvdHlwZV90aWNrX3ZhbHVlBKRmcm9tPKR0eXBlplN0YXRpY6hpbnZlcnRlcsKjbWluPKtkZXN5bmNfdHlwZaZTdGF0aWM7iLBkZWxheV9yYW5kb21fbWF4CKpkZWxheV9tb2RlAqtvZmZzZXRfbGVmdOyzZGVsYXlfc2xpZGVyX2NyZWF0ZQKsb2Zmc2V0X3JpZ2h0KK1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tGLBkZWxheV9yYW5kb21fbWluBTzeAB6qdGlja2Jhc2VfMQKnZGVsYXlfMwKqdGlja2Jhc2VfMgKnZGVsYXlfNAKqdGlja2Jhc2VfNAKwbW9kaWZpZXJfb3B0aW9uc4yoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNACoc2xpZGVyXzUAqXJhbmRvbWl6ZcKoc2xpZGVyXzYApm9mZnNldACkbW9kZadEZWZhdWx0o21pbgCjbWF4AKhzbGlkZXJfMQCuY3VzdG9tX3NsaWRlcnMCqnRpY2tiYXNlXzMCp2RlbGF5XzUCrGJvZHlfb3B0aW9uc4+taml0dGVyX2J1dHRvbsOrdGlja19zbGlkZXIEqmxlZnRfbGltaXQ8r2xlZnRfdGlja19saW1pdDyrcmlnaHRfbGltaXQ8sHJpZ2h0X3RpY2tfbGltaXQ8sXR5cGVfcmFuZG9tX3ZhbHVlAqJ0bzyjbWF4PK90eXBlX3RpY2tfdmFsdWUEpGZyb208pHR5cGWmU3RhdGljqGludmVydGVywqNtaW48q2Rlc3luY190eXBlplN0YXRpY6h5YXdfbW9kZaZTdGF0aWOodGlja2Jhc2WpTmV2ZXJsb3Nlp2RlbGF5XzYCqnlhd19vZmZzZXQAqG1vZGlmaWVyqERpc2FibGVkqnRpY2tiYXNlXzUCsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzYCp2RlbGF5XzgCp2RlbGF5XzECsnRpY2tiYXNlX3JuZG1fdHlwZadEZWZhdWx0qnRpY2tiYXNlXzcCq3lhd19tb2RlX2V4iLBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAKtvZmZzZXRfbGVmdACzZGVsYXlfc2xpZGVyX2NyZWF0ZQKsb2Zmc2V0X3JpZ2h0AK1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluAq90aWNrYmFzZV9ybmRtXzIQsHRpY2tiYXNlX3NsaWRlcnMDqnRpY2tiYXNlXzgCrXRpY2tiYXNlX3JuZG0Qp2RlbGF5XzICpGJvZHnDp2RlbGF5XzcCPYyoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNACoc2xpZGVyXzUAqXJhbmRvbWl6ZcKoc2xpZGVyXzYApm9mZnNldACkbW9kZadEZWZhdWx0o21pbgCjbWF4AKhzbGlkZXJfMQCuY3VzdG9tX3NsaWRlcnMCPo+taml0dGVyX2J1dHRvbsOrdGlja19zbGlkZXIEqmxlZnRfbGltaXQ8r2xlZnRfdGlja19saW1pdDyrcmlnaHRfbGltaXQ8sHJpZ2h0X3RpY2tfbGltaXQ8sXR5cGVfcmFuZG9tX3ZhbHVlAqJ0bzyjbWF4PK90eXBlX3RpY2tfdmFsdWUEpGZyb208pHR5cGWmU3RhdGljqGludmVydGVywqNtaW48q2Rlc3luY190eXBlplN0YXRpYz+IsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUAq29mZnNldF9sZWZ0ALNkZWxheV9zbGlkZXJfY3JlYXRlAqxvZmZzZXRfcmlnaHQArWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4CQN4AHqp0aWNrYmFzZV8xAqdkZWxheV8zAqp0aWNrYmFzZV8yAqdkZWxheV80Aqp0aWNrYmFzZV80ArBtb2RpZmllcl9vcHRpb25zjKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80AKhzbGlkZXJfNQCpcmFuZG9taXplwqhzbGlkZXJfNgCmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSjbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwKqdGlja2Jhc2VfMwKnZGVsYXlfNQKsYm9keV9vcHRpb25zj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmU3RhdGljqHlhd19tb2RlplN0YXRpY6h0aWNrYmFzZalOZXZlcmxvc2WnZGVsYXlfNgKqeWF3X29mZnNldACobW9kaWZpZXKoRGlzYWJsZWSqdGlja2Jhc2VfNQKydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNgKnZGVsYXlfOAKnZGVsYXlfMQKydGlja2Jhc2Vfcm5kbV90eXBlp0RlZmF1bHSqdGlja2Jhc2VfNwKreWF3X21vZGVfZXiIsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUAq29mZnNldF9sZWZ0ALNkZWxheV9zbGlkZXJfY3JlYXRlAqxvZmZzZXRfcmlnaHQArWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4Cr3RpY2tiYXNlX3JuZG1fMhCwdGlja2Jhc2Vfc2xpZGVycwOqdGlja2Jhc2VfOAKtdGlja2Jhc2Vfcm5kbRCnZGVsYXlfMgKkYm9kecOnZGVsYXlfNwJBjKhzbGlkZXJfMgCoc2xpZGVyXzMAqHNsaWRlcl80AKhzbGlkZXJfNQCpcmFuZG9taXplwqhzbGlkZXJfNgCmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSjbWluAKNtYXgAqHNsaWRlcl8xAK5jdXN0b21fc2xpZGVycwJCj61qaXR0ZXJfYnV0dG9uw6t0aWNrX3NsaWRlcgSqbGVmdF9saW1pdDyvbGVmdF90aWNrX2xpbWl0PKtyaWdodF9saW1pdDywcmlnaHRfdGlja19saW1pdDyxdHlwZV9yYW5kb21fdmFsdWUConRvPKNtYXg8r3R5cGVfdGlja192YWx1ZQSkZnJvbTykdHlwZaZTdGF0aWOoaW52ZXJ0ZXLCo21pbjyrZGVzeW5jX3R5cGWmU3RhdGljQ4iwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQCrb2Zmc2V0X2xlZnQAs2RlbGF5X3NsaWRlcl9jcmVhdGUCrG9mZnNldF9yaWdodACtZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgJE3gAeqnRpY2tiYXNlXzECp2RlbGF5XzMCqnRpY2tiYXNlXzICp2RlbGF5XzQCqnRpY2tiYXNlXzQCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl8yAKhzbGlkZXJfMwCoc2xpZGVyXzQAqHNsaWRlcl81AKlyYW5kb21pemXCqHNsaWRlcl82AKZvZmZzZXQApG1vZGWnRGVmYXVsdKNtaW4Ao21heACoc2xpZGVyXzEArmN1c3RvbV9zbGlkZXJzAqp0aWNrYmFzZV8zAqdkZWxheV81Aqxib2R5X29wdGlvbnOPrWppdHRlcl9idXR0b27Dq3RpY2tfc2xpZGVyBKpsZWZ0X2xpbWl0PK9sZWZ0X3RpY2tfbGltaXQ8q3JpZ2h0X2xpbWl0PLByaWdodF90aWNrX2xpbWl0PLF0eXBlX3JhbmRvbV92YWx1ZQKidG88o21heDyvdHlwZV90aWNrX3ZhbHVlBKRmcm9tPKR0eXBlplN0YXRpY6hpbnZlcnRlcsOjbWluPKtkZXN5bmNfdHlwZaZTdGF0aWOoeWF3X21vZGWmU3RhdGljqHRpY2tiYXNlqU5ldmVybG9zZadkZWxheV82Aqp5YXdfb2Zmc2V0AKhtb2RpZmllcqhEaXNhYmxlZKp0aWNrYmFzZV81ArJ0aWNrYmFzZV9yYW5kb21pemXDrnRpY2tiYXNlX2Nob2tlEKp0aWNrYmFzZV82AqdkZWxheV84AqdkZWxheV8xArJ0aWNrYmFzZV9ybmRtX3R5cGWnRGVmYXVsdKp0aWNrYmFzZV83Aqt5YXdfbW9kZV9leIiwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQCrb2Zmc2V0X2xlZnQAs2RlbGF5X3NsaWRlcl9jcmVhdGUCrG9mZnNldF9yaWdodACtZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgKvdGlja2Jhc2Vfcm5kbV8yELB0aWNrYmFzZV9zbGlkZXJzA6p0aWNrYmFzZV84Aq10aWNrYmFzZV9ybmRtEKdkZWxheV8yAqRib2R5w6dkZWxheV83AkWMqHNsaWRlcl8yAKhzbGlkZXJfMwCoc2xpZGVyXzQAqHNsaWRlcl81AKlyYW5kb21pemXCqHNsaWRlcl82AKZvZmZzZXQApG1vZGWnRGVmYXVsdKNtaW4Ao21heACoc2xpZGVyXzEArmN1c3RvbV9zbGlkZXJzAkaPrWppdHRlcl9idXR0b27Dq3RpY2tfc2xpZGVyBKpsZWZ0X2xpbWl0PK9sZWZ0X3RpY2tfbGltaXQ8q3JpZ2h0X2xpbWl0PLByaWdodF90aWNrX2xpbWl0PLF0eXBlX3JhbmRvbV92YWx1ZQKidG88o21heDyvdHlwZV90aWNrX3ZhbHVlBKRmcm9tPKR0eXBlplN0YXRpY6hpbnZlcnRlcsOjbWluPKtkZXN5bmNfdHlwZaZTdGF0aWNHiLBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAKtvZmZzZXRfbGVmdACzZGVsYXlfc2xpZGVyX2NyZWF0ZQKsb2Zmc2V0X3JpZ2h0AK1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluAkjeAB6qdGlja2Jhc2VfMQKnZGVsYXlfMwKqdGlja2Jhc2VfMgKnZGVsYXlfNAKqdGlja2Jhc2VfNAKwbW9kaWZpZXJfb3B0aW9uc4yoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNACoc2xpZGVyXzUAqXJhbmRvbWl6ZcKoc2xpZGVyXzYApm9mZnNldACkbW9kZadEZWZhdWx0o21pbgCjbWF4AKhzbGlkZXJfMQCuY3VzdG9tX3NsaWRlcnMCqnRpY2tiYXNlXzMCp2RlbGF5XzUCrGJvZHlfb3B0aW9uc4+taml0dGVyX2J1dHRvbsOrdGlja19zbGlkZXIEqmxlZnRfbGltaXQ8r2xlZnRfdGlja19saW1pdDyrcmlnaHRfbGltaXQ8sHJpZ2h0X3RpY2tfbGltaXQ8sXR5cGVfcmFuZG9tX3ZhbHVlAqJ0bzyjbWF4PK90eXBlX3RpY2tfdmFsdWUEpGZyb208pHR5cGWmU3RhdGljqGludmVydGVyw6NtaW48q2Rlc3luY190eXBlplN0YXRpY6h5YXdfbW9kZaZTdGF0aWOodGlja2Jhc2WpTmV2ZXJsb3Nlp2RlbGF5XzYCqnlhd19vZmZzZXQAqG1vZGlmaWVyqERpc2FibGVkqnRpY2tiYXNlXzUCsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzYCp2RlbGF5XzgCp2RlbGF5XzECsnRpY2tiYXNlX3JuZG1fdHlwZadEZWZhdWx0qnRpY2tiYXNlXzcCq3lhd19tb2RlX2V4iLBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAKtvZmZzZXRfbGVmdACzZGVsYXlfc2xpZGVyX2NyZWF0ZQKsb2Zmc2V0X3JpZ2h0AK1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluAq90aWNrYmFzZV9ybmRtXzIQsHRpY2tiYXNlX3NsaWRlcnMDqnRpY2tiYXNlXzgCrXRpY2tiYXNlX3JuZG0Qp2RlbGF5XzICpGJvZHnDp2RlbGF5XzcCSYyoc2xpZGVyXzIAqHNsaWRlcl8zAKhzbGlkZXJfNACoc2xpZGVyXzUAqXJhbmRvbWl6ZcKoc2xpZGVyXzYApm9mZnNldACkbW9kZadEZWZhdWx0o21pbgCjbWF4AKhzbGlkZXJfMQCuY3VzdG9tX3NsaWRlcnMCSo+taml0dGVyX2J1dHRvbsOrdGlja19zbGlkZXIEqmxlZnRfbGltaXQ8r2xlZnRfdGlja19saW1pdDyrcmlnaHRfbGltaXQ8sHJpZ2h0X3RpY2tfbGltaXQ8sXR5cGVfcmFuZG9tX3ZhbHVlAqJ0bzyjbWF4PK90eXBlX3RpY2tfdmFsdWUEpGZyb208pHR5cGWmU3RhdGljqGludmVydGVyw6NtaW48q2Rlc3luY190eXBlplN0YXRpY0uIsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUAq29mZnNldF9sZWZ0ALNkZWxheV9zbGlkZXJfY3JlYXRlAqxvZmZzZXRfcmlnaHQArWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4CrV9fd2F0ZXJtYXJrX3jNBQCtX193YXRlcm1hcmtfec0Fkg==", 
            [3] = "3gBNAYSucHJlc2V0X2J1dHRvbnOCq3NhdmVfc3dpdGNowq1oaWRkZW5fc3dpdGNowqtwcmVzZXRfbGlzdAascHJlc2V0X2lucHV0pDEzMTKud2F0ZXJtYXJrX2dlYXKEpWlucHV0syRFTlNFQCNAQCNAI0AjQCNHT0SkZm9udKdEZWZhdWx0rGFjY2VudF9jb2xvcpOmU3RhdGljqSNGRjAwMDBGRqF+pG1vZGWRoX4CiKpmc19hbGxvd2Vzwq13YXJtdXBfYWFfdGJsh6tsZWZ0X29mZnNldAClcmFuZ2XNAWilc3BlZWQCo3lhd6RTcGlupG1vZGWRoX6lcGl0Y2ioRGlzYWJsZWSscmlnaHRfb2Zmc2V0AK5mb3JjZV9icmVha19sY5jZJAd7TGluayBBY3RpdmV94oCiICAgB0RFRkFVTFRTdGFuZGluZ9kjB3tMaW5rIEFjdGl2ZX3igKIgICAHREVGQVVMVFJ1bm5pbmfZIwd7TGluayBBY3RpdmV94oCiICAgB0RFRkFVTFRTbG93aW5n2SUHe0xpbmsgQWN0aXZlfeKAoiAgIAdERUZBVUxUQ3JvdWNoaW5n2ScHe0xpbmsgQWN0aXZlfeKAoiAgIAdERUZBVUxUTW92ZSBDcm91Y2i/B3tMaW5rIEFjdGl2ZX3igKIgICAHREVGQVVMVEFpctkmB3tMaW5rIEFjdGl2ZX3igKIgICAHREVGQVVMVEFpciBDcm91Y2ihfqZzdGF0ZXMDqnNlbGVjdGFibGUBtmZvcmNlX2JyZWFrX2xjX29wdGlvbnOCsmRpc2FibGVfb25fZ3JlbmFkZcKqaGlkZV9zaG90c69GYXZvciBGaXJlIFJhdGWldGVhbXMBrG9wdGlvbnNfZ2VhcoanbWFudWFsc6hEaXNhYmxlZKdib2R5X2ZzwqxmcmVlc3RhbmRpbmfCqWRpc2FibGVyc5GhfqlzYWZlX2hlYWSRoX6uYXZvaWRfYmFja3N0YWLCA94ALK9ncmVuYWRlX3JlbGVhc2XCqmVhcnRocXVha2XCr2xvZ19ldmVudHNfbW9kZZKuUmFnZWJvdCBFdmVudHOhfql2aWV3bW9kZWzDt2xvZ19ldmVudHNfcHJlZml4X2NvbG9yqSNGRkZGRkZGRrVsb2dfZXZlbnRzX21haW5fY29sb3KpI0ZGRkZGRkFGsWxvZ19ldmVudHNfcHJlZml4rWdvZHNlbnNlIGJldGG2bG9nX2V2ZW50c19hbHRlcm5hdGl2ZcOyZG1nX2luZGljYXRvcl9tb2Rlp0RlZmF1bHSqfnZpZXdtb2RlbIepbWFpbl9oYW5kqlJpZ2h0IHNpZGWob2Zmc2V0X3gAqWxlZnRfaGFuZMKjZm92RKpyaWdodF9oYW5kwqhvZmZzZXRfegCob2Zmc2V0X3kArH5qaXR0ZXJfbGVnc4KkZnJvbRSidG9jrmhpdG1hcmtlcl90aW1lAq5+aW50ZXJwb2xhdGluZ4Glc2NhbGUOsGhpdG1hcmtlcl9jb2xvcjKpI0ZGRkZGRkZGrXNjb3BlX292ZXJsYXnCr2hpdG1hcmtlcl90aW1lMgKtbWFudWFsX2Fycm93c8K1c2NvcGVfb3ZlcmxheV9vcHRpb25zkaF+tHNjb3BlX292ZXJsYXlfbGVuZ3RozLmpaGl0bWFya2VykaF+sXNjb3BlX292ZXJsYXlfZ2FwBbNzY29wZV9vdmVybGF5X2NvbG9yqSNGRkZGRkZGRq1kbWdfaW5kaWNhdG9ywrJzY29wZV9vdmVybGF5X2VkZ2WpI0ZGRkZGRjAwrnVubG9ja19sYXRlbmN5wq1hcnJvd3NfYWNjZW50qSNGRkZGRkZGRrNmcmVlemV0aW1lX2Zha2VkdWNrw65hcnJvd3NfZm9yd2FyZKFer3VubG9ja19mZF9zcGVlZMOrYXJyb3dzX2xlZnShPKpsb2dfZXZlbnRzw65ub19mYWxsX2RhbWFnZcOrZmFzdF9sYWRkZXLDq2ppdHRlcl9sZWdzwqxhc3BlY3RfcmF0aW/DrWludGVycG9sYXRpbmfCr2hpdG1hcmtlcl9jb2xvcqkjRkZGRkZGOEOtfmFzcGVjdF9yYXRpb4Glc2NhbGXMhaxhcnJvd3NfcmlnaHShPqthcnJvd3NfZm9udKdEZWZhdWx0qXN1cGVydG9zc8KnbGVhbmluZwC3a2VlcF9tb2RlbF90cmFuc3BhcmVuY3nCp2ZhbGxpbmcABN4AHqdkZWxheV84Aqp0aWNrYmFzZV83Aqp0aWNrYmFzZV8yArB0aWNrYmFzZV9zbGlkZXJzA6dkZWxheV8xAqhtb2RpZmllcqUzLVdheadkZWxheV8yAq10aWNrYmFzZV9ybmRtEKRib2R5w6p0aWNrYmFzZV8xAqdkZWxheV8zAqt5YXdfbW9kZV9leIisb2Zmc2V0X3JpZ2h0Hq1kZWxheV9kZWZhdWx0FKp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluArBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAatvZmZzZXRfbGVmdPazZGVsYXlfc2xpZGVyX2NyZWF0ZQKydGlja2Jhc2Vfcm5kbV90eXBlp0RlZmF1bHSoeWF3X21vZGWqTGVmdC9SaWdodKdkZWxheV80Aqp0aWNrYmFzZV84Aqp5YXdfb2Zmc2V0AKp0aWNrYmFzZV8zAqdkZWxheV81ArJ0aWNrYmFzZV9yYW5kb21pemXDrnRpY2tiYXNlX2Nob2tlEKp0aWNrYmFzZV80AqdkZWxheV82ArBtb2RpZmllcl9vcHRpb25zjKhzbGlkZXJfNACuY3VzdG9tX3NsaWRlcnMCpm9mZnNldOqkbW9kZadEZWZhdWx0qHNsaWRlcl82AKNtaW4AqHNsaWRlcl8xAKlyYW5kb21pemXCqHNsaWRlcl8yAKhzbGlkZXJfNQCoc2xpZGVyXzMAo21heACsYm9keV9vcHRpb25zj7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWmU3RhdGljr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG88q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDykZnJvbTyrcmlnaHRfbGltaXQ8pHR5cGWmU3RhdGljqnRpY2tiYXNlXzUCp2RlbGF5XzcCr3RpY2tiYXNlX3JuZG1fMhCqdGlja2Jhc2VfNgKodGlja2Jhc2WpTmV2ZXJsb3NlBYyoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzAqZvZmZzZXTqpG1vZGWnRGVmYXVsdKhzbGlkZXJfNgCjbWluAKhzbGlkZXJfMQCpcmFuZG9taXplwqhzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXgABo+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlplN0YXRpY690eXBlX3RpY2tfdmFsdWUEr2xlZnRfdGlja19saW1pdDyoaW52ZXJ0ZXLConRvPKt0aWNrX3NsaWRlcgStaml0dGVyX2J1dHRvbsOjbWluPKNtYXg8sHJpZ2h0X3RpY2tfbGltaXQ8qmxlZnRfbGltaXQ8pGZyb208q3JpZ2h0X2xpbWl0PKR0eXBlplN0YXRpYweIrG9mZnNldF9yaWdodB6tZGVsYXlfZGVmYXVsdBSqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgKwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQGrb2Zmc2V0X2xlZnT2s2RlbGF5X3NsaWRlcl9jcmVhdGUCCN4AHqdkZWxheV84Aqp0aWNrYmFzZV83Aqp0aWNrYmFzZV8yArB0aWNrYmFzZV9zbGlkZXJzA6dkZWxheV8xAqhtb2RpZmllcqUzLVdheadkZWxheV8yAq10aWNrYmFzZV9ybmRtEKRib2R5w6p0aWNrYmFzZV8xAqdkZWxheV8zAqt5YXdfbW9kZV9leIisb2Zmc2V0X3JpZ2h0Hq1kZWxheV9kZWZhdWx0FKp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluArBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAatvZmZzZXRfbGVmdPazZGVsYXlfc2xpZGVyX2NyZWF0ZQKydGlja2Jhc2Vfcm5kbV90eXBlp0RlZmF1bHSoeWF3X21vZGWqTGVmdC9SaWdodKdkZWxheV80Aqp0aWNrYmFzZV84Aqp5YXdfb2Zmc2V0AKp0aWNrYmFzZV8zAqdkZWxheV81ArJ0aWNrYmFzZV9yYW5kb21pemXDrnRpY2tiYXNlX2Nob2tlEKp0aWNrYmFzZV80AqdkZWxheV82ArBtb2RpZmllcl9vcHRpb25zjKhzbGlkZXJfNACuY3VzdG9tX3NsaWRlcnMCpm9mZnNldACkbW9kZadEZWZhdWx0qHNsaWRlcl82AKNtaW4AqHNsaWRlcl8xAKlyYW5kb21pemXCqHNsaWRlcl8yAKhzbGlkZXJfNQCoc2xpZGVyXzMAo21heACsYm9keV9vcHRpb25zj7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWmU3RhdGljr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG88q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDykZnJvbTyrcmlnaHRfbGltaXQ8pHR5cGWmU3RhdGljqnRpY2tiYXNlXzUCp2RlbGF5XzcCr3RpY2tiYXNlX3JuZG1fMhCqdGlja2Jhc2VfNgKodGlja2Jhc2WpTmV2ZXJsb3NlCYyoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzAqZvZmZzZXQApG1vZGWnRGVmYXVsdKhzbGlkZXJfNgCjbWluAKhzbGlkZXJfMQCpcmFuZG9taXplwqhzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXgACo+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlplN0YXRpY690eXBlX3RpY2tfdmFsdWUEr2xlZnRfdGlja19saW1pdDyoaW52ZXJ0ZXLConRvPKt0aWNrX3NsaWRlcgStaml0dGVyX2J1dHRvbsOjbWluPKNtYXg8sHJpZ2h0X3RpY2tfbGltaXQ8qmxlZnRfbGltaXQ8pGZyb208q3JpZ2h0X2xpbWl0PKR0eXBlplN0YXRpYwuIrG9mZnNldF9yaWdodB6tZGVsYXlfZGVmYXVsdBSqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgKwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQGrb2Zmc2V0X2xlZnT2s2RlbGF5X3NsaWRlcl9jcmVhdGUCDN4AHqdkZWxheV84Aqp0aWNrYmFzZV83Aqp0aWNrYmFzZV8yArB0aWNrYmFzZV9zbGlkZXJzA6dkZWxheV8xAqhtb2RpZmllcqhEaXNhYmxlZKdkZWxheV8yBa10aWNrYmFzZV9ybmRtEKRib2R5w6p0aWNrYmFzZV8xAqdkZWxheV8zA6t5YXdfbW9kZV9leIisb2Zmc2V0X3JpZ2h0Ia1kZWxheV9kZWZhdWx0Bap5YXdfcmFuZG9tIbBkZWxheV9yYW5kb21fbWluArBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAatvZmZzZXRfbGVmdOKzZGVsYXlfc2xpZGVyX2NyZWF0ZQOydGlja2Jhc2Vfcm5kbV90eXBlp0RlZmF1bHSoeWF3X21vZGWqTGVmdC9SaWdodKdkZWxheV80Aqp0aWNrYmFzZV84Aqp5YXdfb2Zmc2V0AKp0aWNrYmFzZV8zAqdkZWxheV81ArJ0aWNrYmFzZV9yYW5kb21pemXDrnRpY2tiYXNlX2Nob2tlEKp0aWNrYmFzZV80AqdkZWxheV82ArBtb2RpZmllcl9vcHRpb25zjKhzbGlkZXJfNACuY3VzdG9tX3NsaWRlcnMCpm9mZnNldACkbW9kZadEZWZhdWx0qHNsaWRlcl82AKNtaW4AqHNsaWRlcl8xAKlyYW5kb21pemXCqHNsaWRlcl8yAKhzbGlkZXJfNQCoc2xpZGVyXzMAo21heACsYm9keV9vcHRpb25zj7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWmU3RhdGljr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG88q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDmkZnJvbTyrcmlnaHRfbGltaXQ4pHR5cGWmU3RhdGljqnRpY2tiYXNlXzUCp2RlbGF5XzcCr3RpY2tiYXNlX3JuZG1fMhCqdGlja2Jhc2VfNgKodGlja2Jhc2WpTmV2ZXJsb3NlDYyoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzAqZvZmZzZXQApG1vZGWnRGVmYXVsdKhzbGlkZXJfNgCjbWluAKhzbGlkZXJfMQCpcmFuZG9taXplwqhzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXgADo+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlplN0YXRpY690eXBlX3RpY2tfdmFsdWUEr2xlZnRfdGlja19saW1pdDyoaW52ZXJ0ZXLConRvPKt0aWNrX3NsaWRlcgStaml0dGVyX2J1dHRvbsOjbWluPKNtYXg8sHJpZ2h0X3RpY2tfbGltaXQ8qmxlZnRfbGltaXQ5pGZyb208q3JpZ2h0X2xpbWl0OKR0eXBlplN0YXRpYw+IrG9mZnNldF9yaWdodCGtZGVsYXlfZGVmYXVsdAWqeWF3X3JhbmRvbSGwZGVsYXlfcmFuZG9tX21pbgKwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQGrb2Zmc2V0X2xlZnTis2RlbGF5X3NsaWRlcl9jcmVhdGUDEN4AHqdkZWxheV84Aqp0aWNrYmFzZV83Aqp0aWNrYmFzZV8yArB0aWNrYmFzZV9zbGlkZXJzA6dkZWxheV8xAqhtb2RpZmllcqhEaXNhYmxlZKdkZWxheV8yBa10aWNrYmFzZV9ybmRtEKRib2R5w6p0aWNrYmFzZV8xAqdkZWxheV8zA6t5YXdfbW9kZV9leIisb2Zmc2V0X3JpZ2h0Ia1kZWxheV9kZWZhdWx0Bap5YXdfcmFuZG9tIbBkZWxheV9yYW5kb21fbWluArBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAatvZmZzZXRfbGVmdOKzZGVsYXlfc2xpZGVyX2NyZWF0ZQOydGlja2Jhc2Vfcm5kbV90eXBlp0RlZmF1bHSoeWF3X21vZGWqTGVmdC9SaWdodKdkZWxheV80Aqp0aWNrYmFzZV84Aqp5YXdfb2Zmc2V0AKp0aWNrYmFzZV8zAqdkZWxheV81ArJ0aWNrYmFzZV9yYW5kb21pemXDrnRpY2tiYXNlX2Nob2tlEKp0aWNrYmFzZV80AqdkZWxheV82ArBtb2RpZmllcl9vcHRpb25zjKhzbGlkZXJfNACuY3VzdG9tX3NsaWRlcnMCpm9mZnNldACkbW9kZadEZWZhdWx0qHNsaWRlcl82AKNtaW4AqHNsaWRlcl8xAKlyYW5kb21pemXCqHNsaWRlcl8yAKhzbGlkZXJfNQCoc2xpZGVyXzMAo21heACsYm9keV9vcHRpb25zj7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWmU3RhdGljr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG88q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDmkZnJvbTyrcmlnaHRfbGltaXQ4pHR5cGWmU3RhdGljqnRpY2tiYXNlXzUCp2RlbGF5XzcCr3RpY2tiYXNlX3JuZG1fMhCqdGlja2Jhc2VfNgKodGlja2Jhc2WpTmV2ZXJsb3NlEYyoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzAqZvZmZzZXQApG1vZGWnRGVmYXVsdKhzbGlkZXJfNgCjbWluAKhzbGlkZXJfMQCpcmFuZG9taXplwqhzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXgAEo+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlplN0YXRpY690eXBlX3RpY2tfdmFsdWUEr2xlZnRfdGlja19saW1pdDyoaW52ZXJ0ZXLConRvPKt0aWNrX3NsaWRlcgStaml0dGVyX2J1dHRvbsOjbWluPKNtYXg8sHJpZ2h0X3RpY2tfbGltaXQ8qmxlZnRfbGltaXQ5pGZyb208q3JpZ2h0X2xpbWl0OKR0eXBlplN0YXRpYxOIrG9mZnNldF9yaWdodCGtZGVsYXlfZGVmYXVsdAWqeWF3X3JhbmRvbSGwZGVsYXlfcmFuZG9tX21pbgKwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQGrb2Zmc2V0X2xlZnTis2RlbGF5X3NsaWRlcl9jcmVhdGUDFN4AHqdkZWxheV84Aqp0aWNrYmFzZV83Aqp0aWNrYmFzZV8yArB0aWNrYmFzZV9zbGlkZXJzA6dkZWxheV8xAqhtb2RpZmllcqZSYW5kb22nZGVsYXlfMgKtdGlja2Jhc2Vfcm5kbRCkYm9kecOqdGlja2Jhc2VfMQKnZGVsYXlfMwKreWF3X21vZGVfZXiIrG9mZnNldF9yaWdodCmtZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbS2wZGVsYXlfcmFuZG9tX21pbgmwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQKrb2Zmc2V0X2xlZnThs2RlbGF5X3NsaWRlcl9jcmVhdGUCsnRpY2tiYXNlX3JuZG1fdHlwZadEZWZhdWx0qHlhd19tb2RlqkxlZnQvUmlnaHSnZGVsYXlfNAKqdGlja2Jhc2VfOAKqeWF3X29mZnNldACqdGlja2Jhc2VfMwKnZGVsYXlfNQKydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNAKnZGVsYXlfNgKwbW9kaWZpZXJfb3B0aW9uc4yoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzAqZvZmZzZXT1pG1vZGWnRGVmYXVsdKhzbGlkZXJfNgCjbWluAKhzbGlkZXJfMQCpcmFuZG9taXplwqhzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXgArGJvZHlfb3B0aW9uc4+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlplN0YXRpY690eXBlX3RpY2tfdmFsdWUEr2xlZnRfdGlja19saW1pdDyoaW52ZXJ0ZXLConRvPKt0aWNrX3NsaWRlcgStaml0dGVyX2J1dHRvbsOjbWluPKNtYXg8sHJpZ2h0X3RpY2tfbGltaXQ8qmxlZnRfbGltaXQ8pGZyb208q3JpZ2h0X2xpbWl0PKR0eXBlplN0YXRpY6p0aWNrYmFzZV81AqdkZWxheV83Aq90aWNrYmFzZV9ybmRtXzIQqnRpY2tiYXNlXzYCqHRpY2tiYXNlqU5ldmVybG9zZRWMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwKmb2Zmc2V09aRtb2Rlp0RlZmF1bHSoc2xpZGVyXzYAo21pbgCoc2xpZGVyXzEAqXJhbmRvbWl6ZcKoc2xpZGVyXzIAqHNsaWRlcl81AKhzbGlkZXJfMwCjbWF4ABaPsXR5cGVfcmFuZG9tX3ZhbHVlAqtkZXN5bmNfdHlwZaZTdGF0aWOvdHlwZV90aWNrX3ZhbHVlBK9sZWZ0X3RpY2tfbGltaXQ8qGludmVydGVywqJ0bzyrdGlja19zbGlkZXIErWppdHRlcl9idXR0b27Do21pbjyjbWF4PLByaWdodF90aWNrX2xpbWl0PKpsZWZ0X2xpbWl0PKRmcm9tPKtyaWdodF9saW1pdDykdHlwZaZTdGF0aWMXiKxvZmZzZXRfcmlnaHQprWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20tsGRlbGF5X3JhbmRvbV9taW4JsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUCq29mZnNldF9sZWZ04bNkZWxheV9zbGlkZXJfY3JlYXRlAhjeAB6nZGVsYXlfOAKqdGlja2Jhc2VfNwKqdGlja2Jhc2VfMgKwdGlja2Jhc2Vfc2xpZGVycwOnZGVsYXlfMQKobW9kaWZpZXKmUmFuZG9tp2RlbGF5XzICrXRpY2tiYXNlX3JuZG0QpGJvZHnDqnRpY2tiYXNlXzECp2RlbGF5XzMCq3lhd19tb2RlX2V4iKxvZmZzZXRfcmlnaHQprWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20tsGRlbGF5X3JhbmRvbV9taW4JsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUCq29mZnNldF9sZWZ04bNkZWxheV9zbGlkZXJfY3JlYXRlArJ0aWNrYmFzZV9ybmRtX3R5cGWnRGVmYXVsdKh5YXdfbW9kZapMZWZ0L1JpZ2h0p2RlbGF5XzQCqnRpY2tiYXNlXzgCqnlhd19vZmZzZXQAqnRpY2tiYXNlXzMCp2RlbGF5XzUCsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzQCp2RlbGF5XzYCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwKmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSoc2xpZGVyXzYAo21pbgCoc2xpZGVyXzEAqXJhbmRvbWl6ZcKoc2xpZGVyXzIAqHNsaWRlcl81AKhzbGlkZXJfMwCjbWF4AKxib2R5X29wdGlvbnOPsXR5cGVfcmFuZG9tX3ZhbHVlAqtkZXN5bmNfdHlwZaZTdGF0aWOvdHlwZV90aWNrX3ZhbHVlBK9sZWZ0X3RpY2tfbGltaXQ8qGludmVydGVywqJ0bzyrdGlja19zbGlkZXIErWppdHRlcl9idXR0b27Do21pbjyjbWF4PLByaWdodF90aWNrX2xpbWl0PKpsZWZ0X2xpbWl0PKRmcm9tPKtyaWdodF9saW1pdDykdHlwZaZTdGF0aWOqdGlja2Jhc2VfNQKnZGVsYXlfNwKvdGlja2Jhc2Vfcm5kbV8yEKp0aWNrYmFzZV82Aqh0aWNrYmFzZalOZXZlcmxvc2UZjKhzbGlkZXJfNACuY3VzdG9tX3NsaWRlcnMCpm9mZnNldACkbW9kZadEZWZhdWx0qHNsaWRlcl82AKNtaW4AqHNsaWRlcl8xAKlyYW5kb21pemXCqHNsaWRlcl8yAKhzbGlkZXJfNQCoc2xpZGVyXzMAo21heAAaj7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWmU3RhdGljr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG88q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDykZnJvbTyrcmlnaHRfbGltaXQ8pHR5cGWmU3RhdGljG4isb2Zmc2V0X3JpZ2h0Ka1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tLbBkZWxheV9yYW5kb21fbWluCbBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAqtvZmZzZXRfbGVmdOGzZGVsYXlfc2xpZGVyX2NyZWF0ZQIc3gAep2RlbGF5XzgCqnRpY2tiYXNlXzcCqnRpY2tiYXNlXzICsHRpY2tiYXNlX3NsaWRlcnMDp2RlbGF5XzECqG1vZGlmaWVypTMtV2F5p2RlbGF5XzICrXRpY2tiYXNlX3JuZG0QpGJvZHnDqnRpY2tiYXNlXzECp2RlbGF5XzMCq3lhd19tb2RlX2V4iKxvZmZzZXRfcmlnaHQarWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20YsGRlbGF5X3JhbmRvbV9taW4HsGRlbGF5X3JhbmRvbV9tYXgFqmRlbGF5X21vZGUCq29mZnNldF9sZWZ08rNkZWxheV9zbGlkZXJfY3JlYXRlArJ0aWNrYmFzZV9ybmRtX3R5cGWnRGVmYXVsdKh5YXdfbW9kZapMZWZ0L1JpZ2h0p2RlbGF5XzQCqnRpY2tiYXNlXzgCqnlhd19vZmZzZXQAqnRpY2tiYXNlXzMCp2RlbGF5XzUCsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzQCp2RlbGF5XzYCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwSmb2Zmc2V0/qRtb2RlpkN1c3RvbahzbGlkZXJfNgCjbWluBKhzbGlkZXJfMQCpcmFuZG9taXplw6hzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXgArGJvZHlfb3B0aW9uc4+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlplN0YXRpY690eXBlX3RpY2tfdmFsdWUEr2xlZnRfdGlja19saW1pdDyoaW52ZXJ0ZXLConRvPKt0aWNrX3NsaWRlcgStaml0dGVyX2J1dHRvbsOjbWluPKNtYXg8sHJpZ2h0X3RpY2tfbGltaXQ8qmxlZnRfbGltaXQ8pGZyb208q3JpZ2h0X2xpbWl0PKR0eXBlplN0YXRpY6p0aWNrYmFzZV81AqdkZWxheV83Aq90aWNrYmFzZV9ybmRtXzIQqnRpY2tiYXNlXzYCqHRpY2tiYXNlqEFkdmFuY2VkHYyoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzBKZvZmZzZXT+pG1vZGWmQ3VzdG9tqHNsaWRlcl82AKNtaW4EqHNsaWRlcl8xAKlyYW5kb21pemXDqHNsaWRlcl8yAKhzbGlkZXJfNQCoc2xpZGVyXzMAo21heAAej7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWmU3RhdGljr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG88q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDykZnJvbTyrcmlnaHRfbGltaXQ8pHR5cGWmU3RhdGljH4isb2Zmc2V0X3JpZ2h0Gq1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tGLBkZWxheV9yYW5kb21fbWluB7BkZWxheV9yYW5kb21fbWF4BapkZWxheV9tb2RlAqtvZmZzZXRfbGVmdPKzZGVsYXlfc2xpZGVyX2NyZWF0ZQIg3gAep2RlbGF5XzgCqnRpY2tiYXNlXzcCqnRpY2tiYXNlXzICsHRpY2tiYXNlX3NsaWRlcnMDp2RlbGF5XzECqG1vZGlmaWVypTMtV2F5p2RlbGF5XzICrXRpY2tiYXNlX3JuZG0QpGJvZHnDqnRpY2tiYXNlXzECp2RlbGF5XzMCq3lhd19tb2RlX2V4iKxvZmZzZXRfcmlnaHQarWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20YsGRlbGF5X3JhbmRvbV9taW4HsGRlbGF5X3JhbmRvbV9tYXgFqmRlbGF5X21vZGUCq29mZnNldF9sZWZ08rNkZWxheV9zbGlkZXJfY3JlYXRlArJ0aWNrYmFzZV9ybmRtX3R5cGWnRGVmYXVsdKh5YXdfbW9kZapMZWZ0L1JpZ2h0p2RlbGF5XzQCqnRpY2tiYXNlXzgCqnlhd19vZmZzZXQAqnRpY2tiYXNlXzMCp2RlbGF5XzUCsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzQCp2RlbGF5XzYCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwSmb2Zmc2V0AKRtb2RlpkN1c3RvbahzbGlkZXJfNgCjbWluBKhzbGlkZXJfMQCpcmFuZG9taXplw6hzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXgArGJvZHlfb3B0aW9uc4+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlplN0YXRpY690eXBlX3RpY2tfdmFsdWUEr2xlZnRfdGlja19saW1pdDyoaW52ZXJ0ZXLConRvPKt0aWNrX3NsaWRlcgStaml0dGVyX2J1dHRvbsOjbWluPKNtYXg8sHJpZ2h0X3RpY2tfbGltaXQ8qmxlZnRfbGltaXQ8pGZyb208q3JpZ2h0X2xpbWl0PKR0eXBlplN0YXRpY6p0aWNrYmFzZV81AqdkZWxheV83Aq90aWNrYmFzZV9ybmRtXzIQqnRpY2tiYXNlXzYCqHRpY2tiYXNlqEFkdmFuY2VkIYyoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzBKZvZmZzZXQApG1vZGWmQ3VzdG9tqHNsaWRlcl82AKNtaW4EqHNsaWRlcl8xAKlyYW5kb21pemXDqHNsaWRlcl8yAKhzbGlkZXJfNQCoc2xpZGVyXzMAo21heAAij7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWmU3RhdGljr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG88q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDykZnJvbTyrcmlnaHRfbGltaXQ8pHR5cGWmU3RhdGljI4isb2Zmc2V0X3JpZ2h0Gq1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tGLBkZWxheV9yYW5kb21fbWluB7BkZWxheV9yYW5kb21fbWF4BapkZWxheV9tb2RlAqtvZmZzZXRfbGVmdPKzZGVsYXlfc2xpZGVyX2NyZWF0ZQIk3gAep2RlbGF5XzgCqnRpY2tiYXNlXzcNqnRpY2tiYXNlXzIUsHRpY2tiYXNlX3NsaWRlcnMGp2RlbGF5XzECqG1vZGlmaWVypTMtV2F5p2RlbGF5XzICrXRpY2tiYXNlX3JuZG0QpGJvZHnDqnRpY2tiYXNlXzELp2RlbGF5XzMCq3lhd19tb2RlX2V4iKxvZmZzZXRfcmlnaHQirWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20XsGRlbGF5X3JhbmRvbV9taW4LsGRlbGF5X3JhbmRvbV9tYXgFqmRlbGF5X21vZGUCq29mZnNldF9sZWZ06bNkZWxheV9zbGlkZXJfY3JlYXRlArJ0aWNrYmFzZV9ybmRtX3R5cGWkV2F5c6h5YXdfbW9kZapMZWZ0L1JpZ2h0p2RlbGF5XzQCqnRpY2tiYXNlXzgMqnlhd19vZmZzZXQAqnRpY2tiYXNlXzMTp2RlbGF5XzUCsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzQLp2RlbGF5XzYCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwKmb2Zmc2V0B6Rtb2Rlp0RlZmF1bHSoc2xpZGVyXzYAo21pbg+oc2xpZGVyXzEAqXJhbmRvbWl6ZcOoc2xpZGVyXzIAqHNsaWRlcl81AKhzbGlkZXJfMwCjbWF486xib2R5X29wdGlvbnOPsXR5cGVfcmFuZG9tX3ZhbHVlAqtkZXN5bmNfdHlwZaZTdGF0aWOvdHlwZV90aWNrX3ZhbHVlBK9sZWZ0X3RpY2tfbGltaXQ8qGludmVydGVywqJ0bzyrdGlja19zbGlkZXIErWppdHRlcl9idXR0b27Do21pbjyjbWF4PLByaWdodF90aWNrX2xpbWl0PKpsZWZ0X2xpbWl0PKRmcm9tPKtyaWdodF9saW1pdDykdHlwZaZTdGF0aWOqdGlja2Jhc2VfNRKnZGVsYXlfNwKvdGlja2Jhc2Vfcm5kbV8yEKp0aWNrYmFzZV82Dqh0aWNrYmFzZahBZHZhbmNlZCWMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwKmb2Zmc2V0B6Rtb2Rlp0RlZmF1bHSoc2xpZGVyXzYAo21pbg+oc2xpZGVyXzEAqXJhbmRvbWl6ZcOoc2xpZGVyXzIAqHNsaWRlcl81AKhzbGlkZXJfMwCjbWF48yaPsXR5cGVfcmFuZG9tX3ZhbHVlAqtkZXN5bmNfdHlwZaZTdGF0aWOvdHlwZV90aWNrX3ZhbHVlBK9sZWZ0X3RpY2tfbGltaXQ8qGludmVydGVywqJ0bzyrdGlja19zbGlkZXIErWppdHRlcl9idXR0b27Do21pbjyjbWF4PLByaWdodF90aWNrX2xpbWl0PKpsZWZ0X2xpbWl0PKRmcm9tPKtyaWdodF9saW1pdDykdHlwZaZTdGF0aWMniKxvZmZzZXRfcmlnaHQirWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20XsGRlbGF5X3JhbmRvbV9taW4LsGRlbGF5X3JhbmRvbV9tYXgFqmRlbGF5X21vZGUCq29mZnNldF9sZWZ06bNkZWxheV9zbGlkZXJfY3JlYXRlAijeAB6nZGVsYXlfOAKqdGlja2Jhc2VfNw+qdGlja2Jhc2VfMg+wdGlja2Jhc2Vfc2xpZGVycwanZGVsYXlfMQKobW9kaWZpZXKlMy1XYXmnZGVsYXlfMgKtdGlja2Jhc2Vfcm5kbRCkYm9kecOqdGlja2Jhc2VfMQ6nZGVsYXlfMwKreWF3X21vZGVfZXiIrG9mZnNldF9yaWdodCitZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbSGwZGVsYXlfcmFuZG9tX21pbgiwZGVsYXlfcmFuZG9tX21heAaqZGVsYXlfbW9kZQKrb2Zmc2V0X2xlZnTrs2RlbGF5X3NsaWRlcl9jcmVhdGUCsnRpY2tiYXNlX3JuZG1fdHlwZaRXYXlzqHlhd19tb2RlqkxlZnQvUmlnaHSnZGVsYXlfNAKqdGlja2Jhc2VfOAyqeWF3X29mZnNldACqdGlja2Jhc2VfMxOnZGVsYXlfNQKydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNAunZGVsYXlfNgKwbW9kaWZpZXJfb3B0aW9uc4yoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzAqZvZmZzZXQApG1vZGWnRGVmYXVsdKhzbGlkZXJfNgCjbWluBahzbGlkZXJfMQCpcmFuZG9taXplw6hzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXj6rGJvZHlfb3B0aW9uc4+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlp0Zyb20vVG+vdHlwZV90aWNrX3ZhbHVlBK9sZWZ0X3RpY2tfbGltaXQ8qGludmVydGVywqJ0bzurdGlja19zbGlkZXIErWppdHRlcl9idXR0b27Do21pbjyjbWF4PLByaWdodF90aWNrX2xpbWl0PKpsZWZ0X2xpbWl0PKRmcm9tOKtyaWdodF9saW1pdDykdHlwZaZTdGF0aWOqdGlja2Jhc2VfNRGnZGVsYXlfNwKvdGlja2Jhc2Vfcm5kbV8yEKp0aWNrYmFzZV82Fah0aWNrYmFzZahBZHZhbmNlZCmMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwKmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSoc2xpZGVyXzYAo21pbgWoc2xpZGVyXzEAqXJhbmRvbWl6ZcOoc2xpZGVyXzIAqHNsaWRlcl81AKhzbGlkZXJfMwCjbWF4+iqPsXR5cGVfcmFuZG9tX3ZhbHVlAqtkZXN5bmNfdHlwZadGcm9tL1Rvr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG87q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDykZnJvbTircmlnaHRfbGltaXQ8pHR5cGWmU3RhdGljK4isb2Zmc2V0X3JpZ2h0KK1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tIbBkZWxheV9yYW5kb21fbWluCLBkZWxheV9yYW5kb21fbWF4BqpkZWxheV9tb2RlAqtvZmZzZXRfbGVmdOuzZGVsYXlfc2xpZGVyX2NyZWF0ZQIs3gAep2RlbGF5XzgCqnRpY2tiYXNlXzcCqnRpY2tiYXNlXzICsHRpY2tiYXNlX3NsaWRlcnMDp2RlbGF5XzECqG1vZGlmaWVyqERpc2FibGVkp2RlbGF5XzICrXRpY2tiYXNlX3JuZG0QpGJvZHnDqnRpY2tiYXNlXzECp2RlbGF5XzMCq3lhd19tb2RlX2V4iKxvZmZzZXRfcmlnaHQZrWRlbGF5X2RlZmF1bHQGqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4CsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUBq29mZnNldF9sZWZ08LNkZWxheV9zbGlkZXJfY3JlYXRlArJ0aWNrYmFzZV9ybmRtX3R5cGWnRGVmYXVsdKh5YXdfbW9kZapMZWZ0L1JpZ2h0p2RlbGF5XzQCqnRpY2tiYXNlXzgCqnlhd19vZmZzZXQAqnRpY2tiYXNlXzMCp2RlbGF5XzUCsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzQCp2RlbGF5XzYCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwKmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSoc2xpZGVyXzYAo21pbgCoc2xpZGVyXzEAqXJhbmRvbWl6ZcKoc2xpZGVyXzIAqHNsaWRlcl81AKhzbGlkZXJfMwCjbWF4AKxib2R5X29wdGlvbnOPsXR5cGVfcmFuZG9tX3ZhbHVlAqtkZXN5bmNfdHlwZaZTdGF0aWOvdHlwZV90aWNrX3ZhbHVlBK9sZWZ0X3RpY2tfbGltaXQ8qGludmVydGVywqJ0bzyrdGlja19zbGlkZXIErWppdHRlcl9idXR0b27Do21pbjyjbWF4PLByaWdodF90aWNrX2xpbWl0PKpsZWZ0X2xpbWl0PKRmcm9tPKtyaWdodF9saW1pdDykdHlwZaZTdGF0aWOqdGlja2Jhc2VfNQKnZGVsYXlfNwKvdGlja2Jhc2Vfcm5kbV8yEKp0aWNrYmFzZV82Aqh0aWNrYmFzZalOZXZlcmxvc2UtjKhzbGlkZXJfNACuY3VzdG9tX3NsaWRlcnMCpm9mZnNldACkbW9kZadEZWZhdWx0qHNsaWRlcl82AKNtaW4AqHNsaWRlcl8xAKlyYW5kb21pemXCqHNsaWRlcl8yAKhzbGlkZXJfNQCoc2xpZGVyXzMAo21heAAuj7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWmU3RhdGljr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG88q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDykZnJvbTyrcmlnaHRfbGltaXQ8pHR5cGWmU3RhdGljL4isb2Zmc2V0X3JpZ2h0Ga1kZWxheV9kZWZhdWx0Bqp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluArBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAatvZmZzZXRfbGVmdPCzZGVsYXlfc2xpZGVyX2NyZWF0ZQIw3gAep2RlbGF5XzgCqnRpY2tiYXNlXzcCqnRpY2tiYXNlXzICsHRpY2tiYXNlX3NsaWRlcnMDp2RlbGF5XzECqG1vZGlmaWVyqERpc2FibGVkp2RlbGF5XzICrXRpY2tiYXNlX3JuZG0QpGJvZHnDqnRpY2tiYXNlXzECp2RlbGF5XzMCq3lhd19tb2RlX2V4iKxvZmZzZXRfcmlnaHQZrWRlbGF5X2RlZmF1bHQGqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4CsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUBq29mZnNldF9sZWZ08LNkZWxheV9zbGlkZXJfY3JlYXRlArJ0aWNrYmFzZV9ybmRtX3R5cGWnRGVmYXVsdKh5YXdfbW9kZapMZWZ0L1JpZ2h0p2RlbGF5XzQCqnRpY2tiYXNlXzgCqnlhd19vZmZzZXQAqnRpY2tiYXNlXzMCp2RlbGF5XzUCsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzQCp2RlbGF5XzYCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwKmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSoc2xpZGVyXzYAo21pbgCoc2xpZGVyXzEAqXJhbmRvbWl6ZcKoc2xpZGVyXzIAqHNsaWRlcl81AKhzbGlkZXJfMwCjbWF4AKxib2R5X29wdGlvbnOPsXR5cGVfcmFuZG9tX3ZhbHVlAqtkZXN5bmNfdHlwZaZTdGF0aWOvdHlwZV90aWNrX3ZhbHVlBK9sZWZ0X3RpY2tfbGltaXQ8qGludmVydGVywqJ0bzyrdGlja19zbGlkZXIErWppdHRlcl9idXR0b27Do21pbjyjbWF4PLByaWdodF90aWNrX2xpbWl0PKpsZWZ0X2xpbWl0PKRmcm9tPKtyaWdodF9saW1pdDykdHlwZaZTdGF0aWOqdGlja2Jhc2VfNQKnZGVsYXlfNwKvdGlja2Jhc2Vfcm5kbV8yEKp0aWNrYmFzZV82Aqh0aWNrYmFzZalOZXZlcmxvc2UxjKhzbGlkZXJfNACuY3VzdG9tX3NsaWRlcnMCpm9mZnNldACkbW9kZadEZWZhdWx0qHNsaWRlcl82AKNtaW4AqHNsaWRlcl8xAKlyYW5kb21pemXCqHNsaWRlcl8yAKhzbGlkZXJfNQCoc2xpZGVyXzMAo21heAAyj7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWmU3RhdGljr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG88q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDykZnJvbTyrcmlnaHRfbGltaXQ8pHR5cGWmU3RhdGljM4isb2Zmc2V0X3JpZ2h0Ga1kZWxheV9kZWZhdWx0Bqp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluArBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAatvZmZzZXRfbGVmdPCzZGVsYXlfc2xpZGVyX2NyZWF0ZQI03gAep2RlbGF5XzgCqnRpY2tiYXNlXzcMqnRpY2tiYXNlXzIWsHRpY2tiYXNlX3NsaWRlcnMGp2RlbGF5XzECqG1vZGlmaWVypFNwaW6nZGVsYXlfMgKtdGlja2Jhc2Vfcm5kbRCkYm9kecOqdGlja2Jhc2VfMRanZGVsYXlfMwKreWF3X21vZGVfZXiIrG9mZnNldF9yaWdodCitZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbSmwZGVsYXlfcmFuZG9tX21pbgawZGVsYXlfcmFuZG9tX21heAqqZGVsYXlfbW9kZQKrb2Zmc2V0X2xlZnTos2RlbGF5X3NsaWRlcl9jcmVhdGUCsnRpY2tiYXNlX3JuZG1fdHlwZaRXYXlzqHlhd19tb2RlqkxlZnQvUmlnaHSnZGVsYXlfNAKqdGlja2Jhc2VfOAmqeWF3X29mZnNldACqdGlja2Jhc2VfMxanZGVsYXlfNQKydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNAynZGVsYXlfNgKwbW9kaWZpZXJfb3B0aW9uc4yoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzBaZvZmZzZXQApG1vZGWmQ3VzdG9tqHNsaWRlcl82AKNtaW4NqHNsaWRlcl8xAKlyYW5kb21pemXDqHNsaWRlcl8yAKhzbGlkZXJfNfeoc2xpZGVyXzMAo21hePGsYm9keV9vcHRpb25zj7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWnRnJvbS9Ub690eXBlX3RpY2tfdmFsdWUEr2xlZnRfdGlja19saW1pdDyoaW52ZXJ0ZXLConRvO6t0aWNrX3NsaWRlcgStaml0dGVyX2J1dHRvbsOjbWluPKNtYXg8sHJpZ2h0X3RpY2tfbGltaXQ8qmxlZnRfbGltaXQ8pGZyb205q3JpZ2h0X2xpbWl0PKR0eXBlplN0YXRpY6p0aWNrYmFzZV81C6dkZWxheV83Aq90aWNrYmFzZV9ybmRtXzIQqnRpY2tiYXNlXzYTqHRpY2tiYXNlqEFkdmFuY2VkNYyoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzBaZvZmZzZXQApG1vZGWmQ3VzdG9tqHNsaWRlcl82AKNtaW4NqHNsaWRlcl8xAKlyYW5kb21pemXDqHNsaWRlcl8yAKhzbGlkZXJfNfeoc2xpZGVyXzMAo21hePE2j7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWnRnJvbS9Ub690eXBlX3RpY2tfdmFsdWUEr2xlZnRfdGlja19saW1pdDyoaW52ZXJ0ZXLConRvO6t0aWNrX3NsaWRlcgStaml0dGVyX2J1dHRvbsOjbWluPKNtYXg8sHJpZ2h0X3RpY2tfbGltaXQ8qmxlZnRfbGltaXQ8pGZyb205q3JpZ2h0X2xpbWl0PKR0eXBlplN0YXRpYzeIrG9mZnNldF9yaWdodCitZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbSmwZGVsYXlfcmFuZG9tX21pbgawZGVsYXlfcmFuZG9tX21heAqqZGVsYXlfbW9kZQKrb2Zmc2V0X2xlZnTos2RlbGF5X3NsaWRlcl9jcmVhdGUCON4AHqdkZWxheV84Aqp0aWNrYmFzZV83DKp0aWNrYmFzZV8yEbB0aWNrYmFzZV9zbGlkZXJzB6dkZWxheV8xAqhtb2RpZmllcqRTcGlup2RlbGF5XzICrXRpY2tiYXNlX3JuZG0QpGJvZHnDqnRpY2tiYXNlXzEHp2RlbGF5XzMCq3lhd19tb2RlX2V4iKxvZmZzZXRfcmlnaHQprWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20ksGRlbGF5X3JhbmRvbV9taW4FsGRlbGF5X3JhbmRvbV9tYXgLqmRlbGF5X21vZGUCq29mZnNldF9sZWZ05bNkZWxheV9zbGlkZXJfY3JlYXRlArJ0aWNrYmFzZV9ybmRtX3R5cGWkV2F5c6h5YXdfbW9kZapMZWZ0L1JpZ2h0p2RlbGF5XzQCqnRpY2tiYXNlXzgJqnlhd19vZmZzZXQAqnRpY2tiYXNlXzMTp2RlbGF5XzUCsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzQMp2RlbGF5XzYCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwWmb2Zmc2V0AKRtb2RlpkN1c3RvbahzbGlkZXJfNgCjbWluAKhzbGlkZXJfMQCpcmFuZG9taXplw6hzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXgArGJvZHlfb3B0aW9uc4+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlp0Zyb20vVG+vdHlwZV90aWNrX3ZhbHVlBK9sZWZ0X3RpY2tfbGltaXQ8qGludmVydGVywqJ0bzyrdGlja19zbGlkZXIErWppdHRlcl9idXR0b27Do21pbjyjbWF4PLByaWdodF90aWNrX2xpbWl0PKpsZWZ0X2xpbWl0PKRmcm9tPKtyaWdodF9saW1pdDykdHlwZaZTdGF0aWOqdGlja2Jhc2VfNQinZGVsYXlfNwKvdGlja2Jhc2Vfcm5kbV8yEKp0aWNrYmFzZV82DKh0aWNrYmFzZahBZHZhbmNlZDmMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwWmb2Zmc2V0AKRtb2RlpkN1c3RvbahzbGlkZXJfNgCjbWluAKhzbGlkZXJfMQCpcmFuZG9taXplw6hzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXgAOo+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlp0Zyb20vVG+vdHlwZV90aWNrX3ZhbHVlBK9sZWZ0X3RpY2tfbGltaXQ8qGludmVydGVywqJ0bzyrdGlja19zbGlkZXIErWppdHRlcl9idXR0b27Do21pbjyjbWF4PLByaWdodF90aWNrX2xpbWl0PKpsZWZ0X2xpbWl0PKRmcm9tPKtyaWdodF9saW1pdDykdHlwZaZTdGF0aWM7iKxvZmZzZXRfcmlnaHQprWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20ksGRlbGF5X3JhbmRvbV9taW4FsGRlbGF5X3JhbmRvbV9tYXgLqmRlbGF5X21vZGUCq29mZnNldF9sZWZ05bNkZWxheV9zbGlkZXJfY3JlYXRlAjzeAB6nZGVsYXlfOAKqdGlja2Jhc2VfNwKqdGlja2Jhc2VfMgKwdGlja2Jhc2Vfc2xpZGVycwOnZGVsYXlfMQKobW9kaWZpZXKoRGlzYWJsZWSnZGVsYXlfMgKtdGlja2Jhc2Vfcm5kbRCkYm9kecKqdGlja2Jhc2VfMQKnZGVsYXlfMwKreWF3X21vZGVfZXiIrG9mZnNldF9yaWdodACtZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgKwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQCrb2Zmc2V0X2xlZnQAs2RlbGF5X3NsaWRlcl9jcmVhdGUCsnRpY2tiYXNlX3JuZG1fdHlwZadEZWZhdWx0qHlhd19tb2RlplN0YXRpY6dkZWxheV80Aqp0aWNrYmFzZV84Aqp5YXdfb2Zmc2V0AKp0aWNrYmFzZV8zAqdkZWxheV81ArJ0aWNrYmFzZV9yYW5kb21pemXDrnRpY2tiYXNlX2Nob2tlEKp0aWNrYmFzZV80AqdkZWxheV82ArBtb2RpZmllcl9vcHRpb25zjKhzbGlkZXJfNACuY3VzdG9tX3NsaWRlcnMCpm9mZnNldACkbW9kZadEZWZhdWx0qHNsaWRlcl82AKNtaW4AqHNsaWRlcl8xAKlyYW5kb21pemXCqHNsaWRlcl8yAKhzbGlkZXJfNQCoc2xpZGVyXzMAo21heACsYm9keV9vcHRpb25zj7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWmU3RhdGljr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG88q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDykZnJvbTyrcmlnaHRfbGltaXQ8pHR5cGWmU3RhdGljqnRpY2tiYXNlXzUCp2RlbGF5XzcCr3RpY2tiYXNlX3JuZG1fMhCqdGlja2Jhc2VfNgKodGlja2Jhc2WpTmV2ZXJsb3NlPYyoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzAqZvZmZzZXQApG1vZGWnRGVmYXVsdKhzbGlkZXJfNgCjbWluAKhzbGlkZXJfMQCpcmFuZG9taXplwqhzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXgAPo+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlplN0YXRpY690eXBlX3RpY2tfdmFsdWUEr2xlZnRfdGlja19saW1pdDyoaW52ZXJ0ZXLConRvPKt0aWNrX3NsaWRlcgStaml0dGVyX2J1dHRvbsOjbWluPKNtYXg8sHJpZ2h0X3RpY2tfbGltaXQ8qmxlZnRfbGltaXQ8pGZyb208q3JpZ2h0X2xpbWl0PKR0eXBlplN0YXRpYz+IrG9mZnNldF9yaWdodACtZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgKwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQCrb2Zmc2V0X2xlZnQAs2RlbGF5X3NsaWRlcl9jcmVhdGUCQN4AHqdkZWxheV84Aqp0aWNrYmFzZV83Aqp0aWNrYmFzZV8yArB0aWNrYmFzZV9zbGlkZXJzA6dkZWxheV8xAqhtb2RpZmllcqhEaXNhYmxlZKdkZWxheV8yAq10aWNrYmFzZV9ybmRtEKRib2R5wqp0aWNrYmFzZV8xAqdkZWxheV8zAqt5YXdfbW9kZV9leIisb2Zmc2V0X3JpZ2h0AK1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluArBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAKtvZmZzZXRfbGVmdACzZGVsYXlfc2xpZGVyX2NyZWF0ZQKydGlja2Jhc2Vfcm5kbV90eXBlp0RlZmF1bHSoeWF3X21vZGWmU3RhdGljp2RlbGF5XzQCqnRpY2tiYXNlXzgCqnlhd19vZmZzZXQAqnRpY2tiYXNlXzMCp2RlbGF5XzUCsnRpY2tiYXNlX3JhbmRvbWl6ZcOudGlja2Jhc2VfY2hva2UQqnRpY2tiYXNlXzQCp2RlbGF5XzYCsG1vZGlmaWVyX29wdGlvbnOMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwKmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSoc2xpZGVyXzYAo21pbgCoc2xpZGVyXzEAqXJhbmRvbWl6ZcKoc2xpZGVyXzIAqHNsaWRlcl81AKhzbGlkZXJfMwCjbWF4AKxib2R5X29wdGlvbnOPsXR5cGVfcmFuZG9tX3ZhbHVlAqtkZXN5bmNfdHlwZaZTdGF0aWOvdHlwZV90aWNrX3ZhbHVlBK9sZWZ0X3RpY2tfbGltaXQ8qGludmVydGVywqJ0bzyrdGlja19zbGlkZXIErWppdHRlcl9idXR0b27Do21pbjyjbWF4PLByaWdodF90aWNrX2xpbWl0PKpsZWZ0X2xpbWl0PKRmcm9tPKtyaWdodF9saW1pdDykdHlwZaZTdGF0aWOqdGlja2Jhc2VfNQKnZGVsYXlfNwKvdGlja2Jhc2Vfcm5kbV8yEKp0aWNrYmFzZV82Aqh0aWNrYmFzZalOZXZlcmxvc2VBjKhzbGlkZXJfNACuY3VzdG9tX3NsaWRlcnMCpm9mZnNldACkbW9kZadEZWZhdWx0qHNsaWRlcl82AKNtaW4AqHNsaWRlcl8xAKlyYW5kb21pemXCqHNsaWRlcl8yAKhzbGlkZXJfNQCoc2xpZGVyXzMAo21heABCj7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWmU3RhdGljr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG88q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDykZnJvbTyrcmlnaHRfbGltaXQ8pHR5cGWmU3RhdGljQ4isb2Zmc2V0X3JpZ2h0AK1kZWxheV9kZWZhdWx0Aqp5YXdfcmFuZG9tALBkZWxheV9yYW5kb21fbWluArBkZWxheV9yYW5kb21fbWF4BKpkZWxheV9tb2RlAKtvZmZzZXRfbGVmdACzZGVsYXlfc2xpZGVyX2NyZWF0ZQJE3gAep2RlbGF5XzgCqnRpY2tiYXNlXzcCqnRpY2tiYXNlXzICsHRpY2tiYXNlX3NsaWRlcnMDp2RlbGF5XzECqG1vZGlmaWVyqERpc2FibGVkp2RlbGF5XzICrXRpY2tiYXNlX3JuZG0QpGJvZHnCqnRpY2tiYXNlXzECp2RlbGF5XzMCq3lhd19tb2RlX2V4iKxvZmZzZXRfcmlnaHQArWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4CsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUAq29mZnNldF9sZWZ0ALNkZWxheV9zbGlkZXJfY3JlYXRlArJ0aWNrYmFzZV9ybmRtX3R5cGWnRGVmYXVsdKh5YXdfbW9kZaZTdGF0aWOnZGVsYXlfNAKqdGlja2Jhc2VfOAKqeWF3X29mZnNldACqdGlja2Jhc2VfMwKnZGVsYXlfNQKydGlja2Jhc2VfcmFuZG9taXplw650aWNrYmFzZV9jaG9rZRCqdGlja2Jhc2VfNAKnZGVsYXlfNgKwbW9kaWZpZXJfb3B0aW9uc4yoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzAqZvZmZzZXQApG1vZGWnRGVmYXVsdKhzbGlkZXJfNgCjbWluAKhzbGlkZXJfMQCpcmFuZG9taXplwqhzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXgArGJvZHlfb3B0aW9uc4+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlplN0YXRpY690eXBlX3RpY2tfdmFsdWUEr2xlZnRfdGlja19saW1pdDyoaW52ZXJ0ZXLConRvPKt0aWNrX3NsaWRlcgStaml0dGVyX2J1dHRvbsOjbWluPKNtYXg8sHJpZ2h0X3RpY2tfbGltaXQ8qmxlZnRfbGltaXQ8pGZyb208q3JpZ2h0X2xpbWl0PKR0eXBlplN0YXRpY6p0aWNrYmFzZV81AqdkZWxheV83Aq90aWNrYmFzZV9ybmRtXzIQqnRpY2tiYXNlXzYCqHRpY2tiYXNlqU5ldmVybG9zZUWMqHNsaWRlcl80AK5jdXN0b21fc2xpZGVycwKmb2Zmc2V0AKRtb2Rlp0RlZmF1bHSoc2xpZGVyXzYAo21pbgCoc2xpZGVyXzEAqXJhbmRvbWl6ZcKoc2xpZGVyXzIAqHNsaWRlcl81AKhzbGlkZXJfMwCjbWF4AEaPsXR5cGVfcmFuZG9tX3ZhbHVlAqtkZXN5bmNfdHlwZaZTdGF0aWOvdHlwZV90aWNrX3ZhbHVlBK9sZWZ0X3RpY2tfbGltaXQ8qGludmVydGVywqJ0bzyrdGlja19zbGlkZXIErWppdHRlcl9idXR0b27Do21pbjyjbWF4PLByaWdodF90aWNrX2xpbWl0PKpsZWZ0X2xpbWl0PKRmcm9tPKtyaWdodF9saW1pdDykdHlwZaZTdGF0aWNHiKxvZmZzZXRfcmlnaHQArWRlbGF5X2RlZmF1bHQCqnlhd19yYW5kb20AsGRlbGF5X3JhbmRvbV9taW4CsGRlbGF5X3JhbmRvbV9tYXgEqmRlbGF5X21vZGUAq29mZnNldF9sZWZ0ALNkZWxheV9zbGlkZXJfY3JlYXRlAkjeAB6nZGVsYXlfOAKqdGlja2Jhc2VfNwKqdGlja2Jhc2VfMgKwdGlja2Jhc2Vfc2xpZGVycwOnZGVsYXlfMQKobW9kaWZpZXKoRGlzYWJsZWSnZGVsYXlfMgKtdGlja2Jhc2Vfcm5kbRCkYm9kecKqdGlja2Jhc2VfMQKnZGVsYXlfMwKreWF3X21vZGVfZXiIrG9mZnNldF9yaWdodACtZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgKwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQCrb2Zmc2V0X2xlZnQAs2RlbGF5X3NsaWRlcl9jcmVhdGUCsnRpY2tiYXNlX3JuZG1fdHlwZadEZWZhdWx0qHlhd19tb2RlplN0YXRpY6dkZWxheV80Aqp0aWNrYmFzZV84Aqp5YXdfb2Zmc2V0AKp0aWNrYmFzZV8zAqdkZWxheV81ArJ0aWNrYmFzZV9yYW5kb21pemXDrnRpY2tiYXNlX2Nob2tlEKp0aWNrYmFzZV80AqdkZWxheV82ArBtb2RpZmllcl9vcHRpb25zjKhzbGlkZXJfNACuY3VzdG9tX3NsaWRlcnMCpm9mZnNldACkbW9kZadEZWZhdWx0qHNsaWRlcl82AKNtaW4AqHNsaWRlcl8xAKlyYW5kb21pemXCqHNsaWRlcl8yAKhzbGlkZXJfNQCoc2xpZGVyXzMAo21heACsYm9keV9vcHRpb25zj7F0eXBlX3JhbmRvbV92YWx1ZQKrZGVzeW5jX3R5cGWmU3RhdGljr3R5cGVfdGlja192YWx1ZQSvbGVmdF90aWNrX2xpbWl0PKhpbnZlcnRlcsKidG88q3RpY2tfc2xpZGVyBK1qaXR0ZXJfYnV0dG9uw6NtaW48o21heDywcmlnaHRfdGlja19saW1pdDyqbGVmdF9saW1pdDykZnJvbTyrcmlnaHRfbGltaXQ8pHR5cGWmU3RhdGljqnRpY2tiYXNlXzUCp2RlbGF5XzcCr3RpY2tiYXNlX3JuZG1fMhCqdGlja2Jhc2VfNgKodGlja2Jhc2WpTmV2ZXJsb3NlSYyoc2xpZGVyXzQArmN1c3RvbV9zbGlkZXJzAqZvZmZzZXQApG1vZGWnRGVmYXVsdKhzbGlkZXJfNgCjbWluAKhzbGlkZXJfMQCpcmFuZG9taXplwqhzbGlkZXJfMgCoc2xpZGVyXzUAqHNsaWRlcl8zAKNtYXgASo+xdHlwZV9yYW5kb21fdmFsdWUCq2Rlc3luY190eXBlplN0YXRpY690eXBlX3RpY2tfdmFsdWUEr2xlZnRfdGlja19saW1pdDyoaW52ZXJ0ZXLConRvPKt0aWNrX3NsaWRlcgStaml0dGVyX2J1dHRvbsOjbWluPKNtYXg8sHJpZ2h0X3RpY2tfbGltaXQ8qmxlZnRfbGltaXQ8pGZyb208q3JpZ2h0X2xpbWl0PKR0eXBlplN0YXRpY0uIrG9mZnNldF9yaWdodACtZGVsYXlfZGVmYXVsdAKqeWF3X3JhbmRvbQCwZGVsYXlfcmFuZG9tX21pbgKwZGVsYXlfcmFuZG9tX21heASqZGVsYXlfbW9kZQCrb2Zmc2V0X2xlZnQAs2RlbGF5X3NsaWRlcl9jcmVhdGUCrV9fd2F0ZXJtYXJrX3jNBQCtX193YXRlcm1hcmtfec0Fkg==", 
            [2] = sys_data_encoded
        };
        for v172, v173 in ipairs(v166.system_presets) do
            if not v166.database[v173] then
                v166.database[v173] = v171[v172];
            end;
        end;
        utils.execute_after(0.1, function()
            -- upvalues: v166 (ref), l_base64_0 (ref)
            v166.home.elements.preset_input:set("");
            v166:update();
            local l_preset_buttons_1 = v166.home.elements.preset_buttons;
            l_preset_buttons_1.create:set_callback(function()
                -- upvalues: v166 (ref), l_base64_0 (ref)
                local v175 = v166.home.elements.preset_input:get();
                if not v175 or v175 == "" then
                    common.add_event("Invalid preset name", "ban");
                    cvar.playvol:call("ui\\weapon_cant_buy", 1);
                    return;
                elseif v166:utf8_len(v175) < 2 or v166:utf8_len(v175) > 20 then
                    common.add_event("Preset name must be between 2 and 20 characters", "ban");
                    cvar.playvol:call("ui\\weapon_cant_buy", 1);
                    return;
                elseif v166:is_system_preset(v175) then
                    common.add_event("Cannot modify system preset", "ban");
                    cvar.playvol:call("ui\\weapon_cant_buy", 1);
                    return;
                else
                    local v176 = v175:lower();
                    for _, v178 in ipairs(v166.system_presets) do
                        if v176 == v166:clean_name(v178):lower() then
                            common.add_event("Cannot use system preset name", "ban");
                            cvar.playvol:call("ui\\weapon_cant_buy", 1);
                            return;
                        end;
                    end;
                    if v166.database[v175] then
                        common.add_event("Preset already exists, use Save to overwrite", "ban");
                        cvar.playvol:call("ui\\weapon_cant_buy", 1);
                        return;
                    else
                        local l_status_2, l_result_2 = pcall(function()
                            -- upvalues: l_base64_0 (ref)
                            return l_base64_0.encode(msgpack.pack({}));
                        end);
                        if not l_status_2 then
                            common.add_event("Failed to create. (Encode error)", "ban");
                            cvar.playvol:call("ui\\weapon_cant_buy", 1);
                            return;
                        else
                            v166.database[v175] = l_result_2;
                            v166:save_database();
                            v166.misc.elements.jitter_legs.from:set(10);
                            v166.misc.elements.jitter_legs.to:set(90);
                            local l_watermark_gear_2 = v166.home.elements.watermark_gear;
                            local v182 = render.screen_size();
                            local v183 = l_watermark_gear_2.input:get() or "";
                            local v184 = l_watermark_gear_2.font:get();
                            local v185 = ({
                                Bold = 4, 
                                Default = 1, 
                                Pixel = 2, 
                                Console = 3
                            })[v184] or 1;
                            if v184 == "Pixel" then
                                v183 = v183:upper();
                            end;
                            local v186 = render.measure_text(v185, "c", v183);
                            local v187 = v182.x * 0.5;
                            local v188 = v182.y - v186.y * 0.5 - 8;
                            l_watermark_gear_2.pos_x:set(v187);
                            l_watermark_gear_2.pos_y:set(v188);
                            db.godsense_watermark_x = v187;
                            db.godsense_watermark_y = v188;
                            common.add_event("Preset created successfully", "check");
                            cvar.playvol:call("ui\\beepclear", 1);
                            v166:update();
                            local v189 = v166.home.elements.preset_list:list();
                            for v190, v191 in ipairs(v189) do
                                if v191 == v175 then
                                    v166.home.elements.preset_list:set(v190);
                                    break;
                                end;
                            end;
                            v166:disabler();
                            return;
                        end;
                    end;
                end;
            end);
            l_preset_buttons_1.save:set_callback(function()
                -- upvalues: v166 (ref), l_preset_buttons_1 (ref)
                local l_preset_list_5 = v166.home.elements.preset_list;
                local v193 = l_preset_list_5:list()[l_preset_list_5:get()];
                if not v193 or v166:is_separator(v193) or v166:is_system_preset(v193) then
                    common.add_event("Select a user preset to overwrite", "ban");
                    cvar.playvol:call("ui\\weapon_cant_buy", 1);
                    return;
                elseif not v166.database[v193] then
                    common.add_event("Preset doesn't exist, use Create instead", "ban");
                    cvar.playvol:call("ui\\weapon_cant_buy", 1);
                    return;
                else
                    l_preset_buttons_1.save_switch:set(true);
                    return;
                end;
            end);
            l_preset_buttons_1.save_confirm:set_callback(function()
                -- upvalues: v166 (ref), l_preset_buttons_1 (ref)
                v166:save();
                l_preset_buttons_1.save_switch:set(false);
            end);
            l_preset_buttons_1.save_cancel:set_callback(function()
                -- upvalues: l_preset_buttons_1 (ref)
                l_preset_buttons_1.save_switch:set(false);
                cvar.playvol:call("ui\\csgo_ui_contract_type1", 1);
            end);
            l_preset_buttons_1.delete_confirm:set_callback(function()
                -- upvalues: v166 (ref), l_preset_buttons_1 (ref)
                v166:delete();
                l_preset_buttons_1.hidden_switch:set(false);
            end);
            l_preset_buttons_1.delete_cancel:set_callback(function()
                -- upvalues: l_preset_buttons_1 (ref)
                l_preset_buttons_1.hidden_switch:set(false);
                cvar.playvol:call("ui\\csgo_ui_contract_type1", 1);
            end);
            l_preset_buttons_1.load:set_callback(function()
                -- upvalues: v166 (ref)
                v166:load();
            end);
            l_preset_buttons_1.export:set_callback(function()
                -- upvalues: v166 (ref)
                v166:export();
            end);
            l_preset_buttons_1.import:set_callback(function()
                -- upvalues: v166 (ref)
                v166:import();
            end);
            v166.home.elements.preset_list:set_callback(function()
                -- upvalues: v166 (ref)
                v166:disabler();
                local l_preset_list_6 = v166.home.elements.preset_list;
                local v195 = l_preset_list_6:list()[l_preset_list_6:get()];
                if not v195 then
                    cvar.playvol:call("ui\\weapon_cant_buy", 1);
                    return;
                else
                    cvar.playvol:call("ui\\csgo_ui_contract_type1", 1);
                    v166.home.elements.preset_input:set(v166:clean_name(v195));
                    return;
                end;
            end);
        end);
        events.shutdown:set(function()
            -- upvalues: v166 (ref)
            db.godsense_recode666 = v166.database;
        end);
    end
}):struct("antiaim")({
    elements = {}, 
    data = {}, 
    init = function(v196)
        -- upvalues: l_pui_0 (ref), l_base64_0 (ref), l_clipboard_0 (ref)
        if v196.groups then
            return;
        else
            v196.e_teams = {
                [1] = "\v\226\128\162   \rCounter-Terrorists", 
                [2] = "\v\226\128\162   \rTerrorists"
            };
            v196.e_states = {
                [1] = "\v\226\128\162   \rStanding", 
                [2] = "\v\226\128\162   \rRunning", 
                [3] = "\v\226\128\162   \rSlowing", 
                [4] = "\v\226\128\162   \rCrouching", 
                [5] = "\v\226\128\162   \rMove Crouch", 
                [6] = "\v\226\128\162   \rAir", 
                [7] = "\v\226\128\162   \rAir Crouch", 
                [8] = "\v\226\128\162   \rFreestanding", 
                [9] = "\v\226\128\162   \rManuals"
            };
            local l_string_0 = v196.string;
            v196.groups = {
                teams_state = l_pui_0.create(l_string_0:format("stars", "", 0, 0, 0), "team / states", 1), 
                selection = l_pui_0.create(l_string_0:format("stars", "", 0, 0, 0), "selection", 2), 
                builder = l_pui_0.create(l_string_0:format("stars", "", 0, 0, 0), "builder", 2), 
                extra = l_pui_0.create(l_string_0:format("stars", "", 0, 0, 0), "Options", 2), 
                snap_builder = l_pui_0.create(l_string_0:format("stars", "", 0, 0, 0), "\n", 1)
            };
            local l_groups_0 = v196.groups;
            local l_elements_0 = v196.elements;
            l_elements_0.teams = l_groups_0.teams_state:list(l_string_0:format("", "", 0, 0, 0), v196.e_teams);
            l_elements_0.states = l_groups_0.teams_state:list(l_string_0:format("", "", 0, 0, 0), v196.e_states);
            l_elements_0.selectable = l_groups_0.selection:list(l_string_0:format("", "", 0, 0, 0), {
                [1] = "\v\226\128\162   \rBuilder", 
                [2] = "\v\226\128\162   \rMisc"
            });
            l_elements_0.force_break_lc = l_groups_0.snap_builder:selectable(l_string_0:format("bone-break", "Force LC", 0, 10, 2, "\a{Small Text}"), v196.e_states);
            l_elements_0.force_break_lc_options = {};
            l_elements_0.warmup_aa = l_groups_0.extra:label(l_string_0:format("rotate", "Warmup AA", 0, 10, 0, "\a{Small Text}"));
            l_elements_0.warmup_aa_tbl = {};
            l_elements_0.teams:depend({
                [1] = nil, 
                [2] = 1, 
                [1] = l_elements_0.selectable
            });
            l_elements_0.states:depend({
                [1] = nil, 
                [2] = 1, 
                [1] = l_elements_0.selectable
            });
            l_elements_0.force_break_lc:depend({
                [1] = nil, 
                [2] = 1, 
                [1] = l_elements_0.selectable
            });
            l_elements_0.options = l_groups_0.extra:label(l_string_0:format("gear", "Extra features", 0, 10, 2, "\a{Small Text}"));
            l_elements_0.options:depend({
                [1] = nil, 
                [2] = 1, 
                [1] = l_elements_0.selectable
            });
            local v200 = l_elements_0.options:create();
            l_elements_0.options_gear = {
                avoid_backstab = v200:switch(l_string_0:format("bring-front", "Avoid Backstab", 0, 10, 0)), 
                safe_head = v200:selectable(l_string_0:format("user-shield", "Safe Head", 0, 10, 0), {
                    [1] = "Standing", 
                    [2] = "Zeus x27", 
                    [3] = "Knife", 
                    [4] = "Crouch", 
                    [5] = "Move Crouch"
                }), 
                sep = v200:label(" \a{Small Text}\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128"), 
                manuals = v200:combo(l_string_0:format("arrows-rotate", "Manuals", 0, 10, 0), {
                    [1] = "Disabled", 
                    [2] = "Left", 
                    [3] = "Right", 
                    [4] = "Forward"
                }), 
                freestanding = v200:switch(l_string_0:format("arrows-repeat", "Freestanding", 0, 10, 0)), 
                body_fs = v200:switch(l_string_0:format("person-rays", "Body Freestanding", 0, 10, 0)), 
                disablers = v200:selectable(l_string_0:format("angles-right", "\a{Small Text}FS Disablers", 20, 10, 0, "\a{Small Text}"), {
                    [1] = "\v\226\128\162   \rStanding", 
                    [2] = "\v\226\128\162   \rRunning", 
                    [3] = "\v\226\128\162   \rSlowing", 
                    [4] = "\v\226\128\162   \rCrouching", 
                    [5] = "\v\226\128\162   \rMove Crouch", 
                    [6] = "\v\226\128\162   \rAir", 
                    [7] = "\v\226\128\162   \rAir Crouch"
                })
            };
            l_elements_0.options_gear.safe_head:tooltip("\vCrouch\r / \vMove Crouch\r working only when you upper then enemy.");
            local v201 = l_elements_0.warmup_aa:create();
            l_elements_0.warmup_aa_tbl = {
                mode = v201:selectable(l_string_0:format(point, "Depends", 0, 10, 0), {
                    [1] = "No enemies", 
                    [2] = "Warmup"
                }), 
                pitch = v201:combo(l_string_0:format(point, "Pitch", 0, 10, 0), {
                    [1] = "Disabled", 
                    [2] = "Up", 
                    [3] = "Down"
                }), 
                yaw = v201:combo(l_string_0:format(point, "Yaw", 0, 10, 0), {
                    [1] = "Spin", 
                    [2] = "Randomize", 
                    [3] = "Left / Right"
                }), 
                range = v201:slider(l_string_0:format(point, "Range", 0, 10, 0), 0, 360, 360, 1, "\194\176"), 
                speed = v201:slider(l_string_0:format(point, "Speed", 0, 10, 0), 2, 10, 2, 1, "t"), 
                left_offset = v201:slider(l_string_0:format(point, "Left", 0, 10, 0), -180, 180, 0, 1, "\194\176"), 
                right_offset = v201:slider(l_string_0:format(point, "Right", 0, 10, 0), -180, 180, 0, 1, "\194\176")
            };
            local l_warmup_aa_tbl_0 = l_elements_0.warmup_aa_tbl;
            l_elements_0.warmup_aa:depend({
                [1] = nil, 
                [2] = 1, 
                [1] = l_elements_0.selectable
            });
            l_warmup_aa_tbl_0.pitch:depend({
                [1] = nil, 
                [2] = true, 
                [1] = l_warmup_aa_tbl_0.mode
            });
            l_warmup_aa_tbl_0.yaw:depend({
                [1] = nil, 
                [2] = true, 
                [1] = l_warmup_aa_tbl_0.mode
            });
            l_warmup_aa_tbl_0.range:depend({
                [1] = nil, 
                [2] = true, 
                [1] = l_warmup_aa_tbl_0.mode
            }, {
                [1] = nil, 
                [2] = "Spin", 
                [3] = "Randomize", 
                [1] = l_warmup_aa_tbl_0.yaw
            });
            l_warmup_aa_tbl_0.speed:depend({
                [1] = nil, 
                [2] = true, 
                [1] = l_warmup_aa_tbl_0.mode
            }, {
                [1] = nil, 
                [2] = "Spin", 
                [3] = "Randomize", 
                [1] = l_warmup_aa_tbl_0.yaw
            });
            l_warmup_aa_tbl_0.left_offset:depend({
                [1] = nil, 
                [2] = "Left / Right", 
                [1] = l_warmup_aa_tbl_0.yaw
            });
            l_warmup_aa_tbl_0.right_offset:depend({
                [1] = nil, 
                [2] = "Left / Right", 
                [1] = l_warmup_aa_tbl_0.yaw
            });
            local v203 = l_elements_0.force_break_lc:create();
            local v204 = {};
            l_elements_0.force_break_lc_options = v204;
            v204.hide_shots = v203:combo(l_string_0:format("eye-slash", "Hide Shots", 0, 10, 0), {
                [1] = "Favor Fire Rate", 
                [2] = "Favor Fake Lag", 
                [3] = "Break LC"
            });
            v204.disable_on_grenade = v203:switch(l_string_0:format("crystal-ball", "Disable on Grenade", 0, 10, 0));
            l_elements_0.fs_allowes = l_groups_0.builder:switch(l_string_0:format("check", "Allow", 0, 10, 0, "\a{Small Text}"));
            local l_builder_0 = l_groups_0.builder;
            local l_states_0 = l_elements_0.states;
            local l_teams_0 = l_elements_0.teams;
            local l_selectable_0 = l_elements_0.selectable;
            local _ = v196.e_states;
            local _ = v196.e_teams;
            v196.data = {};
            for v211 = 1, 9 do
                v196.data[v211] = {};
                do
                    local l_v211_0 = v211;
                    for v213 = 1, 2 do
                        local v214 = {};
                        v196.data[l_v211_0][v213] = v214;
                        v214.yaw_mode = l_builder_0:combo(l_string_0:format("leaf", "Yaw", 0, 10, 0, "\a{Small Text}"), {
                            [1] = "Static", 
                            [2] = "Left/Right"
                        }):depend({
                            [1] = l_states_0, 
                            [2] = l_v211_0
                        }, {
                            [1] = l_teams_0, 
                            [2] = v213
                        });
                        v214.yaw_offset = l_builder_0:slider(l_string_0:format("angles-right", "\a{Small Text}Offset", 20, 10, 0, "\a{Small Text}"), -180, 180, 0, 1, "\194\176");
                        v214.modifier = l_builder_0:combo(l_string_0:format("leaf", "Modifiers", 0, 10, 0, "\a{Small Text}"), {
                            [1] = "Disabled", 
                            [2] = "Offset", 
                            [3] = "Center", 
                            [4] = "Random", 
                            [5] = "Spin", 
                            [6] = "3-Way", 
                            [7] = "5-Way"
                        }):depend({
                            [1] = l_states_0, 
                            [2] = l_v211_0
                        }, {
                            [1] = l_teams_0, 
                            [2] = v213
                        });
                        v214.body = l_builder_0:switch(l_string_0:format("leaf", "Body Yaw", 0, 10, 0, "\a{Small Text}")):depend({
                            [1] = l_states_0, 
                            [2] = l_v211_0
                        }, {
                            [1] = l_teams_0, 
                            [2] = v213
                        });
                        local v215 = {};
                        v214.modifier_options = v215;
                        local v216 = v214.modifier:create();
                        v215.randomize = v216:switch(l_string_0:format("shuffle", "Randomize", 0, 10, 0)):depend({
                            [1] = l_states_0, 
                            [2] = l_v211_0
                        }, {
                            [1] = l_teams_0, 
                            [2] = v213
                        }, {
                            [1] = nil, 
                            [2] = "Disabled", 
                            [3] = true, 
                            [1] = v214.modifier
                        });
                        v215.offset = v216:slider(l_string_0:format("angles-right", "\a{Small Text}Offset", 20, 10, 0, "\a{Small Text}"), -180, 180, 0, 1, "\194\176"):depend({
                            [1] = l_states_0, 
                            [2] = l_v211_0
                        }, {
                            [1] = l_teams_0, 
                            [2] = v213
                        }, {
                            [1] = nil, 
                            [2] = "Disabled", 
                            [3] = true, 
                            [1] = v214.modifier
                        }, {
                            [1] = nil, 
                            [2] = false, 
                            [1] = v215.randomize
                        });
                        v215.mode = v216:combo(l_string_0:format("sliders", "Mode", 0, 10, 0), {
                            [1] = "Default", 
                            [2] = "Custom"
                        }):depend({
                            [1] = l_states_0, 
                            [2] = l_v211_0
                        }, {
                            [1] = l_teams_0, 
                            [2] = v213
                        }, {
                            [1] = nil, 
                            [2] = "Disabled", 
                            [3] = true, 
                            [1] = v214.modifier
                        }, {
                            [1] = nil, 
                            [2] = true, 
                            [1] = v215.randomize
                        });
                        v215.min = v216:slider(l_string_0:format("angles-right", "Minimum", 0, 10, 0), -180, 180, 0, 1, "\194\176"):depend({
                            [1] = l_states_0, 
                            [2] = l_v211_0
                        }, {
                            [1] = l_teams_0, 
                            [2] = v213
                        }, {
                            [1] = nil, 
                            [2] = "Disabled", 
                            [3] = true, 
                            [1] = v214.modifier
                        }, {
                            [1] = nil, 
                            [2] = true, 
                            [1] = v215.randomize
                        }, {
                            [1] = nil, 
                            [2] = "Default", 
                            [1] = v215.mode
                        });
                        v215.max = v216:slider(l_string_0:format("angles-right", "Maximum", 0, 10, 0), -180, 180, 0, 1, "\194\176"):depend({
                            [1] = l_states_0, 
                            [2] = l_v211_0
                        }, {
                            [1] = l_teams_0, 
                            [2] = v213
                        }, {
                            [1] = nil, 
                            [2] = "Disabled", 
                            [3] = true, 
                            [1] = v214.modifier
                        }, {
                            [1] = nil, 
                            [2] = true, 
                            [1] = v215.randomize
                        }, {
                            [1] = nil, 
                            [2] = "Default", 
                            [1] = v215.mode
                        });
                        v215.custom_sliders = v216:slider(l_string_0:format("list", "Sliders", 0, 10, 0), 2, 6, 2):depend({
                            [1] = l_states_0, 
                            [2] = l_v211_0
                        }, {
                            [1] = l_teams_0, 
                            [2] = v213
                        }, {
                            [1] = nil, 
                            [2] = "Disabled", 
                            [3] = true, 
                            [1] = v214.modifier
                        }, {
                            [1] = nil, 
                            [2] = true, 
                            [1] = v215.randomize
                        }, {
                            [1] = nil, 
                            [2] = "Custom", 
                            [1] = v215.mode
                        });
                        do
                            local l_v213_0 = v213;
                            do
                                local l_v214_0, l_v215_0 = v214, v215;
                                for v220 = 1, 6 do
                                    local l_v220_0 = v220;
                                    do
                                        local l_l_v220_0_0 = l_v220_0;
                                        l_v215_0["slider_" .. l_l_v220_0_0] = v216:slider(l_string_0:format("angles-right", tostring(l_l_v220_0_0), 0, 10, 0), -180, 180, 0, 1, "\194\176"):depend({
                                            [1] = l_states_0, 
                                            [2] = l_v211_0
                                        }, {
                                            [1] = l_teams_0, 
                                            [2] = l_v213_0
                                        }, {
                                            [1] = nil, 
                                            [2] = "Disabled", 
                                            [3] = true, 
                                            [1] = l_v214_0.modifier
                                        }, {
                                            [1] = nil, 
                                            [2] = true, 
                                            [1] = l_v215_0.randomize
                                        }, {
                                            [1] = nil, 
                                            [2] = "Custom", 
                                            [1] = l_v215_0.mode
                                        }, {
                                            [1] = l_v215_0.custom_sliders, 
                                            [2] = function()
                                                -- upvalues: l_l_v220_0_0 (ref), l_v215_0 (ref)
                                                return l_l_v220_0_0 <= 2 or l_v215_0.custom_sliders:get() >= l_l_v220_0_0;
                                            end
                                        });
                                    end;
                                end;
                                l_v214_0.yaw_offset:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Static", 
                                    [1] = l_v214_0.yaw_mode
                                }, {
                                    [1] = l_states_0, 
                                    [2] = function(v223)
                                        return v223.value ~= 9;
                                    end
                                });
                                local v224 = {};
                                l_v214_0.body_options = v224;
                                local v225 = l_v214_0.body:create();
                                v224.inverter = v225:switch(l_string_0:format("arrow-rotate-right", "Inverter", 0, 10, 0));
                                v224.jitter_button = v225:switch(l_string_0:format("sparkles", "Jitter", 0, 10, 0), true);
                                v224.type = v225:combo(l_string_0:format("bring-forward", "Mode Jitter", 0, 10, 0), {
                                    [1] = "Static", 
                                    [2] = "Tick", 
                                    [3] = "Random"
                                });
                                v224.type_tick_value = v225:slider(l_string_0:format("clock", "Ticks", 20, 10, 0), 4, 16, 4, 1, "t");
                                v224.type_random_value = v225:slider(l_string_0:format("shuffle", "Random", 20, 10, 0), 2, 16, 2, 1, "x");
                                v224.desync_type = v225:combo(l_string_0:format("angles-right", "Desync Type", 0, 10, 0), {
                                    [1] = "Static", 
                                    [2] = "Tick", 
                                    [3] = "Random", 
                                    [4] = "From/To"
                                });
                                v224.left_limit = v225:slider(l_string_0:format("right-long", "Left Limit", 20, 10, 0), 0, 60, 60, 1, "\194\176");
                                v224.right_limit = v225:slider(l_string_0:format("right-long", "Right Limit", 20, 10, 0), 0, 60, 60, 1, "\194\176");
                                v224.tick_slider = v225:slider(l_string_0:format("arrows-spin", "Ticks", 0, 10, 0), 1, 20, 4, 1, "t");
                                v224.left_tick_limit = v225:slider(l_string_0:format("right-long", "[1]", 20, 10, 0), 0, 60, 60, 1, "\194\176");
                                v224.right_tick_limit = v225:slider(l_string_0:format("right-long", "[2]", 20, 10, 0), 0, 60, 60, 1, "\194\176");
                                v224.min = v225:slider(l_string_0:format("right-long", "[1]", 20, 10, 0), 0, 60, 60, 1, "\194\176");
                                v224.max = v225:slider(l_string_0:format("right-long", "[2]", 20, 10, 0), 0, 60, 60, 1, "\194\176");
                                v224.from = v225:slider(l_string_0:format("right-long", "[1]", 20, 10, 0), 0, 60, 60, 1, "\194\176");
                                v224.to = v225:slider(l_string_0:format("right-long", "[2]", 20, 10, 0), 0, 60, 60, 1, "\194\176");
                                v224.inverter:depend({
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.jitter_button:depend({
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.type:depend({
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.desync_type:depend({
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.type_tick_value:depend({
                                    [1] = nil, 
                                    [2] = "Tick", 
                                    [1] = v224.type
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.type_random_value:depend({
                                    [1] = nil, 
                                    [2] = "Random", 
                                    [1] = v224.type
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.left_limit:depend({
                                    [1] = nil, 
                                    [2] = "Static", 
                                    [1] = v224.desync_type
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.right_limit:depend({
                                    [1] = nil, 
                                    [2] = "Static", 
                                    [1] = v224.desync_type
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.tick_slider:depend({
                                    [1] = nil, 
                                    [2] = "Tick", 
                                    [1] = v224.desync_type
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.left_tick_limit:depend({
                                    [1] = nil, 
                                    [2] = "Tick", 
                                    [1] = v224.desync_type
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.right_tick_limit:depend({
                                    [1] = nil, 
                                    [2] = "Tick", 
                                    [1] = v224.desync_type
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.min:depend({
                                    [1] = nil, 
                                    [2] = "Random", 
                                    [1] = v224.desync_type
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.max:depend({
                                    [1] = nil, 
                                    [2] = "Random", 
                                    [1] = v224.desync_type
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.from:depend({
                                    [1] = nil, 
                                    [2] = "From/To", 
                                    [1] = v224.desync_type
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                v224.to:depend({
                                    [1] = nil, 
                                    [2] = "From/To", 
                                    [1] = v224.desync_type
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.body
                                });
                                local v226 = {};
                                l_v214_0.yaw_mode_ex = v226;
                                local v227 = l_v214_0.yaw_mode:create();
                                v226.offset_left = v227:slider(l_string_0:format("angles-right", "Left Offset", 0, 10, 0), -180, 180, 0, 1, "\194\176");
                                v226.offset_right = v227:slider(l_string_0:format("angles-right", "Right Offset", 0, 10, 0), -180, 180, 0, 1, "\194\176");
                                v226.yaw_random = v227:slider(l_string_0:format("angle-right", "\a{Small Text}Randomization", 20, 10, 0, "\a{Small Text}"), 0, 100, 0, 1, "%");
                                v226.sep = v227:label(" \a{Small Text}\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128");
                                v226.delay_mode = v227:slider(l_string_0:format("code-branch", "Delay type", 0, 10, 0), 0, 3, 0, 1, function(v228)
                                    return ({
                                        [0] = "Off", 
                                        [1] = "Default", 
                                        [2] = "Random", 
                                        [3] = "Ways"
                                    })[v228];
                                end);
                                v226.delay_default = v227:slider(l_string_0:format(point, "Delay", 20, 10, 0), 2, 20, 2, 1, "t");
                                v226.delay_random_min = v227:slider(l_string_0:format("angles-right", "[1]", 20, 10, 0), 2, 20, 2, 1, "t");
                                v226.delay_random_max = v227:slider(l_string_0:format("angles-right", "[2]", 20, 10, 0), 2, 20, 4, 1, "t");
                                v226.delay_slider_create = v227:slider(l_string_0:format("code", "Ways", 10, 10, 0), 2, 8, 2, 1);
                                for v229 = 1, 8 do
                                    local l_v229_0 = v229;
                                    do
                                        local l_l_v229_0_0 = l_v229_0;
                                        l_v214_0["delay_" .. l_l_v229_0_0] = v227:slider(l_string_0:format(point, tostring(l_l_v229_0_0), 15 + 5 * l_l_v229_0_0, 10, 0), 2, 20, 2, nil, "t"):depend({
                                            [1] = l_states_0, 
                                            [2] = l_v211_0
                                        }, {
                                            [1] = l_teams_0, 
                                            [2] = l_v213_0
                                        }, {
                                            [1] = nil, 
                                            [2] = "Left/Right", 
                                            [1] = l_v214_0.yaw_mode
                                        }, {
                                            [1] = nil, 
                                            [2] = 3, 
                                            [1] = v226.delay_mode
                                        }, {
                                            [1] = v226.delay_slider_create, 
                                            [2] = function()
                                                -- upvalues: l_l_v229_0_0 (ref), v226 (ref)
                                                return l_l_v229_0_0 <= 2 or v226.delay_slider_create:get() >= l_l_v229_0_0;
                                            end
                                        });
                                    end;
                                end;
                                v226.offset_left:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Left/Right", 
                                    [1] = l_v214_0.yaw_mode
                                });
                                v226.offset_right:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Left/Right", 
                                    [1] = l_v214_0.yaw_mode
                                });
                                v226.yaw_random:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Left/Right", 
                                    [1] = l_v214_0.yaw_mode
                                });
                                v226.sep:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Left/Right", 
                                    [1] = l_v214_0.yaw_mode
                                });
                                v226.delay_mode:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Left/Right", 
                                    [1] = l_v214_0.yaw_mode
                                });
                                v226.delay_default:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Left/Right", 
                                    [1] = l_v214_0.yaw_mode
                                }, {
                                    [1] = nil, 
                                    [2] = 1, 
                                    [1] = v226.delay_mode
                                });
                                v226.delay_random_min:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Left/Right", 
                                    [1] = l_v214_0.yaw_mode
                                }, {
                                    [1] = nil, 
                                    [2] = 2, 
                                    [1] = v226.delay_mode
                                });
                                v226.delay_random_max:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Left/Right", 
                                    [1] = l_v214_0.yaw_mode
                                }, {
                                    [1] = nil, 
                                    [2] = 2, 
                                    [1] = v226.delay_mode
                                });
                                v226.delay_slider_create:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Left/Right", 
                                    [1] = l_v214_0.yaw_mode
                                }, {
                                    [1] = nil, 
                                    [2] = 3, 
                                    [1] = v226.delay_mode
                                });
                                l_v214_0.tickbase = l_groups_0.snap_builder:combo(l_string_0:format("clock", "Tickbase", 0, 10, 0, "\a{Small Text}"), {
                                    [1] = "Neverlose", 
                                    [2] = "Advanced"
                                }):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = l_elements_0.force_break_lc, 
                                    [2] = function()
                                        -- upvalues: l_elements_0 (ref), l_v211_0 (ref)
                                        return l_elements_0.force_break_lc:get(l_v211_0);
                                    end
                                });
                                local v232 = l_v214_0.tickbase:create();
                                l_v214_0.tickbase_randomize = v232:switch(l_string_0:format("shuffle", "Randomize", 0, 10, 0), true):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Advanced", 
                                    [1] = l_v214_0.tickbase
                                });
                                l_v214_0.tickbase_choke = v232:slider(l_string_0:format("angles-right", "Choke", 20, 10, 0), 2, 22, 16, nil, function(v233)
                                    return ({
                                        [2] = "Sharp", 
                                        [22] = "Smooth"
                                    })[v233] or v233 .. "t";
                                end):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Advanced", 
                                    [1] = l_v214_0.tickbase
                                }, {
                                    [1] = nil, 
                                    [2] = false, 
                                    [1] = l_v214_0.tickbase_randomize
                                });
                                l_v214_0.tickbase_rndm_type = v232:combo(l_string_0:format("sliders", "Type", 0, 10, 0), {
                                    [1] = "Default", 
                                    [2] = "Ways"
                                }):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Advanced", 
                                    [1] = l_v214_0.tickbase
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.tickbase_randomize
                                });
                                l_v214_0.tickbase_rndm = v232:slider(l_string_0:format("angles-right", "[1]", 20, 10, 0), 2, 22, 16, nil, function(v234)
                                    return ({
                                        [2] = "Sharp", 
                                        [22] = "Smooth"
                                    })[v234] or v234 .. "t";
                                end):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Advanced", 
                                    [1] = l_v214_0.tickbase
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.tickbase_randomize
                                }, {
                                    [1] = nil, 
                                    [2] = "Default", 
                                    [1] = l_v214_0.tickbase_rndm_type
                                });
                                l_v214_0.tickbase_rndm_2 = v232:slider(l_string_0:format("angles-right", "[2]", 20, 10, 0), 2, 22, 16, nil, function(v235)
                                    return ({
                                        [2] = "Sharp", 
                                        [22] = "Smooth"
                                    })[v235] or v235 .. "t";
                                end):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Advanced", 
                                    [1] = l_v214_0.tickbase
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.tickbase_randomize
                                }, {
                                    [1] = nil, 
                                    [2] = "Default", 
                                    [1] = l_v214_0.tickbase_rndm_type
                                });
                                l_v214_0.tickbase_sliders = v232:slider(l_string_0:format("list", "Sliders", 0, 10, 0), 2, 8, 3):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Advanced", 
                                    [1] = l_v214_0.tickbase
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.tickbase_randomize
                                }, {
                                    [1] = nil, 
                                    [2] = "Ways", 
                                    [1] = l_v214_0.tickbase_rndm_type
                                });
                                for v236 = 1, 8 do
                                    local l_v236_0 = v236;
                                    do
                                        local l_l_v236_0_0 = l_v236_0;
                                        l_v214_0["tickbase_" .. l_l_v236_0_0] = v232:slider(l_string_0:format("angles-right", tostring(l_l_v236_0_0), 14 + 5 * l_l_v236_0_0, 10, 0), 2, 22, math.random(2), nil, "t"):depend({
                                            [1] = l_states_0, 
                                            [2] = l_v211_0
                                        }, {
                                            [1] = l_teams_0, 
                                            [2] = l_v213_0
                                        }, {
                                            [1] = nil, 
                                            [2] = "Advanced", 
                                            [1] = l_v214_0.tickbase
                                        }, {
                                            [1] = nil, 
                                            [2] = true, 
                                            [1] = l_v214_0.tickbase_randomize
                                        }, {
                                            [1] = nil, 
                                            [2] = "Ways", 
                                            [1] = l_v214_0.tickbase_rndm_type
                                        }, {
                                            [1] = l_v214_0.tickbase_sliders, 
                                            [2] = function()
                                                -- upvalues: l_l_v236_0_0 (ref), l_v214_0 (ref)
                                                return l_l_v236_0_0 <= l_v214_0.tickbase_sliders:get();
                                            end
                                        });
                                    end;
                                end;
                                l_v214_0.tickbase_reset = v232:button(l_string_0:format("rotate-left", "Reset", 0, 10, 0), function()
                                    -- upvalues: l_v214_0 (ref)
                                    l_v214_0.tickbase_sliders:set(3);
                                    for v239 = 1, 8 do
                                        l_v214_0["tickbase_" .. v239]:set(2);
                                    end;
                                end, true):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Advanced", 
                                    [1] = l_v214_0.tickbase
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.tickbase_randomize
                                }, {
                                    [1] = nil, 
                                    [2] = "Ways", 
                                    [1] = l_v214_0.tickbase_rndm_type
                                });
                                l_v214_0.tickbase_randomize_x = v232:button(l_string_0:format("shuffle", "Random", 0, 10, 0), function()
                                    -- upvalues: l_v214_0 (ref)
                                    for v240 = 1, l_v214_0.tickbase_sliders:get() do
                                        l_v214_0["tickbase_" .. v240]:set(math.random(1, 20));
                                    end;
                                end, true):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Advanced", 
                                    [1] = l_v214_0.tickbase
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.tickbase_randomize
                                }, {
                                    [1] = nil, 
                                    [2] = "Ways", 
                                    [1] = l_v214_0.tickbase_rndm_type
                                });
                                l_v214_0.tickbase_random_plus = v232:button(l_string_0:format("shuffle", "Random +", 0, 10, 0), function()
                                    -- upvalues: l_v214_0 (ref)
                                    local v241 = math.random(3, 8);
                                    l_v214_0.tickbase_sliders:set(v241);
                                    for v242 = 1, v241 do
                                        l_v214_0["tickbase_" .. v242]:set(math.random(1, 20));
                                    end;
                                end, true):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = "Advanced", 
                                    [1] = l_v214_0.tickbase
                                }, {
                                    [1] = nil, 
                                    [2] = true, 
                                    [1] = l_v214_0.tickbase_randomize
                                }, {
                                    [1] = nil, 
                                    [2] = "Ways", 
                                    [1] = l_v214_0.tickbase_rndm_type
                                });
                                l_elements_0.fs_allowes:depend({
                                    [1] = nil, 
                                    [2] = 8, 
                                    [1] = l_states_0
                                }, {
                                    [1] = nil, 
                                    [2] = 1, 
                                    [1] = l_selectable_0
                                });
                                l_v214_0.yaw_mode:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = l_states_0, 
                                    [2] = function(v243)
                                        return v243.value ~= 9;
                                    end
                                }, {
                                    [1] = nil, 
                                    [2] = 1, 
                                    [1] = l_selectable_0
                                });
                                l_v214_0.modifier:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = 1, 
                                    [1] = l_selectable_0
                                });
                                l_v214_0.body:depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = 1, 
                                    [1] = l_selectable_0
                                });
                                l_v214_0.yaw_offset:depend({
                                    [1] = nil, 
                                    [2] = 1, 
                                    [1] = l_selectable_0
                                });
                                l_v214_0.tickbase:depend({
                                    [1] = nil, 
                                    [2] = 1, 
                                    [1] = l_selectable_0
                                });
                                local v244 = l_v213_0 == 1 and 2 or 1;
                                l_v214_0.forward_state = l_builder_0:button(l_string_0:format("share-all", "Forward to opposite side", 10, 10, 10), function()
                                    -- upvalues: v196 (ref), l_v211_0 (ref), l_v213_0 (ref), v244 (ref)
                                    local v245 = {
                                        [1] = "yaw_mode", 
                                        [2] = "yaw_offset", 
                                        [3] = "modifier", 
                                        [4] = "modifier_offset", 
                                        [5] = "body"
                                    };
                                    local v246 = {
                                        yaw_mode_ex = {
                                            [1] = "offset_left", 
                                            [2] = "offset_right", 
                                            [3] = "yaw_random", 
                                            [4] = "delay_mode", 
                                            [5] = "delay_default", 
                                            [6] = "delay_random_min", 
                                            [7] = "delay_random_max", 
                                            [8] = "delay_slider_create"
                                        }, 
                                        modifier_options = {
                                            [1] = "randomize", 
                                            [2] = "mode", 
                                            [3] = "min", 
                                            [4] = "max", 
                                            [5] = "custom_sliders"
                                        }, 
                                        body_options = {
                                            [1] = "inverter", 
                                            [2] = "jitter_button", 
                                            [3] = "type", 
                                            [4] = "type_tick_value", 
                                            [5] = "type_random_value", 
                                            [6] = "desync_type", 
                                            [7] = "left_limit", 
                                            [8] = "right_limit", 
                                            [9] = "tick_slider", 
                                            [10] = "left_tick_limit", 
                                            [11] = "right_tick_limit", 
                                            [12] = "min", 
                                            [13] = "max", 
                                            [14] = "from", 
                                            [15] = "to"
                                        }
                                    };
                                    local v247 = v196.data[l_v211_0][l_v213_0];
                                    local v248 = v196.data[l_v211_0][v244];
                                    for _, v250 in ipairs(v245) do
                                        if v247[v250] and v248[v250] then
                                            v248[v250]:set(v247[v250]:get());
                                        end;
                                    end;
                                    for v251, v252 in pairs(v246) do
                                        local v253 = v247[v251];
                                        local v254 = v248[v251];
                                        if v253 and v254 then
                                            for _, v256 in ipairs(v252) do
                                                if v253[v256] and v254[v256] then
                                                    v254[v256]:set(v253[v256]:get());
                                                end;
                                            end;
                                        end;
                                    end;
                                    for v257 = 1, 8 do
                                        local v258 = v247["delay_" .. v257];
                                        local v259 = v248["delay_" .. v257];
                                        if v258 and v259 then
                                            v259:set(v258:get());
                                        end;
                                    end;
                                    for v260 = 1, 6 do
                                        local v261 = v247.modifier_options["slider_" .. v260];
                                        local v262 = v248.modifier_options["slider_" .. v260];
                                        if v261 and v262 then
                                            v262:set(v261:get());
                                        end;
                                    end;
                                    local v263 = {
                                        [1] = "tickbase", 
                                        [2] = "tickbase_randomize", 
                                        [3] = "tickbase_choke", 
                                        [4] = "tickbase_rndm_type", 
                                        [5] = "tickbase_rndm", 
                                        [6] = "tickbase_rndm_2", 
                                        [7] = "tickbase_sliders"
                                    };
                                    for _, v265 in ipairs(v263) do
                                        if v247[v265] and v248[v265] then
                                            v248[v265]:set(v247[v265]:get());
                                        end;
                                    end;
                                    for v266 = 1, 8 do
                                        local v267 = v247["tickbase_" .. v266];
                                        local v268 = v248["tickbase_" .. v266];
                                        if v267 and v268 then
                                            v268:set(v267:get());
                                        end;
                                    end;
                                    common.add_event("Settings successfully forwarded to opposite side.", "check");
                                    cvar.playvol:call("ui\\beepclear", 1);
                                end, true):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = 1, 
                                    [1] = l_selectable_0
                                }):tooltip("\n\nForwards state settings to opposite side.");
                                l_v214_0.paste = l_builder_0:button(l_string_0:format("paste", "", 10, 10, 0), function()
                                    -- upvalues: l_pui_0 (ref), v196 (ref), l_v211_0 (ref), l_v213_0 (ref), l_base64_0 (ref), l_clipboard_0 (ref)
                                    local v269 = l_pui_0.setup({
                                        [1] = v196.data[l_v211_0][l_v213_0]
                                    }, true);
                                    local v270 = l_base64_0.decode(l_clipboard_0.get());
                                    v269:load(msgpack.unpack(v270));
                                    common.add_event("Settings pasted from clipboard", "check");
                                    cvar.playvol:call("ui\\beepclear", 1);
                                end, true):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = 1, 
                                    [1] = l_selectable_0
                                }):tooltip("Paste\n\n\a{Small Text}Paste state settings from clipboard");
                                l_v214_0.copy = l_builder_0:button(l_string_0:format("copy", "", 10, 10, 0), function()
                                    -- upvalues: l_pui_0 (ref), v196 (ref), l_v211_0 (ref), l_v213_0 (ref), l_base64_0 (ref), l_clipboard_0 (ref)
                                    local v271 = l_pui_0.setup({
                                        [1] = v196.data[l_v211_0][l_v213_0]
                                    }, true);
                                    local v272 = l_base64_0.encode(msgpack.pack(v271:save()));
                                    l_clipboard_0.set(v272);
                                    common.add_event("Settings copied to clipboard", "check");
                                    cvar.playvol:call("ui\\beepclear", 1);
                                end, true):depend({
                                    [1] = l_states_0, 
                                    [2] = l_v211_0
                                }, {
                                    [1] = l_teams_0, 
                                    [2] = l_v213_0
                                }, {
                                    [1] = nil, 
                                    [2] = 1, 
                                    [1] = l_selectable_0
                                }):tooltip("Copy\n\n\a{Small Text}Copy state settings to clipboard");
                            end;
                        end;
                    end;
                end;
            end;
            _shared_selectable = l_elements_0.selectable;
            return;
        end;
    end
}):struct("misc")({
    init = function(v273)
        -- upvalues: l_pui_0 (ref)
        v273.groups = {
            visuals = l_pui_0.create(v273.string:format("stars", "", 0, 0, 0), "Visuals", 1), 
            movement = l_pui_0.create(v273.string:format("stars", "", 0, 0, 0), "Movement Features", 2), 
            ragebot = l_pui_0.create(v273.string:format("stars", "", 0, 0, 0), "Aimbot Features", 2), 
            animation = l_pui_0.create(v273.string:format("stars", "", 0, 0, 0), "Animations", 1)
        };
        v273.elements = {
            no_fall_damage = v273.groups.movement:switch(v273.string:format("person-falling-burst", "No Fall Damage", 0, 10, 0, "\a{Small Text}")), 
            fast_ladder = v273.groups.movement:switch(v273.string:format("bolt-auto", "Fast Ladder", 0, 10, 0, "\a{Small Text}")), 
            aspect_ratio = v273.groups.visuals:switch(v273.string:format("fire", "Aspect Ratio", 0, 10, 0, "\a{Small Text}"), false, function(v274)
                -- upvalues: v273 (ref)
                local v276 = {
                    scale = v274:slider(v273.string:format("angles-right", "Value", 20, 10, 0), 50, 200, 177, 0.01, function(v275)
                        if v275 == 177 then
                            return "16:9";
                        elseif v275 == 161 then
                            return "16:10";
                        elseif v275 == 150 then
                            return "3:2";
                        elseif v275 == 133 then
                            return "4:3";
                        elseif v275 == 125 then
                            return "5:4";
                        else
                            return nil;
                        end;
                    end)
                };
                v276.button_4_3 = v274:button("    4:3    ", function()
                    -- upvalues: v276 (ref)
                    v276.scale:set(133);
                end, true);
                v276.button_5_4 = v274:button("    5:4    ", function()
                    -- upvalues: v276 (ref)
                    v276.scale:set(125);
                end, true);
                v276.button_16_9 = v274:button("    16:9    ", function()
                    -- upvalues: v276 (ref)
                    v276.scale:set(177);
                end, true);
                v276.button_16_10 = v274:button("   16:10   ", function()
                    -- upvalues: v276 (ref)
                    v276.scale:set(161);
                end, true);
                return v276;
            end), 
            viewmodel = v273.groups.visuals:switch(v273.string:format("sparkles", "Viewmodel", 0, 10, 0, "\a{Small Text}"), false, function(v277)
                -- upvalues: v273 (ref)
                return {
                    fov = v277:slider(v273.string:format(point, "Field Of View", 0, 10, 0), -100, 100, 68, 1), 
                    offset_x = v277:slider(v273.string:format(point, "Offset X", 0, 10, 0), -150, 150, 0, 0.1), 
                    offset_y = v277:slider(v273.string:format(point, "Offset Y", 0, 10, 0), -150, 150, 0, 0.1), 
                    offset_z = v277:slider(v273.string:format(point, "Offset Z", 0, 10, 0), -150, 150, 0, 0.1), 
                    main_hand = v277:combo(v273.string:format(point, "Hand", 0, 10, 0), {
                        [1] = "Right side", 
                        [2] = "Left side"
                    }), 
                    left_hand = v277:switch(v273.string:format("angles-right", "Knife opposite hand", 20, 10, 0)), 
                    right_hand = v277:switch(v273.string:format("angles-right", "Knife opposite hand", 20, 10, 0))
                };
            end), 
            keep_model_transparency = v273.groups.visuals:switch(v273.string:format("transporter-3", "Keep Model Transparency", 0, 10, 0, "\a{Small Text}")), 
            manual_arrows = v273.groups.visuals:switch(v273.string:format("rotate", "Manual Arrows", 0, 10, 0, "\a{Small Text}")), 
            scope_overlay = v273.groups.visuals:switch(v273.string:format("crosshairs", "Better Scope Overlay", 0, 10, 0, "\a{Small Text}")), 
            hitmarker = v273.groups.visuals:selectable(v273.string:format("wand-sparkles", "Hit Marker", 0, 10, 0, "\a{Small Text}"), {
                [1] = "2D", 
                [2] = "3D"
            }), 
            dmg_indicator = v273.groups.visuals:switch(v273.string:format("layer-plus", "Damage Indicator", 0, 10, 0, "\a{Small Text}")), 
            unlock_latency = v273.groups.ragebot:switch(v273.string:format("unlock", "Unlock Ping Spike", 0, 10, 0, "\a{Small Text}")), 
            freezetime_fakeduck = v273.groups.ragebot:switch(v273.string:format("wind", "Fakeduck on Freezetime", 0, 10, 0, "\a{Small Text}")), 
            unlock_fd_speed = v273.groups.ragebot:switch(v273.string:format("forward-fast", "Unlock FD Speed", 0, 10, 0, "\a{Small Text}")), 
            log_events = v273.groups.ragebot:switch(v273.string:format("code", "Log Events", 0, 10, 0, "\a{Small Text}")), 
            supertoss = v273.groups.ragebot:switch(v273.string:format("brackets-curly", "Super Toss", 0, 10, 0, "\a{Small Text}")), 
            fps_boost = v273.groups.ragebot:switch(v273.string:format("wand-sparkles", "Fps Boost", 0, 10, 0, "\a{Small Text}")), 
            jitter_legs = v273.groups.animation:switch(v273.string:format("user-ninja", "Jitter Legs", 0, 10, 0, "\a{Small Text}"), false, function(v278)
                -- upvalues: v273 (ref)
                return {
                    from = v278:slider(v273.string:format("angles-right", "[1]", 20, 10, 0), 0, 100, 10, 0.01, "x"), 
                    to = v278:slider(v273.string:format("angles-right", "[2]", 20, 10, 0), 0, 100, 90, 0.01, "x")
                };
            end), 
            interpolating = v273.groups.animation:switch(v273.string:format("seedling", "Interpolating", 0, 10, 0, "\a{Small Text}"), false, function(v279)
                -- upvalues: v273 (ref)
                return {
                    scale = v279:slider(v273.string:format("angles-right", "Value", 20, 10, 0), 0, 14, 0, 1, function(v280)
                        if v280 == 0 then
                            return "Default";
                        elseif v280 == 4 then
                            return "Low";
                        elseif v280 == 9 then
                            return "High";
                        elseif v280 == 14 then
                            return "Max.";
                        else
                            return v280 .. "t";
                        end;
                    end)
                };
            end), 
            leaning = v273.groups.animation:slider(v273.string:format("person-burst", "Leaning", 0, 10, 0, "\a{Small Text}"), 0, 100, 0, 1, function(v281)
                if v281 == 0 then
                    return "Default";
                else
                    return v281 .. "%";
                end;
            end), 
            falling = v273.groups.animation:slider(v273.string:format("person-falling-burst", "Falling", 0, 10, 0, "\a{Small Text}"), 0, 100, 0, 1, function(v282)
                if v282 == 0 then
                    return "Default";
                else
                    return v282 .. "%";
                end;
            end)
        };
        v273.elements.fps_boost:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.interpolating.scale:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.interpolating
        });
        v273.elements.jitter_legs.from:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.jitter_legs
        });
        v273.elements.jitter_legs.to:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.jitter_legs
        });
        v273.elements.jitter_legs:set_callback(function(v283)
            -- upvalues: v273 (ref)
            if v283:get() then
                v273.elements.jitter_legs.from:set(10);
                v273.elements.jitter_legs.to:set(90);
            end;
        end);
        local v284 = v273.elements.leaning:create();
        v273.elements.earthquake = v284:switch(v273.string:format("stars", "Earthquake", 20, 10, 0));
        local v285 = v273.elements.log_events:create();
        v273.elements.log_events_mode = v285:selectable(v273.string:format(point, "Log Events", 0, 10, 0), {
            [1] = "Purchases Events", 
            [2] = "Ragebot Events"
        }):depend(v273.elements.log_events);
        v273.elements.log_events_prefix_color = v285:color_picker(v273.string:format(point, "Prefix Color", 20, 10, 0), color(255, 255, 255, 255)):depend(v273.elements.log_events, {
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.log_events_mode
        });
        v273.elements.log_events_main_color = v285:color_picker(v273.string:format(point, "Main Color", 20, 10, 0), color(255, 255, 255, 175)):depend(v273.elements.log_events, {
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.log_events_mode
        });
        v273.elements.log_events_prefix = v285:input(v273.string:format(point, "Prefix", 20, 10, 0), "godsense"):depend(v273.elements.log_events, {
            [1] = nil, 
            [2] = "Ragebot Events", 
            [1] = v273.elements.log_events_mode
        });
        v273.elements.log_events_alternative = v285:switch(v273.string:format(point, "Alternative", 20, 10, 0)):depend(v273.elements.log_events, {
            [1] = nil, 
            [2] = "Ragebot Events", 
            [1] = v273.elements.log_events_mode
        });
        local v286 = v273.elements.dmg_indicator:create();
        v273.elements.dmg_indicator_mode = v286:combo(v273.string:format(point, "Mode", 20, 10, 0), {
            [1] = "Default", 
            [2] = "Advanced"
        }):depend(v273.elements.dmg_indicator);
        local v287 = v273.elements.hitmarker:create();
        v273.elements.hitmarker_color = v287:color_picker(v273.string:format(point, "Color 2D", 20, 10, 0), color(255, 255, 255, 140)):depend({
            [1] = nil, 
            [2] = "2D", 
            [1] = v273.elements.hitmarker
        });
        v273.elements.hitmarker_time = v287:slider(v273.string:format(point, "Duration", 20, 10, 0), 0, 100, 2, 0.1, "s"):depend({
            [1] = nil, 
            [2] = "2D", 
            [1] = v273.elements.hitmarker
        });
        v273.elements.hitmarker_color2 = v287:color_picker(v273.string:format(point, "Color 3D", 20, 10, 0), color(255, 255, 255, 255)):depend({
            [1] = nil, 
            [2] = "3D", 
            [1] = v273.elements.hitmarker
        });
        v273.elements.hitmarker_time2 = v287:slider(v273.string:format(point, "Duration", 20, 10, 0), 0, 100, 20, 0.1, "s"):depend({
            [1] = nil, 
            [2] = "3D", 
            [1] = v273.elements.hitmarker
        });
        local v288 = v273.elements.scope_overlay:create();
        v273.elements.scope_overlay_options = v288:selectable(v273.string:format(point, "Options", 20, 10, 0), {
            [1] = "Inverted"
        }):depend(v273.elements.scope_overlay);
        v273.elements.scope_overlay_length = v288:slider(v273.string:format(point, "Length", 20, 10, 0), 10, 300, 185):depend(v273.elements.scope_overlay);
        v273.elements.scope_overlay_gap = v288:slider(v273.string:format(point, "Gap", 20, 10, 0), 1, 300, 5):depend(v273.elements.scope_overlay);
        v273.elements.scope_overlay_color = v288:color_picker(v273.string:format(point, "Main Accent", 20, 10, 0), color(255, 255, 255, 255)):depend(v273.elements.scope_overlay);
        v273.elements.scope_overlay_edge = v288:color_picker(v273.string:format(point, "Edge Accent", 20, 10, 0), color(255, 255, 255, 0)):depend(v273.elements.scope_overlay);
        local v289 = v273.elements.manual_arrows:create();
        v273.elements.arrows_accent = v289:color_picker(v273.string:format("angles-right", "Accent", 20, 10, 0), color(255, 255, 255, 255)):depend(v273.elements.manual_arrows);
        v273.elements.arrows_font = v289:combo(v273.string:format("angles-right", "Font", 20, 10, 0), {
            [1] = "Default", 
            [2] = "Pixel", 
            [3] = "Console", 
            [4] = "Bold", 
            [5] = "Large"
        }):depend(v273.elements.manual_arrows);
        v273.elements.arrows_forward = v289:input(v273.string:format("angles-right", "Forward", 20, 10, 0), "^"):depend(v273.elements.manual_arrows);
        v273.elements.arrows_left = v289:input(v273.string:format("angles-right", "Left", 20, 10, 0), "<"):depend(v273.elements.manual_arrows);
        v273.elements.arrows_right = v289:input(v273.string:format("angles-right", "Right", 20, 10, 0), ">"):depend(v273.elements.manual_arrows);
        v273.elements.aspect_ratio.scale:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.aspect_ratio
        });
        v273.elements.aspect_ratio.button_4_3:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.aspect_ratio
        });
        v273.elements.aspect_ratio.button_5_4:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.aspect_ratio
        });
        v273.elements.aspect_ratio.button_16_9:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.aspect_ratio
        });
        v273.elements.aspect_ratio.button_16_10:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.aspect_ratio
        });
        v273.elements.viewmodel.fov:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.viewmodel
        });
        v273.elements.viewmodel.offset_x:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.viewmodel
        });
        v273.elements.viewmodel.offset_y:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.viewmodel
        });
        v273.elements.viewmodel.offset_z:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.viewmodel
        });
        v273.elements.viewmodel.main_hand:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.viewmodel
        });
        v273.elements.viewmodel.left_hand:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.viewmodel
        }, {
            [1] = nil, 
            [2] = "Right side", 
            [1] = v273.elements.viewmodel.main_hand
        });
        v273.elements.viewmodel.right_hand:depend({
            [1] = nil, 
            [2] = true, 
            [1] = v273.elements.viewmodel
        }, {
            [1] = nil, 
            [2] = "Left side", 
            [1] = v273.elements.viewmodel.main_hand
        });
        v273.elements.viewmodel:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.no_fall_damage:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.fast_ladder:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.aspect_ratio:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.keep_model_transparency:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.manual_arrows:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.dmg_indicator:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.hitmarker:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.scope_overlay:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.unlock_latency:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.freezetime_fakeduck:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.unlock_fd_speed:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.log_events:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.supertoss:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.interpolating:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.leaning:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.jitter_legs:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        v273.elements.falling:depend({
            [1] = nil, 
            [2] = 2, 
            [1] = _shared_selectable
        });
        _shared_misc = v273;
    end
}):struct("avoid_backstab")({
    reference = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Avoid Backstab"), 
    invoke = function(v290)
        local function v292(v291)
            -- upvalues: v290 (ref)
            v290.reference:override(v291:get());
        end;
        v290.antiaim.elements.options_gear.avoid_backstab:set_callback(v292, true);
    end
}):struct("watermark")({
    pos_loaded = false, 
    dragging = false, 
    _cached_hw = 0, 
    _cached_hh = 0, 
    _enc_chars = "abcdefghijklmnopqrstuvwxyz0123456789~!@#$%^&*+-/=?_<>", 
    screen = render.screen_size(), 
    position = vector(0, 0), 
    drag_offset = vector(0, 0), 
    c_white = color(255, 255, 255, 255), 
    _rainbow_colors = {
        color(255, 0, 0, 255), 
        color(255, 127, 0, 255), 
        color(255, 255, 0, 255), 
        color(0, 255, 0, 255), 
        color(0, 0, 255, 255), 
        color(75, 0, 130, 255), 
        color(148, 0, 211, 255), 
        color(255, 0, 0, 255)
    }, 
    save_pos = function(_, v294, v295)
        db.godsense_watermark_x = v294;
        db.godsense_watermark_y = v295;
    end, 
    load_pos = function(v296)
        local l_godsense_watermark_x_0 = db.godsense_watermark_x;
        local l_godsense_watermark_y_0 = db.godsense_watermark_y;
        if l_godsense_watermark_x_0 and l_godsense_watermark_y_0 then
            v296.loaded_x = l_godsense_watermark_x_0;
            v296.loaded_y = l_godsense_watermark_y_0;
        end;
        v296.pos_loaded = true;
    end, 
    is_point_in_rect = function(_, v300, v301)
        return v300.x >= v301.x1 and v300.x <= v301.x2 and v300.y >= v301.y1 and v300.y <= v301.y2;
    end, 
    on_render = function(v302)
        -- upvalues: l_pui_0 (ref)
        if not globals.is_in_game then
            return;
        else
            local l_watermark_gear_3 = v302.home.elements.watermark_gear;
            if not v302.pos_loaded then
                v302:load_pos();
            end;
            if v302.loaded_x then
                l_watermark_gear_3.pos_x:set(v302.loaded_x);
                l_watermark_gear_3.pos_y:set(v302.loaded_y);
                v302.loaded_x = nil;
                v302.loaded_y = nil;
            end;
            local v304 = l_watermark_gear_3.input:get();
            if not v304 or v304 == "" then
                return;
            else
                local l_realtime_0 = globals.realtime;
                local v306 = l_watermark_gear_3.font:get();
                local v307 = ({
                    Bold = 4, 
                    Default = 1, 
                    Pixel = 2, 
                    Console = 3
                })[v306] or 1;
                local v308 = l_watermark_gear_3.mode:get("Rainbow");
                local v309 = l_watermark_gear_3.mode:get("Encode");
                local v310 = l_watermark_gear_3.mode:get("Pulse") and math.sin(l_realtime_0 * 5) * 0.5 + 0.5 or 1;
                if v309 then
                    local l__enc_chars_0 = v302._enc_chars;
                    local v312 = #l__enc_chars_0;
                    local v313 = #v304;
                    local v314 = math.floor(math.clamp(math.abs(l_realtime_0 * 0.5 % 2 - 1) * (v313 + 1), 0, v313));
                    local v315 = {};
                    for v316 = 1, v313 do
                        local v317 = math.random(v312);
                        v315[v316] = l__enc_chars_0:sub(v317, v317);
                    end;
                    v304 = v304:sub(1, v314) .. table.concat(v315):sub(v314 + 1);
                end;
                if v306 == "Pixel" then
                    v304 = v304.upper(v304);
                end;
                if v304 ~= v302._last_text or v306 ~= v302._last_font_name then
                    v302._cached_size = render.measure_text(v307, "c", v304);
                    v302._cached_hw = v302._cached_size.x * 0.5;
                    v302._cached_hh = v302._cached_size.y * 0.5;
                    v302._last_text = v304;
                    v302._last_font_name = v306;
                end;
                local l__cached_hw_0 = v302._cached_hw;
                local l__cached_hh_0 = v302._cached_hh;
                local v320 = nil;
                local v321 = nil;
                if v308 then
                    local l__rainbow_colors_0 = v302._rainbow_colors;
                    local v323 = 4;
                    local v324 = {};
                    local v325 = 0;
                    local v326 = #v304;
                    local v327 = 1;
                    local v328 = math.floor(255 * v310);
                    while v327 <= v326 do
                        local v329 = v304.byte(v304, v327);
                        local v330 = nil;
                        if v329 >= 240 then
                            v330 = v304.sub(v304, v327, v327 + 3);
                            v327 = v327 + 4;
                        elseif v329 >= 224 then
                            v330 = v304.sub(v304, v327, v327 + 2);
                            v327 = v327 + 3;
                        elseif v329 >= 192 then
                            v330 = v304.sub(v304, v327, v327 + 1);
                            v327 = v327 + 2;
                        else
                            v330 = v304.sub(v304, v327, v327);
                            v327 = v327 + 1;
                        end;
                        local v331 = ((v326 > 1 and 1 - v325 / (v326 - 1) or 0) + l_realtime_0 * v323 * 0.3) % 1 * 7;
                        local v332 = math.floor(v331);
                        if v332 >= 7 then
                            v332 = 6;
                        end;
                        local v333 = v331 - v332;
                        local v334 = l__rainbow_colors_0[v332 + 1];
                        local v335 = l__rainbow_colors_0[v332 + 2];
                        v324[#v324 + 1] = "\a" .. color(math.floor(v334.r + (v335.r - v334.r) * v333), math.floor(v334.g + (v335.g - v334.g) * v333), math.floor(v334.b + (v335.b - v334.b) * v333), v328):to_hex() .. v330;
                        v325 = v325 + 1;
                    end;
                    v320 = table.concat(v324);
                    v321 = v302.c_white;
                else
                    local v336, v337 = l_watermark_gear_3.accent_color:get();
                    if v336 == "Static" then
                        local v338 = type(v337) == "table" and v337[1] or v337;
                        v321 = color(v338.r, v338.g, v338.b, math.floor(v338.a * v310));
                        v320 = v304;
                    else
                        local v339 = v337[1] or v302.c_white;
                        local v340 = v337[2] or v302.c_white;
                        v320 = v302.string:wave(v304, l_realtime_0, color(v339.r, v339.g, v339.b, math.floor(v339.a * v310)), color(v340.r, v340.g, v340.b, math.floor(v340.a * v310)));
                        v321 = v302.c_white;
                    end;
                end;
                local l_x_0 = v302.screen.x;
                local l_y_0 = v302.screen.y;
                if v302._sp_hw ~= l__cached_hw_0 or v302._sp_hh ~= l__cached_hh_0 then
                    v302._sp_hw = l__cached_hw_0;
                    v302._sp_hh = l__cached_hh_0;
                    v302._snap_points = {
                        [1] = {
                            label = "Bottom Center", 
                            pos = vector(l_x_0 * 0.5, l_y_0 - l__cached_hh_0 - 8)
                        }, 
                        [2] = {
                            label = "Left Center", 
                            pos = vector(l__cached_hw_0 + 4, l_y_0 * 0.5)
                        }, 
                        [3] = {
                            label = "Right Center", 
                            pos = vector(l_x_0 - l__cached_hw_0 - 4, l_y_0 * 0.5)
                        }
                    };
                end;
                local l__snap_points_0 = v302._snap_points;
                local v344 = vector(l_watermark_gear_3.pos_x:get(), l_watermark_gear_3.pos_y:get());
                v344.x = math.max(l__cached_hw_0, math.min(l_x_0 - l__cached_hw_0, v344.x));
                v344.y = math.max(l__cached_hh_0, math.min(l_y_0 - l__cached_hh_0, v344.y));
                l_watermark_gear_3.pos_x:set(v344.x);
                l_watermark_gear_3.pos_y:set(v344.y);
                v302.position = v344;
                local v345 = l_pui_0.get_mouse_position();
                local v346 = l_pui_0.get_alpha() > 0;
                local v347 = v302:is_point_in_rect(v345, {
                    x1 = v344.x - l__cached_hw_0, 
                    y1 = v344.y - l__cached_hh_0, 
                    x2 = v344.x + l__cached_hw_0, 
                    y2 = v344.y + l__cached_hh_0
                });
                if common.is_button_down(1) then
                    if v347 and not v302.dragging and v346 then
                        v302.dragging = true;
                        v302.drag_offset = vector(v345.x - v344.x, v345.y - v344.y);
                    end;
                elseif v302.dragging and common.is_button_released(1) then
                    v302.dragging = false;
                    v302:save_pos(l_watermark_gear_3.pos_x:get(), l_watermark_gear_3.pos_y:get());
                end;
                if v302.dragging and v346 then
                    v302.fading = false;
                    local v348 = vector(math.max(l__cached_hw_0, math.min(l_x_0 - l__cached_hw_0, v345.x - v302.drag_offset.x)), math.max(l__cached_hh_0, math.min(l_y_0 - l__cached_hh_0, v345.y - v302.drag_offset.y)));
                    local v349 = nil;
                    local l_huge_0 = math.huge;
                    local v351 = (l_x_0 * 0.009) ^ 2;
                    for _, v353 in ipairs(l__snap_points_0) do
                        local v354 = v348.x - v353.pos.x;
                        local v355 = v348.y - v353.pos.y;
                        local v356 = v354 * v354 + v355 * v355;
                        if v356 < v351 and v356 < l_huge_0 then
                            l_huge_0 = v356;
                            v349 = v353;
                        end;
                    end;
                    local v357 = v349 and v349.pos or v348;
                    if not v302.smooth_pos then
                        v302.smooth_pos = vector(v357.x, v357.y);
                    end;
                    local v358 = v349 and 0.18 or 0.35;
                    v302.smooth_pos.x = v302.smooth_pos.x + (v357.x - v302.smooth_pos.x) * v358;
                    v302.smooth_pos.y = v302.smooth_pos.y + (v357.y - v302.smooth_pos.y) * v358;
                    v302.circle_sizes = v302.circle_sizes or {};
                    v302.label_alphas = v302.label_alphas or {};
                    v302.circle_alphas = v302.circle_alphas or {};
                    v302.dist_alphas = v302.dist_alphas or {};
                    local l_x_1 = v302.smooth_pos.x;
                    local l_y_1 = v302.smooth_pos.y;
                    local l_circle_sizes_0 = v302.circle_sizes;
                    local l_label_alphas_0 = v302.label_alphas;
                    local l_circle_alphas_0 = v302.circle_alphas;
                    local l_dist_alphas_0 = v302.dist_alphas;
                    for v365, v366 in ipairs(l__snap_points_0) do
                        local v367;
                        if v349 then
                            v367 = v349.label == v366.label;
                        else
                            v367 = v349;
                        end;
                        local v368 = math.abs(math.sin(l_realtime_0 * 1.8 + v365));
                        local v369 = l_x_1 - v366.pos.x;
                        local v370 = l_y_1 - v366.pos.y;
                        local v371 = math.max(0, 1 - math.sqrt(v369 * v369 + v370 * v370) / 200);
                        l_dist_alphas_0[v365] = (l_dist_alphas_0[v365] or 0) + (v371 - (l_dist_alphas_0[v365] or 0)) * 0.06;
                        local v372 = l_dist_alphas_0[v365];
                        local v373 = v367 and 12 or 6 + v368 * 2.5;
                        l_circle_sizes_0[v365] = (l_circle_sizes_0[v365] or v373) + (v373 - (l_circle_sizes_0[v365] or v373)) * 0.06;
                        local v374 = (v367 and 40 or 45 + v368 * 20) * v372;
                        l_circle_alphas_0[v365] = (l_circle_alphas_0[v365] or v374) + (v374 - (l_circle_alphas_0[v365] or v374)) * 0.06;
                        local v375 = (v367 and 255 or 120) * v372;
                        l_label_alphas_0[v365] = (l_label_alphas_0[v365] or v375) + (v375 - (l_label_alphas_0[v365] or v375)) * 0.06;
                        local l_pos_0 = v366.pos;
                        render.circle(l_pos_0, color(255, 255, 255, math.floor(l_circle_alphas_0[v365])), l_circle_sizes_0[v365], 32, 1);
                        render.circle(l_pos_0, color(255, 255, 255, math.floor(l_circle_alphas_0[v365] * 1.3)), l_circle_sizes_0[v365] * 0.5, 32, 1);
                        render.text(1, vector(l_pos_0.x, l_pos_0.y - 20), color(255, 255, 255, math.floor(l_label_alphas_0[v365])), "c", v366.label);
                    end;
                    l_watermark_gear_3.pos_x:set(l_x_1);
                    l_watermark_gear_3.pos_y:set(l_y_1);
                    v302.position = v302.smooth_pos;
                else
                    if not v302.fading and v302.circle_sizes then
                        v302.fading = true;
                    end;
                    if v302.fading and v302.circle_sizes then
                        local v377 = true;
                        local l_circle_sizes_1 = v302.circle_sizes;
                        local l_label_alphas_1 = v302.label_alphas;
                        local l_circle_alphas_1 = v302.circle_alphas;
                        for v381, v382 in ipairs(l__snap_points_0) do
                            l_circle_sizes_1[v381] = (l_circle_sizes_1[v381] or 0) * 0.93;
                            l_label_alphas_1[v381] = (l_label_alphas_1[v381] or 0) * 0.93;
                            l_circle_alphas_1[v381] = (l_circle_alphas_1[v381] or 0) * 0.93;
                            local l_pos_1 = v382.pos;
                            render.circle(l_pos_1, color(255, 255, 255, math.floor(l_circle_alphas_1[v381])), l_circle_sizes_1[v381], 32, 1);
                            render.circle(l_pos_1, color(255, 255, 255, math.floor(l_circle_alphas_1[v381] * 1.3)), l_circle_sizes_1[v381] * 0.5, 32, 1);
                            render.text(1, vector(l_pos_1.x, l_pos_1.y - 20), color(255, 255, 255, math.floor(l_label_alphas_1[v381])), "c", v382.label);
                            if l_label_alphas_1[v381] > 0.5 then
                                v377 = false;
                            end;
                        end;
                        if v377 then
                            v302.fading = false;
                            v302.smooth_pos = nil;
                            v302.circle_sizes = nil;
                            v302.label_alphas = nil;
                            v302.circle_alphas = nil;
                            v302.dist_alphas = nil;
                        end;
                    end;
                end;
                render.text(v307, v302.position, v321, "c", v320);
                return;
            end;
        end;
    end, 
    init = function(v384)
        events.shutdown(function()
            -- upvalues: v384 (ref)
            local l_watermark_gear_4 = v384.home.elements.watermark_gear;
            db.godsense_watermark_x = l_watermark_gear_4.pos_x:get();
            db.godsense_watermark_y = l_watermark_gear_4.pos_y:get();
        end);
        local function v386()
            -- upvalues: v384 (ref)
            v384:on_render();
        end;
        v384.home.elements.watermark_gear.input:set_callback(function(v387)
            -- upvalues: v386 (ref)
            events.render(v386, v387:get() ~= "");
        end, true);
    end
}):struct("tweaks")({
    _WARMUP_INTERVAL = 4, 
    _warmup_cache_tick = -1, 
    fs_ref = l_pui_0.find("Aimbot", "Anti Aim", "Angles", "Freestanding"), 
    lag_option_ref = l_pui_0.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"), 
    get_aimbot_targets = function(_)
        local v389 = {};
        entity.get_players(true, true, function(v390)
            -- upvalues: v389 (ref)
            if v390 and v390:is_alive() then
                v389[#v389 + 1] = v390;
            end;
        end);
        return v389;
    end, 
    calculate_offset = function(_, v392, v393, v394, v395, v396)
        if v392 == "Spin" then
            return -math.fmod(globals.curtime * (v393 * 360), v394 * 2) + v394;
        elseif v392 == "Randomize" then
            return math.sin(globals.curtime * v393) * v394;
        else
            return globals.realtime % 0.2 >= 0.1 and v395 or v396;
        end;
    end, 
    warmup_think = function(v397)
        local l_tickcount_0 = globals.tickcount;
        if l_tickcount_0 - v397._warmup_cache_tick < v397._WARMUP_INTERVAL and v397._warmup_cache ~= nil then
            return v397._warmup_cache;
        else
            local v399 = entity.get_local_player();
            if not v399 or not v399:is_alive() then
                v397._warmup_cache = false;
                v397._warmup_cache_tick = l_tickcount_0;
                return false;
            else
                local v400 = entity.get_game_rules();
                if not v400 then
                    v397._warmup_cache = false;
                    v397._warmup_cache_tick = l_tickcount_0;
                    return false;
                else
                    local v401 = true;
                    entity.get_players(true, true, function(v402)
                        -- upvalues: v401 (ref)
                        if v402 and v402:is_alive() then
                            v401 = false;
                            return true;
                        else
                            return;
                        end;
                    end);
                    v397._warmup_cache = {
                        Warmup = v400.m_bWarmupPeriod == true, 
                        ["No enemies"] = v401
                    };
                    v397._warmup_cache_tick = l_tickcount_0;
                    return v397._warmup_cache;
                end;
            end;
        end;
    end, 
    warmup_check = function(v403, v404)
        local l_warmup_aa_tbl_1 = v403.antiaim.elements.warmup_aa_tbl;
        local v406 = l_warmup_aa_tbl_1.mode:get() or {};
        if #v406 == 0 then
            return false;
        else
            local v407 = v403:warmup_think();
            if type(v407) == "boolean" then
                return false;
            else
                local v408 = false;
                for _, v410 in ipairs(v406) do
                    if v407[v410] then
                        v408 = true;
                        break;
                    end;
                end;
                if not v408 then
                    return false;
                else
                    v403.lag_option_ref:override("On Peek");
                    v404.force_defensive = false;
                    local v411 = {
                        Down = "Down", 
                        Up = "Fake Up", 
                        Disabled = "Disabled"
                    };
                    v403.refs.antiaim.angles.pitch:override(v411[l_warmup_aa_tbl_1.pitch:get()] or "Disabled");
                    local v412 = v403:calculate_offset(l_warmup_aa_tbl_1.yaw:get(), l_warmup_aa_tbl_1.speed:get(), l_warmup_aa_tbl_1.range:get(), l_warmup_aa_tbl_1.left_offset:get(), l_warmup_aa_tbl_1.right_offset:get());
                    local l_angles_0 = v403.refs.antiaim.angles;
                    l_angles_0.yaw_add.offset:override(v412);
                    l_angles_0.modifier.mode:override("Disabled");
                    l_angles_0.desync.switch:override(false);
                    v403.fs_ref:override(false);
                    return true;
                end;
            end;
        end;
    end, 
    createmove = function(v414, v415)
        v414:warmup_check(v415);
    end, 
    init = function(v416)
        local function v418(v417)
            -- upvalues: v416 (ref)
            v416:createmove(v417);
        end;
        v416.antiaim.elements.warmup_aa_tbl.mode:set_callback(function(v419)
            -- upvalues: v418 (ref)
            if #v419:get() > 0 then
                events.createmove:set(v418);
            else
                events.createmove:unset(v418);
            end;
        end, true);
    end
}):struct("safe_head")({
    _last_tick = -1, 
    safe_head_until_tick = 0, 
    can_lethal_hit_stomach = function(_, v421, v422)
        local v423 = v421:get_hitbox_position(3);
        local v424 = v422:simulate_movement();
        v424:think(16);
        local v425 = v424.origin + vector(0, 0, v424.view_offset);
        local v426 = utils.trace_bullet(v422, v425, v423);
        return v426 ~= 0 and v421.m_iHealth <= v426;
    end, 
    check = function(v427, v428)
        local l_tickcount_1 = globals.tickcount;
        if v427._last_tick == l_tickcount_1 then
            return;
        else
            v427._last_tick = l_tickcount_1;
            if not v427.antiaim or not v427.antiaim.elements or not v427.antiaim.elements.options_gear then
                return;
            else
                local l_options_gear_0 = v427.antiaim.elements.options_gear;
                if l_options_gear_0.manuals:get() ~= "Disabled" or l_options_gear_0.freestanding:get() then
                    return;
                else
                    local v431 = entity.get_local_player();
                    if not v431 or not v431:is_alive() then
                        return;
                    elseif entity.get_threat(true) == nil then
                        return;
                    else
                        local v432 = v431:get_player_weapon();
                        if not v432 then
                            return;
                        else
                            local v433 = l_options_gear_0.safe_head:get();
                            if not v433 or type(v433) ~= "table" or next(v433) == nil then
                                return;
                            else
                                local v434 = {};
                                for _, v436 in pairs(v433) do
                                    if type(v436) == "string" then
                                        v434[v436] = true;
                                    end;
                                end;
                                if next(v434) == nil then
                                    return;
                                else
                                    local v437 = entity.get_threat(false);
                                    if not v437 or not v437:is_alive() then
                                        return;
                                    else
                                        local v438 = v432:get_classname();
                                        local v439 = v438 == "CKnife";
                                        local v440 = v438 == "CWeaponTaser";
                                        local l_m_fFlags_0 = v431.m_fFlags;
                                        local v442 = v431.m_vecVelocity:length();
                                        local v443 = bit.band(l_m_fFlags_0, 1) == 0;
                                        local v444 = bit.band(l_m_fFlags_0, 4) == 4;
                                        local v445 = nil;
                                        if v443 then
                                            v445 = v444 and 7 or 6;
                                        elseif v442 > 3 then
                                            v445 = v444 and 5 or 2;
                                        else
                                            v445 = v444 and 4 or 1;
                                        end;
                                        local l_m_iTeamNum_0 = v431.m_iTeamNum;
                                        local v447 = v431.m_flDuckAmount or 0;
                                        local v448 = v447 > 0 and 45 or 60;
                                        local v449 = v431:get_origin();
                                        local v450 = v437:get_origin();
                                        local v451 = math.ceil(v449.z + v448 - (v450.z or 0));
                                        local v452 = v449.z - 35 > v450.z;
                                        local v453 = v445 == 7;
                                        local v454 = v445 == 1;
                                        local v455 = l_m_iTeamNum_0 == 3 and -35 or -20;
                                        local v456 = l_m_iTeamNum_0 == 3 and -6 or 20;
                                        local v457 = false;
                                        if v434.Knife and v439 then
                                            if v453 and v455 < v451 then
                                                v457 = not v427:can_lethal_hit_stomach(v431, v437);
                                            elseif (v434.Crouch and v445 == 4 or v434["Move Crouch"] and v445 == 5) and (l_m_iTeamNum_0 == 3 and -20 or -4) <= v451 then
                                                v457 = not v427:can_lethal_hit_stomach(v431, v437);
                                            end;
                                        end;
                                        if not v457 and v434["Zeus x27"] and v440 then
                                            if v453 and v455 < v451 then
                                                v457 = not v427:can_lethal_hit_stomach(v431, v437);
                                            elseif (v434.Crouch and v445 == 4 or v434["Move Crouch"] and v445 == 5) and (l_m_iTeamNum_0 == 3 and -20 or -4) <= v451 then
                                                v457 = not v427:can_lethal_hit_stomach(v431, v437);
                                            end;
                                        end;
                                        if not v457 and v434.Standing and v454 and v452 and v456 <= v451 then
                                            v457 = not v427:can_lethal_hit_stomach(v431, v437);
                                        end;
                                        if not v457 and v434.Crouch and v445 == 4 and v452 and (l_m_iTeamNum_0 == 3 and -20 or -4) <= v451 then
                                            v457 = not v427:can_lethal_hit_stomach(v431, v437);
                                        end;
                                        if not v457 and v434["Move Crouch"] and v445 == 5 and v452 and (l_m_iTeamNum_0 == 3 and -20 or -4) <= v451 then
                                            v457 = not v427:can_lethal_hit_stomach(v431, v437);
                                        end;
                                        if not v457 then
                                            return;
                                        else
                                            local v458 = v432:get_weapon_info();
                                            local v459 = v458 and (v458.max_speed_alt or v458.max_speed) or 250;
                                            if v431.m_bIsScoped and v458 and v458.max_speed_alt then
                                                v459 = v458.max_speed_alt;
                                            end;
                                            if v447 > 0 then
                                                v459 = v459 * 0.34;
                                            end;
                                            local v460 = v442 > 1.1 and v442 < v459 - v459 * 0.1;
                                            local v461 = v428.forwardmove or 0;
                                            local v462 = v428.sidemove or 0;
                                            local v463 = v461 > 0;
                                            local v464 = v461 < 0;
                                            local v465 = v462 > 0;
                                            local v466 = v462 < 0;
                                            local v467 = v445 == 6 or v445 == 7;
                                            local v468 = nil;
                                            if v454 then
                                                v468 = 35;
                                            elseif v467 then
                                                v468 = 32;
                                            elseif v463 then
                                                if v460 then
                                                    v468 = v465 and 33 or v466 and 20 or 20;
                                                else
                                                    v468 = v465 and 38 or v466 and 14 or 26;
                                                end;
                                            elseif v464 then
                                                v468 = v465 and 30 or v466 and 20 or 30;
                                            else
                                                v468 = v465 and 38 or v466 and 20 or 32;
                                            end;
                                            v468 = -v468 + 45;
                                            local l_angles_1 = v427.refs.antiaim.angles;
                                            l_angles_1.yaw_add.offset:override(v468);
                                            l_angles_1.modifier.mode:override("Disabled");
                                            l_angles_1.desync.switch:override(true);
                                            l_angles_1.desync.left_limit:override(1);
                                            l_angles_1.desync.right_limit:override(1);
                                            return;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end, 
    init = function(v470)
        local function v472(v471)
            -- upvalues: v470 (ref)
            v470:check(v471);
        end;
        v470.antiaim.elements.options_gear.safe_head:set_callback(function(v473)
            -- upvalues: v472 (ref)
            if #v473:get() > 0 then
                events.createmove:set(v472);
            else
                events.createmove:unset(v472);
            end;
        end, true);
    end
}):struct("log_events")({
    aim_fire = 0, 
    nade_type = {
        inferno = "Burned", 
        hegrenade = "Naded", 
        knife = "Knifed"
    }, 
    console_print = function(v474, v475, v476)
        local v477 = v474.misc.elements.log_events_prefix:get():match("^%s*(.-)%s*$");
        local v478 = (not (v477 ~= "") or v477 == nil) and "GodSense" or v477;
        local v479 = v474.misc.elements.log_events_main_color:get():to_hex();
        if v474.misc.elements.log_events_alternative:get() then
            common.add_event(string.format("%s", v475), v476 or "check");
            print_raw(string.format("\a%s%s\aDEFAULT \226\128\162 %s", v479, v478, v475));
        else
            print_dev(string.format("\a%s%s\aDEFAULT \226\128\162 %s", v479, v478, v475));
        end;
    end, 
    on_aim_fire = function(v480, _)
        v480.aim_fire = globals.server_tick;
    end, 
    aim_ack = function(v482, v483)
        local v484 = math.max(globals.server_tick - v482.aim_fire - 1, 0);
        local l_target_0 = v483.target;
        local v486 = {
            [0] = "generic", 
            [1] = "head", 
            [2] = "chest", 
            [3] = "stomach", 
            [4] = "left arm", 
            [5] = "right arm", 
            [6] = "left leg", 
            [7] = "right leg", 
            [8] = "neck", 
            [9] = "generic", 
            [10] = "gear"
        };
        local l_state_0 = v483.state;
        local v488 = l_target_0:get_name();
        local _ = l_target_0.m_iHealth;
        local l_backtrack_0 = v483.backtrack;
        local l_hitchance_0 = v483.hitchance;
        local l_damage_0 = v483.damage;
        local l_wanted_damage_0 = v483.wanted_damage;
        local v494 = v486[v483.hitgroup] or "body";
        local v495 = v486[v483.wanted_hitgroup] or "body";
        local v496 = v482.misc.elements.log_events_main_color:get():to_hex();
        if not l_target_0 then
            return;
        else
            if l_state_0 == "correction" or l_state_0 == "backtrack failure" then
                l_state_0 = "?";
            end;
            if not l_state_0 then
                v482:console_print(string.format("Hit \a%s%s\aDEFAULT's \a%s%s\aDEFAULT%s for \a%s%d\aDEFAULT%s damage [hc: \a%s%d%%\aDEFAULT \a898989FF - \aDEFAULT bt: \a%s%st\aDEFAULT]%s", v496, v488, v496, v494, v495 ~= v494 and string.format("(\aC6CBD1FF%s\aDEFAULT)", v495) or "", v496, l_damage_0, l_wanted_damage_0 ~= l_damage_0 and string.format("(\aC6CBD1FF%d\aDEFAULT)", l_wanted_damage_0) or "", v496, l_hitchance_0, v496, l_backtrack_0, v484 ~= 0 and string.format(" \aDEFAULT(delay=\a%s%.0fms\aDEFAULT)", v496, to_time(v484) * 1000) or ""), "check");
            else
                v482:console_print(string.format("\aC6CBD1FFMissed \a%s%s\aDEFAULT's \a%s%s \aDEFAULTdue to \a%s%s\aDEFAULT [hc: \a%s%d%% \a898989FF - \aDEFAULT bt: \a%s%dt\aDEFAULT] (damage: \a%s%shp\aDEFAULT)", v496, v488, v496, v495, v496, l_state_0, v496, l_hitchance_0, v496, l_backtrack_0, v496, l_wanted_damage_0), "xmark");
            end;
            return;
        end;
    end, 
    player_hurt = function(v497, v498)
        local v499 = entity.get_local_player();
        local v500 = entity.get(v498.userid, true);
        local v501 = entity.get(v498.attacker, true);
        local v502 = v497.misc.elements.log_events_main_color:get():to_hex();
        if v500 == v499 or v501 ~= v499 or v497.nade_type[v498.weapon] == nil then
            return;
        else
            v497:console_print(string.format("\aC6CBD1FF%s \a%s%s%s \aDEFAULTfor \a%s%s \aDEFAULTdamage", v497.nade_type[v498.weapon], v502, v500:get_name(), v498.health > 0 and string.format("\aDEFAULT(\aC6CBD1FF%shp\aDEFAULT)", v498.health) or "", v502, v498.dmg_health));
            return;
        end;
    end, 
    item_purchase = function(v503, v504)
        local v505 = entity.get(v504.userid, true);
        local v506 = v503.misc.elements.log_events_main_color:get():to_hex();
        if v505 == nil or not v505:is_enemy() then
            return;
        else
            local l_weapon_0 = v504.weapon;
            if l_weapon_0 == "weapon_unknown" then
                return;
            else
                local v508 = {
                    weapon_knife_butterfly = "Butterfly Knife", 
                    weapon_knife_karambit = "Karambit", 
                    weapon_deagle = "Desert Eagle", 
                    weapon_ak47 = "Ak-47", 
                    weapon_awp = "Awp", 
                    item_defuser = "Defuse Kit", 
                    weapon_taser = "Zeus X27", 
                    item_assaultsuit = "Kevlar + Helmet", 
                    weapon_glock = "Glock-18", 
                    item_kevlar = "Kevlar", 
                    weapon_c4 = "C4", 
                    weapon_decoy = "Decoy", 
                    weapon_incgrenade = "Molotov", 
                    weapon_molotov = "Molotov", 
                    weapon_smokegrenade = "Smoke", 
                    weapon_flashbang = "Flashbang", 
                    weapon_hegrenade = "HE", 
                    weapon_usp_silencer = "Usp-s", 
                    weapon_m4a4 = "M4a4", 
                    weapon_m4a1_silencer = "M4a1-s"
                };
                local function v510(v509)
                    -- upvalues: v508 (ref)
                    return v508[v509] or v509:gsub("^weapon_", ""):gsub("^item_", ""):gsub("_", " ");
                end;
                v503:console_print(string.format("\a%s%s \aDEFAULTbought \a%s%s\aDEFAULT", v506, v505:get_name(), v506, v510(l_weapon_0)), "basket-shopping");
                return;
            end;
        end;
    end, 
    init = function(v511)
        -- upvalues: l_pui_0 (ref)
        v511.logs_ref = l_pui_0.find("Miscellaneous", "Main", "Other", "Log Events");
        v511.logs_ref:override("");
        local function v512()
            -- upvalues: v511 (ref)
            v511:on_aim_fire();
        end;
        local function v514(v513)
            -- upvalues: v511 (ref)
            v511:aim_ack(v513);
        end;
        local function v516(v515)
            -- upvalues: v511 (ref)
            v511:player_hurt(v515);
        end;
        local function v518(v517)
            -- upvalues: v511 (ref)
            v511:item_purchase(v517);
        end;
        v511.misc.elements.log_events_mode:set_callback(function(v519)
            -- upvalues: v512 (ref), v514 (ref), v516 (ref), v518 (ref)
            local v520 = v519:get();
            local v521 = false;
            local v522 = false;
            for _, v524 in pairs(v520) do
                if v524 == "Ragebot Events" then
                    v521 = true;
                end;
                if v524 == "Purchases Events" then
                    v522 = true;
                end;
            end;
            if v521 then
                events.aim_fire:set(v512);
                events.aim_ack:set(v514);
                events.player_hurt:set(v516);
            else
                events.aim_fire:unset(v512);
                events.aim_ack:unset(v514);
                events.player_hurt:unset(v516);
            end;
            if v522 then
                events.item_purchase:set(v518);
            else
                events.item_purchase:unset(v518);
            end;
        end, true);
    end
}):struct("manual_arrows")({
    padding = 40, 
    color_disabled = color(0, 0, 0, 127), 
    screen = render.screen_size(), 
    center = vector(0, 0), 
    big_font = render.load_font("museo900", 20, "ad"), 
    render = function(v525)
        local v526 = entity.get_local_player();
        if not v526 or not v526:is_alive() then
            return;
        else
            local v527 = v525.antiaim.elements.options_gear.manuals:get();
            local v528 = v525.misc.elements.arrows_accent:get() or color(255, 255, 255, 255);
            local v529 = ({
                Pixel = 2, 
                Console = 3, 
                Bold = 4, 
                Default = 1, 
                Large = v525.big_font
            })[v525.misc.elements.arrows_font:get()] or "Custom";
            local v530 = nil;
            local v531 = nil;
            if v527 == "Left" then
                v530 = v525.misc.elements.arrows_left:get();
                local v532 = render.measure_text(v529, "", v530);
                v531 = vector(v525.center.x - v525.padding - v532.x, v525.center.y - v532.y * 0.5);
            elseif v527 == "Right" then
                v530 = v525.misc.elements.arrows_right:get();
                local v533 = render.measure_text(v529, "", v530);
                v531 = vector(v525.center.x + v525.padding, v525.center.y - v533.y * 0.5);
            elseif v527 == "Forward" then
                v530 = v525.misc.elements.arrows_forward:get();
                local v534 = render.measure_text(v529, "", v530);
                v531 = vector(v525.center.x - v534.x * 0.5, v525.center.y - v525.padding - v534.y);
            else
                return;
            end;
            local v535 = math.abs(math.sin(globals.realtime * 1));
            local v536, v537, v538, v539 = v528:unpack();
            local v540 = color(v536, v537, v538, v539 * (0.5 + 0.5 * v535));
            render.text(v529, v531, v540, "a", v530);
            return;
        end;
    end, 
    init = function(v541)
        v541.center = vector(v541.screen.x * 0.5, v541.screen.y * 0.5);
        local function v542()
            -- upvalues: v541 (ref)
            v541:render();
        end;
        v541.misc.elements.manual_arrows:set_callback(function(v543)
            -- upvalues: v542 (ref)
            events.render(v542, v543:get());
        end, true);
    end
}):struct("fast_ladder")({
    createmove = function(_, v545)
        local v546 = entity.get_local_player();
        if not v546 or not v546:is_alive() then
            return;
        elseif v546.m_MoveType ~= 9 then
            return;
        else
            v545.view_angles.y = math.floor(0.5 + v545.view_angles.y);
            v545.view_angles.z = 0;
            if v545.forwardmove > 0 then
                v545.view_angles.x = 89;
                v545.in_moveright = 1;
                v545.in_moveleft = 0;
                v545.in_forward = 0;
                v545.in_back = 1;
                if v545.sidemove == 0 then
                    v545.view_angles.y = v545.view_angles.y + 90;
                end;
                if v545.sidemove < 0 then
                    v545.view_angles.y = v545.view_angles.y + 150;
                end;
                if v545.sidemove > 0 then
                    v545.view_angles.y = v545.view_angles.y + 30;
                end;
            elseif v545.forwardmove < 0 then
                v545.view_angles.x = 89;
                v545.in_moveleft = 1;
                v545.in_moveright = 0;
                v545.in_forward = 1;
                v545.in_back = 0;
                if v545.sidemove == 0 then
                    v545.view_angles.y = v545.view_angles.y + 90;
                end;
                if v545.sidemove > 0 then
                    v545.view_angles.y = v545.view_angles.y + 150;
                end;
                if v545.sidemove < 0 then
                    v545.view_angles.y = v545.view_angles.y + 30;
                end;
            end;
            return;
        end;
    end, 
    init = function(v547)
        local function v549(v548)
            -- upvalues: v547 (ref)
            v547:createmove(v548);
        end;
        local function v551(v550)
            -- upvalues: v549 (ref)
            events.createmove(v549, v550:get());
        end;
        v547.misc.elements.fast_ladder:set_callback(v551, true);
    end
}):struct("no_fall_damage")({
    no_fall_damage = false, 
    last_no_fall_damage_state = false, 
    should_jump = false, 
    trace = function(_, v553)
        local v554 = entity.get_local_player();
        return utils.trace_line(v554:get_origin(), v554:get_origin() + vector(0, 0, -v553), v554).fraction < 1;
    end, 
    createmove = function(v555, v556)
        local v557 = entity.get_local_player();
        if not v557 or not v557:is_alive() then
            return;
        else
            v555.velocity_z = v557.m_vecVelocity.z;
            if v555.velocity_z > -580 then
                return;
            else
                v555.new_state = v555.velocity_z < -580 and not v555:trace(15);
                if v555.new_state ~= v555.last_no_fall_damage_state then
                    v555.no_fall_damage = v555.new_state;
                    v555.last_no_fall_damage_state = v555.new_state;
                end;
                if v555.velocity_z < -580 then
                    v556.in_duck = v555.no_fall_damage and 1 or 0;
                end;
                return;
            end;
        end;
    end, 
    init = function(v558)
        local function v560(v559)
            -- upvalues: v558 (ref)
            v558:createmove(v559);
        end;
        local function v562(v561)
            -- upvalues: v560 (ref)
            events.createmove(v560, v561:get());
        end;
        v558.misc.elements.no_fall_damage:set_callback(v562, true);
    end
}):struct("break_lc")({
    _last_tick = -1, 
    lag_option_ref = l_pui_0.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"), 
    hide_shots_ref = l_pui_0.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options"), 
    update = function(v563, v564)
        local v565 = entity.get_local_player();
        if not v565 or not v565:is_alive() then
            return;
        else
            local v566 = v565:get_player_weapon();
            if not v566 then
                return;
            else
                local v567 = v566:get_classname();
                if v563.antiaim.elements.force_break_lc_options.disable_on_grenade:get() and v567:find("Grenade") then
                    v563.lag_option_ref:override("On Peek");
                    v563.hide_shots_ref:override("Favor Fire Rate");
                    v563._cached_state = nil;
                    return;
                else
                    v563.hide_shots_ref:override(v563.antiaim.elements.force_break_lc_options.hide_shots:get());
                    local l_tickcount_2 = globals.tickcount;
                    local v569 = nil;
                    local v570 = nil;
                    if v563._last_tick ~= l_tickcount_2 then
                        local v571, v572 = v563.localplayer:state(v564);
                        v570 = v572;
                        v569 = v571;
                        v563._last_tick = l_tickcount_2;
                        v563._cached_state = v569;
                        v563._cached_team = v570;
                        if v569 and v570 then
                            v571 = v563.antiaim.data;
                            v563._cached_d = v571[v569] and v571[v569][v570] or nil;
                        else
                            v563._cached_d = nil;
                        end;
                    else
                        v569 = v563._cached_state;
                        v570 = v563._cached_team;
                    end;
                    if not v569 or not v570 then
                        v563.lag_option_ref:override("On Peek");
                        return;
                    else
                        local l__cached_d_0 = v563._cached_d;
                        if not l__cached_d_0 then
                            v563.lag_option_ref:override("On Peek");
                            return;
                        else
                            if v563.antiaim.elements.force_break_lc:get(v569) then
                                if l__cached_d_0.tickbase:get() ~= "Neverlose" then
                                    v563.lag_option_ref:override("On Peek");
                                    local l_command_number_0 = v564.command_number;
                                    if l__cached_d_0.tickbase_randomize:get() then
                                        if l__cached_d_0.tickbase_rndm_type:get() == "Default" then
                                            local v575 = l__cached_d_0.tickbase_rndm:get();
                                            local v576 = l__cached_d_0.tickbase_rndm_2:get();
                                            if v575 < v576 then
                                                v564.force_defensive = l_command_number_0 % math.random(v575, v576) == 0;
                                            end;
                                        else
                                            local v577 = l__cached_d_0.tickbase_sliders:get();
                                            if v577 > 0 then
                                                local v578 = l__cached_d_0["tickbase_" .. math.random(1, v577)];
                                                if v578 then
                                                    v564.force_defensive = l_command_number_0 % v578:get() == 0;
                                                end;
                                            end;
                                        end;
                                    else
                                        v564.force_defensive = l_command_number_0 % l__cached_d_0.tickbase_choke:get() == 0;
                                    end;
                                else
                                    v563.lag_option_ref:override("Always on");
                                end;
                            else
                                v563.lag_option_ref:override("On Peek");
                            end;
                            return;
                        end;
                    end;
                end;
            end;
        end;
    end, 
    init = function(v579)
        events.createmove(function(v580)
            -- upvalues: v579 (ref)
            v579:update(v580);
        end);
    end
}):struct("freezetime_fakeduck")({
    ready = false, 
    cnt = 0, 
    fakeduck_ref = l_pui_0.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"), 
    dt_ref = l_pui_0.find("Aimbot", "Ragebot", "Main", "Double Tap"), 
    hs_ref = l_pui_0.find("Aimbot", "Ragebot", "Main", "Hide Shots"), 
    createmove = function(v581, v582)
        local v583 = entity.get_local_player();
        if not v583 or not v583:is_alive() then
            return;
        else
            local v584 = entity.get_game_rules();
            if not v584.m_bFreezePeriod == true then
                v581.dt_ref:override();
                v581.hs_ref:override();
                return;
            else
                if v584.m_bFreezePeriod == true and v581.fakeduck_ref:get() then
                    v581.dt_ref:override(false);
                    v581.hs_ref:override(false);
                    v582.send_packet = false;
                    if v581.cnt % 14 == 0 then
                        v581.ready = true;
                    elseif v581.cnt % 14 == 6 then
                        v582.send_packet = true;
                    elseif v581.cnt % 14 == 7 then
                        v581.ready = false;
                    end;
                    v582.in_duck = v581.ready and true or false;
                    v581.cnt = v581.cnt + 1;
                else
                    v581.dt_ref:override();
                    v581.hs_ref:override();
                    v581.ready = false;
                    v581.cnt = 0;
                end;
                return;
            end;
        end;
    end, 
    override_view = function(v585, v586)
        local v587 = entity.get_local_player();
        if not v587 or not v587:is_alive() then
            return;
        else
            local v588 = entity.get_game_rules();
            if not v588.m_bFreezePeriod == true then
                return;
            else
                if v588.m_bFreezePeriod == true and v585.fakeduck_ref:get() then
                    v586.camera.z = v587:get_origin().z + 64;
                end;
                return;
            end;
        end;
    end, 
    init = function(v589)
        local function v591(v590)
            -- upvalues: v589 (ref)
            v589:createmove(v590);
        end;
        local function v593(v592)
            -- upvalues: v589 (ref)
            v589:override_view(v592);
        end;
        local function v595(v594)
            -- upvalues: v591 (ref), v593 (ref)
            events.createmove(v591, v594:get());
            events.override_view(v593, v594:get());
        end;
        v589.misc.elements.freezetime_fakeduck:set_callback(v595, true);
    end
}):struct("unlock_fd_speed")({
    fakeduck_ref = l_pui_0.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"), 
    createmove_run = function(v596, v597)
        if not v596.fakeduck_ref:get() then
            return;
        else
            local v598 = 5;
            local l_forwardmove_0 = v597.forwardmove;
            local l_sidemove_0 = v597.sidemove;
            if v598 < math.abs(l_forwardmove_0) or v598 < math.abs(l_sidemove_0) then
                local v601 = 450 / (l_forwardmove_0 * l_forwardmove_0 + l_sidemove_0 * l_sidemove_0) ^ 0.5;
                v597.forwardmove = l_forwardmove_0 * v601;
                v597.sidemove = l_sidemove_0 * v601;
            end;
            return;
        end;
    end, 
    init = function(v602)
        local function v604(v603)
            -- upvalues: v602 (ref)
            v602:createmove_run(v603);
        end;
        local function v606(v605)
            -- upvalues: v604 (ref)
            events.createmove_run(v604, v605:get());
        end;
        v602.misc.elements.unlock_fd_speed:set_callback(v606, true);
    end
}):struct("hitmarker")({
    screen_fade_time = 0.25, 
    screen_active = false, 
    screen_wait_time = 0.25, 
    world_wait_time = 5, 
    world_fade_time = 0.25, 
    center_x = 0, 
    center_y = 0, 
    screen_duration = 1, 
    hit_markers = {}, 
    screen = render.screen_size(), 
    _c_lines = color(255, 255, 255, 255), 
    _c_3d = color(255, 255, 255, 255), 
    _lines = {
        [1] = {
            [1] = 5, 
            [2] = 5, 
            [3] = 10, 
            [4] = 10
        }, 
        [2] = {
            [1] = -5, 
            [2] = 5, 
            [3] = -10, 
            [4] = 10
        }, 
        [3] = {
            [1] = -5, 
            [2] = -5, 
            [3] = -10, 
            [4] = -10
        }, 
        [4] = {
            [1] = 5, 
            [2] = -5, 
            [3] = 10, 
            [4] = -10
        }
    }, 
    draw_hit_indicator = function(v607)
        if not v607.screen_active or not globals.is_in_game then
            return;
        else
            v607.screen_wait_time = v607.screen_wait_time - globals.frametime;
            if v607.screen_wait_time <= 0 then
                v607.screen_duration = v607.screen_duration - globals.frametime / v607.screen_fade_time;
            end;
            local v608 = v607.misc.elements.hitmarker_color:get();
            local v609 = math.floor(v608.a * v607.screen_duration);
            local v610 = color(v608.r, v608.g, v608.b, v609);
            local l_center_x_0 = v607.center_x;
            local l_center_y_0 = v607.center_y;
            for _, v614 in ipairs(v607._lines) do
                render.line(vector(l_center_x_0 + v614[1], l_center_y_0 + v614[2]), vector(l_center_x_0 + v614[3], l_center_y_0 + v614[4]), v610);
            end;
            if v607.screen_duration <= 0 then
                v607.screen_active = false;
            end;
            return;
        end;
    end, 
    draw_hit_markers = function(v615)
        if not next(v615.hit_markers) then
            return;
        else
            local v616 = v615.misc.elements.hitmarker_color2:get();
            local l_frametime_0 = globals.frametime;
            local l_world_fade_time_0 = v615.world_fade_time;
            for v619 = #v615.hit_markers, 1, -1 do
                local v620 = v615.hit_markers[v619];
                if v620.fade_time <= 0 then
                    table.remove(v615.hit_markers, v619);
                else
                    v620.wait_time = v620.wait_time - l_frametime_0;
                    if v620.wait_time <= 0 then
                        v620.fade_time = v620.fade_time - l_frametime_0 / l_world_fade_time_0;
                    end;
                    if v620.position and not v620.reason then
                        local v621 = render.world_to_screen(v620.position);
                        if v621 then
                            local v622 = math.floor(v620.fade_time * 255);
                            local v623 = color(v616.r, v616.g, v616.b, v622);
                            render.rect(vector(v621.x - 1, v621.y - 5), vector(v621.x + 1, v621.y + 5), v623, 0, true);
                            render.rect(vector(v621.x - 5, v621.y - 1), vector(v621.x + 5, v621.y + 1), v623, 0, true);
                        end;
                    end;
                end;
            end;
            return;
        end;
    end, 
    init = function(v624)
        local v625 = render.screen_size();
        v624.center_x = v625.x / 2;
        v624.center_y = v625.y / 2;
        local function v626()
            -- upvalues: v624 (ref)
            v624:draw_hit_indicator();
        end;
        local function v627()
            -- upvalues: v624 (ref)
            v624:draw_hit_markers();
        end;
        v624.misc.elements.hitmarker:set_callback(function(v628)
            -- upvalues: v626 (ref), v627 (ref)
            events.render(v626, v628:get(1) and true or false);
            events.render(v627, v628:get(2) and true or false);
        end, true);
        events.round_start(function()
            -- upvalues: v624 (ref)
            v624.hit_markers = {};
            v624.screen_active = false;
        end);
        events.player_spawned(function(v629)
            -- upvalues: v624 (ref)
            if entity.get_local_player() == entity.get(v629.userid, true) then
                v624.screen_active = false;
            end;
        end);
        events.aim_ack(function(v630)
            -- upvalues: v624 (ref)
            v624.hit_markers[#v624.hit_markers + 1] = {
                fade_time = 1, 
                position = v630.aim, 
                wait_time = v624.misc.elements.hitmarker_time2:get() * 0.5, 
                reason = v630.state
            };
        end);
        events.player_hurt(function(v631)
            -- upvalues: v624 (ref)
            if entity.get_local_player() == entity.get(v631.attacker, true) then
                v624.screen_active = true;
                v624.screen_duration = 1;
                v624.screen_wait_time = v624.misc.elements.hitmarker_time:get() * 0.5;
            end;
        end);
    end
}):struct("player_transparency")({
    on_change = function(v632, v633)
        local v634 = entity.get_local_player();
        if v634 == nil or not v634:is_alive() then
            return v633;
        elseif not v632.misc.elements.keep_model_transparency:get() then
            return v633;
        else
            if v634.m_bIsScoped or v634.m_bResumeZoom then
                v633 = 59;
            end;
            return v633;
        end;
    end, 
    init = function(v635)
        events.localplayer_transparency(function(v636)
            -- upvalues: v635 (ref)
            return v635:on_change(v636);
        end);
    end
}):struct("scope_overlay")({
    animation_speed = 16, 
    animated_gap = 0, 
    animated_size = 0, 
    overlay_ref = l_pui_0.find("Visuals", "World", "Main", "Override Zoom", "Scope Overlay"), 
    screen = render.screen_size(), 
    center = vector(0, 0), 
    lerp = function(_, v638, v639, v640)
        return v638 + (v639 - v638) * math.min(v640, 1);
    end, 
    on_render = function(v641)
        local v642 = v641.misc.elements.scope_overlay:get();
        local v643 = v641.misc.elements.scope_overlay_options:get(1);
        local v644 = v641.misc.elements.scope_overlay_length:get();
        local v645 = v641.misc.elements.scope_overlay_gap:get();
        local v646 = v641.misc.elements.scope_overlay_color:get();
        local v647 = v641.misc.elements.scope_overlay_edge:get();
        local v648 = globals.frametime * v641.animation_speed;
        v641.animated_gap = v641:lerp(v641.animated_gap, v645, v648);
        v641.animated_size = v641:lerp(v641.animated_size, v644, v648);
        if not v642 then
            v641.overlay_ref:override();
            return;
        else
            local v649 = entity.get_local_player();
            if not v649 or not v649.m_bIsScoped then
                return;
            else
                v641.overlay_ref:override("Remove All");
                local v650 = 1;
                local l_x_2 = v641.center.x;
                local l_y_2 = v641.center.y;
                local l_animated_gap_0 = v641.animated_gap;
                local l_animated_size_0 = v641.animated_size;
                if v643 then
                    render.push_rotation(45, v641.screen / 2 + 1);
                end;
                render.gradient(vector(l_x_2, l_y_2 - l_animated_gap_0 - l_animated_size_0), vector(l_x_2 + v650, l_y_2 - l_animated_gap_0), v647, v647, v646, v646);
                render.gradient(vector(l_x_2, l_y_2 + l_animated_gap_0 + 1), vector(l_x_2 + v650, l_y_2 + l_animated_gap_0 + l_animated_size_0), v646, v646, v647, v647);
                render.gradient(vector(l_x_2 - l_animated_gap_0 - l_animated_size_0, l_y_2), vector(l_x_2 - l_animated_gap_0, l_y_2 + v650), v647, v646, v647, v646);
                render.gradient(vector(l_x_2 + l_animated_gap_0 + 1, l_y_2), vector(l_x_2 + l_animated_gap_0 + l_animated_size_0, l_y_2 + v650), v646, v647, v646, v647);
                if v643 then
                    render.pop_rotation();
                end;
                return;
            end;
        end;
    end, 
    init = function(v655)
        local v656 = render.screen_size();
        v655.center = vector(math.floor(v656.x / 2 + 0.5), math.floor(v656.y / 2 + 0.5));
        local function v657()
            -- upvalues: v655 (ref)
            v655:on_render();
        end;
        local function v658()
            -- upvalues: v655 (ref)
            v655.overlay_ref:override();
        end;
        local function v660(v659)
            -- upvalues: v655 (ref), v657 (ref), v658 (ref)
            v655.overlay_ref:override(v659:get() and "Remove All" or "Remove Overlay");
            events.render(v657, v659:get());
            events.shutdown(v658, v659:get());
        end;
        v655.misc.elements.scope_overlay:set_callback(v660, true);
    end
}):struct("dmg_indicator")({
    screensize = render.screen_size(), 
    verdana = render.load_font("Verdana", 10, "ad"), 
    on_render = function(v661)
        if not v661.misc.elements.dmg_indicator:get() then
            return;
        else
            local v662 = entity.get_local_player();
            if not v662 or v662.m_iHealth <= 0 then
                return;
            else
                local v663 = v661.misc.elements.dmg_indicator_mode:get();
                local v664 = ui.get_binds();
                for _, v666 in pairs(v664) do
                    if v666.name == "Min. Damage" and v666.active then
                        if v663 == "Advanced" then
                            render.text(v661.verdana, vector(v661.screensize.x / 2 + 5, v661.screensize.y / 2 - 15), color(), "", v666.value);
                            break;
                        elseif v663 == "Default" then
                            render.text(1, vector(v661.screensize.x / 2 + 4, v661.screensize.y / 2 - 15), color(), "", v666.value);
                            break;
                        else
                            break;
                        end;
                    end;
                end;
                return;
            end;
        end;
    end, 
    init = function(v667)
        local function v668()
            -- upvalues: v667 (ref)
            v667:on_render();
        end;
        local function v670(v669)
            -- upvalues: v668 (ref)
            events.render(v668, v669:get());
        end;
        v667.misc.elements.dmg_indicator:set_callback(v670, true);
    end
}):struct("unlock_latency")({
    maxunlag = cvar.sv_maxunlag, 
    init = function(v671)
        local function v672()
            -- upvalues: v671 (ref)
            v671.maxunlag:float(0.2);
        end;
        local function v674(v673)
            -- upvalues: v671 (ref), v672 (ref)
            v671.maxunlag:float(v673:get() and 0.4 or 0.2);
            events.shutdown(v672, v673:get());
        end;
        v671.misc.elements.unlock_latency:set_callback(v674, true);
    end
}):struct("viewmodel")({
    lerp_speed = 0.05, 
    target_fov = 68, 
    target_x = 0, 
    target_y = 0, 
    target_z = 0, 
    current_fov = 68, 
    current_x = 68, 
    current_y = 68, 
    current_z = 68, 
    cvar_fov = cvar.viewmodel_fov, 
    cvar_axis_x = cvar.viewmodel_offset_x, 
    cvar_axis_y = cvar.viewmodel_offset_y, 
    cvar_axis_z = cvar.viewmodel_offset_z, 
    lerp = function(_, v676, v677, v678)
        return v676 + (v677 - v676) * v678;
    end, 
    update = function(v679)
        local v680 = entity.get_local_player();
        if not v680 or not v680:is_alive() then
            return;
        elseif not _shared_misc.elements.viewmodel:get() then
            return;
        else
            v679.target_fov = _shared_misc.elements.viewmodel.fov:get();
            v679.target_x = _shared_misc.elements.viewmodel.offset_x:get() / 10;
            v679.target_y = _shared_misc.elements.viewmodel.offset_y:get() / 10;
            v679.target_z = _shared_misc.elements.viewmodel.offset_z:get() / 10;
            return;
        end;
    end, 
    apply_value = function(v681)
        local v682 = entity.get_local_player();
        if not v682 or not v682:is_alive() then
            return;
        else
            if not _shared_misc.elements.viewmodel:get() then
                v681.target_fov = 68;
                v681.target_x = 0;
                v681.target_y = 0;
                v681.target_z = 0;
            end;
            v681.current_fov = v681:lerp(v681.current_fov, v681.target_fov, v681.lerp_speed);
            v681.current_x = v681:lerp(v681.current_x, v681.target_x, v681.lerp_speed);
            v681.current_y = v681:lerp(v681.current_y, v681.target_y, v681.lerp_speed);
            v681.current_z = v681:lerp(v681.current_z, v681.target_z, v681.lerp_speed);
            v681.cvar_fov:float(v681.current_fov, true);
            v681.cvar_axis_x:float(v681.current_x, true);
            v681.cvar_axis_y:float(v681.current_y, true);
            v681.cvar_axis_z:float(v681.current_z, true);
            return;
        end;
    end, 
    apply_hand = function(_)
        local v684 = entity.get_local_player();
        if not v684 or not v684:get_player_weapon() then
            return;
        else
            local v685 = _shared_misc.elements.viewmodel.main_hand:get();
            local v686 = v684:get_player_weapon():get_classname() == "CKnife";
            local v687 = nil;
            if v686 then
                v687 = v685 == "Right side" and _shared_misc.elements.viewmodel.left_hand:get() and 0 or v685 == "Left side" and _shared_misc.elements.viewmodel.right_hand:get() and 1 or v685 == "Right side" and 1 or 0;
            else
                v687 = v685 == "Right side" and 1 or 0;
            end;
            cvar.cl_righthand:int(v687);
            return;
        end;
    end, 
    init = function(v688)
        events.pre_render(function()
            -- upvalues: v688 (ref)
            v688:update();
            v688:apply_value();
            v688:apply_hand();
        end);
    end
}):struct("aspect_ratio")({
    current_value = 100, 
    cvar_aspectratio = cvar.r_aspectratio, 
    apply_value = function(v689, v690)
        v689.current_value = v690;
        v689.cvar_aspectratio:float(v690 / 100);
    end, 
    init = function(v691)
        local function v693(v692)
            -- upvalues: v691 (ref)
            if not _shared_misc.elements.aspect_ratio:get() then
                v691.cvar_aspectratio:float(0);
                return;
            else
                v691:apply_value(v692:get());
                return;
            end;
        end;
        local function v695(v694)
            -- upvalues: v691 (ref)
            if not v694:get() then
                v691.cvar_aspectratio:float(0);
            else
                v691:apply_value(_shared_misc.elements.aspect_ratio.scale:get());
            end;
        end;
        _shared_misc.elements.aspect_ratio.scale:set_callback(v693, true);
        _shared_misc.elements.aspect_ratio:set_callback(v695, true);
        local function v697(v696)
            -- upvalues: v691 (ref)
            if not _shared_misc.elements.aspect_ratio:get() then
                return;
            else
                if _shared_misc.elements.aspect_ratio.scale:get() / 100 ~= v696:float() then
                    v691:apply_value(_shared_misc.elements.aspect_ratio.scale:get());
                end;
                return;
            end;
        end;
        v691.cvar_aspectratio:set_callback(v697);
        events.shutdown(function()
            -- upvalues: v691 (ref), v697 (ref)
            v691.cvar_aspectratio:unset_callback(v697);
            v691.cvar_aspectratio:float(0);
        end);
    end
}):struct("antiaim_update")({
    packets = 0, 
    max_angle_variation = 15, 
    current_slider = 1, 
    switch_delay = 0, 
    random_val = 0, 
    from_to_dir = 1, 
    from_to_value = 0, 
    delay_method_lim = 1, 
    delay_method = 1, 
    flicker_lim = false, 
    last_flick_at_lim = 0, 
    packets_lim = 0, 
    flicker = false, 
    last_flick_at = 0, 
    add_yaw_randomization = function(v698, v699, v700, v701, v702)
        if v700 <= 0 then
            return v699;
        else
            local v703 = v699 + (math.random() * 2 - 1) * v698.max_angle_variation * (v700 / 100);
            if v701 and v702 then
                v703 = math.min(math.max(v703, v701), v702);
            end;
            return v703;
        end;
    end, 
    update = function(v704, v705)
        local v706 = entity.get_local_player();
        if not v706 or not v706:is_alive() then
            return;
        elseif v704.tweaks:warmup_check(v705) then
            return;
        else
            local l_antiaim_0 = v704.refs.antiaim;
            local l_yaw_add_0 = l_antiaim_0.angles.yaw_add;
            local l_desync_0 = l_antiaim_0.angles.desync;
            local l_freestanding_0 = l_antiaim_0.angles.freestanding;
            local l_angles_2 = l_antiaim_0.angles;
            l_antiaim_0.enabled:override(true);
            l_yaw_add_0.roll:override(false);
            l_yaw_add_0.yaw:override("Backward");
            l_angles_2.pitch:override("Down");
            l_yaw_add_0.base:override("At Target");
            l_yaw_add_0.snap:override(false);
            local v712, v713 = v704.localplayer:state(v705);
            local v714 = v704.localplayer:disabler_state(v705);
            local l_data_0 = v704.antiaim.data;
            local v716 = l_data_0[v712] and l_data_0[v712][v713];
            if not v716 then
                return;
            else
                local l_yaw_mode_ex_0 = v716.yaw_mode_ex;
                local l_modifier_options_0 = v716.modifier_options;
                local l_body_options_0 = v716.body_options;
                local v720 = nil;
                local v721 = l_yaw_mode_ex_0.delay_mode:get();
                local v722 = l_yaw_mode_ex_0.delay_slider_create:get();
                if v716.yaw_mode:get() == "Left/Right" then
                    if v721 ~= 0 and globals.choked_commands == 0 then
                        v704.switch_delay = v704.switch_delay + 1;
                        local v723 = nil;
                        if v721 == 1 then
                            v723 = l_yaw_mode_ex_0.delay_default:get();
                        elseif v721 == 2 then
                            v723 = utils.random_int(l_yaw_mode_ex_0.delay_random_min:get(), l_yaw_mode_ex_0.delay_random_max:get());
                        elseif v721 == 3 then
                            local v724 = v716["delay_" .. v704.current_slider];
                            v723 = v724 and v724:get() or 1;
                        end;
                        if v723 <= v704.switch_delay then
                            v704.switch_delay = 0;
                            v704.flicker = not v704.flicker;
                            if v721 == 3 then
                                v704.current_slider = v704.current_slider + 1;
                                if v722 < v704.current_slider then
                                    v704.current_slider = 1;
                                end;
                            end;
                        end;
                        rage.antiaim:inverter(v704.flicker);
                        v720 = v704.flicker and l_yaw_mode_ex_0.offset_left:get() or l_yaw_mode_ex_0.offset_right:get();
                    else
                        v720 = rage.antiaim:inverter() and l_yaw_mode_ex_0.offset_left:get() or l_yaw_mode_ex_0.offset_right:get();
                    end;
                else
                    v720 = v716.yaw_offset:get();
                end;
                l_angles_2.modifier.mode:override(v716.modifier:get());
                local v725 = l_modifier_options_0.offset and l_modifier_options_0.offset:get() or 0;
                if l_modifier_options_0.randomize:get() then
                    if l_modifier_options_0.mode:get() == "Default" then
                        v725 = math.random(l_modifier_options_0.min:get(), l_modifier_options_0.max:get());
                    else
                        v725 = l_modifier_options_0["slider_" .. math.random(l_modifier_options_0.custom_sliders:get())]:get();
                    end;
                end;
                l_angles_2.modifier.offset:override(v725);
                local v726 = v716.body:get();
                l_desync_0.inverter:override(v726 and l_body_options_0.inverter:get() or false);
                l_desync_0.tweaks:override(v726 and l_body_options_0.jitter_button:get() and "Jitter" or "");
                local v727 = false;
                if v726 then
                    local v728 = l_body_options_0.type:get();
                    local v729 = l_body_options_0.type_tick_value:get();
                    local v730 = l_body_options_0.type_random_value:get();
                    v727 = v728 == "Static" or v728 == "Tick" and not (globals.tickcount % v729 <= 1) or utils.random_int(0, v730) == v730;
                    local v731 = l_body_options_0.desync_type:get();
                    local v732 = l_body_options_0.left_limit:get();
                    local v733 = l_body_options_0.right_limit:get();
                    if globals.choked_commands == 0 then
                        if v731 == "Tick" then
                            v704.packets_lim = v704.packets_lim + 1;
                            if v704.packets_lim - v704.last_flick_at_lim >= l_body_options_0.tick_slider:get() then
                                v704.flicker_lim = not v704.flicker_lim;
                                v704.last_flick_at_lim = v704.packets_lim;
                            end;
                        elseif v731 == "Random" then
                            v704.packets_lim = v704.packets_lim + 1;
                            if v704.packets_lim - v704.last_flick_at_lim >= l_body_options_0.tick_slider:get() then
                                v704.last_flick_at_lim = v704.packets_lim;
                                v704.random_val = math.random(l_body_options_0.min:get(), l_body_options_0.max:get());
                            end;
                        elseif v731 == "From/To" then
                            local v734 = l_body_options_0.from:get();
                            local v735 = l_body_options_0.to:get();
                            v704.from_to_value = math.clamp(v704.from_to_value, v734, v735);
                            v704.from_to_value = v704.from_to_value + v704.from_to_dir;
                            if v735 <= v704.from_to_value then
                                v704.from_to_value = v735;
                                v704.from_to_dir = -1;
                            elseif v704.from_to_value <= v734 then
                                v704.from_to_value = v734;
                                v704.from_to_dir = 1;
                            end;
                        end;
                    end;
                    if v731 == "Static" then
                        l_desync_0.left_limit:override(v732);
                        l_desync_0.right_limit:override(v733);
                    elseif v731 == "Random" then
                        l_desync_0.left_limit:override(v704.random_val);
                        l_desync_0.right_limit:override(v704.random_val);
                    elseif v731 == "Tick" then
                        local v736 = v704.flicker_lim and l_body_options_0.left_tick_limit:get() or l_body_options_0.right_tick_limit:get();
                        l_desync_0.left_limit:override(v736);
                        l_desync_0.right_limit:override(v736);
                    elseif v731 == "From/To" then
                        l_desync_0.left_limit:override(v704.from_to_value);
                        l_desync_0.right_limit:override(v704.from_to_value);
                    else
                        l_desync_0.left_limit:override(v732);
                        l_desync_0.right_limit:override(v733);
                    end;
                end;
                l_desync_0.switch:override(v727);
                l_desync_0.freestanding:override("Off");
                local l_options_gear_1 = v704.antiaim.elements.options_gear;
                local v738 = l_options_gear_1.freestanding:get();
                local v739 = l_options_gear_1.disablers:get(v714);
                if v738 and not v739 then
                    l_freestanding_0.body:set(l_options_gear_1.body_fs:get());
                    l_freestanding_0.switch:set(true);
                else
                    l_freestanding_0.switch:set(false);
                end;
                local v740 = l_options_gear_1.manuals:get();
                if v740 ~= "Disabled" then
                    local v741 = {
                        Forward = 180, 
                        Right = 90, 
                        Left = -90
                    };
                    if v741[v740] then
                        v720 = v741[v740];
                        l_yaw_add_0.base:override("Local View");
                        l_freestanding_0.switch:override(false);
                    end;
                end;
                if v716.yaw_mode:get() == "Left/Right" then
                    v720 = v704:add_yaw_randomization(v720, l_yaw_mode_ex_0.yaw_random:get(), -180, 180);
                end;
                l_yaw_add_0.offset:override(v720);
                return;
            end;
        end;
    end, 
    init = function(v742)
        events.createmove(function(v743)
            -- upvalues: v742 (ref)
            v742:update(v743);
        end);
    end
}):struct("animations")({
    earthquake_value = 0, 
    earthquake_counter = 0, 
    smoothed_data = {}, 
    animlayer_t = ffi.typeof("            struct {\n                bool client_blend; float blend_in; void *studio_hdr;\n                int dispatch_sequence; int second_dispatch_sequence;\n                uint32_t order; uint32_t sequence;\n                float prev_cycle; float weight; float weight_delta_rate;\n                float playback_rate; float cycle; void *entity;\n                char pad_0x0038[0x4];\n            } **\n        "), 
    get_anim_overlay = function(v744, v745, v746)
        if not v744._cast then
            v744._cast = ffi.cast(v744.animlayer_t, ffi.cast("char*", v745[0]) + 10640);
        end;
        return ffi.cast(v744.animlayer_t, ffi.cast("char*", v745[0]) + 10640)[0][v746];
    end, 
    reset = function(v747)
        v747.smoothed_data = {};
        v747._cast = nil;
    end, 
    update = function(v748, v749)
        local v750 = entity.get_local_player();
        if not v750 or not v750:is_alive() then
            if next(v748.smoothed_data) then
                v748.smoothed_data = {};
            end;
            return;
        elseif v750 ~= v749 then
            return;
        elseif not v750:get_player_weapon() then
            return;
        else
            local l_elements_1 = v748.misc.elements;
            local v752 = v750:get_index();
            local v753 = v748.smoothed_data[v752];
            if not v753 then
                v753 = {
                    smoothed_pose_p = {}, 
                    smoothed_layers = {}
                };
                for v754 = 0, 12 do
                    v753.smoothed_pose_p[v754] = 0;
                    v753.smoothed_layers[v754] = 0;
                end;
                v748.smoothed_data[v752] = v753;
            end;
            if l_elements_1.interpolating:get() then
                local v755 = l_elements_1.interpolating.scale:get();
                if v755 > 0 then
                    local v756 = globals.tickinterval * v755;
                    local v757 = 1 - v756;
                    local l_m_flPoseParameter_0 = v750.m_flPoseParameter;
                    local l_smoothed_pose_p_0 = v753.smoothed_pose_p;
                    local l_smoothed_layers_0 = v753.smoothed_layers;
                    for v761 = 0, 12 do
                        l_smoothed_pose_p_0[v761] = v756 * l_smoothed_pose_p_0[v761] + v757 * l_m_flPoseParameter_0[v761];
                        l_m_flPoseParameter_0[v761] = l_smoothed_pose_p_0[v761];
                        local v762 = v748:get_anim_overlay(v750, v761);
                        if v762 then
                            l_smoothed_layers_0[v761] = v756 * l_smoothed_layers_0[v761] + v757 * v762.weight;
                            v762.weight = l_smoothed_layers_0[v761];
                        end;
                    end;
                end;
            end;
            local v763 = v748:get_anim_overlay(v750, 12);
            if v763 then
                if l_elements_1.earthquake:get() then
                    v748.earthquake_counter = v748.earthquake_counter + 1;
                    if v748.earthquake_counter % 4 == 0 then
                        v748.earthquake_value = math.random() * 2;
                    end;
                    v763.weight = v748.earthquake_value;
                else
                    local v764 = l_elements_1.leaning:get();
                    if v764 ~= 0 then
                        v763.weight = v764 * 0.01;
                    end;
                end;
            end;
            local v765 = l_elements_1.falling:get();
            v750.m_flPoseParameter[6] = v765 ~= 0 and v765 / 100 or 0;
            if l_elements_1.jitter_legs:get() then
                local v766 = l_elements_1.jitter_legs.from:get() * 0.01;
                local v767 = l_elements_1.jitter_legs.to:get() * 0.01;
                v750.m_flPoseParameter[0] = (globals.clock_offset + globals.client_tick) % 3 == 0 and v766 or v767;
            end;
            return;
        end;
    end, 
    init = function(v768)
        local l_misc_0 = v768.refs.antiaim.misc;
        events.post_update_clientside_animation(function(v770)
            -- upvalues: v768 (ref)
            v768:update(v770);
        end);
        events.createmove(function(v771)
            -- upvalues: v768 (ref), l_misc_0 (ref)
            if v768.misc.elements.jitter_legs:get() then
                l_misc_0.slidewalk_directory:override(v771.command_number % 3 == 0 and "Walking" or "Sliding");
            else
                l_misc_0.slidewalk_directory:override();
            end;
        end);
        events.round_start(function()
            -- upvalues: v768 (ref)
            v768:reset();
        end);
        events.disconnect(function()
            -- upvalues: v768 (ref)
            v768:reset();
        end);
    end
}):struct("super_toss")({
    enabled = false, 
    solve_angles = function(_, v773, v774, v775, v776)
        local v777 = 0.3;
        v773.x = v773.x - 10 + math.abs(v773.x) / 9;
        local v778 = vector():angles(v773);
        local v779 = math.clamp(v774 * 0.9, 15, 750);
        local v780 = math.clamp(v775, 0, 1);
        v779 = v779 * (v777 + (1 - v777) * v780);
        local v781 = v776 * 1.25;
        local l_v778_0 = v778;
        for _ = 1, 8 do
            l_v778_0 = (v778 * (l_v778_0 * v779 + v781):length() - v781) / v779;
            l_v778_0:normalize();
        end;
        local v784 = l_v778_0.angles(l_v778_0);
        if v784.x > -10 then
            v784.x = 0.9 * v784.x + 9;
        else
            v784.x = 1.125 * v784.x + 11.25;
        end;
        return v784;
    end, 
    grenade_override = function(v785, v786)
        local v787 = entity.get_local_player();
        if not v787 then
            return;
        else
            local v788 = v787:get_player_weapon();
            if not v788 then
                return;
            else
                local v789 = v788:get_weapon_info();
                if not v789 then
                    return;
                else
                    v786.angles = v785:solve_angles(v786.angles, v789.throw_velocity, v788.m_flThrowStrength, v786.velocity);
                    return;
                end;
            end;
        end;
    end, 
    createmove = function(v790, v791)
        if not v791.jitter_move then
            return;
        else
            local v792 = entity.get_local_player();
            if not v792 then
                return;
            else
                local v793 = v792:get_player_weapon();
                if not v793 then
                    return;
                else
                    local v794 = v793:get_weapon_info();
                    if not v794 or v794.weapon_type ~= 9 then
                        return;
                    elseif v793.m_fThrowTime < globals.curtime - to_time(globals.clock_offset) then
                        return;
                    else
                        v791.in_speed = true;
                        local v795 = v792:simulate_movement();
                        v795:think();
                        v791.view_angles = v790:solve_angles(v791.view_angles, v794.throw_velocity, v793.m_flThrowStrength, v795.velocity);
                        return;
                    end;
                end;
            end;
        end;
    end, 
    init = function(v796)
        v796.enabled = false;
        events.createmove(function(v797)
            -- upvalues: v796 (ref)
            if v796.enabled then
                v796:createmove(v797);
            end;
        end);
        events.grenade_override_view(function(v798)
            -- upvalues: v796 (ref)
            if v796.enabled then
                v796:grenade_override(v798);
            end;
        end);
        v796.misc.elements.supertoss:set_callback(function(v799)
            -- upvalues: v796 (ref)
            v796.enabled = v799:get();
        end, true);
        v796.enabled = v796.misc.elements.supertoss:get();
    end
}):struct("fps_boost")({
    init = function(v800)
        local v801 = {
            cl_csm_translucent_shadows = 0, 
            cl_csm_entity_shadows = 0, 
            violence_hblood = 0, 
            r_drawdecals = 0, 
            r_drawrain = 0, 
            r_drawropes = 0, 
            r_drawsprites = 0, 
            dsp_slow_cpu = 1, 
            mat_disable_bloom = 1, 
            cl_showerror = 0, 
            r_eyegloss = 0, 
            r_eyemove = 0, 
            r_dynamiclighting = 0, 
            r_dynamic = 0, 
            func_break_max_pieces = 0, 
            r_3dsky = 0, 
            r_shadows = 0, 
            cl_csm_static_prop_shadows = 0, 
            cl_csm_shadows = 0, 
            cl_csm_world_shadows = 0, 
            cl_foot_contact_shadows = 0, 
            cl_csm_viewmodel_shadows = 0, 
            cl_csm_rope_shadows = 0, 
            cl_csm_sprite_shadows = 0, 
            cl_disablefreezecam = 1, 
            cl_freezecampanel_position_dynamic = 0, 
            cl_freezecameffects_showholiday = 0, 
            cl_showhelp = 0, 
            cl_autohelp = 0, 
            cl_disablehtmlmotd = 1, 
            fog_enable_water_fog = 0, 
            gameinstructor_enable = 0, 
            cl_csm_world_shadows_in_viewmodelcascade = 0, 
            cl_disable_ragdolls = 1, 
            mod_forcedata = 1
        };
        v800.element = v800.misc.elements.fps_boost;
        v800.element:set_callback(function(v802)
            -- upvalues: v801 (ref)
            local v803 = v802:get() and 0 or 1;
            for v804, v805 in pairs(v801) do
                if cvar[v804] then
                    cvar[v804]:int(v802:get() and v805 or v803);
                end;
            end;
            if v802:get() then
                common.add_event("Game CVARS optimizated!", "star");
            end;
        end);
    end
}):struct("sidebar")({
    on_render = function(v806)
        -- upvalues: l_pui_0 (ref)
        if l_pui_0.get_alpha() <= 0 then
            return;
        else
            local v807 = l_pui_0.get_style("Link Active");
            local v808 = color(v807.r, v807.g, v807.b, 200);
            local v809 = color(v807.r, v807.g, v807.b, 0);
            local v810 = v806.string:wave("G o d  \226\128\162  S e n s e ", globals.realtime, v808, v809);
            ui.sidebar(v810, "clover");
            return;
        end;
    end, 
    init = function(v811)
        local function v812()
            -- upvalues: v811 (ref)
            v811:on_render();
        end;
        events.render(v812);
    end
});
v813.home:init();
v813.antiaim:init();
v813.misc:init();
v813.localplayer:init();
v813.avoid_backstab:invoke();
v813.tweaks:init();
v813.safe_head:init();
v813.log_events:init();
v813.manual_arrows:init();
v813.fast_ladder:init();
v813.no_fall_damage:init();
v813.break_lc:init();
v813.freezetime_fakeduck:init();
v813.unlock_fd_speed:init();
v813.hitmarker:init();
v813.player_transparency:init();
v813.scope_overlay:init();
v813.dmg_indicator:init();
v813.unlock_latency:init();
v813.viewmodel:init();
v813.aspect_ratio:init();
v813.antiaim_update:init();
v813.animations:init();
v813.super_toss:init();
v813.fps_boost:init();
v813.presets:init();
v813.watermark:init();
v813.sidebar:init();