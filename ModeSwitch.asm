
[BITS 32]         
global kReadCPUID, kSwitchAndExecute64bitKernel

SECTION .text   

    
kSwitchAndExecute64bitKernel:
    mov eax, cr4    
    or eax, 0x20    
    mov cr4, eax   
	 
    mov eax, 0x100000 
    mov cr3, eax       
    

    mov ecx, 0xC0000080  
    rdmsr             
   
    or eax, 0x0100      
                       
    wrmsr         
        
    mov eax, cr0           
    or eax, 0xE0000000  
    xor eax, 0x60000000 
	or eax, 0x00010000   ;;;;; WP == 1 (no. 16bit) set
    mov cr0, eax           
    
    jmp 0x08:0x200000    
