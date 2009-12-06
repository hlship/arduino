#define FIRST_LED 12
#define LED_COUNT 4
#define DEBOUNCE_PERIOD 50 // ms

class LedController
{
public:
  LedController(int pin);
  void display(boolean light);
private:
  int _pin;
};

LedController::LedController(int pin)
{
  _pin = pin;
  
  pinMode(_pin, OUTPUT);
}

void LedController::display(boolean light)
{
  digitalWrite(_pin, light ? HIGH : LOW);
}

// --------------------------------------

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

// --------------------------------------

// First press will move to the first LED.
int currentLed = -1;

Debounce nextButton = Debounce(2);
Debounce prevButton = Debounce(3);

LedController ledController[LED_COUNT] = {
  LedController(12),
  LedController(11),
  LedController(10),
  LedController(9) };
  

void setup()
{
  for (int i = 0; i < LED_COUNT; i++) {
    ledController[i].display(true);
  }

  delay(250);

  for (int i = 0; i < LED_COUNT; i++)
  {
    ledController[i].display(false);
  }
}

void next()
{
  if (currentLed >= 0)
    ledController[currentLed].display(false);

  if (++currentLed == LED_COUNT)
    currentLed = 0;

  ledController[currentLed].display(true);
}

void prev()
{
  if (currentLed >= 0)
    ledController[currentLed].display(false);

  if (--currentLed < 0)
    currentLed = LED_COUNT - 1;

  ledController[currentLed].display(true);
}

void loop()
{
  if (nextButton.read()) next();

  if (prevButton.read()) prev();
}













