-- Randomises parameter of TrackFX on selected tracks --


-- DEBUG HELPER --
local DEBUG = true
local DEBUG_VERBOSE = false
function msg(msg)
  if DEBUG then
    reaper.ShowConsoleMsg(tostring(msg .. "\n"))
  end
end
if DEBUG then msg("\nRunning fx-parameter-randomiser") end


-- A RANDOMISER AND THREE ITERATORS (tracks, fx, parameters) DO THE WORK --
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

 
function IterateTrackFX(trackno)
  local track = reaper.GetTrack(0, trackno)
  local n_fx_on_track = reaper.TrackFX_GetCount(track)
  msg("Found " .. n_fx_on_track .. " FX on current track")
  for fxno=0,n_fx_on_track-1 do
    local _, fx_name = reaper.TrackFX_GetFXName(track, fxno)
    IterateFXParameters(track, fxno, fx_name)
  end
end


function IterateSelectedTracks()
  local n_tracks_selected = reaper.CountSelectedTracks2(0, false)
  if n_tracks_selected > 0 then
    math.randomseed(os.time())
    msg(n_tracks_selected .. " tracks selected")
    local n_tracks = reaper.GetNumTracks()
    for trackno= 0,n_tracks-1 do
      if reaper.IsTrackSelected(reaper.GetTrack(0, trackno)) then
        msg("Working on track " .. trackno)
        IterateTrackFX(trackno)
      end
    end
  end
end


-- INITIATE SCRIPT --
IterateSelectedTracks()

