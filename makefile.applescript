#!/usr/bin/osascript
use AppleScript version "2.4"
use scripting additions
use ASMake : script "com.lifepillar/ASMake" version "0.2.1"
property parent : ASMake
property TopLevel : me

on run argv
	continue run argv
end run

------------------------------------------------------------------
-- Tasks
------------------------------------------------------------------

script api
	property parent : Task(me)
	property description : "Build the API documentation"
	property dir : "Documentation"
	
	ohai("Running HeaderDoc, please wait...")
	--Set LANG to get rid of warnings about missing default encoding
	shell for "env LANG=en_US.UTF-8 headerdoc2html" given options:{"-q", "-o", dir, "OmniFocusDomain.applescript"}
	shell for "env LANG=en_US.UTF-8 gatherheaderdoc" given options:dir
end script

script BuildScriptLibrary
	property parent : Task(me)
	property name : "build/library"
	property description : "Build Script Libraries"
	
	property sourceDir : "src/Script Libraries/"
	property destinationDir : "build/Script Libraries/com.kraigparkinson"
	
	makeScriptBundle from joinPath(sourceDir, "OmniFocusDomain.applescript") at destinationDir with overwriting
end script

script BuildOFApplicationScripts
	property parent : Task(me)
	property name : "build/omnifocus-scripts"
	property description : "Build OmniFocus Application Scripts"
	
	property sourceDir : "src/OmniFocus Scripts/"
	property destinationDir : "build/OmniFocus Scripts"
	
	tell BuildScriptLibrary to exec:{}
	makeScriptBundle from joinPath(sourceDir, "Repeat Defer Daily.applescript") at destinationDir with overwriting
	makeScriptBundle from joinPath(sourceDir, "Repeat Defer Weekly.applescript") at destinationDir with overwriting
end script

script build
	property parent : Task(me)
	property description : "Build all source AppleScript scripts"
	
	tell BuildScriptLibrary to exec:{}
	tell BuildOFApplicationScripts to exec:{}
	
	osacompile(glob({}), "scpt", {"-x"})
end script

script clean
	property parent : Task(me)
	property description : "Remove any temporary products"
	
	removeItems at {"build"} & glob({"**/*.scpt", "**/*.scptd", "tmp"}) with forcing
end script

script clobber
	property parent : Task(me)
	property description : "Remove any generated file"
	
	tell clean to exec:{}
	removeItems at glob({"OmniFocusDomain-*", "*.tar.gz", "*.html"}) with forcing
end script

script doc
	property parent : Task(me)
	property description : "Build an HTML version of the old manual and the README"
	property markdown : missing value
	
	set markdown to which("markdown")
	if markdown is not missing value then
		shell for markdown given options:{"-o", "README.html", "README.md"}
	else
		error markdown & space & "not found." & linefeed & "PATH: " & (do shell script "echo $PATH")
	end if
end script

script dist
	property parent : Task(me)
	property description : "Prepare a directory for distribution"
	property dir : missing value
	
	tell clobber to exec:{}
	tell BuildScriptLibrary to exec:{}
	tell BuildOFApplicationScripts to exec:{}
	
	tell api to exec:{}
	tell doc to exec:{}
	
	set {n, v} to {name, version} of (run script POSIX file (joinPath(workingDirectory(), "src/OmniFocusDomain.applescript")))
	set dir to n & "-" & v
	makePath(dir)
end script

script gzip
	property parent : Task(me)
	property description : "Build a compressed archive for distribution"
	
	tell dist to exec:{}
	do shell script "tar czf " & quoted form of (dist's dir & ".tar.gz") & space & quoted form of dist's dir & "/*"
end script

script InstallOFApplicationScripts
	property parent : Task(me)
	property dir : POSIX path of Â
		((path to library folder from user domain) as text) & "Application Scripts/com.omnigroup.OmniFocus2"
	property description : "Install Repeat Defer Daily in" & space & dir
	
	on installWithOverwriteAlert(scriptname, targetDirName)
		set targetDir to joinPath(dir, targetDirName)
		set targetPath to joinPath(targetDir, scriptname & ".scptd")
		
		copyItem at "build/OmniFocus Scripts/" & scriptname & ".scptd" into targetDir with overwriting
		ohai(scriptname & " installed at" & space & targetPath)
	end installWithOverwriteAlert
	
	tell BuildOFApplicationScripts to exec:{}
	installWithOverwriteAlert("Repeat Defer Daily", "")
	installWithOverwriteAlert("Repeat Defer Weekly", "")
end script

script installScriptLibraries
	property parent : Task(me)
	property dir : POSIX path of Â
		((path to library folder from user domain) as text) & "Script Libraries"
	property description : "Install OmniFocusDomain in" & space & dir
	
	on installWithOverwriteAlert(scriptname, targetDirName)
		set targetDir to joinPath(dir, targetDirName)
		set targetPath to joinPath(targetDir, scriptname & ".scptd")
		
		copyItem at "build/Script Libraries/" & scriptname & ".scptd" into targetDir with overwriting
		ohai(scriptname & " installed at" & space & targetPath)
	end installWithOverwriteAlert
	
	tell BuildScriptLibrary to exec:{}
	installWithOverwriteAlert("com.kraigparkinson/OmniFocusDomain", "com.kraigparkinson")
end script

script install
	property parent : Task(me)
	
	tell installScriptLibraries to exec:{}
	tell InstallOFApplicationScripts to exec:{}
	
end script

script BuildTests
	property parent : Task(me)
	property name : "test/build"
	property description : "Build tests, but do not run them"
	
	owarn("Due to bugs in OS X Yosemite, building tests requires ASUnit to be installed.")
	
	tell build to exec:{}
	makeScriptBundle from "test/Test OmniFocus.applescript" at "test" with overwriting
	makeScriptBundle from "test/Test OmniFocusDomain.applescript" at "test" with overwriting
	makeScriptBundle from "test/Test OmniFocusTransportTextParsingService.applescript" at "test" with overwriting
end script

script RunTestsOnOmniFocus
	property parent : Task(me)
	property name : "test/of"
	property description : "Build and run tests on OmniFocus behavior"
	property printSuccess : false

	tell BuildTests to exec:{}
	-- The following causes a segmentation fault unless ASUnit in installed in a shared location
	set testSuite to load script POSIX file (joinPath(workingDirectory(), "test/Test OmniFocus.scptd"))
	run testSuite
end script

script RunTests
	property parent : Task(me)
	property name : "test/run"
	property description : "Build and run tests"
	property printSuccess : false
	
	shell for "open" & space & POSIX path of ((path to home folder) as text) & "test.ofocus"
	
	tell BuildTests to exec:{}
	-- The following causes a segmentation fault unless ASUnit in installed in a shared location
	set testSuite to load script POSIX file (joinPath(workingDirectory(), "test/Test OmniFocusDomain.scptd"))
	run testSuite
	
	set testSuite to load script POSIX file (joinPath(workingDirectory(), "test/Test OmniFocusTransportTextParsingService.scptd"))
	run testSuite
	
end script

script deploy
	property parent : Task(me)
	property description : "Prepare a directory for deployment"
	
	property sourceDir : "build/OmniFocus Scripts"
	property targetDirDir : "dist/OmniFocus Scripts"
	
	tell RunTests to exec:{}
	
	copyItems at sourceDir into targetDir with overwriting
end script

script uninstall
	property parent : Task(me)
	property dir : POSIX path of Â
		((path to library folder from user domain) as text) & "Script Libraries"
	property description : "Remove OmniFocusDomain from" & space & dir
	
	set targetPath to joinPath(dir, "com.kraigparkinson/OmniFocusTransportTextParsingService.scptd")
	if pathExists(targetPath) then
		removeItem at targetPath
	end if
	ohai(targetPath & space & "deleted.")
	
	set targetPath to joinPath(dir, "com.kraigparkinson/OmniFocusDomain.scptd")
	if pathExists(targetPath) then
		removeItem at targetPath
	end if
	ohai(targetPath & space & "deleted.")
	
end script

script VersionTask
	property parent : Task(me)
	property name : "version"
	property description : "Print OmniFocusDomain's version and exit"
	property printSuccess : false
	
	set {n, v} to {name, version} of Â
		(run script POSIX file (joinPath(workingDirectory(), "OmniFocusDomain.applescript")))
	ohai(n & space & "v" & v)
end script
