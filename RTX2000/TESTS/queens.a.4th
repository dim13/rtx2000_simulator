\ /* queens.c */
\ CESYS compiled version

EMPTY
: XY " DOS XY queens.a.4th" EVALUATE ;

DECIMAL
load gnutool.4th

VARIABLE tries   4   CELL- ALLOT

 100 REG-ADDR $FFC0 AND  UBR!

: do_error  ." Error in Queens." cr  ;

: Try
  0 u! 1 u! 2 u! 3 u! 4 u! 5 u!
  tries @  $1 +  tries !
  $0 6 u!
  $0 1 u@ !

[ 41 ] label
  1 u@ @  0=   1 and 
  dup  [ 43 ] branchz
  drop 

  6 u@ $8  <> 1 and
[ 43 ] label
  [ 42 ] branchz

  6 u@ $1 + 6 u!
  $0 1 u@ !
  3 u@ 6 u@ 2* + @ dup
  [ 45 ] branchz
  drop

  2 u@ 0 u@ 6 u@ + 2* + @

[ 45 ] label
  dup
  [ 46 ] branchz
  drop
  4 u@ 0 u@ 6 u@ - $7 + 2* + @

[ 46 ] label
  [ 44 ] branchz
  6 u@ 5 u@ 0 u@ 2* + !
  $0 3 u@ 6 u@ 2* + !
  $0 2 u@ 0 u@ 6 u@ + 2* + !
  $0 4 u@ 0 u@ 6 u@ - 
  $7 + 2* + ! $8 0 u@
  > 1 and
  [ 47 ] branchz

  5 u@ 4 u@ 3 u@ 2 u@ 1 u@ 0 u@ $1 +
  17 g@ 64 + 17 g!
RECURSE   17 g@ 64 - 17 g!
  1 u@ @  0= 1 and 
  [ 48 ] branchz

  $ffff 3 u@ 6 u@ 2* + !
  $ffff 2 u@ 0 u@ 6 u@ + 2* + !
  $ffff 4 u@ 0 u@ 6 u@ - $7 + 2* + !

[ 48 ] label
  [ 49 ] branch

[ 47 ] label
  $ffff 1 u@ !

[ 49 ] label
[ 44 ] label
  [ 41 ] branch

[ 42 ] label ;


: Doit
  $fff9 0 u!

[ 51 ] label
  0 u@ $10  <= 1 and
  [ 52 ] branchz

  $1 0 u@  <= 1 and dup
  [ 54 ] branchz
  drop

  0 u@ $8  <= 1 and
[ 54 ] label
  [ 53 ] branchz

  $ffff 4 17 g@ + 0 u@ 2* + !

[ 53 ] label
  $2 0 u@  <= 1 and
  [ 55 ] branchz

  $ffff 22 17 g@ + 0 u@ 2* + !

[ 55 ] label
  0 u@ $7  <= 1 and
  [ 56 ] branchz

  $ffff 56 17 g@ + 0 u@ $7 + 2* + !

[ 56 ] label
  0 u@ $1 + 0 u!
  [ 51 ] branch

[ 52 ] label
  86 17 g@ +
  56 17 g@ +
  4 17 g@ +
  22 17 g@ +
  2 17 g@ +
  $1 
  17 g@ 128 + 17 g!
    Try
  17 g@ 128 - 17 g!
  1 u@  0= 1 and 
  [ 57 ] branchz

  17 g@ 128 + 17 g!
    do_error
  17 g@ 128 - 17 g!
  tries @ $3e8 + tries !

[ 57 ] label ;

: main
 100 REG-ADDR $FFC0 AND  UBR! $1 0 u!

[ 59 ] label
  0 u@
dup .
  $9c4  <= 1 and
  [ 60 ] branchz

  $0 tries !
  17 g@ 64 + 17 g!
    Doit
  17 g@ 64 - 17 g!
  tries @ $71  <> 1 and
  [ 62 ] branchz

  17 g@ 64 + 17 g!
    do_error
  17 g@ 64 - 17 g!

[ 62 ] label
[ 61 ] label
  0 u@ $1 + 0 u!
  [ 59 ] branch

[ 60 ] label ;

.( max ) $9c4 . cr
