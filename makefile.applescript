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
	shell for "env LANG=en_US.UTF-8 headerdoc2html" given options:{"-q", "-o", dir, "OFTaskParser.applescript"}
	--	shell for "env LANG=en_US.UTF-8 headerdoc2html" given options:{"-q", "-o", dir, "OFDateParser.applescript"}
	shell for "env LANG=en_US.UTF-8 gatherheaderdoc" given options:dir
end script


script BuildOFTaskParser
	property parent : Task(me)
	property name : "oftaskparser"
	property description : "Build OFTaskParser"
	
	makeScriptBundle from "src/OFTaskParser.applescript" at "build" with overwriting
end script

script BuildOFDateParser
	property parent : Task(me)
	property name : "ofdateparser"
	property description : "Build OFDateParser"
	
	makeScriptBundle from "src/OFDateParser.applescript" at "build" with overwriting
end script

script build
	property parent : Task(me)
	property description : "Build all source AppleScript scripts"
	
	tell BuildOFDateParser to exec:{}
	tell BuildOFTaskParser to exec:{}
	
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
	removeItems at glob({"OFTaskParser-*", "*.tar.gz", "*.html"}) with forcing
end script

script doc
	property parent : Task(me)
	property description : "Build an HTML version of the old manual and the README"
	property markdown : missing value
	
	set markdown to which("markdown")
	if markdown is not missing value then
		shell for markdown given options:{"-o", "README.html", "README.md"}
	else
		error markdown & space & "not found." & linefeed & Â
			"PATH: " & (do shell script "echo $PATH")
	end if
end script

script dist
	property parent : Task(me)
	property description : "Prepare a directory for distribution"
	property dir : missing value
	
	tell clobber to exec:{}
	tell BuildOFDateParser to exec:{}
	tell BuildOFTaskParser to exec:{}
	
	tell api to exec:{}
	tell doc to exec:{}
	
	set {n, v} to {name, version} of Â
		(run script POSIX file (joinPath(workingDirectory(), "src/OFTaskParser.applescript")))
	--	set {n, v} to {name, version} of Â
	--	(run script POSIX file (joinPath(workingDirectory(), "src/OFDateParser.applescript")))
	set dir to n & "-" & v
	makePath(dir)
	copyItems at {"build/OFTaskParser.scptd", "build/OFDateParser.scptd", "COPYING", "Documentation", Â
		"README.html"} into dir
end script

script gzip
	property parent : Task(me)
	property description : "Build a compressed archive for distribution"
	
	tell dist to exec:{}
	do shell script "tar czf " & quoted form of (dist's dir & ".tar.gz") & space & quoted form of dist's dir & "/*"
end script

script install
	property parent : Task(me)
	property dir : POSIX path of Â
		((path to library folder from user domain) as text) & "Script Libraries"
	property description : "Install OFTaskParser in" & space & dir
	
	tell BuildOFDateParser to exec:{}
	set targetDir to joinPath(dir, "com.kraigparkinson")
	set targetPath to joinPath(targetDir, "OFDateParser.scptd")
	
	if pathExists(targetPath) then
		tell application "Terminal"
			activate
			display alert Â
				"A version of OFDateParser is already installed." message targetPath & space & Â
				"exists. Overwrite?" as warning Â
				buttons {"Cancel", "OK"} Â
				default button "Cancel" cancel button "Cancel"
		end tell
	end if
	
	copyItem at "build/OFDateParser.scptd" into targetDir with overwriting
	ohai("OFDateParser installed at" & space & targetPath)
	
	tell BuildOFTaskParser to exec:{}
	set targetDir to joinPath(dir, "com.kraigparkinson")
	set targetPath to joinPath(targetDir, "OFTaskParser.scptd")
	
	if pathExists(targetPath) then
		tell application "Terminal"
			activate
			display alert Â
				"A version of OFTaskParser is already installed." message targetPath & space & Â
				"exists. Overwrite?" as warning Â
				buttons {"Cancel", "OK"} Â
				default button "Cancel" cancel button "Cancel"
		end tell
	end if
	
	copyItem at "build/OFTaskParser.scptd" into targetDir with overwriting
	ohai("OFTaskParser installed at" & space & targetPath)
	
end script

script BuildTests
	property parent : Task(me)
	property name : "test/build"
	property description : "Build tests, but do not run them"
	
	owarn("Due to bugs in OS X Yosemite, building tests requires ASUnit to be installed.")
	tell install to exec:{}
	makeScriptBundle from "test/Test OF Task Parser.applescript" at "test" with overwriting
	makeScriptBundle from "test/Test OF Date Parser.applescript" at "test" with overwriting
end script

script RunTests
	property parent : Task(me)
	property name : "test/run"
	property description : "Build and run tests"
	property printSuccess : false
	
	tell BuildTests to exec:{}
	-- The following causes a segmentation fault unless ASUnit in installed in a shared location
	set testSuite to load script POSIX file (joinPath(workingDirectory(), "test/Test OF Task Parser.scptd"))
	run testSuite
	
	set testSuite to load script POSIX file (joinPath(workingDirectory(), "test/Test OF Date Parser.scptd"))
	run testSuite
end script

script uninstall
	property parent : Task(me)
	property dir : POSIX path of Â
		((path to library folder from user domain) as text) & "Script Libraries"
	property description : "Remove OFTaskParser from" & space & dir
	
	set targetPath to joinPath(dir, "com.kraigparkinson/OFTaskParser.scptd")
	if pathExists(targetPath) then
		removeItem at targetPath
	end if
	ohai(targetPath & space & "deleted.")
	
	set targetPath to joinPath(dir, "com.kraigparkinson/OFDateParser.scptd")
	if pathExists(targetPath) then
		removeItem at targetPath
	end if
	ohai(targetPath & space & "deleted.")
	
end script

script VersionTask
	property parent : Task(me)
	property name : "version"
	property description : "Print OFTaskParser's version and exit"
	property printSuccess : false
	
	set {n, v} to {name, version} of Â
		(run script POSIX file (joinPath(workingDirectory(), "OFTaskParser.applescript")))
	ohai(n & space & "v" & v)
end script
