local n_tracks = reaper.CountTracks(0)

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

local function spltodB(spl)
  return 20*math.log(spl, 10)
end

local function dBtospl(dB)
  return 10^(dB/20)
end

for i=1, n_tracks do
  local track = reaper.GetTrack(0, i-1)
  if reaper.IsTrackSelected(track) then
    local vol = reaper.GetMediaTrackInfo_Value(track,"D_VOL") -- gets fader level
    vol = spltodB(vol)
    vol = round(vol)
    vol = dBtospl(vol)
    reaper.SetMediaTrackInfo_Value(track, "D_VOL", vol)
  end
end
