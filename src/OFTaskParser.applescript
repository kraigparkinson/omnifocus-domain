(*! @abstract <em>[text]</em> OFTaskParser's name. *)
property name : "OFTaskParser"
(*! @abstract <em>[text]</em> OFTaskParser's version. *)
property version : "1.0.0"
(*! @abstract <em>[text]</em> OFTaskParser's id. *)
property id : "com.kraigparkinson.OFTaskParser"

-- script OFTaskParser
on reparseTaskPropertiesFromTaskName(selectedTask)
	local unparsedTaskName
	
	tell application "OmniFocus"
		set unparsedTaskName to name of selectedTask
		
		tell front document
			set name of selectedTask to my parseTaskNameFromTaskName(unparsedTaskName)
			
			set projectName to my parseProjectNameFromTaskName(unparsedTaskName)
			set contextName to my parseContextNameFromTaskName(unparsedTaskName)
			set theDueDate to my parseDueDateFromTaskName(unparsedTaskName)
			set theDeferDate to my parseDeferDateFromTaskName(unparsedTaskName)
			set theEstimate to my parseEstimateFromTaskName(unparsedTaskName)
			
			if projectName is not equal to "" and (exists (first flattened project where its name = projectName)) and (containing project of selectedTask is missing value) then
				set theProject to first flattened project where its name = projectName
				move selectedTask to end of tasks of theProject
			end if
			
			--Find matching context
			--			if contextName is not equal to "" and (exists (first flattened context where its name = contextName)) and (context of selectedTask is missing value) then
			if contextName is not equal to "" and (context of selectedTask is missing value) then
				local theContext
				
				set theContext to my findContextFromName(contextName)
				
				set context of selectedTask to theContext
			end if
			
			if due date of selectedTask is missing value and theDueDate is not null then
				set the (due date of selectedTask) to theDueDate
			end if
			
			if defer date of selectedTask is missing value and theDeferDate is not null then
				set the (defer date of selectedTask) to theDeferDate
			end if
			
			if estimated minutes of selectedTask is missing value and theEstimate is not missing value then
				set the estimated minutes of selectedTask to theEstimate
			end if
			
		end tell
		
	end tell
end reparseTaskPropertiesFromTaskName

on findContextFromName(contextName)
	local theContext
	
	tell front document of application "OmniFocus"
		
		set contextNameElements to my getTextElements(contextName, ":")
		
		if ((count of contextNameElements) > 1) then
			
			set contextLevel to 1
			set contextParentName to item 1 in contextNameElements
			
			if (exists (first flattened context where its name = contextParentName)) then
				set parentContext to first flattened context where its name = contextParentName
				
				repeat while contextLevel < (count of contextNameElements)
					set contextLevel to contextLevel + 1
					set childContextName to (item (contextLevel) in contextNameElements)
					
					if (exists (first flattened context of parentContext where its name = childContextName)) then
						set theContext to first flattened context of parentContext where its name = childContextName
						set parentContext to theContext
					end if
				end repeat
			else
				set theContext to missing value
			end if
		else
			
			--			set theContext to first flattened context where its name = first item of contextNameElements
			if (exists (first flattened context where its name = contextName)) then
				set theContext to first flattened context where its name = contextName
			else
				set theContext to missing value
			end if
			
			
		end if
		
	end tell
	
	return theContext
end findContextFromName

to parseDueDateFromTaskName(taskName)
	local dueDate
	set taskNameElements to getTextElements(taskName, " #")
	
	if (count of taskNameElements) is 2 then
		set dueDateSegment to item 2 of taskNameElements
		set dueDate to date dueDateSegment
		--Might have other task elements coming after that
		--			set dueDateElements to getTextElements(dueDateSegment, {" #", " $"})
		
		--			set dueDate to date item 1 of dueDateElements
	else if (count of taskNameElements) is 3 then
		set dueDateSegment to item 3 of taskNameElements
		set dueDate to date dueDateSegment
	else
		set dueDate to missing value
	end if
	
	return dueDate
end parseDueDateFromTaskName

on parseDeferDateFromTaskName(taskName)
	local deferDate
	set taskNameElements to getTextElements(taskName, " #")
	
	if (count of taskNameElements) is equal to 3 then
		set deferDateSegment to item 2 of taskNameElements
		set deferDate to date deferDateSegment
	else
		set deferDate to missing value
	end if
	
	return deferDate
end parseDeferDateFromTaskName

on parseTaskNameFromTaskName(unparsedTaskName)
	return item 1 of getTextElements(unparsedTaskName, {" ::", " @", " #", " $"})
end parseTaskNameFromTaskName

on getTextElements(theText, delimeter)
	local textElements
	
	set prevTIDs to text item delimiters of AppleScript
	try
		set text item delimiters of AppleScript to delimeter
		set textElements to every text item of theText
	on error
		set text item delimiters of AppleScript to prevTIDs
	end try
	
	set text item delimiters of AppleScript to prevTIDs
	return textElements
end getTextElements

on parseContextNameFromTaskName(taskName)
	local contextName
	set taskNameElements to getTextElements(taskName, " @")
	
	if (count of taskNameElements) is greater than 1 then
		set contextNameSegment to item 2 of taskNameElements
		
		--Might have other task elements coming after that
		set contextNameElements to getTextElements(contextNameSegment, {" #", " $"})
		set contextName to item 1 of contextNameElements
	else
		set contextName to ""
	end if
	
	return contextName
end parseContextNameFromTaskName

on parseProjectNameFromTaskName(taskName)
	local projectName
	set taskNameElements to getTextElements(taskName, " ::")
	
	if (count of taskNameElements) is greater than 1 then
		set projectNameSegment to item 2 of taskNameElements
		
		--Might have other task elements coming after that
		set projectNameElements to getTextElements(projectNameSegment, {" @", " #", " $"})
		set projectName to item 1 of projectNameElements
	else
		set projectName to ""
	end if
	
	return projectName
end parseProjectNameFromTaskName

on parseEstimateFromTaskName(taskName)
	local theEstimate
	local estimateInMinutes
	
	set taskNameElements to getTextElements(taskName, " $")
	
	if (count of taskNameElements) is greater than 1 then
		set theEstimate to item 2 of taskNameElements
		local estimateInMinutes
		
		if length of theEstimate is equal to 1 then
			set estimateInMinutes to theEstimate as integer
		else if length of theEstimate is greater than 1 then
			set estimateText to text 1 thru ((length of theEstimate) - 1) of theEstimate
			set estimateInMinutes to estimateText as integer
			
			if (theEstimate contains "h") then
				set estimateInMinutes to estimateInMinutes * 60
			else if (theEstimate contains "d") then
				set estimateInMinutes to estimateInMinutes * 60 * 24
			else if (theEstimate contains "w") then
				set estimateInMinutes to estimateInMinutes * 60 * 24 * 7
			end if
			
		end if
	else
		set estimateInMinutes to missing value
	end if
	
	return estimateInMinutes
end parseEstimateFromTaskName

-- end script