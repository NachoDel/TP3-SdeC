; pmode.asm - Cambio a modo protegido sin usar macros
BITS 16                  ; Ensamblador en modo 16 bits (modo real)
ORG 0x7C00               ; Dirección de carga típica de un boot sector

start:
    cli                 ; Deshabilita interrupciones para evitar interferencias
    xor ax, ax
    mov ds, ax          ; Inicializa segmento de datos en 0
    mov ss, ax          ; Inicializa segmento de pila en 0
    mov sp, 0x7C00      ; Coloca la pila justo debajo del bootloader (no pisa código)

    ; ------------------------------
    ; Cargar la GDT en GDTR
    lgdt [gdt_desc]     ; GDTR = base y límite de nuestra tabla de descriptores

    ; ------------------------------
    ; Activar el bit PE (Protection Enable) en CR0 para pasar a modo protegido
    mov eax, cr0
    or eax, 1           ; Bit 0 = PE (Protection Enable)
    mov cr0, eax

    ; ------------------------------
    ; Salto lejano para cargar CS con selector de código 32 bits y hacer flush del pipeline
    jmp CODE_SEL:pm_entry

; ------------------------------
; Definición de la Global Descriptor Table (GDT)
gdt_start:
    ; Descriptor nulo obligatorio (índice 0)
    dq 0x0000000000000000

    ; Descriptor de código (índice 1)
    ; Base = 0x00000000, Límite = 0xFFFFF (4 GB), Ejecutable, Solo lectura, Ring 0
    dw 0xFFFF           ; Límite 15:0
    dw 0x0000           ; Base 15:0
    db 0x00             ; Base 23:16
    db 10011010b        ; Access Byte: Presente, Ring 0, Código, Ejecutable, Readable
    db 11001111b        ; Flags: 4K Granularidad, 32-bit segment, Límite 19:16
    db 0x00             ; Base 31:24

    ; Descriptor de datos (índice 2)
    ; Base = 0x00200000, Límite = 0x0FFFFF (1 MB), Solo lectura, Ring 0
    dw 0xFFFF           ; Límite 15:0
    dw 0x0000           ; Base 15:0
    db 0x20             ; Base 23:16 (Base = 0x00200000)
    db 10010000b        ; Access Byte: Presente, Ring 0, Datos, Read-Only
    db 11001111b        ; Flags: 4K Granularidad, 32-bit segment, Límite 19:16
    db 0x00             ; Base 31:24
gdt_end:

; Descriptor de la GDT (límite de 16 bits y base de 32 bits)
gdt_desc:
    dw gdt_end - gdt_start - 1   ; Límite (tamaño de la GDT - 1)
    dd gdt_start                 ; Dirección base de la GDT

; Selectores de segmento (índices en la GDT)
CODE_SEL equ 0x08   ; Selector para el segmento de código (índice 1 * 8)
DATA_SEL equ 0x10   ; Selector para el segmento de datos (índice 2 * 8)

; ------------------------------
; Código que se ejecuta en modo protegido (BITS 32)
[BITS 32]
pm_entry:
    ; Cargar todos los registros de segmento con el selector de datos
    mov ax, DATA_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Intentar escribir en el segmento de datos (esto debería fallar si es solo lectura)
    mov dword [0x00200000], 0xDEADBEEF

    ; A partir de aquí estamos en modo protegido y usando segmentos de 32 bits
    ; Loop infinito que ejecuta HLT (detener CPU hasta próxima interrupción)
.halt:
    hlt
    jmp .halt           ; Mantiene la CPU en estado inactivo

; ------------------------------
; Relleno hasta 510 bytes + firma de boot (0xAA55)
times 510-($-$$) db 0
dw 0xAA55               ; Firma requerida por BIOS para detectar el bootloader