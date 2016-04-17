(*! @abstract <em>[text]</em> OmniFocus Rule Processing Daemon's name. *)
property name : "OmniFocus Rules Engine"
(*! @abstract <em>[text]</em> OmniFocus Rule Processing Daemon's version. *)
property version : "1.0.0"
(*! @abstract <em>[text]</em> OmniFocus Rule Processing Daemon's id. *)
property id : "com.kraigparkinson.OmniFocus Rules Engine"

property domain : script "com.kraigparkinson/OmniFocusDomain"
property textutil : script "com.kraigparkinson/ASText"

script OmniFocusRuleTarget
	property tasks : { }
	property targetName : missing value
	
	on construct()
		copy me to aTarget
		set aTarget's tasks to getTasks() 
		set aTarget's targetName to defineName()
		return aTarget
	end construct
	
	on getTasks()
	end getTasks
	
	on defineName()
		error "Name of target must be defined."
	end defineName

	on accept(rules)
		log "Attempting to process " & count of rules & " rules for target, " & targetName & "."
		
		repeat with aRule in rules
			log "[OmniFocus rule target: " & targetName & "][" & aRule's prettyName() & "] Attempting to process " & count of tasks & " tasks."
			tell aRule to accept(tasks)
			log "[OmniFocus rule target: " & targetName & "][" & aRule's prettyName() & "] Finished processing " & count of tasks & " tasks."
		end repeat
		
		log "Finished processing " & count of rules & " rules for target, " & targetName & "."		
	end accept
end script

script Inbox
	property parent : OmniFocusRuleTarget
	
	on defineName()
		return "Inbox"
	end defineName
	
	on getTasks()
		return domain's TaskRepository's selectAllInboxTasks()
	end getTasks
end script

script DocumentTarget
	property parent : OmniFocusRuleTarget
	
	on defineName()
		return "All Tasks"
	end defineName
	
	on getTasks()
		return domain's TaskRepository's selectAll()
	end getTasks
end script

script UserSpecifiedTasks
	property parent : OmniFocusRuleTarget
	
	on defineName()
		return "User-Specified Tasks"
	end defineName
	
	on getTasks()
		return domain's TaskRepository's selectUserSpecifiedTasks()
	end getTasks
end script


script OmniFocusTaskProcessingRule	
	on constructRule()
		copy me to aRule
		return aRule
	end constructRule

	on prettyName()
		return "Unnammed Rule"
		--error "Rule name not specified."
	end prettyName

	(*
	@pre aTask must be an OmniFocus task
	@post Returns boolean or record
	*)
	on matchTask(aTask, inputAttributes)
	end matchTask
	
	(*
	@post Throws error if there's a problem processing rule.
	*)
	on processTask(aTask, inputAttributes)
	end processTask
	
	on accept(tasks)
		
		repeat with aTask in tasks
--				tell application "OmniFocus"
--					log "[OmniFocus rule target: " & targetName & "][" & aRule's prettyName() & "] Testing task with name: " & aTask's name
--				end tell
			
			set inputAttributes to { }
	
			set taskIsMatched to false

			try
				set matchResult to matchTask(aTask, inputAttributes)
			
	
				if ((matchResult's class is boolean) and matchResult) 
					set taskIsMatched to true
				else if (matchResult's class is record and matchResult's passesCriteria)
					set taskIsMatched to true
					set inputAttributes to matchResult's outputAttributes
				end if
			
			on error message
				log "[" & prettyName() & "] Error occurred matching rule: " & message
			end try
		
			
			if (taskIsMatched)
			
--				tell application "OmniFocus"
--						log "[OmniFocus rule target: " & targetName & "][" & aRule's prettyName() & "] Task matched. Name: " & aTask's name
--				end tell
				
				try
					set processResult to processTask(aTask, inputAttributes)
				
					if (processResult is not missing value and processResult is not null and processResult's class is record)
						if (ruleStop of processResult) then 
--								log "[OmniFocus rule target: " & targetName & "][" & aRule's prettyName() & "] Rule stopped. Name: " & aTask's name
							exit repeat
						end if
					end if 
					
--						tell application "OmniFocus"
--							log "[OmniFocus rule target: " & targetName & "][" & aRule's prettyName() & "] Task successfully processed. Name: " & aTask's name
--						end tell
					
				on error message 
					log "[" & prettyName() & "] Error occurred processing rule: " & message
				end try				

			else 
--				tell application "OmniFocus"
--					log "[" & my prettyName() & "] Task skipped. Name: " & aTask's name
--				end tell
			end if
		end repeat		
	end accept
	
end script

script ConditionalCommandRule	
	property parent : OmniFocusTaskProcessingRule
	property conditions : { }
	property actions : { }
	
	on constructRule()
		set aRule to continue constructRule()
		set aRule's conditions to { }
		set aRule's actions to { }
		return aRule
	end constructRule
	
	on addCondition(aSpec)
		set conditions's end to aSpec
	end addCondition
	
	on addAction(aCommand)
		set actions's end to aCommand
	end addAction
	
	(*
	@post Returns boolean or record
	*)
	on matchTask(aTask, inputAttributes)
		--Implement all
		set satisfiedConditions to 0
		
		repeat with condition in conditions
			set matchResult to condition's isSatisfiedBy(aTask)
			
			if (matchResult's class is boolean)
				if (matchResult) then set satisfiedConditions to satisfiedConditions + 1
			else if (matchResult's class is record)
				if (matchResult's passesCriteria) then
					set satisfiedConditions to satisfiedConditions + 1					
					set inputAttributes to inputAttributes & matchREsult's outputAttributes
				end if 
			end 
		end repeat
		
		return (satisfiedConditions equals count of conditions)
	end matchTask
	
	(*
	@post Throws error if there's a problem processing rule.
	*)
	on processTask(aTask, inputAttributes)
		repeat with anAction in actions
			tell anAction to execute(aTask)
		end repeat
	end processTask
end script

script DeferDailyRepeatRule
	property parent : OmniFocusTaskProcessingRule
	
	on prettyName()
		return "Defer Daily Rule"
	end prettyName
	
	
	on matchTask(aTask, inputAttributes)
		local taskName
		
		tell application "OmniFocus"
			set taskName to aTask's name
		end tell
		
		if (taskName contains ">>")
			set repetitionText to text item 2 of textutil's getTextElements(taskName, ">>")
			return {passesCriteria:true, outputAttributes:{ repetitionPattern: repetitionText }}
		else 
			return false
		end if
	end matchTask
	
	on processTask(aTask, inputAttributes)
		set repetitionText to repetitionPattern of inputAttributes
		
		local taskName
		
		tell application "OmniFocus"
			set taskName to aTask's name
		end tell
		
		set taskNameTokens to textutil's getTextElements(taskName, space)
		set repetitionText to missing value
		
		repeat with token in taskNameTokens
			if (token begins with ">>") 
				set repetitionText to token
				exit
			end if
		end repeat

		set taskName to textutil's StringObj's makeString(taskName)'s replaceText(space & repetitionText, "")'s asText()
				
		if (repetitionText ends with "1d")
			tell application "OmniFocus"
				set aTask's name to taskName
			end tell
		
			set aCommand to domain's RepeatDeferDailyCommand's constructCommand()
			tell aCommand to execute(aTask)
		end if			
			
	end processTask
end script

script OmniFocusRuleSet
	
	on constructRuleSet()
		copy me to aRuleSet
		return aRuleSet
	end constructRuleSet
	
	on processAll()
	end processAll
	
end script

script AbstractOmniFocusRuleSet
	property parent : OmniFocusRuleSet
	property targetConfigs : { }
	
	on addTargetConfig(aTarget, rules)
		set targetConfigs's end to { target:aTarget, rules:rules }
	end addTargetConfig

	on processAll()
		repeat with configItem in targetConfigs
			set aTarget to configItem's target
			set rules to configItem's rules
			
			tell aTarget to accept(rules)			
		end repeat
	end processAll	
end script 

on makeAllRule()
	return OmniFocusTaskProcessingRule
end makeAllRule

on makeAnyRule()
end makeAnyRule

on makeNoneRule()
end makeNoneRule

on createTargetForTask(aTask)
	script SingleTaskTarget
		property parent : rules's OmniFocusRuleTarget

		on construct()
			set tasks to { aTask }
		end construct	

	end script
	
	return SingleTaskTarget
end createTargetForTask
