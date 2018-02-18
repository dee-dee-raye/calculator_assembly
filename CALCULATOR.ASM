TITLE "Calculator"
;****************************************************************************************
;* Title:       Calculator                                                                                                                         *
;* Author:    Dee Dee McCroskey           										    				                                    *
;* Date:		10/ 14/16																                        				                  *
;* Purpose:	  This program is a simple calculator.																                    *
;****************************************************************************************
;* Grading:    Correctness      ___________                                                                                        *
;*                  Style                 ___________                                                                                        *
;*                  Documentation  ___________                                                                                        *
;****************************************************************************************

                    .MODEL      small
                    STACK       256
;****************************************************************************************
;* Equates Section                                                                                                                              *
;****************************************************************************************

EOS       EQU     0                                                       ; End of string
maxLen  EQU     40                                                     ; Max entry string length

;****************************************************************************************
;* Data Section                                                                                                                                    *
;****************************************************************************************
                .DATA

exCode                      db              0                                                                    ;DOS error code
calculator                  db              'My Calculator.',EOS                                     ;calculator opening
firstValulePrompt     db              'Enter first value          :',EOS                      ;prompt to get first value
secondValuePrompt   db              'Enter second value         :',EOS                    ;prompt to get second value
operationPrompt       db              'Enter operation (+, -, C)  :',EOS                    ;prompt to get operation
resultListing             db              'The result is              :',EOS                         ;listing of result
promptForCalc          db              'Do another calculation (Y or N)? ',EOS        ;question of another calculation
endingMessage         db               'Exiting Program.',EOS                                 ;message for end of program
subSign                    db               '-',EOS                                                          ;string of -
addSign                    db               '+',EOS                                                                    ;string of +
firstValueBuffer      db              maxLen DUP (?)                                                        ;holds first value from user
secondValueBuffer   db              maxLen DUP (?)                                                        ;holds second value from user
operationBuffer       db              maxLen DUP (?)                                                         ;holds operation from user
responseBuffer        db              maxLen DUP (?)                                                         ;holds yes or no response from user
result                       dw              0                                                                               ;result from math
firstValue                dw              0                                                                                ;store first value in binary
secondValue             dw              0                                                                                ;store second value in binary
compGreaterResult  db              'The second number is larger than the first.',EOS    ;result of greater than comparison
compLessResult       db              'The second number is less than the first.',EOS       ;result of less than comparison
compEqualResult      db              'The second number is equal to the first.' ,EOS       ;result of equal comparison
errorMessage          db               'Not valid entry.',EOS                                              ;message for bad entries
overFlowMessage    db               'Error - Overflow',EOS                                              ;message for overflows
resultRecord            db              maxLen DUP (?)                                                         ;result from to be shown on screen

;****************************************************************************************
;* Code Section                                                                                                                                   *
;****************************************************************************************
                .CODE

;****************************************************************************************
;* External procedures from STRINGS.OBJ & STRIO.OBJ                                                               *
;****************************************************************************************

                EXTRN       StrLength:proc, StrRead:proc
                EXTRN       StrWrite:proc,   NewLine:proc

;****************************************************************************************
;* External procedures from BASIC.OBJ                                                                                           *
;****************************************************************************************
                EXTRN       BinToAscHex:proc,   SBinToAscDec:proc,  BinToAscDec:proc
                EXTRN       BinToAscBin:proc,    AscToBin:proc

;****************************************************************************************
;* Main entry point of program.                                                                                                           *
;****************************************************************************************
Start:
                mov         ax, @data                                               ;initialize DS to address
                mov         ds, ax                                                      ; of data segment
                mov         es, ax                                                      ; make es=ds
;****************************************************************************************
;* Start of program.                                                                                                                            *
;****************************************************************************************
                call NewLine                                                            ;put a new display line on the screen
                mov di, OFFSET calculator                                      ;pointer to start of calculator string
                call StrWrite                                                           ;put calculator string on screen
                call NewLine                                                            ;put a new display line on the screen
        Main:
                call NewLine                                                             ;display new display line on screen

;****************************************************************************************
;* Get values from user and store them.                                                                                             *
;****************************************************************************************

            ;*********************************************************************************
            ;* Prompt user for first value and store it as binary while error checking.                             *
            ;*********************************************************************************
                mov di, OFFSET firstValulePrompt                          ;pointer to start of firstValulePrompt string
                call StrWrite                                                           ;put firstValulePrompt on screen
                mov di, OFFSET firstValueBuffer                           ;pointer to start of firstValueBuffer
                mov cx, maxLen                                                       ;max a user can type in
                call StrRead                                                            ;read in user response
                call NewLine                                                            ;display new display line on screen

                mov di, OFFSET firstValueBuffer                          ;pointer to start of firstValueBuffer
                call AscToBin                                                          ;convert to binary
                jnc continueOnFirstNum                                         ;continue past error because number was entered
                jmp error                                                               ;go to error section
            continueOnFirstNum:
                mov firstValue,ax                                                    ;store binary result in firstValue

                ;*******************************************************************************
                ;* Prompt user for second value and store it as binary while error checking.                      *
                ;*******************************************************************************

                mov di, OFFSET secondValuePrompt                        ;pointer to start of secondValuePrompt string
                call StrWrite                                                           ;put secondValuePrompt on screen
                mov di, OFFSET secondValueBuffer                        ;pointer to start of secondValueBuffer
                mov cx, maxLen                                                       ;max a user can type in
                call StrRead                                                            ;read in user response
                call NewLine                                                            ;display new display line on screen

                mov di,OFFSET secondValueBuffer                        ;pointer to start of secondValueBuffer
                call AscToBin                                                          ;convert to binary
                jnc continueOnSecondNum                                      ;continue past error because number was entered
                jmp error                                                               ;go to error section
            continueOnSecondNum:
                mov secondValue,ax                                                ;store binary result in secondValue

                ;*******************************************************************************
                ;* Prompt user for operation and store it as binary while error checking.                           *
                ;*******************************************************************************

                mov di, OFFSET operationPrompt                          ;pointer to start of operationPrompt string
                call StrWrite                                                         ;put operationPrompt on screen
                mov di, OFFSET operationBuffer                          ;pointer to start of operationBuffer
                mov cx, maxLen                                                     ;max a user can type in
                call StrRead                                                          ;read in user response
                call NewLine                                                          ;display new display line on screen

;****************************************************************************************
;* Determine occupation and perform it.                                                                                             *
;****************************************************************************************

            ;*******************************************************************************
            ;* Addition.                                                                                                                         *
            ;*******************************************************************************

                mov al, addSign                                                     ;put addSign in ax register
                cmp operationBuffer, al                                       ;check if + response
                je  addition                                                           ;go to addition Section
                jmp past                                                               ;go to next check point
                addition:
                        mov ax, firstValue                                        ;move firstValue to ax register
                        add ax, secondValue                                     ;store addition of secondValue and firstValue in secondValue
                        jo overFlowError                                         ;go to overflow section
                        mov result, ax                                              ;move result of addition into result
                        mov di, OFFSET resultRecord                     ;pointer to start of resultRecord
                        mov cx, 0                                                      ;set size to be results size
                        mov ax, result                                              ;move result into ax register
                        call SbinToAscDec                                       ;convert binary result into asc decimal
                        mov di, OFFSET resultListing                      ;pointer to start of resultListing string
                        call StrWrite                                               ;put resultListing on screen
                        mov di, OFFSET resultRecord                     ;pointer to start of result
                        call StrWrite                                               ;result to screen
                        jmp Repeat                                                   ;go to repeat section

            ;*******************************************************************************
            ;* Subtraction.                                                                                                                    *
            ;*******************************************************************************

            past:
                mov al, subSign                                                     ;move subSign in ax register
                cmp operationBuffer, al                                       ;check if - response
                je subtraction                                                       ;go to subtraction Section
                jmp pastAgain                                                       ;go to next check point
                subtraction:
                        mov ax, firstValue                                       ;move firstValue to ax register
                        sub ax, secondValue                                     ;store subtraction of secondValue and firstValue in secondValue
                        jo overFlowError                                          ;go to overFlowError section
                        mov result, ax                                              ;move result of subtraction into result
                        mov di, OFFSET resultRecord                     ;pointer to start of resultRecord
                        mov cx, 0                                                     ;set size to be result size
                        mov ax, result                                              ;move result into ax register
                        call SbinToAscDec                                       ;convert binary result into asc decimal
                        mov di, OFFSET resultListing                      ;pointer to start of resultListing string
                        call StrWrite                                               ;put resultListing on screen
                        mov di, OFFSET resultRecord                     ;pointer to start of result
                        call StrWrite                                               ;result to screen
                        jmp Repeat                                                   ;go to repeat section

            ;*******************************************************************************
            ;* Compare.                                                                                                                          *
            ;*******************************************************************************

            pastAgain:
                cmp operationBuffer, 'C'                                      ;check if C response
                jne nextPossible                                                     ;go to lower c check point
                jmp compare                                                           ;go to compare
                nextPossible:
                    cmp operationBuffer, 'c'                                      ;check if c response
                    jne error                                                               ;go to error section
                compare:
                        mov ax, firstValue                                       ;move firstValue to ax register
                        cmp ax, secondValue                                   ;compare first and second value
                        jo  overFlowError                                       ;go to overFlowError section
                        jl greaterCompare                                     ;go to greaterCompare
                        cmp ax, secondValue                                  ;compare first and second value
                        jg lesserCompare                                       ;go to lesserCompare
                        cmp ax, secondValue                                  ;compare first and second value
                        je equalCompare                                         ;go to equalCompare

;****************************************************************************************
;* Handle errors.                                                                                                                                 *
;****************************************************************************************

                    errorJumper:
                            jmp error                                                   ;go to main error handling section

                    overFlowError:
                            call NewLine                                                ;put new display line on screen
                            mov di, OFFSET overFlowMessage              ;pointer to start of overFlowMessage
                            call StrWrite                                              ;put overFlowMessage on screen
                            call NewLine                                                ;put new display line on the screen
                            jmp Main                                                     ;go to repeat section

                error:
                        call NewLine                                                  ;put new display line on screen
                        mov di, OFFSET errorMessage                     ;pointer to start of errorMessage
                        call StrWrite                                               ;put error message on screen
                        call NewLine                                                 ;put new display line on the screen
                        jmp Main                                                      ;go to repeat section

;****************************************************************************************
;* Individual comparisons.                                                                                                                   *
;****************************************************************************************

                    greaterCompare:
                        mov di, OFFSET compGreaterResult            ;pointer to beginning of compGreaterResult
                        call StrWrite                                               ;put compGreaterResult on screen
                        jmp Repeat                                                  ;go to repeat section
                        jmp Repeat                                                  ;go to repeat section

                lesserCompare:
                        mov di, OFFSET compLessResult               ;pointer to beginning of compLessResult
                        call StrWrite                                             ;put compLessResult on screen
                        jmp Repeat                                                 ;go to repeat section

                equalCompare:
                        mov di, OFFSET compEqualResult              ;pointer to beginning of compEqualResult
                        call StrWrite                                              ;put compEqualResult on screen
                        jmp Repeat                                                  ;go to repeat section

;****************************************************************************************
;* Check if user wants to continue.                                                                                                     *
;****************************************************************************************

                Repeat:
                        call NewLine                                                       ;put new display line on screen
                        call NewLine                                                       ;put new display line on screen
                        mov di, OFFSET promptForCalc                         ;pointerto start of calc question
                        call StrWrite                                                    ;put cal question on screen
                        mov	di,	OFFSET responseBuffer	                   ;pointer to beginning of response
	                    mov	cx,	maxLen			                                      ;set max size for entering response
	                    call strRead				                                      ;read reponse in
	                    call NewLine				                                     ;put new display line on screen
                        cmp	responseBuffer, 'Y'		                             ;check for if response was Y
	                    jne next1				                                           ;go check if lower case Y
	                    jmp	Main				                                          ;go to main if Y
	                    next1:
                            cmp	responseBuffer, 'y'	                            ;check for if respose was y
	                     jne next2				                                         ;go to ending if not lower Y
	                    jmp	Main				                                         ;go back to main part of program

                        next2:
	                       call	NewLine				                                    ;put new display line on screen
	                        mov	di,	OFFSET endingMessage                 ;pointer to beginning of good bye message
	                        call StrWrite			                                   ;put good bye message on screen

;****************************************************************************************
;* End of program.                                                                                                                               *
;****************************************************************************************
Done:
                call NewLine

;****************************************************************************************
;* Program termination code.                                                                                                               *
;****************************************************************************************
                mov     ah, 04Ch                          ;DOS function: Exit program
                mov     al, exCode                        ;return exit code value
                int       21h                                   ;call DOS. Terminate program

                END     Start                               ;end of program / entry point
