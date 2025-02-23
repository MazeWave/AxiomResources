-- Requires Axiom 4.5.3 or later
-- Posterize Brush script 1.2 by MazeWave
-- Source : https://github.com/MazeWave/AxiomResources

-- USER INPUT
_G.steps		= $int(Steps, 8, 3, 16)$
_G.isF				= $boolean([F] Use Full 1x1x1 Blocks, true)$
_G.isS				= $boolean([S] Use Solid Hitbox Blocks, true)$
_G.isO				= $boolean([O] Use Opaque Blocks, true)$
_G.isT				= $boolean([T] Use Same Textures on all sides, false)$
_G.isNO			= $boolean(No ores, false)$
_G.isNG			= $boolean(No glazed terracota, false)$
_G.isNT			= $boolean(No tile entities, true)$
_G.index			= $int(Index (Advanced), 1, 1, 10)$

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
	local	g = math.floor( (hex - r * 0x10000) / 0x100 )
	local	b = hex - r * 0x10000 - g * 0x100

	return { r, g, b }
end

local function	ConvertRGBTableToHex(rgb)
	return (rgb[1] * 0x10000) + (rgb[2] * 0x100) + rgb[3]
end

function round(n)
	return n >= 0 and math.floor(n + 0.5) or math.ceil(n - 0.5)
end

local function clamp(x, min, max)
	return math.max(min, math.min(x, max))
end

local function QuantizeChannel(input)
	local	normalized = input / 255
	local	quantized = math.floor(normalized * (steps - 1) + 0.5) / (steps - 1)

	return clamp(math.floor(quantized * 255 + 0.5), 0, 255)
end

local function	GetQuantizedColorRGB(rgb)
	if steps < 3 then return rgb end

	return
	{
		QuantizeChannel(rgb[1]),
		QuantizeChannel(rgb[2]),
		QuantizeChannel(rgb[3])
	}
end

local function	Quantize(block)
	local	hex = getBlockRGB(block)
	local	rgb = ConvertHexToRGBTable(hex)
	local	newRGB = GetQuantizedColorRGB(rgb);
	local	newHEX = ConvertRGBTableToHex(newRGB)
	return newHEX
end

-- MAIN FUNCTION
if (getBlock(x, y, z) == blocks.air or getBlockRGB(getBlock(x, y, z)) == nil) then
	return nil
else
	return findClosestBlockToRGB(Quantize(getBlock(x, y, z)), GetFlagsBinary(), index)
end