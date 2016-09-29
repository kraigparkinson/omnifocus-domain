use AppleScript version "2.4" -- Yosemite (10.10) or later

(*!
	@header OmniFocusTransportTextParsingService
		OmniFocusTransportTextParsingService self tests.
	@abstract License: GNU GPL, see COPYING for details.
	@author Kraig Parkinson
	@copyright 2015 kraigparkinson
*)

property dateutil : script "com.kraigparkinson/ASDate"
property domain : script "com.kraigparkinson/OmniFocusDomain"
property parent : script "com.lifepillar/ASUnit"
property collections : script "com.kraigparkinson/ASCollections"

property suite : makeTestSuite("OF Transport Text Tokenizer")

my autorun(suite)

script |AssignedContainerNameExpression|
	property parent : registerFixture(me)
	property PROJECT_FIXTURE_NAME : "Test: (Project) AssignedContainerNameExpression"
	property CONTEXT_FIXTURE_NAME : "Test: (Context) AssignedContainerNameExpression"
	property taskList : missing value
	property projectFixture : missing value
	property contextFixture : missing value
	property projectList : missing value
	property contextList : missing value
	
	on setUp()
		set taskList to { }
		
		set projectFixture to domain's ProjectRepository's create(PROJECT_FIXTURE_NAME)
		set projectList to {projectFixture}
		
		set contextFixture to domain's ContextRepository's create(CONTEXT_FIXTURE_NAME)
		set contextList to {contextFixture}
		
		set domain's _taskRepository to domain's DocumentTaskRepository
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in taskList
				delete aTask's original
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
		set aTask to domain's TaskFactory's create()
		aTask's setName(taskName)
		
		set aTask to (domain's taskRepositoryInstance()'s addTask(aTask))
		set end of taskList to aTask
		return aTask
	end createTask

	on createProject(projectName)
		set aProject to first item of (domain's ProjectRepository's create(projectName))
		
		set end of projectList to aProject
		return aProject
	end createTask

	script |should assign project from token of existing project|
		property parent : registerTestCase(me)
		
		set expr to domain's TransportTextParsingService's CustomInterpreter's TransportTextExpression's AssignedContainerNameExpression()
		set aTask to createTask("Should find project test")
		
		set variables to collections's makeMap()
		tell variables to putValue(domain's TransportTextParsingService's CustomInterpreter's TransportTextTokenTypeEnum's PROJECT_TYPE, PROJECT_FIXTURE_NAME)
		
		assertMissing(expr's interpret(aTask, variables))

		assertEqual(projectFixture, aTask's _containingProjectValue())
		
				
	end script

	script |should not assign project from token of non-existing project|
		property parent : registerTestCase(me)
		
		set expr to domain's TransportTextParsingService's CustomInterpreter's TransportTextExpression's AssignedContainerNameExpression()
		set aTask to createTask("Should not assign project test")
		
		set variables to collections's makeMap()
		tell variables to putValue(domain's TransportTextParsingService's CustomInterpreter's TransportTextTokenTypeEnum's PROJECT_TYPE, "Non-existent Project")
		
		assertEqual("::Non-existent Project", expr's interpret(aTask, variables))

		assertMissing(aTask's _containingProjectValue())
				
	end script

	script |should not assign project when project already assigned|
		property parent : registerTestCase(me)
		
		set expr to domain's TransportTextParsingService's CustomInterpreter's TransportTextExpression's AssignedContainerNameExpression()
		set aTask to createTask("Should not assigned project test")
		
		tell aTask to assignToProject(projectFixture)
		
		createProject("Another test project")
		
		set variables to collections's makeMap()
		tell variables to putValue(domain's TransportTextParsingService's CustomInterpreter's TransportTextTokenTypeEnum's PROJECT_TYPE, "Another test project")
		
		assertMissing(expr's interpret(aTask, variables))

		assertEqual(projectFixture, aTask's _containingProjectValue())
				
	end script

end script

script |CustomerInterpreter|
	property parent : registerFixture(me)

	on setUp()
	end setUp
	
	on tearDown()
	end tearDown


	on assertTaskNamePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, domain's TransportTextParsingService's CustomInterpreter's TransportTextTokenTypeEnum's NAME_TYPE)
	end assertTaskNamePresent

	on assertFlagPresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, domain's TransportTextParsingService's CustomInterpreter's TransportTextTokenTypeEnum's FLAG_TYPE)
	end assertFlagPresent

	on assertProjectNamePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, domain's TransportTextParsingService's CustomInterpreter's TransportTextTokenTypeEnum's PROJECT_TYPE)
	end assertProjectNamePresent

	on assertContextNamePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, domain's TransportTextParsingService's CustomInterpreter's TransportTextTokenTypeEnum's CONTEXT_TYPE)
	end assertContextNamePresent

	on assertDeferDatePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, domain's TransportTextParsingService's CustomInterpreter's TransportTextTokenTypeEnum's DEFER_DATE_TYPE)
	end assertDeferDatePresent

	on assertDueDatePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, domain's TransportTextParsingService's CustomInterpreter's TransportTextTokenTypeEnum's DUE_DATE_TYPE)
	end assertDueDatePresent

	on assertEstimatePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, domain's TransportTextParsingService's CustomInterpreter's TransportTextTokenTypeEnum's ESTIMATE_TYPE)
	end assertEstimatePresent

	on assertNotePresent(expectedValue, variables)
		assertVariablePresent(expectedValue, variables, domain's TransportTextParsingService's CustomInterpreter's TransportTextTokenTypeEnum's NOTE_TYPE)
	end assertNotePresent

	on assertVariablePresent(expectedValue, variables, aType)
		assertEqual(expectedValue, variables's getValue(aType))
	end assertVariablePresent

	script |should find name|
		property parent : registerTestCase(me)
		set tokenText to "--Foo is the word"
		
		set variables to domain's TransportTextParsingService's CustomInterpreter's _parseTransportTextIntoVariables(tokenText)
		
		assertTaskNamePresent("Foo is the word", variables)
	end script

	script |should find flag|
		property parent : registerTestCase(me)
		set tokenText to "--Foo is the word !"
		
		set variables to domain's TransportTextParsingService's CustomInterpreter's _parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo is the word", variables)
		assertFlagPresent(true, variables)
	end script
	
	script |should find project token|
		property parent : registerTestCase(me)
		set tokenText to "--Foo ::bar"
		
		set variables to domain's TransportTextParsingService's CustomInterpreter's _parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertProjectNamePresent("bar", variables)				
	end script

	script |should find context token|
		property parent : registerTestCase(me)
		set tokenText to "--Foo @bar"
		
		set variables to domain's TransportTextParsingService's CustomInterpreter's _parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertContextNamePresent("bar", variables)				
	end script

	script |should find due date token|
		property parent : registerTestCase(me)
		set tokenText to "--Foo #2015-06-01"
		
		set variables to domain's TransportTextParsingService's CustomInterpreter's _parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertDueDatePresent("2015-06-01", variables)				
	end script

	script |should find due date token with time|
		property parent : registerTestCase(me)
		set tokenText to "--Foo #2015-06-01 at 1pm"
		
		set variables to domain's TransportTextParsingService's CustomInterpreter's _parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertDueDatePresent("2015-06-01 at 1pm", variables)				
	end script

	script |should find defer date token|
		property parent : registerTestCase(me)
		set tokenText to "--Foo #2015-06-01 #2015-07-01"
		
		set variables to domain's TransportTextParsingService's CustomInterpreter's _parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertDueDatePresent("2015-07-01", variables)				
		assertDeferDatePresent("2015-06-01", variables)				
	end script

	script |should find defer date token with time|
		property parent : registerTestCase(me)
		set tokenText to "--Foo #2015-06-01 at 2pm #2015-07-01"
		
		set variables to domain's TransportTextParsingService's CustomInterpreter's _parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertDueDatePresent("2015-07-01", variables)	
		assertDeferDatePresent("2015-06-01 at 2pm", variables)				
	end script

	script |should find estimate token|
		property parent : registerTestCase(me)
		set tokenText to "--Foo $5m"
		
		set variables to domain's TransportTextParsingService's CustomInterpreter's _parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertEstimatePresent("5m", variables)				
	end script

	script |should find note token|
		property parent : registerTestCase(me)
		set tokenText to "--Foo //Arbitrary note"
		
		set variables to domain's TransportTextParsingService's CustomInterpreter's _parseTransportTextIntoVariables(tokenText)

		assertTaskNamePresent("Foo", variables)
		assertNotePresent("Arbitrary note", variables)				
	end script
end script
	
script |TransportTextParsingService|
	property parent : registerFixture(me)
	property PROJECT_FIXTURE_NAME : "Test: Project TransportTextEvaluator"
	property CONTEXT_FIXTURE_NAME : "Test: Context TransportTextEvaluator"
	property taskList : missing value
	property projectFixture : missing value
	property contextFixture : missing value
	property projectList : missing value
	property contextList : missing value
	
	on setUp()
		set taskList to { }
		
		set projectFixture to domain's ProjectRepository's create(PROJECT_FIXTURE_NAME)
		set projectList to {projectFixture}
		
		set contextFixture to domain's ContextRepository's create(CONTEXT_FIXTURE_NAME)
		set contextList to {contextFixture}
		
		set domain's _taskRepository to domain's DocumentTaskRepository
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in taskList
				delete aTask's original
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
		set aTask to domain's TaskFactory's create()
		aTask's setName(taskName)
		set aTask to domain's taskRepositoryInstance()'s addTask(aTask)
		set end of taskList to aTask
		return aTask
	end createTask

	on testUpdateTask(transportText, expectedName, expectedFlagged, expectedProject, expectedContext, expectedDeferDate, expectedDueDate, expectedEstimate, expectedNote)
		set aTask to createTask(transportText)

		set aService to domain's TransportTextParsingService		
		tell aService to updateTaskPropertiesFromName(aTask)
			
		shouldEqual(expectedName, aTask's getName())
		shouldEqual(expectedFlagged, aTask's hasFlagSet())
		
		shouldEqual(expectedProject, aTask's _containingProjectValue())		
		shouldEqual(expectedContext, aTask's _contextValue())

		shouldEqual(expectedDeferDate, aTask's _deferDateValue())
		shouldEqual(expectedDueDate, aTask's _dueDateValue())
		shouldEqual(expectedEstimate, aTask's _estimatedMinutesValue())
		shouldEqual(expectedNote, aTask's _noteValue())

	end testUpdateTask
	
	script |converts transport text into a task|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "Test convert transport text into a task"
		testUpdateTask("--" & expectedTaskName, expectedTaskName, false, missing value, missing value, missing value, missing value, missing value, "")
	end script	

	script |converts transport text with a flag into a task|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "Test convert transport text with a flag into a flagged task"
		testUpdateTask("--" & expectedTaskName & " !", expectedTaskName, true, missing value, missing value, missing value, missing value, missing value, "")		
	end script	

	script |convests transport text with a context into a task with context assigned|
		property parent : registerTestCase(me)
		
		set domain's _contextRepository to domain's ContextRepository
		
		set expectedTaskName to "Test convert transport text with context name into task with a context assigned"
		testUpdateTask("--" & expectedTaskName & " @" & CONTEXT_FIXTURE_NAME, expectedTaskName, false, missing value, contextFixture, missing value, missing value, missing value, "")
	end script	

	script |converts transport text with a non-existent context into a task with missing context left inline|
		property parent : registerTestCase(me)
		
		set domain's _contextRepository to domain's ContextRepository

		set expectedTaskName to "--Test leave transport text alone  @asdfghjkl;"
		testUpdateTask(expectedTaskName, expectedTaskName, false, missing value, missing value, missing value, missing value, missing value, "")
	end script	

	script |test update task with task, project|
		property parent : registerTestCase(me)
		
		set domain's _projectRepository to domain's ProjectRepository
		
		set expectedTaskName to "My New Task P1"
		testUpdateTask("--" & expectedTaskName & " ::" & PROJECT_FIXTURE_NAME & "", expectedTaskName, false, projectFixture, missing value, missing value, missing value, missing value, "")
	end script	

	script |handle transport text with  non-existent project|
		property parent : registerTestCase(me)
		
		set domain's _projectRepository to domain's ProjectRepository

		set expectedTaskName to "--My New Task P2 ::asdfghjkl;"
		testUpdateTask(expectedTaskName, expectedTaskName, false, missing value, missing value, missing value, missing value, missing value, "")
	end script	

	script |handle transport text with due and defer dates|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "My New Task due defer"
		testUpdateTask("--" & expectedTaskName & " #06/21/2015 #06/22/2015 02:00PM", expectedTaskName, false, missing value, missing value, date "06/21/2015", date "06/22/2015 02:00PM", missing value, "")
	end script	

	script |handle transport text with due and defer dates and a note|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "My New Task due defer note"
		testUpdateTask("--" & expectedTaskName & " #06/26/2015 #06/25/2015 02:00PM //I'm a note!", expectedTaskName, false, missing value, missing value, date "06/26/2015", date "06/25/2015 02:00PM", missing value, "I'm a note!")
	end script	

	script |converts transport text with due dates into a task|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "My New Task"
		testUpdateTask("--" & expectedTaskName & " #06/25/2015 02:00PM", expectedTaskName, false, missing value, missing value, missing value, date "06/25/2015 02:00PM", missing value, "")
	end script	

	script |converts transport text with an estimate in minutes into a task|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "My New Task"
		testUpdateTask("--" & expectedTaskName & " $5m", expectedTaskName, false, missing value, missing value, missing value, missing value, 5, "")
	end script	

	script |converts transport text with an estimate in hours into a task|
		property parent : registerTestCase(me)
		
		set expectedTaskName to "My New Task"
		testUpdateTask("--" & expectedTaskName & " $1h", expectedTaskName, false, missing value, missing value, missing value, missing value, 60, "")
	end script	

	script |handle transport text without flags|
		property parent : registerTestCase(me)

		set domain's _projectRepository to domain's ProjectRepository
		set domain's _contextRepository to domain's ContextRepository

		set expectedTaskName to "My New Task all stops"
		testUpdateTask("--" & expectedTaskName & " ::" & PROJECT_FIXTURE_NAME & " @" & CONTEXT_FIXTURE_NAME & " #06/23/2015 5:00pm $5m //I wanna rock and roll all night", expectedTaskName, false, projectFixture, contextFixture, missing value, date "06/23/2015 05:00PM", 5, "I wanna rock and roll all night")
	end script	
	
	script |should update values from transport text when not set on task|
		property parent : registerTestCase(me)
			
		set aTask to createTask("--Foo ! ::" & PROJECT_FIXTURE_NAME & " @Test Context #2015-04-15 #2015-05-15 $5m //Arbitrary note")
	
		tell domain's TransportTextParsingService to updateTaskPropertiesFromName(aTask)
		
		my assertEqual("Foo", aTask's getName())
		my assertEqual(true, aTask's _flaggedValue())
		my assertEqual(projectFixture, aTask's _containingProjectValue())
		my assertEqual(contextFixture, aTask's _contextValue())
		my assertEqual(date "2015-04-15 12:00am", aTask's _deferDateValue())
		my assertEqual(date "2015-05-15 5:00pm", aTask's _dueDateValue())
		my assertEqual(5, aTask's _estimatedMinutesValue())
		my assertEqual("Arbitrary note", aTask's _noteValue()'s text)
		
	end script

	script |should not update task values from transport text when properties already set on task|
		property parent : registerTestCase(me)
	
		set end of contextList to domain's ContextRepository's create("Another Test Context")
		set end of projectList to domain's ProjectRepository's create("Another Test Project")
		
		set aTask to createTask("--Foo ! ::Another Test Project @Another Test Context #2015-04-15 #2015-05-15 $5m //Arbitrary note")
		
		tell aTask to assignToProject(projectFixture)
		tell aTask to assignToContext(contextFixture)
		tell aTask to deferUntil(date "2014-04-15")
		tell aTask to dueOn(date "2014-05-15")
		tell aTask to setEstimate(10)
			
		tell domain's TransportTextParsingService to updateTaskPropertiesFromName(aTask)

		assertEqual("Foo", aTask's getName())
		assertEqual(true, aTask's _flaggedValue())
		assertEqual(projectFixture, aTask's _containingProjectValue())
		assertEqual(contextFixture, aTask's _contextValue())
		assertEqual(date "2014-04-15 12:00am", aTask's _deferDateValue())
		assertEqual(date "2014-05-15 12:00am", aTask's _dueDateValue())
		assertEqual(10, aTask's _estimatedMinutesValue())
		assertEqual("Arbitrary note", aTask's _noteValue()'s text)
		
	end script

	script |should not update task values from transport text when no valid values available|
		property parent : registerTestCase(me)
		
		set aTask to createTask("--Foo ! ::Non-existent Project 1 @Non-existent Context #2015-04-15 #2015-05-15 $5m //Arbitrary note")
				
		tell domain's TransportTextParsingService to updateTaskPropertiesFromName(aTask)
				
		assertEqual("--Foo ::Non-existent Project 1 @Non-existent Context", aTask's getName())
		assertEqual(true, aTask's _flaggedValue())
		assertEqual(missing value, aTask's _containingProjectValue())
		assertEqual(missing value, aTask's _contextValue())
		assertEqual(date "2015-04-15", aTask's _deferDateValue())
		assertEqual(date "2015-05-15 5:00pm", aTask's _dueDateValue())
		assertEqual(5, aTask's _estimatedMinutesValue())
		
	end script	
end script
