\ /* bubble.c */
\ GNU C for RTX 2000

EMPTY
: XY " DOS XY bubble.b.4th" EVALUATE ;

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

 -64 FP+!
   Initrand
 64 FP+!

 0
 biggest
 !
 0
 littlest
 !

 1
 [ 0011 ADD_INDEX ] >R

 [ 0011 ] LABEL

 -64 FP+!
   Rand
 64 FP+!

 [ 0011 ]  INDEX
 2*
 [ sortlist ] SYMBOL_+
 SWAP
 32767
 -
 SWAP !

 [ 0011 ]  INDEX
 2*
 [ sortlist ] SYMBOL_+
 @
 biggest
 @
 >
 [ 008 ] BRANCHZ
 [ 0011 ]  INDEX
 2*
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

 -64 FP+!
   bInitarr
 64 FP+!

 500
 top
 TUCK_!

 1
 >
 [ 0028 ] BRANCHZ

 [ 0023 ] LABEL

 1

 top
 @_SWAP
 [ 4 ] DUP_U!
 >
 [ 0027 ] BRANCHZ

 [ 0022 ] LABEL

 4 U@
 2*
 [ sortlist ] SYMBOL_+
 4 U@
 2*
 3 U@  +
 @_SWAP
 @_SWAP
 >
 [ 0021 ] BRANCHZ

 4 U@
 2*
 [ sortlist ] SYMBOL_+
 @

 4 U@
 2*
 [ sortlist ] SYMBOL_+
 4 U@
 2*
 3 U@  +
 @_SWAP
 !

 4 U@
 2*
 3 U@  +
 !

 [ 0021 ] LABEL
 4 U@
 1
 +
 top
 @_SWAP
 [ 4 ] DUP_U!
 <=
 [ 0022 ] BRANCHZ

 [ 0027 ] LABEL

 -1
 top
 +!
 top
 @
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
 -64 FP+!
   do_error
 64 FP+!

 [ 0016 ] LABEL
 2 U@
 1
 +
 [ 2 ] DUP_U!
dup .
 29
 >
 [ 0026 ] BRANCHZ

 EXIT  [ 0029 ] LABEL
   ;

.( max 29)
