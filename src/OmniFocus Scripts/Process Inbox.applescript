
on main()	
	log "Process Inbox called."
	
	set rules to script "com.kraigparkinson/Creating Flow with OmniFocus Rules"
	set aRuleSet to rules's DefaultRuleSet's constructRuleSet()
	tell aRuleSet to processAll()
	
	log "Process Inbox completed."
			
end main

main()