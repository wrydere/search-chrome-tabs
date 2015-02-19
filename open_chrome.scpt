on run argv
  try
    set windowName to ""

    -- Take the input {query} (by way of argument variable) and turn it into a local variable
    set query to argv as text

    -- This is a quick way to debug our query
    -- display dialog (query)

    -- Since we need multiple parameters out of query, we packaged it up when filtering,
    -- now we chop it back up.

    set AppleScript's text item delimiters to {"."}
    set chromeArgs to every text item of query

    set tabIndex to item 1 of chromeArgs
    set windowArrayPosition to item 2 of chromeArgs

    tell application "Google Chrome"
      set theWindow to window (windowArrayPosition as integer)
      set windowName to ((title of theWindow) as text)
    end tell

    tell application "Google Chrome"

      -- This seems to be the only way to get the right window to rise to the front:

      set index of window 1 where title contains (windowName) to 1
      do shell script "open -a Google\\ Chrome"

      -- Now that the window is in focus, we can set the tab index to our arg variable

      set (active tab index of window 1) to (tabIndex as integer)
      
    end tell

  end try
end run
