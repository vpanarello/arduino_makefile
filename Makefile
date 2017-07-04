
########### BULDER PREFERENCES ###########

ARDUINO_FOLDER = C:/opensource/arduino-1.8.1

########### AVR TARGET MCU SPECS ###########

MCU = atmega328p
MCU_CLK = 16000000L

###########  PROGRAMMER OPTIONS (AVRDUDE) ########### 

AVRDUDE_PROGRAMMER = arduino #avrisp 
AVRDUDE_PORT = COM3

########### STANDART PROJECT STRUCTURE (make init) ###########

# project
#	|_(build)
#		|_(cores)
#   |_(libs)
#	|_main.cpp

# This source must contain the 'int main() {}' function
MAIN_FILE = main.cpp

LIBRARIES = libs/
BUILD_OUTPUT = build/
BUILD_CORES = $(BUILD_OUTPUT)cores/
LINKED_CORE_FILE = core.a

########### STATIC RESOURCE FOLDERS ###########

# Specify de main cores sources of arduino
CORES_FOLDER = $(ARDUINO_FOLDER)/hardware/arduino/avr/cores/arduino
# Specify avr tools of arduino folder
AVR_TOOLS = $(ARDUINO_FOLDER)/hardware/tools/avr/bin

########### AVR TOOLS ###########

GPP = $(AVR_TOOLS)\avr-g++
GCC = $(AVR_TOOLS)\avr-gcc
AR = $(AVR_TOOLS)\avr-gcc-ar
DUMP = $(AVR_TOOLS)\avr-objdump
DUDE = $(AVR_TOOLS)\avrdude
SIZE = $(AVR_TOOLS)\avr-size
COPY = $(AVR_TOOLS)\avr-objcopy

########### AVR STANDARD LIBS ###########

INCLUDES += -I"C:\opensource\arduino-1.8.1\hardware\arduino\avr\cores\arduino"
INCLUDES += -I"C:\opensource\arduino-1.8.1\hardware\arduino\avr\variants\standard"

########### AVR PREPROCESSOR DEFINES ###########

TAGS += -DF_CPU=$(MCU_CLK)   
TAGS += -DARDUINO=10801
TAGS += -DARDUINO_AVR_UNO
TAGS += -DARDUINO_ARCH_AVR

MCU_SPECS = -mmcu=$(MCU) $(TAGS)
 
########### AVR COMPILER DEFINITIONS ###########

# -Os	-> tell the compiler to optimize the code for efficient space usage
# -c	-> tells the compiler to compile and stop
# -g	-> used to embed debug info
# -v	-> verbose mode

GCC_FLAGS = -c -g -Os -Wall -Wextra -std=gnu11 -ffunction-sections -fdata-sections -MMD -flto -fno-fat-lto-objects
GPP_FLAGS = -c -g -Os -Wall -Wextra -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD -flto

AR_FLAGS = rcs -v

########### AVR COMPILERS ###########

GCC_COMPILER = "$(GCC)" $(GCC_FLAGS) $(MCU_SPECS) $(INCLUDES)
GPP_COMPILER = "$(GPP)" $(GPP_FLAGS) $(MCU_SPECS) $(INCLUDES)

AR_LINKER = "$(AR)" $(AR_FLAGS)

########### AVR LINKERS ###########

LINKER_FLAGS = -Wall -Wextra -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections $(MCU_SPECS)
LINKER_OBJ = -o "$(GCC_SOURCES) $(GPP_SOURCES)"

OBJECT_FILES = $(wildcard $(BUILD_FOLDER)*.o)

CORES_OBJECT_FILES = $(wildcard $(BUILD_CORES)*.o)

########### APPLICATION SOURCE FILES ###########

INCLUDE_SUBFOLDERS = libs/
BUILD_FOLDER = build/

GCC_SOURCES = $(wildcard *.c)
GCC_SOURCES += $(foreach folder, $(INCLUDE_SUBFOLDERS), $(wildcard $(folder)*.c))

GPP_SOURCES = $(wildcard *.cpp)
GPP_SOURCES += $(foreach folder, $(INCLUDE_SUBFOLDERS), $(wildcard $(folder)*.cpp))

GCC_CORES = $(wildcard $(CORES_FOLDER)/*.c)
GPP_CORES = $(wildcard $(CORES_FOLDER)/*.cpp)

########### UPLOADABLE FORMATS ###########

OBJCOPY_TAGS = -O ihex -R .eeprom

###########  Programming Options (avrdude) ########### 

AVRDUDE_CONF =  $(ARDUINO_FOLDER)/hardware/tools/avr/etc/avrdude.conf

AVRDUDE_BAUD = 115200

AVRDUDE_FLASH_WRITE = -U flash:w:$(BUILD_FOLDER)$(basename $(MAIN_FILE)).hex:i
AVRDUDE_FLASH_READ = -U flash:r:$(BUILD_FOLDER)read_$(basename $(MAIN_FILE)).hex:i

AVRDUDE_EEPROM_WRITE = -U eeprom:w:$(BUILD_FOLDER)$(basename $(MAIN_FILE)).eep:i
AVRDUDE_EEPROM_READ = -U eeprom:r:$(BUILD_FOLDER)read_$(basename $(MAIN_FILE)).eep:i


# Uncomment the following if you want avrdude's erase cycle counter.
# Note that this counter needs to be initialized first using -Yn,
# see avrdude manual.
#AVRDUDE_ERASE_COUNTER = -y

# Uncomment the following if you do /not/ wish a verification to be
# performed after programming the device.
#AVRDUDE_NO_VERIFY = -V

# Increase verbosity level.  Please use this when submitting bug
# reports about avrdude. See <http://savannah.nongnu.org/projects/avrdude> 
# to submit bug reports.
AVRDUDE_VERBOSE = -v -v

AVRDUDE_D_FLAG = -D

AVRDUDE_FLAGS = -C $(AVRDUDE_CONF) -p $(MCU) -P $(AVRDUDE_PORT) -c $(AVRDUDE_PROGRAMMER) -b $(AVRDUDE_BAUD)
AVRDUDE_FLAGS += $(AVRDUDE_NO_VERIFY)
AVRDUDE_FLAGS += $(AVRDUDE_VERBOSE)
AVRDUDE_FLAGS += $(AVRDUDE_ERASE_COUNTER)
AVRDUDE_FLAGS += $(AVRDUDE_D_FLAG)


########### BUILD RECIPES ###########

all: compile link tohex size

compile:
	@for filename in $(GPP_SOURCES); \
		do \
			echo "*** Compiling C++ Source '$$filename' -> '$(BUILD_FOLDER)$${filename//[a-zA-Z0-9_]*[\/]}.o'"; \
			$(GPP_COMPILER) "$$filename" -o "$(BUILD_FOLDER)$${filename//[a-zA-Z0-9_]*[\/]}.o"; \
	done
	@for filename in $(GCC_SOURCES); \
		do \
			echo "*** Compiling C Source '$$filename' -> '$(BUILD_FOLDER)$${filename//[a-zA-Z0-9_]*[\/]}.o'"; \
			$(GCC_COMPILER) "$$filename" -o "$(BUILD_FOLDER)$${filename//[a-zA-Z0-9_]*[\/]}.o"; \
	done
	@echo ''

cores: compile_cores linkcores

compile_cores:
	@echo '*** Compiling cores...'
	@for filename in $(GPP_CORES); \
		do \
			echo "*** Compiling C++ Source '$$filename' -> '$(BUILD_CORES)$${filename//[a-zA-Z0-9_]*[\/]}.o'"; \
			$(GPP_COMPILER) "$$filename" -o "$(BUILD_CORES)$${filename//[a-zA-Z0-9_]*[\/]}.o"; \
	done
	@for filename in $(GCC_CORES); \
		do \
			echo "*** Compiling C Source '$$filename' -> '$(BUILD_CORES)$${filename//[a-zA-Z0-9_]*[\/]}.o'"; \
			$(GCC_COMPILER) "$$filename" -o "$(BUILD_CORES)$${filename//[a-zA-Z0-9_]*[\/]}.o"; \
	done
	@rm $(BUILD_CORES)main.*
	@echo ''

linkcores:
	@echo '*** Linking cores...'
	@for filename in $(CORES_OBJECT_FILES); do $(AR_LINKER) $(BUILD_FOLDER)$(LINKED_CORE_FILE) "$$filename"; done
	@echo ''

dumpcore: $(BUILD_CORES)$(LINKED_CORE_FILE)
	@$(DUMP) -d $(BUILD_CORES)$(LINKED_CORE_FILE)
	
link:
	@if [ -a $(BUILD_OUTPUT)$(LINKED_CORE_FILE) ]; \
		then \
			echo '*** Linking everything together with core libraries...'; \
			"$(GCC)" $(LINKER_FLAGS) -o $(BUILD_FOLDER)$(basename $(MAIN_FILE)).elf $(OBJECT_FILES) $(BUILD_OUTPUT)$(LINKED_CORE_FILE) -lm; \
		else \
			echo '*** Linking everything together without cores...'; \
			"$(GCC)" $(LINKER_FLAGS) -o $(BUILD_FOLDER)$(basename $(MAIN_FILE)).elf $(OBJECT_FILES); \
	fi

dump:
	@$(DUMP) -d $(BUILD_FOLDER)$(basename $(MAIN_FILE)).elf

size:
	@echo
	@echo
	@$(SIZE) --mcu=$(MCU) --format=avr $(BUILD_FOLDER)$(basename $(MAIN_FILE)).elf


########### UPLOADABLE FORMATS RECIPES ###########

tohex: $(BUILD_FOLDER)$(basename $(MAIN_FILE)).elf
	@echo "*** Converting to intel hexadecimal format... '$(BUILD_FOLDER)$(basename $(MAIN_FILE)).elf' -> '$(BUILD_FOLDER)$(basename $(MAIN_FILE)).hex' "
	@"$(COPY)" $(OBJCOPY_TAGS) "$(BUILD_FOLDER)$(basename $(MAIN_FILE)).elf" "$(BUILD_FOLDER)$(basename $(MAIN_FILE)).hex"

# "C:\opensource\arduino-1.8.1\hardware\tools\avr/bin/avr-objcopy" -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0  "C:\Users\VagnerF\AppData\Local\Temp\arduino_build_909140/sketch_jun15a.ino.elf" "C:\Users\VagnerF\AppData\Local\Temp\arduino_build_909140/sketch_jun15a.ino.eep"
# "C:\opensource\arduino-1.8.1\hardware\tools\avr/bin/avr-objcopy" -O ihex -R .eeprom  "C:\Users\VagnerF\AppData\Local\Temp\arduino_build_909140/sketch_jun15a.ino.elf" "C:\Users\VagnerF\AppData\Local\Temp\arduino_build_909140/sketch_jun15a.ino.hex"


########### DEVICE PROGRAM RECIPES ###########

program: $(BUILD_FOLDER)$(basename $(MAIN_FILE)).hex
	$(DUDE) $(AVRDUDE_FLAGS) $(AVRDUDE_FLASH_WRITE)

program-read:
	$(DUDE) $(AVRDUDE_FLAGS) $(AVRDUDE_FLASH_READ)

program-eeprom: $(TARGET).eep
	$(DUDE) $(AVRDUDE_FLAGS) $(AVRDUDE_EEPROM_WRITE)

program-read-eeprom:
	$(DUDE) $(AVRDUDE_FLAGS) $(AVRDUDE_EEPROM_READ)

program-erase:
	$(DUDE) $(AVRDUDE_FLAGS) -e


########### MAINTENANCE RECIPES ###########

init:
	@if [ ! -d $(BUILD_OUTPUT) ]; then mkdir -v $(BUILD_OUTPUT); fi
	@if [ ! -d $(BUILD_CORES) ]; then mkdir -v $(BUILD_CORES); fi
	@if [ ! -d $(LIBRARIES) ]; then mkdir -v $(LIBRARIES); fi
	@if [ ! -a $(MAIN_FILE) ] ; then touch $(MAIN_FILE); fi;

cleanall: cleancores clean

clean:
	@rm -v $(BUILD_FOLDER)*.o
	@rm -v $(BUILD_FOLDER)*.d
	@rm -v $(BUILD_FOLDER)*.elf
	@rm -v $(BUILD_FOLDER)*.hex

cleancores:
	@rm -v $(BUILD_CORES)*.o
	@rm -v $(BUILD_CORES)*.d
	@rm -v $(BUILD_FOLDER)core.a

help:
	@echo '         init -> initialize a new project folder structure'
	@echo '          all ->'
	@echo '      compile ->'
	@echo '        cores -> compile, link cores and genereate core.a file'
	@echo 'compile_cores -> only compare cores'
	@echo '    linkcores -> only link the cores and genereate core.a file'
	@echo '     dumpcore ->'
	@echo '         link ->'
	@echo '         dump ->'
	@echo '         size ->'
	@echo '     cleanall ->'
	@echo '        clean ->'
	@echo '   cleancores ->'

########### COMPILATION PROCESS RESULTANT FILES ###########
# .h	-> C declaration headers 
# .c	-> C pure source files
# .cpp	-> C++ source files
# .a	-> library object file
# .o	-> compiled (c/cpp) object files
# .elf	-> output file for debbugers (output linking binary file)
# .epp	-> output files for uC build-in eproms
# .hex	-> output files to uC flash upload program

########### AVR TOOLS HELP PRINTS ###########
#	Usage: avr-gcc.exe [options] file...
#Options:
#  -pass-exit-codes         Exit with highest error code from a phase
#  --help                   Display this information
#  --target-help            Display target specific command line options
#  --help={target|optimizers|warnings|undocumented|params}[,{[^]joined|[^]separate}]
#                           Display specific types of command line options
#  (Use '-v --help' to display command line options of sub-processes)
#  -dumpspecs               Display all of the built in spec strings
#  -dumpversion             Display the version of the compiler
#  -dumpmachine             Display the compiler's target processor
#  -print-search-dirs       Display the directories in the compiler's search path
#  -print-libgcc-file-name  Display the name of the compiler's companion library
#  -print-file-name=<lib>   Display the full path to library <lib>
#  -print-prog-name=<prog>  Display the full path to compiler component <prog>
#  -print-multi-directory   Display the root directory for versions of libgcc
#  -print-multi-lib         Display the mapping between command line options and
#                           multiple library search directories
#  -print-multi-os-directory Display the relative path to OS libraries
#  -print-sysroot-headers-suffix Display the sysroot suffix used to find headers
#  -Wa,<options>            Pass comma-separated <options> on to the assembler
#  -Wp,<options>            Pass comma-separated <options> on to the preprocessor
#  -Wl,<options>            Pass comma-separated <options> on to the linker
#  -Xassembler <arg>        Pass <arg> on to the assembler
#  -Xpreprocessor <arg>     Pass <arg> on to the preprocessor
#  -Xlinker <arg>           Pass <arg> on to the linker
#  -combine                 Pass multiple source files to compiler at once
#  -save-temps              Do not delete intermediate files
#  -pipe                    Use pipes rather than intermediate files
#  -time                    Time the execution of each subprocess
#  -specs=<file>            Override built-in specs with the contents of <file>
#  -std=<standard>          Assume that the input sources are for <standard>
#  --sysroot=<directory>    Use <directory> as the root directory for headers
#                           and libraries
#  -B <directory>           Add <directory> to the compiler's search paths
#  -b <machine>             Run gcc for target <machine>, if installed
#  -V <version>             Run gcc version number <version>, if installed
#  -v                       Display the programs invoked by the compiler
#  -###                     Like -v but options quoted and commands not executed
#  -E                       Preprocess only; do not compile, assemble or link
#  -S                       Compile only; do not assemble or link
#  -c                       Compile and assemble, but do not link
#  -o <file>                Place the output into <file>
#  -x <language>            Specify the language of the following input files
#                           Permissible languages include: c c++ assembler none
#                           'none' means revert to the default behavior of
#                           guessing the language based on the file's extension
#
# Options starting with -g, -f, -m, -O, -W, or --param are automatically
# passed on to the various sub-processes invoked by avr-gcc.exe.  In order to pass
# other options on to these processes the -W<letter> options must be used.

#Usage: avr-g++.exe [options] file...
#Options:
#  -pass-exit-codes         Exit with highest error code from a phase
#  --help                   Display this information
#  --target-help            Display target specific command line options
#  --help={target|optimizers|warnings|undocumented|params}[,{[^]joined|[^]separate}]
#                           Display specific types of command line options
#  (Use '-v --help' to display command line options of sub-processes)
#  -dumpspecs               Display all of the built in spec strings
#  -dumpversion             Display the version of the compiler
#  -dumpmachine             Display the compiler's target processor
#  -print-search-dirs       Display the directories in the compiler's search path
#  -print-libgcc-file-name  Display the name of the compiler's companion library
#  -print-file-name=<lib>   Display the full path to library <lib>
#  -print-prog-name=<prog>  Display the full path to compiler component <prog>
#  -print-multi-directory   Display the root directory for versions of libgcc
#  -print-multi-lib         Display the mapping between command line options and
#                           multiple library search directories
#  -print-multi-os-directory Display the relative path to OS libraries
#  -print-sysroot-headers-suffix Display the sysroot suffix used to find headers
#  -Wa,<options>            Pass comma-separated <options> on to the assembler
#  -Wp,<options>            Pass comma-separated <options> on to the preprocessor
#  -Wl,<options>            Pass comma-separated <options> on to the linker
#  -Xassembler <arg>        Pass <arg> on to the assembler
#  -Xpreprocessor <arg>     Pass <arg> on to the preprocessor
#  -Xlinker <arg>           Pass <arg> on to the linker
#  -combine                 Pass multiple source files to compiler at once
#  -save-temps              Do not delete intermediate files
#  -pipe                    Use pipes rather than intermediate files
#  -time                    Time the execution of each subprocess
#  -specs=<file>            Override built-in specs with the contents of <file>
#  -std=<standard>          Assume that the input sources are for <standard>
#  --sysroot=<directory>    Use <directory> as the root directory for headers
#                           and libraries
#  -B <directory>           Add <directory> to the compiler's search paths
#  -b <machine>             Run gcc for target <machine>, if installed
#  -V <version>             Run gcc version number <version>, if installed
#  -v                       Display the programs invoked by the compiler
#  -###                     Like -v but options quoted and commands not executed
#  -E                       Preprocess only; do not compile, assemble or link
#  -S                       Compile only; do not assemble or link
#  -c                       Compile and assemble, but do not link
#  -o <file>                Place the output into <file>
#  -x <language>            Specify the language of the following input files
#                           Permissible languages include: c c++ assembler none
#                           'none' means revert to the default behavior of
#                           guessing the language based on the file's extension
#
# Options starting with -g, -f, -m, -O, -W, or --param are automatically
# passed on to the various sub-processes invoked by avr-g++.exe.  In order to pass
# other options on to these processes the -W<letter> options must be used.
