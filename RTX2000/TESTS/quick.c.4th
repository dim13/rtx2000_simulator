\ /* quick.c */
\ GNU C  2020/3000

EMPTY
: XY " DOS XY quick.c.4th" EVALUATE ;

DECIMAL
load gnutool.4th

#REGS 100 - REG-ADDR $FFC0 AND  UBR!

VARIABLE seed   4   CELL- ALLOT

VARIABLE top   4   CELL- ALLOT
VARIABLE littlest   4   CELL- ALLOT
VARIABLE biggest   4   CELL- ALLOT
VARIABLE sortlist   10004   CELL- ALLOT

: .DATA
  1000 2 DO I SORTLIST + @ .  2 +LOOP ;

: do_error
   ." Error in Quick." cr
   ;

 64 FRAME_SIZE !
: Initrand
 9219
 seed
 !
   ;

 64 FRAME_SIZE !
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

 64 FRAME_SIZE !
: Initarr

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

 32668
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
 5000
 U>
 [ 0011 ] BRANCHZ
 [ 0011 DROP_INDEX ] R>DROP

 EXIT  [ 0012 ] LABEL
   ;

 64 FRAME_SIZE !
: Quicksort

 1_PICK
 1_PICK
 1_PICK
 1_PICK    +
 0_pick
 0<

 [ 0014 ] BRANCHZ

 1
 +
 [ 0014 ] LABEL

 0_pick
 -2
 AND
 6_pick     +
 @

 [ 0015 ] LABEL

 3_pick
 2*
 7_pick    +
 @
 1_pick
 <

 [ 0028 ] BRANCHZ

 [ 0020 ] LABEL
 3_pick
 1
 +
 4_PUT
 3_pick
 2*
 7_pick     +
 @
 1_pick
 >=
 [ 0020 ] BRANCHZ

 [ 0028 ] LABEL

 2_pick

 2*
 7_pick    +
 @
 1_pick
 >
 [ 0027 ] BRANCHZ

 [ 0023 ] LABEL
 2_pick
 1
 -
 3_PUT
 2_pick
 2*
 7_pick    +
 @
 1_pick
 <=
 [ 0023 ] BRANCHZ

 [ 0027 ] LABEL

 3_PICK
 3_pick
 <=
 [ 0017 ] BRANCHZ

 3_pick
 2*
 7_pick     +
 @

 4_pick
 2*
 8_pick     +
 4_pick
 2*
 9_pick    +
 @
 SWAP
 !

 3_pick
 2*
 8_pick    +
 !

 3_pick
 1
 +
 4_PUT

 -1
 3_pick     +
 3_PUT

 [ 0017 ] LABEL

 3_PICK
 3_pick
 >

 [ 0015 ] BRANCHZ

 drop
 drop
 5 U!
 2 U!
 3 U!
 SWAP 7 U!
 [ 6 ] DUP_U!

 5 U@
 <
 [ 0025 ] BRANCHZ
 7 U@
 6 U@
 5 U@

 -64 FP+!
  recurse  64 FP+!

 [ 0025 ] LABEL

 2 U@
 3 U@
 <
 [ 0026 ] BRANCHZ
 7 U@
 2 U@
 3 U@

 -64 FP+!
 recurse  64 FP+!
 EXIT  [ 0026 ] LABEL
   ;

 64 FRAME_SIZE !
: main
#REGS 100 - REG-ADDR $FFC0 AND  UBR!

 0
 2 U!
 [
 sortlist
 2
 +
 ] LITERAL
 3 U!

 [ 0035 ] LABEL

 -64 FP+!
   Initarr
 64 FP+!

 sortlist
 1
 5000

 -64 FP+!
   Quicksort
 64 FP+!

 3 U@
 @
 littlest
 @
 -
 [ 0034 ] BRANCHNZ
 [
 sortlist
 10000
 +
 ] LITERAL
 @
 biggest
 @
 -
 [ 0032 ] BRANCHZ
 [ 0034 ] LABEL

 -64 FP+!
   do_error
 64 FP+!

 [ 0032 ] LABEL
 2 U@
 1
 +
 [ 2 ] DUP_U!
dup .  49
 >
 [ 0035 ] BRANCHZ

 EXIT  [ 0036 ] LABEL
   ;

.( max 49) cr
