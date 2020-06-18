; Made by Freddie Chessell
; Credits: https://www.autohotkey.com/boards/viewtopic.php?t=44677

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
;#NoTrayIcon ; Completely remove tray icon
#Include lib\BrightnessSetter.ahk



; Settings
global defaultMonitorInput := 15 ; My desktop
global altMonitorInput := 17 ; My work laptop

; Setup variables
global currentInput :=
global maximumInput :=
global Physical_Monitor :=
global brightnessSetter := new BrightnessSetter()




; Change the tray icon
MONITOR_ICON := 90
Menu, Tray, Icon, shell32.dll, %MONITOR_ICON%
Menu, Tray, Tip, MonitorSwitcher

; Creates a separator line
Menu, Tray, Add

; Add change settings button
MenuInputInfoText := "Get monitor info"
Menu, Tray, Add, %MenuInputInfoText%, MenuHandler
Menu, Tray, Default, %MenuInputInfoText% ; Set as tray double click item




GetMonitorInfo() {
	global
	
	
	; Initialize Monitor handle
	; Pointer to monitor, flag to return primary monitor on failure
	hMon := DllCall("MonitorFromPoint", "int64", 0, "uint", 1)

	; Find number of Physical Monitors
	DllCall("dxva2\GetNumberOfPhysicalMonitorsFromHMONITOR", "int", hMon, "uint*", nMon)

	; Get Physical Monitor from handle
	VarSetCapacity(Physical_Monitor, (A_PtrSize ? A_PtrSize : 4) + 128, 0)

	; Monitor handle, monitor array size, pointer to array with monitor
	DllCall("dxva2\GetPhysicalMonitorsFromHMONITOR", "int", hMon, "uint", nMon, "int", &Physical_Monitor)

	hPhysMon := NumGet(Physical_Monitor)

	DllCall("dxva2\GetVCPFeatureAndVCPFeatureReply"
			, "int", handle
			, "char", 0x60 ; VCP code for Input Source Select
			, "Ptr", 0
			, "uint*", currentInput
			, "uint*", maximumInput)
}

SetMonitorInputSource(source) {
	global
	
	if (source == defaultMonitorInput) {
		brightnessSetter.SetBrightness(100) ; Set max laptop brightness while not using secondary screen
	} else {
		brightnessSetter.SetBrightness(-100) ; Dim laptop brightness while duplicating work screen
	}
	
	DllCall("dxva2\SetVCPFeature"
			, "int", handle
			, "char", 0x60 ; VCP code for Input Source Select
			, "uint", source)
}


Return


;------------------------------------------------------------------------------
; Monitor Input to HDMI
;------------------------------------------------------------------------------

; Gets info for your monitor's current input
MenuHandler:
	if (A_ThisMenuItem = MenuInputInfoText) {
		GetMonitorInfo()
		MsgBox, % "Monitor description: " . StrGet(&Physical_Monitor+(A_PtrSize ? A_PtrSize : 4), "utf-16") . "`nCurrent Input: " . currentInput . "`nMax Input: " . maximumInput
		Return
	}
	Return

; SHIFT+ALT+M
!+m::
	GetMonitorInfo()
	if (currentInput == defaultMonitorInput) {
		SetMonitorInputSource(altMonitorInput)
	} else {
		SetMonitorInputSource(defaultMonitorInput)
	}
	Return
