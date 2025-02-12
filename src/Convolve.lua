function FTTConvolve1D(a, b)
	local	m = #a
	local	n = #b
	local	N = m + n - 1
	local	result = {}

	for i = 1, N do
		local	sum = 0
		local	jmin = math_max(1, i - m + 1)
		local	jmax = math_min(i, n)
		for j = jmin, jmax do
			sum = sum + a[i - j + 1] * b[j]
		end
		result[i] = sum
	end

	return result
end

-- Example usage:
local	signal = {1, 2, 3, 4}
local	kernel = {0.2, 0.5, 0.2}
local	output = FTTConvolve1D(signal, kernel)
