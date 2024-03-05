
[org 0x100]

jmp start

;***********************varaibles***********************

length: dw 0                    
snake: times 300 db 0
location: times 300 dw 0
fruitlocation: dw 562
oldtimer: dd 0
oldisr: dd 0
scoreVar: dw 0
dir: dw 0 
message1: db 'SNAKE GAME'  
message2: db 'YOU LOST'
message3: db 'RESTARTING GAME'
message4: db 'WELCOME TO SNAKE GAME'
message5: db 'Score:'

;**********************************************************
;**********************clrscr******************************

clrscr: 
push es
push ax
push cx
push di
mov ax, 0xb800
mov es, ax 
mov di,0
mov al, 0x20      ;space
mov ah, 0x00      ;black foregroud and back ground
mov cx, 2000
cld 
rep stosw 
pop di
pop cx
pop ax
pop es
ret

;**********************************************************
;**********************reset*******************************

reset:
pusha
mov word[scoreVar],0
call clrscr
call printBorders
call initializeSnake
call printSnake
call printFruit
call score
call display
popa
ret

;**********************************************************
;**********************box*********************************

box:
call clrscr
pusha
mov ax,0xb800
mov es,ax
mov ah,0x66       ;black foregroud and background
mov al,'_'        ;_

mov di,0                 ;_________________________________________
mov cx,80
topBorder:
mov word[es:di],ax
add di,2
loop topBorder

mov di,158                                                       ;_
mov cx,24                                                        ;_
rightBorder:                                                     ;_
mov word[es:di],ax                                               ;_ 
add di,160                                                       ;_ 
loop rightBorder                                                 ;_

mov di,3680
mov cx,80
bottomBorder:
mov word[es:di],ax
add di,2
loop bottomBorder         ;_________________________________________

mov di,0                 ;_
mov cx,24                ;_
leftBorder:              ;_
mov word[es:di],ax       ;_ 
add di,160               ;_
loop leftBorder          ;_

popa
ret

;**************************************************************
;*********************Scores***********************************

score:
pusha

mov ax, 0xb800 
mov es, ax 
mov di,164               ;Row 1 Coloumn 1
mov si, message5
mov cx, 6
mov ah, 0x06
cld 
next: 
lodsb 
stosw 
loop next
popa
ret

;**************************************************************
;***********************ScoreDisplay***************************

display:
pusha 
mov ax, 0xb800 
mov es, ax 
mov word ax, [scoreVar] 
mov bx, 10 
mov cx, 0 
nextdigit:
mov dx, 0 
div bx 
add dl, 0x30 
push dx 
inc cx 
cmp ax, 0 
jnz nextdigit 
mov di, 180 
nextpos: pop dx 
mov dh, 0x07 
mov [es:di], dx 
add di, 2 
loop nextpos 
popa
ret
 
;**************************************************************
;*********************printBorders*****************************

printBorders:
pusha
call box

mov ax,0xb800
mov es,ax
mov ah,0x66
mov al,'_'
mov di,480         ;Printing an Orange line n 3rd row 0 coloumn
mov cx,80
upperBorder:
mov word[es:di],ax
add di,2
loop upperBorder
popa
ret

;***************************************************************
;***********************initializeSnake*************************

initializeSnake:
pusha
mov word[cs:length], 10       ;5=Born Length0
mov cx,9
mov byte[cs:snake+9],'+'        ;snake+4 index = head
mov bx,0
initializeLoop:
mov byte[cs:snake+bx],'*'       ;snake 0-3 = body
inc bx
loop initializeLoop
popa
ret

;***************************************************************
;************************printSnake*****************************

printSnake:
pusha
mov ax,0xb800
mov es,ax
mov di,1980                    ;12th row, 30th coloumn        
mov word cx,[cs:length]        ;cx=length
mov bx,0
mov si,0
mov ah,0x06                    ;black background and orange foregroud
printingLoop:
mov al,[cs:snake+bx]
mov word[es:di],ax
mov word[cs:location+si],di     ;stores location of every block
add bx,1
add di,2
add si,2
loop printingLoop
popa
ret

;********************************************************************************************************************************************************************************
;**********************************************************************
;**********************moveRight***************************************


moveRight:
pusha
mov ax,0xb800
mov es,ax

cmp word[dir] , 2 ; 1 for right
je endOfRight1

mov word si,[cs:length]
shl si,1                          ;length*2
sub si,2                          ;length-2

checkRightHit:
mov ah,0x66
mov al,'_'
mov di,[cs:location+si]           ;head
cmp ax,[es:di+2]                  ;check if head == rightBorder
jne rightItselfHit
call reset
jmp endOfRight

rightItselfHit:
mov ah,0x06
mov al,'*'
mov di,[cs:location+si]           ;head
cmp ax,[es:di+2]                  ;cheack if head == snake body
jne fruitPickedR
call reset
jmp endOfRight

fruitPickedR:
mov ah,0x66
mov al,'A'
mov di,[cs:location+si]           ;head
cmp ax,[es:di+2]                  ;check if head == fruit
jne continueRight
add word[scoreVar],1
call extendR
call printFruit1

jmp continueRight
endOfRight1:
jmp endOfRight
continueRight:
mov word cx,[cs:length]
dec cx                                 
mov bx,cx
mov word si,[cs:length]
shl si,1                               ;length*2
sub si,2                               ;length-2
mov ah,0x06                            ;attributes
mov di,[cs:location+si]                ;head
mov al,[cs:snake+bx]                   ;head attributes
mov word[es:di+2],ax                   ;print on next location
add word[cs:location+si],2

rightLoop:
mov bx,[cs:location+si-2]              ;continue to print the body on next location(right) +2 di
mov ax,[es:bx]
mov word[es:di],ax
mov [cs:location+si-2],di
mov di,bx
sub si,2
loop rightLoop

mov dl,0x20                            ;print space on the last location
mov dh,0x00
mov word[es:di],dx

endOfRight:
popa
ret
;*******************
extendR:
pusha
call clrscr
call printBorders
call score
call display
add word[cs:length],1
mov word bx,[cs:length]
sub bx,1
mov byte[cs:snake+bx],'+'
mov cx,bx
mov bx,0

exLoopR:
mov byte[cs:snake+bx],'*'
add bx,1
loop exLoopR
PrLoopR:
mov ax,0xb800
mov es,ax
mov ax, 0
mov word di,[cs:location+si]
sub di,10
mov word cx,[cs:length]
mov bx,0
mov si,0
mov ah,0x06
LR:                        ;loop right 
mov al, [cs:snake+bx]
mov word[es:di],ax
mov word[cs:location+si],di
add bx,1
add di,2
add si,2
loop LR
popa 
ret

;*************************************************************************************************
;*******************************moveLeft**********************************************************

moveLeft:
pusha
mov ax,0xb800
mov es,ax
mov word si,[cs:length]
shl si,1                            ;length*2
sub si,2                            ;length-2

checkLeftHit:
mov ah,0x66
mov al,'_'
mov di,[cs:location+si]             ;head
cmp ax,[es:di-2]                    ;check if head == leftBorder (di-2)
jne leftItselfHit
call reset
jmp endOfLeft


leftItselfHit:
mov ah,0x06
mov al,'*'
mov di,[cs:location+si]             ;head
cmp ax,[es:di-2]                    ;check if head == snake body
jne fruitPicketL
call reset
jmp endOfLeft

fruitPicketL:
mov ah,0x66
mov al,'A'
mov di,[cs:location+si]              ;head
cmp ax,[es:di-2]                     ;check if head == fruit
jne continueLeft
add word[scoreVar],1
call extendL
call printFruit3


continueLeft:
mov word cx,[cs:length]
dec cx                                 
mov bx,cx
mov word si,[cs:length]
shl si,1                               ;length*2
sub si,2                               ;length-2
mov ah,0x06                            ;attributes
mov di,[cs:location+si]                ;head
mov al,[cs:snake+bx]                   ;head attributes
mov word[es:di-2],ax                   ;print on next location(left)
sub word[cs:location+si],2

leftLoop:
mov bx,[cs:location+si-2]              ;continue to print the body on next location(left) -2 di
mov ax,[es:bx]
mov word[es:di],ax
mov [cs:location+si-2],di
mov di,bx
sub si,2
loop leftLoop
mov dl,0x20                            ;print space on the last location
mov dh,0x00
mov word[es:di],dx

endOfLeft:
popa
ret

extendL:
pusha
call clrscr
call printBorders
call score
call display
sub si,2
add word[cs:length],1
mov word bx,[cs:length]
sub bx,1
mov byte[cs:snake+bx],'+'
mov cx,bx
mov bx,0
exLoopL:
mov byte[cs:snake+bx],'*'
add bx,1
loop exLoopL
PrLoopL:
mov ax,0xb800
mov es,ax
mov ax, 0
mov word di,[cs:location+si]
add di,10
mov word cx,[cs:length]
mov bx,0
mov si,0
mov ah,0x06
LL:                        ;loop left 
mov al, [cs:snake+bx]
mov word[es:di],ax
mov word[cs:location+si],di
add bx,1
sub di,2
add si,2
loop LL
popa 
ret
;****************
;****************************************************************************
;************************moveDown********************************************

moveDown:
pusha
mov ax,0xb800
mov es,ax
mov word si,[cs:length]
shl si,1                               ;length*2
sub si,2                               ;length-2

checkDownHit:
mov ah,0x66
mov al,'_'
mov di,[cs:location+si]                ;head
cmp ax,[es:di+160]                     ;check if head == bottomBorder, +160
jne downItselfHit
call reset
jmp endOfDown


downItselfHit:
mov ah,0x06
mov al,'*'
mov di,[cs:location+si]                ;head
cmp ax,[es:di+160]                     ;check if head == body
jne fruitPickedD
call reset
jmp endOfDown

fruitPickedD:
mov ah,0x66
mov al,'A'
mov di,[cs:location+si]                ;head
cmp ax,[es:di+160]                     ;check if head == fruit
jne continueDown
add word[scoreVar],1
call extendD
call printFruit2



continueDown:
mov word cx,[cs:length]
dec cx                                 
mov bx,cx
mov word si,[cs:length]
shl si,1                               ;length*2
sub si,2                               ;length-2
mov ah,0x06                            ;attributes
mov di,[cs:location+si]                ;head
mov al,[cs:snake+bx]                   ;head attributes
mov word[es:di+160],ax                 ;print on next location(down)
add word[cs:location+si],160


downLoop:
mov bx,[cs:location+si-2]              ;continue to print the body on next location(dlwn) +160 di
mov ax,[es:bx]
mov word[es:di],ax
mov [cs:location+si-2],di
mov di,bx
sub si,2
loop downLoop

mov dl,0x20                             ;print space on the last location
mov dh,0x00
mov word[es:di],dx

endOfDown:
popa
ret


extendD:
pusha
call clrscr
call printBorders
call score
call display
sub si,2
add word[cs:length],1
mov word bx,[cs:length]
sub bx,1
mov byte[cs:snake+bx],'+'
mov cx,bx
mov bx,0
exLoopD:
mov byte[cs:snake+bx],'*'
add bx,1
loop exLoopD
PrLoopD:
sub si,2
mov ax,0xb800
mov es,ax
mov ax, 0
mov word di,[cs:location+si]
sub di,160
mov word cx,[cs:length]
mov bx,0
mov si,0
mov ah,0x06
LD:                        ;loop Down 
mov al, [cs:snake+bx]
mov word[es:di],ax
mov word[cs:location+si],di
add bx,1
add di,160
add si,2
loop LD
popa 
ret

;*****************************************************************************************
;***************************moveUp********************************************************

moveUp:

pusha
mov ax,0xb800
mov es,ax

mov word si,[cs:length]  
shl si,1                              ;length*2
sub si,2                              ;length-2

checkUpHit:
mov ah,0x66
mov al,'_'
mov di,[cs:location+si]               ;head
cmp ax,[es:di-160]                    ;check if head == upperBorder (di-160)
jne UpItselfHit
call reset
jmp endOfUp

UpItselfHit:
mov ah,0x06
mov al,'*'
mov di,[cs:location+si]                 ;head
cmp ax,[es:di-160]                      ;check if head == body (di-160)
jne fruitPickedU
call reset
jmp endOfUp

fruitPickedU:
mov ah,0x66
mov al,'A'
mov di,[cs:location+si]                 ;head
cmp ax,[es:di-160]                      ;check if head == fruit
jne continueUp
call extendU
call printFruit2
call display

continueUp:
mov word cx,[cs:length]
dec cx                                 
mov bx,cx
mov word si,[cs:length]
shl si,1                               ;length*2
sub si,2                               ;length-2
mov ah,0x06                            ;attributes
mov di,[cs:location+si]                ;head
mov al,[cs:snake+bx]                   ; head attributes
mov word[es:di-160],ax                 ;print head on next location (di+160)
sub word[cs:location+si],160  


upLoop:
mov bx,[cs:location+si-2]              ;move all characters to next location
mov ax,[es:bx]
mov word[es:di],ax
mov [cs:location+si-2],di
mov di,bx
sub si,2
loop upLoop

mov dl,0x20                            ;print space on last location
mov dh,0x00
mov word[es:di],dx

endOfUp:
popa
ret


extendU:
pusha
call clrscr
call printBorders
call score
add word[scoreVar],1
sub si,2
add word[cs:length],1
mov word bx,[cs:length]
sub bx,1
mov byte[cs:snake+bx],'+'
mov cx,bx
mov bx,0
exLoopU:
mov byte[cs:snake+bx],'*'
add bx,1
loop exLoopU
PrLoopU:
sub si,2
mov ax,0xb800
mov es,ax
mov ax, 0
mov word di,[cs:location+si]
add di,160
mov word cx,[cs:length]
mov bx,0
mov si,0
mov ah,0x06
LU:                        ;loop Up 
mov al, [cs:snake+bx]
mov word[es:di],ax
mov word[cs:location+si],di
add bx,1
sub di,160
add si,2
loop LU
popa 
ret

;***********************************************************************************
;*******************************************************************************************************************************************************************************
;***********************printfruit**************************************************

printFruit:
pusha
mov ax,0xb800
mov es,ax
mov ah,0x66
mov al,'A'
mov di,[fruitlocation]
add word[fruitlocation],200
mov [es:2000],ax
popa
ret

printFruit1:
pusha
mov ax,0xb800
mov es,ax
mov ah,0x66
mov al,'A'
mov di,[fruitlocation]
add word[fruitlocation],200
mov [es:1900],ax
popa
ret

printFruit2:
pusha
mov ax,0xb800
mov es,ax
mov ah,0x66
mov al,'A'
mov di,[fruitlocation]
add word[fruitlocation],200
mov [es:2020],ax
popa
ret

printFruit3:
pusha
mov ax,0xb800
mov es,ax
mov ah,0x66
mov al,'A'
mov di,[fruitlocation]
add word[fruitlocation],200
mov [es:3000],ax
popa
ret

;***********************************************************************************
;***************************kbisr**************************************************

kbisr:
push ax
push es
mov ax, 0xb800
mov es, ax 
in al, 0x60 

cmp al, 0x4D     ;right key scancode
jne left  
mov word[dir], 1 ; 1 for right

call moveRight
jmp noMatch  

left:
cmp al, 0x4B    ;left key scancode
jne up  
mov word[dir], 2 ; 2 for left
call moveLeft
jmp noMatch 

up:
cmp al, 0x48    ;up key scancode
jne down
mov word[dir], 3 ; 8 for up

call moveUp
jmp noMatch

down:
cmp al, 0x50	;down key scancode
jne noMatch
mov word[dir], 4 ; 9 for down
call moveDown

noMatch: 
mov al, 0x20
out 0x20, al 
pop es
pop ax
iret 

;*********************************************************************************************************
;*********************************timer*******************************************************************

timer:
push ax
push es	
	
rightCheck:
cmp word[dir], 1                       ; if right
jne checkLeft
call moveRight
jmp exitTimer

checkLeft:
cmp word[dir], 2                       ; if left
jne checkUp
call moveLeft
jmp exitTimer

checkUp:
cmp word[dir], 3                   ; if up
jne checkDown 
call moveUp
jmp exitTimer

checkDown:
cmp word[dir], 4                   ; if down
jne exitTimer
call moveDown

exitTimer:
mov al, 0x20
out 0x20, al 
pop es
pop ax
iret 


;********************************************************

start:
call clrscr
call printBorders
call initializeSnake
call printSnake
call printFruit
call score
call display
           
xor ax, ax 
mov es, ax 
mov ax, [es:9*4] 
mov [oldisr], ax
mov ax, [es:9*4+2] 
mov [oldisr+2], ax 
 
xor ax, ax 
mov es, ax 
mov ax, [es:8*4] 
mov [oldtimer], ax
mov ax, [es:8*4+2] 
mov [oldtimer+2], ax 
 
 
cli
mov word [es:9*4], kbisr 
mov [es:9*4+2], cs 
sti  
l1:

cli
mov word [es:8*4], timer 
mov [es:8*4+2], cs 
sti  
jmp l1

;**************************
exit:
mov ax, 0x4c00 
int 0x21



