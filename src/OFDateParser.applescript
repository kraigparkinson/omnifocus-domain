(*! @abstract <em>[text]</em> OFDateParser's name. *)
property name : "OFDateParser"
(*! @abstract <em>[text]</em> OFDateParser's version. *)
property version : "1.0.0"
(*! @abstract <em>[text]</em> OFDateParser's id. *)
property id : "com.kraigparkinson.OFDateParser"

property textutil : script "com.kraigparkinson/ASText"

property DEFAULT_DUE_TIME : "5:00 PM"
property DEFAULT_DEFER_TIME : "12:00 AM"

on hasTime(dateText)
	local dateTextElements
	
	--tell utils
	set dateTextElements to textutil's getTextElements(dateText, space)
	--end tell
	
	local hasTime
	if ((count of dateTextElements) > 1) then
		set hasTime to true
	else
		set hasTime to false
	end if
	
	return hasTime
end hasTime

on parseDueDate(dateText)
	set dueDate to parseDate(dateText)
	if (dueDate is not missing value and not hasTime(dateText)) then
		set dueDate to date DEFAULT_DUE_TIME in dueDate
	end if
	return dueDate
end parseDueDate

on parseDeferDate(dateText)
	set deferDate to parseDate(dateText)
	if (deferDate is not missing value and not hasTime(dateText)) then
		set deferDate to date DEFAULT_DEFER_TIME in deferDate
	end if
	return deferDate
	
end parseDeferDate

on parseDate(dateText)
	local theDate
	
	ignoring case
		if (dateText is equal to "today") then
			set theDate to current date
		else if (dateText is equal to "tomorrow" or dateText is equal to "tom") then
			set theDate to tomorrow()
		else if dateText is missing value then
			set theDate to missing value
		else
			set theDate to date dateText
		end if
	end ignoring
	
	return theDate
end parseDate

on tomorrow()
	set theDate to current date
	set day of theDate to (day of theDate) + 1
	return theDate
end tomorrow

-- end script
