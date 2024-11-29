; Nombre: [Colocar nombre y padrón]
; Implementación de codificación BASE64 en ensamblador Intel x86_64

global	main

section	.data
	secuenciaBinariaA	db	0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C 
						db	0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51 
						db	0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18 
	largoSecuenciaA		db	0x18 ; 24d (longitud en bytes)

	TablaConversion		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	
section	.bss
	secuenciaImprimibleA	resb	32 ; Espacio reservado para la salida codificada

section	.text
global _start  ; Define el punto de entrada global

section .text
_start:
    ; Llama a la función principal
    call main

    ; Terminar el programa
    mov rax, 60       ; syscall: exit
    xor rdi, rdi      ; Código de salida: 0
    syscall

main:
    ; Inicializar punteros y longitud
    mov rsi, secuenciaBinariaA    ; rsi -> Entrada
    mov rdi, secuenciaImprimibleA ; rdi -> Salida
    movzx rcx, byte [largoSecuenciaA] ; Longitud de entrada

encode_loop:
    cmp rcx, 3
    jl fin_encode                 ; Salir si quedan menos de 3 bytes

    ; Cargar 3 bytes en EAX
    xor eax, eax                  ; Limpiar EAX
    mov al, [rsi]                 ; Primer byte (bits 16-23)
    shl eax, 8
    mov al, [rsi+1]               ; Segundo byte (bits 8-15)
    shl eax, 8
    mov al, [rsi+2]               ; Tercer byte (bits 0-7)

    ; Extraer bloques de 6 bits
    ; Primer bloque (bits 18-23)
    mov ebx, eax
    shr ebx, 18
    and ebx, 0x3F
    mov bl, [TablaConversion + rbx]
    mov [rdi], bl

    ; Segundo bloque (bits 12-17)
    mov ebx, eax
    shr ebx, 12
    and ebx, 0x3F
    mov bl, [TablaConversion + rbx]
    mov [rdi+1], bl

    ; Tercer bloque (bits 6-11)
    mov ebx, eax
    shr ebx, 6
    and ebx, 0x3F
    mov bl, [TablaConversion + rbx]
    mov [rdi+2], bl

    ; Cuarto bloque (bits 0-5)
    mov ebx, eax
    and ebx, 0x3F
    mov bl, [TablaConversion + rbx]
    mov [rdi+3], bl

    ; Avanzar punteros y reducir contador
    add rsi, 3
    add rdi, 4
    sub rcx, 3
    jmp encode_loop

fin_encode:
    ; Mostrar la salida
    mov rax, 1        ; syscall: write
    mov rdi, 1        ; stdout
    mov rsi, secuenciaImprimibleA ; Dirección de salida
    mov rdx, 32       ; Longitud de salida
    syscall

    ret
