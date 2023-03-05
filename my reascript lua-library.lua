--------------------------------------------------
-- Just a collection of functions I find useful --
-- I did NOT necessarily write all these myself --
--------------------------------------------------

function rgbToHex(rgb)
  local hexadecimal = '0X'

  for key, value in pairs(rgb) do
    local hex = ''

    while(value > 0)do
      local index = math.fmod(value, 16) + 1
      value = math.floor(value / 16)
      hex = string.sub('0123456789ABCDEF', index, index) .. hex      
    end

    if(string.len(hex) == 0)then
      hex = '00'

    elseif(string.len(hex) == 1)then
      hex = '0' .. hex
    end

    hexadecimal = hexadecimal .. hex
  end

  return hexadecimal
end

local function log(msg, verbose)
  -- add booleans DEBUG and DEBUG_VERBOSE along with a \n at the start of the script to keep things tidy
  if DEBUG then
    if verbose and not DEBUG_VERBOSE then return end
    reaper.ShowConsoleMsg(tostring(msg .. "\n"))
  end
end


local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


local function spltodB(spl)
  return 20*math.log(spl, 10)
end


local function dBtospl(dB)
  return 10^(dB/20)
end
