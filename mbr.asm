	;; mbr.asm - A simple x86 bootloader example.
	;;
	;; In worship to the seven hacker gods and for the honor 
	;; of source code realm, we hereby humbly offer our sacred 
	;; "Hello World" sacrifice. May our code remain bugless.

	
 
	org 0x7c00		; Our load address



_start:
	
	CALL RESET	
	CALL IMPUTWAIT	;pega imput e espera operacao
	restart:	
	mov al, 0x00
	mov ah, 0x00
	CALL Rand2	;numero aleatorio, numero de rotacoes
	mov cl, al
	mov dl, 0x00
	sloop:
		CALL RESET
		CALL waittime	;dar um "framerate" a acao
		CALL PrintAll   ;printa a carinha
		cmp dl,	cl  
		je end 
		add dl, 0x1
		CALL PrintJumpLine
	jmp sloop

end:				
	
	mov al, [state]
	cmp al, 0x0
	je happy
	cmp al, 0x1
	je sad

	mov ah, 0xe
	mov al, 0x3f
	INT 0x10
	CALL Barran
	jmp realend 
	
	happy:
	mov ah, 0xe
	mov al, 0x59
	INT 0x10
	CALL Barran
	jmp realend

	sad:
	mov ah, 0xe
	mov al, 0x4e
	INT 0x10
	CALL Barran
	jmp realend

realend:
	mov ah, 0x00
	mov al, 0x00
	CALL IMPUTWAIT
	jmp restart

IMPUTWAIT:
	mov ah, 0x00
	mov al, 0x00
	INT 0x16

ret 
PrintAll:
	
	mov ah, 0xe		; Configure BIOS teletype mode
	mov al, 0x00
	mov bx, 0x00		; May be 0 because org directive.

	loop1:
	mov al, [smiley1 + bx]
	int 0x10
	cmp al, 0x0
	je end1 
	add bx, 0x1
	jmp loop1

	end1:
	mov bx, 0x0

	mov al, [state]
	cmp al, 0x0 ; H -> N
	je loop2

	cmp al, 0x1 ;N-> S
	je loop3

	loop4:
		mov al, [smiley4 + bx]
		int 0x10
		cmp al, 0x0
		je end4
		add bx, 0x1
		jmp loop4
	end4: 
		mov al, 0x0
		mov [state], al
		jmp endend



	loop3:
		mov al, [smiley3 + bx]
		int 0x10
		cmp al, 0x0
		je end2
		add bx, 0x1
		jmp loop3
	end3: 
		mov al, [state]
		add al, 0x1
		mov [state], al
		jmp endend
	

	loop2:
		mov al, [smiley2 + bx]
		int 0x10
		cmp al, 0x0
		je end2
		add bx, 0x1
		jmp loop2
	end2: 
		mov al, [state]
		add al, 0x1
		mov [state], al
		jmp endend

	endend:

ret

Barran:
	mov al, 0xa
	int 0x10
	mov al, 0xd
	int 0x10
ret

Rand2:
	rdtsc
	AND EAX, 0xF ;valor de 0 a 16
ret

waittime:
	mov cl, 0x06
	mov ah, 0x86
	INT 0x15
ret

PrintJumpLine:
    mov ah, 0xe        ; Configure BIOS teletype mode
    mov al, 0x00
    mov bx, 0x11        ; May be 0 because org directive.

    loopPrintJumpLine:
        mov al, 0xa
        int 0x10
        mov al, 0xd
        int 0x10
        cmp bx, 0x0
        je endPrintJumpLine
        dec bx
        jmp loopPrintJumpLine

    endPrintJumpLine:
ret

RESET:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
ret



here:				; C-like NULL terminated string
	
	state db 0 ;0 -> happy 1 -> neutral 2-> sad
	smiley1 db '    0     0   ', 0xa, 0xd,0x0
	smiley2 db '              ', 0xa, 0xd,'    XXXXXXX   ', 0xa, 0xd,'  XX       XX ', 0xa, 0xd,'              ', 0xa, 0xd,0x0
	smiley3 db '              ', 0xa, 0xd,'  XXXXXXXXXXX ', 0xa, 0xd,'              ', 0xa, 0xd,'              ', 0xa, 0xd,0x0
	smiley4 db ' XX       XX ', 0xa, 0xd,'    XXXXXXX   ', 0xa, 0xd,'              ', 0xa, 0xd,'              ', 0xa, 0xd,0x0

	times 510 - ($-$$) db 0	; Pad with zeros
	dw 0xaa55		; Boot signature
