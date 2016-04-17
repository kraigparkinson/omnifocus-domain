(*!
	@header Test OmniFocus Rule Parsing Daemon self tests.
	@abstract License: GNU GPL, see COPYING for details.
	@author Kraig Parkinson
	@copyright 2015 kraigparkinson
*)
property rules : script "com.kraigparkinson/OmniFocus Rules Engine"
property domain : script "com.kraigparkinson/OmniFocusDomain"
property textutil : script "com.kraigparkinson/ASText"

property parent : script "com.lifepillar/ASUnit"
property suite : makeTestSuite("OmniFocus Rules Engine")


my autorun(suite)

script MockTarget
	property parent : rules's OmniFocusRuleTarget

	on construct()
		set tasks to { missing value }
	end construct	
end script

script |AbstractOmniFocusRuleSet| 
	property parent : TestSet(me)
	
	property taskFixtures : { }
	
	on setUp()
		set taskFixtures to { }
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in my taskFixtures
				delete aTask
			end repeat
		end tell
	end tearDown

	on createInboxTask(transportText)
		set newTask to domain's TaskRepository's createInboxTaskWithName(transportText)
		set end of taskFixtures to newTask		
		return newTask 		
	end createInboxTask
	
	script |test process empty set does nothing|
		property parent : UnitTest(me)
	
		copy rules's AbstractOmniFocusRuleSet to aRuleSet
		tell aRuleSet to addTargetConfig(MockTarget, { })
				
		try
			tell aRuleSet to processAll()
		on error message
			fail("Should have completed without error: " & message)
		end try
	end script
	
	script FailedProcessingRule
		property parent : rules's OmniFocusTaskProcessingRule
		
		on matchTask(aTask, inputAttributes)
			return true
		end matchTask
		
		on processTask(aTask, inputAttributes)
			error "Intentionally failing rule"
		end processTask
	end script
	
	script SuccessfulMatchRule
		property parent : rules's OmniFocusTaskProcessingRule
		
		on matchTask(aTask, inputAttributes)
			return true
		end matchTask
		
		on processTask(aTask, inputAttributes)
			return { ruleStop:false }
		end processTask
	end script

	script FailedMatchRule
		property parent : rules's OmniFocusTaskProcessingRule
		
		on matchTask(aTask, inputAttributes)
			return false
		end matchTask
		
		on processTask(aTask, inputAttributes)
			fail()
		end processTask
	end script

	script StopProcessingRule
		property parent : rules's OmniFocusTaskProcessingRule
		
		on matchTask(aTask, inputAttributes)
			return true
		end matchTask
		
		on processTask(aTask, inputAttributes)
			return { ruleStop:true }
		end processTask
	end script
			
	script |test process all completes even when rules throw errors|
		property parent : UnitTest(me)
	
		set aTarget to MockTarget
		set theRules to { FailedProcessingRule }
				
		copy rules's AbstractOmniFocusRuleSet to aRuleSet
		tell aRuleSet to addTargetConfig(aTarget, theRules)
		
		try
			tell aRuleSet to processAll()
		on error message
			fail("Should have completed without error: " & message)
		end try
	end script
	
	script |test process all stops future rules when is told to stop|
		property parent : UnitTest(me)

		set aTarget to MockTarget
		set theRules to { StopProcessingRule, FailedProcessingRule }
				
		copy rules's AbstractOmniFocusRuleSet to aRuleSet
		tell aRuleSet to addTargetConfig(aTarget, theRules)
		
		try
			tell aRuleSet to processAll()
		on error message
			fail("Should have completed without error: " & message)
		end try
	end script
	
	script |test rule skips processing at failed match|
		property parent : UnitTest(me)

		set aTarget to MockTarget
		set theRules to { FailedMatchRule }
			
		copy rules's AbstractOmniFocusRuleSet to aRuleSet
		tell aRuleSet to addTargetConfig(aTarget, theRules)
	
		try
			tell aRuleSet to processAll()
		on error message
			fail("Should have completed without error: " & message)
		end try
	end script
	
end script

script |DeferDailyRepeatRule|
	property parent : TestSet(me)

	property taskFixtures : { }
	
	on setUp()
		set taskFixtures to { }
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in my taskFixtures
				delete aTask
			end repeat
		end tell
	end tearDown

	on createInboxTask(transportText)
		set newTask to domain's TaskRepository's createInboxTaskWithName(transportText)
		set end of taskFixtures to newTask		
		return newTask 		
	end createInboxTask

	script |add defer repeat rule matches with correct token|
		property parent : UnitTest(me)
				
		set matchingTask to createInboxTask("Foo >>1d")
		set anotherMatchingTask to createInboxTask("Foo >>2d")
		
		set aRule to rules's DeferDailyRepeatRule
		set actual to aRule's matchTask(matchingTask, { })
		
		assertInstanceOf(record, actual)		
		assertEqual(true, actual's passesCriteria)
		refuteMissing(actual's outputAttributes)
		assertEqual("1d", actual's outputAttributes's repetitionPattern)
		
		set actual to aRule's matchTask(anotherMatchingTask, { })
		
		assertInstanceOf(record, actual)		
		assertEqual(true, actual's passesCriteria)
		refuteMissing(actual's outputAttributes)
		assertEqual("2d", actual's outputAttributes's repetitionPattern)

	end script
	
	script |add defer repeat rule does not match without correct token|
		property parent : UnitTest(me)
		
		set nonmatchingTask to createInboxTask("Foo")

		set aRule to rules's DeferDailyRepeatRule
		set actual to aRule's matchTask(nonmatchingTask, { })
		
		refute(actual, "Should have returned false.")		
	end script
	
	script |add defer repeat rule updates task with values|
		property parent : UnitTest(me)
				
		set matchingTask to createInboxTask("Foo >>1d")
--		set matchingTask to createInboxTask("Foo <<1d")
--		set matchingTask to createInboxTask("Foo ^^1d")
		set repetitionText to "1d"
		
		set aRule to rules's DeferDailyRepeatRule
		tell aRule to processTask(matchingTask, { repetitionPattern: repetitionText })
		
		tell application "OmniFocus"
			my assertEqual("Foo", matchingTask's name)
			my assertEqual({repetition method:start after completion, recurrence:"FREQ=DAILY"}, matchingTask's repetition rule)
		end tell

--		set anotherMatchingTask to createInboxTask("Foo >>2d")

--		tell aRule to processTask(anotherMatchingTask, { repetitionPattern: repetitionText })

--		tell application "OmniFocus"
--			my assertEqual("Foo", anotherMatchingTask's name)
--			my assertEqual({repetition method:start after completion, recurrence:"FREQ=DAILY"}, anotherMatchingTask's repetition rule)
--		end tell
	end script
	
		
end script

script |OmniFocus Rule Processing Daemon|
	property parent : TestSet(me)
	property taskFixtures : { }
	
	on setUp()
		set taskFixtures to { }
	end setUp
	
	on tearDown()
		tell application "OmniFocus"
			repeat with aTask in my taskFixtures
				delete aTask
			end repeat
		end tell
	end tearDown

	on createInboxTask(transportText)
		set newTask to domain's TaskRepository's createInboxTaskWithName(transportText)
		set end of taskFixtures to newTask		
		return newTask 		
	end createInboxTask
		

end script