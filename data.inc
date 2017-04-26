__UNICODE__ equ 1
include \masm32\include\masm32rt.inc
includelib colorstatic\colorstatic.lib
includelib setti\setti.lib
includelib lang\lang.lib
includelib ex_api\ex_api.lib
include lib.inc

paint_proc   proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

;macro
    xparam MACRO n_const, ident
        mov ebx, ident
        mov ecx, n_const
        shl ecx, 16
        or ecx, ebx
        EXITM <ecx>
    ENDM

.const
    STR_A          equ 0
    STR_W          equ -1
    STR_ITALIC     equ 010000h
    STR_UNDERLINE  equ 0100h
    STR_STRIKEOUT  equ 01h

.data
    UC ClassXpix,   "newxpix",0
    UC ClassXY,     "newxpix_xy",0
    UC button,      "button",0
    UC static,      "static",0
    UC edit,        "edit",0
    UC hotkey,      "msctls_hotkey32",0
    UC combobox,    "combobox",0
    UC VerdanaFont, "Verdana",0
    align word

    ed_f                     dd 0
    dist_f                   dd 1
    pri_f                    dd 1
    up_down                  dd 0
    sad3                     dd 0
    sub_x                    dd 0
    sub_y                    dd 0
    clip_xy                  dd 0
    clip_xy_1                dd 1
    clip_xy_2                dd 1
    fLng                     dd 1
    color_hotkey_ReferPoint  dd 000000ffh
    color_hotkey_BlockX      dd 000000ffh
    color_hotkey_BlockY      dd 000000ffh
    color_hotkey_ColorClip   dd 000000ffh

    s_Translation            dd 0, 10010  ; Перевод
    s_About                  dd 0, 10020  ; О программе
    s_BindingCoord           dd 0, 10040  ; Привязка координат к курсору
    s_ColorClipboard         dd 0, 10050  ; Цвет в буфер обмена
    s_BlockY                 dd 0, 10060  ; Блок перемещения по Y
    s_BlockX                 dd 0, 10070  ; Блок перемещения по X
    s_ReferencePoint         dd 0, 10080  ; Точка отсчёта
    s_KeyboardShortcuts      dd 0, 10090  ; Сочетания клавиш
    s_Pixels                 dd 0, 10100  ; Пиксели
    s_Millimeters            dd 0, 10110  ; Миллиметры
    s_Distance               dd 0, 10115  ; Расстояние
    s_UnitsOfMeasurement     dd 0, 10120  ; Единицы измерения
    s_Settings               dd 0, 10130  ; Настройки
    s_ScreenRuler            dd 0, 10140  ; Экранная линейка
    s_RestartProgram         dd 0, 10150  ; Перезапустите программу

    id_Settings              dd 3070, 0, -1
    id_UnitsOfMeasurement    dd 3065, 0, -1
    id_KeyboardShortcuts     dd 3060, 0, -1
    id_ColorClipboard        dd 3055, 0, -1
    id_BlockY                dd 3050, 0, -1
    id_BlockX                dd 3045, 0, -1
    id_ReferencePoint        dd 3040, 0, -1
    id_combobox              dd 3035, 0, 0
    id_hotkey_ReferPoint     dd 3030, 0, 0
    id_hotkey_BlockX         dd 3025, 0, 0
    id_hotkey_BlockY         dd 3020, 0, 0
    id_hotkey_ColorClip      dd 3015, 0, 0
    id_BindingCoord          dd 3010, 0, 0
    id_Distance              dd 3005, 0, 0

.data?
    hInstance   dd ?
    hWin        dd ?
    hWinXY      dd ?
    hWnd2       dd ?
    hSt1        dd ?
    hSt2        dd ?
    hSt3        dd ?
    sad1        dd ?
    sad2        dd ?
    DDX         dd ?
    DDY         dd ?
    qq1         dd ?
    qq2         dd ?
    hdc_des     dd ?
    hMenu       dd ?
    hMenu1      dd ?
    ini_f       dd ?
    monx        dd ?
    mony        dd ?
    monx_mm     dd ?
    mony_mm     dd ?
    monx_k      dd ?
    mony_k      dd ?

    temp_str    TCHAR 1024 dup (?)
    hLng        TCHAR 64 dup (?)
    Name_lng    TCHAR 64 dup (?)
    
    wc          WNDCLASSEX <>
    subb        POINT <>
    iccex       INITCOMMONCONTROLSEX <>
    msg         MSG <>
    
