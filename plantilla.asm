; Nombre: [Nicolas Ferreiro - 111674, Daniel Mamani - 109932]
; Implementación de codificación BASE64 en ensamblador Intel x86_64

%macro inicializar 0
    mov rsi, secuenciaBinariaA    ; rsi -> Entrada
    mov rdi, secuenciaImprimibleA ; rdi -> Salida
    movzx rcx, byte [largoSecuenciaA] ; Longitud de entrada
%endmacro

%macro agrupar_bytes 0
    xor eax, eax                  ; Limpiar EAX
    mov al, [rsi]                 ; Primer byte (bits 16-23)
    shl eax, 8
    mov al, [rsi+1]               ; Segundo byte (bits 8-15)
    shl eax, 8
    mov al, [rsi+2]               ; Tercer byte (bits 0-7)
%endmacro

%macro extraer_bloque 1
    mov ebx, eax
    shr ebx, %1
    and ebx, 0x3F
    mov bl, [TablaConversion + rbx]
%endmacro

%macro avanzar 0
    add rsi, 3
    add rdi, 4
    sub rcx, 3
    jmp encode_loop
%endmacro

%macro encode_loop 0
    encode_loop:
    cmp rcx, 3
    jl fin_encode   ; Salir si quedan menos de 3 bytes

    ; Cargar 3 bytes en EAX
    agrupar_bytes

    ; Extraer bloques de 6 bits
    
    ; Primer bloque (bits 18-23)
    extraer_bloque 18
    mov [rdi], bl

    ; Segundo bloque (bits 12-17)
    extraer_bloque 12
    mov [rdi+1], bl

    ; Tercer bloque (bits 6-11)
    extraer_bloque 6
    mov [rdi+2], bl

    ; Cuarto bloque (bits 0-5)
    extraer_bloque 0
    mov [rdi+3], bl

    ; Avanzar punteros y reducir contador
    avanzar
%endmacro

%macro mostrar_salida 0
    mov rax, 1        ; syscall: write
    mov rdi, 1        ; stdout
    mov rsi, secuenciaImprimibleA ; Dirección de salida
    mov rdx, 32       ; Longitud de salida
    syscall
%endmacro

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
    inicializar
    
    ; Bucle para codificar la secuencia
    encode_loop

fin_encode:
    ; Mostrar la salida
    mostrar_salida    
    ret
