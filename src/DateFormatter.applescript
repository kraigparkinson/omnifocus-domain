property DATE_DELIM : "#"

on replace_chars(this_text, search_string, replacement_string)
	set prevTIDs to text item delimiters of AppleScript
	
	try
		set AppleScript's text item delimiters to the search_string
		set the item_list to every text item of this_text
		
		set AppleScript's text item delimiters to the replacement_string
		set this_text to the item_list as string
		set AppleScript's text item delimiters to prevTIDs
	on error
		set AppleScript's text item delimiters to prevTIDs
	end try
	
	return this_text
end replace_chars

-- From Nigel Garvey's CSV-to-list converter
-- http://macscripter.net/viewtopic.php?pid=125444#p125444
on trim(txt, trimming)
	if (trimming) then
		repeat with i from 1 to (count txt) - 1
			if (txt begins with space) then
				set txt to text 2 thru -1 of txt
			else
				exit repeat
			end if
		end repeat
		repeat with i from 1 to (count txt) - 1
			if (txt ends with space) then
				set txt to text 1 thru -2 of txt
			else
				exit repeat
			end if
		end repeat
		if (txt is space) then set txt to ""
	end if
	
	return txt
end trim

on stripWhitespace(textValue)
	return textValue
end stripWhitespace



(*
	OF doesn't like the YYYY-MM-DDTHH:MM:SS-ZONE format.  
	It doens't know what to do with seconds or the time zone, and doens't know how to parse the T in the middle. 
	Instead it needs you to say 'YYYY-MM-DD at HH:MM' 
	*)
on reformatDateTimeStampToOF(supposedDateTimeStamp)
	set reformattedDateTimeStamp to supposedDateTimeStamp
	
	--Is it the right length?
	if length of supposedDateTimeStamp is equal to 24 then
		
		-- Check that the format of the string matches what I'm expecting
		set prevTIDs to text item delimiters of AppleScript
		try
			set text item delimiters of AppleScript to "T"
			
			if (length of first text item of supposedDateTimeStamp is equal to 10) then --length of date stamp
				set supposedDateTimeStampElements to every text item of supposedDateTimeStamp
				
				if (count of supposedDateTimeStampElements) is equal to 2 then
					-- This just shows us there's a 'T' character, need to dive deeper
					
					set supposedDateStamp to first text item of supposedDateTimeStampElements
					set supposedTimeStamp to second text item of supposedDateTimeStampElements
					
					--Check if first element looks like a date stamp
					
					set text item delimiters of AppleScript to "-"
					set supposedDateStampElements to every text item of supposedDateStamp
					
					if (count of supposedDateStampElements) is equal to 3 then
						set theYear to text item 1 of supposedDateStampElements
						set theMonth to text item 2 of supposedDateStampElements
						set theDay to text item 3 of supposedDateStampElements
						
						if length of theYear is equal to 4 and length of theMonth is equal to 2 and length of theDay is equal to 2 then
							--We might have a date! Should do more validation here...
							--Now check the time...							
							set text item delimiters of AppleScript to ":"
							set supposedTimeStampElements to every text item of supposedTimeStamp
							
							if (count of supposedTimeStampElements) is equal to 3 then
								--We might have a date time stamp!
								-- Let's go do stuff to it.
								
								
								set reformattedDateTimeStamp to replace_chars(supposedDateTimeStamp, "T", " at ")
								set reformattedDateTimeStamp to trimTimeZone(reformattedDateTimeStamp)
								set reformattedDateTimeStamp to trimSeconds(reformattedDateTimeStamp)
								
								
							end if
						end if
					end if
				end if
			end if
			set AppleScript's text item delimiters to prevTIDs
		on error
			set AppleScript's text item delimiters to prevTIDs
		end try
	end if
	
	return reformattedDateTimeStamp
	
	
end reformatDateTimeStampToOF


on tidyTaskName(unparsedTaskName)
	set parsedTaskName to "no processing whatsoever"
	
	set prevTIDs to text item delimiters of AppleScript
	try
		set text item delimiters of AppleScript to DATE_DELIM
		
		-- Find dates
		set taskNameElements to every text item of unparsedTaskName
		set AppleScript's text item delimiters to prevTIDs
		
		if (count of taskNameElements) is 1 then (* Likely no date found *)
			set parsedTaskName to item 1 of taskNameElements
		else if (count of taskNameElements) is 2 then (* Treat the second item like a due date *)
			set taskName to item 1 of taskNameElements
			
			set dueDateAndPossiblyMore to item 2 of taskNameElements
			set dueDateTimeStamp to (characters 1 thru 24 of dueDateAndPossiblyMore) as string
			set remainder to ""
			
			if length of dueDateAndPossiblyMore is greater than 24 then
				set remainder to (characters 25 thru -1 of dueDateAndPossiblyMore) as string
			end if
			
			set parsedTaskName to taskName & DATE_DELIM & reformatDateTimeStampToOF(dueDateTimeStamp) & remainder
			
		else if (count of taskNameElements) is 3 then
			set taskName to item 1 of taskNameElements
			set deferDateTimeStamp to (characters 1 thru 24 of item 2 of taskNameElements) as string
			
			set dueDateAndPossiblyMore to item 3 of taskNameElements
			set dueDateTimeStamp to (characters 1 thru 24 of dueDateAndPossiblyMore) as string
			
			set remainder to ""
			
			if length of dueDateAndPossiblyMore is greater than 24 then
				set remainder to (characters 25 thru -1 of dueDateAndPossiblyMore) as string
			end if
			
			set parsedTaskName to taskName & DATE_DELIM & reformatDateTimeStampToOF(deferDateTimeStamp) & " " & DATE_DELIM & reformatDateTimeStampToOF(dueDateTimeStamp) & remainder
		else if (count of taskNameElements) is 4 then
			
		else if (count of taskNameElements) is 5 then
			
		else
			
		end if
		
		
		
	on error msg number num
		set AppleScript's text item delimiters to prevTIDs
		error msg number num
		
	end try
	
	return parsedTaskName
end tidyTaskName

on trimTimeZone(dateTimeString)
	return replace_chars(dateTimeString, "-0600", "")
end trimTimeZone

on trimSeconds(dateTimeString)
	--if dateTimeString is not equal to "" then
	set prevTIDs to text item delimiters of AppleScript
	try
		set text item delimiters of AppleScript to ":"
		
		set theDateAndHour to text item 1 of dateTimeString
		set theMinutes to text item 2 of dateTimeString
		
		--reconstruct the date 
		set dateTimeString to theDateAndHour & ":" & theMinutes
		
		set AppleScript's text item delimiters to prevTIDs
	on error
		set AppleScript's text item delimiters to prevTIDs
	end try
	--end if
	return dateTimeString
end trimSeconds
