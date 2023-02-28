local ctx = reaper.ImGui_CreateContext('minimalist-reaimgui')

-- MAKE SCRIPT TOGGLEABLE --
local _, _, sectionID, cmdID, _, _, _ = reaper.get_action_context()
reaper.SetToggleCommandState(sectionID, cmdID, 1)
reaper.RefreshToolbar2(sectionID, cmdID)
function DoAtExit()
  -- set toggle state to off
  reaper.SetToggleCommandState(sectionID, cmdID, 0);
  reaper.RefreshToolbar2(sectionID, cmdID);
end

-- MAIN LOOP --
local function loop()
  -- Push style tweaks --
  local col_bg = 0x292929ff
  local window_flags = reaper.ImGui_WindowFlags_NoCollapse() | reaper.ImGui_WindowFlags_NoTitleBar() | reaper.ImGui_WindowFlags_NoResize()
  reaper.ImGui_SetNextWindowBgAlpha(ctx, 0.9)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBgActive() | reaper.ImGui_Col_WindowBg(), col_bg)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowRounding(), 8)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowMinSize(), 300, 300)
  
  -- Create Windows context --
  local visible, open = reaper.ImGui_Begin(ctx, 'minimalist-reaimgui', true, window_flags)
  
  if visible then
    
    reaper.ImGui_End(ctx)
  end
  
  -- Pop style tweaks --
  reaper.ImGui_PopStyleColor(ctx) 
  reaper.ImGui_PopStyleVar(ctx, 2)
  
  if open then
    
    reaper.defer(loop)
  end
end


-- RUN SCRIPT --
reaper.defer(loop)
reaper.atexit(DoAtExit)
