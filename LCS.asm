.data                   
    prompt1 db 'Enter first string: $'     ; 提示用戶輸入第一個字串
    prompt2 db 0dh, 0ah, 'Enter second string: $'  ; 提示用戶輸入第二個字串
    result db 0dh, 0ah, 'LCS length: $'  ; 顯示最長公共子序列 (LCS) 的長度
    array1 db 100 dup(0)   ; 儲存第一個字串的陣列
    array2 db 100 dup(0)   ; 儲存第二個字串的陣列
    count_first_word_long dw 0   ; 儲存第一個字串的長度
    count_second_word_long dw 0  ; 儲存第二個字串的長度
    matrix db 400 dup(0)   ; 儲存LCS的矩陣
    count_now_row dw 1     ; 當前的行索引
    count_now_col dw 1     ; 當前的列索引
    result_array db 100 dup(0) ;儲存結果  
    result_array_length db 0 ;儲存結果
.code    

main proc               
    mov ax, @data      ; 設置段寄存器 DS，指向資料段
    mov ds, ax 
    
    call initial_input        ; 輸入兩個字串
    call calculate_lcs        ; 計算最長公共子序列 (LCS)
    call display_result       ; 顯示結果
    call display_result_string
    
    mov ah, 4ch        ; 結束程式
    int 21h            ; 呼叫 DOS 中斷 21h 來結束程序
    
main endp

initial_input proc       
    ; 顯示第一行提示，請用戶輸入第一個字串
    mov ah, 09h        
    lea dx, prompt1    
    int 21h           
    
    ; 輸入第一個字串
    lea si, array1     ; 將 SI 指向 array1
    inc si             ; 跳過 array1 的第一個元素（可能是空白）
    mov cx, 0          ; 初始化字串長度為 0
    
input_first_word:           
    mov ah, 01h        ; 等待用戶輸入一個字元
    int 21h            ; 呼叫 DOS 中斷，讀取鍵盤輸入
    
    cmp al, 0dh        ; 如果輸入的是 Enter (0x0D)，結束輸入
    je input_first_word_store   
    
    mov [si], al       ; 把輸入的字符存入 array1
    inc si             ; 指向 array1 的下一個位置
    inc cx             ; 增加字串長度
    jmp input_first_word    ; 重新執行輸入

input_first_word_store:          
    mov count_first_word_long, cx    ; 儲存第一個字串的長度
    
    ; 顯示第二行提示，請用戶輸入第二個字串
    mov ah, 09h       
    lea dx, prompt2   
    int 21h          
    
    ; 輸入第二個字串
    lea si, array2    ; 將 SI 指向 array2
    inc si            ; 跳過 array2 的第一個元素（可能是空白）
    mov cx, 0         ; 初始化字串長度為 0
     
input_second_word:          
    mov ah, 01h       ; 等待用戶輸入一個字元
    int 21h           ; 呼叫 DOS 中斷，讀取鍵盤輸入
    
    cmp al, 0dh       ; 如果輸入的是 Enter (0x0D)，結束輸入
    je input_second_word_store   
    
    mov [si], al      ; 把輸入的字符存入 array2
    inc si            ; 指向 array2 的下一個位置
    inc cx            ; 增加字串長度
    jmp input_second_word   ; 重新執行輸入

input_second_word_store:         
    mov count_second_word_long, cx   ; 儲存第二個字串的長度
    ret
initial_input endp  

                
calculate_lcs proc
compare_word:  
    ; 比較當前字符
    mov bx, count_now_col         
    lea si, array1                ; 指向第一個字串
    add si, bx                     ; 根據列索引偏移到對應位置
    mov ah, [si]                   ; 取出當前字元
    
    mov bx, count_now_row          
    lea si, array2                 ; 指向第二個字串
    add si, bx                     ; 根據行索引偏移到對應位置
    mov al, [si]                   ; 取出當前字元
    
    cmp ah, al                     ; 比較兩個字元是否相同
    je if_they_same                ; 如果相同，執行 if_they_same 分支

if_they_not_same:
    ; 找出上方和左方的最大值
    lea si, matrix                
    mov ax, count_now_row         ; 計算上方位置的矩陣索引
    dec ax                        
    mov bx, 20                    ; 計算矩陣的行偏移量
    mul bx                        
    mov bx, count_now_col
    add ax, bx                    
    add si, ax
    mov cl, [si]                  ; 讀取上方的值

    lea si, matrix                
    mov ax, count_now_row         
    mov bx, 20                    
    mul bx                        
    mov bx, count_now_col
    dec bx                        
    add ax, bx                    
    add si, ax
    mov ch, [si]                  ; 讀取左方的值
     
    lea si, matrix                
    mov ax, count_now_row         
    mov bx, 20                    
    mul bx                        
    mov bx, count_now_col
    add ax, bx
    add si, ax
    cmp ch, cl                    ; 比較左方和上方的值
    jle store_cl                  ; 如果左方小於等於上方，則儲存左方的值
    mov [si], ch                  ; 否則儲存上方的值
    jmp check_position
    
store_cl:
    mov [si], cl                  ; 儲存左方的值
    jmp check_position

if_they_same:
    ; 取得左上角值+1
    lea si, matrix
    mov ax, count_now_row         ; 計算左上角位置的矩陣索引
    dec ax
    mov bx, 20                    ; 計算矩陣的行偏移量
    mul bx
    mov bx, count_now_col
    dec bx
    add ax, bx
    add si, ax
    mov cl, [si]
    inc cl                        ; 左上角的值加 1
    
    lea si, matrix
    mov ax, count_now_row         ; 計算當前位置的矩陣索引
    mov bx, 20
    mul bx
    mov bx, count_now_col
    add ax, bx
    add si, ax
    mov [si], cl                  ; 儲存結果

check_position:
    ; 判斷是否完成一行
    mov ax, count_now_col
    cmp ax, count_first_word_long
    je next_row                   ; 如果列索引達到第一個字串長度，換行
    
    inc count_now_col             ; 否則繼續處理下一列
    jmp compare_word

next_row:
    ; 判斷是否完成所有行
    mov ax, count_now_row
    cmp ax, count_second_word_long
    je done_calculate             ; 如果行索引達到第二個字串長度，計算完成
    
    mov count_now_col, 1          ; 換行後重置列索引
    inc count_now_row             ; 行索引加 1
    jmp compare_word

done_calculate:
    ret 
    
calculate_lcs endp

display_result proc
    ; 顯示結果提示
    mov ah, 09h
    lea dx, result
    int 21h
    
    ; 獲取最終結果
    lea si, matrix
    mov ax, count_second_word_long
    mov bx, 20
    mul bx
    mov bx, count_first_word_long
    add ax, bx
    add si, ax
    mov al, [si]                  ; 讀取 LCS 的長度
    
    ; 轉換為 ASCII 並顯示
    mov ah, 0
    mov bl, 10
    div bl          ; AX / BL = AL(商)...AH(餘數)
    mov bx, ax      ; 保存結果
    
    mov dl, bl      ; 顯示十位數
    add dl, '0'
    mov ah, 02h
    int 21h

    mov dl, bh      ; 顯示個位數
    add dl, '0'
    mov ah, 02h
    int 21h

    mov dl, 0dh     ; 換行
    int 21h
    mov dl, 0ah
    int 21h
    
    ret
display_result endp
 

display_result_string proc 
    mov dx , 0 
compare_result_word:  
    ; 比較當前字符
    mov bx, count_now_col         
    lea si, array1                ; 指向第一個字串
    add si, bx                     ; 根據列索引偏移到對應位置
    mov ah, [si]                   ; 取出當前字元
    
    mov bx, count_now_row          
    lea si, array2                 ; 指向第二個字串
    add si, bx                     ; 根據行索引偏移到對應位置
    mov al, [si]                   ; 取出當前字元
    
    cmp ah, al                     ; 比較兩個字元是否相同
    je if_same                ; 如果相同，執行 if_they_same 分支
if_not_same:
    lea si, matrix                
    mov ax, count_now_row         ; 計算上方位置的矩陣索引
    dec ax                        
    mov bx, 20                    ; 計算矩陣的行偏移量
    mul bx                        
    mov bx, count_now_col
    add ax, bx                    
    add si, ax
    mov cl, [si]                  ; 讀取上方的值
    
    lea si, matrix                
    mov ax, count_now_row         
    mov bx, 20                    
    mul bx                        
    mov bx, count_now_col
    dec bx                        
    add ax, bx                    
    add si, ax
    mov ch, [si]                  ; 讀取左方的值 
    
    cmp ch,cl 
    jl cl_win                  ; 如果左方小於等於上方，則儲存左方的值
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


