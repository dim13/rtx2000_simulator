\ /* perm.c */
\ Improved source code GNU C for RTX 2000

EMPTY
: XY " DOS XY perm.d.4th" EVALUATE ;

DECIMAL
load gnutool.4th

VARIABLE permarray   24   CELL- ALLOT
VARIABLE pctr   4   CELL- ALLOT

#REGS 100 - REG-ADDR $FFC0 AND  UBR!

: do_error
 ." Error in Perm."  cr
   ;

 ( 13  top> #2x )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : Swap_el  ( FUNC )   ( 3  top> empty )
 ( #4 dummy reload )  ( 4  top> empty )
 ( #5 dummy reload )  ( 5  top> #64 )
 OVER          ( #64)  ( 9  top> #65 #64 )
 @                ( 9  top> #0x #65 #64 )
 2 U!            ( 9  top> #66 #65 #64 )
 DUP           ( #65)  ( 10  top> #65 #64d )
 @                ( 10  top> #0x #65 #64d )
 ROT              ( 10  top> #0x #65 #64d )
 !                ( 10  top> #64x #0x #65 )
 [ 2 ]  U@_SWAP  ( 11  top> #65d )
 !                ( 11  top> #65d #66x )
   ;  ( END )   

 ( 12  top> empty )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : Initialize  ( FUNC )   ( 3  top> empty )
 1  ( LIT)       ( 6  top> empty )
 [ 007 ADD_INDEX ] >R   ( 35  top> #64 )
 ( TYPE 1 LOOP BEGIN)  ( 7  top> empty )
 [ 007 ] LABEL     ( 23  top> empty )
 [ 007 ]  INDEX  ( 15  top> empty )
 2*               ( 15  top> #64x )
 [ permarray ] SYMBOL_+  ( 16  top> #67d )
 [ 007 ]  INDEX  ( 18  top> #68d )
 1  ( LIT)       ( 18  top> #64x #68d )
 -                ( 18  top> #0x #64x #68d )
 SWAP !           ( 18  top> #0x #68d )
 R>               ( 22  top> empty )
 1  ( LIT)       ( 22  top> #64x )
 +                ( 22  top> #0x #64x )
 DUP_>R   ( #64 )  ( 10  top> #64 )
 7  ( LIT)       ( 10  top> #64x )
 U>               ( 11  top> #65x #64x )
 [ 007 ] BRANCHZ   ( 11  top> #0x )
 [ 007 DROP_INDEX ] R>DROP  ( 28  top> empty )
 EXIT  [ 008 ] LABEL     ( 36  top> empty )
   ;  ( END )   

 ( 30  top> empty )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : Permute  ( FUNC )   ( 3  top> empty )
 ( #4 dummy reload )  ( 4  top> empty )
 1  ( LIT)       ( 10  top> #64 )
 pctr  ( SYMBOL)    ( 10  top> #0x #64 )
 +!               ( 10  top> #0x #0x #64 )
 [ 2 ] DUP_U!         ( 13  top> #64 )
 1  ( LIT)       ( 13  top> #64x )
 -                ( 14  top> #69x #64x )
 [ 0010 ] BRANCHZ   ( 14  top> #0x )
 2 U@            ( 19  top> empty )
 1  ( LIT)       ( 19  top> #64x )
 -                ( 19  top> #0x #64x )
 ( #4 Calling Arg )  ( 21  top> #4 )
 -64 FP+!  ( Link)   ( 21  top> empty )
RECURSE \    Permute  ( CALL)    ( 21  top> empty )
 64 FP+!  ( Unlink)  ( 21  top> empty )
 2 U@            ( 24  top> empty )
 2*               ( 24  top> #64x )
 [ permarray ] SYMBOL_+  ( 25  top> #71d )
 DUP           ( #66)  ( 27  top> #66 )
 2  ( LIT)       ( 27  top> #0x #66 )
 -                ( 27  top> #0x #0x #66 )
 [                ( 75  top> #65 #66 )
 permarray  ( SYMBOL)    ( 75  top> #65 #66 )
 2  ( LIT)       ( 75  top> #0x #65 #66 )
 +                ( 75  top> #0x #0x #65 #66 )
 ] LITERAL        ( 75  top> #0x #65 #66 )
 ROT              ( 76  top> #72d #65 #66 )
 3 U!            ( 76  top> #66 #72d #65 )
 OVER          ( #65)  ( 76  top> #72d #65 )
 4 U!            ( 76  top> #65 #72d #65x )
 U<               ( 78  top> #72x #65x )
 [ 0015 ] BRANCHNZ  ( 78  top> #0x )
 ( LOOP_BEGIN)    ( 29  top> empty )
 [ 0014 ] LABEL     ( 62  top> empty )
 3 U@            ( 38  top> empty )
 4 U@            ( 39  top> #4 )
 ( #5 Calling Arg )  ( 42  top> #5 #4 )
 ( #4 Calling Arg )  ( 42  top> #4 )
 -64 FP+!  ( Link)   ( 42  top> empty )
   Swap_el  ( CALL)    ( 42  top> empty )
 64 FP+!  ( Unlink)  ( 42  top> empty )
 2 U@            ( 46  top> empty )
 1  ( LIT)       ( 46  top> #64x )
 -                ( 46  top> #0x #64x )
 ( #4 Calling Arg )  ( 48  top> #4 )
 -64 FP+!  ( Link)   ( 48  top> empty )
RECURSE \   Permute  ( CALL)    ( 48  top> empty )
 64 FP+!  ( Unlink)  ( 48  top> empty )
 3 U@            ( 52  top> empty )
 4 U@            ( 53  top> #4 )
 ( #5 Calling Arg )  ( 56  top> #5 #4 )
 ( #4 Calling Arg )  ( 56  top> #4 )
 -64 FP+!  ( Link)   ( 56  top> empty )
   Swap_el  ( CALL)    ( 56  top> empty )
 64 FP+!  ( Unlink)  ( 56  top> empty )
 4 U@            ( 61  top> empty )
 2  ( LIT)       ( 61  top> #65x )
 -                ( 61  top> #0x #65x )
 [                ( 32  top> #65 )
 permarray  ( SYMBOL)    ( 32  top> #65 )
 2  ( LIT)       ( 32  top> #0x #65 )
 +                ( 32  top> #0x #0x #65 )
 ] LITERAL        ( 32  top> #0x #65 )
 OVER          ( #65)  ( 33  top> #72d #65 )
 4 U!            ( 33  top> #65 #72d #65x )
 U<               ( 34  top> #72x #65x )
 [ 0014 ] BRANCHZ   ( 34  top> #0x )
 ( LOOP_END)      ( 67  top> empty )
 [ 0015 ] LABEL     ( 77  top> empty )
 EXIT  [ 0010 ] LABEL     ( 69  top> empty )
   ;  ( END )   

 ( 70  top> empty )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : main  ( FUNC )   ( 3  top> empty )
#REGS 100 - REG-ADDR $FFC0 AND  UBR!
 1  ( LIT)       ( 6  top> empty )
 [ 0021 ADD_INDEX ] >R   ( 50  top> #64 )
 ( TYPE 1 LOOP BEGIN)  ( 7  top> empty )
 [ 0021 ] LABEL     ( 38  top> empty )
 0  ( LIT)       ( 14  top> empty )
 pctr  ( SYMBOL)    ( 14  top> #0x )
 !                ( 14  top> #0x #0x )
 -64 FP+!  ( Link)   ( 17  top> empty )
   Initialize  ( CALL)    ( 17  top> empty )
 64 FP+!  ( Unlink)  ( 17  top> empty )
 7  ( LIT)       ( 20  top> empty )
 ( #4 Calling Arg )  ( 22  top> #4 )
 -64 FP+!  ( Link)   ( 22  top> empty )
   Permute  ( CALL)    ( 22  top> empty )
 64 FP+!  ( Unlink)  ( 22  top> empty )
 pctr  ( SYMBOL)    ( 26  top> empty )
 @                ( 26  top> #0x )
 8660  ( LIT)       ( 28  top> #66x )
 -                ( 29  top> #67x #66x )
 [ 0019 ] BRANCHZ   ( 29  top> #0x )
 -64 FP+!  ( Link)   ( 31  top> empty )
   do_error  ( CALL)    ( 31  top> empty )
 64 FP+!  ( Unlink)  ( 31  top> empty )
 [ 0019 ] LABEL     ( 36  top> empty )
 R>               ( 37  top> empty )
 1  ( LIT)       ( 37  top> #64x )
 +                ( 37  top> #0x #64x )
 DUP_>R   ( #64 )  ( 10  top> #64 )
 250  ( LIT)       ( 10  top> #64x )
 U>               ( 11  top> #65x #64x )
 [ 0021 ] BRANCHZ   ( 11  top> #0x )
 [ 0021 DROP_INDEX ] R>DROP  ( 43  top> empty )
 EXIT  [ 0022 ] LABEL     ( 51  top> empty )
   ;  ( END )   

 ( 45  top> empty )

.( max 250) cr
