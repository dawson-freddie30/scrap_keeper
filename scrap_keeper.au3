#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Run_AU3Check=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIConstantsEx.au3>

AutoItSetOption('MustDeclareVars')
AutoItSetOption('TrayMenuMode', 3)
AutoItSetOption('TrayOnEventMode', 1)

TrayCreateItem('Reset')
TrayItemSetOnEvent(-1, '_Tray_Reset')
TrayCreateItem('')
TrayCreateItem('Exit')
TrayItemSetOnEvent(-1, "_Tray_Exit")

Global $INI = 'scrap_keeper.ini'
Global $WIN
Global $TIMER = 0

Global $DELAY = IniRead($INI, 'settings', 'delay', '1.5')

_ReadLogin('ZoomBucks')
_ReadLogin('SwagBucks')
_ReadLogin('PrizeRebel')
_ReadLogin('GiftHulk')
_ReadLogin('InboxDollars')
_ReadLogin('PedToClick')

_DeleteLogin('LootPalace')
_DeleteLogin('instaGC')
_DeleteLogin('PaidVert')
_DeleteLogin('iRazoo')

_DoGUI()

Func _DoGUI()
	Local $gui = GUICreate("Scrap Keeper", 275, 153, 252, 145)
	Local $buttonGo = GUICtrlCreateButton("Go", 176, 112, 75, 25)
	Local $_check_ZoomBucks = GUICtrlCreateCheckbox("ZoomBucks", 8, 8, 121, 17)
	Local $_check_SwagBucks = GUICtrlCreateCheckbox("SwagBucks", 8, 32, 121, 17)
	Local $_check_PrizeRebel = GUICtrlCreateCheckbox("PrizeRebel", 8, 56, 121, 17)
	Local $_check_GiftHulk = GUICtrlCreateCheckbox("GiftHulk", 152, 8, 121, 17)
	Local $_check_InboxDollars = GUICtrlCreateCheckbox("InboxDollars", 152, 32, 121, 17)
	Local $_check_PedToClick = GUICtrlCreateCheckbox("PedToClick", 152, 56, 121, 17)
	GUICtrlCreateLabel("Reset every X hours", 24, 96, 100, 17)
	$DELAY = GUICtrlCreateInput($DELAY, 24, 120, 41, 21)
	GUISetState(@SW_SHOW)

	GUICtrlSetState($_check_ZoomBucks, $CHECK_ZoomBucks)
	GUICtrlSetState($_check_SwagBucks, $CHECK_SwagBucks)
	GUICtrlSetState($_check_PrizeRebel, $CHECK_PrizeRebel)
	GUICtrlSetState($_check_GiftHulk, $CHECK_GiftHulk)
	GUICtrlSetState($_check_InboxDollars, $CHECK_InboxDollars)
	GUICtrlSetState($_check_PedToClick, $CHECK_PedToClick)

	While 1
		Switch GUIGetMsg()
			Case $buttonGo
				$DELAY = GUICtrlRead($DELAY)

				_WriteLogin('ZoomBucks', $_check_ZoomBucks)
				_WriteLogin('SwagBucks', $_check_SwagBucks)
				_WriteLogin('PrizeRebel', $_check_PrizeRebel)
				_WriteLogin('GiftHulk', $_check_GiftHulk)
				_WriteLogin('InboxDollars', $_check_InboxDollars)
				_WriteLogin('PedToClick', $_check_PedToClick)

				IniWrite($INI, 'settings', 'delay', $DELAY)

				GUIDelete()

				_Keep()
			Case $GUI_EVENT_CLOSE
				Exit
		EndSwitch
	WEnd
EndFunc   ;==>_DoGUI

Func _Keep()
	Local $seconds
	$DELAY *= 3600 * 1000

	If $DELAY < 1000 Then
		MsgBox(16, '', 'hours is too low')
		Exit
	EndIf

	While 1
		If $TIMER = 0 Then
			$seconds = 0
		Else
			$seconds = Int(($DELAY - TimerDiff($TIMER)) / 1000)
		EndIf

		If $seconds <= 0 Then
			$TIMER = TimerInit()
			_Reset()
		Else
			TraySetToolTip(_Seconds2Time($seconds))
		EndIf

		Sleep(250)
	WEnd
EndFunc   ;==>_Keep

Func _Reset()
	TraySetToolTip('...')
	$WIN = 0

	Do
		_ClearScrap()
		Sleep(2000) ; settle down plz

		Run(@LocalAppDataDir & '\Scrap\Scrap.exe')

		BlockInput(1)
		Sleep(5000) ; give time for handle to be ready and update to trigger
		BlockInput(0)

		If ProcessExists('scrap.exe') = 0 Then ; update!
			WinWaitClose('[CLASS:#32770]')
			ContinueLoop
		EndIf

		$WIN = WinWait('[REGEXPCLASS:HwndWrapper\[Scrap\.exe;;;;.*\]]', '', 5)
		If $WIN = 0 Then ContinueLoop

		WinSetOnTop($WIN, '', 1)
		BlockInput(1)

		_SendDelayed(500, '{TAB}')

		If WinExists($WIN) = 0 Then ; dump out before trying all the logins
			BlockInput(0)
			ContinueLoop
		EndIf

		_SendLogin('ZoomBucks')
		_SendLogin('SwagBucks')
		_SendLogin('PrizeRebel')
		_SendLogin('GiftHulk')
		_SendLogin('InboxDollars')
		_SendLogin('PedToClick')

		WinSetOnTop($WIN, '', 0)
		BlockInput(0)

		$WIN = WinExists($WIN) ; loop again if false
	Until $WIN <> 0
EndFunc   ;==>_Reset

Func _SendDelayed($DELAY, $keys, $raw = 0)
	While WinActive($WIN) = 0
		If WinExists($WIN) = 0 Then Return

		WinActivate($WIN)
		Sleep(10)
	WEnd

	AutoItSetOption('SendKeyDelay', $DELAY)
	Send($keys, $raw)
EndFunc   ;==>_SendDelayed

Func _SendLogin($section)
	If Eval('CHECK_' & $section) = $GUI_CHECKED Then
		_SendDelayed(500, '{TAB}')
		_SendDelayed(500, '{TAB}')
		_SendDelayed(250, '{TAB}')
		_SendDelayed(250, '{ENTER}')
		Sleep(3000)
		_SendDelayed(250, '+{TAB}')
		_SendDelayed(250, '+{TAB}')
		_SendDelayed(250, '+{TAB}')
	EndIf

	_SendDelayed(500, '{RIGHT}')
EndFunc   ;==>_SendLogin

Func _ClearScrap()
	_KillAll('scrap.exe')
	_KillAll('chromedriver.exe')
	_KillAll('chrome.exe')
EndFunc   ;==>_ClearScrap

Func _KillAll($name)
	While ProcessExists($name) <> 0
		ProcessClose($name)
	WEnd
EndFunc   ;==>_KillAll

Func _Seconds2Time($seconds)
	Local $hours = Int($seconds / 3600)
	$seconds -= $hours * 3600
	Local $minutes = Int($seconds / 60)
	$seconds -= $minutes * 60
	Return StringFormat('%02d:%02d:%02d', $hours, $minutes, $seconds)
EndFunc   ;==>_Seconds2Time

Func _ReadLogin($section)
	Assign('CHECK_' & $section, IniRead($INI, $section, 'check', $GUI_UNCHECKED), 2)
	_CleanupLogin($section)
EndFunc   ;==>_ReadLogin

Func _WriteLogin($section, $checkCtrl)
	Assign('CHECK_' & $section, GUICtrlRead($checkCtrl), 4)

	IniWrite($INI, $section, 'check', Eval('CHECK_' & $section))
EndFunc   ;==>_WriteLogin

Func _DeleteLogin($section)
	IniDelete($INI, $section)
EndFunc   ;==>_DeleteLogin

Func _CleanupLogin($section)
	IniDelete($INI, $section, 'user')
	IniDelete($INI, $section, 'pass')
EndFunc   ;==>_CleanupLogin

Func _Tray_Exit()
	_ClearScrap()
	Exit
EndFunc   ;==>_Tray_Exit

Func _Tray_Reset()
	$TIMER = 0
EndFunc   ;==>_Tray_Reset
