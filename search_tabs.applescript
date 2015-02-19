-- This is all a direct rip off of John Day's "Generating Feedback in Alfred 2"
-- example: http://www.johneday.com/617/generate-feedback-in-alfred-2-workflows

----------------------------------------
-- Here we get info from Chrome about its windows and tabs
----------------------------------------
on run argv
  try
    --coerce the argv list to text
    set query to argv as text
    
    set tablist to {}
    set itemList to {}
    set tabTitles to {}
    set tabIds to {}
    set tabIndexes to {}
    set windowIds to {}
    set tabUrls to {}
    
    
    tell application "Google Chrome"
      set tempWinlist to every window
      repeat with win in every window
        set tempTablist to every tab of win
        repeat with x from 1 to count of tempTablist
          
          set thisTabTitle to (title of item x of tempTablist)
          set thisTabUrl to (URL of item x of tempTablist as text)
          
          -- Build our lists only with matches to a title or URL
          -- These redundant loops should be put into a function,
          -- but I'm still learning AppleScript

          if query is in thisTabTitle then
            set end of tabTitles to thisTabTitle
            set end of tabIds to (id of item x of tempTablist)
            set end of tabIndexes to x
            set end of windowIds to id of win
            set end of tabUrls to thisTabUrl
          else if query is in thisTabUrl then
            set end of tabTitles to thisTabTitle
            set end of tabIds to (id of item x of tempTablist)
            set end of tabIndexes to x
            set end of windowIds to id of win
            set end of tabUrls to thisTabUrl
          end if
          
        end repeat
      end repeat
    end tell
    
    -- Loop through the tabTitle list (of matches only now), and send them to Alfred as XML
    -- Later we can act on those in a separate script that opens the proper tab in Chrome
    
    repeat with x from 1 to count of tabTitles
      set chromeArgs to (item x of tabIndexes as text) & "." & (item x of windowIds as text)
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
