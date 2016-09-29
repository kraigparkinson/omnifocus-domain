use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions
use application "OmniFocus"


(*! @abstract <em>[text]</em> OmniFocusDomain's name. *)
property name : "OmniFocusDomain"
(*! @abstract <em>[text]</em> OmniFocusDomain's version. *)
property version : "1.0.0"
(*! @abstract <em>[text]</em> OmniFocusDomain's id. *)
property id : "com.kraigparkinson.OmniFocusDomain"

property textutil : script "com.kraigparkinson/ASText"
property dateutil : script "com.kraigparkinson/ASDate"
property ddd : script "com.kraigparkinson/ASDomainDrivenDesign"
property collections : script "com.kraigparkinson/ASCollections"

property _taskRepository : missing value
property _projectRepository : missing value
property _contextRepository : missing value

script ServiceRegistry
	property serviceMap : collections's makeMap()
	
	on registerService(serviceName, serviceImpl)
		serviceMap's putValue(serviceName, serviceImpl)
	end registerService
	
	on findService(serviceName)
		serviceMap's getValue(serviceName)
	end findService
end script

script TaskEntity
	
	on _assignedContainerValue()
	end _assignedContainerValue
	
	on _containingProjectValue()
	end _containingProjectValue

	on _contextValue()
	end _contextValue

	on _deferDateValue()
	end _deferDateValue

	on _dueDateValue()
	end _dueDateValue

	on _estimatedMinutesValue()
	end _estimatedMinutesValue

	on _flaggedValue()
	end _flaggedValue

	on _noteValue()
	end _noteValue

	on _repetitionRuleValue()
	end _repetitionRuleValue
	
	on _completedValue()
	end _completedValue

	on getName()
	end getName

	on setName(newName)
	end setName

	on isDueOn(aDate)
		_dueDateValue() is aDate
	end isDueOn

	on isDeferredUntil(aDate)
		_deferDateValue() is aDate
	end isDeferredUntil

	on hasDueDate()
		_dueDateValue() is not missing value
	end hasDueDate

	on hasDeferDate()
		_deferDateValue() is not missing value
	end hasDueDate

	on isNotDue()
		not hasDueDate()
	end isNoDue

	on isNotDeferred()
		not hasDeferDate()
	end isNotDeferred

	on dueOn(aDate)
	end dueOn

	on deferUntil(aDate)
	end deferUntil

	on getDueDate()
	end getDueDate

	on getDeferDate()
	end getDeferDate

	on assignToContext(aContext)
	end assignToContext
	
	on isAssignedToAProject()
		return _containingProjectValue() is not missing value		
	end isAssignedToAProject
	
	on assignToProject(aProject)
	end assignToProject

	on hasFlagSet()
		return _flaggedValue()
	end hasFlagSet

	on toggleFlag()
	end toggleFlag

	on setFlag()
	end setFlag

	on clearFlag()
	end clearFlag

	on isRepeating()
	end isRepeating

	on defer(frequency)
	end defer

	on dueAgain(frequency)
	end dueAgain

	on repeatAgain(frequency)
	end dueAgain

	on deferDaily()
		defer("DAILY")
	end deferDaily

	on deferWeekly()
		defer("WEEKLY")
	end deferWeekly

	on deferMonthly()
		defer("MONTHLY")
	end deferMonthly

	on dueAgainDaily()
		dueAgain("DAILY")
	end dueAgainDaily

	on dueAgainWeekly()
		dueAgain("WEEKLY")
	end dueAgainWeekly

	on dueAgainMonthly()
		dueAgain("MONTHLY")
	end dueAgainMonthly

	on repeatDaily()
		repeatAgain("DAILY")
	end repeatDaily

	on repeatWeekly()
		repeatAgain("WEEKLY")
	end repeatWeekly

	on repeatMonthly()
		repeatAgain("MONTHLY")
	end repeatMonthly

	on setEstimate(anEstimate)
	end setEstimate

	on markComplete()
	end markComplete

	on markIncomplete()
	end markIncomplete
	
	on hasBeenCompleted()
		return _completedValue()
	end hasBeenCompleted

	on appendToNote(additionalNoteText)
	end appendToNote

	on hasNote()
		_noteValue() is not missing value and _noteValue() is not ""
	end hasNote

	on hasEstimate()
		_estimateValue() is not missing value
	end hasEstimate	

end script

script TaskFactory
	on create()
		script TaskEntityImpl
			property parent : TaskEntity
			property _name : missing value
			property _assignedContainer : missing value
			property _context : missing value
			property _deferDate : missing value
			property _dueDate : missing value
			property _estimatedMinutes : missing value
			property _note : missing value
			property _flagged : false	
			property _repetitionRule : missing value
			property _completed : missing value
			
			on _completedValue()
				return _completed
			end _completedValue
			
			on _assignedContainerValue()
				_assignedContainer
			end _assignedContainerValue
	
			on _contextValue()
				_context
			end _contextValue
	
			on _deferDateValue()
				_deferDate
			end _deferDateValue
	
			on _dueDateValue()
				_dueDate
			end _dueDateValue
	
			on _estimatedMinutesValue()
				_estimatedMinutes
			end _estimatedMinutesValue
	
			on _flaggedValue()
				_flagged
			end _flaggedValue
	
			on _noteValue()
				_note
			end _noteValue
	
			on _repetitionRuleValue()
				_repetitionRule
			end _repetitionRuleValue

			on getName()
				return _name
			end getName
	
			on setName(newName)
				set _name to newName
			end setName
	
			on isDueOn(aDate)
				_dueDate is aDate
			end isDueOn

			on isDeferredUntil(aDate)
				_deferDateValue is aDate
			end isDeferredUntil
			on hasDueDate()
				_dueDateValue() is not missing value
			end hasDueDate
	
			on hasDeferDate()
				_deferDateValue() is not missing value
			end hasDueDate
	
			on isNotDue()
				not hasDueDate()
			end isNoDue
	
			on isNotDeferred()
				not hasDeferDate()
			end isNotDeferred
	
			on dueOn(aDate)
				set _dueDate to aDate
			end dueOn
	
			on deferUntil(aDate)
				set _deferDate to aDate
			end deferUntil
	
			on getDueDate()
				_deferDate
			end getDueDate
	
			on getDeferDate()
				_dueDate
			end getDeferDate
	
			on assignToContext(aContext)
				set _context to aContext
			end assignToContext
	
			on assignToProject(aProject)
				set _assignedContainer to aProject
			end assignToProject
	
			on hasFlagSet()
				return _flaggedValue()
			end hasFlagSet
	
			on toggleFlag()
			end toggleFlag
	
			on setFlag()
				set _flagged to true
			end setFlag

			on clearFlag()
				set _flagged to false
			end clearFlag
	
			on isRepeating()
				return _repetitionRule is not missing value
			end isRepeating
	
			on defer(frequency)
				using terms from application "OmniFocus"
					set freqString to "FREQ=" & frequency
					set newRepetitionRule to {repetition method:start after completion, recurrence:freqString}	
					set _repetitionRule to newRepetitionRule
				end using terms from
			end defer
	
			on dueAgain(frequency)
				using terms from application "OmniFocus"
					set freqString to "FREQ=" & frequency
					set newRepetitionRule to {repetition method:due after completion, recurrence:freqString}	
					set _repetitionRule to newRepetitionRule
				end using terms from
			end dueAgain
	
			on repeatAgain(frequency)
				using terms from application "OmniFocus"
					set freqString to "FREQ=" & frequency
					set newRepetitionRule to {repetition method:fixed repetition, recurrence:freqString}	
					set _repetitionRule to newRepetitionRule
				end using terms from 
			end dueAgain
	
			on setEstimate(anEstimate)
				set _estimatedMinutes to anEstimate
			end setEstimate
		
			on markComplete()
				set _completed to true
			end markComplete
	
			on markIncomplete()
				set _completed to false
			end markIncomplete
	
			on appendToNote(additionalNoteText)
				if _note is "" then
					set _note to additionalNoteText
				else
					set _note to _note & return & additionalNoteText
				end if
			end appendToNote
	
			on hasNote()
				_noteValue() is not missing value and _noteValue() is not ""
			end hasNote

			on hasEstimate()
				_estimateValue() is not missing value
			end hasEstimate	
	
		end script
		
		return TaskEntityImpl
	end create
end script

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
		aTask's markComplete()
	end execute
end script

script AppendNoteCommand
	property parent : TaskCommand

	on execute(aTask)
		set additionalNoteText to defineNote()
		aTask's appendToNote(additionalNoteText)
	end execute
	
	on defineNote()
		return ""
	end defineNote
end script

script DeferAnotherCommand
	property parent : TaskCommand
	property frequency : missing value
	
	on execute(aTask)
		if frequency is "DAILY" then
			aTask's deferDaily()
		else if frequency is "WEEKLY" then
			aTask's deferWeekly()
		else if frequency is "MONTHLY" then 
			aTask's deferMonthly()
		end
	end execute
end script

script DueAgainCommand
	property parent : TaskCommand
	property frequency : missing value
	
	on execute(aTask)
		if frequency is "DAILY" then
			aTask's dueAgainDaily()
		else if frequency is "WEEKLY" then
			aTask's dueAgainWeekly()
		else if frequency is "MONTHLY" then 
			aTask's dueAgainMonthly()
		end
	end execute	
end script

script RepeatEveryCommand
	property parent : TaskCommand
	property frequency : missing value
	
	on execute(aTask)
		if frequency is "DAILY" then
			aTask's repeatDaily()
		else if frequency is "WEEKLY" then
			aTask's repeatWeekly()
		else if frequency is "MONTHLY" then 
			aTask's repeatMonthly()
		end

	end execute
end script

script FlaggedSpecification
	property parent : ddd's AbstractSpecification
	property name : "flagged"
	
	on isSatisfiedBy(aTask)
		aTask's hasFlagSet()
	end isSatisfiedBy
end script

script TaskHasProjectSpecification
	property parent : ddd's AbstractSpecification
	property name : "has project"
	
	on isSatisfiedBy(obj)
		aTask's isAssignedToAProject() 
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

		aTask's isAssignedToAProject()
	end isSatisfiedBy
end script

script TaskHasContextSpecification
	property parent : ddd's AbstractSpecification
	property name : "has context"

	on isSatisfiedBy(aTask)
		aTask's hasContext()
	end isSatisfiedBy
end script

script ContainsDeferDateSpecification
	property parent : ddd's AbstractSpecification
	property name : "has defer date"
	
	on isSatisfiedBy(aTask)
		aTask's hasDeferDate()
	end isSatisfiedBy
end script

script ContainsDueDateSpecification
	property parent : ddd's AbstractSpecification
	property name : "has due date"
	
	on isSatisfiedBy(aTask)
		aTask's hasDueDate()
	end isSatisfiedBy
end script

script ContainsEstimateSpecification
	property parent : ddd's AbstractSpecification
	property name : "has estimate"
	
	on isSatisfiedBy(aTask)
		aTask's hasEstimate()
	end isSatisfiedBy
end script

script ContainsNoteSpecification
	property parent : ddd's AbstractSpecification
	property name : "has note"
	
	on isSatisfiedBy(aTask)
		return aTask's hasNote()
	end isSatisfiedBy
end script

script MatchingNameTaskSpecification
	property parent : ddd's AbstractSpecification
	property taskName : missing value
	property name : "matches task name"
	
	on isSatisfiedBy(aTask)
		set candidateTaskName to aTask's getName()
		set theResult to ((candidateTaskName) equals taskName)
		return theResult
	end isSatisfiedBy
end script 

script UnparsedTaskSpecification
	property parent : ddd's AbstractSpecification
	property name : "unparsed"
	
	on isSatisfiedBy(aTask)
		return (aTask's getName()) starts with "--"
	end isSatisfiedBy
end script

script NonrepeatingTaskSpecification
	property parent : ddd's AbstractSpecification
	property name : "not repeating"
	
	on isSatisfiedBy(aTask)
		return not aTask's isRepeating()
	end isSatisfiedBy
end script

script TaskRepository
	on addTask(aTask)
	end addTask
	
	on selectUserSpecifiedTasks()
	end selectUserSpecifiedTasks
	
	on addTaskFromTransportText(transportText)
	end addTaskFromTransportText
	
	on removeTask(aTask)
	end removeTask
end script

script RuntimeTaskRepository
	property inboxTasks : { }
	property tasks : { }

	on removeTask(aTask)
		
	end removeTask
	
	on selectUserSpecifiedTasks()
		return tasks
	end selectUserSpecifiedTasks
	
	on selectInboxTasks(spec)		
		set inboxItems to selectAllInboxTasks()
		
		set matchingItems to { }
		
		repeat with currentTask in inboxItems
			if spec's isSatisfiedBy(currentTask) then 
				set matchingItems to matchingItems & { currentTask } 
			end if
		end repeat
		
		return matchingItems
	end selectInboxTasks
	
	on selectAllInboxTasks()
		inboxTasks
	end selectAllInboxTasks

	on selectAll()
		tasks & inboxTasks
	end selectAll
	
	on addTaskFromTransportText(transportText)
		error "Unsupported operation: addTaskFromTransportText"
	end addTaskFromTransportText

	on addTask(aTask)
		set aTask to end of tasks
	end addTask	
end script

script DocumentTaskRepository
	property parent : TaskRepository

	on _makeTaskProxy(aTask)
		if (aTask is missing value) then error "Cannot create TaskProxy with missing value."
	
		script TaskProxy
			property parent : TaskEntity
			property original : aTask
	
			on getName()
				using terms from application "OmniFocus"
					original's name
				end using terms from
			end getName
			
			on _completedValue()
				return original's completed
			end _completedValue
			
			on _containingProjectValue()
				original's containing project
			end _containingProjectValue
	
			on _assignedContainerValue()
				original's assigned container
			end _assignedContainerValue
	
			on _contextValue()
				original's context
			end _contextValue
	
			on _deferDateValue()
				original's defer date 
			end _deferDateValue
	
			on _dueDateValue()
				original's due date
			end _dueDateValue
	
			on _estimatedMinutesValue()
				original's estimated minutes
			end _estimatedMinutesValue
	
			on _flaggedValue()
				original's flagged
			end _flaggedValue
	
			on _noteValue()
				using terms from application "OmniFocus"
					original's note
				end using terms from
			end _noteValue
	
			on _repetitionRuleValue()
				original's repetition rule
			end _repetitionRuleValue
	
			on _estimateValue()
				original's estimated minutes
			end _estimateValue
		
			on setName(newName)
				set original's name to newName
			end setName
	
			on isDueOn(aDate)
				original's due date is aDate
			end isDueOn
	
			on isNotDue()
				original's due date is missing value
			end isNoDue
	
			on dueOn(aDate)
				set original's due date to aDate
			end dueOn
	
			on deferUntil(aDate)
				set original's defer date to aDate
			end deferUntil
	
			on isNotDeferred()
				original's defer date is missing value
			end isNotDeferred
	
			on getDueDate()
				original's defer date
			end getDueDate
	
			on getDeferDate()
				original's due date
			end getDeferDate
	
			on hasAssignedContext()
				using terms from application "OmniFocus"
--					(original's assigned context) is missing value
					(original's context) is not missing value
				end using terms from
			end hasAssignedContext
			
			on hasContext()
				original's context is not missing value
			end hasContext
			
			on assignToContext(aContext)
				set original's context to aContext
			end assignToContext
			
			on isAssignedToAProject()
				return (_containingProjectValue() is not missing value) or ((original's in inbox) and (_assignedContainerValue() is not missing value))		
			end isAssignedToAProject
	
			on assignToProject(aProject)
				using terms from application "OmniFocus"
--					if (original's in inbox) then 
--						set original's assigned container to aProject
--					else 
						move original to end of tasks of aProject
--					end if
				end using terms from
--				set original's project to aProject
			end assignToProject
	
			on toggleFlag()
			end toggleFlag
	
			on setFlag()
				set original's flagged to true
			end setFlag

			on clearFlag()
				set original's flagged to false
			end clearFlag
	
			on isRepeating()
				original's repetition rule is not missing value
			end isRepeating
	
			on defer(frequency)
				using terms from application "OmniFocus"
					set freqString to "FREQ=" & frequency
					set newRepetitionRule to {repetition method:start after completion, recurrence:freqString}	
					set original's repetition rule to newRepetitionRule
				end using terms from
			end defer
	
			on dueAgain(frequency)
				using terms from application "OmniFocus"
					set freqString to "FREQ=" & frequency
					set newRepetitionRule to {repetition method:due after completion, recurrence:freqString}	
					set original's repetition rule to newRepetitionRule
				end using terms from
			end dueAgain
	
			on repeatAgain(frequency)
				using terms from application "OmniFocus"
					set freqString to "FREQ=" & frequency
					set newRepetitionRule to {repetition method:fixed repetition, recurrence:freqString}	
					set original's repetition rule to newRepetitionRule
				end using terms from
			end dueAgain
	
			on setEstimate(anEstimate)
				set original's estimated minutes to anEstimate
			end setEstimate
	
			on markComplete()
				set original's completed to true
			end markComplete
	
			on markIncomplete()
				set original's completed to false
			end markIncomplete
	
			on appendToNote(additionalNoteText)
				using terms from application "OmniFocus"
					if note of original is missing value 
						set the note to additionalNoteText
					else if text of the note of original is "" then
						set the text of the note of original to additionalNoteText
					else
						--Append to existing note
						set the text of the note of original to text of the note of original & return & additionalNoteText
					end if			
				end using terms from
			end appendToNote
	
			on isEqualTo(another)
				original's id is another's id
			end isEqualTo
	
		end script
		
		return TaskProxy
	end _makeTaskProxy
	
	on _wrapList(taskList)
		set proxyTasks to { }
		repeat with aTask in taskList
			set end of proxyTasks to _makeTaskProxy(aTask)
		end repeat
		return proxyTasks
	end _wrapList
	
	on makeTaskBuilder()
		script TaskBuilder
			property _name : missing value
			property _assignedContainer : missing value
			property _context : missing value
			property _deferDate : missing value
			property _dueDate : missing value
			property _estimatedMinutes : missing value
			property _note : missing value
			property _flagged : missing value
		
			on addName(aName)
				set _name to aName 
			end addName
		
			on addProject(aProject)
				set _assignedContainer to aProject
			end addProject
		
			on addContext(aContext)
				set _context to aContext
			end addContext
		
			on addDeferDate(aDeferDate)
				set _deferDate to aDeferDate
			end addContext
		
			on addDueDate(aDueDate)
				set _dueDate to aDueDate
			end addContext
		
			on addEstimatedMinutes(anEstimate)
				set _estimatedMinutes to anEstimate
			end addContext
			
			on addFlagged(aFlag)
				set _flagged to aFlag
			end addFlagged
		
			on addNote(aNote)
				set _note to aNote
			end addContext
			
			on fillTask(aTask)
				using terms from application "OmniFocus"
					if _name is not missing value then set aTask's name to _name
					if _assignedContainer is not missing value then set aTask's assigned container to _assignedContainer
					if _context is not missing value then set aTask's context to _context
					if _deferDate is not missing value then set aTask's defer date to _deferDate
					if _dueDate is not missing value then set aTask's due date to _dueDate
					if _estimatedMinutes is not missing value then set aTask's estimated minutes to _estimatedMinutes
					if _flagged is not missing value then set aTask's flagged to _flagged
					if _note is not missing value then set aTask's note to _note
				end using terms from
			end fillTask
		
		end script
	end makeTaskBuilder
	
	on addTask(aTask)
--		if (aTask's name is "TaskEntity")
		
		set aBuilder to makeTaskBuilder()
		
		aBuilder's addName(aTask's getName())
		aBuilder's addProject(aTask's _assignedContainerValue())
		aBuilder's addContext(aTask's _contextValue())
		aBuilder's addDeferDate(aTask's _deferDateValue())
		aBuilder's addDueDate(aTask's _dueDateValue())
		aBuilder's addEstimatedMinutes(aTask's _estimatedMinutesValue())
		aBuilder's addFlagged(aTask's _flaggedValue())
		aBuilder's addNote(aTask's _noteValue())
		
		tell default document of application "OmniFocus"
			set newTask to (make new inbox task with properties {name:aTask's getName()})
		end tell
		
		aBuilder's fillTask(newTask)
		
		return _makeTaskProxy(newTask) 
--		else if (anEntity's name is "TaskProxy")
--			set original to findById()
--			error "Attempting to save TaskProxy."
--		else 
--			error "Attempting to save unsupported type."
--		end if
	end addTask
	
	on addTaskFromTransportText(transportText)
		_wrapList(parse tasks into default document with transport text transportText with as single task)
	end addTaskFromTransportText
	
	(*
		@pre: transportText not null
		@post: returns a list
		@post: list has at least one item
	*)
	on addAllTasksFromTransportText(transportText)
		_wrapList(parse tasks into default document with transport text transportText)
	end addAllTasksFromTransportText

	on removeTask(aTask)
		delete aTask's original
	end removeTask
	
	-- Returns TaskProxy objects
	on selectUserSpecifiedTasks()
		tell content of first document window of front document of application "OmniFocus"
			return my _wrapList(value of (selected trees where class of its value is not item and class of its value is not folder))
		end tell		
	end selectUserSpecifiedTasks
	
	on selectAllInboxTasks()
		tell front document of application "OmniFocus"
			set inboxItems to every inbox task
			return my _wrapList(inboxItems)
		end tell
	end selectAllInboxTasks

	-- Returns TaskProxy objects
	on selectInboxTasks(spec)
		set inboxItems to selectAllInboxTasks()
		
		set matchingItems to { }
		
		repeat with currentTask in inboxItems
			if spec's isSatisfiedBy(currentTask) then 
				set end of matchingItems to currentTask
			end if
		end repeat
		
		return matchingItems
	end selectInboxTasks
	
	on findById(taskId)
		tell front document of application "OmniFocus"
			set taskList to tasks where id is taskId
			if (count of taskList is greater than 0) then
				set aTask to first item in taskList
				return my _makeTaskProxy(aTask)
			else 
				--Look in inbox tasks next
				set taskList to inbox tasks where id is taskId
				if (count of taskList is greater than 0) then
					set aTask to first item in taskList
					return my _makeTaskProxy(aTask)
				else 
					return missing value
				end if
			end if
		end tell
	end findById
	
	on selectAll()
		tell front document of application "OmniFocus"
			set inboxItems to tasks
			return my _wrapList(inboxItems)
		end tell
	end selectAll
	
	on selectTasksFromProject(aProject)
		local theTasks
		tell application "OmniFocus"
			set theTasks to aProject's tasks
		end tell
		return _wrapList(theTasks)
	end selectTasksFromProject	
end script

script ContextRepository
	on create(contextName)
		local newContext
	
		tell default document of application "OmniFocus"
			set newContext to make new context with properties {name:contextName}
		end tell
	
		if newContext is equal to missing value then
			error "Context not created for " & contextName
		end if
		return newContext
	end create

	on createChild(parentContext, contextName)
		local newContext
	
		tell default document of application "OmniFocus"
			set newContext to make new context at parentContext with properties {name:contextName}
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
	
		tell default document
			set newProject to make new project with properties {name:projectName}
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

on taskRepositoryInstance()
	if _taskRepository is missing value
--		error "_taskRepository is not set.  Please register an instance of the repository first."
		set _taskRepository to DocumentTaskRepository
	end if 
	
	return _taskRepository
end taskRepositoryInstance

on projectRepositoryInstance()
	if _projectRepository is missing value
		error "_projectRepository is not set"
--		set _projectRepository to DocumentProjectRepository
	end if 
	
	return _projectRepository
end projectRepositoryInstance

on contextRepositoryInstance()
	if _contextRepository is missing value
		error "_contextRepository is not set"
--		set _contextRepository to DocumentContextRepository
	end if 
	
	return _contextRepository
end contextRepositoryInstance

script SetContextCommand
	property parent : TaskCommand
	property contextName : missing value
	property name : "Set context"
	
	on execute(aTask)
		set aContext to ContextRepository's findByName(contextName)
		if (aContext is missing value) then 
			error "Context, " & contextName & ", not found"
		end if
		
		log "Command, " & name & ", assigning " & contextName & " to task."
		tell aTask to assignToContext(aContext)
	end execute
end script

script TransportTextParsingService

	script TransportTextInterpreter
		on update(aTask)	
		end update
	end script

	script DefaultInterpreter
		property parent : TransportTextInterpreter
	
		on update(aTask)
			set taskName to aTask's getName()

			if (taskName starts with "--")
				set taskName to ((characters 3 thru -1 of taskName) as string)

				--TODO Refactor this to update the existing task, not add and removeTask
				taskRepositoryInstance()'s addTaskFromTransportText(taskName)
				tell taskRepositoryInstance() to removeTask(aTask)
			end if
			
		end update
	end script

	script CustomInterpreter
		property parent : TransportTextInterpreter
		
		property TASK_DELIM : "--"
		property FLAG_DELIM : "!"
		property PROJECT_DELIM : "::"
		property CONTEXT_DELIM : "@"
		property DATE_DELIM : "#"
		property ESTIMATE_DELIM : "$"
		property NOTE_DELIM : "//"
		
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
	
		on _parseTransportTextIntoVariables(transportText as text)
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
		end _parseTransportTextIntoVariables
		
		script TransportTextExpression
			property expressions : missing value
	
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

			on TaskNameExpression()
				script _TaskNameExpression
					property parent : Expression

					on interpret(aTask, ttVariables)
						set taskNameToken to ttVariables's getValue(TransportTextTokenTypeEnum's NAME_TYPE)
			
						aTask's setName(taskNameToken)

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
				
						aTask's setFlag()
			
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
			
						set aProject to ProjectRepository's findByName(projectToken)
			
						if (aProject is missing value) then 						
							set ttRemainder to "::" & projectToken
						else
							if (not aTask's isAssignedToAProject()) then 
								aTask's assignToProject(aProject)
							end if
						end if
			
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
			
						set aContext to ContextRepository's findByName(contextToken)

						if (aContext is missing value)
							set ttRemainder to "@" & contextToken
						else
							if (not aTask's hasAssignedContext()) then 
								aTask's assignToContext(aContext)
							end if
						end if
			
						return ttRemainder
					end interpret
				end script
				return _ContextNameExpression's makeExpression(TransportTextTokenTypeEnum's CONTEXT_TYPE)

			end ContextNameExpression

			on DueDateExpression()
				script _DueDateExpression
					property parent : Expression
			
					on defaultDueTime()
						return "05:00PM"
					end defaultDueTime
			
					on interpret(aTask, ttVariables)
						set aDueDateExpression to ttVariables's getValue(TransportTextTokenTypeEnum's DUE_DATE_TYPE)
								
						if (aTask's isNotDue()) then 
							set dueDate to parse of (dateutil's CalendarDate) from aDueDateExpression at defaultDueTime()
							aTask's dueOn(dueDate's asDate())
						end if
						return missing value
					end interpret
			
				end script
				return _DueDateExpression's makeExpression(TransportTextTokenTypeEnum's DUE_DATE_TYPE)
			end DueDateExpression

			on DeferDateExpression()
				script _DeferDateExpression
					property parent : Expression

					on defaultDeferTime()
						return "12:00:00AM"
					end defaultDeferTime

					on interpret(aTask, ttVariables)
						set aDeferDateExpression to ttVariables's getValue(TransportTextTokenTypeEnum's DEFER_DATE_TYPE)

						if (aTask's isNotDeferred())
							set deferDate to parse of (dateutil's CalendarDate) from aDeferDateExpression at defaultDeferTime()
				
							aTask's deferUntil(deferDate's asDate())
						end if 
						return missing value
					end interpret
				end script
				return _DeferDateExpression's makeExpression(TransportTextTokenTypeEnum's DEFER_DATE_TYPE)
			end DeferDateExpression

			on EstimateExpression()
				script _EstimateExpression
					property parent : Expression
			
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

					on interpret(aTask, ttVariables)
						set anEstimateExpression to ttVariables's getValue(TransportTextTokenTypeEnum's ESTIMATE_TYPE)
			
						if (ContainsEstimateSpecification's notSpec()'s isSatisfiedBy(aTask))
							aTask's setEstimate(my parseEstimate(anEstimateExpression))
						end if				
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
							property parent : AppendNoteCommand
	
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
		
				if ttRemainders is not missing value then 
					aTask's setName("--" & aTask's getName() & ttRemainders)
				end if 
				tell application "OmniFocus" to compact		
			end interpret
		end script

		script TransportTextEvaluator
			property syntaxTree : TransportTextExpression
	
			on evaluate(aTask, ttVariables)
				tell syntaxTree to interpret(aTask, ttVariables)			
			end evaluate
		end script

		on update(aTask)
			set transportText to aTask's getName()

			set variables to _parseTransportTextIntoVariables(transportText)

			set evaluator to TransportTextEvaluator
			tell evaluator to evaluate(aTask, variables)
		end update
	end script

	property interpreter : CustomInterpreter

	on updateTaskPropertiesFromName(aTask)
		tell interpreter to update(aTask)
	end updateTaskPropertiesFromName
end script





