(*!
	@header OFTransportTextParsingApplication
		OFTransportTextParsingApplication self tests.
	@abstract License: GNU GPL, see COPYING for details.
	@author Kraig Parkinson
	@copyright 2015 kraigparkinson
*)

property dateutil : script "com.kraigparkinson/ASDate"
property domain : script "com.kraigparkinson/OmniFocusDomain"
property parsingApp : script "com.kraigparkinson/OFTransportTextParsingApplication"

property parent : script "com.lifepillar/ASUnit"
property suite : makeTestSuite("OF Transport Text Parsing Application")

my autorun(suite)

script |Expressions|
	property parent : TestSet(me)
	property taskList : missing value
	property projectFixture : missing value
	property contextFixture : missing value
	
	on setUp()
		set taskList to { }
		
		set projectFixture to domain's ProjectRepository's create("Test Project")
		
		set contextFixture to domain's ContextRepository's create("Test Context")
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in taskList
				delete aTask
			end repeat
			delete my projectFixture
			delete my contextFixture
		end tell
	end tearDown
	
	on createTask(taskName)
		set aTask to first item of (domain's TaskRepository's createInboxTaskWithName(taskName))
		
		set end of taskList to aTask
		return aTask
	end createTask

	on testUnparsedTaskNameExpression(transportText, expectedTaskName)
		set aTask to createTask(transportText)
		
		set expression to parsingApp's UnparsedTaskNameExpression's makeExpression()
		tell expression to interpret(aTask)
		
		tell application "OmniFocus"
			my shouldEqual(expectedTaskName, aTask's name)
		end tell
	end testUnparsedTaskNameExpression

	script |test unparsed task name |
		property parent : UnitTest(me)
	
		testUnparsedTaskNameExpression("--Foo", "Foo")
		testUnparsedTaskNameExpression("Foo", "Foo")
	end script

	on testAssignedContainerExpression(transportText, expectedTaskName, expectedProject)
		set aTask to createTask(transportText)
		
		set expression to parsingApp's AssignedContainerExpression's makeExpression()
		tell expression to interpret(aTask)
		
		tell application "OmniFocus"
			my shouldEqual(expectedTaskName, aTask's name)
			my shouldEqual(expectedProject, aTask's assigned container)
		end tell
	end testAssignedContainerExpression

	script |test AssignedContainerExpression without previous values|
		property parent : UnitTest(me)
	
		testAssignedContainerExpression("Foo ::Test Project", "Foo", projectFixture)
		testAssignedContainerExpression("Foo ::Test Fake Project", "Foo ::Test Fake Project", missing value)
	end script
	
	script |test ContextExpression|
		property parent : UnitTest(me)
	
		set aTask to createTask("Foo @Test Context")
		
		set expression to parsingApp's ContextExpression's makeExpression()
		tell expression to interpret(aTask)
		
		tell application "OmniFocus"
			my shouldEqual("Foo", aTask's name)
			my shouldEqual("Test Context", aTask's context's name)
		end tell
	end script

	script |test DateExpression handles due dates|
		property parent : UnitTest(me)
	
		set aTask to createTask("Foo #2016-03-02")
		
		set expression to parsingApp's DateExpression's makeExpression()
		tell expression to interpret(aTask)
		
		tell application "OmniFocus"
			my shouldEqual("Foo", aTask's name)
			my shouldEqual(date "2016-03-02 5:00pm", aTask's due date)
			my shouldEqual(missing value, aTask's defer date)
		end tell
	end script

	script |test DateExpression handles due and defer dates|
		property parent : UnitTest(me)
	
		testDateExpression("Foo #2016-03-02 #2016-03-03", "Foo", date "2016-03-02", date "2016-03-03 5:00pm")
		testDateExpression("Foo #2016-03-02 8:00am #2016-03-03 4:30pm", "Foo", date "2016-03-02 8:00am", date "2016-03-03 4:30pm")
	end script
	
	on testDateExpression(transportText, expectedTaskName, expectedDeferDate, expectedDueDate)
		set aTask to createTask(transportText)		
		set expression to parsingApp's DateExpression's makeExpression()
		tell expression to interpret(aTask)
		
		tell application "OmniFocus"
			my shouldEqual(expectedTaskName, aTask's name)
			my shouldEqual(expectedDeferDate, aTask's defer date)
			my shouldEqual(expectedDueDate, aTask's due date)
		end tell
	end testDateExpression

	script |test EstimateExpression|
		property parent : UnitTest(me)
	
		set aTask to createTask("Foo $5m")
		
		set expression to parsingApp's EstimateExpression's makeExpression()
		tell expression to interpret(aTask)
		
		tell application "OmniFocus"
			my shouldEqual("Foo", aTask's name)
			my shouldEqual(5, aTask's estimated minutes)
		end tell
	end script
		
	script |test NoteExpression without note|
		property parent : UnitTest(me)
	
		set aTask to createTask("Foo //Sample note")
		
		set expression to parsingApp's NoteExpression's makeExpression()
		tell expression to interpret(aTask)
		
		tell application "OmniFocus"
			my shouldEqual("Foo", aTask's name)
			my shouldEqual("Sample note", aTask's note)
		end tell
	end script

	script |test NoteExpression with existing note|
		property parent : UnitTest(me)
	
		set aTask to createTask("Foo //Sample note")
		tell application "OmniFocus"
			set aTask's note's text to "Hey there."
		end tell
		
		set expression to parsingApp's NoteExpression's makeExpression()
		tell expression to interpret(aTask)
		
		tell application "OmniFocus"
			my shouldEqual("Foo", aTask's name)
			my shouldEqual("Hey there." & "\n" & "Sample note", aTask's note)
		end tell
	end script
	
	script |test ParsableTransportTextEvaluatorBuilder|
		property parent : UnitTest(me)
		
		testDefaultTransportTextEvaluator("Foo ! ::Test Project @Test Context #2016-02-01 #2016-03-01 $10m //Sample note", "Foo", true, projectFixture, contextFixture, date "2016-02-01", date "2016-03-01 5:00pm", 10, "Sample note")
--		testDefaultTransportTextEvaluator("Foo ! ::Test Project @Test Context #2016-02-01 #2016-03-01 $10m //Sample note", "Foo", true, projectFixture, contextFixture, date "2016-02-01", date "2016-03-01 5:00pm", 10, "Sample note")
	end script 
	
	on testDefaultTransportTextEvaluator(transportText, expectedTaskName, expectedFlagged, expectedProject, expectedContext, expectedDeferDate, expectedDueDate, expectedEstimatedMinutes, expectedNote)
		set aTask to createTask(transportText)
		
		set evaluator to parsingApp's TransportTextEvaluator's anotherEvaluator()
		
		tell evaluator to interpret(aTask)
				
		tell application "OmniFocus"
			--Handles task name with "--"
			my shouldEqual(expectedTaskName, name of aTask)
			--Handles a flag
			my shouldEqual(expectedFlagged, flagged of aTask)
			--Handles a project
			my shouldEqual(expectedProject, assigned container of aTask)
			--Handles a context
			my shouldEqual(expectedContext, context of aTask)
			--Handles a defer date
			my shouldEqual(expectedDeferDate, defer date of aTask)
			--Handles a due date
			my shouldEqual(expectedDueDate, due date of aTask)
			--Handles an estimate
			my shouldEqual(expectedEstimatedMinutes, estimated minutes of aTask)
			--Handles a note
			my shouldEqual(expectedNote, note of aTask)
		end tell
		
	end testDefaultTransportTextEvaluator
end script

script |TransportTextEvaluator|
	property parent : TestSet(me)
	property taskList : missing value
	property projectFixture : missing value
	property contextFixture : missing value

	on setUp()
	
		set taskList to { } 

		set projectFixture to domain's ProjectRepository's create("Test Project")
	
		set contextFixture to domain's ContextRepository's create("Test Context")
	end setUp

	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in taskList
				delete aTask
			end repeat
			delete my projectFixture
			delete my contextFixture
		end tell
	end tearDown

	on createTask(taskName)
		set aTask to first item of (domain's TaskRepository's createInboxTaskWithName(taskName))
	
		set taskList to taskList & { aTask }
		return aTask
	end createTask

	on testUpdateTask(transportText, expectedName, expectedFlagged, expectedProjectName, expectedContextName, expectedDeferDate, expectedDueDate, expectedEstimate, expectedNote)
		set aTask to createTask(transportText)
				
		tell application "OmniFocus"			
			my shouldEqual(transportText, name of aTask)
			my shouldEqual(false, flagged of aTask)
			
			tell parsingApp's TransportTextEvaluator's anotherEvaluator() to interpret(aTask)
			
			my shouldEqual(expectedName, name of aTask)
			my shouldEqual(expectedFlagged, flagged of aTask)
			
			local expectedProject
			if (expectedProjectName is not missing value)
				set expectedProject to domain's ProjectRepository's findByName(expectedProjectName)
			else 
				set expectedProject to missing value
			end 
			my shouldEqual(expectedProject, assigned container of aTask)
			
			local expectedContext
			if (expectedContextName is not missing value)
				set expectedContext to domain's ContextRepository's findByName(expectedContextName)
			else 
				set expectedContext to missing value
			end 
			my shouldEqual(expectedContext, context of aTask)

			my shouldEqual(expectedDeferDate, defer date of aTask)
			my shouldEqual(expectedDueDate, due date of aTask)
			my shouldEqual(expectedEstimate, estimated minutes of aTask)
			my shouldEqual(expectedNote, note of aTask)
		end tell
	end testUpdateTask
	
	script |test update task with just a task name|
		property parent : UnitTest(me)
		
		testUpdateTask("My New Task", "My New Task", false, missing value, missing value, missing value, missing value, missing value, "")
	end script	

	script |test update task with task and flag|
		property parent : UnitTest(me)
		
		testUpdateTask("My New Task F !", "My New Task F", true, missing value, missing value, missing value, missing value, missing value, "")		
	end script	

	script |test update task with task, context|
		property parent : UnitTest(me)
		
		testUpdateTask("My New Task C1 @Test Context", "My New Task C1", false, missing value, "Test Context", missing value, missing value, missing value, "")
	end script	

	script |test update task with task, non-existent context|
		property parent : UnitTest(me)
		
		testUpdateTask("My New Task C2 @asdfghjkl;", "My New Task C2 @asdfghjkl;", false, missing value, missing value, missing value, missing value, missing value, "")
	end script	

	script |test update task with task, project|
		property parent : UnitTest(me)
		
		testUpdateTask("My New Task P1 ::Test Project", "My New Task P1", false, "Test Project", missing value, missing value, missing value, missing value, "")
	end script	

	script |test update task with task, non-existent project|
		property parent : UnitTest(me)
		
		testUpdateTask("My New Task P2 ::asdfghjkl;", "My New Task P2 ::asdfghjkl;", false, missing value, missing value, missing value, missing value, missing value, "")
	end script	

	script |test update task with task, due and defer dates|
		property parent : UnitTest(me)
		
		testUpdateTask("My New Task due defer #06/21/2015 #06/22/2015 02:00PM", "My New Task due defer", false, missing value, missing value, date "06/21/2015", date "06/22/2015 02:00PM", missing value, "")
	end script	

	script |test update task with task, both dates and a note|
		property parent : UnitTest(me)
		
		testUpdateTask("My New Task due defer note #06/26/2015 #06/25/2015 02:00PM //I'm a note!", "My New Task due defer note", false, missing value, missing value, date "06/26/2015", date "06/25/2015 02:00PM", missing value, "I'm a note!")
	end script	

	script |test update task with task, due date|
		property parent : UnitTest(me)
		
		testUpdateTask("My New Task #06/25/2015 02:00PM", "My New Task", false, missing value, missing value, missing value, date "06/25/2015 02:00PM", missing value, "")
	end script	

	script |test update task with task, estimate in minutes|
		property parent : UnitTest(me)
		
		testUpdateTask("My New Task $5m", "My New Task", false, missing value, missing value, missing value, missing value, 5, "")
	end script	

	script |test update task with task, estimate in hours|
		property parent : UnitTest(me)
		
		testUpdateTask("My New Task $1h", "My New Task", false, missing value, missing value, missing value, missing value, 60, "")
	end script	

	script |test update task with everything but a flag|
		property parent : UnitTest(me)

		testUpdateTask("My New Task all stops ::Test Project @Test Context #06/23/2015 5:00pm $5m //I wanna rock and roll all night", "My New Task all stops", false, "Test Project", "Test Context", missing value, date "06/23/2015 05:00PM", 5, "I wanna rock and roll all night")
	end script	
	
	script |test update task in summary|
		property parent : UnitTest(me)

		testUpdateTask("My New Task", "My New Task", false, missing value, missing value, missing value, missing value, missing value, "")
		testUpdateTask("My New Task F !", "My New Task F", true, missing value, missing value, missing value, missing value, missing value, "")		
		testUpdateTask("My New Task C1 @Test Context", "My New Task C1", false, missing value, "Test Context", missing value, missing value, missing value, "")
		testUpdateTask("My New Task C2 @asdfghjkl;", "My New Task C2 @asdfghjkl;", false, missing value, missing value, missing value, missing value, missing value, "")
		testUpdateTask("My New Task P1 ::Test Project", "My New Task P1", false, "Test Project", missing value, missing value, missing value, missing value, "")
		testUpdateTask("My New Task P2 ::asdfghjkl;", "My New Task P2 ::asdfghjkl;", false, missing value, missing value, missing value, missing value, missing value, "")
		testUpdateTask("My New Task due defer #06/21/2015 #06/22/2015 02:00PM", "My New Task due defer", false, missing value, missing value, date "06/21/2015", date "06/22/2015 02:00PM", missing value, "")
		testUpdateTask("My New Task due defer note #06/26/2015 #06/25/2015 02:00PM //I'm a note!", "My New Task due defer note", false, missing value, missing value, date "06/26/2015", date "06/25/2015 02:00PM", missing value, "I'm a note!")	
		testUpdateTask("My New Task #06/25/2015 02:00PM", "My New Task", false, missing value, missing value, missing value, date "06/25/2015 02:00PM", missing value, "")
		testUpdateTask("My New Task $5m", "My New Task", false, missing value, missing value, missing value, missing value, 5, "")
		testUpdateTask("My New Task $1h", "My New Task", false, missing value, missing value, missing value, missing value, 60, "")
		testUpdateTask("My New Task all stops ::Test Project @Test Context #06/23/2015 5:00pm $5m //I wanna rock and roll all night", "My New Task all stops", false, "Test Project", "Test Context", missing value, date "06/23/2015 05:00PM", 5, "I wanna rock and roll all night")
							
	end script
end script

script |Parse Tasks|
	property parent : TestSet(me)
	property taskList : missing value
	property projectFixture : missing value
	property contextFixture : missing value
	
	on setUp()
		
		set taskList to { } 

		set projectFixture to domain's ProjectRepository's create("Test Project")
		
		set contextFixture to domain's ContextRepository's create("Test Context")
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in taskList
				delete aTask
			end repeat
			delete my projectFixture
			delete my contextFixture
		end tell
	end tearDown
	
	on createTask(taskName)
		set aTask to first item of (domain's TaskRepository's createInboxTaskWithName(taskName))
		
		set taskList to taskList & { aTask }
		return aTask
	end createTask
	
	on testTransportTextContainsFlag(expectedFlag, transportText)
		shouldEqual(expectedFlag, parsingApp's ContainsFlagSpecification's isSatisfiedBy(transportText))		
	end testTransportTextContainsFlag
	
	script |transport text flagging|
		property parent : UnitTest(me)
		
		testTransportTextContainsFlag(false, "Task Name")
		testTransportTextContainsFlag(false, "Task Name!")
		testTransportTextContainsFlag(true, "Task Name !")
		testTransportTextContainsFlag(false, "Task Name ::Project Name")
		testTransportTextContainsFlag(false, "Task Name @Context Name")
		testTransportTextContainsFlag(true, space & "!")
		testTransportTextContainsFlag(false, "")
		testTransportTextContainsFlag(false, "//I'm a note!")
		testTransportTextContainsFlag(false, "Not flagged //I'm a note!")
		testTransportTextContainsFlag(true, "Flagged ! //I'm a note!")
	end script
		
end script

script |Parse Dates|
	property parent : TestSet(me)
	
	on setUp()
	end setUp
	
	on tearDown()
	end tearDown

	on testParseDueDateMethod(expectedDate, testDateString) 
		shouldEqual(expectedDate's asDate(), parsingApp's parseDueDate(testDateString))
	end testParseDueDate
	
	script |parse due date|
		property parent : UnitTest(me)
		
		tell dateutil's CalendarDate
			my testParseDueDateMethod(today at "5:00 PM", "today")
			my testParseDueDateMethod((today at "2:00 PM"), "today at 2:00PM")
			my testParseDueDateMethod((tomorrow at "2:00 PM"), "+1d at 2:00PM")
			my testParseDueDateMethod((create on date "Sunday, May 24, 2015 at 5:00:00 PM"), "2015-05-24")
			my testParseDueDateMethod((create on date "Sunday, May 24, 2015 at 1:00:00 PM"), "2015-05-24 1:00PM")
			my testParseDueDateMethod((create on date "Sunday, May 24, 2015 at 2:00:00 PM"), "2015-05-24 at 2:00PM")
			my testParseDueDateMethod((create on date "Monday, May 25, 2015 at 1:00:00 PM"), "May 25, 2015 1:00PM")
			my testParseDueDateMethod((create on date "Monday, May 25, 2015 at 2:00:00 PM"), "May 25, 2015 at 2:00PM")
			my testParseDueDateMethod((today at "5:00 PM")'s nextWeekday(Wednesday), "wednesday")
			my testParseDueDateMethod((today at "4:00 PM")'s nextWeekday(Wednesday), "wednesday at 4:00PM")
		end tell
	end script
	
	on testParseDeferDateMethod(expectedDate, testDateString) 
		shouldEqual(expectedDate's asDate(), parsingApp's parseDeferDate(testDateString))
	end testParseDueDate
		
	script |parse defer date|
		property parent : UnitTest(me)

		tell dateutil's CalendarDate
			my testParseDeferDateMethod((today at "12:00:00AM"), "today")
			my testParseDeferDateMethod((today at "2:00 PM"), "today at 2:00PM")
			my testParseDeferDateMethod((tomorrow at "2:00 PM"), "+1d at 2:00PM")
			my testParseDeferDateMethod((create on date "Sunday, May 24, 2015 at 12:00:00 AM"), "2015-05-24")
			my testParseDeferDateMethod((create on date "Sunday, May 24, 2015 at 1:00:00 PM"), "2015-05-24 1:00PM")
			my testParseDeferDateMethod((create on date "Sunday, May 24, 2015 at 2:00:00 PM"), "2015-05-24 at 2:00PM")
			my testParseDeferDateMethod((create on date "Monday, May 25, 2015 at 1:00:00 PM"), "May 25, 2015 1:00PM")
			my testParseDeferDateMethod((create on date "Monday, May 25, 2015 at 2:00:00 PM"), "May 25, 2015 at 2:00PM")
			my testParseDeferDateMethod((today at "12:00 AM")'s nextWeekday(Wednesday), "wednesday")
			my testParseDeferDateMethod((today at "5:00 PM")'s nextWeekday(Wednesday), "wednesday at 5:00PM")
		end tell
	end script
	
end script