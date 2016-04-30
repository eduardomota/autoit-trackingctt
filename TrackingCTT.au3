#include-once
#include <Array.au3>
#include <Inet.au3>
#include <String.au3>
#include "HTML.au3"

; #INDEX# =======================================================================================================================
; Title .........: Tracking CTT
; Version .......: 1.0
; AutoIt Version : 3.3.14.2
; Language ......: Portugu�s (pt_PT)
; Description ...: UDF para obter informa��es de tracking CTT
; Author(s) .....: Eduardo Mota
; Dll ...........: -
; Dependencies ..: HTML UDF from Dhilip89
; ===============================================================================================================================

; #VARS/CONSTANTS# ==============================================================================================================
; $ctt_url_prefix 		= Prefixo do URL (antes dos par�metros)
; $ctt_url_sufix 		= Sufixo do URL (depois dos par�metros)
; $ctt_tracking_regex	= Padr�o Regex comparativo de tracking (XX012345678XX)
; ===============================================================================================================================
Global Const $ctt_url_prefix = "https://www.ctt.pt/feapl_2/app/open/objectSearch/objectSearch.jspx?objects=", _
	$ctt_url_sufix = "" , _
	$ctt_tracking_regex = "[A-z]{2}\d{9}[A-z]{2}"

; #CURRENT# =====================================================================================================================
;_trackingctt_obterultimoestado
; ===============================================================================================================================

;===============================================================================
;
; Function Name:   	_trackingctt_obterultimoestado()
; Description:      Obter o �ltimo estado sobre um determinado tracking number
; Parameter(s):     $sTrackingnumber     - O n�mero tracking sobre o qual se
;										  se pretende mais informa��es
;					$bClearentities		- [optional] Se Verdadeiro limpar
;										  e retornar valores em formato
;										  leg�vel inv�s de html
;
; Return Value(s):  On Success  - Retorna um array com as informa��es de estado
;                  				  'Array'[0] = Tracking Number
;                  				  'Array'[1] = Data
;								  'Array'[2] = Hora
;								  'Array'[3] = Estado
;								  'Array'[4] = Local
;								  'Array'[5] = Motivo
;								  'Array'[6] = Receptor
;					On Failure  - Retorna vari�vel da falha correspondente o set error
;                                 1 = Erro na Liga��o/Obter dados
;								  2 = C�digo Inv�lido (XX012345678XX)
;								  3 = Erro a processar informa��o
;								  4 = N�mero n�o encontrado
;								  5 = Erro ao obter p�gina
;								  6 = Erro ao descodificar HTML Entities
;
; Author(s):        Eduardo Mota
;
;===============================================================================

Func _trackingctt_obterultimoestado(ByRef $sTrackingnumber, $bClearentities = 1)
	Local $sTrackinginfo[7], _	; Localiza��o final das informa��es de Tracking.
		  $ctt_url_final, _	; URL Final para tracking
		  $ctt_trkbuffer	; Localiza��o interm�dia da informa��o obtida

	If Not StringRegExp($sTrackingnumber,$ctt_tracking_regex) Then
		SetError(2)
		Return 2
	EndIf

	$ctt_url_final = $ctt_url_prefix & $sTrackingnumber & $ctt_url_sufix
	$ctt_trkbuffer = _INetGetSource($ctt_url_final)
	If @error Then
		SetError(1)
		Return 1		; Terminar se ocorrer erro a obter dados
	EndIf

	If Not StringInStr($ctt_trkbuffer,$sTrackingnumber) Then
		SetError(5)
		Return 5
	EndIf

	$ctt_trkbuffer = _StringBetween($ctt_trkbuffer, "<td>", "</td>")
	If @error Then
		SetError(3)
		Return 3
	EndIf

	If UBound($ctt_trkbuffer) < 10 Then
		SetError(4)
		Return 4 ; Se o array for menor que 10 � prov�vel que o n�mero n�o tenha sido encontrado
	EndIf

	; Atribuir informa��es de tracking existentes
	$sTrackinginfo[0] = $sTrackingnumber	; Tracking Number (XX012345678XX)
	$sTrackinginfo[1] = $ctt_trkbuffer[2]	; Data (AAAA/MM/DD)
	$sTrackinginfo[2] = $ctt_trkbuffer[3]	; Hora (HH:MM)
	$sTrackinginfo[3] = $ctt_trkbuffer[6]	; Estado
	$sTrackinginfo[4] = $ctt_trkbuffer[8]	; Local
	$sTrackinginfo[5] = $ctt_trkbuffer[7]	; Motivo
	$sTrackinginfo[6] = $ctt_trkbuffer[9]	; Receptor

	; Limpar HTML Entities
	If $bClearentities Then
		For $i = 3 To 6
			$sTrackinginfo[$i] = _HTMLDecode($sTrackinginfo[$i])
			If @error Then
				SetError(6)
				Return 6
			EndIf
		Next
	Endif

	Return $sTrackinginfo

EndFunc