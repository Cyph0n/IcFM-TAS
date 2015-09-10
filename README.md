iTAS
========

The code used for the transmitter and receiver of the Intelligent Traffic Alert System. 

The code is provided as is. It does work, but is quite messy and not too organized. It has been open sourced in case anyone working on something similar needs it.

## How to Use

The code is divided into two folders:

* transmitter
* receiver

The transmitter code is esentially a set of MATLAB scripts that should be run from `FSKwithaudio.m`. In the aforementioned script, you should check and modify (if needed) the variables at the top of the file. Furthermore, if not running on Windows, you'll need to install both LAME and ffmpeg to be able to save the output files as MP3 and WMA. The easiest way to do this is via Homebrew on OS X or APT on Debian. This is optional, yet the code will spew some errors out. Be sure to remove all the lines that write to output. They can be found towards the end of `FSKwithaudio.m`.

The receiver code however was written for the Arduino microcontroller using the Arduino IDE. However, the code is all pure AVR C, meaning it should and probably will run in any other AVR IDE, such as AVR Studio. Before you can though, you'll need to import some header files, create a `main()` function, copy the contents of the `setup()` function to the start of main, and finally copy the contents of the `loop()` function and place it within a `while (1)` (infinite loop) right under the setup code in `main()`.

## Help?

Create an issue here on Github or simply email me: assilksiksi [at] gmail (dot) com.
