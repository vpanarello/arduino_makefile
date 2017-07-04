Arduino Projects Makefile
==

### Description
Build and Flash Arduino based projects with makefile for GNU Make

### Configure
Open the 'Makefile' and configure 'ARDUINO_FOLDER' with the folder where your Arduino IDE is installed. Configure also the parameters 'MCU' with your Arduino Board type, 'MCU_CLK' with the frequency clock of your board. This file is already set to use default board Arduino Uno. To program the board 'AVRDUDE_PORT' must be set with current serial port of your Arduino.

### Use
1) GNU Make must be set in your system path enviroment variable
2) copy the 'Makefile' to a empty project folder
3) type the command 'make init' the basic folder structure will be created
4) type 'make cores' to compile the core of Arduino 
5) type 'make' to compile your project files and link everything
6) type 'make program' to flash the generated HEX file to your Arduino

### Author
Vagner Panarello <<vpanarello@gmail.com>>


### Contribute
* Send comments, suggestions and bug reports to:
https://github.com/vpanarello/arduino_makefile/issues

* Or fork the code on github:
https://github.com/vpanarello/arduino_makefile


