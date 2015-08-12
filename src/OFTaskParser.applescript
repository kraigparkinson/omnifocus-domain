(*! @abstract <em>[text]</em> OFTaskParser's name. *)
property name : "OFTaskParser"
(*! @abstract <em>[text]</em> OFTaskParser's version. *)
property version : "1.0.0"
(*! @abstract <em>[text]</em> OFTaskParser's id. *)
property id : "com.kraigparkinson.OFTaskParser"

-- script OFTaskParser
property OFDateParser : script "com.kraigparkinson/OFDateParser"
property textutil : script "com.kraigparkinson/ASText"

property PROJECT_DELIM : " ::"
property CONTEXT_DELIM : " @"
property DATE_DELIM : " #"
property ESTIMATE_DELIM : " $"

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
		
		set contextNameElements to textutil's getTextElements(contextName, ":")
		
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
	local dueDateSegment
	local dueDate
	set taskNameElements to textutil's getTextElements(taskName, DATE_DELIM)
	
	if (count of taskNameElements) is 2 then
		--Assuming it comes after a task name being present (being item 1)
		set dueDateSegment to item 2 of taskNameElements
		
		--Might have estimate mixed in with that
		set dueDateElements to textutil's getTextElements(dueDateSegment, {DATE_DELIM, ESTIMATE_DELIM})
		
		set dueDateSegment to item 1 of dueDateElements
	else if (count of taskNameElements) is 3 then
		set dueDateSegment to item 3 of taskNameElements
		
		--Might have estimate mixed in with that
		set dueDateElements to textutil's getTextElements(dueDateSegment, {DATE_DELIM, ESTIMATE_DELIM})
		
		set dueDateSegment to item 1 of dueDateElements
	else
		set dueDateSegment to missing value
	end if
	
	tell OFDateParser
		set dueDate to parseDueDate(dueDateSegment)
	end tell
	
	return dueDate
end parseDueDateFromTaskName

on parseDeferDateFromTaskName(taskName)
	local deferDate
	set taskNameElements to textutil's getTextElements(taskName, DATE_DELIM)
	
	if (count of taskNameElements) is equal to 3 then
		set deferDateSegment to item 2 of taskNameElements
		tell OFDateParser
			set deferDate to parseDeferDate(deferDateSegment)
		end tell
	else
		set deferDate to missing value
	end if
	
	return deferDate
end parseDeferDateFromTaskName

on parseTaskNameFromTaskName(unparsedTaskName)
	return item 1 of textutil's getTextElements(unparsedTaskName, {PROJECT_DELIM, CONTEXT_DELIM, DATE_DELIM, ESTIMATE_DELIM})
end parseTaskNameFromTaskName

on parseContextNameFromTaskName(taskName)
	local contextName
	set taskNameElements to textutil's getTextElements(taskName, CONTEXT_DELIM)
	
	if (count of taskNameElements) is greater than 1 then
		set contextNameSegment to item 2 of taskNameElements
		
		--Might have other task elements coming after that
		set contextNameElements to textutil's getTextElements(contextNameSegment, {DATE_DELIM, ESTIMATE_DELIM})
		set contextName to item 1 of contextNameElements
	else
		set contextName to ""
	end if
	
	return contextName
end parseContextNameFromTaskName

on parseProjectNameFromTaskName(taskName)
	local projectName
	set taskNameElements to textutil's getTextElements(taskName, PROJECT_DELIM)
	
	if (count of taskNameElements) is greater than 1 then
		set projectNameSegment to item 2 of taskNameElements
		
		--Might have other task elements coming after that
		set projectNameElements to textutil's getTextElements(projectNameSegment, {CONTEXT_DELIM, DATE_DELIM, ESTIMATE_DELIM})
		set projectName to item 1 of projectNameElements
	else
		set projectName to ""
	end if
	
	return projectName
end parseProjectNameFromTaskName

on parseEstimateFromTaskName(taskName)
	local theEstimate
	local estimateInMinutes
	
	set taskNameElements to textutil's getTextElements(taskName, ESTIMATE_DELIM)
	
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