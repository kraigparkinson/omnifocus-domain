use AppleScript version "2.4" -- Yosemite (10.10) or later

(*!
	@header Test OmniFocus
		Tests to verify OmniFocus functionality.
	@abstract License: GNU GPL, see COPYING for details.
	@author Kraig Parkinson
	@copyright 2015 kraigparkinson
*)

use dateutil : script "com.kraigparkinson/ASDate"
use application "OmniFocus"

property parent : script "com.lifepillar/ASUnit"
property suite : makeTestSuite("OmniFocus")


my autorun(suite)

script |parse tasks into from transport text|
	property PROJECT_FIXTURE_NAME : "Test" & space & "OmniFocus" & space & "(Project)"
	property CONTEXT_FIXTURE_NAME : "Test OmniFocus (Context)"
	property parent : registerFixture(me)
	property taskList : {}
	property contextFixture : missing value
	property contextList : {}
	property projectFixture : missing value
	property projectList : {}
	
	on setUp()
		set taskList to {}
		
		tell default document
			set contextFixture to make new context with properties {name:CONTEXT_FIXTURE_NAME}
			set contextList to { contextFixture }
		end tell		
		
		tell default document
			set my projectFixture to make new project with properties {name:PROJECT_FIXTURE_NAME}
			set projectList to { projectFixture }
		end tell
	end setUp
	
	on addTaskToFixture(aTask)
		set end of taskList to aTask
	end addTaskToFixture
	
	on tearDown()
		set errorList to { }
		
		repeat with aTask in taskList
			tell application "OmniFocus"
				try
					delete aTask
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
	
	on testCreateTaskWithTransportText(transportText, expectedTaskName, expectedProject, expectedContext, expectedDeferDate, expectedDueDate, expectedEstimatedMinutes, expectedNote)
		set newTaskList to (parse tasks into default document with transport text transportText with as single task)
		
		should(count of newTaskList is 1, "Should have one task from adding task via transport text") 
		
		set myTask to first item in newTaskList		
		addTaskToFixture(myTask)
		shouldEqual(expectedTaskName, myTask's name)
		shouldEqual(expectedProject, myTask's containing project)
		shouldEqual(expectedContext, myTask's context)
		shouldEqual(expectedDeferDate, myTask's defer date)	
		shouldEqual(expectedDueDate, myTask's due date)
		shouldEqual(expectedEstimatedMinutes, myTask's estimated minutes)
		shouldEqual(expectedNote, myTask's note)
	end testCreateTaskWithTransportText
	
	script |transport text with hours and without minutes (h) specified in the due and defer dates is parsed into dates|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "Test create tasks w/ transport text exact (hours only)"
		set transportText to expectedTaskName & " ::" & PROJECT_FIXTURE_NAME & " @" & CONTEXT_FIXTURE_NAME & " #tuesday #wednesday at 5.00pm $5m"
				
		set expectedDeferDate to (dateutil's CalendarDateFactory's parse from "tuesday")'s asDate()
		set expectedDueDate to (dateutil's CalendarDateFactory's parse from "wednesday" at "05:00:00PM")'s asDate()
		
		testCreateTaskWithTransportText(expectedTaskName & " ::" & PROJECT_FIXTURE_NAME & " @" & CONTEXT_FIXTURE_NAME & " #tuesday #wednesday at 5pm $5m //A note.", expectedTaskName, projectFixture, contextFixture, expectedDeferDate, expectedDueDate, 5, "A note.")
		testCreateTaskWithTransportText(expectedTaskName & " ::" & PROJECT_FIXTURE_NAME & " @" & CONTEXT_FIXTURE_NAME & " #tuesday #wednesday at 17 $5m //A note.", expectedTaskName, projectFixture, contextFixture, expectedDeferDate, expectedDueDate, 5, "A note.")
	end script
	
	script |transport text with hours and minutes delimeted by period (h.mm) at top of hour specified in the due and defer dates is parsed into dates|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "Test transport text w/ transport text exact at top of hour"
		set transportText to expectedTaskName & " ::" & PROJECT_FIXTURE_NAME & " @" & CONTEXT_FIXTURE_NAME & " #tuesday #wednesday at 5.00pm $5m"
				
		set expectedDeferDate to (dateutil's CalendarDateFactory's parse from "tuesday")'s asDate()
		set expectedDueDate to (dateutil's CalendarDateFactory's parse from "wednesday" at "05:00:00PM")'s asDate()
	
		testCreateTaskWithTransportText(expectedTaskName & " ::" & PROJECT_FIXTURE_NAME & " @" & CONTEXT_FIXTURE_NAME & " #tuesday #wednesday at 5.00pm $5m //A note.", expectedTaskName, projectFixture, contextFixture, expectedDeferDate, expectedDueDate, 5, "A note.")
	end script
	
	script |transport text with times delimeted by periods (h.mm) in the due and defer dates is parsed into dates|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "Test create tasks w/ transport text (minutes)"
		
		set expectedDeferDate to date "2015-09-18 08:30 AM"

		set expectedCalendarDueDate to dateutil's CalendarDateFactory's parse from "wednesday"
		set expectedDueDate to date "5:00 PM" of expectedCalendarDueDate's asDate()		

		set expectedEstimatedMinutes to 5

		set transportText to expectedTaskName & " ::" & PROJECT_FIXTURE_NAME & " @" & CONTEXT_FIXTURE_NAME & " #2015-09-18 at 8.30am #wednesday $5m //A note." 
			
		testCreateTaskWithTransportText(transportText, expectedTaskName, projectFixture, contextFixture, expectedDeferDate, expectedDueDate, expectedEstimatedMinutes, "A note.")
	end script
	
	script |transport text with hours and minutes delimeted by colon (h:mm) at bottom of hour specified in the due and defer dates is not parsed into dates and minutes are appended to task name|
		property parent : registerTestCase(me)
	
		set expectedTaskName to "Test create tasks w/ transport text exact (hours only)"
		set transportText to expectedTaskName & " ::" & PROJECT_FIXTURE_NAME & " @" & CONTEXT_FIXTURE_NAME & " #tuesday #wednesday at 5.00pm $5m"
			
		set expectedDeferDate to (dateutil's CalendarDateFactory's parse from "tuesday")'s asDate()
		set expectedDueDate to (dateutil's CalendarDateFactory's parse from "wednesday" at "05:00:00PM")'s asDate()

		testCreateTaskWithTransportText(expectedTaskName & " ::" & PROJECT_FIXTURE_NAME & " @" & CONTEXT_FIXTURE_NAME & " #tuesday #wednesday at 5:00pm $5m //A note.", expectedTaskName & ":00pm", projectFixture, contextFixture, expectedDeferDate, (dateutil's CalendarDateFactory's parse from "wednesday" at "05:00:00AM")'s asDate(), 5, "A note.")
	end script
	
	script |create tasks with transport text with inexact items (1 level deep)|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "Test create tasks w/ transport text inexact"
		testCreateTaskWithTransportText(expectedTaskName & " ::Test OmniFocus (Proj @Test OmniFocus (Cont $5m //A note.", expectedTaskName, projectFixture, contextFixture, missing value, missing value, 5, "A note.")
	end script
	
	script |create tasks with transport text with inexact items (multiple levels deep)|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "Test create tasks with transport text inexact deep"

		local expectedContext
		tell default document of application "OmniFocus"
			set expectedContext to make new context at contextFixture with properties {name:"Test Child context"}
		end tell

		testCreateTaskWithTransportText(expectedTaskName & " ::Test OmniFocus (Proj" & " @Test Child $5m //A note.", expectedTaskName, projectFixture, expectedContext, missing value, missing value, 5, "A note.")
	end script
	
	script |creating a task with transport text items that don't exist remain in transport text|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "Test create task w transport text w non-existing items"
		set transportText to expectedTaskName & " ::Nonexistent Test Project @Nonexistent Test Context $5m //A note."

		set newTaskList to (parse tasks into default document with transport text transportText with as single task)		
		set myTask to first item in newTaskList
		addTaskToFixture(myTask)
						
		my shouldEqual(expectedTaskName & " ::Nonexistent Test Project @Nonexistent Test Context", myTask's name)
		my shouldEqual(missing value, myTask's assigned container)
		my shouldEqual(missing value, myTask's context)
		my shouldEqual("A note.", myTask's note)
	
	end script
end script


