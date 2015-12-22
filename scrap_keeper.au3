#RequireAdmin

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
Global $USER_ZoomBucks, $PASS_ZoomBucks
Global $USER_SwagBucks, $PASS_SwagBucks
Global $USER_PrizeRebel, $PASS_PrizeRebel
Global $USER_PaidVert, $PASS_PaidVert
Global $USER_iRazoo, $PASS_iRazoo
Global $USER_GiftHulk, $PASS_GiftHulk

_ReadLogin($USER_ZoomBucks, $PASS_ZoomBucks, 'ZoomBucks')
_ReadLogin($USER_SwagBucks, $PASS_SwagBucks, 'SwagBucks')
_ReadLogin($USER_PrizeRebel, $PASS_PrizeRebel, 'PrizeRebel')
_ReadLogin($USER_PaidVert, $PASS_PaidVert, 'PaidVert')
_ReadLogin($USER_iRazoo, $PASS_iRazoo, 'iRazoo')
_ReadLogin($USER_GiftHulk, $PASS_GiftHulk, 'GiftHulk')

_DoGUI()

Func _DoGUI()
   Local $gui = GUICreate("Scrap Keeper", 432, 311, 314, 216)
   Local $buttonGo = GUICtrlCreateButton("Go", 296, 272, 75, 25)
   GUICtrlCreateLabel("ZoomBucks", 11, 6, 61, 17)
   $USER_ZoomBucks = GUICtrlCreateInput($USER_ZoomBucks, 19, 30, 177, 21)
   $PASS_ZoomBucks = GUICtrlCreateInput($PASS_ZoomBucks, 19, 54, 177, 21)
   GUICtrlCreateLabel("Swagbucks", 8, 88, 60, 17)
   $USER_SwagBucks = GUICtrlCreateInput($USER_SwagBucks, 24, 112, 169, 21)
   $PASS_SwagBucks = GUICtrlCreateInput($PASS_SwagBucks, 24, 136, 169, 21)
   GUICtrlCreateLabel("PrizeRebel", 11, 166, 55, 17)
   $USER_PrizeRebel = GUICtrlCreateInput($USER_PrizeRebel, 19, 190, 169, 21)
   $PASS_PrizeRebel = GUICtrlCreateInput($PASS_PrizeRebel, 19, 214, 169, 21)
   GUICtrlCreateLabel("PaidVert", 233, 6, 44, 17)
   $USER_PaidVert = GUICtrlCreateInput($USER_PaidVert, 249, 30, 169, 21)
   $PASS_PaidVert = GUICtrlCreateInput($PASS_PaidVert, 249, 54, 169, 21)
   GUICtrlCreateLabel("iRazoo", 233, 86, 37, 17)
   $USER_iRazoo = GUICtrlCreateInput($USER_iRazoo, 249, 110, 169, 21)
   $PASS_iRazoo = GUICtrlCreateInput($PASS_iRazoo, 249, 134, 169, 21)
   GUICtrlCreateLabel("GiftHulk", 233, 166, 42, 17)
   $USER_GiftHulk = GUICtrlCreateInput($USER_GiftHulk, 249, 190, 169, 21)
   $PASS_GiftHulk = GUICtrlCreateInput($PASS_GiftHulk, 249, 214, 169, 21)
   GUICtrlCreateLabel("reset every x hours", 8, 272, 93, 17)
   $DELAY = GUICtrlCreateInput($DELAY, 16, 288, 41, 21)
   GUISetState(@SW_SHOW)

   While 1
	  Switch GUIGetMsg()
		 Case $buttonGo
			$USER_ZoomBucks = GUICtrlRead($USER_ZoomBucks)
			$PASS_ZoomBucks = GUICtrlRead($PASS_ZoomBucks)

			$USER_SwagBucks = GUICtrlRead($USER_SwagBucks)
			$PASS_SwagBucks = GUICtrlRead($PASS_SwagBucks)

			$USER_PrizeRebel = GUICtrlRead($USER_PrizeRebel)
			$PASS_PrizeRebel = GUICtrlRead($PASS_PrizeRebel)

			$USER_PaidVert = GUICtrlRead($USER_PaidVert)
			$PASS_PaidVert = GUICtrlRead($PASS_PaidVert)

			$USER_iRazoo = GUICtrlRead($USER_iRazoo)
			$PASS_iRazoo = GUICtrlRead($PASS_iRazoo)

			$USER_GiftHulk = GUICtrlRead($USER_GiftHulk)
			$PASS_GiftHulk = GUICtrlRead($PASS_GiftHulk)

			$DELAY = GUICtrlRead($DELAY)

			GUIDelete()

			_WriteLogin($USER_ZoomBucks, $PASS_ZoomBucks, 'ZoomBucks')
			_WriteLogin($USER_SwagBucks, $PASS_SwagBucks, 'SwagBucks')
			_WriteLogin($USER_PrizeRebel, $PASS_PrizeRebel, 'PrizeRebel')
			_WriteLogin($USER_PaidVert, $PASS_PaidVert, 'PaidVert')
			_WriteLogin($USER_iRazoo, $PASS_iRazoo, 'iRazoo')
			_WriteLogin($USER_GiftHulk, $PASS_GiftHulk, 'GiftHulk')
			IniWrite($INI, 'settings', 'delay', $DELAY)

			_Keep()
		 Case $GUI_EVENT_CLOSE
			Exit
	  EndSwitch
   WEnd
EndFunc

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
EndFunc

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

	  _SendLogin($USER_ZoomBucks, $PASS_ZoomBucks)
	  _SendLogin($USER_SwagBucks, $PASS_SwagBucks)
	  _SendLogin($USER_PrizeRebel, $PASS_PrizeRebel)
	  _SendLogin($USER_PaidVert, $PASS_PaidVert)
	  _SendLogin($USER_iRazoo, $PASS_iRazoo)
	  _SendLogin($USER_GiftHulk, $PASS_GiftHulk)

	  WinSetOnTop($WIN, '', 0)
	  BlockInput(0)

	  $WIN = WinExists($WIN) ; loop again if false
   Until $WIN <> 0
EndFunc

Func _SendDelayed($delay, $keys)
   While WinActive($WIN) = 0
	  If WinExists($WIN) = 0 Then Return

	  WinActivate($WIN)
	  Sleep(10)
   WEnd

   AutoItSetOption('SendKeyDelay', $delay)
   Send($keys)
EndFunc

Func _SendLogin($user, $pass)
   If $user <> '' And $pass <> '' Then
	  _SendDelayed(500, '{TAB}')
	  _SendDelayed(10, $user)
	  _SendDelayed(500, '{TAB}')
	  _SendDelayed(10, $pass)
	  ;_SendDelayed(500, '{TAB}')
	  _SendDelayed(500, '{TAB}{ENTER}')
	  Sleep(3000)
	  _SendDelayed(500, '+{TAB 3}')
   EndIf

   _SendDelayed(500, '{RIGHT}')
EndFunc

Func _ClearScrap()
   _KillAll('scrap.exe')
   _KillAll('chromedriver.exe')
   _KillAll('chrome.exe')
EndFunc

Func _KillAll($name)
   While ProcessExists($name) <> 0
      ProcessClose($name)
   WEnd
EndFunc

Func _Seconds2Time($seconds)
   Local $hours = Int($seconds / 3600)
   $seconds -= $hours * 3600
   Local $minutes = Int($seconds / 60)
   $seconds -= $minutes * 60
   Return StringFormat('%02d:%02d:%02d', $hours, $minutes, $seconds)
EndFunc

Func _ReadLogin(ByRef $user, ByRef $pass, $section)
   $user = IniRead($INI, $section, 'user', '')
   $pass = IniRead($INI, $section, 'pass', '')
EndFunc

Func _WriteLogin($user, $pass, $section)
   IniWrite($INI, $section, 'user', $user)
   IniWrite($INI, $section, 'pass', $pass)
EndFunc

Func _Tray_Exit()
   _ClearScrap()
   Exit
EndFunc

Func _Tray_Reset()
   $TIMER = 0
EndFunc