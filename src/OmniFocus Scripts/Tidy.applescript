
property rules : script "com.kraigparkinson/OmniFocus Rules Engine"
property cfr : script "com.kraigparkinson/Creating Flow with OmniFocus Rules"

on main()
	script TidyRuleSet
		property parent : rules's AbstractOmniFocusRuleSet
	
		on constructRuleSet()
			set aRuleSet to continue constructRuleSet()		
			set theRules to { }
			set theRules's end to cfr's ExpiredMeetingPreparationRule's constructRule()
			set theRules's end to cfr's AddDailyRepeatRule's constructRule()
			set theRules's end to cfr's TidyConsiderationsRule's constructRule()
			set theRules's end to cfr's ExpiredCheckMeetingParticipationRule's constructRule()
		
			tell aRuleSet to addTargetConfig(rules's UserSpecifiedTasks's construct(), theRules )
		
			return aRuleSet
		end constructRuleSet
	end script 

	log "Tidy called."

	set aRuleSet to TidyRuleSet's constructRuleSet()
	tell aRuleSet to processAll()

	log "Tidy completed."
end main

main()
