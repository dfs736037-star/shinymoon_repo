--gamesense lua
function start(...) 
        return ...
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
    local function safe_call(func, ...)
        local success, result = pcall(func, ...)
        if not success then
            return nil
        end
        return result
    end
    if not math.sign then
        math.sign = function(x)
            if x > 0 then return 1
            elseif x < 0 then return -1
            else return 0
            end
        end
    end
    
    local original_paint = client.set_event_callback
    client.set_event_callback = function(event, callback)
        if event == "paint" or event == "paint_ui" then
            return original_paint(event, function(...)
                return safe_call(callback, ...)
            end)
        end
        return original_paint(event, callback)
    end
    local render_limiter = {
        max_calls_per_frame = 800,
        current_calls = 0,
        frame_skips = 0,
        skip_heavy_renders = false
    }

    
    local original_rectangle = renderer.rectangle
    local original_circle = renderer.circle
    local original_circle_outline = renderer.circle_outline
    local original_gradient = renderer.gradient
    local original_blur = renderer.blur

    renderer.rectangle = function(...)
        render_limiter.current_calls = render_limiter.current_calls + 1
        if render_limiter.current_calls > render_limiter.max_calls_per_frame then
            return
        end
        return original_rectangle(...)
    end

    renderer.circle = function(x, y, r, g, b, a, radius, ...)
        
        radius = math.min(radius or 0, 15)
        render_limiter.current_calls = render_limiter.current_calls + math.ceil(radius / 2)
        if render_limiter.current_calls > render_limiter.max_calls_per_frame then
            return
        end
        return original_circle(x, y, r, g, b, a, radius, ...)
    end

    renderer.circle_outline = function(x, y, r, g, b, a, radius, ...)
        radius = math.min(radius or 0, 15)
        render_limiter.current_calls = render_limiter.current_calls + math.ceil(radius / 2)
        if render_limiter.current_calls > render_limiter.max_calls_per_frame then
            return
        end
        return original_circle_outline(x, y, r, g, b, a, radius, ...)
    end

    renderer.gradient = function(...)
        render_limiter.current_calls = render_limiter.current_calls + 2
        if render_limiter.current_calls > render_limiter.max_calls_per_frame then
            return
        end
        return original_gradient(...)
    end

    local is_paint_ui = false

    renderer.blur = function(x, y, w, h, alpha, amount)
        -- Block blur calls during paint_ui to prevent index buffer crashes
        if is_paint_ui then
            -- Optionally draw a semi-transparent rectangle as fallback
            if alpha and alpha > 0 then
                original_rectangle(x, y, w, h, 0, 0, 0, math.floor(alpha * 0.5))
            end
            return
        end
        
        -- Use same pattern as other renderer functions
        render_limiter.current_calls = render_limiter.current_calls + 1
        if render_limiter.current_calls > render_limiter.max_calls_per_frame then
            return
        end
        return original_blur(x, y, w, h, alpha or 1, amount or 1)
    end

    
    
    client.set_event_callback("paint", function()
        if render_limiter.current_calls > render_limiter.max_calls_per_frame * 0.9 then
            render_limiter.skip_heavy_renders = true
            render_limiter.frame_skips = render_limiter.frame_skips + 1
        else
            render_limiter.skip_heavy_renders = false
        end
        render_limiter.current_calls = 0
    end)

    
    ffi.cdef [[
        typedef unsigned long dword;
        typedef unsigned int size_t;

        typedef struct {
            uint8_t r, g, b, a;
        } color_t;
    ]]
    ffi.cdef[[
        typedef struct
        {
            uint8_t r;
            uint8_t g;
            uint8_t b;
            uint8_t a;
        } color_struct_t;
        typedef void (__cdecl* print_function)(void*, color_struct_t&, const char* text, ...);
    ]]
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
            radius = math.min(w/2, h/2, radius)
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
        findDist = function (x1, y1, z1, x2, y2, z2)
            return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
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

    local u8, device, localize, surface, notify = {}, {}, {}, {}, {}

    do 
        function u8:len(s)
            return #s:gsub("[\128-\191]", "");
        end

        local string_mod; do
            local float = 0;
            local to_alpha = 1 / 255;

            local function fn(rgb, alpha)
                return string.format("%s%02x", rgb, float * tonumber(alpha, 16));
            end

            function string_mod(s, alpha)
                float = alpha * to_alpha;
                return s:gsub("(\a%x%x%x%x%x%x)(%x%x)", fn);
            end
        end

        function device:on_update()
            local new_rect = vector(client.screen_size());

            if new_rect ~= self.rect then
                self.rect = new_rect;
            end
        end

        function device:draw_text(x, y, r, g, b, a, flags, max_width, ...)
            local text = table.concat {...};
            text = string_mod(text, a);

            renderer.text(x, y, r, g, b, a, flags, max_width, text);
        end

        local native_ConvertAnsiToUnicode = vtable_bind("localize.dll", "Localize_001", 15, "int(__thiscall*)(void* thisptr, const char *ansi, wchar_t *unicode, int buffer_size)")
        local native_ConvertUnicodeToAnsi = vtable_bind("localize.dll", "Localize_001", 16, "int(__thiscall*)(void* thisptr, wchar_t *unicode, char *ansi, int buffer_size)")

        function localize:ansi_to_unicode(ansi, unicode, buffer_size)
            return native_ConvertAnsiToUnicode(ansi, unicode, buffer_size);
        end

        function localize:unicode_to_ansi(ansi, unicode, buffer_size)
            return native_ConvertUnicodeToAnsi(ansi, unicode, buffer_size);
        end

        local native_SetTextFont = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 23, "void*(__thiscall*)(void *thisptr, dword font_id)");
        local native_SetTextColor = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 25, "void*(__thiscall*)(void *thisptr, int r, int g, int b, int a)");
        local native_SetTextPos = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 26, "void*(__thiscall*)(void *thisptr, int x, int y)");
        local native_DrawPrintText = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 28, "void*(__thiscall*)(void *thisptr, const wchar_t *text, int maxlen, int draw_type)");
        local native_CreateFont = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 71, "dword(__thiscall*)(void*)");
        local native_SetFontGlyphSet = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 72, "void(__thiscall*)(void*, dword, const char*, int, int, int, int, dword, int, int)");

        local native_GetTextSize = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 79, "void(__thiscall*)(void *thisptr, size_t font, const wchar_t *text, int &wide, int &tall)");

        local native_GetFontName = vtable_bind("vguimatsurface.dll", "VGUI_Surface031", 134, "const char*(__thiscall*)(void *thisptr, size_t font)");

        local buffer = ffi.new("wchar_t[65535]");
        local wide, tall = ffi.new("int[1]"), ffi.new("int[1]");

        local to_alpha = 1 / 255;

        function surface:get_font_name(font_id)
            return ffi.string(native_GetFontName(font_id));
        end

        function surface:create_font(font_name, size, weight)
            local font = native_CreateFont()
            native_SetFontGlyphSet(font, font_name, size, weight or 400, 0, 0, 0, 0, 0)
            return font
        end

        function surface:measure(font, text)
            localize:ansi_to_unicode(text, buffer, 65535)
            native_GetTextSize(font, buffer, wide, tall)
            return wide[0], tall[0]
        end

        function surface:text(font, x, y, r, g, b, a, ...)
            local text = table.concat {...};
            localize:ansi_to_unicode(text, buffer, 65535);

            native_GetTextSize(font, buffer, wide, tall);

            native_SetTextFont(font);
            native_SetTextPos(x, y);
            native_SetTextColor(r, g, b, a);

            native_DrawPrintText(buffer, u8:len(text), 0);

            return wide[0], tall[0];
        end

        function surface:color_text(font, x, y, r, g, b, a, ...)
            local text = table.concat {...};
            local i, j = text:find "\a";

            if i ~= nil then
                x = x + self:text(font, x, y, r, g, b, a, text:sub(1, i - 1))

                while i ~= nil do
                    local new_r, new_g, new_b, new_a = r, g, b, a;

                    if text:sub(i, j + 7) == "\adefault" then
                        text = text:sub(1 + j + 7);
                    else
                        local hex = text:sub(i + 1, j + 8);
                        text = text:sub(1 + j + 8);

                        new_r, new_g, new_b, new_a = func.frgba(hex);
                        new_a = new_a * (a * to_alpha);
                    end

                    i, j = text:find "\a";

                    local new_text = text;

                    if i ~= nil then
                        new_text = text:sub(1, i - 1);
                    end

                    x = x + self:text(font, x, y, new_r, new_g, new_b, new_a, new_text);
                end

                return;
            end

            self:text(font, x, y, r, g, b, a, text);
        end

        local native_ConsoleIsVisible = vtable_bind("engine.dll", "VEngineClient014", 11, "bool(__thiscall*)(void*)");
        local native_ColorPrint = vtable_bind("vstdlib.dll", "VEngineCvar007", 25, "void(__cdecl*)(void*, const color_t&, const char*, ...)");

        local queue = {};
        local current;

        local times = 6;
        local duration = 8;

        local buffer = ffi.new("color_t");
        local to_alpha = 1 / 255;

        local function color_print(r, g, b, a, ...)
            buffer.r, buffer.g, buffer.b, buffer.a = r, g, b, a;
            native_ColorPrint(buffer, ...);
        end

        function notify:color_log(r, g, b, a, ...)
            local text = table.concat {...};
            local i, j = text:find "\a";

            if i ~= nil then
                color_print(r, g, b, a, text:sub(1, i - 1));

                while i ~= nil do
                    local new_r, new_g, new_b, new_a = r, g, b, a;

                    if text:sub(i, j + 7) == "\adefault" then
                        text = text:sub(1 + j + 7);
                    else
                        local hex = text:sub(i + 1, j + 8);
                        text = text:sub(1 + j + 8);

                        new_r, new_g, new_b, new_a = func.frgba(hex);
                        new_a = new_a * a * to_alpha;
                    end

                    i, j = text:find "\a";

                    local new_text = text;

                    if i ~= nil then
                        new_text = text:sub(1, i - 1);
                    end

                    color_print(new_r, new_g, new_b, new_a, new_text);
                end

                color_print(0, 0, 0, 0, "\n");
                return;
            end

            color_print(r, g, b, a, text .. "\n");
        end

        function notify:add_to_queue(r, g, b, a, ...)
            local text = table.concat {...};

            local this =
            {
                text = text,
                colour = {r, g, b, a},
                colored = true,
                liferemaining = duration
            };

            queue[#queue + 1] = this;

            while #queue > times do
                table.remove(queue, 1);
            end

            return this;
        end

        function notify:should_draw()
            local is_visible = false;
            local host_frametime = globals.frametime();

            if not native_ConsoleIsVisible() then
                for i = #queue, 1, -1 do
                    local v = queue[i];
                    v.liferemaining = v.liferemaining - host_frametime;

                    if v.liferemaining <= 0 then
                        table.remove(queue, i);
                        goto continue;
                    end

                    is_visible = true;
                    ::continue::
                end
            end

            return is_visible;
        end

        function notify:on_paint_ui()
            local x, y = 8, 5;
            local flags = "d";

            for i = 1, #queue do
                local v = queue[i];

                local colour = v.colour;
                local r, g, b, a = colour[1], colour[2], colour[3], colour[4];

                local text = v.text:gsub("\n", "");
                local measure = vector(renderer.measure_text(flags, text));

                local tall = measure.y + 1;

                if v.liferemaining < .5 then
                    local f = func.fclamp(v.liferemaining, 0, .5) / .5;
                    a = a * f;

                    if i == 1 and f < .2 then
                        y = y - tall * (1 - f / .2);
                    end
                end

                if v.colored then
                    surface:color_text(63, x, y, r, g, b, a, text);
                else
                    surface:text(63, x, y, r, g, b, a, text);
                end

                y = y + tall;
            end
        end

        function notify:on_console_input(e)
            if e:find("clear") == 1 then
                for i = 1, #queue do
                    queue[i] = nil;
                end
            end
        end
    end

    device:on_update()

client.set_event_callback("paint_ui", function()
    is_paint_ui = true
    device:on_update()
    if notify:should_draw() then
        notify:on_paint_ui()
    end
    is_paint_ui = false
end)

    client.set_event_callback("console_input", function(e)
        notify:on_console_input(e)
    end)

    -- ── Logs (ported from shinymoon_alpha) ───────────────────────────────────
    -- Globals on purpose: usable from every module scope without eating into
    -- the 200-local budget of start().
    SHINY_LOG_HITGROUPS = {
        [0] = "generic", [1] = "head", [2] = "chest", [3] = "stomach",
        [4] = "left arm", [5] = "right arm", [6] = "left leg", [7] = "right leg",
        [8] = "neck", [9] = "generic", [10] = "gear",
    }
    SHINY_LOG_REASON = {
        ["prediction error"] = "pred. error",
        ["correction"] = "?",
        ["backtrack failure"] = "?",
    }
    SHINY_LOG_FADE_HOLD = 6.0
    SHINY_LOG_FADE_OUT = 1.0
    SHINY_LOG_MAX_LINES = 8
    SHINY_LOG_LINE_GAP = 3

    -- Filter engine spam so our branded lines stand out (alpha parity).
    pcall(function()
        client.exec("con_filter_enable 1")
        client.exec("con_filter_text [shinymoon]")
    end)

    function shinymoon_accent_hex()
        local r, g, b = 201, 129, 159
        pcall(function()
            if menu and menu.visuals and menu.visuals.wm_color then
                r, g, b = menu.visuals.wm_color:get()
            elseif menu and menu.visuals and menu.visuals.accentcolor then
                r, g, b = menu.visuals.accentcolor:get()
            end
        end)
        return string.format("%02x%02x%02xff", r, g, b)
    end

    function shinymoon_color_ref_hex(ref, fallback)
        if ref then
            local ok, r, g, b = pcall(function() return ref:get() end)
            if ok and r then
                return string.format("%02x%02x%02xff", r, g or 0, b or 0)
            end
        end
        return fallback or "4ade80ff"
    end

    function shinymoon_brand_name()
        local txt
        pcall(function()
            if menu and menu.visuals and menu.visuals.wm_custom_text then
                txt = menu.visuals.wm_custom_text:get()
            end
        end)
        if txt and txt ~= "" then return txt end
        return "shinymoon"
    end

    function shinymoon_logs_on(kind)
        if not (menu and menu.misc and menu.misc.logs) then return false end
        local ok, on = pcall(function() return menu.misc.logs:get() end)
        if not ok or not on then return false end
        if not kind then return true end
        local sel
        pcall(function() sel = menu.misc.logs_options:get() end)
        if type(sel) ~= "table" then return false end
        for _, v in ipairs(sel) do
            if v == kind then return true end
        end
        return false
    end

    function shinymoon_logs_output()
        local console_on, screen_on = true, true
        pcall(function()
            local out = menu.misc.logs_output:get()
            if type(out) == "table" then
                console_on, screen_on = false, false
                for _, v in ipairs(out) do
                    if v == "Console" then console_on = true
                    elseif v == "On screen" then screen_on = true end
                end
            end
        end)
        return console_on, screen_on
    end

    -- Console: split \aRRGGBBAA / \adefault into client.color_log segments,
    -- "\0"-terminated so they join on one line (varg multicolor_console pattern).
    function shinymoon_console_print(msg)
        local segs = {}
        local r, g, b = 255, 255, 255
        local pos = 1
        while true do
            local i = msg:find("\a", pos, true)
            if not i then
                local tail = msg:sub(pos)
                if #tail > 0 then segs[#segs + 1] = {r, g, b, tail} end
                break
            end
            local chunk = msg:sub(pos, i - 1)
            if #chunk > 0 then segs[#segs + 1] = {r, g, b, chunk} end
            local rest = msg:sub(i + 1)
            local low = rest:sub(1, 7):lower()
            if low == "default" then
                r, g, b = 255, 255, 255
                pos = i + 1 + 7
            else
                local hex = rest:sub(1, 8)
                r = tonumber(hex:sub(1, 2), 16) or r
                g = tonumber(hex:sub(3, 4), 16) or g
                b = tonumber(hex:sub(5, 6), 16) or b
                pos = i + 1 + 8
            end
        end
        if #segs == 0 then return end
        for i = 1, #segs - 1 do
            client.color_log(segs[i][1], segs[i][2], segs[i][3], segs[i][4] .. "\0")
        end
        local last = segs[#segs]
        client.color_log(last[1], last[2], last[3], last[4])
    end

    shinymoon_screen_logs = shinymoon_screen_logs or {}

    -- screen_msg: shorter on-screen string, or false to keep console-only
    -- (purchases / UI actions never flood the aimbot feed).
    function shinymoon_log_print(msg, screen_msg)
        local accent = shinymoon_accent_hex()
        local brand = shinymoon_brand_name()
        local branded = string.format("[\a%s%s\adefault] %s", accent, brand, msg)

        local console_on, screen_on = shinymoon_logs_output()
        if console_on then
            shinymoon_console_print(branded)
        end

        if screen_msg == false then return end
        if screen_on then
            table.insert(shinymoon_screen_logs, {
                text = screen_msg or msg,
                time = globals.realtime(),
            })
        end
    end

    function shinymoon_log_strip(raw)
        return (tostring(raw or ""):gsub("\a%x%x%x%x%x%x%x%x", ""):gsub("\a[Dd][Ee][Ff][Aa][Uu][Ll][Tt]", ""):gsub("\a", ""))
    end

    function shinymoon_log_parse_segments(raw, dr, dg, db, da)
        local segments = {}
        local cr, cg, cb, ca = dr, dg, db, da
        local pos, len = 1, #raw
        while pos <= len do
            local a_pos = raw:find("\a", pos, true)
            if not a_pos then
                segments[#segments + 1] = { text = raw:sub(pos), r = cr, g = cg, b = cb, a = ca }
                break
            end
            if a_pos > pos then
                segments[#segments + 1] = { text = raw:sub(pos, a_pos - 1), r = cr, g = cg, b = cb, a = ca }
            end
            local rest = raw:sub(a_pos + 1)
            if rest:sub(1, 7):lower() == "default" then
                cr, cg, cb, ca = dr, dg, db, da
                pos = a_pos + 1 + 7
            elseif rest:sub(1, 8):match("^%x%x%x%x%x%x%x%x$") then
                cr = tonumber(rest:sub(1, 2), 16) or cr
                cg = tonumber(rest:sub(3, 4), 16) or cg
                cb = tonumber(rest:sub(5, 6), 16) or cb
                pos = a_pos + 1 + 8
            else
                pos = a_pos + 1
            end
        end
        return segments
    end

    function shinymoon_log_draw_line(flags, center_x, y, raw, dr, dg, db, da)
        local segments = shinymoon_log_parse_segments(raw, dr, dg, db, da)
        local total_w = 0
        for i = 1, #segments do
            if segments[i].text ~= "" then
                total_w = total_w + (renderer.measure_text(flags, segments[i].text) or 0)
            end
        end
        local cx = center_x - total_w * 0.5
        for i = 1, #segments do
            local seg = segments[i]
            if seg.text ~= "" then
                local sa = math.floor(55 * (seg.a / 255))
                renderer.text(cx + 1, y + 1, 0, 0, 0, sa, flags, 0, seg.text)
                renderer.text(cx, y, seg.r, seg.g, seg.b, seg.a, flags, 0, seg.text)
                cx = cx + (renderer.measure_text(flags, seg.text) or 0)
            end
        end
        return total_w
    end

    function shinymoon_log_visible_lines()
        local now = globals.realtime()
        local kept, lines = {}, {}
        for i = 1, #shinymoon_screen_logs do
            local entry = shinymoon_screen_logs[i]
            local age = now - (entry.time or now)
            if age < SHINY_LOG_FADE_HOLD + SHINY_LOG_FADE_OUT then
                kept[#kept + 1] = entry
                local a = 255
                if age > SHINY_LOG_FADE_HOLD then
                    a = math.floor(255 * (1 - (age - SHINY_LOG_FADE_HOLD) / SHINY_LOG_FADE_OUT))
                end
                lines[#lines + 1] = { raw = entry.text, alpha = math.max(0, a) }
            end
        end
        shinymoon_screen_logs = kept
        if #lines > SHINY_LOG_MAX_LINES then
            local trimmed = {}
            for i = #lines - SHINY_LOG_MAX_LINES + 1, #lines do
                trimmed[#trimmed + 1] = lines[i]
            end
            lines = trimmed
        end
        return lines
    end

    -- Filled later once drag_notify exists (Y-locked panel, alpha parity).
    shinymoon_draw_screen_logs = function() end

    function shinymoon_log_action(label, value)
        local accent = shinymoon_accent_hex()
        if value ~= nil and value ~= "" then
            shinymoon_log_print(string.format("\a%s%s\adefault \a%s%s", accent, label, accent, tostring(value)), false)
        else
            shinymoon_log_print(string.format("\a%s%s", accent, label), false)
        end
    end

    function shinymoon_widget_on(name)
        if not (menu and menu.visuals and menu.visuals.widgets) then return false end
        local sel
        pcall(function() sel = menu.visuals.widgets:get() end)
        if type(sel) ~= "table" then return false end
        for _, v in ipairs(sel) do
            if v == name then return true end
        end
        return false
    end

    client.set_event_callback("aim_hit", function(e)
        if not e or not e.target or not shinymoon_logs_on("Aimbot") then return end
        local accent = shinymoon_color_ref_hex(
            menu and menu.misc and menu.misc.logs_hit_color, "4ade80ff")
        local name = string.lower(entity.get_player_name(e.target) or "?")
        local hg = SHINY_LOG_HITGROUPS[e.hitgroup] or tostring(e.hitgroup or "?")
        local hp = entity.get_prop(e.target, "m_iHealth") or 0
        local dmg = e.damage or 0
        local console_msg = string.format(
            "\a%sHit\adefault %s's %s for \a%s%d\adefault damage (hp: \a%s%d\adefault)",
            accent, name, hg, accent, dmg, accent, hp)
        local screen_msg = string.format(
            "Hit \a%s%s\adefault for \a%s%d\adefault (%s)",
            accent, name, accent, dmg, hg)
        shinymoon_log_print(console_msg, screen_msg)
    end)

    client.set_event_callback("aim_miss", function(e)
        if not e or not e.target or not shinymoon_logs_on("Aimbot") then return end
        local accent = shinymoon_color_ref_hex(
            menu and menu.misc and menu.misc.logs_miss_color, "ff5a5aff")
        local name = string.lower(entity.get_player_name(e.target) or "?")
        local hg = SHINY_LOG_HITGROUPS[e.hitgroup] or tostring(e.hitgroup or "?")
        local reason = SHINY_LOG_REASON[e.reason] or tostring(e.reason or "?")
        local console_msg = string.format(
            "\a%sMissed\adefault shot at %s's %s due to \a%s%s",
            accent, name, hg, accent, reason)
        if e.hitchance ~= nil then
            console_msg = string.format("%s (hc: \a%s%d%%\adefault)", console_msg, accent, e.hitchance)
        end
        local screen_msg = string.format(
            "Missed \a%s%s\adefault (%s)",
            accent, name, reason)
        shinymoon_log_print(console_msg, screen_msg)
    end)

    client.set_event_callback("item_purchase", function(e)
        if not shinymoon_logs_on("Purchases") then return end
        if not e or not e.weapon or e.weapon == "weapon_unknown" then return end
        local buyer = e.userid and client.userid_to_entindex(e.userid)
        if not buyer or not entity.is_enemy(buyer) then return end
        local accent = shinymoon_accent_hex()
        local wpn = tostring(e.weapon):gsub("^weapon_", ""):gsub("^item_", ""):gsub("_", " ")
        wpn = wpn:gsub("(%a)([%w']*)", function(a, b) return a:upper() .. b:lower() end)
        local msg = string.format(
            "\a%s%s\adefault bought \a%s%s",
            accent, string.lower(entity.get_player_name(buyer) or "?"), accent, wpn)
        shinymoon_log_print(msg, false)
    end)
    local r, g, b = 255,255,255
    local r1, g1, b1 = 0,0,0
    local r2, g2, b2 = 0,0,0
    local r3,g3,b3 = 0,0,0
    local x, y = client.screen_size()

                local font_flags = {
                    ['Default'] = '',
                    ['Pixel'] = '-',
                    ['Console'] = '-',
                    ['Bold'] = 'b',
                    ['Small'] = '-', -- legacy alias
                }

    start(function()
        client.open_link = panorama.open().SteamOverlayAPI.OpenExternalBrowserURL
        client.ping = math.floor(client.latency() * 1000)

        math.random_string = function(...)
            local args = {...}
            if #args == 1 and type(args[1]) == "table" then
                args = args[1]
            end
            return args[math.random(1, #args)]
        end

        math.invert = function(value, bool)
            return bool and -value or value
        end

        math.round = function(value)
            return math.floor(value + 0.5)
        end

        math.clamp = function(value, minimum, maximum)
            if minimum > maximum then 
                minimum, maximum = maximum, minimum 
            end

            return math.max(minimum, math.min(maximum, value))
        end

        math.to_hex = function(r, g, b, a)
            return bit.tohex((math.floor((r or 0) + 0.5) * 16777216) + (math.floor((g or 0) + 0.5) * 65536) + (math.floor((b or 0) + 0.5) * 256) +(math.floor((a or 0) + 0.5)))
        end

        math.gcd = function(m, n)
            while m ~= 0 do
                m, n = math.fmod(n, m), m
            end
        
            return n
        end

        string.split = function(input, sep)
            local result = {}
            for str in input:gmatch("([^" .. sep .. "]+)") do
                table.insert(result, str)
            end
            return result
        end

        string.lower_first = function(input)
            return input:sub(1, 1):lower() .. input:sub(2)
        end

        string.add_string = function(tbl, to_add, upp)
            local result = {}
            for i, v in ipairs(tbl) do
                if upp then
                    result[i] = to_add .. v:lower_first()
                else
                    result[i] = to_add .. v
                end
            end
            return result
        end

        string.del_string = function(str, prefix, low)
            local result = str:gsub("^" .. prefix, "")
            if low then
                result = result:lower()
            end
            return result
        end

        string.delete = function(str, count)
            return str:sub(count + 1)
        end  

        entity.get_max_desync = function(ent)
            local ways = math.clamp(ent.feet_speed_forwards_or_sideways, 0, 1)
            local frac = (ent.stop_to_full_running_fraction * -0.3 - 0.2) * ways + 1
            local ducking = ent.duck_amount

            if ducking > 0 then
                frac = frac + ducking * ways * (0.5 - frac)
            end

            return math.clamp(frac, 0.5, 1)
        end

        local animstates = ffi.typeof("struct { char pad0[0x18]; float anim_update_timer; char pad1[0xC]; float started_moving_time; float last_move_time; char pad2[0x10]; float last_lby_time; char pad3[0x8]; float run_amount; char pad4[0x10]; void* entity; void* active_weapon; void* last_active_weapon; float last_client_side_animation_update_time; int\t last_client_side_animation_update_framecount; float eye_timer; float eye_angles_y; float eye_angles_x; float goal_feet_yaw; float current_feet_yaw; float torso_yaw; float last_move_yaw; float lean_amount; char pad5[0x4]; float feet_cycle; float feet_yaw_rate; char pad6[0x4]; float duck_amount; float landing_duck_amount; char pad7[0x4]; float current_origin[3]; float last_origin[3]; float velocity_x; float velocity_y; char pad8[0x4]; float unknown_float1; char pad9[0x8]; float unknown_float2; float unknown_float3; float unknown; float m_velocity; float jump_fall_velocity; float clamped_velocity; float feet_speed_forwards_or_sideways; float feet_speed_unknown_forwards_or_sideways; float last_time_started_moving; float last_time_stopped_moving; bool on_ground; bool hit_in_ground_animation; char pad10[0x4]; float time_since_in_air; float last_origin_z; float head_from_ground_distance_standing; float stop_to_full_running_fraction; char pad11[0x4]; float magic_fraction; char pad12[0x3C]; float world_force; char pad13[0x1CA]; float min_yaw; float max_yaw; } **")
        local animlayers = ffi.typeof("struct { char pad_0x0000[0x18]; uint32_t sequence; float prev_cycle; float weight; float weight_delta_rate; float playback_rate; float cycle;void *entity;char pad_0x0038[0x4]; } **")
        local entity_list = vtable_bind("client.dll", "VClientEntityList003", 3, "void*(__thiscall*)(void*, int)")

        entity.get_animstate = function(ent)
            local active = ent and entity_list(ent)

            if active then
                return ffi.cast(animstates, ffi.cast("char*", ffi.cast("void***", active)) + 39264)[0]
            end
        end

        entity.get_animlayer = function(ent, layer)
            local active = entity_list(ent)

            if active then
                return ffi.cast(animlayers, ffi.cast("char*", ffi.cast("void***", active)) + 10640)[0][layer or 0]
            end
        end
    end)()

        local utils = utils or {}
            do
            local reg = {}
            function utils.event_callback(ev, cb, enable)
                reg[ev] = reg[ev] or {}
                if enable and not reg[ev][cb] then
                    client.set_event_callback(ev, cb)
                    reg[ev][cb] = true
            elseif not enable and reg[ev][cb] then
                    client.unset_event_callback(ev, cb)
                    reg[ev][cb] = nil
                end
            end

            function utils.lerp(a, b, t)
                t = math.max(0, math.min(1, t or 0))
                return a + (b - a) * t
            end

            function utils.find_signature(module_name, pattern, offset)
                local match = client.find_signature(module_name, pattern)

                if match == nil then
                    return nil
                end

                if offset ~= nil then
                    local address = ffi.cast('char*', match)
                    address = address + offset

                    return address
                end

                return match
            end
        end


        local events = {
            set = client.set_event_callback,
            unset = client.unset_event_callback,
            fire = client.fire_event
        }
        
        local event_handler_mt = {
            set = function(self, callback)
                if type(callback) == "function" and self.proxy[callback] == nil then
                    local callback_index = #self.callbacks + 1
                    self.proxy[callback], self.callbacks[callback_index] = callback_index, callback
                end
            end,
            
            unset = function(self, callback)
                local callback_index = self.proxy[callback]
                if callback_index == nil then return end
                
                table.remove(self.callbacks, callback_index)
                self.proxy[callback] = nil
                
                for cb, idx in pairs(self.proxy) do
                    if callback_index < idx then
                        self.proxy[cb] = idx - 1
                    end
                end
            end,
            
            __call = function(self, enable, callback)
                if enable then
                    event_handler_mt.set(self, callback)
                else
                    event_handler_mt.unset(self, callback)
                end
            end,
            
            fire = function(self, ...)
                return self.hook(...)
            end,
            
            global_fire = function(self, ...)
                events.fire(self.event_name, ...)
            end,
            
            unhook = function(self)
                events.unset(self.event_name, self.hook)
            end
        }
        
        event_handler_mt.__index = event_handler_mt
        
        local call_reg = setmetatable({}, {
            __index = function(registry, event_name)
                local handler = setmetatable({
                    event_name = event_name,
                    proxy = {},
                    callbacks = {}
                }, event_handler_mt)
                
                function handler.hook(...)
                    local result
                    
                    for i = 1, #handler.callbacks do
                        if handler.callbacks[i] then
                            local callback_result = handler.callbacks[i](...)
                            if callback_result ~= nil then
                                result = callback_result
                            end
                        end
                    end
                    
                    return result
                end
                
                events.set(handler.event_name, handler.hook)
                rawset(registry, event_name, handler)
                
                return handler
            end
        })

        local animate = {
            table = {},
            lerp = function(self, start, end_pos, speed)
                local progress = math.abs((start - end_pos) / (end_pos - start))
                local dynamic_speed = speed * (1 + (1 - progress)^2) * 2
                
                if math.abs(end_pos - start) < 0.01 then
                    return end_pos
                end

                local speed = math.clamp(globals.frametime() * dynamic_speed * 100, 0, 1)
                local value = (end_pos - start) * speed + start
                
                return tonumber(string.format("%.3f", value))
            end,
            get_anim = function(self, name) 
                return self.table[name]
            end,
            color = function(self, name, value, speed)
                local aname = "clr." .. name

                if not self.table[aname] then
                    self.table[aname] = {unpack(value)}
                end
                
                local result = {}
                
                for i = 1, 4 do
                    result[i] = self:lerp(self.table[aname][i], value[i], speed)
                    self.table[aname][i] = result[i]
                end
                
                return unpack(result)
            end,
            number = function(self, name, value, speed)
                if self.table[name] == nil then
                    self.table[name] = value
                end
                
                local animation = self:lerp(self.table[name], value, speed)
        
                self.table[name] = animation
        
                return self.table[name]
            end
        }

        local render = {
            measures = function(self, plus, arg, name) 
                return {renderer.measure_text(arg, name) + plus, name}
            end,
            alphen = function(self, value)
                return math.clamp(value, 0, 255)
            end,
            blur = function(self, x, y, w, h) 
                return renderer.blur(x, y, w, h)
            end,
            rect = {
                rect = function(self, x, y, w, h, clr, rounding)
                    local r, g, b, a = unpack(clr)
            
                    renderer.circle(x + rounding, y + rounding, r, g, b, a, rounding, 180, 0.25)
                    renderer.rectangle(x + rounding, y, w - rounding - rounding, rounding, r, g, b, a)
                    renderer.circle(x + w - rounding, y + rounding, r, g, b, a, rounding, 90, 0.25)
                    renderer.rectangle(x, y + rounding, w, h - rounding*2, r, g, b, a)
                    renderer.circle(x + rounding, y + h - rounding, r, g, b, a, rounding, 270, 0.25)
                    renderer.rectangle(x + rounding, y + h - rounding, w - rounding - rounding, rounding, r, g, b, a)
                    renderer.circle(x + w - rounding, y + h - rounding, r, g, b, a, rounding, 0, 0.25)
                end,
                outline = function(self, x, y, w, h, clr, thickness, round)
                    local r, g, b, a = unpack(clr)
            
                    if thickness == 0 then
                        renderer.rectangle(x, y, w - round, round, r, g, b, a)
                        renderer.rectangle(x, y + round, round, h - round, r, g, b, a)
                        renderer.rectangle(x + w - round, y, round, h - round, r, g, b, a)
                        renderer.rectangle(x + round, y + h - round, w - round, round, r, g, b, a)
                    else
                        renderer.circle_outline(x + thickness, y + thickness, r, g, b, a, thickness, 180, 0.25, round)
                        renderer.rectangle(x + thickness, y, w - thickness - thickness, round, r, g, b, a)
                        renderer.circle_outline(x + w - thickness, y + thickness, r, g, b, a, thickness, 270, 0.25, round)
                        renderer.rectangle(x, y + thickness, round, h - thickness - thickness, r, g, b, a)
                        renderer.circle_outline(x + thickness, y + h - thickness, r, g, b, a, thickness, 90, 0.25, round)
                        renderer.rectangle(x + thickness, y + h - round, w - thickness - thickness, round, r, g, b, a)
                        renderer.circle_outline(x + w - thickness, y + h - thickness, r, g, b, a, thickness, 0, 0.25, round)
                        renderer.rectangle(x + w - round, y + thickness, round, h - thickness - thickness, r, g, b, a)
                    end
                end,
                bulcolic = function(self, x, y, w, h, clr, rounding, clr2, thickness)
                    local r, g, b, a = unpack(clr)
                    local r1, g1, b1, a1
            
                    renderer.circle(x + rounding, y + rounding, r, g, b, a, rounding, 180, 0.25)
                    renderer.rectangle(x + rounding, y, w - rounding - rounding, rounding, r, g, b, a)
                    renderer.circle(x + w - rounding, y + rounding, r, g, b, a, rounding, 90, 0.25)
                    renderer.rectangle(x, y + rounding, w, h - rounding*2 + 1, r, g, b, a)
                    
                    renderer.circle(x + rounding, y + h - rounding + 1, r, g, b, a, rounding, 270, 0.25)
                    renderer.rectangle(x + rounding, y + h - rounding + 1, w - rounding - rounding, rounding, r, g, b, a)
                    renderer.circle(x + w - rounding, y + h - rounding + 1, r, g, b, a, rounding, 0, 0.25)
            
                    if clr2 then 
                        r1, g1, b1, a1 = unpack(clr2)
                        local hs = thickness or 2
            
                        renderer.rectangle(x + rounding, y, w - rounding * 2, hs, r1, g1, b1, a1)
                        renderer.gradient(x - 1, y + rounding, hs, h - rounding * 2.7, r1, g1, b1, a1, r1, g1, b1, 0, false) 
                        renderer.gradient(x + w - 1, y + rounding, hs, h - rounding * 2.7, r1, g1, b1, a1, r1, g1, b1, 0, false) 
                        renderer.circle_outline(x + w - rounding, y + rounding, r1, g1, b1, a1, rounding, 270, 0.25, hs) 
                        renderer.circle_outline(x + rounding, y + rounding, r1, g1, b1, a1, rounding, 180, .25, hs) 
                    end
                end,
                recth = function(self, x, y, w, h, clr, rounding)
                    local r, g, b, a = unpack(clr)
            
                    renderer.circle(x + rounding, y + rounding, r,g, b,a, rounding, 180, 0.25)
                    renderer.rectangle(x + rounding, y, w - rounding - rounding, rounding, r,g, b,a)
                    renderer.circle(x + w - rounding, y + rounding, r,g, b,a, rounding, 90, 0.25)
                    renderer.rectangle(x, y + rounding, w, h - rounding, r,g, b,a)
                end
            },
            glow = {
                work = function(x, y, w, h, radius, thickness, color)
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
                run = function(self,x,y,w,h,width, clr,rounding,thickness)
                    local Offset = 1
                    local r, g, b, a = unpack(clr)
        
                    for k = 0, width do
                        if a * (k/width)^(1) > 5 then
                            local accent = {r, g, b, a * (k/width)^(2)}
                            self.work(x + (k - width - Offset)*thickness, y + (k - width - Offset) * thickness, w - (k - width - Offset)*thickness*2, h + 1 - (k - width - Offset)*thickness*2, rounding + thickness * (width - k + Offset), thickness, accent)
                        end
                    end
                end
            },
            paint_tab = function(self, el, names, labels)
                local text_tab = ""
                local active_index = 1
                local current_tab = el:get()
                for i, name in ipairs(names) do
                    if current_tab:find(name) then
                        active_index = i
                        break
                    end
                end
                for i, label in ipairs(labels) do
                    if i == active_index then
                        text_tab = text_tab .. "\v" .. label
                    else
                        text_tab = text_tab .. "\f<gray>" .. label
                    end
                    if i < #labels then
                        text_tab = text_tab .. "\f<gray>  •  "
                    end
                end
                return text_tab
            end,
            text = {
                default = function(self, speed, string, r1, g1, b1, a1, r2, g2, b2, a2)
                    local t_out, t_out_iter = {}, 1
                    local time = globals.curtime()
                    for i = 1, #string do
                        local iter = (i - 1)/(#string - 1) + time * speed
                        local progress = math.abs(math.cos(iter))
                        
                        local r = r1 + (r2 - r1) * progress
                        local g = g1 + (g2 - g1) * progress
                        local b = b1 + (b2 - b1) * progress
                        local a = a1 + (a2 - a1) * progress
                        
                        t_out[t_out_iter] = "\a" .. math.to_hex(r, g, b, a)
                        t_out[t_out_iter + 1] = string:sub(i, i)
                        t_out_iter = t_out_iter + 2
                    end
                
                    return t_out
                end,
                center = function(self, speed, string, ...)
                    local colors = {...}
                    local t_out, t_out_iter = {}, 1
                    local time = globals.curtime()
                    local length = #string
                    local center = length / 2
                    
                local colors = {
                    {r1 or 255, g1 or 255, b1 or 255, a1 or 255},
                    {r2 or 255, g2 or 255, b2 or 255, a2 or 255}
                }
            
                for i = 1, length do
                    local distance_from_center = math.abs(i - center) / center
                    local iter = distance_from_center + time * speed
                    local progress = (math.sin(iter) + 1) / 2
                
                    local c1 = colors[1]
                    local c2 = colors[2]
                
                    local r = c1[1] + (c2[1] - c1[1]) * progress
                    local g = c1[2] + (c2[2] - c1[2]) * progress
                    local b = c1[3] + (c2[3] - c1[3]) * progress
                    local a = c1[4] + (c2[4] - c1[4]) * progress
                
                    t_out[t_out_iter] = "\a" .. math.to_hex(r, g, b, a)
                    t_out[t_out_iter + 1] = string:sub(i, i)
                    t_out_iter = t_out_iter + 2
                end
            
                return t_out
            end,
        }
        }  

        local native_print = vtable_bind("vstdlib.dll", "VEngineCvar007", 25, "void(__cdecl*)(void*, const void*, const char*, ...)")
        local hex = "\a74A6A9FF"

            -- Drag overlay (from shinymoon_alpha): blur + darkness + alignment grid
            local WM_GRID_STEP = 40
            local WM_SNAP_DIST = 14
            local WM_SNAP_SMOOTH = 0.35
            local WM_DRAG_ANIM_IN = 0.028
            local WM_DRAG_ANIM_OUT = 0.09

            local function drag_lerp(a, b, t)
                return a + (b - a) * t
            end

            local function drag_ease_smootherstep(t)
                t = math.min(1, math.max(0, t))
                return t * t * t * (t * (t * 6 - 15) + 10)
            end

            local function drag_snap_axis(pos, extent, center_line)
                local c = pos + extent * 0.5
                local best = math.floor(c / WM_GRID_STEP + 0.5) * WM_GRID_STEP
                if center_line and math.abs(c - center_line) < math.abs(c - best) then
                    best = center_line
                end
                if math.abs(c - best) <= WM_SNAP_DIST then
                    return best - extent * 0.5
                end
                return pos
            end

            local function drag_draw_grid(sw, sh, t)
                local line_a = math.floor(16 * t)
                local axis_a = math.floor(42 * t)
                if line_a > 0 then
                    local gx = WM_GRID_STEP
                    while gx < sw do
                        renderer.rectangle(gx, 0, 1, sh, 255, 255, 255, line_a)
                        gx = gx + WM_GRID_STEP
                    end
                    local gy = WM_GRID_STEP
                    while gy < sh do
                        renderer.rectangle(0, gy, sw, 1, 255, 255, 255, line_a)
                        gy = gy + WM_GRID_STEP
                    end
                end
                if axis_a > 0 then
                    local mx, my = math.floor(sw * 0.5), math.floor(sh * 0.5)
                    renderer.rectangle(mx, 0, 1, sh, 255, 255, 255, axis_a)
                    renderer.rectangle(0, my, sw, 1, 255, 255, 255, axis_a)
                end
            end

            local function drag_draw_overlay(sw, sh, t)
                if t < 0.01 then return end
                pcall(function() renderer.blur(0, 0, sw, sh, 0.5 * t, 1) end)
                -- Match alpha vis_draw_watermark: fullscreen dim under the grid.
                renderer.rectangle(0, 0, sw, sh, 0, 0, 0, math.floor(100 * t))
                drag_draw_grid(sw, sh, t)
            end

            local DRAG_POS_KEY = "shinymoon:drag:pos:"

            local function drag_load_positions()
                local ok, data = pcall(database.read, DRAG_POS_KEY)
                if ok and type(data) == "table" then return data end
                return {}
            end

            local function drag_save_positions(elements)
                local out = {}
                for i = 1, #elements do
                    local el = elements[i]
                    if el and el.name then
                        out[el.name] = { x = el.x, y = el.y }
                    end
                end
                pcall(database.write, DRAG_POS_KEY, out)
            end

            local draggable = {
                elements = {},
                active_element = nil,
                offset = {0,0},
                alpha = {0,0,0},

                    new = function(self, name, x, y, lock_x, lock_y)
                        local saved = drag_load_positions()
                        local pos = saved[name]
                        if pos and type(pos.x) == "number" and type(pos.y) == "number" then
                            x, y = pos.x, pos.y
                        end
                        local element = {
                            name = name,
                            x = x,
                            y = y,
                            width = 0,
                            height = 0,
                            dragging = false,
                            drag_anim = 0,
                            smooth_x = nil,
                            smooth_y = nil,
                            locks = {lock_x or false, lock_y or false},

                        drag = function(elem, width, height)
                            elem.width = width
                            elem.height = height
                            self.alpha[3] = animate:lerp(self.alpha[3], pui.menu_open and 1 or 0, 0.04)

                            if (self.alpha[3] > 0.1) then 
                                self:setup(elem, self.alpha[3])
                            end
                        end,
                        get = function(elem) 
                            return elem.x, elem.y
                        end,
                        get_x = function(elem) 
                            return elem.x, 0.1
                        end,
                        get_y = function(elem) 
                            return elem.y 
                        end
                    }
                    table.insert(self.elements, element)
                    return element
                end,
                hover = function(self, x, y, w, h, mouseX, mouseY)
                    return mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h
                end,
                setup = function(self, element, alpha_menu)
                    local mouseX, mouseY = ui.mouse_position()
                    local pressed_left = client.key_state(0x01) == true
                    local hover = self:hover(element.x, element.y, element.width, element.height, mouseX, mouseY)
                    local sw, sh = x, y

                    local padd = 5
                    self.alpha[1] = animate:lerp(self.alpha[1], 15 + (hover and 20 or 0) + (element.dragging and 60 or 0), 0.05)*alpha_menu

                    -- Alpha-style drag overlay fade (smootherstep)
                    element.drag_anim = drag_lerp(element.drag_anim or 0, element.dragging and 1 or 0, element.dragging and WM_DRAG_ANIM_IN or WM_DRAG_ANIM_OUT)
                    local t = drag_ease_smootherstep(element.drag_anim or 0)
                    if t < 0.01 then t = 0 end
                    if t > 0 and alpha_menu > 0.1 then
                        drag_draw_overlay(sw, sh, t * alpha_menu)
                    end

                    render.rect:rect(element.x - padd, element.y - padd, element.width + padd * 2, element.height + padd * 2, {255,255,255,self.alpha[1]}, 4)

                    if pressed_left then
                        if not self.active_element then
                            if hover then
                                self.active_element = element
                                self.offset[1] = mouseX - element.x
                                self.offset[2] = mouseY - element.y
                                element.dragging = true
                            end
                        end
                    else
                    if element.dragging then
                        element.dragging = false
                        element.smooth_x, element.smooth_y = nil, nil
                        self.active_element = nil
                        drag_save_positions(self.elements)
                    end
                end

                    if element.dragging then
                        local raw_x = element.x
                        local raw_y = element.y
                        if not element.locks[1] then
                            raw_x = mouseX - self.offset[1]
                        end
                        if not element.locks[2] then
                            raw_y = mouseY - self.offset[2]
                        end

                        raw_x = math.max(0, math.min(sw - element.width, raw_x))
                        raw_y = math.max(0, math.min(sh - element.height, raw_y))

                        local target_x = element.locks[1] and element.x or drag_snap_axis(raw_x, element.width, sw * 0.5)
                        local target_y = element.locks[2] and element.y or drag_snap_axis(raw_y, element.height, sh * 0.5)
                        target_x = math.max(0, math.min(sw - element.width, target_x))
                        target_y = math.max(0, math.min(sh - element.height, target_y))

                        element.smooth_x = drag_lerp(element.smooth_x or raw_x, target_x, WM_SNAP_SMOOTH)
                        element.smooth_y = drag_lerp(element.smooth_y or raw_y, target_y, WM_SNAP_SMOOTH)
                        element.x = element.smooth_x
                        element.y = element.smooth_y
                    end
                end
            }

    local drag_notify = draggable:new("notification", x/2 - 60, y/2 + 250, true)
    local drag_watermark = draggable:new("watermark", x - 200, 12)
    local drag_dtc = draggable:new("dtc_viz", x/2 - 22, y/2 + 80)
    local drag_dmg = draggable:new("damage_indicator", x/2 + 5, y/2 - 10)

    -- On-screen logs: alpha fade + colored segments, Y-draggable when menu open.
    shinymoon_draw_screen_logs = function()
        local _, screen_on = shinymoon_logs_output()
        if not screen_on then return end
        if not (menu and menu.misc and menu.misc.logs and menu.misc.logs:get()) then return end

        local menu_open = pui.menu_open
        local lines = shinymoon_log_visible_lines()
        if #lines == 0 and not menu_open then return end

        local display = lines
        if #lines == 0 then
            display = { { raw = "Hit (?) for (dmg), (hitbox)", alpha = 130 } }
        end

        local flags = ""
        local sw, sh = client.screen_size()
        local box_w, line_h = 0, select(2, renderer.measure_text(flags, "Ag")) or 12
        for i = 1, #display do
            local tw = renderer.measure_text(flags, shinymoon_log_strip(display[i].raw)) or 0
            if tw > box_w then box_w = tw end
        end
        local box_h = (#display * line_h) + ((#display - 1) * SHINY_LOG_LINE_GAP)

        local nx, ny = drag_notify:get()
        -- Keep centered on X; drag only moves Y (lock_x on drag_notify).
        local cx = sw * 0.5
        drag_notify.x = cx - box_w * 0.5
        drag_notify:drag(box_w, box_h)
        nx, ny = drag_notify:get()

        local y = ny
        for i = 1, #display do
            local line = display[i]
            shinymoon_log_draw_line(flags, cx, y, line.raw, 255, 255, 255, line.alpha)
            y = y + line_h + SHINY_LOG_LINE_GAP
        end
    end

    -- Watermark (Default + Full), exact port of shinymoon_alpha vis_draw_watermark.
    local wm_state = { fps_smooth = 0, stat_anims = {}, avatar = { next_retry = 0 }, fonts = {}, full_fonts = {} }
    -- Alpha VIS.wm_fonts → GS renderer flags (Pixel/Console ≈ small).
    local WM_FONT_FLAGS = { Default = "", Pixel = "-", Console = "-", Bold = "b" }
    local WM_FA_GLYPHS = {
        ["chart-bar"] = "\239\152\165",
        ["signal-bars"] = "\239\128\146",
        ["wifi-exclamation"] = "\239\129\177",
        ["clock"] = "\239\128\151",
        ["user"] = "\239\128\135",
    }
    local WM_FULL_FONT_SIZE = 13
    local WM_SHADOW_LAYERS = 32
    local WM_SMOOTH = 0.12

    local function wm_lerp(a, b, t)
        return a + (b - a) * t
    end

    local function wm_full_fonts(scale)
        local size = math.max(1, math.floor(WM_FULL_FONT_SIZE * scale + 0.5))
        local cached = wm_state.full_fonts[size]
        if cached then return cached.font, cached.icon end
        local font, icon
        pcall(function() font = surface:create_font("Verdana", size, 500) end)
        pcall(function() icon = surface:create_font("Font Awesome 6 Free Solid", size, 900) end)
        font = font or false
        icon = icon or font
        wm_state.full_fonts[size] = { font = font, icon = icon }
        return font, icon
    end

    local function wm_draw_shadowed_surface(tl_x, tl_y, box_w, box_h, radius, opacity, scale)
        scale = scale or 1
        opacity = opacity or 1
        local drop = 1 * scale
        local blur = 8 * scale
        for i = WM_SHADOW_LAYERS, 1, -1 do
            local t = i / WM_SHADOW_LAYERS
            local grow = blur * t
            local a = math.floor(10 * opacity * (1 - t) * (1 - t))
            if a > 0 then
                render.rect:rect(
                    tl_x - grow, tl_y - grow + drop,
                    box_w + grow * 2, box_h + grow * 2,
                    {0, 0, 0, a}, radius + grow
                )
            end
        end
        render.rect:rect(tl_x, tl_y, box_w, box_h, {5, 6, 8, math.floor(75 * opacity)}, radius)
        func.rec_outline(tl_x, tl_y, box_w, box_h, radius, 1, {255, 255, 255, math.floor(18 * opacity)})
    end

    local wm_get_net_channel = vtable_bind("engine.dll", "VEngineClient014", 78, "void*(__thiscall*)(void*)")
    local function wm_packet_loss()
        local ok, value = pcall(function()
            local channel = wm_get_net_channel()
            if channel == nil then return 0 end
            local get_avg_loss = ffi.cast("float(__thiscall*)(void*, int)", ffi.cast("void***", channel)[0][11])
            return math.floor(math.max(get_avg_loss(channel, 0), get_avg_loss(channel, 1)) * 100 + 0.5)
        end)
        return ok and value or 0
    end

    local function wm_steam_avatar()
        local avatar = wm_state.avatar
        if not avatar.image and globals.realtime() >= avatar.next_retry then
            avatar.next_retry = globals.realtime() + 2
            pcall(function() avatar.image = images.get_steam_avatar(steamid) end)
        end
        return avatar.image
    end

    local function wm_stat_selected(label)
        local sel
        pcall(function() sel = menu.visuals.wm_stats:get() end)
        if type(sel) ~= "table" then return false end
        for _, v in ipairs(sel) do
            if v == label then return true end
        end
        return false
    end

    local function wm_brand_text()
        local custom
        pcall(function() custom = menu.visuals.wm_custom_text:get() end)
        if custom and custom ~= "" then return custom end
        return "shinymoon.lua"
    end

    local function wm_accent()
        local r, g, b, a = 255, 255, 255, 255
        pcall(function() r, g, b, a = menu.visuals.wm_color:get() end)
        local r2, g2, b2, a2 = r, g, b, a
        local grad = false
        pcall(function() grad = menu.visuals.wm_gradient:get() end)
        if grad then
            pcall(function() r2, g2, b2, a2 = menu.visuals.wm_color2:get() end)
        end
        return grad, r, g, b, a or 255, r2, g2, b2, a2 or 255
    end

    local function wm_gradient_text(text, r1, g1, b1, a1, r2, g2, b2, a2, speed)
        local len = #text
        if len <= 0 then return text end
        local phase = (speed and speed > 0) and ((globals.realtime() or 0) * speed * 0.02) or 0
        local animated = speed and speed > 0
        local out = {}
        for i = 1, len do
            local t = (i - 1) / math.max(1, len - 1)
            local blend
            if animated then
                local u = (t + phase) % 1
                blend = 0.5 - 0.5 * math.cos(u * (math.pi * 2))
            else
                blend = t * t * t * (t * (t * 6 - 15) + 10)
            end
            local r = math.floor(r1 + (r2 - r1) * blend + 0.5)
            local g = math.floor(g1 + (g2 - g1) * blend + 0.5)
            local b = math.floor(b1 + (b2 - b1) * blend + 0.5)
            local a = math.floor(a1 + (a2 - a1) * blend + 0.5)
            out[#out + 1] = string.format("\a%02x%02x%02x%02x%s", r, g, b, a, text:sub(i, i))
        end
        return table.concat(out)
    end

    local function wm_measure(font, text)
        if font then
            local ok, w, h = pcall(surface.measure, surface, font, text)
            if ok then return w or 0, h or 12 end
        end
        return renderer.measure_text("", text)
    end

    local function wm_draw_text(font, x, y, r, g, b, a, text, colored)
        if font then
            if colored then
                pcall(surface.color_text, surface, font, x, y, r, g, b, a, text)
            else
                pcall(surface.text, surface, font, x, y, r, g, b, a, text)
            end
            return
        end
        renderer.text(x, y, r, g, b, a, "", 0, text)
    end

    local function wm_draw_default()
        local text = wm_brand_text()
        local font_name = "Default"
        pcall(function() font_name = menu.visuals.wm_font:get() end)
        -- Legacy configs that still have "Small".
        if font_name == "Small" then font_name = "Pixel" end
        local flags = (WM_FONT_FLAGS[font_name] or "") .. "c"
        local grad, r, g, b, a, r2, g2, b2, a2 = wm_accent()
        local tw, th = renderer.measure_text(flags:gsub("c", ""), text)
        tw, th = tw or 0, th or 12
        drag_watermark:drag(tw, th)
        local wx, wy = drag_watermark:get()
        local cx, cy = wx + tw * 0.5, wy + th * 0.5

        -- Alpha Default: pad rect while drag overlay is visible.
        local t = drag_ease_smootherstep(drag_watermark.drag_anim or 0)
        if t < 0.01 then t = 0 end
        if t > 0 then
            local pad_x, pad_y = 10, 6
            render.rect:rect(
                cx - tw * 0.5 - pad_x, cy - th * 0.5 - pad_y,
                tw + pad_x * 2, th + pad_y * 2,
                {18, 19, 23, math.floor(125 * t)}, 6
            )
        end

        renderer.text(cx + 1, cy + 1, 0, 0, 0, 55, flags, 0, text)
        if grad then
            local speed = 0
            pcall(function() speed = menu.visuals.wm_gradient_speed:get() end)
            local branded = wm_gradient_text(text, r, g, b, a, r2, g2, b2, a2, speed)
            renderer.text(cx, cy, 255, 255, 255, a, flags, 0, branded)
        else
            renderer.text(cx, cy, r, g, b, a, flags, 0, text)
        end
    end

    local function wm_draw_full()
        local text = wm_brand_text()
        local scale = 1
        pcall(function() scale = (menu.visuals.wm_scale:get() or 100) / 100 end)
        local font, icon_font = wm_full_fonts(scale)
        local text_shadow = math.max(1, math.floor(scale + 0.5))
        local grad, ar, ag, ab, aa, ar2, ag2, ab2, aa2 = wm_accent()
        local muted_r, muted_g, muted_b = 214, 218, 224

        local ping_ms = math.floor((client.latency() or 0) * 1000 + 0.5)
        local hours, minutes = client.system_time()
        local clock_str = string.format("%02d:%02d", hours or 0, minutes or 0)
        local uname = username or "you"
        pcall(function()
            local me = entity.get_local_player()
            if me then uname = entity.get_player_name(me) or uname end
        end)
        local fps = math.floor(wm_state.fps_smooth + 0.5)
        do
            local ft = globals.frametime()
            if ft and ft > 0 then
                local raw = 1 / ft
                wm_state.fps_smooth = wm_state.fps_smooth > 0
                    and wm_lerp(wm_state.fps_smooth, raw, 0.1)
                    or raw
                fps = math.floor(wm_state.fps_smooth + 0.5)
            end
        end
        local loss_pct = wm_packet_loss()
        local avatar = wm_steam_avatar()

        local stats = {}
        local function add_stat(label, icon_name, value, is_avatar, col)
            local enabled = wm_stat_selected(label)
            local anim = wm_state.stat_anims[label]
            if not anim then
                anim = { alpha = enabled and 1 or 0 }
                wm_state.stat_anims[label] = anim
            end
            anim.alpha = wm_lerp(anim.alpha, enabled and 1 or 0, WM_SMOOTH)
            if anim.alpha < 0.01 then return end
            stats[#stats + 1] = {
                icon = WM_FA_GLYPHS[icon_name] or "",
                text = value,
                avatar = is_avatar,
                col = col,
                alpha = anim.alpha,
            }
        end
        add_stat("FPS", "chart-bar", string.format("%d FPS", fps))
        add_stat("Ping", "signal-bars", string.format("%dms", ping_ms))
        add_stat("Packet Loss", "wifi-exclamation", string.format("%d%%LOSS", loss_pct), false, loss_pct > 1 and {255, 70, 70} or nil)
        add_stat("Clock", "clock", clock_str)
        add_stat("Username", "user", uname, true)

        local brand_w, brand_h = wm_measure(font, text)
        brand_w, brand_h = brand_w or 0, brand_h or 12
        local PAD, SEG_GAP, STAT_GAP, AV_GAP, AV_SZ = 10 * scale, 12 * scale, 4 * scale, 6 * scale, 20 * scale
        local box_w = PAD + brand_w
        local box_h = math.max(26 * scale, brand_h + 10 * scale)

        for _, st in ipairs(stats) do
            local a = st.alpha
            local iw, ih = wm_measure(icon_font, st.icon)
            local vw, vh = wm_measure(font, st.text)
            local seg_w = SEG_GAP + iw + STAT_GAP + vw
            if st.avatar then seg_w = seg_w + AV_GAP + AV_SZ end
            box_w = box_w + seg_w * a
            box_h = math.max(box_h, math.max(ih, vh) + 10 * scale)
            if st.avatar then box_h = math.max(box_h, AV_SZ + 8 * scale) end
        end
        box_w = box_w + PAD

        drag_watermark:drag(box_w, box_h)
        local tl_x, tl_y = drag_watermark:get()
        local cy = tl_y + box_h * 0.5
        local radius = math.min(box_h * 0.5, 14 * scale)
        wm_draw_shadowed_surface(tl_x, tl_y, box_w, box_h, radius, 1, scale)

        local x = tl_x + PAD
        local brand_y = cy - brand_h * 0.5
        wm_draw_text(font, x + text_shadow, brand_y + text_shadow, 0, 0, 0, 110, text, false)
        if grad then
            local speed = 0
            pcall(function() speed = menu.visuals.wm_gradient_speed:get() end)
            wm_draw_text(font, x, brand_y, 255, 255, 255, aa,
                wm_gradient_text(text, ar, ag, ab, aa, ar2, ag2, ab2, aa2, speed), true)
        else
            wm_draw_text(font, x, brand_y, ar, ag, ab, aa, text, false)
        end
        x = x + brand_w

        for _, st in ipairs(stats) do
            local a = st.alpha
            local iw, ih = wm_measure(icon_font, st.icon)
            local vw, vh = wm_measure(font, st.text)
            local seg_w = SEG_GAP + iw + STAT_GAP + vw
            if st.avatar then seg_w = seg_w + AV_GAP + AV_SZ end
            local draw_w = seg_w * a
            local seg_x = x
            x = x + draw_w

            -- GS has no clip rect; fade via alpha (layout width still matches alpha).
            local dx = seg_x + SEG_GAP
            local col = st.col or { muted_r, muted_g, muted_b }
            local ca = math.floor((col[4] or 255) * a)
            local sh_a = math.floor(100 * a)
            wm_draw_text(icon_font, dx + text_shadow, cy - ih * 0.5 + text_shadow, 0, 0, 0, sh_a, st.icon, false)
            wm_draw_text(icon_font, dx, cy - ih * 0.5, col[1], col[2], col[3], ca, st.icon, false)
            dx = dx + iw + STAT_GAP
            wm_draw_text(font, dx + text_shadow, cy - vh * 0.5 + text_shadow, 0, 0, 0, sh_a, st.text, false)
            wm_draw_text(font, dx, cy - vh * 0.5, col[1], col[2], col[3], ca, st.text, false)
            dx = dx + vw
            if st.avatar and avatar and avatar.draw then
                dx = dx + AV_GAP
                pcall(avatar.draw, avatar, dx, cy - AV_SZ * 0.5, AV_SZ, AV_SZ, 255, 255, 255, math.floor(255 * a), false, "f")
            end
        end
    end

    -- Damage indicator (embertrash paint_ui: draggable mindmg / override value)
    local dmg_ind_state = { alpha = 0, value = 0, hotkey_alpha = 0 }
    local DMG_FONT_FLAGS = { Default = "", Bold = "b", Small = "-" }
    local dmg_md_ref, dmg_ovr_enable, dmg_ovr_hotkey, dmg_ovr_value

    local function dmg_ind_resolve_refs()
        if dmg_md_ref then return end
        pcall(function()
            dmg_md_ref = ui.reference("RAGE", "Aimbot", "Minimum damage")
            local a, b, c = ui.reference("RAGE", "Aimbot", "Minimum damage override")
            dmg_ovr_enable, dmg_ovr_hotkey, dmg_ovr_value = a, b, c
            -- GS returns enable, hotkey, value — but tolerate swapped value/hotkey.
            if dmg_ovr_hotkey and type(ui.get(dmg_ovr_hotkey)) == "number" then
                dmg_ovr_hotkey, dmg_ovr_value = dmg_ovr_value, dmg_ovr_hotkey
            end
        end)
    end

    local function dmg_ind_format(value)
        value = tonumber(value) or 0
        if value <= 0 then return "AUTO" end
        if value > 100 then return "+" .. tostring(math.floor(value - 100 + 0.5)) end
        return tostring(math.floor(value + 0.5))
    end

    local function dmg_ind_read()
        dmg_ind_resolve_refs()
        local base = 0
        if dmg_md_ref then
            local ok, v = pcall(ui.get, dmg_md_ref)
            if ok then base = tonumber(v) or 0 end
        end
        local hotkey_on = false
        local override_val = base
        if dmg_ovr_enable and dmg_ovr_hotkey then
            local ok_e, en = pcall(ui.get, dmg_ovr_enable)
            local ok_h, hk = pcall(ui.get, dmg_ovr_hotkey)
            if ok_e and en and ok_h and hk then
                hotkey_on = true
                if dmg_ovr_value then
                    local ok_v, vv = pcall(ui.get, dmg_ovr_value)
                    if ok_v then override_val = tonumber(vv) or base end
                end
            end
        end
        return hotkey_on and override_val or base, hotkey_on
    end

    local function shinymoon_draw_damage_ind()
        if not (menu and menu.visuals and menu.visuals.damage_ind) then return end
        local enabled = false
        pcall(function() enabled = menu.visuals.damage_ind:get() end)

        local menu_open = pui.menu_open
        local me = entity.get_local_player()
        local alive = me and entity.is_alive(me)
        local disable = not menu_open and not alive

        local ft = math.min(globals.frametime() or 0.016, 0.1)
        local alpha_t = 1 - math.pow(0.82, ft * 60)
        local want_alpha = (enabled and not disable) and 255 or 0
        dmg_ind_state.alpha = dmg_ind_state.alpha + (want_alpha - dmg_ind_state.alpha) * alpha_t
        if dmg_ind_state.alpha < 1 then return end

        local target, hotkey_on = dmg_ind_read()
        local value_t = 1 - math.pow(0.85, ft * 60)
        dmg_ind_state.value = dmg_ind_state.value + (target - dmg_ind_state.value) * value_t
        local display = math.ceil(dmg_ind_state.value - 0.001)

        local style = "Always on"
        pcall(function() style = menu.visuals.damage_style:get() end)
        local want_hk = (menu_open or hotkey_on) and 1 or 0
        dmg_ind_state.hotkey_alpha = dmg_ind_state.hotkey_alpha + (want_hk - dmg_ind_state.hotkey_alpha) * alpha_t
        local draw_alpha = dmg_ind_state.alpha
        if style == "On hotkey" then
            draw_alpha = draw_alpha * dmg_ind_state.hotkey_alpha
        end
        if draw_alpha < 1 then return end

        local font_name = "Default"
        pcall(function() font_name = menu.visuals.damage_font:get() end)
        local flag = DMG_FONT_FLAGS[font_name] or ""
        local text = dmg_ind_format(display)
        local tw, th = renderer.measure_text(flag, text)
        tw, th = (tw or 12) + 3, th or 12

        drag_dmg:drag(tw, th)
        local dx, dy = drag_dmg:get()

        local r, g, b, a = 255, 255, 255, 255
        pcall(function() r, g, b, a = menu.visuals.damage_color:get() end)
        a = math.floor((a or 255) * (draw_alpha / 255) + 0.5)
        renderer.text(dx + 1, dy - 1, r, g, b, a, flag, nil, text)
    end

    local function shinymoon_draw_watermark()
        if not (menu and menu.visuals and menu.visuals.watermark and menu.visuals.watermark:get()) then
            return
        end
        local style = "Default"
        pcall(function() style = menu.visuals.wm_style:get() end)
        if style == "Full" then
            wm_draw_full()
        else
            wm_draw_default()
        end
    end

    client.set_event_callback("paint_ui", function()
        shinymoon_draw_watermark()
        shinymoon_draw_screen_logs()
        shinymoon_draw_damage_ind()
    end)

    -- Forward-declared: assigned below where the pui/ui references are built.
    -- Without this the callback under it reads the (nil) global `refs` forever.
    local refs

    -- Suppress native GS damage logs while ours are active (alpha Log Events override).
    client.set_event_callback("paint", function()
        if not refs or not refs.misc or not refs.misc.log_damage then return end
        local our = menu and menu.misc and menu.misc.logs and menu.misc.logs:get()
        pcall(function()
            if our then
                refs.misc.log_damage:override(false)
            else
                refs.misc.log_damage:override()
            end
        end)
    end)

    local animations = { }

    local function lerp_anim (name, target_value, speed, tolerance, easing_style)
        if animations[name] == nil then
            animations[name] = target_value
        end

        speed = speed or 8
        tolerance = tolerance or 0.005
        easing_style = easing_style or 'linear'
        
        local current_value = animations[name]
        local delta = globals.absoluteframetime() * speed
        local new_value
        
        if easing_style == 'linear' then
            new_value = current_value + (target_value - current_value) * delta
        elseif easing_style == 'smooth' then
            new_value = current_value + (target_value - current_value) * (delta * delta * (3 - 2 * delta))
        elseif easing_style == 'ease_in' then
            new_value = current_value + (target_value - current_value) * (delta * delta)
        elseif easing_style == 'ease_out' then
            local progress = 1 - (1 - delta) * (1 - delta)
            new_value = current_value + (target_value - current_value) * progress
        elseif easing_style == 'ease_in_out' then
            local progress = delta < 0.5 and 2 * delta * delta or 1 - math.pow(-2 * delta + 2, 2) / 2
            new_value = current_value + (target_value - current_value) * progress
        else
            new_value = current_value + (target_value - current_value) * delta
        end

        if math.abs(target_value - new_value) <= tolerance then
            animations[name] = target_value
        else
            animations[name] = new_value
        end
        
        return animations[name]
    end

    local function lazy_lerp (a, b, t)
        return a + (b - a) * (t * t * (3 - 2 * t))
    end

    local function lerp_color (c1, c2, t)
        return {
            r = lazy_lerp(c1.r, c2.r, t),
            g = lazy_lerp(c1.g, c2.g, t),
            b = lazy_lerp(c1.b, c2.b, t),
            a = lazy_lerp(c1.a, c2.a, t)
        }
    end

    local cached_colors = { }
    local last_cache_time = -1

    local function prepare_gradient_cache (speed, col1_start, col1_end, col2_start, col2_end, vertical, w, h)
        local time = globals.realtime() * speed * 0.2
        local steps = 16
        local single_mode = not (w and h)

        if not single_mode then
            
            steps = math.min(64, vertical and h or w)
        end

        if cached_colors.steps == steps and cached_colors.single_mode == single_mode and math.abs(time - last_cache_time) < 0.02 then
            return cached_colors.data
        end

        last_cache_time = time
        cached_colors.steps = steps
        cached_colors.single_mode = single_mode
        cached_colors.data = { }

        if single_mode then
            local t1 = (math.sin(time * 0.5) + 1) * 0.5
            local t2 = (math.cos(time * 0.5) + 1) * 0.5

            local c_a = lerp_color(col1_start, col1_end, t1)
            local c_b = lerp_color(col2_start, col2_end, t2)

            local blend_t = (math.sin(time) + 1) * 0.5
            local final_color = lerp_color(c_a, c_b, blend_t)

            cached_colors.data = final_color
        else
            for i = 0, steps do
                local offset = steps > 0 and (i / steps) or 0

                local t1 = (math.sin(time * 0.5 + offset * math.pi * 2) + 1) * 0.5
                local t2 = (math.cos(time * 0.5 + offset * math.pi * 2) + 1) * 0.5

                local c_a = lerp_color(col1_start, col1_end, t1)
                local c_b = lerp_color(col2_start, col2_end, t2)

                local blend_t = (math.sin(time + offset * math.pi) + 1) * 0.5
                local final_color = lerp_color(c_a, c_b, blend_t)

                cached_colors.data[i] = final_color
            end
        end

        return cached_colors.data
    end

    local function draw_animated_gradient(x, y, w, h, speed, col1_start, col1_end, col2_start, col2_end, vertical, direction_up)
        
        if render_limiter.skip_heavy_renders then
            
            local c = col1_start or {r=255, g=255, b=255, a=255}
            renderer.rectangle(x, y, w, h, c.r, c.g, c.b, c.a)
            return
        end
        
        
        local steps = vertical and h or w
        local max_steps = 16
        local step_size = math.max(4, math.ceil(steps / max_steps))
        
        local time = globals.realtime() * (speed or 1) * 0.2
        
        for i = 0, math.min(steps, max_steps * step_size), step_size do
            local t = i / math.max(1, steps)
            local phase = (math.sin(time + t * math.pi * 2) + 1) * 0.5
            
            local r = col1_start.r + (col1_end.r - col1_start.r) * phase
            local g = col1_start.g + (col1_end.g - col1_start.g) * phase
            local b = col1_start.b + (col1_end.b - col1_start.b) * phase
            local a = col1_start.a + (col1_end.a - col1_start.a) * phase
            
            if vertical then
                local draw_y = direction_up and (y + h - i - step_size) or (y + i)
                renderer.rectangle(x, draw_y, w, step_size, r, g, b, a)
            else
                local draw_x = direction_up and (x + w - i - step_size) or (x + i)
                renderer.rectangle(draw_x, y, step_size, h, r, g, b, a)
            end
        end
    end

    local function draw_gradient_text(x, y, flags, max_width, text, speed, col1_start, col1_end, col2_start, col2_end)
        
        if render_limiter.skip_heavy_renders or not text or #text == 0 then
            local c = col1_start or {r=255, g=255, b=255, a=255}
            renderer.text(x, y, c.r, c.g, c.b, c.a, flags, max_width, text or "")
            return x + (renderer.measure_text(flags, text or "") or 0)
        end
        
        
        local text_len = math.min(#text, 64)
        local time = globals.realtime() * (speed or 1) * 0.2
        
        local final_text = {}
        
        for i = 1, text_len do
            local char = text:sub(i, i)
            local t = (i - 1) / text_len
            local phase = (math.sin(time + t * math.pi * 2) + 1) * 0.5
            
            local r = math.floor(col1_start.r + (col1_end.r - col1_start.r) * phase)
            local g = math.floor(col1_start.g + (col1_end.g - col1_start.g) * phase)
            local b = math.floor(col1_start.b + (col1_end.b - col1_start.b) * phase)
            
            local hex = string.format("%02x%02x%02xff", 
                math.max(0, math.min(255, r)),
                math.max(0, math.min(255, g)),
                math.max(0, math.min(255, b))
            )
            
            table.insert(final_text, '\a')
            table.insert(final_text, hex)
            table.insert(final_text, char)
        end
        
        local rendered = table.concat(final_text)
        renderer.text(x, y, 255, 255, 255, col1_start.a or 255, flags, max_width, rendered)
        local w = renderer.measure_text(flags, text) or 0
        return x + w
    end



    local is_on_ground = false do
        local pre, post = 0, 0
        local function on_setup_command ()
            local me = entity.get_local_player()
            if not me or not entity.is_alive(me) then 
                return 
            end

            pre = entity.get_prop(me, 'm_fFlags')
        end

        local function on_run_command ()
            local me = entity.get_local_player()
            if not me or not entity.is_alive(me) then 
                return 
            end

            post = entity.get_prop(me, 'm_fFlags')
            is_on_ground = bit.band(pre, 1) == 1 and bit.band(post, 1) == 1
        end

        client.set_event_callback('setup_command', on_setup_command)
        client.set_event_callback('run_command', on_run_command)
    end

    local ticks = 0
    local helpers = {
        rounded_rectangle = function (x, y, w, h, rounding, r, g, b, a, gradient_colors)
            y = y + rounding
            gradient_colors = gradient_colors or { use_gradient = false }

            local data_circle = {
                {x + rounding, y, 180},
                {x + w - rounding, y, 90},
                {x + rounding, y + h - rounding * 2, 270},
                {x + w - rounding, y + h - rounding * 2, 0}
            }
        
            local data = {
                {x + rounding, y, w - rounding * 2, h - rounding * 2},
                {x + rounding, y - rounding, w - rounding * 2, rounding},
                {x + rounding, y + h - rounding * 2, w - rounding * 2, rounding},
                {x, y, rounding, h - rounding * 2},
                {x + w - rounding, y, rounding, h - rounding * 2}
            }
        
            for _, data in next, data_circle do
                if gradient_colors.use_gradient then
                    local t1 = (math.sin(globals.realtime() * 25 * 0.2 * 0.5 + data[3] * math.pi * 2) + 1) / 2
                    local t2 = (math.sin(globals.realtime() * 25 * 0.2 * 0.5 + data[3] * math.pi * 2) + 1) / 2

                    local c_a = lerp_color(gradient_colors.col1_start, gradient_colors.col1_end, t1)
                    local c_b = lerp_color(gradient_colors.col2_start, gradient_colors.col2_end, t2)

                    local blend_t = (math.sin(25 + 50 * math.pi) + 1) / 2
                    local final_color = lerp_color(c_a, c_b, blend_t)
        
                    renderer.circle(data[1], data[2], final_color.r, final_color.g, final_color.b, final_color.a, rounding, data[3], 0.25)
                else
                    renderer.circle(data[1], data[2], r, g, b, a, rounding, data[3], 0.25)
                end
            end

            for _, data in next, data do
                if gradient_colors.use_gradient then
                    draw_animated_gradient(data[1], data[2], data[3], data[4], 25,
                        gradient_colors.col1_start,
                        gradient_colors.col1_end,
                        gradient_colors.col2_start,
                        gradient_colors.col2_end,
                        false
                    )
                else
                    renderer.rectangle(data[1], data[2], data[3], data[4], r, g, b, a)
                end
            end
        end,

        semi_outlined_rectangle = function (x, y, w, h, rounding, thickness, gradient_colors, reverse)
        if render_limiter.skip_heavy_renders then
            return
        end
        
        reverse = reverse or false
        rounding = math.min(rounding or 0, 6, w / 3, h / 3)
        thickness = math.min(thickness or 1, 2)
        
        if rounding < 2 then
            
            local base = gradient_colors.col1_start or {r=255, g=255, b=255, a=255}
            local line_y = reverse and y or (y + h - thickness)
            renderer.rectangle(x, line_y, w, thickness, base.r, base.g, base.b, base.a)
            return
        end
        
        if reverse then
            y = y - rounding + 1
        else
            y = y + rounding
        end
        
        local base = gradient_colors.col1_start or {r=255, g=255, b=255, a=255}
        
        
        local circle_y = reverse and y or (y + h - rounding + 1)
        renderer.circle_outline(x + rounding, circle_y, base.r, base.g, base.b, base.a, rounding, reverse and 180 or 90, 0.25, thickness)
        renderer.circle_outline(x + w - rounding, circle_y, base.r, base.g, base.b, base.a, rounding, reverse and 270 or 0, 0.25, thickness)
        
        
        local rect_y = reverse and (y - rounding) or (y + h - thickness + 1)
        renderer.rectangle(x + rounding, rect_y, w - rounding * 2, thickness, base.r, base.g, base.b, base.a)
        
        
        local grad_y = reverse and (y - h + rounding + thickness + 20) or (y + thickness + 9)
        local grad_h = math.min(h - rounding - thickness - 20, 50)
        
        if grad_h > 5 then
            if reverse then
                renderer.gradient(x + w - thickness, grad_y, thickness, grad_h, base.r, base.g, base.b, 0, base.r, base.g, base.b, base.a, false)
            else
                renderer.gradient(x + w - thickness, grad_y, thickness, grad_h, base.r, base.g, base.b, base.a, base.r, base.g, base.b, 0, false)
            end
        end
    end,    
        rounded_outlined_rectangle = function (x, y, w, h, rounding, thickness, r, g, b, a)
            y = y + rounding
            local data_circle = {
                {x + rounding, y, 180},
                {x + w - rounding, y, 270},
                {x + rounding, y + h - rounding * 2, 90},
                {x + w - rounding, y + h - rounding * 2, 0}
            }
        
            local data = {
                {x + rounding, y - rounding, w - rounding * 2, thickness},
                {x + rounding, y + h - rounding - thickness, w - rounding * 2, thickness},
                {x, y, thickness, h - rounding * 2},
                {x + w - thickness, y, thickness, h - rounding * 2}
            }
        
            for _, data in next, data_circle do
                renderer.circle_outline(data[1], data[2], r, g, b, a, rounding, data[3], 0.25, thickness)
            end
        
            for _, data in next, data do
                renderer.rectangle(data[1], data[2], data[3], data[4], r, g, b, a)
            end
        end,

    }

    function helpers:clamp (value, min, max) 
        return math.max(min, math.min(value, max)) 
    end

    local function table_contains (tbl, val)
        for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
        end
        return false
    end

    local function screen_size_x ()
        return select(1, client.screen_size()) or 1920
    end

    local function screen_size_y ()
        return select(2, client.screen_size()) or 1080
    end

    local drag_system = {
        elements = { },
        dragging = nil,
        drag_start_pos = { x = 0, y = 0 },
        last_alpha = 0,
        guide_alpha = 0,
        dot_alpha = 0,
        animate_menu = 0
    }

    function drag_system:get_width()
        local w = self.element.w
        return type(w) == 'function' and w() or w
    end

    function drag_system:get_height()
        local h = self.element.h
        return type(h) == 'function' and h() or h
    end

    function drag_system.new (name, x_slider, y_slider, default_x, default_y, drag_axes, options)
        local self = setmetatable({ }, { __index = drag_system })

        self.name = name
        self.x_slider = x_slider
        self.y_slider = y_slider

        self.element = {
            default_x = default_x,
            default_y = default_y,
            w = options and (options.w or 60) or 60,
            h = options and (options.h or 20) or 20,
            align_x = options and options.align_x or 'center',
            align_y = options and options.align_y or 'center',  
            expand_dir = options and options.expand_dir or 'right' 
        }

        self.drag_axes = drag_axes:lower()
        self.options = {
            show_guides = options and options.show_guides,
            show_highlight = options and options.show_highlight,
            show_default_dot = options and options.show_default_dot,
            align_center = options and options.align_center,
            show_center_dot = options and options.show_center_dot,
            snap_distance = options and options.snap_distance,
            highlight_color = options and options.highlight_color or {150, 150, 150, 80}
        }

        self.hover_progress = 0
        self.click_progress = 0
        self.last_screen_w = screen_size_x()
        self.last_screen_h = screen_size_y()
        self.relative_x = x_slider and (x_slider:get() / self.last_screen_w) or (default_x / self.last_screen_w)
        self.relative_y = y_slider and (y_slider:get() / self.last_screen_h) or (default_y / self.last_screen_h)

        table.insert(drag_system.elements, self)
        return self
    end

    function drag_system:clamp_position (x, y, screen_w, screen_h, elem_w, elem_h)
        if self.element.expand_dir == 'left' then
            x = helpers:clamp(x, elem_w, screen_w)
        else
            x = helpers:clamp(x, 0, screen_w - elem_w)
        end
        
        y = helpers:clamp(y, 0, screen_h - elem_h)
        return x, y
    end

    function drag_system:get_pos ()
        local elem_w, elem_h = self:get_width(), self:get_height()

        local x = self.x_slider and self.x_slider:get() or self.element.default_x
        local y = self.y_slider and self.y_slider:get() or self.element.default_y

        if self.element.expand_dir == 'left' then
            x = x - elem_w
        elseif not self.x_slider then
            x = math.floor(x - elem_w / 2 + 1)
        end

        if not self.y_slider then
            y = math.floor(y - elem_h / 2 + 0.5)
        end

        return x, y
    end

    function drag_system:update (alpha)
        if not ui.is_menu_open() or alpha < 100 then return end

        local screen_w, screen_h = screen_size_x(), screen_size_y()
        local elem_w, elem_h = self:get_width(), self:get_height()

        if screen_w ~= self.last_screen_w or screen_h ~= self.last_screen_h then
            if self.x_slider then
                local new_x = math.floor(self.relative_x * screen_w + 0.5)
                self.x_slider:set(new_x)
            end
            if self.y_slider then
                local new_y = math.floor(self.relative_y * screen_h + 0.5)
                self.y_slider:set(new_y)
            end
            self.last_screen_w = screen_w
            self.last_screen_h = screen_h
        end

        local x, y = self:get_pos(screen_w, screen_h)
        local mx, my = ui.mouse_position()
        local mp_x, mp_y = ui.menu_position()
        local ms_w, ms_h = ui.menu_size()

        if mx >= mp_x and mx <= mp_x + ms_w and my >= mp_y and my <= mp_y + ms_h then
            self.dragging = false
            drag_system.dragging = false
            return
        end

        if not self.dragging then
            local current_x = self.x_slider and self.x_slider:get() or self.element.default_x
            local current_y = self.y_slider and self.y_slider:get() or self.element.default_y
            
            local clamped_x, clamped_y = self:clamp_position(current_x, current_y, screen_w, screen_h, elem_w, elem_h)
            if self.x_slider and clamped_x ~= current_x then
                self.x_slider:set(clamped_x)
                self.relative_x = clamped_x / screen_w
            end
            if self.y_slider and clamped_y ~= current_y then
                self.y_slider:set(clamped_y)
                self.relative_y = clamped_y / screen_h
            end
        end

        local is_hovered = mx >= x and mx <= x + elem_w and my >= y and my <= y + elem_h
        self.hover_progress = lerp_anim('hover_' .. tostring(self.name), is_hovered and 1 or 0, 10, 0.001, 'ease_out')

        if client.key_state(0x01) then
            if not self.dragging and not drag_system.dragging then
                if is_hovered then
                    self.dragging = true
                    drag_system.dragging = true
                    self.drag_start_pos.x = mx - x
                    self.drag_start_pos.y = my - y
                    self.click_progress = 0
                end
            elseif self.dragging then
                self.click_progress = lerp_anim('click_' .. tostring(self.name), 1, 10, 0.001, 'ease_out')
                
                local new_x = mx - self.drag_start_pos.x
                local new_y = my - self.drag_start_pos.y
                local snap = self.options.snap_distance
                local elem_center_x = new_x + elem_w / 2
                local elem_center_y = new_y + elem_h / 2

                if self.drag_axes:find('x') and self.x_slider then
                    if self.options.align_center then
                        if math.abs(elem_center_x - screen_w / 2) < snap then
                            new_x = screen_w / 2 - elem_w / 2
                        end
                    end

                    local target_x = self.element.default_x
                    if self.element.align_x == 'left' then
                        target_x = target_x + elem_w / 2
                    elseif self.element.align_x == 'right' then
                        target_x = target_x - elem_w / 2
                    end
                    
                    if math.abs(elem_center_x - target_x) < snap then
                        new_x = self.element.default_x
                        if self.element.align_x == 'left' then
                            new_x = new_x
                        elseif self.element.align_x == 'center' then
                            new_x = new_x - elem_w / 2
                        elseif self.element.align_x == 'right' then
                            new_x = new_x - elem_w
                        end
                    end

                    if self.element.expand_dir == 'left' then
                        new_x = helpers:clamp(new_x + elem_w, elem_w, screen_w)
                        self.x_slider:set(new_x)
                    else
                        new_x = helpers:clamp(new_x, 0, screen_w - elem_w)
                        self.x_slider:set(new_x)
                    end

                    self.relative_x = self.x_slider:get() / screen_w
                end

                if self.drag_axes:find('y') and self.y_slider then
                    if self.options.align_center then
                        if math.abs(elem_center_y - screen_h / 2) < snap then
                            new_y = screen_h / 2 - elem_h / 2
                        end
                    end

                    local target_y = self.element.default_y
                    if self.element.align_y == 'top' then
                        target_y = target_y + elem_h / 2
                    elseif self.element.align_y == 'bottom' then
                        target_y = target_y - elem_h / 2
                    end
                    
                    if math.abs(elem_center_y - target_y) < snap then
                        new_y = self.element.default_y
                        if self.element.align_y == 'top' then
                            new_y = new_y
                        elseif self.element.align_y == 'center' then
                            new_y = new_y - elem_h / 2
                        elseif self.element.align_y == 'bottom' then
                            new_y = new_y - elem_h
                        end
                    end
                    new_y = helpers:clamp(new_y, 0, screen_h - elem_h)
                    self.y_slider:set(new_y)
                    self.relative_y = self.y_slider:get() / screen_h
                end
            end
        else
            self.click_progress = lerp_anim('click_' .. tostring(self.name), 0, 10, 0.001, 'ease_out')
            self.dragging = false
            drag_system.dragging = false
        end
    end

    function drag_system:draw_guides (alpha)
        local screen_w, screen_h = screen_size_x(), screen_size_y()
        local x, y = self:get_pos(screen_w, screen_h)
        local elem_w, elem_h = self:get_width(), self:get_height()
        local menu_open_factor = ui.is_menu_open() and 1 or 0

        local target_guide_alpha = self.dragging and 255 or 0
        self.guide_alpha = lerp_anim('guide_alpha_' .. tostring(self.name), (target_guide_alpha) * menu_open_factor * alpha / 255, 12, 0.01, 'ease_out')

        local target_dot_alpha = self.dragging and 255 or 0  
        self.dot_alpha = lerp_anim('dot_alpha_' .. tostring(self.name), (target_dot_alpha) * menu_open_factor * alpha / 255, 12, 0.01, 'ease_out')

        local target_alpha = self.dragging and 120 or 0
        self.last_alpha = lerp_anim('last_alpha_' .. tostring(self.name), (target_alpha) * menu_open_factor * alpha / 255, 8, 0.01, 'ease_out')

        if self.last_alpha > 1 then
            -- No fullscreen black dim behind dragged widgets.
        end

        if self.options.show_highlight then
            local hc = self.options.highlight_color
            local base_alpha = hc[4] 
            local hover_alpha = base_alpha * (0.5 + self.hover_progress * 0.5)
            local click_alpha = base_alpha * (1 + self.click_progress * 0.3)
            
            local final_alpha = hover_alpha + (click_alpha - hover_alpha) * self.click_progress
            self.animate_menu = lerp_anim('animate_menu_' .. tostring(self.name), (final_alpha) * menu_open_factor * alpha / 255, 11, 0.01, 'ease_out')
            helpers.rounded_rectangle(x, y, elem_w, elem_h, 4, hc[1], hc[2], hc[3], self.animate_menu)
        end

        if self.options.show_guides then
            local ga = math.floor(self.guide_alpha)

            local show_center_dot = self.options.show_center_dot ~= false
            local center_x, center_y = screen_w / 2, screen_h / 2
            local elem_center_x, elem_center_y = x + elem_w / 2, y + elem_h / 2
            local center_snapped_x = self.drag_axes:find('x') and math.abs(elem_center_x - center_x) < self.options.snap_distance
            local center_snapped_y = self.drag_axes:find('y') and math.abs(elem_center_y - center_y) < self.options.snap_distance
            local is_at_center = (not self.drag_axes:find('x') or center_snapped_x) and (not self.drag_axes:find('y') or center_snapped_y)
            local center_alpha = (show_center_dot and not is_at_center) and ga or 0
            self.center_alpha = lerp_anim('center_alpha_' .. tostring(self.name), center_alpha, 8, 0.01, 'ease_out')

            if self.options.align_center then
                if show_center_dot and self.center_alpha > 0 then
                    renderer.circle(center_x, center_y, 255, 255, 255, self.center_alpha, 3, 0, 1)
                end
                if self.drag_axes:find('x') and self.element.default_y ~= center_y then
                    renderer.line(0, center_y, screen_w, center_y, 255, 255, 255, ga * 0.3)
                end
                if self.drag_axes:find('y') and self.element.default_x ~= center_x then
                    renderer.line(center_x, 0, center_x, screen_h, 255, 255, 255, ga * 0.3)
                end
            end

            local show_default_dot = self.options.show_default_dot ~= false
            local da = math.floor(self.dot_alpha)

            local default_x, default_y = self.element.default_x, self.element.default_y
            if self.element.align_x == 'center' then
                default_x = default_x - elem_w / 2
            elseif self.element.align_x == 'right' then
                default_x = default_x - elem_w
            end
            if self.element.align_y == 'center' then
                default_y = default_y - elem_h / 2
            elseif self.element.align_y == 'bottom' then
                default_y = default_y - elem_h
            end

            local is_snapped_x = self.drag_axes:find('x') and math.abs(x - default_x) < self.options.snap_distance
            local is_snapped_y = self.drag_axes:find('y') and math.abs(y - default_y) < self.options.snap_distance
            local is_at_default = (not self.drag_axes:find('x') or is_snapped_x) and (not self.drag_axes:find('y') or is_snapped_y)
            local default_alpha = (show_default_dot and not is_at_default) and da or 0
            self.default_alpha = lerp_anim('default_alpha_' .. tostring(self.name), default_alpha, 8, 0.01, 'ease_out')

            if show_default_dot and self.default_alpha > 0 then
                renderer.circle(self.element.default_x, self.element.default_y, 255, 255, 255, self.default_alpha, 3, 0, 1)
            end
            if show_default_dot and self.drag_axes:find('x') then
                renderer.line(0, self.element.default_y, screen_w, self.element.default_y, 255, 255, 255, da * 0.3)
            end
            if show_default_dot and self.drag_axes:find('y') then
                renderer.line(self.element.default_x, 0, self.element.default_x, screen_h, 255, 255, 255, da * 0.3)
            end
        end
    end do
        local block_fire = false
        client.set_event_callback('setup_command', function (e)
            if ui.is_menu_open() then
                if bit.band(e.buttons, 1) == 1 then
                    e.buttons = bit.band(e.buttons, bit.bnot(1))
                    block_fire = true
                end
            else
                block_fire = false
            end
        end)
    end
    local color do
        color = ffi.typeof [[
            struct {
                unsigned char r;
                unsigned char g;
                unsigned char b;
                unsigned char a;
            }
        ]]

        local M = { } do
            M.__index = M

            function M:__tostring()
                return string.format(
                    '%i, %i, %i, %i',
                    self:unpack()
                )
            end

            function M.lerp(a, b, t)
                return color(
                    a.r + t * (b.r - a.r),
                    a.g + t * (b.g - a.g),
                    a.b + t * (b.b - a.b),
                    a.a + t * (b.a - a.a)
                )
            end

            function M:unpack()
                return self.r, self.g, self.b, self.a
            end

            function M:clone()
                return color(self:unpack())
            end

            function M:to_hex()
                return string.format(
                    '%02x%02x%02x%02x',
                    self:unpack()
                )
            end

            function M:hsv(h, s, v)
                local r, g, b

                h = (h % 1.0) * 360
                s = math.max(0, math.min(s, 1))
                v = math.max(0, math.min(v, 1))

                local c = v * s
                local x = c * (1 - math.abs((h / 60) % 2 - 1))
                local m = v - c

                if h < 60 then
                    r, g, b = c, x, 0
                elseif h < 120 then
                    r, g, b = x, c, 0
                elseif h < 180 then
                    r, g, b = 0, c, x
                elseif h < 240 then
                    r, g, b = 0, x, c
                elseif h < 300 then
                    r, g, b = x, 0, c
                else
                    r, g, b = c, 0, x
                end

                self.r = (r + m) * 255
                self.g = (g + m) * 255
                self.b = (b + m) * 255
                self.a = 255

                return self
            end
        end

        ffi.metatype(color, M)
    end


    local coloring = {
        parse = function()
            local r, g, b = 201, 129, 159
            if menu and menu.visuals and menu.visuals.accentcolor then
                r, g, b = menu.visuals.accentcolor:get()
            end
            return {
                r = r, g = g, b = b,
                r2 = r, g2 = g, b2 = b,
                r3 = r, g3 = g, b3 = b,
                r4 = r, g4 = g, b4 = b
            }
        end
    }

    local colors = {
        combobox = { get = function() return 'Default' end },
        custom = {
            type = { get = function() return 'Solid' end },
            select = { get = function() return false end }
        }
    }

    local function create_interface (x, y, w, h, r, g, b, a, options)
        options = options or { }
        local side = options.side or 'down'
        local item = options.item or ''  
        local outline_y = side == 'up' and y + 12 or y + 4

        local custom = coloring.parse()
    
        helpers.rounded_rectangle(x, y, w, h, 4, 25, 25, 25, 255 * (a / 255))
    
        if side == 'up' or side == 'down' then
            local reverse = side == 'up'

            local gradient_colors = {
                use_gradient = colors.combobox:get() == 'Custom' and colors.custom.type:get() == 'Gradient' and colors.custom.select:get(item),
                col1_start = {r = custom.r, g = custom.g, b = custom.b, a = a},
                col1_end   = {r = custom.r3, g = custom.g3, b = custom.b3, a = a},
                col2_start = {r = custom.r4, g = custom.g4, b = custom.b4, a = a},
                col2_end   = {r = custom.r2, g = custom.g2, b = custom.b2, a = a}
            }

            helpers.semi_outlined_rectangle(x + 4, outline_y, w - 8, 14, 4, 2, gradient_colors, reverse)
        elseif side == 'left' then
            if colors.combobox:get() == 'Custom' and colors.custom.type:get() == 'Gradient' and colors.custom.select:get(item) then
                draw_animated_gradient(x + 5, y + 4, 3, h - 8, 25, 
                    {r = custom.r, g = custom.g, b = custom.b, a = a},
                    {r = custom.r3, g = custom.g3, b = custom.b3, a = a},
                    {r = custom.r4, g = custom.g4, b = custom.b4, a = a},
                    {r = custom.r2, g = custom.g2, b = custom.b2, a = a}, 
                    true
                )
            else
                renderer.gradient(x + 5, y + 4, 3, h - 8, r, g, b, a, r, g, b, 0, false)
            end
        elseif side == 'right' then
            if colors.combobox:get() == 'Custom' and colors.custom.type:get() == 'Gradient' and colors.custom.select:get(item) then
                draw_animated_gradient(x + w - 8, y + 4, 3, h - 8, 25, 
                    {r = custom.r, g = custom.g, b = custom.b, a = a},
                    {r = custom.r3, g = custom.g3, b = custom.b3, a = a},
                    {r = custom.r4, g = custom.g4, b = custom.b4, a = a},
                    {r = custom.r2, g = custom.g2, b = custom.b2, a = a}, 
                    true
                )
            else
                renderer.gradient(x + w - 8, y + 4, 3, h - 8, r, g, b, 0, r, g, b, a, false)
            end
        elseif side == 'left + right' then
            if colors.combobox:get() == 'Custom' and colors.custom.type:get() == 'Gradient' and colors.custom.select:get(item) then
                draw_animated_gradient(x + 5, y + 4, 3, h - 8, 25, 
                    {r = custom.r, g = custom.g, b = custom.b, a = a},
                    {r = custom.r3, g = custom.g3, b = custom.b3, a = a},
                    {r = custom.r4, g = custom.g4, b = custom.b4, a = a},
                    {r = custom.r2, g = custom.g2, b = custom.b2, a = a}, 
                    true,
                    true
                )

                draw_animated_gradient(x + w - 8, y + 4, 3, h - 8, 25, 
                    {r = custom.r, g = custom.g, b = custom.b, a = a},
                    {r = custom.r3, g = custom.g3, b = custom.b3, a = a},
                    {r = custom.r4, g = custom.g4, b = custom.b4, a = a},
                    {r = custom.r2, g = custom.g2, b = custom.b2, a = a}, 
                    true,
                    false
                )
            else
                renderer.gradient(x + 5, y + 4, 3, h - 8, r, g, b, a, r, g, b, 0, false)
                renderer.gradient(x + w - 8, y + 4, 3, h - 8, r, g, b, 0, r, g, b, a, false)
            end
        end
    
        helpers.rounded_outlined_rectangle(x, y, w, h, 4, 1, 12, 12, 12, a)
        helpers.rounded_outlined_rectangle(x + 1, y + 1, w - 2, h - 2, 4, 1, 60, 60, 60, a)
        helpers.rounded_outlined_rectangle(x + 2, y + 2, w - 4, h - 4, 4, 3, 40, 40, 40, a)
    end

    coloring.rgba_to_hex = coloring.rgba_to_hex or function(r, g, b, a)
        return string.format("%02x%02x%02x%02x", 
            math.floor(math.max(0, math.min(255, r))),
            math.floor(math.max(0, math.min(255, g))),
            math.floor(math.max(0, math.min(255, b))),
            math.floor(math.max(0, math.min(255, a or 255)))
        )
    end

    helpers.rounded_rectangle = function(x, y, w, h, rounding, r, g, b, a, gradient_colors)
        if a < 5 or render_limiter.skip_heavy_renders then
            return
        end
        
        rounding = math.min(rounding or 0, 8, math.floor(w/3), math.floor(h/3))
        
        if rounding < 2 then
            renderer.rectangle(x, y, w, h, r, g, b, a)
            return
        end
        
        y = y + rounding
        
        renderer.circle(x + rounding, y, r, g, b, a, rounding, 180, 0.25)
        renderer.circle(x + w - rounding, y, r, g, b, a, rounding, 270, 0.25)
        renderer.circle(x + rounding, y + h - rounding * 2, r, g, b, a, rounding, 90, 0.25)
        renderer.circle(x + w - rounding, y + h - rounding * 2, r, g, b, a, rounding, 0, 0.25)
        
        renderer.rectangle(x + rounding, y - rounding, w - rounding * 2, h, r, g, b, a)
        renderer.rectangle(x, y, rounding, h - rounding * 2, r, g, b, a)
        renderer.rectangle(x + w - rounding, y, rounding, h - rounding * 2, r, g, b, a)
    end

    local last_render_time = 0
    local render_interval = 1/60

    local original_paint_callbacks = {}

    local function throttled_render(callback_name, callback_fn)
        local now = globals.realtime()
        if now - last_render_time < render_interval then
            return
        end
        last_render_time = now
        callback_fn()
    end

    local globalvars do
    globalvars = { }

    local globalvars_t = ffi.typeof [[
            struct {
                float   realtime;                     // 0x0000
                int     framecount;                   // 0x0004
                float   absoluteframetime;            // 0x0008
                float   absoluteframestarttimestddev; // 0x000C
                float   curtime;                      // 0x0010
                float   frametime;                    // 0x0014
                int     max_clients;                  // 0x0018
                int     tickcount;                    // 0x001C
                float   interval_per_tick;            // 0x0020
                float   interpolation_amount;         // 0x0024
                int     simTicksThisFrame;            // 0x0028
                int     network_protocol;             // 0x002C
                void*   pSaveData;                    // 0x0030
                bool    m_bClient;                    // 0x0031
                bool    m_bRemoteClient;              // 0x0032
            } ***
        ]]

    local globalvars_ptr = utils.find_signature(
        'client.dll', '\xA1\xCC\xCC\xCC\xCC\x5E\x8B\x40\x10', 0x1
    )

    if globalvars_ptr == nil then
        error 'Unable to find CGlobalVarsBase'
    end

    globalvars = ffi.cast(globalvars_t, globalvars_ptr)[0][0]
    end

    refs = {
        aa = {
            enabled = pui.reference("AA", "anti-aimbot angles", "enabled"),
            pitch = {pui.reference("AA", "anti-aimbot angles", "pitch")},
            yaw_base = pui.reference("AA", "anti-aimbot angles", "Yaw base"),
            yaw = {pui.reference("AA", "anti-aimbot angles", "Yaw")},
            yaw_jitter = {pui.reference("AA", "anti-aimbot angles", "Yaw Jitter")},
            body_yaw = {pui.reference("AA", "anti-aimbot angles", "Body yaw")},
            fs_body_yaw = pui.reference("AA", "anti-aimbot angles", "Freestanding body yaw"),
            freestand = {pui.reference("AA", "anti-aimbot angles", "Freestanding")},
            roll = {pui.reference("AA", "anti-aimbot angles", "Roll")},
            edge_yaw = pui.reference("AA", "anti-aimbot angles", "Edge yaw"),
            fake_peek = {pui.reference("AA", "other", "Fake peek")},
            osaa = {pui.reference("AA", "other", "On shot anti-aim")},
            fl = {
                enable = {pui.reference("AA", "fake lag", "enabled")},
                amount = {pui.reference("AA", "fake lag", "amount")},
                variance = {pui.reference("AA", "fake lag", "variance")},
                limit = {pui.reference("AA", "fake lag", "limit")},
                lg = {pui.reference("AA", "other", "Leg movement")},
                sw = {pui.reference("AA", "other", "Slow motion")}, 
            },
        },
        slowmotion = {ui.reference("AA", "other", "Slow motion")},
        scope = ui.reference('VISUALS', 'Effects', 'Remove scope overlay'),
        rage = {
            enable = ui.reference('RAGE', 'aimbot', 'Enabled'),
            dt = {
                value = {ui.reference("RAGE", "aimbot", "Double tap")},
                fl = {pui.reference("RAGE", "Aimbot", "Double tap fake lag limit")}
            },
            md = {
                damage = {pui.reference('RAGE', 'aimbot', 'minimum damage')},
                ovr = {ui.reference('RAGE', 'aimbot', 'minimum damage override')},
            },

            faceduck = {ui.reference("RAGE", "other", "Duck peek assist")},
            peek = {ui.reference("RAGE", "other", "Quick peek assist")},
            baim = {ui.reference('RAGE', 'aimbot', 'force body aim')},
            safe = {ui.reference('RAGE', 'aimbot', 'force safe point')},
            osaa = {ui.reference("AA", "other", "On shot anti-aim")},
        },
        misc = {
            fov = ui.reference('misc', 'miscellaneous', 'Override FOV'),
            clantag = pui.reference("MISC", "Miscellaneous", "Clan tag spammer"),
            log_damage = pui.reference("MISC", "Miscellaneous", "Log damage dealt"),
            ping_spike = pui.reference("MISC", "Miscellaneous", "Ping spike"),
            bindfs = {ui.reference("aa", "anti-aimbot angles", "Freestanding")},
            settings = {
                maxshift = pui.reference("MISC", "Settings", "sv_maxusrcmdprocessticks2")
            }
        },
        color = {
            gscolor = pui.reference("MISC", "Settings", "Menu color"),
        }
    }

    local infos = {
        build = "Nightly",
        author = "shine",

        loads = "shinymoon:loads:db:",
        cfg = "shinymoon:cfg:db:",
        kill = "shinymoon:kill:db:",
        miss = "shinymoon:miss:db:",
        ping = math.floor(client.latency() * 1000),
        run = function(self)
            if database.read(self.cfg) == nil then 
                database.write(self.cfg, {})
            end
        
            local loads = database.read(self.loads)
            local kills = database.read(self.kill)
            local miss = database.read(self.miss)

            if loads == nil then loads = 0 end
            loads = loads + 1

            if kills == nil then kills = 0 end
            if miss == nil then miss = 0 end
            
            database.write(self.loads, loads)
            database.write(self.kill, kills)
            database.write(self.miss, miss)
        end
    }
    infos:run()

    local points = {
        mooncount = "shinymoon:moonpoints:db:",
        spent = "shinymoon:moonspent:db:",

        run = function(self)
            local kills = database.read(infos.kill) or 0
            local miss = database.read(infos.miss) or 0
            local spent = database.read(self.spent) or 0

            -- Purchases persist as "spent" so recomputing from kills/misses
            -- can't silently refund them on the next load.
            local total_points = math.max(0, kills * 1 + miss * 0.5 - spent)
            database.write(self.mooncount, total_points)

            return total_points
        end
    }

    local function moon_points()
        return database.read(points.mooncount) or 0
    end
    points:run()

    -- Global so the shop buy button (defined later) can refresh too.
    function shinymoon_shop_refresh()
        if not (menu and menu.shop) then return end
        pcall(function()
            menu.shop.kills:set("Kills: " .. (database.read(infos.kill) or 0) .. ", each kill gives you 1 Moon$.")
            menu.shop.missed:set("Misses on you: " .. (database.read(infos.miss) or 0) .. ", each miss gives you 0.5 Moon$.")
            menu.shop.moon_points:set("You have " .. moon_points() .. " Moon$.")
        end)
    end

    do
        local last_hurt_at = 0
        local last_miss_at = 0

        client.set_event_callback("player_death", function(e)
            local me = entity.get_local_player()
            if not me or not e or not e.userid or not e.attacker then return end
            local victim = client.userid_to_entindex(e.userid)
            local attacker = client.userid_to_entindex(e.attacker)
            if attacker ~= me or victim == me then return end
            database.write(infos.kill, (database.read(infos.kill) or 0) + 1)
            points:run()
            shinymoon_shop_refresh()
        end)

        client.set_event_callback("player_hurt", function(e)
            local me = entity.get_local_player()
            if me and e and e.userid and client.userid_to_entindex(e.userid) == me then
                last_hurt_at = globals.realtime()
            end
        end)

        client.set_event_callback("bullet_impact", function(e)
            local me = entity.get_local_player()
            if not me or not entity.is_alive(me) or not e or not e.userid then return end
            local shooter = client.userid_to_entindex(e.userid)
            if not shooter or shooter == me or not entity.is_enemy(shooter) then return end

            local now = globals.realtime()
            if now - last_miss_at < 0.5 then return end -- one counted miss per burst

            local hx, hy, hz = entity.hitbox_position(me, 0)
            local sx, sy, sz = entity.hitbox_position(shooter, 0)
            if not hx or not sx then return end

            -- Distance from local head to the shot ray (shooter head -> impact);
            -- only shots actually aimed at us count as a miss (alpha parity, 129u).
            local dx, dy, dz = e.x - sx, e.y - sy, e.z - sz
            local len2 = dx * dx + dy * dy + dz * dz
            if len2 < 1 then return end
            local t = math.max(0, math.min(1, ((hx - sx) * dx + (hy - sy) * dy + (hz - sz) * dz) / len2))
            local cx, cy, cz = sx + dx * t - hx, sy + dy * t - hy, sz + dz * t - hz
            if cx * cx + cy * cy + cz * cz > 129 * 129 then return end

            last_miss_at = now
            local shot_at = now
            -- Count it only once we know the shot didn't connect.
            client.delay_call(0.25, function()
                if math.abs(last_hurt_at - shot_at) <= 0.2 then return end
                database.write(infos.miss, (database.read(infos.miss) or 0) + 1)
                points:run()
                shinymoon_shop_refresh()
            end)
        end)
    end



-- state detection (alpha parity: 5-tick ground debounce, single Moving state)
local FL_ONGROUND = 1
local GROUND_DEBOUNCE_TICKS = 5
local ground_timer = 0
local ground_timer_tick = -1

-- A bhop landing flips FL_ONGROUND on/off within a tick or two; require it to
-- hold for GROUND_DEBOUNCE_TICKS before trusting "grounded" so state doesn't
-- flicker Air <-> Standing/Moving mid-hop (alpha ground_debounced parity).
local function ground_debounced(flags)
    if bit.band(flags, FL_ONGROUND) == 0 then
        ground_timer = 0
        return false
    end
    if ground_timer >= GROUND_DEBOUNCE_TICKS then
        return true
    end
    local tick = globals.tickcount()
    if ground_timer_tick ~= tick then
        ground_timer_tick = tick
        ground_timer = ground_timer + 1
    end
    return false
end

local getstate = function()
    local me = entity.get_local_player()
    if not me or not entity.is_alive(me) then
        return "Global"
    end

    local vx, vy, vz = entity.get_prop(me, "m_vecVelocity")
    vx, vy = vx or 0, vy or 0
    local speed = math.sqrt(vx * vx + vy * vy)

    local flags = entity.get_prop(me, "m_fFlags") or 0
    local raw_on_ground = bit.band(flags, FL_ONGROUND) == FL_ONGROUND
    local on_ground = ground_debounced(flags)

    
    ticks = raw_on_ground and 0 or (ticks + 1)
    is_on_ground = raw_on_ground

    local duck_amt = entity.get_prop(me, "m_flDuckAmount") or 0
    local duck_active = duck_amt == 1

    
    -- Fakeduck counts only while armed: checkbox on AND hotkey active.
    if not duck_active and refs and refs.rage and refs.rage.faceduck and refs.rage.faceduck[1] then
        pcall(function()
            duck_active = (ui.get(refs.rage.faceduck[1])
                and (not refs.rage.faceduck[2] or ui.get(refs.rage.faceduck[2])))
                or duck_active
        end)
    end

    
    if not on_ground then
        return duck_active and "Air + Crouch" or "Air"
    end

    
    local slow_active = false
    if menu and menu.aa and menu.aa.slowmotion then
        slow_active = menu.aa.slowmotion:get() or false
    elseif refs and refs.slowmotion and refs.slowmotion[1] then
        pcall(function() slow_active = ui.get(refs.slowmotion[1]) or slow_active end)
    end
    if slow_active and not duck_active then
        return "Slow Walk"
    end

    
    if duck_active then
        return (speed > 1.2) and "Crouch Moving" or "Crouching"
    end

    
    if speed > 1.2 then
        return "Moving"
    end

    return "Standing"
end
    local states = {"Global", "Standing", "Moving", "Crouching", "Crouch Moving", "Air", "Air + Crouch", "Slow Walk"}

    local shop_items_list = {"ShinyMoon Setts", "Shine Config", "Discord Role.1", "Discord Role.2"}
    local private = {
        initialized = false,
        show = function(self, visible)
            pui.traverse(refs.aa, function(ac)
                ac:set_visible(visible)
            end)
        end,
        keep_hidden = function(self)
            if refs.aa then
                pui.traverse(refs.aa, function(ac)
                    if ac and ac.set_visible then
                        ac:set_visible(false)
                    end
                end)
            end
        end,
        header = function(self, tab) return tab:label("\a333333FF‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾") end,
        space = function(self, tab) return tab:label("\n ") end,
        init = function(self)
            if self.initialized then return end
            self.initialized = true
            -- Persist operational controls; config-management widgets must stay live.
            -- Legacy state names from before alpha-parity rename.
            local LEGACY_STATE_ALIASES = {
                ["Walking"] = "Moving",
                ["Running"] = "Moving",
                ["Crouching moving"] = "Crouch Moving",
                ["Air crouching"] = "Air + Crouch",
                ["Slow motion"] = "Slow Walk",
            }

            local LAST_CFG_KEY = "shinymoon:configs:last:"
            -- Filled by init_presets() after builder controls exist (avoids 200-local blowup).
            local cfg_logic = {}

            -- Kept for per-state clipboard / reset (builder Other tab).
            local function shiny_is_control(elem)
                return type(elem) == "table"
                    and type(elem.get) == "function"
                    and type(elem.set) == "function"
            end

            local function shiny_export_controls(tbl)
                local out = {}
                if type(tbl) ~= "table" then return out end
                for key, elem in pairs(tbl) do
                    if shiny_is_control(elem) then
                        local ok, val = pcall(function() return elem:get() end)
                        if ok then
                            out[key] = val
                        end
                    elseif type(elem) == "table" then
                        local nested = shiny_export_controls(elem)
                        local any = false
                        for _ in pairs(nested) do
                            any = true
                            break
                        end
                        if any then
                            out[key] = nested
                        end
                    end
                end
                return out
            end

            local function shiny_import_controls(tbl, data)
                if type(tbl) ~= "table" or type(data) ~= "table" then return end
                for key, elem in pairs(tbl) do
                    if data[key] == nil then
                        -- skip
                    elseif shiny_is_control(elem) then
                        pcall(function() elem:set(data[key]) end)
                    elseif type(elem) == "table" and type(data[key]) == "table" then
                        shiny_import_controls(elem, data[key])
                    end
                end
            end

            local function shiny_cfg_encode(data)
                return base64.encode(json.stringify(data))
            end

            local function shiny_cfg_decode(encoded)
                if type(encoded) ~= "string" or encoded == "" then return nil end
                local ok_dec, decoded = pcall(base64.decode, encoded)
                if not ok_dec or not decoded then return nil end
                local ok_json, data = pcall(json.parse, decoded)
                if not ok_json or type(data) ~= "table" then return nil end
                return data
            end

            local angles = pui.group("AA", "anti-aimbot angles")
            local fl = pui.group("AA", "Fake lag")
            local other = pui.group("AA", "Other")
            menu = {}
            pui.macros.main = "\ac9819fFF"
            pui.macros.grey = "\a878787FF"
            pui.macros.dot = "\a808080FF•\r  "
            pui.macros.ex = "\ac9abbfFF"
            menu = {
                    tabs = fl:combobox("\nvtabs", " Visuals", " Builder", " Misc", " Settings", " Shop"),

                    aa = {
                        version = angles:label("\f<main>ShinyMoon ~ \r" .. pui.macros.grey .. infos.build),
                        buildertabs = fl:combobox("\nbuildertabs", " Anti-aim", " Fake lag"),
                        self:header(angles),
                        self:header(fl),
                        hotkeys = fl:multiselect("\f<dot>Hotkeys", {"Manuals", "Freestanding", "Slow motion", "Hideshots", "Edge yaw"}),
                        manuall = fl:hotkey("\f<dot>Left"),
                        manualr = fl:hotkey("\f<dot>Right"),                    
                        manualb = fl:hotkey("\f<dot>Back"),
                        manualf = fl:hotkey("\f<dot>Forward"),
                        manualsoptions = fl:combobox("\nmanualsoptions", "Default", "Jitter", "Static"),

                        freestand = fl:hotkey("\f<dot>Freestanding"),

                        slowmotion = fl:hotkey("\f<dot>Slow motion"),
                        hideshots = fl:hotkey("\f<dot>On shot anti-aim"),
                        edgeyaw = fl:hotkey("\f<dot>Edge yaw"),
                        adds = fl:multiselect("\f<dot>Adds", "Anti backstab", "Safe Head", "Spin on warmup/no enemies"),
                        safeheadoptions = fl:multiselect("\nsafeheadoptions", "Air c + Knife", "Air c + Zeus"),
                        fakelag_label = fl:label("\f<dot>Fake Lag"),
                        fakelag = {
                            fl_amount = fl:combobox("\nfl_amount", "Dynamic", "Maximum", "Fluctuate"),
                            fl_variance = fl:slider("\nfl_variance", 0, 100, 0, true, "%"),
                            fl_limit = fl:slider("\nfl_limit", 1, 15, 1, true),
                        },
                        builder = {
                            cheats = angles:combobox("\f<dot>Enemy cheat", "Gamesense", "Neverlose", "Unknown"),
                            states = angles:combobox("\f<dot>State", unpack(states)),
                            modes = {
                                normal = {},
                                defensive = {}
                            }
                        }

                    },
                    visuals = {
                        lua = angles:label("\f<main>ShinyMoon ~ \r" .. pui.macros.grey .. infos.build),
                        welcome = angles:label( "Welcome back, " .. username .. "!" ),
                        space = self:header(angles),
                        accent = angles:label("\f<dot>Accent color", true),
                        accentcolor = angles:color_picker("\naccentcolor", 201, 129, 159, 255),
                        aspectratio = angles:checkbox("\f<dot>Aspect Ratio", false),
                        ratio = angles:slider("\naspectratio", 50, 150, 100, true, "%", 0.01, {
                            [75] = "4:3",
                            [100] = "16:9",
                            [125] = "16:10",
                            [133] = "5:4",
                            [150] = "21:9",
                        }),
                        thirdperson = angles:checkbox("\f<dot>Thirdperson", false),
                        thirdperson_dist = angles:slider("\nthirdperson_dist", 30, 110, 90, true),
                        defdebug = angles:checkbox("\f<dot>LC ESP", true),
                        grenadeesp = angles:checkbox("\f<dot>Grenade ESP", false),
                        molotov_radius = angles:checkbox("\f<dot>Molotov Radius", false),
                        molotov_color = angles:color_picker("\nmolotov_color", 255, 183, 183, 255),
                        smoke_radius = angles:checkbox("\f<dot>Smoke Radius", false),
                        smoke_color = angles:color_picker("\nsmoke_color", 197, 199, 255, 255),
                        damage_ind = angles:checkbox("\f<dot>Damage Indicator", false),
                        damage_style = angles:combobox("\ndamage_style", "Always on", "On hotkey"),
                        damage_font = angles:combobox("\ndamage_font", "Default", "Bold", "Small"),
                        damage_color = angles:color_picker("\ndamage_color", 255, 255, 255, 255),
                        widgets = angles:multiselect("\nwidgets", "Defensive"),
                        watermark = angles:checkbox("\f<dot>Watermark", true),
                        wm_style = angles:combobox("\nwm_style", "Default", "Full"),
                        wm_scale = angles:slider("\nwm_scale", 50, 200, 100, true, "%"),
                        wm_custom_text = angles:textbox("\nwm_custom_text"),
                        wm_font = angles:combobox("\nwm_font", "Default", "Pixel", "Console", "Bold"),
                        wm_color = angles:color_picker("\nwm_color", 255, 255, 255, 255),
                        wm_gradient = angles:checkbox("\f<dot>Gradient", false),
                        wm_color2 = angles:color_picker("\nwm_color2", 74, 158, 255, 255),
                        wm_gradient_speed = angles:slider("\nwm_gradient_speed", 0, 100, 0, true, "%"),
                        wm_stats = angles:multiselect("\nwm_stats", "FPS", "Ping", "Packet Loss", "Clock", "Username"),
                    },
                    misc = {
                        predictenemies = angles:checkbox("\f<ex>✧･ﾟ＊✧･ﾟ:* \rresolver", false),
                        autobuy = angles:checkbox("\f<dot>Auto Buy", false), 
                            options = {
                                autobuy_primary = angles:combobox("\nautobuy_primary", "Off", "Scout", "Awp", "Autos"),
                                autobuy_secondary = angles:combobox("\nautobuy_secondary", "Off", "Five-SeveN/Tec-9", "Dual Barretas", "Deagle", "R8"),
                                autobuy_armor = angles:multiselect("\nautobuy_armor", "Kevlar", "Kevlar + Helmet"),
                                autobuy_nades = angles:multiselect("\nautobuy_nades", "HE Grenade", "Smoke Grenade", "Molotov"),
                                autobuy_utils = angles:multiselect("\nautobuy_utils", "Defuse Kit", "Taser"),
                            },
                        fpsboost = angles:checkbox("\f<dot>FPS Boost", false), boostoptions = {
                        angles:multiselect("\noptions", {'Fix chams color', 'Disable dynamic lighting', 'Disable dynamic shadows', 'Disable first-person tracers', 'Disable ragdolls', 'Disable eye gloss', 'Disable eye movement', 'Disable muzzle flash light', 'Enable low CPU audio', 'Disable bloom', 'Disable particles', 'Reduce breakable objects'}),
                        },
                        animations = angles:checkbox("\f<dot>Animations", false),
                        anims = {
                            ground_legs = angles:combobox("Ground Legs", "Off", "Static", "Walking", "Jitter", "Earthquake"),
                            air_legs = angles:combobox("Air Legs", "Off", "Static", "Walking"),
                            legs_offset_1 = angles:slider("Offset 1", 0, 100, 100, true, "%"),
                            legs_offset_2 = angles:slider("Offset 2", 0, 100, 100, true, "%"),
                            body_lean = angles:slider("Body Lean", -1, 100, -1, true, "%", 1, {[-1] = "Off"}),
                            pitch_on_land = angles:checkbox("Pitch on Land", true),
                            interpolation = angles:checkbox("Interpolation", false),
                            interpolation_scale = angles:slider("Interpolation Scale", 1, 14, 9, true),
                        },
                        fast_ladder = angles:checkbox("\f<dot>Fast Ladder", false),
                        clantag = angles:checkbox("\f<dot>Clan Tag", false),
                        trashtalk = angles:checkbox("\f<dot>Trash Talk", false),
                        logs = angles:checkbox("\f<dot>Logs", true),
                        logs_options = angles:multiselect("\nlogs_options", "Aimbot", "Purchases"),
                        logs_output = angles:multiselect("\nlogs_output", "Console", "On screen"),
                        logs_hit_color = angles:color_picker("\nlogs_hit_color", 74, 222, 128, 255),
                        logs_miss_color = angles:color_picker("\nlogs_miss_color", 255, 90, 90, 255),
                    },
                    settings = {
                        name_local = angles:textbox("\nlocal_name"),
                        create_local = angles:button("\a89f596FF Create"),
                        list_local = angles:listbox("\nlocal_settings", {}),
                        save_local = angles:button("\a32a852FF Save"),
                        load_local = angles:button("\a89f596FF Load"),
                        load_aa_local = angles:button("\a89f596FF Apply AA only"),
                        delete_local = angles:button("\aC84632FF Delete"),
                        export_local = angles:button("\a89f596FF Export"),
                        import_local = angles:button("\a32a852FF Import"),
                    },
                    shop = {
                        shop_label = angles:label("\f<dot>\f<main>ShinyMoon Shop ~ \r\f<grey> New items!"),
                        shop_items = angles:listbox("\nshop_items", {"ShinyMoon Setts", "Shine Config", "Discord Role.1", "Discord Role.2"}),

                        shop_select = angles:textbox("\nshop_select"),
                        buy_button = angles:button("\f<ex> Buy item", function()
                            local sel_idx = (menu.shop.shop_items and menu.shop.shop_items:get()) and menu.shop.shop_items:get() or -1
                            local selected = shop_items_list[sel_idx + 1] or (menu.shop.shop_select and menu.shop.shop_select:get()) or ""
                            local accent = shinymoon_accent_hex()

                            local item_prices = {
                                ["ShinyMoon Setts"] = 75,
                                ["Shine Config"] = 150,
                                ["Discord Role.1"] = 100,
                                ["Discord Role.2"] = 200,
                            }

                            local item_price = item_prices[selected]
                            if not item_price then
                                shinymoon_log_print("Select a shop item first!", false)
                                return
                            end

                            local purchased_items = database.read("shinymoon:purchased:db:") or {}
                            if purchased_items[selected] then
                                shinymoon_log_print("You have already purchased \a" .. accent .. selected .. "\adefault!", false)
                                return
                            end

                            if moon_points() >= item_price then
                                database.write(points.spent, (database.read(points.spent) or 0) + item_price)
                                points:run()
                                purchased_items[selected] = true
                                database.write("shinymoon:purchased:db:", purchased_items)
                                shinymoon_shop_refresh()
                                if shinymoon_logs_on("Purchases") then
                                    shinymoon_log_print(string.format(
                                        "You have purchased \a%s%s\adefault for %d Moon$! Remaining Moon$: %s",
                                        accent, selected, item_price, tostring(moon_points())), false)
                                end
                            else
                                if shinymoon_logs_on("Purchases") then
                                    shinymoon_log_print(string.format(
                                        "Not enough Moon$ to purchase \a%s%s\adefault (need %d, have %s)",
                                        accent, selected, item_price, tostring(moon_points())), false)
                                end
                            end
                        end),
                        self:header(fl),
                        kills = fl:label("Kills: " .. (database.read(infos.kill) or 0) ..", each kill gives you 1 \f<ex>Moon$\r."),
                        missed = fl:label("Misses on you: " .. (database.read(infos.miss) or 0) .. ", each miss gives you 0.5 \f<ex>Moon$\r."),
                        moon_points = fl:label("You have " .. (database.read(points.mooncount) or 0) ..  " \f<ex>Moon$\r."),
                        self:header(fl),
                        shop_label2 = fl:label("Earn \f<ex>Moon$\r by playing and use the discord bot to claim!"),                    
                    },
                }
                menu.visuals.watermark:set_enabled(false)
                -- Resolver UI is retired: force off so a stale config cannot keep
                -- set_pinned rewriting cl_interp / cl_interp_ratio every tick.
                pcall(function() menu.misc.predictenemies:set(false) end)
                menu.misc.predictenemies:set_enabled(false)
                -- Pose-smoothing Interpolation is a no-op on GS (see apply_interpolation);
                -- clear any saved-on state so the menu cannot imply it is active.
                pcall(function() menu.misc.anims.interpolation:set(false) end)
                pcall(function() menu.misc.logs_options:set({"Aimbot", "Purchases"}) end)
                pcall(function() menu.misc.logs_output:set({"Console", "On screen"}) end)
                pcall(function() menu.visuals.widgets:set({"Defensive"}) end)
                pcall(function() menu.visuals.wm_stats:set({"Ping", "Packet Loss", "Clock", "Username"}) end)
                pcall(function() menu.visuals.wm_custom_text:set("") end)
                local visibility = {
                    [menu.aa] = {{menu.tabs, " Builder"}},
                    [menu.aa.version] = {{menu.tabs, " Builder"}},
                    [menu.aa.buildertabs] = {{menu.tabs, " Builder"}},
                    [menu.aa.hotkeys] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Anti-aim"}},
                    [menu.aa.manuall] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Anti-aim"}, {menu.aa.hotkeys, "Manuals"}},
                    [menu.aa.manualr] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Anti-aim"}, {menu.aa.hotkeys, "Manuals"}},
                    [menu.aa.manualb] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Anti-aim"}, {menu.aa.hotkeys, "Manuals"}},
                    [menu.aa.manualf] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Anti-aim"}, {menu.aa.hotkeys, "Manuals"}},
                    [menu.aa.manualsoptions] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Anti-aim"}, {menu.aa.hotkeys, "Manuals"}},
                    [menu.aa.freestand] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Anti-aim"}, {menu.aa.hotkeys, "Freestanding"}},
                    [menu.aa.slowmotion] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Anti-aim"}, {menu.aa.hotkeys, "Slow motion"}},
                    [menu.aa.hideshots] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Anti-aim"}, {menu.aa.hotkeys, "Hideshots"}},
                    [menu.aa.edgeyaw] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Anti-aim"}, {menu.aa.hotkeys, "Edge yaw"}},
                    [menu.aa.adds] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Anti-aim"}},
                    [menu.aa.safeheadoptions] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Anti-aim"}, {menu.aa.adds, "Safe Head"}},
                    [menu.aa.fakelag_label] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Fake lag"}},
                    [menu.aa.fakelag.fl_amount] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Fake lag"}},
                    [menu.aa.fakelag.fl_variance] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Fake lag"}},
                    [menu.aa.fakelag.fl_limit] = {{menu.tabs, " Builder"}, {menu.aa.buildertabs, " Fake lag"}},

                    [menu.visuals] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.lua] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.welcome] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.space] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.accentcolor] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.aspectratio] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.ratio] = {{menu.tabs, " Visuals"}, {menu.visuals.aspectratio, true}},
                    [menu.visuals.thirdperson] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.thirdperson_dist] = {{menu.tabs, " Visuals"}, {menu.visuals.thirdperson, true}},
                    [menu.visuals.defdebug] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.grenadeesp] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.molotov_radius] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.molotov_color] = {{menu.tabs, " Visuals"}, {menu.visuals.molotov_radius, true}},
                    [menu.visuals.smoke_radius] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.smoke_color] = {{menu.tabs, " Visuals"}, {menu.visuals.smoke_radius, true}},
                    [menu.visuals.damage_ind] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.damage_style] = {{menu.tabs, " Visuals"}, {menu.visuals.damage_ind, true}},
                    [menu.visuals.damage_font] = {{menu.tabs, " Visuals"}, {menu.visuals.damage_ind, true}},
                    [menu.visuals.damage_color] = {{menu.tabs, " Visuals"}, {menu.visuals.damage_ind, true}},
                    [menu.visuals.widgets] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.watermark] = {{menu.tabs, " Visuals"}},
                    [menu.visuals.wm_style] = {{menu.tabs, " Visuals"}, {menu.visuals.watermark, true}},
                    [menu.visuals.wm_scale] = {{menu.tabs, " Visuals"}, {menu.visuals.watermark, true}, {menu.visuals.wm_style, "Full"}},
                    [menu.visuals.wm_custom_text] = {{menu.tabs, " Visuals"}, {menu.visuals.watermark, true}},
                    [menu.visuals.wm_font] = {{menu.tabs, " Visuals"}, {menu.visuals.watermark, true}, {menu.visuals.wm_style, "Default"}},
                    [menu.visuals.wm_color] = {{menu.tabs, " Visuals"}, {menu.visuals.watermark, true}},
                    [menu.visuals.wm_gradient] = {{menu.tabs, " Visuals"}, {menu.visuals.watermark, true}},
                    [menu.visuals.wm_color2] = {{menu.tabs, " Visuals"}, {menu.visuals.watermark, true}, {menu.visuals.wm_gradient, true}},
                    [menu.visuals.wm_gradient_speed] = {{menu.tabs, " Visuals"}, {menu.visuals.watermark, true}, {menu.visuals.wm_gradient, true}},
                    [menu.visuals.wm_stats] = {{menu.tabs, " Visuals"}, {menu.visuals.watermark, true}, {menu.visuals.wm_style, "Full"}},
                    [menu.misc] = {{menu.tabs, " Misc"}},
                    [menu.misc.autobuy] = {{menu.tabs, " Misc"}},
                    [menu.misc.options] = {{menu.tabs, " Misc"}, {menu.misc.autobuy, true}},
                    [menu.misc.options.autobuy_primary] = {{menu.tabs, " Misc"}, {menu.misc.autobuy, true}},
                    [menu.misc.options.autobuy_secondary] = {{menu.tabs, " Misc"}, {menu.misc.autobuy, true}},
                    [menu.misc.options.autobuy_armor] = {{menu.tabs, " Misc"}, {menu.misc.autobuy, true}},
                    [menu.misc.options.autobuy_nades] = {{menu.tabs, " Misc"}, {menu.misc.autobuy, true}},
                    [menu.misc.options.autobuy_utils] = {{menu.tabs, " Misc"}, {menu.misc.autobuy, true}},
                    [menu.misc.fpsboost] = {{menu.tabs, " Misc"}},
                    [menu.misc.boostoptions] = {{menu.tabs, " Misc"}, {menu.misc.fpsboost, true}},
                    [menu.misc.animations] = {{menu.tabs, " Misc"}},
                    [menu.misc.anims.ground_legs] = {{menu.tabs, " Misc"}, {menu.misc.animations, true}},
                    [menu.misc.anims.air_legs] = {{menu.tabs, " Misc"}, {menu.misc.animations, true}},
                    [menu.misc.anims.legs_offset_1] = {{menu.tabs, " Misc"}, {menu.misc.animations, true}, {menu.misc.anims.ground_legs, "Jitter"}},
                    [menu.misc.anims.legs_offset_2] = {{menu.tabs, " Misc"}, {menu.misc.animations, true}, {menu.misc.anims.ground_legs, "Jitter"}},
                    [menu.misc.anims.body_lean] = {{menu.tabs, " Misc"}, {menu.misc.animations, true}},
                    [menu.misc.anims.pitch_on_land] = {{menu.tabs, " Misc"}, {menu.misc.animations, true}},
                    [menu.misc.anims.interpolation] = {{menu.tabs, " Misc"}, {menu.misc.animations, true}},
                    [menu.misc.anims.interpolation_scale] = {{menu.tabs, " Misc"}, {menu.misc.animations, true}, {menu.misc.anims.interpolation, true}},
                    [menu.misc.fast_ladder] = {{menu.tabs, " Misc"}},
                    [menu.misc.clantag] = {{menu.tabs, " Misc"}},
                    [menu.misc.trashtalk] = {{menu.tabs, " Misc"}},
                    [menu.misc.predictenemies] = {{menu.tabs, " Misc"}},
                    [menu.misc.logs] = {{menu.tabs, " Misc"}},
                    [menu.misc.logs_options] = {{menu.tabs, " Misc"}, {menu.misc.logs, true}},
                    [menu.misc.logs_output] = {{menu.tabs, " Misc"}, {menu.misc.logs, true}},
                    [menu.misc.logs_hit_color] = {{menu.tabs, " Misc"}, {menu.misc.logs, true}},
                    [menu.misc.logs_miss_color] = {{menu.tabs, " Misc"}, {menu.misc.logs, true}},

                    [menu.settings] = {{menu.tabs, " Settings"}},
                    [menu.settings.list_local] = {{menu.tabs, " Settings"}},
                    [menu.settings.name_local] = {{menu.tabs, " Settings"}},
                    [menu.settings.create_local] = {{menu.tabs, " Settings"}},
                    [menu.settings.save_local] = {{menu.tabs, " Settings"}},
                    [menu.settings.load_local] = {{menu.tabs, " Settings"}},
                    [menu.settings.load_aa_local] = {{menu.tabs, " Settings"}},
                    [menu.settings.delete_local] = {{menu.tabs, " Settings"}},
                    [menu.settings.export_local] = {{menu.tabs, " Settings"}},
                    [menu.settings.import_local] = {{menu.tabs, " Settings"}},

                    [menu.shop] = {{menu.tabs, " Shop"}},
                    [menu.shop.shop_label] = {{menu.tabs, " Shop"}},
                    [menu.shop.shop_items] = {{menu.tabs, " Shop"}},
                    [menu.shop.shop_label2] = {{menu.tabs, " Shop"}},
                    [menu.shop.shop_select] = {{menu.tabs, " Shop"}},
                }

                for _, state_name in ipairs(states) do
                    menu.aa.builder.modes.normal[state_name] = {}

                    local aa = menu.aa.builder.modes.normal[state_name]
                    local c = "\n" .. state_name

                    aa.space123 = self:space(angles)

                    if state_name ~= "Global" then
                        aa.active = angles:checkbox("Enable \f<dot>" .. state_name)
                    end
                    aa.method = angles:combobox("\f<dot>Method", "Normal", "Net_update")

                    aa.yaw_base = angles:combobox("\f<dot>Yaw base", "Local view", "At targets")
                    aa.headers = self:header(angles)
                    -- Pitch combobox removed: pitch is forced Down elsewhere.
                    aa.space = self:space(angles)
                    aa.yaw_left = angles:slider("\f<dot> Yaw left" .. c, -180, 180, 0, true, "°")
                    aa.left_random = angles:slider("\n<dot> Left random " .. c, 0, 100, 0 , true, "%")
                    aa.yaw_right = angles:slider("\f<dot> Yaw right" .. c, -180, 180, 0, true, "°")
                    aa.right_random = angles:slider("\n<dot> Right random " .. c, 0, 100, 0 , true, "%")

                    aa.sapsd = self:space(angles)

                    aa.jitter = angles:label("\f<dot>Yaw jitter")
                    aa.jitter_mode = angles:combobox("\njitter_mode" .. c, "Off", "Center", "Offset", "Random", "3-Way", "Hold", "Spin", "Shiny")
                    
                    aa.jitter_amount = angles:slider("\njitter_amount" .. c, -180, 180, 0, true, "°"):depend({aa.jitter_mode, "Off", true, "Center", true}, {aa.jitter_mode, "Offset", true}, {aa.jitter_mode, "Random", true}, {aa.jitter_mode, "3-Way", true}, {aa.jitter_mode, "Hold", true})
                    aa.spin_from = angles:slider("\nspin_from" .. c, -180, 180, 0, true, "°"):depend({aa.jitter_mode, "Spin"})
                    aa.spin_to = angles:slider("\nspin_to" .. c, -180, 180, 0, true, "°"):depend({aa.jitter_mode, "Spin"})
                    aa.spin_speed = angles:slider("\nspin_speed" .. c, 1, 32, 5, true, "t"):depend({aa.jitter_mode, "Spin"})
                    aa.spin_random = angles:slider("\nspin_random" .. c, 0, 100, 0, true, "%"):depend({aa.jitter_mode, "Spin"})

                    aa.body_yaw = angles:combobox("\f<dot>Body yaw", {"Off", "Static", "Jitter", "Amnesia", "Adaptive"})
                    aa.body_yaw_static = angles:slider("\f<dot> Desync" .. c, -60, 60, 0, true, "°", 1, {[0] = "Off"}):depend({aa.body_yaw, "Static"})
                    -- Varg: desync left / desync right (0–60) — shown for Jitter or Amnesia
                    aa.body_yaw_left = angles:slider("\f<dot> Desync left" .. c, 0, 60, 60, true, "°", 1, {[0] = "Off"}):depend({aa.body_yaw, "Jitter", "Amnesia"})
                    aa.body_yaw_right = angles:slider("\f<dot> Desync right" .. c, 0, 60, 60, true, "°", 1, {[0] = "Off"}):depend({aa.body_yaw, "Jitter", "Amnesia"})
                    aa.desync_random = angles:checkbox("\f<dot>Desync random" .. c):depend({aa.body_yaw, "Jitter"})
                    aa.amnesia_tick_speed = angles:slider("\namnesia_tick_speed" .. c, 1, 32, 16, true, "t"):depend({aa.body_yaw, "Amnesia"})
                    aa.freestadingbody = angles:checkbox("\f<dot>Freestanding body yaw"):depend({aa.body_yaw, "Off", true})

                    aa.space1 = self:space(angles)

                    aa.forward_track = angles:checkbox("\f<dot>Forward Track")
                    aa.forward_track_conditions = angles:multiselect(
                        "\nforward_track_conditions" .. c,
                        "Holding Knife", "Holding Zeus", "Always"
                    )
                    pcall(function() aa.forward_track_conditions:set({ "Always" }) end)

                    aa.delay_enabled = angles:checkbox("\f<dot> Enable delay")
                    aa.delay_modes = angles:combobox("\ndelay_modes" .. c, "Normal", "Random", "Min/Max", "Custom", "Exponencial", "Shiny"):depend({aa.delay_enabled, true})
                    aa.delay_amount = angles:slider("\ndelay_amount" .. c, 0, 22, 0, true, "t", 1, {[0] = "Off"}):depend({aa.delay_enabled, true}, {aa.delay_modes, "Normal"}) 
                    aa.delay_min = angles:slider("\ndelay_min" .. c, 0, 22, 0, true, "t", 1, {[0] = "Off"}):depend({aa.delay_enabled, true}, {aa.delay_modes, "Min/Max"})
                    aa.delay_max = angles:slider("\ndelay_max" .. c, 0, 22, 0, true, "t", 1, {[0] = "Off"}):depend({aa.delay_enabled, true}, {aa.delay_modes, "Min/Max"})
                    aa.delay_random = angles:slider("\ndelay_random" .. c, 1, 22, 1, true, "t"):depend({aa.delay_enabled, true}, {aa.delay_modes, "Random"})
                    aa.delay_exp_base = angles:slider("\ndelay_exp_base" .. c, 1, 10, 2, true, "t"):depend({aa.delay_enabled, true}, {aa.delay_modes, "Exponencial"})
                    aa.delay_shiny_speed = angles:slider("\ndelay_shiny_speed" .. c, 1, 10, 5, true):depend({aa.delay_enabled, true}, {aa.delay_modes, "Shiny"})
                    
                    
                    aa.delay_custom_count = angles:slider("\f<dot>Custom delays" .. c, 1, 8, 2, true):depend({aa.delay_enabled, true}, {aa.delay_modes, "Custom"})
                    aa.delay_custom_values = {}
                    
                    local MAX_CUSTOM_SLIDERS = 8
                    for i = 1, MAX_CUSTOM_SLIDERS do
                        aa.delay_custom_values[i] = angles:slider(string.format("\f<grey>Delay #%d" .. c, i), 1, 22, math.min(i * 2, 14), true, "t")
                        
                        local deps = {{aa.delay_enabled, true}, {aa.delay_modes, "Custom"}, {menu.aa.builder.states, state_name}}
                        if state_name ~= "Global" then
                            table.insert(deps, {aa.active, true})
                        end
                        aa.delay_custom_values[i]:depend(table.unpack(deps))
                    end

                    

                    

                    local function apply_dependencies(tbl, active_ref)
                        for key, v in pairs(tbl) do
                            if type(v) == "table" and v.depend and key ~= "delay_custom_values" and key ~= "forward_track_conditions" then
                                local deps = {{menu.aa.builder.states, state_name}}
                                if key ~= "active" and key ~= "space123" then
                                    if active_ref and state_name ~= "Global" then
                                        table.insert(deps, {active_ref, true})
                                    end

                                    
                                    table.insert(deps, {menu.aa.buildertabs, " Anti-aim"})
                                end
                                v:depend(table.unpack(deps))
                            end
                        end
                    end

                    apply_dependencies(aa, aa.active)

                    do
                        local ft_deps = {
                            { menu.aa.builder.states, state_name },
                            { aa.forward_track, true },
                            { menu.aa.buildertabs, " Anti-aim" },
                        }
                        if state_name ~= "Global" and aa.active then
                            table.insert(ft_deps, 2, { aa.active, true })
                        end
                        aa.forward_track_conditions:depend(table.unpack(ft_deps))
                    end

                    

                    
                    local custom_delay_handler = (function()
                        local this_state_name = state_name
                        local last_count = -1
                        local last_mode = ""
                        local last_enabled = nil
                        
                        return function()
                            if not aa.delay_enabled or not aa.delay_custom_count or not aa.delay_modes then return end
                            
                            local enabled = aa.delay_enabled:get()
                            local mode = aa.delay_modes:get()
                            local count = math.max(1, math.min(MAX_CUSTOM_SLIDERS, math.floor(aa.delay_custom_count:get() or 2)))
                            local current_state = menu.aa.builder.states:get()
                            
                            
                            if count == last_count and mode == last_mode and enabled == last_enabled then return end
                            last_count = count
                            last_mode = mode
                            last_enabled = enabled
                            
                            local should_show_custom = enabled and mode == "Custom" and current_state == this_state_name
                            
                            for i = 1, MAX_CUSTOM_SLIDERS do
                                local child = aa.delay_custom_values[i]
                                if child and child.set_visible then
                                    local visible = should_show_custom and i <= count
                                    child:set_visible(visible)
                                end
                            end
                        end
                    end)()
                    
                    client.set_event_callback("paint_ui", custom_delay_handler)

                    pcall(function()
                        pui.traverse(aa, function(ac)
                            if ac and type(ac) == "table" and ac.depend then
                                ac:depend({ menu.tabs, " Builder" }, { menu.aa.buildertabs, " Anti-aim" })
                            end
                        end)
                    end)
                end

                local shiny_state_defaults = {}
                for _, state_name in ipairs(states) do
                    local state_tbl = menu.aa.builder.modes.normal[state_name]
                    if state_tbl then
                        shiny_state_defaults[state_name] = shiny_export_controls(state_tbl)
                    end
                end
                

                menu.aa.state_space = self:space(other)
                menu.aa.state_to = other:button("\v\r State To \v»\r ", function()
                    local state = menu.aa.builder.states:get()
                    local state_tbl = menu.aa.builder.modes.normal[state]
                    if not state_tbl then return end
                    local data = shiny_export_controls(state_tbl)
                    clipboard.set("{state:" .. state .. ":builder}::" .. shiny_cfg_encode(data))
                end)
                menu.aa.state_from = other:button("\v\r State From \v«\r ", function()
                    local state = menu.aa.builder.states:get()
                    local state_tbl = menu.aa.builder.modes.normal[state]
                    if not state_tbl then return end

                    local encrypted = clipboard.get()
                    if not encrypted or encrypted == "" then return end

                    local dcp = encrypted:find("::")
                    if not dcp then return end

                    local data = shiny_cfg_decode(encrypted:sub(dcp + 2))
                    if type(data) ~= "table" then return end
                    shiny_import_controls(state_tbl, data)
                end)
                menu.aa.reset = other:button("\v\r Reset", function()
                    local state = menu.aa.builder.states:get()
                    local state_tbl = menu.aa.builder.modes.normal[state]
                    local defaults = shiny_state_defaults[state]
                    if not state_tbl or not defaults then return end
                    shiny_import_controls(state_tbl, defaults)
                end)

                for element, deps in pairs(visibility) do
                    if element and type(element) == "table" and element.depend then
                        
                        pcall(function()
                            element:depend(unpack(deps))
                        end)
                    elseif element and type(element) == "table" then
                        
                        pui.traverse(element, function(ac)
                            if ac and type(ac) == "table" and ac.depend then
                                pcall(function()
                                    ac:depend(unpack(deps))
                                end)
                            end
                        end)
                    end
                end

                -- Embertrash-style preset system (wrapped to keep start() under 200 locals).
                local function init_presets()
                    local LEGACY_CONFIG_KEY = "shinymoon:configs:db:"
                    local PRESET_DB_KEY = "shinymoon::gs::local_presets"

                    local config_db = database.read(PRESET_DB_KEY) or {}
                    config_db.presets = config_db.presets or {}
                    config_db.data = config_db.data or {}
                    database.write(PRESET_DB_KEY, config_db)
                    pcall(function() database.flush() end)

                    local function remember_last(name)
                        if type(name) == "string" and name ~= "" then
                            pcall(database.write, LAST_CFG_KEY, name)
                        end
                    end

                    local function serialize(tbl)
                        local t = {}
                        for k, v in pairs(tbl) do
                            local key = type(k) == "string" and string.format("[%q]=", k) or ("[" .. k .. "]=")
                            if type(v) == "table" then
                                t[#t + 1] = key .. serialize(v)
                            elseif type(v) == "string" then
                                t[#t + 1] = key .. string.format("%q", v)
                            else
                                t[#t + 1] = key .. tostring(v)
                            end
                        end
                        return "{" .. table.concat(t, ",") .. "}"
                    end

                    local function table_to_string(tbl)
                        return "return " .. serialize(tbl)
                    end

                    local function table_contains(list, name)
                        for i = 1, #list do
                            if list[i] == name then return true end
                        end
                        return false
                    end

                    local function flush_db()
                        database.write(PRESET_DB_KEY, config_db)
                        pcall(function() database.flush() end)
                    end

                    local function refresh_list()
                        if menu.settings and menu.settings.list_local then
                            -- gamesense listbox can't be empty → placeholder avoids "compare number with nil"
                            local items = config_db.presets
                            menu.settings.list_local:update(#items > 0 and items or {" "})
                        end
                        return config_db.presets
                    end

                    -- Package order: 1=builder states, 2=AA extras → Apply AA only loads 1–2.
                    local aa_extras = {
                        hotkeys = menu.aa.hotkeys,
                        manualsoptions = menu.aa.manualsoptions,
                        manuall = menu.aa.manuall,
                        manualr = menu.aa.manualr,
                        manualb = menu.aa.manualb,
                        manualf = menu.aa.manualf,
                        freestand = menu.aa.freestand,
                        slowmotion = menu.aa.slowmotion,
                        hideshots = menu.aa.hideshots,
                        edgeyaw = menu.aa.edgeyaw,
                        adds = menu.aa.adds,
                        safeheadoptions = menu.aa.safeheadoptions,
                        fakelag = menu.aa.fakelag,
                    }

                    local visuals_pkg = {
                        accentcolor = menu.visuals.accentcolor,
                        aspectratio = menu.visuals.aspectratio,
                        ratio = menu.visuals.ratio,
                        thirdperson = menu.visuals.thirdperson,
                        thirdperson_dist = menu.visuals.thirdperson_dist,
                        defdebug = menu.visuals.defdebug,
                        grenadeesp = menu.visuals.grenadeesp,
                        molotov_radius = menu.visuals.molotov_radius,
                        molotov_color = menu.visuals.molotov_color,
                        smoke_radius = menu.visuals.smoke_radius,
                        smoke_color = menu.visuals.smoke_color,
                        damage_ind = menu.visuals.damage_ind,
                        damage_style = menu.visuals.damage_style,
                        damage_font = menu.visuals.damage_font,
                        damage_color = menu.visuals.damage_color,
                        widgets = menu.visuals.widgets,
                        watermark = menu.visuals.watermark,
                        wm_style = menu.visuals.wm_style,
                        wm_scale = menu.visuals.wm_scale,
                        wm_custom_text = menu.visuals.wm_custom_text,
                        wm_font = menu.visuals.wm_font,
                        wm_color = menu.visuals.wm_color,
                        wm_gradient = menu.visuals.wm_gradient,
                        wm_color2 = menu.visuals.wm_color2,
                        wm_gradient_speed = menu.visuals.wm_gradient_speed,
                        wm_stats = menu.visuals.wm_stats,
                    }

                    local misc_pkg = {
                        autobuy = menu.misc.autobuy,
                        options = menu.misc.options,
                        fpsboost = menu.misc.fpsboost,
                        boostoptions = menu.misc.boostoptions,
                        animations = menu.misc.animations,
                        anims = menu.misc.anims,
                        fast_ladder = menu.misc.fast_ladder,
                        clantag = menu.misc.clantag,
                        trashtalk = menu.misc.trashtalk,
                        predictenemies = menu.misc.predictenemies,
                        logs = menu.misc.logs,
                        logs_options = menu.misc.logs_options,
                        logs_output = menu.misc.logs_output,
                        logs_hit_color = menu.misc.logs_hit_color,
                        logs_miss_color = menu.misc.logs_miss_color,
                    }

                    local cfg_setup
                    do
                        local ok_setup, setup_or_err = pcall(function()
                            return pui.setup({
                                menu.aa.builder.modes.normal,
                                aa_extras,
                                visuals_pkg,
                                misc_pkg,
                            }, true)
                        end)
                        if ok_setup then
                            cfg_setup = setup_or_err
                        else
                            client.color_log(255, 80, 80, "[shinymoon] pui.setup failed: " .. tostring(setup_or_err))
                        end
                    end

                    local function snapshot_string()
                        if not cfg_setup then return nil end
                        local ok, saved = pcall(function() return cfg_setup:save() end)
                        if not ok or type(saved) ~= "table" then return nil end
                        local payload = saved
                        if type(shinymoon_cheat_config_bridge) == "table"
                            and type(shinymoon_cheat_config_bridge.export) == "function" then
                            local ok_export, cheat_builder = pcall(shinymoon_cheat_config_bridge.export)
                            if ok_export and type(cheat_builder) == "table"
                                and type(cheat_builder.profiles) == "table"
                                and (cheat_builder.selected == "Gamesense"
                                    or cheat_builder.selected == "Neverlose"
                                    or cheat_builder.selected == "Unknown") then
                                payload = {
                                    shinymoon_version = 2,
                                    pui = saved,
                                    cheat_builder = cheat_builder,
                                }
                            end
                        end
                        local ok_enc, encoded = pcall(function()
                            return base64.encode(table_to_string(payload))
                        end)
                        if not ok_enc then return nil end
                        return encoded
                    end

                    local function decode_and_load(encoded, aa_only)
                        if not cfg_setup or type(encoded) ~= "string" or encoded == "" then return false end
                        local ok_dec, decoded = pcall(base64.decode, encoded)
                        if not ok_dec or not decoded then return false end
                        local ok_ls, chunk = pcall(loadstring, decoded)
                        if not ok_ls or type(chunk) ~= "function" then return false end
                        local ok_run, cfg = pcall(chunk)
                        if not ok_run or type(cfg) ~= "table" then return false end
                        local is_v2 = cfg.shinymoon_version == 2
                        local pui_cfg = is_v2 and cfg.pui or cfg
                        if type(pui_cfg) ~= "table" then return false end
                        if is_v2 and (type(shinymoon_cheat_config_bridge) ~= "table"
                            or type(shinymoon_cheat_config_bridge.import) ~= "function") then
                            return false
                        end
                        local ok_load
                        if aa_only then
                            ok_load = pcall(function() cfg_setup:load(pui_cfg, 1) end)
                            if not ok_load then return false end
                            ok_load = pcall(function() cfg_setup:load(pui_cfg, 2) end)
                        else
                            ok_load = pcall(function() cfg_setup:load(pui_cfg) end)
                        end
                        if not ok_load then return false end
                        if is_v2 then
                            local ok_import, imported = pcall(
                                shinymoon_cheat_config_bridge.import,
                                cfg.cheat_builder
                            )
                            return ok_import and imported == true
                        end
                        if type(shinymoon_cheat_config_bridge) == "table"
                            and type(shinymoon_cheat_config_bridge.capture) == "function" then
                            local ok_capture = pcall(shinymoon_cheat_config_bridge.capture)
                            if not ok_capture then return false end
                        end
                        return true
                    end

                    local function make_meta(name)
                        return {
                            creator = username or "unknown",
                            build = (infos and infos.build) or "gs",
                            name = name,
                            cheat = "gamesense",
                            config = snapshot_string(),
                        }
                    end

                    local function sanitize_name(raw)
                        if type(raw) ~= "string" then return nil end
                        local name = raw:match("^%s*(.-)%s*$")
                        if not name or name == "" then return nil end
                        return name
                    end

                    -- Legacy JSON walker → live UI (migration / clipboard fallback).
                    local function import_cfg_legacy(data)
                        if type(data) ~= "table" then return end
                        local function apply_state_blob(state_name, blob)
                            local target = LEGACY_STATE_ALIASES[state_name] or state_name
                            local state_tbl = menu.aa.builder.modes.normal[target]
                            if state_tbl and type(blob) == "table" then
                                shiny_import_controls(state_tbl, blob)
                            end
                        end
                        -- Flat Varg export: { [state] = {...}, full = {...} }
                        for _, state_name in ipairs(states) do
                            local blob = data[state_name]
                            if not blob then
                                for legacy, modern in pairs(LEGACY_STATE_ALIASES) do
                                    if modern == state_name and data[legacy] then
                                        blob = data[legacy]
                                        break
                                    end
                                end
                            end
                            if blob then apply_state_blob(state_name, blob) end
                        end
                        -- Nested legacy: { states = {...}, full = {...} }
                        if type(data.states) == "table" then
                            for key, blob in pairs(data.states) do
                                apply_state_blob(key, blob)
                            end
                        end
                        if type(data.full) == "table" then
                            shiny_import_controls({
                                aa = aa_extras,
                                visuals = visuals_pkg,
                                misc = misc_pkg,
                            }, data.full)
                        end
                    end

                    local function migrate_legacy_db()
                        if #config_db.presets > 0 then return end
                        local old = database.read(LEGACY_CONFIG_KEY)
                        if type(old) ~= "table" then return end
                        local any = false
                        for name, stored in pairs(old) do
                            if type(name) == "string" and name ~= "" then
                                local data = nil
                                if type(stored) == "string" then
                                    data = shiny_cfg_decode(stored)
                                elseif type(stored) == "table" then
                                    data = stored
                                end
                                if type(data) == "table" then
                                    import_cfg_legacy(data)
                                    if not table_contains(config_db.presets, name) then
                                        config_db.presets[#config_db.presets + 1] = name
                                    end
                                    config_db.data[name] = make_meta(name)
                                    any = true
                                end
                            end
                        end
                        if any then
                            flush_db()
                        end
                    end

                    cfg_logic.create = function()
                        local name = sanitize_name(menu.settings.name_local:get())
                        if not name then return end
                        if not table_contains(config_db.presets, name) then
                            config_db.presets[#config_db.presets + 1] = name
                        end
                        config_db.data[name] = make_meta(name)
                        flush_db()
                        refresh_list()
                        remember_last(name)
                        pcall(function() cvar.play:invoke_callback("ambient\\tones\\elev1") end)
                    end

                    cfg_logic.save = function()
                        local index = (menu.settings.list_local:get() or -1) + 1
                        local name = config_db.presets[index]
                        if not name then
                            return cfg_logic.create()
                        end
                        local data = config_db.data[name] or {}
                        data.creator = username or "unknown"
                        data.build = (infos and infos.build) or "gs"
                        data.name = name
                        data.cheat = "gamesense"
                        data.config = snapshot_string()
                        config_db.data[name] = data
                        flush_db()
                        remember_last(name)
                        pcall(function() cvar.play:invoke_callback("ambient\\tones\\elev1") end)
                    end

                    cfg_logic.load = function(aa_only)
                        local index = (menu.settings.list_local:get() or -1) + 1
                        local name = config_db.presets[index]
                        local data = name and config_db.data[name]
                        if not data or not data.config then return end
                        if decode_and_load(data.config, aa_only) then
                            remember_last(name)
                            if menu.settings.name_local then
                                pcall(function() menu.settings.name_local:set(name) end)
                            end
                            pcall(function() cvar.play:invoke_callback("ambient\\tones\\elev1") end)
                        end
                    end

                    cfg_logic.delete = function()
                        local index = (menu.settings.list_local:get() or -1) + 1
                        local name = config_db.presets[index]
                        if not name then return end
                        table.remove(config_db.presets, index)
                        config_db.data[name] = nil
                        flush_db()
                        refresh_list()
                        local last = database.read(LAST_CFG_KEY)
                        if last == name then
                            pcall(database.write, LAST_CFG_KEY, nil)
                        end
                    end

                    cfg_logic.export = function()
                        local index = (menu.settings.list_local:get() or -1) + 1
                        local name = config_db.presets[index]
                        local data = name and config_db.data[name]
                        if data and data.config then
                            clipboard.set(data.config)
                            pcall(function() cvar.play:invoke_callback("ambient\\tones\\elev1") end)
                        end
                    end

                    cfg_logic.import = function()
                        local encoded = clipboard.get()
                        if not encoded or encoded == "" then return end
                        if decode_and_load(encoded, false) then
                            local name = sanitize_name(menu.settings.name_local:get())
                            if name then
                                if not table_contains(config_db.presets, name) then
                                    config_db.presets[#config_db.presets + 1] = name
                                end
                                config_db.data[name] = make_meta(name)
                                config_db.data[name].config = encoded
                                flush_db()
                                refresh_list()
                                remember_last(name)
                            end
                            return
                        end
                        local data = shiny_cfg_decode(encoded)
                        if type(data) == "table" then
                            import_cfg_legacy(data)
                            local name = sanitize_name(menu.settings.name_local:get())
                            if name then
                                if not table_contains(config_db.presets, name) then
                                    config_db.presets[#config_db.presets + 1] = name
                                end
                                config_db.data[name] = make_meta(name)
                                flush_db()
                                refresh_list()
                                remember_last(name)
                            end
                        end
                    end

                    local function autoload_last()
                        local last = database.read(LAST_CFG_KEY)
                        if type(last) ~= "string" or last == "" then return end
                        local data = config_db.data[last]
                        if data and data.config then
                            decode_and_load(data.config, false)
                            if menu.settings.name_local then
                                pcall(function() menu.settings.name_local:set(last) end)
                            end
                            for i = 1, #config_db.presets do
                                if config_db.presets[i] == last then
                                    pcall(function() menu.settings.list_local:set(i - 1) end)
                                    break
                                end
                            end
                        end
                    end

                    migrate_legacy_db()
                    refresh_list()

                    -- Wire buttons after logic exists (embertrash pattern).
                    menu.settings.create_local:set_callback(cfg_logic.create)
                    menu.settings.save_local:set_callback(cfg_logic.save)
                    menu.settings.load_local:set_callback(function() cfg_logic.load(false) end)
                    menu.settings.load_aa_local:set_callback(function() cfg_logic.load(true) end)
                    menu.settings.delete_local:set_callback(cfg_logic.delete)
                    menu.settings.export_local:set_callback(cfg_logic.export)
                    menu.settings.import_local:set_callback(cfg_logic.import)

                    if menu.settings and menu.settings.list_local then
                        menu.settings.list_local:set_callback(function()
                            local names = config_db.presets
                            local selected_idx = (menu.settings.list_local:get() or -1) + 1
                            if selected_idx >= 1 and selected_idx <= #names then
                                menu.settings.name_local:set(names[selected_idx])
                            end
                        end)
                    end

                    client.delay_call(0.5, autoload_last)
                end
                do
                    local ok_init, err_init = pcall(init_presets)
                    if not ok_init then
                        client.color_log(255, 80, 80, "[shinymoon] presets init failed: " .. tostring(err_init))
                    end
                end

                -- ── Per-cheat builder profiles (Enemy cheat combobox) ──
                -- Live controls always hold the profile selected in the
                -- combobox; the other profiles live as export blobs and are
                -- applied at runtime through a read-only {get=...} proxy.
                do
                    local CHEAT_CFG_KEY = "shinymoon:gs:cheat_builder"
                    local cheat_cfgs = database.read(CHEAT_CFG_KEY) or {}
                    local edited_cheat = menu.aa.builder.cheats:get() or "Gamesense"
                    local cheat_mt_cache = {}

                    local function cheat_export_all()
                        local out = {}
                        for _, st in ipairs(states) do
                            out[st] = shiny_export_controls(menu.aa.builder.modes.normal[st])
                        end
                        return out
                    end

                    local function cheat_import_all(blob)
                        if type(blob) ~= "table" then return end
                        for _, st in ipairs(states) do
                            if blob[st] then
                                shiny_import_controls(menu.aa.builder.modes.normal[st], blob[st])
                            end
                        end
                    end

                    shinymoon_cheat_config_bridge = {
                        export = function()
                            cheat_cfgs[edited_cheat] = cheat_export_all()
                            local profiles = {}
                            for _, name in ipairs({ "Gamesense", "Neverlose", "Unknown" }) do
                                if type(cheat_cfgs[name]) == "table" then
                                    profiles[name] = cheat_cfgs[name]
                                end
                            end
                            return {
                                selected = edited_cheat,
                                profiles = profiles,
                            }
                        end,
                        capture = function()
                            cheat_cfgs[edited_cheat] = cheat_export_all()
                            pcall(database.write, CHEAT_CFG_KEY, cheat_cfgs)
                        end,
                        import = function(snapshot)
                            if type(snapshot) ~= "table"
                                or type(snapshot.profiles) ~= "table"
                                or (snapshot.selected ~= "Gamesense"
                                    and snapshot.selected ~= "Neverlose"
                                    and snapshot.selected ~= "Unknown") then
                                return false
                            end

                            local imported = {}
                            for _, name in ipairs({ "Gamesense", "Neverlose", "Unknown" }) do
                                if type(snapshot.profiles[name]) == "table" then
                                    imported[name] = snapshot.profiles[name]
                                end
                            end

                            cheat_cfgs = imported
                            edited_cheat = snapshot.selected
                            cheat_mt_cache = {}
                            menu.aa.builder.cheats:set(edited_cheat)
                            if cheat_cfgs[edited_cheat] then
                                cheat_import_all(cheat_cfgs[edited_cheat])
                            end
                            pcall(database.write, CHEAT_CFG_KEY, cheat_cfgs)
                            return true
                        end,
                    }

                    local function cheat_wrap(v)
                        return { get = function() return v end }
                    end

                    -- complete()/ft only ever call :get(); delay_custom_values
                    -- is the one nested control table, wrapped element-wise.
                    local function cheat_state_proxy(sblob)
                        local p = {}
                        for k, v in pairs(sblob) do
                            if k == "delay_custom_values" and type(v) == "table" then
                                local t = {}
                                for i, sv in pairs(v) do t[i] = cheat_wrap(sv) end
                                p[k] = t
                            else
                                p[k] = cheat_wrap(v)
                            end
                        end
                        return p
                    end

                    -- Runtime seam: mode table for the detected threat bucket.
                    -- Live controls when the bucket is being edited or has no
                    -- stored blob (pre-change behavior).
                    function shinymoon_cheat_mode_table()
                        local bucket = shinymoon_active_cheat_bucket
                            and shinymoon_active_cheat_bucket() or "Unknown"
                        if bucket == edited_cheat then
                            return menu.aa.builder.modes.normal
                        end
                        local blob = cheat_cfgs[bucket]
                        if not blob then
                            return menu.aa.builder.modes.normal
                        end
                        local cached = cheat_mt_cache[bucket]
                        if not cached or cached.blob ~= blob then
                            local mt = {}
                            for st, sblob in pairs(blob) do
                                if type(sblob) == "table" then
                                    mt[st] = cheat_state_proxy(sblob)
                                end
                            end
                            cached = { blob = blob, mt = mt }
                            cheat_mt_cache[bucket] = cached
                        end
                        return cached.mt
                    end

                    if cheat_cfgs[edited_cheat] then
                        cheat_import_all(cheat_cfgs[edited_cheat])
                    end

                    menu.aa.builder.cheats:set_callback(function()
                        local new_cheat = menu.aa.builder.cheats:get()
                        if new_cheat == edited_cheat then return end
                        cheat_cfgs[edited_cheat] = cheat_export_all()
                        edited_cheat = new_cheat
                        -- No stored blob: current values seed the new profile.
                        if cheat_cfgs[new_cheat] then
                            cheat_import_all(cheat_cfgs[new_cheat])
                        end
                        pcall(database.write, CHEAT_CFG_KEY, cheat_cfgs)
                    end)

                    client.set_event_callback("shutdown", function()
                        cheat_cfgs[edited_cheat] = cheat_export_all()
                        pcall(database.write, CHEAT_CFG_KEY, cheat_cfgs)
                    end)
                end

                local function table_contains (tbl, val)
                    for _, v in ipairs(tbl) do
                    if v == val then
                        return true
                    end
                    end
                    return false
                end


        local lcdefesp do
                    local g_esp_data = { }
                    local g_sim_ticks, g_net_data = { }, { }

                    local globals_tickinterval = globals.tickinterval
                    local entity_is_enemy = entity.is_enemy
                    local entity_get_prop = entity.get_prop
                    local entity_is_dormant = entity.is_dormant
                    local entity_is_alive = entity.is_alive
                    local entity_get_origin = entity.get_origin
                    local entity_get_local_player = entity.get_local_player
                    local entity_get_player_resource = entity.get_player_resource
                    local entity_get_bounding_box = entity.get_bounding_box
                    local entity_get_player_name = entity.get_player_name
                    local renderer_text = renderer.text
                    local w2s = renderer.world_to_screen
                    local line = renderer.line
                    local table_insert = table.insert
                    local client_trace_line = client.trace_line
                    local math_floor = math.floor
                    local globals_frametime = globals.frametime

                    local sv_gravity = cvar.sv_gravity
                    local sv_jump_impulse = cvar.sv_jump_impulse

                    local time_to_ticks = function(t) return math_floor(0.5 + (t / globals_tickinterval())) end
                    local vec_substract = function(a, b) return { a[1] - b[1], a[2] - b[2], a[3] - b[3] } end
                    local vec_add = function(a, b) return { a[1] + b[1], a[2] + b[2], a[3] + b[3] } end
                    local vec_lenght = function(x, y) return (x * x + y * y) end

                    local get_entities = function(enemy_only, alive_only)
                        local enemy_only = enemy_only ~= nil and enemy_only or false
                        local alive_only = alive_only ~= nil and alive_only or true
                        
                        local result = {}

                        local me = entity_get_local_player()
                        local player_resource = entity_get_player_resource()
                        
                        for player = 1, globals.maxplayers() do
                            local is_enemy, is_alive = true, true
                            
                            if enemy_only and not entity_is_enemy(player) then is_enemy = false end
                            if is_enemy then
                                if alive_only and entity_get_prop(player_resource, 'm_bAlive', player) ~= 1 then is_alive = false end
                                if is_alive then table_insert(result, player) end
                            end
                        end

                        return result
                    end

                    local extrapolate = function(ent, origin, flags, ticks)
                        local tickinterval = globals_tickinterval()

                        local sv_gravity = sv_gravity:get_float() * tickinterval
                        local sv_jump_impulse = sv_jump_impulse:get_float() * tickinterval

                        local p_origin, prev_origin = origin, origin

                        local velocity = { entity_get_prop(ent, 'm_vecVelocity') }
                        local gravity = velocity[3] > 0 and -sv_gravity or sv_jump_impulse

                        for i=1, ticks do
                            prev_origin = p_origin
                            p_origin = {
                                p_origin[1] + (velocity[1] * tickinterval),
                                p_origin[2] + (velocity[2] * tickinterval),
                                p_origin[3] + (velocity[3]+gravity) * tickinterval,
                            }

                            local fraction = client_trace_line(-1, 
                                prev_origin[1], prev_origin[2], prev_origin[3], 
                                p_origin[1], p_origin[2], p_origin[3]
                            )

                            if fraction <= 0.99 then
                                return prev_origin
                            end
                        end

                        return p_origin
                    end

                    local function g_net_update()
                        local me = entity_get_local_player()
                        local players = get_entities(true, true)

                        for i=1, #players do
                            local idx = players[i]
                            local prev_tick = g_sim_ticks[idx]
                            
                            if entity_is_dormant(idx) or not entity_is_alive(idx) then
                                g_sim_ticks[idx] = nil
                                g_net_data[idx] = nil
                                g_esp_data[idx] = nil
                            else
                                local player_origin = { entity_get_origin(idx) }
                                local simulation_time = time_to_ticks(entity_get_prop(idx, 'm_flSimulationTime'))
                        
                                if prev_tick ~= nil then
                                    local delta = simulation_time - prev_tick.tick

                                    if delta < 0 or delta > 0 and delta <= 64 then
                                        local m_fFlags = entity_get_prop(idx, 'm_fFlags')

                                        local diff_origin = vec_substract(player_origin, prev_tick.origin)
                                        local teleport_distance = vec_lenght(diff_origin[1], diff_origin[2])

                                        local extrapolated = extrapolate(idx, player_origin, m_fFlags, delta-1)
                        
                                        if delta < 0 then
                                            g_esp_data[idx] = 1
                                        end

                                        g_net_data[idx] = {
                                            tick = delta-1,

                                            origin = player_origin,
                                            predicted_origin = extrapolated,

                                            tickbase = delta < 0,
                                            lagcomp = teleport_distance > 4096,
                                        }
                                    end
                                end
                        
                                if g_esp_data[idx] == nil then
                                    g_esp_data[idx] = 0
                                end

                                g_sim_ticks[idx] = {
                                    tick = simulation_time,
                                    origin = player_origin,
                                }
                            end
                        end
                    end

                    local function g_paint_handler()
                        local me = entity_get_local_player()
                        local player_resource = entity_get_player_resource()

                        if not me or not entity_is_alive(me) then
                            return
                        end

                        local observer_mode = entity_get_prop(me, "m_iObserverMode")
                        local active_players = {}

                        if (observer_mode == 0 or observer_mode == 1 or observer_mode == 2 or observer_mode == 6) then
                            active_players = get_entities(true, true)
                        elseif (observer_mode == 4 or observer_mode == 5) then
                            local all_players = get_entities(false, true)
                            local observer_target = entity_get_prop(me, "m_hObserverTarget")
                            local observer_target_team = entity_get_prop(observer_target, "m_iTeamNum")

                            for test_player = 1, #all_players do
                                if (
                                    observer_target_team ~= entity_get_prop(all_players[test_player], "m_iTeamNum") and
                                    all_players[test_player ] ~= me
                                ) then
                                    table_insert(active_players, all_players[test_player])
                                end
                            end
                        end

                        if #active_players == 0 then
                            return
                        end

                        for idx, net_data in pairs(g_net_data) do
                            if entity_is_alive(idx) and entity_is_enemy(idx) and net_data ~= nil then
                                if net_data.lagcomp then
                                    local predicted_pos = net_data.predicted_origin

                                    local min = vec_add({ entity_get_prop(idx, 'm_vecMins') }, predicted_pos)
                                    local max = vec_add({ entity_get_prop(idx, 'm_vecMaxs') }, predicted_pos)

                                    local points = {
                                        {min[1], min[2], min[3]}, {min[1], max[2], min[3]},
                                        {max[1], max[2], min[3]}, {max[1], min[2], min[3]},
                                        {min[1], min[2], max[3]}, {min[1], max[2], max[3]},
                                        {max[1], max[2], max[3]}, {max[1], min[2], max[3]},
                                    }

                                    -- 12 box edges over the 1-indexed points (1-4 bottom, 5-8 top)
                                    local edges = {
                                        {1, 2}, {2, 3}, {3, 4}, {4, 1},
                                        {5, 6}, {6, 7}, {7, 8}, {8, 5},
                                        {1, 5}, {2, 6}, {3, 7}, {4, 8},
                                    }

                                    for i = 1, #edges do
                                        if i == 1 then
                                            local origin = { entity_get_origin(idx) }
                                            local origin_w2s = { w2s(origin[1], origin[2], origin[3]) }
                                            local min_w2s = { w2s(min[1], min[2], min[3]) }

                                            if origin_w2s[1] ~= nil and min_w2s[1] ~= nil then
                                                line(origin_w2s[1], origin_w2s[2], min_w2s[1], min_w2s[2], 255, 255, 255, 255)
                                            end
                                        end

                                        local a1, a2 = points[edges[i][1]], points[edges[i][2]]
                                        local p1 = { w2s(a1[1], a1[2], a1[3]) }
                                        local p2 = { w2s(a2[1], a2[2], a2[3]) }

                                        if p1[1] ~= nil and p2[1] ~= nil then
                                            line(p1[1], p1[2], p2[1], p2[2], 255, 255, 255, 255)
                                        end
                                    end
                                end

                                local text = {
                                    [0] = '', [1] = 'BREAKING LC',
                                    [2] = 'SHIFTING TICKBASE'
                                }

                                local x1, y1, x2, y2, a = entity_get_bounding_box(idx)
                                local palpha = 0

                                if g_esp_data[idx] > 0 then
                                    g_esp_data[idx] = g_esp_data[idx] - globals_frametime()*2
                                    g_esp_data[idx] = g_esp_data[idx] < 0 and 0 or g_esp_data[idx]

                                    palpha = g_esp_data[idx]
                                end

                                local tb = net_data.tickbase or g_esp_data[idx] > 0
                                local lc = net_data.lagcomp

                                if not tb or net_data.lagcomp then
                                    palpha = a
                                end

                                if x1 ~= nil and a > 0 then
                                    local name = entity_get_player_name(idx)
                                    local y_add = name == '' and -8 or 0

                                    renderer_text(x1 + (x2-x1)/2, y1 - 18 + y_add, 255, 45, 45, palpha*255, 'c', 0, text[tb and 2 or (lc and 1 or 0)])
                                end
                            end
                        end
                    end

                    client.set_event_callback('paint', g_paint_handler)
                    client.set_event_callback('net_update_end', g_net_update)
                    -- Entindexes are reused across maps; stale sim ticks would
                    -- flash false "SHIFTING TICKBASE" on the first updates.
                    client.set_event_callback('level_init', function()
                        g_esp_data = { }
                        g_sim_ticks, g_net_data = { }, { }
                    end)
                end

                local aspectratio = {
                    alpha = 0,
                    current_ratio = nil,
                    native_ratio = nil,
                    original_cvar = nil,
                    smooth_speed = 5,

                    init = function(self)
                        local x, y = client.screen_size()
                        self.native_ratio = (x and y and x / y) or 16/9
                        local ok, v = pcall(function() return cvar.r_aspectratio:get_float() end)
                        self.original_cvar = (ok and v) and v or nil
                        if ok and tonumber(v) and tonumber(v) > 0 then
                            self.current_ratio = tonumber(v)
                        else
                            self.current_ratio = self.native_ratio
                        end
                    end,

                    run = function(self)
                        if not self.native_ratio then self:init() end

                        local enabled = menu.visuals.aspectratio:get()
                        self.alpha = lerp_module.new('aspect_ratio_alpha', enabled and 255 or 0, 16, 0.001, 'ease_out')

                        local slider_pct = (menu.visuals.ratio:get() or 100) / 100
                        local target = enabled and (self.native_ratio * slider_pct) or self.native_ratio

                        if not self.current_ratio then self.current_ratio = self.native_ratio end
                        local t = func.clamp(globals.frametime() * self.smooth_speed, 0, 1)
                        self.current_ratio = func.lerp(self.current_ratio, target, t)

                        if math.abs(self.current_ratio - target) < 0.0005 then
                            self.current_ratio = target
                        end

                        pcall(function() cvar.r_aspectratio:set_float(self.current_ratio) end)
                        end,

                        restore_original = function(self)
                        if self.original_cvar and tonumber(self.original_cvar) and tonumber(self.original_cvar) > 0 then
                            pcall(function() cvar.r_aspectratio:set_float(tonumber(self.original_cvar)) end)
                        else
                            pcall(function() cvar.r_aspectratio:set_float(self.native_ratio) end)
                        end
                    end
                }

                client.set_event_callback("paint", function()
                    aspectratio:run()
                end)

                client.set_event_callback("shutdown", function()
                    cvar.r_aspectratio:set_float(0)
                end)




                local autobuy = {
                    run = function(self)
                        if not menu.misc.autobuy:get() then return end

                        local function selected(options, name)
                            for key, option in pairs(options or {}) do
                                if option == name or (key == name and option) then return true end
                            end
                            return false
                        end
                        
                        local primary = menu.misc.options.autobuy_primary:get()
                        local secondary = menu.misc.options.autobuy_secondary:get()
                        local armor = menu.misc.options.autobuy_armor:get()
                        local nades = menu.misc.options.autobuy_nades:get()
                        local utils = menu.misc.options.autobuy_utils:get()

                        if primary == "Scout" then
                            client.exec("buy ssg08")
                        elseif primary == "Awp" then
                            client.exec("buy awp")
                        elseif primary == "Autos" then
                            client.exec("buy g3sg1; buy scar20")
                        end

                        if secondary == "Five-SeveN/Tec-9" then
                            client.exec("buy fiveseven; buy tec9")
                        elseif secondary == "Dual Barretas" then
                            client.exec("buy elite")
                        elseif secondary == "Deagle" then
                            client.exec("buy deagle")
                        elseif secondary == "R8" then
                            client.exec("buy revolver")
                        end

                        if selected(armor, "Kevlar + Helmet") then
                            client.exec("buy vesthelm")
                        elseif selected(armor, "Kevlar") then
                            client.exec("buy vest")
                        end

                        if selected(nades, "HE Grenade") then client.exec("buy hegrenade") end
                        if selected(nades, "Smoke Grenade") then client.exec("buy smokegrenade") end
                        if selected(nades, "Molotov") then client.exec("buy molotov; buy incgrenade") end
                        if selected(utils, "Defuse Kit") then client.exec("buy defuser") end
                        if selected(utils, "Taser") then client.exec("buy taser") end
                    end
                }

                client.set_event_callback("round_prestart", function()
                    autobuy:run()
                end)

                local animations = {
                    interp_state = { smoothed_pose = {} },
                    settle_until = 0,

                    reset_interp = function(self)
                        self.interp_state.smoothed_pose = {}
                        -- Give the new map/spawn time to build a clean animstate
                        -- before we write poses again, and drop any stuck
                        -- leg-movement override from the previous map.
                        self.settle_until = globals.realtime() + 0.5
                        self:set_leg_movement(nil)
                    end,

                    set_leg_movement = function(self, mode)
                        local lg = refs.aa.fl and refs.aa.fl.lg and refs.aa.fl.lg[1]
                        if not lg then return end
                        if mode == nil then
                            lg:override()
                        else
                            lg:override(mode)
                        end
                    end,

                    -- Pose EMA is unsafe on gamesense: pre_render runs every frame (not
                    -- once per anim update), set_prop persists into the next read, and the
                    -- blend lags body/movement poses — killing local desync + anim breakers.
                    -- Alpha/godsense use post_update_clientside_animation; GS has no equivalent.
                    apply_interpolation = function(self, me)
                        return
                    end,

                    run = function(self)
                        if not menu.misc.animations:get() then
                            self:set_leg_movement(nil)
                            return
                        end

                        local me = entity.get_local_player()
                        if not me or not entity.is_alive(me) then return end

                        -- Don't touch poses/layers while the fresh entity is still
                        -- settling (map change / server join / respawn).
                        if globals.realtime() < (self.settle_until or 0) then return end

                        local flags = entity.get_prop(me, "m_fFlags") or 0
                        local on_ground = bit.band(flags, 1) == 1
                        local anim_state = entity.get_animstate and entity.get_animstate(me)
                        if not anim_state then return end

                        if on_ground then
                            local ground_mode = menu.misc.anims.ground_legs:get()
                            if ground_mode == "Static" then
                                entity.set_prop(me, "m_flPoseParameter", 1, 0)
                                self:set_leg_movement("Always slide")
                            elseif ground_mode == "Jitter" then
                                local tick = globals.tickcount()
                                local osc = 1 / (tick % 8 >= 4 and 200 or 400)
                                local off1 = menu.misc.anims.legs_offset_1:get() or 100
                                local off2 = menu.misc.anims.legs_offset_2:get() or 100
                                local j_val = tick % 4 >= 2 and off1 or off2
                                self:set_leg_movement("Always slide")
                                entity.set_prop(me, "m_flPoseParameter", j_val * osc, 0)
                            elseif ground_mode == "Walking" then
                                entity.set_prop(me, "m_flPoseParameter", 0, 7)
                                self:set_leg_movement("Off")
                            elseif ground_mode == "Earthquake" then
                                entity.set_prop(me, "m_flPoseParameter", math.random(), 3)
                                entity.set_prop(me, "m_flPoseParameter", math.random(), 6)
                                entity.set_prop(me, "m_flPoseParameter", math.random(), 7)
                                self:set_leg_movement(nil)
                            else
                                self:set_leg_movement(nil)
                            end

                            if menu.misc.anims.pitch_on_land:get() and anim_state and anim_state.hit_in_ground_animation then
                                entity.set_prop(me, "m_flPoseParameter", 0.5, 12)
                            end
                        else
                            local air_mode = menu.misc.anims.air_legs:get()
                            if air_mode == "Static" then
                                entity.set_prop(me, "m_flPoseParameter", 0.5, 6)
                            elseif air_mode == "Walking" then
                                local air_layer = entity.get_animlayer and entity.get_animlayer(me, 6)
                                if air_layer then
                                    air_layer.weight = 1
                                    air_layer.cycle = globals.realtime() * 0.5 % 1
                                end
                            end
                        end

                        local lean = menu.misc.anims.body_lean:get() or -1
                        if lean > 0 then
                            local lean_layer = entity.get_animlayer and entity.get_animlayer(me, 12)
                            if lean_layer then
                                lean_layer.weight = lean / 100.0
                            end
                        end
                    end
                }

                client.set_event_callback("pre_render", function()
                    animations:run()
                end)

                client.set_event_callback("round_prestart", function()
                    animations:reset_interp()
                end)

                client.set_event_callback("level_init", function()
                    animations:reset_interp()
                end)

                client.set_event_callback("cs_game_disconnected", function()
                    animations:reset_interp()
                end)

                client.set_event_callback("player_spawn", function(e)
                    local me = entity.get_local_player()
                    if e and e.userid and me and client.userid_to_entindex(e.userid) == me then
                        animations:reset_interp()
                    end
                end)
                local thirdperson; do
                    thirdperson = {
                        enabled = false,

                        run = function(self)
                            local enabled = menu.visuals.thirdperson:get()

                            if enabled then
                                if not self.enabled then
                                    client.exec("thirdperson")
                                end
                                local dist = menu.visuals.thirdperson_dist and menu.visuals.thirdperson_dist:get() or 90
                                client.exec("cam_idealdist " .. dist)
                            elseif self.enabled then
                                client.exec("firstperson")
                            end

                            self.enabled = enabled
                        end
                    }

                    client.set_event_callback("paint", function()
                        thirdperson:run()
                    end)

                end
                local fpsboost; do
                    local fps_cvars = {
                        ['Fix chams color'] = {'mat_autoexposure_max_multiplier', 0.2, 1},
                        ['Disable dynamic lighting'] = {'r_dynamiclighting', 0, 1},
                        ['Disable dynamic shadows'] = {'r_dynamic', 0, 1},
                        ['Disable first-person tracers'] = {'r_drawtracers_firstperson', 0, 1},
                        ['Disable ragdolls'] = {'cl_disable_ragdolls', 1, 0},
                        ['Disable eye gloss'] = {'r_eyegloss', 0, 1},
                        ['Disable eye movement'] = {'r_eyemove', 0, 1},
                        ['Disable muzzle flash light'] = {'muzzleflash_light', 0, 1},
                        ['Enable low CPU audio'] = {'dsp_slow_cpu', 1, 0},
                        ['Disable bloom'] = {'mat_disable_bloom', 1, 0},
                        ['Disable particles'] = {'r_drawparticles', 0, 1},
                        ['Reduce breakable objects'] = {'func_break_max_pieces', 0, 15}
                    }
                
                    local fpsboost_was_on = false
                    local function fpsboost()
                        if not menu.misc.fpsboost:get() then
                            -- Restore once on disable; don't stomp user cvars every tick.
                            if fpsboost_was_on then
                                fpsboost_was_on = false
                                for name, data in pairs(fps_cvars) do
                                    local cvar_name, boost_value, default_value = unpack(data)
                                    cvar[cvar_name]:set_int(default_value)
                                end
                            end
                            return
                        end
                        fpsboost_was_on = true
                
                        local selected_boosts = {}
                        if menu and menu.misc and menu.misc.boostoptions then
                            if type(menu.misc.boostoptions.get) == "function" then
                                selected_boosts = menu.misc.boostoptions:get() or {}
                            elseif menu.misc.boostoptions[1] and type(menu.misc.boostoptions[1].get) == "function" then
                                selected_boosts = menu.misc.boostoptions[1]:get() or {}
                            end
                        end

                        for name, data in pairs(fps_cvars) do
                            local cvar_name, boost_value, default_value = unpack(data)
                            cvar[cvar_name]:set_int(table_contains(selected_boosts, name) and boost_value or default_value)
                        end
                    end
                    
                    client.set_event_callback('setup_command', fpsboost)
                end

                -- Fast ladder (Misc): relative-yaw pattern proven on gamesense
                -- (embertrash/OneSense). Alpha's ladder-normal absolute yaw pairs
                -- with the opposite strafe keys and does not climb on GS.
                client.set_event_callback("setup_command", function(cmd)
                    if not menu.misc.fast_ladder or not menu.misc.fast_ladder:get() then return end
                    local me = entity.get_local_player()
                    if not me or not entity.is_alive(me) then return end
                    if entity.get_prop(me, "m_MoveType") ~= 9 then return end

                    -- Skip knives (matches alpha misc_has_knife)
                    local wpn = entity.get_player_weapon(me)
                    if wpn then
                        local cn = entity.get_classname(wpn) or ""
                        if cn:find("Knife") or cn:find("knife") then return end
                    end

                    if cmd.forwardmove > 0 then
                        -- Looking down past 45° while holding W means the user wants
                        -- to descend; don't fight their intent (embertrash gate).
                        if cmd.pitch < 45 then
                            cmd.pitch = 89
                            cmd.in_forward = 0
                            cmd.in_back = 1
                            cmd.in_moveright = 1
                            cmd.in_moveleft = 0

                            if cmd.sidemove == 0 then
                                cmd.yaw = cmd.yaw + 90
                            elseif cmd.sidemove < 0 then
                                cmd.yaw = cmd.yaw + 150
                            elseif cmd.sidemove > 0 then
                                cmd.yaw = cmd.yaw + 30
                            end
                        end
                    elseif cmd.forwardmove < 0 then
                        cmd.pitch = 89
                        cmd.in_forward = 1
                        cmd.in_back = 0
                        cmd.in_moveleft = 1
                        cmd.in_moveright = 0

                        if cmd.sidemove == 0 then
                            cmd.yaw = cmd.yaw + 90
                        elseif cmd.sidemove > 0 then
                            cmd.yaw = cmd.yaw + 150
                        elseif cmd.sidemove < 0 then
                            cmd.yaw = cmd.yaw + 30
                        end
                    end
                end)

            self:show(false)
        end,
    } private:init()
    client.set_event_callback("paint_ui", function()
        if private.initialized then
            private:keep_hidden()
        end
    end)
    local fakelag = {
        last_amount = 0,
        fluctuate_direction = 1,
        fluctuate_value = 1,
        
        run = function(self)
            local me = entity.get_local_player()
            if not me or not entity.is_alive(me) then return end
            
            
            local fl_mode = menu.aa.fakelag.fl_amount:get()
            local fl_variance = menu.aa.fakelag.fl_variance:get()
            local fl_limit = menu.aa.fakelag.fl_limit:get()
            
            
            local amount = 0
            local variance = 0
            
            if fl_mode == "Dynamic" then
                
                local vx, vy, vz = entity.get_prop(me, "m_vecVelocity")
                vx, vy, vz = vx or 0, vy or 0, vz or 0
                local speed = math.sqrt(vx * vx + vy * vy)
                
                
                if speed > 200 then
                    amount = fl_limit
                elseif speed > 100 then
                    amount = math.floor(fl_limit * 0.75)
                elseif speed > 50 then
                    amount = math.floor(fl_limit * 0.5)
                else
                    amount = math.max(1, math.floor(fl_limit * 0.3))
                end
                
                
                variance = math.floor((fl_variance / 100) * amount)
                
            elseif fl_mode == "Maximum" then
                
                amount = fl_limit
                variance = math.floor((fl_variance / 100) * fl_limit)
                
            elseif fl_mode == "Fluctuate" then
                
                self.fluctuate_value = self.fluctuate_value + self.fluctuate_direction
                
                if self.fluctuate_value >= fl_limit then
                    self.fluctuate_direction = -1
                    self.fluctuate_value = fl_limit
                elseif self.fluctuate_value <= 1 then
                    self.fluctuate_direction = 1
                    self.fluctuate_value = 1
                end
                
                amount = self.fluctuate_value
                variance = math.floor((fl_variance / 100) * fl_limit)
            end
            
            
            amount = func.fclamp(amount, 1, 15)
            variance = func.fclamp(variance, 0, 14)
            
            
            local function safe_override(ref, value)
                if ref then
                    if type(ref) == "table" then
                        if ref.override then
                            pcall(function() ref:override(value) end)
                        elseif ref[1] then
                            if type(ref[1]) == "table" and ref[1].override then
                                pcall(function() ref[1]:override(value) end)
                            else
                                pcall(ui.set, ref[1], value)
                            end
                        end
                    else
                        pcall(ui.set, ref, value)
                    end
                end
            end
            
            if refs.aa and refs.aa.fl then
                safe_override(refs.aa.fl.enable, true)
                safe_override(refs.aa.fl.amount, amount)
                safe_override(refs.aa.fl.variance, variance)
                safe_override(refs.aa.fl.limit, fl_limit)
            end
            
            self.last_amount = amount
        end
    }

    client.set_event_callback("setup_command", function(cmd)
        pcall(function()
            if menu.aa and menu.aa.fakelag then
                fakelag:run()
            end
        end)
    end)

    local aa = {
        
        state = {
            side = 0,                    
            switch_delay = 0,            
            current_slider = 1,          
            counter = 0,                 
            body_yaw_false_ticks = 0,    
            last_rand = 0,               
            random_threshold = 0,        
            minmax_threshold = 0,        
            exp_stage = 0,               
            shiny_delay = nil,
            desync_save = 180,           -- varg body-yaw jitter desync-random countdown
        },
        
        
        manual = {
            aa = 0,
            tick = 0,
            active = false,              
            direction = 0                
        },
        
        
        net_update = {
            last_simtime = {},           
            last_origin = {},            
            breaking_lc = {},            
            tick_delta = {},             
            side_on_update = 0,          
            pending_switch = false,      
            last_update_tick = 0,        
        },
        
        
shiny = {
    
    enemies = {},
    
    
    threat = {
        level = 0,
        primary_threat = nil,
        threat_direction = 0,
        imminent_danger = false,
        aim_locked_count = 0,
        last_update = 0,
    },
    
    
    learning = {
        side_effectiveness = {[0] = 0, [1] = 0},
        recent_hits = {},
        recent_dodges = {},
        last_hit_side = nil,
        same_side_hits = 0,
    },
    
    
    timing = {
        last_switch = 0,
        last_switch_tick = 0,
        phase_offset = math.random() * math.pi * 2,
        anti_predict_timer = 0,
    },
    
    auto_values = {
        yaw_left = -45,
        yaw_right = 21,
        body_yaw = -1,
        delay = 0.5,
        jitter_amount = 0,
        last_calculation = 0,
    },
    
     shot_analysis = {
        recent_shots = {},  
        max_samples = 4096,  
        
        
        db_keys = {
            yaw_buckets = "shiny:shot_analysis:yaw_buckets",
            body_yaw_stats = "shiny:shot_analysis:body_yaw_stats",
            timing_patterns = "shiny:shot_analysis:timing_patterns",
            weapon_stats = "shiny:shot_analysis:weapon_stats",
            last_save = "shiny:shot_analysis:last_save",
        },
        
        
        yaw_buckets = {
            
            
        },
        
        
        body_yaw_stats = {
            
        },
        
        
        timing_patterns = {
            last_hit_times = {},      
            last_miss_times = {},     
            avg_hit_interval = 0,     
            hit_streak = 0,           
            miss_streak = 0,          
        },
        
        
        weapon_stats = {
            
        },
        
        
        last_save_time = 0,
        save_interval = 5,  
        dirty = false,      
    },
    
    
    aim_tracking = {
        
        db_keys = {
            global_stats = "shiny:aim_tracking:global_stats",
            angle_heatmap = "shiny:aim_tracking:angle_heatmap",
            last_save = "shiny:aim_tracking:last_save",
        },
        
        
        enemies = {
            
            
            
            
            
            
            
            
            
            
            
            
            
        },
        
        
        global_stats = {
            total_shots_tracked = 0,
            left_side_preference = 0,   
            right_side_preference = 0,
            avg_enemy_accuracy = 0.5,
        },
        
        
        angle_heatmap = {
            
            
        },
        
        
        last_save_time = 0,
        save_interval = 5,
        dirty = false,
    },

    
    THREAT_CRITICAL = 0.85,
    THREAT_HIGH = 0.65,
    THREAT_MEDIUM = 0.4,
    
    
    db_initialized = false,
},

        -- run is defined after dtc/forward-track exist (see `aa.run =` below).

        handle_manuals = function(self, cmd)
            local tick = globals.tickcount()
            local hk = menu.aa.hotkeys and menu.aa.hotkeys:get()
            local manuals_on = false
            if type(hk) == "table" then
                for _, v in ipairs(hk) do
                    if v == "Manuals" then manuals_on = true break end
                end
            end
            if not manuals_on then
                if self.manual.active then
                    self.manual.aa = 0
                    self.manual.direction = 0
                    self.manual.active = false
                end
                return
            end
            local manual_mode = menu.aa.manualsoptions and menu.aa.manualsoptions:get() or "Default"
            
            
            if menu.aa.manualr and menu.aa.manualr:get() and (self.manual.tick < tick - 11) then
                if self.manual.direction == 90 then
                    
                    self.manual.aa = 0
                    self.manual.direction = 0
                    self.manual.active = false
                else
                    self.manual.aa = 90
                    self.manual.direction = 90
                    self.manual.active = true
                end
                self.manual.tick = tick
            end
            
            
            if menu.aa.manuall and menu.aa.manuall:get() and (self.manual.tick < tick - 11) then
                if self.manual.direction == -90 then
                    
                    self.manual.aa = 0
                    self.manual.direction = 0
                    self.manual.active = false
                else
                    self.manual.aa = -90
                    self.manual.direction = -90
                    self.manual.active = true
                end
                self.manual.tick = tick
            end
            
            
            if menu.aa.manualb and menu.aa.manualb:get() and (self.manual.tick < tick - 11) then
                if self.manual.direction == 180 then
                    
                    self.manual.aa = 0
                    self.manual.direction = 0
                    self.manual.active = false
                else
                    self.manual.aa = 180
                    self.manual.direction = 180
                    self.manual.active = true
                end
                self.manual.tick = tick
            end
            
            
            if menu.aa.manualf and menu.aa.manualf:get() and (self.manual.tick < tick - 11) then
                self.manual.aa = 0
                self.manual.direction = 0
                self.manual.active = false
                self.manual.tick = tick
            end
        end,

        handle_hotkeys = function(self, cmd)
            local selected = {}
            local hk = menu.aa.hotkeys and menu.aa.hotkeys:get()
            if type(hk) == "table" then
                for _, v in ipairs(hk) do selected[v] = true end
            end

            if selected["Freestanding"] and menu.aa.freestand and refs.aa.freestand then
                local fs_active = menu.aa.freestand:get()
                if refs.aa.freestand[1] then
                    refs.aa.freestand[1]:override(fs_active)
                end
            end

            -- On-shot AA is gated by its own hotkey (embertrash uses set_hotkey,
            -- not a plain override). Open the gate while held, restore on release.
            -- set_hotkey is a persistent GS menu write: the restore must run even
            -- if "Hideshots" got deselected, or the mode wedges at "Always on".
            local hs_held = selected["Hideshots"] and menu.aa.hideshots
                and (menu.aa.hideshots:get() and true or false)
            if hs_held and refs.aa.osaa and refs.aa.osaa[1] then
                local osaa = refs.aa.osaa[1]
                if not self.hs_forced then
                    local ok, mode = pcall(function() return select(2, osaa:get_hotkey()) end)
                    self.hs_saved_mode = (ok and mode) or 1
                    pcall(function() osaa:set_hotkey("Always on") end)
                    self.hs_forced = true
                end
                pcall(function() osaa:override(true) end)
            elseif self.hs_forced and refs.aa.osaa and refs.aa.osaa[1] then
                local osaa = refs.aa.osaa[1]
                local modes = {[0] = "Always on", [1] = "On hotkey", [2] = "Toggle", [3] = "Off hotkey"}
                pcall(function() osaa:set_hotkey(modes[self.hs_saved_mode] or "On hotkey") end)
                pcall(function() osaa:override() end)
                self.hs_forced = false
                self.hs_saved_mode = nil
            end

            if selected["Slow motion"] and menu.aa.slowmotion and refs.aa.fl and refs.aa.fl.sw then
                local slow_active = menu.aa.slowmotion:get()
                if refs.aa.fl.sw[1] then
                    refs.aa.fl.sw[1]:override(slow_active)
                end
            end

            if selected["Edge yaw"] and menu.aa.edgeyaw and refs.aa.edge_yaw then
                local edge_active = menu.aa.edgeyaw:get()
                refs.aa.edge_yaw:override(edge_active)
            end
        end,
shiny_calculate_auto_yaw = function(self)
    local shiny = self.shiny
    local now = globals.realtime()
    local tick = globals.tickcount()
    
    
    if now - (shiny.auto_values.last_calculation or 0) < 0.016 then
        return shiny.auto_values.yaw_left, shiny.auto_values.yaw_right
    end
    
    local me = entity.get_local_player()
    if not me then return -21, 46 end
    
    local threat = shiny.threat or {}
    local learning = shiny.learning or {}
    local enemies = shiny.enemies or {}
    
    
    
    
    local BASE_LEFT = -21
    local BASE_RIGHT = 46
    local BASE_VARIANCE = 2  
    
    
    
    
    local threat_level = threat.level or 0
    local imminent = threat.imminent_danger or false
    local aim_locked = threat.aim_locked_count or 0
    
    local danger_score = threat_level * 0.4
    if imminent then danger_score = danger_score + 0.35 end
    if aim_locked >= 1 then danger_score = danger_score + aim_locked * 0.1 end
    danger_score = math.min(1.0, danger_score)
    
    
    
    
    shiny.auto_values.side_state = shiny.auto_values.side_state or {
        current_side = 0,  
        last_switch = 0,
        switch_count = 0,
        consecutive_hits = 0,
        last_hit_side = -1,
        extrapolating = false,
        extrap_start = 0,
        extrap_duration = 0,
        next_switch_time = 0,
        switch_pattern = {},  
    }
    
    local state = shiny.auto_values.side_state
    
    
    local recent_hits = learning.recent_hits or {}
    local hits_on_current_side = 0
    local total_recent_hits = 0
    
    for i = #recent_hits, math.max(1, #recent_hits - 8), -1 do
        local hit = recent_hits[i]
        if hit and now - hit.time < 10 then
            total_recent_hits = total_recent_hits + 1
            if hit.side == state.current_side then
                hits_on_current_side = hits_on_current_side + 1
            end
        end
    end
    
    
    if total_recent_hits > 0 then
        local last_hit = recent_hits[#recent_hits]
        if last_hit and last_hit.side == state.current_side then
            if now - (state.last_hit_time or 0) < 3 then
                state.consecutive_hits = (state.consecutive_hits or 0) + 1
            else
                state.consecutive_hits = 1
            end
            state.last_hit_time = now
            state.last_hit_side = last_hit.side
        end
    end
    
    
    
    
    local should_switch = false
    local time_since_switch = now - state.last_switch
    
    
    local base_interval = 1.2
    if #state.switch_pattern < 10 then
        
        base_interval = 0.8 + math.random() * 1.7
    else
        
        local golden = 1.618033988749895
        local phase = (now * golden) % 1
        base_interval = 0.8 + phase * 1.7
    end
    
    
    if hits_on_current_side >= 2 and time_since_switch > 0.3 then
        should_switch = true
    elseif state.consecutive_hits >= 2 and time_since_switch > 0.25 then
        should_switch = true
    end
    
    
    if not should_switch and time_since_switch >= base_interval then
        
        local switch_prob = 0.4 + danger_score * 0.3
        local hash = bit.bxor(tick, bit.lshift(tick, 5))
        local roll = (hash % 1000) / 1000
        
        if roll < switch_prob then
            should_switch = true
        end
    end
    
    
    if time_since_switch > 3.5 then
        should_switch = true
    end
    
    
    if should_switch and not state.extrapolating then
        state.current_side = 1 - state.current_side
        state.last_switch = now
        state.switch_count = state.switch_count + 1
        state.consecutive_hits = 0
        
        
        table.insert(state.switch_pattern, time_since_switch)
        if #state.switch_pattern > 20 then
            table.remove(state.switch_pattern, 1)
        end
    end
    
    
    
    
    
    
    local should_extrap = false
    local extrap_variance = 0
    
    if not state.extrapolating then
        
        
        
        
        
        local extrap_chance = 0
        
        
        if state.consecutive_hits >= 1 and now - (state.last_hit_time or 0) < 0.5 then
            extrap_chance = 0.35 + state.consecutive_hits * 0.15
        end
        
        
        if danger_score > 0.6 then
            extrap_chance = math.max(extrap_chance, 0.15 + danger_score * 0.2)
        end
        
        
        local primary_id = threat.primary_threat and tostring(threat.primary_threat)
        if primary_id and enemies[primary_id] then
            local enemy_data = enemies[primary_id]
            local time_since_enemy_shot = now - (enemy_data.last_shot_time or 0)
            
            
            if time_since_enemy_shot > 0.3 and time_since_enemy_shot < 0.8 then
                extrap_chance = math.max(extrap_chance, 0.5)
            end
            
            
            local fire_rate = enemy_data.fire_rate or 0.5
            local time_to_next = fire_rate - time_since_enemy_shot
            if time_to_next > 0 and time_to_next < 0.2 then
                extrap_chance = math.max(extrap_chance, 0.6)
            end
        end
        
        
        local extrap_cooldown = 2.0 + math.random() * 1.5
        if now - (state.extrap_start or 0) > extrap_cooldown then
            local roll = math.random()
            if roll < extrap_chance then
                should_extrap = true
            end
        end
    end
    
    
    if should_extrap then
        state.extrapolating = true
        state.extrap_start = now
        
        
        state.extrap_duration = 0.15 + math.random() * 0.25
        
        
        
        if state.current_side == 0 then
            
            extrap_variance = -14 - math.random() * 20
        else
            
            extrap_variance = 9 + math.random() * 20
        end
        
        state.extrap_variance = extrap_variance
    end
    
    
    if state.extrapolating then
        if now - state.extrap_start > state.extrap_duration then
            state.extrapolating = false
            state.extrap_variance = 0
        else
            extrap_variance = state.extrap_variance or 0
        end
    end
    
    
    
    
    
    
    local left_micro = (math.sin(now * 7.3) + math.cos(tick / 5)) * (BASE_VARIANCE / 2)
    local right_micro = (math.cos(now * 5.7) + math.sin(tick / 7)) * (BASE_VARIANCE / 2)
    
    local yaw_left = BASE_LEFT + left_micro
    local yaw_right = BASE_RIGHT + right_micro
    
    
    if state.extrapolating then
        if state.current_side == 0 then
            yaw_left = yaw_left + extrap_variance
        else
            yaw_right = yaw_right + extrap_variance
        end
    end
    
    
    
    
    
    
    local golden = 1.618033988749895
    local anti_pred = math.sin(now * golden * 3.14159) * 1.5
    
    if not state.extrapolating then
        yaw_left = yaw_left + anti_pred * 0.5
        yaw_right = yaw_right - anti_pred * 0.5
    end
    
    
    
    
    
    
    
    
    if state.extrapolating then
        yaw_left = math.max(-60, math.min(-15, math.floor(yaw_left + 0.5)))
        yaw_right = math.max(40, math.min(80, math.floor(yaw_right + 0.5)))
    else
        yaw_left = math.max(-26, math.min(-16, math.floor(yaw_left + 0.5)))
        yaw_right = math.max(41, math.min(51, math.floor(yaw_right + 0.5)))
    end
    
    
    if yaw_left > 0 then yaw_left = -yaw_left end
    if yaw_right < 0 then yaw_right = -yaw_right end
    
    
    
    
    shiny.auto_values.yaw_left = yaw_left
    shiny.auto_values.yaw_right = yaw_right
    shiny.auto_values.last_calculation = now
    shiny.auto_values.danger_score = danger_score
    shiny.auto_values.is_extrapolating = state.extrapolating
    shiny.auto_values.current_side = state.current_side
    
    return yaw_left, yaw_right
end,



shiny_calculate_auto_body_yaw = function(self)
    local shiny = self.shiny
    local now = globals.realtime()
    local tick = globals.tickcount()
    
    local me = entity.get_local_player()
    if not me then return -1 end
    
    -- =========================================================================
    -- JITTER MODE: Oscillate between -1 and 0
    -- -1 = Opposite (body yaw opposite to fake direction)
    --  0 = Center (no body yaw offset)
    -- =========================================================================
    
    -- Initialize jitter state if needed
    shiny.auto_values.body_jitter_state = shiny.auto_values.body_jitter_state or {
        current = -1,
        last_switch = 0,
        switch_count = 0,
    }
    
    local state = shiny.auto_values.body_jitter_state
    local time_since_switch = now - state.last_switch
    
    -- Calculate switch interval (variable for unpredictability)
    -- Use golden ratio and tick-based modulation for non-repeating pattern
    local golden = 1.618033988749895
    local base_interval = 0.08  -- Base 80ms between switches
    
    -- Add variance: 60-120ms range
    local phase = math.sin(now * golden * 3.7) * math.cos(tick / 13.0)
    local interval_variance = 0.02 + math.abs(phase) * 0.02
    local switch_interval = base_interval + interval_variance
    
    -- Sometimes hold longer (150-200ms) for unpredictability
    if math.abs(math.sin(tick / 31.0)) > 0.85 then
        switch_interval = switch_interval + 0.05 + math.random() * 0.05
    end
    
    -- Switch between -1 and 0
    if time_since_switch >= switch_interval then
        -- Toggle between -1 and 0
        if state.current == -1 then
            state.current = 0
        else
            state.current = -1
        end
        
        state.last_switch = now
        state.switch_count = state.switch_count + 1
    end
    
    local body_yaw = state.current
    
    -- Store and return
    shiny.auto_values.body_yaw = body_yaw
    shiny.auto_values.last_body_yaw_reason = {
        mode = "jitter",
        current_state = body_yaw,
        switch_count = state.switch_count,
        interval = switch_interval,
    }
    
    return body_yaw
end,




shiny_calculate_auto_delay = function(self)
    local shiny = self.shiny
    local now = globals.realtime()
    local tick = globals.tickcount()
    
    local me = entity.get_local_player()
    if not me then return 2 end
    
    local threat = shiny.threat or {}
    local learning = shiny.learning or {}
    local sa = shiny.shot_analysis or {}
    local enemies = shiny.enemies or {}
    
    
    
    
    local last_enemy_shot_time = 0
    local enemy_avg_fire_rate = 0.15  
    local enemy_shot_count = 0
    
    
    for id, enemy_data in pairs(enemies) do
        if enemy_data.shots and #enemy_data.shots > 0 then
            local last_shot = enemy_data.shots[#enemy_data.shots]
            if last_shot and last_shot.time then
                if last_shot.time > last_enemy_shot_time then
                    last_enemy_shot_time = last_shot.time
                end
                enemy_shot_count = enemy_shot_count + 1
                
                
                if #enemy_data.shots >= 2 then
                    local recent_intervals = {}
                    for i = #enemy_data.shots, math.max(2, #enemy_data.shots - 5), -1 do
                        if enemy_data.shots[i] and enemy_data.shots[i-1] then
                            local interval = enemy_data.shots[i].time - enemy_data.shots[i-1].time
                            if interval > 0.05 and interval < 2.0 then
                                table.insert(recent_intervals, interval)
                            end
                        end
                    end
                    if #recent_intervals > 0 then
                        local sum = 0
                        for _, v in ipairs(recent_intervals) do sum = sum + v end
                        enemy_avg_fire_rate = sum / #recent_intervals
                    end
                end
            end
        end
    end
    
    local time_since_enemy_shot = now - last_enemy_shot_time
    
    
    
    
    local should_extrapolate = false
    local extrapolation_reason = "none"
    
    if last_enemy_shot_time > 0 and time_since_enemy_shot < 3.0 then
        local cycle_position = time_since_enemy_shot / enemy_avg_fire_rate
        local cycle_phase = cycle_position % 1.0
        
        
        if cycle_phase < 0.15 and time_since_enemy_shot < 0.12 then
            if math.random() < 0.35 then
                should_extrapolate = true
                extrapolation_reason = "post_shot_recovery"
            end
        end
        
        
        if cycle_phase > 0.85 and cycle_phase < 1.0 then
            if math.random() < 0.25 then
                should_extrapolate = true
                extrapolation_reason = "pre_shot_disrupt"
            end
        end
        
        
        if cycle_phase > 0.45 and cycle_phase < 0.55 then
            if math.random() < 0.15 then
                should_extrapolate = true
                extrapolation_reason = "mid_cycle_surprise"
            end
        end
        
        
        if cycle_position > 3.0 and math.random() < 0.20 then
            should_extrapolate = true
            extrapolation_reason = "pattern_break"
        end
    end
    
    
    
    
    local recent_hits = learning.recent_hits or {}
    local same_side_hits = learning.same_side_hits or 0
    local tp = sa.timing_patterns or {}
    local hit_streak = tp.hit_streak or 0
    
    local very_recent_hit = false
    local time_since_hit = 999
    for i = #recent_hits, math.max(1, #recent_hits - 2), -1 do
        if recent_hits[i] and recent_hits[i].time then
            local hit_age = now - recent_hits[i].time
            if hit_age < 0.5 then
                very_recent_hit = true
                time_since_hit = math.min(time_since_hit, hit_age)
            end
        end
    end
    
    if very_recent_hit then
        if time_since_hit < 0.15 and math.random() < 0.50 then
            should_extrapolate = true
            extrapolation_reason = "hit_response"
        end
    end
    
    if same_side_hits >= 2 and math.random() < 0.45 then
        should_extrapolate = true
        extrapolation_reason = "side_read"
    end
    
    if hit_streak >= 3 then
        should_extrapolate = true
        extrapolation_reason = "hit_streak_break"
    elseif hit_streak >= 2 and math.random() < 0.40 then
        should_extrapolate = true
        extrapolation_reason = "hit_streak_prevention"
    end
    
    
    
    
    
    local random_high_spike = false
    
    
    local golden = 1.618033988749895
    local spike_phase = math.sin(now * golden * 2.3) * math.cos(now * 1.7)
    
    
    if not should_extrapolate then
        local spike_roll = math.random()
        if spike_roll < 0.08 then
            random_high_spike = true
        elseif spike_roll < 0.12 and math.abs(spike_phase) > 0.7 then
            random_high_spike = true
        end
    end
    
    
    
    
    local base_delay
    
    if should_extrapolate then
        
        if extrapolation_reason == "post_shot_recovery" then
            base_delay = math.random(7, 10)
        elseif extrapolation_reason == "pre_shot_disrupt" then
            base_delay = math.random(7, 10)
        elseif extrapolation_reason == "mid_cycle_surprise" then
            base_delay = math.random(8, 10)
        elseif extrapolation_reason == "hit_response" then
            base_delay = math.random(7, 9)
        elseif extrapolation_reason == "side_read" or extrapolation_reason == "hit_streak_break" then
            base_delay = math.random(8, 10)
        elseif extrapolation_reason == "pattern_break" then
            base_delay = math.random(7, 10)
        else
            base_delay = math.random(7, 10)
        end
    elseif random_high_spike then
        
        local spike_weight = math.random()
        if spike_weight < 0.30 then
            base_delay = 7
        elseif spike_weight < 0.60 then
            base_delay = 8
        elseif spike_weight < 0.85 then
            base_delay = 9
        else
            base_delay = 10
        end
    else
        
        local weight = math.random()
        if weight < 0.15 then
            base_delay = 1  
        elseif weight < 0.40 then
            base_delay = 2  
        elseif weight < 0.65 then
            base_delay = 3  
        elseif weight < 0.85 then
            base_delay = 4  
        else
            base_delay = 5  
        end
    end
    
    
    
    
    local threat_level = threat.level or 0
    local imminent = threat.imminent_danger or false
    local aim_locked = threat.aim_locked_count or 0
    local danger_score = shiny.auto_values.danger_score or threat_level
    
    
    if not should_extrapolate and not random_high_spike then
        if imminent and math.random() < 0.20 then
            
            base_delay = math.random(7, 9)
        elseif danger_score > 0.8 and math.random() < 0.15 then
            base_delay = math.random(7, 10)
        elseif aim_locked >= 2 and math.random() < 0.25 then
            base_delay = math.random(7, 8)
        end
    end
    
    
    
    
    local miss_streak = tp.miss_streak or 0
    
    
    if miss_streak >= 4 and not should_extrapolate and not random_high_spike then
        if math.random() < 0.90 then
            base_delay = math.random(2, 4)  
        end
        
    end
    
    
    
    
    local last_delay = shiny.auto_values.delay or 3
    local last_was_high = last_delay >= 7
    
    
    if last_was_high and (should_extrapolate or random_high_spike) then
        if math.random() < 0.75 then
            
            base_delay = math.random(1, 5)
            should_extrapolate = false
            random_high_spike = false
        end
    end
    
    
    
    
    if base_delay <= 5 and not should_extrapolate and not random_high_spike then
        local phase = math.sin(now * golden * 1.9) * math.cos(tick / 31.0)
        
        if math.abs(phase) > 0.75 and math.random() < 0.20 then
            local adjustment = phase > 0 and 1 or -1
            base_delay = base_delay + adjustment
        end
    end
    
    
    
    
    
    
    if same_side_hits >= 5 then
        
        base_delay = math.random(8, 10)
    elseif danger_score > 0.95 then
        
        if math.random() < 0.5 then
            base_delay = math.random(1, 2)
        else
            base_delay = math.random(8, 10)
        end
    end
    
    
    base_delay = math.max(1, math.min(10, math.floor(base_delay + 0.5)))
    
    
    
    
    shiny.auto_values.delay = base_delay
    shiny.auto_values.last_delay_reason = {
        was_extrapolation = should_extrapolate,
        was_random_spike = random_high_spike,
        extrapolation_reason = extrapolation_reason,
        time_since_enemy_shot = time_since_enemy_shot,
        enemy_fire_rate = enemy_avg_fire_rate,
        danger_score = danger_score,
        same_side_hits = same_side_hits,
        hit_streak = hit_streak,
        miss_streak = miss_streak,
        final = base_delay,
    }
    
    return base_delay
end,




shiny_calculate_auto_jitter = function(self)
    local shiny = self.shiny
    local threat = shiny.threat or {}
    local learning = shiny.learning or {}
    
    local threat_level = threat.level or 0
    
    
    
    local base_jitter = 0
    
    if threat_level > 0.6 then
        base_jitter = 8 + math.floor(threat_level * 12)  
    elseif threat_level > 0.3 then
        base_jitter = math.floor((threat_level - 0.3) * 25)  
    end
    
    
    
    local same_side_hits = learning.same_side_hits or 0
    if same_side_hits >= 2 then
        base_jitter = math.min(25, base_jitter + same_side_hits * 5)
    end
    
    
    local recent_hits = learning.recent_hits or {}
    local now = globals.realtime()
    local recent_headshots = 0
    
    for i = #recent_hits, math.max(1, #recent_hits - 3), -1 do
        if recent_hits[i] and recent_hits[i].headshot and now - recent_hits[i].time < 5 then
            recent_headshots = recent_headshots + 1
        end
    end
    
    if recent_headshots >= 2 then
        base_jitter = math.min(25, base_jitter + 10)
    end
    
    
    -- Jitter more on the side that got hit
    local hit_side = learning.last_hit_side
    if hit_side ~= nil and hit_side == self.state.side then
        base_jitter = base_jitter + 10
    end

    base_jitter = math.max(0, math.min(25, math.floor(base_jitter + 0.5)))

    shiny.auto_values.jitter_amount = base_jitter

    return base_jitter
end,

shiny_calculate_auto_pitch = function(self)
    local shiny = self.shiny
    local now = globals.realtime()
    local tick = globals.tickcount()
    
    local me = entity.get_local_player()
    if not me then return "Custom", 89 end
    
    local threat = shiny.threat or {}
    local learning = shiny.learning or {}
    local enemies = shiny.enemies or {}
    
    -- Initialize pitch state
    shiny.auto_values.pitch_state = shiny.auto_values.pitch_state or {
        mode = "Custom",
        current_value = 89,
        last_update = 0,
        last_major_change = 0,
    }
    
    local state = shiny.auto_values.pitch_state
    local danger_score = shiny.auto_values.danger_score or (threat.level or 0)
    
    -- =========================================================================
    -- PHASE 1: GATHER ALL ENEMY DATA
    -- =========================================================================
    local my_x, my_y, my_z = entity.get_prop(me, "m_vecOrigin")
    local my_head_x, my_head_y, my_head_z = entity.hitbox_position(me, 0)
    local my_eye_z = my_head_z or (my_z and my_z + 64) or 0
    local my_flags = entity.get_prop(me, "m_fFlags") or 0
    local my_ducking = (entity.get_prop(me, "m_flDuckAmount") or 0) > 0.5
    
    local analysis = {
        enemies = {},
        total_weight = 0,
        weighted_height = 0,
        weighted_distance = 0,
        weighted_angle = 0,
        min_distance = 9999,
        max_threat_height = 0,
        aiming_count = 0,
    }
    
    if my_x then
        local enemy_list = entity.get_players(true)
        
        for _, enemy in ipairs(enemy_list) do
            if entity.is_alive(enemy) then
                local ex, ey, ez = entity.get_prop(enemy, "m_vecOrigin")
                local enemy_head_x, enemy_head_y, enemy_head_z = entity.hitbox_position(enemy, 0)
                local enemy_eye_x, enemy_eye_y, enemy_eye_z = entity.hitbox_position(enemy, 0)
                
                if ex and enemy_head_z and enemy_eye_z then
                    local dx = ex - my_x
                    local dy = ey - my_y
                    local dz = enemy_eye_z - my_eye_z
                    local dist_2d = math.sqrt(dx * dx + dy * dy)
                    local dist_3d = math.sqrt(dx * dx + dy * dy + dz * dz)
                    
                    -- Calculate angle enemy needs to aim at our head
                    local vertical_angle = math.deg(math.atan2(dz, dist_2d))
                    
                    -- Check if enemy is aiming at us
                    local is_aiming = false
                    local enemy_data = enemies[tostring(enemy)]
                    if enemy_data and enemy_data.is_aiming_at_us then
                        is_aiming = true
                        analysis.aiming_count = analysis.aiming_count + 1
                    end
                    
                    -- Calculate threat weight
                    local dist_weight = 1.0 / (1.0 + dist_2d / 400)
                    local aim_weight = is_aiming and 3.0 or 1.0
                    local primary_weight = (enemy == threat.primary_threat) and 2.0 or 1.0
                    local total_weight = dist_weight * aim_weight * primary_weight
                    
                    -- Store enemy data
                    table.insert(analysis.enemies, {
                        player = enemy,
                        dist_2d = dist_2d,
                        dist_3d = dist_3d,
                        height_diff = dz,
                        vertical_angle = vertical_angle,
                        is_aiming = is_aiming,
                        weight = total_weight,
                    })
                    
                    -- Accumulate weighted values
                    analysis.total_weight = analysis.total_weight + total_weight
                    analysis.weighted_height = analysis.weighted_height + dz * total_weight
                    analysis.weighted_distance = analysis.weighted_distance + dist_2d * total_weight
                    analysis.weighted_angle = analysis.weighted_angle + vertical_angle * total_weight
                    
                    -- Track extremes
                    if dist_2d < analysis.min_distance then
                        analysis.min_distance = dist_2d
                        analysis.closest_enemy = enemy
                        analysis.closest_height = dz
                        analysis.closest_angle = vertical_angle
                    end
                    
                    if math.abs(dz) > math.abs(analysis.max_threat_height) and total_weight > 1.0 then
                        analysis.max_threat_height = dz
                    end
                end
            end
        end
    end
    
    -- Calculate averages
    if analysis.total_weight > 0 then
        analysis.avg_height = analysis.weighted_height / analysis.total_weight
        analysis.avg_distance = analysis.weighted_distance / analysis.total_weight
        analysis.avg_angle = analysis.weighted_angle / analysis.total_weight
    else
        analysis.avg_height = 0
        analysis.avg_distance = 1000
        analysis.avg_angle = 0
    end
    
    -- =========================================================================
    -- PHASE 2: CALCULATE OPTIMAL PITCH
    -- =========================================================================
    local optimal_pitch = 89  -- Default: down (safest general choice)
    local pitch_confidence = 0.5
    local pitch_reason = "default"
    
    local enemy_count = #analysis.enemies
    
    if enemy_count > 0 then
        -- Get key metrics
        local avg_height = analysis.avg_height
        local closest_height = analysis.closest_height or 0
        local closest_dist = analysis.min_distance
        local avg_angle = analysis.avg_angle
        
        -- =====================================================================
        -- RULE 1: Height-based pitch (most important factor)
        -- =====================================================================
        -- If enemies are significantly above us, pitch DOWN to hide head
        -- If enemies are significantly below us, pitch UP to hide head
        
        if avg_height > 72 then
            -- Enemies are well above us (e.g., on platform, window)
            optimal_pitch = 89  -- Full down
            pitch_confidence = 0.9
            pitch_reason = "enemies_above_high"
        elseif avg_height > 36 then
            -- Enemies moderately above
            optimal_pitch = 75 + math.random() * 14  -- 75-89
            pitch_confidence = 0.8
            pitch_reason = "enemies_above_mid"
        elseif avg_height < -72 then
            -- Enemies are well below us
            optimal_pitch = -89  -- Full up
            pitch_confidence = 0.9
            pitch_reason = "enemies_below_high"
        elseif avg_height < -36 then
            -- Enemies moderately below
            optimal_pitch = -75 - math.random() * 14  -- -75 to -89
            pitch_confidence = 0.8
            pitch_reason = "enemies_below_mid"
        else
            -- Enemies roughly at same level
            -- Use the vertical angle they need to hit our head
            if math.abs(avg_angle) < 5 then
                -- They're aiming nearly horizontal - down pitch hides head best
                optimal_pitch = 89
                pitch_confidence = 0.7
                pitch_reason = "level_default_down"
            else
                -- Counter their aim angle
                optimal_pitch = avg_angle > 0 and 89 or -89
                pitch_confidence = 0.65
                pitch_reason = "counter_aim_angle"
            end
        end
        
        -- =====================================================================
        -- RULE 2: Distance-based adjustments
        -- =====================================================================
        if closest_dist < 200 then
            -- Very close range - extreme pitches are critical
            if closest_height > 20 then
                optimal_pitch = 89
                pitch_confidence = 0.95
                pitch_reason = "close_enemy_above"
            elseif closest_height < -20 then
                optimal_pitch = -89
                pitch_confidence = 0.95
                pitch_reason = "close_enemy_below"
            else
                -- Close and level - down pitch usually best for close quarters
                optimal_pitch = 89
                pitch_confidence = 0.85
                pitch_reason = "close_quarters"
            end
        elseif closest_dist < 500 then
            -- Medium range - maintain calculated pitch with slight variance
            local variance = (math.random() - 0.5) * 10
            optimal_pitch = optimal_pitch + variance
        end
        -- Long range: keep calculated pitch as-is
        
        -- =====================================================================
        -- RULE 3: Multi-threat handling
        -- =====================================================================
        if analysis.aiming_count >= 2 then
            -- Multiple enemies aiming at us - need to be unpredictable
            -- Add jitter to the optimal pitch
            local jitter = math.sin(now * 8.3 + tick / 5.0) * 15
            optimal_pitch = optimal_pitch + jitter
            pitch_reason = pitch_reason .. "_multi_threat"
        end
        
        -- =====================================================================
        -- RULE 4: Crouching adjustment
        -- =====================================================================
        if my_ducking then
            -- When crouched, our head is lower - adjust calculations
            -- Enemies need to aim lower to hit us, so maintain extreme pitches
            if optimal_pitch > 0 then
                optimal_pitch = math.max(optimal_pitch, 75)  -- Ensure strong down pitch
            else
                optimal_pitch = math.min(optimal_pitch, -75)  -- Ensure strong up pitch
            end
            pitch_reason = pitch_reason .. "_crouched"
        end
        
        -- =====================================================================
        -- RULE 5: Danger-based intensity
        -- =====================================================================
        if danger_score > 0.7 then
            -- High danger - use more extreme pitches
            if optimal_pitch > 0 then
                optimal_pitch = 70 + (optimal_pitch / 89) * 19  -- Scale to 70-89
            else
                optimal_pitch = -70 + (optimal_pitch / -89) * -19  -- Scale to -70 to -89
            end
            pitch_reason = pitch_reason .. "_high_danger"
        end
    else
        -- No enemies visible - safe default
        optimal_pitch = 89
        pitch_reason = "no_enemies"
    end
    
    -- =========================================================================
    -- PHASE 3: ANTI-PREDICTION VARIANCE
    -- =========================================================================
    local golden = 1.618033988749895
    
    -- Small continuous variance (doesn't change the overall direction)
    local micro_variance = math.sin(now * golden * 4.7) * 3
    optimal_pitch = optimal_pitch + micro_variance
    
    -- Occasional direction flip for unpredictability (rare, only when safe)
    if enemy_count > 0 and pitch_confidence < 0.8 then
        local flip_phase = math.sin(now * golden * 0.3 + tick / 127.0)
        if math.abs(flip_phase) > 0.97 and math.random() < 0.1 then
            -- Quick flip to opposite
            optimal_pitch = -optimal_pitch * 0.9
            pitch_reason = pitch_reason .. "_flip"
        end
    end
    
    -- =========================================================================
    -- PHASE 4: SMOOTH TRANSITIONS (prevent jarring changes)
    -- =========================================================================
    local last_pitch = state.current_value or optimal_pitch
    local pitch_diff = math.abs(optimal_pitch - last_pitch)
    
    -- If major change needed, allow it but track timing
    if pitch_diff > 60 then
        -- Large change - only allow if enough time passed
        if now - state.last_major_change > 0.15 then
            state.last_major_change = now
            -- Allow the change
        else
            -- Smooth toward target
            local direction = optimal_pitch > last_pitch and 1 or -1
            optimal_pitch = last_pitch + direction * 30
        end
    elseif pitch_diff > 20 then
        -- Medium change - slight smoothing
        optimal_pitch = last_pitch + (optimal_pitch - last_pitch) * 0.7
    end
    
    -- =========================================================================
    -- PHASE 5: FINAL CLAMP AND OUTPUT
    -- =========================================================================
    optimal_pitch = math.floor(optimal_pitch + 0.5)
    optimal_pitch = math.max(-89, math.min(89, optimal_pitch))
    
    state.current_value = optimal_pitch
    state.last_update = now
    
    local pitch_mode = "Custom"
    
    shiny.auto_values.pitch_mode = pitch_mode
    shiny.auto_values.pitch_value = optimal_pitch
    shiny.auto_values.last_pitch_reason = {
        mode = pitch_mode,
        value = optimal_pitch,
        reason = pitch_reason,
        confidence = pitch_confidence,
        enemy_count = enemy_count,
        avg_height = analysis.avg_height,
        avg_angle = analysis.avg_angle,
        closest_dist = analysis.min_distance,
        aiming_count = analysis.aiming_count,
        danger_score = danger_score,
    }
    
    return pitch_mode, optimal_pitch
end,

shiny_calculate_auto_spin = function(self)
    local shiny = self.shiny
    local now = globals.realtime()
    local tick = globals.tickcount()
    
    local me = entity.get_local_player()
    if not me then return false, 0 end
    
    local threat = shiny.threat or {}
    local learning = shiny.learning or {}
    local sa = shiny.shot_analysis or {}
    
    -- Initialize spin state
    shiny.auto_values.spin_state = shiny.auto_values.spin_state or {
        active = false,
        last_spin_start = 0,
        last_spin_end = 0,
        spin_count = 0,
        current_speed = 70,
        spin_duration = 0,
        last_direction = 1,
        burst_mode = false,
    }
    
    local state = shiny.auto_values.spin_state
    local danger_score = shiny.auto_values.danger_score or (threat.level or 0)
    
    -- =========================================================================
    -- PHASE 1: DETERMINE IF WE SHOULD SPIN
    -- =========================================================================
    local should_spin = false
    local spin_reason = "none"
    
    -- Check if currently spinning
    if state.active then
        -- Check if spin duration has ended
        if now > state.last_spin_start + state.spin_duration then
            state.active = false
            state.last_spin_end = now
            state.last_direction = -state.last_direction -- Alternate direction
        else
            -- Continue spinning
            should_spin = true
            spin_reason = "continuing"
        end
    end
    
    -- MUCH shorter cooldown for more frequent spins
    local base_cooldown = 2.0  -- Base 2 second cooldown
    local cooldown_variance = math.random() * 2.0  -- 0-2 second variance
    local spin_cooldown = base_cooldown + cooldown_variance  -- 2-4 second cooldown
    
    -- Reduce cooldown if under pressure
    if danger_score > 0.5 then
        spin_cooldown = spin_cooldown * (1.0 - danger_score * 0.4)  -- Up to 40% faster
    end
    
    if not state.active and now - state.last_spin_end > spin_cooldown then
        
        -- Trigger conditions for spin (AGGRESSIVE):
        local spin_chance = 0.05  -- Base 5% chance always
        
        -- 1. Hit streak - LOWERED THRESHOLDS
        local tp = sa.timing_patterns or {}
        local hit_streak = tp.hit_streak or 0
        if hit_streak >= 2 then
            spin_chance = spin_chance + 0.60  -- 60% on 2+ hits
            spin_reason = "hit_streak_escape"
        elseif hit_streak >= 1 then
            spin_chance = spin_chance + 0.30  -- 30% on single hit
            spin_reason = "hit_prevention"
        end
        
        -- 2. Same side hits - LOWERED THRESHOLD
        local same_side_hits = learning.same_side_hits or 0
        if same_side_hits >= 2 then
            spin_chance = spin_chance + 0.50  -- 50% on 2+ same side
            spin_reason = "same_side_evasion"
        elseif same_side_hits >= 1 then
            spin_chance = spin_chance + 0.25  -- 25% on single same side
            spin_reason = "same_side_detected"
        end
        
        -- 3. High danger - LOWERED THRESHOLD
        local aim_locked = threat.aim_locked_count or 0
        if aim_locked >= 1 then
            spin_chance = spin_chance + 0.20 + (aim_locked * 0.15)  -- 35%+ per aimer
            spin_reason = "threat_evasion"
        end
        
        -- 4. Danger score based
        if danger_score > 0.7 then
            spin_chance = spin_chance + 0.35
            spin_reason = "high_danger"
        elseif danger_score > 0.4 then
            spin_chance = spin_chance + 0.15
            if spin_reason == "none" then spin_reason = "medium_danger" end
        end
        
        -- 5. Random periodic spin (golden ratio timing for unpredictability)
        local golden = 1.618033988749895
        local random_phase = math.sin(now * golden * 0.5) * math.cos(tick / 67.0)
        if math.abs(random_phase) > 0.75 then
            spin_chance = spin_chance + 0.20
            if spin_reason == "none" then spin_reason = "periodic_chaos" end
        end
        
        -- 6. Recent damage taken
        local recent_hits = learning.recent_hits or {}
        local recent_damage_count = 0
        local recent_headshots = 0
        for i = #recent_hits, math.max(1, #recent_hits - 5), -1 do
            if recent_hits[i] and now - recent_hits[i].time < 5 then
                recent_damage_count = recent_damage_count + 1
                if recent_hits[i].headshot then
                    recent_headshots = recent_headshots + 1
                end
            end
        end
        
        if recent_headshots >= 1 then
            spin_chance = spin_chance + 0.45  -- 45% on any headshot
            spin_reason = "headshot_evasion"
        elseif recent_damage_count >= 2 then
            spin_chance = spin_chance + 0.30  -- 30% on 2+ hits
            spin_reason = "damage_evasion"
        elseif recent_damage_count >= 1 then
            spin_chance = spin_chance + 0.15  -- 15% on any damage
            if spin_reason == "none" then spin_reason = "hit_response" end
        end
        
        -- 7. Time-based guaranteed spin (every 8-15 seconds if nothing else triggers)
        if now - state.last_spin_end > 8.0 + math.random() * 7.0 then
            spin_chance = spin_chance + 0.80  -- 80% chance for periodic spin
            if spin_reason == "none" then spin_reason = "timed_rotation" end
        end
        
        -- Cap at 95% to maintain some unpredictability
        spin_chance = math.min(0.95, spin_chance)
        
        -- Roll for spin
        if math.random() < spin_chance then
            should_spin = true
            state.active = true
            state.last_spin_start = now
            state.spin_count = state.spin_count + 1
            state.spin_duration = 0  -- Reset for new calculation
        end
    end
    
    -- =========================================================================
    -- PHASE 2: CALCULATE SPIN SPEED (when spinning)
    -- =========================================================================
    local spin_speed = 70  -- Default in preferred range
    
    if should_spin then
        -- Base speed in preferred range (60-80)
        local base_speed = 65 + math.random() * 15  -- 65-80 range
        
        -- Danger score adjustments
        base_speed = base_speed + (danger_score * 10)  -- Up to +10 based on danger
        
        -- Hit streak = faster spin
        local tp = sa.timing_patterns or {}
        local hit_streak = tp.hit_streak or 0
        if hit_streak >= 2 then
            base_speed = base_speed + math.min(15, hit_streak * 4)
        end
        
        -- Multiple threats = faster
        local aim_locked = threat.aim_locked_count or 0
        if aim_locked >= 1 then
            base_speed = base_speed + math.min(12, aim_locked * 5)
        end
        
        -- Headshot evasion = burst speed
        if spin_reason == "headshot_evasion" then
            base_speed = base_speed + 10
            state.burst_mode = true
        end
        
        -- Add micro-variance for unpredictability
        local speed_variance = math.sin(now * 4.2 + tick / 9.0) * 5
        spin_speed = base_speed + speed_variance
        
        -- Burst mode - occasional high speed
        if state.burst_mode or math.random() < 0.20 then
            spin_speed = spin_speed + math.random(5, 12)
            state.burst_mode = false
        end
        
        -- Direction (positive or negative speed for spin direction)
        spin_speed = spin_speed * state.last_direction
        
        -- Clamp to valid range (absolute value)
        local abs_speed = math.abs(spin_speed)
        abs_speed = math.max(55, math.min(100, math.floor(abs_speed + 0.5)))
        spin_speed = abs_speed * (spin_speed > 0 and 1 or -1)
        
        state.current_speed = spin_speed
        
        -- Calculate spin duration based on reason
        if state.spin_duration == 0 or spin_reason ~= "continuing" then
            if spin_reason == "hit_streak_escape" or spin_reason == "headshot_evasion" then
                state.spin_duration = 0.8 + math.random() * 1.2  -- 0.8-2.0s (longer)
            elseif spin_reason == "same_side_evasion" or spin_reason == "damage_evasion" then
                state.spin_duration = 0.7 + math.random() * 1.0  -- 0.7-1.7s
            elseif spin_reason == "threat_evasion" or spin_reason == "high_danger" then
                state.spin_duration = 0.6 + math.random() * 1.2  -- 0.6-1.8s
            elseif spin_reason == "timed_rotation" then
                state.spin_duration = 0.5 + math.random() * 0.8  -- 0.5-1.3s
            elseif spin_reason == "periodic_chaos" then
                state.spin_duration = 0.4 + math.random() * 0.7  -- 0.4-1.1s
            else
                state.spin_duration = 0.5 + math.random() * 1.0  -- 0.5-1.5s
            end
        end
    end
    
    -- =========================================================================
    -- PHASE 3: STORE & RETURN
    -- =========================================================================
    shiny.auto_values.should_spin = should_spin
    shiny.auto_values.spin_speed = math.abs(spin_speed)  -- Always positive for the AA
    shiny.auto_values.last_spin_reason = {
        active = should_spin,
        reason = spin_reason,
        speed = math.abs(spin_speed),
        duration = state.spin_duration,
        spin_count = state.spin_count,
        danger_score = danger_score,
        direction = state.last_direction,
    }
    
    return should_spin, math.abs(spin_speed)
end,

shiny_calculate_auto_random = function(self)
    local shiny = self.shiny
    local now = globals.realtime()
    local tick = globals.tickcount()
    
    local me = entity.get_local_player()
    if not me then return 15, 15 end
    
    local threat = shiny.threat or {}
    local learning = shiny.learning or {}
    local sa = shiny.shot_analysis or {}
    
    -- Initialize random state
    shiny.auto_values.random_state = shiny.auto_values.random_state or {
        left_random = 15,
        right_random = 15,
        last_update = 0,
        intensity_phase = 0,
        burst_active = false,
        burst_end_time = 0,
    }
    
    local state = shiny.auto_values.random_state
    local danger_score = shiny.auto_values.danger_score or (threat.level or 0)
    
    -- =========================================================================
    -- PHASE 1: BASE RANDOMIZATION (10-25% range normally)
    -- =========================================================================
    local golden = 1.618033988749895
    
    -- Smooth oscillating base using golden ratio for non-repeating pattern
    local base_phase = math.sin(now * golden * 0.8) * math.cos(tick / 47.0)
    local base_left = 12 + math.abs(base_phase) * 13  -- 12-25%
    local base_right = 12 + math.abs(math.cos(now * golden * 0.6)) * 13  -- 12-25%
    
    -- Slight asymmetry for unpredictability
    local asymmetry = math.sin(now * 1.3 + tick / 23.0) * 5
    base_left = base_left + asymmetry
    base_right = base_right - asymmetry
    
    -- =========================================================================
    -- PHASE 2: THREAT-BASED ADJUSTMENTS
    -- =========================================================================
    local aim_locked = threat.aim_locked_count or 0
    local imminent = threat.imminent_danger or false
    
    -- Increase randomization under threat
    if danger_score > 0.7 then
        -- High danger: increase randomization significantly
        local threat_boost = (danger_score - 0.7) * 50  -- Up to +15%
        base_left = base_left + threat_boost
        base_right = base_right + threat_boost
    elseif danger_score > 0.4 then
        -- Medium danger: moderate increase
        local threat_boost = (danger_score - 0.4) * 25  -- Up to +7.5%
        base_left = base_left + threat_boost
        base_right = base_right + threat_boost
    end
    
    -- Multiple aimers = more randomization
    if aim_locked >= 2 then
        base_left = base_left + aim_locked * 5
        base_right = base_right + aim_locked * 5
    end
    
    -- Imminent danger = spike randomization
    if imminent then
        base_left = base_left + 15
        base_right = base_right + 15
    end
    
    -- =========================================================================
    -- PHASE 3: HIT RESPONSE
    -- =========================================================================
    local tp = sa.timing_patterns or {}
    local hit_streak = tp.hit_streak or 0
    local same_side_hits = learning.same_side_hits or 0
    
    -- Recent hits increase randomization
    if hit_streak >= 2 then
        base_left = base_left + hit_streak * 8
        base_right = base_right + hit_streak * 8
    elseif hit_streak >= 1 then
        base_left = base_left + 10
        base_right = base_right + 10
    end
    
    -- Same side hits = heavily randomize that side
    if same_side_hits >= 2 then
        local current_side = self.state.side
        if current_side == 0 then
            base_left = base_left + same_side_hits * 10
        else
            base_right = base_right + same_side_hits * 10
        end
    end
    
    -- =========================================================================
    -- PHASE 4: BURST MODE (occasional high randomization)
    -- =========================================================================
    if not state.burst_active then
        -- Random chance to enter burst mode
        local burst_chance = 0.02 + danger_score * 0.05  -- 2-7% per tick
        if math.random() < burst_chance then
            state.burst_active = true
            state.burst_end_time = now + 0.3 + math.random() * 0.5  -- 0.3-0.8s burst
        end
    end
    
    if state.burst_active then
        if now > state.burst_end_time then
            state.burst_active = false
        else
            -- Burst: high randomization
            base_left = base_left + 20 + math.random() * 15
            base_right = base_right + 20 + math.random() * 15
        end
    end
    
    -- =========================================================================
    -- PHASE 5: MICRO-VARIANCE (continuous small changes)
    -- =========================================================================
    local micro_left = math.sin(now * 5.7 + tick / 7.0) * 3
    local micro_right = math.cos(now * 4.3 + tick / 11.0) * 3
    
    base_left = base_left + micro_left
    base_right = base_right + micro_right
    
    -- =========================================================================
    -- PHASE 6: FINAL CLAMP AND SMOOTH
    -- =========================================================================
    -- Smooth transition from previous values
    local smooth_factor = 0.3
    local prev_left = state.left_random or base_left
    local prev_right = state.right_random or base_right
    
    base_left = prev_left + (base_left - prev_left) * smooth_factor
    base_right = prev_right + (base_right - prev_right) * smooth_factor
    
    -- Clamp to valid range (5-60%)
    base_left = math.max(5, math.min(60, math.floor(base_left + 0.5)))
    base_right = math.max(5, math.min(60, math.floor(base_right + 0.5)))
    
    -- Store values
    state.left_random = base_left
    state.right_random = base_right
    state.last_update = now
    
    shiny.auto_values.left_random = base_left
    shiny.auto_values.right_random = base_right
    shiny.auto_values.last_random_reason = {
        left = base_left,
        right = base_right,
        danger_score = danger_score,
        hit_streak = hit_streak,
        burst_active = state.burst_active,
    }
    
    return base_left, base_right
end,

shiny_calculate_auto_desync = function(self)
    local shiny = self.shiny
    local now = globals.realtime()
    local me = entity.get_local_player()
    if not me then return 0 end
    
    local threat = shiny.threat or {}
    local learning = shiny.learning or {}
    
    -- Initialize desync state
    shiny.auto_values.desync_state = shiny.auto_values.desync_state or {
        current_desync = 0,
        target_desync = 0,
        last_update = 0,
        mode = "max", -- "max", "min", "micro", "jitter"
    }
    
    local state = shiny.auto_values.desync_state
    local danger_score = shiny.auto_values.danger_score or 0
    
    -- Determine desync mode based on situation
    local aim_locked = threat.aim_locked_count or 0
    local hit_streak = (shiny.shot_analysis.timing_patterns or {}).hit_streak or 0
    local same_side = learning.same_side_hits or 0
    
    local desync_mode = "max"
    local target = 58  -- Default max desync
    
    -- If getting hit frequently, use micro desync (harder to resolve)
    if hit_streak >= 2 or same_side >= 2 then
        desync_mode = "micro"
        target = 20 + math.random() * 20  -- 20-40 range
    -- High danger with aimers = jitter desync
    elseif aim_locked >= 2 and danger_score > 0.6 then
        desync_mode = "jitter"
        target = 30 + math.sin(now * 8) * 28  -- Oscillate 2-58
    -- Medium danger = varied desync
    elseif danger_score > 0.4 then
        desync_mode = "varied"
        target = 40 + math.sin(now * 2.5) * 18  -- 22-58
    -- Low danger = max desync
    else
        desync_mode = "max"
        target = 55 + math.random() * 3  -- 55-58
    end
    
    -- Smooth transition
    local smooth = 0.15
    state.current_desync = state.current_desync + (target - state.current_desync) * smooth
    state.target_desync = target
    state.mode = desync_mode
    state.last_update = now
    
    return math.floor(state.current_desync + 0.5)
end,

shiny_calculate_auto_roll = function(self)
    local shiny = self.shiny
    local now = globals.realtime()
    local tick = globals.tickcount()
    local me = entity.get_local_player()
    if not me then return 0 end
    
    local threat = shiny.threat or {}
    local danger_score = shiny.auto_values.danger_score or 0
    
    -- Only use roll under significant threat
    if danger_score < 0.5 then return 0 end
    
    -- Initialize roll state
    shiny.auto_values.roll_state = shiny.auto_values.roll_state or {
        current_roll = 0,
        direction = 1,
        last_switch = 0,
    }
    
    local state = shiny.auto_values.roll_state
    
    -- Calculate roll based on enemy positions
    local primary = threat.primary_threat
    if not primary then return 0 end
    
    local my_x, my_y = entity.get_prop(me, "m_vecOrigin")
    local enemy_x, enemy_y = entity.get_prop(primary, "m_vecOrigin")
    if not my_x or not enemy_x then return 0 end
    
    -- Calculate angle to enemy
    local angle = math.deg(math.atan2(enemy_y - my_y, enemy_x - my_x))
    local _, my_yaw = client.camera_angles()
    local rel_angle = ((angle - my_yaw + 180) % 360) - 180
    
    -- Roll away from enemy's side
    local base_roll = 0
    if rel_angle > 20 then
        base_roll = -45  -- Roll left if enemy on right
    elseif rel_angle < -20 then
        base_roll = 45   -- Roll right if enemy on left
    else
        -- Enemy in front - jitter roll
        base_roll = math.sin(now * 6) * 45
    end
    
    -- Scale by danger
    base_roll = base_roll * danger_score
    
    -- Add micro variance
    base_roll = base_roll + math.sin(now * 12 + tick / 5) * 5
    
    -- Clamp
    return math.max(-50, math.min(50, math.floor(base_roll + 0.5)))
end,

shiny_calculate_auto_freestand = function(self)
    local me = entity.get_local_player()
    if not me then return nil end
    
    local my_x, my_y, my_z = entity.get_prop(me, "m_vecOrigin")
    local my_eye_x, my_eye_y, my_eye_z = client.eye_position()
    if not my_x then return nil end
    
    local _, my_yaw = client.camera_angles()
    
    -- Check walls on left and right
    local check_dist = 40
    local left_yaw = math.rad(my_yaw + 90)
    local right_yaw = math.rad(my_yaw - 90)
    
    local left_x = my_eye_x + math.cos(left_yaw) * check_dist
    local left_y = my_eye_y + math.sin(left_yaw) * check_dist
    
    local right_x = my_eye_x + math.cos(right_yaw) * check_dist
    local right_y = my_eye_y + math.sin(right_yaw) * check_dist
    
    -- Trace to check for walls
    local left_frac = client.trace_line(1, my_eye_x, my_eye_y, my_eye_z, left_x, left_y, my_eye_z)
    local right_frac = client.trace_line(1, my_eye_x, my_eye_y, my_eye_z, right_x, right_y, my_eye_z)
    
    -- If wall on one side, face that direction (hide head behind cover)
    if left_frac < 0.9 and right_frac > 0.9 then
        return 0  -- Wall on left, use left side
    elseif right_frac < 0.9 and left_frac > 0.9 then
        return 1  -- Wall on right, use right side
    end
    
    return nil  -- No clear freestand direction
end,

shiny_predict_enemy_shot = function(self, enemy_id)
    local shiny = self.shiny
    local now = globals.realtime()
    local enemy_data = shiny.enemies[enemy_id]
    if not enemy_data then return false, 0 end
    
    local last_shot = enemy_data.last_shot_time or 0
    local fire_rate = enemy_data.fire_rate or 0.15
    local time_since = now - last_shot
    
    -- Predict next shot time
    local predicted_next = last_shot + fire_rate
    local time_until_shot = predicted_next - now
    
    -- If shot is imminent (within 50-100ms), switch preemptively
    if time_until_shot > 0 and time_until_shot < 0.1 then
        return true, time_until_shot
    end
    
    return false, time_until_shot
end,

shiny_on_death = function(self)
    local shiny = self.shiny
    local learning = shiny.learning
    
    -- Partial reset - keep some data but clear patterns
    learning.same_side_hits = math.floor(learning.same_side_hits * 0.3)
    
    -- Clear recent hits (they've figured us out)
    while #learning.recent_hits > 2 do
        table.remove(learning.recent_hits, 1)
    end
    
    -- Randomize starting side for next life
    self.state.side = math.random(0, 1)
    
    -- Reset extrapolation state
    if shiny.auto_values.side_state then
        shiny.auto_values.side_state.extrapolating = false
        shiny.auto_values.side_state.consecutive_hits = 0
    end
end,

shiny_calculate_onshot_yaw = function(self)
    local shiny = self.shiny
    local threat = shiny.threat or {}
    
    -- If primary threat exists, face away from them on shot
    if threat.primary_threat then
        local direction = threat.threat_direction or 0
        -- Opposite direction from threat
        return direction + 180
    end
    
    -- Default: opposite of current yaw
    local current = self.state.side == 0 
        and shiny.auto_values.yaw_left 
        or shiny.auto_values.yaw_right
    
    return -current
end,

shiny_get_auto_values = function(self)
    local yaw_left, yaw_right = self:shiny_calculate_auto_yaw()
    local body_yaw = self:shiny_calculate_auto_body_yaw()
    local delay = self:shiny_calculate_auto_delay()
    local jitter = self:shiny_calculate_auto_jitter()
    local pitch_mode, pitch_value = "Down", 89  -- pitch controller removed: always Down (shiny_calculate_auto_pitch now dead)
    local should_spin, spin_speed = self:shiny_calculate_auto_spin()
    local left_random, right_random = self:shiny_calculate_auto_random()
    
    return {
        yaw_left = yaw_left,
        yaw_right = yaw_right,
        body_yaw_amount = body_yaw,
        delay_value = delay,
        jitter_amount = jitter,
        jitter_mode = jitter > 0 and "Offset" or "Off",
        pitch_mode = pitch_mode,
        pitch_value = pitch_value,
        should_spin = should_spin,
        spin_speed = spin_speed,
        left_random = left_random,
        right_random = right_random,
    }
end,

shiny_record_shot_analysis = function(self, attacker, hit_us, hitgroup, distance, weapon_id)
    local shiny = self.shiny
    local now = globals.realtime()
    local sa = shiny.shot_analysis
    
    
    local current_yaw = shiny.auto_values.yaw_left
    if self.state.side == 1 then
        current_yaw = shiny.auto_values.yaw_right
    end
    local current_body_yaw = shiny.auto_values.body_yaw or 60
    local current_side = self.state.side
    
    
    table.insert(sa.recent_shots, {
        time = now,
        attacker = attacker,
        hit = hit_us,
        hitgroup = hitgroup or 0,
        our_yaw = current_yaw,
        our_body_yaw = current_body_yaw,
        our_side = current_side,
        distance = distance or 0,
        weapon_id = weapon_id or 0,
    })
    
    
    while #sa.recent_shots > sa.max_samples do
        table.remove(sa.recent_shots, 1)
    end
    
    
    local yaw_bucket = math.floor((current_yaw + 60) / 10) + 1  
    yaw_bucket = math.max(1, math.min(12, yaw_bucket))
    
    if not sa.yaw_buckets[yaw_bucket] then
        sa.yaw_buckets[yaw_bucket] = { hits = 0, misses = 0, headshots = 0 }
    end
    
    if hit_us then
        sa.yaw_buckets[yaw_bucket].hits = sa.yaw_buckets[yaw_bucket].hits + 1
        if hitgroup == 1 then
            sa.yaw_buckets[yaw_bucket].headshots = sa.yaw_buckets[yaw_bucket].headshots + 1
        end
    else
        sa.yaw_buckets[yaw_bucket].misses = sa.yaw_buckets[yaw_bucket].misses + 1
    end
    
    
    local body_bucket = math.floor(current_body_yaw / 5) * 5  
    if not sa.body_yaw_stats[body_bucket] then
        sa.body_yaw_stats[body_bucket] = { hits = 0, misses = 0 }
    end
    
    if hit_us then
        sa.body_yaw_stats[body_bucket].hits = sa.body_yaw_stats[body_bucket].hits + 1
    else
        sa.body_yaw_stats[body_bucket].misses = sa.body_yaw_stats[body_bucket].misses + 1
    end
    
    
    local tp = sa.timing_patterns
    if hit_us then
        table.insert(tp.last_hit_times, now)
        if #tp.last_hit_times > 20 then table.remove(tp.last_hit_times, 1) end
        
        tp.hit_streak = tp.hit_streak + 1
        tp.miss_streak = 0
        
        
        if #tp.last_hit_times >= 2 then
            local total_interval = 0
            for i = 2, #tp.last_hit_times do
                total_interval = total_interval + (tp.last_hit_times[i] - tp.last_hit_times[i-1])
            end
            tp.avg_hit_interval = total_interval / (#tp.last_hit_times - 1)
        end
    else
        table.insert(tp.last_miss_times, now)
        if #tp.last_miss_times > 20 then table.remove(tp.last_miss_times, 1) end
        
        tp.miss_streak = tp.miss_streak + 1
        tp.hit_streak = 0
    end
    
    
    if weapon_id and weapon_id > 0 then
        if not sa.weapon_stats[weapon_id] then
            sa.weapon_stats[weapon_id] = { hits = 0, misses = 0, headshots = 0 }
        end
        
        if hit_us then
            sa.weapon_stats[weapon_id].hits = sa.weapon_stats[weapon_id].hits + 1
            if hitgroup == 1 then
                sa.weapon_stats[weapon_id].headshots = sa.weapon_stats[weapon_id].headshots + 1
            end
        else
            sa.weapon_stats[weapon_id].misses = sa.weapon_stats[weapon_id].misses + 1
        end
    end

    sa.dirty = true
    
    
    self:shiny_save_shot_analysis(false)
end,


shiny_get_optimal_yaw_from_analysis = function(self)
    local sa = self.shiny.shot_analysis
    
    local best_left_bucket = nil
    local best_left_score = -999
    local best_right_bucket = nil
    local best_right_score = -999
    
    for bucket, stats in pairs(sa.yaw_buckets) do
        local total = stats.hits + stats.misses
        if total >= 3 then
            
            local miss_rate = stats.misses / total
            local hs_rate = stats.headshots / math.max(1, stats.hits)
            local score = miss_rate - (hs_rate * 0.5)
            
            
            local approx_yaw = (bucket - 1) * 10 - 60  
            
            if approx_yaw < 0 then
                if score > best_left_score then
                    best_left_score = score
                    best_left_bucket = bucket
                end
            else
                if score > best_right_score then
                    best_right_score = score
                    best_right_bucket = bucket
                end
            end
        end
    end
    
    
    local optimal_left = best_left_bucket and ((best_left_bucket - 1) * 10 - 55) or -35
    local optimal_right = best_right_bucket and ((best_right_bucket - 1) * 10 - 55) or 35
    
    return optimal_left, optimal_right, best_left_score, best_right_score
end,


shiny_get_optimal_body_yaw_from_analysis = function(self)
    local sa = self.shiny.shot_analysis
    
    local best_body_yaw = 60
    local best_score = -999
    
    for body_yaw, stats in pairs(sa.body_yaw_stats) do
        local total = stats.hits + stats.misses
        if total >= 3 then
            local miss_rate = stats.misses / total
            if miss_rate > best_score then
                best_score = miss_rate
                best_body_yaw = body_yaw
            end
        end
    end
    
    return best_body_yaw, best_score
end,






shiny_init_aim_tracking = function(self, enemy)
    local id = tostring(enemy)
    local at = self.shiny.aim_tracking
    
    if at.enemies[id] then return at.enemies[id] end
    
    at.enemies[id] = {
        aim_samples = {},
        avg_aim_offset = 0,
        aim_variance = 0,
        preferred_side = nil,
        reaction_time = 0.25,  
        last_aim_update = 0,
        shots_at_us = 0,
        hits_on_us = 0,
        headshots_on_us = 0,
        last_shot_yaw = 0,
        predicted_next_aim = 0,
        crosshair_tracking = {
            on_us_time = 0,
            total_time = 0,
            last_check = 0,
        },
    }
    
    return at.enemies[id]
end,


shiny_update_aim_tracking = function(self, enemy)
    local me = entity.get_local_player()
    if not me or not enemy then return end
    
    local now = globals.realtime()
    local at = self.shiny.aim_tracking
    local enemy_data = self:shiny_init_aim_tracking(enemy)
    
    
    if now - enemy_data.last_aim_update < 0.05 then return end
    enemy_data.last_aim_update = now
    
    
    local enemy_eye_x, enemy_eye_y, enemy_eye_z = entity.hitbox_position(enemy, 0)
    if not enemy_eye_x then return end
    
    local enemy_pitch, enemy_yaw = entity.get_prop(enemy, "m_angEyeAngles[0]"), entity.get_prop(enemy, "m_angEyeAngles[1]")
    if not enemy_yaw then return end
    
    
    local my_x, my_y, my_z = entity.get_prop(me, "m_vecOrigin")
    local head_x, head_y, head_z = entity.hitbox_position(me, 0)
    if not my_x or not head_x then return end
    
    
    local dx = head_x - enemy_eye_x
    local dy = head_y - enemy_eye_y
    local dz = head_z - enemy_eye_z
    
    local dist_2d = math.sqrt(dx * dx + dy * dy)
    local angle_to_us = math.deg(math.atan2(dy, dx))
    
    
    local aim_offset = ((enemy_yaw - angle_to_us + 180) % 360) - 180
    
    
    table.insert(enemy_data.aim_samples, {
        time = now,
        offset = aim_offset,
        distance = dist_2d,
        enemy_yaw = enemy_yaw,
    })
    
    
    while #enemy_data.aim_samples > 30 do
        table.remove(enemy_data.aim_samples, 1)
    end
    
    
    if #enemy_data.aim_samples >= 5 then
        local sum = 0
        local sum_sq = 0
        local left_count = 0
        local right_count = 0
        
        for _, sample in ipairs(enemy_data.aim_samples) do
            sum = sum + sample.offset
            sum_sq = sum_sq + sample.offset * sample.offset
            
            if sample.offset < -5 then
                left_count = left_count + 1
            elseif sample.offset > 5 then
                right_count = right_count + 1
            end
        end
        
        local n = #enemy_data.aim_samples
        enemy_data.avg_aim_offset = sum / n
        enemy_data.aim_variance = math.sqrt((sum_sq / n) - (enemy_data.avg_aim_offset * enemy_data.avg_aim_offset))
        
        
        if left_count > right_count * 1.5 then
            enemy_data.preferred_side = 0  
        elseif right_count > left_count * 1.5 then
            enemy_data.preferred_side = 1  
        else
            enemy_data.preferred_side = nil  
        end
        
        
        if n >= 3 then
            local recent_trend = enemy_data.aim_samples[n].offset - enemy_data.aim_samples[n-2].offset
            enemy_data.predicted_next_aim = enemy_data.aim_samples[n].offset + recent_trend * 0.5
        end
    end
    
    
    local ct = enemy_data.crosshair_tracking
    local time_delta = now - ct.last_check
    ct.last_check = now
    ct.total_time = ct.total_time + time_delta
    
    if math.abs(aim_offset) < 15 then
        ct.on_us_time = ct.on_us_time + time_delta
    end
    
    
    at.global_stats.total_shots_tracked = at.global_stats.total_shots_tracked + 1
end,


shiny_record_aim_tracking_shot = function(self, shooter, hit_us, hitgroup)
    local at = self.shiny.aim_tracking
    local now = globals.realtime()
    
    local enemy_data = at.enemies[tostring(shooter)]
    if not enemy_data then
        enemy_data = self:shiny_init_aim_tracking(shooter)
    end
    
    enemy_data.shots_at_us = enemy_data.shots_at_us + 1
    
    if hit_us then
        enemy_data.hits_on_us = enemy_data.hits_on_us + 1
        if hitgroup == 1 then
            enemy_data.headshots_on_us = enemy_data.headshots_on_us + 1
        end
    end
    
    
    local enemy_yaw = entity.get_prop(shooter, "m_angEyeAngles[1]")
    if enemy_yaw then
        enemy_data.last_shot_yaw = enemy_yaw
    end
    
    
    local my_x, my_y = entity.get_prop(entity.get_local_player(), "m_vecOrigin")
    local enemy_x, enemy_y = entity.get_prop(shooter, "m_vecOrigin")
    
    if my_x and enemy_x then
        local _, my_yaw = client.camera_angles()
        local angle_to_enemy = math.deg(math.atan2(enemy_y - my_y, enemy_x - my_x))
        local relative_angle = ((angle_to_enemy - my_yaw + 180) % 360) - 180
        
        local bucket = math.floor((relative_angle + 180) / 30) + 1  
        bucket = math.max(1, math.min(12, bucket))
        
        if not at.angle_heatmap[bucket] then
            at.angle_heatmap[bucket] = { times_targeted = 0, times_hit = 0 }
        end
        
        at.angle_heatmap[bucket].times_targeted = at.angle_heatmap[bucket].times_targeted + 1
        if hit_us then
            at.angle_heatmap[bucket].times_hit = at.angle_heatmap[bucket].times_hit + 1
        end
    end
    
    
    if enemy_data.preferred_side == 0 then
        at.global_stats.left_side_preference = at.global_stats.left_side_preference + 0.1
        at.global_stats.right_side_preference = at.global_stats.right_side_preference - 0.05
    elseif enemy_data.preferred_side == 1 then
        at.global_stats.right_side_preference = at.global_stats.right_side_preference + 0.1
        at.global_stats.left_side_preference = at.global_stats.left_side_preference - 0.05
    end
    
    
    at.global_stats.left_side_preference = math.max(-1, math.min(1, at.global_stats.left_side_preference))
    at.global_stats.right_side_preference = math.max(-1, math.min(1, at.global_stats.right_side_preference))

    at.dirty = true
    
    
    self:shiny_save_aim_tracking(false)

end,

shiny_load_shot_analysis = function(self)
    local sa = self.shiny.shot_analysis
    local keys = sa.db_keys
    
    
    local yaw_data = database.read(keys.yaw_buckets)
    if yaw_data and type(yaw_data) == "table" then
        sa.yaw_buckets = yaw_data
    end
    
    
    local body_data = database.read(keys.body_yaw_stats)
    if body_data and type(body_data) == "table" then
        sa.body_yaw_stats = body_data
    end
    
    
    local timing_data = database.read(keys.timing_patterns)
    if timing_data and type(timing_data) == "table" then
        sa.timing_patterns.avg_hit_interval = timing_data.avg_hit_interval or 0
    end
    
    
    local weapon_data = database.read(keys.weapon_stats)
    if weapon_data and type(weapon_data) == "table" then
        sa.weapon_stats = weapon_data
    end
    
end,


shiny_save_shot_analysis = function(self, force)
    local sa = self.shiny.shot_analysis
    local now = globals.realtime()
    
    
    if not force and (now - sa.last_save_time < sa.save_interval or not sa.dirty) then
        return
    end
    
    local keys = sa.db_keys
    
    
    database.write(keys.yaw_buckets, sa.yaw_buckets)
    
    
    database.write(keys.body_yaw_stats, sa.body_yaw_stats)
    
    
    database.write(keys.timing_patterns, {
        avg_hit_interval = sa.timing_patterns.avg_hit_interval,
    })
    
    
    database.write(keys.weapon_stats, sa.weapon_stats)
    
    
    database.write(keys.last_save, now)
    
    sa.last_save_time = now
    sa.dirty = false
end,


shiny_load_aim_tracking = function(self)
    local at = self.shiny.aim_tracking
    local keys = at.db_keys
    
    
    local global_data = database.read(keys.global_stats)
    if global_data and type(global_data) == "table" then
        at.global_stats.total_shots_tracked = global_data.total_shots_tracked or 0
        at.global_stats.left_side_preference = global_data.left_side_preference or 0
        at.global_stats.right_side_preference = global_data.right_side_preference or 0
        at.global_stats.avg_enemy_accuracy = global_data.avg_enemy_accuracy or 0.5
    end
    
    
    local heatmap_data = database.read(keys.angle_heatmap)
    if heatmap_data and type(heatmap_data) == "table" then
        at.angle_heatmap = heatmap_data
    end
    
end,


shiny_save_aim_tracking = function(self, force)
    local at = self.shiny.aim_tracking
    local now = globals.realtime()
    
    
    if not force and (now - at.last_save_time < at.save_interval or not at.dirty) then
        return
    end
    
    local keys = at.db_keys
    
    
    database.write(keys.global_stats, {
        total_shots_tracked = at.global_stats.total_shots_tracked,
        left_side_preference = at.global_stats.left_side_preference,
        right_side_preference = at.global_stats.right_side_preference,
        avg_enemy_accuracy = at.global_stats.avg_enemy_accuracy,
    })
    
    
    database.write(keys.angle_heatmap, at.angle_heatmap)
    
    
    database.write(keys.last_save, now)
    
    at.last_save_time = now
    at.dirty = false
end,


shiny_init_database = function(self)
    if self.shiny.db_initialized then return end
    
    self:shiny_load_shot_analysis()
    self:shiny_load_aim_tracking()
    
    self.shiny.db_initialized = true
end,


shiny_save_all = function(self, force)
    self:shiny_save_shot_analysis(force)
    self:shiny_save_aim_tracking(force)
end,


shiny_clear_database = function(self)
    local sa = self.shiny.shot_analysis
    local at = self.shiny.aim_tracking
    
    
    for key, value in pairs(sa.db_keys) do
        database.write(value, nil)
    end
    
    
    for key, value in pairs(at.db_keys) do
        database.write(value, nil)
    end
    
    
    sa.yaw_buckets = {}
    sa.body_yaw_stats = {}
    sa.weapon_stats = {}
    sa.timing_patterns = {
        last_hit_times = {},
        last_miss_times = {},
        avg_hit_interval = 0,
        hit_streak = 0,
        miss_streak = 0,
    }
    sa.recent_shots = {}
    
    at.global_stats = {
        total_shots_tracked = 0,
        left_side_preference = 0,
        right_side_preference = 0,
        avg_enemy_accuracy = 0.5,
    }
    at.angle_heatmap = {}
    at.enemies = {}
    
end,


shiny_get_aim_tracking_recommendation = function(self)
    local at = self.shiny.aim_tracking
    local gs = at.global_stats
    
    local recommendation = {
        preferred_side = nil,
        confidence = 0,
        avoid_angles = {},
        safe_angles = {},
    }
    
    
    if gs.left_side_preference > 0.3 then
        recommendation.preferred_side = 1  
        recommendation.confidence = gs.left_side_preference
    elseif gs.right_side_preference > 0.3 then
        recommendation.preferred_side = 0  
        recommendation.confidence = gs.right_side_preference
    end
    
    
    for bucket, stats in pairs(at.angle_heatmap) do
        if stats.times_targeted >= 3 then
            local hit_rate = stats.times_hit / stats.times_targeted
            local approx_angle = (bucket - 1) * 30 - 180 + 15  
            
            if hit_rate > 0.5 then
                table.insert(recommendation.avoid_angles, {
                    angle = approx_angle,
                    hit_rate = hit_rate,
                })
            elseif hit_rate < 0.25 then
                table.insert(recommendation.safe_angles, {
                    angle = approx_angle,
                    miss_rate = 1 - hit_rate,
                })
            end
        end
    end
    
    return recommendation
end,


shiny_reset_aim_tracking = function(self)
    local at = self.shiny.aim_tracking
    
    
    for id, enemy_data in pairs(at.enemies) do
        enemy_data.aim_samples = {}
        enemy_data.crosshair_tracking = {
            on_us_time = 0,
            total_time = 0,
            last_check = 0,
        }
        
        enemy_data.shots_at_us = math.floor(enemy_data.shots_at_us * 0.3)
        enemy_data.hits_on_us = math.floor(enemy_data.hits_on_us * 0.3)
        enemy_data.headshots_on_us = math.floor(enemy_data.headshots_on_us * 0.3)
    end
    
    
    at.global_stats.left_side_preference = at.global_stats.left_side_preference * 0.5
    at.global_stats.right_side_preference = at.global_stats.right_side_preference * 0.5
    
    
    at.angle_heatmap = {}
end,


shiny_reset_shot_analysis = function(self)
    local sa = self.shiny.shot_analysis
    
    
    local keep_count = math.min(30, #sa.recent_shots)
    while #sa.recent_shots > keep_count do
        table.remove(sa.recent_shots, 1)
    end
    
    
    for bucket, stats in pairs(sa.yaw_buckets) do
        stats.hits = math.floor(stats.hits * 0.4)
        stats.misses = math.floor(stats.misses * 0.4)
        stats.headshots = math.floor(stats.headshots * 0.4)
    end
    
    
    for body_yaw, stats in pairs(sa.body_yaw_stats) do
        stats.hits = math.floor(stats.hits * 0.4)
        stats.misses = math.floor(stats.misses * 0.4)
    end
    
    
    sa.timing_patterns.hit_streak = 0
    sa.timing_patterns.miss_streak = 0
end,


        complete = function(self, cmd, state)
            local data = {}
            
            
            -- Per-cheat profiles: mode table follows the detected threat bucket.
            local mode_table = (shinymoon_cheat_mode_table and shinymoon_cheat_mode_table())
                or menu.aa.builder.modes.normal
            local active_ref = mode_table[state] and mode_table[state].active
            
            if state ~= "Global" and active_ref and not active_ref:get() then
                state = "Global"
            end

            local state_data = mode_table[state]
            if not state_data then return end

            
            data.method = state_data.method and state_data.method:get() or "Normal"
                data.jitter_mode = state_data.jitter_mode and state_data.jitter_mode:get() or "Off"
                data.jitter_amount = state_data.jitter_amount and state_data.jitter_amount:get() or 0
                data.spin_from = state_data.spin_from and state_data.spin_from:get() or 0
                data.spin_to = state_data.spin_to and state_data.spin_to:get() or 0
                data.spin_speed = state_data.spin_speed and state_data.spin_speed:get() or 5
                data.spin_random = state_data.spin_random and state_data.spin_random:get() or 0        
            
            
            if data.method == "Shiny" then
                
                local me = entity.get_local_player()
                if me and entity.is_alive(me) then
                    self:shiny_analyze_threats(me)
                end
                
                
                local auto = self:shiny_get_auto_values()
                
                -- Check if spin mode is active
                if auto.should_spin then
                    -- Spin mode overrides
                    data.yaw_mode = "Spin"
                    data.spin_speed = auto.spin_speed
                    data.yaw_left = 0
                    data.yaw_right = 0
                else
                    -- Normal Shiny AA
                    data.yaw_mode = "180"
                    data.yaw_left = auto.yaw_left
                    data.yaw_right = auto.yaw_right
                end
                                
                data.left_random = auto.left_random
                data.right_random = auto.right_random
                data.delay = true
                data.delay_mode = "Normal"
                data.delay_value = auto.delay_value
                data.body_yaw = "Jitter" 
                local body_yaw_value = -1  -- Default
                if math.abs(auto.yaw_left) > math.abs(auto.yaw_right) then
                    body_yaw_value = 1
                else
                    body_yaw_value = -1
                end

                data.body_yaw = "Jitter"
                data.body_yaw_amount = body_yaw_value
                data.jitter_mode = auto.jitter_mode
                data.jitter_amount = auto.jitter_amount
                data.fs_body_yaw = true  
                
                -- Pitch controller removed: always Down
                data.pitch = "Down"
                data.yaw_base = state_data.yaw_base and state_data.yaw_base:get() or "Local view"

            if data.yaw_mode == "Spin" then
                if refs.aa.yaw and refs.aa.yaw[1] then
                    refs.aa.yaw[1]:override("Spin")
                end
                if refs.aa.yaw and refs.aa.yaw[2] then
                    refs.aa.yaw[2]:override(data.spin_speed or 15)
                end
                
                -- During spin, disable jitter and use static body yaw
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                    refs.aa.yaw_jitter[1]:override("Off")
                end
                if refs.aa.body_yaw and refs.aa.body_yaw[1] then
                    refs.aa.body_yaw[1]:override("Static")
                end
                if refs.aa.body_yaw and refs.aa.body_yaw[2] then
                    refs.aa.body_yaw[2]:override(60)
                end
                
                -- Skip normal yaw/offset processing during spin
                if cmd.chokedcommands == 0 then
                    self.state.counter = self.state.counter + 1
                end
                return
            end

            
            else
                
                -- Pitch controller removed: always Down
                data.pitch = "Down"
                data.yaw_base = state_data.yaw_base and state_data.yaw_base:get() or "Local view"
                
                
                data.yaw_left = state_data.yaw_left and state_data.yaw_left:get()
                data.left_random = state_data.left_random and state_data.left_random:get()
                data.yaw_right = state_data.yaw_right and state_data.yaw_right:get()
                data.right_random = state_data.right_random and state_data.right_random:get()
                
                data.delay = state_data.delay_enabled and state_data.delay_enabled:get() or false
                data.delay_mode = state_data.delay_modes and state_data.delay_modes:get() or "Normal"
                data.delay_value = state_data.delay_amount and state_data.delay_amount:get()
                data.delay_random = state_data.delay_random and state_data.delay_random:get()
                data.delay_min = state_data.delay_min and state_data.delay_min:get()
                data.delay_max = state_data.delay_max and state_data.delay_max:get()
                data.delay_sliders = state_data.delay_custom_count and state_data.delay_custom_count:get()
                
                
                if state_data.delay_custom_values then
                    for i = 1, 22 do
                        data["delay_slider" .. i] = state_data.delay_custom_values[i] and state_data.delay_custom_values[i]:get() or 1
                    end
                end
                
                
                data.jitter_mode = state_data.jitter_mode and state_data.jitter_mode:get() or "Off"
                data.jitter_amount = state_data.jitter_amount and state_data.jitter_amount:get() or 0
                
                
                data.body_yaw = state_data.body_yaw and state_data.body_yaw:get() or "Off"
                data.body_yaw_static = state_data.body_yaw_static and state_data.body_yaw_static:get() or 0
                data.body_yaw_left = state_data.body_yaw_left and state_data.body_yaw_left:get() or 60
                data.body_yaw_right = state_data.body_yaw_right and state_data.body_yaw_right:get() or 60
                data.desync_random = state_data.desync_random and state_data.desync_random:get() or false
                data.amnesia_tick_speed = state_data.amnesia_tick_speed and state_data.amnesia_tick_speed:get() or 16
                data.fs_body_yaw = state_data.freestadingbody and state_data.freestadingbody:get() or false
            end

            
            data.state = state

            self:set(cmd, data)
        end,

        
handle_side_switching = function(self, cmd, data)
    
    if cmd.chokedcommands ~= 0 then
        return
    end
    
    
    if not data.delay then
        self.state.side = 1 - self.state.side
        self.state.switch_delay = 0
        return
    end
    
    
    self.state.switch_delay = self.state.switch_delay + 1
    
    local delay_value = data.delay_value or 1
    local delay_mode = data.delay_mode or "Normal"

    if delay_mode == "Custom" then
        if not self.state.current_slider then
            self.state.current_slider = 1
        end
        
        local num_sliders = data.delay_sliders or 1
        num_sliders = math.max(1, math.min(22, num_sliders))
        
        local slider_delay = tonumber(data["delay_slider" .. tostring(self.state.current_slider)]) or 1
        slider_delay = math.max(1, slider_delay)
        
        if self.state.switch_delay >= slider_delay then
            self.state.side = 1 - self.state.side
            self.state.switch_delay = 0
            
            
            self.state.current_slider = self.state.current_slider + 1
            if self.state.current_slider > num_sliders then
                self.state.current_slider = 1
            end
        end
        
    elseif delay_mode == "Min/Max" then
        
        local min_val = data.delay_min or 1
        local max_val = data.delay_max or 4
        if min_val > max_val then min_val, max_val = max_val, min_val end
        
        
        if not self.state.minmax_threshold or self.state.minmax_threshold <= 0 then
            self.state.minmax_threshold = math.random(min_val, max_val)
        end
        
        if self.state.switch_delay >= self.state.minmax_threshold then
            self.state.side = 1 - self.state.side
            self.state.switch_delay = 0
            self.state.minmax_threshold = math.random(min_val, max_val)
        end
        
    elseif delay_mode == "Exponencial" then
        
        local base_delay = data.delay_value or 0
        
        
        if not self.state.exp_stage then
            self.state.exp_stage = 0
        end
        
        
        local exp_delay = math.floor(base_delay * math.pow(1.3, self.state.exp_stage))
        exp_delay = math.max(1, math.min(15, exp_delay))
        
        if self.state.switch_delay >= exp_delay then
            self.state.side = 1 - self.state.side
            self.state.switch_delay = 0
            
            
            self.state.exp_stage = self.state.exp_stage + 1
            if self.state.exp_stage >= 6 or exp_delay >= 12 then
                self.state.exp_stage = 0
            end
        end
    elseif delay_mode == "Shiny" then

        local now = globals.realtime()
        local tick = globals.tickcount()
        local base_delay = data.delay_value or 0
        
        
        if not self.state.shiny_delay then
            self.state.shiny_delay = {
                last_switch_time = 0,
                pattern_phase = 0,
                entropy_seed = math.random() * 1000,
                burst_mode = false,
                burst_count = 0,
                burst_end_tick = 0,
                adaptive_base = base_delay,
                switch_history = {},
                micro_switch_cooldown = 0,
                chaos_active = false,
                chaos_end_time = 0,
                last_random_offset = 0,
            }
        end
        
        local sd = self.state.shiny_delay
        
        
        
        local golden = 1.618033988749895
        local phase_offset = ((tick * golden) % 1.0) * 2 - 1  
        
        
        
        local primes = {2, 3, 5, 7, 11, 13}
        local prime_mod = 0
        for i, p in ipairs(primes) do
            prime_mod = prime_mod + math.sin(tick / p + sd.entropy_seed * i) / i
        end
        prime_mod = prime_mod / 3  
        
        
        
        if not sd.chaos_active and math.random() < 0.02 then
            sd.chaos_active = true
            sd.chaos_end_time = now + 0.4 + math.random() * 0.3
        end
        
        if sd.chaos_active and now > sd.chaos_end_time then
            sd.chaos_active = false
        end
        
        
        
        if not sd.burst_mode and tick > sd.burst_end_tick + 30 and math.random() < 0.04 then
            sd.burst_mode = true
            sd.burst_count = math.random(2, 4)
        end
        
        
        local shiny_delay
        
        if sd.chaos_active then
            
            shiny_delay = math.random(1, 3)
            
        elseif sd.burst_mode then
            
            shiny_delay = 1
            sd.burst_count = sd.burst_count - 1
            if sd.burst_count <= 0 then
                sd.burst_mode = false
                sd.burst_end_tick = tick
            end
            
        else
            
            
            
            local base_variation = base_delay * (0.6 + phase_offset * 0.4)
            
            
            local prime_variation = base_delay * prime_mod * 0.3
            
            
            local time_variation = math.sin(now * 2.7 + sd.entropy_seed) * (base_delay * 0.25)
            
            
            if tick % 17 == 0 then
                sd.last_random_offset = (math.random() - 0.5) * base_delay * 0.4
            end
            
            
            shiny_delay = base_variation + prime_variation + time_variation + sd.last_random_offset
            
            
            if math.random() < 0.08 then
                shiny_delay = shiny_delay * (1.5 + math.random() * 0.5)
            end
            
            
            if math.random() < 0.06 then
                shiny_delay = math.max(1, shiny_delay * 0.4)
            end
        end
        
        
        shiny_delay = math.max(1, math.min(18, math.floor(shiny_delay + 0.5)))
        
        
        if self.state.switch_delay >= shiny_delay then
            self.state.side = 1 - self.state.side
            self.state.switch_delay = 0
            sd.last_switch_time = now
            
            
            table.insert(sd.switch_history, {
                time = now,
                delay = shiny_delay,
                side = self.state.side
            })
            while #sd.switch_history > 20 do
                table.remove(sd.switch_history, 1)
            end
            
            
            if math.random() < 0.1 then
                sd.entropy_seed = sd.entropy_seed + math.random() * 100
            end
        end

            elseif delay_mode == "Random" then
                
                local base = tonumber(data.delay_random) or tonumber(data.delay_value) or 1
                local min_val = math.max(1, math.floor(base))
                local extra_max = math.max(2, math.floor(min_val * 0.6))
                local max_val = math.min(22, min_val + extra_max)

                
                local use_shiny_variant = math.random() < 0.25

                if use_shiny_variant then
                    
                    if not self.state._shiny_rand then
                        self.state._shiny_rand = {seed = math.random() * 1000, last_offset = 0}
                    end

                    local sr = self.state._shiny_rand
                    local now = globals.realtime()
                    local tick = globals.tickcount()
                    local golden = 1.618033988749895

                    
                    local phase_offset = ((tick * golden) % 1.0) * 2 - 1
                    local primes = {2, 3, 5, 7, 11, 13}
                    local prime_mod = 0
                    for i, p in ipairs(primes) do
                        prime_mod = prime_mod + math.sin(tick / p + sr.seed * i) / i
                    end
                    prime_mod = prime_mod / 3

                    local base_variation = base * (0.6 + phase_offset * 0.4)
                    local time_variation = math.sin(now * 2.7 + sr.seed) * (base * 0.25)

                    if tick % 17 == 0 then
                        sr.last_offset = (math.random() - 0.5) * base * 0.4
                    end

                    local shiny_delay = base_variation + prime_mod * base * 0.3 + time_variation + sr.last_offset

                    
                    if math.random() < 0.08 then
                        shiny_delay = shiny_delay * (1.5 + math.random() * 0.5)
                    end
                    if math.random() < 0.06 then
                        shiny_delay = math.max(1, shiny_delay * 0.4)
                    end

                    shiny_delay = math.floor(math.max(1, math.min(18, shiny_delay + 0.5)))

                    if self.state.switch_delay >= shiny_delay then
                        self.state.side = 1 - self.state.side
                        self.state.switch_delay = 0
                        
                        if math.random() < 0.10 then
                            client.delay_call(0.02 + math.random() * 0.04, function()
                                if aa and aa.state then
                                    aa.state.side = 1 - aa.state.side
                                    aa.state.switch_delay = 0
                                end
                            end)
                        end
                    end

                else
                    
                    if not self.state.random_threshold or self.state.random_threshold < min_val or self.state.random_threshold > max_val then
                        local time_jitter = math.floor((math.abs(math.sin(globals.realtime() * 1.7)) * (max_val - min_val + 1)))
                        local pick = math.random(min_val, max_val)
                        if math.random() < 0.45 then
                            pick = math.max(min_val, pick - time_jitter)
                        else
                            pick = math.min(max_val, pick + time_jitter)
                        end
                        self.state.random_threshold = pick
                        self.state.last_random_threshold_time = globals.realtime()
                    end

                    if self.state.switch_delay >= self.state.random_threshold then
                        self.state.side = 1 - self.state.side
                        self.state.switch_delay = 0

                        if math.random() < 0.10 then
                            client.delay_call(0.02 + math.random() * 0.04, function()
                                if aa and aa.state then
                                    aa.state.side = 1 - aa.state.side
                                    aa.state.switch_delay = 0
                                end
                            end)
                        end

                        self.state.random_threshold = nil
                    end
                end  
        
    else
        
        if self.state.switch_delay >= delay_value then
            self.state.side = 1 - self.state.side
            self.state.switch_delay = 0
        end
    end
end,

defaa = {

},



        handle_side_switching_net_update = function(self, cmd, data)
            
            if cmd.chokedcommands ~= 0 then
                return
            end
            
            
            if self.net_update.pending_switch then
                self.state.side = self.net_update.side_on_update
                self.net_update.pending_switch = false
                self.state.switch_delay = 0
                return
            end
            
            
            
            if not data.delay then
                
                local tick = globals.tickcount()
                local ticks_since_update = tick - self.net_update.last_update_tick
                
                
                if ticks_since_update > 16 then
                    self.state.switch_delay = self.state.switch_delay + 1
                    if self.state.switch_delay >= 2 then
                        self.state.switch_delay = 0
                        self.state.side = 1 - self.state.side
                    end
                end
                return
            end
            
            
            self.state.switch_delay = self.state.switch_delay + 1
            local delay_value = data.delay_value or 1
            
            
            if self.state.switch_delay >= delay_value then
                self.state.switch_delay = 0
                self.state.side = 1 - self.state.side
            end
        end,

        
        on_net_update_end = function(self)
            local me = entity.get_local_player()
            if not me or not entity.is_alive(me) then return end
            
            local tick = globals.tickcount()
            local tickinterval = globals.tickinterval()
            local has_enemy_update = false
            local closest_enemy = nil
            local closest_distance = 999999
            
            
            local lx, ly, lz = entity.get_prop(me, "m_vecOrigin")
            if not lx then return end
            
            
            for player = 1, globals.maxplayers() do
                if entity.is_enemy(player) and entity.is_alive(player) and not entity.is_dormant(player) then
                    local simtime = entity.get_prop(player, "m_flSimulationTime")
                    if simtime then
                        local simtime_ticks = math.floor(simtime / tickinterval + 0.5)
                        local last_simtime = self.net_update.last_simtime[player] or 0
                        
                        
                        if simtime_ticks ~= last_simtime then
                            local delta = simtime_ticks - last_simtime
                            
                            
                            self.net_update.tick_delta[player] = delta
                            
                            
                            if delta < 0 or delta > 16 then
                                self.net_update.breaking_lc[player] = true
                            else
                                self.net_update.breaking_lc[player] = false
                            end
                            
                            
                            local ox, oy, oz = entity.get_prop(player, "m_vecOrigin")
                            if ox then
                                local last_origin = self.net_update.last_origin[player]
                                if last_origin then
                                    local dist_sq = (ox - last_origin.x)^2 + (oy - last_origin.y)^2 + (oz - last_origin.z)^2
                                    
                                    if dist_sq > 4096 then 
                                        self.net_update.breaking_lc[player] = true
                                    end
                                end
                                self.net_update.last_origin[player] = {x = ox, y = oy, z = oz}
                                
                                
                                local dist = math.sqrt((ox - lx)^2 + (oy - ly)^2 + (oz - lz)^2)
                                if dist < closest_distance then
                                    closest_distance = dist
                                    closest_enemy = player
                                end
                            end
                            
                            has_enemy_update = true
                        end
                        
                        self.net_update.last_simtime[player] = simtime_ticks
                    end
                end
            end
            
            
            if has_enemy_update then
                self.net_update.last_update_tick = tick
                
                
                if closest_enemy then
                    local is_breaking_lc = self.net_update.breaking_lc[closest_enemy]
                    local delta = self.net_update.tick_delta[closest_enemy] or 1
                    
                    
                    if is_breaking_lc then
                        
                        
                        if delta < 0 then
                            
                            self.net_update.side_on_update = 1 - self.state.side
                        else
                            
                            self.net_update.side_on_update = self.state.side
                        end
                    else
                        
                        self.net_update.side_on_update = 1 - self.state.side
                    end
                else
                    
                    self.net_update.side_on_update = 1 - self.state.side
                end
                
                self.net_update.pending_switch = true
            end
        end,
cleanup_net_update_data = function(self)
            for player = 1, globals.maxplayers() do
                if not entity.is_alive(player) or entity.is_dormant(player) then
                    self.net_update.last_simtime[player] = nil
                    self.net_update.last_origin[player] = nil
                    self.net_update.breaking_lc[player] = nil
                    self.net_update.tick_delta[player] = nil
                end
            end
        end,

                
        
        calculate_offsets = function(self, data)
            local yaw_offset = 0
            local body_yaw_val = data.body_yaw_amount or 60
            
            
            
            local now = globals.realtime()
            local tick = globals.tickcount()
            
            
            local threat_level = 0
            local timing_urgency = 0
            if self.shiny and self.shiny.response then
                threat_level = self.shiny.response.threat_level or 0
            end
            if self.shiny and self.shiny.timing_prediction then
                timing_urgency = self.shiny.timing_prediction.urgency or 0
            end
            
            
            local function generate_optimal_random(base_percent, layer_count)
                if base_percent <= 0 then return 0 end
                
                local result = 0
                local max_val = base_percent
                
                
                local sine_component = math.sin(now * 7.3 + tick * 0.13) * (max_val * 0.25)
                
                
                local hash_seed = bit.bxor(tick, bit.lshift(tick, 5), bit.rshift(tick, 3))
                local hash_component = ((hash_seed % 1000) / 1000 - 0.5) * (max_val * 0.35)
                
                
                local random_component = (math.random() - 0.5) * (max_val * 0.4)
                
                
                local threat_amp = 1.0 + threat_level * 0.5 + timing_urgency * 0.3
                
                
                local pattern_break = 0
                if math.random() < 0.08 then
                pattern_break = (math.random() - 0.5) * max_val * 0.6
                end
                
                
                result = sine_component + hash_component + random_component + pattern_break
                result = result * threat_amp
                
                
                result = math.max(-max_val, math.min(max_val, result))
                
                return result
            end
            
            
            local function generate_entropy_offset(base_value, randomization_percent)
                if randomization_percent <= 0 then return base_value end
                
                
                local side_entropy = 0.5
                if self.shiny and self.shiny.weather and self.shiny.weather.switch_history then
                local history = self.shiny.weather.switch_history
                local same_count = 0
                local current = self.state.side
                for i = #history, math.max(1, #history - 5), -1 do
                    if history[i].side == current then
                    same_count = same_count + 1
                    else
                    break
                    end
                end
                
                side_entropy = 0.3 + math.min(0.7, same_count * 0.15)
                end
                
                
                local rand_val = generate_optimal_random(randomization_percent, 5)
                
                
                rand_val = rand_val * side_entropy
                
                return base_value + rand_val
            end
            
            
            
            
            local now = globals.realtime()
            local tick = globals.tickcount()
            local shiny = self.shiny or {}
            
            
            local threat_level = (shiny.response and shiny.response.threat_level) or 0
            local timing_urgency = (shiny.timing_prediction and shiny.timing_prediction.urgency) or 0
            local pre_shot_threat = (shiny.pre_shot and shiny.pre_shot.imminent_threat) or 0
            local dodge_confidence = (shiny.prediction and shiny.prediction.confidence) or 0.5
            
            
            local switch_history = (shiny.weather and shiny.weather.switch_history) or {}
            local recent_same_side = 0
            local pattern_entropy = 0.5
            
            if #switch_history >= 3 then
                local current = self.state.side
                for i = #switch_history, math.max(1, #switch_history - 6), -1 do
                if switch_history[i] and switch_history[i].side == current then
                    recent_same_side = recent_same_side + 1
                else
                    break
                end
                end
                
                
                local side_changes = 0
                for i = #switch_history, math.max(2, #switch_history - 8), -1 do
                if switch_history[i] and switch_history[i-1] then
                    if switch_history[i].side ~= switch_history[i-1].side then
                    side_changes = side_changes + 1
                    end
                end
                end
                local check_count = math.min(8, #switch_history - 1)
                if check_count > 0 then
                pattern_entropy = side_changes / check_count
                
                if pattern_entropy > 0.85 or pattern_entropy < 0.15 then
                    pattern_entropy = 0.3 
                end
                end
            end
            
            
            local function generate_multi_layer_noise(base_percent, context_weight)
                if base_percent <= 0 then return 0 end
                
                local max_amplitude = base_percent
                local result = 0
                
                
                local prime_freqs = {2.71828, 3.14159, 7.38906, 11.0, 13.0}
                local sine_component = 0
                for i, freq in ipairs(prime_freqs) do
                local weight = 1.0 / i
                sine_component = sine_component + math.sin(now * freq + tick * 0.017 * i) * weight
                end
                sine_component = (sine_component / 3.5) * (max_amplitude * 0.22)
                
                
                local hash1 = bit.bxor(tick, bit.lshift(tick, 7), bit.rshift(tick, 4))
                local hash2 = bit.bxor(hash1, bit.lshift(hash1, 3), bit.rshift(hash1, 5))
                local hash_normalized = ((hash2 % 10000) / 10000 - 0.5) * 2
                local hash_component = hash_normalized * (max_amplitude * 0.28)
                
                
                local random_seed = math.sin(now * 1000) * 10000
                local pseudo_random = (random_seed - math.floor(random_seed)) - 0.5
                local true_random = (math.random() - 0.5)
                local random_component = (pseudo_random * 0.4 + true_random * 0.6) * (max_amplitude * 0.35)
                
                
                local combined_threat = threat_level * 0.3 + timing_urgency * 0.3 + pre_shot_threat * 0.4
                local threat_amplifier = 1.0 + combined_threat * 0.65
                
                
                local entropy_boost = 1.0
                if recent_same_side >= 3 then
                
                entropy_boost = 1.0 + (recent_same_side - 2) * 0.15
                end
                
                
                local spike_component = 0
                local spike_chance = 0.06 + combined_threat * 0.08
                if math.random() < spike_chance then
                local spike_direction = math.random() > 0.5 and 1 or -1
                local spike_magnitude = 0.4 + math.random() * 0.35
                spike_component = spike_direction * max_amplitude * spike_magnitude
                end
                
                
                local confidence_factor = 1.0 - (dodge_confidence * 0.25)
                
                
                result = sine_component + hash_component + random_component + spike_component
                result = result * threat_amplifier * entropy_boost * confidence_factor * context_weight
                
                
                local soft_max = max_amplitude * 1.15
                if math.abs(result) > max_amplitude then
                local excess = math.abs(result) - max_amplitude
                local compressed = max_amplitude + excess * 0.35
                result = (result > 0 and compressed or -compressed)
                end
                
                return math.max(-soft_max, math.min(soft_max, result))
            end
            
            
            local function generate_adaptive_offset(base_value, randomization_percent, side_context)
                if randomization_percent <= 0 then return base_value end
                
                
                local side_entropy = 0.5 + pattern_entropy * 0.3
                
                
                if recent_same_side >= 4 then
                side_entropy = math.min(1.0, side_entropy + 0.25)
                end
                
                
                local context_weight = 0.7 + side_entropy * 0.3
                
                
                local noise = generate_multi_layer_noise(randomization_percent, context_weight)
                
                
                local bias_correction = 0
                if shiny.dodge_effectiveness and shiny.dodge_effectiveness.by_side then
                local side_data = shiny.dodge_effectiveness.by_side[self.state.side]
                if side_data and side_data.total > 3 then
                    local success_rate = side_data.success / side_data.total
                    
                    if success_rate < 0.35 then
                    bias_correction = (0.35 - success_rate) * randomization_percent * 0.5
                    bias_correction = bias_correction * (math.random() > 0.5 and 1 or -1)
                    end
                end
                end
                
                return base_value + noise + bias_correction
            end
            
            
            if self.state.side == 0 then
                
                local left_randomization = data.left_random or 0
                local base_left = data.yaw_left or -35
                
                yaw_offset = yaw_offset + generate_adaptive_offset(base_left, left_randomization, "left")
            else
                
                local right_randomization = data.right_random or 0
                local base_right = data.yaw_right or 35
                
                yaw_offset = yaw_offset + generate_adaptive_offset(base_right, right_randomization, "right")
            end
            
            
            yaw_offset = self:apply_jitter_modifier(data, yaw_offset)
            
            return yaw_offset, body_yaw_val
            end,

        
        apply_jitter_modifier = function(self, data, yaw_offset)
            local jitter_mode = data.jitter_mode or "Off"
            local jitter_amount = data.jitter_amount or 0
            
            if jitter_mode == "Off" or jitter_amount == 0 then
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                    refs.aa.yaw_jitter[1]:override("Off")
                end
                return yaw_offset
            end
            
            if jitter_mode == "Offset" then
                
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                    refs.aa.yaw_jitter[1]:override("Off")
                end
                if self.state.side == 1 then
                    yaw_offset = yaw_offset + jitter_amount
                end
                
            elseif jitter_mode == "Center" then
                
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                    refs.aa.yaw_jitter[1]:override("Off")
                end
                if self.state.side == 1 then
                    yaw_offset = yaw_offset + (jitter_amount / 2)
                else
                    yaw_offset = yaw_offset - (jitter_amount / 2)
                end
                
            elseif jitter_mode == "Random" then
                
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                    refs.aa.yaw_jitter[1]:override("Off")
                end
                local rand = math.random(0, jitter_amount) - (jitter_amount / 1.5)
                yaw_offset = yaw_offset + rand
                self.state.last_rand = rand

            elseif jitter_mode == "Spin" then
                -- Spin modifier: oscillate yaw between spin_from and spin_to at spin_speed
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                    refs.aa.yaw_jitter[1]:override("Off")
                end
                
                local spin_from = data.spin_from or 0
                local spin_to = data.spin_to or 0
                local spin_speed = data.spin_speed or 5
                
                -- Initialize spin state if needed
                if not self.state.spin_state then
                    self.state.spin_state = {
                        current_angle = spin_from,
                        direction = 1, -- 1 = towards spin_to, -1 = towards spin_from
                        last_update = 0,
                    }
                end
                
                local ss = self.state.spin_state
                local now = globals.realtime()
                local dt = now - ss.last_update
                ss.last_update = now
                
                -- Clamp dt to prevent large jumps on first frame or lag
                if dt > 0.1 or dt < 0 then dt = 0.016 end
                
                -- Calculate step: speed 1-10 maps to degrees per second (36-360°/s)
                local degrees_per_second = spin_speed * 36
                local step = degrees_per_second * dt
                
                -- Determine sweep range
                local range = spin_to - spin_from
                
                if math.abs(range) < 1 then
                    -- spin_from == spin_to, just use that value
                    yaw_offset = yaw_offset + spin_from
                else
                    -- Move current_angle towards target
                    ss.current_angle = ss.current_angle + (step * ss.direction)
                    
                    -- Bounce when reaching either end
                    if ss.direction == 1 and ss.current_angle >= math.max(spin_from, spin_to) then
                        ss.current_angle = math.max(spin_from, spin_to)
                        ss.direction = -1
                    elseif ss.direction == -1 and ss.current_angle <= math.min(spin_from, spin_to) then
                        ss.current_angle = math.min(spin_from, spin_to)
                        ss.direction = 1
                    end
                    
                    yaw_offset = yaw_offset + ss.current_angle
                end                

            elseif jitter_mode == "3-Way" then
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                    refs.aa.yaw_jitter[1]:override("Off")
                end
                -- alpha apply_modifier "3-Way": phase over sent ticks -> {-amount, 0, +amount}
                local phase = (self.state.counter or 0) % 3
                if phase == 0 then
                    yaw_offset = yaw_offset - jitter_amount
                elseif phase == 2 then
                    yaw_offset = yaw_offset + jitter_amount
                end

            elseif jitter_mode == "Hold" then
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                    refs.aa.yaw_jitter[1]:override("Off")
                end
                -- alpha apply_modifier "Hold": hold an offset for a random burst, biased by side
                local c = self.state.counter or 0
                local hold = self.state.jitter_hold
                if not hold or c >= (hold.until_c or 0) then
                    local prefer = (self.state.side ~= 1) and -1 or 1
                    local sign = (math.random() < 0.7) and prefer or -prefer
                    hold = { sign = sign, until_c = c + math.random(2, 6) }
                    self.state.jitter_hold = hold
                end
                yaw_offset = yaw_offset + hold.sign * jitter_amount

            elseif jitter_mode == "Shiny" then
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                    local mode = "Offset"
                    local rand_interval = 3 + math.random(0, 1)
                    if self.state.counter % rand_interval == 0 then
                        mode = math.random(0, 6) == 0 and "Center" or "Random"
                    end
                    refs.aa.yaw_jitter[1]:override(mode)
                end
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[2] then
                    local jitter_val = 0
                    if jitter_amount > 0 then
                        jitter_val = math.random(-jitter_amount, jitter_amount)
                    elseif jitter_amount < 0 then
                        jitter_val = math.random(jitter_amount, -jitter_amount)
                    end
                    refs.aa.yaw_jitter[2]:override(jitter_val)
                end
                return yaw_offset
            end
            
            return yaw_offset
        end,

        
        apply_manual_mode = function(self, cmd, data)
            local manual_mode = menu.aa.manualsoptions and menu.aa.manualsoptions:get() or "Default"
            
            
            if not self.manual.active or self.manual.direction == 0 then
                return false
            end
            
            if manual_mode == "Default" then
                
                
                return false
                
            elseif manual_mode == "Jitter" then
                
                
                
                
                
                
                
                if refs.aa.enabled then
                    refs.aa.enabled:override(true)
                end
                
                
            local pitch_mode = data.pitch
            if refs.aa.pitch and refs.aa.pitch[1] then
                -- Gamesense doesn't have a "Jitter" pitch mode natively,
                -- so override as "Custom" and calculate the value ourselves
                if pitch_mode == "Jitter" then
                    refs.aa.pitch[1]:override("Custom")
                else
                    refs.aa.pitch[1]:override(pitch_mode)
                end
            end
            
            if refs.aa.pitch and refs.aa.pitch[2] then
                if pitch_mode == "Custom" then
                    refs.aa.pitch[2]:override(data.pitch_custom or 0)
                elseif pitch_mode == "Down" then
                    refs.aa.pitch[2]:override(89)
                elseif pitch_mode == "Up" then
                    refs.aa.pitch[2]:override(-89)
                elseif pitch_mode == "Jitter" then
                    -- Initialize pitch jitter state once
                    if not self.state.pitch_jitter then
                        self.state.pitch_jitter = {
                            current = 89,
                            direction = -1,
                            last_time = 0,
                            hold_timer = 0,
                        }
                    end
                    
                    local pj = self.state.pitch_jitter
                    local now = globals.realtime()
                    local speed = data.pitch_jitter_speed or 5
                    local dt = now - pj.last_time
                    pj.last_time = now
                    
                    -- Clamp dt to prevent large jumps on first frame or lag spikes
                    if dt > 0.1 or dt <= 0 then dt = globals.tickinterval() end
                    
                    if speed >= 9 then
                        -- Fast snap mode: alternate between 89 and -89 each tick/interval
                        local snap_interval = speed == 10 and 0.0 or 0.02
                        pj.hold_timer = pj.hold_timer + dt
                        if pj.hold_timer >= snap_interval then
                            pj.current = pj.current > 0 and -89 or 89
                            pj.hold_timer = 0
                        end
                    else
                        -- Sweep mode: smoothly oscillate between -89 and 89
                        -- Speed 1 = ~0.6s per full sweep, speed 8 = ~0.04s
                        local cycle_time = math.max(0.04, 0.6 - (speed - 1) * 0.07)
                        local step = (178 / cycle_time) * dt -- 178° total range
                        
                        pj.current = pj.current + step * pj.direction
                        
                        if pj.current >= 89 then
                            pj.current = 89
                            pj.direction = -1
                        elseif pj.current <= -89 then
                            pj.current = -89
                            pj.direction = 1
                        end
                    end
                    
                    refs.aa.pitch[2]:override(math.floor(pj.current + 0.5))
                else
                    refs.aa.pitch[2]:override(0)
                end
            end
                
                
                if refs.aa.yaw_base then
                    refs.aa.yaw_base:override(data.yaw_base)
                end
                
                
                if refs.aa.yaw and refs.aa.yaw[1] then
                    refs.aa.yaw[1]:override("180")
                end
                if refs.aa.yaw and refs.aa.yaw[2] then
                    refs.aa.yaw[2]:override(self.manual.direction)
                end
                
                
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                    refs.aa.yaw_jitter[1]:override("Off")
                end
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[2] then
                    refs.aa.yaw_jitter[2]:override(0)
                end
                
                
                if refs.aa.body_yaw and refs.aa.body_yaw[1] then
                    refs.aa.body_yaw[1]:override("Static")
                end
                if refs.aa.body_yaw and refs.aa.body_yaw[2] then
                    local body_val = self.state.side == 0 and -60 or 60
                    refs.aa.body_yaw[2]:override(body_val)
                end
                
                
                if refs.aa.fs_body_yaw then
                    refs.aa.fs_body_yaw:override(data.fs_body_yaw)
                end
                
                return true 
                
            elseif manual_mode == "Static" then
                
                
                
                
                
                
                
                if refs.aa.enabled then
                    refs.aa.enabled:override(true)
                end
                
                
                local pitch_mode = data.pitch
                if refs.aa.pitch and refs.aa.pitch[1] then
                    refs.aa.pitch[1]:override(pitch_mode)
                end
                if refs.aa.pitch and refs.aa.pitch[2] then
                    if pitch_mode == "Custom" then
                        refs.aa.pitch[2]:override(data.pitch_custom or 0)
                    elseif pitch_mode == "Down" then
                        refs.aa.pitch[2]:override(89)
                    elseif pitch_mode == "Up" then
                        refs.aa.pitch[2]:override(-89)
                    else
                        refs.aa.pitch[2]:override(0)
                    end
                end
                
                
                if refs.aa.yaw_base then
                    refs.aa.yaw_base:override(data.yaw_base)
                end
                
                
                if refs.aa.yaw and refs.aa.yaw[1] then
                    refs.aa.yaw[1]:override("180")
                end
                if refs.aa.yaw and refs.aa.yaw[2] then
                    refs.aa.yaw[2]:override(self.manual.direction)
                end
                
                
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                    refs.aa.yaw_jitter[1]:override("Off")
                end
                if refs.aa.yaw_jitter and refs.aa.yaw_jitter[2] then
                    refs.aa.yaw_jitter[2]:override(0)
                end
                
                
                if refs.aa.body_yaw and refs.aa.body_yaw[1] then
                    refs.aa.body_yaw[1]:override("Off")
                end
                if refs.aa.body_yaw and refs.aa.body_yaw[2] then
                    refs.aa.body_yaw[2]:override(0)
                end
                
                
                if refs.aa.fs_body_yaw then
                    refs.aa.fs_body_yaw:override(false)
                end
                
                return true 
            end
            
            return false
        end,

shiny_init_enemy = function(self, player)
    local id = tostring(player)
    if self.shiny.enemies[id] then return self.shiny.enemies[id] end
    
    self.shiny.enemies[id] = {
        
        distance = 9999,
        has_los = false,
        angle_to_us = 0,
        
        
        looking_at_us = false,
        aim_on_head = false,
        aim_stability = 0,
        tracking_time = 0,
        last_aim_update = 0,
        
        
        weapon_type = "rifle",
        weapon_delay = 0.1,
        is_scoped = false,
        can_shoot = true,
        
        
        last_shot_time = 0,
        shot_interval = 0.15,
        
        
        hits_on_side = {[0] = 0, [1] = 0},
        dodges_on_side = {[0] = 0, [1] = 0},
        
        
        threat_score = 0,
    }
    
    return self.shiny.enemies[id]
end,




shiny_analyze_threats = function(self, me)
    local now = globals.realtime()
    local shiny = self.shiny
    
    local my_x, my_y, my_z = entity.get_prop(me, "m_vecOrigin")
    if not my_x then return end
    
    local my_eye_x, my_eye_y, my_eye_z = client.eye_position()
    local head_x, head_y, head_z = entity.hitbox_position(me, 0)
    if not head_x then head_x, head_y, head_z = my_eye_x, my_eye_y, my_eye_z end
    
    local highest_threat = 0
    local primary_threat = nil
    local threat_direction = 0
    local aim_locked = 0
    local imminent_danger = false
    
    
    local enemies = entity.get_players(true)
    for _, enemy in ipairs(enemies) do
        if entity.is_alive(enemy) and not entity.is_dormant(enemy) then
            local data = self:shiny_init_enemy(enemy)
            
            
            local ex, ey, ez = entity.get_prop(enemy, "m_vecOrigin")
            if not ex then goto continue end
            
            local e_eye_x, e_eye_y, e_eye_z = entity.hitbox_position(enemy, 0)
            if not e_eye_x then 
                e_eye_x, e_eye_y, e_eye_z = ex, ey, ez + 64 
            end
            
            
            local dx, dy = ex - my_x, ey - my_y
            data.distance = math.sqrt(dx*dx + dy*dy + (ez - my_z)^2)
            data.angle_to_us = math.deg(math.atan2(dy, dx))
            
            
            local frac, hit = client.trace_line(me, my_eye_x, my_eye_y, my_eye_z, e_eye_x, e_eye_y, e_eye_z)
            data.has_los = frac > 0.97 or hit == enemy
            
            
            local enemy_pitch = entity.get_prop(enemy, "m_angEyeAngles[0]") or 0
            local enemy_yaw = entity.get_prop(enemy, "m_angEyeAngles[1]") or 0
            
            
            local to_head_x = head_x - e_eye_x
            local to_head_y = head_y - e_eye_y
            local to_head_z = head_z - e_eye_z
            local ideal_yaw = math.deg(math.atan2(to_head_y, to_head_x))
            local ideal_pitch = -math.deg(math.atan2(to_head_z, math.sqrt(to_head_x^2 + to_head_y^2)))
            
            
            local yaw_diff = math.abs(func.aa_clamp(enemy_yaw - ideal_yaw))
            local pitch_diff = math.abs(enemy_pitch - ideal_pitch)
            
            data.looking_at_us = yaw_diff < 25 and pitch_diff < 25
            data.aim_on_head = yaw_diff < 10 and pitch_diff < 12
            
            
            if data.looking_at_us then
                data.aim_stability = math.min(1, data.aim_stability + 0.15)
                data.tracking_time = (data.last_aim_update > 0 and data.looking_at_us) 
                    and (data.tracking_time + (now - data.last_aim_update)) or 0
                aim_locked = aim_locked + 1
            else
                data.aim_stability = math.max(0, data.aim_stability - 0.3)
                data.tracking_time = 0
            end
            data.last_aim_update = now
            
            
            local weapon = entity.get_player_weapon(enemy)
            if weapon then
                local classname = entity.get_classname(weapon) or ""
                local clip = entity.get_prop(weapon, "m_iClip1") or 1
                
                if classname:find("awp") then
                    data.weapon_type = "awp"
                    data.weapon_delay = 1.5
                elseif classname:find("ssg08") then
                    data.weapon_type = "scout"
                    data.weapon_delay = 1.25
                elseif classname:find("scar20") or classname:find("g3sg1") then
                    data.weapon_type = "auto"
                    data.weapon_delay = 0.25
                else
                    data.weapon_type = "rifle"
                    data.weapon_delay = 0.1
                end
                
                local fov = entity.get_prop(enemy, "m_iFOV")
                data.is_scoped = fov and fov > 0 and fov < 90
                data.can_shoot = clip > 0 and (now - data.last_shot_time) >= data.weapon_delay
            end
            
            
            local threat = 0
            
            
            local dist_mult = 1 / (1 + data.distance / 800)
            threat = dist_mult * 0.3
            
            
            if data.has_los then
                threat = threat + 0.2
                
                
                if data.looking_at_us then
                    threat = threat + 0.15
                    
                    
                    threat = threat + data.aim_stability * 0.2
                    
                    
                    if data.aim_on_head then
                        threat = threat + 0.3
                        
                        
                        if data.can_shoot then
                            imminent_danger = true
                            threat = threat + 0.2
                        end
                    end
                end
                
                
                if data.is_scoped then
                    threat = threat + 0.15
                end
                
                if data.weapon_type == "awp" or data.weapon_type == "auto" then
                    threat = threat + 0.1
                end
            else
                
                threat = threat * 0.2
            end
            
            
            data.threat_score = func.fclamp(threat, 0, 1)
            
            
            if data.threat_score > highest_threat then
                highest_threat = data.threat_score
                primary_threat = enemy
                threat_direction = data.angle_to_us
            end
            
            ::continue::
        end
    end
    
    
    shiny.threat.level = highest_threat
    shiny.threat.primary_threat = primary_threat
    shiny.threat.threat_direction = threat_direction
    shiny.threat.imminent_danger = imminent_danger
    shiny.threat.aim_locked_count = aim_locked
    shiny.threat.last_update = now
end,




shiny_record_shot = function(self, shooter, hit_us, hitgroup)
    local id = tostring(shooter)
    local data = self.shiny.enemies[id]
    if not data then return end
    
    local shiny = self.shiny
    local current_side = self.state.side
    
    if hit_us then
        
        data.hits_on_side[current_side] = (data.hits_on_side[current_side] or 0) + 1
        shiny.learning.side_effectiveness[current_side] = 
            (shiny.learning.side_effectiveness[current_side] or 0) - 3
        
        
        if shiny.learning.last_hit_side == current_side then
            shiny.learning.same_side_hits = shiny.learning.same_side_hits + 1
        else
            shiny.learning.last_hit_side = current_side
            shiny.learning.same_side_hits = 1
        end
        
        
        if hitgroup == 1 then
            shiny.learning.side_effectiveness[current_side] = 
                shiny.learning.side_effectiveness[current_side] - 5
        end
        
        
        table.insert(shiny.learning.recent_hits, {
            side = current_side,
            time = globals.realtime(),
            headshot = hitgroup == 1,
        })
        while #shiny.learning.recent_hits > 10 do
            table.remove(shiny.learning.recent_hits, 1)
        end
    else
        
        data.dodges_on_side[current_side] = (data.dodges_on_side[current_side] or 0) + 1
        shiny.learning.side_effectiveness[current_side] = 
            (shiny.learning.side_effectiveness[current_side] or 0) + 2
        
        shiny.learning.same_side_hits = 0
        shiny.learning.last_hit_side = nil
        
        
        table.insert(shiny.learning.recent_dodges, {
            side = current_side,
            time = globals.realtime(),
        })
        while #shiny.learning.recent_dodges > 10 do
            table.remove(shiny.learning.recent_dodges, 1)
        end
    end
    
    
    data.last_shot_time = globals.realtime()
end,




shiny_calculate_optimal_side = function(self)
    local shiny = self.shiny
    local now = globals.realtime()
    local current_side = self.state.side
    
    local scores = {[0] = 0, [1] = 0}
    
    
    if shiny.learning.same_side_hits >= 3 then
        local other_side = current_side == 1 and 0 or 1
        return other_side, 1.0  
    end
    
    
    
    local recent_weight = 0.5
    
    
    local recent_hit_scores = {[0] = 0, [1] = 0}
    local hit_count = math.min(#shiny.learning.recent_hits, 5)
    if hit_count > 0 then
        for i = #shiny.learning.recent_hits - hit_count + 1, #shiny.learning.recent_hits do
            local hit = shiny.learning.recent_hits[i]
            local time_factor = 1 - ((now - hit.time) / 10)  
            time_factor = math.max(0, time_factor)
            
            
            local penalty = hit.headshot and -4 or -2
            recent_hit_scores[hit.side] = recent_hit_scores[hit.side] + (penalty * time_factor)
        end
    end
    
    
    local recent_dodge_scores = {[0] = 0, [1] = 0}
    local dodge_count = math.min(#shiny.learning.recent_dodges, 5)
    if dodge_count > 0 then
        for i = #shiny.learning.recent_dodges - dodge_count + 1, #shiny.learning.recent_dodges do
            local dodge = shiny.learning.recent_dodges[i]
            local time_factor = 1 - ((now - dodge.time) / 10)
            time_factor = math.max(0, time_factor)
            
            
            recent_dodge_scores[dodge.side] = recent_dodge_scores[dodge.side] + (3 * time_factor)
        end
    end
    
    
    local recent_0 = recent_hit_scores[0] + recent_dodge_scores[0]
    local recent_1 = recent_hit_scores[1] + recent_dodge_scores[1]
    
    if recent_0 ~= 0 or recent_1 ~= 0 then
        local total = math.abs(recent_0) + math.abs(recent_1)
        scores[0] = scores[0] + (recent_0 / total) * recent_weight
        scores[1] = scores[1] + (recent_1 / total) * recent_weight
    end
    
    
    if shiny.threat.primary_threat and shiny.threat.level > 0.3 then
        local threat_data = shiny.enemies[tostring(shiny.threat.primary_threat)]
        if threat_data then
            local hits_0 = threat_data.hits_on_side[0] or 0
            local hits_1 = threat_data.hits_on_side[1] or 0
            local dodge_0 = threat_data.dodges_on_side[0] or 0
            local dodge_1 = threat_data.dodges_on_side[1] or 0
            
            
            local total_0 = hits_0 + dodge_0
            local total_1 = hits_1 + dodge_1
            
            if total_0 > 0 or total_1 > 0 then
                local success_rate_0 = total_0 > 0 and (dodge_0 / total_0) or 0.5
                local success_rate_1 = total_1 > 0 and (dodge_1 / total_1) or 0.5
                
                
                local score_0 = (success_rate_0 - 0.5) * 2
                local score_1 = (success_rate_1 - 0.5) * 2
                
                scores[0] = scores[0] + score_0 * 0.3
                scores[1] = scores[1] + score_1 * 0.3
            end
        end
    end
    
    
    if shiny.learning.same_side_hits >= 2 then
        
        local penalty = math.min(0.8, shiny.learning.same_side_hits * 0.35)
        scores[shiny.learning.last_hit_side] = scores[shiny.learning.last_hit_side] - penalty
        
        
        local other_side = shiny.learning.last_hit_side == 1 and 0 or 1
        scores[other_side] = scores[other_side] + penalty * 0.5
    end
    
    
    local time_on_side = now - shiny.timing.last_switch
    
    if time_on_side > 0.5 then
        
        local staleness = math.min(0.15, (time_on_side - 0.5) * 0.4)
        scores[current_side] = scores[current_side] - staleness
    elseif time_on_side < 0.1 then
        
        scores[current_side] = scores[current_side] + 0.05
    end
    
    
    if shiny.threat.level > 0.4 and shiny.threat.primary_threat then
        local me = entity.get_local_player()
        if me then
            local my_yaw = entity.get_prop(me, "m_angEyeAngles[1]") or 0
            local threat_angle = shiny.threat.threat_direction
            local relative_angle = func.aa_clamp(threat_angle - my_yaw)
            
            
            
            
            local direction_factor = func.fclamp(relative_angle / 70, -0.12, 0.12)
            
            
            local threat_mult = shiny.threat.level
            scores[0] = scores[0] - (direction_factor * threat_mult)
            scores[1] = scores[1] + (direction_factor * threat_mult)
            
            
            if shiny.threat.imminent_danger then
                scores[0] = scores[0] - (direction_factor * 0.3)
                scores[1] = scores[1] + (direction_factor * 0.3)
            end
        end
    end
    
    
    if shiny.threat.aim_locked_count > 1 then
        
        local multi_scores = {[0] = 0, [1] = 0}
        local valid_threats = 0
        
        for id, data in pairs(shiny.enemies) do
            if data.threat_score > 0.3 and data.looking_at_us then
                local total_0 = (data.hits_on_side[0] or 0) + (data.dodges_on_side[0] or 0)
                local total_1 = (data.hits_on_side[1] or 0) + (data.dodges_on_side[1] or 0)
                
                if total_0 > 0 then
                    local success_0 = (data.dodges_on_side[0] or 0) / total_0
                    multi_scores[0] = multi_scores[0] + success_0
                end
                
                if total_1 > 0 then
                    local success_1 = (data.dodges_on_side[1] or 0) / total_1
                    multi_scores[1] = multi_scores[1] + success_1
                end
                
                valid_threats = valid_threats + 1
            end
        end
        
        if valid_threats > 0 then
            
            multi_scores[0] = (multi_scores[0] / valid_threats) - 0.5
            multi_scores[1] = (multi_scores[1] / valid_threats) - 0.5
            
            scores[0] = scores[0] + multi_scores[0] * 0.15
            scores[1] = scores[1] + multi_scores[1] * 0.15
        end
    end
    
    
    
    local eff_0 = shiny.learning.side_effectiveness[0] or 0
    local eff_1 = shiny.learning.side_effectiveness[1] or 0
    
    if eff_0 ~= 0 or eff_1 ~= 0 then
        local total = math.abs(eff_0) + math.abs(eff_1) + 1  
        local norm_0 = eff_0 / total
        local norm_1 = eff_1 / total
        
        
        scores[0] = scores[0] + norm_0 * 0.05
        scores[1] = scores[1] + norm_1 * 0.05
    end
    
    
    local best_side = scores[1] > scores[0] and 1 or 0
    local confidence = math.abs(scores[1] - scores[0])
    
    
    if confidence > 0.3 then
        confidence = confidence * 1.2
    end
    
    
    confidence = func.fclamp(confidence, 0, 1)
    
    
    if #shiny.learning.recent_hits == 0 and #shiny.learning.recent_dodges == 0 then
        if math.random() < 0.3 then
            best_side = current_side == 1 and 0 or 1
        end
        confidence = 0.1
    end
    
    return best_side, confidence
end,




shiny_calculate_switch_timing = function(self, data)
    local shiny = self.shiny
    local now = globals.realtime()
    local tick = globals.tickcount()
    
    local base_delay = data.delay_value or 3
    local threat = shiny.threat.level
    local ticks_since = tick - (shiny.timing.last_switch_tick or 0)
    
    
    if shiny.threat.imminent_danger then
        
        if ticks_since >= 1 then
            return true, 1, "emergency"
        end
        return false, 1, "emergency_wait"
    end
    
    
    if threat >= shiny.THREAT_CRITICAL then
        local critical_delay = 1
        
        
        if shiny.threat.aim_locked_count > 1 then
            critical_delay = 1
        end
        
        return ticks_since >= critical_delay, critical_delay, "critical"
    end
    
    
    
    if #shiny.learning.recent_hits > 0 then
        local last_hit = shiny.learning.recent_hits[#shiny.learning.recent_hits]
        local time_since_hit = now - last_hit.time
        
        
        if time_since_hit < 0.3 then
            local panic_delay = math.random(1, 2)
            if ticks_since >= panic_delay then
                return true, panic_delay, "hit_response"
            end
        end
    end
    
    
    if threat >= shiny.THREAT_HIGH then
        local fast_delay
        
        
        local recent_effectiveness = 0
        local current_side = self.state.side
        
        
        local recent_count = 0
        for i = math.max(1, #shiny.learning.recent_dodges - 2), #shiny.learning.recent_dodges do
            local dodge = shiny.learning.recent_dodges[i]
            if dodge.side == current_side and (now - dodge.time) < 2.0 then
                recent_effectiveness = recent_effectiveness + 1
                recent_count = recent_count + 1
            end
        end
        
        for i = math.max(1, #shiny.learning.recent_hits - 2), #shiny.learning.recent_hits do
            local hit = shiny.learning.recent_hits[i]
            if hit.side == current_side and (now - hit.time) < 2.0 then
                recent_effectiveness = recent_effectiveness - 2
                recent_count = recent_count + 1
            end
        end
        
        
        if recent_count > 0 then
            if recent_effectiveness > 0 then
                
                fast_delay = math.random(3, 5)
            elseif recent_effectiveness < -1 then
                
                fast_delay = 1
            else
                
                fast_delay = math.random(2, 3)
            end
        else
            
            fast_delay = math.random(2, 4)
        end
        
        return ticks_since >= fast_delay, fast_delay, "high_threat_adaptive"
    end
    
    
    if threat >= shiny.THREAT_MEDIUM then
        local medium_delay = base_delay
        
        
        local time_on_side = now - shiny.timing.last_switch
        
        
        if time_on_side > 0.5 then
            medium_delay = math.floor(base_delay * 0.7)
        end
        
        return ticks_since >= medium_delay, medium_delay, "medium_threat"
    end
    
    
    local delay_mult = 1.0
    
    
    local time_on_side = now - shiny.timing.last_switch
    if time_on_side > 0.6 then
        delay_mult = delay_mult * 0.7  
    elseif time_on_side < 0.2 then
        delay_mult = delay_mult * 1.3  
    end
    
    
    local current_side = self.state.side
    local side_score = 0
    
    
    for i = math.max(1, #shiny.learning.recent_dodges - 3), #shiny.learning.recent_dodges do
        local dodge = shiny.learning.recent_dodges[i]
        if dodge.side == current_side and (now - dodge.time) < 3.0 then
            side_score = side_score + 1
        end
    end
    
    
    for i = math.max(1, #shiny.learning.recent_hits - 3), #shiny.learning.recent_hits do
        local hit = shiny.learning.recent_hits[i]
        if hit.side == current_side and (now - hit.time) < 3.0 then
            side_score = side_score - (hit.headshot and 2 or 1)
        end
    end
    
    
    if side_score > 1 then
        delay_mult = delay_mult * 1.4  
    elseif side_score < -1 then
        delay_mult = delay_mult * 0.5  
    end
    
    
    shiny.timing.phase_offset = shiny.timing.phase_offset + globals.tickinterval() * 1.618
    local wave = math.sin(shiny.timing.phase_offset)
    delay_mult = delay_mult + wave * 0.15
    
    
    if now > shiny.timing.anti_predict_timer then
        
        if math.random() < 0.2 then
            local variance = 0.5 + math.random() * 1.0  
            delay_mult = delay_mult * variance
            shiny.timing.anti_predict_timer = now + (0.8 + math.random() * 0.6)  
        else
            shiny.timing.anti_predict_timer = now + 0.3
        end
    end
    
    
    delay_mult = func.fclamp(delay_mult, 0.3, 2.0)
    
    
    local final_delay = math.max(1, math.floor(base_delay * delay_mult + 0.5))
    
    
    final_delay = math.min(final_delay, 12)
    
    
    local should_switch = ticks_since >= final_delay
    
    return should_switch, final_delay, "normal_adaptive"
end,




handle_side_switching_shiny = function(self, cmd, data)
    if cmd.chokedcommands ~= 0 then return end
    
    local me = entity.get_local_player()
    if not me or not entity.is_alive(me) then return end
    
    local shiny = self.shiny
    local now = globals.realtime()
    local tick = globals.tickcount()
    
    
    self:shiny_analyze_threats(me)
    
    
    local optimal_side, confidence = self:shiny_calculate_optimal_side()
    
    
    local should_switch, delay, reason = self:shiny_calculate_switch_timing(data)
    
    
    local force_switch = false
    
    
    if shiny.threat.imminent_danger and optimal_side ~= self.state.side and confidence > 0.15 then
        force_switch = true
    end
    
    
    if shiny.learning.same_side_hits >= 2 then
        force_switch = true
    end
    
    
    if confidence > 0.5 and optimal_side ~= self.state.side then
        force_switch = true
    end
    
    
    if should_switch or force_switch then
        local new_side
        
        
        if confidence > 0.2 or force_switch then
            new_side = optimal_side
        else
            
            new_side = self.state.side == 1 and 0 or 1
        end
        
        
        if new_side ~= self.state.side then
            self.state.side = new_side
            shiny.timing.last_switch = now
            shiny.timing.last_switch_tick = tick
            self.state.switch_delay = 0  
        end
    else
        
        self.state.switch_delay = self.state.switch_delay + 1
    end
end,




shiny_reset = function(self)
    self.shiny.enemies = {}
    
    self.shiny.threat = {
        level = 0,
        primary_threat = nil,
        threat_direction = 0,
        imminent_danger = false,
        aim_locked_count = 0,
        last_update = 0,
    }
    
    self.shiny.timing = {
        last_switch = 0,
        last_switch_tick = 0,
        phase_offset = math.random() * math.pi * 2,
        anti_predict_timer = 0,
    }
    
    
    for side = 0, 1 do
        self.shiny.learning.side_effectiveness[side] = 
            (self.shiny.learning.side_effectiveness[side] or 0) * 0.4
    end
    
    self.shiny.learning.same_side_hits = 0
    self.shiny.learning.last_hit_side = nil
    
    
    while #self.shiny.learning.recent_hits > 3 do
        table.remove(self.shiny.learning.recent_hits, 1)
    end
    while #self.shiny.learning.recent_dodges > 3 do
        table.remove(self.shiny.learning.recent_dodges, 1)
    end
end,


        set = function(self, cmd, data)
            
            local method = data.method or "Normal"
            
            if method == "Net_update" then
                
                self:handle_side_switching_net_update(cmd, data)
            elseif method == "Shiny" then
                
                self:handle_side_switching_shiny(cmd, data)
            else
                
                self:handle_side_switching(cmd, data)
            end
            
            
            if self:apply_manual_mode(cmd, data) then
                
                if cmd.chokedcommands == 0 then
                    self.state.counter = self.state.counter + 1
                    self.state.body_yaw_false_ticks = self.state.body_yaw_false_ticks + 1
                end
                return
            end
            
            
            if refs.aa.enabled then
                refs.aa.enabled:override(true)
            end

            
            local pitch_mode = data.pitch
            if refs.aa.pitch and refs.aa.pitch[1] then
                if pitch_mode == "Jitter" then
                    refs.aa.pitch[1]:override("Custom")
                else
                    refs.aa.pitch[1]:override(pitch_mode)
                end
            end
            
            if refs.aa.pitch and refs.aa.pitch[2] then
                if pitch_mode == "Custom" then
                    refs.aa.pitch[2]:override(data.pitch_custom or 0)
                elseif pitch_mode == "Down" then
                    refs.aa.pitch[2]:override(89)
                elseif pitch_mode == "Up" then
                    refs.aa.pitch[2]:override(-89)
                elseif pitch_mode == "Jitter" then
                    if not self.state.pitch_jitter then
                        self.state.pitch_jitter = {
                            current = 89,
                            direction = -1,
                            last_time = 0,
                            hold_timer = 0,
                        }
                    end
                    
                    local pj = self.state.pitch_jitter
                    local now = globals.realtime()
                    local speed = data.pitch_jitter_speed or 5
                    local dt = now - pj.last_time
                    pj.last_time = now
                    
                    if dt > 0.1 or dt <= 0 then dt = globals.tickinterval() end
                    
                    if speed >= 9 then
                        local snap_interval = speed == 10 and 0.0 or 0.02
                        pj.hold_timer = pj.hold_timer + dt
                        if pj.hold_timer >= snap_interval then
                            pj.current = pj.current > 0 and -89 or 89
                            pj.hold_timer = 0
                        end
                    else
                        local cycle_time = math.max(0.04, 0.6 - (speed - 1) * 0.07)
                        local step = (178 / cycle_time) * dt
                        
                        pj.current = pj.current + step * pj.direction
                        
                        if pj.current >= 89 then
                            pj.current = 89
                            pj.direction = -1
                        elseif pj.current <= -89 then
                            pj.current = -89
                            pj.direction = 1
                        end
                    end
                    
                    refs.aa.pitch[2]:override(math.floor(pj.current + 0.5))
                else
                    refs.aa.pitch[2]:override(0)
                end
            end
            
            
            if refs.aa.yaw_base then
                refs.aa.yaw_base:override(data.yaw_base)
            end

            
            local yaw_offset, body_yaw_val = self:calculate_offsets(data)
            
            
            yaw_offset = yaw_offset + self.manual.aa
            
            
            
            yaw_offset = func.aa_clamp(yaw_offset)

            -- Varg order: write yaw first, then body yaw
            if refs.aa.yaw and refs.aa.yaw[1] then
                refs.aa.yaw[1]:override("180")
            end
            if refs.aa.yaw and refs.aa.yaw[2] then
                refs.aa.yaw[2]:override(yaw_offset)
            end

            -- Body yaw: Varg jitter (reference/legacy/varg_top1_lua_gsc.lua ~1067-1088)
            local body_yaw_mode = data.body_yaw
            local bscale = function(v)
                v = tonumber(v) or 0
                if v == 0 then return 0 end
                return math.floor((v - 1) / 59 * 139)
            end

            if refs.aa.body_yaw and refs.aa.body_yaw[1] and refs.aa.body_yaw[2] then
                local left_scaled = bscale(data.body_yaw_left or 60)
                local right_scaled = bscale(data.body_yaw_right or 60)

                if body_yaw_mode == "Off" then
                    refs.aa.body_yaw[1]:override("Off")
                elseif body_yaw_mode == "Static" then
                    refs.aa.body_yaw[1]:override("Static")
                    refs.aa.body_yaw[2]:override(bscale(data.body_yaw_static or 0))
                elseif body_yaw_mode == "Jitter" then
                    -- varg: Static + (best_side == 0 and right or -left)
                    refs.aa.body_yaw[1]:override("Static")
                    if data.body_yaw_amount then
                        refs.aa.body_yaw[2]:override(self.state.side == 0 and -data.body_yaw_amount or data.body_yaw_amount)
                    else
                        refs.aa.body_yaw[2]:override(self.state.side == 0 and right_scaled or -left_scaled)
                    end
                    -- varg disable_desync_exploit ("desync random")
                    if data.desync_random then
                        self.state.desync_save = (self.state.desync_save or 180) - 1
                        refs.aa.body_yaw[2]:override(self.state.side == 0 and self.state.desync_save or -self.state.desync_save)
                        if math.abs(self.state.desync_save) < 2 then
                            local lo, hi = left_scaled, right_scaled
                            if lo > hi then lo, hi = hi, lo end
                            self.state.desync_save = (lo == hi) and lo or math.random(lo, hi)
                            refs.aa.body_yaw[1]:override("Off")
                        end
                    end
                elseif body_yaw_mode == "Amnesia" then
                    if self.state.amnesia_on == nil then self.state.amnesia_on = true end
                    if cmd.chokedcommands == 0 then
                        local speed_ticks = math.max(1, math.floor(data.amnesia_tick_speed or 16))
                        self.state.amnesia_tick_counter = (self.state.amnesia_tick_counter or 0) + 1
                        if self.state.amnesia_tick_counter >= speed_ticks then
                            self.state.amnesia_tick_counter = 0
                            self.state.amnesia_on = not self.state.amnesia_on
                        end
                    end
                    if self.state.amnesia_on then
                        refs.aa.body_yaw[1]:override("Static")
                        refs.aa.body_yaw[2]:override(self.state.side == 0 and right_scaled or -left_scaled)
                    else
                        refs.aa.body_yaw[1]:override("Off")
                    end
                elseif body_yaw_mode == "Adaptive" then
                    -- varg adaptive: Static + normalize(yaw)
                    refs.aa.body_yaw[1]:override("Static")
                    refs.aa.body_yaw[2]:override(func.aa_clamp(yaw_offset))
                end
            end

            
            if refs.aa.fs_body_yaw then
                refs.aa.fs_body_yaw:override(data.fs_body_yaw)
            end
            
            
            if cmd.chokedcommands == 0 then
                self.state.counter = self.state.counter + 1
                self.state.body_yaw_false_ticks = self.state.body_yaw_false_ticks + 1
            end
        end,
    }


    
client.set_event_callback("player_hurt", function(e)
    local me = entity.get_local_player()
    local victim = client.userid_to_entindex(e.userid)
    local attacker = client.userid_to_entindex(e.attacker)
    
    
    if victim == me and attacker and attacker ~= me then
        pcall(function()
            aa:shiny_record_shot(attacker, true, e.hitgroup)
            aa:shiny_record_shot_analysis(attacker, true, e.hitgroup, nil, e.weapon)
            aa:shiny_record_aim_tracking_shot(attacker, true, e.hitgroup)
        end)
    end
end)



client.set_event_callback("bullet_impact", function(e)
    local shooter = client.userid_to_entindex(e.userid)
    local me = entity.get_local_player()
    
    if shooter and shooter ~= me and entity.is_enemy(shooter) then
        pcall(function()
            aa:shiny_record_shot(shooter, false, nil)
            aa:shiny_record_shot_analysis(shooter, false, nil, nil, nil)
            aa:shiny_record_aim_tracking_shot(shooter, false, nil)
            aa:shiny_update_aim_tracking(shooter)
        end)
    end
end)



client.set_event_callback("round_prestart", function()
    pcall(function()
        if aa and aa.shiny_reset then
            aa:shiny_reset()
        end
        if aa and aa.shiny_reset_shot_analysis then
            aa:shiny_reset_shot_analysis()
        end
        if aa and aa.shiny_reset_aim_tracking then
            aa:shiny_reset_aim_tracking()
        end
    end)
end)

client.set_event_callback("shutdown", function()
    if aa and aa.shiny and aa.shiny.db_initialized then
        aa:shiny_save_all(true)  
    end
end)


client.set_event_callback("paint", function()
    if aa and aa.shiny and aa.shiny.db_initialized then
        local now = globals.realtime()
        
        if now % 30 < 0.02 then
            aa:shiny_save_all(false)
        end
    end
end)

    local safehead = {
        active = false,
        
        check = function(self)
            if not menu.aa.adds then return false end
            
            local selections = menu.aa.adds:get()
            if not selections then return false end
            
            
            local enabled = false
            if type(selections) == "table" then
                for _, v in ipairs(selections) do
                    if v == "Safe Head" then
                        enabled = true
                        break
                    end
                end
            elseif type(selections) == "string" then
                enabled = selections == "Safe Head"
            end
            
            if not enabled then return false end
            
            local lp = entity.get_local_player()
            if not lp or not entity.is_alive(lp) then return false end
            
            
            local options = menu.aa.safeheadoptions and menu.aa.safeheadoptions:get() or {}
            
            
            local flags = entity.get_prop(lp, "m_fFlags") or 0
            local in_air = bit.band(flags, 1) == 0
            local ducking = (entity.get_prop(lp, "m_flDuckAmount") or 0) > 0.5
            
            local weapon = entity.get_player_weapon(lp)
            local has_knife = false
            local has_zeus = false
            
            if weapon then
                local classname = entity.get_classname(weapon) or ""
                classname = classname:lower()
                has_knife = classname:find("knife") or classname:find("bayonet")
                has_zeus = classname:find("taser")
            end
            
            
            if type(options) == "table" then
                for _, opt in ipairs(options) do
                    if opt == "Air c + Knife" and in_air and ducking and has_knife then
                        return true
                    elseif opt == "Air c + Zeus" and in_air and ducking and has_zeus then
                        return true
                    end
                end
            end
            
            return false
        end,
        
        apply = function(self)
            
            if refs.aa.pitch and refs.aa.pitch[1] then
                refs.aa.pitch[1]:override("Down")
            end
            
            if refs.aa.yaw and refs.aa.yaw[1] then
                refs.aa.yaw[1]:override("180")
            end
            if refs.aa.yaw and refs.aa.yaw[2] then
                refs.aa.yaw[2]:override(0)
            end
            
            
            if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                refs.aa.yaw_jitter[1]:override("Off")
            end
            
            
            if refs.aa.body_yaw and refs.aa.body_yaw[1] then
                refs.aa.body_yaw[1]:override("Static")
            end
            if refs.aa.body_yaw and refs.aa.body_yaw[2] then
                refs.aa.body_yaw[2]:override(0)
            end
            
            return true 
        end
    }
local anti_backstab = {
    enabled = true,
    trigger_distance = 250,
    last_check = 0,
    check_interval = 0.05,
    active = false,
    threat_player = nil,
    mode = "forward",
    
    
    is_knife = function(self, weapon)
        if not weapon then return false end
        local classname = entity.get_classname(weapon)
        if not classname then return false end
        classname = classname:lower()
        return classname:find("knife") ~= nil or classname:find("bayonet") ~= nil
    end,
    
    
    distance = function(self, x1, y1, z1, x2, y2, z2)
        return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
    end,
    
    
    extrapolate = function(self, player, ticks, x, y, z)
        local xv, yv, zv = entity.get_prop(player, "m_vecVelocity")
        xv, yv, zv = xv or 0, yv or 0, zv or 0
        local new_x = x + globals.tickinterval() * xv * ticks
        local new_y = y + globals.tickinterval() * yv * ticks
        local new_z = z + globals.tickinterval() * zv * ticks
        return new_x, new_y, new_z
    end,
    
    
    get_distance = function(self)
        return self.trigger_distance
    end,
    
    
    should_activate = function(self)
        local myself = entity.get_local_player()
        if not myself or not entity.is_alive(myself) then return false end
        
        local distance_threshold = self:get_distance()
        
        
        for player = 1, globals.maxplayers() do
            if entity.is_enemy(player) and entity.is_alive(player) and not entity.is_dormant(player) then
                local weapon = entity.get_player_weapon(player)
                
                
                if self:is_knife(weapon) then
                    local ex, ey, ez = entity.get_origin(player)
                    local lx, ly, lz = entity.get_origin(myself)
                    
                    if ex and lx then
                        for ticks = 1, 9 do
                            local tex, tey, tez = self:extrapolate(myself, ticks, lx, ly, lz)
                            local dist = self:distance(ex, ey, ez, tex, tey, tez)
                            
                            if math.abs(dist) < distance_threshold then
                                self.active = true
                                self.threat_player = player
                                return true
                            end
                        end
                    end
                end
            end
        end
        
        self.active = false
        self.threat_player = nil
        return false
    end,
    
    
    apply = function(self)
        if not self.active then return false end
        
        
        if refs.aa.yaw and refs.aa.yaw[2] then
            refs.aa.yaw[2]:override(180)
        end
        
        
        if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
            refs.aa.yaw_jitter[1]:override("Off")
        end
        if refs.aa.yaw_jitter and refs.aa.yaw_jitter[2] then
            refs.aa.yaw_jitter[2]:override(0)
        end
        
        
        if refs.aa.body_yaw and refs.aa.body_yaw[1] then
            refs.aa.body_yaw[1]:override("Opposite")
        end
        if refs.aa.body_yaw and refs.aa.body_yaw[2] then
            refs.aa.body_yaw[2]:override(0)
        end
        
        return true
    end,
    
    
    run = function(self, cmd)
        if self:should_activate() then
            return self:apply()
        end
        return false
    end,
}
    local spin_controller = {
        active = false,
        last_check = 0,
        check_interval = 0.5,  
        
        is_round_warmup = function(self)
            local gr = entity.get_game_rules()
            if not gr then return false end
            
            local ok, warmed = pcall(entity.get_prop, gr, "m_bWarmupPeriod")
            return ok and warmed == 1
        end,
        
        are_enemies_dead = function(self)
            local me = entity.get_local_player()
            if not me then return false end
            
            local my_team = entity.get_prop(me, 'm_iTeamNum')
            if not my_team then return false end
            
            local pr = entity.get_player_resource()
            if not pr then return false end
            
            
            for i = 1, globals.maxplayers() do
                local connected = entity.get_prop(pr, 'm_bConnected', i)
                if connected == 1 then
                    local player_team = entity.get_prop(pr, 'm_iTeam', i)
                    
                    
                    if player_team ~= my_team and player_team ~= 0 then
                        local alive = entity.get_prop(pr, 'm_bAlive', i)
                        if alive == 1 then
                            
                            return false
                        end
                    end
                end
            end
            
            
            return true
        end,
        
        should_spin = function(self)
            if not menu.aa.adds then return false end
            
            local selections = menu.aa.adds:get()
            if not selections then return false end
            
            
            local enabled = false
            if type(selections) == "table" then
                for _, v in ipairs(selections) do
                    if v == "Spin on warmup/no enemies" then
                        enabled = true
                        break
                    end
                end
            elseif type(selections) == "string" then
                enabled = selections == "Spin on warmup/no enemies"
            end
            
            if not enabled then return false end
            
            local me = entity.get_local_player()
            if not me or not entity.is_alive(me) then return false end
            
            
            local now = globals.realtime()
            if now - self.last_check < self.check_interval then
                return self.active
            end
            self.last_check = now
            
            
            local warmup = self:is_round_warmup()
            local no_enemies = self:are_enemies_dead()
            
            self.active = warmup or no_enemies
            return self.active
        end,
        
        apply = function(self)
            
            if refs.aa.pitch and refs.aa.pitch[1] then
                refs.aa.pitch[1]:override("Off")
            end
            
            if refs.aa.yaw and refs.aa.yaw[1] then
                refs.aa.yaw[1]:override("Spin")
            end
            if refs.aa.yaw and refs.aa.yaw[2] then
                refs.aa.yaw[2]:override(25)  
            end
            
            
            if refs.aa.yaw_jitter and refs.aa.yaw_jitter[1] then
                refs.aa.yaw_jitter[1]:override("Off")
            end
            if refs.aa.yaw_jitter and refs.aa.yaw_jitter[2] then
                refs.aa.yaw_jitter[2]:override(0)
            end
            
            
            if refs.aa.body_yaw and refs.aa.body_yaw[1] then
                refs.aa.body_yaw[1]:override("Static")
            end
            if refs.aa.body_yaw and refs.aa.body_yaw[2] then
                refs.aa.body_yaw[2]:override(0)
            end
            
            return true  
        end,
        
        reset = function(self)
            self.active = false
        end
    }


    -- ── Defensive Ticks Correction ────────────────────────────────
    -- Measure: max_tickbase - tickbase - 1 (predict + setup dual sample)
    -- Fire:    force_defensive = not no_choke (every setup_command)
    -- ESP:     ticks_left, fallback to ticks_processed while in_defensive
    local DEFENSIVE_MAX_TICKS = 14
    local DEFENSIVE_TICKBASE_RESET = 64

    local function dtc_clamp(v, lo, hi)
        return math.min(hi, math.max(lo, v))
    end

    -- (checkbox, hotkey) reference pair: armed only when both are on.
    local function dtc_pair_enabled(pair)
        if not pair or not pair[1] then return false end
        local ok, on = pcall(ui.get, pair[1])
        if not (ok and on) then return false end
        if not pair[2] then return true end
        local ok2, active = pcall(ui.get, pair[2])
        return ok2 and active and true or false
    end

    local dtc_dt_refs = { ui.reference("RAGE", "Aimbot", "Double tap") }
    local dtc_hs_refs = { ui.reference("AA", "Other", "On shot anti-aim") }

    local function dtc_read_max_process_ticks()
        local ok, v = pcall(function()
            return cvar.sv_maxusrcmdprocessticks:get_int()
        end)
        return math.abs((ok and v) or 16) - 1
    end

    local dtc_exploits = {
        max_process_ticks = dtc_read_max_process_ticks(),
        tickbase_difference = 0,
        ticks_processed = 0,
        command_number = 0,
        choked_commands = 0,
        local_player = nil,
    }

    function dtc_exploits:reset()
        self.ticks_processed = 0
        self.tickbase_difference = 0
        self.choked_commands = 0
        self.command_number = 0
    end

    function dtc_exploits:store_vars(cmd)
        if not cmd then return end
        self.command_number = cmd.command_number or 0
        self.choked_commands = cmd.chokedcommands or 0
    end

    function dtc_exploits:store_tickbase_difference(cmd)
        if not cmd or cmd.command_number ~= self.command_number then return end
        local me = self.local_player or entity.get_local_player()
        if not me then return end
        local tickbase = entity.get_prop(me, "m_nTickBase") or 0
        local prev = self.tickbase_difference or 0
        if prev == 0 or math.abs(tickbase - prev) > DEFENSIVE_TICKBASE_RESET then
            -- first sample or server tickbase warp: nothing valid to measure
            self.tickbase_difference = tickbase
            self.ticks_processed = 0
            self.command_number = 0
            return
        end
        local max_shift = (self.max_process_ticks or 0) - (self.choked_commands or 0)
        self.ticks_processed = dtc_clamp(math.abs(tickbase - prev), 0, math.max(0, max_shift))
        self.tickbase_difference = math.max(tickbase, prev)
        self.command_number = 0
    end

    function dtc_exploits:is_active()
        return dtc_pair_enabled(dtc_dt_refs) or dtc_pair_enabled(dtc_hs_refs)
    end

    function dtc_exploits:in_defensive(max)
        max = max or self.max_process_ticks
        return self:is_active() and (self.ticks_processed > 1 and self.ticks_processed < max)
    end

    local dtc = {
        ticks_left = 1,
        max_tickbase = 0,
        bar_anim = 0,
    }

    local function dtc_sample()
        local me = entity.get_local_player()
        if not me then return end

        local tickbase = entity.get_prop(me, "m_nTickBase") or 0
        if math.abs(tickbase - dtc.max_tickbase) > DEFENSIVE_TICKBASE_RESET or tickbase > dtc.max_tickbase then
            dtc.max_tickbase = tickbase
        end

        dtc.ticks_left = math.min(DEFENSIVE_MAX_TICKS, math.max(1, dtc.max_tickbase - tickbase - 1))

        -- DT/OSAA unarmed: track tickbase 1:1 (no residual shift window can
        -- accumulate) and hold the readout at the 1t baseline.
        if not dtc_exploits:is_active() then
            dtc.max_tickbase = tickbase
            dtc.ticks_left = 1
        end
    end

    local function dtc_reset()
        dtc.ticks_left = 1
        dtc.max_tickbase = 0
        dtc_exploits:reset()
    end

    -- Sample then fire (setup_command half of dual measure).
    local function dtc_fire(cmd)
        if not cmd then return end
        dtc_sample()
        if dtc_exploits:is_active() then
            cmd.force_defensive = not cmd.no_choke
        else
            -- DT/OSAA unarmed: nothing to shift into; dtc_sample holds 1t.
            cmd.force_defensive = false
        end
    end

    local defensive_tick = dtc

    -- ── Forward Track (max-shot evasion; GS port of alpha FT) ──
    local FT_CVAR_ACTIVE = 19
    local FT_CVAR_IDLE = 16
    local FT_SPACE_FL = 16
    local FT_TEMP_FL = 1
    local FT_SPACE_MIN = 64
    local FT_FALLBACK_SENT = 7

    local ft_held = false
    local ft_regime = "idle"
    local ft_sent_since_tp = 0
    local ft_teleporting = false

    local function ft_safe_set(ref, value)
        if not ref then return end
        if type(ref) == "table" then
            if ref.override then
                pcall(function() ref:override(value) end)
            elseif ref[1] then
                if type(ref[1]) == "table" and ref[1].override then
                    pcall(function() ref[1]:override(value) end)
                else
                    pcall(ui.set, ref[1], value)
                end
            end
        else
            pcall(ui.set, ref, value)
        end
    end

    local function ft_set_doubletap(enabled)
        local dt = refs and refs.rage and refs.rage.dt and refs.rage.dt.value
        ft_safe_set(dt, enabled)
    end

    local function ft_set_maxshift(value)
        local ms = refs and refs.misc and refs.misc.settings and refs.misc.settings.maxshift
        ft_safe_set(ms, value)
    end

    local function ft_release()
        if not ft_held and not ft_teleporting then
            ft_regime = "idle"
            return
        end
        ft_held = false
        ft_teleporting = false
        ft_regime = "idle"
        ft_set_doubletap(true)
        ft_set_maxshift(FT_CVAR_IDLE)
        -- FL restored next tick by fakelag:run
    end

    local function ft_apply_packing(regime, fl_limit)
        if refs and refs.aa and refs.aa.fl then
            ft_safe_set(refs.aa.fl.enable, true)
            ft_safe_set(refs.aa.fl.limit, fl_limit)
        end
        local dt_fl = refs and refs.rage and refs.rage.dt and refs.rage.dt.fl
        ft_safe_set(dt_fl, fl_limit)
        ft_set_maxshift(FT_CVAR_ACTIVE)
        if not ft_teleporting then
            ft_set_doubletap(true)
        end
        ft_held = true
        ft_regime = regime
    end

    local function ft_speed_2d(me)
        local vx, vy = entity.get_prop(me, "m_vecVelocity")
        vx, vy = vx or 0, vy or 0
        return math.sqrt(vx * vx + vy * vy)
    end

    local function ft_space_gap(me)
        local ti = globals.tickinterval()
        if not ti or ti <= 0 then ti = 1 / 64 end
        return ft_speed_2d(me) * FT_SPACE_FL * ti
    end

    local function ft_list_has(tbl, name)
        if type(tbl) ~= "table" then return false end
        for _, v in pairs(tbl) do
            if v == name then return true end
        end
        return false
    end

    local function ft_conditions_ok(me, conditions)
        if conditions == nil then return true end
        if type(conditions) ~= "table" then return false end
        if ft_list_has(conditions, "Always") then return true end
        local want_knife = ft_list_has(conditions, "Holding Knife")
        local want_zeus = ft_list_has(conditions, "Holding Zeus")
        if not want_knife and not want_zeus then return false end
        local weapon = entity.get_player_weapon(me)
        local classname = ""
        if weapon then
            classname = (entity.get_classname(weapon) or ""):lower()
        end
        if want_knife and (classname:find("knife") or classname:find("bayonet")) then return true end
        if want_zeus and classname:find("taser") then return true end
        return false
    end

    local function ft_get_state_cfg()
        local mode_table = menu and menu.aa and menu.aa.builder and menu.aa.builder.modes and menu.aa.builder.modes.normal
        if not mode_table then return nil end
        -- Per-cheat profiles: FT gates on the detected threat's profile.
        if shinymoon_cheat_mode_table then
            mode_table = shinymoon_cheat_mode_table() or mode_table
        end
        local state = getstate()
        local active_ref = mode_table[state] and mode_table[state].active
        if state ~= "Global" and active_ref and not active_ref:get() then
            state = "Global"
        end
        return mode_table[state]
    end

    local function ft_threat_pressure(aa_self)
        local threat = aa_self and aa_self.shiny and aa_self.shiny.threat
        if not threat then return false, nil end
        local primary = threat.primary_threat
        if not primary then return false, nil end
        local pressure = threat.imminent_danger
            or (threat.aim_locked_count or 0) > 0
            or (threat.level or 0) >= 0.3
        return pressure, primary
    end

    local function ft_enemy_fire_soon(threat_ent)
        if not threat_ent then return false end
        local wpn = entity.get_player_weapon(threat_ent)
        if not wpn then return false end
        local next_atk = entity.get_prop(wpn, "m_flNextPrimaryAttack") or 0
        local cur = globals.curtime()
        local ti = globals.tickinterval()
        if not ti or ti <= 0 then ti = 1 / 64 end
        return next_atk <= (cur + ti * 2)
    end

    local function ft_dt_charged()
        local dt = refs and refs.rage and refs.rage.dt and refs.rage.dt.value
        if not dt then return false end
        if type(dt) ~= "table" then
            local ok, on = pcall(ui.get, dt)
            return ok and on and true or false
        end
        return dtc_pair_enabled(dt)
    end

    local function forward_track_reset()
        ft_sent_since_tp = 0
        ft_release()
    end

    local function forward_track_run(cmd, aa_self)
        if not cmd then return end

        local cfg = ft_get_state_cfg()
        if not cfg or not cfg.forward_track or not cfg.forward_track:get() then
            ft_release()
            return
        end

        -- ticks_left is clamped to a 1-tick baseline; only a real residual
        -- shift window (>1) means DTC still owns the exploit cycle.
        if (dtc.ticks_left or 0) > 1 or dtc_exploits:in_defensive() then
            ft_release()
            return
        end

        local me = entity.get_local_player()
        if not me or not entity.is_alive(me) then
            ft_release()
            return
        end

        local conditions = cfg.forward_track_conditions and cfg.forward_track_conditions:get() or nil
        if not ft_conditions_ok(me, conditions) then
            ft_release()
            return
        end

        if aa_self and aa_self.shiny_analyze_threats then
            pcall(function() aa_self:shiny_analyze_threats(me) end)
        end

        local pressure, primary = ft_threat_pressure(aa_self)
        local in_jump = cmd.in_jump == true or cmd.in_jump == 1
        if not primary then
            ft_release()
            return
        end
        if not in_jump and not pressure then
            ft_release()
            return
        end

        local gap = ft_space_gap(me)
        local space_ok = (not in_jump) and gap >= FT_SPACE_MIN
        local sent = (cmd.chokedcommands or 0) == 0
        if sent then
            ft_sent_since_tp = (ft_sent_since_tp or 0) + 1
        end

        if space_ok then
            ft_teleporting = false
            ft_apply_packing("SPACE", FT_SPACE_FL)
            ft_set_doubletap(true)
            return
        end

        ft_apply_packing("TEMP", FT_TEMP_FL)

        local fire_soon = ft_enemy_fire_soon(primary)
        local charged = ft_dt_charged()
        local fallback = sent and ft_sent_since_tp >= FT_FALLBACK_SENT
        if charged and (fire_soon or fallback) then
            ft_teleporting = true
            ft_set_doubletap(false)
            ft_sent_since_tp = 0
        else
            ft_teleporting = false
            ft_set_doubletap(true)
        end
    end

    -- ── Break LC (auto: armed whenever Hide Shots / OSAA is armed) ──
    -- GS has no native Break LC. While OSAA is active and we move fast
    -- enough to displace >64u inside a safe choke window, own packet sends
    -- so consecutive sent origins land >64u apart (embertrash 4096 sq-units
    -- rule) and the server invalidates our lag-comp records.
    -- Single table (not 5 locals): the main chunk sits near Lua's 200-local cap.
    local blc = { sx = nil, sy = nil, broke = false, breaks = 0,
        CHOKE_CAP = 14, DIST_SQ = 64 * 64 }

    function blc.reset()
        blc.sx, blc.sy, blc.broke = nil, nil, false
    end

    function blc.run(cmd)
        if not cmd then return end
        local me = entity.get_local_player()
        if not me or not entity.is_alive(me) then blc.reset() return end
        if not dtc_pair_enabled(dtc_hs_refs) then blc.reset() return end
        -- Yield: DT recharge/shots, fakeduck, a DTC defensive shift and an
        -- owned Forward Track cycle all need their own packet flow.
        if dtc_pair_enabled(dtc_dt_refs) then blc.reset() return end
        if dtc_pair_enabled(refs.rage.faceduck) then blc.reset() return end
        if dtc_exploits:in_defensive() or ft_held or ft_teleporting then blc.reset() return end
        if cmd.in_attack == 1 or cmd.in_use == 1 then blc.reset() return end

        local ox, oy = entity.get_origin(me)
        if not ox then return end
        local choked = cmd.chokedcommands or 0

        -- Re-baseline at every confirmed send; count the break it produced.
        if not blc.sx or choked == 0 then
            if blc.sx then
                local dx, dy = ox - blc.sx, oy - blc.sy
                blc.broke = dx * dx + dy * dy > blc.DIST_SQ
                if blc.broke then blc.breaks = blc.breaks + 1 end
            end
            blc.sx, blc.sy = ox, oy
        end

        -- Only own packets when 64u is reachable inside the cap window;
        -- normal ground speed can't break LC, so don't choke uselessly.
        local ti = globals.tickinterval()
        if not ti or ti <= 0 then ti = 1 / 64 end
        if ft_speed_2d(me) < 64 / (blc.CHOKE_CAP * ti) then return end

        local dx, dy = ox - blc.sx, oy - blc.sy
        cmd.allow_send_packet = (dx * dx + dy * dy > blc.DIST_SQ)
            or choked >= blc.CHOKE_CAP
    end

    client.set_event_callback("run_command", function(cmd)
        dtc_exploits.local_player = entity.get_local_player()
        dtc_exploits:store_vars(cmd)
    end)

    client.set_event_callback("predict_command", function(cmd)
        dtc_sample()
        dtc_exploits:store_tickbase_difference(cmd)
    end)

    client.set_event_callback("level_init", function()
        dtc_exploits.max_process_ticks = dtc_read_max_process_ticks()
        dtc_reset()
        forward_track_reset()
        blc.reset()
    end)

    client.set_event_callback("round_prestart", function()
        dtc_reset()
        forward_track_reset()
        blc.reset()
    end)

    client.set_event_callback("player_death", function(e)
        local me = entity.get_local_player()
        if me and e and e.userid and client.userid_to_entindex(e.userid) == me then
            dtc_reset()
            forward_track_reset()
            blc.reset()
            pcall(function() aa:shiny_on_death() end)
        end
    end)

    aa.run = function(self, cmd)
        local me = entity.get_local_player()
        if not me or not entity.is_alive(me) then return end

        if not self.shiny.db_initialized then
            self:shiny_init_database()
        end

        if spin_controller:should_spin() then
            spin_controller:apply()
            self.state.counter = self.state.counter + 1
            dtc_fire(cmd)
            forward_track_run(cmd, self)
            blc.run(cmd)
            return
        end

        if safehead:check() then
            safehead:apply()
            self.state.counter = self.state.counter + 1
            dtc_fire(cmd)
            forward_track_run(cmd, self)
            blc.run(cmd)
            return
        end

        if anti_backstab:run(cmd) then
            self.state.counter = self.state.counter + 1
            dtc_fire(cmd)
            forward_track_run(cmd, self)
            blc.run(cmd)
            return
        end

        local state = getstate()

        self:handle_manuals(cmd)
        self:handle_hotkeys(cmd)

        self:complete(cmd, state)

        dtc_fire(cmd)
        forward_track_run(cmd, self)
        blc.run(cmd)
    end


    client.set_event_callback("paint", function()
        local me = entity.get_local_player()
        if not me or not entity.is_alive(me) then return end

        -- Defensive ticks widget: gated on the Widgets multiselect, not LC ESP.
        if shinymoon_widget_on("Defensive") then
            local ticks = math.max(1, dtc.ticks_left or 1)
            if ticks == 1 and dtc_exploits:in_defensive() then
                ticks = math.max(1, math.min(DEFENSIVE_MAX_TICKS, dtc_exploits.ticks_processed or 1))
            end

            local BOX_W, BOX_H, ROUND = 56, 34, 5
            local bx, by = drag_dtc:get()
            drag_dtc:drag(BOX_W, BOX_H)

            local target = ticks / DEFENSIVE_MAX_TICKS
            local t = math.min(1, (globals.absoluteframetime() or 0.016) * 14)
            dtc.bar_anim = (dtc.bar_anim or 0) + (target - (dtc.bar_anim or 0)) * t

            render.rect:rect(bx, by, BOX_W, BOX_H, {0, 0, 0, 128}, ROUND)
            renderer.text(bx + BOX_W * 0.5, by + BOX_H * 0.5 - 2, 255, 255, 255, 255, "c", 0,
                string.format("%dt", ticks))

            local ar, ag, ab2 = 201, 129, 159
            pcall(function() ar, ag, ab2 = menu.visuals.accentcolor:get() end)

            local pad = 5
            local line_y = by + BOX_H - 5
            local line_w = BOX_W - pad * 2
            renderer.rectangle(bx + pad, line_y, line_w, 1, ar, ag, ab2, 77)
            local fill_w = math.floor(line_w * dtc.bar_anim + 0.5)
            if fill_w > 0 then
                renderer.rectangle(bx + pad, line_y, fill_w, 1, ar, ag, ab2, 255)
            end
        end

        if not (menu and menu.visuals and menu.visuals.defdebug and menu.visuals.defdebug:get()) then return end

        for player = 1, globals.maxplayers() do
            if entity.is_enemy(player) and entity.is_alive(player) and not entity.is_dormant(player) then
                if aa.net_update.breaking_lc[player] then
                    local hx, hy, hz = entity.hitbox_position(player, 0)
                    if hx then
                        local sx, sy = renderer.world_to_screen(hx, hy, hz + 20)
                        if sx then
                            renderer.text(sx, sy, 255, 255, 255, 255, "c", 0, "LC")
                        end
                    end
                end
            end
        end
    end)

    client.set_event_callback("net_update_end", function()
        aa:on_net_update_end()
    end)

    
    client.set_event_callback("round_prestart", function()
        aa:cleanup_net_update_data()
        spin_controller:reset()
    end)


    
    
    local function aa_state_reset()
        aa.manual.aa = 0
        aa.manual.tick = 0
        aa.manual.direction = 0
        aa.manual.active = false
        aa.state.side = 0
        aa.state.switch_delay = 0
        aa.state.current_slider = 1
        aa.state.counter = 0
        aa.state.body_yaw_false_ticks = 0
        aa.state.last_rand = 0
        aa.state.random_threshold = 0
        aa.state.minmax_threshold = 0
        aa.state.exp_stage = 0
        aa.state.shiny_delay = nil
        aa.state.jitter_hold = nil
        aa.state.amnesia_on = true
        aa.state.amnesia_tick_counter = 0
        aa.state.desync_save = 180
        spin_controller:reset()
    end

    client.set_event_callback("round_prestart", aa_state_reset)

    -- New map: entindexes get reused, so per-player net_update caches are garbage.
    client.set_event_callback("level_init", function()
        aa_state_reset()
        aa.net_update.last_simtime = {}
        aa.net_update.last_origin = {}
        aa.net_update.breaking_lc = {}
        aa.net_update.tick_delta = {}
        aa.net_update.pending_switch = false
        aa.net_update.last_update_tick = 0
        pcall(function()
            aa:shiny_reset()
            aa.shiny.enemies = {}
            aa.shiny.aim_tracking.enemies = {}
        end)
    end)

    client.set_event_callback("setup_command", function(cmd)
        aa:run(cmd)
    end)
    local menu_refs = {}

                local server_cvars = {
                    maxunlag = 0.5,
                    lagcomp_teleport_dist = 64,
                    tickrate = 64,
                    max_rewind_ticks = 12,
                    interp_min_ratio = 1,
                    interp_max_ratio = 2
                }
                local localdb = {
                    key = base64.encode("shinymoon:localdb:key:" .. tostring(steamid or "default"))
                }

    pcall(function()
        menu_refs.doubletap = {ui.reference("RAGE", "Aimbot", "Double tap")}
    end)
        local plist = plist or {
        set = function(ent, key, value) end,
        get = function(ent, key) return nil end
    }                
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
local clantag do
    
    local original_tag = ""
    local last_tag = nil
    local enabled_prev = false

    local frames = {
        " ",
        " s",
        " sh/",
        " shi_",
        " shin|",
        " shiny*",
        " shinym~",
        " shinymo_",
        " shinymoo/",
        " shinymoon ",
        "shinymoon ",
        "hinymoon/ ",
        "inymoon| ",
        "nymoon* ",
        "ymoon~ ",
        "moon_ ",
        "oon/ ",
        "on| ",
        "n* ",
        " ",
    }
    local fps = 5

    local function is_enabled()
        
        if refs and refs.misc and refs.misc.clantag then
            local ok, v = pcall(function() return refs.misc.clantag:get() end)
            if ok and v then return true end
        end

        if menu and menu.misc then
            
            local ref = menu.misc.clantag or menu.misc.clan_tag_spammer
            if ref then
                local ok, v = pcall(function() return ref:get() end)
                if ok and v then return true end
            end
        end

        return false
    end

    local function read_original_tag()
        
        local ok, steam = pcall(require, "gamesense/steamworks")
        if ok and type(steam) == "table" and steam.ISteamFriends and steam.ISteamFriends.GetClanTag then
            local ok_tag, tag = pcall(steam.ISteamFriends.GetClanTag, steam.ISteamFriends)
            if ok_tag and type(tag) == "string" and tag ~= "" then
                return tag
            end
        end

        if client.get_clan_tag then
            local ok2, tag2 = pcall(client.get_clan_tag)
            if ok2 and type(tag2) == "string" then
                return tag2
            end
        end

        return ""
    end

    original_tag = read_original_tag() or ""

    local function set_tag(tag)
        tag = tag or ""
        pcall(function() client.set_clan_tag(tostring(tag)) end)
        last_tag = tag
    end

    client.set_event_callback("paint", function()
        local enabled = is_enabled()
        if enabled then
            local t = globals.realtime() * fps
            local idx = (math.floor(t) % #frames) + 1
            local tag = frames[idx] or ""
            if tag ~= last_tag then set_tag(tag) end
        else
            if enabled_prev then set_tag(original_tag or "") end
        end
        enabled_prev = enabled
    end)

    
    client.set_event_callback("run_command", function(e)
        if not e then return end
        if e.chokedcommands == 0 and is_enabled() then
            local t = globals.realtime() * fps
            local idx = (math.floor(t) % #frames) + 1
            local tag = frames[idx] or ""
            if tag ~= last_tag then set_tag(tag) end
        end
    end)

    client.set_event_callback("shutdown", function()
        set_tag(original_tag or "")
    end)
end

local trashtalk do
    local phrases = {
        "{victim} got predicted ~ shinymoon ",
        "you just whitnessed 𝓼𝓱𝓲𝓷𝔂𝓶𝓸𝓸𝓷",
        "easy for 𝐬𝐡𝐢𝐧𝐲𝐦𝐨𝐨𝐧",
        "another one for 𝕤𝕙𝕚𝕟𝕪𝕞𝕠𝕠𝕟",
        "1",
        
    }

    local cooldown = 1.0
    local chance = 1 
    local last_time = 0
    local recent_targets = {}

    local function pick_phrase(victim_name)
        local s = phrases[math.random(1, #phrases)]
        s = s:gsub("{victim}", tostring(victim_name or "opponent"))
        local me_name = entity.get_player_name(entity.get_local_player()) or "me"
        s = s:gsub("{me}", tostring(me_name))
        return s
    end

    client.set_event_callback("player_death", function(e)
        if not e then return end
        if not (menu and menu.misc and menu.misc.trashtalk and menu.misc.trashtalk:get()) then return end

        local local_player = entity.get_local_player()
        if not local_player then return end

        local attacker_ent = e.attacker and client.userid_to_entindex(e.attacker) or nil
        local victim_ent = e.userid and client.userid_to_entindex(e.userid) or nil
        if not attacker_ent or not victim_ent then return end

        if attacker_ent ~= local_player then return end

        local now = globals.realtime()
        if now - last_time < cooldown then return end

        if recent_targets[victim_ent] and (now - recent_targets[victim_ent]) < 2.0 then
            return
        end

        if math.random() > chance then
            last_time = now
            recent_targets[victim_ent] = now
            return
        end

        local victim_name = entity.get_player_name(victim_ent) or "opponent"
        local msg = pick_phrase(victim_name)

        msg = msg:gsub('"', "'")
        pcall(function() client.exec('say "' .. msg .. '"') end)

        last_time = now
        recent_targets[victim_ent] = now
    end)

    client.set_event_callback("paint", function()
        local now = globals.realtime()
        for k, t in pairs(recent_targets) do
            if now - t > 10 then recent_targets[k] = nil end
        end
    end)
end


-- Resolver
-- Nested function: main-chunk Lua locals are capped at 200.
local function init_predict_enemies()
    local MAX_TICKS = 16
    local MIN_SPEED = 30
    local ERR_ALPHA = 0.30
    local ERR_K = 18
    local ACCEL_ALPHA = 0.35
    local CONF_MIN = 0.05
    local CONF_FLOOR = 0.55
    local STALE_S = 0.50
    local THREAT_HOLD_S = 0.35
    local GAP_HOLD_S = 0.40
    local SPEED_CAP = 340

    local track = {}
    local saved_interp, saved_ratio = nil, nil
    local pinned = false
    local threat_hold_idx, threat_hold_rt = nil, nil
    local decision = nil

    local function pe_enabled()
        -- Retired with the Resolver UI. Kept false so cl_interp pinning cannot
        -- resurrect from a stale config while the checkbox is greyed out.
        return false
    end

    local function resolver_enabled()
        return pe_enabled()
    end

    -- All improvements are always active while Resolver is on.
    local function rsv_has_imp(_name)
        return true
    end

    local function ti()
        local t = globals.tickinterval()
        if not t or t <= 0 then return 1 / 64 end
        return t
    end

    local function time_to_ticks(t)
        return math.floor(t / ti() + 0.5)
    end

    local function len2d(x, y)
        return math.sqrt((x or 0) * (x or 0) + (y or 0) * (y or 0))
    end

    local function ping_ticks()
        local lat = 0
        pcall(function() lat = client.latency() or 0 end)
        return time_to_ticks(lat)
    end

    local function has_live_enemy()
        local players = entity.get_players(true)
        if not players then return false end
        for i = 1, #players do
            if entity.is_alive(players[i]) then return true end
        end
        return false
    end

    local function aa_clamp(a)
        a = (a or 0) % 360
        if a > 180 then a = a - 360 end
        if a < -180 then a = a + 360 end
        return a
    end

    local function fclamp(v, lo, hi)
        if v < lo then return lo end
        if v > hi then return hi end
        return v
    end

    -- ── Body-yaw resolver  ──
    local rsv_players = {}
    local rsv_touched = {}
    local rsv_value_key = nil -- cached: "Force body yaw value" or "Body yaw value"
    local rsv_was_on = false
    local BF_OFFSETS = {60, -60, 58, -58, 50, -50, 45, -45, 40, -40, 35, -35, 30, -30}
    local RSV_WEIGHT_FLOOR = 0.2
    local RSV_WEIGHT_CAP = 4.0
    local RSV_STALE_S = 2.0
    local MOTION_FLOOR = 0.40

    -- Neural body-yaw (expanded: 32→64→48→3, DB version 2).
    local nn = {}
    do
        local DB_KEY = "shinymoon:gs:neural_resolver:weights"
        local DB_VERSION = 2
        local CFG = {
            input_size = 32,
            hidden = {64, 48},
            output_size = 3,
            lr = 0.001,
            lr_min = 0.0001,
            lr_max = 0.01,
            lr_decay = 0.9995,
            momentum = 0.9,
            dropout = 0.2,
            replay_size = 1024,
            batch_size = 16,
            min_train = 32,
            per_alpha = 0.6,
            per_beta = 0.4,
            per_eps = 0.01,
            train_interval = 0.5,
            save_interval = 60.0,
            conf_floor = 0.6,
            conf_high = 0.85,
            bf_miss_threshold = 2,
            weight_lr = 0.05,
            weight_cap = 0.70,
            weight_floor = 0.05,
            unanimous_boost = 0.15,
        }
        local net = {
            weights = {}, biases = {},
            w_mom = {}, b_mom = {},
            act = {}, pre = {}, drop = {},
        }
        local buf = { samples = {}, priorities = {}, max_p = 1, size = 0, pos = 0 }
        local stats = { lr = CFG.lr, iters = 0, loss = 0, preds = 0, correct = 0 }
        local src_w = { neural = 0.45, stat = 0.40, bruteforce = 0.15 }
        local ready = false
        local last_train, last_save = 0, 0
        local last_pred = {} -- [id] = { side, body, conf, features, stat_side, stat_body, source }
        local last_resolve = { source = "none", body = 0, conf = 0 }

        local function relu(x) return x > 0 and x or 0 end
        local function relu_d(x) return x > 0 and 1 or 0 end
        local function sigmoid(x)
            x = math.max(-500, math.min(500, x))
            return 1 / (1 + math.exp(-x))
        end
        local function sigmoid_d(x)
            local s = sigmoid(x)
            return s * (1 - s)
        end
        local function tanh_d(x)
            local t = math.tanh(x)
            return 1 - t * t
        end

        local function layer_weight(player, idx)
            if not entity.get_animlayer then return 0 end
            local ok, L = pcall(entity.get_animlayer, player, idx)
            if ok and L and type(L.weight) == "number" then return L.weight end
            return 0
        end

        local function features(player)
            if not player or not entity.is_alive(player) then return nil end
            local as = nil
            if entity.get_animstate then
                local ok, st = pcall(entity.get_animstate, player)
                if ok then as = st end
            end
            local vx, vy = entity.get_prop(player, "m_vecVelocity")
            vx, vy = vx or 0, vy or 0
            local speed2d = math.sqrt(vx * vx + vy * vy)
            local duck = entity.get_prop(player, "m_flDuckAmount") or 0
            local flags = entity.get_prop(player, "m_fFlags") or 0
            local on_ground = bit.band(flags, 1) == 1 and 1 or 0
            local _, eye_yaw = entity.get_prop(player, "m_angEyeAngles")
            eye_yaw = eye_yaw or 0
            -- GS body yaw pose is prop index 11 (not varg internal pose table).
            local pose_body = entity.get_prop(player, "m_flPoseParameter", 11) or 0.5
            local pose_move = entity.get_prop(player, "m_flPoseParameter", 0) or 0
            local pose_speed = entity.get_prop(player, "m_flPoseParameter", 3) or 0
            local pose_stand = entity.get_prop(player, "m_flPoseParameter", 1) or 0

            local vel_x = as and as.velocity_x or vx
            local vel_y = as and as.velocity_y or vy
            local vel_2d = as and as.m_velocity or speed2d
            local vel_cl = as and as.clamped_velocity or speed2d
            local eye_y = as and as.eye_angles_y or eye_yaw
            local gfy = as and as.goal_feet_yaw or eye_y
            local cfy = as and as.current_feet_yaw or eye_y
            local body_d = as and (as.torso_yaw or (gfy - eye_y)) or ((pose_body * 120) - 60)
            local run_a = as and as.run_amount or 0
            local lean = as and as.lean_amount or 0
            local feet_c = as and as.feet_cycle or 0
            local feet_r = as and as.feet_yaw_rate or 0
            local min_y = as and as.min_yaw or -58
            local max_y = as and as.max_yaw or 58
            local magic = as and as.magic_fraction or 0
            local og = as and (as.on_ground and 1 or 0) or on_ground
            local duck_a = as and as.duck_amount or duck

            -- Extra 8 dims from rsv / PE track (normalized).
            local rsv = rsv_players[tostring(player)]
            local mode_conf = rsv and (rsv.mode_confidence or 0.4) or 0.4
            local body_var = rsv and (rsv.body_yaw_variance or 0) or 0
            local hits = rsv and (rsv.body_hit_count or 0) or 0
            local misses = rsv and (rsv.body_miss_count or 0) or 0
            local shot_n = hits + misses
            local hit_rate = shot_n > 0 and (hits / shot_n) or 0.5
            local miss_streak = math.min(1, misses / 8)
            local side_corr = 0
            if rsv and rsv.side_body_correlation then
                local best = 0
                for _, sd in pairs(rsv.side_body_correlation) do
                    local n = sd.samples and #sd.samples or 0
                    if n > best then best = n end
                end
                side_corr = math.min(1, best / 12)
            end
            local rec = track[player]
            local gap_n = rec and math.min(1, (rec.gap_hold or 0) / 16) or 0
            local threat_n = (threat_hold_idx == player) and 1 or 0

            return {
                vel_x / 250, vel_y / 250, vel_2d / 250, vel_cl / 260,
                eye_y / 180, gfy / 180, cfy / 180, body_d / 60,
                duck_a, run_a, og, lean / 30,
                pose_body, pose_move, pose_speed, pose_stand,
                layer_weight(player, 3), layer_weight(player, 6),
                layer_weight(player, 7), layer_weight(player, 12),
                feet_c, feet_r / 5, ((max_y - min_y) / 2) / 60, magic,
                mode_conf, math.min(1, body_var / 60), hit_rate, miss_streak,
                side_corr, gap_n, threat_n, shot_n > 0 and 1 or 0,
            }
        end

        local function expected_sizes()
            local sizes = { CFG.input_size }
            for i = 1, #CFG.hidden do sizes[#sizes + 1] = CFG.hidden[i] end
            sizes[#sizes + 1] = CFG.output_size
            return sizes
        end

        local function weights_compatible(weights, biases)
            if type(weights) ~= "table" or type(biases) ~= "table" then return false end
            local sizes = expected_sizes()
            if #weights ~= (#sizes - 1) or #biases ~= (#sizes - 1) then return false end
            for i = 1, #sizes - 1 do
                local fan_out, fan_in = sizes[i + 1], sizes[i]
                if type(biases[i]) ~= "table" or #biases[i] ~= fan_out then return false end
                if type(weights[i]) ~= "table" or #weights[i] ~= fan_out then return false end
                if type(weights[i][1]) ~= "table" or #weights[i][1] ~= fan_in then return false end
            end
            return true
        end

        local function save_weights()
            if not ready then return end
            local data = {
                version = DB_VERSION,
                weights = net.weights,
                biases = net.biases,
                source_weights = src_w,
                stats = {
                    lr = stats.lr,
                    iters = stats.iters,
                    loss = stats.loss,
                    preds = stats.preds,
                    correct = stats.correct,
                },
            }
            pcall(database.write, DB_KEY, data)
            pcall(function() database.flush() end)
            last_save = globals.realtime()
        end

        local function load_weights()
            local ok, data = pcall(database.read, DB_KEY)
            if not ok or type(data) ~= "table" then return false end
            if data.version ~= DB_VERSION then return false end
            if not weights_compatible(data.weights, data.biases) then return false end
            net.weights, net.biases = data.weights, data.biases
            if type(data.source_weights) == "table" then
                src_w.neural = data.source_weights.neural or src_w.neural
                src_w.stat = data.source_weights.stat or src_w.stat
                src_w.bruteforce = data.source_weights.bruteforce or src_w.bruteforce
            end
            net.w_mom, net.b_mom = {}, {}
            for i = 1, #net.weights do
                net.w_mom[i], net.b_mom[i] = {}, {}
                for j = 1, #net.weights[i] do
                    net.w_mom[i][j] = {}
                    for k = 1, #net.weights[i][j] do
                        net.w_mom[i][j][k] = 0
                    end
                    net.b_mom[i][j] = 0
                end
            end
            if type(data.stats) == "table" then
                stats.lr = data.stats.lr or stats.lr
                stats.iters = data.stats.iters or 0
                stats.loss = data.stats.loss or 0
                stats.preds = data.stats.preds or 0
                stats.correct = data.stats.correct or 0
            end
            return true
        end

        local function init_network()
            if ready then return end
            if load_weights() then
                ready = true
                return
            end
            local sizes = expected_sizes()
            for i = 1, #sizes - 1 do
                local fan_in, fan_out = sizes[i], sizes[i + 1]
                local scale = math.sqrt(2 / fan_in)
                net.weights[i], net.w_mom[i] = {}, {}
                net.biases[i], net.b_mom[i] = {}, {}
                for j = 1, fan_out do
                    net.weights[i][j], net.w_mom[i][j] = {}, {}
                    for k = 1, fan_in do
                        net.weights[i][j][k] = (math.random() * 2 - 1) * scale
                        net.w_mom[i][j][k] = 0
                    end
                    net.biases[i][j] = 0
                    net.b_mom[i][j] = 0
                end
            end
            ready = true
            stats.lr = CFG.lr
        end

        local function forward(input, training)
            if not ready then init_network() end
            if not input or #input ~= CFG.input_size then return nil end
            net.act, net.pre, net.drop = {}, {}, {}
            local current = {}
            for i = 1, #input do current[i] = input[i] or 0 end
            net.act[0] = current
            local nL = #net.weights
            for layer = 1, nL do
                local W, B = net.weights[layer], net.biases[layer]
                local pre, act = {}, {}
                for j = 1, #B do
                    local sum = B[j]
                    for k = 1, #current do sum = sum + W[j][k] * current[k] end
                    pre[j] = sum
                    if layer < nL then
                        act[j] = relu(sum)
                    elseif j == 1 or j == 3 then
                        act[j] = sigmoid(sum)
                    else
                        act[j] = math.tanh(sum)
                    end
                end
                if training and layer < nL then
                    local keep = 1 - CFG.dropout
                    local mask = {}
                    for j = 1, #act do
                        if math.random() < keep then
                            mask[j] = 1 / keep
                            act[j] = act[j] * mask[j]
                        else
                            mask[j] = 0
                            act[j] = 0
                        end
                    end
                    net.drop[layer] = mask
                end
                net.pre[layer], net.act[layer] = pre, act
                current = act
            end
            return current
        end

        local function backward(target, imp)
            if not target or #target ~= CFG.output_size then return 0 end
            local nL = #net.weights
            local lr = stats.lr * (imp or 1)
            local mom = CFG.momentum
            local out = net.act[nL]
            local delta = {}
            local loss = 0
            for j = 1, #out do
                local err = out[j] - target[j]
                loss = loss + err * err
                local pre = net.pre[nL][j]
                if j == 2 then
                    delta[j] = err * tanh_d(pre)
                else
                    delta[j] = err * sigmoid_d(pre)
                end
            end
            loss = loss / #out
            for layer = nL, 1, -1 do
                local inp = net.act[layer - 1]
                local W, B = net.weights[layer], net.biases[layer]
                if net.drop[layer] then
                    for j = 1, #delta do
                        delta[j] = delta[j] * (net.drop[layer][j] or 1)
                    end
                end
                for j = 1, #B do
                    net.b_mom[layer][j] = mom * net.b_mom[layer][j] - lr * delta[j]
                    B[j] = B[j] + net.b_mom[layer][j]
                    for k = 1, #inp do
                        local g = delta[j] * inp[k]
                        net.w_mom[layer][j][k] = mom * net.w_mom[layer][j][k] - lr * g
                        W[j][k] = W[j][k] + net.w_mom[layer][j][k]
                    end
                end
                if layer > 1 then
                    local prev = {}
                    local pre = net.pre[layer - 1]
                    for k = 1, #inp do
                        local s = 0
                        for j = 1, #delta do s = s + delta[j] * W[j][k] end
                        prev[k] = s * relu_d(pre[k])
                    end
                    delta = prev
                end
            end
            return loss
        end

        local function add_exp(input, target, priority)
            priority = (priority or buf.max_p) + CFG.per_eps
            buf.pos = (buf.pos % CFG.replay_size) + 1
            buf.samples[buf.pos] = { input = input, target = target, priority = priority }
            buf.priorities[buf.pos] = priority
            if buf.size < CFG.replay_size then buf.size = buf.size + 1 end
            if priority > buf.max_p then buf.max_p = priority end
        end

        local function sample_batch()
            if buf.size < CFG.min_train then return nil end
            local n = math.min(CFG.batch_size, buf.size)
            local psum = 0
            for i = 1, buf.size do
                psum = psum + (buf.priorities[i] or 1) ^ CFG.per_alpha
            end
            if psum <= 0 then return nil end
            local batch, indices, weights, picked = {}, {}, {}, {}
            local min_prob = (CFG.per_eps ^ CFG.per_alpha) / psum
            local max_w = (buf.size * min_prob) ^ (-CFG.per_beta)
            for _ = 1, n do
                local r, cum = math.random() * psum, 0
                for i = 1, buf.size do
                    if not picked[i] then
                        cum = cum + (buf.priorities[i] or 1) ^ CFG.per_alpha
                        if cum >= r then
                            picked[i] = true
                            batch[#batch + 1] = buf.samples[i]
                            indices[#indices + 1] = i
                            local prob = (buf.priorities[i] or 1) ^ CFG.per_alpha / psum
                            weights[#weights + 1] = ((buf.size * prob) ^ (-CFG.per_beta)) / max_w
                            break
                        end
                    end
                end
            end
            CFG.per_beta = math.min(1, CFG.per_beta + 0.001)
            return batch, indices, weights
        end

        local function train_batch()
            local batch, indices, weights = sample_batch()
            if not batch then return 0 end
            local total, losses = 0, {}
            for i = 1, #batch do
                local exp = batch[i]
                if forward(exp.input, true) then
                    local loss = backward(exp.target, weights[i] or 1)
                    total = total + loss
                    losses[i] = loss
                    buf.priorities[indices[i]] = math.abs(loss) + CFG.per_eps
                    if buf.priorities[indices[i]] > buf.max_p then
                        buf.max_p = buf.priorities[indices[i]]
                    end
                else
                    losses[i] = 0
                end
            end
            local avg = total / #batch
            stats.loss = stats.loss * 0.95 + avg * 0.05
            stats.iters = stats.iters + 1
            stats.lr = math.max(CFG.lr_min, math.min(CFG.lr_max, stats.lr * CFG.lr_decay))
            return avg
        end

        local function predict(player)
            init_network()
            local vec = features(player)
            if not vec then return nil end
            local out = forward(vec, false)
            if not out or #out < 3 then return nil end
            local side_prob, body_n, conf = out[1], out[2], out[3]
            local side = side_prob > 0.5 and 1 or 0
            local body = body_n * 60
            if side == 1 and body < 0 then body = math.abs(body)
            elseif side == 0 and body > 0 then body = -math.abs(body) end
            body = math.max(-60, math.min(60, math.floor(body + 0.5)))
            stats.preds = stats.preds + 1
            return {
                side = side,
                body = body,
                confidence = conf,
                side_probability = side_prob,
                features = vec,
            }
        end

        local function side_align(body, side)
            local b = body or 0
            if side == 1 and b < 0 then b = math.abs(b)
            elseif side == 0 and b > 0 then b = -math.abs(b) end
            return math.max(-60, math.min(60, math.floor(b + 0.5)))
        end

        local function normalize_src_w()
            local sum = (src_w.neural or 0) + (src_w.stat or 0) + (src_w.bruteforce or 0)
            if sum <= 0 then
                src_w.neural, src_w.stat, src_w.bruteforce = 0.45, 0.40, 0.15
                return
            end
            src_w.neural = src_w.neural / sum
            src_w.stat = src_w.stat / sum
            src_w.bruteforce = src_w.bruteforce / sum
        end

        local function nudge_source(source, hit)
            if not source or not src_w[source] then return end
            local lr = CFG.weight_lr
            if hit then
                src_w[source] = math.min(CFG.weight_cap, src_w[source] + lr)
            else
                src_w[source] = math.max(CFG.weight_floor, src_w[source] - lr)
            end
            normalize_src_w()
        end

        -- Slim supreme: override → agree → w*conf vote (caller handles BF hard gate).
        function nn.ensemble(player, stat_side, stat_body, stat_conf)
            local nn_pred = predict(player)
            local preds = {}
            if nn_pred then
                preds[#preds + 1] = {
                    source = "neural",
                    side = nn_pred.side,
                    body = nn_pred.body,
                    confidence = nn_pred.confidence or 0.5,
                }
            end
            if stat_body ~= nil then
                preds[#preds + 1] = {
                    source = "stat",
                    side = stat_side or 0,
                    body = stat_body,
                    confidence = stat_conf or 0.45,
                }
            end

            if #preds == 0 then
                last_resolve = { source = "stat_fallback", body = 0, conf = 0.4 }
                return 0, 0.4, "stat_fallback", nn_pred
            end

            local neural = nn_pred
            if neural and (neural.confidence or 0) >= CFG.conf_high then
                local b = side_align(neural.body, neural.side)
                last_resolve = { source = "neural_override", body = b, conf = neural.confidence }
                return b, neural.confidence, "neural_override", nn_pred
            end

            if neural and #preds >= 2 then
                local st = preds[2]
                if st and st.side == neural.side then
                    local b = side_align(neural.body, neural.side)
                    local conf = math.min(0.95, ((neural.confidence or 0.5) + (st.confidence or 0.45)) * 0.5 + CFG.unanimous_boost)
                    last_resolve = { source = "ensemble_agree", body = b, conf = conf }
                    return b, conf, "ensemble_agree", nn_pred
                end
            end

            if not neural then
                local b = side_align(stat_body, stat_side or 0)
                last_resolve = { source = "stat_fallback", body = b, conf = stat_conf or 0.45 }
                return b, stat_conf or 0.45, "stat_fallback", nil
            end

            -- Weighted vote: effective_weight = source_weight * confidence
            local side_votes = { [0] = 0, [1] = 0 }
            local body_sum, conf_sum, tot = 0, 0, 0
            for i = 1, #preds do
                local p = preds[i]
                local w = (src_w[p.source] or 0.1) * (p.confidence or 0.5)
                side_votes[p.side] = (side_votes[p.side] or 0) + w
                body_sum = body_sum + p.body * w
                conf_sum = conf_sum + p.confidence * w
                tot = tot + w
            end
            if tot <= 0 then
                local b = side_align(stat_body or neural.body, stat_side or neural.side)
                last_resolve = { source = "stat_fallback", body = b, conf = 0.4 }
                return b, 0.4, "stat_fallback", nn_pred
            end
            local final_side = side_votes[1] > side_votes[0] and 1 or 0
            local margin = math.abs(side_votes[1] - side_votes[0]) / tot
            local final_body = side_align(body_sum / tot, final_side)
            local final_conf = conf_sum / tot
            if margin > 0.6 then final_conf = math.min(0.95, final_conf + 0.1) end
            last_resolve = { source = "ensemble", body = final_body, conf = final_conf }
            return final_body, final_conf, "ensemble", nn_pred
        end

        -- Kept for compatibility; prefer nn.ensemble.
        function nn.combine(player, body, conf, side)
            return nn.ensemble(player, side, body, conf)
        end

        function nn.remember(player, side, body, conf, nn_pred, stat_side, stat_body, source)
            last_pred[tostring(player)] = {
                side = side,
                body = body,
                confidence = conf,
                features = nn_pred and nn_pred.features or features(player),
                stat_side = stat_side,
                stat_body = stat_body,
                source = source or (last_resolve and last_resolve.source) or "ensemble",
            }
            if source then
                last_resolve = { source = source, body = body or 0, conf = conf or 0 }
            end
        end

        function nn.record(player, hit)
            local pred = last_pred[tostring(player)]
            if not pred or not pred.features then return end
            local side = pred.side or 0
            local body = pred.body or 0
            local target
            if hit then
                if pred.stat_body ~= nil then
                    side = pred.stat_side or side
                    body = pred.stat_body
                end
                target = { side, body / 60, 1.0 }
                stats.correct = stats.correct + 1
            else
                target = { 1 - side, -body / 60, 0.3 }
            end
            add_exp(pred.features, target, hit and 1.0 or 2.0)
            local src = pred.source
            if src == "neural_override" or src == "ensemble_agree" or src == "ensemble" then
                src = "neural"
            elseif src == "stat_fallback" then
                src = "stat"
            end
            nudge_source(src, hit)
        end

        function nn.last()
            return last_resolve
        end

        function nn.bruteforce_gate(player)
            local data = rsv_players[tostring(player)]
            if not data then return false end
            return (data.body_miss_count or 0) >= CFG.bf_miss_threshold
                and (data.body_hit_count or 0) < (data.body_miss_count or 0)
        end

        function nn.tick()
            if not resolver_enabled() then return end
            init_network()
            local now = globals.realtime()
            if now - last_train >= CFG.train_interval then
                train_batch()
                last_train = now
            end
            if now - last_save >= CFG.save_interval then
                save_weights()
            end
        end

        function nn.save()
            save_weights()
        end

        function nn.clear_preds()
            last_pred = {}
            last_resolve = { source = "none", body = 0, conf = 0 }
        end
    end

    local function read_body_yaw(ent)
        local pose = entity.get_prop(ent, "m_flPoseParameter", 11)
        if pose == nil then return nil end
        return fclamp(pose * 120 - 60, -60, 60)
    end

    local function read_eye_yaw(ent)
        local _, yaw = entity.get_prop(ent, "m_angEyeAngles")
        return yaw
    end

    local function rsv_init(player)
        local id = tostring(player)
        local data = rsv_players[id]
        if data then return data end
        data = {
            body_samples = {},
            desync_samples = {},
            side_body_correlation = {},
            avg_body_yaw = 0,
            body_yaw_variance = 0,
            detected_mode = "unknown",
            mode_confidence = 0.4,
            body_follows_side = false,
            body_opposes_side = false,
            last_body_direction = 0,
            consecutive_same_body = 0,
            last_body_change = 0,
            body_change_intervals = {},
            bruteforce_body_stage = 0,
            body_hit_count = 0,
            body_miss_count = 0,
            body_offset_weights = {},
            last_bf_offset = nil,
            last_pose = nil,
            last_update = 0,
        }
        rsv_players[id] = data
        return data
    end

    -- Samples are appended oldest-first, so stale entries sit at the front.
    local function rsv_prune_front(list, now)
        while list[1] and (now - (list[1].time or 0)) > RSV_STALE_S do
            table.remove(list, 1)
        end
    end

    local function rsv_recompute_side(sd)
        local n = #sd.samples
        if n < 1 then sd.avg, sd.variance = 0, 0 return end
        local sum = 0
        for _, s in ipairs(sd.samples) do sum = sum + s.desync end
        sd.avg = sum / n
        local var_sum = 0
        for _, s in ipairs(sd.samples) do var_sum = var_sum + (s.desync - sd.avg) ^ 2 end
        sd.variance = var_sum / n
    end

    local function rsv_sample(player)
        local body = read_body_yaw(player)
        local eye = read_eye_yaw(player)
        if body == nil or eye == nil then return end
        local data = rsv_init(player)
        local now = globals.realtime()
        local desync = aa_clamp(body - eye)
        local side = desync > 0 and 1 or 0

        data.body_samples[#data.body_samples + 1] = {
            value = body, desync = desync, eye_yaw = eye, side = side, time = now,
        }
        data.desync_samples[#data.desync_samples + 1] = {
            value = desync, side = side, time = now,
        }
        while #data.body_samples > 65 do table.remove(data.body_samples, 1) end
        while #data.desync_samples > 65 do table.remove(data.desync_samples, 1) end
        rsv_prune_front(data.body_samples, now)
        rsv_prune_front(data.desync_samples, now)

        local side_data = data.side_body_correlation[side]
        if not side_data then
            side_data = { samples = {}, avg = 0, variance = 0 }
            data.side_body_correlation[side] = side_data
        end
        side_data.samples[#side_data.samples + 1] = { body = body, desync = desync, time = now }
        while #side_data.samples > 30 do table.remove(side_data.samples, 1) end
        rsv_prune_front(side_data.samples, now)
        rsv_recompute_side(side_data)
        -- Age out the side(s) not touched this sample so a stopped jitter fades.
        for s, sd in pairs(data.side_body_correlation) do
            if s ~= side then
                local before = #sd.samples
                rsv_prune_front(sd.samples, now)
                if #sd.samples ~= before then rsv_recompute_side(sd) end
            end
        end

        local body_direction = desync > 0 and 1 or -1
        if body_direction ~= data.last_body_direction and data.last_body_direction ~= 0 then
            if data.last_body_change > 0 then
                data.body_change_intervals[#data.body_change_intervals + 1] = now - data.last_body_change
                while #data.body_change_intervals > 25 do table.remove(data.body_change_intervals, 1) end
            end
            data.last_body_change = now
            data.consecutive_same_body = 0
        else
            data.consecutive_same_body = data.consecutive_same_body + 1
        end
        data.last_body_direction = body_direction
        data.last_pose = body
        data.last_update = now
    end

    local function rsv_analyze_mode(player)
        local data = rsv_players[tostring(player)]
        if not data or #data.desync_samples < 4 then
            return "unknown", 0.4
        end
        local samples = data.desync_samples
        local n = #samples
        local values = {}
        for i = math.max(1, n - 20), n do
            values[#values + 1] = samples[i].value
        end
        if #values < 4 then return "unknown", 0.4 end

        local sum, min_v, max_v = 0, values[1], values[1]
        for _, v in ipairs(values) do
            sum = sum + v
            if v < min_v then min_v = v end
            if v > max_v then max_v = v end
        end
        local mean = sum / #values
        local range = max_v - min_v
        data.avg_body_yaw = mean

        local var_sum = 0
        for _, v in ipairs(values) do var_sum = var_sum + (v - mean) ^ 2 end
        local variance = var_sum / #values
        local std_dev = math.sqrt(variance)
        data.body_yaw_variance = variance
        local cv = std_dev / math.max(1, math.abs(mean))

        local positive_count, negative_count = 0, 0
        for _, v in ipairs(values) do
            if v > 10 then positive_count = positive_count + 1
            elseif v < -10 then negative_count = negative_count + 1 end
        end

        local direction_changes, last_sign = 0, nil
        for _, v in ipairs(values) do
            local sign = v > 5 and 1 or (v < -5 and -1 or 0)
            if sign ~= 0 and last_sign and sign ~= last_sign then
                direction_changes = direction_changes + 1
            end
            if sign ~= 0 then last_sign = sign end
        end
        local change_rate = direction_changes / math.max(1, #values - 1)

        local side_correlated, correlation_strength = false, 0
        local side0, side1 = data.side_body_correlation[0], data.side_body_correlation[1]
        if side0 and side1 and #side0.samples >= 3 and #side1.samples >= 3 then
            local side_diff = math.abs(side0.avg - side1.avg)
            if side_diff > 40 then
                side_correlated = true
                correlation_strength = math.min(1.0, side_diff / 100)
            end
            if (side0.avg > 20 and side1.avg < -20) or (side0.avg < -20 and side1.avg > 20) then
                data.body_follows_side, data.body_opposes_side = false, true
            elseif (side0.avg < -20 and side1.avg < -20) or (side0.avg > 20 and side1.avg > 20) then
                data.body_follows_side, data.body_opposes_side = false, false
            else
                data.body_follows_side, data.body_opposes_side = true, false
            end
        end

        local mode_scores = { static = 0, jitter = 0, opposite = 0, synced = 0, random = 0 }
        if range < 25 and std_dev < 12 then
            mode_scores.static = 0.85 - range * 0.01
            if std_dev < 6 then mode_scores.static = mode_scores.static + 0.10 end
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
            if change_rate < 0.30 then mode_scores.opposite = mode_scores.opposite + 0.10 end
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

        local best_mode, best_score = "unknown", 0.35
        for mode, score in pairs(mode_scores) do
            if score > best_score then best_score, best_mode = score, mode end
        end
        if #values < 8 then best_score = best_score * 0.75
        elseif #values < 12 then best_score = best_score * 0.88
        elseif #values >= 18 then best_score = math.min(0.92, best_score * 1.05) end

        data.detected_mode = best_mode
        data.mode_confidence = fclamp(best_score, 0.30, 0.92)
        return best_mode, data.mode_confidence
    end

    local function rsv_predict_side(player)
        local data = rsv_players[tostring(player)]
        if not data or #data.desync_samples == 0 then return 1, 0.4 end
        local last = data.desync_samples[#data.desync_samples]
        local side = last.side or (last.value > 0 and 1 or 0)
        -- Prefer majority of recent samples when jittery.
        local pos, neg = 0, 0
        local n = #data.desync_samples
        for i = math.max(1, n - 8), n do
            if data.desync_samples[i].value > 5 then pos = pos + 1
            elseif data.desync_samples[i].value < -5 then neg = neg + 1 end
        end
        if pos ~= neg then side = pos > neg and 1 or 0 end
        return side, 0.55
    end

    -- Shared BF ladder pick: highest learned weight, tie-broken by the rotating
    -- stage so behavior is identical until weights diverge. Returns aligned
    -- offset + the stage used (for the caller's confidence formula).
    local function rsv_next_bf_offset(data, side)
        local n = #BF_OFFSETS
        local stage = data and data.bruteforce_body_stage or 0
        local best_i = (stage % n) + 1
        local weights = data and data.body_offset_weights
        if weights then
            local best_w = weights[BF_OFFSETS[best_i]] or 1.0
            for i = 1, n do
                local w = weights[BF_OFFSETS[i]] or 1.0
                if w > best_w + 1e-6 then best_w, best_i = w, i end
            end
        end
        local off = BF_OFFSETS[best_i]
        if side == 1 and off < 0 then off = -off
        elseif side == 0 and off > 0 then off = -off end
        off = math.max(-60, math.min(60, math.floor(off + 0.5)))
        if data then
            data.bruteforce_body_stage = stage + 1
            data.last_bf_offset = off
        end
        return off, stage
    end

    local function rsv_predict(player, predicted_side, allow_bf)
        if allow_bf == nil then allow_bf = true end
        local data = rsv_players[tostring(player)]
        if not data then return 0, 0.4, "default" end

        -- Pose seed: cold records use live pose instead of ±58 default.
        if rsv_has_imp("Pose seed") and #data.body_samples < 3 then
            local pose = data.last_pose or read_body_yaw(player)
            if pose ~= nil then
                local body = math.max(-60, math.min(60, math.floor(pose + 0.5)))
                return body, 0.50, "pose_seed"
            end
        end

        local mode, mode_conf = rsv_analyze_mode(player)
        local predicted_body, confidence, method = 0, 0.45, "default"

        -- BF inside predict only when allow_bf (ensemble uses hard gate outside).
        if allow_bf and data.body_miss_count >= 2 and data.body_hit_count < data.body_miss_count then
            local predicted_body, stage = rsv_next_bf_offset(data, predicted_side)
            return predicted_body, fclamp(0.42 - stage * 0.02, 0.25, 0.55), "bruteforce"
        end

        if mode == "static" then
            predicted_body = data.avg_body_yaw
            if predicted_side == 1 and predicted_body < 20 then predicted_body = math.max(predicted_body, 45)
            elseif predicted_side == 0 and predicted_body > -20 then predicted_body = math.min(predicted_body, -45) end
            confidence, method = mode_conf * 0.95, "static"
        elseif mode == "jitter" or mode == "opposite" or mode == "synced" then
            local side_data = data.side_body_correlation[predicted_side]
            if side_data and #side_data.samples >= 2 then
                predicted_body = side_data.avg
                confidence = mode_conf * (mode == "opposite" and 0.90 or mode == "jitter" and 0.88 or 0.85)
            else
                predicted_body = predicted_side == 1 and 58 or -58
                confidence = mode_conf * 0.72
            end
            method = mode
        elseif mode == "random" then
            local side_data = data.side_body_correlation[predicted_side]
            if side_data and #side_data.samples >= 2 then
                predicted_body, confidence, method = side_data.avg, mode_conf * 0.75, "learned_random"
            else
                predicted_body = predicted_side == 1 and 58 or -58
                confidence, method = mode_conf * 0.55, "random_default"
            end
        else
            predicted_body = data.last_pose or (predicted_side == 1 and 58 or -58)
            confidence, method = 0.45, "unknown"
        end

        if predicted_side == 1 then
            if predicted_body <= 0 then predicted_body = 58
            elseif predicted_body < 45 then predicted_body = 58 end
        else
            if predicted_body >= 0 then predicted_body = -58
            elseif predicted_body > -45 then predicted_body = -58 end
        end
        predicted_body = math.max(-60, math.min(60, math.floor(predicted_body + 0.5)))
        return predicted_body, fclamp(confidence, 0.25, 0.92), method
    end

    local function rsv_probe_value_key(player, body)
        if rsv_value_key then
            pcall(function() plist.set(player, rsv_value_key, body) end)
            return
        end
        local ok = pcall(function() plist.set(player, "Force body yaw value", body) end)
        if ok then
            rsv_value_key = "Force body yaw value"
            return
        end
        ok = pcall(function() plist.set(player, "Body yaw value", body) end)
        if ok then rsv_value_key = "Body yaw value" end
    end

    local function rsv_apply(player, body)
        if not plist or type(plist.set) ~= "function" then return end
        pcall(function() plist.set(player, "Force body yaw", true) end)
        rsv_probe_value_key(player, body)
        rsv_touched[player] = true
    end

    local function rsv_clear(player)
        if not plist or type(plist.set) ~= "function" then return end
        pcall(function()
            plist.set(player, "Force body yaw", false)
            plist.set(player, rsv_value_key or "Force body yaw value", 0)
        end)
        rsv_touched[player] = nil
    end

    local function rsv_clear_all()
        for player in pairs(rsv_touched) do
            rsv_clear(player)
        end
        rsv_touched = {}
    end

    local function rsv_run_apply()
        local players = entity.get_players(true)
        if not players then return end
        local me = entity.get_local_player()
        local bias = rsv_has_imp("Extrapolation bias")
        local gate = rsv_has_imp("Confidence gate")
        local seen = {}

        -- Closest alive enemy with PE choke gap (for Extrapolation bias).
        local threat_idx = nil
        if bias and me then
            local mx, my, mz = entity.get_origin(me)
            local best_d2 = nil
            if mx then
                for i = 1, #players do
                    local idx = players[i]
                    local rec = track[idx]
                    if rec and (rec.gap_hold or 0) > 0
                        and entity.is_alive(idx) and not entity.is_dormant(idx) then
                        local ox, oy, oz = entity.get_origin(idx)
                        if ox then
                            local dx, dy, dz = ox - mx, oy - my, oz - mz
                            local d2 = dx * dx + dy * dy + dz * dz
                            if not best_d2 or d2 < best_d2 then
                                best_d2, threat_idx = d2, idx
                            end
                        end
                    end
                end
            end
        end

        local order = {}
        if threat_idx then order[1] = threat_idx end
        for i = 1, #players do
            local idx = players[i]
            if idx ~= threat_idx then order[#order + 1] = idx end
        end

        for oi = 1, #order do
            local idx = order[oi]
            if entity.is_alive(idx) and not entity.is_dormant(idx) then
                seen[idx] = true
                if not rsv_players[tostring(idx)] then rsv_sample(idx) end
                local data = rsv_players[tostring(idx)]
                local side, side_conf = rsv_predict_side(idx)
                if bias and idx == threat_idx then
                    side_conf = math.min(0.95, (side_conf or 0.55) + 0.12)
                    -- Choke window: the freshest observed desync is the best side
                    -- signal, so let it flip the vote, not just bump confidence.
                    local fresh = data and data.last_body_direction or 0
                    if fresh ~= 0 then
                        side = fresh > 0 and 1 or 0
                        side_conf = math.max(side_conf, 0.75)
                    end
                end

                local body, conf, source, nn_pred

                -- Supreme-style: miss-streak BF hard gate before neural/stat.
                if nn.bruteforce_gate(idx) then
                    local stage
                    body, stage = rsv_next_bf_offset(data, side)
                    conf = fclamp(0.42 - stage * 0.02, 0.25, 0.55)
                    source = "bruteforce"
                    nn.remember(idx, side, body, conf, nil, side, body, "bruteforce")
                else
                    local stat_body, stat_conf = rsv_predict(idx, side, false)
                    stat_conf = (stat_conf or 0.45) * 0.7 + (side_conf or 0.55) * 0.3
                    body, conf, source, nn_pred = nn.ensemble(idx, side, stat_body, stat_conf)
                    nn.remember(idx, side, body, conf, nn_pred, side, stat_body, source)
                end

                -- PE motion confidence scales apply conf; a low value can suppress.
                local motion_conf = fclamp(1 - (track[idx] and track[idx].err_ema or 0), 0, 1)
                conf = conf * (0.6 + 0.4 * motion_conf)

                if gate then
                    if motion_conf >= MOTION_FLOOR then
                        local mode = data and data.detected_mode or "unknown"
                        local floor = (mode == "static") and 0.35 or 0.28
                        if conf >= floor then
                            rsv_apply(idx, body)
                        end
                    end
                    -- else: PE too unsure to force a new body this tick (seen[idx] kept).
                else
                    rsv_apply(idx, body)
                end
            end
        end
        for player in pairs(rsv_touched) do
            if not seen[player] then rsv_clear(player) end
        end
    end

    -- Gravity + trace step with optional seeded XY velocity (accel midpoint).
    local function predict_origin(ox, oy, oz, svx, svy, vz, ticks)
        if ticks < 1 then ticks = 1 end
        if ticks > MAX_TICKS then ticks = MAX_TICKS end
        local tickinterval = ti()
        local grav = (cvar.sv_gravity:get_float() or 800) * tickinterval
        local jump = (cvar.sv_jump_impulse:get_float() or 301.993) * tickinterval
        local gravity = vz > 0 and -grav or jump
        local p = { ox, oy, oz }
        local prev = p
        for _ = 1, ticks do
            prev = p
            p = {
                p[1] + svx * tickinterval,
                p[2] + svy * tickinterval,
                p[3] + (vz + gravity) * tickinterval,
            }
            local fraction = client.trace_line(-1, prev[1], prev[2], prev[3], p[1], p[2], p[3])
            if fraction and fraction <= 0.99 then
                return prev, true
            end
        end
        return p, false
    end

    local function set_pinned(on)
        -- Refuse new pins. Only restore if a previous session left us pinned.
        if on then return end
        if not pinned and saved_interp == nil and saved_ratio == nil then return end
        pinned = false
        if saved_interp then cvar.cl_interp:set_raw_float(saved_interp) end
        if saved_ratio then cvar.cl_interp_ratio:set_raw_float(saved_ratio) end
        saved_interp, saved_ratio = nil, nil
    end

    local function full_reset()
        pcall(set_pinned, false)
        rsv_clear_all()
        rsv_players = {}
        rsv_was_on = false
        track = {}
        decision = nil
        threat_hold_idx, threat_hold_rt = nil, nil
        pcall(nn.save)
        nn.clear_preds()
    end

    local function confidence(rec)
        local conf = 1 - (rec.err_ema or 0)
        if conf < 0 then conf = 0 end
        if conf > 1 then conf = 1 end
        -- Keep a floor share even when prediction error is high.
        return CONF_FLOOR + (1 - CONF_FLOOR) * conf
    end

    local function record_stale(rec, now)
        local accepted = rec.accepted_rt or 0
        local updated = rec.updated_rt or accepted
        if now - accepted <= STALE_S then return false end
        -- Choke heartbeat: same-sim packet touch keeps the record alive.
        local expect = ((rec.gap_hold or 0) + 4) * ti() + 0.25
        return now - updated > expect
    end

    local function pick_threat(me)
        local now = globals.realtime()
        local mx, my, mz = entity.get_origin(me)
        if not mx then return nil end
        local best_idx, best_d2 = nil, nil
        local players = entity.get_players(true)
        if players then
            for i = 1, #players do
                local idx = players[i]
                if entity.is_alive(idx) and not entity.is_dormant(idx) then
                    local ox, oy, oz = entity.get_origin(idx)
                    if ox then
                        local dx, dy, dz = ox - mx, oy - my, oz - mz
                        local d2 = dx * dx + dy * dy + dz * dz
                        if not best_d2 or d2 < best_d2 then
                            best_d2, best_idx = d2, idx
                        end
                    end
                end
            end
        end
        if best_idx then
            threat_hold_idx, threat_hold_rt = best_idx, now
            return best_idx
        end
        if threat_hold_idx and now - (threat_hold_rt or 0) <= THREAT_HOLD_S then
            return threat_hold_idx
        end
        threat_hold_idx, threat_hold_rt = nil, nil
        return nil
    end

    local function on_net_update()
        if not pe_enabled() then
            if next(track) or pinned then full_reset() end
            return
        end
        local me = entity.get_local_player()
        if not me or not entity.is_alive(me) then return end

        local now = globals.realtime()
        local ping_t = ping_ticks()
        local players = entity.get_players(true)
        local seen = {}

        if players then
            for i = 1, #players do
                local idx = players[i]
                if entity.is_alive(idx) and not entity.is_dormant(idx) then
                    seen[idx] = true
                    if resolver_enabled() then
                        rsv_sample(idx)
                    end
                    local ox, oy, oz = entity.get_origin(idx)
                    local vx, vy, vz = entity.get_prop(idx, "m_vecVelocity")
                    local sim = entity.get_prop(idx, "m_flSimulationTime")
                    if ox and sim then
                        vx, vy, vz = vx or 0, vy or 0, vz or 0
                        local sim_tick = time_to_ticks(sim)
                        local rec = track[idx]
                        if not rec then
                            rec = {
                                sim = sim_tick, origin = { ox, oy, oz },
                                vx = vx, vy = vy, vz = vz,
                                ax = 0, ay = 0, err_ema = 0,
                                gap_ticks = 0, gap_hold = 0, gap_hold_rt = 0,
                                accepted_rt = now, updated_rt = now,
                                steer_ok = false, collided = false, pred_pos = nil,
                            }
                            track[idx] = rec
                        else
                            local gap = sim_tick - (rec.sim or sim_tick)
                            if gap < 0 or gap > 64 then
                                -- Teleport / tickbase: cold restart.
                                rec.sim = sim_tick
                                rec.origin = { ox, oy, oz }
                                rec.vx, rec.vy, rec.vz = vx, vy, vz
                                rec.ax, rec.ay = 0, 0
                                rec.err_ema = 0
                                rec.gap_ticks, rec.gap_hold = 0, 0
                                rec.accepted_rt, rec.updated_rt = now, now
                                rec.steer_ok, rec.collided, rec.pred_pos = false, false, nil
                            else
                                if gap > 0 then
                                    -- Accel EMA from velocity delta over the gap.
                                    local dt = gap * ti()
                                    if dt > 0 then
                                        local nax = (vx - rec.vx) / dt
                                        local nay = (vy - rec.vy) / dt
                                        rec.ax = (rec.ax or 0) + ACCEL_ALPHA * (nax - (rec.ax or 0))
                                        rec.ay = (rec.ay or 0) + ACCEL_ALPHA * (nay - (rec.ay or 0))
                                    end
                                    -- Prediction error vs last pred (soft confidence).
                                    if rec.pred_pos then
                                        local dx = ox - rec.pred_pos[1]
                                        local dy = oy - rec.pred_pos[2]
                                        local dz = oz - rec.pred_pos[3]
                                        local err = math.sqrt(dx * dx + dy * dy + dz * dz)
                                        local soft = err / (err + ERR_K)
                                        rec.err_ema = (rec.err_ema or 0) + ERR_ALPHA * (soft - (rec.err_ema or 0))
                                    end
                                    rec.gap_ticks = gap
                                    if gap >= (rec.gap_hold or 0) then
                                        rec.gap_hold = gap
                                        rec.gap_hold_rt = now
                                    elseif now - (rec.gap_hold_rt or 0) > GAP_HOLD_S then
                                        rec.gap_hold = gap
                                        rec.gap_hold_rt = now
                                    end
                                end
                                rec.sim = sim_tick
                                rec.origin = { ox, oy, oz }
                                rec.vx, rec.vy, rec.vz = vx, vy, vz
                                rec.updated_rt = now
                                if gap > 0 then rec.accepted_rt = now end

                                local moving = len2d(vx, vy) >= MIN_SPEED or math.abs(vz) > 10
                                local lag = rec.gap_hold or 0
                                if moving and lag > 0 then
                                    local horizon = lag + ping_t
                                    if horizon < 1 then horizon = 1 end
                                    if horizon > MAX_TICKS then horizon = MAX_TICKS end
                                    -- Seed with midpoint accel so peekers keep accelerating into the horizon.
                                    local t = ti() * horizon
                                    local svx = vx + (rec.ax or 0) * t * 0.5
                                    local svy = vy + (rec.ay or 0) * t * 0.5
                                    local sp = len2d(svx, svy)
                                    if sp > SPEED_CAP then
                                        local s = SPEED_CAP / sp
                                        svx, svy = svx * s, svy * s
                                    end
                                    local pred, collided = predict_origin(ox, oy, oz, svx, svy, vz, horizon)
                                    rec.pred_pos = pred
                                    rec.collided = collided
                                    rec.steer_ok = not collided
                                    rec.reject_reason = collided and "collision" or nil
                                else
                                    rec.pred_pos = nil
                                    rec.collided = false
                                    rec.steer_ok = false
                                    rec.reject_reason = moving and "no_choke_gap" or "low_movement"
                                    if not moving then rec.ax, rec.ay = 0, 0 end
                                end
                            end
                        end
                    end
                end
            end
        end

        for idx in pairs(track) do
            if not seen[idx] then
                track[idx] = nil
                rsv_players[tostring(idx)] = nil
                if rsv_has_imp("Strict clear") then
                    rsv_clear(idx)
                end
            end
        end
    end

    local function desired_window(me)
        local tick = globals.tickcount()
        if decision and decision.tick == tick then return decision end
        local d = { tick = tick, effective_ticks = 0, reason = "warming_up" }
        local threat_idx = pick_threat(me)
        local rec = threat_idx and track[threat_idx] or nil
        if not rec then
            d.reason = "no_threat_record"
            decision = d
            return d
        end
        local now = globals.realtime()
        if not rec.steer_ok then
            d.reason = rec.reject_reason or "warming_up"
            decision = d
            return d
        end
        if record_stale(rec, now) then
            rec.steer_ok = false
            rec.reject_reason = "stale_sim"
            d.reason = "stale_sim"
            decision = d
            return d
        end
        if len2d(rec.vx, rec.vy) < MIN_SPEED and math.abs(rec.vz or 0) <= 10 then
            d.reason = "low_movement"
            decision = d
            return d
        end
        if rec.collided then
            d.reason = "collision_rejected"
            decision = d
            return d
        end
        local lag = rec.gap_hold or 0
        if lag <= 0 then
            d.reason = "no_choke_gap"
            decision = d
            return d
        end
        local conf = confidence(rec)
        if conf < CONF_MIN then
            d.reason = "low_confidence"
            decision = d
            return d
        end
        local horizon = lag + ping_ticks()
        if horizon < 1 then horizon = 1 end
        if horizon > MAX_TICKS then horizon = MAX_TICKS end
        -- Confidence shrinks the applied window share.
        local applied = math.max(1, math.floor(horizon * conf + 0.5))
        if applied > MAX_TICKS then applied = MAX_TICKS end
        d.effective_ticks = applied
        d.reason = "threat_qualified"
        decision = d
        return d
    end

    local function on_steer()
        if not pe_enabled() then
            if pinned or next(track) or rsv_was_on or next(rsv_touched) then full_reset() end
            return
        end
        local me = entity.get_local_player()
        if not me or not entity.is_alive(me) then
            pcall(set_pinned, false)
            if rsv_was_on then
                rsv_clear_all()
                rsv_was_on = false
            end
            return
        end
        local win = desired_window(me)
        if win.effective_ticks >= 1 then
            pcall(set_pinned, true)
        else
            -- Always-on baseline: pin for any live enemy when smart window is idle.
            pcall(set_pinned, has_live_enemy())
        end

        local rsv_on = resolver_enabled()
        if rsv_on then
            rsv_was_on = true
            rsv_run_apply()
            nn.tick()
        elseif rsv_was_on then
            rsv_clear_all()
            rsv_was_on = false
            pcall(nn.save)
            nn.clear_preds()
        end
    end

    client.set_event_callback("net_update_end", on_net_update)
    client.set_event_callback("setup_command", on_steer)
    client.set_event_callback("shutdown", full_reset)
    client.set_event_callback("round_prestart", full_reset)
    client.set_event_callback("level_init", full_reset)
    -- level_init is too late for a new server: userinfo (cl_interp) is sent
    -- during the connect handshake, so a raw-pinned 0 from the previous map
    -- would become our "real" interp on the new server. Unpin at disconnect.
    client.set_event_callback("cs_game_disconnected", full_reset)

    client.set_event_callback("aim_hit", function(e)
        if not resolver_enabled() or not rsv_has_imp("Hit feedback") then return end
        if not e or not e.target then return end
        nn.record(e.target, true)
        local data = rsv_init(e.target)
        data.body_hit_count = (data.body_hit_count or 0) + 1
        data.bruteforce_body_stage = 0
        -- Credit the offset that connected so BF prefers it next cycle.
        if data.last_bf_offset ~= nil then
            local o = data.last_bf_offset
            data.body_offset_weights[o] = math.min(RSV_WEIGHT_CAP, (data.body_offset_weights[o] or 1.0) * 1.15)
            data.last_bf_offset = nil
        end
        -- Boost side weight via a synthetic correlated sample.
        local side = rsv_predict_side(e.target)
        local side_data = data.side_body_correlation[side]
        if not side_data then
            side_data = { samples = {}, avg = side == 1 and 58 or -58, variance = 0 }
            data.side_body_correlation[side] = side_data
        end
        local hit_body = side == 1 and math.max(side_data.avg or 58, 45) or math.min(side_data.avg or -58, -45)
        side_data.samples[#side_data.samples + 1] = {
            body = hit_body, desync = hit_body, time = globals.realtime(),
        }
        while #side_data.samples > 30 do table.remove(side_data.samples, 1) end
        local sum = 0
        for _, s in ipairs(side_data.samples) do sum = sum + s.desync end
        side_data.avg = sum / #side_data.samples
    end)

    client.set_event_callback("aim_miss", function(e)
        if not resolver_enabled() or not rsv_has_imp("Hit feedback") then return end
        if not e or not e.target then return end
        -- Count resolver-ish misses; skip pure spread/death.
        local reason = e.reason
        if reason == "spread" or reason == "death" then return end
        nn.record(e.target, false)
        local data = rsv_init(e.target)
        data.body_miss_count = (data.body_miss_count or 0) + 1
        -- Penalize the offset that missed so BF stops preferring it.
        if data.last_bf_offset ~= nil then
            local o = data.last_bf_offset
            data.body_offset_weights[o] = math.max(RSV_WEIGHT_FLOOR, (data.body_offset_weights[o] or 1.0) * 0.85)
            data.last_bf_offset = nil
        end
    end)

end
init_predict_enemies()

local function init_grenade_esp()
    local csgo_weapons = require("gamesense/csgo_weapons")
    local images = require("gamesense/images")

    local function get_menu_value(key)
        if not key then return false end
        local ok, v = pcall(function() 
            if type(key) == "table" and key.get then return key:get() end
            return key
        end)
        return ok and v or false
    end

    local function round(num, numDecimalPlaces)
        local mult = 10^(numDecimalPlaces or 0)
        return math.floor(num * mult + 0.5) / mult
    end

    local function table_contains(tbl, element)
        if not tbl then return false end
        for _, value in pairs(tbl) do
            if value == element then
                return true
            end
        end
        return false
    end

    local function average(t) 
        if not t or #t == 0 then return 0 end
        local sum = 0
        for _,v in pairs(t) do sum = sum + v end
        return sum / #t
    end

    local function safe_icon(name)
        if not images or not images.get_weapon_icon then
            return { measure = function() return 0, 0 end, draw = function() end }
        end
        local ok, icon = pcall(images.get_weapon_icon, name)
        if not ok or not icon then
            return { measure = function() return 0, 0 end, draw = function() end }
        end
        return icon
    end

    local player_items = {}

    client.set_event_callback("level_init", function()
        player_items = {}
    end)

    client.set_event_callback("player_death", function(e)
        if not e or not e.userid then return end
        player_items[client.userid_to_entindex(e.userid)] = {}
    end)

    client.set_event_callback("player_spawn", function(e)
        if not e or not e.userid then return end
        player_items[client.userid_to_entindex(e.userid)] = {}
    end)

    local nadenames = {
        "weapon_molotov",
        "weapon_smokegrenade",
        "weapon_hegrenade",
        "weapon_incgrenade"
    }

    local icons = {
        moly = safe_icon(nadenames[1]),
        smoke = safe_icon(nadenames[2]),
        nade = safe_icon(nadenames[3]),
        incin = safe_icon(nadenames[4]),
    }

    local function measure_icon(icon)
        if not icon or not icon.measure then return 0, 0 end
        local ok, w, h = pcall(icon.measure, icon)
        if not ok or not w or not h then return 0, 0 end
        return w, h
    end

    local sizes = {
        nade = { measure_icon(icons.nade) },
        smoke = { measure_icon(icons.smoke) },
        moly = { measure_icon(icons.moly) },
        incin = { measure_icon(icons.incin) },
    }

    for k, v in pairs(sizes) do
        sizes[k][1] = math.floor((v[1] or 0) * 0.4)
        sizes[k][2] = math.floor((v[2] or 0) * 0.4)
    end

    client.set_event_callback("item_remove", function(e)
        if not e or not e.userid then return end
        local plyr = client.userid_to_entindex(e.userid)
        if not plyr then return end
        if entity.is_enemy(plyr) then
            if player_items[plyr] ~= nil then
                local weapon = "weapon_".. tostring(e.item or "")
                local newtable = {}
                for i, v in ipairs(player_items[plyr] or {}) do
                    if v ~= weapon then 
                        table.insert(newtable, v)
                    end
                end
                player_items[plyr] = newtable 
            else
                player_items[plyr] = {}
            end
        end
    end)

    client.set_event_callback("item_pickup", function(e)
        if not e or not e.userid then return end
        local plyr = client.userid_to_entindex(e.userid)
        if not plyr then return end
        if entity.is_enemy(plyr) then
            player_items[plyr] = player_items[plyr] or {}
            local weapon = "weapon_".. tostring(e.item or "")
            if table_contains(nadenames, weapon) then
                table.insert(player_items[plyr], weapon)
            end
        end
    end)

    client.set_event_callback("paint", function()
        local show = get_menu_value(menu and menu.visuals and menu.visuals.grenadeesp)
        if not show then return end

        local teamcheck = false
        local localplayer = entity.get_local_player()
        local obsmode = entity.get_prop(localplayer, "m_iObserverMode")
        if not entity.is_alive(localplayer) then
            if obsmode == 4 or obsmode == 5 then
                local obs = entity.get_prop(localplayer, "m_hObserverTarget")
                if obs and entity.is_enemy(obs) then
                    teamcheck = true
                end
            end
        end

        local player_recources = entity.get_player_resource()
        for player = 1, globals.maxplayers() do
            if player_recources and entity.get_prop(player_recources, 'm_bConnected', player) == 1 then
                if (entity.is_enemy(player) and not teamcheck) or (not entity.is_enemy(player) and teamcheck) then
                    player_items[player] = player_items[player] or {}

                    if entity.is_alive(player) and not entity.is_dormant(player) then
                        local weapons = {}
                        for index = 0, 64 do
                            local a = entity.get_prop(player, "m_hMyWeapons", index)
                            if a ~= nil then
                                local ok, wep = pcall(csgo_weapons, a)
                                if ok and wep and wep.type == "grenade" and wep.console_name ~= "weapon_flashbang" and wep.console_name ~= "weapon_decoy" then
                                    table.insert(weapons, wep.console_name)
                                end
                            end
                        end
                        player_items[player] = weapons
                    end

                    if #player_items[player] > 0 then
                        local x1, y1, x2, y2, alpha_multiplier = entity.get_bounding_box(player)
                        if x1 and alpha_multiplier ~= 0 then
                            local width = (x2 or x1) - x1
                            if width <= 0 then width = 50 end

                            local moly, nade, smoke, incin = false, false, false, false
                            for _, v in ipairs(player_items[player]) do
                                if v == "weapon_molotov" then moly = true
                                elseif v == "weapon_smokegrenade" then smoke = true
                                elseif v == "weapon_hegrenade" then nade = true
                                elseif v == "weapon_incgrenade" then incin = true end
                            end

                            local length = 0
                            if nade then length = length + 11 end
                            if moly then length = length + 11 end
                            if incin then length = length + 9 end
                            if smoke then length = length + 9 end

                            local start = ((width / 2) - (length / 2)) + 3
                            local spot = 0 
                            
                            local r, g, b, alph = 255, 255, 255, 255
                            
                            local a = math.floor((alph or 255) * (alpha_multiplier or 1) + 0.5)

                            if nade and icons.nade and icons.nade.draw then
                                icons.nade:draw(round(x1 + start + spot), y1 - 26, sizes.nade[1] or 8, sizes.nade[2] or 8, r, g, b, a, false, "f")
                                spot = spot + 11
                            end
                            if moly and icons.moly and icons.moly.draw then
                                icons.moly:draw(round(x1 + start + spot), y1 - 26, sizes.moly[1] or 8, sizes.moly[2] or 8, r, g, b, a, false, "f")
                                spot = spot + 11
                            end
                            if incin and icons.incin and icons.incin.draw then
                                icons.incin:draw(round(x1 + start + spot), y1 - 26, sizes.incin[1] or 8, sizes.incin[2] or 8, r, g, b, a, false, "f")
                                spot = spot + 9
                            end
                            if smoke and icons.smoke and icons.smoke.draw then
                                icons.smoke:draw(round(x1 + start + spot), y1 - 26, sizes.smoke[1] or 8, sizes.smoke[2] or 8, r, g, b, a, false, "f")
                            end
                        end
                    end
                end
            end
        end
    end)
end
init_grenade_esp()

local function init_grenade_radius()
    local MESH_DETAIL = 32
    local MAX_ALPHA = 191
    local SMOOTH_STRENGTH = 0.15
    local RENDER_DISTANCE = 650
    local MAX_MOLOTOVS = 2
    local MAX_SMOKES = 2
    local SMOKE_RADIUS = 125
    local MOLOTOV_SAFE_PADDING = 52
    local MESH_REFRESH = 0.2
    local REBUILDS_PER_FRAME = 2
    local FRAME_CELL_BUDGET = 1280
    local ORIGIN_EPSILON = 4
    local BAND_INNER = 0.10
    local BAND_LOW = 320
    local BAND_HIGH = 720
    local BAND_HYSTERESIS = 48
    local VIS_SMOOTH = 0.12
    local SMOKE_DURATION = 17.55

    local smoke_dirs = {}
    for i = 0, MESH_DETAIL - 1 do
        local angle = i * math.pi * 2 / MESH_DETAIL
        smoke_dirs[i + 1] = { x = math.cos(angle), y = math.sin(angle) }
    end

    local state = {
        molotov_alpha = 0,
        smoke_alpha = 0,
        molotov_mesh_cache = {},
        smoke_mesh_cache = {},
    }

    local function menu_get(ctrl)
        if not ctrl then return nil end
        local ok, v = pcall(function() return ctrl:get() end)
        return ok and v or nil
    end

    local function menu_color(ctrl, dr, dg, db, da)
        local ok, r, g, b, a = pcall(function() return ctrl:get() end)
        if ok and r then return r, g, b, a or 255 end
        return dr, dg, db, da
    end

    local function lerp(a, b, t)
        return a + (b - a) * t
    end

    local function lerp_step(current, target, speed)
        return lerp(current, target, speed or VIS_SMOOTH)
    end

    local function ease_smootherstep(t)
        t = math.min(1, math.max(0, t))
        return t * t * t * (t * (t * 6 - 15) + 10)
    end

    local function vec(x, y, z)
        return { x = x, y = y, z = z }
    end

    local function lerp_vec(a, b, t)
        return vec((b.x - a.x) * t + a.x, (b.y - a.y) * t + a.y, (b.z - a.z) * t + a.z)
    end

    local function distance_2d(a, b)
        return math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2)
    end

    local function distance_sq(a, b)
        local dx, dy, dz = a.x - b.x, a.y - b.y, a.z - b.z
        return dx * dx + dy * dy + dz * dz
    end

    local function ent_origin(ent)
        local x, y, z = entity.get_prop(ent, "m_vecOrigin")
        if not x then return nil end
        return vec(x, y, z)
    end

    local function reset_caches()
        state.molotov_mesh_cache = {}
        state.smoke_mesh_cache = {}
    end

    local function trace_world_line(from, to)
        if not from or not to then return nil end
        local ok, fraction = pcall(client.trace_line, -1, from.x, from.y, from.z, to.x, to.y, to.z)
        if not ok or type(fraction) ~= "number" then return nil end
        return {
            fraction = fraction,
            end_pos = vec(
                from.x + (to.x - from.x) * fraction,
                from.y + (to.y - from.y) * fraction,
                from.z + (to.z - from.z) * fraction
            ),
            all_solid = false,
            start_solid = false,
        }
    end

    local function trace_world_floor(point)
        if not point then return nil end
        local trace = trace_world_line(vec(point.x, point.y, point.z + 32), vec(point.x, point.y, point.z - 128))
        if trace and trace.fraction and trace.fraction < 1 then
            return trace.end_pos
        end
        trace = trace_world_line(vec(point.x, point.y, point.z + 96), vec(point.x, point.y, point.z - 384))
        return (trace and trace.fraction and trace.fraction < 1) and trace.end_pos or nil
    end

    local function trace_floor_inward(point, anchors)
        local traced = trace_world_floor(point)
        if traced then return traced end
        local ratios = { 0.75, 0.5, 0.25 }
        for i = 1, #anchors do
            local anchor = anchors[i]
            if anchor then
                for j = 1, #ratios do
                    traced = trace_world_floor(lerp_vec(anchor, point, ratios[j]))
                    if traced then return traced end
                end
            end
        end
        return nil
    end

    local function convex_hull_xy(points)
        if not points or #points < 3 then return nil end
        local sorted = {}
        for i = 1, #points do
            local point = points[i]
            if point and point.x and point.y and point.z then
                sorted[#sorted + 1] = point
            end
        end
        table.sort(sorted, function(a, b)
            return a.x == b.x and (a.y == b.y and a.z < b.z or a.y < b.y) or a.x < b.x
        end)
        local unique = {}
        for i = 1, #sorted do
            local point = sorted[i]
            local previous = unique[#unique]
            if not previous or point.x ~= previous.x or point.y ~= previous.y then
                unique[#unique + 1] = point
            end
        end
        if #unique < 3 then return nil end
        local function cross(a, b, c)
            return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
        end
        local lower = {}
        for i = 1, #unique do
            while #lower >= 2 and cross(lower[#lower - 1], lower[#lower], unique[i]) <= 0 do
                table.remove(lower)
            end
            lower[#lower + 1] = unique[i]
        end
        local upper = {}
        for i = #unique, 1, -1 do
            while #upper >= 2 and cross(upper[#upper - 1], upper[#upper], unique[i]) <= 0 do
                table.remove(upper)
            end
            upper[#upper + 1] = unique[i]
        end
        table.remove(lower)
        table.remove(upper)
        for i = 1, #upper do lower[#lower + 1] = upper[i] end
        return #lower >= 3 and lower or nil
    end

    local function subdivide_boundary(boundary)
        if not boundary or #boundary < 3 then return nil end
        local lengths, perimeter = {}, 0
        for i = 1, #boundary do
            local next_point = boundary[i % #boundary + 1]
            lengths[i] = distance_2d(boundary[i], next_point)
            perimeter = perimeter + lengths[i]
        end
        if perimeter <= 0 then return nil end
        local result, edge, traversed = {}, 1, 0
        for sample = 0, MESH_DETAIL - 1 do
            local distance = perimeter * sample / MESH_DETAIL
            while edge < #boundary and traversed + lengths[edge] < distance do
                traversed = traversed + lengths[edge]
                edge = edge + 1
            end
            local edge_length = lengths[edge]
            local t = edge_length > 0 and (distance - traversed) / edge_length or 0
            result[#result + 1] = lerp_vec(boundary[edge], boundary[edge % #boundary + 1], t)
        end
        return result
    end

    local function smooth_boundary(boundary)
        if not boundary or #boundary < 3 then return nil end
        local smoothed = {}
        for i = 1, #boundary do
            local previous = boundary[(i - 2) % #boundary + 1]
            local next_point = boundary[i % #boundary + 1]
            local neighbors = lerp_vec(previous, next_point, 0.5)
            smoothed[i] = lerp_vec(boundary[i], neighbors, SMOOTH_STRENGTH)
        end
        return smoothed
    end

    local function boundary_centroid(boundary)
        if not boundary or #boundary == 0 then return nil end
        local x, y, z = 0, 0, 0
        for i = 1, #boundary do
            x, y, z = x + boundary[i].x, y + boundary[i].y, z + boundary[i].z
        end
        return vec(x / #boundary, y / #boundary, z / #boundary)
    end

    local function fill_missing_boundary(boundary)
        local count = MESH_DETAIL
        for i = 1, count do
            if not boundary[i] then
                for distance = 1, count - 1 do
                    local previous = boundary[(i - distance - 1) % count + 1]
                    local next_point = boundary[(i + distance - 1) % count + 1]
                    if previous or next_point then
                        boundary[i] = previous or next_point
                        break
                    end
                end
                if not boundary[i] then return nil end
            end
        end
        return boundary
    end

    local function retrace_smoothed_boundary(boundary)
        local smoothed = smooth_boundary(boundary)
        if not smoothed then return nil end
        local traced = {}
        for i = 1, #smoothed do
            traced[i] = trace_world_floor(smoothed[i]) or boundary[i]
        end
        return traced
    end

    local function build_smoke_mesh(origin, radius)
        if not origin or not radius or radius <= 0 then return nil end
        local boundary = {}
        for i = 1, MESH_DETAIL do
            local direction = smoke_dirs[i]
            local endpoint = vec(origin.x + direction.x * radius, origin.y + direction.y * radius, origin.z)
            boundary[i] = trace_floor_inward(endpoint, { origin }) or false
        end
        boundary = fill_missing_boundary(boundary)
        if not boundary then return nil end
        boundary = retrace_smoothed_boundary(boundary)
        local centroid = boundary_centroid(boundary)
        local center = trace_world_floor(origin) or trace_world_floor(centroid) or centroid
        if not center then return nil end
        return { center = center, boundary = boundary }
    end

    local function build_molotov_mesh(inferno)
        if not inferno then return nil end
        local origin = ent_origin(inferno)
        if not origin then return nil end
        local points = {}
        for i = 0, 63 do
            local burning = entity.get_prop(inferno, "m_bFireIsBurning", i)
            local x = entity.get_prop(inferno, "m_fireXDelta", i)
            local y = entity.get_prop(inferno, "m_fireYDelta", i)
            local z = entity.get_prop(inferno, "m_fireZDelta", i)
            if (burning == true or burning == 1) and x and y and z then
                points[#points + 1] = vec(origin.x + x, origin.y + y, origin.z + z)
            end
        end
        local hull = convex_hull_xy(points)
        local hull_centroid = boundary_centroid(hull)
        if not hull or not hull_centroid then return nil end
        local padded = {}
        for i = 1, #hull do
            local point = hull[i]
            local dx, dy = point.x - hull_centroid.x, point.y - hull_centroid.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist > 0 then
                padded[i] = vec(
                    point.x + dx / dist * MOLOTOV_SAFE_PADDING,
                    point.y + dy / dist * MOLOTOV_SAFE_PADDING,
                    point.z
                )
            else
                padded[i] = point
            end
        end
        local boundary = subdivide_boundary(padded)
        if not boundary then return nil end
        local raw_centroid = boundary_centroid(boundary)
        local traced = {}
        for i = 1, #boundary do
            traced[i] = trace_floor_inward(boundary[i], { raw_centroid, origin }) or false
        end
        boundary = fill_missing_boundary(traced)
        if not boundary then return nil end
        boundary = retrace_smoothed_boundary(boundary)
        local centroid = boundary_centroid(boundary)
        local center = trace_world_floor(centroid) or centroid
        return center and { center = center, boundary = boundary } or nil
    end

    local function origin_changed(a, b)
        return not a or not b
            or math.abs(a.x - b.x) > ORIGIN_EPSILON
            or math.abs(a.y - b.y) > ORIGIN_EPSILON
            or math.abs(a.z - b.z) > ORIGIN_EPSILON
    end

    local function cached_grenade_mesh(cache, key, origin, detail, mesh_state, now, budget, build)
        if not key then return nil, nil end
        local entry = cache[key]
        local stale = not entry or now - entry.refreshed >= MESH_REFRESH
            or entry.detail ~= detail or entry.state ~= mesh_state or origin_changed(entry.origin, origin)
        if stale and budget.remaining > 0 then
            budget.remaining = budget.remaining - 1
            local ok, mesh = pcall(build)
            entry = entry or {}
            if ok and mesh and mesh.center and mesh.boundary and #mesh.boundary >= 3 then
                entry.target = mesh
                entry.mesh_revision = (entry.mesh_revision or 0) + 1
                entry.screen_cache = nil
                if not entry.mesh or not entry.mesh.boundary or #entry.mesh.boundary ~= #mesh.boundary then
                    local boundary = {}
                    for i = 1, #mesh.boundary do boundary[i] = mesh.boundary[i] end
                    entry.mesh = { center = mesh.center, boundary = boundary }
                end
            end
            entry.origin, entry.detail, entry.state, entry.refreshed = origin, detail, mesh_state, now
            entry.display_alpha = entry.display_alpha or 0
            cache[key] = entry
        end
        if entry and entry.mesh and entry.target and #entry.mesh.boundary == #entry.target.boundary then
            local frametime = math.min(globals.frametime() or (1 / 60), 0.1)
            local factor = 1 - math.pow(0.82, frametime * 60)
            entry.mesh.center = lerp_vec(entry.mesh.center, entry.target.center, factor)
            for i = 1, #entry.mesh.boundary do
                entry.mesh.boundary[i] = lerp_vec(entry.mesh.boundary[i], entry.target.boundary[i], factor)
            end
        end
        return entry and entry.mesh or nil, key
    end

    local function project_point(point)
        if not point then return nil end
        local ok, sx, sy = pcall(renderer.world_to_screen, point.x, point.y, point.z)
        if not ok or not sx or not sy then return nil end
        if sx ~= sx or sy ~= sy or math.abs(sx) > 100000 or math.abs(sy) > 100000 then return nil end
        return { x = sx, y = sy }
    end

    local function origin_in_fov(origin, screen_w, screen_h)
        local projected = project_point(origin)
        if not projected then return false end
        return projected.x >= 0 and projected.y >= 0 and projected.x <= screen_w and projected.y <= screen_h
    end

    local function screen_edge_valid(a, b, max_edge)
        if not a or not b then return false end
        local dx, dy = b.x - a.x, b.y - a.y
        return dx * dx + dy * dy <= max_edge * max_edge
    end

    local function screen_quad_valid(a, b, c, d, max_edge)
        if not screen_edge_valid(a, b, max_edge)
            or not screen_edge_valid(b, c, max_edge)
            or not screen_edge_valid(c, d, max_edge)
            or not screen_edge_valid(d, a, max_edge)
            or not screen_edge_valid(a, c, max_edge)
            or not screen_edge_valid(b, d, max_edge) then return false end
        local function cross(p1, p2, p3)
            return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)
        end
        local c1, c2 = cross(a, b, c), cross(b, c, d)
        local c3, c4 = cross(c, d, a), cross(d, a, b)
        local positive = c1 > 0.01 or c2 > 0.01 or c3 > 0.01 or c4 > 0.01
        local negative = c1 < -0.01 or c2 < -0.01 or c3 < -0.01 or c4 < -0.01
        return positive ~= negative
    end

    local function recover_projection(valid_world, invalid_world, valid_screen)
        if not valid_world or not invalid_world or not valid_screen then return nil end
        local low, high, best = 0, 1, valid_screen
        for _ = 1, 6 do
            local midpoint = (low + high) * 0.5
            local candidate = project_point(lerp_vec(valid_world, invalid_world, midpoint))
            if candidate then
                low, best = midpoint, candidate
            else
                high = midpoint
            end
        end
        return best
    end

    local function projection_pair(inner_world, outer_world, inner_screen, outer_screen)
        if inner_screen and outer_screen then return inner_screen, outer_screen end
        if inner_screen then
            return inner_screen, recover_projection(inner_world, outer_world, inner_screen)
        end
        if outer_screen then
            return recover_projection(outer_world, inner_world, outer_screen), outer_screen
        end
        return nil, nil
    end

    local function draw_outline(a, b, r, g, bcol, a_alpha)
        local dx, dy = b.x - a.x, b.y - a.y
        local length = math.sqrt(dx * dx + dy * dy)
        if length <= 0 then return end
        local px, py = -dy / length, dx / length
        renderer.line(a.x - px * 0.5, a.y - py * 0.5, b.x - px * 0.5, b.y - py * 0.5, r, g, bcol, a_alpha)
        renderer.line(a.x + px * 0.5, a.y + py * 0.5, b.x + px * 0.5, b.y + py * 0.5, r, g, bcol, a_alpha)
    end

    local function draw_quad(a, b, c, d, r, g, bcol, a_alpha)
        renderer.triangle(a.x, a.y, b.x, b.y, c.x, c.y, r, g, bcol, a_alpha)
        renderer.triangle(a.x, a.y, c.x, c.y, d.x, d.y, r, g, bcol, a_alpha)
    end

    local function outer_extent(projected, vertex_count)
        local min_x, min_y, max_x, max_y, count
        for i = 1, vertex_count do
            local point = projected[i]
            if point then
                min_x, max_x = math.min(min_x or point.x, point.x), math.max(max_x or point.x, point.x)
                min_y, max_y = math.min(min_y or point.y, point.y), math.max(max_y or point.y, point.y)
                count = (count or 0) + 1
            end
        end
        return count and count >= 2 and math.max(max_x - min_x, max_y - min_y) or nil
    end

    local function band_count(mesh, extent)
        if extent then
            local frametime = math.min(globals.frametime() or (1 / 60), 0.1)
            local factor = 1 - math.pow(0.85, frametime * 60)
            mesh.projected_extent = lerp(mesh.projected_extent or extent, extent, factor)
        end
        local metric = mesh.projected_extent
        local bands = mesh.band_count
        if not bands then
            bands = metric and (metric >= BAND_HIGH and 20 or metric >= BAND_LOW and 14 or 10) or 14
        elseif metric then
            if bands == 10 and metric > BAND_LOW + BAND_HYSTERESIS then
                bands = 14
            elseif bands == 14 then
                if metric < BAND_LOW - BAND_HYSTERESIS then
                    bands = 10
                elseif metric > BAND_HIGH + BAND_HYSTERESIS then
                    bands = 20
                end
            elseif bands == 20 and metric < BAND_HIGH - BAND_HYSTERESIS then
                bands = 14
            end
        end
        mesh.band_count = bands
        return bands
    end

    local function sector_count(bands)
        return bands == 10 and 16 or MESH_DETAIL
    end

    local function budgeted_lod(desired_bands, draw_budget)
        if not draw_budget then return desired_bands, sector_count(desired_bands) end
        local remaining = draw_budget.remaining or 0
        if desired_bands == 20 then
            if remaining >= 20 * MESH_DETAIL then return 20, MESH_DETAIL end
            if remaining >= 14 * MESH_DETAIL then return 14, MESH_DETAIL end
            if remaining >= 10 * 16 then return 10, 16 end
        elseif desired_bands == 14 then
            if remaining >= 14 * MESH_DETAIL then return 14, MESH_DETAIL end
            if remaining >= 10 * 16 then return 10, 16 end
        elseif desired_bands == 10 and remaining >= 10 * 16 then
            return 10, 16
        end
        return 0, 0
    end

    local function build_row(mesh, ratio, outer_screen)
        local is_outer = ratio >= 0.9999
        local row = { world = {}, screen = {}, ratio = ratio }
        for i = 1, #mesh.boundary do
            row.world[i] = is_outer and mesh.boundary[i] or lerp_vec(mesh.center, mesh.boundary[i], ratio)
            row.screen[i] = is_outer and outer_screen[i] or project_point(row.world[i])
        end
        return row
    end

    local function camera_state()
        local ok_p, px, py, pz = pcall(client.eye_position)
        local ok_a, pitch, yaw, roll = pcall(client.camera_angles)
        if not ok_p or not ok_a or not px or not pitch then return nil end
        return {
            position = vec(px, py, pz),
            angles = vec(pitch, yaw or 0, roll or 0),
        }
    end

    local function camera_matches(cached, current)
        if not cached or not current then return false end
        local function within(a, b, limit)
            return math.abs(a.x - b.x) <= limit and math.abs(a.y - b.y) <= limit and math.abs(a.z - b.z) <= limit
        end
        return within(cached.position, current.position, 1) and within(cached.angles, current.angles, 0.25)
    end

    local function cache_point(point)
        return { x = point.x, y = point.y }
    end

    local function draw_screen_cache(screen_cache, r, g, bcol, composed_alpha)
        local drew = false
        for i = 1, #screen_cache.cells do
            local cell = screen_cache.cells[i]
            draw_quad(cell.a, cell.b, cell.c, cell.d, r, g, bcol, composed_alpha)
            drew = true
        end
        for i = 1, #screen_cache.outline_edges do
            local edge = screen_cache.outline_edges[i]
            draw_outline(edge.a, edge.b, r, g, bcol, composed_alpha)
            drew = true
        end
        return drew
    end

    local function draw_grenade_mesh(entry, r, g, bcol, primary_a, alpha_scale, draw_budget, screen_w, screen_h)
        local mesh = entry and entry.mesh
        if not mesh or not mesh.boundary or #mesh.boundary < 3 or alpha_scale <= 0 then return false end
        local max_edge = math.max(screen_w, screen_h) * 2
        local composed_alpha = math.floor(math.min(primary_a, MAX_ALPHA) * alpha_scale + 0.5)
        if composed_alpha <= 1 then return false end
        local screen_cache = entry.screen_cache
        if screen_cache then
            local cache_compatible = screen_cache.mesh_revision == entry.mesh_revision
                and screen_cache.band_count == mesh.band_count
                and screen_cache.sector_count == sector_count(mesh.band_count)
                and globals.framecount() - screen_cache.frame <= 2
            local camera = camera_state()
            cache_compatible = cache_compatible and camera_matches(screen_cache.camera, camera)
            if cache_compatible then
                local cache_cost = screen_cache.band_count * screen_cache.sector_count
                if not draw_budget or (draw_budget.remaining or 0) >= cache_cost then
                    if draw_budget then draw_budget.remaining = math.max(0, draw_budget.remaining - cache_cost) end
                    return draw_screen_cache(screen_cache, r, g, bcol, composed_alpha)
                end
            else
                entry.screen_cache = nil
            end
        end
        local vertex_count = #mesh.boundary
        local outer_screen = {}
        for i = 1, vertex_count do outer_screen[i] = project_point(mesh.boundary[i]) end
        local extent = outer_extent(outer_screen, vertex_count)
        if not extent then return false end
        local desired_bands = band_count(mesh, extent)
        local bands, sectors = budgeted_lod(desired_bands, draw_budget)
        if draw_budget then
            draw_budget.remaining = math.max(0, (draw_budget.remaining or 0) - bands * sectors)
        end
        local drew = false
        local camera = bands > 0 and camera_state() or nil
        local new_screen_cache = camera and {
            mesh_revision = entry.mesh_revision,
            band_count = bands,
            sector_count = sectors,
            frame = globals.framecount(),
            camera = camera,
            cells = {},
            outline_edges = {},
        } or nil
        if bands > 0 then
            local inner = build_row(mesh, BAND_INNER, outer_screen)
            for band = 1, bands do
                local outer_ratio = BAND_INNER + band * (1 - BAND_INNER) / bands
                local outer = build_row(mesh, outer_ratio, outer_screen)
                for sector = 1, sectors do
                    local previous_index = sectors == 16 and ((sector - 1) * 2 + 1) or sector
                    local index = previous_index + (sectors == 16 and 2 or 1)
                    if index > vertex_count then index = index - vertex_count end
                    local previous_inner, previous_outer = projection_pair(
                        inner.world[previous_index], outer.world[previous_index],
                        inner.screen[previous_index], outer.screen[previous_index]
                    )
                    local current_inner, current_outer = projection_pair(
                        inner.world[index], outer.world[index],
                        inner.screen[index], outer.screen[index]
                    )
                    if screen_quad_valid(previous_inner, previous_outer, current_outer, current_inner, max_edge) then
                        draw_quad(previous_inner, previous_outer, current_outer, current_inner, r, g, bcol, composed_alpha)
                        if new_screen_cache then
                            new_screen_cache.cells[#new_screen_cache.cells + 1] = {
                                a = cache_point(previous_inner), b = cache_point(previous_outer),
                                c = cache_point(current_outer), d = cache_point(current_inner),
                            }
                        end
                        drew = true
                    end
                end
                inner = outer
            end
        end
        for sector = 1, sectors do
            local i = sectors == 16 and (sector * 2 - 1) or sector
            local next_index = i + (sectors == 16 and 2 or 1)
            if next_index > vertex_count then next_index = next_index - vertex_count end
            local a, b = outer_screen[i], outer_screen[next_index]
            if a and b and screen_edge_valid(a, b, max_edge) then
                draw_outline(a, b, r, g, bcol, composed_alpha)
                if new_screen_cache then
                    new_screen_cache.outline_edges[#new_screen_cache.outline_edges + 1] = {
                        a = cache_point(a), b = cache_point(b),
                    }
                end
                drew = true
            end
        end
        if new_screen_cache and (#new_screen_cache.cells > 0 or #new_screen_cache.outline_edges > 0) then
            entry.screen_cache = new_screen_cache
        else
            entry.screen_cache = nil
        end
        return drew
    end

    local function draw_grenade_cache(cache, master_alpha, enabled, draw_budget, screen_w, screen_h)
        local frametime = math.min(globals.frametime() or (1 / 60), 0.1)
        local factor = 1 - math.pow(0.82, frametime * 60)
        for key, entry in pairs(cache) do
            local target = entry.seen and enabled and 1 or 0
            entry.display_alpha = lerp(entry.display_alpha or 0, target, factor)
            if entry.mesh and entry.r and entry.effect_alpha then
                draw_grenade_mesh(
                    entry, entry.r, entry.g, entry.b, entry.a,
                    master_alpha * entry.effect_alpha * entry.display_alpha,
                    draw_budget, screen_w, screen_h
                )
            end
            entry.seen = false
            if enabled and target == 0 and entry.display_alpha <= 0.01 then cache[key] = nil end
        end
    end

    local function draw_simple_ring(center, radius, r, g, bcol, alpha_scale, primary_a)
        if not center or not radius or radius <= 0 or alpha_scale <= 0 then return end
        local alpha = math.floor(math.min(primary_a, MAX_ALPHA) * alpha_scale + 0.5)
        if alpha <= 1 then return end
        local prev
        for i = 0, MESH_DETAIL do
            local angle = (i % MESH_DETAIL) * math.pi * 2 / MESH_DETAIL
            local point = vec(center.x + math.cos(angle) * radius, center.y + math.sin(angle) * radius, center.z)
            local floor = trace_world_floor(point) or point
            local screen = project_point(floor)
            if prev and screen then
                renderer.line(prev.x, prev.y, screen.x, screen.y, r, g, bcol, alpha)
            end
            prev = screen
        end
    end

    local function molotov_circle(inferno)
        local origin = ent_origin(inferno)
        if not origin then return nil end
        local points = {}
        for i = 0, 63 do
            local burning = entity.get_prop(inferno, "m_bFireIsBurning", i)
            local x = entity.get_prop(inferno, "m_fireXDelta", i)
            local y = entity.get_prop(inferno, "m_fireYDelta", i)
            local z = entity.get_prop(inferno, "m_fireZDelta", i)
            if (burning == true or burning == 1) and x and y and z then
                points[#points + 1] = vec(x, y, z)
            end
        end
        local max_dist, p1, p2 = 0, nil, nil
        for a = 1, #points do
            for b = a + 1, #points do
                local dist = distance_2d(points[a], points[b])
                if dist > max_dist then max_dist, p1, p2 = dist, points[a], points[b] end
            end
        end
        local center = p1 and vec(origin.x + lerp(p1.x, p2.x, 0.5), origin.y + lerp(p1.y, p2.y, 0.5), origin.z + lerp(p1.z, p2.z, 0.5)) or origin
        return center, max_dist > 0 and max_dist * 0.5 + MOLOTOV_SAFE_PADDING or 140
    end

    local function select_nearest(selected, candidate, limit)
        local insert_at
        for i = 1, #selected do
            local current = selected[i]
            if candidate.distance_sq < current.distance_sq
                or (candidate.distance_sq == current.distance_sq and candidate.index < current.index) then
                insert_at = i
                break
            end
        end
        if #selected < limit then
            table.insert(selected, insert_at or (#selected + 1), candidate)
        elseif insert_at then
            table.insert(selected, insert_at, candidate)
            selected[#selected] = nil
        end
    end

    local function on_paint()
        local molotov_enabled = menu_get(menu and menu.visuals and menu.visuals.molotov_radius) == true
        local smoke_enabled = menu_get(menu and menu.visuals and menu.visuals.smoke_radius) == true
        local molotov_simple = molotov_enabled and menu_get(menu.visuals.molotov_mode) == "Simple"
        local smoke_simple = smoke_enabled and menu_get(menu.visuals.smoke_mode) == "Simple"

        state.molotov_alpha = lerp_step(state.molotov_alpha, molotov_enabled and 1 or 0, VIS_SMOOTH)
        state.smoke_alpha = lerp_step(state.smoke_alpha, smoke_enabled and 1 or 0, VIS_SMOOTH)

        if state.molotov_alpha <= 0.01 then state.molotov_mesh_cache = {} end
        if state.smoke_alpha <= 0.01 then state.smoke_mesh_cache = {} end
        if molotov_simple then state.molotov_mesh_cache = {} end
        if smoke_simple then state.smoke_mesh_cache = {} end
        if state.molotov_alpha <= 0.01 and state.smoke_alpha <= 0.01 then return end

        local me = entity.get_local_player()
        if not me then return end
        local player_origin = ent_origin(me)
        if not player_origin then return end

        local now = globals.realtime()
        local budget = { remaining = REBUILDS_PER_FRAME }
        local draw_budget = { remaining = FRAME_CELL_BUDGET }
        local screen_w, screen_h = client.screen_size()
        if not screen_w or not screen_h then return end
        local max_distance_sq = RENDER_DISTANCE * RENDER_DISTANCE

        if state.molotov_alpha > 0.01 and molotov_enabled then
            local fires = entity.get_all("CInferno")
            if fires then
                local selected = {}
                local r, g, b, a = menu_color(menu.visuals.molotov_color, 255, 183, 183, 255)
                for i = 1, #fires do
                    local inferno = fires[i]
                    local origin = ent_origin(inferno)
                    if origin then
                        local dist_sq = distance_sq(origin, player_origin)
                        if dist_sq <= max_distance_sq and origin_in_fov(origin, screen_w, screen_h) then
                            select_nearest(selected, {
                                ent = inferno,
                                origin = origin,
                                distance_sq = dist_sq,
                                key = inferno,
                                index = inferno,
                            }, MAX_MOLOTOVS)
                        else
                            state.molotov_mesh_cache[inferno] = nil
                        end
                    end
                end
                for i = 1, #selected do
                    local candidate = selected[i]
                    local inferno, origin = candidate.ent, candidate.origin
                    if molotov_simple then
                        local center, radius = molotov_circle(inferno)
                        draw_simple_ring(center, radius, r, g, b, state.molotov_alpha, a)
                    else
                        local mesh, key = cached_grenade_mesh(
                            state.molotov_mesh_cache, candidate.key, origin, MESH_DETAIL, nil, now, budget,
                            function() return build_molotov_mesh(inferno) end
                        )
                        if key then
                            local entry = state.molotov_mesh_cache[key]
                            if entry then
                                entry.seen, entry.r, entry.g, entry.b, entry.a, entry.effect_alpha = true, r, g, b, a, 1
                            end
                        end
                        if not mesh then
                            local center, radius = molotov_circle(inferno)
                            draw_simple_ring(center, radius, r, g, b, state.molotov_alpha, a)
                        end
                    end
                end
            end
        end
        if not molotov_simple then
            draw_grenade_cache(state.molotov_mesh_cache, state.molotov_alpha, molotov_enabled, draw_budget, screen_w, screen_h)
        end

        if state.smoke_alpha > 0.01 and smoke_enabled then
            local smokes = entity.get_all("CSmokeGrenadeProjectile")
            if smokes then
                local selected = {}
                local tick = globals.tickcount()
                local interval = globals.tickinterval()
                local r, g, b, a = menu_color(menu.visuals.smoke_color, 197, 199, 255, 255)
                for i = 1, #smokes do
                    local smoke = smokes[i]
                    local origin = ent_origin(smoke)
                    if origin then
                        local dist_sq = distance_sq(origin, player_origin)
                        if dist_sq <= max_distance_sq and origin_in_fov(origin, screen_w, screen_h) then
                            local did = entity.get_prop(smoke, "m_bDidSmokeEffect")
                            if did == true or did == 1 then
                                local begin_tick = entity.get_prop(smoke, "m_nSmokeEffectTickBegin")
                                if begin_tick then
                                    local elapsed = interval * (tick - begin_tick)
                                    if elapsed > 0 and SMOKE_DURATION - elapsed > 0 then
                                        local lifetime_alpha = 1
                                        local radius = SMOKE_RADIUS
                                        if elapsed < 0.3 then
                                            radius = radius * (0.6 + (elapsed / 0.3) * 0.4)
                                            lifetime_alpha = elapsed / 0.3
                                        end
                                        if SMOKE_DURATION - elapsed < 1 then
                                            local remaining = SMOKE_DURATION - elapsed
                                            radius = radius * (remaining * 0.3 + 0.7)
                                            lifetime_alpha = lifetime_alpha * ease_smootherstep(remaining)
                                        end
                                        select_nearest(selected, {
                                            ent = smoke,
                                            origin = origin,
                                            radius = radius,
                                            lifetime_alpha = lifetime_alpha,
                                            distance_sq = dist_sq,
                                            key = smoke,
                                            index = smoke,
                                        }, MAX_SMOKES)
                                    end
                                end
                            end
                        else
                            state.smoke_mesh_cache[smoke] = nil
                        end
                    end
                end
                for i = 1, #selected do
                    local candidate = selected[i]
                    local smoke, origin = candidate.ent, candidate.origin
                    local radius, lifetime_alpha = candidate.radius, candidate.lifetime_alpha
                    local alpha_scale = state.smoke_alpha * lifetime_alpha
                    if smoke_simple then
                        draw_simple_ring(origin, radius, r, g, b, alpha_scale, a)
                    else
                        local mesh, key = cached_grenade_mesh(
                            state.smoke_mesh_cache, candidate.key, origin, MESH_DETAIL,
                            math.floor(radius + 0.5), now, budget,
                            function() return build_smoke_mesh(origin, radius) end
                        )
                        if key then
                            local entry = state.smoke_mesh_cache[key]
                            if entry then
                                entry.seen, entry.r, entry.g, entry.b, entry.a, entry.effect_alpha = true, r, g, b, a, lifetime_alpha
                            end
                        end
                        if not mesh then
                            draw_simple_ring(origin, radius, r, g, b, alpha_scale, a)
                        end
                    end
                end
            end
        end
        if not smoke_simple then
            draw_grenade_cache(state.smoke_mesh_cache, state.smoke_alpha, smoke_enabled, draw_budget, screen_w, screen_h)
        end
    end

    client.set_event_callback("paint", on_paint)
    client.set_event_callback("round_start", reset_caches)
    client.set_event_callback("level_init", reset_caches)
end
init_grenade_radius()

-- ── Cheat revealer (voice-packet detection → builder cheat buckets) ──
-- Detection core ported from "!!_Cheat revealer.lua" (icons/scoreboard UI
-- dropped). Classifies players by voice packet fingerprints and maps every
-- result into the 3 builder profiles: Gamesense / Neverlose / Unknown.
-- Nested function: main-chunk Lua locals are capped at 200.
local function init_cheat_revealer()
    local voice_data_t = ffi.typeof([[
        struct {
            char     pad_0000[8];
            int32_t  client;
            int32_t  audible_mask;
            uint32_t xuid_low;
            uint32_t xuid_high;
            void*    voice_data;
            bool     proximity;
            bool     caster;
            char     pad_001E[2];
            int32_t  format;
            int32_t  sequence_bytes;
            uint32_t section_number;
            uint32_t uncompressed_sample_offset;
            char     pad_0030[4];
            uint32_t has_bits;
        } *
    ]])

    local CHEAT_BUCKET = { gs = "Gamesense", nl = "Neverlose" }
    local CHEAT_NAMES = {
        gs = "gamesense", nl = "neverlose", nw = "nixware", pd = "pandora",
        ot = "onetap", ft = "fatality", pl = "plaguecheat", ev = "ev0lve",
        r7 = "rifk7", af = "airflow",
    }

    local users = {}
    local det

    local function reset_det()
        det = {
            nl = { sig_count = {}, found = {} },
            nw = {}, pd = {}, ot = {}, ft = {}, pl = {}, ev = {},
            r7 = {}, af = {}, gs = {},
        }
    end
    reset_det()

    local function find_duplicate_element(array, divisor)
        local visited_elements = {}
        for current_index = 1, #array do
            local current_element = array[current_index]
            if not visited_elements[current_element] then
                visited_elements[current_element] = true
                for next_index = current_index + 4, #array do
                    if current_index % divisor == 0 then
                        if array[next_index] == current_element then
                            return true
                        end
                    elseif array[next_index] == current_element then
                        return false
                    end
                end
            end
        end
        return false
    end

    local detector_table = {
        nl = function(packet, target)
            if packet.xuid_high == 0 then return end
            local sig = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 22)[0])
            if sig == det.current_signature then
                det.nl.sig_count[target] = (det.nl.sig_count[target] or 0) + 1
                if det.nl.sig_count[target] > 24 then
                    det.nl.found[target] = 1
                    return true
                else
                    det.nl.sig_count[target] = nil
                end
            end
            if #det.nl.found > 3 then return false end
            if not det.nl[target] then det.nl[target] = {} end
            det.nl[target][#det.nl[target] + 1] = packet.xuid_high
            if #det.nl[target] > 24 then
                if find_duplicate_element(det.nl[target], 4) and packet.xuid_high ~= 0 then
                    det.current_signature = sig
                    det.nl[target] = {}
                    return true
                end
                table.remove(det.nl[target], 1)
            end
            return false
        end,
        nw = function(packet, target)
            if not det.nw[target] then det.nw[target] = 0 end
            if det.nw[target] > 34 then
                det.nw[target] = nil
                return true
            elseif packet.xuid_high == 0 then
                det.nw[target] = det.nw[target] + 1
            else
                det.nw[target] = 0
            end
            return false
        end,
        pd = function(packet, target)
            if not det.pd[target] then det.pd[target] = 0 end
            local sig = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 16)[0])
            if det.pd[target] > 24 then
                return true
            elseif sig == "695B" or sig == "1B39" then
                det.pd[target] = det.pd[target] + 1
            else
                det.pd[target] = 0
            end
            return false
        end,
        ot = function(packet, target)
            if not det.ot[target] then det.ot[target] = {} end
            det.ot[target][#det.ot[target] + 1] = {
                sequence_bytes = packet.sequence_bytes,
                xuid_low = packet.xuid_low,
                section_number = packet.section_number,
                umcompressed_sample_offset = packet.uncompressed_sample_offset,
            }
            if #det.ot[target] > 16 then
                local oldest_packet = det.ot[target][1]
                for i = 2, #det.ot[target] do
                    local loop_packet = det.ot[target][i]
                    if loop_packet.xuid_low ~= oldest_packet.xuid_low
                        or loop_packet.section_number ~= oldest_packet.section_number
                        or loop_packet.uncompressed_sample_offset ~= oldest_packet.uncompressed_sample_offset then
                        table.remove(det.ot[target], 1)
                        return false
                    end
                end
                table.remove(det.ot[target], 1)
                return true
            end
            return false
        end,
        ft = function(packet, target)
            if not det.ft[target] then det.ft[target] = 0 end
            local sig = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 16)[0])
            if det.ft[target] > 36 then
                return true
            elseif sig == "7FFA" or sig == "7FFB" then
                det.ft[target] = det.ft[target] + 1
            end
            return false
        end,
        pl = function(packet, target)
            if not det.pl[target] then det.pl[target] = 0 end
            if det.pl[target] > 24 then
                return true
            elseif ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 44)[0]) == "7275" then
                det.pl[target] = det.pl[target] + 1
            else
                det.pl[target] = 0
            end
            return false
        end,
        ev = function(packet, target)
            if not det.ev[target] then det.ev[target] = {} end
            det.ev[target][#det.ev[target] + 1] = packet.xuid_high
            if #det.ev[target] > 44 then
                for i = 1, #det.ev[target] - 4 do
                    local loop_info = det.ev[target][i]
                    if det.ev[target][i + 1] + det.ev[target][i + 2] == det.ev[target][i] * 2
                        and det.ev[target][i + 4] == loop_info + 1 then
                        det.ev[target] = {}
                        return true
                    end
                end
                table.remove(det.ev[target], 1)
            end
            return false
        end,
        r7 = function(packet, target)
            if not det.r7[target] then det.r7[target] = 0 end
            local sig = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 16)[0])
            if det.r7[target] > 24 then
                return true
            elseif sig == "234" or sig == "134" then
                det.r7[target] = det.r7[target] + 1
            else
                det.r7[target] = 0
            end
            return false
        end,
        af = function(packet, target)
            if not det.af[target] then det.af[target] = 0 end
            if det.af[target] > 24 then
                return true
            elseif ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 16)[0]) == "AFF1" then
                det.af[target] = det.af[target] + 1
            else
                det.af[target] = 0
            end
            return false
        end,
        gs = function(packet, target)
            local sig = ("%.02X"):format(ffi.cast("uint16_t*", ffi.cast("uintptr_t", packet) + 22)[0])
            local sequence_bytes = string.sub(packet.sequence_bytes, 1, 4)
            if not det.gs[target] then
                det.gs[target] = { repeated = 0, packet = sig, bytes = sequence_bytes }
            end
            if sequence_bytes ~= det.gs[target].bytes and sig ~= det.gs[target].packet then
                det.gs[target].packet = sig
                det.gs[target].bytes = sequence_bytes
                det.gs[target].repeated = det.gs[target].repeated + 1
            else
                det.gs[target].repeated = 0
            end
            if det.gs[target].repeated >= 36 then
                det.gs[target] = { repeated = 0, packet = sig, bytes = sequence_bytes }
                return true
            end
            return false
        end,
    }

    function shinymoon_enemy_cheat(idx)
        local c = idx and users[idx]
        return c and (CHEAT_BUCKET[c] or "Unknown") or "Unknown"
    end

    local cache = { tick = -1, bucket = "Unknown" }
    function shinymoon_active_cheat_bucket()
        local tick = globals.tickcount()
        if cache.tick == tick then return cache.bucket end
        cache.tick = tick
        cache.bucket = "Unknown"
        local me = entity.get_local_player()
        if not me then return cache.bucket end
        local target
        local threat = aa and aa.shiny and aa.shiny.threat
        if threat and threat.primary_threat
            and (globals.realtime() - (threat.last_update or 0)) < 1
            and entity.is_alive(threat.primary_threat) then
            target = threat.primary_threat
        else
            local mx, my, mz = entity.get_origin(me)
            local players = mx and entity.get_players(true)
            if players then
                local best_d2
                for i = 1, #players do
                    local idx = players[i]
                    if entity.is_alive(idx) and not entity.is_dormant(idx) then
                        local ox, oy, oz = entity.get_origin(idx)
                        if ox then
                            local dx, dy, dz = ox - mx, oy - my, oz - mz
                            local d2 = dx * dx + dy * dy + dz * dz
                            if not best_d2 or d2 < best_d2 then
                                best_d2, target = d2, idx
                            end
                        end
                    end
                end
            end
        end
        cache.bucket = shinymoon_enemy_cheat(target)
        return cache.bucket
    end

    client.set_event_callback("voice", function(event)
        if not event or event.data == nil then return end
        pcall(function()
            local packet = ffi.cast(voice_data_t, event.data)
            local target = (ffi.cast("char*", packet) + 8)[0] + 1
            for cheat_identifier, detect in pairs(detector_table) do
                local cur = users[target]
                -- Precedence guards (ported): a stronger fingerprint never
                -- gets overwritten by a weaker one.
                local allowed = cur ~= cheat_identifier
                    and (cheat_identifier ~= "nl" or (cur ~= "ev" and cur ~= "gs" and cur ~= "pl" and cur ~= "pd" and cur ~= "r7" and cur ~= "af" and cur ~= "ft"))
                    and (cheat_identifier ~= "nw" or cur ~= "nl")
                    and (cheat_identifier ~= "ev" or (cur ~= "pd" and cur ~= "nl" and cur ~= "ft"))
                    and (cheat_identifier ~= "gs" or (cur ~= "ev" and cur ~= "ot" and cur ~= "pl" and cur ~= "pd" and cur ~= "r7" and cur ~= "ft"))
                    and (cheat_identifier ~= "ot" or (cur ~= "nw" and cur ~= "ft" and cur ~= "pd" and cur ~= "pl"))
                    and not (cheat_identifier == "ft" and (cur == "nw" or cur == "pd"))
                if allowed and detect(packet, target) then
                    users[target] = cheat_identifier
                    if entity.is_enemy(target) then
                        local accent = shinymoon_accent_hex()
                        shinymoon_log_print(string.format(
                            "Revealed \a%s%s\adefault on %s (%s profile)",
                            accent, CHEAT_NAMES[cheat_identifier] or cheat_identifier,
                            string.lower(entity.get_player_name(target) or "?"),
                            CHEAT_BUCKET[cheat_identifier] or "Unknown"), false)
                    end
                end
            end
        end)
    end)

    -- Entindexes are reused across maps; local full-connect also invalidates
    -- everything (server change without level_init on some transitions).
    client.set_event_callback("level_init", function()
        users = {}
        reset_det()
        cache.tick = -1
    end)

    client.set_event_callback("player_connect_full", function(e)
        if not e or not e.userid then return end
        if client.userid_to_entindex(e.userid) == entity.get_local_player() then
            users = {}
            reset_det()
            cache.tick = -1
        end
    end)
end
init_cheat_revealer()

local function init_dt_charge_guard()
    local unsafe_weapons = require("gamesense/csgo_weapons")
    local rage_enable = ui.reference("RAGE", "Aimbot", "Enabled")
    local dt, dt_hk = ui.reference("RAGE", "Aimbot", "Double tap")
    local osaa, osaa_hk = ui.reference("AA", "Other", "On shot anti-aim")
    local fakeduck = ui.reference("RAGE", "Other", "Duck peek assist")
    local timer, forced_off = globals.tickcount(), false

    local function restore()
        if forced_off then
            ui.set(rage_enable, true)
            forced_off = false
        end
    end

    client.set_event_callback("setup_command", function()
        -- tickcount restarts on a new map/server; a stale timer from the old
        -- count would force the ragebot off until ticks catch up (hours).
        if globals.tickcount() < timer then
            timer = globals.tickcount()
            restore()
        end

        local me = entity.get_local_player()
        local weapon = me and entity.is_alive(me) and entity.get_player_weapon(me)
        if not weapon then
            restore()
            timer = globals.tickcount()
            return
        end

        local wep = unsafe_weapons(weapon)
        local ticks = (wep and wep.is_revolver) and 17 or 14
        local fd = ui.get(fakeduck)
        local dt_on = ui.get(dt) and ui.get(dt_hk) and not fd
        local osaa_on = ui.get(osaa) and ui.get(osaa_hk) and not fd

        if dt_on or osaa_on then
            local ready = globals.tickcount() >= timer + ticks
            -- Write only on transitions: a permanent ui.set(true) would stomp
            -- a manual ragebot toggle every tick once the window elapsed.
            if not ready then
                ui.set(rage_enable, false)
                forced_off = true
            elseif forced_off then
                ui.set(rage_enable, true)
                forced_off = false
            end
        else
            restore()
            timer = globals.tickcount()
        end
    end)

    client.set_event_callback("shutdown", restore)
end
init_dt_charge_guard()
