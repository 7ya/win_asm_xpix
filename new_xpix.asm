; Author:            7ya
; Update date:       26.04.2017
; Contact:           7ya@protonmail.com
; Internet address:  https://github.com/7ya/win_asm_xpix
; License:           GPL-3.0
;**********************************************************************************************************************************************************
include data.inc
.code
start:
;**********************************************************************************************************************************************************
    invoke GetModuleHandle, 0
    mov hInstance, eax

    invoke ini_ini, uc$("xpix.ini"), 1024
    mov ini_f, eax
    cmp ini_f, 1
    jne @F
        invoke get_data, 0, addr fLng
    @@:
    invoke read_lng, uc$("xpix.lng"), 262144
    invoke get_str, addr s_Translation, 13, fLng, hInstance

    invoke GetSystemMetrics, SM_CXSCREEN
    mov monx, eax
    invoke GetSystemMetrics, SM_CYSCREEN
    mov mony, eax
    invoke GetDC, 0
    mov hdc_des, eax
    invoke GetDeviceCaps, hdc_des, HORZSIZE
    mov monx_mm, eax
    invoke GetDeviceCaps, hdc_des, VERTSIZE
    mov mony_mm, eax
    finit
    fild monx
    fidiv monx_mm
    fstp monx_k
    fild mony
    fidiv mony_mm
    fstp mony_k
        
    mov iccex.dwSize, sizeof INITCOMMONCONTROLSEX
    mov iccex.dwICC, ICC_WIN95_CLASSES
    invoke InitCommonControlsEx, addr iccex

    mov wc.cbSize, sizeof WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, offset XPix_Proc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 40
    mrm wc.hInstance, hInstance
    invoke LoadIcon, hInstance, 900
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    invoke LoadCursor, 0, IDC_ARROW
    mov wc.hCursor, eax
    mov wc.hbrBackground, COLOR_BTNFACE+1
    mov wc.lpszMenuName, 0
    mov wc.lpszClassName, offset ClassXpix
    invoke RegisterClassEx, addr wc
    invoke crtwindow, s_ScreenRuler, 0, 0, addr ClassXpix, 0, 0, 365, 260, WS_MINIMIZEBOX or WS_SYSMENU, 0, 0, 0, 0, 0, hInstance
    mov hWin, eax
    cmp ini_f, 1
    jne @F
        call read_setting
    @@:
    invoke window_center, hWin
    invoke ShowWindow, hWin, SW_SHOWNORMAL
    invoke SendMessage, hWin, WM_NCPAINT, 1, 0
    start_msg:
        invoke GetMessage, addr msg, 0, 0, 0
        or eax, eax
        je end_msg
        invoke tab_focus, addr msg, hWin
        cmp eax, 1
        je start_msg
        invoke TranslateMessage, addr msg
        invoke DispatchMessage, addr msg
        jmp start_msg
    end_msg:
    invoke ExitProcess, msg.wParam
;**********************************************************************************************************************************************************
XPix_Proc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL loc_m:DWORD
LOCAL ps:PAINTSTRUCT
.IF uMsg== WM_COMMAND
    mov eax, wParam
    ror eax, 16
    .IF ax== CBN_SELENDOK || ax== BN_CLICKED || ax== EN_CHANGE
        shr eax, 16
        .IF eax== id_combobox       ;единицы измерения
            invoke SendMessage, h(offset id_combobox), CB_GETCURSEL, 0, 0
            invoke SendMessage, h(offset id_combobox), CB_GETITEMDATA, eax, 0
            mov ed_f, eax
            inc qq1
        .ELSEIF eax== id_Distance   ;расстояние
            .if dist_f== 1
                mov dist_f, 0
                invoke SetWindowPos, hWinXY, HWND_TOP, 0, 0, 38, 33, SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOMOVE
            .else
                mov dist_f, 1
                invoke SetWindowPos, hWinXY, HWND_TOP, 0, 0, 38, 49, SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOMOVE
            .endif
            inc qq1
        .ELSEIF eax== id_hotkey_ReferPoint   ;точка отсчета
            invoke reghotkey, hWnd, 2200, offset id_hotkey_ReferPoint, offset color_hotkey_ReferPoint
        .ELSEIF eax== id_hotkey_BlockX   ;блок X
            invoke reghotkey, hWnd, 2201, offset id_hotkey_BlockX, offset color_hotkey_BlockX
        .ELSEIF eax== id_hotkey_BlockY   ;блок Y
            invoke reghotkey, hWnd, 2202, offset id_hotkey_BlockY, offset color_hotkey_BlockY
        .ELSEIF eax== id_hotkey_ColorClip   ;цвет в буфер
            invoke reghotkey, hWnd, 2203, offset id_hotkey_ColorClip, offset color_hotkey_ColorClip
        .ELSEIF eax== id_BindingCoord   ;привязка
            .if pri_f== 1
                mov pri_f, 0
            .else
                mov pri_f, 1
            .endif
        .ELSEIF eax== 5000   ;о программе
            call about
        .ELSEIF eax>= 5001   ;Смена языка
            movzx ebx, ax
            sub ebx, 5000
            mov fLng, ebx
            invoke get_str, addr s_RestartProgram, 0, fLng, 0
            invoke MessageBox, hWnd, s_RestartProgram, s_ScreenRuler, MB_OK
            invoke SendMessage, hWnd, WM_CLOSE, 0, 0
        .ENDIF
    .ENDIF

.ELSEIF uMsg== WM_HOTKEY
    mov eax, wParam
    .if ax== 2200
        invoke GetCursorPos, addr subb
        inc qq1
    .elseif ax== 2201
        mov clip_xy, 1
        call clip_cur
    .elseif ax== 2202
        mov clip_xy, 2
        call clip_cur
    .elseif ax== 2203
        call get_color
    .endif

.ELSEIF uMsg== WM_CREATE
    invoke CreateMenu
    mov hMenu, eax
    invoke CreateLngMenu, hMenu, fLng
    invoke AppendMenu, hMenu, MF_STRING, 5000, s_About
    invoke SetMenu, hWnd, hMenu
    
    invoke crtwindow, 0, offset id_combobox, hWnd, offset combobox, 18, 35, 120, 110, 050200003h, 0, offset VerdanaFont, 12, 400, 0, hInstance
    invoke SendMessage, h(offset id_combobox), CB_ADDSTRING, 0, s_Pixels
    invoke SendMessage, h(offset id_combobox), CB_SETITEMDATA, 0, 0
    invoke SendMessage, h(offset id_combobox), CB_ADDSTRING, 0, s_Millimeters
    invoke SendMessage, h(offset id_combobox), CB_SETITEMDATA, 1, 1
    invoke SendMessage, h(offset id_combobox), CB_SETCURSEL, 0, 0
    invoke crtwindow, 0, offset id_hotkey_ReferPoint, hWnd, offset hotkey, 45, 95, 85, 25, 050000000h, 000000200h, offset VerdanaFont, 14, 400, 0, hInstance
    invoke SendMessage, eax, HKM_SETRULES, HKCOMB_SC or HKCOMB_CA or HKCOMB_SA or HKCOMB_SCA, HOTKEYF_CONTROL
    invoke crtwindow, 0, offset id_hotkey_BlockX, hWnd, offset hotkey, 45, 125, 85, 25, 050000000h, 0, offset VerdanaFont, 14, 400, 0, hInstance
    invoke SendMessage, eax, HKM_SETRULES, HKCOMB_SC or HKCOMB_CA or HKCOMB_SA or HKCOMB_SCA, HOTKEYF_CONTROL
    invoke crtwindow, 0, offset id_hotkey_BlockY, hWnd, offset hotkey, 45, 155, 85, 25, 050000000h, 0, offset VerdanaFont, 14, 400, 0, hInstance
    invoke SendMessage, eax, HKM_SETRULES, HKCOMB_SC or HKCOMB_CA or HKCOMB_SA or HKCOMB_SCA, HOTKEYF_CONTROL
    invoke crtwindow, 0, offset id_hotkey_ColorClip, hWnd, offset hotkey, 45, 185, 85, 25, 050000000h, 0, offset VerdanaFont, 14, 400, 0, hInstance
    invoke SendMessage, eax, HKM_SETRULES, HKCOMB_SC or HKCOMB_CA or HKCOMB_SA or HKCOMB_SCA, HOTKEYF_CONTROL
    invoke crtwindow, s_BindingCoord, offset id_BindingCoord, hWnd, offset button, 15, 225, 240, 25, 050000003h, 0, offset VerdanaFont, 12, 400, 0, hInstance
    invoke SendMessage, eax, BM_SETCHECK, BST_CHECKED, 0
    invoke crtwindow, s_ColorClipboard, offset id_ColorClipboard, hWnd, offset static, 135, 190, 205, 20, 050000000h, 0, offset VerdanaFont, 12, 400, 0, hInstance
    invoke crtwindow, s_BlockY, offset id_BlockY, hWnd, offset static, 135, 160, 205, 20, 050000000h, 0, offset VerdanaFont, 12, 400, 0, hInstance
    invoke crtwindow, s_BlockX, offset id_BlockX, hWnd, offset static, 135, 130, 205, 20, 050000000h, 0, offset VerdanaFont, 12, 400, 0, hInstance
    invoke crtwindow, s_ReferencePoint, offset id_ReferencePoint, hWnd, offset static, 135, 100, 205, 20, 050000000h, 0, offset VerdanaFont, 12, 400, 0, hInstance
    invoke crtwindow, s_KeyboardShortcuts, offset id_KeyboardShortcuts, hWnd, offset button, 10, 70, 345, 150, WS_CHILD or WS_VISIBLE or BS_GROUPBOX, 0, offset VerdanaFont, 12, 400, 0, hInstance
    invoke crtwindow, s_UnitsOfMeasurement, offset id_UnitsOfMeasurement, hWnd, offset button, 10, 15, 345, 50, WS_CHILD or WS_VISIBLE or BS_GROUPBOX, 0, offset VerdanaFont, 12, 400, 0, hInstance
    invoke crtwindow, s_Settings, offset id_Settings, hWnd, offset button, 5, 0, 355, 255, 050000307h, 0, offset VerdanaFont, 12, 400, 0, hInstance
    invoke crtwindow, s_Distance, offset id_Distance, hWnd, offset button, 260, 225, 95, 25, 050000003h, 0, offset VerdanaFont, 12, 400, 0, hInstance
    invoke SendMessage, eax, BM_SETCHECK, BST_CHECKED, 0
    
    mov wc.style, CS_HREDRAW or CS_VREDRAW or CS_NOCLOSE
    invoke LoadCursor, 0, IDC_SIZEALL
    mov wc.hCursor, eax
    mov wc.lpfnWndProc, offset WndProcXY
    invoke CreateSolidBrush, 0ffffffh
    mov wc.hbrBackground, eax
    mov wc.lpszClassName, offset ClassXY
    invoke RegisterClassEx, addr wc
    invoke CreateWindowEx, WS_EX_TOPMOST or WS_EX_TOOLWINDOW, addr ClassXY, 0, WS_VISIBLE or WS_POPUP, 0, 0, 38, 49, 0, 0, hInstance, 0
    mov hWinXY, eax
    invoke SetTimer, hWinXY, 2303, 9, 0
    
.ELSEIF uMsg== WM_PAINT
    invoke BeginPaint, hWnd, addr ps
    invoke paint_proc, ps.hdc, color_hotkey_ReferPoint, 15, 95, 25, 25
    invoke paint_proc, ps.hdc, color_hotkey_BlockX, 15, 125, 25, 25
    invoke paint_proc, ps.hdc, color_hotkey_BlockY, 15, 155, 25, 25
    invoke paint_proc, ps.hdc, color_hotkey_ColorClip, 15, 185, 25, 25
    invoke EndPaint, hWnd, addr ps

.ELSEIF uMsg== WM_LBUTTONDOWN
    invoke SetFocus, hWnd
    
.ELSEIF uMsg== WM_CLOSE
    invoke ShowWindow, hWnd, SW_HIDE
    invoke free_lng
    call writ_setting
    invoke ReleaseDC, 0, hdc_des
    invoke KillTimer, hWinXY, 2303
    invoke PostQuitMessage, 0
.ELSE
    invoke DefWindowProc, hWnd, uMsg, wParam, lParam
    ret
.ENDIF
return 0
XPix_Proc endp
;**********************************************************************************************************************************************************
WndProcXY proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
.IF uMsg== WM_CREATE
    invoke color_static, 0, 0DDFFDDh, 0ff0000h, 0, 0, 38, 16, hWnd, hInstance
    mov hSt1, eax
    invoke SendMessage, hSt1, WM_SETFONT, FUNC(RetFontHEx, offset VerdanaFont, 12, 400, 0), 1
    invoke color_static, 0, 0DDFFDDh, 0ff0000h, 0, 16, 38, 16, hWnd, hInstance
    mov hSt2, eax
    invoke SendMessage, hSt2, WM_SETFONT, FUNC(RetFontHEx, offset VerdanaFont, 12, 400, 0), 1
    invoke color_static, 0, 0DDDDFFh, 0ff0000h, 0, 32, 38, 17, hWnd, hInstance
    mov hSt3, eax
    invoke SendMessage, hSt3, WM_SETFONT, FUNC(RetFontHEx, offset VerdanaFont, 12, 400, 0), 1
.ELSEIF uMsg== WM_TIMER
    mov eax, wParam
    .if ax== 2303
        .if pri_f== 1
            call priv_auto
        .else
            .if up_down== 1
                call priv
            .endif
        .endif
        call koord
    .endif
.ELSEIF uMsg== WM_LBUTTONUP
    mov sad3, 0
    mov up_down, 0
    invoke ReleaseCapture
    invoke SendMessage, hSt1, WM_COMMAND, 0, 0DDFFDDh
    invoke SendMessage, hSt2, WM_COMMAND, 0, 0DDFFDDh
    invoke SendMessage, hSt3, WM_COMMAND, 0, 0DDDDFFh

.ELSEIF uMsg== WM_LBUTTONDOWN
    mov up_down, 1
    invoke SetCapture, hWnd
    invoke SendMessage, hSt1, WM_COMMAND, 0, 0DDDDFFh
    invoke SendMessage, hSt2, WM_COMMAND, 0, 0DDDDFFh
    invoke SendMessage, hSt3, WM_COMMAND, 0, 0DDFFDDh
    
.ELSEIF uMsg== WM_RBUTTONUP
    invoke ShowWindow, hWin, SW_RESTORE
.ELSE
    invoke DefWindowProc, hWnd, uMsg, wParam, lParam
    ret
.ENDIF
return 0
WndProcXY endp
;**********************************************************************************************************************************************************
priv_auto proc
LOCAL koor:POINT
    invoke GetCursorPos, addr koor
    mov ebx, koor.x
    mov ecx, koor.y
    .if ebx== DDX && ecx== DDY
        ret
    .endif
    mov DDX, ebx
    mov DDY, ecx
    mov eax, monx
    sub eax, 100
    cmp koor.x, eax
    jbe @F
        sub koor.x, 05ah
    @@:
    mov eax, mony
    sub eax, 100
    cmp koor.y, eax
    jbe @F
        sub koor.y, 05ah
    @@:
    add koor.x, 25
    add koor.y, 25
    invoke SetWindowPos, hWinXY, HWND_TOP, koor.x, koor.y, 0, 0, SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOSIZE
ret
priv_auto endp
;**********************************************************************************************************************************************************
priv proc
LOCAL koor:POINT, rec:RECT
    invoke GetCursorPos, addr koor
    cmp sad3, 0
    jne @F
        invoke GetWindowRect, hWinXY, addr rec
        mov ecx, rec.left
        mov ebx, koor.x
        sub ebx, ecx
        mov sad1, ebx
        mov ecx, rec.top
        mov ebx, koor.y
        sub ebx, ecx
        mov sad2, ebx
        mov sad3, 1
    @@:
    mov ebx, sad1
    sub koor.x, ebx
    mov ecx, sad2
    sub koor.y, ecx
    invoke SetWindowPos, hWinXY, HWND_TOP, koor.x, koor.y, 0, 0, SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOSIZE
ret
priv endp
;**********************************************************************************************************************************************************
koord proc
LOCAL poi:POINT
    invoke GetCursorPos, addr poi
    mov ecx, poi.x
    mov edx, poi.y
    .if qq1== ecx && qq2== edx
        ret
    .endif
    mov qq1, ecx
    mov qq2, edx
    mov eax, subb.x
    .if poi.x>= eax
        sub poi.x, eax
    .elseif eax> poi.x
        sub eax, poi.x
        mov poi.x, eax
    .endif
    inc poi.x
    mov eax, subb.y
    .if poi.y>= eax
        sub poi.y, eax
    .elseif eax> poi.y
        sub eax, poi.y
        mov poi.y, eax
    .endif
    inc poi.y
    cmp ed_f, 1
    jne @F
        finit
        fild poi.x
        fdiv monx_k
        fistp poi.x
        fild poi.y
        fdiv mony_k
        fistp poi.y
        fwait
    @@:
    invoke SetWindowText, hSt1, ustr$(poi.x)
    invoke SetWindowText, hSt2, ustr$(poi.y)
    cmp dist_f, 1
    jne @F
        finit
        fild poi.x
        fimul poi.x
        fild poi.y
        fimul poi.y
        fadd st(0), st(1)
        fsqrt
        fistp poi.y
        fwait
        invoke SetWindowText, hSt3, ustr$(poi.y)
    @@:
ret
koord endp
;**********************************************************************************************************************************************************
get_color proc
LOCAL buf_rgb:DWORD, poi_color:POINT
    invoke OpenClipboard, hWin
    invoke EmptyClipboard
    invoke GetCursorPos, addr poi_color
    invoke LocalAlloc, 040h, 1024
    mov buf_rgb, eax
    invoke GetPixel, hdc_des, poi_color.x, poi_color.y
    invoke dw2hex, eax, buf_rgb
    invoke SetClipboardData, CF_TEXT, buf_rgb
    invoke LocalFree, buf_rgb
    invoke CloseClipboard
ret
get_color endp
;**********************************************************************************************************************************************************
clip_cur proc
LOCAL poi:POINT, rct:RECT
.if clip_xy== 1
    cmp clip_xy_1, 1
    jne @F
        invoke GetCursorPos, addr poi
        mrm rct.left, poi.x
        mov rct.top, 0
        mrm rct.right, poi.x
        inc rct.right
        mrm rct.bottom, mony
        invoke ClipCursor, addr rct
        mov clip_xy_1, 0
        mov clip_xy_2, 1
        jmp clp1
    @@:
    call free_clip
    mov clip_xy_1, 1
.elseif clip_xy== 2
    cmp clip_xy_2, 1
    jne @F
        invoke GetCursorPos, addr poi
        mov rct.left, 0
        mrm rct.top, poi.y
        mrm rct.right, monx
        mrm rct.bottom, poi.y
        inc rct.bottom
        invoke ClipCursor, addr rct
        mov clip_xy_1, 1
        mov clip_xy_2, 0
        jmp clp1
    @@:
    call free_clip
    mov clip_xy_2, 1
.endif
clp1:
ret
clip_cur endp
;**********************************************************************************************************************************************************
free_clip proc
LOCAL rct:RECT
    mrm rct.right, monx
    mrm rct.bottom, mony
    mov rct.left, 0
    mov rct.top, 0
    invoke ClipCursor, addr rct
ret
free_clip endp
;**********************************************************************************************************************************************************
read_setting proc
LOCAL loc_m:DWORD
        invoke get_data, 0, addr ed_f
        invoke SendMessage, h(offset id_combobox), CB_SETCURSEL, ed_f, 0
        invoke get_data, 0, addr dist_f
        .if dist_f== 1
            invoke SetWindowPos, hWinXY, HWND_TOP, 0, 0, 38, 49, SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOMOVE
            invoke SendMessage, h(offset id_Distance), BM_SETCHECK, BST_CHECKED, 0
        .else
            invoke SetWindowPos, hWinXY, HWND_TOP, 0, 0, 38, 33, SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOMOVE
            invoke SendMessage, h(offset id_Distance), BM_SETCHECK, BST_UNCHECKED, 0
        .endif
        invoke get_data, 0, addr loc_m
        invoke SendMessage, h(offset id_hotkey_ReferPoint), HKM_SETHOTKEY, loc_m, 0
        invoke SendMessage, hWin, WM_COMMAND, xparam(EN_CHANGE, id_hotkey_ReferPoint), 0
        invoke get_data, 0, addr loc_m
        invoke SendMessage, h(offset id_hotkey_BlockX), HKM_SETHOTKEY, loc_m, 0
        invoke SendMessage, hWin, WM_COMMAND, xparam(EN_CHANGE, id_hotkey_BlockX), 0
        invoke get_data, 0, addr loc_m
        invoke SendMessage, h(offset id_hotkey_BlockY), HKM_SETHOTKEY, loc_m, 0
        invoke SendMessage, hWin, WM_COMMAND, xparam(EN_CHANGE, id_hotkey_BlockY), 0
        invoke get_data, 0, addr loc_m
        invoke SendMessage, h(offset id_hotkey_ColorClip), HKM_SETHOTKEY, loc_m, 0
        invoke SendMessage, hWin, WM_COMMAND, xparam(EN_CHANGE, id_hotkey_ColorClip), 0
        invoke get_data, 0, addr pri_f
        .if pri_f== 1
            invoke SendMessage, h(offset id_BindingCoord), BM_SETCHECK, BST_CHECKED, 0
        .else
            invoke SendMessage, h(offset id_BindingCoord), BM_SETCHECK, BST_UNCHECKED, 0
        .endif
        invoke get_data, 0, addr subb.x
        invoke get_data, 0, addr subb.y
        invoke get_data, 0, addr loc_m
        mov edx, loc_m
        invoke get_data, 0, addr loc_m
        invoke SetWindowPos, hWinXY, HWND_TOP, edx, loc_m, 0, 0, SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOSIZE
ret
read_setting endp
;**********************************************************************************************************************************************************
writ_setting proc
LOCAL rct:RECT, loc_m:DWORD
    invoke set_data, 0, addr fLng, 4
    invoke set_data, 0, addr ed_f, 4
    invoke set_data, 0, addr dist_f, 4
    invoke SendMessage, h(offset id_hotkey_ReferPoint), HKM_GETHOTKEY, 0, 0
    mov loc_m, eax
    invoke set_data, 0, addr loc_m, 4
    invoke SendMessage, h(offset id_hotkey_BlockX), HKM_GETHOTKEY, 0, 0
    mov loc_m, eax
    invoke set_data, 0, addr loc_m, 4
    invoke SendMessage, h(offset id_hotkey_BlockY), HKM_GETHOTKEY, 0, 0
    mov loc_m, eax
    invoke set_data, 0, addr loc_m, 4
    invoke SendMessage, h(offset id_hotkey_ColorClip), HKM_GETHOTKEY, 0, 0
    mov loc_m, eax
    invoke set_data, 0, addr loc_m, 4
    invoke set_data, 0, addr pri_f, 4
    invoke set_data, 0, addr subb.x, 4
    invoke set_data, 0, addr subb.y, 4
    invoke GetWindowRect, hWinXY, addr rct
    invoke set_data, 0, addr rct.left, 4
    invoke set_data, 0, addr rct.top, 4
    invoke write_ini
ret
writ_setting endp
;**********************************************************************************************************************************************************
paint_proc proc hDCd:DWORD, color_hotkey:DWORD, xxx:DWORD, yyy:DWORD, www:DWORD, hhh:DWORD
LOCAL lb:LOGBRUSH
LOCAL hBrush:DWORD, hBrushOld:DWORD
    mov lb.lbStyle, BS_SOLID
    mrm lb.lbColor, color_hotkey
    mov lb.lbHatch, 0
    invoke CreateBrushIndirect, addr lb
    mov hBrush, eax
    invoke SelectObject, hDCd, hBrush
    mov hBrushOld, eax
    mov eax, xxx
    add www, eax
    mov eax, yyy
    add hhh, eax
    invoke Rectangle, hDCd, xxx, yyy, www, hhh
    invoke SelectObject, hDCd, hBrushOld
    invoke DeleteObject, hBrush
ret
paint_proc endp
;**********************************************************************************************************************************************************
about proc
    invoke lstrcpy, addr temp_str, ucc$("xPix v2.5 © 2017 7ya\nContact: 7ya@protonmail.com\nhttps://github.com/7ya/win_asm_xpix\n\n")
    invoke lstrcat, addr temp_str, s_Translation
    invoke about_box, hInstance, hWin, addr temp_str, s_ScreenRuler, MB_OK, 900
ret
about endp
;**********************************************************************************************************************************************************
end start

