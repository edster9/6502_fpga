; hello.s - Simple "Hello World" program for 6502
; This program demonstrates basic 6502 assembly programming
; It loads values into registers and stores them to memory

.setcpu "6502"

; Code segment - the main program
.segment "CODE"

reset:
    ; Initialize system - clear decimal mode and set stack
    CLD                     ; Clear decimal mode
    LDX #$FF               ; Load stack pointer
    TXS                    ; Set stack pointer to $01FF
    
    ; Test program - load and store values
    LDA #$42               ; Load hex 42 into accumulator  
    STA $8000              ; Store A to memory location $8000
    
    LDX #$33               ; Load hex 33 into X register
    STX $8001              ; Store X to memory location $8001
    
    LDY #$24               ; Load hex 24 into Y register
    STY $8002              ; Store Y to memory location $8002
    
    ; Simple arithmetic test
    LDA $8001              ; Load X value back into A
    CLC                    ; Clear carry flag
    ADC #$10               ; Add 16 to accumulator
    STA $8003              ; Store result (should be $43)
    
    ; Test complete marker
    LDA #$FF               ; Load completion marker
    STA $8004              ; Store completion flag
    
loop:
    JMP loop               ; Infinite loop

; Interrupt vectors - required for 6502 system
.segment "VECTORS"
.addr reset                ; NMI vector ($FFFA-$FFFB)
.addr reset                ; Reset vector ($FFFC-$FFFD)  
.addr reset                ; IRQ vector ($FFFE-$FFFF)
