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
property collections : script "com.kraigparkinson/ASCollections"

property TASK_DELIM : "--"
property FLAG_DELIM : "!"
property PROJECT_DELIM : "::"
property CONTEXT_DELIM : "@"
property DATE_DELIM : "#"
property ESTIMATE_DELIM : "$"
property NOTE_DELIM : "//"
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

on parseEstimate(theEstimate)
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
	return estimatedMinutes
end parseEstimate

script Expression
	property tokenType : missing value
	
	on makeExpression(aType)
		copy me to anExpression
		set anExpression's tokenType to aType
		return anExpression
	end makeExpression
	
	on interpret(aTask, ttVariables)
	end interpret	
end 

on makeExpression(aType)
	return Expression's makeExpression(aType)
end Expression

script TransportTextTokenTypeEnum
	property NAME_TYPE : "name"
	property FLAG_TYPE : "flagged"
	property PROJECT_TYPE : "project"
	property CONTEXT_TYPE : "context"
	property DUE_DATE_TYPE : "due date"
	property DEFER_DATE_TYPE : "defer date"
	property ESTIMATE_TYPE : "estimate"
	property NOTE_TYPE : "note"
end script

on TaskNameExpression()
	script _TaskNameExpression
		property parent : Expression

		on interpret(aTask, ttVariables)
			set taskNameToken to ttVariables's getValue(TransportTextTokenTypeEnum's NAME_TYPE)

			tell application "OmniFocus"
				set aTask's name to taskNameToken
			end tell

			return missing value
		end interpret
	end script
	
	return _TaskNameExpression's makeExpression(TransportTextTokenTypeEnum's NAME_TYPE)
end TaskNameExpression

on FlaggedExpression()
	script _FlaggedExpression
		property parent : Expression

		on interpret(aTask, ttVariables)
			set flaggedToken to ttVariables's getValue(TransportTextTokenTypeEnum's FLAG_TYPE)
			
			tell application "OmniFocus"
				set aTask's flagged to true
			end tell
			
			return missing value
		end interpret
	end script
	return _FlaggedExpression's makeExpression(TransportTextTokenTypeEnum's FLAG_TYPE)
end FlaggedExpression
	
on AssignedContainerNameExpression()
	script _AssignedContainerNameExpression
		property parent : Expression

		on interpret(aTask, ttVariables)
			set projectToken to ttVariables's getValue(TransportTextTokenTypeEnum's PROJECT_TYPE)
						
			set ttRemainder to missing value 
			
			tell application "OmniFocus"
				set aProject to domain's ProjectRepository's findByName(projectToken)
				
				if (aProject is missing value) then 						
					set ttRemainder to "::" & projectToken
				else
					if (aTask's assigned container is missing value) then 
						set aTask's assigned container to aProject
					end if
				end if
			end tell
			
			return ttRemainder		
		end interpret		
	end script
	return _AssignedContainerNameExpression's makeExpression(TransportTextTokenTypeEnum's PROJECT_TYPE)
end AssignedContainerNameExpression
	
on ContextNameExpression()
	script _ContextNameExpression
		property parent : Expression

		on interpret(aTask, ttVariables)
			set contextToken to ttVariables's getValue(TransportTextTokenTypeEnum's CONTEXT_TYPE)

			set ttRemainder to missing value
			
			tell application "OmniFocus"
				set aContext to domain's ContextRepository's findByName(contextToken)

				if (aContext is missing value)
					set ttRemainder to "@" & contextToken
				else
					if (aTask's context is missing value) then 
						set aTask's context to aContext
					end if
				end if
			end tell
			
			return ttRemainder
		end interpret
	end script
	return _ContextNameExpression's makeExpression(TransportTextTokenTypeEnum's CONTEXT_TYPE)

end ContextNameExpression

on DueDateExpression()
	script _DueDateExpression
		property parent : Expression

		on interpret(aTask, ttVariables)
			set aDueDateExpression to ttVariables's getValue(TransportTextTokenTypeEnum's DUE_DATE_TYPE)
			
			set dueDate to parse of (dateutil's CalendarDate) from aDueDateExpression at defaultDueTime()
					
			tell application "OmniFocus"
				if (aTask's due date is missing value) then 
					
					set aTask's due date to dueDate's asDate()
--					set aTask's due date to my parseDueDate(aDueDateExpression)
				end if
			end tell
			
			return missing value
		end interpret
	end script
	return _DueDateExpression's makeExpression(TransportTextTokenTypeEnum's DUE_DATE_TYPE)
end DueDateExpression

on DeferDateExpression()
	script _DeferDateExpression
		property parent : Expression

		on interpret(aTask, ttVariables)
			set aDeferDateExpression to ttVariables's getValue(TransportTextTokenTypeEnum's DEFER_DATE_TYPE)
			
			tell application "OmniFocus"
				if (aTask's defer date is missing value) then
					set aTask's defer date to my parseDeferDate(aDeferDateExpression)
				end if
			end tell
			
			return missing value
		end interpret
	end script
	return _DeferDateExpression's makeExpression(TransportTextTokenTypeEnum's DEFER_DATE_TYPE)
end DeferDateExpression

on EstimateExpression()
	script _EstimateExpression
		property parent : Expression

		on interpret(aTask, ttVariables)
			set anEstimateExpression to ttVariables's getValue(TransportTextTokenTypeEnum's ESTIMATE_TYPE)

			tell application "OmniFocus"
				if (aTask's estimated minutes is missing value) then 
					set aTask's estimated minutes to my parseEstimate(anEstimateExpression)
				end if
			end tell
			return missing value
		end interpret
	end script
	return _EstimateExpression's makeExpression(TransportTextTokenTypeEnum's ESTIMATE_TYPE)
end EstimateExpression

on NoteExpression()
	script _NoteExpression
		property parent : Expression

		on interpret(aTask, ttVariables)
			set aNoteExpression to ttVariables's getValue(TransportTextTokenTypeEnum's NOTE_TYPE)
			
			script ExpressionAppendNoteCommand
				property parent : domain's AppendNoteCommand
	
				on defineNote()
					return aNoteExpression
				end defineNote
			end script
		
			set aCommand to ExpressionAppendNoteCommand's constructCommand()
			tell aCommand to execute(aTask)
			
			return missing value
		end interpret
	end script
	return _NoteExpression's makeExpression(TransportTextTokenTypeEnum's NOTE_TYPE)
end NoteExpression

script TransportTextExpression
	property expressions : missing value
	
	on interpret(aTask, ttVariables)		
		set ttRemainders to missing value
		
		set expressions to { }
		set end of expressions to TaskNameExpression()
		set end of expressions to FlaggedExpression()
		set end of expressions to AssignedContainerNameExpression()
		set end of expressions to ContextNameExpression()
		set end of expressions to DeferDateExpression()
		set end of expressions to DueDateExpression()
		set end of expressions to EstimateExpression()
		set end of expressions to NoteExpression()	
		
		repeat with expr in expressions
			set aKey to expr's tokenType

			if (ttVariables's containsValue(aKey))
				set remainder to expr's interpret(aTask, ttVariables)

				if (remainder is not missing value)
					if ttRemainders is missing value
						set ttRemainders to space & remainder
					else 
						set ttRemainders to ttRemainders & space & remainder
					end if
				end if  
			end if
		end repeat
		
		if ttRemainders is not missing value then tell application "OmniFocus" to set aTask's name to "--" & aTask's name & ttRemainders
		tell application "OmniFocus" to compact		
	end interpret
end script
	
on parseTransportTextIntoVariables(transportText as text)
	set possibleTokens to textutil's getTextElements(transportText, space)
		
	set varStack to collections's makeStack()

	repeat with tokenItem in possibleTokens
		if tokenItem starts with TASK_DELIM
			tell varStack to push({key:TransportTextTokenTypeEnum's NAME_TYPE, value:textutil's replaceText(tokenItem, TASK_DELIM, "")})
		else if tokenItem starts with PROJECT_DELIM
			tell varStack to push({key:TransportTextTokenTypeEnum's PROJECT_TYPE, value:textutil's replaceText(tokenItem, PROJECT_DELIM, "")})
		else if tokenItem starts with CONTEXT_DELIM
			tell varStack to push({key:TransportTextTokenTypeEnum's CONTEXT_TYPE, value:textutil's replaceText(tokenItem, CONTEXT_DELIM, "")})
		else if tokenItem starts with DATE_DELIM
			if (varStack's height() > 0)
				set lastToken to varStack's peek()
				if lastToken's key equals my TransportTextTokenTypeEnum's DUE_DATE_TYPE
					tell varStack to pop()
					--switch out for defer date type
		 			tell varStack to push({key:TransportTextTokenTypeEnum's DEFER_DATE_TYPE, value:textutil's replaceText(lastToken's value, DATE_DELIM, "")})
					tell varStack to push({key:TransportTextTokenTypeEnum's DUE_DATE_TYPE, value:textutil's replaceText(tokenItem, DATE_DELIM, "")})
				else 
					tell varStack to push({key:TransportTextTokenTypeEnum's DUE_DATE_TYPE, value:textutil's replaceText(tokenItem, DATE_DELIM, "")})
				end if
			else 
				tell varStack to push({key:TransportTextTokenTypeEnum's DUE_DATE_TYPE, value:textutil's replaceText(tokenItem, DATE_DELIM, "")})
			end if 
		else if tokenItem starts with ESTIMATE_DELIM
			tell varStack to push({key:TransportTextTokenTypeEnum's ESTIMATE_TYPE, value:textutil's replaceText(tokenItem, ESTIMATE_DELIM, "")})
		else if tokenItem starts with NOTE_DELIM
			tell varStack to push({key:TransportTextTokenTypeEnum's NOTE_TYPE, value:textutil's replaceText(tokenItem, NOTE_DELIM, "")})
		else if tokenItem's contents equals FLAG_DELIM
			tell varStack to push({key:TransportTextTokenTypeEnum's FLAG_TYPE, value:true})
		else
			if (varStack's height() > 0)
				set lastToken to varStack's peek()
				set lastToken's value to lastToken's value's contents & space & tokenItem--'s contents
			else
				error "Unrecognized token"
			end if 
		end if 
	end repeat
	
	set ttVariables to collections's makeMap()
	repeat with aVar in varStack's values
		tell ttVariables to putValue(aVar's key, aVar's value)
	end repeat
	
	return ttVariables
end parseTransportTextIntoVariables

script TransportTextEvaluator
	property syntaxTree : TransportTextExpression
	
	on evaluate(aTask, ttVariables)
		tell syntaxTree to interpret(aTask, ttVariables)			
	end evaluate
end script

on createTransportTextEvaluator()	
	copy TransportTextExpression to ttExpr	
	
	return TransportTextEvaluator
end createTransportTextEvaluator

script TransportTextInterpreter
	on update(aTask)	
	end update
end script

script DefaultInterpreter
	property parent : TransportTextInterpreter
	
	on update(aTask)
		
		tell application "OmniFocus"
			set taskName to aTask's name

			if (taskName starts with "--")
				set taskName to ((characters 3 thru -1 of taskName) as string)
				set newTask to parse tasks into with transport text taskName with as single task

				delete aTask
			end if
		end tell
	end update
end script

script CustomInterpreter
	property parent : TransportTextInterpreter
	
	on update(aTask)
		
		tell application "OmniFocus"
			set transportText to aTask's name
		end tell

		set variables to parseTransportTextIntoVariables(transportText)

		set evaluator to createTransportTextEvaluator()
		tell evaluator to evaluate(aTask, variables)
	end update
end script

script OmniFocusTransportTextService
	property interpreter : CustomInterpreter
	
	on updateTaskPropertiesFromName(aTask)
		tell interpreter to update(aTask)
	end updateTaskPropertiesFromName
end script

