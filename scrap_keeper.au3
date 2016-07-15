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

_DoGUI()

Func _DoGUI()
	Local $gui = GUICreate("Scrap Keeper", 432, 328, 212, 150)
	Local $buttonGo = GUICtrlCreateButton("Go", 288, 280, 75, 25)
	Local $_check_ZoomBucks = GUICtrlCreateCheckbox("ZoomBucks", 8, 8, 121, 17)
	$USER_ZoomBucks = GUICtrlCreateInput($USER_ZoomBucks, 24, 32, 177, 21)
	$PASS_ZoomBucks = GUICtrlCreateInput($PASS_ZoomBucks, 24, 56, 177, 21)
	Local $_check_SwagBucks = GUICtrlCreateCheckbox("SwagBucks", 8, 88, 121, 17)
	$USER_SwagBucks = GUICtrlCreateInput($USER_SwagBucks, 24, 112, 169, 21)
	$PASS_SwagBucks = GUICtrlCreateInput($PASS_SwagBucks, 24, 136, 169, 21)
	Local $_check_PrizeRebel = GUICtrlCreateCheckbox("PrizeRebel", 8, 168, 121, 17)
	$USER_PrizeRebel = GUICtrlCreateInput($USER_PrizeRebel, 24, 192, 169, 21)
	$PASS_PrizeRebel = GUICtrlCreateInput($PASS_PrizeRebel, 24, 216, 169, 21)
	Local $_check_GiftHulk = GUICtrlCreateCheckbox("GiftHulk", 232, 8, 121, 17)
	$USER_GiftHulk = GUICtrlCreateInput($USER_GiftHulk, 248, 32, 169, 21)
	$PASS_GiftHulk = GUICtrlCreateInput($PASS_GiftHulk, 248, 56, 169, 21)
	Local $_check_InboxDollars = GUICtrlCreateCheckbox("InboxDollars", 232, 88, 121, 17)
	$USER_InboxDollars = GUICtrlCreateInput($USER_InboxDollars, 248, 112, 169, 21)
	$PASS_InboxDollars = GUICtrlCreateInput($PASS_InboxDollars, 248, 136, 169, 21)
	Local $_check_PedToClick = GUICtrlCreateCheckbox("PedToClick", 232, 168, 121, 17)
	$USER_PedToClick = GUICtrlCreateInput($USER_PedToClick, 248, 192, 169, 21)
	$PASS_PedToClick = GUICtrlCreateInput($PASS_PedToClick, 248, 216, 169, 21)
	GUICtrlCreateLabel("Reset every X hours", 24, 264, 132, 17)
	$DELAY = GUICtrlCreateInput($DELAY, 24, 288, 41, 21)
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
	Local $user = Eval('USER_' & $section)
	Local $pass = Eval('PASS_' & $section)

	If Eval('CHECK_' & $section) = $GUI_CHECKED And $user <> '' And $pass <> '' Then
		_SendDelayed(500, '{TAB}')
		_SendDelayed(10, $user, 1)
		_SendDelayed(500, '{TAB}')
		_SendDelayed(10, $pass, 1)
		;_SendDelayed(500, '{TAB}')
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
	Assign('USER_' & $section, IniRead($INI, $section, 'user', ''), 2)
	Assign('PASS_' & $section, IniRead($INI, $section, 'pass', ''), 2)
EndFunc   ;==>_ReadLogin

Func _WriteLogin($section, $checkCtrl)
	Assign('CHECK_' & $section, GUICtrlRead($checkCtrl), 4)
	Assign('USER_' & $section, GUICtrlRead(Eval('USER_' & $section)), 4)
	Assign('PASS_' & $section, GUICtrlRead(Eval('PASS_' & $section)), 4)

	IniWrite($INI, $section, 'check', Eval('CHECK_' & $section))
	IniWrite($INI, $section, 'user', Eval('USER_' & $section))
	IniWrite($INI, $section, 'pass', Eval('PASS_' & $section))
EndFunc   ;==>_WriteLogin

Func _DeleteLogin($section)
	IniDelete($INI, $section)
EndFunc   ;==>_DeleteLogin

Func _Tray_Exit()
	_ClearScrap()
	Exit
EndFunc   ;==>_Tray_Exit

Func _Tray_Reset()
	$TIMER = 0
EndFunc   ;==>_Tray_Reset
