(*! @abstract <em>[text]</em> OmniFocusTransportTextParsingService's name. *)
property name : "OmniFocusTransportTextParsingService"
(*! @abstract <em>[text]</em> OmniFocusTransportTextParsingService's version. *)
property version : "1.0.0"
(*! @abstract <em>[text]</em> OmniFocusTransportTextParsingService's id. *)
property id : "com.kraigparkinson.OmniFocusTransportTextParsingService"

property textutil : script "com.kraigparkinson/ASText"
property dateutil : script "com.kraigparkinson/ASDate"
property ddd : script "com.kraigparkinson/ASDomainDrivenDesign"
property domain : script "com.kraigparkinson/OmniFocusDomain"
property rules : script "com.kraigparkinson/OmniFocus Rules Engine"

--property OFDateParser : script "com.kraigparkinson/OFDateParser"

property FLAG_DELIM : space & "!"
property PROJECT_DELIM : space & "::"
property CONTEXT_DELIM : space & "@"
property DATE_DELIM : space & "#"
property ESTIMATE_DELIM : space & "$"
property NOTE_DELIM : space & "//"

script ContainsTaskNameSpecification
	property parent : ddd's AbstractSpecification
	
	on isSatisfiedBy(obj)
		return (obj is not missing value) and (obj is not "")
	end isSatisfiedBy
end script

script ContainsUnparsedTaskNameSpecification
	property parent : ddd's AbstractSpecification
	
	on isSatisfiedBy(obj)
		return (obj begins with "--")
	end isSatisfiedBy
end script

script ContainsFlagSpecification
	property parent : ddd's specification
	
	on isSatisfiedBy(obj)
		set theTransportText to obj as text
		set isFlagged to (count of textutil's getTextElements(theTransportText, FLAG_DELIM)) is equal to 2
		return isFlagged
	end isSatisfiedBy
end script

script ContainsProjectNameSpecification
	property parent : ddd's specification
	
	on isSatisfiedBy(obj)
		set theTransportText to obj as text
		return hasAProjectDelimeter(theTransportText)
	end isSatisfiedBy
	
	on hasAProjectDelimeter(transportText)
		return (count of textutil's getTextElements(transportText, PROJECT_DELIM)) is equal to 2
	end hasAProjectDelimeter
end script

script ContainsValidProjectInTransportTextSpecification
	property parent : ContainsProjectNameSpecification
	
	on isSatisfiedBy(obj)
		if (continue isSatisfiedBy(obj)) then
			set theTransportText to obj as text
			
			if (isALegitimateProject(theTransportText)) then
				return true
			else
				return false
			end if
		else
			return false
		end if
	end isSatisfiedBy
	
	on isALegitimateProject(transportText)
		set transportTextElements to textutil's getTextElements(transportText, PROJECT_DELIM)
		
		set projectNameSegment to item 2 of transportTextElements
		
		--Might have other task elements coming after that
		set projectNameElements to textutil's getTextElements(projectNameSegment, {CONTEXT_DELIM, DATE_DELIM, ESTIMATE_DELIM, NOTE_DELIM})
		set projectName to item 1 of projectNameElements
		
		return (domain's ProjectRepository's findByName(projectName) is not missing value)
	end isALegitimateProject
end script

script ContainsContextNameSpecification
	property parent : ddd's specification
	
	on isSatisfiedBy(obj)
		set theTransportText to obj as text
		return (count of textutil's getTextElements(theTransportText, CONTEXT_DELIM)) is equal to 2
	end isSatisfiedBy
end script

script ContainsValidContextInTransportTextSpecification
	property parent : ContainsContextNameSpecification
	
	on isSatisfiedBy(obj)
		if (continue isSatisfiedBy(obj)) then
			set theTransportText to obj as text
			
			if (isALegitimateContext(theTransportText)) then
				return true
			else
				return false
			end if
		else
			return false
		end if
	end isSatisfiedBy
	
	on isALegitimateContext(transportText)
		set transportTextElements to textutil's getTextElements(transportText, CONTEXT_DELIM)
		
		set contextNameSegment to item 2 of transportTextElements
		
		--Might have other task elements coming after that
		set contextNameElements to textutil's getTextElements(contextNameSegment, {DATE_DELIM, ESTIMATE_DELIM, NOTE_DELIM})
		set contextName to item 1 of contextNameElements
		
		return (domain's ContextRepository's findByName(contextName) is not missing value)
	end isALegitimateContext
end script

script ContainsDeferDateTextSpecification
	property parent : ddd's specification
	
	on isSatisfiedBy(obj)
		set theTransportText to obj as text
		return (count of textutil's getTextElements(theTransportText, DATE_DELIM)) is equal to 3
	end isSatisfiedBy
end script

script ContainsDueDateTextSpecification
	property parent : ddd's specification
	
	on isSatisfiedBy(obj)
		set theTransportText to obj as text
		return (count of textutil's getTextElements(theTransportText, DATE_DELIM)) is in {2, 3}
	end isSatisfiedBy
end script

script ContainsEstimateSpecification
	property parent : ddd's specification
	
	on isSatisfiedBy(obj)
		set theTransportText to obj as text
		return (count of textutil's getTextElements(theTransportText, ESTIMATE_DELIM)) is equal to 2
	end isSatisfiedBy
end script

script ContainsNoteSpecification
	property parent : ddd's specification
	
	on isSatisfiedBy(obj)
		set theTransportText to obj as text
		return (count of textutil's getTextElements(theTransportText, NOTE_DELIM)) is equal to 2
	end isSatisfiedBy
end script

script Expression
	property spec : missing value
	on makeExpression()
		copy me to newExpression
		tell newExpression to defineSpecification()
		return newExpression
	end makeExpression
	
	on interpret(aTask)
		local transportText
		
		tell application "OmniFocus"
			set transportText to name of aTask
		end tell
		
		if (spec's isSatisfiedBy(transportText)) then
			doInterpret(aTask)
		end if
	end interpret
	
	on doInterpret(aTask)
	end doInterpret
end script

script MacroExpression
	property parent : Expression
	property expressions : {}
	
	on defineSpecification()
		script TrueSpecification
			property parent : ddd's specification
			on isSatisfiedBy(obj)
				return true
			end isSatisfiedBy
		end script
		
		set my spec to TrueSpecification
	end defineSpecification
	
	on addExpression(anExpression)
		set expressions's end to anExpression
	end addExpression
	
	on interpret(aTask)
		repeat with Expression in expressions
			tell Expression to interpret(aTask)
		end repeat
	end interpret
end script

script NameExpression
	property parent : Expression
	
	on defineSpecification()
		set my spec to ContainsTaskNameSpecification
	end defineSpecification
	
	on doInterpret(aTask)
		set taskName to item 1 of textutil's getTextElements(transportText, {FLAG_DELIM, PROJECT_DELIM, CONTEXT_DELIM, DATE_DELIM, ESTIMATE_DELIM, NOTE_DELIM})
		return {name:taskName}
	end doInterpret
end script

script UnparsedTaskNameExpression
	property parent : NameExpression
	
	on defineSpecification()
		continue defineSpecification()
		set my spec to my spec's andSpec(ContainsUnparsedTaskNameSpecification)
	end defineSpecification
	
	on doInterpret(aTask)
		local transportText
		
		tell application "OmniFocus"
			set transportText to aTask's name
		end tell
		
		set taskName to textutil's StringObj's makeString(transportText)'s removeText("--")'s asText()
		
		tell application "OmniFocus"
			set aTask's name to taskName
		end tell
		return aTask
	end doInterpret
end script

script FlagExpression
	property parent : Expression
	
	on defineSpecification()
		set my spec to ContainsFlagSpecification
	end defineSpecification
	
	on doInterpret(aTask)
		local transportText
		
		tell application "OmniFocus"
			set transportText to name of aTask
		end tell
		
		set taskName to textutil's StringObj's makeString(transportText)'s removeText(FLAG_DELIM)
		
		tell application "OmniFocus"
			set aTask's flagged to true
			set aTask's name to taskName's asText()
		end tell
		
		return aTask
	end doInterpret
end script

script AssignedContainerExpression
	property parent : Expression
	
	on defineSpecification()
		set my spec to ContainsValidProjectInTransportTextSpecification
	end defineSpecification
	
	on doInterpret(aTask)
		local transportText
		
		tell application "OmniFocus"
			set transportText to name of aTask
		end tell
		
		set transportTextElements to textutil's getTextElements(transportText, PROJECT_DELIM)
		
		set projectNameSegment to item 2 of transportTextElements
		
		--Might have other task elements coming after that
		set projectNameElements to textutil's getTextElements(projectNameSegment, {CONTEXT_DELIM, DATE_DELIM, ESTIMATE_DELIM, NOTE_DELIM})
		set projectName to item 1 of projectNameElements
		
		set aProject to domain's ProjectRepository's findByName(projectName)
		
		set taskName to textutil's StringObj's makeString(transportText)'s removeText(PROJECT_DELIM & projectName)
		
		tell application "OmniFocus"
			if (aTask's assigned container is missing value) then set aTask's assigned container to aProject
			
			set name of aTask to taskName's asText()
		end tell
	end doInterpret
end script

script ContextExpression
	property parent : Expression
	
	on defineSpecification()
		set my spec to ContainsValidContextInTransportTextSpecification
	end defineSpecification
	
	on doInterpret(aTask)
		local transportText
		
		tell application "OmniFocus"
			set transportText to name of aTask
		end tell
		
		set transportTextElements to textutil's getTextElements(transportText, CONTEXT_DELIM)
		
		set contextNameSegment to item 2 of transportTextElements
		
		--Might have other task elements coming after that
		set contextNameElements to textutil's getTextElements(contextNameSegment, {DATE_DELIM, ESTIMATE_DELIM, NOTE_DELIM})
		set contextName to item 1 of contextNameElements
		
		set aContext to my domain's ContextRepository's findByName(contextName)
		
		set taskName to textutil's StringObj's makeString(transportText)'s removeText(CONTEXT_DELIM & contextName)
		
		tell application "OmniFocus"
			if (aTask's context is missing value) then set aTask's context to aContext
			
			set aTask's name to taskName's asText()
		end tell
		
		return aTask
	end doInterpret
end script

property TIME_DELIM : space & "at" & space

on parseDueDate(dateText)
	set dueDate to parse of (dateutil's CalendarDate) from dateText at defaultDueTime()
	return dueDate's asDate()
end parseDueDate

on defaultDueTime()
	return "05:00PM"
end defaultDueTime

on parseDeferDate(dateText)
	set deferDate to parse of (dateutil's CalendarDate) from dateText at defaultDeferTime()
	return deferDate's asDate()
end parseDeferDate

on defaultDeferTime()
	return "12:00:00AM"
end defaultDeferTime

script DateExpression
	property parent : Expression
	
	on defineSpecification()
		set my spec to ContainsDueDateTextSpecification
	end defineSpecification
	
	on doInterpret(aTask)
		local transportText
		
		tell application "OmniFocus"
			set transportText to name of aTask
		end tell
		
		local dueDateSegment
		local deferDateSegment
		local dateReplacementString
		local aDeferDate
		local aDueDate
		
		set transportTextElements to textutil's getTextElements(transportText, DATE_DELIM)
		
		if (count of transportTextElements) is 2 then
			--Assuming it comes after a task name being present (being item 1)
			set aDeferDate to missing value
			
			set dueDateSegment to item 2 of transportTextElements
			
			--Might have estimate mixed in with that
			set dueDateElements to textutil's getTextElements(dueDateSegment, {DATE_DELIM, ESTIMATE_DELIM, NOTE_DELIM})
			
			set dueDateSegment to item 1 of dueDateElements
			set aDueDate to parseDueDate(dueDateSegment)
			
			set dateReplacementString to DATE_DELIM & dueDateSegment
			
		else if (count of transportTextElements) is 3 then
			--Defer date
			set deferDateSegment to item 2 of transportTextElements
			set aDeferDate to parseDeferDate(deferDateSegment)
			
			--Due date
			set dueDateSegment to item 3 of transportTextElements
			
			--Might have estimate mixed in with that
			set dueDateElements to textutil's getTextElements(dueDateSegment, {DATE_DELIM, ESTIMATE_DELIM, NOTE_DELIM})
			
			set dueDateSegment to item 1 of dueDateElements
			set aDueDate to parseDueDate(dueDateSegment)
			
			set dateReplacementString to DATE_DELIM & deferDateSegment & DATE_DELIM & dueDateSegment
		end if
		
		set taskName to textutil's StringObj's makeString(transportText)'s removeText(dateReplacementString)
		
		tell application "OmniFocus"
			if aDeferDate is not missing value then set defer date of aTask to aDeferDate
			if aDueDate is not missing value then set due date of aTask to aDueDate
			
			set name of aTask to taskName's asText()
		end tell
	end doInterpret
end script

script DeferDateExpression
	property parent : Expression
	
	on defineSpecification()
		set my spec to ContainsDeferDateTextSpecification
	end defineSpecification
	
	on doInterpret(aTask)
		local transportText
		
		tell application "OmniFocus"
			set transportText to name of aTask
		end tell
		
		set transportTextElements to textutil's getTextElements(transportText, DATE_DELIM)
		
		set deferDateSegment to item 2 of transportTextElements
		
		set aDeferDate to parseDeferDate(deferDateSegment)
		
		set taskName to textutil's StringObj's makeString(transportText)'s removeText(DATE_DELIM & deferDateSegment)
		tell application "OmniFocus"
			set defer date of aTask to aDeferDate
			
			set name of aTask to taskName's asText()
		end tell
	end doInterpret
end script

script DueDateExpression
	property parent : Expression
	
	on defineSpecification()
		set my spec to ContainsDueDateTextSpecification
	end defineSpecification
	
	on doInterpret(aTask)
		local transportText
		
		tell application "OmniFocus"
			set transportText to name of aTask
		end tell
		
		local dueDateSegment
		set transportTextElements to textutil's getTextElements(transportText, DATE_DELIM)
		
		if (count of transportTextElements) is 2 then
			--Assuming it comes after a task name being present (being item 1)
			set dueDateSegment to item 2 of transportTextElements
			
			--Might have estimate mixed in with that
			set dueDateElements to textutil's getTextElements(dueDateSegment, {DATE_DELIM, ESTIMATE_DELIM, NOTE_DELIM})
			
			set dueDateSegment to item 1 of dueDateElements
		else if (count of transportTextElements) is 3 then
			set dueDateSegment to item 3 of transportTextElements
			
			--Might have estimate mixed in with that
			set dueDateElements to textutil's getTextElements(dueDateSegment, {DATE_DELIM, ESTIMATE_DELIM, NOTE_DELIM})
			
			set dueDateSegment to item 1 of dueDateElements
		end if
		
		set aDueDate to parseDueDate(dueDateSegment)
		
		set taskName to textutil's StringObj's makeString(transportText)'s removeText(DATE_DELIM & dueDateSegment)
		
		tell application "OmniFocus"
			set due date of aTask to aDueDate
			
			set name of aTask to taskName's asText()
		end tell
		
		return aTask
	end doInterpret
end script

script EstimateExpression
	property parent : Expression
	
	on defineSpecification()
		set my spec to ContainsEstimateSpecification
	end defineSpecification
	
	on doInterpret(aTask)
		local transportText
		
		tell application "OmniFocus"
			set transportText to name of aTask
		end tell
		
		local theEstimate
		
		set transportTextElements to textutil's getTextElements(transportText, ESTIMATE_DELIM)
		
		set estimateSegment to item 2 of transportTextElements
		
		set estimateElements to textutil's getTextElements(estimateSegment, NOTE_DELIM)
		set theEstimate to item 1 of estimateElements
		
		if length of theEstimate is equal to 1 then
			set estimatedMinutes to theEstimate as integer
		else if length of theEstimate is greater than 1 then
			set estimateText to text 1 thru ((length of theEstimate) - 1) of theEstimate
			set estimatedMinutes to estimateText as integer
			
			if (theEstimate contains "h") then
				set estimatedMinutes to estimatedMinutes * 60
			else if (theEstimate contains "d") then
				set estimatedMinutes to estimatedMinutes * 60 * 24
			else if (theEstimate contains "w") then
				set estimatedMinutes to estimatedMinutes * 60 * 24 * 7
			end if
		end if
		
		set taskName to textutil's StringObj's makeString(transportText)'s removeText(ESTIMATE_DELIM & theEstimate)
		
		tell application "OmniFocus"
			set aTask's estimated minutes to estimatedMinutes
			--Update task name
			set aTask's name to taskName's asText()
		end tell
		
		return aTask
	end doInterpret
end script

script NoteExpression
	property parent : Expression
	
	on defineSpecification()
		set my spec to ContainsNoteSpecification
	end defineSpecification
	
	on doInterpret(aTask)
		local aNoteSegment
		local tt
		
		local taskName
		
		tell application "OmniFocus"
			set taskName to aTask's name
		end tell
		
		set transportTextElements to textutil's getTextElements(taskName, NOTE_DELIM)
		
		if (count of transportTextElements) is 2 then
			set aNoteSegment to item 2 of transportTextElements
		else
			error "Did not find note as expected from transport text: " & taskName
		end if
		
		set revisedTaskName to textutil's StringObj's makeString(taskName)'s removeText(NOTE_DELIM & aNoteSegment)'s asText()
		
		tell application "OmniFocus"
			if text of the note of aTask is "" then
				set the text of the note of aTask to aNoteSegment
			else
				--Append to existing note
				set the text of the note of aTask to text of the note of aTask & "
" & aNoteSegment
			end if
			
			set aTask's name to revisedTaskName
		end tell
		
		return aTask
	end doInterpret
end script

script transportText
	property textValue : missing value
	
	on makeTransportText(textValue)
		copy transportText to aText
		set aText's textValue to textValue
		return aText
	end makeTransportText
	
	on getTaskNameToken()
	end getTaskNameToken
	
	on getFlaggedToken()
	end getFlaggedToken
	
	on getProjectToken()
	end getProjectToken
	
	on getContextToken()
	end getContextToken
	
	on getDueDateToken()
	end getDueDateToken
	
	on getDeferDateToken()
	end getDeferDateToken
	
	on getEstimatedMinutesToken()
	end getEstimatedMinutesToken
	
	on getNoteToken()
	end getNoteToken
	
	on extractNoteToken()
		return noteToken
	end extractNoteToken
	
	on asText()
		return textValue
	end asText
end script

script TransportTextEvaluator
	property transportTextItems : {}
	(*
	type = Expression
	*)
	property syntaxTree : missing value
	
	on anotherEvaluator()
		set exp to MacroExpression's makeExpression()
		tell exp to addExpression(FlagExpression's makeExpression())
		tell exp to addExpression(AssignedContainerExpression's makeExpression())
		tell exp to addExpression(ContextExpression's makeExpression())
		tell exp to addExpression(DateExpression's makeExpression())
		tell exp to addExpression(EstimateExpression's makeExpression())
		tell exp to addExpression(NoteExpression's makeExpression())
		
		tell exp to addExpression(UnparsedTaskNameExpression's makeExpression())
		
		copy TransportTextEvaluator to anEvaluator
		set anEvaluator's syntaxTree to exp
		return anEvaluator
	end anotherEvaluator
	
	(* 
	@post returns boolean
	*)
	on interpret(aTask)
		return syntaxTree's interpret(aTask)
	end interpret
end script

script OmniFocusTransportTextParsingRule
	property parent : rules's ConditionalCommandRule
	
	on prettyName()
		return "OmniFocus Transport Text Parsing Rule"
	end prettyName
	
	on constructRule()
		set aRule to continue constructRule()
		
		tell aRule to addCondition(domain's UnparsedTaskSpecification)
		
		script EvaluatorCommand
			property parent : domain's TaskCommand
			
			on execute (aTask)
				set evaluator to TransportTextEvaluator's anotherEvaluator()
				tell evaluator to interpret(aTask)
			end execute
		end script
		
		tell aRule to addAction(EvaluatorCommand)
		return aRule
	end constructRule
end script
