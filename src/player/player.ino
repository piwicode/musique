#include <SPI.h>            // To talk to the SD card and MP3 chip
#include <SdFat.h>          // SD card file system
#include <SFEMP3Shield.h>   // MP3 decoder chip
#include <PinChangeInt.h>
#include <util/atomic.h>

// Trigger and IO

// Trigger 1: General purpose I/O pin (Arduino pin A0). You'll usually connect
// this through a switch to ground. Can also be used as an analog input.
#define TRIG1 A0
// Trigger 2: General purpose I/O pin (Arduino pin A4). You'll usually connect
// this through a switch to ground. Can also be used as SDA (serial data) in
// an I2C ("wire" library) connection (4.7K pullup included), or an analog
// input if the pullup is disabled.
#define TRIG2 A4
// Trigger 3: General purpose I/O pin (Arduino pin A5). You'll usually connect
// this through a switch to ground. Can also be used as SCL (serial clock) in
// an I2C ("wire" library) connection (4.7K pullup included), or an analog
// input if the pullup is disabled.
#define TRIG3 A5
// Trigger 4: General purpose I/O pin (Arduino pin D1). You'll usually connect
// this through a switch to ground. Can also be used as TX (transmit) in a
// serial connection. Do not permanently pull this pin low or reprogramming and
// serial monitoring will be disabled.
#define TRIG4 1
// Trigger 5: General purpose I/O pin (Arduino pin D0). You'll usually connect
// this through a switch to ground. Can also be used as RX (receive) in a
// serial connection. Do not permanently pull this pin low or reprogramming and
// serial monitoring will be disabled.
#define TRIG5 0


// Rotary leds Red Green and Blue.
#define ROT_LEDR 10
#define ROT_LEDG A1
#define ROT_LEDB 5

// Rotary coder channels
#define ROT_B A3
#define ROT_A 3

// Rotary pushbutton
#define ROT_SW 4

// Amp enable + MIDI/MP3 mode select
#define EN_GPIO1 A2

#define RIGHT A6
#define LEFT A7
#define MP3_DREQ 2

#define MP3_CS 6
#define MP3_DCS 7
#define MP3_RST 8
#define SD_CS 9
#define MOSI 11
#define MISO 12
#define SCK 13

// RGB LED colors (for common anode LED, 0 is on, 1 is off)

#define OFF B111
#define RED B110
#define GREEN B101
#define YELLOW B100
#define BLUE B011
#define PURPLE B010
#define CYAN B001
#define WHITE B000

// Duration of innactivity after which one the player auto switches of.
#define SWITCH_OFF_DELAY 20000

#define SERIAL_DEBUG_ENABLED 0

#if SERIAL_DEBUG_ENABLED

#define LOG(...) do { \  
  Serial.print('L'); \
  Serial.print(__LINE__); \
  Serial.print(": "); \
  CAT(COUNT_ARGS(__VA_ARGS__))(__VA_ARGS__) \
  Serial.println(); \
} while(0)

#define CAT(N) DOG(N)
#define DOG(N) LOG ## N

/* max supported args is 5 for now */
#define COUNT_ARGS(...) GET_SIXTH(__VA_ARGS__, 6, 5, 4, 3, 2, 1)
#define GET_SIXTH(N1, N2, N3, N4, N5, N6, N, ...) N

#define LOG1(A)  Serial.print(A);
#define LOG2(A, ...) Serial.print(A); Serial.print(" "); LOG1(__VA_ARGS__)
#define LOG3(A, ...) Serial.print(A); Serial.print(" "); LOG2(__VA_ARGS__)
#define LOG4(A, ...) Serial.print(A); Serial.print(" "); LOG3(__VA_ARGS__)
#define LOG5(A, ...) Serial.print(A); Serial.print(" "); LOG4(__VA_ARGS__)
#define LOG6(A, ...) Serial.print(A); Serial.print(" "); LOG5(__VA_ARGS__)

#else // if SERIAL_DEBUG_ENABLED
#define LOG(...)
#endif // if SERIAL_DEBUG_ENABLED

#define CHECK(cond) \
do {if(!(cond)) {LOG(F("Check failed"), F(#cond)); fatalErrorBlink(3, RED);}} while(0)

// Global variables and flags for interrupt request functions:
volatile unsigned long last_rotary_event = 0L;
volatile int rotary_counter = 0; // Current "position" of rotary encoder (increments CW) 

volatile boolean button_pressed = false; // Will turn true if the button has been pushed
volatile boolean button_released = false; // Will turn true if the button has been released (sets button_downtime)
volatile unsigned long button_downtime = 0L; // ms the button was pushed before release

static bool volume_control_mode = false;
static int volume = 32+16;

// Bill Porter, Michael Flaga, ddz, and Wade Brainerd MP3 library.
// https://github.com/madsci1016/Sparkfun-MP3-Player-Shield-Arduino-Library
SFEMP3Shield MP3player;

// Bill Greiman SdFat library.
// https://github.com/greiman/SdFat
SdFat sd;

void initializeSerialDebugging() {
  if(SERIAL_DEBUG_ENABLED) {
    Serial.begin(9600);
    Serial.println(F("=*=*=*= Musique player =*=*=*="));
  }
}

int fetchAndClearRotaryCounter() {
  int result;
  ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
    result = rotary_counter;
    rotary_counter = 0;
  }
  return result;
}

void initializePowerControlPin() {
  // The first trigger is used to control the shutdown circuit. A high pulse
  // (> 1 V) on this pin turns off the switch.
  pinMode(TRIG1, OUTPUT);
  digitalWrite(TRIG1, LOW);
}

void switchOff() {
    LOG("Auto switch off");
    setLEDColor(BLUE);
    // Fade out.    
    while(volume < 255) {
      volume = min(volume + 4, 255);
      MP3player.setVolume(volume, volume);
      delay(10);
    }    
    AmpOff();  // Switch off amp.
    digitalWrite(TRIG1, HIGH);  // Switch power off.
    fatalErrorBlink(1, BLUE);  // Wait forever.
}

void initializePushButtons() {  
  LOG(F("Configure push buttons IO...")); 
  // Configure LED pins for outputs, and set pins to off.
  pinMode(TRIG2, INPUT_PULLUP);
  pinMode(TRIG3, INPUT_PULLUP);
  if(!SERIAL_DEBUG_ENABLED) {
    // Leave the pins used for serial communication unchanged when debugging is
    // enabled.
    pinMode(TRIG4, INPUT_PULLUP);
    pinMode(TRIG5, INPUT_PULLUP);  
  }
  LOG(F("success!"));
}
void initializeLeds() {  
  // Configure LED pins for outputs, and set pins to off.
  pinMode(ROT_LEDR, OUTPUT);
  pinMode(ROT_LEDG, OUTPUT);
  pinMode(ROT_LEDB, OUTPUT);
  setLEDColor(WHITE);
}

void initializeRotary() {  
  LOG(F("Configure rotary input and interupts...")); 
   // Configure rotary encoder inputs.
  pinMode(ROT_A, INPUT_PULLUP);
  pinMode(ROT_B, INPUT_PULLUP);  
  attachInterrupt(digitalPinToInterrupt(ROT_A), rotaryIRQ, CHANGE);

  // Configure rotary push button input.
  pinMode(ROT_SW, INPUT); // This one has a 1k pull down resistance.  
  LOG(F("success!"));
}

void initializeChips() {
  // The board uses a single I/O pin to select the
  // mode the MP3 chip will start up in (MP3 or MIDI),
  // and to enable/disable the amplifier chip:  
  pinMode(EN_GPIO1, OUTPUT);
  digitalWrite(EN_GPIO1, LOW);  // MP3 mode / amp off
}

void AmpOff() {
  // Turn off the amplifier chip:
  LOG(F("Amp off"));
  digitalWrite(EN_GPIO1, LOW);  
}
void AmpOn() {
  // Turn on the amplifier chip:
  LOG(F("Amp on"));
  digitalWrite(EN_GPIO1, HIGH);  
}

void initializeSDCard() {
  LOG(F("Initialize SD card... "));
  // Initialize the SD card; SS = pin 9, half speed at first
  // TODO: Explain why SD_CS and why SPI_HALF_SPEED
  byte result = sd.begin(SD_CS, SPI_HALF_SPEED);
  if( result != 1 /*success*/) {    
    fatalErrorBlink(2, RED);
  }
  LOG(F("success!"));
}

void initializeMP3Library() {
  LOG(F("Initialize MP3 library... "));
  byte result = MP3player.begin(); // 0 or 6 for success.
  // Check the result, see the library readme for error codes.  
  if( result != 0 && result != 6) {
    LOG(F("error code "), result);
    fatalErrorBlink(3, RED);
  }
  // This project uses only one speaker.
  MP3player.setMonoMode(1);
  
  // Set the VS1053 volume. 0 is loudest, 255 is lowest (off):
  MP3player.setVolume(volume, volume);
  // Cargo cult inspired by the Lilipad code samples.
  delay(2);
  AmpOn();
}
byte genre_colors[] = {OFF, BLUE, YELLOW, RED, GREEN};
int BinaryToGrey(int b){ return (b >> 1) ^ b; }

#define DEFLAKE_DURATION 100
#define NOTHING_PRESSED -1
#define SHUT_DOWN_BUTTON_DURATION 3000

  
class PushButton {
  public:
  // Time at which the position changed.
  unsigned long int pressed_time;
  unsigned long int released_time;
  // Value in milliseconds equals to 0 when the button is released, and to DEFLAKE_DURATION when it is pressed.
  short button_accumulator;
  // Deflaked position of the button. True when the button is considered to be pressed.
  bool is_down;
  // Set to true as soon as the button is pressed, to be consumed.
  bool pressed_event;
  bool release_event;
  
  const byte trigger;
  const unsigned char pressed_digital_value;
    
  PushButton(byte trigger, unsigned char pressed_digital_value):
    pressed_time(millis()),
    released_time(millis()),
    button_accumulator(0),
    is_down(false),
    pressed_event(false),
    release_event(false),
    trigger(trigger),
    pressed_digital_value(pressed_digital_value)
      {}
  
  void Poll(unsigned long int now, unsigned long int delta_t) {
    bool isTrigerred = digitalRead(trigger) == pressed_digital_value;
    if(isTrigerred) LOG(trigger, F("pressed with delta"), delta_t);
    button_accumulator += isTrigerred ? delta_t : -delta_t;
    button_accumulator = max(0, min(DEFLAKE_DURATION, button_accumulator));
  
    if(is_down) {
      if(button_accumulator == 0) {
        is_down = false;        
        released_time = now;
        release_event = true;        
      }
    } else {
      if(button_accumulator == DEFLAKE_DURATION) {
        is_down = true;
        pressed_time = now;
        pressed_event = true;
      }
    }  
  }
};

class Facade {  
  PushButton buttons[4];
  unsigned long int last_time;
  byte trigger_count; 
  
  public:
    PushButton rotary;

    Facade():
    rotary(ROT_SW, HIGH),
    buttons({PushButton(TRIG2, LOW), PushButton(TRIG3, LOW), PushButton(TRIG4, LOW), PushButton(TRIG5, LOW)}),
    last_time(0), 
    trigger_count(SERIAL_DEBUG_ENABLED ? 2 : 4) {}

  void Poll() {    
    unsigned long int now = millis();
    if(last_time != 0) {
      const int delta_t = max(now - last_time, DEFLAKE_DURATION/2); // Amount of time since last check.
      rotary.Poll(now, delta_t);
      for(byte b = 0 ; b < trigger_count ; b++) {
        buttons[b].Poll(now, delta_t);
      }
    }
    last_time = now;          
  }

  bool ShutDownPressed() {
    return rotary.is_down && millis() - rotary.pressed_time > SHUT_DOWN_BUTTON_DURATION;
  }

  int NextPressEvent() {
    for(int b = 0 ; b < trigger_count ; b++) {
      if(buttons[b].release_event){
        buttons[b].release_event = false;
        return b;
      }
    }
    return NOTHING_PRESSED;
  }
} facade;

class FileBrowser {
  int current_genre;  
  uint16_t albums[32];  
  uint16_t tracks[32];
  int8_t nb_album;
  int8_t nb_track;
  int8_t cur_album;
  int8_t cur_track;

  char filename[/*filename size*/12 * 3 + /*slash*/3 + /*null*/1];

  static bool NextDir(SdFile* dir, SdFile* result, uint16_t* position) {    
    do {
      if(result->isOpen()) { result->close(); }      
      if(!result->openNext(dir, O_READ)) { return false; }
      *position = (dir->curPosition() >> 5) - 1;
      if(result->isDir()) { return true; }
    } while(true);
  }

  static bool NextPlayableFile(SdFile* dir, SdFile* result, uint16_t* position) {    
    do {
      if(result->isOpen()) { result->close(); }      
      if(!result->openNext(dir, O_READ)) { return false; }
      *position = (dir->curPosition() >> 5) - 1;
      if(result->isFile() && IsPlayable(result)) { return true; }
    } while(true);
  }

  static boolean IsPlayable(SdFile *file) {    
    char tmpname [13];
    CHECK(file->getFilename(tmpname));
    // Check to see if a filename has a "playable" extension.
    // This is to keep the VS1053 from locking up if it is sent
    // unplayable data.
    char *extension = strrchr(tmpname, '.') + /*skip point*/1;  
    return (strcasecmp(extension,"MP3") == 0) ||
           (strcasecmp(extension,"WAV") == 0) ||
           (strcasecmp(extension,"MID") == 0) ||
           (strcasecmp(extension,"MP4") == 0) ||
           (strcasecmp(extension,"WMA") == 0) ||
           (strcasecmp(extension,"FLA") == 0) ||
           (strcasecmp(extension,"OGG") == 0) ||
           (strcasecmp(extension,"AAC") == 0); 
  }

  void OpenCurrentGenre(SdFile *genre_dir) {
    sprintf(filename, "/%d", current_genre);
    CHECK(genre_dir->open(filename, O_READ));
  }

  void OpenCurrentAlbum(SdFile *genre_dir, SdFile *album_dir) {
    LOG(F("OpenCurrentAlbum ["), cur_album, F("/"), nb_album, F("]"));
    CHECK(cur_album < nb_album);
    CHECK(album_dir->open(genre_dir, albums[cur_album], O_READ));
  }
  
  void OpenCurrentTrack(SdFile *album_dir, SdFile *track_dir) {
    LOG(F("OpenCurrentTrack ["), cur_track, F("/"), nb_track, F("]"));
    CHECK(cur_track < nb_track);
    CHECK(track_dir->open(album_dir, tracks[cur_track], O_READ));
  }
  
  public:
  FileBrowser(): 
    current_genre(0), 
    albums{},
    tracks{}, 
    nb_album(0), 
    cur_album(0), 
    nb_track(0), 
    cur_track(0) {}

  void NextAlbum(bool backward=false) {
    LOG(F("NextAlbum backward="), backward);    
    cur_album += backward ? -1 : 1;
    if(cur_album < 0) {cur_album = nb_album - 1; }
    if(cur_album >= nb_album) {cur_album = 0; }
  }

  void ListAlbums() {  
    SdFile genre_dir, album_dir;
    OpenCurrentGenre(&genre_dir);
    for(nb_album = 0 ; nb_album < sizeof(albums) / sizeof(albums[0]) ; nb_album++) {
      if(!NextDir(&genre_dir, &album_dir, &albums[nb_album])) { break; }
    }
    genre_dir.close();
    if(album_dir.isOpen()) { album_dir.close(); }
  }

  void ListTracks( ) {  
    SdFile genre_dir, album_dir, track_file;
    OpenCurrentGenre(&genre_dir);
    OpenCurrentAlbum(&genre_dir, &album_dir);        
    genre_dir.close();
    for(nb_track = 0 ; nb_track < sizeof(tracks) / sizeof(tracks[0]) ; nb_track++) {
      if(!NextPlayableFile(&album_dir, &track_file, &tracks[nb_track])) { break; }
    }
    album_dir.close();
    if(track_file.isOpen()) { album_dir.close(); }
  }
  bool IsLastTrackOfAlbum() {
    return cur_track + 1 >= nb_track;
  }

  int CurrentGenre() {return current_genre;}
  void NextTrack(bool backward=false) {    
    if(current_genre == 0) {
      NotifyGenre(1, backward);
      return;
    }
    cur_track += backward ? -1 : 1;
    if(cur_track < 0 || cur_track >= nb_track) {
      NextAlbum(backward);
      ListTracks();
      cur_track = backward ? nb_track - 1 : 0;
      return;
    }
  }

  void NotifyGenre(int genre, bool backward=false) {
    LOG(F("NotifyGenre genre="), genre);
    if(genre != current_genre) {
      current_genre = genre;
      ListAlbums();
      cur_album = backward ? nb_album - 1 : 0;
      ListTracks();
      cur_track = backward ? nb_track - 1 : 0;
    } else {
      NextAlbum(backward);
      ListTracks();
      cur_track = 0;
    }
  }

  char* GetPath() {
    SdFile genre_dir;
    SdFile album_dir;
    SdFile track_file;
    OpenCurrentGenre(&genre_dir);
    OpenCurrentAlbum(&genre_dir, &album_dir);
    OpenCurrentTrack(&album_dir, &track_file);  
    
    char *fptr = filename;
    *fptr++='/';
    genre_dir.getFilename(fptr);
    while(*fptr) { fptr++; }
    *fptr++='/';    
    album_dir.getFilename(fptr);
    while(*fptr) { fptr++; }
    *fptr++='/';
    track_file.getFilename(fptr);

    genre_dir.close();
    album_dir.close();
    track_file.close();
    return filename;
  }

} file_browser;

bool playing = false;
unsigned long stopped_playing_at = 0L;

void initializePlayerState() {
  playing = false;
  stopped_playing_at = millis();  
}

void setup() {
  initializePowerControlPin();
  initializeLeds();
  initializeSerialDebugging();  
  initializePushButtons();
  initializeRotary();
  initializeSDCard();
  initializeMP3Library(); 
  initializePlayerState();
  LOG(F("Ready!"));  
}


void loop() {
  facade.Poll();

  int press_event = facade.NextPressEvent();
  if(press_event != NOTHING_PRESSED) {
    LOG(F("Button"), press_event, F("pressed."));
    // Before switching to a new audio file, we MUST
    // stop playing before accessing the SD directory:
    if (playing) { stopPlaying(); }
    file_browser.NotifyGenre(press_event + 1);    
    startPlaying();
  }

  int rotary_events= fetchAndClearRotaryCounter();
  if(rotary_events != 0) {
    last_rotary_event = millis();
    LOG(F("Rotary moved by"), rotary_events);
    if(volume_control_mode) { 
      volume = min(90, max(16, volume - 4 * rotary_events));
      LOG(F("Change volume to"), volume);
      MP3player.setVolume(volume, volume);  
    } else {
      bool backward = rotary_events < 0;
      // Before switching to a new audio file, we MUST
      // stop playing before accessing the SD directory:
      if (playing) { stopPlaying(); }
      for(int i = abs(rotary_events); i > 0 ; i--) {
        file_browser.NextTrack(backward);
      }
      startPlaying();
    }
  }

  // On rotery press, toggle volume control mode on and off. 
  if(facade.rotary.pressed_event) {
    facade.rotary.pressed_event = false;
    last_rotary_event = millis();
    volume_control_mode = !volume_control_mode;
    LOG(F("volume_control_mode"), volume_control_mode);    
  }

  // Auto exit from volume control mode after a fixed delay.
  if(volume_control_mode && (millis() - last_rotary_event > 10000)) {
    LOG(F("Exit volume control mode"));
    volume_control_mode = false;    
  }

  
  if (playing && !MP3player.isPlaying()) {
    LOG(F("Track is over."));
    stopPlaying();
    if(file_browser.IsLastTrackOfAlbum()) {
      playing = false;
      stopped_playing_at = millis();
    } else {
      file_browser.NextTrack();
      startPlaying();
    }
  }

  if(volume_control_mode) {    
    setLEDColor(CYAN);
  } else {
    if(!playing) {
      unsigned long duration = millis() - stopped_playing_at;
      setLEDColor(BinaryToGrey((duration >> 8)&7)); // Blink
      if( duration > SWITCH_OFF_DELAY ) {
        switchOff();
      }
    }
  
    if(playing) {
      int off = ((millis() >> 8) & 3);    
      setLEDColor(off ? OFF : genre_colors[file_browser.CurrentGenre()]);
    }
  }
  
  if(facade.ShutDownPressed()) {
    switchOff();
  }
}

void stopPlaying() {
  LOG(F("Stopping playback"));  
  MP3player.stopTrack();  
}

void startPlaying() {  
  setLEDColor(WHITE);
  char* path = file_browser.GetPath();
  LOG(F("Start playing file"), path);  
  byte result = MP3player.playMP3(path);
  playing = true;
  LOG(F("Playback returned with"), result);
  setLEDColor(OFF);
}

// Sets the RGB LED in the rotary encoder to a specific color. See the color
// code defined at the start of this sketch.
void setLEDColor(unsigned char color) {  
  digitalWrite(ROT_LEDR, color & B001);
  digitalWrite(ROT_LEDG, color & B010);
  digitalWrite(ROT_LEDB, color & B100);  
}

// Blink the RGB LED in the rotary encoder a given number of times and repeats
// forever. This is so you can see error codes without having to use the serial
// monitor window.
void fatalErrorBlink(int blinks, byte color) {
  LOG(F("Halted."));
  int x;
  while(true) { // Loop forever  
    for (x=0; x < blinks; x++) { // Blink a given number of times
      setLEDColor(color);
      delay(250);
      setLEDColor(OFF);
      delay(250);
    }
    delay(1250); // Longer pause between blink-groups
  }
}

void rotaryIRQ() {
  // Rotary encoder interrupt request function (IRQ).
  // This function is called *automatically* when the
  // rotary encoder changes state.

  // Process input from the rotary encoder.
  // The rotary "position" is held in rotary_counter, increasing
  // for CW rotation (changes by one per detent).
  
  // If the position changes, rotary_change will be set true.
  // (You may manually set this to false after handling the change).

  // This function will automatically run when rotary encoder input A
  // transitions in either direction (low to high or high to low).
  // By saving the state of the A and B pins through two interrupts,
  // we'll determine the direction of rotation.
  
  // Int rotary_counter will be updated with the new value, and boolean
  // rotary_change will be true if there was a value change.
  
  // Based on concepts from Oleg at circuits@home (http://www.circuitsathome.com/mcu/rotary-encoder-interrupt-service-routine-for-avr-micros)
  // Unlike Oleg's original code, this code uses only one interrupt and
  // has only two transition states; it has less resolution but needs only
  // one interrupt, is very smooth, and handles switchbounce well.

  static volatile unsigned char rotary_state = 0xff; // Current (0x3) and previous (0xC) encoder states
  
  bool first = rotary_state == 0xff;
  rotary_state <<= 2;  // Remember previous state
  rotary_state |= (digitalRead(ROT_A) | (digitalRead(ROT_B) << 1));  // Mask in current state
  rotary_state &= 0x0F; // Zero upper nybble
  if(first) {
  }else if (rotary_state == 0x09) {
    // From 10 to 01, increment counter. Also try 0x06 if unreliable.
    rotary_counter++;
  } else if (rotary_state == 0x03) {
    // From 00 to 11, decrement counter. Also try 0x0C if unreliable.
    rotary_counter--;
  }
}
