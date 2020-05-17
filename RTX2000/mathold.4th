















( load entire package from high level source )
\ Rewritten by Phil Koopman for RTX 2000 / Forth-83
\ Note: this was written for portability, NOT SPEED!
: THIS ;
DECIMAL 3 109 THRU












DECIMAL
FORGET THIS   : THIS ;
3 109 THRU




























( CELL SIZE ALIASES )
: CELL* 2* ;              MACRO
: CELL+ 2+ ;              MACRO
2 CONSTANT CELL-SIZE

: DDROP DROP DROP ;       MACRO
: DDUP  OVER OVER ;       MACRO
: D!    !+2 !+2 DROP ;    MACRO
\ : U*    UM* ;
: D+-  0< IF DNEGATE THEN ;
\ : <NUMBER> NUMBER ;
: DLITERAL  STATE @ IF SWAP [COMPILE] LITERAL
                  [COMPILE] LITERAL THEN ; IMMEDIATE
\ : HLD  PTR ;
VARIABLE DPL  \ Looks like NUMBER doesn't support DPL
: SIGN  0<  IF 45 HOLD THEN ;
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
VARIABLE TEMP-ADDR  ( temporary address storage )
VARIABLE TSUMH 24 ALLOT    ( division temp storage - remainder)
  TSUMH 8 + CONSTANT TSUML ( division temp storage - quotient )
  TSUML 8 + CONSTANT TSUMQ ( quad precision temp storage )
VARIABLE TEMP-CARRY  ( temporary carry storage )
VARIABLE SIGDIG   ( number significant digits )
     7 SIGDIG !
 VARIABLE TERM  4 ALLOT   ( temp storage for transcendentals )
 VARIABLE FTERM  4 ALLOT   ( temp storage for transcendentals )
\ VARIABLE <?MODE>  ( numeric input mode )




( shift/rotate operations  LSL  ASR  LSR )
HEX   ( may be replaced with CODE definitions )
\ : 2/   2  / ;

: LSL   ( n1 -> n2 )
  2* ;  MACRO

: ASR   ( n1 -> n2 )
  2/  ; MACRO

: LSR   ( n1 -> n2 )
  U2/ ; MACRO

DECIMAL


( C+!  SGN  U>  )
DECIMAL
: C+!  ( b addr -> )
   DUP  >R  C@ +  R> C! ;

: SGN    ( n -> signum.of.n )
  DUP  IF   0<  IF -1 ELSE 1 THEN THEN ;

: U>     ( un1 un2 -> flag )
 SWAP U< ;






( RRC  RLC  ADC  )
HEX     ( may be replaced with CODE definitions )
A005 UCODE c2/
A003 UCODE 2*c
: RRC    ( n1 carry.in -> n2 carry.out )
  -1 + DROP  c2/  0 -1 +c  NOT ;

: RLC    ( n1 carry.in -> n2 carry.out )
  -1 + DROP  DUP 2*c  SWAP 0< ;

: ADC  ( n1 n2 carry.in -> n3  carry.out )
  -1 + DROP  +c   0 -1 +c NOT ;

DECIMAL


( single precision multiple rotates  ASRN  LSRN  LSLN  )
DECIMAL
: ASRN   ( n1 count -> n2 )
  DUP 0>  IF  1- OF( 2/
          ELSE  DROP  THEN ;

: LSRN   ( n1 count -> n2 )
  DUP 0>  IF  1- OF( U2/
          ELSE  DROP  THEN  ;

: LSLN   ( n1 count -> n2 )
  DUP 0>  IF  1- OF( 2*
          ELSE  DROP  THEN  ;



( conversions   S->Q  D->Q  D->S  Q->S  Q->D  )
DECIMAL
: S->D   ( n -> d )   DUP 0<  ;
: S->Q   ( n -> q )
  S->D  DUP DUP ;
: D->Q   ( d -> q )
  S->D  DUP ;
: D->S   ( d -> n )
  DROP ;                MACRO
: Q->S   ( q -> n )
  DDROP    DROP ;
: Q->D   ( q -> d )
  DDROP ;

: M+  S->D D+ ;

( double stack ops  DOVER  DSWAP  DROT )
DECIMAL     ( may be replaced with CODE definitions )
: DOVER   ( d1 d2 -> d1 d2 d1 )  ( MVP-FORTH UTILITY )
  2>R 2DUP 2R> 2SWAP ;

: DSWAP   ( d1 d2 -> d2 d1 )  ( MVP-FORTH UTILITY )
  ROT >R ROT R> ;

: DROT  ( d1 d2 d3 -> d2 d3 d1 )  ( MVP-FORTH UTILITY )
  2>R 2SWAP 2R> 2SWAP ;






( double precision stack ops  D@  D>R  DR>  DR@  )
DECIMAL     ( may be replaced with CODE definitions )
: D@   ( addr -> d )     ( MVP-FORTH UTILITY )
   @+2 @+2 DROP SWAP ;

: D>R   ( d -> )
  COMPILE >R  COMPILE >R NOP  ;  IMMEDIATE

: DR>  ( d -> )
  COMPILE R>  COMPILE R> NOP  ;   IMMEDIATE

: DR@   ( -> d )
\  R> R@  OVER >R  ;  MACRO  -- FIX CODE OPTIMIZER, THEN USE
  R>  DR> 2DUP D>R  ROT >R ;


( double precision stack ops  DPICK  DROLL  D? )
HEX
: DPICK   ( d1 .. dn count -> d1 .. dn dm )
\  DUP 0 <  IF  ." DPICK ARGUMENT < 0"  ABORT THEN
  1+ 2*  1- DUP 1+   PICK  SWAP PICK  ;

: DROLL   ( d1 .. dn count -> d1 ..<omit dm>.. dn dm )
\  DUP 0 <  IF  ." DROLL ARGUMENT < 0"  ABORT THEN
  1+ 2*  1- DUP 1+  ROLL  SWAP ROLL  ;

: D?   ( addr -> )
  D@  D.  ;

DECIMAL


( D,  DCONSTANT DVARIABLE )
DECIMAL
: D,   ( d -> )
       ,  ,  ;

: DCONSTANT   ( d -> )  ( compiling )
              ( -> d )  ( executing )
  CREATE  D,
   DOES>  D@ ;

: DVARIABLE   ( -> )       ( compiling )
              ( -> addr )  ( executing )
  CREATE  2 CELL*  ALLOT ;



( D-  D+! )
DECIMAL
: D-   ( d1 d2 -> d3 )  ( MVP-FORTH UTILITY )
  DNEGATE  D+  ;

: D+!   ( d1 addr -> )
  DUP >R  D@ D+  R> D!  ;









( double precision rotates/add  DADC  DRRC  DRLC )
HEX
A00D UCODE cD2/     A00E UCODE UD2/
A00B UCODE D2*c     A00C UCODE cUD2/
: DADC   ( d1 d2 carry.in -> d3 carry.out )
  -1 + DROP   >R  SWAP  >R  +c  R> R> +c   0 -1 +c NOT ;

: DRRC  ( d1 carry.in -> d2 carry.out )
  -1 + DROP   cD2/   0 -1 +c NOT ;

: DRLC   ( d1 carry.in -> d2 carry.out )
  -1 + DROP   D2*c   0 -1 +c NOT ;

DECIMAL


( double precision shifts  DASR  DLSR  DLSL  )
HEX
: DASR   ( d1 -> d2 )
   D2/ ;  MACRO

: DLSR   ( d1 -> d2 )
   UD2/ ; MACRO

: DLSL   ( D1 -> D2 )
   D2*  ; MACRO

DECIMAL




( double precision multiple shifts  DASRN  DLSRN  DLSLN )
DECIMAL
: DASRN   ( d1 n -> d2 )
  DUP 0>  IF   1-  OF( D2/
          ELSE  DROP  THEN  ;

: DLSRN   ( d1 n -> d2 )
  DUP 0>  IF   1-  OF( UD2/
          ELSE  DROP  THEN  ;

: DLSLN   ( d1 n -> d2 )
  DUP 0>  IF   1-  OF( D2*
          ELSE  DROP  THEN  ;



( DOR  DAND  DXOR  BYTESWAP  )
DECIMAL
: DOR   ( d1 d2 -> d3 )
 >R  SWAP >R  OR  R> R> OR  ;

: DAND   ( d1 d2 -> d3 )
 >R  SWAP >R  AND  R> R> AND ;

: DXOR   ( d1 d2 -> d3 )
 >R  SWAP >R  XOR  R> R> XOR ;

: BYTESWAP  ( n1 -> n2 )
   DUP  8 DLSRN DROP  ;



( double precision comparisons  D0<  D0>  D0=  D>  D=  )
DECIMAL
: D0<   ( d1 -> flag )
  SWAP  DROP  0<  ;

: D0>   ( d1 -> flag )
  DNEGATE D0<  ;

: D0=   ( d1 -> flag )
  OR 0= ;

: D>   ( d1 d2 -> flag )    ( MVP-FORTH UTILITY )
  DSWAP D< ;

: D=   ( d1 d2 -> flag )  ( MVP-FORTH UTILITY )
  D- D0=  ;
( DMAX  DMIN  DU<  DU> )
HEX
: DMAX   ( d1 d2 -> d3 )  ( MVP-FORTH UTILITY )
  DOVER DOVER  D<  IF  DSWAP  THEN   DDROP  ;

: DMIN   ( d1 d2 -> d3 )  ( MVP-FORTH UTILITY )
  DOVER DOVER  D<  0= ( NOT )   IF  DSWAP  THEN   DDROP ;

: DU<   ( ud1 ud2 -> flag )  ( MVP-FORTH UTILITY )
  D>R  8000 +  DR>  8000 +  D<  ;

: DU>   ( ud1 ud2 -> flag )
  DSWAP DU<  ;

DECIMAL

( quad precision stack ops  QDROP  QDUP  QOVER  QSWAP  QROT )
DECIMAL     ( may be replaced with CODE definitions )
: QDROP   ( q -> )
  DDROP DDROP  ;

: QDUP   ( q1 -> q1 q1 )
  DOVER DOVER  ;

: QOVER   ( q1 q2 -> q1 q2 q1 )
  3 DPICK  3 DPICK  ;

: QSWAP   ( q1 q2 -> q2 q1 )
  3 DROLL  3 DROLL  ;

: QROT   ( q1 q2 q3 -> q2 q3 q1 )
  5 DROLL  5 DROLL  ;
( quad precision store and fetch  Q!  Q@  )
DECIMAL     ( may be replaced with CODE definitions )
: Q!   ( q addr -> )
  DUP  >R  D!  R>  4 +  ( CELL+ CELL+ )  D! ;

: Q@   ( addr -> q )
  DUP  4 +  ( CELL+  CELL+)  D@  ROT  D@  ;









( quad return stack operations  Q>R  QR>  QR@  )
DECIMAL     ( may be replaced with CODE definitions )
: Q>R   ( q -> )
  COMPILE >R COMPILE >R COMPILE >R COMPILE >R NOP ; IMMEDIATE

: QR>   ( -> q )
  COMPILE R> COMPILE R> COMPILE R> COMPILE R> NOP ; IMMEDIATE

: QR@  ( -> Q )
  R>  TEMP-ADDR !  DR> DR>
  QDUP  D>R D>R  TEMP-ADDR @  >R  ;





( quad logical ops  QOR  QAND  QXOR )
DECIMAL
: QOR        ( q1 q2 -> q3 )
   D>R  DSWAP   D>R  DOR    DR>   DR> DOR  ;

: QAND       ( q1 q2 -> q3 )
   D>R  DSWAP   D>R  DAND   DR>   DR> DAND  ;

: QXOR       ( q1 q2 -> q3 )
   D>R  DSWAP   D>R  DXOR   DR>   DR> DXOR  ;






( QADC )
DECIMAL     ( may be replaced with CODE definitions )
: QADC   ( q1 q2 carry.in -> q3 carry.out )
 TEMP-CARRY !  D>R  DSWAP D>R  TEMP-CARRY @   DADC
 DR> DR>  4 ROLL  DADC  ;











( Q+  QNEGATE  Q-   DM+  )
DECIMAL
: Q+   ( q1 q2 -> qsum )
  0 QADC  DROP  ;

: QNEGATE     ( q1 -> -q1 )
  -1. -1. QXOR    1. 0. Q+   ;

: Q-   ( q1 q2 -> q3 )
  QNEGATE Q+  ;

: DM+    ( q1 d2 -> q3 )
  D->Q Q+  ;



( Q+!  Q+-  QABS )
DECIMAL
: Q+!   ( q addr -> )
  DUP >R  Q@ Q+  R> Q!  ;

: Q+-   ( q1 n2 -> q3 )
  0<  IF  QNEGATE  THEN  ;

: QABS   ( q1 -> q2 )
  DUP Q+-  ;






( QASR  QLSR  QLSL )
HEX
: QASR   ( q1 -> q2 )
  DUP 0<  -1 + DROP   cD2/  >R >R  cUD2/  R> R> ;

: QLSR   ( q1 -> q2 )
  0 0 +  DROP  cD2/  >R >R  cUD2/  R> R> ;

: QLSL   ( q1 -> q2 )
  >R >R D2*  R> R> D2*c ;

DECIMAL




( QASRN  QLSRN  QLSLN  )
DECIMAL
: QASRN   ( q1 n2 -> q3 )
  DUP 0>  IF    0 DO  QASR  LOOP
          ELSE  DROP  THEN  ;

: QLSRN   ( q1 n2 -> q3 )
  DUP 0>  IF    0 DO  QLSR  LOOP
          ELSE  DROP  THEN  ;

: QLSLN   ( q1 n2 -> q3 )
  DUP 0>  IF    0 DO  QLSL  LOOP
          ELSE  DROP  THEN  ;



( basic double multiplication  DU* )
DECIMAL     ( may be replaced with CODE definitions )
: DU*   ( ud1 ud2 -> uq3 )
  ( adds 4 partial products to get result )
  OVER  4 PICK  UM*  D>R  SWAP  2 PICK  UM*  D>R
  ROT  OVER  UM*  D>R  UM*  0 0  DSWAP
  0  DR>  0 Q+  0 DR>  0 Q+  DR>  0 0 Q+  ;









( double precision multiplication  D*  DM* )
DECIMAL
: D*   ( d1 d2 -> d3 )
  DU* DDROP  ;

: DM*   ( d1 d2 -> q3 )
  DUP  3 PICK  XOR >R
  DABS  DSWAP DABS  DU*  R> Q+-  ;








( double precision unsigned division  DU/MOD )
HEX     ( may be replaced with CODE definitions )
: DU/MOD   ( uq1 ud2 -> ud3 ud4 )
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


( double precision mixed division  DM/MOD  DM/  D/MOD  D*/MOD )
DECIMAL
: DM/MOD   ( uq1 ud2 -> ud3 uq4 )
  D>R  0 0 DR@  DU/MOD  DR> DSWAP D>R  DU/MOD DR>  ;

: DM/   ( q1 d2 -> d3 d4 )
  2 PICK >R  D>R  QABS  R> R@  DABS  DU/MOD
  R> R@  XOR D+-  DSWAP  R>  D+-  DSWAP  ;

: D/MOD   ( d1 d2 -> d3 d4 )
  D>R  D->Q  DR>  DM/  ;

: D*/MOD   ( d1 d2 d3 -> d4 d5 )
  D>R  DM*  DR>  DM/  ;


( D/  D*/  DMOD )
DECIMAL
: D/   ( d1 d2 -> d3 )
  D/MOD  DSWAP DDROP  ;

: D*/   ( d1 d2 d3 -> d4 )
  D*/MOD  DSWAP DDROP  ;

: DMOD   ( d1 d2 -> d3 )
  D/MOD DDROP  ;






( DINP#  DMODE  ?MODE )
DECIMAL
: DINP#    ( -> D )  ( "state-smart" word )
  BL WORD  NUMBER
  [COMPILE] DLITERAL  ;  IMMEDIATE

\ : DMODE  ( -> )
\   0 <?MODE> !
\   ' <NUMBER> CFA     'NUMBER !
\   ' <INTERPRET> CFA  'INTERPRET !
\   R> DROP  INTERPRET  ;     IMMEDIATE
\
\ : ?MODE   ( -> flag=0,1,2 )
\   <?MODE> @ ;
\ DMODE

( QPICK  QROLL )
DECIMAL
: QPICK   ( q1 .. qn count -> q1 .. qn qm )
\  DUP  1 < ABORT" QPICK ARGUMENT < 1"
  2*  >R  R@ DPICK  R> DPICK ;

: QROLL  ( qn1 .. qnn count -> qnn ..<omit q1>.. qnn q1 )
\  DUP 1 < ABORT" QROLL ARGUMENT < 1"
  2*  >R  R@ DROLL  R> DROLL ;







(  Q,   QCONSTANT  QVARIABLE  QLITERAL )
DECIMAL
: Q,   ( q -> )
   D, D,  ;

: QCONSTANT   ( q -> ) ( compiling )  ( -> q ) ( executing )
  CREATE  Q,     DOES>  Q@  ;

: QVARIABLE   ( -> ) ( compiling )  ( -> addr ) ( executing )
  CREATE  4 CELL* ALLOT  ;

: QLITERAL   ( q -> q ) ( executing )
             ( q -> )   ( compiling )
  STATE @   IF  DSWAP  [COMPILE] DLITERAL
     [COMPILE] DLITERAL  THEN  ;     IMMEDIATE

( QRRC  QRLC )
DECIMAL
: QRRC   ( q1 carry.in -> q2 carry.out )
  DRRC  >R DSWAP R>  DRRC  >R DSWAP R>  ;

: QRLC   ( q1 carry.in -> q2 carry.out )
  >R DSWAP R>  DRLC  >R DSWAP R>  DRLC  ;









( quad comparisons  Q0<  Q0>  Q0=  )
DECIMAL
: Q0<   ( q -> flag )
  >R  DDROP DROP  R> 0<  ;

: Q0>   ( q -> flag )
  QNEGATE Q0<  ;

: Q0=   ( q -> flag )
  OR OR OR  0=  ;






( quad precision comparisons  Q>  Q<  Q= )
DECIMAL
: Q>   ( q1 q2 -> flag )
  DUP  5 PICK  DDUP =
  IF  DDROP  Q- Q0>
  ELSE  <  >R  QDROP QDROP  R>  THEN  ;

: Q<   ( q1 q2 -> flag )
  QSWAP Q>  ;

: Q=   ( q1 q1 -> flag )
  Q- Q0=   ;




( QMAX  QMIN  QU<  QU> )
HEX
: QMAX   ( q1 q2 -> q3 )
  QOVER QOVER  Q<  IF  QSWAP  THEN  QDROP  ;

: QMIN   ( q1 q2 -> q3 )
  QOVER QOVER  Q>  IF  QSWAP  THEN  QDROP  ;

: QU<   ( uq1 uq2 -> flag )
  Q>R  8000 +  QR>  8000 +  Q<  ;

: QU>   ( uq1 uq2 -> flag )
  QSWAP QU<  ;

DECIMAL

( DQADC  DQ+  )
DECIMAL
: DQADC   ( dq1 dq2 carry.in -> dq3 carry.out )
  TEMP-CARRY !  Q>R QSWAP Q>R  TEMP-CARRY @
  QADC  QR> QR>  8 ROLL  QADC  ;

: DQ+   ( dq1 dq2 -> dq3 )
  0 DQADC  DROP  ;








( DQNEGATE  DQ+-  DQABS )
DECIMAL
: DQNEGATE   ( dq1 -> dq2 )
  -1. -1. QXOR  Q>R  -1. -1. QXOR
  QR>  1. 0. 0. 0.  DQ+  ;

: DQ+-   ( dq1 n2 -> dq3 )
  0<  IF  DQNEGATE  THEN  ;

: DQABS   ( dq1 -> dq2 )
  DUP DQ+-  ;





( quad precision multiplication  QU* )
DECIMAL     ( may be replaced with CODE definitions )
: QU*   ( uq1 uq2 -> udq3 )
  ( uses 4 partial products to get result )
  DOVER  4 DPICK  DU*  Q>R  DSWAP  2 DPICK  DU*  Q>R
  DROT  DOVER  DU*  Q>R  DU*  0 0 0 0  QSWAP
  0 0  QR>  0 0 DQ+
  0 0  QR>  0 0 DQ+  QR>  0 0 0 0  DQ+  ;








( quad precision unsigned division  QU/MOD )
HEX         ( may be replaced with CODE definitions )
: QU/MOD     ( udq1 uq2 -> uq3 uq4 )
  Q>R  TSUMH Q!  TSUML Q!
  QR>  QDUP  QNEGATE  TSUMH Q+!  41 >R
  BEGIN  TSUMH @  0<  R>  1-  DUP >R
  WHILE  TSUML Q@  0 QRLC  >R  TSUML Q!
     TSUMH Q@  R> QRLC  DROP  TSUMH Q!
     IF  QDUP
     ELSE  QDUP QNEGATE  1 TSUML  6 + +!  THEN
     TSUMH  Q+!  REPEAT        R> DROP
  TSUML Q@  4 PICK  0=  QRLC  DROP  4 ROLL
  IF  QSWAP  TSUMH Q@ Q+
  ELSE  QSWAP QDROP   TSUMH Q@  THEN     QSWAP ;

DECIMAL
( Q*  QM/MOD  Q/MOD  Q*/MOD )
DECIMAL
: Q*   ( q1 q2 -> q3 )
  QU*  QDROP  ;

: QM/MOD   ( udq1 uq2 -> uq3 udq4 )
  Q>R  0 0 0 0  QR@  QU/MOD  QR> QSWAP Q>R  QU/MOD QR>  ;

: Q/MOD   ( q1 q2 -> q3 q4 )
  DUP  5 PICK  DUP >R  XOR >R  QSWAP QABS  0 0 0 0
  QROT  QABS QU/MOD  R> Q+-  QSWAP R> Q+-  QSWAP  ;

: Q*/MOD   ( q1 q2 q3 -> q4 q5 )
  DUP  8 PICK  DUP  >R XOR  4 PICK  XOR >R   QABS Q>R
  QABS  QSWAP  QABS QU*  QR> QU/MOD
  R> Q+-  QSWAP  R> Q+-  QSWAP  ;
( Q/  Q*/  QMOD  DM*/ )
DECIMAL
: Q/   ( q1 q2 -> q3 )
  Q/MOD  QSWAP QDROP  ;

: Q*/   ( q1 q2 q3 -> q4 )
  Q*/MOD  QSWAP QDROP  ;

: QMOD   ( q1 q2 -> q3 )
  Q/MOD QDROP  ;

: DM*/   ( q1 d2 d3 -> q4 )
  DUP  3 PICK XOR  5 PICK XOR  >R  DABS D>R
  DABS D>R  QABS DR>  D->Q  QU*  DR>
  D->Q  QU/MOD  QSWAP QDROP  R> Q+-  ;

( quad output formatting   <Q#  Q#>  Q#  Q#S )
HEX
: <Q#   ( q1 -> q1 )
  <#  ;

: Q#>   ( uq1 -> addr n2 )
  QDROP  PTR @  PAD OVER  -  ;

: Q#   ( uq1 -> uq2 )
  BASE @  S->D DM/MOD  DROT  D->S  9 OVER <
  IF  7 +  THEN      30 + HOLD  ;

: Q#S   ( uq -> 0 0 0 0 )
  BEGIN  Q#  QDUP Q0=  UNTIL  ;

DECIMAL
( quad printing   Q.R  Q.  Q? )
DECIMAL
: Q.R   ( q1 n2 -> )
  DEPTH 5 <  ABORT" EMPTY STACK"
  >R  DUP >R  QABS
  <Q#   Q#S  R>  SIGN  Q#>
  R>  OVER -  SPACES TYPE  ;

: Q.   ( q -> )
  0 Q.R  SPACE  ;

: Q?   ( addr -> )
  Q@ Q.  ;



( unsigned double printing   DU.  DU.R )
DECIMAL
: DU.   ( d -> )
  0 0 Q.  ;

: DU.R   ( d1 n2 -> )
  0 0  ROT  Q.R  ;









( quad input   QCONVERT  <QNUMBER> )
HEX
VARIABLE QQQ  30 ALLOT  \ ????????????
: QCONVERT   ( q1 addr -> q2 addr2 )
  BEGIN  1+ DUP  >R  C@ BASE @  DIGIT
  WHILE  >R  BASE @ S->Q  Q*  R> S->Q  Q+
     DPL @ 1+  IF  1 DPL +!  THEN   R>  REPEAT  R>  ;

: <QNUMBER>   ( addr -> q1 )   QQQ 20 CMOVE  QQQ
  0 0 0 0  4 ROLL  DUP 1+ C@  2D =  1 AND  DUP  >R
  + -1 DPL !   QCONVERT  DUP C@ BL >
  IF DUP C@  2E = 0= ( NOT)  ABORT" NOT RECOGNIZED"  0 DPL !
     QCONVERT  DUP C@ BL >  ABORT" NOT RECOGNIZED"  THEN
  DROP R>   IF  QNEGATE  THEN  ;

DECIMAL
( ??? quad interpret  <QINTERPRET> )
DECIMAL
\ : <QINTERPRET>   ( -> )
\   BEGIN  -FIND
\     IF STATE @ <
\        IF  CFA ,
\        ELSE  CFA EXECUTE  THEN
\     ELSE  HERE  NUMBER DPL @ 1+
\        IF  [COMPILE] QLITERAL
\        ELSE Q->S [COMPILE] LITERAL  THEN
\     THEN  ?STACK
\  AGAIN ;




( ??? QMODE  QINP# )
DECIMAL
\ : QMODE   ( -> )
\   1 <?MODE> !
\   ' <QNUMBER> CFA     'NUMBER !
\   ' <QINTERPRET> CFA  'INTERPRET !
\   R> DROP   INTERPRET  ;     IMMEDIATE
\
: QINP#   ( -> q )  ( "state-smart" word )
  BL WORD  <QNUMBER>
  [COMPILE] QLITERAL  ;     IMMEDIATE





( floating point return stack operations  F>R  FR>  FR@  )
DECIMAL     ( may be replaced with CODE definitions )
: F>R   ( f1 -> )
  COMPILE  >R  COMPILE >R  NOP ;  IMMEDIATE

: FR>   ( -> f1 )
  COMPILE R>   COMPILE R>  NOP ;  IMMEDIATE

: FR@   ( -> f1 )
\  R>  R@  OVER  >R  ;  MACRO
  R> DR> 2DUP D>R  ROT >R ;





( floating point aliases )
DECIMAL
: F@           @+2 @+2  DROP  SWAP ;  MACRO
: F!           !+2  !+2 DROP ;        MACRO
: FDROP        DROP DROP ; MACRO
: FDUP         OVER OVER ; MACRO
: FSWAP        ROT >R ROT R> ;
: FOVER        2>R 2DUP 2R> 2SWAP ;
: FROT         2>R 2SWAP 2R> 2SWAP ;
: FPICK        DPICK  ;
: FROLL        DROLL  ;
: FCONSTANT    DCONSTANT  ;
: FVARIABLE    DVARIABLE  ;
: FLITERAL     [COMPILE] DLITERAL  ;   IMMEDIATE
: F,           D,  ;

( FABS  F0=  and temporary absolute values & zero test )
HEX
: FABS   ( f1 -> f2 )
  7FFF AND  ;

: F0=   ( f1 -> flag )
  FABS  D0=  ;

: TABS   ( t1 -> t2 )
   >R FABS R>  ;

: T0=   ( t1 -> t1 flag )
  ( Note:  does NOT remove t1 from stack !!! )
  >R  DDUP FABS  D0= R> SWAP  ;

DECIMAL
( various T operations )
HEX
: TDROP   ( t1 -> )
  DROP DROP DROP  ; MACRO

: CHK0   ( t1 -> t2 )   ( forces clean zero )
   T0=  IF  TDROP 0 0 0  THEN  ;
: TNEGATE   ( t1 -> t2 )
   >R  8000 XOR  R> CHK0  ;
: T+-   ( t1 n2 -> t3 )
  0< IF  TNEGATE  THEN  ;
: TR> COMPILE R> COMPILE R> COMPILE R> NOP ; IMMEDIATE
: T>R COMPILE >R COMPILE >R COMPILE >R NOP ; IMMEDIATE

DECIMAL

( TSWAP  TOVER  TDUP  T@  T! )
DECIMAL     ( may be replaced with CODE definitions )
: TDUP   ( t1 -> t1 t1 )
  >R >R  DUP R> SWAP OVER  R@ SWAP >R SWAP R> R> ;
: TSWAP   ( t1 t2 -> t2 t1 )
  >R >R SWAP >R SWAP >R SWAP  R> R> R> SWAP >R SWAP >R SWAP
  R> R> R>  SWAP >R SWAP >R SWAP R> R> ;
: TOVER   ( t1 t2 -> t1 t2 t1 )
  T>R TDUP TR> TSWAP ;

: T@   ( addr -> t1 )
  DUP  CELL+ F@  ROT @  ;

: T!   ( t1 addr -> )
  SWAP  OVER !  CELL+ D!  ;

( floating point to temporary conversion )
HEX     ( may be replaced with CODE definitions )
: F->T   ( f1 -> t2 )
  DDUP  F0=
  IF  DROP  0 0
  ELSE  DUP 7F80 AND
  ( 7 LSRN )  6 OF( U2/
                              7F -  >R  DUP >R
    7F AND  80 OR
  ( 7 DLSLN ) 6 OF( D2*
    R> R>  SWAP T+-  THEN  ;

DECIMAL



( 32-bit normalization of mantissa )
HEX     ( may be replaced with CODE definitions )
: UDNORMALIZE   ( ut1 -> ut2 )
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


( temporary to floating point conversion )
HEX     ( may be replaced with CODE definitions )
: T->F   ( t1 -> f2 )
  CHK0  OVER ( sign ) >R  7F +  ( exponent )  >R   FABS
  DDUP D0=
  IF  R> R> DDROP
  ELSE  ( round )  40 0 D+ R> UDNORMALIZE >R
     ( 7 DLSRN ) 6 OF( UD2/    7F AND
     R>  ( 7 LSLN ) 6 OF( 2*    7F80 AND  OR
     R> 8000 AND OR     THEN ;

DECIMAL




( floating to temp conversions and quad normalize )
HEX
: SEPARATE2   ( f1 f2 -> t1 t2 )
  F>R  F->T   FR>  F->T  ;

: UQNORMALIZE  ( uq1 n2 -> uq3 n4 )   ( shift left only )
  >R  DUP 0<
  IF  QLSR  R> 1+
  ELSE  QDUP   OR OR OR 0=
     IF ( zero ) R> DROP 0
     ELSE ( shift left )
       BEGIN  DUP  4000 AND  0=
       WHILE  QLSL  R> 1- >R  REPEAT   R>  THEN  THEN ;

 DECIMAL

( temporary floating point addition )
DECIMAL     ( may be replaced with CODE definitions )
: T+   ( t1 t2 -> t3 )
  T0=  IF  TDROP
  ELSE  TSWAP  T0=
     IF  TDROP
     ELSE  >R  ROT  R>  SWAP  DDUP >
        IF  DROT  DSWAP   ELSE  SWAP  THEN
        OVER >R  4 PICK  DUP >R  3 PICK  XOR  0< >R
        DROT FABS  DROT FABS  DROT   -   31 MIN DLSRN
        DDUP D0= IF R> DROP 0 >R  THEN     R>
        IF R> 0<    IF DSWAP THEN
           DNEGATE  0 DADC 0= ( NOT)     >R DABS R>
        ELSE  D+ R>  0<   THEN
     R> SWAP >R UDNORMALIZE R>   IF TNEGATE THEN
  THEN THEN   CHK0  ;
( temporary floating point multiplication )
HEX         ( may be replaced with CODE definitions )
: T*   ( t1 t2 -> t3 )
  >R  ROT  R> +  OVER  4 PICK  XOR  D>R
  FABS  DSWAP  FABS  DU* R> 2+ UQNORMALIZE
  T0=  0= ( NOT)  IF
    >R  ( round )  0 8000 0 0 Q+  R> UQNORMALIZE  THEN
  >R   DSWAP DDROP  DR>  T+-   CHK0  ;

DECIMAL






( temporary floating point division )
HEX     ( may be replaced with CODE definitions )
: T/   ( t1 t2 -> t3 )
  ( check for divide by zero )  T0=
  IF  TSWAP TDROP  ( result is zero )
  ELSE  >R  ROT  R>  - OVER  4 PICK  XOR   >R >R
     FABS  DSWAP  FABS  0 0 DSWAP  QLSR DROT
     DU/MOD DSWAP DDROP
     R> 1- UDNORMALIZE  R>  T+-  THEN   CHK0  ;

DECIMAL





( F+  F*  F/  F2/  F2* )
DECIMAL
: F+   ( f1 f2 -> f3 )
  SEPARATE2  T+ T->F  ;

: F*   ( f1 f2 -> f3 )
  SEPARATE2  T* T->F  ;

: F/   ( f1 f2 -> f3 )
  SEPARATE2  T/ T->F  ;

: F2/   ( f1 -> f2 )
  F->T  1-  T->F  ;

: F2*   ( f1 -> f2 )
  F->T  1+  T->F  ;
( FNEGATE  F-  F+! )
HEX
: FNEGATE   ( f1 -> f2 )
  DDUP OR  IF  8000 XOR  THEN  ;
DECIMAL
: T-   ( t1 t2 -> t3 )
  TNEGATE  T+  ;

: F-   ( f1 f2 -> f3 )
  FNEGATE F+  ;

: F+!   ( f1 addr -> )
  DUP  >R  F@ F+  R>  F!  ;

: T+!  ( t1 addr -> )
  DUP >R  T@ T+  R>  T! ;
( conversions  D->F )
HEX     ( may be replaced with CODE definitions )
: D->T   ( d1 -> t2 )   ( floats the integer value )
  DUP >R  DABS  01E UDNORMALIZE   R> T+-  CHK0  ;

: D->F   ( d1 -> f2 )
   D->T  T->F  ;

: T->D   ( t1 -> d2 )
  CHK0   01E -   DUP ABS   01E >
  IF  TDROP 0 0
  ELSE  DUP 0>
     IF  DLSLN
     ELSE  OVER  >R >R  7FFF AND  R> ABS DLSRN
        R> D+-  THEN THEN ;
DECIMAL
( conversions  F->D  F->S  S->F  )
DECIMAL
: F->D   ( f1 -> d2 )
   F->T T->D  ;

: F->S   ( f1 -> n2 )
    F->D DROP  ;

: S->F   ( n1 -> f2 )
    S->D D->F  ;






( floating comparisons  F0< F0>   F= F< F> )
DECIMAL
: F0<          D0<  ;

: F0>          D0>  ;

: F=           D=   ;

: F<   ( f1 f2 -> flag )
  F- F0<  ;

: F>   ( f1 f2 -> flag )
  FSWAP  F<  ;



( FMIN  FMAX  F+-  FSGN  )
DECIMAL
: FMIN   ( f1 f2 -> f3 )
  FOVER FOVER  F>  IF  FSWAP  THEN  FDROP  ;

: FMAX   ( f1 f2 -> f3 )
  FOVER FOVER  F<  IF  FSWAP  THEN  FDROP  ;

: F+-   ( f1 n2 -> f3 )
  0<  IF  FNEGATE  THEN  ;

: FSGN   ( f1 -> n2 )
  SWAP DROP  SGN  ;



( integer & fractional portion  INT  FRAC  REM )
HEX
: INT   ( f1 -> f2 )
  F->T  DUP  01F <  IF  T->D D->T THEN   T->F  ;

: TFRAC   ( t1 -> t2 )
  DUP 01F <  IF  TDUP T->D D->T T-
             ELSE  TDROP 0 0 0  THEN  ;

: FRAC   ( f1 -> f2 )
  F->T TFRAC  T->F  ;

: REM   ( f1 f2 -> f3 )
   FOVER FOVER   F/   INT  F* F-  ;

DECIMAL
( floating point input  FCONVERT )
DECIMAL
: FCONVERT   ( f1 addr2 -> f3 addr4 )
  >R F->T   BASE @ 0 D->T  TSWAP R>
  BEGIN  1+ DUP >R  C@ BASE @ DIGIT
  WHILE  >R TOVER T*  R> 0 D->T  T+   DPL @ 1+
     IF  1 DPL +!  THEN      R>
  REPEAT  TSWAP TDROP T->F  R> ;








( floating point input  <FNUMBER> )
HEX
: <FNUMBER>   ( addr1 -> f2 )  QQQ 20 CMOVE QQQ
  0 0 ROT  DUP 1+ C@  2D = 1 AND  DUP >R  +  -1 DPL !
  FCONVERT  DUP C@ BL >
  IF DUP C@ 2E =  0= ( NOT)  ABORT" NOT RECOGNIZED"
     0 DPL !  FCONVERT DUP C@ BL >  ABORT" NOT RECOGNIZED"
  THEN    DROP R>
  IF  FNEGATE  THEN     F->T     DPL @
  BEGIN   DUP 0>
  WHILE  >R  BASE @ 0 D->T  T/  R> 1-
  REPEAT         DROP T->F  ;

DECIMAL


( ?? floating interpret  <FINTERPRET> )
DECIMAL
\ : <FINTERPRET>   ( -> )
\   BEGIN  -FIND
\      IF STATE @ <
\         IF  CFA ,
\         ELSE  CFA EXECUTE  THEN
\      ELSE  HERE  NUMBER DPL @ 1+
\         IF  [COMPILE] FLITERAL
\         ELSE F->S [COMPILE] LITERAL  THEN
\      THEN  ?STACK
\  AGAIN ;




( ??? FMODE  FINP# )
DECIMAL
\ : FMODE   ( -> )
\   2 <?MODE> !
\   ' <FNUMBER> CFA     'NUMBER !
\   ' <FINTERPRET> CFA  'INTERPRET !
\   R> DROP   INTERPRET  ;     IMMEDIATE

: FINP#   ( -> f )  ( "state-smart" word )
  BL WORD  <FNUMBER>
  [COMPILE] FLITERAL  ;     IMMEDIATE





( floating point input  TCONVERT )
DECIMAL
: TCONVERT   ( t1 addr2 -> t3 addr4 )
  >R        BASE @ 0 D->T  TSWAP R>
  BEGIN  1+ DUP >R  C@ BASE @ DIGIT
  WHILE  >R TOVER T*  R> 0 D->T  T+   DPL @ 1+
     IF  1 DPL +!  THEN      R>
  REPEAT  TSWAP TDROP       R> ;








( floating point input  <TNUMBER> )
HEX
: <TNUMBER>   ( addr1 -> t2 )  QQQ 20 CMOVE QQQ
  0 0 ROT  0 SWAP DUP 1+ C@  2D = 1 AND   DUP >R  +  -1 DPL !
  TCONVERT  DUP C@ BL >
  IF DUP C@ 2E =  0= ( NOT)  ABORT" NOT RECOGNIZED"
     0 DPL !  TCONVERT DUP C@ BL >  ABORT" NOT RECOGNIZED"
  THEN    DROP R>
  IF  TNEGATE  THEN              DPL @
  BEGIN   DUP 0>
  WHILE  >R  BASE @ 0 D->T  T/  R> 1-
  REPEAT         DROP  ;

DECIMAL


(  TINP# )
DECIMAL
: TINP#   ( -> f )  ( "state-smart" word )
  BL WORD  <TNUMBER>
  STATE @   IF
     >R  [COMPILE] DLITERAL R> [COMPILE] LITERAL
  THEN ;    IMMEDIATE









( TSLOG2 calculation  0.5 <= x <= 1.0  taylor series ln/ln2 )
DECIMAL
: TSLOG2     ( t1 -> t2 )       ( 0.5 <= t1 <=1 )
  TABS   T0=  IF EXIT THEN
  TDUP  TINP# -1 T+   TSWAP   TINP# 1 T+  T/
  TDUP TDUP T* TERM T!
  TDUP TINP# 2.885390082 ( 2/ln2 ) T*  FTERM T!  TERM T@ T*
  TDUP TINP# .9617966939 T*  ( 2/3ln2 ) FTERM T+!   TERM T@ T*
  TDUP TINP# .5770780164 T*  ( 2/5ln2 ) FTERM T+!   TERM T@ T*
  TDUP TINP# .4121985831 T*  ( 2/7ln2 ) FTERM T+!   TERM T@ T*
  TDUP TINP# .3205988980 T*  ( 2/9ln2 ) FTERM T+!   TERM T@ T*
  TDUP TINP# .2623081893 T*  ( 2/11ln2 ) FTERM T+!   TERM T@ T*
  TDUP TINP# .2219530832 T*  ( 2/13ln2 ) FTERM T+!   TERM T@ T*
  TDUP TINP# .1923593388 T*  ( 2/15ln2 ) FTERM T+!   TERM T@ T*
  TINP# .1697288283 T*  ( 2/17ln2 ) FTERM T@ T+ ;

( chebyshev TS2**   calculation   0.0 <= x <= 1.0 )
DECIMAL
: TS2**      ( t1 -> t2 )       ( 0 <= t1 <=1 )
  TABS   TDUP TERM T!     TINP# 1.0  FTERM T!   ( x**0 )
  TDUP TINP# .69314718 T*  ( x**1 ) FTERM T+!   TERM T@ T*
  TDUP TINP# .24022636 T*  ( x**2 ) FTERM T+!   TERM T@ T*
  TDUP TINP# .055505294 T*  ( x**3 ) FTERM T+!   TERM T@ T*
  TDUP TINP# .0096135358 T*  ( x**4 ) FTERM T+!   TERM T@ T*
  TDUP TINP# .0013429811 T*  ( x**5 ) FTERM T+!   TERM T@ T*
  TDUP TINP# .00014299401 T*  ( x**6 ) FTERM T+!   TERM T@ T*
  TINP# .000021651724 T*  ( x**7 ) FTERM T@ T+  ;





( basic logarithm  LOG2 )
DECIMAL
: TLOG2   ( t1 -> t2 )
  T0=  3 PICK 0< OR   DUP
  IF ( BAD OPERATION )    DROP TABS T0= THEN
  0= ( NOT)   IF  >R  -1 TSLOG2
     R> 1+  S->D D->T  T+  THEN  ;

: LOG2   ( f1 -> f2 )
   F->T  TLOG2  T->F  ;






( basic exponentiation  2** )
HEX
: T2**   ( t1 -> t2 )
  OVER >R ( sign )
  TABS  TDUP T->D  DDUP F>R  D->T  T-
  TS2**   FR> DROP +   R> 0<
  IF  40000000. 0 ( t=1.0 )    TSWAP T/  THEN  ;

: 2**   ( f1 -> f2 )
  F->T  T2**  T->F  ;

DECIMAL




( LOGB  F** )
DECIMAL
: TLOGB   ( t1 tbase -> t3 )   ( log to a base )
  TSWAP  TLOG2  TSWAP  TLOG2  T/  ;

: LOGB   ( f1 f2 -> f3 )
  SEPARATE2  TLOGB  T->F  ;

: F**   ( f1 f2 -> f3 )
  FSWAP  SEPARATE2  TLOG2  T*  T2**   T->F  ;






( LOG  LN  10**  E**  )
HEX
: LOG   ( f1 -> f2 )
  41200000.  ( f=10.0 )  LOGB  ;

: LN   ( f1 -> f2 )
  402DF854.  ( f=2.7182818 )   LOGB ;

: 10**   ( f1 -> f2 )
  41200000.  ( f=10.0 ) FSWAP  F**  ;

: E**   ( f1 -> f2 )
  402DF854.  ( f=2.7182818 )  FSWAP  F**  ;

DECIMAL

( ROOT  **2  1/X  EXP  )
DECIMAL
: ROOT   ( f1 f2 -> f3 )
  SEPARATE2 TSWAP  TLOG2  TSWAP T/  T2**  T->F  ;

: **2   ( f1 -> f2 )
  FDUP F*  ;

: 1/X   ( f1 -> f2 )
  FINP# 1  FSWAP F/  ;

: EXP   ( f1 n -> f2 )
  S->D D->F  BASE @ 0 D->F  FSWAP  F**  F*  ;



( floating to alpha conversion  F->ME )
HEX
: F->ME   ( f1 -> d2 n3 )
  F->T  T0= 0= ( NOT)
  IF  OVER >R TABS  BASE @ 0 D->T TSWAP TOVER
     TLOGB  TDUP TFRAC  TSWAP  T->D  DROP  2 PICK 0<
     IF  1- >R  40000000. 0 ( t=1.0 ) T+  R> THEN
     >R  ( log almost 1? ) BASE @ 0 DDUP
     SIGDIG @  1  DO  FOVER D*  LOOP
     -1 M+  F>R D->T FR>  D->T
     TSWAP TLOGB TFRAC  TOVER  T- DROP F0<
     IF  TDROP 0 0 0  R> 1+ >R  THEN
     SIGDIG @ 1-  0 D->T
     T+ TSWAP TLOG2 T* T2**   40000000. -1  ( 0.5 )
     T+ T->D   R> R> SWAP  >R D+- R>  THEN  ;
DECIMAL
( exponent print  F.ER  F.E  )
HEX
: F.ER   ( f1 n2 -> )
  >R  F->ME   DUP >R ABS  S->D
  <# #S  DDROP  R> SIGN  BL HOLD
  50 HOLD  58 HOLD  45 HOLD  BL HOLD   DUP >R DABS
  SIGDIG @  1  DO  #  LOOP
  2E HOLD  #  R> SIGN  #>
  R>  OVER -  SPACES TYPE  ;

: F.E   ( f1 -> )
  0 F.ER  SPACE  ;

DECIMAL


( fixed point numeric printing  <F.>  F.XR  F.X )
HEX
: <F.>   ( d1 n2 -> addr3 n4 n5 )
  SIGDIG @ - 1+  NEGATE DUP  0 MAX  >R OVER >R
  >R  DABS   <#  R@ 0 MAX    ?DUP
  IF  0  DO  #  LOOP  THEN
  2E HOLD    R@ 0<
  IF  R@ ABS  0  DO  30 HOLD  LOOP  THEN
  R> DROP   #S  R> SIGN  #>   R>  ;

: F.XR   ( f1 n2 -> )
  >R F->ME  <F.> DROP  R> OVER -  SPACES TYPE  ;

: F.X   ( f1 -> )
  0 F.XR  SPACE  ;
DECIMAL
( aligned fixed point print  F.AR  F.A )
HEX
: F.AR   ( f1 n2 n3 -> )
  >R  0 MAX  >R  F->ME   SIGDIG @  OVER - 1-   R@ -  DUP 0>
  IF  SWAP >R  S->F  10**  F2/  F->D D+
     R>  <F.>  R> - -
     ELSE  DROP <F.>  R>   DDUP <
        IF  SWAP -  2 PICK 2 PICK +  OVER  30 FILL +
        ELSE  DDROP   THEN     THEN
  R>  OVER -  SPACES TYPE  ;

: F.A   ( f1 n2 -> )
  0 F.AR  SPACE  ;

DECIMAL

( smart floating point prints  F.R  F.  F?  )
HEX
: F.R   ( f1 n2 -> )
  >R  FDUP F->T   DUP 17 >  SWAP -4 <  OR
  IF  DDROP R>  F.ER
  ELSE  DDROP  F->ME  <F.>  DROP
  BEGIN  DDUP + 1- C@     30 =
  WHILE  1-  REPEAT
  R>  OVER -  SPACES TYPE  THEN  ;

: F.  ( FP# -> )
  0 F.R SPACE ;

: F?     F@ F. ;

DECIMAL
( SQRT  FACTORIAL )
DECIMAL
: SQRT   ( f1 -> f2 )
  FABS    F->T  TDUP TERM T!
  ( initial approximation is f1/2 )     ASR 1-
  5 0  DO  TERM T@  TOVER T/  T+  1-  LOOP
  T->F  ;

: FACTORIAL   ( f1 -> f2 )
  FINP# 1  FSWAP  F->S  ABS
  1+ 1 DO   I  S->F  F*   LOOP  ;





( PI  PI/2  PI/4  2*PI  RAD->DEG  DEG->RAD )
DECIMAL
FINP# 3.14159265 FCONSTANT PI
PI   F2/ FCONSTANT PI/2
PI/2 F2/ FCONSTANT PI/4
PI   F2* FCONSTANT 2*PI

: RAD->DEG   ( f1 -> f2 )
  FINP# 57.29577951 F* ;

: DEG->RAD   ( f1 -> f2 )
  FINP# 0.0174532925 F*  ;




( chebyshev sine routine )
DECIMAL
: TSIN   ( t1 -> t2 )
  ( input from -pi/4 TO pi/4 )
  TDUP  TDUP T* TERM T!
  TDUP TINP# .9999999995 ( x**1 ) T*  FTERM T!
  TERM T@ T*  TDUP  TINP# -.1666666663 ( x**3 ) T* FTERM T+!
  TERM T@ T*  TDUP  TINP# .008333328785 ( x**5 ) T* FTERM T+!
  TERM T@ T*  TDUP  TINP# -.0001983920268 ( x**7 ) T* FTERM T+!
  TERM T@ T*  TINP# .000002717349463 ( x**9 )  T* FTERM T@ T+ ;






( chebyshev cosine routine )
DECIMAL
: TCOS   ( t1 -> t2 )
  ( input from -pi/4 to pi/4 )
  TDUP T* TDUP TERM T!
  TDUP TINP# -.4999999943 ( x**2 ) T*  FTERM T!
  TERM T@ T*  TDUP  TINP# .0416666167 ( x**4 ) T* FTERM T+!
  TERM T@ T*  TDUP  TINP# -0.001388661862 ( x**6 ) T* FTERM T+!
  TERM T@ T*  TINP# .00002437988031 ( x**8 )  T* FTERM T@ T+
  TINP# 1.0  T+ ;






( full range cosine and sine  <COS>  <SIN>  )
DECIMAL
: <COS>  ( FP# -> FP# )
  FABS  2*PI REM   FDUP PI F>
  IF  FNEGATE  2*PI F+  THEN
  FDUP  PI/2  F>
  IF  FNEGATE  PI F+  -1 >R   ELSE   1 >R  THEN
  FDUP  PI/4 F>
  IF  FNEGATE  PI/2 F+  F->T TSIN T->F
  ELSE  F->T TCOS T->F  THEN
  R> F+-  ;

: <SIN>   ( f1 -> f2 )
  FNEGATE   PI/2 F+   <COS>  ;


( derived trig functions  <TAN>  <SEC>  <CSC>  <COT> )
DECIMAL
: <TAN>   ( f1 -> f2 )
  FDUP <SIN>  FSWAP <COS>  F/  ;

: <SEC>   ( f1 -> f2 )
  <COS>  1/X  ;

: <CSC>   ( f1 -> f2 )
  <SIN>  1/X  ;

: <COT>   ( f1 -> f2 )
  FDUP <COS>  FSWAP <SIN>  F/  ;



( trig functions  COS  SIN  TAN  SEC  CSC  COT  )
DECIMAL
: COS   ( f1 -> f2 )
  DEG->RAD  <COS>  ;
: SIN   ( f1 -> f2 )
  DEG->RAD  <SIN>  ;
: TAN   ( f1 -> f2 )
  DEG->RAD  <TAN>  ;

: SEC   ( f1 -> f2 )
  DEG->RAD  <SEC>  ;
: CSC   ( f1 -> f2 )
  DEG->RAD  <CSC>  ;
: COT   ( f1 -> f2 )
  DEG->RAD  <COT>  ;

( chebyshev arctangent routine )
DECIMAL
: TATAN   ( t1 -> t2 )
  ( input from -1 to 1 )
  TDUP  TDUP T* TERM T!
  TDUP TINP# .9999999842 ( x**1 ) T*  FTERM T!
  TERM T@ T*  TDUP  TINP# -.3333306679 ( x**3 ) T* FTERM T+!
  TERM T@ T*  TDUP  TINP# .1999248354 ( x**5 ) T* FTERM T+!
  TERM T@ T*  TDUP  TINP# -.1420257041 ( x**7 ) T* FTERM T+!
  TERM T@ T*  TDUP  TINP# .1063675406 ( x**9 ) T* FTERM T+!
  TERM T@ T*  TDUP  TINP# -.0749544546 ( x**11 ) T* FTERM T+!
  TERM T@ T*  TDUP  TINP# .0425876076 ( x**13 ) T* FTERM T+!
  TERM T@ T*  TDUP  TINP# -.0160050306 ( x**15 ) T* FTERM T+!
  TERM T@ T*  TINP# .0028340643 ( x**17 )  T* FTERM T@ T+ ;


( basic inverse trig function  <ATAN> <ATAN2>  )
DECIMAL
: <ATAN>   ( f1 -> f2 )
  FDUP FABS  FINP# 1  F>
  IF  DUP >R  FINP# 1  FSWAP F/  F->T TATAN T->F
     FNEGATE   PI/2  R> F+-  F+
  ELSE  F->T TATAN T->F  THEN  ;

: <ATAN2>   ( fx fy -> f3 )
  FOVER F0=
  IF  >R DROP FDROP  PI/2  R> F+-
  ELSE  FOVER F0<
     IF  FDUP F0<  >R  FSWAP F/  <ATAN>  PI  R>
        IF  F-  ELSE  F+  THEN
     ELSE   FSWAP F/  <ATAN>   THEN THEN ;

( derived inverse trig  <ASIN>  <ACOS>  <ACOT>  )
DECIMAL
: <ASIN>   ( f1 -> f2 )
  FDUP FABS  FINP# 1  F=
  IF  SWAP DROP  PI/2  ROT F+-
  ELSE  FINP# 1  FOVER  **2  F-  SQRT F/  <ATAN>  THEN  ;

: <ACOS>   ( f1 -> f2 )
  <ASIN> FNEGATE   PI/2 F+  ;

: <ACOT>   ( f1 -> f2 )
  <ATAN> FNEGATE   PI/2 F+  ;




( derived inverse trig  <ASEC>  <ACSC>  )
DECIMAL
: <ASEC>   ( f1 -> f2 )
  FDUP  **2  FINP# -1  F+  SQRT  <ATAN> FSWAP   F0<
  IF  PI F- THEN   ;

: <ACSC>  ( FP# -> FP# )
  FDUP  FABS  FINP# 1  F=
  IF  SWAP DROP  PI/2  ROT F+-
  ELSE  FDUP  **2 FINP# -1  F+
     SQRT 1/X    <ATAN> FSWAP   F0<
     IF  PI F- THEN  THEN  ;




( trig functions  ACOS  ASIN  ATAN  ASEC  ACSC  ACOT  ATAN2 )
DECIMAL
: ACOS   ( f1 -> f2 )
  <ACOS>  RAD->DEG  ;
: ASIN   ( f1 -> f2 )
  <ASIN>  RAD->DEG  ;
: ATAN   ( f1 -> f2 )
  <ATAN>  RAD->DEG  ;
: ASEC   ( f1 -> f2 )
  <ACSC>  RAD->DEG  ;
: ACSC   ( f1 -> f2 )
  <ACSC>  RAD->DEG  ;
: ACOT   ( f1 -> f2 )
  <ACOT>  RAD->DEG  ;
: ATAN2   ( fx fy -> f3 )
  <ATAN2>  RAD->DEG  ;
( <P->R>  <R->P>  P->R  R->P  )
DECIMAL
: <P->R>   ( frad fang -> fx fy )
  FOVER FOVER  <SIN>  F* F>R
  <COS>  F* FR>  ;

: <R->P>   ( fx fy -> frad fang )
  FOVER FOVER  <ATAN2> F>R
  **2 FSWAP  **2 F+  SQRT FR>  ;

: P->R   ( frad fang -> fx fy )
  DEG->RAD  <P->R>  ;

: R->P   ( fx fy -> frad fang )
  <R->P>  RAD->DEG ;

















( TEST SCREEN FOR FLOATING POINT )
DECIMAL
: TEST-TRIG  CR
 ." ANGLE     SIN         COS         TAN       ATAN(TAN)"
 CR
 ." -----  ----------  ----------  ----------  ----------"
 CR
 91 0 DO
    I S->F FDUP       1 5 F.AR
           FDUP  SIN  6 12 F.AR
           FDUP  COS  6 12 F.AR
           FDUP  TAN  6 12 F.AR
           TAN  ATAN  6 12 F.AR  CR
   LOOP ;


















( SPEED TEST )

: SPEED
  PI 100 0 DO   TAN ATAN LOOP
  1000 0 DO  PI F* PI F/ LOOP
  CR F. CR PI F. CR ;










































































































































































































































































































































































































































































































































































































































































































































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
  FINP# 1.0     BEGIN
     KEY?  ABORT" BREAK..."
     FOVER FOVER  CAN    FINP# 0.25  F+
     FDUP  FINP# 4.25  F<  NOT  UNTIL
  FDROP FDROP CR ;

( Floating Point problem solution - 4 )
DECIMAL
: RESULTS   ( -> )
  .HEADER
  FINP# 1.0   BEGIN
     FDUP  CAN-HEIGHT     FINP# 0.5 F+
     FDUP  FINP# 5.5   F<  NOT    UNTIL
  FDROP  ;








( Calculation speed and accuracy benchmark )
( Adapted from BYTE magazine )
(   Volume 10, No. 5, MAY 1985, page 280 )
FMODE
2.71828 FCONSTANT FA
3.14159 FCONSTANT FB

: CALCULATIONS   ( -> )
   1.0
   5000 0 DO    FA F*  FB  F*
                FA F/  FB  F/   LOOP
  CR  ." DONE"  CR  ." ERROR="  1.0  F- F.  ;
DMODE



































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































