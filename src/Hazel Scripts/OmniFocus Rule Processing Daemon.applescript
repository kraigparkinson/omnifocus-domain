
(*)
property theFile : missing value
property inputAttributes : missing value 

hazelProcessFile(theFile, inputAttributes)
*)
on hazelProcessFile(theFile, inputAttributes)
	set rules to script "com.kraigparkinson/Creating Flow with OmniFocus Rules"
	set aRuleSet to rules's DefaultRuleSet's constructRuleSet()	
	tell aRuleSet to processAll()	
end hazelProcessFile