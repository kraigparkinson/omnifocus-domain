use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

(*!
	@header Test OF Context Repository
		ContextRepository self tests.
	@abstract License: GNU GPL, see COPYING for details.
	@author Kraig Parkinson
	@copyright 2015 kraigparkinson
*)

use dateutil : script "com.kraigparkinson/ASDate"
property ddd : script "com.kraigparkinson/ASDomainDrivenDesign"
use domain : script "com.kraigparkinson/OmniFocusDomain"
use application "OmniFocus"

property parent : script "com.lifepillar/ASUnit"
property suite : makeTestSuite("OmniFocusDomain")


my autorun(suite)

script |TaskFactory|
	property parent : registerFixture(me)

	script |create creates blank shell|
		property parent : registerTestCase(me)
		
		set aTask to domain's TaskFactory's create()
		assertMissing(aTask's getName(), "Name should not be set.")
		assertMissing(aTask's _assignedContainerValue(), "Project should not be set.")
		assertMissing(aTask's _contextValue(), "Context should not be set.")
		assertMissing(aTask's _dueDateValue(), "Due date should not be set.")
		assertMissing(aTask's _deferDateValue(), "Defer date should not be set.")
		assertMissing(aTask's _estimatedMinutesValue(), "Estimated minutes should not be set.")
		refute(aTask's _flaggedValue(), "Flag should not be clear.")
		assertMissing(aTask's _repetitionRuleValue(), "Repetition rule should not be set.")
		assertMissing(aTask's _noteValue(), "Note should not be set.")
		
		aTask's setName("test")
		set aTask to domain's TaskFactory's create()
		assertMissing(aTask's getName(), "Name should not be set.")
		assertMissing(aTask's _assignedContainerValue(), "Project should not be set.")
		assertMissing(aTask's _contextValue(), "Context should not be set.")
		assertMissing(aTask's _dueDateValue(), "Due date should not be set.")
		assertMissing(aTask's _deferDateValue(), "Defer date should not be set.")
		assertMissing(aTask's _estimatedMinutesValue(), "Estimated minutes should not be set.")
		refute(aTask's _flaggedValue(), "Flag should not be clear.")
		assertMissing(aTask's _repetitionRuleValue(), "Repetition rule should not be set.")
		assertMissing(aTask's _noteValue(), "Note should not be set.")
	end script

end script

script |TaskEntityImpl|
	property parent : registerFixture(me)
	
	script |is not due|
		property parent : registerTestCase(me)
		
		set aTask to domain's TaskFactory's create()
		should(aTask's isNotDue(), "Should not be due.")
	end script
	
	script |is due|
		property parent : registerTestCase(me)
		
		set aTask to domain's TaskFactory's create()
		set aDate to date "2001-01-01"
		aTask's dueOn(aDate)
		should(aTask's hasDueDate(), "Should be due.")
	end script
	
	script |is not deferred|
		property parent : registerTestCase(me)
		
		set aTask to domain's TaskFactory's create()
		should(aTask's isNotDeferred(), "Should not be deferred.")
	end script
	
	script |is deferred|
		property parent : registerTestCase(me)
		
		set aTask to domain's TaskFactory's create()
		set aDate to date "2001-01-01"
		aTask's deferUntil(aDate)
		should(aTask's hasDeferDate(), "Should be deferred.")
	end script
end script 

script |TaskProxy|
	property parent : registerFixture(me)
	property taskFixture : missing value
	property projectFixture : missing value
	property contextFixture : missing value
	
	on setUp()
		set expectedTaskName to "Test TaskProxy"
		
		set taskProperties to {name:expectedTaskName}
		try
			tell default document of application "OmniFocus"
				set taskFixture to (make new inbox task with properties taskProperties)
			end tell
		on error errMsg number errNum
			log "Error creating task: " & errMsg & errNum & taskFixture
			error errMsg number errNum
		end try
		
		set projectFixture to missing value
		set contextFixture to missing value
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			try
				delete taskFixture
			on error errMsg number errNum
				log "Error deleting task: " & errMsg & errNum & taskFixture
				error errMsg number errNum
			end try
			try
				if projectFixture is not missing value then delete projectFixture
			on error errMsg number errNum
				log "Error deleting project: " & errMsg & errNum
				error errMsg number errNum
			end try
			try
				if contextFixture is not missing value then delete contextFixture
			on error errMsg number errNum
				log "Error deleting context: " & errMsg & errNum
				error errMsg number errNum
			end try
		end tell
	end tearDown

	script |create returns wrapped task|
		property parent : registerTestCase(me)
		
		set aTask to domain's DocumentTaskRepository's _makeTaskProxy(taskFixture)
		assertEqual(taskFixture, aTask's original)
		assertEQual(taskFixture's name, aTask's getName())
	end script
		
	script |is not due|
		property parent : registerTestCase(me)
		
		set aTask to domain's DocumentTaskRepository's _makeTaskProxy(taskFixture)
		should(aTask's isNotDue(), "Should not be due.")
	end script
	
	script |is due|
		property parent : registerTestCase(me)
		
		set aTask to domain's DocumentTaskRepository's _makeTaskProxy(taskFixture)
		set aDate to date "2001-01-01"
		aTask's dueOn(aDate)
		should(aTask's hasDueDate(), "Should be due.")
	end script
	
	script |is not deferred|
		property parent : registerTestCase(me)
		
		set aTask to domain's DocumentTaskRepository's _makeTaskProxy(taskFixture)
		should(aTask's isNotDeferred(), "Should not be deferred.")
	end script
	
	script |is deferred|
		property parent : registerTestCase(me)
		
		set aTask to domain's DocumentTaskRepository's _makeTaskProxy(taskFixture)
		set aDate to date "2001-01-01"
		aTask's deferUntil(aDate)
		should(aTask's hasDeferDate(), "Should be deferred.")
	end script
	
	script |should not assign a task to project by default|
		property parent : registerTestCase(me)

		set aTask to domain's DocumentTaskRepository's _makeTaskProxy(taskFixture)
		assertMissing(aTask's _containingProjectValue())
		refute(aTask's isAssignedToAProject(), "Task should not appear to be assigned to a project.")
	end script

	script |should assign task to project in inbox based on assigned container|
		property parent : registerTestCase(me)

		set aTask to domain's DocumentTaskRepository's _makeTaskProxy(taskFixture)
		set projectFixture to domain's ProjectRepository's create("Test Task Proxy – Assigns Task to Project with Context")
		aTask's assignToProject(projectFixture)

		assert(aTask's isAssignedToAProject(), "Task should appear to be assigned to a project before compacting.")
		assert(projectFixture is aTask's _assignedContainerValue(), "Assigned container should be set to project fixture.")
		assert(aTask's _containingProjectValue() is missing value, "Containing project value should not be set while not compacted.")
		
		--Local settings may change, so adding a context to the task so that compact will be guaranteed to clean up the task all the way.
		set contextFixture to domain's ContextRepository's create("Test Task Proxy - Assigned Task to Project")
		aTask's assignToContext(contextFixture)
		
		tell application "OmniFocus" to compact default document
		
		using terms from application "OmniFocus"
			my refute(aTask's original is in inbox, "Task should no longer be in inbox once project and context assigned and compacted.")
		end using terms from
		should(aTask's isAssignedToAProject(), "Task should appear to be assigned to a project after compacting.")
		assertEqual(projectFixture, aTask's _containingProjectValue())		
	end script	
	
end script 

script |TaskRepository Fixture|
    property parent : makeFixture()
	property lastRepo : missing value
	
	on setUp()
		set lastRepo to domain's _taskRepository
		set domain's _taskRepository to domain's RuntimeTaskRepository		
	end setUp
	
	on tearDown()
		set domain's _taskRepository to lastRepo
	end tearDown
end script

script |NonrepeatingTaskSpecification|
	property parent : registerFixture(me)
	
	script |specification passes without repetition rule set|
		property parent : registerTestCase(me)
		
		set aTask to domain's TaskFactory's create()
		aTask's setName("Foo")
		
		set aSpec to domain's NonrepeatingTaskSpecification
		
		assert(aSpec's isSatisfiedBy(aTask), "Inbox task should not have a repetition rule.")		
	end script

	script |specification fails with repetition rule set|
		property parent : registerTestCase(me)
		
		set aTask to domain's TaskFactory's create()
		aTask's setName("Foo")
		aTask's deferDaily()
		
		set aSpec to domain's NonrepeatingTaskSpecification
		
		refute(aSpec's isSatisfiedBy(aTask), "Should have a repetition rule now.")
	end script
end script  


script |DeferDailyRuleCommand|
	property parent : registerFixture(me)
	
	on setUp()
	end setUp
	
	on tearDown()
	end tearDown
	
	script |test daily defer works|
		property parent : registerTestCase(me)
	
		set aTask to domain's TaskFactory's create()
		aTask's setName("Foo")
		
		set aCommand to domain's makeDeferAnotherCommand("DAILY")
		
		tell aCommand to execute(aTask)

		using terms from application "OmniFocus"
			my assert(aTask's isRepeating(), "Task should now be repeating.")
			set expectedRepetitionRule to {repetition method:start after completion, recurrence:"FREQ=DAILY"}
			my assertEqual(expectedRepetitionRule, aTask's _repetitionRule)
		end using terms from
	end script
	
	script |test weekly defer works|
		property parent : registerTestCase(me)
	
		set aTask to domain's TaskFactory's create()
		aTask's setName("Foo")
		
		set aCommand to domain's makeDeferAnotherCommand("WEEKLY")
		
		tell aCommand to execute(aTask)
		
		tell application "OmniFocus"
			my assert(aTask's isRepeating(), "Task should now be repeating.")
			set expectedRepetitionRule to {repetition method:start after completion, recurrence:"FREQ=WEEKLY"}
			my assertEqual(expectedRepetitionRule, aTask's _repetitionRule)
		end tell
	end script
	
end script  


script |DueAgainCommand|
	property parent : registerFixture(me)
	
	on setUp()
	end setUp
	
	on tearDown()
	end tearDown
	
	script |test due again daily works|
		property parent : registerTestCase(me)
	
		set aTask to domain's TaskFactory's create()
		aTask's setName("Foo")
	
		set aCommand to domain's makeDueAgainCommand("DAILY")
		
		tell aCommand to execute(aTask)
		
		tell application "OmniFocus"
			my assert(aTask's isRepeating(), "Task should now be repeating.")
			set expectedRepetitionRule to {repetition method:due after completion, recurrence:"FREQ=DAILY"}
			my assertEqual(expectedRepetitionRule, aTask's _repetitionRule)
		end tell
	end script
	
	script |test due again weekly works|
		property parent : registerTestCase(me)
	
		set aTask to domain's TaskFactory's create()
		aTask's setName("Foo")
	
		set aCommand to domain's makeDueAgainCommand("WEEKLY")
		
		tell aCommand to execute(aTask)
		
		tell application "OmniFocus"
			my assert(aTask's isRepeating(), "Task should now be repeating.")
			set expectedRepetitionRule to {repetition method:due after completion, recurrence:"FREQ=WEEKLY"}
			my assertEqual(expectedRepetitionRule, aTask's _repetitionRule)
		end tell
	end script
	
end script  


script |RepeatEveryPeriodCommand|
	property parent : registerFixture(me)
	
	on setUp()
	end setUp
	
	on tearDown()
	end tearDown
	
	script |repeat daily|
		property parent : registerTestCase(me)
	
		set aTask to domain's TaskFactory's create()
		aTask's setName("Foo")
	
		set aCommand to domain's makeRepeatEveryCommand("DAILY")
		
		tell aCommand to execute(aTask)
		
		tell application "OmniFocus"
			my assert(aTask's isRepeating(), "Should now be repeating.")
			set expectedRepetitionRule to {repetition method:fixed repetition, recurrence:"FREQ=DAILY"}
			my assertEqual(expectedRepetitionRule, aTask's _repetitionRule)
		end tell
	end script
	
	script |repeat weekly|
		property parent : registerTestCase(me)
	
		set aTask to domain's TaskFactory's create()
		aTask's setName("Foo")

		set aCommand to domain's makeRepeatEveryCommand("WEEKLY")
		
		tell aCommand to execute(aTask)
		
		tell application "OmniFocus"
			my assert(aTask's isRepeating(), "Should now be repeating.")
			set expectedRepetitionRule to {repetition method:fixed repetition, recurrence:"FREQ=WEEKLY"}
			my assertEqual(expectedRepetitionRule, aTask's _repetitionRule)
		end tell
	end script
	
end script  

script |Specification Fixture|
	property parent : makeFixture()
	
	on testSpecification(aSpec, aTask)
		should(aSpec's isSatisfiedBy(aTask), "Spec should be satisfied.")
	end testSpecification
end script

script |MatchingNameTaskSpecification|
	property parent : registerFixtureOfKind(me, |Specification Fixture|)
	
	script |satisfied when name is identical|
		property parent : registerTestCase(me)

		set expectedTaskName to "Test Matching Name Specification Test"
		set aTask to domain's TaskFactory's create()
		aTask's setName(expectedTaskName)

		set aSpec to domain's MatchingNameTaskSpecification
		set taskName of aSpec to expectedTaskName

		testSpecification(aSpec, aTask)
--		should(aSpec's isSatisfiedBy(aTask), "Spec should be satisfied.")
	end script 
end script

script |UnparsedTaskSpecification|
	property parent : registerFixture(me)

	script |satisfied when task name has token|
		property parent : registerTestCase(me)

		set aTask to domain's TaskFactory's create()
		aTask's setName("--Unparsed Name Specification Test (Unparsed)")

		set aSpec to domain's UnparsedTaskSpecification

		should(aSpec's isSatisfiedBy(aTask), "Spec should be satisfied.")
	end script 	
	
	script |not satisfied when task name does not have token|
		property parent : registerTestCase(me)

		set aTask to domain's TaskFactory's create()
		aTask's setName("Unparsed Name Specification Test (Parsed)")

		set aSpec to domain's UnparsedTaskSpecification

		shouldnt(aSpec's isSatisfiedBy(aTask), "Spec should not be satisfied.")
	end script 	
end script



script |DocumentProjectRepository|
	property PROJECT_FIXTURE_NAME : "Test DocumentProjectRepository"
	property parent : registerFixture(me)
	property projectList : {}
	
	on setUp()
		set projectList to {}
	end setUp
	
	on tearDown()
		repeat with aProject in projectList
			tell application "OmniFocus" to delete aProject
		end repeat
	end tearDown
	
	on createProject(projectName)
		set newProject to domain's ProjectRepository's create(PROJECT_FIXTURE_NAME)
		set projectList to projectList & {newProject}
		return newProject
	end createProject
	
	script |create project with name|
		property parent : registerTestCase(me)
		
		set testProject to createProject(PROJECT_FIXTURE_NAME)
		
		tell application "OmniFocus"
			my shouldEqual(PROJECT_FIXTURE_NAME, name of testProject)
		end tell
	end script

	script |find existing project with name|
		property parent : registerTestCase(me)
		
		set testProject to createProject(PROJECT_FIXTURE_NAME)
		
		set foundProject to domain's ProjectRepository's findByName(PROJECT_FIXTURE_NAME)
		
		tell application "OmniFocus"
			my shouldEqual(PROJECT_FIXTURE_NAME, name of testProject)
			my shouldEqual(testProject, foundProject)
		end tell		
	end script
	
	script |find non-existing project returns missing value|
		property parent : registerTestCase(me)
				
		shouldEqual(missing value, domain's ProjectRepository's findByName("Test Find non-existing project"))
	end script
end script

script |DocumentTaskRepository|
	property PROJECT_FIXTURE_NAME : "Test" & space & "DocumentTaskRepository" & space & "(Project)"
	property CONTEXT_FIXTURE_NAME : "Test DocumentTaskRepository (Context)"
	property parent : registerFixture(me)
	property taskList : {}
	property contextFixture : missing value
	property contextList : {}
	property projectFixture : missing value
	property projectList : {}
	
	on setUp()
		set taskList to {}
		
		set contextFixture to domain's ContextRepository's create(CONTEXT_FIXTURE_NAME)
		set contextList to { contextFixture }
		set projectFixture to domain's ProjectRepository's create(PROJECT_FIXTURE_NAME)
		set projectList to { projectFixture }
	end setUp
	
	on addTaskToFixture(aTask)
		set end of taskList to aTask
--		set taskList to taskList & { aTask }		
	end addTaskToFixture
	
	on tearDown()
		set errorList to { }
		
		repeat with aTask in taskList
			tell application "OmniFocus"
				try
					delete aTask's original
				on error errMsg number errNum
					set end of errorList to errMsg
					log "Error deleting task: " & errMsg & errNum
				end try
			end tell
		end repeat
		
		repeat with aContext in contextList
			tell application "OmniFocus"
				try
					tell default document to delete aContext
				on error errMsg number errNum
					log "Error deleting context: " & errMsg & errNum
					set end of errorList to errMsg
				end try
			end tell
		end repeat
		repeat with aProject in projectList
			tell application "OmniFocus"
				try
					tell default document to delete aProject
				on error errMsg number errNum
					log "Error deleting project: " & errMsg & errNum
					set end of errorList to errMsg
				end try
			end tell
		end repeat
		
		if count of errorList > 0 then error errorList
	end tearDown
	
	script |_makeTaskProxy places OF task into TaskProxy|
		property parent : registerTestCase(me)
		set expectedTaskName to "Test wrap places OF task into TaskProxy"

		set expectedDeferDate to date "2009-01-02"
		set expectedDueDate to date "2009-05-31"
		
		tell default document of application "OmniFocus"
			set taskProperties to {name:expectedTaskName, assigned container:projectFixture, context:contextFixture, defer date:expectedDeferDate, due date:expectedDueDate, estimated minutes:10, flagged:true, note:"A great note."}
			set aTask to make new inbox task with properties taskProperties
			set aTask to domain's DocumentTaskRepository's _makeTaskProxy(aTask)
		end tell
		
		addTaskToFixture(aTask)
		
		assertEqual(expectedTaskName, aTask's getName())
		assertEqual(projectFixture, aTask's _assignedContainerValue())
		assertEqual(contextFixture, aTask's _contextValue())
		assertEqual(expectedDeferDate, aTask's _deferDateValue())
		assertEqual(expectedDueDate, aTask's _dueDateValue())
		should(aTask's _flaggedValue(), "Should be flagged")
		assertEqual(10, aTask's _estimatedMinutesValue())
		assertEqual(aTask's _noteValue(), "A great note.")
	end script
	
	script |select all inbox tasks returns a list|
		property parent : registerTestCase(me)
		
		set allTasks to domain's DocumentTaskRepository's selectAllInboxTasks()
		
		refuteMissing(allTasks, "Should be a list, even a zero-length one.")
	end script
	
	script |select selected inbox tasks|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "Test select selected inbox tasks"
		
		set aTask to domain's TaskFactory's create()
		aTask's setName(expectedTaskName)
		
		set aTask to domain's DocumentTaskRepository's addTask(aTask)
		addTaskToFixture(aTask)
		
		set aSpec to domain's MatchingNameTaskSpecification
		set taskName of aSpec to expectedTaskName
		
		set actualTasks to domain's DocumentTaskRepository's selectInboxTasks(aSpec)
		
		shouldEqual(1, count of actualTasks)
		
		tell application "OmniFocus"
			set actualTask to first item of actualTasks
			my shouldEqual(aTask's original's id, actualTask's original's id)
			my shouldEqual(expectedTaskName, actualTask's getName())
		end tell		
	end script
	
	script |add preserves values as provided|
		property parent : registerTestCase(me)
		
		set expectedDueDate to dateutil's CalendarDateFactory's (today at "5:00pm")'s asDate()
		set expectedDeferDate to dateutil's CalendarDateFactory's (yesterday at "12:00pm")'s asDate()
		
		set aTask to domain's TaskFactory's create()
		set aTask's _name to "Test add preserves values as provided"
		set aTask's _assignedContainer to projectFixture
		set aTask's _context to contextFixture
		set aTask's _deferDate to expectedDeferDate
		set aTask's _dueDate to expectedDueDate
		set aTask's _estimatedMinutes to 10
		set aTask's _note to "This is a note"
		set aTask's _flagged to true
		set aTask to domain's DocumentTaskRepository's addTask(aTask)
		addTaskToFixture(aTask)

		assertEqual("Test add preserves values as provided", aTask's getName())
		assertEqual(projectFixture, aTask's _assignedContainerValue())
		assertEQual(contextFixture, aTask's _contextValue())
		assertEqual(expectedDeferDate, aTask's _deferDateValue())
		assertEqual(expectedDueDate, aTask's _dueDateValue())
		assertEqual(10, aTask's _estimatedMinutesValue())
		assertEqual(true, aTask's _flaggedValue())
		assertEqual("This is a note", aTask's _noteValue()'s text)
	end script
			
	script |create task with transport text|
		property parent : registerTestCase(me)
	
		set expectedTaskName to "Test create tasks with transport text"
		set expectedDueDate to dateutil's CalendarDateFactory's (today at "5:00pm")'s asDate()
		set expectedDeferDate to dateutil's CalendarDateFactory's (yesterday at "12:00pm")'s asDate()
		set expectedNote to "A note."
		
		set transportText to expectedTaskName & "! ::" & PROJECT_FIXTURE_NAME & " @" & CONTEXT_FIXTURE_NAME & " $5m" & " //" & expectedNote
		
		set newTaskList to domain's DocumentTaskRepository's addTaskFromTransportText(transportText)
		
		should(count of newTaskList is 1, "Should have one task from adding task via transport text") 
		
		set myTask to first item in newTaskList		
		addTaskToFixture(myTask)
		shouldEqual(expectedTaskName, myTask's getName())
		shouldEqual(projectFixture, myTask's _containingProjectValue())
		shouldEqual(contextFixture, myTask's _contextValue())
--		shouldEqual(expectedDeferDate, myTask's _deferDateValue())	
--		shouldEqual(expectedDueDate, myTask's _dueDateValue())
		shouldEqual(5, myTask's _estimatedMinutesValue())
		shouldEqual(expectedNote, myTask's _noteValue())
	end script 
	
	script |findById returns existing tasks that match id|
		property parent : registerTestCase(me)
		
		set aTask to domain's TaskFactory's create()
		tell aTask to setName("Test findById")
		set aTask to domain's DocumentTaskRepository's addTask(aTask)
		addTaskToFixture(aTask)
			
		local taskId
		using terms from application "OmniFocus"
			set expectedTaskId to aTask's original's id
			set actualTask to domain's DocumentTaskRepository's findById(expectedTaskId)
			set actualTaskId to actualTask's original's id
		end using terms from
		
		assertEqual(expectedTaskId, actualTaskId)
--		assertEqual(aTask, actualTask)
	end script

	script |findById returns missing value for no match|
		property parent : registerTestCase(me)
				
		assertMissing(domain's DocumentTaskRepository's findById("gibberish"), "Should not have found a task with 'gibberish' as id.")
	end script
	
	script |removeTask deletes task from document|
		property parent : registerTestCase(me)
		
		set aTask to domain's TaskFactory's create()
		tell aTask to setName("Test removeTask deletes task from document")
		set aTask to domain's DocumentTaskRepository's addTask(aTask)
			
		local taskId
		using terms from application "OmniFocus"
			set taskId to aTask's original's id
		end using terms from

		tell domain's DocumentTaskRepository to removeTask(aTask)

		assertMissing(domain's DocumentTaskRepository's findById(taskId), "Should not have found such a task")
	end script
end script

script |ContextRepository|
	property parent : registerFixture(me)
	property contextList : {}
	
	on setUp()
		set contextList to {}
	end setUp
	
	on tearDown()
		repeat with aContext in contextList
			tell front document of application "OmniFocus"
				delete aContext
			end tell
		end repeat
	end tearDown
	
	on addToContextList(aContext)
		tell application "OmniFocus"
			if aContext is equal to missing value then
				fail("Tried to add a missing value")
			else
				set contextList to contextList & {aContext}
			end if
		end tell
	end addToContextList
	
	on createContext(contextName)
		set newContext to domain's ContextRepository's create(contextName)
		addToContextList(newContext)
		return newContext
	end createContext
	
	script |create context with name|
		property parent : registerTestCase(me)
		
		set testContext to createContext("Test Context")
		
		tell application "OmniFocus"
			my shouldEqual("Test Context", name of testContext)
		end tell
	end script
	
	
	script |create and find child context|
		property parent : registerTestCase(me)
		
		set testParentContext to createContext("Test Parent Context")
		set testChildContext to domain's ContextRepository's createChild(testParentContext, "Test Child Context")
		--addToContextList(testChildContext)
		
		tell application "OmniFocus"
			my shouldEqual("Test Child Context", name of testChildContext)
			my shouldEqual("Test Parent Context", name of container of testChildContext)
		end tell
	end script
	
	
	script |find existing context|
		property parent : registerTestCase(me)
		
		set myContext to createContext("Findable Context")
		
		tell domain's ContextRepository
			set actualContext to findByName("Findable Context")
			my shouldEqual(myContext, actualContext)
		end tell
	end script
	
	script |don't find non-existing context|
		property parent : registerTestCase(me)
		
		tell domain's ContextRepository
			my shouldEqual(missing value, findByName("Nonexistent Test Context"))
		end tell
	end script
		
	script |find context from partially qualified name|
		property parent : registerTestCase(me)
		
		createContext("Test Context")
		
		set testParentContext to createContext("Test Parent Context")
		set testChildContext to domain's ContextRepository's createChild(testParentContext, "Test Child Context")
		--addToContextList(testChildContext)
		
		tell domain's ContextRepository
			my should(findByName("Child Context") is not missing value, "Couldn't find partially qualified, nested context.")
			my should(findByName("Test Child Context") is not missing value, "Couldn't find partially qualified, nested context.")
			my should(findByName("est Context") is not missing value, "Couldn't find partially qualified, top-level solo context.")
			my should(findByName("Parent Context") is not missing value, "Couldn't find partially qualified, top-level parent context.")
		end tell
		
	end script
	
	script |find context from fully qualified name of solo context|
		property parent : registerTestCase(me)
		
		local myContext
		
		set testContext to createContext("Test Context")
		
		tell domain's ContextRepository
			my shouldEqual(testContext, findByName("Test Context"))	
		end tell
		
	end script

	script |find context from fully qualified name of nested context|
		property parent : registerTestCase(me)
		
		set testParentContext to createContext("Test Parent Context")
		set testChildContext to domain's ContextRepository's createChild(testParentContext, "Test Child Context")
		
		tell domain's ContextRepository
			set actualChildContext to findByName("Test Parent Context:Test Child Context")
			my shouldEqual(testChildContext, actualChildContext)
			
			tell application "OmniFocus"
				my shouldEqual(testParentContext, container of actualChildContext)
			end tell
		end tell
		
	end script

	
end script