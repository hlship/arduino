const int firstLed = 12;
const int ledCount = 4;
const int advanceButton = 2;
const int retreatButton = 3;

const long debouncePeriod = 50; // ms

boolean advanceEnabled = true;
long lastButtonDebounce = 0;
int previousAdvanceValue = LOW;

boolean retreatEnabled = true;
int previousRetreatValue = LOW;


// First press will move to the first LED.
int currentLed = -1;

void setup()
{
  for (int i = 0; i < ledCount; i++) {
    int pin = firstLed - i;
    pinMode(pin, OUTPUT);
    digitalWrite(pin, HIGH);
  }

  pinMode(advanceButton, INPUT);
  pinMode(retreatButton, INPUT);

  delay(250);

  for (int i = 0; i < ledCount; i++)
  {
    digitalWrite(firstLed - i, LOW);
  }
}

void advance()
{
  if (currentLed >= 0)
    digitalWrite(firstLed - currentLed, LOW);

  if (++currentLed == ledCount)
    currentLed = 0;

  digitalWrite(firstLed - currentLed, HIGH);
}

void retreat()
{
  if (currentLed >= 0)
    digitalWrite(firstLed - currentLed, LOW);

  if (--currentLed < 0)
    currentLed = ledCount - 1;

  digitalWrite(firstLed - currentLed, HIGH);
}

void debounce(int pin, int *lastReadValue, boolean *enabled, void (*handler)())
{
  int currentValue = digitalRead(pin);

  long now = millis();

  if (currentValue != *lastReadValue)
  {
    lastButtonDebounce = now;
    *lastReadValue = currentValue;
    return;
  }

  if (now - lastButtonDebounce < debouncePeriod) {
    return;
  }


  // It's gone HIGH to LOW

  if (currentValue == LOW) {
    *enabled = true;
    return;
  }

  // It's gone LOW to HIGH

  if (*enabled) {
    handler();
    *enabled = false;
  }
}

void loop()
{
  debounce(advanceButton, &previousAdvanceValue, &advanceEnabled, advance);
  debounce(retreatButton, &previousRetreatValue, &retreatEnabled, retreat);
}










