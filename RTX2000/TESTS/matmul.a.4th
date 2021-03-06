\ /* matmul.c */
\ CESYS compiled code

EMPTY

: XY " DOS XY matmul.a.4th" EVALUATE ;

DECIMAL

load gnutool.4th
 100 REG-ADDR $FFC0 AND  UBR!

VARIABLE seed   4   CELL- ALLOT
VARIABLE imr   3364   CELL- ALLOT
VARIABLE imb   3364   CELL- ALLOT
VARIABLE ima   3364   CELL- ALLOT

: Initrand
  $2403 seed ! ;

: Rand
  seed @  $51d *   $3619 +   seed ! 
  seed   @ ;

: Initmatrix
  >r  $1 2 u!

[ 41 ] label
  2 u@  $28  <= 1 and 
  [ 42 ] branchz

  $1 3 u!

[ 44 ] label
  3 u@  $28  <= 1 and 
  [ 45 ] branchz

  17 g@ 64 + 17 g! 
  Rand
  17 g@ 64 - 17 g! 
  1 u!
  1 u@    1 u@ $78 /   $78 *  - 
  $ffc4 + r@   2 u@   $52  * + 
  3 u@ 2* + !

[ 46 ] label
  3 u@ $1 + 3 u! 
  [ 44 ] branch

[ 45 ] label
[ 43 ] label
  2 u@ $1 + 2 u! 
  [ 41 ] branch

[ 42 ] label
  r> drop ;


: Innerproduct
  0 u!  1 u!  2 u!  3 u!  4 u! 
  $0  0 u@ !    $1 5 u!
[ 48 ] label
  5 u@   $28  <=  1 and 
  [ 49 ] branchz

  0 u@  @   1 u@   3 u@   $52 *  +
  5 u@  2* +  @   2 u@ 5 u@ $52  * + 4 u@
  2* + @ *   + 0 u@ !

[ 50 ] label
  5 u@ $1 + 5 u! 
  [ 48 ] branch

[ 49 ] label
  ;

: main
 100 REG-ADDR $FFC0 AND  UBR!
  $1 2 u!

[ 52 ] label
  $19 2 u@ 
  dup .
  > 1 and 
  [ 53 ] branchz

  17 g@ 64 + 17 g! 
  Initrand
  17 g@ 64 - 17 g! 

  ima 
  17 g@ 64 + 17 g! 
   Initmatrix
  17 g@ 64 - 17 g! 

  imb 
  17 g@ 64 + 17 g! 
   Initmatrix
  17 g@ 64 - 17 g!
  $1 0 u!

[ 55 ] label
  0 u@ $28  <= 1 and 
  [ 56 ] branchz

  $1 1 u!
[ 58 ] label
  1 u@ $28  <= 1 and 
  [ 59 ] branchz

  1 u@ 0 u@ imb
  ima imr 0 u@ $52  * + 1 u@ 2* +
  17 g@ 64 + 17 g! 
   Innerproduct 
  17 g@ 64 - 17 g!

[ 60 ] label
  1 u@ $1 + 1 u! 
  [ 58 ] branch

[ 59 ] label
[ 57 ] label
  0 u@ $1 + 0 u! 
  [ 55 ] branch

[ 56 ] label
[ 54 ] label
  2 u@ $1 + 2 u! 
  [ 52 ] branch

[ 53 ] label
  ;

.( max ) $19 . cr
