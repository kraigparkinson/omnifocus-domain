(*!
	@header Test OF Context Repository
		ContextRepository self tests.
	@abstract License: GNU GPL, see COPYING for details.
	@author Kraig Parkinson
	@copyright 2015 kraigparkinson
*)

property dateutil : script "com.kraigparkinson/ASDate"
property ddd : script "com.kraigparkinson/ASDomainDrivenDesign"
property domain : script "com.kraigparkinson/OmniFocusDomain"

property parent : script "com.lifepillar/ASUnit"
property suite : makeTestSuite("OmniFocusDomain")


my autorun(suite)

script |NonrepeatingTaskSpecification|
	property parent : TestSet(me)
	property taskList : missing value
	
	on setUp()
		set taskList to { }
	end setUp
	
	on tearDown()
		repeat with aTask in taskList
			tell application "OmniFocus"
				try
					delete aTask
				on error errMsg number errNum
					log "Error deleting task: " & errMsg & errNum & aTask
					error errMsg number errNum
				end try
			end tell
		end repeat
	end tearDown
	
	on createInboxTask(transportText)
		set newTask to domain's TaskRepository's createInboxTaskWithName(transportText)
		set end of taskList to newTask		
		return newTask 
	end createInboxTask
	
	script |test specification works|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("Foo")
		set aSpec to domain's NonrepeatingTaskSpecification
		
		assert(aSpec's isSatisfiedBy(aTask), "Inbox task should not have a repetition rule.")		
		
		tell application "OmniFocus"
			set aTask's repetition rule to {repetition method:start after completion, recurrence:"FREQ=DAILY"}
		end tell
		refute(aSpec's isSatisfiedBy(aTask), "Should have a repetition rule now.")
	end script
end script  


script |DeferDailyRuleCommand|
	property parent : TestSet(me)
	property taskList : missing value
	
	on setUp()
		set taskList to { }
	end setUp
	
	on tearDown()
		repeat with aTask in taskList
			tell application "OmniFocus"
				try
					delete aTask
				on error errMsg number errNum
					log "Error deleting task: " & errMsg & errNum & aTask
					error errMsg number errNum
				end try
			end tell
		end repeat
	end tearDown
	
	on createInboxTask(transportText)
		set newTask to domain's TaskRepository's createInboxTaskWithName(transportText)
		set end of taskList to newTask		
		return newTask 
	end createInboxTask

	script |test daily defer works|
		property parent : UnitTest(me)
	
		set aTask to createInboxTask("Foo")
		set aCommand to domain's DeferAnotherCommand's constructCommand()
		set aCommand's frequency to "DAILY"
		
		tell aCommand to execute(aTask)
		
		tell application "OmniFocus"
			my assertNotEqual(missing value, aTask's repetition rule)
			set expectedRepetitionRule to {repetition method:start after completion, recurrence:"FREQ=DAILY"}
			my assertEqual(expectedRepetitionRule, aTask's repetition rule)
			
--			my assertEqual("FREQ=DAILY", aTask's repetition rule's recurrence as text)
--			my assert(start after completion is aTask's repetition rule's repetition method, "Should start after completion")
		end tell
	end script
	
	script |test weekly defer works|
		property parent : UnitTest(me)
	
		set aTask to createInboxTask("Foo")
		set aCommand to domain's DeferAnotherCommand's constructCommand()
		set aCommand's frequency to "WEEKLY"
		
		tell aCommand to execute(aTask)
		
		tell application "OmniFocus"
			my assertNotEqual(missing value, aTask's repetition rule)
			set expectedRepetitionRule to {repetition method:start after completion, recurrence:"FREQ=WEEKLY"}
			my assertEqual(expectedRepetitionRule, aTask's repetition rule)
--			my assertEqual("FREQ=WEEKLY", aTask's repetition rule's recurrence as text)
--			my assert(start after completion is aTask's repetition rule's repetition method, "Should start after completion")
		end tell
	end script
	
end script  


script |DueAgainCommand|
	property parent : TestSet(me)
	property taskList : missing value
	
	on setUp()
		set taskList to { }
	end setUp
	
	on tearDown()
		repeat with aTask in taskList
			tell application "OmniFocus"
				try
					delete aTask
				on error errMsg number errNum
					log "Error deleting task: " & errMsg & errNum & aTask
					error errMsg number errNum
				end try
			end tell
		end repeat
	end tearDown
	
	on createInboxTask(transportText)
		set newTask to domain's TaskRepository's createInboxTaskWithName(transportText)
		set end of taskList to newTask		
		return newTask 
	end createInboxTask

	script |test due again daily works|
		property parent : UnitTest(me)
	
		set aTask to createInboxTask("Foo")
		set aCommand to domain's DueAgainCommand's constructCommand()
		set aCommand's frequency to "DAILY"
		
		tell aCommand to execute(aTask)
		
		tell application "OmniFocus"
			my assertNotEqual(missing value, aTask's repetition rule)
			set expectedRepetitionRule to {repetition method:due after completion, recurrence:"FREQ=DAILY"}
			my assertEqual(expectedRepetitionRule, aTask's repetition rule)
		end tell
	end script
	
	script |test due again weekly works|
		property parent : UnitTest(me)
	
		set aTask to createInboxTask("Foo")
		set aCommand to domain's DueAgainCommand's constructCommand()
		set aCommand's frequency to "WEEKLY"
		
		tell aCommand to execute(aTask)
		
		tell application "OmniFocus"
			my assertNotEqual(missing value, aTask's repetition rule)
			set expectedRepetitionRule to {repetition method:due after completion, recurrence:"FREQ=WEEKLY"}
			my assertEqual(expectedRepetitionRule, aTask's repetition rule)
		end tell
	end script
	
end script  


script |RepeatEveryPeriodCommand|
	property parent : TestSet(me)
	property taskList : missing value
	
	on setUp()
		set taskList to { }
	end setUp
	
	on tearDown()
		repeat with aTask in taskList
			tell application "OmniFocus"
				try
					delete aTask
				on error errMsg number errNum
					log "Error deleting task: " & errMsg & errNum & aTask
					error errMsg number errNum
				end try
			end tell
		end repeat
	end tearDown
	
	on createInboxTask(transportText)
		set newTask to domain's TaskRepository's createInboxTaskWithName(transportText)
		set end of taskList to newTask		
		return newTask 
	end createInboxTask

	script |repeat daily|
		property parent : UnitTest(me)
	
		set aTask to createInboxTask("Foo")
		set aCommand to domain's RepeatEveryCommand's constructCommand()
		set aCommand's frequency to "DAILY"
		
		tell aCommand to execute(aTask)
		
		tell application "OmniFocus"
			my assertNotEqual(missing value, aTask's repetition rule)
			set expectedRepetitionRule to {repetition method:fixed repetition, recurrence:"FREQ=DAILY"}
			my assertEqual(expectedRepetitionRule, aTask's repetition rule)
		end tell
	end script
	
	script |repeat weekly|
		property parent : UnitTest(me)
	
		set aTask to createInboxTask("Foo")
		set aCommand to domain's RepeatEveryCommand's constructCommand()
		set aCommand's frequency to "WEEKLY"
		
		tell aCommand to execute(aTask)
		
		tell application "OmniFocus"
			my assertNotEqual(missing value, aTask's repetition rule)
			set expectedRepetitionRule to {repetition method:fixed repetition, recurrence:"FREQ=WEEKLY"}
			my assertEqual(expectedRepetitionRule, aTask's repetition rule)
		end tell
	end script
	
end script  

script |OmniFocus Project Repository|
	property parent : TestSet(me)
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
		set newProject to domain's ProjectRepository's create(projectName)
		set projectList to projectList & {newProject}
		return newProject
	end createProject
	
	script |create project with name|
		property parent : UnitTest(me)
		
		set testProject to createProject("Test Project")
		
		tell application "OmniFocus"
			my shouldEqual("Test Project", name of testProject)
		end tell
	end script

	script |find existing project with name|
		property parent : UnitTest(me)
		
		set projectName to "Test Project"
		set testProject to createProject(projectName)
		
		set foundProject to domain's ProjectRepository's findByName(projectName)
		
		tell application "OmniFocus"
			my shouldEqual("Test Project", name of testProject)
			my shouldEqual(testProject, foundProject)
		end tell
		
		shouldEqual(missing value, domain's ProjectRepository's findByName("asdfghjkl;"))
	end script
	
	
end script


script |OmniFocus Task Repository|
	property parent : TestSet(me)
	property taskList : {}
	property contextFixture : missing value
	property contextList : {}
	property projectFixture : missing value
	property projectList : {}
	
	on setUp()
		set taskList to {}
		
		set contextFixture to domain's ContextRepository's create("Test Context")
		set contextList to { contextFixture }
		set projectFixture to domain's ProjectRepository's create("1 Test Project")
		set projectList to { projectFixture }
	end setUp
	
	on tearDown()
		repeat with aTask in taskList
			tell application "OmniFocus"
				try
					delete aTask
				on error errMsg number errNum
					log "Error deleting task: " & errMsg & errNum & aTask
					error errMsg number errNum
				end try
			end tell
		end repeat
		repeat with aContext in contextList
			tell application "OmniFocus"
				try
					tell default document to delete aContext
				on error errMsg number errNum
					log "Error deleting context: " & errMsg & errNum & aContext
					error errMsg number errNum
				end try
			end tell
		end repeat
		repeat with aProject in projectList
			tell application "OmniFocus"
				try
					tell default document to delete aProject
				on error errMsg number errNum
					log "Error deleting project: " & errMsg & errNum & aProject
					error errMsg number errNum
				end try
			end tell
		end repeat
	end tearDown
	
	on createTaskWithTaskName(taskName)
		set newTask to domain's TaskRepository's createInboxTaskWithName(taskName)
		set taskList to taskList & {newTask}		
		return newTask
	end createTaskWithTaskName

	on createTaskWithProperties(taskProperties)
		set newTask to domain's TaskRepository's createInboxTaskWithProperties(taskProperties)
		set taskList to taskList & {newTask}		
		return newTask
	end createTaskWithTaskName
	
	on createTaskWithTransportText(transportText)
		set newTaskList to domain's TaskRepository's createFromTransportText(transportText)
		
		set taskList to taskList & {newTaskList}
		
		shouldEqual(1, length of newTaskList)
		set newTask to first item in newTaskList

		return newTask
	end createTask
	
	script |matching name specification|
		property parent : UnitTest(me)
	
		set expectedTaskName to "Matching Name Specification Test"
		set expectedTask to createTaskWithTaskName(expectedTaskName)
		
		set aSpec to domain's MatchingNameTaskSpecification
		set aName of aSpec to expectedTaskName

		tell application "OmniFocus"
			my shouldEqual(expectedTaskName, name of expectedTask)
		end tell
		
		should(aSpec's isSatisfiedBy(expectedTask), "Spec should be satisfied.")
	end script 
	
	script |unparsed task specification|
		property parent : UnitTest(me)
	
		set unparsedExpectedTaskName to "--Unparsed Name Specification Test (Unparsed)"
		set unparsedExpectedTask to createTaskWithTaskName(unparsedExpectedTaskName)

		set parsedExpectedTaskName to "Unparsed Name Specification Test (Parsed)"
		set parsedExpectedTask to createTaskWithTaskName(parsedExpectedTaskName)
		
		set aSpec to domain's UnparsedTaskSpecification

		tell application "OmniFocus"
			my shouldEqual(unparsedExpectedTaskName, name of unparsedExpectedTask)
			my shouldEqual(parsedExpectedTaskName, name of parsedExpectedTask)
		end tell
		
		should(aSpec's isSatisfiedBy(unparsedExpectedTask), "Spec should be satisfied.")
		shouldnt(aSpec's isSatisfiedBy(parsedExpectedTask), "Spec should not be satisfied.")
	end script 
	
	script |select all inbox tasks|
		property parent : UnitTest(me)
		
		set expectedTaskName to "All Inbox Tasks Test"
		set expectedTask to createTaskWithTaskName(expectedTaskName)
		
		set allTasks to domain's TaskRepository's selectAllInboxTasks()
		
		should((count of allTasks) > 0, "Should be at least one inbox task.")
		should(allTasks contains { expectedTask }, "Should contain the task we created.")		
	end script
	
	script |select selected inbox tasks|
		property parent : UnitTest(me)
		
		set expectedTaskName to "Selected Inbox Tasks Test"
		set expectedTask to createTaskWithTaskName(expectedTaskName)
		
		
		set aSpec to domain's MatchingNameTaskSpecification
		set aName of aSpec to expectedTaskName
		
		set actualTasks to domain's TaskRepository's selectInboxTasks(aSpec)
		
		shouldEqual(1, count of actualTasks)
		
		tell application "OmniFocus"
			set actualTask to first item of actualTasks
			my shouldEqual(id of expectedTask, id of actualTask)
			my shouldEqual(expectedTaskName, name of actualTask)
		end tell		
	end script
	
	script |create task with task name|
		property parent : UnitTest(me)
	
		set expectedTaskName to "Test create task with task name"
		set myTask to createTaskWithTaskName(expectedTaskName)
	
		tell application "OmniFocus"
			set actualTaskName to name of myTask
			my shouldEqual(expectedTaskName, actualTaskName)
			my shouldEqual(missing value, containing project of myTask)
			my shouldEqual(missing value, context of myTask)
			my shouldEqual(missing value, defer date of myTask)
			my shouldEqual(missing value, due date of myTask)		
		end tell
	end script 
	
	script |create task with properties|
		property parent : UnitTest(me)
	
		set expectedTaskName to "Test create task with properties"
		set myTask to createTaskWithProperties({name:expectedTaskName})
	
		tell application "OmniFocus"
			set actualTaskName to name of myTask
			my shouldEqual(expectedTaskName, actualTaskName)
			my shouldEqual(missing value, containing project of myTask)
			my shouldEqual(missing value, context of myTask)
			my shouldEqual(missing value, defer date of myTask)
			my shouldEqual(missing value, due date of myTask)		
		end tell
	end script 
	
	script |create task with transport text|
		property parent : UnitTest(me)
	
		set expectedTaskName to "Test create tasks with transport text"
		
		testCreateTaskWithTransportText(expectedTaskName, expectedTaskName, missing value, missing value, missing value, missing value, missing value)
	end script 
	
	script |create tasks with transport text with exact items (hours only)|
		property parent : UnitTest(me)
		
		set transportText to "Test Task Name ::1 Test Project @Test Context #tuesday #wednesday at 5.00pm $5m"
		
		local tuesDate
		local wedsDate
		
		tell dateutil's CalendarDate
			set tuesDate to parse from "tuesday"
			set wedsDate to parse from "wednesday" by "05:00:00PM"
		end tell
		
		set expectedDeferDate to (dateutil's CalendarDate's parse from "tuesday")'s asDate()
		set expectedDueDate to (dateutil's CalendarDate's parse from "wednesday" at "05:00:00PM")'s asDate()
		
		testCreateTaskWithTransportText("Test Task Name ::1 Test Project @Test Context #tuesday #wednesday at 5.00pm $5m", "Test Task Name", projectFixture, contextFixture, expectedDeferDate, expectedDueDate, 5)
		testCreateTaskWithTransportText("Test Task Name ::1 Test Project @Test Context #tuesday #wednesday at 5pm $5m", "Test Task Name", projectFixture, contextFixture, expectedDeferDate, expectedDueDate, 5)
		testCreateTaskWithTransportText("Test Task Name ::1 Test Project @Test Context #tuesday #wednesday at 17 $5m", "Test Task Name", projectFixture, contextFixture, expectedDeferDate, expectedDueDate, 5)
		testCreateTaskWithTransportText("Test Task Name ::1 Test Project @Test Context #tuesday #wednesday at 5:00pm $5m", "Test Task Name:00pm", projectFixture, contextFixture, expectedDeferDate, (dateutil's CalendarDate's parse from "wednesday" at "05:00:00AM")'s asDate(), 5)
	end script

	on testCreateTaskWithTransportText(transportText, expectedTaskName, expectedProject, expectedContext, expectedDeferDate, expectedDueDate, expectedEstimatedMinutes)
		set myTask to createTaskWithTransportText(transportText)
		
		tell application "OmniFocus"
			my shouldEqual(expectedTaskName, name of myTask)
			my shouldEqual(expectedProject, containing project of myTask)
			my shouldEqual(expectedContext, context of myTask)
			my shouldEqual(expectedDeferDate, defer date of myTask)	
			my shouldEqual(expectedDueDate, due date of myTask)
			my shouldEqual(expectedEstimatedMinutes, estimated minutes of myTask)			
		end tell
	end testCreateTaskWithTransportText
	
	script |create tasks with transport text with exact items (minutes)|
		property parent : UnitTest(me)
		
		set transportText to "Test Task Name ::Test Project @Test Context #2015-09-18 at 8.30am #wednesday $5m"
		
		set expectedTaskName to "Test Task Name"
		set expectedDeferDate to date "2015-09-18 08:30 AM"
		set expectedProject to projectFixture
		set expectedContext to contextFixture
		set expectedCalendarDueDate to dateutil's CalendarDate's parse from "wednesday"
		set expectedDueDate to date "5:00 PM" of expectedCalendarDueDate's asDate()		
		set expectedEstimatedMinutes to 5
			
		testCreateTaskWithTransportText("Test Task Name ::Test Project @Test Context #2015-09-18 at 8.30am #wednesday $5m", expectedTaskName, expectedProject, expectedContext, expectedDeferDate, expectedDueDate, expectedEstimatedMinutes)
		testCreateTaskWithTransportText("Test Task Name ::Test Project @Test Context #2015-09-18 at 8:30am #wednesday $5m", "Test Task Name:30am", expectedProject, expectedContext, date "2015-09-18 08:00 AM", expectedDueDate, expectedEstimatedMinutes)
	end script
	
	script |create tasks with transport text with inexact items (1 level deep)|
		property parent : UnitTest(me)
		
		testCreateTaskWithTransportText("Test Task Name ::1 Test Proje @Test Conte $5m", "Test Task Name", projectFixture, contextFixture, missing value, missing value, 5)
	end script
	
	script |create tasks with transport text with inexact items (multiple levels deep)|
		property parent : UnitTest(me)
		
		set parentContext to domain's ContextRepository's create("Test Parent Context")
		set contextList to contextList & {parentContext}
		set childContext to domain's ContextRepository's createChild(parentContext, "Test Child Context")
		--set contextList to contextList & {childContext}
		
		set myTask to createTaskWithTransportText("Test Task Name ::1 Test Project @Test Child $5m")
		
		tell application "OmniFocus"
			my shouldEqual("Test Task Name", name of myTask)
			my shouldEqual("1 Test Project", name of containing project of myTask)
			my shouldEqual("Test Child Context", name of context of myTask)
		end tell
	end script
	
	script |create tasks with transport text with items that don't exist|
		property parent : UnitTest(me)
		
		set myTask to createTaskWithTransportText("Test Task Name ::Nonexistent Test Project @Nonexistent Test Context $5m")
		
		tell application "OmniFocus"
			my shouldEqual("Test Task Name ::Nonexistent Test Project @Nonexistent Test Context", name of myTask) --Leave it alone.
			my shouldEqual(missing value, containing project of myTask)
			my shouldEqual(missing value, context of myTask)
		end tell
	end script
end script

script |ContextRepository|
	property parent : TestSet(me)
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
		property parent : UnitTest(me)
		
		set testContext to createContext("Test Context")
		
		tell application "OmniFocus"
			my shouldEqual("Test Context", name of testContext)
		end tell
	end script
	
	
	script |create and find child context|
		property parent : UnitTest(me)
		
		set testParentContext to createContext("Test Parent Context")
		set testChildContext to domain's ContextRepository's createChild(testParentContext, "Test Child Context")
		--addToContextList(testChildContext)
		
		tell application "OmniFocus"
			my shouldEqual("Test Child Context", name of testChildContext)
			my shouldEqual("Test Parent Context", name of container of testChildContext)
		end tell
	end script
	
	
	script |find existing context|
		property parent : UnitTest(me)
		
		set myContext to createContext("Findable Context")
		
		tell domain's ContextRepository
			set actualContext to findByName("Findable Context")
			my shouldEqual(myContext, actualContext)
		end tell
	end script
	
	script |don't find non-existing context|
		property parent : UnitTest(me)
		
		tell domain's ContextRepository
			my shouldEqual(missing value, findByName("Nonexistent Test Context"))
		end tell
	end script
		
	script |find context from partially qualified name|
		property parent : UnitTest(me)
		
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
		property parent : UnitTest(me)
		
		local myContext
		
		set testContext to createContext("Test Context")
		
		tell domain's ContextRepository
			my shouldEqual(testContext, findByName("Test Context"))	
		end tell
		
	end script

	script |find context from fully qualified name of nested context|
		property parent : UnitTest(me)
		
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
