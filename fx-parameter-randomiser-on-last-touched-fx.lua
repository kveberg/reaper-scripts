-- Randomises parameter of TrackFX on last touched FX --

local DEBUG = true
local DEBUG_VERBOSE = true
function msg(msg)
  if DEBUG then
    reaper.ShowConsoleMsg(tostring(msg .. "\n"))
  end
end
if DEBUG then msg("\nRunning fx-parameter-randomiser for focused FX") end


function RandomiseParameterValue(val, minval, maxval)
  local within_bounds = false
  local new_val
  while not within_bounds do
    new_val = math.random()
    if minval < new_val and new_val < maxval then
      within_bounds = true
    end
  end
  if DEBUG_VERBOSE then
    msg("Old value: " .. val .. " New value: " .. new_val .. "\n")
  end
  return new_val
end


function IterateFXParameters(track, fxno, fx_name)
    n_params_in_fx = reaper.TrackFX_GetNumParams(track, fxno)
    msg("FX " .. fxno .. ": " .. fx_name .. " has " .. n_params_in_fx .. " parameters")
    for paramno=1,n_params_in_fx do
      local val, minval, maxval, midval = reaper.TrackFX_GetParamEx(track, fxno, paramno)
      local _, param_name = reaper.TrackFX_GetParamName( track, fxno, paramno)
      if DEBUG_VERBOSE then
        msg("Value: " .. val .. " Min: " .. minval .. " Max: " .. maxval .. " Mid: " .. midval .. " " .. param_name)
      end
      local new_val = RandomiseParameterValue(val, minval, maxval)
      reaper.TrackFX_SetParam(track, fxno, paramno, new_val)
    end
end


function RandomiseLastTouchedOrFocusedFX()
  local retval, trackno, _, fxno = reaper.GetFocusedFX2()
  if retval == 1 or retval == 5 then
    local track = reaper.GetTrack(0, trackno-1)
    local _, fx_name = reaper.TrackFX_GetFXName(track, fxno)
    IterateFXParameters(track, fxno, fx_name)
  end
end


RandomiseLastTouchedOrFocusedFX()

