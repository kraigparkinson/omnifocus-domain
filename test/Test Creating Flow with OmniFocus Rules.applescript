(*!
	@header Test OmniFocus Rule Parsing Daemon self tests.
	@abstract License: GNU GPL, see COPYING for details.
	@author Kraig Parkinson
	@copyright 2015 kraigparkinson
*)
property domain : script "com.kraigparkinson/OmniFocusDomain"
property cfr : script "com.kraigparkinson/Creating Flow with OmniFocus Rules"

property parent : script "com.lifepillar/ASUnit"
property suite : makeTestSuite("OmniFocus Rules Engine")


my autorun(suite)

script |Tidy Incomplete Consideration Tasks Rule| 
	property parent : TestSet(me)
	
	property taskFixtures : { }
	property contextFixtures : { }
	
	on setUp()
		set taskFixtures to { }
		set contextFixtures to { }
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in my taskFixtures
				delete aTask
			end repeat
		end tell
		tell application "OmniFocus"
			repeat with aContext in my contextFixtures
				delete aContext
			end repeat
		end tell
	end tearDown

	on createInboxTask(transportText)
		set newTask to domain's TaskRepository's createInboxTaskWithName(transportText)
		set end of taskFixtures to newTask		
		return newTask 		
	end createInboxTask
	
	on createContext(name)
		set newContext to domain's ContextRepository's create(name)
		set end of contextFixtures to newContext
		return newContext
	end createContext
	
	script |does not match when context is already set|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("Consider foo")
		set aContext to createContext("Test Context")
		
		tell application "OmniFocus"
			set aTask's context to aContext
		end tell
		
		set aRule to cfr's TidyConsiderationsRule's constructRule()
		
		set matchingResult to aRule's matchTask(aTask, { })
		
		refute(matchingResult, "Should not have matched.")
	end script

	script |matches when context is not set|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("Consider foo")
		
		set aRule to cfr's TidyConsiderationsRule's constructRule()
				
		set matchingResult to aRule's matchTask(aTask, { })
		
		assert(matchingResult, "Should have matched.")
	end script
	
	script |updates context and repetition rule to defer daily|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("Consider foo")
		set aContext to domain's ContextRepository's findByName("Considerations")
		
		set aRule to cfr's TidyConsiderationsRule's constructRule()
				
		tell aRule to processTask(aTask, { })
		
		tell application "OmniFocus"
			set expectedRepetitionRule to {repetition method:start after completion, recurrence:"FREQ=DAILY"}
			
			my assertEqual(aContext, aTask's context)
			my assertEqual(expectedRepetitionRule, aTask's repetition rule)
		end tell
		
	end script

end script

script |Add Daily Repeat Rule| 
	property parent : TestSet(me)
	
	property taskFixtures : { }
	property contextFixtures : { }
	
	on setUp()
		set taskFixtures to { }
		set contextFixtures to { }
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in my taskFixtures
				delete aTask
			end repeat
		end tell
		tell application "OmniFocus"
			repeat with aContext in my contextFixtures
				delete aContext
			end repeat
		end tell
	end tearDown

	on createInboxTask(transportText)
		set newTask to domain's TaskRepository's createInboxTaskWithName(transportText)
		set end of taskFixtures to newTask
		return newTask 		
	end createInboxTask
	
	on createContext(name)
		set newContext to domain's ContextRepository's create(name)
		set end of contextFixtures to newContext
		return newContext
	end createContext
	
	script |matches with text in name|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("Consider (Add daily repeat)")
				
		set aRule to cfr's AddDailyRepeatRule's constructRule()
		
		set matchingResult to aRule's matchTask(aTask, { })
		
		assert(matchingResult, "Should have matched.")
	end script

	script |does not match when text is not set|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("Consider foo")
		
		set aRule to cfr's AddDailyRepeatRule's constructRule()
				
		set matchingResult to aRule's matchTask(aTask, { })
		
		refute(matchingResult, "Should not have matched.")
	end script
	
	script |updates repetition rule to defer daily|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("Consider (Add daily repeat)")
		
		set aRule to cfr's AddDailyRepeatRule's constructRule()
				
		tell aRule to processTask(aTask, { })
		
		tell application "OmniFocus"
			set expectedRepetitionRule to {repetition method:start after completion, recurrence:"FREQ=DAILY"}
			my assertEqual("Consider", aTask's name)
			my assertEqual(expectedRepetitionRule, aTask's repetition rule)
		end tell
		
	end script

end script


script |Expired Meeting Preparation Rule| 
	property parent : TestSet(me)
	
	property taskFixtures : { }
	property contextFixtures : { }
	
	on setUp()
		set taskFixtures to { }
		set contextFixtures to { }
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in my taskFixtures
				delete aTask
			end repeat
		end tell
		tell application "OmniFocus"
			repeat with aContext in my contextFixtures
				delete aContext
			end repeat
		end tell
	end tearDown

	on createInboxTask(transportText)
		set newTask to domain's TaskRepository's createInboxTaskWithName(transportText)
		set end of taskFixtures to newTask		
		return newTask 		
	end createInboxTask
	
	on createContext(name)
		set newContext to domain's ContextRepository's create(name)
		set end of contextFixtures to newContext
		return newContext
	end createContext
	
	script |matches with text in name|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("Prepare for your meeting 'Foo'")
		tell application "OmniFocus"
			set aTask's due date to current date - 1 * days
		end tell
				
		set aRule to cfr's ExpiredMeetingPreparationRule's constructRule()
		
		set matchingResult to aRule's matchTask(aTask, { })
		
		assert(matchingResult, "Should have matched.")
	end script

	script |matches with recurring text in name|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("Prepare for your recurring meeting 'Foo'")
		tell application "OmniFocus"
			set aTask's due date to current date - 1 * days
		end tell
				
		set aRule to cfr's ExpiredMeetingPreparationRule's constructRule()
		
		set matchingResult to aRule's matchTask(aTask, { })
		
		assert(matchingResult, "Should have matched.")
	end script

	script |does not match when task is in the future|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("Prepare for your meeting 'Doe'")
		tell application "OmniFocus"
			set aTask's due date to current date + 1 * days
		end tell
		
		set aRule to cfr's ExpiredMeetingPreparationRule's constructRule()
				
		set matchingResult to aRule's matchTask(aTask, { })
		
		refute(matchingResult, "Should not have matched.")
	end script
	
	script |marks complete|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("Prepare for your meeting 'Doe'")
		tell application "OmniFocus"
			set aTask's due date to current date - 1 * days
		end tell
		
		set aRule to cfr's ExpiredMeetingPreparationRule's constructRule()
				
		tell aRule to processTask(aTask, { })
		
		tell application "OmniFocus"
			my assert(aTask's completed, "Should have marked completed.")
		end tell
		
	end script

end script

script |Evernote TaskClone Preparation Rule| 
	property parent : TestSet(me)
	
	property taskFixtures : { }
	property contextFixtures : { }
	
	on setUp()
		set taskFixtures to { }
		set contextFixtures to { }
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in my taskFixtures
				delete aTask
			end repeat
		end tell
		tell application "OmniFocus"
			repeat with aContext in my contextFixtures
				delete aContext
			end repeat
		end tell
	end tearDown

	on createInboxTask(transportText)
		set newTask to domain's TaskRepository's createInboxTaskWithName(transportText)
		set end of taskFixtures to newTask		
		return newTask 		
	end createInboxTask
	
	script |matches when token is in front|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("|EN| Catch up with Dave")
		
		set aRule to cfr's EvernoteTaskClonePreparationRule's constructRule()
		
		set matchingResult to aRule's matchTask(aTask, { })
		
		assert(matchingResult, "Should have matched.")
		
	end script	
	
	script |does not match when token isn't in front|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("Catch up with Dave |EN|")
				
		set aRule to cfr's EvernoteTaskClonePreparationRule's constructRule()
		
		set matchingResult to aRule's matchTask(aTask, { })
		
		refute(matchingResult, "Should not have matched.")
	end script
	
	script |replaces token|
		property parent : UnitTest(me)
		
		set aTask to createInboxTask("|EN| Catch up with Dave")
		
		set aRule to cfr's EvernoteTaskClonePreparationRule's constructRule()
				
		tell aRule to processTask(aTask, { })
		
		tell application "OmniFocus"
			my assertEqual("--Catch up with Dave |EN|", aTask's name)
		end tell
		
	end script
end script