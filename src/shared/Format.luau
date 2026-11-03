-- Formato de números grandes: 1234 → "1.2K", 5600000 → "5.6M".

local Format = {}

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

function Format.Number(n: number): string
	if n < 1000 then
		return tostring(math.floor(n))
	end

	local index = math.min(math.floor(math.log10(n) / 3), #SUFFIXES - 1)
	local value = n / 10 ^ (index * 3)
	local text
	if value >= 100 then
		text = tostring(math.floor(value))
	else
		text = (string.format("%.1f", math.floor(value * 10) / 10):gsub("%.0$", ""))
	end
	return text .. SUFFIXES[index + 1]
end

return Format
