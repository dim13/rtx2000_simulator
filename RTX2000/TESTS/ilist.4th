
\ Generate a disassembly of all instructions

EMPTY

: xy  " dos xy ilist.4" evaluate ;

\ Constants for 2010 AppForth, from disassembling the word UN
: UN-ONE    $1345 , ; IMMEDIATE
: LOCATION  $0E71 , ; IMMEDIATE

: dis-asm  ( n -- )  \ uses address $9000
  LOCATION @ !
  UN-ONE
 ;

: .DIS-ASM  ( n -- )
  DUP S>D <# # # # # #> TYPE  ."  " DIS-ASM CR
  13 for -1 FOR NEXT next ;

: MAKE-LIST
  HEX cr cr
  $9000 LOCATION !
  0 .DIS-ASM
  $FFFF $7FFF DO  I  .DIS-ASM  LOOP
  $FFFF .DIS-ASM
  BYE ;

.( type in: MAKE-LIST)
