(*! @abstract <em>[text]</em> OmniFocusDomain's name. *)
property name : "OmniFocusDomain"
(*! @abstract <em>[text]</em> OmniFocusDomain's version. *)
property version : "1.0.0"
(*! @abstract <em>[text]</em> OmniFocusDomain's id. *)
property id : "com.kraigparkinson.OmniFocusDomain"

property ddd : script "com.kraigparkinson/ASDomainDrivenDesign"

script TaskCommand
	on constructCommand()
		copy me to aCommand
		return aCommand
	end constructCommand
	
	on execute(aTask)
		error "Abstract method not implemented: execute" from me
	end execute	
end script

script MacroTaskCommand
	property parent : TaskCommand
	property commands : { }
	on execute(aTask)
		repeat with command in commands
			tell command to execute(aTask)
		end repeat
	end execute
end script

script MarkCompleteCommand
	property parent : TaskCommand

	on execute(aTask)
		tell application "OmniFocus"
			set aTask's completed to true
		end tell
	end execute
end script


script AbstractRepeatDeferCommand
	property parent : TaskCommand
	property repetitionRule : { }
	
	on constructCommand()
		copy me to aCommand
		tell aCommand to addRecurrenceText()
		tell aCommand to addRepetitionMethod()
		return aCommand
	end constructCommand
	
	on addRecurrenceText()
	end addRecurrenceText
	
	on addRepetitionMethod()
	end addRepetitionMethod
	
	on execute(aTask)
		tell application "OmniFocus"
			set newRepetitionRule to my repetitionRule
			log "made a repetition rule"
			
			set aTask's repetition rule to newRepetitionRule
--			set aTask's repetition to { unit:day, steps:2, fixed:false }
		end tell
	end execute
end script

script RepeatDeferWeeklyCommand
	property parent : AbstractRepeatDeferCommand
	
	on addRecurrenceText()
		set my repetitionRule to my repetitionRule & { recurrence:"FREQ=WEEKLY" }
	end addRecurrenceText
	
	on addRepetitionMethod()
		tell application "OmniFocus"
			set my repetitionRule to my repetitionRule & { repetition method:start after completion }
		end tell
	end addRepetitionMethod	
end script

script RepeatDeferDailyCommand
	property parent : TaskCommand
	
	on execute(aTask)
		tell application "OmniFocus"
			set newRepetitionRule to {repetition method:start after completion, recurrence:"FREQ=DAILY"}
			log "made a repetition rule"
			
			set aTask's repetition rule to newRepetitionRule
--			set aTask's repetition to { unit:day, steps:2, fixed:false }
		end tell
	end execute
end script

script MatchingNameTaskSpecification
	property parent : ddd's Specification
	property aName : missing value
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			return name of aTask equals aName
		end tell
	end isSatisfiedBy
end script 

script UnparsedTaskSpecification
	property parent : ddd's specification
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			return (name of aTask) starts with "--"
		end tell
	end isSatisfiedBy
end script

script NonrepeatingTaskSpecification
	property parent : ddd's specification
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			return aTask's repetition rule is missing value
		end tell
	end isSatisfiedBy
end script

script TaskRepository
	on selectUnparsedTasksFromInbox()
		set spec to UnparsedTaskSpecification
		
		return selectInboxTasks(spec)
	end selectUnparsedTasksFromInbox
	
	on selectUserSpecifiedTasks()
		tell application "OmniFocus"
			tell content of first document window of front document
				return value of (selected trees where class of its value is not item and class of its value is not folder)
			end tell
		end tell		
	end selectUserSpecifiedTasks
	
	on selectInboxTasks(spec)
		set inboxItems to selectAllInboxTasks()
		set matchingItems to { }
		repeat with currentTask in inboxItems
			if spec's isSatisfiedBy(currentTask) then 
				set end of matchingItems to currentTask
			end if
		end repeat
		return matchingItems
	end selectAllInboxTasks
	
	on selectAllInboxTasks()
		tell application "OmniFocus"
			tell front document
				set inboxItems to every inbox task
				return inboxItems
			end tell
		end tell
	end selectAllInboxTasks

	on selectAll()
		tell application "OmniFocus"
			tell front document
				set inboxItems to tasks
				return inboxItems
			end tell
		end tell
	end selectAll
	
	(*
		@pre: transportText not null
		@post: returns a list
		@post: list has at least one item
	*)
	on createFromTransportText(transportText)
		tell application "OmniFocus"
			return parse tasks into default document with transport text transportText with as single task
		end tell
	end create

	on createInboxTaskWithName(taskName)
		tell application "OmniFocus"
			tell default document
--				tell quick entry
					return make new inbox task with properties {name:taskName}
--				end tell
			end tell
		end tell
	end createInboxTaskWithName
	
	on createInboxTaskWithProperties(taskProperties)
		tell application "OmniFocus"
			tell default document
--				tell quick entry
					return make new inbox task with properties taskProperties
--				end tell
			end tell
		end tell
	end createInboxTaskWithProperties
	
end script

script ContextRepository
	on create(contextName)
		local newContext
	
		tell application "OmniFocus"
			tell default document
				set newContext to make new context with properties {name:contextName}
			end tell
		end tell
	
		if newContext is equal to missing value then
			error "Context not created for " & contextName
		end if
		return newContext
	end create

	on createChild(parentContext, contextName)
		local newContext
	
		tell application "OmniFocus"
			tell default document
				set newContext to make new context at parentContext with properties {name:contextName}
			end tell
		end tell
	
		if newContext is equal to missing value then
			error "Context not created for " & contextName
		end if
		return newContext
	end createChild

	(*
	 @pre contextName is not empty
	*)
	on findByName(contextName)
		local theContext
	
		tell front document of application "OmniFocus"
		
			set thePossibleContexts to complete contextName as context maximum matches 1
			if ((count of thePossibleContexts) is equal to 1) then
				set theContextID to id of first item of thePossibleContexts
				set theContext to context id theContextID
			else
				set theContext to missing value
			end if
		
		end tell
	
		return theContext
	end findByName
end script

script ProjectRepository
	on create(projectName)
		local newProject
	
		tell application "OmniFocus"
			tell default document
				set newProject to make new project with properties {name:projectName}
			end tell
		end tell
	
		return newProject
	end create

	on findByName(projectName)
		local theProject
	
		tell front document of application "OmniFocus"
		
			set thePossibleProjects to complete projectName as project maximum matches 1
			if ((count of thePossibleProjects) is equal to 1) then
				set theProjectID to id of first item of thePossibleProjects
				set theProject to project id theProjectID
			else
				set theProject to missing value
			end if
		
		end tell
		return theProject
	end findProjectFromName
end script