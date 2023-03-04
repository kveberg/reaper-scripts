--------------------------------------------------
-- Just a collection of functions I find useful --
--------------------------------------------------

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
