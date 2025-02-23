--[[ 
This code implements 1D convolution via the Fast Fourier Transform (FFT).
The overall strategy is:
	1. Pad the two real input sequences to a length that is a power of two and
	at least as large as (m + n – 1), where m and n are the lengths of the inputs.
	2. Represent the sequences as arrays of complex numbers (each element has a real part 'r'
	and an imaginary part 'i', with i = 0 for the real data).
	3. Compute the FFT of both padded arrays.
	4. Multiply the resulting complex arrays pointwise.
	5. Compute the inverse FFT (IFFT) of the product.
	6. The real parts of the IFFT result (up to index m+n–1) are the convolution result.
]]

-- Complex arithmetic functions
local	function c_add(a, b)
	return { r = a.r + b.r, i = a.i + b.i }
end

local	function c_sub(a, b)
	return { r = a.r - b.r, i = a.i - b.i }
end

local	function c_mul(a, b)
	return { r = a.r * b.r - a.i * b.i, i = a.r * b.i + a.i * b.r }
end

local function c_exp(theta)
	-- Returns the complex exponential: exp(i * theta) = cos(theta) + i*sin(theta)
	return { r = math.cos(theta), i = math.sin(theta) }
end

-- Recursive FFT implementation
local	function fft(a)
	local	n = #a
	if n == 1 then
		return { a[1] }
	end

	local	even = {}
	local	odd = {}
	for i = 1, n/2 do
		even[i] = a[2 * i - 1]
		odd[i]  = a[2 * i]
	end

	local	Feven = fft(even)
	local	Fodd  = fft(odd)
	local	F = {}
	for k = 1, n/2 do
		local	theta = -2 * math.pi * (k - 1) / n
		local	w = c_exp(theta)
		local	t = c_mul(w, Fodd[k])
		F[k]         = c_add(Feven[k], t)
	F[k + n/2]   = c_sub(Feven[k], t)
	end

	return F
end

-- Inverse FFT (using the conjugation method)
local	function ifft(a)
	local	n = #a
	local	conj = {}
	for i = 1, n do
		conj[i] = { r = a[i].r, i = -a[i].i }
	end
	local	y = fft(conj)
	local	inv = {}
	for i = 1, n do
		inv[i] = { r = y[i].r / n, i = -y[i].i / n }
	end
	return inv
end

-- Convolution using FFT
function	FTTConvolve1D(a, b)
	local	m = #a
	local	n = #b
	local	N = m + n - 1

	-- Compute the next power-of-two length for FFT
	local	Nfft = 1
	while Nfft < N do
		Nfft = Nfft * 2
	end

	-- Prepare padded complex arrays (with imaginary parts = 0)
	local	A = {}
	local	B = {}
	for i = 1, Nfft do
		A[i] = { r = (i <= m and a[i] or 0), i = 0 }
		B[i] = { r = (i <= n and b[i] or 0), i = 0 }
	end

	-- Compute FFT of both sequences
	local	FA = fft(A)
	local	FB = fft(B)

	-- Pointwise multiply the two FFTs
	local	FC = {}
	for i = 1, Nfft do
		FC[i] = c_mul(FA[i], FB[i])
	end

	-- Compute the inverse FFT to get the convolution result
	local	C = ifft(FC)

	-- Extract the real part for the first N values (the valid convolution length)
	local	result = {}
	for i = 1, N do
		result[i] = C[i].r
	end

	return result
end

--[[
	Example usage:

	local a = {1, 2, 3}
	local b = {4, 5, 6}
	local result = FTTConvolve1D(a, b)
	for i = 1, #result do
	print(result[i])
	end

	Expected output:
	4
	13
	28
	27
	18
]]