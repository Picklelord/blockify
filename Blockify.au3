#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=headphones.ico
#AutoIt3Wrapper_Res_Description=Spotify Controller that allows the user to control spotify without jumping to it.
#AutoIt3Wrapper_Res_Fileversion=2020.1.2.2
#AutoIt3Wrapper_Res_ProductName=Blockify
#AutoIt3Wrapper_Res_CompanyName=Pickled Industries Ltd
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_Icon_Add=headphones.ico
#AutoIt3Wrapper_Res_Icon_Add=play.ico
#AutoIt3Wrapper_Res_Icon_Add=pause.ico
#AutoIt3Wrapper_Res_Icon_Add=previous.ico
#AutoIt3Wrapper_Res_Icon_Add=next.ico
#AutoIt3Wrapper_Res_Icon_Add=unmute.ico
#AutoIt3Wrapper_Res_Icon_Add=mute.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Process.au3>
#include <Array.au3>
#include <WinAPI.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>


Opt("WinDetectHiddenText", 1) ;0=don't detect, 1=do detect
Opt("WinSearchChildren", 1) ;0=no, 1=search children also
Opt("WinTextMatchMode", 2) ;1=complete, 2=quick
Opt("WinTitleMatchMode", 2) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase

Opt("TrayOnEventMode",1)
Opt("TrayMenuMode",1)

$ExitItem = TrayCreateItem("Close Blockify")
TrayItemSetOnEvent(-1,"ReadList")
TraySetIcon("headphones.ico");download.jpg");SpotPlayerControl.ico")


Func ReadList()
 $SelectedItem = TrayItemGetText(@TRAY_ID)
 If $SelectedItem="Close Blockify" Then
   Exit
 EndIf
EndFunc

;#################################################;
;			   Main Function Below				  ;
;#################################################;

$autoUnmute = False
$CrntSong = ""
SpotControlGui()


Func SpotControlGui()
    ; Create a GUI with various controls.
    Local $hGUI = GUICreate("Blockify", 530, 51, 600, 1, $WS_EX_APPWINDOW + $WS_MINIMIZEBOX);, $WS_EX_TOPMOST)
    Local $idPrevious = GUICtrlCreateButton("|<<", 5, 1, 24, 24, $BS_ICON)
    Local $idPausePlay = GUICtrlCreateButton("> ||", 35, 1, 24, 24, $BS_ICON)
    Local $idNext = GUICtrlCreateButton(">>|", 65, 1, 24, 24, $BS_ICON)
    Local $idMute = GUICtrlCreateButton("MU", 95, 1, 24, 24, $BS_ICON)
	$CrntSongLabel = GUICtrlCreateLabel("", 205, 5, 355, 24)
	$CrntSongLbl = GUICtrlCreateLabel("Current Song: ", 125, 5, 75)

	;GUICtrlSetImage ( controlID, filename [, iconname [, icontype]] )
	GUICtrlSetImage ( $idPrevious, "previous.ico",1,1)
	GUICtrlSetImage ( $idPausePlay, "pause.ico",1,1)
	GUICtrlSetImage ( $idNext, "next.ico",1,1)
	GUICtrlSetImage ( $idMute, "unmute.ico",1,1)



    ; Display the GUI.
	GuiSetIcon("headphones.ico", $hGUI)
    GUISetState(@SW_SHOW, $hGUI)
	$title = ProcessGetWindow(ProcessList("Spotify.exe")[1][1]) ; check what title is
    $thatNumber = WinGetHandle($title)
    $prevTitle = $title ; check what title is  Chrome_WidgetWin_0
   controlSetText($hGUI, $prevTitle, $CrntSongLabel, $title)


	$mute = False
	$playing = True
	$paused = False

    ; Loop until the user exits.
	While 1
	  Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			ExitLoop

		Case $idPrevious
			Send("{MEDIA_PREV}")

		Case $idPausePlay
			Send("{MEDIA_PLAY_PAUSE}")
			if $playing Then
				GUICtrlSetImage ( $idPausePlay, "pause.ico",1,1)
				$playing = False
				Send("{VOLUME_MUTE}", 0); to counter the mute on stopping
				GUICtrlSetImage ( $idMute, "unmute.ico",1,1)
				$mute = True
				$paused = False

			ElseIf not $playing Then
				GUICtrlSetImage ( $idPausePlay, "play.ico",1,1)
				$playing = True
				Send("{VOLUME_MUTE}", 0); to counter the unmute on starting
				GUICtrlSetImage ( $idMute, "unmute.ico",1,1)
				$mute = False
				$paused = True
			EndIf

		Case $idNext
			Send("{MEDIA_NEXT}")

		Case $idMute
			if $mute Then
				Send("{VOLUME_MUTE}", 0)
				GUICtrlSetImage ( $idMute, "unmute.ico",1,1)
				$mute = False
			ElseIf not $mute Then
				Send("{VOLUME_MUTE}", 0)
				GUICtrlSetImage ( $idMute, "mute.ico",1,1)
				$mute = True
			EndIf

	  EndSwitch
	  Sleep(20) ; give time for title of window to change\
	  $prevTitle = $title
	  $title = WinGetTitle(WinGetHandle($thatNumber));ProcessGetWindow(ProcessList("Spotify.exe")[1][1]) ; check what title is
	  ;ConsoleWrite(@CRLF&"Previous Title: '"&$prevTitle);&"', New Title: '"&$title&"'      ")
	  ;ConsoleWrite(@CRLF&"Current  Title: '"&$title);&"', New Title: '"&$title&"'      ")
	  ;GUICtrlDelete($CrntSongLabel)
	  If $prevTitle <> $title Then

		 controlSetText($hGUI, $prevTitle, $CrntSongLabel, $title)
	  endIf
	  If not $paused Then
		  If StringInStr($title, " - ") == 0 Then ; if not song title, mute.
			 If Not $autoUnmute Then
				Send("{VOLUME_MUTE}", 0)
				GUICtrlSetImage ( $idMute, "mute.ico",1,1)
				$mute = True
				$autoUnmute = True
				$playing = True
				GUICtrlSetImage ( $idPausePlay, "play.ico",1,1)
			 EndIf
		  ElseIf $autoUnmute Then ;var set by "autoMute", if true, check when to unmute.
			 If StringInStr($title, " - ") <> 0 Then
				Send("{VOLUME_MUTE}", 0)
				GUICtrlSetImage ( $idMute, "unmute.ico",1,1)
				$mute = False
				$autoUnmute = False
			 EndIf
		  EndIf
	  EndIf
	WEnd
    ; Delete the previous GUI and all controls.
	GUIDelete($hGUI)
EndFunc   ;==>Example

Func ProcessGetWindow($PId)
    ;If IsNumber($PId) = 0 Or ProcessExists("Spotify.exe") = 0 Then;ProcessGetName($PId)
    ;    SetError(1)
    ;Else
	 Local $WinList = WinList()
	 Local $i = 1
	 Local $WindowTitle = ""
	 ;While $i <= $WinList[0][0] And $WindowTitle = ""
	 For $i = 1 to $WinList[0][0]
		 If WinGetProcess($WinList[$i][0], "") = $PId Then
			$WindowTitle = $WinList[$i][0]
			$thatNumber = WinGetHandle($WindowTitle)

			Return $WindowTitle
		 EndIf
	  Next
    ;WEnd
    ;EndIf
 EndFunc   ;==>ProcessGetWindow


Func ProcessGetId($Process)
    If IsString($Process) = 0 Then
        SetError(2)
    ElseIf ProcessExists($Process) = 0 Then
        SetError(1)
    Else
        Local $PList = ProcessList($Process)
        Local $i
        Local $PId[$PList[0][0] + 1]
        $PId[0] = $PList[0][0]
        For $i = 1 To $PList[0][0]
            $PId[$i] = $PList[$i][1]
        Next
        Return $PId
    EndIf
EndFunc   ;==>ProcessGetId

Func ProcessGetName($PId)
    If IsNumber($PId) = 0 Then
        SetError(2)
    ElseIf $PId > 9999 Then
        SetError(1)
    Else
        Local $PList = ProcessList()
        Local $i = 1
        Local $ProcessName = ""

        While $i <= $PList[0][0] And $ProcessName = ""
            If $PList[$i][1] = $PId Then
                $ProcessName = $PList[$i][0]
            Else
                $i = $i + 1
            EndIf
        WEnd
        Return $ProcessName
    EndIf
EndFunc   ;==>ProcessGetName