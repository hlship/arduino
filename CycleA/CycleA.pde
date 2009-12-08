#define FIRST_LED 12
#define LED_COUNT 4
#define DEBOUNCE_PERIOD 50 // ms

#define ANALOG_MIN 0
#define ANALOG_MAX 200

#define ANIMATION_PERIOD 250 // ms

// Handler functions are void with no args

typedef void handler_t();

class LedController
{
public:
  LedController(int pin);
  LedController display(boolean light);
  /** Interrupte current animation, animate to the target value form the current value. */
  LedController animateTo(int target);
  LedController callAtEnd(handler_t *handler);
  void doAnimate();
private:
  int _currentValue; // PWM: 0-255
  int _startValue; // PWM: 0-255
  int _targetValue; // PWM: 0-255
  unsigned long _animStart; // millis
  handler_t* _handler;
  int _pin;
  boolean _animating;
};

LedController::LedController(int pin)
{
  _pin = pin;

  _currentValue = ANALOG_MIN;

  pinMode(_pin, OUTPUT);

  animateTo(ANALOG_MAX);
}

LedController LedController::animateTo(int target)
{
  _animStart = millis();
  _startValue = _currentValue;
  _targetValue = target;
  _animating = true;
  _handler = NULL;
  
  return *this;
}

LedController LedController::callAtEnd(handler_t *handler)
{
  _handler = handler;
  
  return *this;
}

void LedController::doAnimate()
{  
  if (!_animating) return;

  int ellapsed = millis() - _animStart;

  if (ellapsed >= ANIMATION_PERIOD) {
    _animating = false;
    _currentValue = _targetValue;
    
    // If an end-of-animation handler was specified, call it now.
    if (_handler != NULL) {
      (*_handler)();
      _handler = NULL;
    }
  }
  else
  {
    // TODO: Sinosoidal!
    _currentValue = map(ellapsed, 0, ANIMATION_PERIOD, _startValue, _targetValue);
  }

  analogWrite(_pin, _currentValue); 
}

LedController LedController::display(boolean light)
{
  return animateTo(light ? ANALOG_MAX : ANALOG_MIN);
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

void dimTheLights()
{
  for (int i = 0; i < LED_COUNT; i++) {
    ledController[i].display(false);
  }
}

void setup()
{
  Serial.begin(57600);
  
  ledController[0].callAtEnd(&dimTheLights);
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

void animateAll()
{
  for (int i = 0; i < LED_COUNT; i++) {
    ledController[i].doAnimate();
  }
}

void loop()
{
  animateAll();

  if (nextButton.read()) next();

  if (prevButton.read()) prev();
}
















