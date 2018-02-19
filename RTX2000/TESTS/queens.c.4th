\ /* queens.c */
\ GNU C 2020/3000

EMPTY
: XY " DOS XY queens.c.4th" EVALUATE ;

DECIMAL
load gnutool.4th


VARIABLE tries   4   CELL- ALLOT

#REGS 100 - REG-ADDR $FFC0 AND  UBR!

64 frame_size !
: do_error
 ." Error in Queens." cr
   ;

64 frame_size !
: Try

 [ 2 ] MEM_ARG@
 [ 3 ] MEM_ARG@

 1
 tries
 +!

 0
 5_pick
 !

 0

 5_pick
 @
 [ 0010 ] BRANCHNZ

 [ 009 ] LABEL
 0_pick
 8
 -
 [ 004 ] BRANCHZ

 1
 +

 0
 6_pick   !

 0_pick
 2*
 4_pick  +
 @
 [ 003 ] BRANCHZ

 6_PICK
 1_pick   +
 0_pick
 2*
 6_pick   +
 @
 [ 103 ] BRANCHZ

 7_PICK
 2_pick
 -
 0_pick
 2*
 5_pick   +
 14
 +
 @
 [ 203 ] BRANCHZ

 8_pick
 2*
 4_pick   +
 3_pick  SWAP
 !

 2_pick
 2*
 6_pick   +
 [ 0 ] LIT_SWAP
 !

 1_pick
 2*
 7_pick   +
 [ 0 ] LIT_SWAP
 !

 0_pick
 2*
 5_pick   +
 14
 +
 0
 SWAP !

 8_pick
 7
 <=
 [ 006 ] BRANCHZ

 10 U!
  9 U!
  5 U!
 [ 6 ] DUP_U!
 [ 3 ] MEM_ARG!
 [ 2 ] DUP_U!
 [ 2 ] MEM_ARG!
  3 U!
  4 U!
  7 U!
 [ 8 ] DUP_U!

 1
 +

 7 U@
 4 U@
 3 U@

 -64 FP+!
  recurse   64 FP+!

 8 U@  7 U@  4 U@  3 U@  2 U@  6 U@  5 U@

 5_pick
 @
 [ 303 ] BRANCHNZ

 0_pick
 2*
 4_pick   +
 [ -1 ] LIT_SWAP
 !

 9 U@
 2*
 5_pick   +
 [ -1 ] LIT_SWAP
 !

 10 U@
 2*
 2 U@  +
 14
 +
 -1
 SWAP !

 [ 403 ] BRANCH

 [ 006 ] LABEL

 -1
 8_pick   !

 [ 203 ] LABEL
 DROP

 [ 103 ] LABEL
 DROP

 [ 003 ] LABEL

 [ 303 ] LABEL

 [ 403 ] LABEL
 5_pick
 @

 [ 009 ] BRANCHZ

 [ 0010 ] LABEL

 [ 004 ] LABEL
  drop
  drop
  drop
  drop
  drop
  drop
  drop
   ;

192 frame_size !
: Doit

 -7
 2 U!

 [ 0017 ] LABEL

 2 U@
 0_pick
 0>
 [ 0014 ] BRANCHZ

 0_pick
 8
 <=
 [ 0114 ] BRANCHZ

 0_pick
 2*
 UBR@ +
 [ -1 ] LIT_SWAP
 28
 -
 !
 [ 0014 ] LABEL
 [ 0114 ] LABEL

 0_pick
 1
 >
 [ 0015 ] BRANCHZ
 0_pick
 2*
 UBR@ +
 [ -1 ] LIT_SWAP
 64
 -
 !

 [ 0015 ] LABEL
 0_pick
 7
 <=
 [ 0016 ] BRANCHZ

 0_pick
 2*
 UBR@ +
 [ -1 ] LIT_SWAP
 82
 -
 !
 [ 0016 ] LABEL

 1
 +
 [ 2 ] DUP_U!

 16
 >
 [ 0017 ] BRANCHZ

 [ 0019 ] LABEL

 UBR@
 96
 -
 [ 2 ] MEM_ARG!
 UBR@
 116
 -
 [ 3 ] MEM_ARG!
 1
 UBR@
 120
 -
 UBR@
 64
 -
 UBR@
 28
 -

 -192 FP+!
   Try
 192 FP+!

 [ -62 ] MEM_ARG@
 [ 0018 ] BRANCHNZ
 -192 FP+!
   do_error
 192 FP+!
 1000
 tries
 +!
 EXIT  [ 0018 ] LABEL
   ;

64 frame_size !
: main
#REGS 100 - REG-ADDR $FFC0 AND  UBR!

 1
 [ 0025 ADD_INDEX ] >R

 [ 0025 ] LABEL

 0
 tries
 !

 -64 FP+!
   Doit
 64 FP+!

 tries
 @
 113
 -
 [ 0023 ] BRANCHZ
 -64 FP+!
   do_error
 64 FP+!
 [ 0023 ] LABEL
 R>
 1
 +
 DUP_>R
dup . 2500
 U>
 [ 0025 ] BRANCHZ
 [ 0025 DROP_INDEX ] R>DROP
 EXIT  [ 0026 ] LABEL
   ;

.( max 2500) cr
