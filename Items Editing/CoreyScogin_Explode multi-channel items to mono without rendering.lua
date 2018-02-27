--[[
 * ReaScript Name: Explode multi-channel items to mono without rendering
 * Description: Explodes multi-channel audio items to mono items without rendering. 
 * Instructions: Select an audio item. Run the script. 
 * Author: CoreyScogin
 * Author URI: https://github.com/CoreyScogin
 * Repository URI: https://github.com/CoreyScogin/ReaScripts
 * File URI: https://github.com/CoreyScogin/ReaScripts/blob/master/Items%20Editing/CoreyScogin_Explode%20multi-channel%20items%20to%20mono%20without%20rendering.lua
 * Licence: GPL v3
 * Version: 1.0
--]]
 
--[[
 * Changelog:

--]]

--[[
  * Known Bugs:
  + If the next track below the item is a child then exploded items are created as children instead of siblings.
  + Throws an exception if item is an empty item.
]]

-- Functions -----------------------------------------------
function InsertTracks(trackCount)
  for insertTrackIndex = 0, trackCount - 1 do
    reaper.Main_OnCommand(40001, 0) -- Insert new track
  end
end

-- Main ---------------------------------------------------
selectedItemsCount = reaper.CountSelectedMediaItems(0)

if selectedItemsCount > 0 then
  reaper.PreventUIRefresh(1)
  reaper.Undo_BeginBlock()
  
  -- Save cursor
  local origCursorPos = reaper.GetCursorPosition()
  
  -- Main Function    
  local groupId = 5000      -- base for grouping resulting items

  -- init arrays
  local selectedItems = {} 
  local origItem = {}
  local origTake = {}
  local origSource = {}
  local origTrack = {}
  local channelCount = {}
  local maxChannelCount = 0
  
  -- Get an array of selected items for reference later
  for i = 0, selectedItemsCount - 1  do
    selectedItems[i] = reaper.GetSelectedMediaItem(0,i)
  end 
  
  -- Get arrays of media items, tracks, etc
  for i = 0, selectedItemsCount - 1  do  
    reaper.SetMediaItemSelected(selectedItems[i], 0)                -- Deselect all items
    origItem[i] = selectedItems[i]                                  -- Store ref to original item
    origTake[i] = reaper.GetActiveTake(origItem[i])                 -- Store ref to original take
    origSource[i] = reaper.GetMediaItemTake_Source(origTake[i])     -- Store ref to original source
    origTrack[i] = reaper.GetMediaItem_Track(origItem[i])           -- Store ref to original track
    channelCount[i] = reaper.GetMediaSourceNumChannels(origSource[i])-- Store channel count
  end 
  
  -- Process each selected item
  local lastOrigTrackIndex = -100 
  for i = 0, selectedItemsCount - 1  do   
    reaper.Main_OnCommand(40289, 0) -- Unselect all items 
    reaper.SetMediaItemSelected(origItem[i], 1) -- Select original item
    reaper.SetMediaItemTakeInfo_Value(origTake[i], "I_CHANMODE", 3) -- Set original to mono so new tracks don't contain N channels
    reaper.Main_OnCommand(40698, 0) -- Copy the item
    reaper.SetMediaItemInfo_Value(origItem[i], "B_MUTE", 1) -- Mute original
    reaper.SetMediaItemTakeInfo_Value(origTake[i], "I_CHANMODE", 0) -- Set original back to normal
    reaper.SetOnlyTrackSelected(origTrack[i]) -- Select track containing media
    reaper.Main_OnCommand(40914, 0) -- Set selected track as last touched
        
    -- Determine whether or not to insert new tracks for items
    local thisOrigTrackIndex = reaper.CSurf_TrackToID(origTrack[i], false)
    local insertTrack = (lastOrigTrackIndex ~= thisOrigTrackIndex) 
    
    -- Add items for each channel
    for c = 0, channelCount[i] - 1 do    
      reaper.Main_OnCommand(41173, 0) -- Move cursor to start of item
      if insertTrack then -- Don't insert new tracks for next item if items on the same track originally. 
        InsertTracks(1) 
      else 
        reaper.Main_OnCommand(40285, 0) -- Go to next track
      end      
      reaper.Main_OnCommand(40058, 0) -- Paste item
      local newItem = reaper.GetSelectedMediaItem(0, 0)
      local newTake = reaper.GetActiveTake(newItem)
      reaper.SetMediaItemTakeInfo_Value(newTake, "I_CHANMODE", c+3) -- Set the channel in the media item to use
      reaper.SetMediaItemInfo_Value(newItem, "I_GROUPID", groupId + i) -- Group all exploded items together
    end -- for channelCount    
    
    reaper.SetMediaItemSelected(origItem[i], 0)    
    lastOrigTrackIndex = thisOrigTrackIndex
    
  end -- for selectedItemsCount
  
  -- Restore cursor
  reaper.Main_OnCommand(40042, 0) -- Go to project start
  reaper.MoveEditCursor(origCursorPos, false)
  
  reaper.Undo_EndBlock("Explode multi-channel items without rendering", 0) 
  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)
end -- if selectedItemsCount > 0

