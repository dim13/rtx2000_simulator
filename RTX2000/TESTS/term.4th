\ COPYRIGHT 1990 HARRIS CORPORATION  ALL RIGHTS RESERVED
\ Rick VanNorman Mon  04-02-1990  11:17:24

VARIABLE BUGGY

\ ---------- serial interrupt service for TIL

$FFF CONSTANT /BUF

\ offsets into the serial allocation, sizes implied by offset differences
\ kindof tricky, but standard forth anyway
\ the tricks are used to allow the use of segment:offset address
\ tokens, which is the basic compilation unit in TIL

     0 CONSTANT _COM#               \ the com port base address
     4 CONSTANT _INTO-BUF           \ index of where to put next char into buf
     8 CONSTANT _OUTOF-BUF          \ where to get next char from buf
   $0C CONSTANT _XOFFED             \ unused, but could be an xon/xoff flag
   $10 CONSTANT _BUF                \ the data buffer itself
 $1010 CONSTANT _INTERRUPT-SERVICE  \ and the interrupt service routine

HERE PARA_ALIGN HERE - ALLOT ( align the dictionary)

$0D ALLOT ( magic number to force the next definition's parameter)
          ( field to be paragraph aligned.  change with caution)

\ the serial input data buffers and interrupt routine
CREATE SERIAL

   HERE $F AND 0= huh?  \ compile time check for dictionary alignment
                        \ do not *EVER* remove this check

   _INTERRUPT-SERVICE ALLOT

   ASSEMBLER

                   AX   PUSH  \
                   BX   PUSH  \ save affected regs
                   DX   PUSH  \
                   DS   PUSH  \
                CS AX   MOV   \
                AX DS   MOV   \ establish addressing
          _COM# #) DX   MOV   \ get com port number
      _INTO-BUF #) BX   MOV   \ where in buffer
                   BX   INC   \ increment
      BX _INTO-BUF #)   MOV   \ save pointer
           /BUF #  BX   AND   \ pointer mod buf_size
                 0 AL   IN    \ read character
         AL _BUF [BX]   MOV   \ into ring buffer
             $20 # AL   MOV   \ send EOI to 8259
             $20 # AL   OUT   \
                   DS   POP   \
                   DX   POP   \ restore registers
                   BX   POP   \
                   AX   POP   \
                        IRET
                        END-CODE

\ ---------- data structure pointers

: COM#                SERIAL _COM#              + ;
: INTO-BUF            SERIAL _INTO-BUF          + ;
: OUTOF-BUF           SERIAL _OUTOF-BUF         + ;
: BUF                 SERIAL _BUF               + ;
: INTERRUPT-SERVICE   SERIAL S:O_ALIGN _INTERRUPT-SERVICE +  ;

\ ---------- Com port interface

VARIABLE INSTALLED
VARIABLE IRQ-MASK   ( irq mask for the selected com port)
VARIABLE INT-#      ( interrupt number for the com port)

: COM1   $3F8 COM# !  $10 IRQ-MASK !  $0C INT-# ! INSTALLED OFF ;
: COM2   $2F8 COM# !  $08 IRQ-MASK !  $0B INT-# ! INSTALLED OFF ;
: COM3   $3E8 COM# !  $10 IRQ-MASK !  $0C INT-# ! INSTALLED OFF ;
: COM4   $2E8 COM# !  $08 IRQ-MASK !  $0B INT-# ! INSTALLED OFF ;

COM3

: INT-VEC ( - s:o)
   INT-# @ 4 * ;

VARIABLE OLD-VEC ( a holding spot for the old ivecs)

\ ---------- 8250 port definition

: PORT   CREATE ,  DOES> @ COM# @ + ;

   0 PORT ^RBR     4 PORT ^MCR
   0 PORT ^THR     5 PORT ^LSR
   1 PORT ^IER     6 PORT ^MSR
   2 PORT ^IIR     0 PORT ^DLL
   3 PORT ^LCR     1 PORT ^DLM

\ ---------- baud rate

VARIABLE RATE

: BAUD ( n)
   115200 SWAP / RATE ! ;

19200 BAUD ( or whatever the default should be)

\ ---------- characters out of the interrupt buffer

: RCV@ ( - char)
   OUTOF-BUF @ /BUF AND BUF + C@ ;

: RCV? ( - flag)
   INTO-BUF @ OUTOF-BUF @ <> ;

: RCV ( - char)
   BEGIN  RCV? UNTIL  1 OUTOF-BUF H+! RCV@ ;

: #RCV ( - n)
   RCV RCV $100 * + ;

: RCVS ( a #)
   BOUNDS ?DO  RCV I C!  LOOP ;

\ ---------- 8250 output routines

CODE _XMT ( char port)
                BX DX   MOV   \ get com port number
               5 # DX   ADD   \ point to line status reg
                        BEGIN \ wait for transmitter empty
                 0 AL   IN    \ sample status
             $20 # AL   AND   \
                  0<>   UNTIL \ until transmitter ready
               5 # DX   SUB   \ point back to data register
                   AX   POP
                   AX   POP
                 0 AL   OUT   \ SEND CHAR
                   DX   POP
                   BX   POP
                        NEXT
                        END-CODE

: XMT ( char)
   COM# @ _XMT ;

: #XMT ( n)
   DUP XMT 256 / XMT ;

: XMTS ( a #)
   BOUNDS ?DO  I C@ XMT  LOOP ;

\ ---------- Interrupt vector management

: SET-TRAP
   INT-VEC @  OLD-VEC !
   INTERRUPT-SERVICE INT-VEC ! ;

: RESTORE-TRAP
   OLD-VEC @  INT-VEC ! ;

CODE ENABLE  ( interrupts)
   STI
   NEXT
   END-CODE

CODE DISABLE ( interrupts)
   CLI
   NEXT
   END-CODE

\ ---------- 8250 uart initialization

: INIT-8250
          $80 ^LCR PC!       ( select baud rate)
      RATE C@ ^DLL PC!
   RATE 1+ C@ ^DLM PC!
           03 ^LCR PC!       ( No parity, 8 bits, 1 stop bit)
           00 ^IER PC!       ( disable interrupts)
              ^LSR PC@ DROP  (  clear the registers)
              ^RBR PC@ DROP ;

: ENABLE-8250
          $0B ^MCR PC!       ( set modem control)
            1 ^IER PC! ;     ( enable interrupts)

: DISABLE-8250
           00 ^MCR PC!       ( loopback and modem control)
           00 ^IER PC! ;     ( disable interrupts)

\ ---------- 8259 interrupt controller initialization

: UNMASK-8259
   $021 PC@                 ( read 8259 int mask )
   IRQ-MASK @ -1 XOR AND    ( turn on desired level )
   $021 PC!  ;

: MASK-8259
   $021 PC@        ( read 8259 int mask )
   IRQ-MASK @ OR   ( turn off this level )
   $021 PC! ;      ( write mask back to 8259 )

: INSTALL ( interrupt service routines)
   DISABLE
      INIT-8250 ENABLE-8250
      SET-TRAP
      UNMASK-8259
   ENABLE
   0 INTO-BUF !
   0 OUTOF-BUF !
   BUF /BUF 1+ ERASE
   INSTALLED ON ;

: REMOVE ( interrupt service routines)
   DISABLE
      MASK-8259
      INIT-8250 DISABLE-8250
      RESTORE-TRAP
   ENABLE ;

\ ---------- simple, stupid terminal program

: INIT-ALT-COM
   COM# @ 16 XOR COM# !         \ the alternate com port must be
   DISABLE-8250                 \ share interrupt vectors
   COM# @ 16 XOR COM# ! ;       \ back to original com port

: INITIALIZE
   INSTALLED @ 0= IF
      INIT-ALT-COM
      INSTALL   \ the com port interrupt and init com port
   THEN
   INTO-BUF @ OUTOF-BUF @ -  /BUF >
   IF  CR ." buffer overrun"  0 INTO-BUF !  0 OUTOF-BUF !  THEN ;

: SUSPEND
   CR ." TIL "
   QUIT ;

: BYE
   REMOVE (BYE) ;

: HELP
   CR
   CR ." COPYRIGHT 1990 HARRIS CORPORATION  ALL RIGHTS RESERVED"
   CR ." Rick VanNorman Mon  04-02-1990  11:17:15"
   CR
   CR ." Press alt-f10 to exit to DOS"
   CR ;

: KEYBOARD
   KEY? IF
      KEY
      ?DUP IF XMT EXIT THEN
      KEY DUP 113 = IF DROP BYE            THEN
          DUP 103 = IF DROP SUSPEND        THEN
          DUP  59 = IF DROP HELP EXIT      THEN
          DUP  60 = IF DROP BUGGY @ 0= BUGGY !
                                      EXIT THEN
      0 XMT XMT
   THEN ;

\ ----------

ONLY FORTH ALSO DEFINITIONS  DOS2 ALSO

: X-OPEN-FILE
   PAD 80 ERASE
   PAD #RCV DDUP RCVS
   OPEN-FILE  XMT ;

: X-CLOSE-FILE
   RCV CLOSE-FILE ;

: X-READ-FILE
   RCV  PAD #RCV  ROT READ-FILE ( #read)
   DUP #XMT PAD SWAP XMTS ;

: X-WRITE-FILE
   RCV #RCV
   PAD OVER RCVS
   PAD SWAP ROT WRITE-FILE
   #XMT ;

: X-SEEK
   RCV ( handle) >R
   RCV ( dir)    >R
   #RCV ( hi pos)  16 LSLN
   #RCV ( lo pos)  OR
   R> R>
   SEEK-FILE
   DUP #XMT 16 LSRN #XMT ;

: X-CREATE
   PAD 80 ERASE
   PAD #RCV DDUP RCVS
   CREATE-FILE  XMT ;

: X-DELETE     ;

\ ---------- simple file lister

ONLY FORTH ALSO DEFINITIONS  SYSTEM ALSO  DOS2 ALSO

: X-OPEN-LIST ( - f)
   LNAME FOPEN DUP HANDLE !  0<> DUP XMT ;

: X-CLOSE-LIST
   HANDLE @  DUP CLOSE-FILE  0<> XMT ;

: X-L16 ( list the next 16 lines)
   X-OPEN-LIST IF
      0 0 AT  DARK
      LINE# @ >LINE
      16 0 DO
         PAD 80 HANDLE @ READ-LINE IF PAD SWAP TYPE ELSE DROP THEN
         CR
      LOOP
      .LNAME
      X-CLOSE-LIST
   THEN ;

: X-LIST
   #RCV  0 MAX  LAST-LINE @ MIN  LINE# !  X-L16  LINE# @ #XMT ;

\ ----------

: X-SETUP-VIEW-FILE
   X-OPEN-LIST IF
      HANDLE @ FILESIZE  0 0 HANDLE @ SEEK-FILE DROP
      PAD S:O_ALIGN DUP ROT HANDLE @ BIG-READ-FILE ( pad #)
      OVER S:O>LINEAR + LINEAR>S:O ( from to)  LINES S:O_ALIGN
      SCAN-LINES LAST-LINE !
      X-CLOSE-LIST
   THEN ;

ONLY FORTH ALSO DEFINITIONS SYSTEM ALSO DOS2 ALSO

: X-LIST-FILE
   PAD 80 ERASE  PAD #RCV DDUP RCVS ( a #)
   LNAME SWAP  DDUP >R >R  CMOVE  0 R> R> + C!
   X-SETUP-VIEW-FILE ;

\ ----------

: X-READ-LINE
   SPIN
   RCV ( handle) #RCV ( count) SWAP ( # handle)
   >R  BUFF  OVER 1+ 128 MIN  R@  READ-FILE  ( # #read)
   DUP 0= IF ( end of file)
      DDROP  R> DROP  0 #XMT 0 XMT  EXIT
   THEN
   ( # #read)
   BUFF OVER #EOL SCAN  NIP ( # #read #toeol)
   ?DUP IF    EOL# OVER - >R -
        ELSE  DDUP U< >R
        THEN
   MIN R> ( u4 #seek)
   ?DUP IF  1 R@ SEEK-FILE DROP  THEN
   BUFF OVER #EOF SCAN  NIP -   ( remove if no control-Zs)
   R> DROP
   BUFF W@ $205C = IF  DROP 2  THEN
   DUP ( #line) #XMT -1 XMT
   BUFF SWAP
   BUGGY @ IF  CR DDUP TYPE THEN
   XMTS ;


\ ----- COMMAND.COM INTERFACE

: X-COMMAND
   #RCV HERE C!  HERE COUNT RCVS
   HERE  [COMMAND]
   0 XMT ;

\ ----------

: HOST-COMMAND ( cmd#)
   $20 CASE ( openfile) X-OPEN-FILE     ESAC
   $21 CASE ( close)    X-CLOSE-FILE    ESAC
   $22 CASE ( read)     X-READ-FILE     ESAC
   $23 CASE ( write)    X-WRITE-FILE    ESAC
   $24 CASE ( seek)     X-SEEK          ESAC
   $25 CASE ( create)   X-CREATE        ESAC
   $26 CASE ( delete)   X-DELETE        ESAC
   $2D CASE ( listfile) X-LIST-FILE     ESAC
   $2E CASE ( list)     X-LIST          ESAC
   $2F CASE ( rdline)   X-READ-LINE     ESAC
   $30 CASE ( dos cmd)  X-COMMAND       ESAC
   $FF CASE ( exit)     BYE             ESAC

   HEX U. ABORT" unknown function" ;

: REMOTE
   RCV? IF
      RCV ?DUP IF EMIT EXIT THEN
      RCV HOST-COMMAND
   THEN ;

: TERM
   INITIALIZE
   BEGIN
      KEYBOARD
      REMOTE
   AGAIN ;

\ ----------

: WHO   ." pc " ;

: READY
   HELP
   SS@ $10 - FLIP $80 +   COUNT EVALUATE  TERM ;

SAVE-SYSTEM TERM.EXE
(BYE)

