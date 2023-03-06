-----------------------------------------------------------------------------
------------------------------- FOR DEBUGGING -------------------------------
-----------------------------------------------------------------------------
DEBUG = false
DEBUG_VERBOSE = false
local function log(msg, verbose)
  if DEBUG then
    if verbose and not DEBUG_VERBOSE then return end
    reaper.ShowConsoleMsg(tostring(msg .. "\n"))
  end
end
log("-----------------------------------------------------------")
log("Running script ...")


---------------------------------------------------------------------------------
------------------------------- INITIALISE THINGS -------------------------------
---------------------------------------------------------------------------------
math.randomseed(os.time())
math.random(); math.random(); math.random()

local w = 600.0
local h = 700.0

local tilesize = 20              -- target number of tiles w here
local theme = 1                  -- 1 = static random, 2 = twinkle random
local tilecol_rgbval_min = 0
local tilecol_rgbval_max = 255
local tilecol_pulsespeed_max = 3
local tileopacity = "ff"
local nwtiles, nhtiles, wtilesize, htilesize -- these are set by CalculateTileVariables() which is called by CreateTileArray()
local bg_colors = {0xACCBF1F1,-- 1: light blue
                  0x4188FFEC, -- 2: darker blue
                  0xFFCC00EA, -- 3: yellow
                  0x395144FA, -- 4: Green
                  0x4E0707F7, -- 5: Red
                  0x00008BEF, -- 6: dark blue
                  0x000000F3, -- 7: black
                  
                  } 
bg_color = bg_colors[4]


-- MAKE SCRIPT TOGGLEABLE --
local _, _, sectionID, cmdID, _, _, _ = reaper.get_action_context()
reaper.SetToggleCommandState(sectionID, cmdID, 1)
reaper.RefreshToolbar2(sectionID, cmdID)
function DoAtExit()
  -- set toggle state to off
  reaper.SetToggleCommandState(sectionID, cmdID, 0);
  reaper.RefreshToolbar2(sectionID, cmdID);
end


--------------------------------------------------------------------------------
------------------------------- HELPER FUNCTIONS -------------------------------
--------------------------------------------------------------------------------


local function FlipBool(bool)
  -- returns flipped boolean
  if bool then return false
  end
  if not bool then return true
  end
end


function RgbToHex(rgb)
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
  hexadecimal = string.sub(hexadecimal, 1, 8) .. tileopacity                  
  return hexadecimal
end


local dbg_nprint = 0
function nprint(msg, n)
  if dbg_nprint < n then
    reaper.ShowConsoleMsg("\n" .. tostring(msg))
    dbg_nprint = dbg_nprint + 1 
  end
end


function CalculateTileVariables(w, h)
  wtilesize = math.floor(w / tilesize)                                        -- whole tiles that fit w
  wtilesize = wtilesize + ((math.fmod(w, tilesize)) / (w / wtilesize))        -- add the remainder divided across all the tiles
  htilesize = math.floor(h / tilesize)                                      
  htilesize = htilesize + ((math.fmod(h, tilesize)) / (h / htilesize)) 
  nwtiles = w / wtilesize
  nhtiles = h / htilesize
end


function CreateTileArray(w, h, theme)
  CalculateTileVariables(w, h)
  local tilearray = {}
  local new_tile = {}
  for htile=1, nhtiles do
    local tilerow = {}
    for wtile=1, nwtiles do
      -- R, G, B, pulse_speed and pulse_direction variables
      if theme == 2 then 
        new_tile = {math.random(tilecol_rgbval_min, tilecol_rgbval_max), 
                    math.random(tilecol_rgbval_min, tilecol_rgbval_max), 
                    math.random(tilecol_rgbval_min, tilecol_rgbval_max), 
                    math.random(tilecol_pulsespeed_max),
                    math.random(1, 2),
                    math.random(1, 2),
                    math.random(1, 2)}
      end
      if theme == 1 then
        local direction = math.random(1, 2)
        new_tile = {math.random(tilecol_rgbval_min, tilecol_rgbval_max), 
                    math.random(tilecol_rgbval_min, tilecol_rgbval_max), 
                    math.random(tilecol_rgbval_min, tilecol_rgbval_max), 
                    math.random(tilecol_pulsespeed_max),
                    direction, direction, direction}
      end
      table.insert(tilerow, new_tile)
    end
    table.insert(tilearray, tilerow)
  end
  return tilearray
end
local tilearray = CreateTileArray(w, h, theme)


local function PulsateColor(rgb, change, direction)
  new_rgb = {}
  for key, value in pairs(rgb) do
    if direction[key] == 1 then -- 1 is up
      if value < 265 then
        value = value + change
      end
      if value >= 255 then
        direction[key] = 2
      end
    end
    if direction[key] == 2 then -- 2 is down
      if value > -1 then
        value = value - change
      end
      if value <= 0 then
        direction[key] = 1
      end
    end
    table.insert(new_rgb, math.floor(value))
  end
  return {new_rgb, direction}
end


local function DrawTiles(draw_list, x, y)

  for htile=1, nhtiles do
    for wtile=1, nwtiles do
      local rgb = {}
      local direction = {}
      local updated_tile = {}
      --                            X      Y
      table.insert(rgb, tilearray[htile][wtile][1])
      table.insert(rgb, tilearray[htile][wtile][2])
      table.insert(rgb, tilearray[htile][wtile][3])
      change = tilearray[htile][wtile][4]
      table.insert(direction, tilearray[htile][wtile][5])
      table.insert(direction, tilearray[htile][wtile][6])
      table.insert(direction, tilearray[htile][wtile][7])
      
      local col_pulsated = PulsateColor(rgb, change, direction)
       
      table.insert(updated_tile, col_pulsated[1][1])
      table.insert(updated_tile, col_pulsated[1][2])
      table.insert(updated_tile, col_pulsated[1][3])
      table.insert(updated_tile, change)
      table.insert(updated_tile, col_pulsated[2][1])
      table.insert(updated_tile, col_pulsated[2][2])
      table.insert(updated_tile, col_pulsated[2][3])
      
      --nprint(tostring(updated_tile[4]), 10)
    
      tilearray[htile][wtile] = updated_tile
      
      reaper.ImGui_DrawList_AddRectFilled(draw_list, 
        x + ((htile-1)*wtilesize), 
        y + ((wtile-1)*htilesize), 
        x + (htile*wtilesize), 
        y + (wtile*htilesize), 
        RgbToHex(rgb))
      
    end
  end
end



-------------------------------------------------------------------------
------------------------------- MAIN LOOP -------------------------------
-------------------------------------------------------------------------

local previous_w = w
local previous_h = h
local new_w, new_h
local ctx = reaper.ImGui_CreateContext("imgui empty template")

local function main()
  -- Push style tweaks --
  local col_bg = 0x292929ff
  local window_flags = reaper.ImGui_WindowFlags_NoCollapse() | reaper.ImGui_WindowFlags_NoTitleBar() | reaper.ImGui_WindowFlags_NoResize() 
  reaper.ImGui_SetNextWindowBgAlpha(ctx, 0)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_TitleBgActive() | reaper.ImGui_Col_WindowBg(), col_bg)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowRounding(), 5)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowMinSize(), w, h)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowPadding(), 0, 0)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowBorderSize(), 0)
  
  reaper.ImGui_SetWindowSizeEx(ctx, "imgui empty template", w, h)
  
  
  -- Begin main window context and draw background --
  local visible, open = reaper.ImGui_Begin(ctx, "imgui empty template", true, window_flags)
  local x, y = reaper.ImGui_GetWindowPos(ctx)
  local draw_list = reaper.ImGui_GetWindowDrawList(ctx)
  
  new_w, new_h = reaper.ImGui_GetWindowSize(ctx)
    if new_w ~= previous_w then 
      tilearray = CreateTileArray(new_w, new_h, theme)
      previous_w = new_w
    end
    
    if new_h ~= previous_h then 
      tilearray = CreateTileArray(new_w, new_h, theme) 
      previous_h = new_h
    end
  
  DrawTiles(draw_list, x, y)
  reaper.ImGui_DrawList_AddRectFilled(draw_list, x, y, x+previous_w, y+previous_h, bg_color)
  
  -- Build program GUI from here on ... --
  if visible then
    
    
  
    reaper.ImGui_End(ctx)
  end
  
  -- Pop style and color stacks --
  reaper.ImGui_PopStyleColor(ctx) 
  reaper.ImGui_PopStyleVar(ctx, 4)
  
  if open then
    
    reaper.defer(main)
  end
end

----------------------------------------------------------------------------------
------------------------------- LAUNCH & TERMINATE -------------------------------
----------------------------------------------------------------------------------
reaper.defer(main)
reaper.atexit(DoAtExit)
