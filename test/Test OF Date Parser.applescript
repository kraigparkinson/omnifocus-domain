(*!
	@header OFDateParser
		OFDateParser self tests.
	@abstract License: GNU GPL, see COPYING for details.
	@author Kraig Parkinson
	@copyright 2015 kraigparkinson
*)

property OFDateParser : script "com.kraigparkinson/OFDateParser"

property parent : script "com.lifepillar/ASUnit"
property suite : makeTestSuite("OF Date Parser")

my autorun(suite)

script |Parse Dates|
	property parent : TestSet(me)
	
	on setUp()
	end setUp
	
	on tearDown()
	end tearDown
	
	script |parse today works|
		property parent : UnitTest(me)
		
		set today to current date
		
		tell OFDateParser
			my shouldEqual(today, parseDate("today"))
		end tell
	end script
	
	script |parse tomorrow works|
		property parent : UnitTest(me)
		
		set tomorrow to current date
		set day of tomorrow to (day of tomorrow) + 1
		
		tell OFDateParser
			
			my shouldEqual(tomorrow, parseDate("tomorrow"))
			my shouldEqual(tomorrow, parseDate("tom"))
		end tell
	end script
	
	script |parse due date|
		property parent : UnitTest(me)
		
		set today to current date
		set today to date "5:00 PM" of today
		
		local actualDate
		tell OFDateParser
			set actualDate to parseDueDate("today")
		end tell
		
		my shouldEqual(today, actualDate)
	end script

	script |parse defer date|
		property parent : UnitTest(me)
		
		set today to current date
		set today to date "12:00 AM" of today
		
		local actualDate
		tell OFDateParser
			set actualDate to parseDeferDate("today")
		end tell
		
		my shouldEqual(today, actualDate)
	end script
end script
