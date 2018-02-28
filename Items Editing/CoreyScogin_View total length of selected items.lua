--[[
 * ReaScript Name: View total length of selected items
 * Description: Displays the total length of the selected items in a message window.
 * Instructions: Select items. Run the script. 
 * Author: CoreyScogin
 * Author URI: https://github.com/CoreyScogin
 * Repository URI: https://github.com/CoreyScogin/ReaScripts
 * File URI: https://github.com/CoreyScogin/ReaScripts/blob/master/Items%20Editing/CoreyScogin_View%20total%20length%20of%20selected%20items.lua
 * Licence: GPL v3
 * Version: 1.0
--]]
 
--[[
 * Changelog:

--]]

-- Functions ----------------------------------------------
function disp_time(time)
  -- borrowed from StackOverflow https://stackoverflow.com/questions/45364628/lua-4-script-to-convert-seconds-elapsed-to-days-hours-minutes-seconds
  local days = math.floor(time/86400)
  local hours = math.floor((time % 86400)/3600)
  local minutes = math.floor((time % 3600)/60)
  local seconds = math.floor((time % 60))
  return string.format("%d:%02d:%02d:%02d",days,hours,minutes,seconds)
end

-- Main ---------------------------------------------------
local selectedItemsCount = reaper.CountSelectedMediaItems(0)

if selectedItemsCount > 0 then

  -- init variables
  local length = 0.0

  -- Process each selected item
  for i = 0, selectedItemsCount - 1  do   
    length = length + reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0,i), "D_LENGTH")
  end

  -- Show message
  local msg = "Selected item(s) total length: \n" .. disp_time(length) .. "\n\n(Days:Hours:Minutes:Seconds)"
  reaper.ShowMessageBox(msg, "Selected Item(s) Length", 0)  -- 0 = OK prompt

end -- if selectedItemsCount > 0
