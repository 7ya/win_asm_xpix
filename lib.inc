;**********************************************************************************************************************************************************
;���������������
;-----lang.lib
read_lng       proto :DWORD, :DWORD
get_str        proto :DWORD, :DWORD, :DWORD, :DWORD
list_lng       proto :DWORD, :DWORD
CreateLngMenu  proto :DWORD, :DWORD
free_lng       proto
;**********************************************************************************************************************************************************
;��������� ��������
;-----setti.lib
set_data       proto :DWORD, :DWORD, :DWORD
ini_ini        proto :DWORD, :DWORD
get_data       proto :DWORD, :DWORD
write_ini      proto
;**********************************************************************************************************************************************************
;�������������� �������
;-----ex_api.lib
crtwindow      proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
about_box      proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
reghotkey      proto :DWORD, :DWORD, :DWORD, :DWORD
RetFontHEx     proto :DWORD, :DWORD, :DWORD, :DWORD
tab_focus      proto :DWORD, :DWORD
window_center  proto :DWORD

h MACRO ident
    mov edx, ident
    mov ecx, dword ptr[edx+4]
    EXITM <ecx>
ENDM

;-----colorstatic.lib
color_static   proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
;**********************************************************************************************************************************************************
