; By Michael Winkler & Ido Nidbach

; MULTI-SEGMENT EXECUTABLE FILE TEMPLATE.

DSEG SEGMENT
    
    ;Messages:
    
    MSG1 DB 'PRESS ANY KEY TO START THE GAME$'
    MSG2 DB 'ENTER YOUR GUESS (4 DIGITS): $'
    MSG3 DB 'INVALID GUESS$'
    MSG4 DB 'WINNER + NUMOFGUESS: $'
    MSG5 DB 'NUMBER OF BULLSEYES/HITS: $' ;(AFTER EACH GUESS)
    MSG6 DB 'ZERO CANT BE THE FIRST NUMBER IN YOUR GUESS$'
    MSG7 DB 'YOU HAVE ENTERED THE SAME DIGIT TWICE.$'
    MSG8 DB 'TRY AGAIN$'
    MSG9 DB 'YOU HAVE LOST THE GAME, NUMBER OF TRIES: $'
    RES1 DB 'YOU HAVE $' 
    RES2 DB ' BULLSEYES & $'
    RES3 DB ' HITS$'
    RES4 DB 'THE NUMBER WAS: $'
    LOST DB ' 13$'
      
      
    ; Counters:  
      
    HITCOUNTER DB 0H
    BULLCOUNTER DB 0H
    
    TRIES DB 0H
    RESTCOUNTER DB 0H           
    VALIDDIGITCOUNTER DB 0H
    CHECKCOUNTER DB 0H
    COUNTER DB 0H    
    
    
    DIGTOCHECK DB ?
              
    ;Computer generated num   
    COMPUTERNUM DB 0,0,0,0  
    
    ;User input
    USERGUESS DB 4+1,4+2 DUP (?)
DSEG ENDS

SSEG SEGMENT    
    
    DW   128  DUP(0)

SSEG ENDS

CSEG SEGMENT
ASSUME DS:DSEG,SS:SSEG,CS:CSEG

START:

    MOV AX, DSEG
    MOV DS, AX

    

       PROGRAM_START:
;THIS PRINTS THE STRING 'STARTMSG' ON THE SCREEN   
                MOV DX, OFFSET MSG1
                MOV AH, 9
                INT 21H
                ; New line:            
                MOV DL, 10
                MOV AH, 02H
                INT 21H
                MOV DL, 13
                MOV AH, 02H
                INT 21H
                ;Asks for user input without showing on screen
                MOV AH, 7
                INT 21H 
                
    
       RANDOM_NUMBER:
                MOV CX, 0004H
 
                CALL GENERATE
                MOV CX, 4 ; TO RESET THE COUNTER TO CHECK THE ARRAY FOR SAME NUMBERS
                MOV COUNTER, 0
                XOR AX, AX
                XOR DX, DX
                JMP FINISHED_RANDOM
                
                               
                 
               ;Generate a 4 digit number 
       GENERATE:
               
               XOR AX,AX
               MOV AH,2CH
               INT 21H
               MOV AX,DX
               XOR DX,DX
               MOV BX, 000AH
               DIV BX
               MOV DIGTOCHECK, DL
               XOR BX,BX
               MOV BL, COUNTER
               MOV BYTE PTR COMPUTERNUM +[BX], DL
               CMP COUNTER, 00H
               MOV CHECKCOUNTER, 0
               JE FIRST_DIGIT_CHECK
               JNE DIGIT_CHECKER  
               
               ;This is where we come back after checking if the first number is zero.
       RETURNFROM:    
               MOV CX, 4
               
               INC COUNTER
               CMP COUNTER, 4
               JNE GENERATE
               JE FINISHED_RANDOM
               

               ;This checks if the first digit of the randomized number is zero
       FIRST_DIGIT_CHECK:
               CMP COMPUTERNUM[0] , 00H
               JE GENERATE
               JNE RETURNFROM
                            

                
                
                ;Compare if the 'checkcounter' is equal to 4, if it is, 
                ;it means that we checked all the elements inside the array for duplicates.
       DIGIT_CHECKER: 
                CMP CHECKCOUNTER, 04H
                JE RETURNFROM
                XOR BX, BX
                MOV BL, CHECKCOUNTER 
                INC CHECKCOUNTER
                CMP BL, COUNTER
                JE RETURNFROM 
                MOV AL, DIGTOCHECK
                CMP AL, BYTE PTR COMPUTERNUM + [BX]
                
                JE GENERATE
                JMP DIGIT_CHECKER


     
 
       FINISHED_RANDOM: 
                ;This is where we arrive after the computer generated 4 digits.
                MOV DX, OFFSET MSG2 
                MOV AH, 9
                INT 21H
                ;Line break
                MOV DL, 10
                MOV AH, 02H
                INT 21H
                MOV DL, 13
                MOV AH, 02H
                INT 21H         
                ;Asks user for guess:
                MOV DX, OFFSET USERGUESS
                MOV AH, 0AH
                INT 21H
                MOV CX, 4
                MOV DL, 13
                MOV AH, 02H
                INT 21H
                
                MOV CHECKCOUNTER, 02H
                CALL INPUT_CHECK
                                ; USERGUESS = INPUT (FROM INDEX 2 TO 5>
                MOV COUNTER, 2H
                XOR BX, BX
                MOV BL, COUNTER
                JMP OUTER_LOOP
                
                

       INPUT_CHECK:
                XOR BX, BX
                CMP CHECKCOUNTER, 06H
                JE HITS_AND_BULLS
                
                MOV BL, CHECKCOUNTER
    
                MOV AL, BYTE PTR USERGUESS + BX
                SUB AL, 30H
               
                MOV RESTCOUNTER, 02h
                CMP BL, 02H
                
                JE ZERO_CHECK
                
                
                JNE REST_OF_INPUT_CHECK
                
            
           

                 RET 1
                 ;This checks the user input after the first digit
       REST_OF_INPUT_CHECK:
                CMP RESTCOUNTER, 06H
                JE INC_CHECK_COUNTER
                XOR BX, BX
                MOV BL, RESTCOUNTER
                INC RESTCOUNTER
                MOV AH, BYTE PTR USERGUESS + BX
                SUB AH, 30h
                
                
                CMP BL, CHECKCOUNTER           
                JE  REST_OF_INPUT_CHECK            
                CMP AL, AH
                JE REPEATED_DIGITS_INPUT
    
                
                
                
                JNE REST_OF_INPUT_CHECK  
                
                
                
                ;This is used to increment the 'checkcounter'
       INC_CHECK_COUNTER:
                INC CHECKCOUNTER
                JMP INPUT_CHECK
    

                ;If the user entered the same digit twice, it will print 
                ;the relevant message.
       REPEATED_DIGITS_INPUT:
                MOV DL, 10
                MOV AH, 02H
                INT 21H
                MOV DL, 13
                MOV AH, 02H
                INT 21H ;INPUT USER GUESS:
                MOV DX, OFFSET MSG3
                MOV AH, 9
                INT 21H
                MOV DL, 10
                MOV AH, 02H
                INT 21H
                MOV DL, 13
                MOV AH, 02H
                MOV DX, OFFSET MSG7  ;MSG7
                MOV AH, 9
                INT 21H
                MOV DL, 10
                MOV AH, 02H
                INT 21H
                MOV DL, 13
                MOV AH, 02H
                INT 21H
                JMP FINISHED_RANDOM
    
    
                
    
               ;This checks if the user entered zero as the first digit of the guess.
       ZERO_CHECK: 
                CMP AL, 00H                
                JNE REST_OF_INPUT_CHECK
                MOV DL, 10
                MOV AH, 02H
                INT 21H
                MOV DL, 13
                MOV AH, 02H
                INT 21H
                MOV DX, OFFSET MSG6
                MOV AH, 9
                INT 21H
                MOV DL, 10
                MOV AH, 02H
                INT 21H
                MOV DL, 13
                MOV AH, 02H
                INT 21H
                JMP FINISHED_RANDOM
                
                
                
                ;The labels below will check the user guess 
                ;against the computer guess for hits and bulls.
       HITS_AND_BULLS:
                MOV BX, 01H
                
       OUTER_LOOP: 
                INC BX
                CMP BX, 06H
                JE HITCHECK
                XOR AX, AX
                MOV AL, BYTE PTR USERGUESS + [BX] 
                SUB AL, 30H 
                
                MOV DI, 0
                
       INNER_LOOP:            
                
                CMP DI, 4
                JE OUTER_LOOP
                MOV AH, BYTE PTR COMPUTERNUM + [DI]; AH=  COMPUTERNUM[0]
                
                
                CMP AL, AH
                JE HIT
                INC DI
                JNE INNER_LOOP
                
                ;This checks for hits.
       HIT:
                SUB BX, 02H             
                CMP DI, BX
                JE BULLS_EYE
                INC DI
                ADD BX, 02H
                
                INC HITCOUNTER
                JMP INNER_LOOP
                
                ;This checks for bullseyes.    
       BULLS_EYE:                
              INC DI
              ADD BX, 02H
              
              INC BULLCOUNTER
              JMP INNER_LOOP
                    
                    
    
                ;This checks if the user had 0 hits, 
       HITCHECK:
             
             INC TRIES
             CMP BULLCOUNTER, 4
             JE WINNER
                
                
                
                ;This prints the counter of the bullseyes and the hits.
       PRINT_RES:  
                
                
                MOV DX, OFFSET RES1
                MOV AH, 9
                INT 21H
                 
                MOV AL, BULLCOUNTER
                ADD AL, 30H
                MOV DL, AL ;MSG7
                MOV AH, 2
                INT 21H
                MOV DX, OFFSET RES2
                MOV AH, 9
                INT 21H
               
                MOV AL, HITCOUNTER
                ADD AL, 30H
                MOV DL, AL
                MOV AH, 2
                INT 21H 
                MOV DX, OFFSET RES3
                MOV AH, 9
                INT 21H  
                
                MOV DL, 10
                MOV AH, 02H
                INT 21H
                MOV DL, 13
                MOV AH, 02H
                INT 21H                    
                
                
                ;This checks if the user had reached 13 tries. if it 
                ;did,it will jump to the 'loser' label.
       GAME_OVER:  
                 
                CMP TRIES, 13
                
                JE LOSER
                MOV DX, OFFSET MSG8
                MOV AH, 9
                INT 21H
                MOV DL, 10
                MOV AH, 02H
                INT 21H
                MOV DL, 13
                MOV AH, 02H
                INT 21H 
                MOV BULLCOUNTER, 0
                MOV HITCOUNTER, 0
                JNE FINISHED_RANDOM
               
                
                MOV AX, 4C00H ; EXIT TO OPERATING SYSTEM.
                INT 21H    
            
                ;If the number of tries is bigger or equal to 10, we 
                ;need to split the characters of the tries counter in to two prints.
       CONVERTER: 
               
               MOV BX, 16
               XOR AX, AX
               MOV AL, TRIES
               ADD AL, 6    
               XOR DX, DX
               DIV BX
               MOV BH, DL
               MOV BL, AL
               ADD BL, 30H
               MOV DL, BL 
               MOV AH, 2
               INT 21H               
               ADD BH, 30H
               MOV DL, BH
               MOV AH, 2
               INT 21H
               JMP CONTINUE
               
               ;This is where we arrive after the user had guessed correctly.
       WINNER:
                
                MOV DX, OFFSET MSG4
                MOV AH, 9
                INT 21H 
                CMP  TRIES, 10
                JA CONVERTER
                
                MOV AL, TRIES
                ADD AL, 30H
                MOV DL, AL ;MSG7
                MOV AH, 2
                INT 21H
               ;This is where we print the random number generated 
               ;by the computer after the game finished.
       CONTINUE:
                MOV BX, 00H
                MOV DL, 10
                MOV AH, 02H
                INT 21H
                MOV DL, 13
                MOV AH, 02H
                INT 21H
                MOV DX, OFFSET RES4
                MOV AH, 9
                INT 21H 
                
       PRINT_NUM: 
                    
                MOV AL, COMPUTERNUM + BX
                INC BX
                ADD AL, 30H
                MOV DL, AL
                MOV AH, 2
                INT 21H
                CMP BX, 4
                JNE PRINT_NUM
                MOV AX, 4C00H ; EXIT TO OPERATING SYSTEM.
                INT 21H 
    
    LOSER: 
                MOV DX, OFFSET MSG9
                MOV AH, 9
                INT 21H 
                MOV DX, OFFSET LOST
                MOV AH, 9
                INT 21H
                JMP CONTINUE
                MOV AX, 4C00H ; EXIT TO OPERATING SYSTEM.
                INT 21H
                

CSEG ENDS

END START ; SET ENTRY POINT AND STOP THE ASSEMBLER.

