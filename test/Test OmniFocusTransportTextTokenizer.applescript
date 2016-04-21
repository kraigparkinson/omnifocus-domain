(*!
	@header OmniFocusTransportTextParsingService
		OmniFocusTransportTextParsingService self tests.
	@abstract License: GNU GPL, see COPYING for details.
	@author Kraig Parkinson
	@copyright 2015 kraigparkinson
*)

property dateutil : script "com.kraigparkinson/ASDate"
property collections : script "com.kraigparkinson/ASCollections"
property domain : script "com.kraigparkinson/OmniFocusDomain"
property oftt : script "com.kraigparkinson/OmniFocusTransportTextParsingService"

property parent : script "com.lifepillar/ASUnit"
property suite : makeTestSuite("OF Transport Text Parsing Application")

my autorun(suite)

script |TransportTextPrototype|
	property parent : TestSet(me)
	property taskList : missing value
	property projectFixture : missing value
	property contextFixture : missing value
	property projectList : missing value
	property contextList : missing value
	
	on setUp()
		set taskList to { }
		
		set projectFixture to domain's ProjectRepository's create("Test Project")
		set projectList to {projectFixture}
		
		set contextFixture to domain's ContextRepository's create("Test Context")
		set contextList to {contextFixture}
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in taskList
				delete aTask
			end repeat
			repeat with aContext in contextList
				delete aContext
			end repeat
			repeat with aProject in projectList
				delete aProject
			end repeat
		end tell
	end tearDown
	
	on createTask(taskName)
		set aTask to first item of (domain's TaskRepository's createInboxTaskWithName(taskName))
		
		set end of taskList to aTask
		return aTask
	end createTask

	script |should update values from transport text when not set on task|
		property parent : UnitTest(me)
			
		set aTask to createTask("--Foo ! ::Test Project @Test Context #2015-04-15 #2015-05-15 $5m //Arbitrary note")
	
		tell oftt's OmniFocusTransportTextService to updateTaskPropertiesFromName(aTask)
		
		tell application "OmniFocus"
			my assertEqual("Foo", aTask's name)
			my assertEqual(true, aTask's flagged)
			my assertEqual(projectFixture, aTask's assigned container)
			my assertEqual(contextFixture, aTask's context)
			my assertEqual(date "2015-04-15 12:00am", aTask's defer date)
			my assertEqual(date "2015-05-15 5:00pm", aTask's due date)
			my assertEqual(5, aTask's estimated minutes)
			my assertEqual("Arbitrary note", aTask's note's text)
		end tell
		
	end script

	script |should not update task values from transport text when properties already set on task|
		property parent : UnitTest(me)
	
		set end of contextList to domain's ContextRepository's create("Another Test Context")
		set end of projectList to domain's ProjectRepository's create("Another Test Project")
		
		set aTask to createTask("--Foo ! ::Another Test Project @Another Test Context #2015-04-15 #2015-05-15 $5m //Arbitrary note")
		tell application "OmniFocus"
			set aTask's assigned container to projectFixture
			my assertEqual(projectFixture, aTask's assigned container)
--			set aTask's context to contextFixture
			set aTask's defer date to date "2014-04-15"
			set aTask's due date to date "2014-05-15"
			set aTask's estimated minutes to 10
		end tell
		
		tell oftt's OmniFocusTransportTextService to updateTaskPropertiesFromName(aTask)
			
		tell application "OmniFocus"
			my assertEqual("Foo", aTask's name)
			my assertEqual(true, aTask's flagged)
			my assertEqual(projectFixture, aTask's assigned container)
---			my assertEqual(contextFixture, aTask's context)
			my assertEqual(date "2014-04-15 12:00am", aTask's defer date)
			my assertEqual(date "2014-05-15 12:00am", aTask's due date)
			my assertEqual(10, aTask's estimated minutes)
			my assertEqual("Arbitrary note", aTask's note's text)
		end tell
		
	end script

	script |should not update task values from transport text when no valid values available|
		property parent : UnitTest(me)
		
		set aTask to createTask("--Foo ! ::Non-existent Project 1 @Non-existent Context #2015-04-15 #2015-05-15 $5m //Arbitrary note")
				
		tell oftt's OmniFocusTransportTextService to updateTaskPropertiesFromName(aTask)
				
		tell application "OmniFocus"
			my assertEqual("--Foo ::Non-existent Project 1 @Non-existent Context", aTask's name)
			my assertEqual(true, aTask's flagged)
			my assertEqual(missing value, aTask's assigned container)
			my assertEqual(missing value, aTask's context)
			my assertEqual(date "2015-04-15", aTask's defer date)
			my assertEqual(date "2015-05-15 5:00pm", aTask's due date)
			my assertEqual(5, aTask's estimated minutes)
		end tell
		
	end script
end script

script |AssignedContainerNameExpression|
	property parent : TestSet(me)
	property taskList : missing value
	property projectFixture : missing value
	property contextFixture : missing value
	property projectList : missing value
	property contextList : missing value
	
	on setUp()
		set taskList to { }
		
		set projectFixture to domain's ProjectRepository's create("Test Project")
		set projectList to {projectFixture}
		
		set contextFixture to domain's ContextRepository's create("Test Context")
		set contextList to {contextFixture}
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in taskList
				delete aTask
			end repeat
			repeat with aContext in contextList
				delete aContext
			end repeat
			repeat with aProject in projectList
				delete aProject
			end repeat
		end tell
	end tearDown
	
	on createTask(taskName)
		set aTask to first item of (domain's TaskRepository's createInboxTaskWithName(taskName))
		
		set end of taskList to aTask
		return aTask
	end createTask

	on createProject(projectName)
		set aProject to first item of (domain's ProjectRepository's create(projectName))
		
		set end of projectList to aProject
		return aProject
	end createTask

	script |should assign project from token of existing project|
		property parent : UnitTest(me)
		
		set expr to oftt's AssignedContainerNameExpression()
		set aTask to createTask("Should find project test")
		
		set variables to collections's makeMap()
		tell variables to putValue(oftt's TransportTextTokenTypeEnum's PROJECT_TYPE, "Test Project")
		
		assertMissing(expr's interpret(aTask, variables))

		tell application "OmniFocus"
			my assertEqual(projectFixture, aTask's assigned container)
		end tell
				
	end script

	script |should not assign project from token of non-existing project|
		property parent : UnitTest(me)
		
		set expr to oftt's AssignedContainerNameExpression()
		set aTask to createTask("Should not assign project test")
		
		set variables to collections's makeMap()
		tell variables to putValue(oftt's TransportTextTokenTypeEnum's PROJECT_TYPE, "Non-existent Project")
		
		assertEqual("::Non-existent Project", expr's interpret(aTask, variables))

		tell application "OmniFocus"
			my assertMissing(aTask's assigned container)
		end tell
				
	end script

	script |should not assign project when project already assigned|
		property parent : UnitTest(me)
		
		set expr to oftt's AssignedContainerNameExpression()
		set aTask to createTask("Should not assigned project test")
		
		tell application "OmniFocus"
			set aTask's assigned container to projectFixture
		end tell
		
		createProject("Another test project")
		
		set variables to collections's makeMap()
		tell variables to putValue(oftt's TransportTextTokenTypeEnum's PROJECT_TYPE, "Another test project")
		
		assertMissing(expr's interpret(aTask, variables))

		tell application "OmniFocus"
			my assertEqual(projectFixture, aTask's assigned container)
		end tell
				
	end script

end script

script |TransportTextEvaluator|
	property parent : TestSet(me)

	on setUp()
	end setUp
	
	on tearDown()
	end tearDown


	on assertTaskNamePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, oftt's TransportTextTokenTypeEnum's NAME_TYPE)
	end assertTaskNamePresent

	on assertFlagPresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, oftt's TransportTextTokenTypeEnum's FLAG_TYPE)
	end assertFlagPresent

	on assertProjectNamePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, oftt's TransportTextTokenTypeEnum's PROJECT_TYPE)
	end assertProjectNamePresent

	on assertContextNamePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, oftt's TransportTextTokenTypeEnum's CONTEXT_TYPE)
	end assertContextNamePresent

	on assertDeferDatePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, oftt's TransportTextTokenTypeEnum's DEFER_DATE_TYPE)
	end assertDeferDatePresent

	on assertDueDatePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, oftt's TransportTextTokenTypeEnum's DUE_DATE_TYPE)
	end assertDueDatePresent

	on assertEstimatePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, oftt's TransportTextTokenTypeEnum's ESTIMATE_TYPE)
	end assertEstimatePresent

	on assertNotePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, oftt's TransportTextTokenTypeEnum's NOTE_TYPE)
	end assertNotePresent

	on assertVariablePresent(expectedValue, variables, aType)
		assertEqual(expectedValue, variables's getValue(aType))
	end assertVariablePresent

	script |should find name|
		property parent : UnitTest(me)
		set tokenText to "--Foo is the word"
		
		set variables to oftt's parseTransportTextIntoVariables(tokenText)
		
		assertTaskNamePresent("Foo is the word", variables)
	end script

	script |should find flag|
		property parent : UnitTest(me)
		set tokenText to "--Foo is the word !"
		
		set variables to oftt's parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo is the word", variables)
		assertFlagPresent(true, variables)
	end script
	
	script |should find project token|
		property parent : UnitTest(me)
		set tokenText to "--Foo ::bar"
		
		set variables to oftt's parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertProjectNamePresent("bar", variables)				
	end script

	script |should find context token|
		property parent : UnitTest(me)
		set tokenText to "--Foo @bar"
		
		set variables to oftt's parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertContextNamePresent("bar", variables)				
	end script

	script |should find due date token|
		property parent : UnitTest(me)
		set tokenText to "--Foo #2015-06-01"
		
		set variables to oftt's parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertDueDatePresent("2015-06-01", variables)				
	end script

	script |should find due date token with time|
		property parent : UnitTest(me)
		set tokenText to "--Foo #2015-06-01 at 1pm"
		
		set variables to oftt's parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertDueDatePresent("2015-06-01 at 1pm", variables)				
	end script

	script |should find defer date token|
		property parent : UnitTest(me)
		set tokenText to "--Foo #2015-06-01 #2015-07-01"
		
		set variables to oftt's parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertDueDatePresent("2015-07-01", variables)				
		assertDeferDatePresent("2015-06-01", variables)				
	end script

	script |should find defer date token with time|
		property parent : UnitTest(me)
		set tokenText to "--Foo #2015-06-01 at 2pm #2015-07-01"
		
		set variables to oftt's parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertDueDatePresent("2015-07-01", variables)	
		assertDeferDatePresent("2015-06-01 at 2pm", variables)				
	end script

	script |should find estimate token|
		property parent : UnitTest(me)
		set tokenText to "--Foo $5m"
		
		set variables to oftt's parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertEstimatePresent("5m", variables)				
	end script

	script |should find note token|
		property parent : UnitTest(me)
		set tokenText to "--Foo //Arbitrary note"
		
		set variables to oftt's parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertNotePresent("Arbitrary note", variables)				
	end script
end script