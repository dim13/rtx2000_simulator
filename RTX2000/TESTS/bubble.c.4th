\ /* bubble.c */
\ GNU C 2020/3000

EMPTY
: XY " DOS XY bubble.c.4th" EVALUATE ;

DECIMAL
load gnutool.4th

VARIABLE seed   4   CELL- ALLOT
VARIABLE top   4   CELL- ALLOT
VARIABLE littlest   4   CELL- ALLOT
VARIABLE biggest   4   CELL- ALLOT
VARIABLE sortlist   10004   CELL- ALLOT

: .DATA
  1000 2 DO I SORTLIST + @ .  2 +LOOP ;

#REGS 100 - REG-ADDR $FFC0 AND  UBR!

: do_error
 ." Error3 in Bubble."  CR
   ;

: Initrand
 9219
 seed
 !
   ;

: Rand
 seed
 @
 1309
 *
 13849
 +
 seed
 TUCK_!
   ;

: bInitarr

   Initrand

 0
 biggest
 !
 0
 littlest
 !

 1
 [ 0011 ADD_INDEX ] >R

 [ 0011 ] LABEL

   Rand

 32767
 -

 [ 0011 ]  INDEX
 2*
 [ sortlist ] SYMBOL_+

 !

 [ 0011 ] INDEX
 2*
 [ sortlist ] SYMBOL_+
 @
 biggest
 @
 >
 [ 008 ] BRANCHZ
 [ 0011 ]  INDEX           2*
 [ sortlist ] SYMBOL_+
 @
 biggest
 !
 [ 007 ] BRANCH

 [ 008 ] LABEL
 [ 0011 ]  INDEX
 2*
 [ sortlist ] SYMBOL_+
 @
 littlest
 @
 <
 [ 107 ] BRANCHZ
 [ 0011 ]  INDEX
 2*
 [ sortlist ] SYMBOL_+
 @
 littlest
 !
 [ 007 ] LABEL
 [ 107 ] LABEL

 R>
 1
 +
 DUP_>R
 500
 U>
 [ 0011 ] BRANCHZ
 [ 0011 DROP_INDEX ] R>DROP

 EXIT  [ 0012 ] LABEL
   ;

: main
#REGS 100 - REG-ADDR $FFC0 AND  UBR!

 1
 2 U!

 [
 sortlist
 2
 +
 ] LITERAL
 3 U!

 [ 0026 ] LABEL

   bInitarr

 500
 top
 TUCK_!

 1
 >
 [ 0028 ] BRANCHZ

 [ 0023 ] LABEL

 1

 top
 @
 1_PICK
 >
 [ 0027 ] BRANCHZ

 [ 0022 ] LABEL

 0_PICK
 2*
 [ sortlist ] SYMBOL_+
 1_PICK
 2*
 3 U@  +
 @_SWAP
 @_SWAP
 >
 [ 0021 ] BRANCHZ

 0_PICK
 2*
 [ sortlist ] SYMBOL_+
 @

 1_PICK
 2*
 [ sortlist ] SYMBOL_+
 2_PICK
 2*
 3 U@  +
 @_SWAP
 !

 1_PICK
 2*
 3 U@  +
 !

 [ 0021 ] LABEL
 1
 +
 top
 @
 1_PICK
 <=
 [ 0022 ] BRANCHZ

DROP

 [ 0027 ] LABEL

 top
 @ -1 +  0_PICK top !
 1
 <=
 [ 0023 ] BRANCHZ

 [ 0028 ] LABEL

 3 U@
 @
 littlest
 @
 -
 [ 0025 ] BRANCHNZ
 [
 sortlist
 1000
 +
 ] LITERAL
 @
 biggest
 @
 -
 [ 0016 ] BRANCHZ
 [ 0025 ] LABEL
   do_error

 [ 0016 ] LABEL
 2 U@
 1
 +
 [ 2 ] DUP_U!
dup . 29
 >
 [ 0026 ] BRANCHZ

 EXIT  [ 0029 ] LABEL
   ;

.( max 29) cr
