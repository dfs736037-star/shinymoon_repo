local ffi = require("ffi")
local bit = bit

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
