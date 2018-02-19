\ /* matmul.c */
\ Improved source code GNU C for RTX 2000

EMPTY
: XY " DOS XY matmul.d.4th" EVALUATE ;

DECIMAL

load gnutool.4th
#REGS 100 - REG-ADDR $FFC0 AND  UBR!

VARIABLE seed   4   CELL- ALLOT
VARIABLE imr   3364   CELL- ALLOT
VARIABLE imb   3364   CELL- ALLOT
VARIABLE ima   3364   CELL- ALLOT

\ gcc_compiled.:


( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : Initrand  ( FUNC )   ( 3  top> empty )
 9219  ( LIT)       ( 6  top> empty )
 seed  ( SYMBOL)    ( 6  top> #0x )
 !                ( 6  top> #0x #0x )
   ;  ( END )   

 ( 6  top> empty )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : Rand  ( FUNC )   ( 3  top> empty )
 seed  ( SYMBOL)    ( 6  top> empty )
 @                ( 6  top> #0x )
 1309  ( LIT)       ( 6  top> #0x )
 *                ( 6  top> #0x #0x )
 13849  ( LIT)       ( 8  top> #64d )
 +                ( 8  top> #0x #0x )
 seed  ( SYMBOL)    ( 10  top> #0x )
 TUCK_! ( #0)    ( 10  top> #0x #0x )
   ;  ( END )   

 ( 11  top> #2 )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : Initmatrix  ( FUNC )   ( 3  top> empty )
 ( #4 dummy reload )  ( 4  top> empty )
 1  ( LIT)       ( 8  top> #64 )
 2 U!            ( 74  top> #66 #64 )
 3 U!            ( 74  top> #64 )
 ( LOOP_BEGIN)    ( 9  top> empty )
 [ 0011 ] LABEL     ( 57  top> empty )
 2 U@            ( 16  top> empty )
 82  ( LIT)       ( 16  top> #66x )
 *                ( 16  top> #0x #66x )
 3 U@  +         ( 17  top> #70d )
 1  ( LIT)       ( 20  top> #68 )
 4 U!            ( 69  top> #67 #68 )
 5 U!            ( 69  top> #68 )
 ( LOOP_BEGIN)    ( 21  top> empty )
 [ 0010 ] LABEL     ( 46  top> empty )
 -64 FP+!  ( Link)   ( 30  top> empty )
   Rand  ( CALL)    ( 30  top> empty )
 64 FP+!  ( Unlink)  ( 30  top> #2x )
 4 U@            ( 34  top> #73 )
 2*               ( 34  top> #67x #73 )
 5 U@  +         ( 35  top> #74d #73 )
 OVER          ( #73)  ( 36  top> #75 #73 )
 120  ( LIT)       ( 36  top> #0x #75 #73 )
 /                ( 36  top> #0x #0x #75 #73 )
 120  ( LIT)       ( 37  top> #76d #75 #73 )
 *                ( 37  top> #0x #0x #75 #73 )
 2_PICK   ( LAST #73)  ( 38  top> #77d #75 #73d )
 SWAP-            ( 38  top> #0x #77d #75 #73d )
 60  ( LIT)       ( 40  top> #78d #75d #73d )
 -                ( 40  top> #0x #0x #75d #73d )
 SWAP !           ( 40  top> #0x #75d #73d )
 DROP             ( 40  top> #73d )
 4 U@            ( 45  top> empty )
 1  ( LIT)       ( 45  top> #67x )
 +                ( 45  top> #0x #67x )
 [ 4 ] DUP_U!         ( 24  top> #67 )
 40  ( LIT)       ( 24  top> #67x )
 >                ( 25  top> #72x #67x )
 [ 0010 ] BRANCHZ   ( 25  top> #0x )
 ( TYPE 1 LOOP END)  ( 51  top> empty )
 [ 0012 ] LABEL     ( 70  top> empty )
 2 U@            ( 56  top> empty )
 1  ( LIT)       ( 56  top> #66x )
 +                ( 56  top> #0x #66x )
 [ 2 ] DUP_U!         ( 12  top> #66 )
 40  ( LIT)       ( 12  top> #66x )
 >                ( 13  top> #69x #66x )
 [ 0011 ] BRANCHZ   ( 13  top> #0x )
 ( TYPE 1 LOOP END)  ( 62  top> empty )
 EXIT  [ 0013 ] LABEL     ( 75  top> empty )
   ;  ( END )   

 ( 64  top> empty )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : Innerproduct  ( FUNC )   ( 3  top> empty )
 ( #4 dummy reload )  ( 4  top> empty )
 ( #5 dummy reload )  ( 5  top> #64 )
 ( #6 dummy reload )  ( 6  top> #65 #64 )
 ( #7 dummy reload )  ( 7  top> #66 #65 #64 )
 [ 2 ] MEM_ARG@  ( 8  top> #67 #66 #65 #64 )
 2 U!            ( 8  top> #68 #67 #66 #65 #64 )
 [ 3 ] DUP_U!         ( 8  top> #67 #66 #65 #64 )
 SWAP             ( 8  top> #67 #66 #65 #64 )
 4 U!            ( 12  top> #66 #67 #65 #64 )
 82  ( LIT)       ( 12  top> #67x #65 #64 )
 *                ( 12  top> #0x #67x #65 #64 )
 +                ( 13  top> #72d #65d #64 )
 0  ( LIT)       ( 15  top> #71 #64 )
 1  ( LIT)       ( 17  top> #70 #71 #64 )
 5 U!            ( 52  top> #69 #70 #71 #64 )
 6 U!            ( 52  top> #70 #71 #64 )
 7 U!            ( 52  top> #71 #64 )
 8 U!            ( 52  top> #64 )
 5 U@            ( 52  top> empty )
 40  ( LIT)       ( 52  top> #69x )
 <=               ( 54  top> #73x #69x )
 [ 0019 ] BRANCHZ   ( 54  top> #0x )
 2 U@            ( 55  top> empty )
 2*               ( 55  top> #68x )
 9 U!            ( 18  top> #78 )
 ( LOOP_BEGIN)    ( 18  top> empty )
 [ 0018 ] LABEL     ( 38  top> empty )
 5 U@            ( 25  top> empty )
 2*               ( 25  top> #69x )
 7 U@  +         ( 26  top> #74d )
 5 U@            ( 27  top> #75 )
 82  ( LIT)       ( 27  top> #69x #75 )
 *                ( 27  top> #0x #69x #75 )
 4 U@  +         ( 28  top> #76d #75 )
 9 U@  +         ( 30  top> #77d #75 )
 @_SWAP           ( 31  top> #79d #75d )
 @                ( 31  top> #79x #0x )
 *                ( 31  top> #0x #0x )
 6 U@  +         ( 32  top> #80d )
 1  ( LIT)       ( 37  top> #70 )
 5 U@ +   5 U!  ( 21  top> #0x #70 )
 6 U!            ( 21  top> #70 )
 5 U@            ( 21  top> empty )
 40  ( LIT)       ( 21  top> #69x )
 >                ( 22  top> #73x #69x )
 [ 0018 ] BRANCHZ   ( 22  top> #0x )
 ( LOOP_END)      ( 43  top> empty )
 [ 0019 ] LABEL     ( 53  top> empty )
 6 U@            ( 46  top> empty )
 8 U@  !         ( 46  top> #70x )
   ;  ( END )   

 ( 47  top> empty )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : main  ( FUNC )   ( 3  top> empty )
#REGS 100 - REG-ADDR $FFC0 AND  UBR!

 1  ( LIT)       ( 6  top> empty )
 [ 0032 ADD_INDEX ] >R   ( 110  top> #66 )
 ( TYPE 1 LOOP BEGIN)  ( 7  top> empty )
 [ 0032 ] LABEL     ( 90  top> empty )
 -64 FP+!  ( Link)   ( 15  top> empty )
   Initrand  ( CALL)    ( 15  top> empty )
 64 FP+!  ( Unlink)  ( 15  top> empty )
 ima  ( SYMBOL)    ( 18  top> empty )
 ( #4 Calling Arg )  ( 20  top> #4 )
 -64 FP+!  ( Link)   ( 20  top> empty )
   Initmatrix  ( CALL)    ( 20  top> empty )
 64 FP+!  ( Unlink)  ( 20  top> empty )
 imb  ( SYMBOL)    ( 24  top> empty )
 ( #4 Calling Arg )  ( 26  top> #4 )
 -64 FP+!  ( Link)   ( 26  top> empty )
   Initmatrix  ( CALL)    ( 26  top> empty )
 64 FP+!  ( Unlink)  ( 26  top> empty )
 1  ( LIT)       ( 30  top> #64 )
 [ 0031 ADD_INDEX ] >R   ( 106  top> #64 )
 ( TYPE 1 LOOP BEGIN)  ( 31  top> empty )
 [ 0031 ] LABEL     ( 79  top> empty )
 [ 0031 ]  INDEX  ( 38  top> empty )
 82  ( LIT)       ( 38  top> #64x )
 *                ( 38  top> #0x #64x )
 [ imr ] SYMBOL_+  ( 40  top> #70d )
 1  ( LIT)       ( 42  top> #67 )
 2 U!            ( 102  top> #65 #67 )
 3 U!            ( 102  top> #67 )
 ( LOOP_BEGIN)    ( 43  top> empty )
 [ 0030 ] LABEL     ( 68  top> empty )
 2 U@            ( 50  top> empty )
 2*               ( 50  top> #65x )
 2 U@            ( 53  top> #73 )
 [ 2 ] MEM_ARG!  ( 53  top> #65x #73 )
 3 U@  +         ( 54  top> #73d )
 ima  ( SYMBOL)    ( 55  top> #4 )
 imb  ( SYMBOL)    ( 56  top> #5 #4 )
 [ 0031 ]  INDEX  ( 57  top> #6 #5 #4 )
 ( #7 Calling Arg )  ( 62  top> #7 #6 #5 #4 )
 ( #6 Calling Arg )  ( 62  top> #6 #5 #4 )
 ( #5 Calling Arg )  ( 62  top> #5 #4 )
 ( #4 Calling Arg )  ( 62  top> #4 )
 -64 FP+!  ( Link)   ( 62  top> empty )
   Innerproduct  ( CALL)    ( 62  top> empty )
 64 FP+!  ( Unlink)  ( 62  top> empty )
 2 U@            ( 67  top> empty )
 1  ( LIT)       ( 67  top> #65x )
 +                ( 67  top> #0x #65x )
 [ 2 ] DUP_U!         ( 46  top> #65 )
 40  ( LIT)       ( 46  top> #65x )
 >                ( 47  top> #72x #65x )
 [ 0030 ] BRANCHZ   ( 47  top> #0x )
 ( TYPE 1 LOOP END)  ( 73  top> empty )
 [ 0033 ] LABEL     ( 103  top> empty )
 R>               ( 78  top> empty )
 1  ( LIT)       ( 78  top> #64x )
 +                ( 78  top> #0x #64x )
 DUP_>R   ( #64 )  ( 34  top> #64 )
 40  ( LIT)       ( 34  top> #64x )
 U>               ( 35  top> #69x #64x )
 [ 0031 ] BRANCHZ   ( 35  top> #0x )
 [ 0031 DROP_INDEX ] R>DROP  ( 84  top> empty )
 [ 0034 ] LABEL     ( 107  top> empty )
 R>               ( 89  top> empty )
 1  ( LIT)       ( 89  top> #66x )
 +                ( 89  top> #0x #66x )
 DUP_>R   ( #66 )  ( 10  top> #66 )
 24  ( LIT)       ( 10  top> #66x )
 U>               ( 11  top> #68x #66x )
 [ 0032 ] BRANCHZ   ( 11  top> #0x )
 [ 0032 DROP_INDEX ] R>DROP  ( 95  top> empty )
 EXIT  [ 0035 ] LABEL     ( 111  top> empty )
   ;  ( END )   


.( max 24) cr
