*----------------------------------------------------------- 
* Title      : Jump Table Junkies 68K DisAssembler
* Written by : Bogdan Boiko, John Sliwa, Geoff Lebbos
* Date       : 05-23-2017
* Description:
*---------------------------------------------------------------------

userinput   EQU     $00A0           * user input
minAddress  EQU     $00000000       * min address
maxAddress  EQU     $00FFFE00       * max address
storage     EQU     $0000F000       * stores instructions
compareEnd  EQU     $0000FFF0       * stores end address in good form    
run         EQU     $00B0 
numOfLines  EQU     $00C0   

inputMin    EQU     $0A00
inputMax    EQU     $0B00

START:      ORG     $1000           * first instruction of program

*---------------------------------------------------------------------
        *LEA         SCREEN,A1       * display start screen
        *MOVE.B      #14,D0          * move task #14 to D0
        *TRAP        #15
      
        LEA         PROJECT,A1      * display project 
        MOVE.B      #14,D0          * move task #14 to D0
        TRAP        #15 
     
        LEA         INFO,A1         * display instructions
        MOVE.B      #14,D0          * move task #14 to D0
        TRAP        #15

* User will input the starting address of deconstructor -------------
STARTADDRESS
        CLR         D7              * clear register D7
        LEA         INPUTSTARTADD,A1 * load input message
        MOVE.B      #14,D0              
        TRAP        #15
        
        LEA         inputMin,A1     * load start address to be stored
        MOVE.B      #2,D0           * move task #2 to D0
        TRAP        #15 
     
        BRA         LOADCHAR        * branch to LOADCHAR

* User will input the ending address of deconstructor -------------
ENDADDRESS
        CLR         D7              * clear register D7
        LEA         INPUTENDADD,A1  * load end address input message
        MOVE.B      #14,D0          * move task #14 to D0
        TRAP        #15 
     
        LEA         inputMax,A1     * load end address to be stored
        MOVE.B      #2,D0           * move task #2 to D0
        TRAP        #15 
      
        BRA         LOADCHAR        * branch to LOADCHAR
      
* Loop throught bytes to check each hex char 1 at a time -------------
LOADCHAR    
        MOVE.B      (A1),D1         * move content of A1 into D1
        ADDI.B      #1,D7           * start looping
        CMPI.W      #10,D7          * stop if looped 9 times
        BEQ         ADD_TOO_BIG     * branch to CHECKADD
        BRA         ASCII_HEX       * branch to ASCII_HEX
         
* Input address is calculated ----------------------------------------
ADD_DONE
        CMPI.W      #1,D7           * error if looped 0 times
        BEQ         NO_ADDRESS      * branch to NO_START_ADDRESS     
        BRA         SIMPLIFY_ADDRESS * branch to SIMPLIFY_ADDRESS  

* Address input is taken and put into data register ------------------
SIMPLIFY_ADDRESS
        CLR         D2              * clear D2
        CLR         D3              * clear D3       
        CMPI.B      #1,D6           * complare if D6 is 1
        BEQ         SIMPLIFY_END_ADDRESS    * branch to SIMPLIFY_END_ADDRESS
        MOVE.L      #inputMin,A1    * move inputMin into A1      
        BRA         LOOPADDRESS     * branch to LOOPADDRESS

* For the case of simplifiying the end address -----------------------
SIMPLIFY_END_ADDRESS
        MOVE.L      #inputMax,A1    * load inputMax into A1
        BRA         LOOPADDRESS     * branch to LOOPADDRESS
       
* Loops address and simplifies it ------------------------------------       
LOOPADDRESS
        MOVE.B      (A1)+,D1        * move byte from A1 to D1 and postincriment
        ADDI.B      #1,D3           * add 1 to D3
        CMP.B       D3,D7           * compare if D3 is equal to D7
        BEQ         CHECKIFEVEN     * brach if equal
        ASL.L       #4,D2           * shift content of D2 4 bits left
        ADD.B       D1,D2           * add a byte from D1 to D2
        BRA         LOOPADDRESS     * branch to LOOPADDRESS
              
* Checks if the user input address is even -------------------------
CHECKIFEVEN 
        MOVE.L      D2,D3           * copy D2 to D3
        ASR         #1,D3           * shift content of D3 1 bit right
        BCS         NOTEVENERROR    * branch to NOTEVENERROR if bit is set    
        CMPI.B      #1,D6           * compare if D6 is 1
        BEQ         CHECK_END_ADDRESS   * brach to CHECK_END_ADDRESS if equal
        BRA         CHECK_START_ADDRESS * branch to CHEKC_START_ADDRESS
              
* Check to make sure that the start address is even ------------------        
CHECK_START_ADDRESS
        CMP.L       #minAddress,D2  * compare minAddress and D2
        BLT         ADDRESS_SMALL   * branch to ADDRESS_SMALL if smaller
        CMP.L       #maxAddress,D2  * compare maxAddress and D2
        BGT         ADDRESS_LARGE   * branch to ADDRESS_LARGE if bigger   
        ADDI.B      #1,D6           * add 1 to D6
        MOVE.L      D2,A6           * move content of D2 into A6
        BRA         ENDADDRESS      * branch to ENDADDRESS
           
* Check to make sure that the end address is even ------------------  
CHECK_END_ADDRESS
        CMP.L       #maxAddress,D2  * compare maxAddress and D2 
        BGT         ADDRESS_LARGE   * branch to ADDRESS_LARGE if bigger
        CMP.L       D2,A6           * compare content of D6 and A6
        BGT         ADDRESS_MISMATCH * branch to ADDRESS_MISMATCH if bigger      
         * MOVE.L      D2,A5           * move content of D2 to A5
        LEA         compareEnd,A5   * load compareEnd into A5
        MOVE.L      D2,(A5)         * move content of D2 into A5
        BRA         GOODADDRESS     * branch to GOODADDRESS

************** DIFFERENT ERRORS FOR ADDRESS **************************

* Invalid input branch -----------------------------------------------
INVALID
        LEA         BADADDRESS,A1       * load BADINPUT message
        MOVE.B      #14,D0              * move task #14 to D0
        TRAP        #15                 * display BADINPUT messgae
        CLR.W       D7                  * clear counter data register
        
        CMPI.W      #1,D6               * compare if D6 is equal to 1
        BEQ         ENDADDRESS          * branch to ENDADDRESS
        BRA         STARTADDRESS        * branch to STATADDRESS
      

* The address user has entered is over 8 characters so ---------------
ADD_TOO_BIG
        LEA         INPUTTOOLARGE,A1    * load INPUTTOOLARGE message
        MOVE.B      #14,D0              * move task #14 to D0
        TRAP        #15
        
        CMPI.W      #1,D6               * compare if D6 is equal to 1
        BEQ         ENDADDRESS          * branch to ENDADDRESS
        BRA         STARTADDRESS        * branch to STATADDRESS
        
* Displays an error if the address input is not even ---------------
NOTEVENERROR
        LEA         NOTEVEN,A1          * load NOTEVEN message
        MOVE.B      #14,D0              * move task #14 to D0
        TRAP        #15
        
        CMPI.W      #1,D6               * compare if D6 is equal to 1
        BEQ         ENDADDRESS          * branch to ENDADDRESS
        BRA         STARTADDRESS        * branch to STATADDRESS

* Check if end address is large than start address ----------------
ADDRESS_MISMATCH
        LEA         ENDBIGGERSTART,A1   * load ENDBIGGERSTART
        MOVE.B      #14,D0              * move task #14 to D0
        TRAP        #15
        
        BRA         ENDADDRESS          * branch to ENDADDRESS

* Checks if address is smaller than the minimum value -------------
ADDRESS_SMALL
        LEA         TOOSMALLADDRESS,A1  * load TOOSMALLADDRESS message
        MOVE.B      #14,D0              * move task #14 to D0
        TRAP        #15
        
        CMPI.W      #1,D6               * compare if D6 is equal to 1
        BEQ         ENDADDRESS          * branch to ENDADDRESS
        BRA         STARTADDRESS        * branch to STATADDRESS
        
* Checks if address is large than the maximum value ---------------
ADDRESS_LARGE
        LEA         TOOLARGEADDRESS,A1  * load TOOLARGEADDRESS message
        MOVE.B      #14,D0              * move task #14 to D0
        TRAP        #15

        CMPI.W      #1,D6               * compare if D6 is equal to 1
        BEQ         ENDADDRESS          * branch to ENDADDRESS
        BRA         STARTADDRESS        * branch to STATADDRESS

* User did not input a starting address ------------------------------
NO_ADDRESS
        LEA         NOADDRESS_ERR,A1    * load NOADDRESS_ERR message
        MOVE.B      #14,D0              * move task #14 to D0
        TRAP        #15
        
        BRA         STARTADDRESS        * branch to STARTADDRESS
 

                * ASCII to Hex and Hex to ASCII converters    
*//////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
**************************************************************************
*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\///////////////////////////////////

* Used to find ASCII characters to be converted to hex ---------------      
ASCII_HEX
        CMPI.B      #$0,D1          * if end of address
        BEQ         ADD_DONE        * branch to ADD_DONE
        
        CMPI.B      #$30,D1         * compare to ascii 0
        BLT         INVALID         * branch to INVALID if less
        CMPI.B      #$66,D1         * compare to ascii f
        BGT         INVALID         * branch to INVALID if more
        CMPI.B      #$39,D1         * compare to ascii 9
        BLE         NUMBER          * branch to NUMBER if less or equal
        CMPI.B      #$61,D1         * compare to ascii a
        BGE         LOWLETTER       * branch to LOWLETTER if greater or equal
        CMPI.B      #$46,D1         * compare to ascii F
        BGT         INVALID         * branch to INVALID if more 
        CMPI.B      #$41,D1         * compare to ascii A
        BGE         CAPLETTER       * branch to CAPLETTER if greater or equal
        
        BRA         INVALID         * branch to INVALID
 
* Convert ASCII to hex for numbers 0 - 9 -----------------------------
NUMBER
        SUBI.B      #$30,D1             * subtract ascii to get hex
        MOVE.B      D1,(A1)+            * move hex value into storage instead of ascii       
        
        BRA         LOADCHAR            * branch to check next character

* Convert ASCII to hex for letters A - F -----------------------------
CAPLETTER
        SUBI.B      #55,D1              * subtract ascii to get hex
        MOVE.B      D1,(A1)+            * move hex value into storage instead of ascii
        
        BRA         LOADCHAR            * branch to LOADCHAR

* Convert ASCII to hex for letters a - f -----------------------------
LOWLETTER 
        SUBI.B      #87,D1              * subtract ascii to get hex
        MOVE.B      D1,(A1)+            * move hex value into storage instead of ascii
        
        BRA         LOADCHAR            * branch to LOADCHAR

* Adds 0 into the address that will be printer and postincrements
ADD_ASCII_0
        MOVE.B      #'0',(A2)+          * move 0 into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds 1 into the address that will be printer and postincrements
ADD_ASCII_1
        MOVE.B      #'1',(A2)+          * move 1 into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds 2 into the address that will be printer and postincrements
ADD_ASCII_2
        MOVE.B      #'2',(A2)+          * move 2 into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds 3 into the address that will be printer and postincrements
ADD_ASCII_3
        MOVE.B      #'3',(A2)+          * move 3 into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds 4 into the address that will be printer and postincrements
ADD_ASCII_4
        MOVE.B      #'4',(A2)+          * move 4 into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds 5 into the address that will be printer and postincrements
ADD_ASCII_5
        MOVE.B      #'5',(A2)+          * move 5 into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds 6 into the address that will be printer and postincrements
ADD_ASCII_6
        MOVE.B      #'6',(A2)+          * move 6 into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds 7 into the address that will be printer and postincrements
ADD_ASCII_7
        MOVE.B      #'7',(A2)+          * move 7 into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds 8 into the address that will be printer and postincrements        
ADD_ASCII_8
        MOVE.B      #'8',(A2)+          * move 8 into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds 9 into the address that will be printer and postincrements
ADD_ASCII_9
        MOVE.B      #'9',(A2)+          * move 9 into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds A into the address that will be printer and postincrements
ADD_ASCII_A
        MOVE.B      #'A',(A2)+          * move A into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds B into the address that will be printer and postincrements
ADD_ASCII_B
        MOVE.B      #'B',(A2)+          * move B into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds C into the address that will be printer and postincrements
ADD_ASCII_C
        MOVE.B      #'C',(A2)+          * move C into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT
 
* Adds D into the address that will be printer and postincrements       
ADD_ASCII_D
        MOVE.B      #'D',(A2)+          * move D into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds E into the address that will be printer and postincrements
ADD_ASCII_E
        MOVE.B      #'E',(A2)+          * move E into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT
        
* Adds F into the address that will be printer and postincrements
ADD_ASCII_F         
        MOVE.B      #'F',(A2)+          * move F into address A2
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT   
        
*//////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
**************************************************************************
*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\///////////////////////////////////

* User input address is correct --------------------------------------
GOODADDRESS 

        MOVE.L      A6,$00FFFE10        * stores user input start address
        MOVE.L      A5,$00FFFE20        * stores user input end addres
        
        CLR         D6                  * clear data register D6
        MOVE.L      A5,D6               * move end address to D6          
        SUB.L       A6,D6               * subtract start address from end address
        MOVE.L      D6,$00FFFE30        * stores number of instructions
        
        MOVE.L      A6,D6
        
        LEA         storage,A2          * loads storage 
        BRA         STARTDECODE         * branch to STARTDECODE

* Starts the actuall process of doing the deconstruction of code -----       
STARTDECODE
        CLR         D1                  * clear D1
        CLR         D2                  * clear D2
        CLR         D3                  * clear D3
        MOVE.L      A6,D3               * move content of D6 to D3
        LEA         $0000F000,A2        * re-load address to start printing from
        JSR         CHECK_IF_DONE       * jump to CHECK_IF_DONE
        BRA         PREPARE_PRINT       * jump to PREPARE PRINT
        
* Prints the current address or the address location of the op code --
PREPARE_PRINT     
        ADDI.W      #1,D2               * add 1 to D2
        CMPI.B      #9,D2               * compare if D2 is 9
        BEQ         PRINT_READY         * if equal, branch to PRINT_READY
        ROL.L       #4,D3               * rotate content of D3 4 bits
        MOVE.B      D3,D1               * copy D3 to D1
        LSL.B       #4,D1               * shift content of D1 4 bits left
        LSR.B       #4,D1               * shift content of D1 4 bits right
        CMPI.B      #0,D1               * compare if D1 is 0
        BEQ         ADD_ASCII_0         * branch if equal
        CMPI.B      #1,D1               * compare if D1 is 1
        BEQ         ADD_ASCII_1         * branch if equal
        CMPI.B      #2,D1               * compare if D1 is 2
        BEQ         ADD_ASCII_2         * branch if equal
        CMPI.B      #3,D1               * compare if D1 is 3
        BEQ         ADD_ASCII_3         * branch if equal
        CMPI.B      #4,D1               * compare if D1 is 4
        BEQ         ADD_ASCII_4         * branch if equal
        CMPI.B      #5,D1               * compare if D1 is 5
        BEQ         ADD_ASCII_5         * branch if equal
        CMPI.B      #6,D1               * compare if D1 is 6
        BEQ         ADD_ASCII_6         * branch if equal
        CMPI.B      #7,D1               * compare if D1 is 7
        BEQ         ADD_ASCII_7         * branch if equal
        CMPI.B      #8,D1               * compare if D1 is 8
        BEQ         ADD_ASCII_8         * branch if equal
        CMPI.B      #9,D1               * compare if D1 is 9
        BEQ         ADD_ASCII_9         * branch if equal
        CMPI.B      #$A,D1              * compare if D1 is A
        BEQ         ADD_ASCII_A         * branch if equal
        CMPI.B      #$B,D1              * compare if D1 is B
        BEQ         ADD_ASCII_B         * branch if equal
        CMPI.B      #$C,D1              * compare if D1 is C
        BEQ         ADD_ASCII_C         * branch if equal
        CMPI.B      #$D,D1              * compare if D1 is D
        BEQ         ADD_ASCII_D         * branch if equal
        CMPI.B      #$E,D1              * compare if D1 is E
        BEQ         ADD_ASCII_E         * branch if equal
        CMPI.B      #$F,D1              * compare if D1 is F
        BEQ         ADD_ASCII_F         * branch if equal
                     
        BRA         PREPARE_PRINT       * branch to PREPARE_PRINT

* Adds final touches to make nice syntax before printing ------------
****************************************************************************************************************************
PRINT_READY
        MOVE.B      #' ',(A2)+              * Just for syntax
        MOVE.B      #' ',(A2)+
        MOVE.B      #' ',(A2)+
        MOVE.B      #' ',(A2)+
        
        BRA         MAIN  
              
MAIN:  
            MOVE.W      (A6)+,D6        ;MOVE NEXT OPCODE INTO D6...A6 starts as user entered the start address
            CMP.W       #$47E1,D6
            BEQ         _NOP
            CMP.W       #$4E75,D6
            BEQ         _RTS
            MOVE.W      D6,D5           ;MOVE WORD INTO D5 TO GET WORKED ON
            LSR.W       #8,D5           ;Shift and mask bits
            LSR.W       #4,D5               
            LSL.W       #8,D5
            LSL.W       #4,D5
            CMP.W       #$1000,D5
            BEQ         _MOVEB
            CMP.W       #$3000,D5
            BEQ         _MOVEW
            CMP.W       #$2000,D5
            BEQ         _MOVEL
            
            MOVE.W      D6,D5
            LSR.W       #8,D5
            LSL.W       #8,D5
            
            CMP.W       #$6000,D5
            BEQ         _BRA
            CMP.W       #$6100,D5
            BEQ         _BSR
            CMP.W       #$6200,D5
            BEQ         _BHI
            CMP.W       #$6300,D5
            BEQ         _BLS
            CMP.W       #$6400,D5
            BEQ         _BCC
            CMP.W       #$6500,D5
            BEQ         _BCS
            CMP.W       #$6600,D5
            BEQ         _BNE
            CMP.W       #$6700,D5
            BEQ         _BEQ
            CMP.W       #$6800,D5
            BEQ         _BVC
            CMP.W       #$6900,D5
            BEQ         _BVS
            CMP.W       #$6A00,D5
            BEQ         _BPL
            CMP.W       #$6B00,D5
            BEQ         _BMI
            CMP.W       #$6C00,D5
            BEQ         _BGE
            CMP.W       #$6D00,D5
            BEQ         _BLT
            CMP.W       #$6E00,D5
            BEQ         _BGT
            CMP.W       #$6F00,D5
            BEQ         _BLE
            
            MOVE.W      D6,D5
            LSR.W       #6,D5
            LSL.W       #6,D5
            
            CMP.W       #$4E80,D5
            BEQ         _JSR
            CMP.W       #$E3C0,D5
            BEQ         _LSL
            CMP.W       #$E2C0,D5
            BEQ         _LSR
            CMP.W       #$E0C0,D5
            BEQ         _ASR
            CMP.W       #$E1C0,D5
            BEQ         _ASL
            CMP.W       #$E7C0,D5
            BEQ         _ROL
            CMP.W       #$E6C0,D5
            BEQ         _ROR
            CMP.W       #$4200,D5
            BEQ         _CLRB
            CMP.W       #$4240,D5
            BEQ         _CLRW
            CMP.W       #$4280,D5
            BEQ         _CLRL
            CMP.W       #$0600,D5
            BEQ         _ADDIB
            CMP.W       #$0640,D5
            BEQ         _ADDIW
            CMP.W       #$0680,D5
            BEQ         _ADDIL
***********************************************************************************************
            MOVE.W      D6,D5
            LSR.W       #3,D5
            LSL.W       #3,D5
            BCLR.L      #$05,D5
            BCLR.L      #$09,D5
            BCLR.L      #$0A,D5
            BCLR.L      #$0B,D5
            
            CMP.W       #$E108,D5
            BEQ         _LSLB
            CMP.W       #$E148,D5
            BEQ         _LSLW
            CMP.W       #$E188,D5
            BEQ         _LSLL
            CMP.W       #$E008,D5
            BEQ         _LSRB
            CMP.W       #$E048,D5
            BEQ         _LSRW
            CMP.W       #$E088,D5
            BEQ         _LSRL
            CMP.W       #$E000,D5
            BEQ         _ASRB
            CMP.W       #$E040,D5
            BEQ         _ASRW
            CMP.W       #$E080,D5
            BEQ         _ASRL
            CMP.W       #$E100,D5
            BEQ         _ASLB
            CMP.W       #$E140,D5
            BEQ         _ASLW
            CMP.W       #$E180,D5
            BEQ         _ASLL
            CMP.W       #$E118,D5
            BEQ         _ROLB
            CMP.W       #$E158,D5
            BEQ         _ROLW
            CMP.W       #$E198,D5
            BEQ         _ROLL
            CMP.W       #$E018,D5
            BEQ         _RORB
            CMP.W       #$E058,D5
            BEQ         _RORW
            CMP.W       #$E098,D5
            BEQ         _RORL

*************************************************************************************************
            MOVE.W      D6,D5
            LSR.W       #6,D5
            LSL.W       #6,D5
            BCLR.L      #$09,D5
            BCLR.L      #$0A,D5
            BCLR.L      #$0B,D5
            
            CMP.W       #$1040,D5
            BEQ         _MOVEAB
            CMP.W       #$3040,D5
            BEQ         _MOVEAW
            CMP.W       #$2040,D5
            BEQ         _MOVEAL
            CMP.W       #$D0C0,D5
            BEQ         _ADDAW
            CMP.W       #$D1C0,D5
            BEQ         _ADDAL
            CMP.W       #$5000,D5
            BEQ         _ADDQB
            CMP.W       #$5040,D5
            BEQ         _ADDQW
            CMP.W       #$5080,D5
            BEQ         _ADDQL
            CMP.W       #$C1C0,D5
            BEQ         _MULS
            CMP.W       #$80C0,D5
            BEQ         _DIVU
            CMP.W       #$41C0,D5
            BEQ         _LEA
            CMP.W       #$B000,D5
            BEQ         _CMPB
            CMP.W       #$B040,D5
            BEQ         _CMPW
            CMP.W       #$B080,D5
            BEQ         _CMPL

            BCLR.L      #$08,D5

            CMP.W       #$C000,D5
            BEQ         _ANDB
            CMP.W       #$C040,D5
            BEQ         _ANDW
            CMP.W       #$C080,D5
            BEQ         _ANDL
            CMP.W       #$8000,D5
            BEQ         _ORB
            CMP.W       #$8040,D5
            BEQ         _ORW
            CMP.W       #$8080,D5
            BEQ         _ORL
            CMP.W       #$9000,D5
            BEQ         _SUBB
            CMP.W       #$9040,D5
            BEQ         _SUBW
            CMP.W       #$9080,D5
            BEQ         _SUBL
            CMP.W       #$D000,D5
            BEQ         _ADDB
            CMP.W       #$D040,D5
            BEQ         _ADDW
            CMP.W       #$D080,D5
            BEQ         _ADDL
            
            MOVE.W      D6,D5
            LSR.W       #6,D5
            LSL.W       #6,D5
            BCLR.L      #$0A,D5
            
            CMP.W       #$4880,D5
            BEQ         _MOVEMW
            CMP.W       #$48C0,D5
            BEQ         _MOVEML
            CMP.W       #$7000,D5
            BEQ         _MOVEQL
            
_DATA
            MOVE.B      #'D',(A2)+      ;Couldn't decode, print DATA
            MOVE.B      #'A',(A2)+
            MOVE.B      #'T',(A2)+
            MOVE.B      #'A',(A2)+ 
            MOVE.B      #9,(A2)+        ;tab  
            MOVE.B      #9,(A2)+        ;tab 
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
           
_NOP
            MOVE.B      #'N',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'P',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_RTS
            MOVE.B      #'R',(A2)+
            MOVE.B      #'T',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_MOVEB
            MOVE.B      #2,D4
            MOVE.B      #'M',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'V',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        
            MOVE.B      #' ',(A2)+      
            MOVE.B      #' ',(A2)+ 
            JSR         EA_5_0          ;determine source addressing mode & number and print

            JSR         MOVEDEST  
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_MOVEW
            MOVE.B      #4,D4
            MOVE.B      #'M',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'V',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print

            JSR         MOVEDEST    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_MOVEL
            MOVE.B      #8,D4
            MOVE.B      #'M',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'V',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #' ',(A2)+ 
            MOVE.B      #' ',(A2)+           
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print

            JSR         MOVEDEST
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BRA
            MOVE.B      #'B',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'A',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BSR
            MOVE.B      #'B',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BHI
            MOVE.B      #'B',(A2)+
            MOVE.B      #'H',(A2)+
            MOVE.B      #'I',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BLS
            MOVE.B      #'B',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BCC
            MOVE.B      #'B',(A2)+
            MOVE.B      #'C',(A2)+
            MOVE.B      #'C',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BCS
            MOVE.B      #'B',(A2)+
            MOVE.B      #'C',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BNE
            MOVE.B      #'B',(A2)+
            MOVE.B      #'N',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BEQ
            MOVE.B      #'B',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #'Q',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BVC
            MOVE.B      #'B',(A2)+
            MOVE.B      #'V',(A2)+
            MOVE.B      #'C',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BVS
            MOVE.B      #'B',(A2)+
            MOVE.B      #'V',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BPL
            MOVE.B      #'B',(A2)+
            MOVE.B      #'P',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BMI
            MOVE.B      #'B',(A2)+
            MOVE.B      #'M',(A2)+
            MOVE.B      #'I',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BGE
            MOVE.B      #'B',(A2)+
            MOVE.B      #'G',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BLT
            MOVE.B      #'B',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'T',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BGT
            MOVE.B      #'B',(A2)+
            MOVE.B      #'G',(A2)+
            MOVE.B      #'T',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_BLE
            MOVE.B      #'B',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_JSR
            MOVE.B      #'J',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DISPLACEMENT    ;determine  the displacement and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
****************************** MEMORY SHIFTS *********************************************
_LSL
            MOVE.B      #'L',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'L',(A2)+  
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR 
_LSR
            MOVE.B      #'L',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'R',(A2)+  
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR 
_ASR
            MOVE.B      #'A',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'R',(A2)+  
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR 
_ASL
            MOVE.B      #'A',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'L',(A2)+  
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR 
_ROL
            MOVE.B      #'R',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'L',(A2)+  
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR 
_ROR
            MOVE.B      #'R',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'R',(A2)+  
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR 
*****************************************************************************************
_CLRB
            MOVE.B      #2,D4
            MOVE.B      #'C',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_CLRW 
            MOVE.B      #4,D4
            MOVE.B      #'C',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #' ',(A2)+
            MOVE.B      #' ',(A2)+
            MOVE.B      #' ',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_CLRL
            MOVE.B      #8,D4
            MOVE.B      #'C',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
*****************************************ADD IMMEDIATE*******************************************
_ADDIB
            MOVE.B      #2,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'I',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #'#',(A2)+
            MOVE.B      #'$',(A2)+
            JSR         IMEDBYTE        ;print immediate byte
            MOVE.B      #',',(A2)+
            JSR         EA_5_0          ;determine source addressing mode & number and print    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ADDIW
            MOVE.B      #4,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'I',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #'#',(A2)+
            MOVE.B      #'$',(A2)+
            JSR         IMEDWORD        ;print immediate word
            MOVE.B      #',',(A2)+

            JSR         EA_5_0          ;determine source addressing mode & number and print    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ADDIL
            MOVE.B      #8,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'I',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #'#',(A2)+
            MOVE.B      #'$',(A2)+
            JSR         IMEDLONG        ;print immediate long
            MOVE.B      #',',(A2)+

            JSR         EA_5_0          ;determine source addressing mode & number and print    
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
**************************************IMMEDIATE AND REGISTER SHIFTS****************************************
_LSLB
            MOVE.B      #2,D4
            MOVE.B      #'L',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data 
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG

            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_LSLW
            MOVE.B      #4,D4
            MOVE.B      #'L',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data  
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_LSLL
            MOVE.B      #8,D4
            MOVE.B      #'L',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data 
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_LSRB
            MOVE.B      #2,D4
            MOVE.B      #'L',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data   
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_LSRW
            MOVE.B      #4,D4
            MOVE.B      #'L',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_LSRL
            MOVE.B      #8,D4
            MOVE.B      #'L',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data  
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ASLB
            MOVE.B      #2,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data 
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ASLW
            MOVE.B      #4,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data 
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ASLL
            MOVE.B      #8,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data 
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ASRB
            MOVE.B      #2,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data  
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ASRW
            MOVE.B      #4,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data 
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ASRL
            MOVE.B      #8,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data 
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ROLB
            MOVE.B      #2,D4
            MOVE.B      #'R',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ROLW
            MOVE.B      #4,D4
            MOVE.B      #'R',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ROLL
            MOVE.B      #8,D4
            MOVE.B      #'R',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_RORB
            MOVE.B      #2,D4
            MOVE.B      #'R',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_RORW
            MOVE.B      #4,D4
            MOVE.B      #'R',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_RORL
            MOVE.B      #8,D4
            MOVE.B      #'R',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            *JSR         EA_2_0          ;determine destination data register numer print (always Data reg)
            *JSR         EA_11_9_5       ;bit 5 set means register source, unset means immediate data
            JSR         BIT5
            MOVE.B      #',',(A2)+
            JSR         SOURCEDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR

**********************************************************************************************************

_MOVEAB
            MOVE.B      #2,D4
            MOVE.B      #'M',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'V',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #'A',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print

            JSR         DESTADDREG  
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_MOVEAW
            MOVE.B      #4,D4
            MOVE.B      #'M',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'V',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #'A',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print

            JSR         DESTADDREG  
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_MOVEAL
            MOVE.B      #8,D4
            MOVE.B      #'M',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'V',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #'A',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine source addressing mode & number and print

            JSR         DESTADDREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ADDAW
            MOVE.B      #4,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'A',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine addressing mode & source and print

            JSR         DESTADDREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ADDAL
            MOVE.B      #8,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'A',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine addressing mode & source and print

            JSR         DESTADDREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ADDQB
            MOVE.B      #2,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'Q',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #' ',(A2)+
            MOVE.B      #' ',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         SHIFTIMMEDIATE
            MOVE.B      #',',(A2)+
            JSR         EA_5_0          ;determine addressing mode & source and print

            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ADDQW
            MOVE.B      #4,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'Q',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         SHIFTIMMEDIATE
            MOVE.B      #',',(A2)+
            JSR         EA_5_0          ;determine addressing mode & source and print

            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ADDQL
            MOVE.B      #8,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'Q',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         SHIFTIMMEDIATE
            MOVE.B      #',',(A2)+
            JSR         EA_5_0          ;determine addressing mode & source and print
            
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_MULS
            MOVE.B      #'M',(A2)+
            MOVE.B      #'U',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #'S',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine addressing mode & source and print

            JSR         DESTDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_DIVU
            MOVE.B      #'D',(A2)+
            MOVE.B      #'I',(A2)+
            MOVE.B      #'V',(A2)+
            MOVE.B      #'U',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine addressing mode & source and print

            JSR         DESTDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_LEA
            MOVE.B      #4,D4
            MOVE.B      #'L',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #'A',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine addressing mode & source and print
            MOVE.B      #',',(A2)+
            JSR         DESTADDREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_CMPB
            MOVE.B      #2,D4
            MOVE.B      #'C',(A2)+
            MOVE.B      #'M',(A2)+
            MOVE.B      #'P',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine addressing mode & source and print

            JSR         DESTDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_CMPW
            MOVE.B      #4,D4
            MOVE.B      #'C',(A2)+
            MOVE.B      #'M',(A2)+
            MOVE.B      #'P',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine addressing mode & source and print

            JSR         DESTDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_CMPL
            MOVE.B      #8,D4
            MOVE.B      #'C',(A2)+
            MOVE.B      #'M',(A2)+
            MOVE.B      #'P',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #' ',(A2)+
            MOVE.B      #' ',(A2)+
            MOVE.B      #' ',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_5_0          ;determine addressing mode & source and print

            JSR         DESTDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
_ANDB
            MOVE.B      #2,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'N',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         DIRECTION       ; DETERMINE DIRECTION BIT AND PRINT ACCORDINGLY, PRINT AND NEXT_CODE INSIDE SUB
_ANDW
            MOVE.B      #4,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'N',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         DIRECTION       ; DETERMINE DIRECTION BIT AND PRINT ACCORDINGLY, PRINT AND NEXT_CODE INSIDE SUB

_ANDL
            MOVE.B      #8,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'N',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         DIRECTION       ; DETERMINE DIRECTION BIT AND PRINT ACCORDINGLY, PRINT AND NEXT_CODE INSIDE SUB
_ORB
            MOVE.B      #2,D4
            MOVE.B      #'O',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DIRECTION       ; DETERMINE DIRECTION BIT AND PRINT ACCORDINGLY, PRINT AND NEXT_CODE INSIDE SUB
_ORW
            MOVE.B      #4,D4
            MOVE.B      #'O',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DIRECTION       ; DETERMINE DIRECTION BIT AND PRINT ACCORDINGLY, PRINT AND NEXT_CODE INSIDE SUB
_ORL
            MOVE.B      #8,D4
            MOVE.B      #'O',(A2)+
            MOVE.B      #'R',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            MOVE.B      #9,(A2)+        ;tab
            JSR         DIRECTION       ; DETERMINE DIRECTION BIT AND PRINT ACCORDINGLY, PRINT AND NEXT_CODE INSIDE SUB
_SUBB
            MOVE.B      #2,D4
            MOVE.B      #'S',(A2)+
            MOVE.B      #'U',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         DIRECTION       ; DETERMINE DIRECTION BIT AND PRINT ACCORDINGLY, PRINT AND NEXT_CODE INSIDE SUB
_SUBW
            MOVE.B      #4,D4
            MOVE.B      #'S',(A2)+
            MOVE.B      #'U',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         DIRECTION       ; DETERMINE DIRECTION BIT AND PRINT ACCORDINGLY, PRINT AND NEXT_CODE INSIDE SUB
_SUBL
            MOVE.B      #8,D4
            MOVE.B      #'S',(A2)+
            MOVE.B      #'U',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         DIRECTION       ; DETERMINE DIRECTION BIT AND PRINT ACCORDINGLY, PRINT AND NEXT_CODE INSIDE SUB
_ADDB
            MOVE.B      #2,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'B',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         DIRECTION       ; DETERMINE DIRECTION BIT AND PRINT ACCORDINGLY, PRINT AND NEXT_CODE INSIDE SUB
_ADDW
            MOVE.B      #4,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         DIRECTION       ; DETERMINE DIRECTION BIT AND PRINT ACCORDINGLY, PRINT AND NEXT_CODE INSIDE SUB
_ADDL
            MOVE.B      #8,D4
            MOVE.B      #'A',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'D',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         DIRECTION       ; DETERMINE DIRECTION BIT AND PRINT ACCORDINGLY, PRINT AND NEXT_CODE INSIDE SUB
_MOVEMW
            MOVE.B      #4,D4
            MOVE.B      #'M',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'V',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #'M',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'W',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            
            JSR         BIT9_11         ;isolate data bits 9-11 into D5
            CMP.B       #%100,D5        ;register to memory
            BEQ         _MOVEMRTM
            CMP.B       #%110,D5        ;memory to register
            BEQ         _MOVEMMTR
_MOVEML
            MOVE.B      #8,D4
            MOVE.B      #'M',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'V',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #'M',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            
            JSR         BIT9_11         ;isolate data bits 9-11 into D5
            CMP.B       #%100,D5        ;register to memory
            BEQ         _MOVEMRTM
            CMP.B       #%110,D5        ;memory to register
            BEQ         _MOVEMMTR

_MOVEQL
            MOVE.B      #'M',(A2)+
            MOVE.B      #'O',(A2)+
            MOVE.B      #'V',(A2)+
            MOVE.B      #'E',(A2)+
            MOVE.B      #'Q',(A2)+
            MOVE.B      #'.',(A2)+
            MOVE.B      #'L',(A2)+
            MOVE.B      #9,(A2)+        ;tab
            JSR         EA_DATA         ;determine data
            JSR         EA_11_9         ;determine destination number and print (Always Data Register)
            
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR     
            
NEXT_CODE ;set everything up for the next opcode
            CLR         D4
            BRA         STARTDECODE

***************************************************************
*specific MOVEM routines
***************************************************************
*MOVEM Memory to Register  
_MOVEMMTR
            MOVE.W      D6,D5
            JSR     	BIT3_5          ;puts bits 3-5 ONLY in D5
            
            CMP.B   	#%010,D5        ;test for (An)
            BEQ     	_An             ;
            CMP.B   	#%011,D5        ;test for (An)+
            BEQ     	_An_PLUS        ;
            CMP.B   	#%101,D5        ;test for (d16,An)
            BEQ     	_d16_An         ;
            CMP.B   	#%110,D5        ;test for (d8,An,Xn)
            BEQ     	_d8_An_Xn       ;
            CMP.B   	#%111,D5        ;test for (d8,An,Xn)
            BNE     	_DATA           ;not allowed else CONTINUE & figure out register to determine mode
            
            MOVE.W      D6,D5
            JSR     	BIT0_2          ;puts bits 0-2 ONLY in D5
            
            CMP.B   	#%000,D5        ;test for (xxx).W
            BEQ     	_xxxW           ;
            CMP.B   	#%001,D5        ;test for (xxx).L
            BEQ     	_xxxL           ;
            CMP.B   	#%010,D5        ;test for  (d16,PC)
            BEQ     	_d16_PC         ;
            CMP.B   	#%011,D5        ;test for  (d8,PC,Xn)
            BEQ     	_d8_PC_Xn       ;

_An
            RTS
_d16_An
            RTS
_d8_An_Xn      
            RTS 
_xxxW 
            RTS
_xxxL   
            RTS
_d16_PC 
            RTS
_d8_PC_Xn
            RTS
            

***************************************************************
*MOVEM Register to memory
_MOVEMRTM
            MOVE.W      D6,D5
            JSR     	BIT3_5          ;puts bits 3-5 ONLY in D5
            
            CMP.B   	#%010,D5        ;test for (An) Address Register Indirect Mode 
            BEQ     	_An             ;
            CMP.B   	#%100,D5        ;test for -(An) Address Register Indirect with Predecrement Mode 
            BEQ     	_MIN_An         ;
            CMP.B   	#%101,D5        ;test for (d16,An) Address Register Indirect with Displacement Mode
            BEQ     	_d16_An         ;
            CMP.B   	#%110,D5        ;test for (d8,An,Xn) Address Register Indirect with Index (8-Bit Displacement) Mode
            BEQ     	_d8_An_Xn       ;
            CMP.B   	#%111,D5        ;test for not allowed
            BNE     	_DATA           ;not allowed else CONTINUE & figure out register to determine mode
            
            MOVE.W      D6,D5
            JSR     	BIT0_2          ;puts bits 0-2 ONLY in D5
            
            CMP.B   	#%000,D5        ;test for (xxx).W Absolute Data Addressing short
            BEQ     	_xxxW           ;
            CMP.B   	#%001,D5        ;test for (xxx).L Absolute Data Addressing long
            BEQ     	_xxxL           ; 

*****************************************************************
* pre decrement mode If the effective address is specified by the predecrement mode, 
* only a register-to-memory operation is allowed. 
* MSB to LSB (16->0) D0 D1 D2 D3 D4 D5 D6 D7 A0 A1 A2 A3 A4 A5 A6 A7 
*----------------------------------------------------------------
* address register pre decrement mode  
_MIN_An
            MOVE.W      D6,D5
            JSR     	BIT0_2          ;puts bits 0-2 ONLY in D5
            MOVE.W      D5,D3           ;Copy D5, into D3 for use in final print
            
            MOVE.W  	(A6)+,D6        ;read word with register list and increment
	        MOVE.W  	D6,D5           ;copy to D5 to work on it
	        
            CMP.B   	#0,D5           ;are there any address registers in this byte?
            BEQ     	PD_START_D      ;no, move to data registers
            CLR         D2              ;Clear D2 counter
PD_CHK_A     
            CMP     	#8,D2           ;have we read the whole byte? done with this byte, move to next 
            BEQ         PD_START_D      ;Finished with this byte go do data bytes
            LSL.B   	#1,D5           ;shift first bit out (Starts at A0)
            BCS     	PD_LOOP_A       ;if set, print the register # 
            ADDI.B  	#1,D2           ;not set, increment counter & loop back
            BRA         PD_CHK_A 
PD_LOOP_A
            MOVE.B  	#'A',(A2)+      ;print A
            CLR         D4
            MOVE.B  	D2,D4           ;copy counter
            MULU    	#8,D4           ;get ready for table
            LEA     	Table0_7_8_F,A4 ;load table
            JSR     	(A4,D4)         ;get register number and print it
            MOVE.B  	#'/',(A2)+      ;print /
            ADDI.B  	#1,D2           ;increment counter
            BRA         PD_CHK_A

PD_START_D  
	        MOVE.W  	D6,D5           ;copy to D5 to work on it
	        LSR.W       #8,D5           ;Shift to work on data register list now
            CMP.B   	#0,D5           ;are there any data registers in this byte?
            BEQ     	PD_DONE         ;no, finish
            CLR         D2              ;Clear D2 counter
PD_CHK_D     
            CMP     	#8,D2           ;have we read the whole byte? done with this byte, move to next 
            BEQ         PD_DONE         ;Finished with this byte go find destination
            LSL.B   	#1,D5           ;shift first bit out (Starts at D0)
            BCS     	PD_LOOP_D       ;if set, print the register #  
            ADDI.B  	#1,D2           ;not set, increment counter & loop back
            BRA         PD_CHK_D         
PD_LOOP_D
            MOVE.B  	#'D',(A2)+      ;print D
            CLR         D4
            MOVE.B  	D2,D4           ;copy counter
            MULU    	#8,D4           ;get ready for table
            LEA     	Table0_7_8_F,A4 ;load table
            JSR     	(A4,D4)         ;get register number and print it
            MOVE.B  	#'/',(A2)+      ;print /
            ADDI.B  	#1,D2           ;increment counter
            BRA         PD_CHK_D
PD_DONE
            MOVE.B  	#',',-(A2)      ;print ',' (overwrites last '/' charecter) 
            MOVE.B  	#',',(A2)+      ;print ',' (overwrites last '/' charecter) 
            MOVE.B  	#'-',(A2)+      ;print -
            MOVE.B  	#'(',(A2)+      ;print (
            MOVE.B  	#'A',(A2)+      ;print A
            MULU    	#8,D3           ;get ready for table
            LEA     	Table0_7_8_F,A4 ;load table
            JSR     	(A4,D3)         ;get register number and print it
            MOVE.B  	#')',(A2)+      ;print )
            
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR 

*********************************************************
*Post Increment Mode
*If the effective address is specified by the postincrement 
*mode, only a memory-to-register operation is allowed
*********************************************************
_An_PLUS
            MOVE.W      D6,D5
            JSR     	BIT0_2          ;puts bits 0-2 ONLY in D5

            MOVE.B  	#'(',(A2)+      
            MOVE.B  	#'A',(A2)+      
            MULU    	#8,D5           ;get ready for table
            LEA     	Table0_7_8_F,A4 ;load table
            JSR     	(A4,D5)         ;get register number and print it
            MOVE.B  	#')',(A2)+      
            MOVE.B  	#'+',(A2)+      
            MOVE.B  	#',',(A2)+                 
            
            MOVE.W  	(A6)+,D6        ;read word with register list and increment
	        MOVE.W  	D6,D5           ;copy to D5 to work on it
            CLR         D2              ;Clear D2 counter    
PI_CHK_D     
            CMP     	#8,D2           ;have we read the whole byte? done with this byte, move to next 
            BEQ         PI_START_A      ;Finished with this byte go do Address bytes
            LSR.W   	#1,D5           ;shift first bit out (Starts at D0)
            BCS     	PI_LOOP_D       ;if set, print the register # 
            ADDI.B  	#1,D2           ;not set...increment counter, read next bit
            BRA         PI_CHK_D        
PI_LOOP_D
            MOVE.B  	#'D',(A2)+      
            CLR         D4
            MOVE.B  	D2,D4           ;copy counter
            MULU    	#8,D4           ;get ready for table
            LEA     	Table0_7_8_F,A4 ;load table
            JSR     	(A4,D4)         ;get register number and print it
            MOVE.B  	#'/',(A2)+      
            ADDI.B  	#1,D2           ;increment counter
            BRA         PI_CHK_D

PI_START_A  
            CMP.B   	#0,D5           ;are there address registers in this byte?
            BEQ     	PI_DONE         ;no, finish
            CLR         D2              ;Clear D2 counter
PI_CHK_A     
            CMP     	#8,D2           ;have we read the whole byte? 
            BEQ         PI_DONE         ;Finished 
            LSR.B   	#1,D5           ;shift first bit out (Starts at A0)
            BCS     	PI_LOOP_A       ;if set, print the register #  
            ADDI.B  	#1,D2           ;not set...increment counter, read next bit
            BRA         PI_CHK_A           
PI_LOOP_A
            MOVE.B  	#'A',(A2)+      
            CLR         D4
            MOVE.B  	D2,D4           ;copy counter
            MULU    	#8,D4           ;get ready for table
            LEA     	Table0_7_8_F,A4 ;load table
            JSR     	(A4,D4)         ;get register number and print it
            MOVE.B  	#'/',(A2)+      
            ADDI.B  	#1,D2           ;increment counter
            BRA         PI_CHK_A
PI_DONE
            MOVE.B  	#' ',-(A2)      ; Overwrite last '/'
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR 

*------Used for Direction bit on OR,SUB,AND,ADD--------------
DIRECTION
            MOVE.W      D6,D5
            LSL.W       #7,D5
            LSR.W       #7,D5
            LSR.W       #8,D5           ;D5 NOW HAS DIRECTION BIT
            CMP.B       #1,D5
            BEQ         DN_EA           ; Dn TO <ea>
EA_DN
            JSR         EA_5_0          ;determine addressing mode & source and print
            MOVE.B      #',',(A2)+
            JSR         DESTDATAREG
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
DN_EA

            JSR         DESTDATAREG
            MOVE.B      #',',(A2)+
            JSR         EA_5_0          ;determine addressing mode & source and print
            JSR         PRINT           ;print the buffer
            BRA         NEXT_CODE       ;back to beggining, clear working registers and CCR
*------Used for Data Register Shift (LSL,ASL,LSR,LSR,ROR,ROL)--------------
EA_2_0                      ;determine destination data register numer print (always Data reg)
            RTS

EA_11_9_5                   ;bit 5 set means register source, unset means immediate data 
            RTS

*------------------To isolate source mode------------------------
EA_5_0  ;determine source number & mode and print
            JSR     BIT3_5           *Store source mode bits into D5
            LEA     ADDRESSTABLE, A4 *Load jump-table
            MULU    #8,D5
            JSR     (A4,D5)           
            RTS 
*------------------BIT3_5---------------------------------------      
BIT3_5
            MOVE.W  D6,D5    *Move to D5 to figure out source mode    
            LSL.W   #8,D5
            LSL.W   #2,D5       
            LSR.W   #6,D5
            LSR.W   #7,D5    *After this line, D5 contains Source mode
            RTS
*------------------BIT0_2---------------------------------------------
BIT0_2
            MOVE.W  D6,D5       
            LSL.W   #8,D5    *Shift all bits except last 3 out 
            LSL.W   #5,D5                   
            LSR.W   #8,D5
            LSR.W   #5,D5
            RTS       
EA_11_6 ;determine destination number & mode and print
EA_11_9 ;determine destination number and print
            JSR     BIT9_11
            LEA     Table0_7_8_F,A4
            MULU    #8,D5
            JSR     (A4,D5)
            RTS   

BIT6_8  *Destination Mode
            MOVE.W D6,D5  *Isolate bits 6-8
            LSL.W #7,D5
            LSR.W #8,D5
            LSR.W #5,D5
            RTS
BIT9_11 *Destination Register
            MOVE.W D6,D5   *Isolate bits 9-11
            LSL.W #4,D5
            LSR.W #8,D5
            LSR.W #5,D5
            RTS
*------------------------BIT5-----------------------------------------------------------
BIT5 *Used to acquire if source of LS/AS/RO is immediate or register
            MOVE.B   D6,D5
            LSL.W    #5,D5     *Shift bit 5 to MSB
            LSL.W    #5,D5
            LSR.W    #8,D5
            LSR.W    #7,D5     *Shift bit 5 to LSB
            CMP.B    #%0,D5    *Check if shift is immediate 
            BEQ      SHIFTIMMEDIATE
            CMP.B    #%1,D5    *Check if shift amount is from data register
            BEQ      SHIFTFROMDN
SHIFTIMMEDIATE
            MOVE.B   #'#',(A2)+      *Immediate data
            JSR      BIT9_11         *Figure out shift immediate number
            CMP      #0,D5           *Shift ammount is 8
            BEQ      SHIFT8
            Lea      Table0_7_8_F,A4 *Number isn't 8, use jump table to figure out shift ammount
            MULU     #8,D5
            JSR      (A4,D5)           
            RTS
            
SHIFT8  *Specifal case for shifting #8
            MOVE.B #'8',(A2)+
            RTS     *Return to shift opcode
            
SHIFTFROMDN *Shifting from  a number in a data register
            MOVE.B   #'D',(A2)+
            JSR      BIT9_11       *Isolate bits 
            Lea      Table0_7_8_F,A4 *Number isn't 8, use jump table to figure out shift ammount
            MULU     #8,D5
            JSR      (A4,D5)           
            RTS           
*---------Subroutine for figuring out Move destination---------------------
MOVEDEST *To figure out destination of MOVE
            MOVE.B   #',',(A2)+  *Comma between source/dest
            JSR      BIT6_8        *Figure out destination mode
            CMP.W    #%000, D5   *Check if data register
            BEQ      MOVEDEST000
            CMP.W    #%001, D5   *Check if address register
            BEQ      MOVEDEST001   
            CMP.W    #%010,D5    *Check if indirect
            BEQ      MOVEDEST010   
            CMP.W    #%011,D5   *Check if adress post-inc
            BEQ      MOVEDEST011 
            CMP.W    #%100,D5   *Check if address pre-dec
            BEQ      MOVEDEST100 
            CMP.W    #%111,D5   *Check if immediate/absolute
            BEQ      MOVEDEST111
            RTS
MOVEDEST000 *Move destination is a data register
            MOVE.B  #'D',(A2)+
            JSR     BIT9_11
            Lea     Table0_7_8_F,A4
            MULU    #8,D5
            JSR    (A4,D5)
            RTS
            
MOVEDEST001 *Move destination is an address register
            MOVE.B  #'A',(A2)+
            JSR     BIT9_11
            Lea     Table0_7_8_F,A4
            MULU    #8,D5
            JSR    (A4,D5)
            RTS

MOVEDEST010 *Move destinataion is indirect
            MOVE.B  #'(',(A2)+  
            MOVE.B  #'A',(A2)+ 
            JSR     BIT9_11
            Lea     Table0_7_8_F,A4
            MULU    #8,D5
            JSR     (A4,D5)
            MOVE.B   #')',(A2)+
            RTS
            
MOVEDEST011 *Move destination is adress post-inc
            MOVE.B  #'(',(A2)+  
            MOVE.B  #'A',(A2)+ 
            JSR     BIT9_11
            Lea     Table0_7_8_F,A4
            MULU    #8,D5
            JSR     (A4,D5)
            MOVE.B  #')',(A2)+
            MOVE.B  #'+',(A2)+
            RTS

MOVEDEST100 *Move destination is address pre-dec
            MOVE.B  #'-',(A2)+
            MOVE.B  #'(',(A2)+  
            MOVE.B  #'A',(A2)+ 
            JSR     BIT9_11
            Lea     Table0_7_8_F,A4
            MULU    #8,D5
            JSR     (A4,D5)
            MOVE.B  #')',(A2)+
            RTS
MOVEDEST111 *Move destination is absolute
            MOVE.B  #'$',(A2)+      *Destination is absolute address
            JSR     BIT9_11         *Isolate bits 9-11 to figure out size 
            CMP.B   #%001,D5        *Compare with word
            BEQ     MVDSTWRD        *Destination is a word address  
            CMP.B   #0,D5           *Compare with long
            BEQ     MVDSTLNG       *Destination is a long address
            RTS  
MVDSTLNG
            JSR     IMEDWORD 
            JSR     IMEDWORD 
            RTS
MVDSTWRD      
            JSR     IMEDWORD 
            RTS
*--------------------------------------------------------------------------------------
DISPLACEMENT ;special case for BRA instructions
            CLR         D5                      * clear D5  
            CLR         D2                      * clear D2
            CLR         D1                      * clear D1
            CLR         D0                      * clear D0
            
            MOVE.B      #'$',(A2)+              * input $ into A2 and incrament
            MOVE.B      D6,D5                   * move D6 to D5
            CMP.B       #$FF,D5                 * compare if D5 is equal to FF
            BEQ         LONGDISP                * branch to LONGDISP if equal
            CMP.B       #0,D5                   * compare if D5 is equal to 00
            BEQ         WORDISP                 * branch to WORDISP if equal
            NEG.B       D5                      * 2s compliment D5
            MOVE.L      A6,D0                   * move A6 to D0
            SUB.B       D5,D0                   * subtract D5 form D0
            
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT

* Case for displacement being 32 bits or 8 bytes -----------------------------
LONGDISP
            MOVEA.L     A6,A5                           * move A6 into A5
            ADD.L       #2,A5                           * add 2 to A5
            MOVE.L      (A5),D1                         * move content in inside the address A5 into D1
            
            CMP.L       #$7FFFFFFF,D1                   * compare if D1 is less than 7FFFFFFF
            BLT         DISPLACE_POSITIVE               * branch to DISPLAY_POSITIVE
            BRA         DISPLACE_NEGATIVE               * branch to DISPLAY_NEGATIVE

* Case for displacement being only 16 bits or 4 bytes ------------------------
WORDISP
            MOVEA.L     A6,A5                           * move A6 into A5
            MOVE.W      (A5),D1                         * move content in inside the address A5 into D1
            
            CMPI.L      #$7FFF,D1                       * compare if D1 is less than 7FFF
            BLT         DISPLACE_POSITIVE               * branch to DISPLAY_POSITIVE
            BRA         DISPLACE_NEGATIVE               * branch to DISPLAY_NEGATIVE

* Used for positive displacement or displacement that adds to the existing address -----------
DISPLACE_POSITIVE
            MOVE.L      A6,D0                           * move A6 into D0
            ADD.L       D1,D0                           * add D1 to D0
            CLR         D2                              * clear D2
            BRA         INSERT_DISPLACEMENT             * branch to INSERT_DISPACEMENT
            
* Used for negative displacement or displacement that subtracts from the existing address ----
DISPLACE_NEGATIVE
            MOVE.L      A6,D0                           * move A6 into D0
            NEG.W       D1                              * 2s compliment D1
            SUB.L       D1,D0                           * subtract D1 from D0
            CLR         D2                              * clear D2       
            BRA         INSERT_DISPLACEMENT             * branch to INSERT_DISPACEMENT

* Used after displacement is complete -------------------------------------------------------
DISPLACEMENT_DONE
            RTS                                     * return to subroutine

* Inputs the characters of the address that the displacement is done to ---------------------
INSERT_DISPLACEMENT
            CLR         D1                          * clear D1
            ADDI.B      #1,D2                       * add 1 to register D2
            CMPI.B      #9,D2                       * compare if the value in D2 is equal to 9
            BEQ         DISPLACEMENT_DONE           * branch to DISPLACEMENT_DONE if equal
            
            ROL.L       #4,D0                       * rotate left 4 bits to D0
            MOVE.B      D0,D1                       * move a byte from D0 to D1 
            LSL.B       #4,D1                       * shift 4 bits left in data register 1
            LSR.B       #4,D1                       * shift 4 bits right in data register 1
            
            CMPI.B      #0,D1                       * compare if D1 is 0
            BEQ         ADD_0                       * branch to ADD_0
            CMPI.B      #1,D1                       * compare if D1 is 1
            BEQ         ADD_1                       * branch to ADD_1
            CMPI.B      #2,D1                       * compare if D1 is 2
            BEQ         ADD_2                       * branch to ADD_2                       
            CMPI.B      #3,D1                       * compare if D1 is 3
            BEQ         ADD_3                       * branch to ADD_3               
            CMPI.B      #4,D1                       * compare if D1 is 4
            BEQ         ADD_4                       * branch to ADD_4
            CMPI.B      #5,D1                       * compare if D1 is 5
            BEQ         ADD_5                       * branch to ADD_5                   
            CMPI.B      #6,D1                       * compare if D1 is 6
            BEQ         ADD_6                       * branch to ADD_6
            CMPI.B      #7,D1                       * compare if D1 is 7
            BEQ         ADD_7                       * branch to ADD_7
            CMPI.B      #8,D1                       * compare if D1 is 8
            BEQ         ADD_8                       * branch to ADD_8                       
            CMPI.B      #9,D1                       * compare if D1 is 9
            BEQ         ADD_9                       * branch to ADD_9                      
            CMPI.B      #$A,D1                      * compare if D1 is A
            BEQ         ADD_A                       * branch to ADD_A
            CMPI.B      #$B,D1                      * compare if D1 is B
            BEQ         ADD_B                       * branch to ADD_B
            CMPI.B      #$C,D1                      * compare if D1 is C
            BEQ         ADD_C                       * branch to ADD_C
            CMPI.B      #$D,D1                      * compare if D1 is D
            BEQ         ADD_D                       * branch to ADD_D
            CMPI.B      #$E,D1                      * compare if D1 is E
            BEQ         ADD_E                       * branch to ADD_E
            CMPI.B      #$F,D1                      * compare if D1 is F
            BEQ         ADD_F                       * branch to ADD_F   

            BRA         INSERT_DISPLACEMENT         * branch to INSERT_DISPLACEMENT

ADD_0       * Add 0 to be printed
            JSR         Reg0                    * jumpt to Reg0
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT          
ADD_1       * Add 1 to be printed
            JSR         Reg1                    * jumpt to Reg1
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_2       * Add 2 to be printed
            JSR         Reg2                    * jumpt to Reg2
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_3       * Add 3 to be printed
            JSR         Reg3                    * jumpt to Reg3
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_4       * Add 4 to be printed
            JSR         Reg4                    * jumpt to Reg4
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_5       * Add 5 to be printed
            JSR         Reg5                    * jumpt to Reg5
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_6       * Add 6 to be printed
            JSR         Reg6                    * jumpt to Reg6
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_7       * Add 7 to be printed
            JSR         Reg7                    * jumpt to Reg7
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_8       * Add 8 to be printed
            JSR         HEX8                    * jumpt to Reg8
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_9       * Add 9 to be printed
            JSR         HEX9                    * jumpt to Reg9
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_A       * Add A to be printed
            JSR         HEXA                    * jumpt to HEXA
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_B       * Add B to be printed
            JSR         HEXB                    * jumpt to HEXB
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT           
ADD_C       * Add C to be printed
            JSR         HEXC                    * jumpt to HEXC
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_D       * Add D to be printed
            JSR         HEXD                    * jumpt to HEXD
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_E       * Add E to be printed
            JSR         HEXE                    * jumpt to HEXE
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
ADD_F       * Add F to be printed
            JSR         HEXF                    * jumpt to HEXF
            BRA         INSERT_DISPLACEMENT     * branch to INSERT_DISPLACEMENT
*--------------------------------------------------------------------------------------              
EA_DATA ;special case for MOVEQ instruction to determine data
            MOVE.B  #'#',(A2)+       *To signify immediate data
            MOVE.B  #'$',(A2)+       *Printing in hex
            CLR     D5
            MOVE.B  D6,D5            *Byte holds immediate data
            LSR.B   #4,D5            *Grab first character of immediate data
            LEA     Table0_7_8_F,A4  *Load jump table
            MULU.W  #8,D5            *For offset 
            JSR     (A4,D5)          *Print first character of immediate data   
  
            CLR     D5               *Clear to print second character
            MOVE.B  D6,D5            *Obtain data
            LSL.B   #4,D5            *Shift out first hex character
            LSR.B   #4,D5            *Shift second character back to its place
            LEA     Table0_7_8_F,A4  *Load jump table
            MULU.W  #8,D5            *For offset 
            JSR     (A4,D5)          *Print first character of immediate data
            RTS

*--------------------------------------------------------------------------------------
DESTDATAREG *For instructions with data-register only destinations (DIVU,MULU)
            MOVE.B  #',',(A2)+
            MOVE.B  #'D',(A2)+
            JSR     BIT9_11
            LEA     Table0_7_8_F,A4
            MULU    #8,D5
            JSR     (A4,D5)
            RTS   
DESTADDREG *For instructions with address-only destinations (MOVEA)
            MOVE.B  #'A',(A2)+
            JSR     BIT9_11
            LEA     Table0_7_8_F,A4
            MULU    #8,D5
            JSR     (A4,D5)
            RTS   
SOURCEDATAREG       *Used mainly for shift instructions
            MOVE.B  #'D',(A2)+
            JSR     BIT0_2
            LEA     Table0_7_8_F,A4
            MULU    #8,D5
            JSR     (A4,D5)
            RTS                
            
*------------------------Addressing Mode Jump Table-------------------------------------
ADDRESSTABLE JSR     dataReg    *data register
             RTS             
             JSR     addressReg *address register
             RTS             
             JSR     address    *address indirect
             RTS             
             JSR     addPostInc *address post increment
             RTS             
             JSR     addPreDec  *address pre decrement
             RTS             
             JSR     num5       *If number is somehow 5
             RTS             
             JSR     num6       *If number is somehow 6
             RTS             
             JSR     DATA  *Immediate/Absolute addressing
             RTS  
*------------------------num5 num 6 were undefined geoff-------------------------------------
num5         MOVE.B #'W',(A2)+
             MOVE.B #'H',(A2)+
             MOVE.B #'A',(A2)+
             MOVE.B #'T',(A2)+
             MOVE.B #'`',(A2)+
             MOVE.B #'S',(A2)+
             MOVE.B #'T',(A2)+
             MOVE.B #'H',(A2)+
             MOVE.B #'I',(A2)+
             MOVE.B #'S',(A2)+
             MOVE.B #'?',(A2)+
             RTS     
             
num6         MOVE.B #'W',(A2)+
             MOVE.B #'H',(A2)+
             MOVE.B #'A',(A2)+
             MOVE.B #'T',(A2)+
             MOVE.B #'`',(A2)+
             MOVE.B #'S',(A2)+
             MOVE.B #'T',(A2)+
             MOVE.B #'H',(A2)+
             MOVE.B #'I',(A2)+
             MOVE.B #'S',(A2)+
             MOVE.B #'?',(A2)+
             RTS     
             
             
*----------------------Source is a data register----------------------------------------          
dataReg 
            MOVE.B  #'D',(A2)+
            JSR     BIT0_2       
            
       *-------Figure out number of register---------*
            Lea     Table0_7_8_F,A4
            MULU    #8,D5
            JSR     (A4,D5)
            RTS
*----------------------Source is an address register------------------------------------ 
addressReg
            MOVE.B  #'A',(A2)+
            JSR     BIT0_2       
            
       *-------Figure out number of register---------*
            Lea     Table0_7_8_F,A4
            MULU    #8,D5
            JSR     (A4,D5)
            RTS
*----------------------Source is Indirect----------------------------------------------      
address *Indirect
            MOVE.B #'(',(A2)+
            MOVE.B #'A',(A2)+
            JSR     BIT0_2 *Isolate bits 0-2
            Lea     Table0_7_8_F,A4
            MULU    #8,D5
            JSR     (A4,D5)
            MOVE.B  #')',(A2)+
            RTS

            
*----------------------Source is address post-inc---------------------------------------      
addPostInc  
            MOVE.B  #'(',(A2)+
            MOVE.B  #'A',(A2)+
            JSR     BIT0_2 *Isolate bits 0-2
            Lea     Table0_7_8_F,A4
            MULU    #8,D5
            JSR     (A4,D5)
            MOVE.B  #')',(A2)+
            MOVE.B  #'+',(A2)+
            RTS
*----------------------Source is address pre-dec----------------------------------------      
addPreDec  
            MOVE.B  #'-',(A2)+
            MOVE.B  #'(',(A2)+
            MOVE.B  #'A',(A2)+
            JSR     BIT0_2 *Isolate bits 0-2
            Lea     Table0_7_8_F,A4
            MULU    #8,D5
            JSR     (A4,D5)
            MOVE.B  #')',(A2)+
            RTS
*----------------------Source is immediate or absolute data------------------------------    
Data
            MOVE.B  D6,D5
            LSL.B   #2,D5
            LSL.B   #3,D5
            LSR.B   #2,D5
            LSR.B   #3,D5
            CMPI.B  #%001,D5   *Checking if absolute long
            BEQ     ABSLONG
            CMPI.B  #%000,D5   *Checking if absolute word
            BEQ     ABSWORD
            CMPI.B  #%100,D5   *Checking for immediate data
            BEQ     IMMEDIATE
            RTS
*----------------------Immediate data---------------------------------------------------                       
IMMEDIATE             
            MOVE.B  #'#',(A2)+
            MOVE.B  #'$',(A2)+
            CMP.B   #2, D4     
            BEQ     IMEDBYTE   *Check if byte data
            CMP.B    #4, D4     
            BEQ     IMEDWORD   *Check if word data
            CMP.B   #8, D4     
            BEQ     IMEDLONG   *Check if long data
            RTS
*--------------------------------Shifts------------------------------------------------
WORDSHIFT1
            LSR.W   #6,D2
            LSR.W   #6,D2
            RTS
WORDSHIFT2
            LSL.W   #4,D2
            LSR.W   #6,D2
            LSR.W   #6,D2
            RTS

WORDSHIFT3
            LSL.W   #8,D2
            LSR.W   #6,D2
            LSR.W   #6,D2
            RTS
WORDSHIFT4
            LSL.W   #7,D2
            LSL.W   #5,D2
            LSR.W   #6,D2
            LSR.W   #6,D2
            RTS

BYTESHIFT1
            LSL.W   #8,D2
            LSR.W   #6,D2
            LSR.W   #6,D2
            RTS

BYTESHIFT2
            LSL.W   #6,D2
            LSL.W   #6,D2
            LSR.W   #6,D2
            LSR.W   #6,D2
            RTS
*---------------------------------Immediate Byte----------------------------------------
IMEDBYTE  
            MOVE.W  (A6)+,D3         *Assuming (A6)  holds current instruction
            MOVE.W  D3,D2
            JSR     BYTESHIFT1
            LEA     Table0_7_8_F,A4
            MULU.W  #8,D2
            JSR     (A4,D2)          *Convert current value from memory to hex
            MOVE.W  D3,D2
            JSR     BYTESHIFT2
            LEA     Table0_7_8_F,A4
            MULU.W  #8,D2            *For offset
            JSR     (A4,D2)          *Convert current value from memory to hex
            RTS
            
*---------------------------------Immediate Word-----------------------------------------           
IMEDWORD  *Converts 4 characters to hex
            MOVE.W  (A6)+,D3        *Assuming (A6)  holds current instruction
            MOVE.W  D3,D2
            JSR     WORDSHIFT1      *Shift first character
            LEA     Table0_7_8_F,A4 *Load table
            MULU.W  #8,D2
            JSR     (A4,D2)         *Convert current value from memory to hex
            MOVE.W  D3,D2
            JSR     WORDSHIFT2       *Shift second character
            LEA     Table0_7_8_F,A4 *Load table
            MULU.W  #8,D2
            JSR     (A4,D2)         *Convert current value from memory to hex
            MOVE.W  D3,D2
            JSR     WORDSHIFT3      *Shift third character
            LEA     Table0_7_8_F,A4 *Load table
            MULU.W  #8,D2
            JSR     (A4,D2)         *Convert current value from memory to hex
            MOVE.W  D3,D2
            JSR     WORDSHIFT4      *Shift fourth character
            LEA     Table0_7_8_F,A4  
            MULU.W  #8,D2           *For offset
            JSR     (A4,D2)         *Convert current value from memory to hex
            RTS  
*---------------------------------Immediate Long----------------------------------------       
IMEDLONG
            JSR IMEDWORD *First 4 characters
            JSR IMEDWORD *Last 4 characters
            RTS
*---------------------------------Absolute Long----------------------------------------    
ABSLONG
            MOVE.B #'$',(A2)+
            JSR IMEDWORD *First 4 characters
            JSR IMEDWORD *Last 4 characters
            RTS
*---------------------------------Absolute Word----------------------------------------    
ABSWORD     
            MOVE.B #'$',(A2)+
            JSR IMEDWORD  *Convert 4 characters to hex
            RTS 
                            
*-----------------------Hex/Register numbers0-----------------------------------------
Table0_7_8_F JSR     Reg0   *register 0
             RTS           
             JSR     Reg1   *register 1
             RTS             
             JSR     Reg2   *register 2
             RTS           
             JSR     Reg3   *register 3
             RTS            
             JSR     Reg4   *register 4
             RTS           
             JSR     Reg5   *register 5
             RTS             
             JSR     Reg6   *register 6
             RTS             
             JSR     Reg7   *register 7
             RTS
             JSR     HEX8   *Hex 8
             RTS             
             JSR     HEX9   *Hex 9
             RTS             
             JSR     HEXA   *Hex A
             RTS             
             JSR     HEXB   *Hex B
             RTS             
             JSR     HEXC   *Hex C
             RTS             
             JSR     HEXD   *Hex D
             RTS             
             JSR     HEXE   *Hex E
             RTS             
             JSR     HEXF   *Hex F
             RTS             
                                  
*-----------------------Register number printing and hex------------------------------
Reg0
            MOVE.B  #'0',(A2)+ *For displaying "0"
            RTS
Reg1
            MOVE.B  #'1',(A2)+ *For displaying "1"
            RTS 
Reg2
            MOVE.B  #'2',(A2)+ *For displaying "2"
            RTS  
Reg3
            MOVE.B  #'3',(A2)+ *For displaying "3"
            RTS    
Reg4
            MOVE.B  #'4',(A2)+ *For displaying "4"
            RTS   
Reg5
            MOVE.B  #'5',(A2)+ *For displaying "5"
            RTS     
Reg6
            MOVE.B  #'6',(A2)+ *For displaying "6"
            RTS    
Reg7
            MOVE.B  #'7',(A2)+ *For displaying "7"
            RTS
HEX8
            MOVE.B #'8',(A2)+  *For displaying "8"
            RTS

HEX9
            MOVE.B #'9',(A2)+  *For displaying "9"
            RTS
HEXA
            MOVE.B #'A',(A2)+  *For displaying "A"
            RTS
HEXB
            MOVE.B #'B',(A2)+  *For displaying "B"
            RTS
HEXC
            MOVE.B #'C',(A2)+  *For displaying "C"
            RTS
HEXD
            MOVE.B #'D',(A2)+  *For displaying "D"
            RTS
HEXE
            MOVE.B #'E',(A2)+  *For displaying "E"
            RTS
HEXF   
            MOVE.B #'F',(A2)+  *For displaying "F"
            RTS        


********************************************************************************************************************

* Prints the decoded OP-Code in this order ------------------------
* (address of code, OP-Code, addressing (if applicable) -----------      
PRINT      
        MOVE.B      #$00,(A2)           * add NULL value to print string
        LEA         $0000F000,A1        * load address to start printing from
        MOVEQ       #13,D0              * load task 13 into D0
        TRAP        #15                  
        JSR         CHECK_LINES         * check if 30 lines are printed 
        RTS                             * return to subroutine
              
* Check current address to see if end address is reached -------------        
CHECK_IF_DONE
        LEA         compareEnd,A5       * load compareEnd into A5
        MOVE.L      (A5),D5             * move content of A5 into D5
        CMP.L       D5,A6               * compare D5 and A6
        BGE         FINISHED            * branch if greater or equal
        RTS                             * return to subroutine
        
* Checks how many lines are on the display at one time ---------------    
CHECK_LINES
        LEA         numOfLines,A4       * load number of lines storage address into A4
        ADDI.B      #$1,(A4)             * add 1 to the line counter
        CMPI.B      #$1E,(A4)            * compare if number of lines is 30
        BEQ         LINE_LIMIT          * branch if equal to 30
        RTS                             * return to subroutine 

* Allows to print only 30 lines of OP code per page ------------------
LINE_LIMIT
        LEA         NEXT_PAGE,A1        * load NEXT_PAGE message
        CLR         D0                  * clear D0
        MOVE        #14,D0              * load trap task 14 into D0
        TRAP        #15
        
        LEA         run,A1              * load end address to be stored
        MOVE.B      #2,D0               * move task #2 to D0
        TRAP        #15 
        
        CMPI.B      #$2,D0              * compare if input is 
        BEQ         CONTINUE_PRINT      * branch to CONTINUE_PRINT if equal
        BRA         DONT_CONTINUE       * branch to DONT_CONTINUE

* Prevents from going to next page if enter is not pressed -----------
DONT_CONTINUE
        MOVE.B      #2,D0               * move task #2 to D0
        TRAP        #15 

        CMPI.B      #$2,D0              * compare if input is 
        BEQ         CONTINUE_PRINT      * branch to CONTINUE_PRINT if equal
        BRA         DONT_CONTINUE       * branch to DONT_CONTINUE

* Goes back to printing OP-codes -------------------------------------
CONTINUE_PRINT
        RTS                             * return to subroutine

* The program has deconstructed from start address to end address ----
FINISHED
        LEA         FINISHEDPRINT,A1    * load finished message
        MOVE        #14,D0              * load trap task 14 into D0
        TRAP        #15
        
        BRA         FINISHED_NEXT        * branch to STOP
 
 * Asks user if they want to use the program again --------------------
FINISHED_NEXT        
        LEA         RUNAGAIN,A1         * load run again meesage
        MOVE        #14,D0              * load trap task 14 into D0
        TRAP        #15
        
        LEA         run,A1              * load end address to be stored
        MOVE.B      #2,D0               * move task #2 to D0
        TRAP        #15 
       
        CLR         D1                  * clear D1       
        MOVE.B      (A1),D1             * move content in A1 to D1
        CMPI.B      #$79,D1             * compare if input is y
        BEQ         RUN_AGAIN           * branch if equal
        CMPI.B      #$59,D1             * compare if input is Y
        BEQ         RUN_AGAIN           * branch if equal
        CMPI.B      #$6E,D1             * compare if input is n
        BEQ         STOP                * branch if equal
        CMPI.B      #$4E,D1             * compare if input is N
        BEQ         STOP                * branch if equal
        
        BRA         BAD_RERRUN          * branch to BAD_RERRUN

* In case the user input for rerrun is not valid --------------------
BAD_RERRUN
        LEA         BAD_ANSWER,A1       * load bad answer
        MOVE        #14,D0              * load trap task 14 into D0
        TRAP        #15
        
        LEA         run,A1              * load end address to be stored
        MOVE.B      #2,D0               * move task #2 to D0
        TRAP        #15 

        CLR         D1                  * clear D1       
        MOVE.B      (A1),D1             * move content in A1 to D1
        CMPI.B      #$79,D1             * compare if input is y
        BEQ         RUN_AGAIN           * branch if equal
        CMPI.B      #$59,D1             * compare if input is Y
        BEQ         RUN_AGAIN           * branch if equal
        CMPI.B      #$6E,D1             * compare if input is n
        BEQ         STOP                * branch if equal
        CMPI.B      #$4E,D1             * compare if input is N
        BEQ         STOP                * branch if equal

        BRA         BAD_RERRUN          * branch to BAD_RERRUN
        
* Run the program again ----------------------------------------------        
RUN_AGAIN
        JSR         CLEARALL            * jump to CLEALL
        BRA         START               * branch to START
                              
* Clears all registers -----------------------------------------------       
CLEARALL
        CLR         D0
        CLR         D1
        CLR         D2
        CLR         D3
        CLR         D4
        CLR         D5
        CLR         D6
        CLR         D7

        RTS
        
* End the program ----------------------------------------------------
STOP   
        MOVE.B      #9,D0               * move task #9
        TRAP        #15
   
* --------------------------------------------------------------------
**********************************************************************
* --------------------------------------------------------------------
   
CR      EQU         $0D
LF      EQU         $0A

* Messages to be printed ---------------------------------------------

* Info about the program and how to use it
INFO    DC.B        'Jump-9k is a EASy68K deconstructor that takes in OP-Code commands',CR,LF
        DC.B        'and executes those commands. The commands that are acceptable must',CR,LF
        DC.B        'be in hexadecimal format. Both capital and lower case letters are',CR,LF
        DC.B        'accepted to be deconstructed ($00000000 to 00FFFE00)',CR,LF,CR,LF,0

* different address errors 
NOADDRESS_ERR   DC.B    'No input for address, try again',CR,LF,CR,LF,0
INPUTTOOLARGE   DC.B    'Address input cannot exceed 8 characters',CR,LF,0
TOOSMALLADDRESS DC.B    'Address input must be above 00000000',CR,LF,0
TOOLARGEADDRESS DC.B    'Address input must be below 00FFFE00',CR,LF,0
ENDBIGGERSTART  DC.B    'The end address must be bigger than the start address',CR,LF,0
NOTEVEN         DC.B    'The address input has to be an even value...',CR,LF,0

RUNAGAIN        DC.B    'Do you want to run the program again? (y,n) ',0
BAD_ANSWER      DC.B    CR,LF,'Invalid answer, please input y or n ',0
NEXT_PAGE       DC.B    'Please click Enter to go to next page...',0

BADINPUT DC.B       'Input is not valid try again...',CR,LF,0
BADADDRESS DC.B     'Address input is not valid try again...',CR,LF,0
GOODOP  DC.B        'OP Code is valid, I will pass it to John',CR,LF,0
INPUTSTARTADD DC.B  'Enter a starting address for the deconstructor: ',0
INPUTENDADD DC.B    CR,LF,'Enter ending address: ',0

FINISHEDPRINT   DC.B    CR,LF,'The program has completed the deconstruction!!!',CR,LF,0


SCREEN  DC.B        '///////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\',CR,LF
        DC.B        '|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||',CR,LF
        DC.B        '....................-.                 .-....................',CR,LF
        DC.B        '................../´¯)                 (¯`\..................',CR,LF
        DC.B        '................./¯../                 \..¯\.................',CR,LF
        DC.B        '................/.../                   \...\................',CR,LF
        DC.B        '.........../´¯¯/´´´/¯¯¯`-.         .-´¯¯¯\```\¯¯`\...........',CR,LF
        DC.B        '........./´/../.../..../´¯\       /¯`\....\...\..\`\.........',CR,LF
        DC.B        '........( (  ´...´. ¯ /´..`)     (´..`\ ¯ .`...`..) )........',CR,LF
        DC.B        '.........\............`..../     \....´............/.........',CR,LF
        DC.B        '..........\........... _.·´       `·._ .........../..........',CR,LF
        DC.B        '...........\..........(               )........../...........',CR,LF
        DC.B        '............\..........\             /........../............',CR,LF
        DC.B        '.............................................................',CR,LF
        DC.B        '|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||',CR,LF
        DC.B        '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////',CR,LF,CR,LF,0
 
PROJECT DC.B        '.............................................................',CR,LF
        DC.B        '......_..._....._..._....._..._____..........._____..._..._..',CR,LF
        DC.B        '.....| |.| |...| |.| |...| |.|  __ \........./ __  |.| |./ /.',CR,LF
        DC.B        '.....| |.| |...| |.| \.../ |.| |__| |..___..| |__| |.| |/ /..',CR,LF
        DC.B        '.....| |.| |...| |.|  \./  |.|  ___/..|___|..\___  |.|   |...',CR,LF
        DC.B        '|-|__| |.| |___| |.| |\_/| |.| |.................| |.| |\ \..',CR,LF
        DC.B        '|______|.|_______|.|_|...|_|.|_|.................|_|.|_|.\_\.',CR,LF
        DC.B        '.............................................................',CR,LF,CR,LF
        DC.B        '.................... Jump Table Junkies .....................',CR,LF
        DC.B        '...........Bogdan Boiko, Geoffrey Lebbos, John Sliwa.........',CR,LF,CR,LF,0  
                     

    
    
    
    

TESTPOG1
*test ADD,ADDI,ADDA instructions

          ADD.B   D0,D1
          ADD.W     D0,D1
          ADD.L     D0,D1
          ADD.L     (A0),D1
          ADD.L     (SP),D1
          ADD.W     (A0)+,D2
          ADD.L     -(A0),D5
          ADD.L  #$7000,D0
          ADD.W     $7000,D0
          ADD.W  4(PC),D0
          ADD.L  9(PC),D0
          ABCD D0,D1     *DATA
          ADDA.W D1,A0
          ADDA.L D1,A0
          ADDA.L    (A0),A0
          ADDA.W    (A0)+,A5
          ADDA.W    -(A0),A3
          ADDA.L  #$7000,A0
          ADDA.W    $6000,SP
          ADDA.W  4(PC),A6
          ADDA.L  9(PC),A5
          ABCD D0,D1     *DATA
          ADDI.B #$30,(A0)
          ADDI.W #4000,(A0)+
          ADDI.L    #$4040A0A0,-(A0)
          ADDI.L  #$70000000,(SP)
          ADDI.W    #$6000,(SP)
          MOVE.L    #$FFFFFFFF,D0   


TESTPOG2
*test AND,ANDI,ASL,ASR,LSL,LSR,BSR,JSR,RTS

          AND.B  D0,D1
          AND.W     D0,D1
          AND.L     D0,D1
          AND.L     (A0),D1
          AND.L     (SP),D1
          AND.W     (A0)+,D2
          AND.L     -(A0),D5
          AND.L  #$7000,D0
          AND.W     $7000,D0
          AND.B  #$30,D0
          AND.W  #4000,(A0)+
          AND.L     #$4040A0A0,-(A0)
          AND.L  #$70000000,(SP)
          AND.W     #$6000,(SP)
          ABCD D0,D1          *DATA
          ANDI.B #$80,D1
          ANDI.W    #$756A,D1
          ANDI.L    #80808080,(A0)
          ANDI.B #$80,(A0)+
          ANDI.W    #$756A,-(A0)
          ANDI.L    #80808080,(SP)
          ANDI.W    #$756A,D1
          ANDI.L    #80808080,D1
          LSL.B     #01,D1
          LSL.W     #01,D2
          LSL.L     #01,D4
          LSR.B     #01,D1
          LSR.W     #01,D2
          LSR.L     #01,D4
          ABCD D0,D1
          ASL.B     #01,D1
          ASL.W     #01,D2
          ASL.L     #01,D4
          ASR.B     #01,D1
          ASR.W     #01,D2
          ASR.L     #01,D4
          JSR  TESTPOG2
          RTS
          JMP  TESTPOG2
          BSR  TESTPOG2
          MOVE.L    #$FFFFFFFF,D0


TESTPOG3
*test CLR,CMP,CMPI,EOR,EORI,LEA
     
          LEA  TESTPOG3,A0
          LEA  TESTPOG3,A7   
          LEA  TESTPOG2,A3
          CLR  D0
          CLR  D7
          CLR  (A0)+
          CLR  -(A0)
          CLR  (SP)
          CLR  (SP)+
          CLR  $07(A2,A5.L)
          CMP  (A0),D0
*          CMP.B  A0,D0
*          CMP.W  SP,D6
          CMP.L  (SP)+,D2
          CMP  $07(A2,A3.W),D3
          CMPA $07(A2,A3.W),A0     
          CMPA $9(A2,A3.W),A6
          CMPA   A0,A2
          CMPA   A0,SP
          CMPA   $8010A0FC,A3
          CMPA  $8032,A1
          CMPI  #$500,D0
*         CMPI  #$A010A898,(A3)
          CMPI  #$A98F,$07(A2,A3.W)
          CMPI.L  #$A9CD8032,(A3)
          CMPI.L  #$A984,$F(A6,A6)
          EOR  D0,D2
          EOR  D1,(A0)
          EOR  D1,(A0)+
          EOR  D1,(SP)+
          EOR  D6,-(A0)
*           EOR  D6,$8082
*           EOR  D3,$A0FCA083
*           EOR  D3,$07(A3,A2.L)
*           EORI #$A986,D1
*           EORI #$A98ACDC6,D1
*           EORI #$A9,D3
* *          EORI #$A986,$07(A3,A2.L)
* *          EORI #$A98ACDC6,(A0)+
*           EORI #$A9,(SP)
*           MOVE.L    #$FFFFFFFF,D0
          
          
TESTPOG4
*test EXG,NOP,NEG,NOT,OR,ORI
          EXG  D0,D1
          EXG  A0,A1
          EXG  D0,A1
          EXG  A5,D0
          NOP
          NOP  
          NOP
          NEG  D0
          NEG  (A0) 
          NEG  (A0)+
          NEG  -(A0)
          NEG  (SP)+
          NEG  $07(A2,A3.L)
          NOT  D7
          NOT  (A0) 
          NOT  (A0)+
          NOT  -(A0)
          NOT  (SP)+
          NOT  $07(A2,A3.L)
          OR   D0,(A0)
          OR   (A0),D7
          OR   $07(A4,A0.L),D7
          OR   D7,$07(A4,A0.L)
          OR   (SP)+,D7
          OR   (A0)+,D3
          OR   -(A0),D1
          OR   D1,-(A0)
          ORI  #04,(A0)
          ORI  #$9862,D7
          ORI  #$2982,$07(A4,A0.L)
          ORI  #$29,$07(A4,A0.L)
          ORI.L     #$1,D7
          ORI.W     #$FFFF,(A0)+
          ORI.B     #$F,D1
          ORI  #$A082,-(A0)
          MOVE.L    #$FFFFFFFF,D0


TESTPOG5
*test ROL,ROR,SUB,SUBA,SUBI,SWAP

*           SUB  D0,(A0)
*           SUB  (A0),D7
*           SUB  $07(A4,A0.L),D7
*           SUB  D7,$07(A4,A0.L)
          SUB  (SP)+,D7
          SUB  (A0)+,D3
          SUB  -(A0),D1
          SUB  D1,-(A0)
          SUBA $07(A4,A0.L),A0
          SUBA $07(A4,A0.L),A1
          SUBA $07(A4,A0.L),A2
          SUBA $07(A4,A0.L),A3
          SUBA $07(A4,A0.L),A4
          SUBA $07(A4,A0.L),A5     
          SUBA $07(A4,A0.L),A6
          SUBA D0,A3
          SUBA $00AA00AA,A7
          SUBA $A000,SP
          SUBI #$04,(A0)
          SUBI #$A000,(A3)+
          SUBI #$A000,-(SP)
          SUBI #$FFFF,$07(A4,A0.L)
          ROL  #8,D0
          ROR  #8,D7
          ROL  #1,D2
          ROR  #3,D4
          SWAP D0
          SWAP D1
          SWAP D2
          SWAP D3
          SWAP D4   
          SWAP D6
          MOVE.L    #$FFFFFFFF,D0
     

TESTPOG6
*MOVE,MOVEA,MOVEM
     
          MOVE $AA00,$AB00
          MOVE $AA00AA,$AB00AB
          MOVE $FFAAFFBB,$ACD3F70
          MOVE (A0),D0
          MOVE (A0)+,D3
          MOVE $AA00,A0
          MOVE $AA00,SP
          MOVE $FFFF,(SP)+
          MOVE (SP)+,D0
          MOVEM     A0/A1/A2/A3,(SP)-
          MOVEM     (SP)+,A0/A1/A2/A3   
          MOVEM     A0-A6,(SP)-
          MOVEA     $07(A4,A0.L),A0
          MOVEA     $00AA77FF,A6
          MOVEA     (SP),A2
          MOVEA     (SP)+,A3
          MOVEA     -(A3),A4
          MOVEA     D3,A1
          MOVE.L    #$FFFFFFFF,D0
          
    END    START        ; last line of source

