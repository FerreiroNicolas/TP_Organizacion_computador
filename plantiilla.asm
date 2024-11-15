; Colocar nombre y padron de los integrantes del grupo
; Nicolas Ferreiro, 111674
; Daniel Mamani, 

global	main

section	.data
	secuenciaBinariaA	db	0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C 
						db	0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51 
						db	0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18 
	largoSecuenciaA		db	0x18 ; 24d

	secuenciaImprmibleB db	"vhyAHZucgTUuznwTDciGQ8m4TuvUIyjU"
	largoSecuenciaB		db	0x20 ; 32d

	TablaConversion		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	
; Casos de prueba:
; SecuenciaBinariaDePrueba db	0x73, 0x38, 0xE7, 0xF7, 0x34, 0x2C, 0x4F, 0x92
;						   db	0x49, 0x55, 0xE5, 0x9F, 0x8E, 0xF2, 0x75, 0x5A 
;						   db	0xD3, 0xC5, 0x53, 0x65, 0x68, 0x52, 0x78, 0x3F
; SecuenciaImprimibleCodificada	db	"czjn9zQsT5JJVeWfjvJ1WtPFU2VoUng/"

; SecuenciaImprimibleDePrueba db "Qy2A2dhEivizBySXb/09gX+tk/2ExnYb"
; SecuenciaBinariaDecodificada	db	0x43, 0x2D, 0x80, 0xD9, 0xD8, 0x44, 0x8A, 0xF8 
;								db	0xB3, 0x07, 0x24, 0x97, 0x6F, 0xFD, 0x3D, 0x81 
;								db	0x7F, 0xAD, 0x93, 0xFD, 0x84, 0xC6, 0x76, 0x1B
 
; Un codificador/decodificador online se puede encontrar en https://www.rapidtables.com/web/tools/base64-encode.html
	
section	.bss
	secuenciaImprimibleA	resb	32
	secuenciaBinariaB		resb	24
	
section	.text

main:
	; Inicializar registros y variables
	mov rsi, secuenciaBinariaA      ; rsi apunta a la secuencia binaria
	mov rdi, secuenciaImprimibleA  ; rdi apunta a la salida imprimible
	mov rcx, largoSecuenciaA       ; rcx contiene el tamaño de la secuencia
	movzx rcx, byte [rcx]          ; Convertir tamaño a entero

	codificar_base64:
		; Verificar si quedan al menos 3 bytes por procesar
		cmp rcx, 3
		jl fin_codificacion          ; Terminar si menos de 3 bytes restantes

		; Cargar 3 bytes en un registro de 24 bits (rax)
		mov al, byte [rsi]           ; Cargar primer byte en AL
		mov ah, byte [rsi + 1]       ; Cargar segundo byte en AH
		shl eax, 8                   ; Desplazar segundo byte
		mov al, byte [rsi + 2]       ; Cargar tercer byte
		shl eax, 8                   ; Combinar en rax: [Byte3|Byte2|Byte1]

		; Generar los 4 grupos de 6 bits
		mov ebx, eax                 ; Copiar rax a ebx para trabajar
		shr ebx, 18                  ; Grupo 1: bits 18-23
		and ebx, 0x3F                ; Asegurarse de tomar solo 6 bits
		mov bl, byte [TablaConversion + rbx] ; Obtener carácter de la tabla
		mov byte [rdi], bl           ; Escribir carácter en salida

		mov ebx, eax
		shr ebx, 12                  ; Grupo 2: bits 12-17
		and ebx, 0x3F
		mov bl, byte [TablaConversion + rbx]
		mov byte [rdi + 1], bl

		mov ebx, eax
		shr ebx, 6                   ; Grupo 3: bits 6-11
		and ebx, 0x3F
		mov bl, byte [TablaConversion + rbx]
		mov byte [rdi + 2], bl

		mov ebx, eax
		and ebx, 0x3F                ; Grupo 4: bits 0-5
		mov bl, byte [TablaConversion + rbx]
		mov byte [rdi + 3], bl

		; Avanzar punteros y reducir tamaño
		add rsi, 3                   ; Avanzar al siguiente bloque en secuencia
		add rdi, 4                   ; Avanzar en la salida
		sub rcx, 3                   ; Reducir contador de bytes restantes

		jmp codificar_base64         ; Repetir para el siguiente bloque

	fin_codificacion:
		; Salir del programa
		mov eax, 60                  ; syscall: exit
		xor edi, edi                 ; exit code 0
		syscall