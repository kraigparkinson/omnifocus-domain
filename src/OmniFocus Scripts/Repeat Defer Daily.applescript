property domain : script "com.kraigparkinson/OmniFocusDomain"

tell application "OmniFocus"
	tell content of first document window of front document
		--Get selection
		set validSelectedItemsList to value of (selected trees where class of its value is not item and class of its value is not folder)
		
		if (count of validSelectedItemsList) is 0 then
			set alertName to "Error"
			set alertTitle to "Script failure"
			set alertText to "No valid task(s) selected"
			--	my notify(alertName, alertTitle, alertText)
			return
		end if
		
		repeat with selectedTask in validSelectedItemsList
			set aCommand to domain's RepeatDeferDailyCommand's constructCommand()
			tell aCommand to execute(selectedTask)
		end repeat
	end tell
	
end tell