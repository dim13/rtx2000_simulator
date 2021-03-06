\ /* perm.c */
\ GNU C for RTX 2000

EMPTY
: XY " DOS XY bperm.4" EVALUATE ;

DECIMAL
load gnutool.4th

VARIABLE permarray   24   CELL- ALLOT
VARIABLE pctr   4   CELL- ALLOT

#REGS 100 - REG-ADDR $FFC0 AND  UBR!

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : do_swap  ( FUNC )   ( 3  top> empty )
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

 : initialize  ( FUNC )   ( 3  top> empty )
 1  ( LIT)       ( 6  top> empty )
 [ 006 ADD_INDEX ] >R   ( 35  top> #64 )
 ( TYPE 1 LOOP BEGIN)  ( 7  top> empty )
 [ 006 ] LABEL     ( 23  top> empty )
 [ 006 ]  INDEX  ( 15  top> empty )
 2*               ( 15  top> #64x )
 [ permarray ] SYMBOL_+  ( 16  top> #67d )
 [ 006 ]  INDEX  ( 18  top> #68d )
 1  ( LIT)       ( 18  top> #64x #68d )
 -                ( 18  top> #0x #64x #68d )
 SWAP !           ( 18  top> #0x #68d )
 R>               ( 22  top> empty )
 1  ( LIT)       ( 22  top> #64x )
 +                ( 22  top> #0x #64x )
 DUP_>R   ( #64 )  ( 10  top> #64 )
 7  ( LIT)       ( 10  top> #64x )
 U>               ( 11  top> #65x #64x )
 [ 006 ] BRANCHZ   ( 11  top> #0x )
 [ 006 DROP_INDEX ] R>DROP  ( 28  top> empty )
 EXIT  [ 007 ] LABEL     ( 36  top> empty )
   ;  ( END )   

 ( 30  top> empty )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : permute  ( FUNC )   ( 3  top> empty )
 ( #4 dummy reload )  ( 4  top> empty )
 1  ( LIT)       ( 10  top> #64 )
 pctr  ( SYMBOL)    ( 10  top> #0x #64 )
 +!               ( 10  top> #0x #0x #64 )
 [ 2 ] DUP_U!         ( 13  top> #64 )
 1  ( LIT)       ( 13  top> #64x )
 -                ( 14  top> #68x #64x )
 [ 009 ] BRANCHZ   ( 14  top> #0x )
 2 U@            ( 19  top> empty )
 1  ( LIT)       ( 19  top> #64x )
 -                ( 19  top> #0x #64x )
 ( #4 Calling Arg )  ( 21  top> #4 )
 -64 FP+!  ( Link)   ( 21  top> empty )
recurse \   permute  ( CALL)    ( 21  top> empty )
 64 FP+!  ( Unlink)  ( 21  top> empty )
 2 U@            ( 24  top> empty )
 1  ( LIT)       ( 24  top> #64x )
 -                ( 24  top> #0x #64x )
 [ 3 ] DUP_U!         ( 79  top> #65 )
 0>               ( 79  top> #65x )
 [ 0014 ] BRANCHZ   ( 81  top> #0x )
 2 U@            ( 82  top> empty )
 2*               ( 82  top> #64x )
 4 U!            ( 26  top> #71 )
 ( LOOP_BEGIN)    ( 26  top> empty )
 [ 0013 ] LABEL     ( 66  top> empty )
 3 U@            ( 35  top> empty )
 2*               ( 35  top> #65x )
 4 U@            ( 38  top> #73 )
 [ permarray ] SYMBOL_+  ( 38  top> #71x #73 )
 SWAP             ( 39  top> #4 #73d )

 [ permarray ] SYMBOL_+  ( 39  top> #73x #4 )
 ( #5 Calling Arg )  ( 42  top> #5 #4 )
 ( #4 Calling Arg )  ( 42  top> #4 )
 -64 FP+!  ( Link)   ( 42  top> empty )
   do_swap  ( CALL)    ( 42  top> empty )
 64 FP+!  ( Unlink)  ( 42  top> empty )
 2 U@            ( 46  top> empty )
 1  ( LIT)       ( 46  top> #64x )
 -                ( 46  top> #0x #64x )
 ( #4 Calling Arg )  ( 48  top> #4 )
 -64 FP+!  ( Link)   ( 48  top> empty )
recurse \   permute  ( CALL)    ( 48  top> empty )
 64 FP+!  ( Unlink)  ( 48  top> empty )
 3 U@            ( 53  top> empty )
 2*               ( 53  top> #65x )
 4 U@            ( 56  top> #78 )
 [ permarray ] SYMBOL_+  ( 56  top> #71x #78 )
 SWAP             ( 57  top> #4 #78d )

 [ permarray ] SYMBOL_+  ( 57  top> #78x #4 )
 ( #5 Calling Arg )  ( 60  top> #5 #4 )
 ( #4 Calling Arg )  ( 60  top> #4 )
 -64 FP+!  ( Link)   ( 60  top> empty )
   do_swap  ( CALL)    ( 60  top> empty )
 64 FP+!  ( Unlink)  ( 60  top> empty )
 3 U@            ( 65  top> empty )
 1  ( LIT)       ( 65  top> #65x )
 -                ( 65  top> #0x #65x )
 [ 3 ] DUP_U!         ( 29  top> #65 )
 0>               ( 29  top> #65x )
 [ 0013 ] BRANCHNZ  ( 30  top> #0x )
 ( LOOP_END)      ( 71  top> empty )
 [ 0014 ] LABEL     ( 80  top> empty )
 EXIT  [ 009 ] LABEL     ( 73  top> empty )
   ;  ( END )   

 ( 74  top> empty )

( RTX 2000 code generation)

 64 FRAME_SIZE ! 

 : main  ( FUNC )   ( 3  top> empty )
#REGS 100 - REG-ADDR $FFC0 AND  UBR!
 0  ( LIT)       ( 6  top> empty )
 pctr  ( SYMBOL)    ( 6  top> #0x )
 !                ( 6  top> #0x #0x )
 1  ( LIT)       ( 8  top> empty )
 [ 0019 ADD_INDEX ] >R   ( 41  top> #64 )
 ( TYPE 1 LOOP BEGIN)  ( 9  top> empty )
 [ 0019 ] LABEL     ( 29  top> empty )
 -64 FP+!  ( Link)   ( 17  top> empty )
   initialize  ( CALL)    ( 17  top> empty )
 64 FP+!  ( Unlink)  ( 17  top> empty )
 7  ( LIT)       ( 20  top> empty )
 ( #4 Calling Arg )  ( 22  top> #4 )
 -64 FP+!  ( Link)   ( 22  top> empty )
   permute  ( CALL)    ( 22  top> empty )
 64 FP+!  ( Unlink)  ( 22  top> empty )
 R>               ( 28  top> empty )
 1  ( LIT)       ( 28  top> #64x )
 +                ( 28  top> #0x #64x )
 DUP_>R   ( #64 )  ( 12  top> #64 )
 5  ( LIT)       ( 12  top> #64x )
 U>               ( 13  top> #65x #64x )
 [ 0019 ] BRANCHZ   ( 13  top> #0x )
 [ 0019 DROP_INDEX ] R>DROP  ( 34  top> empty )
 EXIT  [ 0020 ] LABEL     ( 42  top> empty )
   ;  ( END )   

 ( 36  top> empty )

