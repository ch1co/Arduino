
/**
 * Project: Pet water warden
 * Author : Michael Winkler
 * Date   : 2/3/21
 */
 

// PushButton
#define onOffBtn 3

// LEDS
#define redLED 4
#define greenLED 5
#define secondGreenLED 6
#define yellowLED 7

// Pumps & Relay pins
#define fillingPumpRelay 8
#define drainingPumpRelay 9

// Sensor Pins
#define waterLevelSensorTrigPin 10
#define waterLevelSensorEchoPin 11

//Status of the system, LOW represents OFF , HIGH represents ON.
#define MACHINE_OFF LOW
#define MACHINE_ON HIGH
volatile int machineState = MACHINE_OFF;

// States of the system (Pumps and Water level) :
const int WATER_LEVEL_OK = 0;
const int WATER_FILLING = 1;
const int WATER_DRAINING = 2;
int CURRENT_STATE = WATER_LEVEL_OK;

// Timer variables :
const unsigned long fiveMinuteTimer = 300000; // in Milliseconds
const unsigned long twelveHourTimer = 43200000; // in Milliseconds
unsigned long previousTime = 0;

// Sensor variables
long duration;
int distance;

// Limits for the water sensor
const float START_FILLING = 340;
const float STOP_FILLING = 311; 

void setup() {
   pinMode(onOffBtn, INPUT);
   pinMode(redLED, OUTPUT);
   pinMode(greenLED, OUTPUT);
   pinMode(secondGreenLED, OUTPUT);
   pinMode(yellowLED, OUTPUT);
   pinMode(waterLevelSensorTrigPin, OUTPUT);
   pinMode(waterLevelSensorEchoPin, INPUT);
   pinMode(fillingPumpRelay ,OUTPUT);
   pinMode(drainingPumpRelay, OUTPUT);
   attachInterrupt(digitalPinToInterrupt(onOffBtn), turnOn, FALLING);
   Serial.begin(9600);
}

void loop() {  
  digitalWrite(greenLED, machineState);  
  if(checkSystemStatus() == true){    
      switch(CURRENT_STATE){
        case WATER_LEVEL_OK:
            delay(1000);
            turnFillingPumpOff();
            digitalWrite(redLED, LOW);
            digitalWrite(yellowLED, LOW);
            digitalWrite(secondGreenLED, HIGH);
              if(checkWaterLevel() == false){
                CURRENT_STATE = WATER_FILLING;
                break;
              }else{
                 if(checkFiveMinutes() == true){
                    if(checkWaterLevel() == true){
                      break;
                    }else{                      
                      CURRENT_STATE = WATER_FILLING;
                      break;
                    }
                 }else{
                      CURRENT_STATE = WATER_LEVEL_OK;
                      break;
                 }
              if(checkTwelveHours() == true){
                CURRENT_STATE = WATER_DRAINING;
                break;
              }
            }           
        case WATER_FILLING:
                delay(1000);
                turnFillingPumpOn();
                digitalWrite(yellowLED, HIGH);
                digitalWrite(secondGreenLED, LOW);
                digitalWrite(redLED, LOW);
              if(checkWaterLevel() == true){                          
                  digitalWrite(yellowLED, LOW);
                  digitalWrite(greenLED, HIGH);
                  turnFillingPumpOff();
                  delay(1000);
                  CURRENT_STATE = WATER_LEVEL_OK;
                  break;
                }else{
                  CURRENT_STATE = WATER_FILLING;
                  break;    
              }    
        case WATER_DRAINING:
                delay(500);
                digitalWrite(redLED, HIGH);
                digitalWrite(secondGreenLED, LOW);
                digitalWrite(yellowLED, LOW);
                turnDrainingPumpOn();             
                if(checkWhenToFill()){
                    delay(500);
                    turnDrainingPumpOff();
                    CURRENT_STATE = WATER_FILLING;
                    break;
                }
      }   
  }else{
    //If the user has pushed the onOff button.
       turnDrainingPumpOff();
       turnFillingPumpOff();
       digitalWrite(redLED, LOW);
       digitalWrite(yellowLED, LOW);
       digitalWrite(secondGreenLED, LOW);
       digitalWrite(greenLED, LOW);
  }                
}

//Methods:

/* This method will be used by the onOffBtn.
 * It will be used to change the state of the machine from ON to OFF
 */
 
void turnOn()
{
  machineState = !machineState;
  
}

/*
 * This method will be used to determine if 5 minutes have passed since the last time checked.
 */
 
bool checkFiveMinutes(){
  unsigned long currentTime = millis();
  if(currentTime - previousTime >= fiveMinuteTimer){
      previousTime = currentTime;
      return true;      
  }else{
    return false;
  }
 }
 
/*
 * This method will be used to determine if 12 Hours have passed since the last time checked
 * In order to drain and refill the water bowl.
 */
bool checkTwelveHours(){
    unsigned long currentTime = millis();
    if(currentTime - previousTime >= twelveHourTimer){
    previousTime = currentTime;
    return true;      
  }else{
    return false;
  }
}

/**
 * This method is used to check if the user have clicked on the button which will turn on the green LED that symbolizes that the system is on.
 */

bool checkSystemStatus(){
  if(digitalRead(greenLED) == HIGH){
    return true;
  }
  return false;
}

/**
 * This method is used to check when the system should start filling water to the tank.
 */
bool checkWhenToFill(){
  if(checkDistance() > START_FILLING){
    return true; 
  }else{
    return false;
  }
}

/**
 * This method is used to check the water level and compare it with the variables that we declared.
 */

bool checkWaterLevel(){
  if(checkDistance() >= STOP_FILLING){
    return false;
  }
  else{
    return true;
  }
}

/**
 * This method will be used to check the distance from the sensor.
 */
int checkDistance(){
  digitalWrite(waterLevelSensorTrigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(waterLevelSensorTrigPin, HIGH);
  delayMicroseconds(10);
  duration = pulseIn(waterLevelSensorEchoPin, HIGH);
  distance = duration*0.34/2;
  return distance;
}

/**
 * This method is used to turn on the draining pump.
 */

void turnDrainingPumpOn(){
 pinMode(drainingPumpRelay, OUTPUT);
 digitalWrite(drainingPumpRelay, HIGH);
  
}

/**
 * This method is used to turn off the draining pump
 */
void turnDrainingPumpOff(){
 digitalWrite(drainingPumpRelay, LOW);
 pinMode(drainingPumpRelay, INPUT);
 }

/**
 * This method is used to turn on the filling pump
 */
void turnFillingPumpOn(){
 pinMode(fillingPumpRelay, OUTPUT);
 digitalWrite(fillingPumpRelay, HIGH);
}

/**
 * This method is used to turn off the filling pump
 */
void turnFillingPumpOff(){
 digitalWrite(fillingPumpRelay, LOW);
 pinMode(fillingPumpRelay, INPUT);
 }
