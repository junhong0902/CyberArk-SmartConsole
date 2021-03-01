#AutoIt3Wrapper_UseX64=n
Opt("MustDeclareVars", 1)
AutoItSetOption("WinTitleMatchMode", 3) ; EXACT_MATCH!

;============================================================
;             PSM AutoIt Dispatcher
;============================================================
#include "PSMGenericClientWrapper.au3"
#include <WinAPIFiles.au3>
#include <String.au3>

;=======================================
; Consts & Globals
;=======================================
Global Const $DISPATCHER_NAME									= "PSM for SmartConsole" ;
Global Const $CLIENT_EXECUTABLE									= "C:\Program Files (x86)\CyberArk\PSM\Components\smartconsole\Check_Point_SmartConsole_R80_30_jumbo_HF_B86_Win_portable\SmartConsole.exe"
Global Const $PS_EXECUTABLE										= "C:\Program Files (x86)\CyberArk\PSM\Components\smartconsole\psm-create-smartconsole-xml.ps1"
Global Const $ERROR_MESSAGE_TITLE  								= "PSM " & $DISPATCHER_NAME & " Dispatcher error message"
Global Const $LOG_MESSAGE_PREFIX 								= $DISPATCHER_NAME & " Dispatcher - "

Global $ConnectionClientPID = 0
Global $TargetAddress
Global $TargetUsername
Global $TargetPassword
;Global $XMLFile = "C:\Windows\Temp\"
Global $XMLFile = "C:\Program Files (x86)\CyberArk\PSM\Components\smartconsole\temp\"
Global $fileName = @YEAR & "-" & @MON & "-" & @MDay & "-" & @HOUR & "-" & @MIN & "-" & @SEC & "-SmartConsole.LoginParams"
Global $ExecutableWithParameters

;=======================================
; Code
;=======================================
Exit Main()
;=======================================
; Main
;=======================================
Func Main()
	; Init PSM Dispatcher utils wrapper
	ToolTip ("Initializing...")
	if (PSMGenericClient_Init() <> $PSM_ERROR_SUCCESS) Then
		Error(PSMGenericClient_PSMGetLastErrorString())
	EndIf

	LogWrite("successfully initialized Dispatcher Utils Wrapper")

	FetchSessionProperties()

	LogWrite("mapping local drives")
	if (PSMGenericClient_MapTSDrives() <> $PSM_ERROR_SUCCESS) Then
		Error(PSMGenericClient_PSMGetLastErrorString())
	 EndIf

	LogWrite("starting client application")
	ToolTip ("Starting " & $DISPATCHER_NAME & "...")

    ; Format XML file name
	$XMLFile = $XMLFile & $fileName
	
	; Convert password string to hex
	Local $HexPassword = _StringToHex ($TargetPassword)
	Local $HexPath = _StringToHex ($XMLFile)
	
    ; Launch powershell script
	;Run('powershell.exe -File ' & '"' & $PS_EXECUTABLE & '" ' & $TargetUsername & ' ' & $TargetAddress & ' ' & $fileName, "", @SW_HIDE)
	Run('powershell.exe -File ' & '"' & $PS_EXECUTABLE & '" ' & $TargetUsername & ' ' & $TargetAddress & ' ' & $HexPath & ' ' & $HexPassword , "", @SW_HIDE)

	; Sleep for 3 seconds
	Sleep(3000)

	; Format client executables with parameters
    $ExecutableWithParameters = $CLIENT_EXECUTABLE & " -p " & '"' & $XMLFile & '"'

	; Launch 3rd party application
    $ConnectionClientPID = Run($ExecutableWithParameters)

   ; Sleep for 10 seconds to give smartconsole some time to load
	Sleep(10000)
	
	; Delete the xml file
	FileDelete($XMLFile)
	
	
	
    if ($ConnectionClientPID == 0) Then
		Error(StringFormat("Failed to execute process [%s]", $CLIENT_EXECUTABLE, @error))
    EndIf

    ; Send PID to PSM as early as possible so recording/monitoring can begin
    LogWrite("sending PID to PSM")
	
	if (PSMGenericClient_SendPID($ConnectionClientPID) <> $PSM_ERROR_SUCCESS) Then
	  Error(PSMGenericClient_PSMGetLastErrorString())
    EndIf
	
   	; Terminate PSM Dispatcher utils wrapper
	LogWrite("Terminating Dispatcher Utils Wrapper")
	PSMGenericClient_Term()

	Return $PSM_ERROR_SUCCESS
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: FetchSessionProperties
; Description ...: Fetches properties required for the session from the PSM
; Parameters ....: None
; Return values .: None
; ===============================================================================================================================
Func FetchSessionProperties() ; CHANGE_ME (If need of more parameters)

	; Get the Session User Name
	if (PSMGenericClient_GetSessionProperty("Username", $TargetUserName) <> $PSM_ERROR_SUCCESS) Then
		Error(PSMGenericClient_PSMGetLastErrorString())
	EndIf

	; Get the Session Password
	if (PSMGenericClient_GetSessionProperty("Password", $TargetPassword) <> $PSM_ERROR_SUCCESS) Then
		Error(PSMGenericClient_PSMGetLastErrorString())
	EndIf

	if (PSMGenericClient_GetSessionProperty("Address", $TargetAddress) <> $PSM_ERROR_SUCCESS) Then
		Error(PSMGenericClient_PSMGetLastErrorString())
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: Error
; Description ...: An exception handler - displays an error message and terminates the dispatcher
; Parameters ....: $ErrorMessage - Error message to display
; 				   $Code 		 - [Optional] Exit error code
; ===============================================================================================================================
Func Error($ErrorMessage, $Code = -1)

	; If the dispatcher utils DLL was already initialized, write an error log message and terminate the wrapper
	if (PSMGenericClient_IsInitialized()) Then
		LogWrite($ErrorMessage, True)
		PSMGenericClient_Term()
	EndIf

	Local $MessageFlags = BitOr(0, 16, 262144) ; 0=OK button, 16=Stop-sign icon, 262144=MsgBox has top-most attribute set

	MsgBox($MessageFlags, $ERROR_MESSAGE_TITLE, $ErrorMessage)

	; If the connection component was already invoked, terminate it
	if ($ConnectionClientPID <> 0) Then
		ProcessClose($ConnectionClientPID)
		$ConnectionClientPID = 0
	EndIf

	Exit $Code
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: LogWrite
; Description ...: Write a PSMWinSCPDispatcher log message to standard PSM log file
; Parameters ....: $sMessage - [IN] The message to write
;                  $LogLevel - [Optional] [IN] Defined if the message should be handled as an error message or as a trace messge
; Return values .: $PSM_ERROR_SUCCESS - Success, otherwise error - Use PSMGenericClient_PSMGetLastErrorString for details.
; ===============================================================================================================================
Func LogWrite($sMessage, $LogLevel = $LOG_LEVEL_TRACE)
	Return PSMGenericClient_LogWrite($LOG_MESSAGE_PREFIX & $sMessage, $LogLevel)
EndFunc