; Compile with:
; nasm -f elf -o pass.o pass.asm
; ld -m elf_i386 -o pass pass.o

section .text
     global _start

_start:
;; Open file
     call    open_file
     jle     file_exist

;; Create file
     mov     eax, 8
     mov     ebx, filename
     mov     ecx, 0666o
     int     0x80

;; File created sucessfully?
     call    check
     jnle    exit

new_password:
     mov     [fd], eax

;; Request a new password
     mov     eax, 4
     mov     ebx, 1
     mov     ecx, new_pass
     mov     edx, new_pass_len
     int     0x80

;; Enter a new password
     mov     eax, 3
     xor     ebx, ebx
     mov     ecx, write
     mov     edx, 1024
     int     0x80

;; Write a new password to file
     mov     eax, 4
     mov     ebx, [fd]
     mov     ecx, write
     mov     edx, 1024
     int     0x80

;; Exit
     jmp     exit

file_exist:
     mov     [fd], eax

;; Read password from file
     mov     eax, 3
     mov     ebx, [fd]
     mov     ecx, read
     mov     edx, 1024
     int     0x80

;; Request password
     mov     eax, 4
     mov     ebx, 1
     mov     ecx, pass
     mov     edx, pass_len
     int     0x80

;; Enter password
     mov     eax, 3
     xor     ebx, ebx
     mov     ecx, input
     mov     edx, 1024
     int     0x80

;; Calculate string length
     mov     eax, read
     mov     ebx, eax

nextchar:
     cmp     byte [eax], 0
     jz      finished

     inc     eax
     jmp     nextchar

finished:
     sub     eax, ebx

;; Compare strings
     mov     ecx, eax
     push    ecx
     inc     ecx
     mov     eax, input

cycle:
     inc     eax
     loop    cycle

     cmp     byte [eax], 0

     jnz     exit

     pop     ecx
     mov     esi, read
     mov     edi, input
     repe    cmpsb

     je      equally

;; Exit
     jmp     exit

equally:
;; Open file
     call    open_file

;; New password
     jle     new_password

exit:
;; Close file
     mov     eax, 6
     mov     ebx, [fd]
     int     0x80

;; Exit
     mov     eax, 1
     xor     ebx, ebx
     int     0x80

open_file:
;; Open file
     mov     eax, 5
     mov     ebx, filename
     mov     ecx, 2
     int     0x80

;; File exist?
check:
     xor     edx, edx
     cmp     edx, eax
     ret

section .bss
     write:  resb 1024
     read:   resb 1024
     input:  resb 1024
     fd:     resb 1

section .data
     filename:       db '/tmp/pass.dat', 0

     new_pass:       db 'New password: '
     new_pass_len:   equ $ - new_pass

     pass:           db 'Password: '
     pass_len:       equ $ - pass
