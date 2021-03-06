\ ---------- Terminal package for AppForth

\ COPYRIGHT 1990 HARRIS CORPORATION  ALL RIGHTS RESERVED
\ Tue  10-09-1990  14:21:08

ONLY FORTH ALSO DEFINITIONS

: ON   -1 SWAP ! ;
: OFF   0 SWAP ! ;
: NOT   0= ;
: H+!   DUP H@ ROT + SWAP H! ;

CODE (BYE)
        $20 INT
        END-CODE

VARIABLE 'BYE

: ?CTLC
   $41A C@
   DUP $1E = IF  DROP $3E  THEN
   2- $400 + C@
   3 = IF   'BYE @EXECUTE  THEN ;

: LSLN ( n # -- n )
   FOR AFT  2*  THEN NEXT ;

: LSRN ( n # -- n )
   FOR AFT  U2/  THEN NEXT ;

\ ----------

VARIABLE BUGGY
VARIABLE LOGGING
VARIABLE LHANDLE

\ ---------- serial interrupt service

$FFF CONSTANT /BUF

VARIABLE COM#               \ the com port base address
VARIABLE INTO-BUF           \ index of where to put next char into buf
VARIABLE OUTOF-BUF          \ where to get next char from buf

CREATE BUF  /BUF 1+ ALLOT   \ the data buffer itself

: INIT-BUFFER
   0 INTO-BUF !  0 OUTOF-BUF !
   BUF /BUF 1+ ERASE ;

\ ----------

CREATE SERIAL-INTERRUPT   ASSEMBLER ALSO

                   AX   PUSH  \
                   BX   PUSH  \ save affected regs
                   DX   PUSH  \
                   DS   PUSH  \
                CS AX   MOV   \
                AX DS   MOV   \ establish addressing
            COM# ) DX   MOV   \ get com port number
        INTO-BUF ) BX   MOV   \ where in buffer
                   BX   INC   \ increment
        BX INTO-BUF )   MOV   \ save pointer
            /BUF # BX   AND   \ pointer mod buf_size
                DX AL   IN    \ read character
          AL BUF [BX]   MOV   \ into ring buffer
             $20 # AL   MOV   \ send EOI to 8259
             $20 # AL   OUT   \
                   DS   POP   \
                   DX   POP   \ restore registers
                   BX   POP   \
                   AX   POP   \
                        IRET
                        END-CODE

ONLY FORTH ALSO DEFINITIONS

\ ---------- Com port interface

VARIABLE IRQ-MASK   ( irq mask for the selected com port)
VARIABLE INT-#      ( interrupt number for the com port)

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

\ : RCV@ ( - char)
\    OUTOF-BUF @ /BUF AND BUF + C@ ;
CODE RCV@ ( -- char )
        DX PUSH         \ SAVE TOS
        BX PUSH         \
        CS:                     \ ALL DATA IS IN THE CODE SEGMENT
        OUTOF-BUF ) BX MOV      \ GET THE OFFSET
        /BUF # BX AND           \ BX MOD BUFSIZE
        CS:                     \
        BUF [BX] BL MOV         \ GET CHAR
        BH BH XOR               \ ZERO
        DX DX XOR               \
        NEXT                    \
        END-CODE

\ : RCV? ( - flag)
\    INTO-BUF @ OUTOF-BUF @ <> ;
CODE RCV? ( -- flag )
        DX PUSH
        BX PUSH
        BX BX XOR
        CS:
        INTO-BUF ) AX MOV
        CS:
        OUTOF-BUF ) AX CMP
        1 L# JE
        BX DEC
1 L:    BX DX MOV
        NEXT
        END-CODE


: RCV ( - char)
   BEGIN ?CTLC RCV? UNTIL  1 OUTOF-BUF H+! RCV@ ;

: #RCV ( - n)
   RCV RCV $100 * + ;

: RCVS ( a #)
   FOR AFT  RCV OVER C!  1+  THEN NEXT DROP ;

\ ---------- 8250 output routines

CODE _xmt ( char -- )
        CS: COM# ) DX   MOV   \ get com port number
               5 # DX   ADD   \ point to line status reg
1 L:            DX AL   IN    \ sample status
             $20 # AL   AND   \
                 1 L#   JZ    \ until xmtr ready
               5 # DX   SUB   \ point back to data register
                BX AX   MOV   \ get char
                DX AL   OUT   \ SEND CHAR
                   BX   POP
                   DX   POP
                        NEXT
                        END-CODE

: XMT   ?CTLC  _xmt ;

: #XMT ( n)
   DUP XMT 256 / XMT ;

: XMTS ( a #)
   FOR AFT  C@+ XMT  THEN NEXT DROP ;

\ ---------- Interrupt vector management

: INSTALLED? ( -- flag )
   INT-VEC @  SERIAL-INTERRUPT = ;

: SET-VECTOR
   INSTALLED? NOT IF
      INT-VEC @  OLD-VEC !
      SERIAL-INTERRUPT INT-VEC !
   THEN ;

: RESTORE-VECTOR
   INSTALLED? IF
      OLD-VEC @  INT-VEC !
   THEN ;

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
   $021 PC@                 \ read 8259 int mask
   IRQ-MASK @ INVERT AND    \ turn on desired level
   $021 PC!  ;

: MASK-8259
   $021 PC@        \ read 8259 int mask
   IRQ-MASK @ OR   \ turn off this level
   $021 PC! ;      \ write mask back to 8259

: INSTALL ( interrupt service routines)
   DISABLE
      INIT-8250 ENABLE-8250
      SET-VECTOR
      UNMASK-8259
   ENABLE
   INIT-BUFFER ;

: REMOVE ( interrupt service routines)
   DISABLE
      MASK-8259
      INIT-8250 DISABLE-8250
      RESTORE-VECTOR
   ENABLE ;

\ ---------- simple, stupid terminal program

: OVERFLOW? ( -- flag )
   INTO-BUF @ OUTOF-BUF @ -  /BUF > ;

: ALTERNATE-COM
   COM# @  16 XOR  COM# ! ;

: INITIALIZE
   INSTALLED? NOT IF
      ALTERNATE-COM  DISABLE-8250       \ since 1&3, 2&4 share interrupts
      ALTERNATE-COM  INSTALL
   THEN
   OVERFLOW? IF
      ." Buffer overflow cleared!"
      0 INTO-BUF !  0 OUTOF-BUF !
   THEN ;

\ ----------

ONLY FORTH ALSO DEFINITIONS  DOS ALSO

: CREATING-LOG
   " APPFORTH.LOG" CREATE-FILE
   ?DUP IF ( create successful)
      LOGGING !
      CR ." File APPFORTH.LOG created." CR
   ELSE
      CR ." Can't create log file."  CR
   THEN ;

: APPENDING-LOG
   " APPFORTH.LOG" OPEN-FILE
   ?DUP IF    ( already exists)
           DUP  LOGGING !  FILESIZE DROP ( seek end of file)
           CR ." File APPFORTH.LOG will be appended." CR
        ELSE  ( doesn't exist )
           CREATING-LOG
        THEN ;

: TOGGLE-LOG
   LOGGING @ IF
      LOGGING @ CLOSE-FILE   0 LOGGING !
      CR ." Log file closed." CR
   ELSE
      APPENDING-LOG
   THEN ;

ONLY FORTH ALSO DEFINITIONS

\ ----------

: SUSPEND
   CR ." ---- HOST ---- "  CR QUIT ;

: BYE
   REMOVE (BYE) ;

\ ----------

: HELP
   CR
   CR ." ╔══f1══╤══f2══╤══f3══╤══f4══╗   ╔══f5══╤══f6══╤══f7══╤══f8══╗   ╔══f9══╤══f10═╗"
   CR ." ║ help │ watch│  --  │  --  ║   ║  --  │  --  │  --  │  --  ║   ║+/-log│ exit ║"
   CR ." ╚══════╧══════╧══════╧══════╝   ╚══════╧══════╧══════╧══════╝   ╚══════╧══════╝"
   CR ;


: FUNCTIONS ( char)
       59 CASE (   f1)  HELP EXIT                    ESAC
       60 CASE (   f2)  BUGGY @ 0= BUGGY !           ESAC
       67 CASE (   f9)  TOGGLE-LOG                   ESAC
       68 CASE (  f10)  BYE                          ESAC
      107 CASE (  @f4)  SUSPEND                      ESAC
   0 XMT XMT ;
                                
: KEYBOARD
   KEY? IF
      KEY ?DUP IF XMT EXIT THEN
      KEY FUNCTIONS
   THEN ;

\ ---------- dos interface for remote

ONLY FORTH ALSO DEFINITIONS  DOS ALSO

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
   BUFF H@ $205C = IF  DROP 2  THEN
   DUP ( #line) #XMT -1 XMT
   BUFF SWAP
   BUGGY @ IF  CR DDUP TYPE THEN
   XMTS ;

: X-SKIP-LINES
   SPIN
   RCV ( handle) #RCV ( handle #)
   FOR AFT
      DUP PAD 127 ROT READ-LINE DDROP
   THEN NEXT
   0 XMT ;
               
\ ----------

: X-COMMAND
   #RCV HERE C!  HERE COUNT RCVS
   HERE  [COMMAND]
   0 XMT ;

\ ----------

ONLY FORTH ALSO DEFINITIONS  BROWSER ALSO

: X-LIST-FILE
   DONE-LISTING
   PAD 80 ERASE   PAD 1+ #RCV RCVS
   PAD $START-LISTING ( flag)
   ?DUP IF    1 LIST  DUP XMT XMT
        ELSE  0 XMT
        THEN ;

: X-LIST ( -- )
   #RCV
   'S @ 0= IF  0 XMT  EXIT  THEN
    AT? BOT-PART AT
    1 LINE# !  'S @ TOP !
    1- 0 MAX  +LINES  L
    -1 DUP XMT XMT  LINE# @ #XMT ;

: X-LISTING-DONE
   DONE ;

\ ----------

CODE @MS ( - n)
   DX PUSH
   BX PUSH
   $00 # AX MOV
   $1A INT
   DX BX MOV
   CX DX MOV
   NEXT
   END-CODE

\ ----------

: UNKNOWN ( fn -- )
   CR ." Unknown function "
   BASE @ >R  HEX 3 U.R ." H"  R> BASE !
   BEGIN
      ." (C)ontinue or (A)bort ? "
      KEY  $20 OR ( lower case!)
      [CHAR] c CASE  ."  Continue" CR  ESAC
      [CHAR] a CASE  ."  Abort"    BYE ESAC
               DROP  ."  What?"    CR
   AGAIN ;

\ ----------

: HOST-COMMAND ( cmd#)
   $20 CASE ( openfile) X-OPEN-FILE     ESAC
   $21 CASE ( close)    X-CLOSE-FILE    ESAC
   $22 CASE ( read)     X-READ-FILE     ESAC
   $23 CASE ( write)    X-WRITE-FILE    ESAC
   $24 CASE ( seek)     X-SEEK          ESAC
   $25 CASE ( create)   X-CREATE        ESAC
   $2B CASE ( donelist) X-LISTING-DONE  ESAC
   $2C CASE ( skiplins) X-SKIP-LINES    ESAC
   $2D CASE ( listfile) X-LIST-FILE     ESAC
   $2E CASE ( list)     X-LIST          ESAC
   $2F CASE ( rdline)   X-READ-LINE     ESAC
   $30 CASE ( dos cmd)  X-COMMAND       ESAC
   $33 CASE ( ms timer) @MS #XMT        ESAC
   $FF CASE ( exit)     BYE             ESAC
                        UNKNOWN ;

: LOG-EMIT
   DUP EMIT
   LOGGING @ IF
      SP@ 1 LOGGING @ [ DOS ] WRITE-FILE DDROP
   ELSE
      DROP
   THEN ;

\ ----------

: REMOTE
   RCV? IF
      RCV ?DUP IF LOG-EMIT EXIT THEN
      RCV HOST-COMMAND
   THEN ;

: TERM
   INITIALIZE
   BEGIN
      KEYBOARD
      REMOTE
   AGAIN ;

\ ----------

: SET-COM ( port# irqmask int# -- )
   REMOVE  INT-# !  IRQ-MASK !  COM# !  INITIALIZE ;

: COM1   $3F8 $10 $0C SET-COM ;
: COM2   $2F8 $08 $0B SET-COM ;
: COM3   $3E8 $10 $0C SET-COM ;
: COM4   $2E8 $08 $0B SET-COM ;

\ ----------

: COPYRIGHT
   CR
   CR ." COPYRIGHT 1990 HARRIS CORPORATION  ALL RIGHTS RESERVED"
   CR ." Rick VanNorman               Wed  10-10-1990  16:29:21"
   CR ;


: READY
   $80 CS+ COUNT EVALUATE
   PAGE COPYRIGHT TERM ;

\ ----------

COM1

' BYE  'BYE !

ONLY FORTH ALSO DEFINITIONS

SAVSYS TERM.EXE

