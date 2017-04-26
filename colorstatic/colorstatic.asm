; Author:            7ya
; Update date:       26.04.2017
; Contact:           7ya@protonmail.com
; Internet address:  https://github.com/7ya/win_asm_xpix
; License:           GPL-3.0
;**********************************************************************************************************************************************************
__UNICODE__ equ 1
include \masm32\include\masm32rt.inc

color_static proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

.data
    UC clName, "col_static_class",0
    Count dd 0

.code
color_static proc scText:DWORD, col:DWORD, coltxt:DWORD, xxx:DWORD, yyy:DWORD, www:DWORD, hhh:DWORD, hParent:DWORD, hinst:DWORD
LOCAL hBrush:DWORD, hwnd:DWORD
LOCAL wc:WNDCLASSEX, SCClass[64]:TCHAR
    inc Count
    invoke lstrcpy, addr SCClass, addr clName
    invoke lstrcat, addr SCClass, ustr$(Count)

    mov wc.cbSize, sizeof WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mrm wc.lpfnWndProc, offset CSProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 32
    mrm wc.hInstance, hinst
    invoke CreateSolidBrush, col
    mov hBrush, eax
    mov wc.hbrBackground, eax
    mov wc.lpszMenuName, 0
    lea eax, SCClass
    mov wc.lpszClassName, eax
    mov wc.hIcon, 0
    invoke LoadCursor, 0, IDC_ARROW
    mov wc.hCursor, eax
    mov wc.hIconSm, 0
    invoke RegisterClassEx, addr wc
    invoke CreateWindowEx, 0, addr SCClass, scText, WS_VISIBLE or WS_CHILD or WS_DISABLED, xxx, yyy, www, hhh, hParent, 0, hinst,0
    mov hwnd, eax
    invoke SetWindowLong, hwnd, 4, 0
    invoke SetWindowLong, hwnd, 8, coltxt
    invoke ShowWindow, hwnd, SW_SHOW
return hwnd
color_static endp
;**********************************************************************************************************************************************************
CSProc proc hWnd:DWORD, uMsg:DWORD, wParam :DWORD, lParam :DWORD
LOCAL hDC:DWORD, scStyle:DWORD, hBrush:DWORD, hOld:DWORD
LOCAL rec:RECT, ps:PAINTSTRUCT
LOCAL buffer[512]:TCHAR
    .if uMsg== WM_SETFONT
        invoke SetWindowLong, hWnd, 4, wParam
        invoke GetClientRect, hWnd, addr rec
        invoke InvalidateRect, hWnd, addr rec, 1

    .elseif uMsg== WM_SETTEXT
        invoke GetClientRect, hWnd, addr rec
        invoke InvalidateRect, hWnd, addr rec, 1

    .elseif uMsg== WM_COMMAND
        .if wParam== 0
            invoke CreateSolidBrush, lParam
            mov hBrush, eax
            invoke SetWindowLong, hWnd, 0, hBrush
            invoke SetClassLong, hWnd, GCL_HBRBACKGROUND, hBrush
        .elseif wParam== 1
            invoke SetWindowLong, hWnd, 8, lParam
        .endif
        invoke GetClientRect, hWnd, addr rec
        invoke InvalidateRect, hWnd, addr rec, 1

    .elseif uMsg== WM_PAINT
        invoke BeginPaint, hWnd, addr ps
        mov hDC, eax
            invoke GetClientRect, hWnd, addr rec
            invoke GetWindowText, hWnd, addr buffer, 512
            invoke SetBkMode, hDC, TRANSPARENT
            mov scStyle, DT_VCENTER or DT_CENTER or DT_SINGLELINE
            invoke SetBkMode, hDC, TRANSPARENT
            invoke GetWindowLong, hWnd, 4
            .if eax!= 0
                invoke SelectObject, hDC, eax
                mov hOld, eax
            .endif
            invoke GetWindowLong, hWnd, 8
            invoke SetTextColor, hDC, eax
            invoke DrawText, hDC, addr buffer, -1, addr rec, scStyle
            invoke GetWindowLong, hWnd, 4
            .if eax!= 0
                invoke SelectObject, hDC, hOld
            .endif
        invoke EndPaint, hWnd, addr ps
    .endif
    invoke DefWindowProc, hWnd, uMsg, wParam, lParam
ret
CSProc endp
;**********************************************************************************************************************************************************
end

