(*! @abstract <em>[text]</em> OmniFocusDomain's name. *)
property name : "OmniFocusDomain"
(*! @abstract <em>[text]</em> OmniFocusDomain's version. *)
property version : "1.0.0"
(*! @abstract <em>[text]</em> OmniFocusDomain's id. *)
property id : "com.kraigparkinson.OmniFocusDomain"

property ddd : script "com.kraigparkinson/ASDomainDrivenDesign"

script TaskCommand
	on make new TaskCommand with properties commandProperties as record : {}
		copy me to aCommand
		return aCommand
	end make

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
	property name : "Mark complete"

	on execute(aTask)
		tell application "OmniFocus"
			with timeout of 3 seconds			
				set aTask's completed to true
			end timeout
		end tell
	end execute
end script

script AppendNoteCommand
	property parent : TaskCommand

	on execute(aTask)
		set additionalNoteText to defineNote()

		tell application "OmniFocus"
			with timeout of 3 seconds
			
				if text of the note of aTask is "" then
					set the text of the note of aTask to additionalNoteText
				else
					--Append to existing note
					set the text of the note of aTask to text of the note of aTask & return & additionalNoteText
				end if			
			end timeout
		end tell
	end execute
	
	on defineNote()
		return ""
	end defineNote
end script

script DeferAnotherCommand
	property parent : TaskCommand
	property frequency : missing value
	
	on execute(aTask)
		tell application "OmniFocus"
			set freqString to "FREQ=" & frequency
			set newRepetitionRule to {repetition method:start after completion, recurrence:freqString}
		
			set aTask's repetition rule to newRepetitionRule
		end tell
	end execute
end script

script DueAgainCommand
	property parent : TaskCommand
	property frequency : missing value
	
	on execute(aTask)
		tell application "OmniFocus"
			set freqString to "FREQ=" & frequency
			set newRepetitionRule to {repetition method:due after completion, recurrence:freqString}
	
			set aTask's repetition rule to newRepetitionRule
		end tell
	end execute
end script

script RepeatEveryCommand
	property parent : TaskCommand
	property frequency : missing value
	
	on execute(aTask)
		tell application "OmniFocus"
			set freqString to "FREQ=" & frequency
			set newRepetitionRule to {repetition method:fixed repetition, recurrence:freqString}
		
			set aTask's repetition rule to newRepetitionRule
		end tell
	end execute
end script

script FlaggedSpecification
	property parent : ddd's AbstractSpecification
	property name : "flagged"
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			with timeout of 3 seconds
				return (aTask's flagged)
			end timeout
		end tell
	end isSatisfiedBy
end script

script TaskHasProjectSpecification
	property parent : ddd's AbstractSpecification
	property name : "has project"
	
	on isSatisfiedBy(obj)
		tell application "OmniFocus"
			with timeout of 3 seconds
			
				return (aTask's project is not missing value)
			end timeout
		end tell
	end isSatisfiedBy
end script

script TaskHasAssignedContainerSpecification
	property parent : ddd's AbstractSpecification
	property name : "has assignd container"
	
	on isSatisfiedBy(obj)
		tell application "OmniFocus"
			with timeout of 3 seconds
			
				return (aTask's assigned container is not missing value)
			end timeout
		end tell
	end isSatisfiedBy
end script

script TaskHasContextSpecification
	property parent : ddd's AbstractSpecification
	property name : "has context"

	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			with timeout of 3 seconds
			
				return (aTask's context is not missing value)
			
			end timeout
		end tell
	end isSatisfiedBy
end script

script ContainsDeferDateSpecification
	property parent : ddd's AbstractSpecification
	property name : "has defer date"
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			with timeout of 3 seconds
				return (aTask's defer date is not missing value)
			end timeout
		end tell
	end isSatisfiedBy
end script

script ContainsDueDateSpecification
	property parent : ddd's AbstractSpecification
	property name : "has due date"
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			with timeout of 3 seconds
			
				return (aTask's due date is not missing value)
			
			end timeout
		end tell
	end isSatisfiedBy
end script

script ContainsEstimateSpecification
	property parent : ddd's AbstractSpecification
	property name : "has estimatee"
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			with timeout of 3 seconds
			
				return (aTask's estimated minutes is not missing value)
			end timeout
		end tell
	end isSatisfiedBy
end script

script ContainsNoteSpecification
	property parent : ddd's AbstractSpecification
	property name : "has note"
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			with timeout of 3 seconds
			
				return (aTask's note is not missing value)
			end timeout
		end tell
	end isSatisfiedBy
end script

script MatchingNameTaskSpecification
	property parent : ddd's AbstractSpecification
	property aName : missing value
	property name : "matches task name"
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			with timeout of 3 seconds
			
				return name of aTask equals aName
			
			end timeout
		end tell
	end isSatisfiedBy
end script 

script UnparsedTaskSpecification
	property parent : ddd's AbstractSpecification
	property name : "unparsed"
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			with timeout of 3 seconds
			
				return (name of aTask) starts with "--"
			
			end timeout
		end tell
	end isSatisfiedBy
end script

script NonrepeatingTaskSpecification
	property parent : ddd's AbstractSpecification
	property name : "not repeating"
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			with timeout of 3 seconds
			
			return aTask's repetition rule is missing value
			
			end timeout
		end tell
	end isSatisfiedBy
end script

script TaskRepository
	on selectUserSpecifiedTasks()
		tell application "OmniFocus"
			tell content of first document window of front document
				return value of (selected trees where class of its value is not item and class of its value is not folder)
			end tell
		end tell		
	end selectUserSpecifiedTasks
	
	on selectInboxTasks(spec)
		set inboxItems to selectAllInboxTasks()
		
--		set inboxItemsRef to reference to inboxItems
		
		set matchingItems to { }
		
--		repeat with currentTask in inboxItemsRef
		repeat with currentTask in inboxItems
			if spec's isSatisfiedBy(currentTask) then 
			--	set end of matchingItems to currentTask
				set matchingItems to matchingItems & { currentTask } 
			end if
		end repeat
		
		if (count of matchingItems > 0) then
			return matchingItems
		else 
			return { }
		end 
	end selectInboxTasks
	
	on selectAllInboxTasks()
		tell application "OmniFocus"
			with timeout of 3 seconds
			
			tell front document
				set inboxItems to every inbox task
				return inboxItems
			end tell
			end timeout
		end tell
	end selectAllInboxTasks

	on selectAll()
		tell application "OmniFocus"
			with timeout of 3 seconds
			
			tell front document
				set inboxItems to tasks
				return inboxItems
			end tell
			end timeout
		end tell
	end selectAll
	
	(*
		@pre: transportText not null
		@post: returns a list
		@post: list has at least one item
	*)
	on createFromTransportText(transportText)
		tell application "OmniFocus"
			with timeout of 3 seconds
			
				return parse tasks into default document with transport text transportText with as single task
			end timeout
		end tell
	end create

	on createInboxTaskWithName(taskName)
		tell application "OmniFocus"
			with timeout of 3 seconds
			
			tell default document
--				tell quick entry
					return make new inbox task with properties {name:taskName}
--				end tell
			end tell
			
			end timeout
		end tell
	end createInboxTaskWithName
	
	on createInboxTaskWithProperties(taskProperties)
		tell application "OmniFocus"
			with timeout of 3 seconds
			
				tell default document
	--				tell quick entry
						return make new inbox task with properties taskProperties
	--				end tell
				end tell
			end timeout
		end tell
	end createInboxTaskWithProperties
	
end script

script ContextRepository
	on create(contextName)
		local newContext
	
		tell application "OmniFocus"
			with timeout of 3 seconds
				tell default document
					set newContext to make new context with properties {name:contextName}
				end tell
			end timeout
		end tell
	
		if newContext is equal to missing value then
			error "Context not created for " & contextName
		end if
		return newContext
	end create

	on createChild(parentContext, contextName)
		local newContext
	
		tell application "OmniFocus"
			with timeout of 3 seconds
			
			tell default document
				set newContext to make new context at parentContext with properties {name:contextName}
			end tell
			
			end timeout
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
			with timeout of 3 seconds
		
			set thePossibleContexts to complete contextName as context maximum matches 1
			if ((count of thePossibleContexts) is equal to 1) then
				set theContextID to id of first item of thePossibleContexts
				set theContext to context id theContextID
			else
				set theContext to missing value
			end if
		end timeout
		end tell
	
		return theContext
	end findByName
end script

script SetContextCommand
	property parent : TaskCommand
	property contextName : missing value
	property name : "Set context"
	
	on execute(aTask)
		set aContext to ContextRepository's findByName(contextName)
		if (aContext is missing value) then 
			error "Context, " & contextName & ", not found"
		else
			log "Found context: " & contextName
		end if

		tell application "OmniFocus"
			with timeout of 3 seconds			
				set aTask's context to aContext
			end timeout
		end tell
	end execute
end script


script ProjectRepository
	on create(projectName)
		local newProject
	
		tell application "OmniFocus"
			with timeout of 3 seconds
			
			tell default document
				set newProject to make new project with properties {name:projectName}
			end tell
		end timeout
		end tell
	
		return newProject
	end create

	on findByName(projectName)
		local theProject
	
		tell front document of application "OmniFocus"
			with timeout of 3 seconds
		
			set thePossibleProjects to complete projectName as project maximum matches 1
			if ((count of thePossibleProjects) is equal to 1) then
				set theProjectID to id of first item of thePossibleProjects
				set theProject to project id theProjectID
			else
				set theProject to missing value
			end if
		end timeout
		end tell
		return theProject
	end findProjectFromName
end script

