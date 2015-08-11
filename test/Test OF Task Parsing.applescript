(*!
	@header OFTaskParser
		OFTaskParser self tests.
	@abstract License: GNU GPL, see COPYING for details.
	@author Kraig Parkinson
	@copyright 2015 kraigparkinson
*)

use OFTaskParser : script "com.kraigparkinson/OFTaskParser"
use DateFormatter : script "com.kraigparkinson/DateFormatter"
use ASUnit : script "com.lifepillar/ASUnit"

property parent : ASUnit
property suite : makeTestSuite("OF Task Parsing")
--autorun(suite)

my autorun(suite)

script |Parse Tasks|
	property parent : TestSet(me)
	property taskList : missing value
	
	(*
	on shouldEqual(expected, actual)
		should(expected is equal to actual, "Expected: '" & expected & "', Actual: '" & actual & "'")
	end shouldEqual
	*)
	
	on setUp()
		tell application "OmniFocus"
			set taskList to parse tasks into default document with transport text "Dummy" with as single task
		end tell
	end setUp
	
	on tearDown()
		repeat with aTask in taskList
			tell application "OmniFocus"
				delete aTask
			end tell
		end repeat
	end tearDown
	
	script |parse project works|
		property parent : UnitTest(me)
		
		--tell script "OFTaskParser"
		tell OFTaskParser
			
			my shouldEqual("", parseProjectNameFromTaskName("::Project Name"))
			my shouldEqual("Project Name", parseProjectNameFromTaskName("Task Name ::Project Name"))
			my shouldEqual("", parseProjectNameFromTaskName("Task Name @Context Name"))
			my shouldEqual("Project Name", parseProjectNameFromTaskName("Task Name ::Project Name @Context Name #2015-05-23"))
			my shouldEqual("", parseProjectNameFromTaskName("Task Name @Context Name #2015-05-23 #2015-05-23"))
			my shouldEqual("Project Name", parseProjectNameFromTaskName("Task Name ::Project Name @Context Name #2015-05-23 #2015-05-23 $5m"))
			my shouldEqual("", parseProjectNameFromTaskName("Task Name #2015-05-23 #2015-05-23 $5m"))
		end tell
		
	end script
	
	script |parse context works|
		property parent : UnitTest(me)
		
		tell script "OFTaskParser"
			
			my shouldEqual("", parseContextNameFromTaskName("Task Name ::Project Name"))
			my shouldEqual("", parseContextNameFromTaskName("@Context Name"))
			my shouldEqual("Context Name", parseContextNameFromTaskName("Task Name @Context Name"))
			my shouldEqual("Context Name", parseContextNameFromTaskName("Task Name @Context Name #2015-05-23"))
			my shouldEqual("Context Name", parseContextNameFromTaskName("Task Name @Context Name #2015-05-23 #2015-05-23"))
			my shouldEqual("Context Name", parseContextNameFromTaskName("Task Name @Context Name #2015-05-23 #2015-05-23 $5m"))
			my shouldEqual("", parseContextNameFromTaskName("Task Name #2015-05-23 #2015-05-23 $5m"))
		end tell
	end script
	
	script |parse due date works|
		property parent : UnitTest(me)
		
		tell OFTaskParser
			my shouldEqual(missing value, parseDueDateFromTaskName("Task Name ::Project Name"))
			my shouldEqual(missing value, parseDueDateFromTaskName("Task Name @Context Name"))
			my shouldEqual(date "Saturday, May 23, 2015 at 2:00:00 PM", parseDueDateFromTaskName("Task Name @Context Name #05/23/2015 02:00PM"))
			my shouldEqual(date "Sunday, May 24, 2015 at 12:00:00 AM", parseDueDateFromTaskName("Task Name @Context Name #2015-05-23 #2015-05-24"))
			my shouldEqual(date "Sunday, May 24, 2015 at 12:00:00 AM", parseDueDateFromTaskName("Task Name @Context Name #2015-05-23 #2015-05-24 $5m"))
			my shouldEqual(date "Sunday, May 24, 2015 at 12:00:00 AM", parseDueDateFromTaskName("Task Name #2015-05-23 #2015-05-24 $5m"))
			my shouldEqual(date "Saturday, May 23, 2015 at 12:00:00 AM", parseDueDateFromTaskName("Task Name #2015-05-23 $5m"))
		end tell
	end script
	
	script |parse defer date works|
		property parent : UnitTest(me)
		
		tell OFTaskParser
			my shouldEqual(missing value, parseDeferDateFromTaskName("Task Name ::Project Name"))
			my shouldEqual(missing value, parseDeferDateFromTaskName("Task Name @Context Name"))
			my shouldEqual(missing value, parseDeferDateFromTaskName("Task Name @Context Name #2015-05-23"))
			my shouldEqual(date "Saturday, May 23, 2015 at 12:00:00 AM", parseDeferDateFromTaskName("Task Name @Context Name #2015-05-23 #2015-05-24"))
			my shouldEqual(date "Saturday, May 23, 2015 at 12:00:00 AM", parseDeferDateFromTaskName("Task Name @Context Name #2015-05-23 #2015-05-24 $5m"))
			my shouldEqual(date "Saturday, May 23, 2015 at 12:00:00 AM", parseDeferDateFromTaskName("Task Name #2015-05-23 #2015-05-24 $5m"))
			my shouldEqual(missing value, parseDeferDateFromTaskName("Task Name #2015-05-23 $5m"))
		end tell
		
	end script
	
	script |parse estimate works|
		property parent : UnitTest(me)
		
		tell OFTaskParser
			my shouldEqual(missing value, parseEstimateFromTaskName("Task Name ::Project Name"))
			my shouldEqual(5, parseEstimateFromTaskName("Task Name $5m"))
			my shouldEqual(60, parseEstimateFromTaskName("Task Name $1h"))
		end tell
		
	end script
	
	script |set context from task name|
		property parent : UnitTest(me)
		
		set expectedTaskName to "My New Task"
		set expectedContextName to "Hygiene"
		set unparsedTaskName to expectedTaskName & " @" & expectedContextName
		
		set newTask to first item in taskList
		
		tell application "OmniFocus"
			set name of newTask to unparsedTaskName
			
			tell OFTaskParser to reparseTaskPropertiesFromTaskName(newTask)
			
			my shouldEqual(expectedTaskName, name of newTask)
			my shouldEqual(missing value, containing project of newTask)
			my shouldEqual(expectedContextName, name of context of newTask)
			my shouldEqual(missing value, due date of newTask)
			my shouldEqual(missing value, defer date of newTask)
		end tell
	end script
	
	script |set project from task name|
		property parent : UnitTest(me)
		
		set expectedTaskName to "My New Task"
		set expectedProjectName to "Miscellaneous"
		set unparsedTaskName to expectedTaskName & " ::" & expectedProjectName
		
		set newTask to first item in taskList
		
		tell application "OmniFocus"
			set name of newTask to unparsedTaskName
		end tell
		
		tell OFTaskParser
			reparseTaskPropertiesFromTaskName(newTask)
		end tell
		
		tell application "OmniFocus"
			
			my shouldEqual(expectedTaskName, name of newTask)
			my shouldEqual(expectedProjectName, name of the containing project of the newTask)
			my shouldEqual(missing value, context of the newTask)
			my shouldEqual(missing value, due date of newTask)
			my shouldEqual(missing value, defer date of newTask)
			
		end tell
		
	end script
	
	script |leave project if it doesn't exist|
		property parent : UnitTest(me)
		
		set expectedTaskName to "My New Task"
		set expectedProjectName to "asdfghjkl;"
		set unparsedTaskName to expectedTaskName & " ::" & expectedProjectName
		
		set newTask to first item in taskList
		
		tell application "OmniFocus"
			set name of newTask to unparsedTaskName
		end tell
		
		tell OFTaskParser
			reparseTaskPropertiesFromTaskName(newTask)
		end tell
		
		tell application "OmniFocus"
			my shouldEqual(expectedTaskName, name of newTask)
			my shouldEqual(missing value, containing project of the newTask)
			my shouldEqual(missing value, context of the newTask)
			my shouldEqual(missing value, due date of newTask)
			my shouldEqual(missing value, defer date of newTask)
		end tell
		
	end script
	
	script |leave context if it doesn't exist|
		property parent : UnitTest(me)
		
		set expectedTaskName to "My New Task"
		set expectedContextName to "asdfghjkl;"
		set unparsedTaskName to expectedTaskName & " @" & expectedContextName
		
		set newTask to first item in taskList
		
		tell application "OmniFocus"
			set name of newTask to unparsedTaskName
		end tell
		
		tell OFTaskParser
			reparseTaskPropertiesFromTaskName(newTask)
		end tell
		
		tell application "OmniFocus"
			my shouldEqual(expectedTaskName, name of newTask)
			my shouldEqual(missing value, containing project of the newTask)
			my shouldEqual(missing value, context of the newTask)
			my shouldEqual(missing value, due date of newTask)
			my shouldEqual(missing value, defer date of newTask)
		end tell
		
	end script
	
	script |set due date from task name|
		property parent : UnitTest(me)
		
		set expectedTaskName to "My New Task"
		set expectedDueDateText to "06/25/2015 02:00PM"
		set expectedDueDate to date expectedDueDateText
		set unparsedTaskName to expectedTaskName & " #" & expectedDueDateText
		
		set newTask to first item in taskList
		
		tell application "OmniFocus"
			set name of newTask to unparsedTaskName
		end tell
		
		tell OFTaskParser
			reparseTaskPropertiesFromTaskName(newTask)
		end tell
		
		tell application "OmniFocus"
			
			my shouldEqual(expectedTaskName, name of newTask)
			my shouldEqual(missing value, containing project of newTask)
			my shouldEqual(missing value, context of newTask)
			my shouldEqual(expectedDueDate, due date of the newTask)
			my shouldEqual(missing value, defer date of the newTask)
		end tell
		
	end script
	
	script |set defer date from task name|
		property parent : UnitTest(me)
		
		set expectedTaskName to "My New Task"
		set expectedDueDateText to "06/25/2015"
		set expectedDueDate to date expectedDueDateText
		set expectedDeferDateText to "06/26/2015"
		set expectedDeferDate to date expectedDeferDateText
		set unparsedTaskName to expectedTaskName & " #" & expectedDeferDateText & " #" & expectedDueDateText
		
		set newTask to first item in taskList
		
		tell application "OmniFocus"
			set name of newTask to unparsedTaskName
		end tell
		
		tell OFTaskParser
			reparseTaskPropertiesFromTaskName(newTask)
		end tell
		
		tell application "OmniFocus"
			my shouldEqual(expectedTaskName, name of newTask)
			my shouldEqual(missing value, containing project of newTask)
			my shouldEqual(missing value, context of newTask)
			my shouldEqual(expectedDueDate, due date of the newTask)
			my shouldEqual(expectedDeferDate, defer date of the newTask)
			my shouldEqual(missing value, estimated minutes of the newTask)
		end tell
	end script
	
	script |set estimated minutes from task name with minutes|
		property parent : UnitTest(me)
		
		set expectedTaskName to "My New Task"
		set expectedEstimate to 5
		set unparsedTaskName to expectedTaskName & " $" & expectedEstimate & "m"
		
		set newTask to first item in taskList
		
		tell application "OmniFocus"
			set name of newTask to unparsedTaskName
		end tell
		
		tell OFTaskParser
			reparseTaskPropertiesFromTaskName(newTask)
		end tell
		
		tell application "OmniFocus"
			my shouldEqual(expectedTaskName, name of newTask)
			my shouldEqual(missing value, containing project of newTask)
			my shouldEqual(missing value, context of newTask)
			my shouldEqual(missing value, due date of the newTask)
			my shouldEqual(missing value, defer date of the newTask)
			my shouldEqual(expectedEstimate, estimated minutes of newTask)
		end tell
	end script
	
	script |set estimated minutes from task name with hours|
		property parent : UnitTest(me)
		
		set expectedTaskName to "My New Task"
		set expectedEstimate to 60
		set unparsedTaskName to expectedTaskName & " $1h"
		
		set newTask to first item in taskList
		
		tell application "OmniFocus"
			set name of newTask to unparsedTaskName
		end tell
		
		tell OFTaskParser
			reparseTaskPropertiesFromTaskName(newTask)
		end tell
		
		tell application "OmniFocus"
			my shouldEqual(expectedTaskName, name of newTask)
			my shouldEqual(missing value, containing project of newTask)
			my shouldEqual(missing value, context of newTask)
			my shouldEqual(missing value, due date of the newTask)
			my shouldEqual(missing value, defer date of the newTask)
			my shouldEqual(expectedEstimate, estimated minutes of newTask)
		end tell
	end script
	
	script |set everything|
		property parent : UnitTest(me)
		
		set expectedTaskName to "My New Task"
		set expectedProjectName to "Miscellaneous"
		set expectedContextParentName to "Hanging Around"
		set expectedContextName to "Read/Review"
		--		set expectedContextName to "Hygiene"
		set expectedDueDateText to "06/23/2015"
		set expectedDueDate to date expectedDueDateText
		set expectedEstimate to 5
		set unparsedTaskName to expectedTaskName & " ::" & expectedProjectName & " @" & expectedContextParentName & ":" & expectedContextName & " #" & expectedDueDateText & " $" & expectedEstimate & "m"
		
		set newTask to first item in taskList
		
		tell application "OmniFocus"
			set name of newTask to unparsedTaskName
		end tell
		
		tell OFTaskParser
			reparseTaskPropertiesFromTaskName(newTask)
		end tell
		
		tell application "OmniFocus"
			my shouldEqual(expectedTaskName, name of newTask)
			my shouldEqual(expectedProjectName, name of containing project of newTask)
			my shouldNotEqual(missing value, context of newTask)
			my shouldEqual(expectedContextName, name of context of newTask)
			my shouldEqual(expectedContextParentName, name of container of context of newTask)
			my shouldEqual(expectedDueDate, due date of the newTask)
			my shouldEqual(missing value, defer date of the newTask)
			my shouldEqual(expectedEstimate, estimated minutes of newTask)
		end tell
	end script
	
	script |find context from partially qualified name|
		property parent : UnitTest(me)
		
		
		tell OFTaskParser
			my should(findContextFromName("Hygiene") is not missing value, "Couldn't find partially qualified, nested Hygiene context.")
			my should(findContextFromName("Considerations") is not missing value, "Couldn't find partially qualified, top-level solo Considerations context.")
			
			my should(findContextFromName("Limited Attention") is not missing value, "Couldn't find partially qualified, top-level Limited Attention context.")
			my should(findContextFromName("Thinking") is not missing value, "Couldn't find partially qualified, top-level Thinking context.")
			
			set actualContext to findContextFromName("Read/Review")
			
			tell application "OmniFocus"
				my should(actualContext is not missing value, "Couldn't find the 'read/review' context")
				my shouldEqual("Thinking", name of container of actualContext)
			end tell
		end tell
		
	end script
	
	script |find context from fully qualified name|
		property parent : UnitTest(me)
		
		local myContext
		
		tell OFTaskParser
			my shouldNotEqual(missing value, findContextFromName("Limited Attention:Hygiene"))
			
			set actualContext to findContextFromName("Hanging Around:Read/Review")
			my shouldNotEqual(missing value, actualContext)
			tell application "OmniFocus"
				my shouldEqual("Hanging Around", name of container of actualContext)
			end tell
		end tell
		
	end script
	
	script |make pretty dates for OF without timezones and seconds|
		property parent : UnitTest(me)
		
		tell DateFormatter
			my shouldEqual("", reformatDateTimeStampToOF(""))
			--shouldEqual("STOP", reformatDateTimeStampToOF("STOP"))
			my shouldEqual("2015-06-19", reformatDateTimeStampToOF("2015-06-19"))
			my shouldEqual("17:25:39-0600", reformatDateTimeStampToOF("17:25:39-0600"))
			my shouldEqual("2015-06-19 at 17:25", reformatDateTimeStampToOF("2015-06-19T17:25:39-0600"))
		end tell
	end script
	
	script |can trim seconds from dates|
		property parent : UnitTest(me)
		
		tell DateFormatter
			my shouldEqual("", trimSeconds(""))
			my shouldEqual("17:25", trimSeconds("17:25"))
			my shouldEqual("17:25", trimSeconds("17:25:39"))
			my shouldEqual("2015-06-19T17:25", trimSeconds("2015-06-19T17:25:39"))
			my shouldEqual("2015-06-19T17:30", trimSeconds("2015-06-19T17:30:39"))
		end tell
	end script
	
	script |can trim time zones from dates|
		property parent : UnitTest(me)
		
		tell DateFormatter
			
			my shouldEqual("", trimTimeZone(""))
			my shouldEqual("2015-06-19T17:25:39", trimTimeZone("2015-06-19T17:25:39-0600"))
		end tell
	end script
	
	script |parse tasks without dates|
		property parent : UnitTest(me)
		
		tell DateFormatter
			
			my shouldEqual("Uncanny", tidyTaskName("Uncanny"))
			my shouldEqual("Uncanny $5m", tidyTaskName("Uncanny $5m"))
			my shouldEqual("Topical thing", tidyTaskName("Topical thing"))
			my shouldEqual("IATA project", tidyTaskName("IATA project"))
			
			my shouldEqual("Uncanny @Hygiene $5m", tidyTaskName("Uncanny @Hygiene $5m"))
			my shouldEqual("Uncanny set-up @Hygiene", tidyTaskName("Uncanny set-up @Hygiene"))
		end tell
	end script
	
	script |parse tasks with just Due Dates|
		property parent : UnitTest(me)
		
		tell DateFormatter
			
			my shouldEqual("Uncanny #2015-06-19 at 17:25", tidyTaskName("Uncanny #2015-06-19T17:25:39-0600"))
			my shouldEqual("Uncanny #2015-07-19 at 17:25 $5", tidyTaskName("Uncanny #2015-07-19T17:25:39-0600 $5"))
		end tell
	end script
	
	script |parse tasks with no subject and a due date|
		property parent : UnitTest(me)
		
		tell DateFormatter
			my shouldEqual("#2015-05-19 at 17:25", tidyTaskName("#2015-05-19T17:25:39-0600"))
		end tell
	end script
	
	script |parse tasks with hyphenated task names|
		property parent : UnitTest(me)
		
		tell DateFormatter
			
			my shouldEqual("Uncanny worlds-of-wonder #2015-06-19 at 17:25", tidyTaskName("Uncanny worlds-of-wonder #2015-06-19T17:25:39-0600"))
			my shouldEqual("Uncanny worlds-of-wonder #2015-06-19 at 00:00 #2015-06-20 at 17:00", tidyTaskName("Uncanny worlds-of-wonder #2015-06-19T00:00:39-0600 #2015-06-20T17:00:22-0600"))
		end tell
	end script
	
	script |parse tasks with due and defer dates|
		property parent : UnitTest(me)
		
		tell DateFormatter
			my shouldEqual("Uncanny #2015-06-19 at 17:25 #2015-06-21 at 17:00", tidyTaskName("Uncanny #2015-06-19T17:25:39-0600 #2015-06-21T17:00:00-0600"))
			my shouldEqual("Uncanny #2015-06-19 at 17:25 #2015-06-21 at 17:00 $5m", tidyTaskName("Uncanny #2015-06-19T17:25:39-0600 #2015-06-21T17:00:00-0600 $5m"))
		end tell
	end script
	
	script |parse tasks with Due Dates and Contexts|
		property parent : UnitTest(me)
		
		tell DateFormatter
			
			my shouldEqual("Uncanny @Hygiene #2015-06-19 at 17:25", tidyTaskName("Uncanny @Hygiene #2015-06-19T17:25:39-0600"))
			my shouldEqual("Uncanny @Hygiene #2015-06-19 at 17:25 #2015-06-20 at 17:00 $5m", tidyTaskName("Uncanny @Hygiene #2015-06-19T17:25:39-0600 #2015-06-20T17:00:39-0600 $5m"))
			my shouldEqual("Foo @Hygiene #2015-06-22 at 00:19 #2015-06-22 at 00:19 $5m", tidyTaskName("Foo @Hygiene #2015-06-22T00:19:43-0600 #2015-06-22T00:19:51-0600 $5m"))
		end tell
	end script
	
	
end script
