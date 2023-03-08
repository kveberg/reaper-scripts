--------------------------------------------------
-- Just a collection of functions I find useful --
-- I did NOT necessarily write all these myself --
--------------------------------------------------
local function get_path()
  return debug.getinfo(1, 'S').source:match('^@(.+)[\\/]')
end


local function RgbToHex(r, g, b)
  return string.format("#%02X%02X%02X", r, g, b)
end

local function RgbaToHex(r, g, b, a)
  a = a * 255
  return string.format("#%02X%02X%02X%02X", r, g, b, a)
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
