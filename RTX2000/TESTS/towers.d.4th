\ /* towers.c */
\ Improved source code GNU C for RTX 2000

EMPTY
: XY " DOS XY towers.d.4th" EVALUATE ;

DECIMAL
load gnutool.4th

#REGS 100 - REG-ADDR $FFC0 AND  UBR!

VARIABLE movesdone   4   CELL- ALLOT
VARIABLE freelist   4   CELL- ALLOT
VARIABLE cellspace   76   CELL- ALLOT
VARIABLE stack   8   CELL- ALLOT

: do_error
   ." Error in Towers." cr
   ;

: Error
   ." Error in Towers." cr
   ;


 ( 16  top> #2x )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

: Makenull  ( FUNC )   ( 3  top> empty )
 ( #4 dummy reload )  ( 4  top> empty )
 [ 0 ] LIT_SWAP  ( 8  top> #64d )
 !                ( 8  top> #64x #0x )
   ;  ( END )   


( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : Getelement  ( FUNC )   ( 3  top> empty )
 freelist  ( SYMBOL)    ( 8  top> empty )
 @                ( 8  top> #0x )
 0>               ( 8  top> #0x )
 [ 005 ] BRANCHZ   ( 9  top> #0x )
 freelist  ( SYMBOL)    ( 12  top> empty )
 @                ( 12  top> #0x )
 DUP           ( #64)  ( 16  top> #64 )
 2*               ( 16  top> #0x #64 )
 2*               ( 16  top> #0x #64 )
 [ cellspace ] SYMBOL_+  ( 17  top> #69d #64 )
 2  ( LIT)       ( 18  top> #70d #64 )
 +                ( 18  top> #0x #0x #64 )
 @                ( 18  top> #0x #64 )
 freelist  ( SYMBOL)    ( 18  top> #0x #64 )
 !                ( 18  top> #0x #0x #64 )
 [ 2 ] DUP_U!         ( 22  top> #2 )
 EXIT         ( [ 004 ] BRANCH )  ( 22  top> empty )
 [ 005 ] LABEL     ( 26  top> empty )
 -64 FP+!  ( Link)   ( 31  top> empty )
   Error  ( CALL)    ( 31  top> empty )
 64 FP+!  ( Unlink)  ( 31  top> empty )
 3 U@            ( 36  top> empty )
 EXIT  [ 004 ] LABEL     ( 43  top> empty )
   ;  ( END )   

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : Push  ( FUNC )   ( 3  top> empty )
 ( #4 dummy reload )  ( 4  top> empty )
 ( #5 dummy reload )  ( 5  top> #64 )
 0  ( LIT)       ( 9  top> #65 #64 )
 2 U!            ( 9  top> #66 #65 #64 )
 DUP           ( #65)  ( 11  top> #65 #64 )
 @                ( 11  top> #0x #65 #64 )
 3 U!            ( 14  top> #68 #65 #64 )
 4 U!            ( 14  top> #65 #64 )
 5 U!            ( 14  top> #64 )
 3 U@            ( 14  top> empty )
 0>               ( 14  top> #68x )
 [ 008 ] BRANCHZ   ( 15  top> #0x )
 3 U@            ( 18  top> empty )
 2*               ( 18  top> #68x )
 2*               ( 18  top> #0x )
 [ cellspace ] SYMBOL_+  ( 19  top> #71d )
 @                ( 20  top> #72d )
 5 U@            ( 21  top> #73x )
 <=               ( 22  top> #64x #73x )
 [ 108 ] BRANCHZ   ( 22  top> #0x )
 1  ( LIT)       ( 27  top> #66 )
\ *$LC3  ( SYMBOL)    ( 28  top> #66 )
\ 6 U!            ( 30  top> #4 #66 ) \ WARNING -- stack argument problem!

 2 U!            ( 30  top> #66 )
 -64 FP+!  ( Link)   ( 30  top> empty )
   Error  ( CALL)    ( 30  top> empty )
 64 FP+!  ( Unlink)  ( 30  top> empty )
 [ 008 ] LABEL     ( 34  top> empty )
 [ 108 ] LABEL     ( 34  top> empty )
 2 U@            ( 37  top> empty )
 [ 0010 ] BRANCHNZ  ( 38  top> #0x )
 -64 FP+!  ( Link)   ( 43  top> empty )
   Getelement  ( CALL)    ( 43  top> empty )
 64 FP+!  ( Unlink)  ( 43  top> #2x )
 DUP           ( #67)  ( 47  top> #67 )
 2*               ( 47  top> #0x #67 )
 2*               ( 47  top> #0x #67 )
 [ cellspace ] SYMBOL_+  ( 48  top> #76d #67 )
 [ 3 ]  U@_SWAP  ( 49  top> #77d #67 )
 2  ( LIT)       ( 49  top> #77d #68x #67 )
 +                ( 49  top> #0x #0x #68x #67 )
 !                ( 49  top> #0x #68x #67 )
 DUP           ( #67)  ( 51  top> #67 )
 4 U@  !         ( 51  top> #0x #67 )
 2*               ( 54  top> #67d )
 2*               ( 54  top> #0x )
 [ cellspace ] SYMBOL_+  ( 55  top> #79d )
 [ 5 ]  U@_SWAP  ( 56  top> #80d )
 !                ( 56  top> #80d #64x )
 EXIT  [ 0010 ] LABEL     ( 58  top> empty )
   ;  ( END )   

 ( 59  top> empty )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : Init  ( FUNC )   ( 3  top> empty )
 ( #4 dummy reload )  ( 4  top> empty )
 ( #5 dummy reload )  ( 5  top> #64 )
 OVER          ( #64)  ( 10  top> #65 #64 )
 4 U! \ 2 U!            ( 12  top> #4 #65 #64 ) WARNING -- stack argument problem!

 3 U!            ( 12  top> #65 #64 )
\ 4 U!            ( 12  top> #64 )
 -64 FP+!  ( Link)   ( 12  top> empty )
   Makenull  ( CALL)    ( 12  top> empty )
 64 FP+!  ( Unlink)  ( 12  top> empty )
 3 U@            ( 15  top> empty )
 [ 5 ] DUP_U!         ( 46  top> #66 )
 0>               ( 46  top> #66x )
 [ 0016 ] BRANCHZ   ( 48  top> #0x )
 ( LOOP_BEGIN)    ( 17  top> empty )
 [ 0015 ] LABEL     ( 34  top> empty )
 5 U@            ( 24  top> empty )
 4 U@            ( 25  top> #4 )
 ( #5 Calling Arg )  ( 28  top> #5 #4 )
 ( #4 Calling Arg )  ( 28  top> #4 )
 -64 FP+!  ( Link)   ( 28  top> empty )
   Push  ( CALL)    ( 28  top> empty )
 64 FP+!  ( Unlink)  ( 28  top> empty )
 5 U@            ( 33  top> empty )
 1  ( LIT)       ( 33  top> #66x )
 -                ( 33  top> #0x #66x )
 [ 5 ] DUP_U!         ( 20  top> #66 )
 0>               ( 20  top> #66x )
 [ 0015 ] BRANCHNZ  ( 21  top> #0x )
 ( LOOP_END)      ( 39  top> empty )
 EXIT  [ 0016 ] LABEL     ( 47  top> empty )
   ;  ( END )   


( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : Pop  ( FUNC )   ( 3  top> empty )
 ( #4 dummy reload )  ( 4  top> empty )
 DUP           ( #64)  ( 8  top> #64 )
 @                ( 8  top> #0x #64 )
 [ 2 ] DUP_U!         ( 10  top> #67 #64 )
 SWAP             ( 10  top> #67 #64 )
 3 U!            ( 10  top> #64 #67 )
 0>               ( 10  top> #67x )
 [ 0018 ] BRANCHZ   ( 11  top> #0x )
 2 U@            ( 16  top> empty )
 2*               ( 16  top> #67x )
 2*               ( 16  top> #0x )
 [ cellspace ] SYMBOL_+  ( 17  top> #71d )
 @                ( 18  top> #72d )
 2 U@            ( 22  top> #66 )
 2*               ( 22  top> #67x #66 )
 2*               ( 22  top> #0x #66 )
 [ cellspace ] SYMBOL_+  ( 23  top> #75d #66 )
 2  ( LIT)       ( 24  top> #76d #66 )
 +                ( 24  top> #0x #0x #66 )
 @                ( 24  top> #0x #66 )
 2 U@            ( 28  top> #65 #66 )
 2*               ( 28  top> #67x #65 #66 )
 2*               ( 28  top> #0x #65 #66 )
 [ cellspace ] SYMBOL_+  ( 29  top> #79d #65 #66 )
 freelist  ( SYMBOL)    ( 30  top> #80d #65 #66 )
 @_SWAP           ( 30  top> #0x #80d #65 #66 )
 2  ( LIT)       ( 30  top> #80x #0x #65 #66 )
 +                ( 30  top> #0x #0x #0x #65 #66 )
 !                ( 30  top> #0x #0x #65 #66 )
 3 U@            ( 32  top> #65 #66 )
 @                ( 32  top> #64x #65 #66 )
 freelist  ( SYMBOL)    ( 32  top> #0x #65 #66 )
 !                ( 32  top> #0x #0x #65 #66 )
 3 U@  !         ( 34  top> #65d #66 )
 [ 4 ] DUP_U!         ( 38  top> #2 )
 EXIT         ( [ 0017 ] BRANCH )  ( 38  top> empty )
 [ 0018 ] LABEL     ( 42  top> empty )
 -64 FP+!  ( Link)   ( 48  top> empty )
   Error  ( CALL)    ( 48  top> empty )
 64 FP+!  ( Unlink)  ( 48  top> empty )
 0  ( LIT)       ( 53  top> #2 )
 EXIT  [ 0017 ] LABEL     ( 60  top> empty )
   ;  ( END )   

 ( 60  top> empty )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : Move  ( FUNC )   ( 3  top> empty )
 ( #4 dummy reload )  ( 4  top> empty )
 ( #5 dummy reload )  ( 5  top> #64 )
 2 U!            ( 10  top> #65 #64d )
 ( #4 Calling Arg )  ( 13  top> #4 )
 -64 FP+!  ( Link)   ( 13  top> empty )
   Pop  ( CALL)    ( 13  top> empty )
 64 FP+!  ( Unlink)  ( 13  top> #2x )
 2 U@            ( 18  top> #4 )
 ( #5 Calling Arg )  ( 21  top> #5 #4 )
 ( #4 Calling Arg )  ( 21  top> #4 )
 -64 FP+!  ( Link)   ( 21  top> empty )
   Push  ( CALL)    ( 21  top> empty )
 64 FP+!  ( Unlink)  ( 21  top> empty )
 1  ( LIT)       ( 25  top> empty )
 movesdone  ( SYMBOL)    ( 25  top> #0x )
 +!               ( 25  top> #0x #0x )
   ;  ( END )   

 ( 26  top> empty )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : tower  ( FUNC )   ( 3  top> empty )
 ( #4 dummy reload )  ( 4  top> empty )
 ( #5 dummy reload )  ( 5  top> #64 )
 ( #6 dummy reload )  ( 6  top> #65 #64 )
 2 U!            ( 10  top> #66 #65 #64 )
 3 U!            ( 11  top> #65 #64 )
 4 U!            ( 11  top> #64 )
 2 U@            ( 11  top> empty )
 1  ( LIT)       ( 11  top> #66x )
 -                ( 12  top> #68x #66x )
 [ 0022 ] BRANCHNZ  ( 12  top> #0x )
 4 U@            ( 14  top> empty )
 2*               ( 14  top> #64x )
 3 U@            ( 16  top> #69 )
 2*               ( 16  top> #65x #69 )
 SWAP             ( 19  top> #71 #69d )
 [ stack ] SYMBOL_+  ( 19  top> #69x #71 )
 SWAP             ( 20  top> #4 #71d ) \ WARNING -- stack argument problem!

 [ stack ] SYMBOL_+  ( 20  top> #71x #4 )
 ( #5 Calling Arg )  ( 23  top> #5 #4 )
 ( #4 Calling Arg )  ( 23  top> #4 )
 -64 FP+!  ( Link)   ( 23  top> empty )
   Move  ( CALL)    ( 23  top> empty )
 64 FP+!  ( Unlink)  ( 23  top> empty )
 EXIT         ( [ 0023 ] BRANCH )  ( 25  top> empty )
 [ 0022 ] LABEL     ( 27  top> empty )
 6  ( LIT)       ( 30  top> empty )
 3 U@            ( 30  top> #0x )
 -                ( 30  top> #65x #0x )
 4 U@            ( 31  top> #73d )
 -                ( 31  top> #64x #0x )
 [ 8 ] dup_U!
 4 U@            ( 35  top> #67 )
 swap \ OVER          ( #67)  ( 36  top> #4 #67 ) WARNING -- stack argument problem!

 2 U@            ( 37  top> #5 #4 #67 )
 1  ( LIT)       ( 37  top> #66x #5 #4 #67 )
 -                ( 37  top> #0x #66x #5 #4 #67 )
\ 5 U!            ( 41  top> #6 #5 #4 #67 )
\ 6 U!            ( 41  top> #5 #4 #67 )
\ 7 U!            ( 41  top> #4 #67 ) \ WARNING -- stack argument problem!

\ 8 U!            ( 41  top> #67 )
 -64 FP+!  ( Link)   ( 41  top> empty )
recurse \   tower  ( CALL)    ( 41  top> empty )
 64 FP+!  ( Unlink)  ( 41  top> empty )
 4 U@            ( 43  top> empty )
 2*               ( 43  top> #64x )
 3 U@            ( 45  top> #75 )
 2*               ( 45  top> #65x #75 )
 SWAP             ( 48  top> #77 #75d )
 [ stack ] SYMBOL_+  ( 48  top> #75x #77 )
 SWAP             ( 49  top> #4 #77d ) \ WARNING -- stack argument problem!

 [ stack ] SYMBOL_+  ( 49  top> #77x #4 )
 ( #5 Calling Arg )  ( 52  top> #5 #4 )
 ( #4 Calling Arg )  ( 52  top> #4 )
 -64 FP+!  ( Link)   ( 52  top> empty )
   Move  ( CALL)    ( 52  top> empty )
 64 FP+!  ( Unlink)  ( 52  top> empty )
 8 U@            ( 56  top> empty )
 3 U@            ( 57  top> #4 )
 2 U@            ( 58  top> #5 #4 )
 1  ( LIT)       ( 58  top> #66x #5 #4 )
 -                ( 58  top> #0x #66x #5 #4 )
 ( #6 Calling Arg )  ( 62  top> #6 #5 #4 )
 ( #5 Calling Arg )  ( 62  top> #5 #4 )
 ( #4 Calling Arg )  ( 62  top> #4 )
 -64 FP+!  ( Link)   ( 62  top> empty )
recurse \   tower  ( CALL)    ( 62  top> empty )
 64 FP+!  ( Unlink)  ( 62  top> empty )
 EXIT  [ 0023 ] LABEL     ( 64  top> empty )
   ;  ( END )   

 ( 65  top> empty )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : main  ( FUNC )   ( 3  top> empty )
#REGS 100 - REG-ADDR $FFC0 AND  UBR!
 0  ( LIT)       ( 6  top> empty )
 [ 0033 ADD_INDEX ] >R   ( 108  top> #65 )
 ( TYPE 1 LOOP BEGIN)  ( 7  top> empty )
 [ 0033 ] LABEL     ( 90  top> empty )
 1  ( LIT)       ( 14  top> empty )
 [ 0031 ADD_INDEX ] >R   ( 102  top> #64 )
 ( TYPE 1 LOOP BEGIN)  ( 15  top> empty )
 [ 0031 ] LABEL     ( 30  top> empty )
 [ 0031 ]  INDEX  ( 22  top> empty )
 2*               ( 22  top> #64x )
 2*               ( 22  top> #0x )
 [ cellspace ] SYMBOL_+  ( 23  top> #69d )
 [ 0031 ]  INDEX  ( 25  top> #70d )
 1  ( LIT)       ( 25  top> #64x #70d )
 -                ( 25  top> #0x #64x #70d )
 SWAP             ( 25  top> #0x #70d )
 2  ( LIT)       ( 25  top> #70x #0x )
 +                ( 25  top> #0x #0x #0x )
 !                ( 25  top> #0x #0x )
 R>               ( 29  top> empty )
 1  ( LIT)       ( 29  top> #64x )
 +                ( 29  top> #0x #64x )
 DUP_>R   ( #64 )  ( 18  top> #64 )
 18  ( LIT)       ( 18  top> #64x )
 U>               ( 19  top> #67x #64x )
 [ 0031 ] BRANCHZ   ( 19  top> #0x )
 [ 0031 DROP_INDEX ] R>DROP  ( 35  top> empty )
 [ 0034 ] LABEL     ( 103  top> empty )
 18  ( LIT)       ( 38  top> empty )
 freelist  ( SYMBOL)    ( 38  top> #0x )
 !                ( 38  top> #0x #0x )
 [                ( 43  top> empty )
 stack  ( SYMBOL)    ( 43  top> empty )
 2  ( LIT)       ( 43  top> #0x )
 +                ( 43  top> #0x #0x )
 ] LITERAL        ( 43  top> #0x )
 14  ( LIT)       ( 44  top> #4 )
 ( #5 Calling Arg )  ( 47  top> #5 #4 )
 ( #4 Calling Arg )  ( 47  top> #4 )
 -64 FP+!  ( Link)   ( 47  top> empty )
   Init  ( CALL)    ( 47  top> empty )
 64 FP+!  ( Unlink)  ( 47  top> empty )
 [                ( 52  top> empty )
 stack  ( SYMBOL)    ( 52  top> empty )
 4  ( LIT)       ( 52  top> #0x )
 +                ( 52  top> #0x #0x )
 ] LITERAL        ( 52  top> #0x )
 ( #4 Calling Arg )  ( 54  top> #4 )
 -64 FP+!  ( Link)   ( 54  top> empty )
   Makenull  ( CALL)    ( 54  top> empty )
 64 FP+!  ( Unlink)  ( 54  top> empty )
 [                ( 60  top> empty )
 stack  ( SYMBOL)    ( 60  top> empty )
 6  ( LIT)       ( 60  top> #0x )
 +                ( 60  top> #0x #0x )
 ] LITERAL        ( 60  top> #0x )
 ( #4 Calling Arg )  ( 62  top> #4 )
 -64 FP+!  ( Link)   ( 62  top> empty )
   Makenull  ( CALL)    ( 62  top> empty )
 64 FP+!  ( Unlink)  ( 62  top> empty )
 0  ( LIT)       ( 65  top> empty )
 movesdone  ( SYMBOL)    ( 65  top> #0x )
 !                ( 65  top> #0x #0x )
 1  ( LIT)       ( 68  top> empty )
 2  ( LIT)       ( 69  top> #4 )
 14  ( LIT)       ( 70  top> #5 #4 )
 ( #6 Calling Arg )  ( 74  top> #6 #5 #4 )
 ( #5 Calling Arg )  ( 74  top> #5 #4 )
 ( #4 Calling Arg )  ( 74  top> #4 )
 -64 FP+!  ( Link)   ( 74  top> empty )
   tower  ( CALL)    ( 74  top> empty )
 64 FP+!  ( Unlink)  ( 74  top> empty )
 movesdone  ( SYMBOL)    ( 77  top> empty )
 @                ( 77  top> #0x )
 16383  ( LIT)       ( 79  top> #78x )
 -                ( 80  top> #79x #78x )
 [ 0027 ] BRANCHZ   ( 80  top> #0x )
 -64 FP+!  ( Link)   ( 83  top> empty )
   do_error  ( CALL)    ( 83  top> empty )
 64 FP+!  ( Unlink)  ( 83  top> empty )
 [ 0027 ] LABEL     ( 88  top> empty )
 R>               ( 89  top> empty )
 1  ( LIT)       ( 89  top> #65x )
 +                ( 89  top> #0x #65x )
 DUP_>R   ( #65 )  ( 10  top> #65 )
 34  ( LIT)       ( 10  top> #65x )
 U>               ( 11  top> #66x #65x )
 [ 0033 ] BRANCHZ   ( 11  top> #0x )
 [ 0033 DROP_INDEX ] R>DROP  ( 95  top> empty )
 EXIT  [ 0035 ] LABEL     ( 109  top> empty )
   ;  ( END )   


.( max 34) cr