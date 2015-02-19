on run argv
  try

    -- Take the input {query} (by way of argument variable) and turn it into a local variable
    set query to argv as text

    -- Since we need multiple parameters out of query, we packaged it up when filtering,
    -- now we chop it back up to get tab indexes and window ids

    set AppleScript's text item delimiters to {"."}
    set chromeArgs to every text item of query
    set tabIndex to item 1 of chromeArgs
    set windowId to item 2 of chromeArgs

    tell application "Google Chrome"
      activate application "Google Chrome"
      set win to window (windowId as integer)
      set (active tab index of win) to (tabIndex as integer)
    end tell
  end try
end run
