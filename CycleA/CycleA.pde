#define LED_COUNT 4
#define DEBOUNCE_PERIOD 20 // ms
#define REPEAT_INTERVAL 150 // ms

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
  /** Interrupt current animation, animate to the target value form the current value. */
  LedController animateTo(int target);
  LedController callAtEnd(handler_t *handler);
  void doAnimate();
private:
  int _currentValue; // PWM: 0-255
  int _startValue; // PWM: 0-255
  int _targetValue; // PWM: 0-255
  unsigned long _animStart; // timestamp millis
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

  unsigned long ellapsed = millis() - _animStart;

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
    _currentValue = map(ellapsed, 0, ANIMATION_PERIOD, _startValue, _targetValue);
  }

  analogWrite(_pin, _currentValue); 
}

LedController LedController::display(boolean light)
{
  return animateTo(light ? ANALOG_MAX : ANALOG_MIN);
}

// --------------------------------------

class ButtonController
{
public:
  /* The handler gets invoked on button press (or button repeat). Perhaps we should have seperate
   handlers for those cases. I like having a no-arguments function ... but we may need to pass
   the pin number or some other identifier. */
  ButtonController(int pin, handler_t *handler);
  /* Read the pin and decide whether to invoke the handler or not. */
  void read();
private:
  int _pin;
  int _previousValue;
  unsigned long _lastButtonDebounce;
  unsigned long _lastNotification;
  boolean _enabled;
  handler_t* _handler;
};

ButtonController::ButtonController(int pin, handler_t *handler)
{
  _pin = pin;
  _previousValue = LOW;
  _lastButtonDebounce = 0; // never
  _lastNotification = 0; // never
  _enabled = true;
  _handler = handler;

  pinMode(_pin, INPUT);  
}

void ButtonController::read()
{
  int currentValue = digitalRead(_pin);

  unsigned long now = millis();

  if (currentValue != _previousValue)
  {
    _lastButtonDebounce = now;
    _previousValue = currentValue;
    return;
  }

  // Wait until the read off of the pin is stable for the DEBOUNCE_PERIOD before
  // continuing.
  
  if (now - _lastButtonDebounce < DEBOUNCE_PERIOD) {
    return;
  }


  // It's gone HIGH to LOW.  If it goes HIGH again
  // we can invoke the handler.

  if (currentValue == LOW) {
    _enabled = true;
    return;
  }

  // It's gone LOW to HIGH, or it's been held down and we're
  // repeating.

  if (_enabled || now - _lastNotification >= REPEAT_INTERVAL) {
    
    // Invoke the handler.
    
    (*_handler)();
    
    // Note the last time we invoke the handler and disable it
    // until a changte
    _lastNotification = now;
    _enabled = false;
  }
}

// --------------------------------------

// First press will move to the first LED.
int currentLed = -1;

LedController ledController[LED_COUNT] = {  
  LedController(11),
  LedController(10),
  LedController(9),
  LedController(6)};

void dimTheLights()
{
  for (int i = 0; i < LED_COUNT; i++) {
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

ButtonController nextButton = ButtonController(2, &next);
ButtonController prevButton = ButtonController(3, &prev);

void setup()
{
  Serial.begin(57600);

  ledController[0].callAtEnd(&dimTheLights);
}


void loop()
{
  for (int i = 0; i < LED_COUNT; i++) {
    ledController[i].doAnimate();
  }

  nextButton.read();
  prevButton.read();
}






















