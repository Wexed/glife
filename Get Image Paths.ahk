/*
 *		-- Get image paths from glife.txt  --
 *
 *		Requires images subfolder to exist in current directory
 *		
 *		OutAllFile 	- List of All unprocessed file names from glife.txt that are not marked missing in the code
 *		OutUsedFile - List of Found file names from glife.txt and Auto List
 *		OutMissFile	- List of Missing file names from glife.txt that are marked missing in the code.
 *		OutAutoFile	- List of file paths from glife.txt that were added to Output file using code in this script
 *		OutManFile	- List of file paths from glife.txt that will have to be added manualy checked either in glife code or added to OutUsedFile
 *          
 *
 *      WD: Jul 2015
 *
 *
 */
  
  

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


SourceFile 		= glife.txt
OutAllFile		= Image List - All.txt
OutUsedFile		= Image List - Used.txt
OutMissFile		= Image List - Missing.txt
OutAutoFile		= Image Paths - Auto List.txt
OutManFile		= Image Paths - Manual List.txt
SearchRegEx		= i)<img\s+src\s*=\s*"(.*?)"
CommentRegEx 	= ^\s*!
MarkMissRegEx	= i)!\s*WD:\s+IMAGE NEEDED\s*~\s*.*?<img\s+src\s*=\s*"(.*?)"

FileEncoding, UTF-16

;-- backup files  and delete --
IfNotExist %SourceFile%
{
	MsgBox, 16, Get Image Paths, Unable to locate "%SourceFile%" in "%A_WorkingDir%", 10
	Exit
}

ifExist %OutAllFile%					;; Backup File		
{
	FileMove, %OutAllFile%, %OutAllFile%.bak, 1	
	FileDelete, %OutAllFile%
}

ifExist %OutUsedFile%				;; Backup File		
{
	FileMove, %OutUsedFile%, %OutUsedFile%.bak, 1	
	FileDelete, %OutUsedFile%
}

ifExist %OutMissFile%				;; Backup File		
{
	FileMove, %OutMissFile%, %OutMissFile%.bak, 1	
	FileDelete, %OutMissFile%
}

ifExist %OutAutoFile%				;; Backup File 
{
	FileMove, %OutAutoFile%, %OutAutoFile%.bak, 1
	FileDelete, %OutAutoFile%
}

ifExist %OutManFile%				;; Backup File 
{
	FileMove, %OutManFile%, %OutManFile%.bak, 1
	FileDelete, %OutManFile%
}


; -- load data from file --
FileRead, Source, %SourceFile%

; -- vars need plenty of space to work with --
VarSetCapacity(OutAll, 4194304)				;; 4mb
VarSetCapacity(OutUsed, 4194304)			;; 4mb
VarSetCapacity(OutMiss, 4194304)			;; 4mb
VarSetCapacity(OutAuto, 1048576)			;; 1mb
VarSetCapacity(OutMan, 1048576)				;; 1mb


; -- Parse data one line at a time --
Loop, Parse, Source, `n, `r  			; Specifying `n prior to `r allows both Windows and Unix files to be parsed.
{
	
	; -- Check is Comment line --
	FoundCmntPos := RegExMatch(A_LoopField, CommentRegEx)
	if (ErrorLevel)
	{
		MsgBox, 48, Get Image Paths, RegExMatch runtime error: %ErrorLevel%`n`nFound searching string: %A_LoopField%`n`nusing search: %CommentRegEx%
		break
	}
	if (FoundCmntPos)															;; comment found
	{
		FoundPos := RegExMatch(A_LoopField, MarkMissRegEx, Match)				;; Check for known missing file
		if (ErrorLevel)
		{
			MsgBox, 48, Get Image Paths, RegExMatch runtime error: %ErrorLevel%`n`nFound searching string: %A_LoopField%`n`nusing search: %MarkMissRegEx%
			break
		}	
		if (FoundPos)															;; Found File
		{	
			Match1 := StrReplace(Match1, "/", "\")								;; Use correct Win path seperator	
			IfExist %Match1%
			{
				OutMiss	.= Spacer(Match1) . "- Missing file exists`n"			;; Missing File found
			}
			else
			{
				OutMiss	.= Match1 . "`n"										;; Missing file Not found
			}		
		}
		Continue
	}

	
	; -- Find Image File Path --
	FoundPos := RegExMatch(A_LoopField, SearchRegEx, Match)						;; Search for image path
	if (ErrorLevel)
	{
		MsgBox, 48, Get Image Paths, RegExMatch runtime error: %ErrorLevel%`n`nFound searching string: %A_LoopField%`n`nusing search: %SearchRegEx%
		break
	}
	
	if (FoundPos)																;; Found File
	{	
		Match1 := StrReplace(Match1, "/", "\")									;; Use correct Win path seperator
		OutAll .= Match1 . "`n"
		; -- Image Path Contains Code --
		if inStr(Match1, "<<")													;; String contains expression
		{
			
			if inStr(Match1, "FUNC('$face_image'")								;; Hairstyle images Function
			{
				if GetImageFiles("images\body\hairstyles", "hcol*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\body\hairstyles\*\hcol*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\body\hairstyles\*\hcol*.jpg'`n"
				}
				
			}
			else if inStr(Match1, "FUNC('$clothing_image'")						;; Clothing images Function
			{
				if GetImageFiles("images\clothes", "vatnik.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\vatnik.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\vatnik.jpg'`n"
				}
				; GetImageFiles("images\clothes\newclo", "131.jpg", OutUsed)	;; Dupe See below	
				
				if GetImageFiles("images\clothes", "jeans*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\jeans*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\jeans*.jpg'`n"
				}

				if GetImageFiles("images\clothes", "yoga*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\yoga*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\yoga*.jpg'`n"
				}

				if GetImageFiles("images\clothes", "sarafan*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\sarafan*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\sarafan*.jpg'`n"
				}


				if GetImageFiles("images\clothes", "short*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\short*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\short*.jpg'`n"
				}

				if GetImageFiles("images\clothes", "skirt*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\skirt*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\skirt*.jpg'`n"
				}

				if GetImageFiles("images\clothes", "dress*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\dress*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\dress*.jpg'`n"
				}

				if GetImageFiles("images\clothes", "profi*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\profi*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\profi*.jpg'`n"
				}

				if GetImageFiles("images\clothes", "pants*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\pants*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\pants*.jpg'`n"
				}

				if GetImageFiles("images\clothes", "latex*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\latex*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\latex*.jpg'`n"
				}

				if GetImageFiles("images\clothes", "hooker*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\hooker*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\hooker*.jpg'`n"
				}

				if GetImageFiles("images\clothes", "k*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\k*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\k*.jpg'`n"
				}

				if GetImageFiles("images\clothes\newclo", "*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\clothes\newclo\*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\clothes\newclo\*.jpg'`n"
				}

				if GetImageFiles("images\img\dress", "ero*.jpg", OutUsed)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\img\dress\ero*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- no files found in 'images\img\dress\ero*.jpg'`n"
				}
			}

			else if inStr(Match1, "images\qwest\card")								;; Playingcard Images
			{
				if GetImageFiles("images\qwest\card", "*.jpg", Output)
				{
					OutAuto	.= Spacer(Match1) . "- Found 'images\qwest\card\*\*.jpg'`n"
				}
				else
				{
					OutMan	.= Spacer(Match1) . "- No files found in 'images\qwest\card\*\*.jpg'`n"
				}				
			}
			
			else if inStr(Match1, "FUNC")											;; Unknown Function - Manual
			{
				OutMan	.= Spacer(Match1) . "- Unknown Function`n"
			}
			
			else if inStr(Match1, "$")												;; Uses String variable - Manual
			{
				OutMan	.= Spacer(Match1) . "- Unknown Function`n"
			}
			
			else if not GetImagefromPath(Match1, OutUsed)							;; Try to find images
			{
				OutMan	.= Spacer(Match1) . "- Files not found`n"
			}
		}
		
		; -- Image path is just a file name --
		else
		{
			IfExist %Match1%
			{
				OutUsed	.= Match1 . "`n"											;; Normal file found
			}
			else
			{
				OutMan	.= Spacer(Match1) . "- File not found`n"					;; Normal file Not found
			}
		}
	}	
}


; -- Set path to use / seperators --
OutAll	:= StrReplace(OutAll, "\", "/")
OutUsed	:= StrReplace(OutUsed, "\", "/")
OutMiss	:= StrReplace(OutMiss, "\", "/")
OutAuto	:= StrReplace(OutAuto, "\", "/")
OutMan	:= StrReplace(OutMan, "\", "/")


; -- sort filenames and remove dupes --
Sort, OutAll, U
Sort, OutUsed, U
Sort, OutMiss, U
Sort, OutAuto, U
Sort, OutMan, U


;-- save files --
FileAppend, %OutAll%, %OutAllFile%
FileAppend, %OutUsed%, %OutUsedFile%
FileAppend, %OutMiss%, %OutMissFile%
FileAppend, %OutAuto%, %OutAutoFile%
FileAppend, %OutMan%, %OutManFile%

Exit

; ########## Functions ##########
Spacer(TxtStr = "")
{
	Static SpaceFill := "                                                  "
	
	;~ ps := strlen(TxtStr) + 1												;; allow empty string = 1 
	;~ ss := TxtStr . SubStr(SpaceFill, ps) . "`t"
	
	return TxtStr . SubStr(SpaceFill, strlen(TxtStr)+1) . "`t"
	
}

GetImageFiles(FilePath, FileName, ByRef Output)
{	;; Get image paths in filepath using filepattern FileName
	
	IfNotExist, %FilePath%
	{
		MsgBox, 48, Get Image Paths, Error in GetImageFiles()`n`nUnable to locate "%FilePath%" folder, Filename '%FileName%'.`n`nCurrent working dir is "%A_WorkingDir%"
		return false		
	}
	
	SaveWorkDir := A_WorkingDir
	Setworkingdir, %FilePath%
	
	found := false
	Loop, Files, %FileName%, FR						;; Find files in FilePath  using Filepattern FileName
	{
		fp := FilePath  . "\" . A_LoopFileFullPath
		Output .= fp . "`n"
		found := true
	}
	
	Setworkingdir, %SaveWorkDir%
	return found

}

GetImagefromPath(FilePath, ByRef Output)
{	;; Try to get Images from path 

	FindRegEx 	:= "<<.*?>>"
	ReplaceStr	:=	"*"

	fp			:= StrReplace(FilePath, "/", "\") 
	fp 			:= RegExReplace(fp, FindRegEx, ReplaceStr)
	
	splitpath, fp, FileName, Dir, Ext

	;; -- Manual if wildcard in path --
	if inStr(Dir, "*")
	{
		; MsgBox, 64, Get Image Path, GetImageFromPath() error: Path contains wildcard`n `nPath : '%fp%'`nDir :  '%Dir%'
		return false
	}
	
	return GetImageFiles(Dir, FileName, Output)
}