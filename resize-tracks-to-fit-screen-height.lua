------------------------------------------
--- RESIZE TRACKS TO FIT SCREEN HEIGHT ---
------------------------------------------
-- Increase/decrease below pad-variable --
--   to calibrate it to your liking.    --
------------------------------------------
local set_this_pad_to_your_liking = 0
------------------------------------------


------------------------------- CODE THAT DOES THE DEED. -------------------------------
set_this_pad_to_your_liking = set_this_pad_to_your_liking + 250     -- add ~space of UI 
local previous_selection = {}
local n_tracks = reaper.CountTracks(0)
local _, _, w, h = reaper.my_getViewport(0, 0, 0, 0, 0, 0, 0, 0, 1) -- Closest thing to documentation here: https://forum.cockos.com/showpost.php?p=1883879&postcount=4
local track_size = (h - set_this_pad_to_your_liking) / n_tracks
local track

for i=1, n_tracks, 1 do
  track = reaper.GetTrack(0, i-1)
  if reaper.IsTrackSelected(track) then table.insert(previous_selection, 1, i) end
  reaper.SetTrackSelected(track, true)
  reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", track_size)
  reaper.SetTrackSelected(track, false)
end

--reaper.ShowConsoleMsg(tostring(previous_selection)
for i, v in ipairs(previous_selection) do
  track = reaper.GetTrack(0, v-1)
  reaper.SetTrackSelected(track, true)
end
