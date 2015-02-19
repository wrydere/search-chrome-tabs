-- This is based on John Day's really great"Generating Feedback in Alfred 2"
-- example: http://www.johneday.com/617/generate-feedback-in-alfred-2-workflows
-- Also: there is a TON of room for improvement, so please feel free to make
-- suggestions.

----------------------------------------
-- Here we get info from Chrome about its windows and tabs
----------------------------------------
on run argv
  try
    -- get command line arguments and convert them to text
    set query to argv as text
    
    -- These are a bunch of lists for storing data,
    -- we don't use all of them, this is something to clean up.
    
    set tablist to {}
    set itemList to {}
    set tabTitles to {}
    set tabIds to {}
    set tabIndexes to {}
    set windowIndexes to {}
    set windowIds to {}
    set tabUrls to {}
    set windowArrayPositions to {} 
    set windowTitles to {} 
    
    tell application "Google Chrome"
      -- create a temporary list of every window in Chrome
      set tempWinlist to every window

      -- for every window in Chrome, do the following block
      repeat with windowCount from 1 to count of tempWinList

        -- create a temp list of all tabs for this window
        set tempTablist to every tab of (item windowCount of tempWinList)
        set win to (item windowCount of tempWinList)

        repeat with x from 1 to count of tempTablist
          
          set thisTabTitle to (title of item x of tempTablist)
          set thisTabUrl to (URL of item x of tempTablist as text)
          
          -- Build our lists only with matches to a title or URL
          -- These redundant loops should be put into a function,
          -- but I'm still learning AppleScript

          ignoring case
            if query is in thisTabTitle then
              set end of tabTitles to thisTabTitle
              set end of tabIndexes to x
              set end of tabUrls to thisTabUrl
              -- windowArrayPositions is the number of the item in 'windows', not the visibility index
              set end of windowArrayPositions to windowCount

              -- These other lists were different ways of getting data that
              -- didn't work, but I'm leaving them commented for reference

              -- set end of tabIds to (id of item x of tempTablist)
              -- set end of windowTitles to (title of win)
              -- set end of windowIds to (id of win)
              -- set end of windowIndexes to index of win
            -- Clearly there's a way to not have to repeat this block, but
            -- AppleScript's function / control flow is new to me.
            else if query is in thisTabUrl then
              set end of tabTitles to thisTabTitle
              set end of tabIndexes to x
              set end of tabUrls to thisTabUrl
              set end of windowArrayPositions to windowCount
            end if
          end ignoring 
          
        end repeat
      end repeat
    end tell
    
    -- Loop through the tabTitle list (of matches only now), and send them to Alfred as XML
    -- Later we can act on those in a separate script that opens the proper tab in Chrome
    
    repeat with x from 1 to count of tabTitles
      set chromeArgs to (item x of tabIndexes as text) & "." & (item x of windowArrayPositions as text)
      set end of itemList to xmlItem({uid:"", arg:chromeArgs, title:(item x of tabTitles as string), subtitle:(item x of tabUrls as string)})
    end repeat
    
    -- Wrap the elements of the list with a declaration and produce feedback
    return giveFeedback(itemList)
    
  on error errMsg number errNum
    tell application "SystemUIServer"
      activate
      display alert errMsg & return & return & "Error number" & errNum buttons "Cancel" as warning
    end tell
  end try
end run

-- Everything below this line is untouched from John Day's original filter example.
----------------------------------------
-- HANDLERS --
----------------------------------------

on xmlItem(itemR)
  set initial to {uid:"", arg:"", itemTypeAttribute:"file", valid:"yes", autocomplete:"", title:"", subtitle:"", icon:"", iconAttribute:""}
  set itemR to itemR & initial
  set myItem to tab & "<item uid=\"" & itemR's uid & "\" arg=\"" & itemR's arg & "\" type=\"" & itemR's itemTypeAttribute & "\" valid=\"" & itemR's valid & "\""
  if itemR's autocomplete ­ "" then set myItem to myItem & " autocomplete=\"" & itemR's autocomplete & "\""
  set myItem to myItem & ">" & return
  set myItem to myItem & tab & tab & "<title>" & itemR's title & "</title>" & return & tab & tab & "<subtitle>" & itemR's subtitle & "</subtitle>" & return
  if itemR's iconAttribute ­ "" then set itemR's iconAttribute to " type=\"" & itemR's iconAttribute & "\""
  if itemR's icon ­ "" then set myItem to myItem & tab & tab & "<icon" & itemR's iconAttribute & ">" & itemR's icon & "</icon>" & return
  set myItem to myItem & tab & "</item>" & return
  return myItem as text
end xmlItem


on clean(input, trimming)
  -- trimming boolean: true to remove leading and trailing whitespace
  if input's class ­ text then return input
  set myText to trim(input, trimming)
  set findChars to {"&", "\"", "'", "<", ">"}
  set replaceChars to {"&amp;", "&quot;", "&apos;", "&lt;", "&gt;"}
  repeat with i from 1 to 5
    if (item i of findChars) is in myText then
      set {TID, text item delimiters} to {text item delimiters, (item i of findChars)}
      set myText to text items of myText
      set AppleScript's text item delimiters to (item i of replaceChars)
      set myText to myText as text
      set text item delimiters to TID
    end if
  end repeat
  return myText
end clean


on trim(txt, trimming)
  if trimming then
    if (txt is space) then return ""
    repeat until txt does not start with space
      set txt to text 2 thru -1 of txt
    end repeat
    repeat until txt does not end with space
      set txt to text 1 thru -2 of txt
    end repeat
  end if
  return txt
end trim


on giveFeedback(xmlList)
  set xmlHead to "<?xml version=\"1.0\"?>" & return & "<items>" & return
  set xmlTail to "</items>"
  return xmlHead & (xmlList as text) & xmlTail
end giveFeedback


--Generate unique uuid
on uuid()
  (do shell script "perl -e 'use Time::HiRes qw(time); print time'")
end uuid
