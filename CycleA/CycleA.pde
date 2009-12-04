#define FIRST_LED 12
#define LED_COUNT 4
#define DEBOUNCE_PERIOD 50 // ms

class Debounce
{
public:
  Debounce(int pin);
  boolean read();
private:
  int _pin;
  int _previousValue;
  int _lastButtonDebounce;
  boolean _enabled;
};

Debounce::Debounce(int pin)
{
  _pin = pin;
  _previousValue = LOW;
  _lastButtonDebounce = 0; // never
  _enabled = true;

  pinMode(_pin, INPUT);  
}

boolean Debounce::read()
{
  int currentValue = digitalRead(_pin);

  long now = millis();

  if (currentValue != _previousValue)
  {
    _lastButtonDebounce = now;
    _previousValue = currentValue;
    return false;
  }

  if (now - _lastButtonDebounce < DEBOUNCE_PERIOD) {
    return false;
  }


  // It's gone HIGH to LOW

  if (currentValue == LOW) {
    _enabled = true;
    return false;
  }

  // It's gone LOW to HIGH

  if (_enabled) {
    _enabled = false;
    return true;
  }

  return false;
}

// First press will move to the first LED.
int currentLed = -1;

Debounce advanceButton = Debounce(2);
Debounce retreatButton = Debounce(3);

void setup()
{
  for (int i = 0; i < LED_COUNT; i++) {
    int pin = FIRST_LED - i;
    pinMode(pin, OUTPUT);
    digitalWrite(pin, HIGH);
  }

  delay(250);

  for (int i = 0; i < LED_COUNT; i++)
  {
    digitalWrite(FIRST_LED - i, LOW);
  }
}

void advance()
{
  if (currentLed >= 0)
    digitalWrite(FIRST_LED - currentLed, LOW);

  if (++currentLed == LED_COUNT)
    currentLed = 0;

  digitalWrite(FIRST_LED - currentLed, HIGH);
}

void retreat()
{
  if (currentLed >= 0)
    digitalWrite(FIRST_LED - currentLed, LOW);

  if (--currentLed < 0)
    currentLed = LED_COUNT - 1;

  digitalWrite(FIRST_LED - currentLed, HIGH);
}

void loop()
{
  if (advanceButton.read()) advance();

  if (retreatButton.read()) retreat();
}













