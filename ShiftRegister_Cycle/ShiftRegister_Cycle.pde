// Cycle pin on and off whenever we
// send a new bit stream to the Shift Register
const int statusPin = 13;

const int latchPin = 11; // ST_CP (12)
const int clockPin = 10; // SH_CP (11)
const int dataPin = 9; // DS (14)

boolean status = false;

void setup()
{
  pinMode(statusPin, OUTPUT);
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
}

int ledValue = 1;

void loop()
{
  status = !status;

  digitalWrite(statusPin, status ? LOW : HIGH);

  // latch low to start writing
  
  digitalWrite(latchPin, LOW);

  byte msb = ledValue >> 8;
  byte lsb = ledValue & 0xff;

  shiftOut(dataPin, clockPin, MSBFIRST,  msb);
  shiftOut(dataPin, clockPin, MSBFIRST,  lsb);
  
  digitalWrite(latchPin, HIGH);

  // Should loop over back to 0
  
  int carryBit = (ledValue & 0x8000) >> 15;
  
  ledValue = (ledValue << 1) | carryBit;

  delay(128);
}

