const int rowPin[] = {
  9, 8, 7, 6, 5, 4, 3, 2};
const int redPin[] = {
  38, 40, 42, 44, 46, 48, 50, 52};

const int statusPin = 13;
boolean status  = true;

int litRow = -1;
int litCol = -1;

void setup()
{
  for (int i = 0; i < 8; i++)
  {
    pinMode(rowPin[i], OUTPUT);
    pinMode(redPin[i], OUTPUT);

    digitalWrite(redPin[i], HIGH);
    digitalWrite(rowPin[i], HIGH);
  }

  pinMode(statusPin, OUTPUT);
}

void loop()
{
  status = !status;

  digitalWrite(statusPin, status ? HIGH : LOW);

  for (int r = 0; r < 8; r++)
  {
    // Bring the row "low" to program it
    digitalWrite(rowPin[r], LOW);

    for (int c = 0; c < 8; c++)
    {
      // Clear this column of the current row
      digitalWrite(redPin[c], HIGH);

      // And light the LED if it is near the target row & column
      if (abs(litCol - c) < 2 ) {
        digitalWrite(redPin[c], LOW);
      }
    }

    // Now bring it high to display it
    if ( abs(litRow - r) < 2) {   
      digitalWrite(rowPin[r], HIGH);  
    }
  }

  litRow++;

  if (litRow > 10) {
    litRow = -1;

    litCol++;

    if (litCol >  8)
      litCol =-1; 

  }

  delay(30);
}










