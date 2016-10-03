property domain : script "com.kraigparkinson/OmniFocusDomain"

on selectedTasks()
	tell application "OmniFocus"
		with timeout of 3 seconds
			tell content of first document window of front document
				--Get selection
				return value of (selected trees where class of its value is not item and class of its value is not folder)
			end tell
		end timeout
	end tell
end selectedTasks

on run
	set validSelectedItemsList to selectedTasks()
	
	if (count of validSelectedItemsList) is 0 then
		set alertName to "Error"
		set alertTitle to "Script failure"
		set alertText to "No valid task(s) selected"
		--	my notify(alertName, alertTitle, alertText)
		return
	end if

	repeat with selectedTask in validSelectedItemsList
		set aCommand to domain's CommandFactory's makeDeferAnotherCommand("DAILY")
		tell aCommand to execute(selectedTask)
	end repeat
	
	
end run 

