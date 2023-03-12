-- IT WORKS BUT IS NOT PARTICULARLY USER FRIENDLY AT THE MOMENT. MAY IMPROVE UPON IT LATER. --




SCRIPTNAME = "Twinkling Tiles for ReaImGui using LUA"
math.randomseed(os.time())
math.random()
math.random()
math.random()



-----------------------------------
--helpers--------------------------
-----------------------------------
local path = debug.getinfo(1, 'S').source:match('^@(.+)[\\/]')


local function RgbToHex(r, g, b)
  return string.format("%02X%02X%02X", r, g, b)
end



function HexToRgb(hex)
 hex = hex:gsub('#','')
 if(string.len(hex) == 3) then
    return tonumber('0x'..hex:sub(1,1)) * 17, tonumber('0x'..hex:sub(2,2)) * 17, tonumber('0x'..hex:sub(3,3)) * 17
  elseif(string.len(hex) == 6) then
    return tonumber('0x'..hex:sub(1,2)), tonumber('0x'..hex:sub(3,4)), tonumber('0x'..hex:sub(5,6))
  else
    return 0, 0, 0
  end
end



local function CreateRandomColor()
  local r = math.random(0, 255)
  local g = math.random(0, 255)
  local b = math.random(0, 255)
  return RgbToHex(r, g, b)
end



local function number_to_bool(value)
  if value == 1 then return true end
  return false
end



local function FlipBool(bool)
  if bool then return false end
  return true
end


-----------------------------------
--configure------------------------
-----------------------------------


COLORPULSE_MAX_RANGE = 50
COLORPULSE_MAX_STEP = 10

ALPHAPULSE_MAX_STEP_DIVISOR = 100 -- A call to math.random(1, 5) divided by this number decides how fast alpha changes.

local function SelectTileConfig(configname)
  
  if configname == "neon" then return 
    {
             {"exists",                       "random"},
             {"palette",                      "midnightmagick"},   
             {"colorpulse",                   true},   
             {"colorpulse_range",             "random"},  
             {"colorpulse_unison",            true},     
             {"colorpulse_direction_unison",  "random"},
             {"colorpulse_unison_step",       "random"},
             {"colorpulse_r",                 "random"},  
             {"colorpulse_g",                 "random"},  
             {"colorpulse_b",                 "random"},
             {"colorpulse_direction_r",       "random"}, 
             {"colorpulse_direction_g",       "random"}, 
             {"colorpulse_direction_b",       "random"},
             {"alpha",                        "random"},
             {"alphapulse",                   true},
             {"alphapulse_step_up",           "random"},
             {"alphapulse_step",              "random"},
             {"tilepad",                          true},
             {"tilepad_size",                  "random"}
    }
  end
end



local function GetRandomColorFromPalette(name)
  -- see https://www.color-hex.com for more
  local palette = {}
  if name == "neon" then palette = {"39FF14",
                    "7FFF00",
                    "CCFF00",
                    "FF3131",
                    "FF5E00",
                    "FFF01F",
                    "E7EE4F",
                    "DFFF00",
                    "FF44CC",
                    "EA00FF",
                    "FF1493",
                    "BC13FE",
                    "8A2BE2",
                    "1F51FF",
                    "0FF0FC"}
  end
  
  if name == "sorbetdreams" then palette =
                            {"FFA07A",
                            "FF7F50",
                            "FF6347",
                            "FA8072", 
                            "D2B48C"}
  end
  
  if name == "midnightmagick" then palette = 
                              {"090c08",
                              "3b0f47",
                              "45173d",
                              "722f37",
                              "a23e48"}
  end
  
  if name == "random" then return CreateRandomColor() end
  
  return palette[math.random(1,#palette)]
  
end

                            


-----------------------------------
--debug----------------------------
-----------------------------------
DEBUG = false
DEBUG_VERBOSE = false
dbg_nprint = 10
dbg_ntiles_created = 0


if DEBUG then
  reaper.ClearConsole()
  reaper.ShowConsoleMsg("\n\n")
  for i=1, string.len(SCRIPTNAME), 1 do reaper.ShowConsoleMsg("-") end
  reaper.ShowConsoleMsg("\n" .. SCRIPTNAME .. "\n")
  for i=1, string.len(SCRIPTNAME), 1 do reaper.ShowConsoleMsg("-") end
end


local function Log(msg, verbose)
  if DEBUG then
    if verbose and not DEBUG_VERBOSE then return end
    reaper.ShowConsoleMsg("\n" ..tostring(msg))
  end
end


local dbg_nprint_log = {}
function nPrint(msg, n, id)
  local current = {id, n}
  for i in pairs(dbg_nprint_log) do
    if dbg_nprint_log[i][1] == id then
      if dbg_nprint_log[i][2] == 0 then
        return
      end
      if dbg_nprint_log[i][2] > 0 then
        dbg_nprint_log[i][2] = dbg_nprint_log[i][2] - 1
        reaper.ShowConsoleMsg("\n" .. tostring(msg))
        return
      end
    end
  end
  table.insert(dbg_nprint_log, current)
  nPrint(msg, n, id)
end





-----------------------------------
--twinkling tile code--------------
-----------------------------------

-- tile size
local tilesize_w, tilesize_h, n_wtiles, n_htiles

local function CalculateTileSize(w, h, desired_tilesize)
  -- pass the width and height of the window in question along with a table {width-tile-size, height-tile-size}
  n_wtiles = math.floor(w/desired_tilesize[1])                                       
  tilesize_w = desired_tilesize[1] + (math.fmod(w, desired_tilesize[1]) / n_wtiles)       
  n_htiles = math.floor(h/desired_tilesize[2])                                               
  tilesize_h = desired_tilesize[2] + (math.fmod(h, desired_tilesize[2]) / n_htiles)
end


-- create new tile
local function CreateNewTile(tileconfig)
  Log("Creating new tile", true)
  local x
  new_tile = {}
  local k, v
  for parameter, setting in ipairs(tileconfig) do
    k = setting[1]
    v = setting[2]
    
    if DEBUG_VERBOSE then
      Log("CreateTile read tileconfig: " .. parameter .. " {" .. tostring(k) .. ", " .. tostring(v) .. "}")
    end
    
    if k == "exists" then
      if v == "random" then table.insert(new_tile, {"exists", number_to_bool(math.random(0,1))}) end
      if v == true or v == false then table.insert(new_tile, {"exists", v}) end
    end
    
    
    if k == "palette" then
      table.insert(new_tile, {"palette", GetRandomColorFromPalette(v)})
    end
    
    if k == "colorpulse" then
      if v == "random" then table.insert(new_tile, {"colorpulse", number_to_bool(math.random(0, 1))}) end
      if v ~= "random" then table.insert(new_tile, {"colorpulse", v}) end
    end
    
    
    if k == "colorpulse_range" then
      if v == "random" then table.insert(new_tile, {"colorpulse_range", math.random(1,COLORPULSE_MAX_RANGE)}) end              
      if v ~= "random" then table.insert(new_tile, {"colorpulse_range", math.random(0, v)}) end
    end
    
    
    if k == "colorpulse_unison" then
      if v == true then table.insert(new_tile, {"colorpulse_unison", math.random(1, COLORPULSE_MAX_STEP)}) end
      if v == false then table.insert(new_tile, {"colorpulse_unison", false}) end
    end
    
    if k == "colorpulse_r" then
      if v == "random" then table.insert(new_tile, {"colorpulse_r", math.random(1, COLORPULSE_MAX_STEP)}) end
      if math.type(v) == "integer" then table.insert(new_tile, {"colorpulse_r", v}) end
    end
    
    
    if k == "colorpulse_g" then
      if v == "random" then table.insert(new_tile, {"colorpulse_g", math.random(1, COLORPULSE_MAX_STEP)}) end
      if math.type(v) == "integer" then table.insert(new_tile, {"colorpulse_g", v}) end
    end
    
    
    if k == "colorpulse_b" then
      if v == "random" then table.insert(new_tile, {"colorpulse_b", math.random(1, COLORPULSE_MAX_STEP)}) end
      if math.type(v) == "integer" then table.insert(new_tile, {"colorpulse_b", v}) end
    end
    
    
    if k == "colorpulse_direction_unison" then
      if v == "random" then table.insert(new_tile, {"colorpulse_direction_unison", number_to_bool(math.random(0,1))}) end
      if v == true then table.insert(new_tile, {"colorpulse_direction_unison", v}) end
      if v == false then table.insert(new_tile, {"colorpulse_direction_unison", v}) end
    end
    
    if k == "colorpulse_unison_step" then
      if v == "random" then table.insert(new_tile, {"colorpulse_unison_step", math.random(1, COLORPULSE_MAX_STEP)}) end
      if math.type(v) == "integer" then table.insert(new_tile, {"colorpulse_unison_step", v}) end
      if math.type(v) == "float" then table.insert(new_tile, {"colorpulse_unison_step", v}) end
    end


    if k == "colorpulse_direction_r" then
      if v == "random" then table.insert(new_tile, {"colorpulse_direction_r", number_to_bool(math.random(0,1))}) end
      if math.type(v) == "integer" then table.insert(new_tile, {"colorpulse_direction_r", v}) end
    end
    
    
    if k == "colorpulse_direction_g" then
      if v == "random" then table.insert(new_tile, {"colorpulse_direction_g", number_to_bool(math.random(0,1))}) end
      if math.type(v) == "integer" then table.insert(new_tile, {"colorpulse_direction_g", v}) end
    end
    
    
    if k == "colorpulse_direction_b" then
      if v == "random" then table.insert(new_tile, {"colorpulse_direction_b", number_to_bool(math.random(0,1))}) end
      if math.type(v) == "integer" then table.insert(new_tile, {"colorpulse_direction_b", v}) end
    end
    
    
    if k == "alpha" then
      if v == "random" then table.insert(new_tile, {"alpha", math.random()}) end
      if math.type(v) == "float" then table.insert(new_tile, {"alpha", v}) end
    end
    
    
    if k == "alphapulse" then
      if v == "random" then table.insert(new_tile, {"alphapulse", number_to_bool(math.random(0,1))}) end
      if v == true then table.insert(new_tile, {"alphapulse", true}) end
      if v == false then table.insert(new_tile, {"alphapulse", false}) end
    end
    
    
    if k == "alphapulse_step_up" then
      if v == "random" then table.insert(new_tile, {"alphapulse_step_up", number_to_bool(math.random(0,1))}) end
      if v == true then table.insert(new_tile, {"alphapulse_step_up", true}) end
      if v == false then table.insert(new_tile, {"alphapulse_step_up", false}) end
    end
    
    
    if k == "alphapulse_step" then
      if v == "random" then table.insert(new_tile, {"alphapulse_step", math.random(1,5)/ALPHAPULSE_MAX_STEP_DIVISOR}) end
      if math.type(v) == "float" then table.insert(new_tile, {"alphapulse_step", v}) end
    end
    
    
    if k == "tilepad" then
      if v == "random" then table.insert(new_tile, {"tilepad", number_to_bool(math.random(0,1))}) end
      if math.type(v) == "boolean" then table.insert(new_tile, {"tilepad", v}) end
    end
    
    
    if k == "tilepad_size" then
      if v == "random" then table.insert(new_tile, {"tilepad_size", math.random()}) end
      if math.type(v) == "integer" then table.insert(new_tile, {"tilepad_size", v}) end
    end
  
  end
  
  if DEBUG_VERBOSE then
    for parameter, setting in ipairs(new_tile) do
      k = setting[1]
      v = setting[2]
      Log("CreateTile wrote new tile: " .. parameter .. " {" .. tostring(k) .. ", " .. tostring(v) .. "}")
    end
  end
  return new_tile
end


local function GetTileValue(htile, wtile, parameter)
  local tile = tile_table[htile][wtile]
  for p, s in ipairs(tile) do
    if s[1] == parameter then return s[2] end
  end
end


local function SetTileValue(htile, wtile, parameter, new_setting)
  local tile = tile_table[htile][wtile]
  for p, s in ipairs(tile) do
    if s[1] == parameter then tile_table[htile][wtile][p][2] = new_setting end
  end
end


local function TwinkleTile(rgb, change, direction)
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


local function ClampColor(col)
  if col <= 0 then return 0 end
  if col >= 255 then return 255 end
  return col
end


local function TwinkleTileRgb(htile, wtile)

  if GetTileValue(htile, wtile, "colorpulse") then
    local color, new_color, r, g, b, cirection, step
    local flip_direction = false
    range = GetTileValue(htile, wtile, "colorpulse_range")
    color = GetTileValue(htile, wtile, "palette")
    r, g, b = HexToRgb(color)
    
    if GetTileValue(htile, wtile, "colorpulse_unison") ~= false then
      direction = GetTileValue(htile, wtile, "colorpulse_direction_unison")
      step = GetTileValue(htile, wtile, "colorpulse_unison_step")
      
      
      if direction then
        
        r = r + step
        g = g + step
        b = b + step

        
        if r >= 255 then
          r = 255
          flip_direction = true
        end
        
        if g >= 255 then
          g = 255
          flip_direction = true
        end
        
        if b >= 255 then
          b = 255
          flip_direction = true
        end
        
      end
      
      
      if direction == false then
        r = r - step
        g = g - step
        b = b - step
      
        if r <= 0 then
          r = 0
          flip_direction = true
        end
        
        if g <= 0 then
          g = 0
          flip_direction = true
        end
        
        if b <= 0 then
          b = 0
          flip_direction = true
        end
        
      end
    end
    
    if GetTileValue(htile, wtile, "colorpulse_unison") == false then
      local r_step, g_step, b_step, r_direction, g_direction, b_direction
      r_step = GetTileValue(htile, wtile, "colorpulse_r")
      g_step = GetTileValue(htile, wtile, "colorpulse_g")
      b_step = GetTileValue(htile, wtile, "colorpulse_b")
      r_direction = GetTileValue(htile, wtile, "colorpulse_direction_r")
      g_direction = GetTileValue(htile, wtile, "colorpulse_direction_g")
      b_direction = GetTileValue(htile, wtile, "colorpulse_direction_b")
      
      if r_direction then r = ClampColor(r + r_step) end
      if not r_direction then r = ClampColor(r - r_step) end
      if g_direction then g = ClampColor(g + g_step) end
      if not g_direction then g = ClampColor(g - g_step) end
      if b_direction then b = ClampColor(b + b_step) end
      if not b_direction then b = ClampColor(b - b_step) end
      
      if r == 0 or r == 255 then SetTileValue(htile, wtile, "colorpulse_direction_r", FlipBool(r_direction)) end
      if g == 0 or g == 255 then SetTileValue(htile, wtile, "colorpulse_direction_g", FlipBool(g_direction)) end
      if b == 0 or b == 255 then SetTileValue(htile, wtile, "colorpulse_direction_b", FlipBool(b_direction)) end
      
      
    end
    
  
  if flip_direction then SetTileValue(htile, wtile, "colorpulse_direction_unison", FlipBool(direction)) end
  new_color = RgbToHex(r, g, b)
  SetTileValue(htile, wtile, "palette", new_color)  
  
  end
end

    
local function TwinkleTileAlpha(htile, wtile)
  if GetTileValue(htile, wtile, "alphapulse") then
    local new_alpha
    local alpha = GetTileValue(htile, wtile, "alpha")
    local alpha_step = GetTileValue(htile, wtile, "alphapulse_step")
    local alpha_step_up = GetTileValue(htile, wtile, "alphapulse_step_up")
    if alpha_step_up then
      new_alpha = alpha + alpha_step
      if new_alpha > 1.0 then new_alpha = 1.0 end 
    end
        
    if not alpha_step_up then
      new_alpha = alpha - alpha_step
      if new_alpha < 0.0 then new_alpha = 0.0 end
    end
    
    if new_alpha == 1.0 then
      SetTileValue(htile, wtile, "alphapulse_step_up", FlipBool(alpha_step_up))
    end
    
    if new_alpha == 0.0 then
      SetTileValue(htile, wtile, "alphapulse_step_up", FlipBool(alpha_step_up))
    end
    
    SetTileValue(htile, wtile, "alpha", new_alpha)
    --nPrint(alpha-new_alpha, 10, "test")

  end
  
end


tile_table = {"none"}
local tiletable_w, tiletable_h
local function CreateTileTable(current_w, current_h, tileconfig, desired_tilesize)
  CalculateTileSize(current_w, current_h, desired_tilesize)
  tiletable_w = current_w
  tiletable_h = current_h
  
  new_tile_table = {}
  local tile_row = {}
  for i=1, n_htiles do
    tile_row = {}
    for i=1, n_wtiles do
      table.insert(tile_row, CreateNewTile(tileconfig))
    end
    table.insert(new_tile_table, tile_row)
  end
  tile_table = new_tile_table
  
  --Log("Created new Tile Table suited a window of w:" .. current_w .. " h:" .. current_h)
  --Log("It has " .. #tile_table .. " htiles and " .. #tile_table[1] .. " wtiles")
end

local switch = false
local function DrawTwinklingTiles(draw_list, current_w, current_h, x, y, tileconfig, desired_tilesize, variant)

  if tile_table[1] == "none" then 
    --Log("No tile table detected. Creating new one")
    CreateTileTable(current_w, current_h, tileconfig, desired_tilesize)
  end
  if current_w ~= tiletable_w or current_h ~= tiletable_h then
    --Log("Window has been resized. Creating new one")
    CreateTileTable(current_w, current_h, tileconfig, desired_tilesize)
  end
  
  local p_min_x, p_min_y, p_max_x, p_max_y, color
  
  for htile=1, n_htiles do
    
    for wtile=1, n_wtiles do
      
      if GetTileValue(htile, wtile, "exists") then
        p_min_x = x + ((wtile-1)*tilesize_w)
        p_min_y = y + ((htile-1)*tilesize_h)
        p_max_x = x + ((wtile-1)*tilesize_w) + tilesize_w
        p_max_y = y + ((htile-1)*tilesize_h) + tilesize_h
        color = GetTileValue(htile, wtile, "palette")
        
        TwinkleTileAlpha(htile, wtile)
        TwinkleTileRgb(htile, wtile)
        color = string.format("0x" .. color)
        color_alpha = color .. string.format("%02X", 0.0)
        color = color .. string.format("%02x", math.floor(GetTileValue(htile, wtile, "alpha")*255))
        
        if variant == "simple" then
          reaper.ImGui_DrawList_AddRectFilled(draw_list, p_min_x, p_min_y, p_max_x, p_max_y, color)
        end
        
        col2 = 0x005500
        
        if variant == "reverse_glow" then
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x, p_min_y, p_max_x, p_max_y, col2, col2, color, color)
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x, p_min_y, p_max_x, p_max_y, color, color, col2, col2)
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x, p_min_y, p_max_x, p_max_y, col2, color, color, col2)
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x, p_min_y, p_max_x, p_max_y, color, col2, col2, color)
        end
        if variant == "glow" then
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x, p_min_y, p_max_x, p_max_y, color, color, col2, col2)
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x, p_min_y, p_max_x, p_max_y, col2, col2, color, color)
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x, p_min_y, p_max_x, p_max_y, color, col2, col2, color)
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x, p_min_y, p_max_x, p_max_y, col2, color, color, col2)
        end
        
        if variant == "spaced" then
          local pad = 2
          reaper.ImGui_DrawList_AddRectFilled(draw_list, p_min_x + pad, p_min_y + pad, p_max_x - pad, p_max_y - pad, color)
        end
        
        if variant == "glowing" then
          local pad = 10
          local spacing = 3
          reaper.ImGui_DrawList_AddRectFilled(draw_list, p_min_x + pad, p_min_y + pad, p_max_x - pad, p_max_y - pad, color)
          
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x, p_min_y+pad, p_min_x+pad, p_max_y-pad, color_alpha, color, color, color_alpha) --left side
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_max_x-pad, p_min_y+pad, p_max_x, p_max_y-pad, color, color_alpha, color_alpha, color) --right side
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x+pad, p_min_y, p_max_x-pad, p_min_y+pad, color_alpha, color_alpha, color, color) --top
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x+pad, p_max_y-pad, p_max_x-pad, p_max_y, color, color, color_alpha, color_alpha) --bottom
          -- Rects are made from triangles, and therefore had to be flipped on the coordinates to get the correct corner shape.
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x, p_min_y, p_min_x+pad, p_min_y+pad, color_alpha, color_alpha, color, color_alpha) --upper left corner
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_max_x, p_min_y, p_max_x-pad, p_min_y+pad, color_alpha, color_alpha, color, color_alpha) --upper right corner
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_min_x, p_max_y, p_min_x+pad, p_max_y-pad, color_alpha, color_alpha, color, color_alpha) --lower left corner
          reaper.ImGui_DrawList_AddRectFilledMultiColor(draw_list, p_max_x, p_max_y, p_max_x-pad, p_max_y-pad, color_alpha, color_alpha, color, color_alpha) --lower right
        end
        
        if variant == "circles" then
          reaper.ImGui_DrawList_AddCircleFilled(draw_list, (p_min_x + p_max_x)/2, (p_min_y + p_max_y)/2, 5, color)
          
        end
        
        if variant == "down-cross-lines" then
          reaper.ImGui_DrawList_AddLine(draw_list, p_min_x, p_min_y, p_max_x, p_max_y, color)
        end
        
        if variant == "up-cross-lines" then
          reaper.ImGui_DrawList_AddLine(draw_list, p_max_x, p_min_y, p_min_x, p_max_y, color)
        end
        
        
        if variant == "crossed-lines" then
          reaper.ImGui_DrawList_AddLine(draw_list, p_min_x, p_min_y, p_max_x, p_max_y, color)
          reaper.ImGui_DrawList_AddLine(draw_list, p_max_x, p_min_y, p_min_x, p_max_y, color)
        end
        
        
        if variant == "alternating-lines" then
          switch = FlipBool(switch)
          if not switch then reaper.ImGui_DrawList_AddLine(draw_list, p_min_x, p_min_y, p_max_x, p_max_y, color) end
          if switch then reaper.ImGui_DrawList_AddLine(draw_list, p_max_x, p_min_y, p_min_x, p_max_y, color) end
          
        end
        
        
        end
        
      end
      
    end
    
  end
  


-----------------------------------
--main-----------------------------
-----------------------------------


local _, _, sectionID, cmdID, _, _, _ = reaper.get_action_context()
reaper.SetToggleCommandState(sectionID, cmdID, 1)
reaper.RefreshToolbar2(sectionID, cmdID)

local function DoAtExit()
  reaper.SetToggleCommandState(sectionID, cmdID, 0)
  reaper.RefreshToolbar2(sectionID, cmdID)
end

local set_initial_size = true
local w = 308
local h = 416

local ctx = reaper.ImGui_CreateContext("Twinkling Tiles for ReaImGui using LUA")


local function main()
  reaper.ImGui_SetNextWindowBgAlpha(ctx, 0.0)
  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(), 0x000000FF)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowPadding(), 0, 0)
  reaper.ImGui_PushStyleVar(ctx, reaper.ImGui_StyleVar_WindowBorderSize(), 0)

  local visible, open = reaper.ImGui_Begin(ctx, "Twinkling Tiles for ReaImGui using LUA", reaper.ImGui_WindowFlags_NoTitleBar(), 1)
  reaper.ImGui_PopStyleVar(ctx, 2)
  reaper.ImGui_PopStyleColor(ctx)
  
  if set_initial_size then
    reaper.ImGui_SetWindowSize(ctx, w, h)
    set_initial_size = false
  end
  
  local current_w, current_h = reaper.ImGui_GetWindowSize(ctx)
  local x, y = reaper.ImGui_GetWindowPos(ctx)
  local draw_list = reaper.ImGui_GetWindowDrawList(ctx)
  local desired_tilesize = {30, 30}           -- in px for width and height of tiles
  local tileconfig = SelectTileConfig("neon") -- see existing configs or create your own
  local frame = true                          -- set to false if you do not want any frame around tiles
  local framesize = 10                        -- increase/decrease framesize
  local col_bg = 0xFFFFFFFF--0xFF1178DD                   -- set to what you want
  local col_foreground = 0xFF10F0AF
  local roundness = 10                        -- set to zero if you do not want any rounding
  if not frame then framesize = 0 end
  local variant = "alternating-lines"
  
  if visible then
    -- Add the below function call and set the tileset variable to one of the presets or define your own.

    reaper.ImGui_DrawList_AddRectFilled(draw_list, x, y, x+current_w, y+current_h, 0x000000FF, roundness)
    DrawTwinklingTiles(draw_list, current_w-(framesize*2), current_h-(framesize*2), x+framesize, y+framesize, tileconfig, desired_tilesize, variant) 
    --reaper.ImGui_DrawList_AddRectFilled(draw_list, x, y, x+current_w, y+current_h, col_foreground, roundness)
    --reaper.ImGui_DrawList_AddRectFilled(draw_list, x, y, x+current_w, y+current_h, 0xFFCC00EA, roundness)
    local bg_colors = {0xACCBF1F1,-- 1: light blue
                      0x4188FFEC, -- 2: darker blue
                      0xFFCC00EA, -- 3: yellow
                      0x395144FA, -- 4: Green
                      0x4E0707F7, -- 5: Red
                      0x00008BEF, -- 6: dark blue
                      0x000000F3, -- 7: black
                      0xFF1178AA,  -- 8: 
                      0xFF10F0AF,   -- 9:  PINK
                      0xDFFF00    -- 10: LUGHT BLUE
                      
                      } 
    bg_color = bg_colors[8]
    -------------------------------- TWEAK ABOVE - APPLICATION BELOW --------------------------------------
    
    
    
    reaper.ImGui_End(ctx)
  end
  
  if open then
    reaper.defer(main)
  end
  
end



main()
reaper.atexit(DoAtExit())
