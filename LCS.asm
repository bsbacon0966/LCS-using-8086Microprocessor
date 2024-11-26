.data                   
    prompt1 db 'Enter first string: $'     ; ���ܥΤ��J�Ĥ@�Ӧr��
    prompt2 db 0dh, 0ah, 'Enter second string: $'  ; ���ܥΤ��J�ĤG�Ӧr��
    result db 0dh, 0ah, 'LCS length: $'  ; ��̪ܳ����@�l�ǦC (LCS) ������
    array1 db 100 dup(0)   ; �x�s�Ĥ@�Ӧr�ꪺ�}�C
    array2 db 100 dup(0)   ; �x�s�ĤG�Ӧr�ꪺ�}�C
    count_first_word_long dw 0   ; �x�s�Ĥ@�Ӧr�ꪺ����
    count_second_word_long dw 0  ; �x�s�ĤG�Ӧr�ꪺ����
    matrix db 400 dup(0)   ; �x�sLCS���x�}
    count_now_row dw 1     ; ��e�������
    count_now_col dw 1     ; ��e���C����
    result_array db 100 dup(0) ;�x�s���G  
    result_array_length db 0 ;�x�s���G
.code    

main proc               
    mov ax, @data      ; �]�m�q�H�s�� DS�A���V��Ƭq
    mov ds, ax 
    
    call initial_input        ; ��J��Ӧr��
    call calculate_lcs        ; �p��̪����@�l�ǦC (LCS)
    call display_result       ; ��ܵ��G
    call display_result_string
    
    mov ah, 4ch        ; �����{��
    int 21h            ; �I�s DOS ���_ 21h �ӵ����{��
    
main endp

initial_input proc       
    ; ��ܲĤ@�洣�ܡA�ХΤ��J�Ĥ@�Ӧr��
    mov ah, 09h        
    lea dx, prompt1    
    int 21h           
    
    ; ��J�Ĥ@�Ӧr��
    lea si, array1     ; �N SI ���V array1
    inc si             ; ���L array1 ���Ĥ@�Ӥ����]�i��O�ťա^
    mov cx, 0          ; ��l�Ʀr����׬� 0
    
input_first_word:           
    mov ah, 01h        ; ���ݥΤ��J�@�Ӧr��
    int 21h            ; �I�s DOS ���_�AŪ����L��J
    
    cmp al, 0dh        ; �p�G��J���O Enter (0x0D)�A������J
    je input_first_word_store   
    
    mov [si], al       ; ���J���r�Ŧs�J array1
    inc si             ; ���V array1 ���U�@�Ӧ�m
    inc cx             ; �W�[�r�����
    jmp input_first_word    ; ���s�����J

input_first_word_store:          
    mov count_first_word_long, cx    ; �x�s�Ĥ@�Ӧr�ꪺ����
    
    ; ��ܲĤG�洣�ܡA�ХΤ��J�ĤG�Ӧr��
    mov ah, 09h       
    lea dx, prompt2   
    int 21h          
    
    ; ��J�ĤG�Ӧr��
    lea si, array2    ; �N SI ���V array2
    inc si            ; ���L array2 ���Ĥ@�Ӥ����]�i��O�ťա^
    mov cx, 0         ; ��l�Ʀr����׬� 0
     
input_second_word:          
    mov ah, 01h       ; ���ݥΤ��J�@�Ӧr��
    int 21h           ; �I�s DOS ���_�AŪ����L��J
    
    cmp al, 0dh       ; �p�G��J���O Enter (0x0D)�A������J
    je input_second_word_store   
    
    mov [si], al      ; ���J���r�Ŧs�J array2
    inc si            ; ���V array2 ���U�@�Ӧ�m
    inc cx            ; �W�[�r�����
    jmp input_second_word   ; ���s�����J

input_second_word_store:         
    mov count_second_word_long, cx   ; �x�s�ĤG�Ӧr�ꪺ����
    ret
initial_input endp  

                
calculate_lcs proc
compare_word:  
    ; �����e�r��
    mov bx, count_now_col         
    lea si, array1                ; ���V�Ĥ@�Ӧr��
    add si, bx                     ; �ھڦC���ް����������m
    mov ah, [si]                   ; ���X��e�r��
    
    mov bx, count_now_row          
    lea si, array2                 ; ���V�ĤG�Ӧr��
    add si, bx                     ; �ھڦ���ް����������m
    mov al, [si]                   ; ���X��e�r��
    
    cmp ah, al                     ; �����Ӧr���O�_�ۦP
    je if_they_same                ; �p�G�ۦP�A���� if_they_same ����

if_they_not_same:
    ; ��X�W��M���誺�̤j��
    lea si, matrix                
    mov ax, count_now_row         ; �p��W���m���x�}����
    dec ax                        
    mov bx, 20                    ; �p��x�}���氾���q
    mul bx                        
    mov bx, count_now_col
    add ax, bx                    
    add si, ax
    mov cl, [si]                  ; Ū���W�誺��

    lea si, matrix                
    mov ax, count_now_row         
    mov bx, 20                    
    mul bx                        
    mov bx, count_now_col
    dec bx                        
    add ax, bx                    
    add si, ax
    mov ch, [si]                  ; Ū�����誺��
     
    lea si, matrix                
    mov ax, count_now_row         
    mov bx, 20                    
    mul bx                        
    mov bx, count_now_col
    add ax, bx
    add si, ax
    cmp ch, cl                    ; �������M�W�誺��
    jle store_cl                  ; �p�G����p�󵥩�W��A�h�x�s���誺��
    mov [si], ch                  ; �_�h�x�s�W�誺��
    jmp check_position
    
store_cl:
    mov [si], cl                  ; �x�s���誺��
    jmp check_position

if_they_same:
    ; ���o���W����+1
    lea si, matrix
    mov ax, count_now_row         ; �p�⥪�W����m���x�}����
    dec ax
    mov bx, 20                    ; �p��x�}���氾���q
    mul bx
    mov bx, count_now_col
    dec bx
    add ax, bx
    add si, ax
    mov cl, [si]
    inc cl                        ; ���W�����ȥ[ 1
    
    lea si, matrix
    mov ax, count_now_row         ; �p���e��m���x�}����
    mov bx, 20
    mul bx
    mov bx, count_now_col
    add ax, bx
    add si, ax
    mov [si], cl                  ; �x�s���G

check_position:
    ; �P�_�O�_�����@��
    mov ax, count_now_col
    cmp ax, count_first_word_long
    je next_row                   ; �p�G�C���޹F��Ĥ@�Ӧr����סA����
    
    inc count_now_col             ; �_�h�~��B�z�U�@�C
    jmp compare_word

next_row:
    ; �P�_�O�_�����Ҧ���
    mov ax, count_now_row
    cmp ax, count_second_word_long
    je done_calculate             ; �p�G����޹F��ĤG�Ӧr����סA�p�⧹��
    
    mov count_now_col, 1          ; ����᭫�m�C����
    inc count_now_row             ; ����ޥ[ 1
    jmp compare_word

done_calculate:
    ret 
    
calculate_lcs endp

display_result proc
    ; ��ܵ��G����
    mov ah, 09h
    lea dx, result
    int 21h
    
    ; ����̲׵��G
    lea si, matrix
    mov ax, count_second_word_long
    mov bx, 20
    mul bx
    mov bx, count_first_word_long
    add ax, bx
    add si, ax
    mov al, [si]                  ; Ū�� LCS ������
    
    ; �ഫ�� ASCII �����
    mov ah, 0
    mov bl, 10
    div bl          ; AX / BL = AL(��)...AH(�l��)
    mov bx, ax      ; �O�s���G
    
    mov dl, bl      ; ��ܤQ���
    add dl, '0'
    mov ah, 02h
    int 21h

    mov dl, bh      ; ��ܭӦ��
    add dl, '0'
    mov ah, 02h
    int 21h

    mov dl, 0dh     ; ����
    int 21h
    mov dl, 0ah
    int 21h
    
    ret
display_result endp
 

display_result_string proc 
    mov dx , 0 
compare_result_word:  
    ; �����e�r��
    mov bx, count_now_col         
    lea si, array1                ; ���V�Ĥ@�Ӧr��
    add si, bx                     ; �ھڦC���ް����������m
    mov ah, [si]                   ; ���X��e�r��
    
    mov bx, count_now_row          
    lea si, array2                 ; ���V�ĤG�Ӧr��
    add si, bx                     ; �ھڦ���ް����������m
    mov al, [si]                   ; ���X��e�r��
    
    cmp ah, al                     ; �����Ӧr���O�_�ۦP
    je if_same                ; �p�G�ۦP�A���� if_they_same ����
if_not_same:
    lea si, matrix                
    mov ax, count_now_row         ; �p��W���m���x�}����
    dec ax                        
    mov bx, 20                    ; �p��x�}���氾���q
    mul bx                        
    mov bx, count_now_col
    add ax, bx                    
    add si, ax
    mov cl, [si]                  ; Ū���W�誺��
    
    lea si, matrix                
    mov ax, count_now_row         
    mov bx, 20                    
    mul bx                        
    mov bx, count_now_col
    dec bx                        
    add ax, bx                    
    add si, ax
    mov ch, [si]                  ; Ū�����誺�� 
    
    cmp ch,cl 
    jl cl_win                  ; �p�G����p�󵥩�W��A�h�x�s���誺��
    mov bx, count_now_col
    dec bx 
    mov count_now_col,bx
    jmp check_if_is_end
    
cl_win:
    mov bx, count_now_row
    dec bx 
    mov count_now_row,bx
    jmp check_if_is_end
    
if_same:       
    lea si,result_array 
    mov dl, result_array_length
    add si,dx
    mov [si],al    
    inc dl
    mov result_array_length,dl   
    
    mov bx, count_now_col
    dec bx
    mov count_now_col , bx
    mov bx, count_now_row
    dec count_now_row
    mov count_now_row , bx  
    
    jmp check_if_is_end
check_if_is_end:
    cmp bx,0
    je ending_show
    cmp ax,0
    je ending_show
    jmp compare_result_word
ending_show:
    ; Initialize SI to point to the start of result_array
    lea si, result_array
    mov cl , result_array_length 
    ; Loop through result_array until null terminator is found
print_result_loop: 
    mov bx , si
    add bx,cx
    mov al, [bx]           ; Load current byte (character) into AL
    cmp cx,0              ; Check if it's the null terminator (end of string)
    jl print_result_done   ; If null terminator, end the loop

    ; Print the current character
    mov dl, al             ; Move the character into DL for output
    mov ah, 02h            ; DOS function 0x02 (Display output)
    int 21h                ; Call interrupt to display character
    dec cx
    jmp print_result_loop  ; Continue looping
print_result_done:
    ; Optionally, print a newline for better output formatting
    mov dl, 0dh            ; Carriage return
    mov ah, 02h            ; DOS function 0x02
    int 21h                ; Print carriage return
    mov dl, 0ah            ; Linefeed
    int 21h                ; Print linefeed

    ret
    
display_result_string endp
end main


