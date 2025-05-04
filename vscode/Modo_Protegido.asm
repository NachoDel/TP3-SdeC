; pmode.asm - arranque a protected mode sin macros
BITS 16
ORG 0x7C00

start:
    cli                     ; deshabilita interrupciones
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Cargar GDT
    lgdt [gdt_desc]

    ; Activar bit PE en CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump para flush de pipeline y cambio a 32 bits
    jmp CODE_SEL:pm_entry

; ------------- GDT -------------
gdt_start:
    dq 0
    ; descriptor código: base=0x00000000, limit=4GiB, exec+read, DPL=0
    dq 0x00CF9A000000FFFF
    ; descriptor datos:  base=0x00200000, limit=1MiB, read/write, DPL=0
    dq 0x00CF92002000FFFF
gdt_end:

gdt_desc:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEL equ 0x08   ; selector índice 1
DATA_SEL equ 0x10   ; selector índice 2

[BITS 32]
pm_entry:
    ; configurar segmentos de datos
    mov ax, DATA_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; aquí ya en modo protegido 32-bit
    ; código de ejemplo: loop infinito
.halt:
    hlt
    jmp .halt

times 510-($-$$) db 0
dw 0xAA55