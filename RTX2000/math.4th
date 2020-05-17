\ Speedup notes
Current rated speed: about 15 KFLOPS for F+ and F* on 8 MHz 2000
This package is not completely tested, but seems reasonably
  operational.  The following are areas where we know things
  could be made faster:

DUM/MOD is not efficiently written.  This affects T/
None of the code uses MD or SR as temporary register.
   Using MD and SR could cut down on stack thrashing.
   TSWAP, TDUP, etc. are good examples where this could be used.
The trig functions, SQRT, etc. are built for accuracy, not
   speed.  You could probably find better algorithms to speed
   them up.

What you see is what you get -- this is not supported,
  nor is it now a Harris product.  2/26/90. PJK
( load entire package from high level source )
\ Rewritten by Phil Koopman for RTX 2000 / Forth-83
CR CR
.( RTX 2000 floating point, for use with RTXForth ) CR
.( Pre-release version, WYSIWYG  2/26/90 ) CR CR
.( Copyright 1990, Harris Semiconductor )  CR
.( By: Phil Koopman Jr. ) CR

DECIMAL 4 79 THRU  \ Floating point library
       80 85 THRU  \ Test routines       (optional)
       90 93 THRU  \ Demonstration code  (optional)
CR CR .( Done loading -- as easy as ) PI F.  CR




































( CELL SIZE ALIASES )
: CELL* 2* ;              MACRO
: CELL+ 2+ ;              MACRO
2 CONSTANT CELL-SIZE

: DDROP DROP DROP ;       MACRO
: DDUP  OVER OVER ;       MACRO
: D!    !+2 !+2 DROP ;    MACRO
: D+-  0< IF DNEGATE THEN ;
: DLITERAL  STATE @ IF SWAP [COMPILE] LITERAL
                  [COMPILE] LITERAL THEN ; IMMEDIATE

VARIABLE DPL  \ Looks like NUMBER doesn't support DPL
: SIGN  0<  IF 45 HOLD THEN ;
: ?DNEGATE  0<  IF  DNEGATE  THEN ;

( OTHER ALIASES )
DECIMAL
: >FLAG  ( n -- flag )  IF -1 EXIT THEN 0 ;

: DIGIT  ( c n1 -- n2 tf | ff )
  SWAP  ASCII 0  -
  DUP 0<      IF  2DROP  0 EXIT THEN
  DUP 9 > IF   [ ASCII A  ASCII 0 - 10 - ] LITERAL -
               DUP 10 <  IF  2DROP 0 EXIT  THEN THEN
  SWAP  OVER
  >   >FLAG ;





\ internal use only variables and holding places )
DECIMAL
VARIABLE TSUMH 24 ALLOT    ( division temp storage - remainder)
   TSUMH 8 + CONSTANT TSUML ( division temp storage - quotient)

VARIABLE TEMP-CARRY  ( temporary carry storage )

VARIABLE SIGDIG   ( number significant digits )
     7 SIGDIG !
CREATE DBASE_VAL  4 ALLOT

VARIABLE CONV_BUF 64 ALLOT




( shift/rotate operations  LSL  ASR  LSR )
DECIMAL
: LSL   ( n1 -- n2 )
  2* ;  MACRO

: ASR   ( n1 -- n2 )
  2/  ; MACRO

: LSR   ( n1 -- n2 )
  U2/ ; MACRO






( ADC  LSRN   c2/ 2*c  )
HEX     ( may be replaced with CODE definitions )
A005 UCODE c2/
A003 UCODE 2*c

: ADC  ( n1 n2 carry.in -- n3  carry.out )
  -1 + DROP  +c   0 -1 +c NOT ;

: LSRN   ( n1 count -- n2 )
  DUP 0>  IF  1- OF( U2/
          ELSE  DROP  THEN  ;

DECIMAL



( conversions   S>D  D>Q  D>S  M+  )
DECIMAL
: S>D   ( n -- d )   DUP 0<  ;

: D>Q   ( d -- q )
  S>D  DUP ;

: D>S   ( d -- n )
  DROP ;                MACRO

: M+  S>D D+ ;





( double stack ops  DOVER  DSWAP  DROT )
DECIMAL
: DOVER   ( d1 d2 -- d1 d2 d1 )
  2>R 2DUP 2R> 2SWAP ;

: DSWAP   ( d1 d2 -- d2 d1 )
  ROT >R ROT R> ;

: DROT  ( d1 d2 d3 -- d2 d3 d1 )
  2>R 2SWAP 2R> 2SWAP ;






( double precision stack ops  D@  D>R  DR>  DR@  )
DECIMAL     ( may be replaced with CODE definitions )
: D@   ( addr -- d )     ( MVP-FORTH UTILITY )
   @+2 @+2 DROP SWAP ;

: D>R   ( d -- )
  COMPILE >R  COMPILE >R NOP  ;  IMMEDIATE

: DR>  ( d -- )
  COMPILE R>  COMPILE R> NOP  ;   IMMEDIATE

: DR@   ( -- d )
\  R> R@  OVER >R  ;  MACRO  -- FIX CODE OPTIMIZER, THEN USE
 COMPILE R> COMPILE R@  COMPILE OVER  COMPILE >R NOP ; IMMEDIATE


( double precision stack ops  DPICK  DROLL )
DECIMAL
: DPICK   ( d1 .. dn count -- d1 .. dn dm )
\  DUP 0 <  IF  ." DPICK ARGUMENT < 0"  ABORT THEN
  1+ 2*  1- DUP 1+   PICK  SWAP PICK  ;

: DROLL   ( d1 .. dn count -- d1 ..<omit dm>.. dn dm )
\  DUP 0 <  IF  ." DROLL ARGUMENT < 0"  ABORT THEN
  1+ 2*  1- DUP 1+  ROLL  SWAP ROLL  ;







( D,  DCONSTANT DVARIABLE )
DECIMAL
: D,   ( d -- )
       ,  ,  ;

: DCONSTANT   ( d -- )  ( compiling )
              ( -- d )  ( executing )
  CREATE  D,
   DOES>  D@ ;

: DVARIABLE   ( -- )       ( compiling )
              ( -- addr )  ( executing )
  CREATE  2 CELL*  ALLOT ;



( D-  D+! )
DECIMAL
: D-   ( d1 d2 -- d3 )
  DNEGATE  D+  ;

: D+!   ( d1 addr -- )
  DUP >R  D@ D+  R> D!  ;









( double precision rotates/add  DADC  DRRC  DRLC )
HEX
A00D UCODE cD2/     A00E UCODE UD2/
A00B UCODE D2*c     A00C UCODE cUD2/

: DADC   ( d1 d2 carry.in -- d3 carry.out )
  -1 + DROP   >R  SWAP  >R  +c  R> R> +c   0 -1 +c NOT ;

: DRRC  ( d1 carry.in -- d2 carry.out )
  -1 + DROP   cD2/   0 -1 +c NOT ;

: DRLC   ( d1 carry.in -- d2 carry.out )
  -1 + DROP   D2*c   0 -1 +c NOT ;

DECIMAL

( double precision shifts  DLSR  DLSL  )
DECIMAL
: DLSR   ( d1 -- d2 )
   UD2/ ; MACRO

: DLSL   ( D1 -- D2 )
   D2*  ; MACRO









( double precision multiple shifts  DLSRN  DLSLN )
DECIMAL
: DLSRN   ( d1 n -- d2 )
  DUP 0>  IF   1-  OF( UD2/
          ELSE  DROP  THEN  ;

: DLSLN   ( d1 n -- d2 )
  DUP 0>  IF   1-  OF( D2*
          ELSE  DROP  THEN  ;







( quad precision store and fetch  Q!  Q@  )
DECIMAL
: Q!   ( q addr -- )
  DUP  >R  D!  R>  4 +  ( CELL+ CELL+ )  D! ;

: Q@   ( addr -- q )
  DUP  4 +  ( CELL+  CELL+)  D@  ROT  D@  ;









( QNEGATE )
DECIMAL
: QNEGATE     ( q1 -- -q1 )
  >R >R >R   -1 XOR  1 +
  R>  -1 XOR  0 +c
  R>  -1 XOR  0 +c
  R>  -1 XOR  0 +c  ;









( ?QNEGATE  QABS )
DECIMAL
: ?QNEGATE   ( q1 n2 -- q3 )
  0<  IF  QNEGATE  THEN  ;

: QABS   ( q1 -- q2 )
  DUP ?QNEGATE  ;









( QLSR  QLSL )
DECIMAL
: QLSR   ( q1 -- q2 )
  0 0 +  DROP  cD2/  >R >R  cUD2/  R> R> ;

: QLSL   ( q1 -- q2 )
  >R >R D2*  R> R> D2*c ;









( basic double multiplication  DUM* D* )
DECIMAL
: DUM*   ( ud1 ud2 -- uq3 )       ( D C B A -- CD*AB )
  ( adds 4 partial products to get result )
  OVER  4 PICK  UM*  SWAP >R >R   ( -- D C B A ) ( RS:-- B*D )
  >R ROT R@ SWAP R>  UM*          ( -- C B A A*D ) ( RS:-- B*D )
  SWAP R> + >R 0 +c >R 0 0 +c >R  ( -- C B A ) ( RS: -- QSUM)
  SWAP 2 PICK  UM*                ( -- C A B*C )  ( RS: -- QSUM)
  SWAP  R> -ROT R> SWAP R>   + >R  +c >R  0 +c >R
                                  ( -- C A )  ( RS: -- QSUM )
  UM*                             ( -- C*A )  ( RS: -- QSUM )
  SWAP  R> SWAP R> +  -ROT  +c  R>  R> SWAP DSWAP ;

: D*  ( d1 -- d2 )
  DUM* DDROP ;

( double precision unsigned division  DU/MOD )
HEX     ( may be replaced with CODE definitions )
: DUM/MOD   ( uq1 ud2 -- ud3 ud4 )
  D>R  TSUMH Q!  DR>  DDUP  DNEGATE  TSUMH D+!  21 >R
  BEGIN   TSUMH @  0<  R> 1- DUP >R
  WHILE  TSUMH Q@  QLSL  TSUMH Q!
     IF  DDUP
     ELSE  DDUP DNEGATE  1 TSUMH 6 + +!  THEN
     TSUMH  D+!  REPEAT
  R> DROP  TSUMH 4 + D@  2 PICK  0=  DRLC DROP  ROT
  IF DSWAP  TSUMH D@ D+
  ELSE  DSWAP DDROP   TSUMH D@  THEN    DSWAP ;

DECIMAL


( double precision mixed division DM/  D/MOD  D/ )
DECIMAL
: DM/   ( q1 d2 -- d3 d4 )
  2 PICK >R  D>R  QABS  R> R@  DABS  DUM/MOD
  R> R@  XOR D+-  DSWAP  R>  D+-  DSWAP  ;

: D/MOD   ( d1 d2 -- d3 d4 )
  D>R  D>Q  DR>  DM/  ;

: D/   ( d1 d2 -- d3 )
  D/MOD  DSWAP DDROP  ;





( floating point return stack operations  F>R  FR>  FR@  )

: F>R   ( f1 -- )
  COMPILE  >R  COMPILE >R  NOP ;  IMMEDIATE

: FR>   ( -- f1 )
  COMPILE R>   COMPILE R>  NOP ;  IMMEDIATE

: FR@   ( -- f1 )
\  R>  R@  OVER  >R  ;  MACRO
  COMPILE R> COMPILE R@ COMPILE OVER COMPILE >R NOP ; IMMEDIATE





( floating point aliases )

: F@           @+2 @+2  DROP  SWAP ;  MACRO
: F!           !+2  !+2 DROP ;        MACRO
: FDROP        DROP DROP ;            MACRO
: FDUP         OVER OVER ;            MACRO
: FSWAP        ROT >R ROT R> ;
: FOVER        2>R 2DUP 2R> 2SWAP ;
: FROT         2>R 2SWAP 2R> 2SWAP ;
: FPICK        DPICK  ;
: FROLL        DROLL  ;
: FCONSTANT    DCONSTANT  ;
: FVARIABLE    DVARIABLE  ;
: FLITERAL     [COMPILE] DLITERAL  ;   IMMEDIATE
: F,           D,  ;

( FABS  F0=  TABS  T0= )

: FABS   ( f1 -- f2 )
  LSL LSR  ;   \ Zero highest bit

: F0=   ( f1 -- flag )
  D2*   D0=  ;

: TABS   ( t1 -- t2 )
   >R LSL LSR  R>  ;

: T0=   ( t1 -- t1 flag )  ( Does not remove t1 from stack !!! )
  OVER LSL   IF  0
           ELSE  >R OVER R> SWAP  0=  THEN ;


( TDROP TNEGATE ?TNEGATE  TR> T>R )
HEX
: TDROP   ( t1 -- )
  DROP DROP DROP  ; MACRO

: TNEGATE   ( t1 -- t2 )
   SWAP  8000 XOR  SWAP  ;

: ?TNEGATE   ( t1 n2 -- t3 )
   8000 AND   ROT  XOR  SWAP  ;

: TR> COMPILE R> COMPILE R> COMPILE R> NOP ; IMMEDIATE
: T>R COMPILE >R COMPILE >R COMPILE >R NOP ; IMMEDIATE

DECIMAL

( TSWAP  TOVER  TDUP  T@  T! )
DECIMAL     ( may be replaced with CODE definitions )
: TDUP   ( t1 -- t1 t1 )
  >R >R  DUP R> SWAP OVER  R@ SWAP >R SWAP R> R> ;
: TSWAP   ( t1 t2 -- t2 t1 )
  >R >R SWAP >R SWAP >R SWAP  R> R> R> SWAP >R SWAP >R SWAP
  R> R> R>  SWAP >R SWAP >R SWAP R> R> ;
: TOVER   ( t1 t2 -- t1 t2 t1 )
  T>R TDUP TR> TSWAP ;

: T@   ( addr -- t1 )
  DUP  CELL+ F@  ROT @  ;

: T!   ( t1 addr -- )
  SWAP  OVER !  CELL+ D!  ;

( F>T )
HEX
: F>T   ( f1 -- t2 )
  DDUP  2* OR
  IF  \ non-zero
     \ Extract exponent
     DUP 7F80 AND
     ( 7 LSRN )  6 OF( U2/    7F -  >R  DUP >R
     7F AND  80 OR
     ( 7 DLSLN ) 6 OF( D2*
     R> R>  SWAP ?TNEGATE   EXIT
  ELSE  \ zero
    DDROP  0 0 0 EXIT
  THEN ;
DECIMAL

( 32-bit normalization of unsigned mantissa )
HEX
: UDNORMALIZE   ( ut1 -- ut2 )
  >R  DUP 0<
  IF  ( shift right )  DLSR R>  1+
  ELSE  DDUP D0=
     IF  ( zero )  R> DROP 0
     ELSE  ( shift left )
        BEGIN   DUP  4000 AND 0=
        WHILE  DLSL  R> 1- >R     REPEAT
     R>  THEN
  THEN  ;

DECIMAL


( T>F )
HEX
: T>F   ( t1 -- f2 )
  >R  DDUP  2* OR
  IF  \ non-zero              ( -- mant )  ( RS: -- exp )
     DUP >R      2* LSR      ( -- umant )  ( RS: -- exp sign )
     40. D+  DUP 0< IF  R> R> 1+ >R >R  UD2/  THEN  \ round
     ( 7 DLSRN ) 6 OF( UD2/   7F AND     \ Shift & mask mantissa
     R> 8000  AND  OR                               \ Apply sign
     R> 7F + ( 7 LSLN ) 6 OF( 2*  7F80 AND  OR  EXIT  \ exponent
  ELSE  R>  DDROP 0 EXIT THEN ;

DECIMAL



( SEPARATE2  T>RND )
HEX
: SEPARATE2   ( f1 f2 -- t1 t2 )
  F>R  F>T   FR>  F>T  ;

: T>RND  ( t1 -- d2 )
   01E -   DUP 0>  OVER  -1F <  OR
   IF   TDROP  0 0   EXIT
   ELSE   >R SWAP OVER  LSL LSR  R>   ( -- sgn um3 e3 )
      ABS ?DUP  IF    ( enough shifting to round )
                    1- DLSRN  1. D+  DLSR   THEN
      ROT ?DNEGATE EXIT
   THEN ;


DECIMAL
( T* )
DECIMAL
: T*   ( t1 t2 -- t3 )
   >R ROT R>  +   >R
   DUP >R SWAP >R  OVER >R  ROT >R  XOR 0<  R> R> R> R>
   D2* DSWAP  D2*
   DUM*   >R >R  DDROP  R> R>
   DUP 0<
   IF    ROT  DRRC  DROP     R>  1+  EXIT
   ELSE  DLSL  ROT  DRRC  DROP   R> EXIT
   THEN ;





( T+ )
DECIMAL
: T+   ( t1 t2 -- t3 )
  >R ROT >R    >R OVER R> SWAP OVER AND 2*
  IF  R> DUP R@ <  IF  R@ DOVER D>R  D>R  DSWAP DR> SWAP
                 ELSE  R> OVER >R  5 PICK  5 PICK D>R  THEN
    2 PICK  5 PICK  XOR 0< >R   - >R    ROT  2* LSR -ROT
    2* LSR   R> 32 MIN  DLSRN   DDUP OR 0=
    IF    DDROP DDROP  R> DROP   DR> R>   EXIT
    ELSE  R>  IF    DR> SWAP DROP 0<  IF DSWAP THEN
                    DNEGATE  0 DADC  0=   >R  DABS R>
              ELSE  D+  DR>  SWAP DROP 0<  THEN
     R> SWAP >R  UDNORMALIZE  R> IF TNEGATE EXIT THEN EXIT THEN
  ELSE   DUP 2*
    IF  D>R DDROP DR>  R> DROP R>  EXIT
    ELSE  DDROP  R> R> DROP  EXIT  THEN THEN ;
( T/ )
DECIMAL
: T/   ( t1 t2 -- t3 )
  ( check for divide by zero )  OVER 2* 0=
  IF  TDROP TDROP  0 0 0  EXIT  ( result is zero )
  ELSE  >R  ROT  R>  2 PICK   5 PICK  XOR >R
    - >R   LSL LSR   DSWAP  LSL LSR  0 0 DSWAP
    QLSR  DROT   DUM/MOD   D>R  DDROP DR>
    R>  1- UDNORMALIZE
    R>  ?TNEGATE  EXIT
  THEN ;





( F+ F* F/  F2/ F2* )
HEX
: F+   ( f1 f2 -- f3 )
  SEPARATE2  T+ T>F  ;

: F*   ( f1 f2 -- f3 )
  SEPARATE2  T* T>F  ;

: F/   ( f1 f2 -- f3 )
  SEPARATE2  T/ T>F  ;

: F2/   ( f1 -- f2 )
  0080 -  ;
: F2*   ( f1 -- f2 )
  0080 +  ;
DECIMAL
( FNEGATE  T- F-  F+! T+! )
HEX
: FNEGATE   ( f1 -- f2 )
  DDUP OR  IF  8000 XOR EXIT   THEN  ;

: T-   ( t1 t2 -- t3 )
  SWAP 8000 XOR  SWAP  T+  ;

: F-   ( f1 f2 -- f3 )
  8000 XOR  F+  ;

: F+!   ( f1 addr -- )
  DUP  >R  F@ F+  R>  F!  ;

: T+!  ( t1 addr -- )
   DUP >R  T@ T+  R>  T! ;
( D>T N>T D>F N>F  T>D  )
HEX
: D>T   ( d1 -- t2 )   ( floats the integer value )
  DUP >R  DABS  01E UDNORMALIZE   R>  ?TNEGATE  ;
: N>T  S>D D>T ;
: D>F   ( d1 -- f2 )
   D>T  T>F  ;
: N>F   S>D D>F ;

: T>D   ( t1 -- d2 )
  01E -   DUP  0>   OVER  -1E <  OR
  IF  TDROP 0 0  EXIT
  ELSE   >R  SWAP OVER   LSL LSR  R>  ( -- sgn um3 e3 )
     ABS  DLSRN   ROT  ?DNEGATE  EXIT
  THEN ;
DECIMAL
( T>N F>D F>N N>F )
DECIMAL
: T>N  T>D DROP ;

: F>D   ( f1 -- d2 )
   F>T T>D  ;

: F>N   ( f1 -- n2 )
    F>D DROP  ;

: N>F   ( n1 -- f2 )
    S>D D>F  ;




( floating comparisons  F0< F0>   F= F< F> ?FNEGATE )
DECIMAL
: F0<      NIP 0< ;
: F0>      NIP 0> ;
: F=           D= ;
: F<           D< ;
: F>           D> ;

: ?FNEGATE   ( f1 n2 -- f3 )
       0<  IF FNEGATE  THEN ;






( FMIN  FMAX  )
DECIMAL
: FMIN   ( f1 f2 -- f3 )
  FOVER FOVER  F>  IF  FSWAP  THEN  FDROP  ;

: FMAX   ( f1 f2 -- f3 )
  FOVER FOVER  F<  IF  FSWAP  THEN  FDROP  ;









( integer & fractional portion  INT  TFRAC  FRAC  REM )
HEX
: INT   ( f1 -- f2 )
  F>T  DUP  01F <  IF  T>D D>T THEN   T>F  ;

: TFRAC   ( t1 -- t2 )
  DUP 01F <  IF  TDUP T>D D>T T-
             ELSE  TDROP 0 0 0  THEN  ;

: FRAC   ( f1 -- f2 )
  F>T TFRAC  T>F  ;

: REM   ( f1 f2 -- f3 )
   FOVER FOVER   F/   INT  F* F-  ;

DECIMAL
( floating point input  FCONVERT )
DECIMAL
: FCONVERT   ( f1 addr2 -- f3 addr4 )
  >R F>T   BASE @ 0 D>T  TSWAP R>
  BEGIN  1+ DUP >R  C@ BASE @ DIGIT
  WHILE  >R TOVER T*  R> 0 D>T  T+   DPL @ 1+
     IF  1 DPL +!  THEN      R>
  REPEAT  TSWAP TDROP T>F  R> ;








( floating point input  <FNUMBER> )
HEX
: <FNUMBER>   ( addr1 -- f2 )   CONV_BUF 20 CMOVE  CONV_BUF
  0 0 ROT  DUP 1+ C@  2D = 1 AND  DUP >R  +  -1 DPL !
  FCONVERT  DUP C@ BL >
  IF DUP C@ 2E =  0= ( NOT)  ABORT" NOT RECOGNIZED"
     0 DPL !  FCONVERT DUP C@ BL >  ABORT" NOT RECOGNIZED"
  THEN    DROP R>
  IF  FNEGATE  THEN     F>T     DPL @
  BEGIN   DUP 0>
  WHILE  >R  BASE @ 0 D>T  T/  R> 1-
  REPEAT         DROP T>F  ;

DECIMAL


( f# )
DECIMAL
: f#   ( -- f )  ( "state-smart" word )
  BL WORD  <FNUMBER>
  [COMPILE] FLITERAL  ;     IMMEDIATE

: F# [COMPILE] f# ; IMMEDIATE









( floating point input  TCONVERT )
DECIMAL
: TCONVERT   ( t1 addr2 -- t3 addr4 )
  >R        BASE @ 0 D>T  TSWAP R>
  BEGIN  1+ DUP >R  C@ BASE @ DIGIT
  WHILE  >R TOVER T*  R> 0 D>T  T+   DPL @ 1+
     IF  1 DPL +!  THEN      R>
  REPEAT  TSWAP TDROP       R> ;








( floating point input  <TNUMBER> )
HEX
: <TNUMBER>   ( addr1 -- t2 )  CONV_BUF 20 CMOVE CONV_BUF
  0 0 ROT  0 SWAP DUP 1+ C@  2D = 1 AND   DUP >R  +  -1 DPL !
  TCONVERT  DUP C@ BL >
  IF DUP C@ 2E =  0= ( NOT)  ABORT" NOT RECOGNIZED"
     0 DPL !  TCONVERT DUP C@ BL >  ABORT" NOT RECOGNIZED"
  THEN    DROP R>
  IF  TNEGATE  THEN              DPL @
  BEGIN   DUP 0>
  WHILE  >R  BASE @ 0 D>T  T/  R> 1-
  REPEAT         DROP  ;

DECIMAL


(  t# )
DECIMAL
: t#   ( -- f )  ( "state-smart" word )
  BL WORD  <TNUMBER>
  STATE @   IF
     >R  [COMPILE] DLITERAL R> [COMPILE] LITERAL
  THEN ;    IMMEDIATE









\ TSLOG2 calculation .5 <= x <= 1.0  Taylor series ln/ln2
DECIMAL
: TLOG2_R<x>  ( t1 -- t2 )   (  0.5 <= t1  <= 1 )
  TABS
  T0=  IF  EXIT  ( Error condition )  THEN
  TDUP   t# -1  T+      TSWAP t# 1  T+  T/
  TDUP  TDUP  T*  TDUP
  t# .1697288283 T*  TOVER T*
  t# .1923593388 T+  TOVER T*
  t# .2219530832 T+  TOVER T*
  t# .2623081893 T+  TOVER T*
  t# .3205988980 T+  TOVER T*
  t# .4121985831 T+  TOVER T*
  t# .5770780164 T+  TOVER T*
  t# .9617966939 T+        T*
  t# 2.885390082 T+        T* ;
\ TLOG2  high level word
DECIMAL
: TLOG2  ( t1 -- t2 )  \ Unrestricted range
  T0=  OVER 0< OR  DUP
  IF  ( Bad operation )   DROP TABS T0=  THEN
  IF  EXIT
  ELSE   >R    -1 TLOG2_R<x>  R>  1+  N>T  T+  EXIT
  THEN ;








\ Chebyshev 2**
DECIMAL
: T2**_R<x>  ( t1 -- t2 )  ( 0 <= t1 <= 1 )
  TABS  TDUP
  t# .000000144372690  T*   TOVER T*
  t# .000001225520044  T+   TOVER T*
  t# .000015369080350  T+   TOVER T*
  t# .000153951114300  T+   TOVER T*
  t# .00133339329836   T+   TOVER T*
  t# .0096181189820    T+   TOVER T*
  t# .055504110233     T+   TOVER T*
  t# .24022650684      T+   TOVER T*
  t# .69314718056      T+         T*
  t# 1.                T+  ;


\ T2**
DECIMAL
: T2**  ( t1 -- t2 )
  OVER 0<  >R    ( -- t )  ( RS: -- sgn )
  TABS  TDUP  T>N   DUP >R
  N>T  T-  T2**_R<x>  R> +   R>
  IF  \ if negative exponent, take reciprocal
    t# 1  TSWAP T/  EXIT
  THEN ;







( LOG2 2** )
DECIMAL
: LOG2   ( f1 -- f2 )
   F>T  TLOG2  T>F  ;

: 2**   ( f1 -- f2 )
  F>T  T2**  T>F  ;









( TLOGB  LOGB  F** )
DECIMAL
: TLOGB   ( t1 tbase -- t3 )   ( log to a base )
  TSWAP  TLOG2  TSWAP  TLOG2  T/  ;

: LOGB   ( f1 f2 -- f3 )
  SEPARATE2  TLOGB  T>F  ;

: F**   ( f1 f2 -- f3 )
  FSWAP  SEPARATE2  TLOG2  T*  T2**   T>F  ;






( LOG  LN  10**  E**  )
HEX
: LOG   ( f1 -- f2 )
  41200000.  ( f=10.0 )  LOGB  ;

: LN   ( f1 -- f2 )
  402DF854.  ( f=2.7182818 )   LOGB ;

: 10**   ( f1 -- f2 )
  41200000.  ( f=10.0 ) FSWAP  F**  ;

: E**   ( f1 -- f2 )
  402DF854.  ( f=2.7182818 )  FSWAP  F**  ;

DECIMAL

( ROOT  **2  1/X  EXP  )
DECIMAL
: ROOT   ( f1 f2 -- f3 )
  SEPARATE2 TSWAP  TLOG2  TSWAP T/  T2**  T>F  ;

: **2   ( f1 -- f2 )
  FDUP F*  ;

: 1/X   ( f1 -- f2 )
  f# 1  FSWAP F/  ;

: EXP   ( f1 n -- f2 )
  S>D D>F  BASE @ 0 D>F  FSWAP  F**  F*  ;



\ Base twiddling for higher speed numeric conversions
DECIMAL
: BASE!  ( n -- )  \ Use this instead of BASE ! for F>ME to work
  DUP BASE !  S>D
  1.  SIGDIG @  0 DO  DOVER D*  LOOP
  DBASE_VAL D!  DDROP ;

: SIGDIG! ( n -- ) \ Use this instead of SIGDIG !
  SIGDIG !   BASE @  S>D
  1.  SIGDIG @  0 DO  BASE @ S>D D*  LOOP
  DBASE_VAL D!  ;

: DECIMAL  10 BASE! ;
: HEX      16 BASE! ;
DECIMAL   \ Important -- execute DECIMAL here for initialization

\ Rounding for F>ME
DECIMAL
: ME_ROUND ( d1 e1 -- d2 e2 )
  \ rounds according to SIGDIG and BASE for printout
  >R
  DUP >R  DABS       \ save sign
  BASE @  2/  M+  BASE @ S>D  D/
  DBASE_VAL D@
  DOVER D>  IF                     R> ?DNEGATE R>     EXIT
          ELSE    BASE @ S>D  D/   R> ?DNEGATE R> 1+  EXIT
          THEN ;





\ F>ME Floating point to mantissa/exponent conversion for print
DECIMAL
: F>ME  ( t1 -- d2 n3 )
  F>T   T0=  IF  TDROP  0. 0  EXIT THEN
  OVER >R  ( sign )    TABS  BASE @ N>T
  TSWAP TOVER  TLOGB   TDUP  TFRAC
  TSWAP  T>N  2 PICK 0<
  IF   >R  t# 1.0 T+  R> 1-  THEN
  >R  SIGDIG @  N>T  T+  TSWAP
  TLOG2  T* T2**  T>D
  R> R@ SWAP >R   ?DNEGATE
  R> R> DROP
  ME_ROUND   ;



( exponent print  F.ER  F.E  )
HEX
: F.ER   ( f1 n2 -- )
  >R  F>ME   DUP >R ABS  S>D
  <# #S  DDROP  R> SIGN  BL HOLD
  50 HOLD  58 HOLD  45 HOLD  BL HOLD   DUP >R DABS
  SIGDIG @  1  DO  #  LOOP
  2E HOLD  #  R> SIGN  #>
  R>  OVER -  SPACES TYPE  ;

: F.E   ( f1 -- )
  0 F.ER  SPACE  ;

DECIMAL


( fixed point numeric printing  <F.>  F.XR  F.X )
HEX
: <F.>   ( d1 n2 -- addr3 n4 n5 )
  SIGDIG @ - 1+  NEGATE DUP  0 MAX  >R OVER >R
  >R  DABS   <#  R@ 0 MAX    ?DUP
  IF  0  DO  #  LOOP  THEN
  2E HOLD    R@ 0<
  IF  R@ ABS  0  DO  30 HOLD  LOOP  THEN
  R> DROP   #S  R> SIGN  #>   R>  ;

: F.XR   ( f1 n2 -- )
  >R F>ME  <F.> DROP  R> OVER -  SPACES TYPE  ;

: F.X   ( f1 -- )
  0 F.XR  SPACE  ;
DECIMAL
( aligned fixed point print  F.AR  F.A )
HEX
: F.AR   ( f1 n2 n3 -- )
  >R  0 MAX  >R  F>ME   SIGDIG @  OVER - 1-   R@ -  DUP 0>
  IF  SWAP >R  N>F  10**  F2/  F>D D+
     R>  <F.>  R> - -
     ELSE  DROP <F.>  R>   DDUP <
        IF  SWAP -  2 PICK 2 PICK +  OVER  30 FILL +
        ELSE  DDROP   THEN     THEN
  R>  OVER -  SPACES TYPE  ;

: F.A   ( f1 n2 -- )
  0 F.AR  SPACE  ;

DECIMAL

( smart floating point prints  F.R  F.  F?  )
HEX
: F.R   ( f1 n2 -- )
  >R  FDUP F>T   DUP 17 >  SWAP -4 <  OR
  IF  DDROP R>  F.ER
  ELSE  DDROP  F>ME  <F.>  DROP
  BEGIN  DDUP + 1- C@     30 =
  WHILE  1-  REPEAT
  R>  OVER -  SPACES TYPE  THEN  ;

: F.  ( FP# -- )
  0 F.R SPACE ;

: F?     F@ F. ;

DECIMAL
( SQRT  FACTORIAL )
DECIMAL
: SQRT   ( f1 -- f2 )
  FABS    F>T  TDUP
  ( initial approximation is f1/2 )     ASR 1-
  4 FOR  TOVER TOVER T/   T+  1-   NEXT
  TSWAP TDROP  T>F  ;

: FACTORIAL   ( f1 -- f2 )
  f# 1  FSWAP  F>N  ABS
  1+ 1 DO   I  N>F  F*   LOOP  ;





( PI  PI/2  PI/4  2*PI  RAD>DEG  DEG>RAD  TDEG>RAD )
DECIMAL
f# 3.14159265 FCONSTANT PI
PI   F2/ FCONSTANT PI/2
PI/2 F2/ FCONSTANT PI/4
PI   F2* FCONSTANT 2*PI

: RAD>DEG   ( f1 -- f2 )
  F>T  t# 57.29577951 T* T>F ;

: DEG>RAD   ( f1 -- f2 )
  F>T  t# 0.0174532925 T*  T>F  ;

: TDEG>RAD  ( t1 -- t2 )
  t# 0.0174532925 T* ;

\ Chebyshev sine & cosine primitives
DECIMAL
: TSIN_R<x>  ( t1 -- t2 )  ( -pi/4 <= t1 <= pi/4 )
  TDUP TDUP T*   TDUP
  t#  .000002717349463  T*
  t# -.0001983920268    T+   TOVER T*
  t#  .008333328785     T+   TOVER T*
  t# -.1666666663       T+         T*
  t#  .9999999995       T+         T*  ;
: TCOS_R<x>  ( t1 -- t2 )  ( -pi/4 <= t1 <= pi/4 )
  TDUP T*   TDUP
  t#  .00002437988031 T*
  t# -.001388661862   T+   TOVER T*
  t#  .0416666167     T+   TOVER T*
  t# -.4999999943     T+         T*
  t# 1.0              T+   ;
\ Sine function
DECIMAL   \ Based on Cody & Waite, but somewhat different
: <TSIN>  ( t1 -- t2 )
  SWAP   DUP 0< >R  ( sign )    LSL LSR  SWAP
  TDUP t# .318309886  ( 1/pi )   T*   T>RND   DROP
  DUP 1 AND    IF  R> 0= >R   THEN
  ?DUP  IF   N>T  t# 3.1415926535898 T* T-  THEN
  TDUP T>F  FDUP  PI/2 F>
  IF  F>R TNEGATE  t# 1.570796327 T+  FR>  THEN
  PI/4 F>
  IF  TNEGATE   t# 1.570796327 T+  TCOS_R<x>
  ELSE  TSIN_R<x>  THEN
  R>  ?TNEGATE ;



\ Cosine function
DECIMAL   \ Based on Cody & Waite, but somewhat different
: <TCOS>  ( t1 -- t2 )
  SWAP   0 >R  ( sign )    LSL LSR  SWAP
  TDUP t# .318309886  ( 1/pi )   T*   T>RND  DROP
  DUP 1 AND    IF  R> 0= >R   THEN
  N>T  t# 3.1415926535898 T* T-
  TDUP T>F  FDUP  PI/2 F>
  IF  F>R TNEGATE  t# 1.570796327 T+  FR>  R> 0= >R   THEN
  PI/4 F>
  IF  TNEGATE   t# 1.570796327 T+  TSIN_R<x>
  ELSE  TCOS_R<x>  THEN
  R>  ?TNEGATE ;



( full range cosine and sine  <COS>  <SIN>  )
DECIMAL
: <SIN>   ( f1 -- f2 )
  F>T  <TSIN> T>F  ;

: <COS>   ( f1 -- f2 )
  F>T  <TCOS> T>F  ;









( derived trig functions  <TAN>  <SEC>  <CSC>  <COT> )
DECIMAL
: <TAN>   ( f1 -- f2 )
  F>T TDUP  <TSIN> TSWAP <TCOS> T/  T>F ;

: <SEC>   ( f1 -- f2 )
  F>T  <TCOS>  t#   1 TSWAP T/  T>F ;

: <CSC>   ( f1 -- f2 )
  F>T  <TSIN>  t#   1 TSWAP T/  T>F ;

: <COT>   ( f1 -- f2 )
  F>T TDUP  <TCOS>  TSWAP  <TSIN>  T/  T>F ;



( trig functions  COS  SIN  TAN  SEC  CSC  COT  )
DECIMAL
: COS   ( f1 -- f2 )
  F>T  TDEG>RAD  <TCOS>  T>F ;
: SIN   ( f1 -- f2 )
  F>T  TDEG>RAD  <TSIN>  T>F ;
: TAN   ( f1 -- f2 )
  DEG>RAD  <TAN>  ;

: SEC   ( f1 -- f2 )
  DEG>RAD  <SEC>  ;
: CSC   ( f1 -- f2 )
  DEG>RAD  <CSC>  ;
: COT   ( f1 -- f2 )
  DEG>RAD  <COT>  ;

\ Chebyshev ATAN
DECIMAL
: TATAN_R<x>  ( t1 -- t2 )  ( -1 <= t1 <= 1 )
  TDUP TDUP  T*   TDUP
  t#  .0028340643              T*
  t# -.0160050306    T+  TOVER T*
  t#  .0425876076    T+  TOVER T*
  t# -.0749544546    T+  TOVER T*
  t#  .1063675406    T+  TOVER T*
  t# -.1420257041    T+  TOVER T*
  t#  .1999248354    T+  TOVER T*
  t# -.3333306679    T+        T*
  t#  .9999999842    T+        T*   ;



( basic inverse trig function  <ATAN> <ATAN2>  )
DECIMAL
: <TATAN>   ( t1 -- t2 )
  DUP 0<
  IF  TATAN_R<x> EXIT
  ELSE  OVER >R   t# 1  TSWAP T/    TATAN_R<x>
        TNEGATE  t# 1.570796327  R> ?TNEGATE  T+  EXIT  THEN ;
: <ATAN>    ( f1 -- f2 )    F>T  <TATAN> T>F ;

: <ATAN2>   ( fx fy -- f3 )
  FOVER F0=
  IF  >R DROP FDROP  PI/2  R> ?FNEGATE
  ELSE  FOVER F0<
     IF  FDUP F0<  >R  FSWAP F/  <ATAN>  PI  R>
        IF  F-  ELSE  F+  THEN
     ELSE   FSWAP F/  <ATAN>   THEN THEN ;
( derived inverse trig  <ASIN>  <ACOS>  <ACOT>  )
DECIMAL
: <ASIN>   ( f1 -- f2 )
  FDUP FABS  f# 1  F=
  IF  SWAP DROP  PI/2  ROT  ?FNEGATE
  ELSE  f# 1  FOVER  **2  F-  SQRT F/  <ATAN>  THEN  ;

: <ACOS>   ( f1 -- f2 )
  <ASIN> FNEGATE   PI/2 F+  ;

: <ACOT>   ( f1 -- f2 )
  <ATAN> FNEGATE   PI/2 F+  ;




( <SEC>  <ACSC>  )
DECIMAL
: <ASEC>   ( f1 -- f2 )
  FDUP  **2  f# -1  F+  SQRT  <ATAN> FSWAP   F0<
  IF  PI F- THEN   ;

: <ACSC>  ( FP# -- FP# )
  FDUP  FABS  f# 1  F=
  IF  SWAP DROP  PI/2  ROT ?FNEGATE
  ELSE  FDUP  **2 f# -1  F+
     SQRT 1/X    <ATAN> FSWAP   F0<
     IF  PI F- THEN  THEN  ;




( trig functions  ACOS  ASIN  ATAN  ASEC  ACSC  ACOT  ATAN2 )
DECIMAL
: ACOS   ( f1 -- f2 )
  <ACOS>  RAD>DEG  ;
: ASIN   ( f1 -- f2 )
  <ASIN>  RAD>DEG  ;
: ATAN   ( f1 -- f2 )
  <ATAN>  RAD>DEG  ;
: ASEC   ( f1 -- f2 )
  <ACSC>  RAD>DEG  ;
: ACSC   ( f1 -- f2 )
  <ACSC>  RAD>DEG  ;
: ACOT   ( f1 -- f2 )
  <ACOT>  RAD>DEG  ;
: ATAN2   ( fx fy -- f3 )
  <ATAN2>  RAD>DEG  ;
( <P>R>  <R>P>  P>R  R>P  )
DECIMAL
: <P>R>   ( frad fang -- fx fy )
  FOVER FOVER  <SIN>  F* F>R
  <COS>  F* FR>  ;

: <R>P>   ( fx fy -- frad fang )
  FOVER FOVER  <ATAN2> F>R
  **2 FSWAP  **2 F+  SQRT FR>  ;

: P>R   ( frad fang -- fx fy )
  DEG>RAD  <P>R>  ;

: R>P   ( fx fy -- frad fang )
  <R>P>  RAD>DEG ;

















( GENERAL TEST SCREEN FOR FLOATING POINT )
DECIMAL
: TEST-TRIG  CR
 ." ANGLE     SIN         COS                 TAN    "  CR
 ." =====  ==========  ==========          =========="  CR
 90 0 DO
    I N>F FDUP       1 5 F.AR
           FDUP  SIN  7 12 F.AR
           FDUP  COS  7 12 F.AR
                 TAN    20 F.XR   CR
     KEY? ABORT" ..BREAK.."
   LOOP ;




( TEST SCREEN FOR LOG FUNCTION )
DECIMAL
: .TEST-LOG
    FDUP        5 F.R        FDUP LOG2   17 F.R
    FDUP  2**   17 F.R       F>T  TDUP TDUP T*  TLOG2 t# 2 T/
           TSWAP  TLOG2 T-  TABS  T>F  9 17 F.AR CR ;

: TEST-LOG ( -- )  CR
 ."   X           LOG2(X)      2**(LOG2(X))  LOG2 REL. ERROR" CR
 ." =====        =========     ============  ===============" CR
  90 0 DO
      I N>F   .TEST-LOG
      KEY?  ABORT" ..BREAK.."
  LOOP ;


( TEST SCREEN FOR EXP FUNCTION )
DECIMAL
: .TEST-EXP
    FDUP        10  F.XR       FDUP 2**  9 20 F.AR
    F>T  TDUP  t# 3 T/  T2**   TDUP TDUP T* T*
       TOVER T2** T-  TABS   TSWAP T2** T/ T>F   8 20 F.AR CR ;

: TEST-EXP ( -- )  CR
 ."      X               2**(X)        EXP2 REL. ERROR" CR
 ."  =========        ============     ===============" CR
 120 0 DO
      I N>F  f# 50 F-  f# .312378 F*  .TEST-EXP
      KEY?  ABORT" ..BREAK.."
  LOOP  CR
  f# 2 .TEST-EXP  f# 4  .TEST-EXP
  f# 8 .TEST-EXP  f# 16 .TEST-EXP  CR ;
( TEST SCREEN FOR SQRT FUNCTION )
DECIMAL
: .TEST-SQRT
    FDUP            15 F.R       FDUP SQRT  17 F.R
    FDUP  SQRT **2  17 F.R
    FDUP  SQRT **2  FOVER F-  FSWAP F/ FABS  7 17 F.AR  CR ;

: TEST-SQRT ( -- )  CR
 ."        X             SQRT(X)            SQRT**2     "
    ."      REL. ERROR" CR
 ." ===============   ==============   =============="
    ."    =============="  CR  f# .0005
 140 0 DO
   f# 1.9876543 F*   FDUP .TEST-SQRT
      KEY?  ABORT" ..BREAK.."
  LOOP FDROP  CR ;
( TEST SCREEN FOR SIN FUNCTION )
DECIMAL
: .TEST-SIN
    FDUP          5 F.R       FDUP  SIN   7 15 F.AR
    FDUP  COS  7 15 F.AR     FDUP F>R  SIN  F>T  TDUP T*
              FR>  COS  F>T  TDUP T*  T+  T>F  17 F.R  CR ;

: TEST-SIN ( -- )  CR
 ."   X        SIN(X)         COS(X)     SIN**2 + COS**2"  CR
 ." =====   ============   ============  ==============="  CR
 90 -89 DO
   I N>F   .TEST-SIN
      KEY?  ABORT" ..BREAK.."
  LOOP   CR ;


( TEST SCREEN FOR TAN FUNCTION )
DECIMAL
: .TEST-TAN
    FDUP          5 F.R       FDUP  TAN   6 15 F.AR
    TAN  ATAN  6 15 F.AR   CR  ;

: TEST-TAN ( -- )  CR
 ."   X        TAN(X)         ATAN(X)   " CR
 ." =====   ============   ============" CR
 90 -89 DO
   I N>F   .TEST-TAN
      KEY?  ABORT" ..BREAK.."
  LOOP   CR ;



































































( Floating Point problem solution - 1 )
DECIMAL
: VOLUME   ( fheight fradius -> fvolume )
  **2  F*  PI F*  ;

: AREA   ( fheight fradius -> farea )
  FDUP  **2  PI F*  F2* F>R
  F*  PI F*  F2*  FR>  F+  ;

: EFFICIENCY   ( fvolume farea -> fefficiency )
  F/  ;





( Floating Point problem solution - 2 )
DECIMAL
: TAB   ( #columns -> )
  #OUT @  -  0 MAX  SPACES ;

: .HEADER   ( -> )
  CR ." HEIGHT"
  10 TAB  ." RADIUS"
  20 TAB  ." AREA"
  30 TAB  ." VOLUME"
  40 TAB  ." EFFICIENCY"  CR CR ;





( Floating Point problem solution - 3 )
DECIMAL
: CAN   ( fheight fradius -> )
  FOVER F.
  10 TAB  FDUP F.
  20 TAB  FOVER FOVER  AREA  FDUP F.  F>R
  30 TAB  VOLUME  FDUP F.
  40 TAB  FR>  EFFICIENCY  F.  CR  ;

: CAN-HEIGHT   ( fheight -> )
  f# 1.0     BEGIN
     KEY?  ABORT" BREAK..."
     FOVER FOVER  CAN    f# 0.25  F+
     FDUP  f# 4.25  F<  NOT  UNTIL
  FDROP FDROP CR ;

( Floating Point problem solution - 4 )
DECIMAL
: RESULTS   ( -> )
  .HEADER
  f# 1.0   BEGIN
     FDUP  CAN-HEIGHT     f# 0.5 F+
     FDUP  f# 5.5   F<  NOT    UNTIL
  FDROP  ;








































































































