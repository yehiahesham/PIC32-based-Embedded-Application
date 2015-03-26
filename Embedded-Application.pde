#include <IOShieldOled.h>
#include <IOShieldTemp.h>
#include <Wire.h>

#define inter_time 1000 //Change this value to change the delay of the timer interrupt

uint32_t testCounter = 0;
uint32_t testCounter2 = 0;
//Global variables for communication between functions:
int globalVarM = 0;
int globalVarH = 0;
int globalVarM2 = 1;
int globalVarH2 = 0;
int globalVar1 = 0;
int globalVar2 = 0;
int globalVar3 = 0;
int globalVar5 = 0;
int light =0x80;
int control=0;
int control2;
int control3;


void setup()
{
  //*******IOShield Structs Setup*******
    IOShieldTemp.config(IOSHIELDTEMP_ONESHOT | IOSHIELDTEMP_RES11 | IOSHIELDTEMP_ALERTHIGH);
    IOShieldTemp.setTempHyst(24);
    IOShieldOled.begin();
    IOShieldOled.setFillPattern(IOShieldOled.getStdPattern(0));
    IOShieldOled.setCharUpdate(0);
  //*******************
   
  Serial.begin(9600); //Starting serial port for debugging.
  
  //***********Interrupts setup****************************
  attachCoreTimerService(timerInterruptHandler); //Setting up timer interrupt
    
    //Switches interrupt setup:
    INTEnable(INT_IC1, INT_ENABLED); //SW1 interrupt. 
    INTSetVectorPriority(INT_INPUT_CAPTURE_1_VECTOR, INT_PRIORITY_LEVEL_1);
    INTSetVectorSubPriority(INT_INPUT_CAPTURE_1_VECTOR, INT_SUB_PRIORITY_LEVEL_1);
    IC1CONSET = 0x1; //Adjusting edge sensetivity.
    IC1CONSET = 0x8000;
    IC1CONCLR = 0x6;
    
    INTEnable(INT_IC2, INT_ENABLED); //SW2 interrupt.
    INTSetVectorPriority(INT_INPUT_CAPTURE_2_VECTOR, INT_PRIORITY_LEVEL_1);
    INTSetVectorSubPriority(INT_INPUT_CAPTURE_2_VECTOR, INT_SUB_PRIORITY_LEVEL_1);
    IC2CONSET = 0x1; //Adjusting edge sensetivity.
    IC2CONSET = 0x8000;
    IC2CONCLR = 0x6;
        
    INTEnable(INT_IC3, INT_ENABLED); //SW3 interrupt.
    INTSetVectorPriority(INT_INPUT_CAPTURE_3_VECTOR, INT_PRIORITY_LEVEL_1);
    INTSetVectorSubPriority(INT_INPUT_CAPTURE_3_VECTOR, INT_SUB_PRIORITY_LEVEL_1);
    IC3CONSET = 0x1; //Adjusting edge sensetivity.
    IC3CONSET = 0x8000;
    IC3CONCLR = 0x6;
     
    INTEnable(INT_IC4, INT_ENABLED); //SW4 interrupt.
    INTSetVectorPriority(INT_INPUT_CAPTURE_4_VECTOR, INT_PRIORITY_LEVEL_1);
    INTSetVectorSubPriority(INT_INPUT_CAPTURE_4_VECTOR, INT_SUB_PRIORITY_LEVEL_1);
    IC4CONSET = 0x1; //Adjusting edge sensetivity.
    IC4CONSET = 0x8000;
    IC4CONCLR = 0x6;
    
    //Leftmost push button interrupt setup:
    INTEnable(INT_CN, INT_ENABLED); //Enabling change notice interrupt
    INTSetVectorPriority(INT_CHANGE_NOTICE_VECTOR, INT_PRIORITY_LEVEL_1);
    INTSetVectorSubPriority(INT_CHANGE_NOTICE_VECTOR, INT_SUB_PRIORITY_LEVEL_1);
    CNCONSET = 0x8000; //CN enable bit.
    CNENSET = 0x10000; //Leftmost button CN enabling bit.
    
    INTConfigureSystem(INT_SYSTEM_CONFIG_MULT_VECTOR);
    INTEnableInterrupts();      
  
  //****Setting inputs and outputs tristate bits****
  //Setting the first LED:
   
   asm volatile(
 " lui $t0, 0xBF88;"
 " ori $t0,0x6100; " // address of tristate
 " li $t1, 0;" //t1=0000000
 " sw $t1, ($t0);" // intiate all the tristates with zero, 0xFF is now in clear memory adress,which will clear the coresponding bits, if first bit in clear reg is 1 , then clear the first bit in the led1
 " lui $t0, 0xBF88;"
 " ori $t0,0x6120; " //address of the latch
 " sw $0,0($t0);"
 "li %0, 0;"
 "li %1, 0;"
                 :"=r"(control2),"=r"(control2)
                 :
                 :);
 
}


//*********Wrapper functions**************
void printChar(int x, int y, int ascii) //Printing character at (x, y).
{
   IOShieldOled.setCursor(x, y);
   IOShieldOled.putChar(char(ascii));
   IOShieldOled.updateDisplay();
}

void printNumber(int x, int y, int Number) //Printing number at (x, y).
{
  String num_str = "";
  num_str += Number;
  num_str += " ";
 
  char num_char[num_str.length() + 1];
  num_str.toCharArray(num_char, num_str.length() + 1);
  IOShieldOled.setCursor(x, y);
  IOShieldOled.putString(num_char);
  IOShieldOled.updateDisplay();
}

void clearScreen() //Clearing the OLED.
{
  IOShieldOled.clearBuffer();
  IOShieldOled.updateDisplay();
}

int readTempC() //Getting the temperature in Celesius.
{
  return int(IOShieldTemp.getTemp());
}

int readTempF() //Getting the temperature in Fahrenheit.
{
  return int(IOShieldTemp.convCtoF(IOShieldTemp.getTemp()));
}
//******************************************





void loop()
{
               
  asm volatile( " lui $t0, 0xBF88;"
               " ori $t0,0x6120; " //address of the latch
               " sw $0,0($t0);"
               "li %0,0x80;"
               "li %1,0;"
               :"=r"(light),"=r"(control)
               :
               :);
               
  asm volatile("li $a0, 11;" //Loading the function parameters.
               "li $a1, 0;"
               "li $a2, 84;" //For printing "T"
               "jal %0;" //Function call.
               :
               :"r"(printChar) //Function mapping. 
               :"a0", "a1", "a2", "ra"
               ); 
  Serial.println("Temp");
  asm volatile(
               "li $a0, 12;" 
               "li $a1, 0;"
               "li $a2, 101;" //For printing "e"
               "jal %0;" 
               "li $a0, 13;" 
               "li $a1, 0;"
               "li $a2, 109;" //For printing "m"
               "jal %0;" 
               "li $a0, 14;" 
               "li $a1, 0;"
               "li $a2, 112;" //For printing "p"
               "jal %0;"
               :
               :"r"(printChar) //Function mapping.
               :"a0", "a1", "a2", "ra"); 
               
                Serial.println("Temp");
  asm volatile(
               "li $a0, 0;" 
               "li $a1, 2;"
               "li $a2, 67;" //For printing "C"
               "jal %0;" 
               "li $a0, 1;" 
               "li $a1, 2;"
               "li $a2, 111;" //For printing "o"
               "jal %0;" 
               "li $a0, 2;" 
               "li $a1, 2;"
               "li $a2, 117;" //For printing "u"
               "jal %0;"
               "li $a0, 3;" 
               "li $a1, 2;"
               "li $a2, 110;" //For printing "n"
               "jal %0;"
               "li $a0, 4;" 
               "li $a1, 2;"
               "li $a2, 116;" //For printing "t"
               "jal %0;"
               "li $a0, 5;" 
               "li $a1, 2;"
               "li $a2, 68;" //For printing "d"
               "jal %0;"
               :
               :"r"(printChar) //Function mapping.
               :"a0", "a1", "a2", "ra"); 
               
Serial.println("x");   
 asm volatile ( // get the char
                 "beq   %1,$0,C;"
                 "add   %0,$0,70;" // cahr C
                 " j exit;"
                 "C:add %0,$0,67;" // char F
                 "exit:;"
                 :"=r"(globalVar3)
                 :"r"(globalVar2)
                 :
                  );
Serial.println("x"); 
   asm volatile ("beq   %1,$0,C2;"
               "jal %3;" // get cel temp
               "move %0,$v0;"
                " j exit4;"
               "C2:jal %2;" // get Fah temp
               "move %0,$v0;"
               "exit4:;"
               :"=r"(globalVar5)
               :"r"(globalVar2),"r"(readTempC),"r"(readTempF)
               :
               );
               
          Serial.println("x"); 
        asm volatile (
               "add $a2,$0,%1;"
               "li $a0, 11;"
               "li $a1, 1;"
               "jal %0;" // print temp fah/cel 
               :
               :"r"(printNumber),"r"(globalVar5)
               :
               );
                 Serial.println("x"); 
        asm volatile (
               "add $a2,$0,%1;"
               "li $a0, 14;"
               "li $a1, 1;"
               "jal %0;" // print char F/cel 
               :
               :"r"(printChar),"r"(globalVar3)
               :
               );
               
               ////////////////
              
            Serial.println("x");    
              //Printing test message:
  asm volatile("li $a0, 0;" //Loading the function parameters.
               "li $a1, 0;"
               "li $a2, 84;" //For printing "T"
               "jal %0;" //Function call.
               :
               :"r"(printChar) //Function mapping. 
               :"a0", "a1", "a2", "ra"); 
  Serial.println("Test");
  asm volatile(
               
               "li $a0, 1;" 
               "li $a1, 0;"
               "li $a2, 105;" //For printing "i"
               "jal %0;" 
               "li $a0, 2;" 
               "li $a1, 0;"
               "li $a2, 109;" //For printing "m"
               "jal %0;"
               "li $a0, 3;" 
               "li $a1, 0;"
               "li $a2, 101;" //For printing "e"
               "jal %0;" 
               :
               :"r"(printChar) //Function mapping.
               :"a0", "a1", "a2", "ra"); 
               
   //Printing the counter:
   // end of printing counter:
   //print stop watch
          //end of code sop watch
                  //printing stop watch
                  Serial.println("SUCEYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY");  
                  asm volatile ( 
               "move $a2, %1;"
               "li  $a0, 0;"
               "li $a1, 3;"
               "jal %0;"
               : 
               :"r"(printNumber), "r"(globalVarH2) //Inputs mapping.
               :);  
               
Serial.println("SUCEzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzZZZZZZZZZZZZZZZZZZZZZZZZZZZz"); 
            asm volatile(
               "li $a0, 2;" 
               "li $a1, 3;"
               "li $a2,58;" //For printing ":"
               "jal %0;"
               :
               :"r"(printChar) //Function mapping.
               :
               );
               
               
               
Serial.println("SUCEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");                
  asm volatile (       "move $a2, %1;"
               "li  $a0, 3;"
               "li $a1, 3;"
               "jal %0;"
               : 
               :"r"(printNumber), "r"(globalVarM2) //Inputs mapping.
               :);  
              Serial.println("SUCEbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbA");
              
              
              Serial.println("Test");
               asm volatile(
               "li $a0, 5;" 
               "li $a1, 3;"
               "li $a2,58;" //For printing ":"
               "jal %0;"
               :
               :"r"(printChar) //Function mapping.
               :
               );
        
   
              Serial.println("SUCEcccccccccccccccccccCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC");

  asm volatile (       "move $a2, %1;"
               "li  $a0, 6;"
               "li $a1, 3;"
               "jal %0;"
               : 
               :"r"(printNumber), "r"(testCounter2) //Inputs mapping.
               :);
               
     //end of printing stop watch
   
   //**********
   Serial.println("Test");
    
               
   //Printing the counter:
   
  
   }              

uint32_t timerInterruptHandler(uint32_t currentTime)
{
     //Serial.println("yehia"); 
  asm volatile("addi %0, %0, 1;"
                "bne %0,60,exit1;"
                "addi %1,%1,1;"
                "li %0,0;"
                "bne %1,60,exit1;"
                "addi %2,%2,1;"
                "li %1,0;"
               "exit1:;"


:"=r"(testCounter),"=r"(globalVarM),"=r"(globalVarH)
:"0"(testCounter),"1"(globalVarM),"2"(globalVarH)
:"ra"
);
Serial.println("SUCEPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP");

 // printing clock
 Serial.println("Test");
   asm volatile ( 
               "move $a2, %1;"
               "li  $a0, 0;"
               "li $a1, 1;"
               "jal %0;"
               : 
               :"r"(printNumber), "r"(globalVarH) //Inputs mapping.
               :);  
               
Serial.println("Test");
            asm volatile(
               "li $a0, 2;" 
               "li $a1, 1;"
               "li $a2,58;" //For printing ":"
               "jal %0;"
               :
               :"r"(printChar) //Function mapping.
               :
               );
               
               
               
Serial.println("Test");               
  asm volatile (       "move $a2, %1;"
               "li  $a0, 3;"
               "li $a1, 1;"
               "jal %0;"
               : 
               :"r"(printNumber), "r"(globalVarM) //Inputs mapping.
               :);  
              Serial.println("Test"); 
              
              
              Serial.println("Test");
               asm volatile(
               "li $a0, 5;" 
               "li $a1, 1;"
               "li $a2,58;" //For printing ":"
               "jal %0;"
               :
               :"r"(printChar) //Function mapping.
               :
               );
        
   
              Serial.println("Test"); 

  asm volatile (       "move $a2, %1;"
               "li  $a0, 6;"
               "li $a1, 1;"
               "jal %0;"
               : 
               :"r"(printNumber), "r"(testCounter) //Inputs mapping.
               :);  
    Serial.println("AAAA");           
  Serial.println(testCounter);
  Serial.println(globalVarM);
  Serial.println(globalVarH);
   
 // end of printing clock
  

   asm volatile(
             "beq   %1,$0,right;"
              "sll %0,%0,1;"
              "bne  %0,0x80,skip;"
              "li %1,0;"
              "skip:j exit3;"
              "right: srl %0,%0,1;"
              "	bne %0,0x01,exit3;"
              "	li %1,1;"
              "exit3:;"
                              
                :"=r"(light),"=r"(control)
                :"0"(light) ,"1"(control)//Mapping input to output.
                :"ra");  
  Serial.println("DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");              
                // stop watch
                  //code of stop
  asm volatile( "bne %0,$0,continue;"
                "bne %1,$0,continue;"
                "bne %2,$0,continue;" 					// if number isnot zero , continue
		"bne %4,$0,reset;" 					// if number is zero , and reset =1. go reset
		"j exit2;" 					// don't fo any thing //else if number is zero, and no rest. exit
		"reset: li %2,0;"					 // number is zero , and reset =1.  reseting
                "li %1,3;"
                "li %0,0;"
		"j exit2;"					// exit after reseting

		"continue:bne %4,$0,reste2;"					//if number is not zero and rest ==1 , then reset
		"bne %3,$0,exit2;" 					//else if rest=0 and pause is =1, then just pause by exiting
		"j decrement;"					//else if reset=0 , and pause is zero, decremnt
		"reste2: bne %3,$0,conditon_true;"		
		"li %2,0;"					 
                "li %1,3;"
                "li %0,0;"
		"j decrement;"
		"conditon_true:li %2,0;"					 
                "li %1,3;"
                "li %0,0;"
		"j exit2;"
		"decrement:addi %0, %0, -1;"
                "bne %0,-1,exit2;"
                "addi %1,%1,-1;"
                "li %0,59;"
                "bne %1,-1,exit2;"
                "addi %2,%2,-1;"
                "li %1,59;"
               "bne %2,-1,exit2;"
                "li %1,00;"
                "exit2:;"


:"=r"(testCounter2),"=r"(globalVarM2),"=r"(globalVarH2), "=r"(control2), "=r"(control3)
:"0"(testCounter2),"1"(globalVarM2),"2"(globalVarH2),"3"(control2),"4"(control3)
:
);
  Serial.println("ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");
                  //end of code stop watch
                  //printing stop watch
                  
                Serial.println("Test");  
                  asm volatile ( 
               "move $a2, %1;"
               "li  $a0, 0;"
               "li $a1, 3;"
               "jal %0;"
               : 
               :"r"(printNumber), "r"(globalVarH2) //Inputs mapping.
               :);  
               
Serial.println("Test");
            asm volatile(
               "li $a0, 2;" 
               "li $a1, 3;"
               "li $a2,58;" //For printing ":"
               "jal %0;"
               :
               :"r"(printChar) //Function mapping.
               :
               );
               
               
               
Serial.println("Test");               
  asm volatile (       "move $a2, %1;"
               "li  $a0, 3;"
               "li $a1, 3;"
               "jal %0;"
               : 
               :"r"(printNumber), "r"(globalVarM2) //Inputs mapping.
               :);  
              Serial.println("Test"); 
              
              
              Serial.println("Test");
               asm volatile(
               "li $a0, 5;" 
               "li $a1, 3;"
               "li $a2,58;" //For printing ":"
               "jal %0;"
               :
               :"r"(printChar) //Function mapping.
               :
               );
        
   
              Serial.println("Test"); 

  asm volatile (       "move $a2, %1;"
               "li  $a0, 6;"
               "li $a1, 3;"
               "jal %0;"
               : 
               :"r"(printNumber), "r"(testCounter2) //Inputs mapping.
               :);
               
                  //  end of stopwatch
                // end of stop
                

  return (currentTime + CORE_TICK_RATE * inter_time);
}



//External interrupts
extern "C"{

   void __ISR(_INPUT_CAPTURE_1_VECTOR,IPL3AUTO) IC1_Interrupt_ISR(void) //SW1 Interrupt Handler
  {
    asm volatile ("xori %0, %0, 1;"
                  
                  :"=r"(globalVar2)
                  :"0" (globalVar2)
                  ); // for temp

    
    IFS0CLR = 0x20; //Clearing status flag.
  }
  void __ISR(_INPUT_CAPTURE_2_VECTOR,IPL3AUTO) IC2_Interrupt_ISR(void)  //SW2 Interrupt Handler
  {
     //Implement your handler in assembly here
     
     IFS0CLR = 0x200; //Clearing status flag.
  }
  
  void __ISR(_INPUT_CAPTURE_3_VECTOR,IPL3AUTO) IC3_Interrupt_ISR(void) //SW3 Interrupt Handler
  {
    //Implement your handler in assembly here
      Serial.println("^66666666666666666666666666666666666666666666666666666");
    asm volatile (
        " xori %0,%0,1;"
        :"=r"(control2)
        :"0"(control2)
        :); // for pause
    Serial.println("^1111111111111111111111111111111111111111111111111111111111111");
    
    IFS0CLR = 0x2000; //Clearing status flag.
  }
  
  void __ISR(_INPUT_CAPTURE_4_VECTOR,IPL3AUTO) IC4_Interrupt_ISR(void) //SW4 Interrupt Handler
  {
    //Implement your handler in assembly here
    asm volatile (
        " xori %0,%0,1;"
        :"=r"(control3)
        :"0"(control3)
        :); // for resting
    Serial.println("^********************************************************************************************");
  
  
    IFS0CLR = 0x20000; //Clearing status flag.
  }
  
  
  void __ISR(_CHANGE_NOTICE_VECTOR,IPL3AUTO) CN_Interrupt_ISR(void) //Push button Interrupt Handler
  {
    asm volatile(
                " lui $t0, 0xBF88;"
                " ori $t0,0x6120; " //address of the latch
                " sw %0,0($t0);"
                :"=r"(light)
                :"0"(light)  //Mapping input to output.
                :);
        
     IFS1CLR = 0x1;; //Clearing status flag.
  }
}
