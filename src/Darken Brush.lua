-- Requires Axiom 4.5.3 or later
-- Darken Brush script 2.0 by MazeWave
-- Source : https://github.com/MazeWave/AxiomResources

-- USER INPUT
_G.factor		= $float(Factor, 0.1, 0.05, 0.25)$
_G.islinear		= $boolean(Use linear method (Can introduce color bleed), false)$
_G.isF				= $boolean([F] Use Full 1x1x1 Blocks, true)$
_G.isS				= $boolean([S] Use Solid Hitbox Blocks, true)$
_G.isO				= $boolean([O] Use Opaque Blocks, true)$
_G.isT				= $boolean([T] Use Same Textures on all sides, false)$
_G.isNO			= $boolean(No ores, false)$
_G.isNG			= $boolean(No glazed terracota, false)$
_G.isNT			= $boolean(No tile entities, true)$
_G.index			= $int(Index (Advanced), 1, 1, 10)$

-- GLOBAL
_G.scaled_factor	= math.floor( (factor / 2) * 255 )


-- FUNCTIONS
local function	GetFlagsBinary()
	local	F = isF and 1 or 0
	local	S = isS and 1 or 0
	local	O = isO and 1 or 0
	local	T = isT and 1 or 0
	local	NO = isNO and 1 or 0
	local	NG = isNG and 1 or 0
	local	NT = isNT and 1 or 0

	return ( (S * 1) + (O * 2) + (F * 4) + (T * 8) + (NO * 16) + (NG * 32) + (NT * 64) )
end

local function	ConvertHexToRGBTable(hex)
	local	r = math.floor(hex / 0x10000)
	local	g = math.floor((hex - r * 0x10000) / 0x100)
	local	b = hex - r * 0x10000 - g * 0x100

	return { r, g, b }
end

local function	DarkenRGB(rgb, factor)
	rgb[1] = math.floor( rgb[1] * (1.0 - factor) )
	rgb[2] = math.floor( rgb[2] * (1.0 - factor) )
	rgb[3] = math.floor( rgb[3] * (1.0 - factor) )
	return rgb
end

local function	DarkenLinearRGB(rgb, factor)
	rgb[1] = rgb[1] - scaled_factor
	rgb[2] = rgb[2] - scaled_factor
	rgb[3] = rgb[3] - scaled_factor

	if (rgb[1] - scaled_factor < 0) then
		rgb[1] = 0
	end
	if (rgb[2] - scaled_factor < 0) then
		rgb[2] = 0
	end
	if (rgb[3] - scaled_factor < 0) then
		rgb[3] = 0
	end
	return rgb
end

local function	ConvertRGBTableToHex(rgb)
	return (rgb[1] * 0x10000) + (rgb[2] * 0x100) + rgb[3]
end

local function	getFinalDarkenRGBasHEX(block)
	local	hex = getBlockRGB(block)

	if (islinear == true) then
		return (ConvertRGBTableToHex(DarkenLinearRGB(ConvertHexToRGBTable(hex), factor)))
	end

	return (ConvertRGBTableToHex(DarkenRGB(ConvertHexToRGBTable(hex), factor)))
end

local function	getFinalDarkenRGBasHEX(block)
	local	hex = getBlockRGB(block)

	if (islinear) then
		return (ConvertRGBTableToHex(DarkenLinearRGB(ConvertHexToRGBTable(hex), factor)))
	else
		return (ConvertRGBTableToHex(DarkenRGB(ConvertHexToRGBTable(hex), factor)))		
	end
end

-- MAIN FUNCTION
if (getBlock(x,y,z) == blocks.air) then
	return nil
else
	return findClosestBlockToRGB(getFinalDarkenRGBasHEX(getBlock(x, y, z)), GetFlagsBinary(), index)
end