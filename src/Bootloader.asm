[bits 16]
[org 0x7C00]

main:
    hlt

.halt:
    jmp .halt







[bits 32]


times 510-($-$$) db 0
dw 0x55AA