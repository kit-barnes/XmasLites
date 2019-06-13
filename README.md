XmasLites
=========
A very quick and dirty (very much unpolished) WS281X RGB LED controller,
ESP8266-NodeMCU based and browser controlled.
FTP and telnet servers allow software upgrades
and execution of arbitrary Lua commands for testing and debugging.

Steps
-----
- Custom NodeMCU build from master branch at https://nodemcu-build.com/
  including modules: color_utils, file, gpio, net, node, tmr, uart, wifi, ws2812, ws2812_effects.
  LFS options: Size=128K, SPIFFS base=[0 start right after firmware], SPIFFS size=[all free flash]
- Float version (nodemcu-master-10-modules-2018-11-14-13-33-13-float.bin)
  loaded onto Adafruit HUZZAH ESP8266 module with NodeMCU PyFlasher.
- Assemble LFS image per https://nodemcu.readthedocs.io/en/master/getting-started/#compile-lua-into-lfs-image
- Load lfsfloat.img to SPIFFS with ESPlorer.
- Using LuaLoader or ESPlorer:
  - wifi.setmode(wifi.STATION);
  - wifi.sta.config({ssid="WIFI_SSID",pwd="WIFI_PASSWORD"});
  - wifi.sta.sethostname("DEVICE_NAME");
  - node.flashreload("lfsfloat.img");
  - upload init.lua, HTTPserver.lua, main.lua, and patterns.lua to SPIFFS

Startup
-------
All the LEDs in the string are lit red at startup.
If they turn blue, then LFS initialization failed.
Once WiFi is connected and the FTP and telnet servers have been started
the LEDs turn green and init.lua pauses for 15 seconds
before running main.lua which in turn loads the HTTPserver and patterns.
The 15 second delay allows time to connect to the FTP server and delete main.lua
should an update to it, the HTTPserver, or patterns cause the system to crash.

Patterns
--------
There are 4 patterns:

- *Sparkle* starts out with a base red color.
  Individual LEDs occasionally flare brighter with a random color and fade back to base.
  Red, green, or white streaks sometimes run up or down the string starting and ending at random points.
  Streaks change the base color of the LEDs they pass to red, green, or white.
- *Waves* has 3 sinusoidal intensity patterns of different wavelengths
  that move at different speeds up and down the light string.
  Red, green and blue are assigned to the 3 pattens and switched randomly.
- *PentaPh* divides the LEDs into 5 sets by having the LEDs "count off" by fives.
  All five sets brighten and dim at the same frequency but with different phases.
  When each set gets to zero brightness, all of its LEDs are set to new random colors.
- *RnG (Red and Green)* is the quietest of the patterns.
  It starts out all red, waits 15 seconds, then rapidly changes each LED to green,
  one at a time, in a random order.
  With all LEDs now green, it waits another 15 seconds,
  then changes them all back to red in a different random order and repeats.

There is also a pattern *All* which is run after boot.
Every 2 minutes, *All* randomly picks one of the patterns above to run.

A very minimal web interface allows picking the pattern to run.

Enclosure
---------
I just reused the 3D printed case I designed for the smartLEDdimmer.
Sketchup files for it are available at:

https://github.com/kit-barnes/smartLEDdimmer.git

FTP and telnet
--------------
The login and password for the FTP server are "xmas" and "tree" respectively.
I'm using WinSCP as a client.
Transfer files one at a time.

The telnet server has no security at all - just connect to port 23 and you're in.
Not all output you'd see on the serial port is shown - STDERR is not connected.

