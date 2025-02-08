-- Requires Axiom 4.5.3 or later
-- Darken Brush script 1.5 by MazeWave

_G.factor = $float(Factor, 0.1, 0.05, 0.25)$
_G.islinear = $boolean(Decrease linearly (Introduce color bleed), false)$

local function	ConvertHexToRGBTable(hex)
	local	r = math.floor(hex / 0x10000)
	local	g = math.floor((hex - r * 0x10000) / 0x100)
	local	b = hex - r * 0x10000 - g * 0x100

	return { r, g, b }
end

local function	DarkenRGB(rgb, factor)
	rgb[1] = math.floor(rgb[1] * ( 1.0 - factor ))
	rgb[2] = math.floor(rgb[2] * ( 1.0 - factor ))
	rgb[3] = math.floor(rgb[3] * ( 1.0 - factor ))
	return { rgb[1], rgb[2], rgb[3] }
end

local function	DarkenLinearRGB(rgb, factor)
	local	newRGB = { rgb[1], rgb[2], rgb[3] }

	newRGB[1] = math.floor( newRGB[1] - ( factor * 127) )
	newRGB[2] = math.floor( newRGB[2] - ( factor * 127) )
	newRGB[3] = math.floor( newRGB[3] - ( factor * 127) )

	return {
		math.max(0, math.floor(newRGB[1])),
		math.max(0, math.floor(newRGB[2])),
		math.max(0, math.floor(newRGB[3]))
	}
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

-- MAIN FUNCTION
if (getBlock(x,y,z) == blocks.air) then
	return nil
else
	return findClosestBlockToRGB(getFinalDarkenRGBasHEX(getBlock(x, y, z)))
end