(*! @abstract <em>[text]</em> Creating Flow with OmniFocus's name. *)
property name : "Creating Flow with OmniFocus Rules"
(*! @abstract <em>[text]</em> Creating Flow with OmniFocus's version. *)
property version : "1.0.0"
(*! @abstract <em>[text]</em> Creating Flow with OmniFocus's id. *)
property id : "com.kraigparkinson.Creating Flow with OmniFocus Rules"

--use OmniFocus : application "OmniFocus" --without importing

property textutil : script "com.kraigparkinson/ASText"
property ddd : script "com.kraigparkinson/ASDomainDrivenDesign"
property rules : script "com.kraigparkinson/OmniFocus Rules Engine"
property domain : script "com.kraigparkinson/OmniFocusDomain"
property oftt : script "com.kraigparkinson/OFTransportTextParsingApplication"

script SetContextCommand
	property parent : domain's TaskCommand
	property contextName : missing value
	
	on execute(aTask)
		set aContext to domain's ContextRepository's findByName(contextName)

		tell application "OmniFocus"
			set aTask's context to aContext
		end tell
	end execute
end script

script StripTokenFromTaskNameCommand
	property parent : domain's TaskCommand
	property token : missing value
	
	on execute(aTask)
		local taskName
		
		tell application "OmniFocus"
			set taskName to aTask's name
		end tell
		
		tell textutil
			set originalTaskNameStr to StringObj's makeString(taskName)
			set revisedTaskNameStr to originalTaskNameStr's removeText(token)
			set revisedTaskName to revisedTaskNameStr's asText()
		end tell

		tell application "OmniFocus"			
			set aTask's name to revisedTaskName
		end tell
	end execute
end script

script ReplaceTokenFromTaskNameCommand
	property parent : domain's TaskCommand
	property findToken : missing value
	property replaceToken : missing value
	
	on execute(aTask)
		local taskName
		
		tell application "OmniFocus"
			set taskName to aTask's name
		end tell
		
		set revisedTaskName to textutil's StringObj's makeString(taskName)'s replaceText(findToken, replaceToken)'s asText()

		tell application "OmniFocus"			
			set aTask's name to revisedTaskName
		end tell
	end execute
end script

script AppendTextToTaskNameCommand
	property parent : domain's TaskCommand
	property textToAppend : missing value
	
	on execute(aTask)
		local taskName
		
		tell application "OmniFocus"
			set taskName to aTask's name
		end tell
		
		set revisedTaskName to taskName & textToAppend

		tell application "OmniFocus"			
			set aTask's name to revisedTaskName
		end tell
	end execute
end script

script HasContextSpecification
	property parent : ddd's AbstractSpecification
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			return aTask's context is not missing value
		end tell
	end isSatisfiedBy
end script

script TaskNameMatchSpecification
	property parent : ddd's AbstractSpecification
	property taskNameSegment : missing value

	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			ignoring case
				return aTask's name contains my taskNameSegment
			end ignoring
		end tell
	end isSatisfiedBy
end script

script PastDueSpecification
	property parent : ddd's AbstractSpecification
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			set aDate to due date of aTask
		end tell

		return (aDate is not missing value) and (aDate comes before current date)
	end isSatisfiedBy
end script

script HasChildrenSpecification
	property parent : ddd's AbstractSpecification
	
	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			return aTask's number of tasks is greater than 0
		end tell
	end isSatisfiedBy
end script

script ConditionalCommand
	property parent : domain's TaskCommand
	property spec : missing value
	property command : missing value
	
	on execute(aTask)
		if (spec's isSatisfiedBy(aTask)) then tell command to execute(aTask)
	end execute
end script

script TidyConsiderationsRule
	property parent : rules's ConditionalCommandRule
	
	on prettyName()
		return "Tidy Considerations Rule"
	end prettyName
	
	on constructRule()
		set aRule to continue constructRule()

		set aSpec to TaskNameMatchSpecification's constructSpecification()
		set aSpec's taskNameSegment to "consider "
		
		tell aRule to addCondition(aSpec)
		tell aRule to addCondition(HasContextSpecification's notSpec())			
		
		set aCommand to SetContextCommand's constructCommand()
		set aCommand's contextName to "Considerations"
		
		tell aRule to addAction(aCommand)
		tell aRule to addAction(domain's RepeatDeferDailyCommand's constructCommand())
		
		return aRule
	end constructRule
end script

script AddDailyRepeatRule
	property parent : rules's ConditionalCommandRule
	
	on prettyName()
		return "Add Daily Repeat Rule"
	end prettyName
	
	on constructRule()
		set aRule to continue constructRule()

		set aSpec to TaskNameMatchSpecification's constructSpecification()
		set aSpec's taskNameSegment to " (Add daily repeat)"
		
		tell aRule to addCondition(aSpec)
		
		tell aRule to addAction(domain's RepeatDeferDailyCommand's constructCommand())
		
		set aCommand to StripTokenFromTaskNameCommand's constructCommand()
		set aCommand's token to " (Add daily repeat)"
		tell aRule to addAction(aCommand)
		
		return aRule
	end constructRule
end script

script ExpiredMeetingPreparationRule
	property parent : rules's ConditionalCommandRule
	
	on prettyName()
		return "Expired Meeting Preparation Rule"
	end prettyName
	
	on constructRule()
		set aRule to continue constructRule()

		set aSpec to TaskNameMatchSpecification's constructSpecification()
		set aSpec's taskNameSegment to "Prepare for your recurring meeting"
		
		set anotherSpec to TaskNameMatchSpecification's constructSpecification()
		set anotherSpec's taskNameSegment to "Prepare for your meeting"
		
		tell aRule to addCondition(aSpec's orSpec(anotherSpec))
		
		set aSpec to PastDueSpecification's constructSpecification()
		tell aRule to addCondition(aSpec)
		
	--	set aSpec to HasChildrenSpecification's constructSpecification()'s notSpec()
	--	tell aRule to addCondition(aSpec)
		
		tell aRule to addAction(domain's MarkCompleteCommand's constructCommand())		
		return aRule
	end constructRule
end script

script ExpiredCheckMeetingParticipationRule
	property parent : rules's ConditionalCommandRule
	
	on prettyName()
		return "Expired Check Meeting Participation Rule"
	end prettyName
	
	on constructRule()
		set aRule to continue constructRule()

		set aSpec to TaskNameMatchSpecification's constructSpecification()
		set aSpec's taskNameSegment to "Check participation for your recurring meeting"
		
		tell aRule to addCondition(aSpec)
		
		set aSpec to PastDueSpecification's constructSpecification()
		tell aRule to addCondition(aSpec)
		
		tell aRule to addAction(domain's MarkCompleteCommand's constructCommand())		
		return aRule
	end constructRule
end script

script TaskNameStartsWithSpecification
	property parent : ddd's AbstractSpecification
	property taskNameSegment : missing value

	on isSatisfiedBy(aTask)
		tell application "OmniFocus"
			ignoring case
				return aTask's name starts with my taskNameSegment
			end ignoring
		end tell
	end isSatisfiedBy
end script

script EvernoteTaskClonePreparationRule
	property parent : rules's ConditionalCommandRule
	
	on prettyName()
		return "Evernote TaskClone Preparation Rule"
	end prettyName
	
	on constructRule()
		set aRule to continue constructRule()

		set aSpec to TaskNameStartsWithSpecification's constructSpecification()
		set aSpec's taskNameSegment to "|EN|"
		
		tell aRule to addCondition(aSpec)
		
		set aCommand to ReplaceTokenFromTaskNameCommand's constructCommand()
		set aCommand's findToken to "|EN| "
		set aCommand's replaceToken to "--"
		
		tell aRule to addAction(aCommand)		
		
		set aCommand to AppendTextToTaskNameCommand's constructCommand()
		set aCommand's textToAppend to " |EN| "
		
		tell aRule to addAction(aCommand)
		return aRule
	end constructRule
end script

script ProjectTarget
	property parent : rules's OmniFocusRuleTarget
	property projectName : missing value 

	on defineName()
		return "Project: Meetings to Prepare"
	end defineName
	
	on getTasks()
		set aProject to domain's ProjectRepository's findByName(projectName)
		
		local theTasks
		tell application "OmniFocus"
			set theTasks to aProject's tasks
		end tell
		
		return theTasks
		
	end getTasks

end script

script MeetingsToPrepareTarget
	property parent : rules's OmniFocusRuleTarget
	
	on defineName()
		return "Project: Meetings to Prepare"
	end defineName
	
	on getTasks()
		set aProject to domain's ProjectRepository's findByName("Meetings to plan")
		
		local theTasks
		tell application "OmniFocus"
			set theTasks to aProject's tasks
		end tell
		
		return theTasks
	end getTasks
end script

script DefaultRuleSet
	property parent : rules's AbstractOmniFocusRuleSet
	
	on constructRuleSet()
		set aRuleSet to continue constructRuleSet()		
		set theRules to { }
		set theRules's end to EvernoteTaskClonePreparationRule's constructRule()
		set theRules's end to oftt's OmniFocusTransportTextParsingRule's constructRule()
		set theRules's end to TidyConsiderationsRule's constructRule()
		set theRules's end to AddDailyRepeatRule's constructRule()
		set theRules's end to ExpiredMeetingPreparationRule's constructRule()
		set theRules's end to ExpiredCheckMeetingParticipationRule's constructRule()
		
		tell aRuleSet to addTargetConfig(rules's Inbox's construct(), theRules )

--		set aProjectTarget to ProjectTarget's construct()
--		set aProjectTarget's projectName to "Meetings to plan"
		set aProjectTarget to MeetingsToPrepareTarget's construct()
		tell aRuleSet to addTargetConfig(aProjectTarget, { ExpiredMeetingPreparationRule's constructRule() } )
		
--		set aDocumentTarget to rules's DocumentTarget's construct()
--		tell aRuleSet to addTargetConfig(aDocumentTarget, { ExpiredCheckMeetingParticipationRule's constructRule() } )
		
		return aRuleSet
	end constructRuleSet
end script 