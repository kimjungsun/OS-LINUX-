
[ORG 0x00]         
[BITS 16]       ;16bit real mode 

SECTION .text  

START:
    mov ax, 0x1000 ; 16bit -> *16 address calculate 
    mov ds, ax     ; protect mode 0x10000 address
    mov es, ax
mov ax, 0x2401
int 0x15
jc .A20GATEERROR
jmp RAM

.A20GATEERROR:
in al, 0x92
or al, 0x02
and al, 0xFE
out 0x92, al

RAM:                    ; RAM size calculating.
.FIRSTCALL:
mov eax,0xE820  
mov ebx, 0   ; initialize to zero
mov ecx,20    ;expected buffer size
mov edx, 0x0534D4150   ; SMAP 
int 0x15   

.CHECK:
mov eax, dword[es:di + 16]  ; TYPE==1 check
cmp eax, 1    
je .RAM
cmp ebx, 0     ; if 0 =>last descriptor 
je .END

.SUBCALL: ; otherwise keep calling
mov eax, 0xE820  
mov edx, 0x0534D4150
int 0x15
jmp .CHECK

.RAM :
mov ecx, [es:di + 8]  ; 8: Low-Length only 
add [LENGTH], ecx    ; 32bits = 4GB > RAMsize
cmp ebx, 0            ;thus, enough return size
je .END
jmp .SUBCALL

.END :
mov eax, [LENGTH]
shr eax, 20      ; 1MB = 2^20Byte 
mov ax, ax         
mov dl, 10       ; ex) 64/10 = 6...4
div dl           
mov dl, al            
add dl, 0x30     ; q   
mov dh, ah 
add dh, 0x30     ; r

mov byte[RAMMESSAGE-$$+0x10000+9],dl
mov byte[RAMMESSAGE-$$+0x10000+10],dh
    cli       ; no interrupt
    lgdt [ GDTR ] ; GDT table load 

;;;;; protect mode start;;;;;;	
    mov eax, 0x4000003B 
    mov cr0, eax        ; control register set up
;;;;; kenel code segment 0x00mode set up    
    jmp dword 0x18: ( PROTECTEDMODE - $$ + 0x10000 )
[BITS 32] 
PROTECTEDMODE:
    mov ax, 0x20 
    mov ds, ax
    mov es, ax     
    mov fs, ax 
    mov gs, ax 
    mov ss, ax 
    mov esp, 0xFFFE  
    mov ebp, 0xFFFE  
push (RAMMESSAGE -$$ + 0x10000)
push 1
push 0
call PRINTMESSAGE
add esp, 12
    
    push ( SWITCHSUCCESSMESSAGE - $$ + 0x10000)
  push 3 
   push 0           
  call PRINTMESSAGE  
  add esp, 12
    jmp dword 0x18: 0x10200    ; c language kenel go

PRINTMESSAGE:
    push ebp    
    mov ebp, esp  
    push esi      
    push edi      
    push eax
    push ecx
    push edx
    
    mov eax, dword [ ebp + 12 ]
    mov esi, 160              
    mul esi               
    mov edi, eax        
    
    mov eax, dword [ ebp + 8 ]
    
	
	mov esi, 2              
    mul esi                
    add edi, eax         
                    
                                
    mov esi, dword [ ebp + 16 ] 

.MESSAGELOOP:        
    mov cl, byte [ esi ]    
                           

    cmp cl, 0      
    je .MESSAGEEND 

    mov byte [ edi + 0xB8000 ], cl

    
    add esi, 1       
    add edi, 2      
            

    jmp .MESSAGELOOP      

.MESSAGEEND:
    pop edx  
    pop ecx 
    pop eax    
    pop edi  
    pop esi  
    pop ebp   
    ret      

align 8, db 0

dw 0x0000
GDTR:
    dw GDTEND - GDT - 1     
    dd ( GDT - $$ + 0x10000 )  

GDT:
    NULLDescriptor:
        dw 0x0000
        dw 0x0000
        db 0x00
        db 0x00
        db 0x00
        db 0x00
    ;;; IA_32e
	IA_32eCODEDESCRIPTOR:
	    dw 0xFFFF
		dw 0x0000
		db 0x00
		db 0x9A
		db 0xAF
		db 0x00
	IA_32eDATADESCRIPTOR:
	    dw 0xFFFF
		dw 0x0000
		db 0x00
		db 0x92
		db 0xAF
		db 0x00
			
    CODEDESCRIPTOR:     
        dw 0xFFFF       ; Limit [15:0]
        dw 0x0000       ; Base [15:0]
        db 0x00         ; Base [23:16]
        db 0x9A         ; P=1, DPL=0, Code Segment, Execute/Read
        db 0xCF         ; G=1, D=1, L=0, Limit[19:16]
        db 0x00         ; Base [31:24]  
        
    DATADESCRIPTOR:
        dw 0xFFFF       ; Limit [15:0]
        dw 0x0000       ; Base [15:0]
        db 0x00         ; Base [23:16]
        db 0x92         ; P=1, DPL=0, Data Segment, Read/Write
        db 0xCF         ; G=1, D=1, L=0, Limit[19:16]
        db 0x00         ; Base [31:24]
GDTEND:
LENGTH: dd 0
RAMMESSAGE: db 'RAM Size:00MB',0
SWITCHSUCCESSMESSAGE: db 'Switch To Protected Mode Success~!!', 0
times 512 - ( $ - $$ )  db  0x00 
