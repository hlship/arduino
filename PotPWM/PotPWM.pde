#define LED_COUNT 4

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

void setup()
{
  Serial.begin(57600);

  // ledController[0].callAtEnd(&dimTheLights);
}


void loop()
{
//  for (int i = 0; i < LED_COUNT; i++) {
//    ledController[i].doAnimate();
//  }
  
  int potValue = analogRead(0);
  
  Serial.println(potValue);
  
  analogWrite(9, potValue >> 2);
  
}






















