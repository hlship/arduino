// Have the matrix count up from 00 to FF (hex)

const int potPin = 5;

const int latchPin = 11; // ST_CP (12)
const int clockPin = 10; // SH_CP (11)
const int dataPin = 9; // DS (14)

boolean status = false;

const byte digits[] = { 
  B01111110, // 0
  B00001100, // 1
  B10110110, // 2
  B10011110, // 3
  B11001100, // 4
  B11011010, // 5
  B11111010, // 6
  B00001110, // 7
  B11111110, // 8
  B11001110, // 9
  B10111110, // A
  B11111000, // B
  B10110000, // C
  B10111100, // D
  B11110010, // E
  B11100010  // F
};

void setup()
{
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
}

void writeDigit(byte value)
{
  // Ignore all but the low 4 bits when indexing
  byte digit = digits[value & 0x0f];

  shiftOut(dataPin, clockPin, MSBFIRST, digit);  
}

void writeByte(byte value)
{
  digitalWrite(latchPin, LOW);
  
  writeDigit(value >> 4);
  writeDigit(value);
  
  digitalWrite(latchPin, HIGH);
}

void loop()
{
  int potValue = analogRead(potPin);
  
  // Shift from 1024 to 256, the range displayable on the LED matrix.
  
  byte displayValue = potValue >> 2;
  
  writeByte(displayValue);
  
  delay(32);
}




