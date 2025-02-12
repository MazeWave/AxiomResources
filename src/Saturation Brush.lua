-- Requires Axiom 4.5.3 or later
-- Saturation Brush script 1.0 by MazeWave
-- Source : https://github.com/MazeWave/AxiomResources

-- USER INPUT
_G.factor		= $float(Factor, 1.0, 0.0, 1.0)$
_G.isF				= $boolean([F] Use Full 1x1x1 Blocks, true)$
_G.isS				= $boolean([S] Use Solid Hitbox Blocks, true)$
_G.isO				= $boolean([O] Use Opaque Blocks, true)$
_G.isT				= $boolean([T] Use Same Textures on all sides, true)$
_G.isNO			= $boolean(No ores, false)$
_G.isNG			= $boolean(No glazed terracota, false)$
_G.isNT			= $boolean(No tile entities, true)$
_G.shift			= $int(Shift, 1, 1, 10)$

-- FUNCTIONS
local function	GetFlagsBinary()
	local	S = isS and 1 or 0
	local	O = isO and 2 or 0
	local	F = isF and 4 or 0
	local	T = isT and 8 or 0
	local	NO = isNO and 16 or 0
	local	NG = isNG and 32 or 0
	local	NT = isNT and 64 or 0

	return ( S + O + F + T + NO + NG + NT )
end

local function	ConvertHexToRGBTable(hex)
	local	r = math.floor(hex / 0x10000)
	local	g = math.floor((hex - r * 0x10000) / 0x100)
	local	b = hex - r * 0x10000 - g * 0x100

	return { r, g, b }
end

local function	ConvertRGBTableToHex(rgb)
	return (rgb[1] * 0x10000) + (rgb[2] * 0x100) + rgb[3]
end

local function RGBToHSV(rgb)
	local	r_norm = rgb[1] / 255
	local	g_norm = rgb[2] / 255
	local	b_norm = rgb[3] / 255

	local	max_val = math.max(r_norm, g_norm, b_norm)
	local	min_val = math.min(r_norm, g_norm, b_norm)
	local	delta = max_val - min_val

	local	h = 0
	local	s = 0
	local	v = max_val

	if max_val ~= 0 then
		s = delta / max_val
	else
		s = 0
	end

	if delta == 0 then
		h = 0
	else
		if max_val == r_norm then
			h = 60 * (((g_norm - b_norm) / delta) % 6)
		elseif max_val == g_norm then
			h = 60 * (((b_norm - r_norm) / delta) + 2)
		else
			h = 60 * (((r_norm - g_norm) / delta) + 4)
		end
	end

	return {h, s, v}
end

local function HSVToRGB(hsv)
	local	h = hsv[1]
	local	s = hsv[2]
	local	v = hsv[3]

	local	c = v * s
	local	x = c * (1 - math.abs((h / 60) % 2 - 1))
	local	m = v - c

	local	r1 = 0
	local	g1 = 0
	local	b1 = 0

	if h < 60 then
		r1, g1, b1 = c, x, 0
	elseif h < 120 then
		r1, g1, b1 = x, c, 0
	elseif h < 180 then
		r1, g1, b1 = 0, c, x
	elseif h < 240 then
		r1, g1, b1 = 0, x, c
	elseif h < 300 then
		r1, g1, b1 = x, 0, c
	else
		r1, g1, b1 = c, 0, x
	end

	local	R = math.floor((r1 + m) * 255 + 0.5)
	local	G = math.floor((g1 + m) * 255 + 0.5)
	local	B = math.floor((b1 + m) * 255 + 0.5)
	return {R, G, B}
end

local function SaturateRGB(block)
	local	hex = getBlockRGB(block)
	local	rgb = ConvertHexToRGBTable(hex)
	local	hsv = RGBToHSV(rgb)

	hsv[2] = factor

	local	newRGB = HSVToRGB(hsv)
	local	newHEX = ConvertRGBTableToHex(newRGB)
	return newHEX
end

-- MAIN FUNCTION
if (getBlock(x, y, z) == blocks.air or getBlockRGB(getBlock(x, y, z)) == nil) then
	return nil
else
	return findClosestBlockToRGB(SaturateRGB(getBlock(x, y, z)), GetFlagsBinary(), shift)
end
