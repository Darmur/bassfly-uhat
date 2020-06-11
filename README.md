# BassFly-uHAT
### uHAT for Raspberry Pi with stereo TFA9879/TFA8200 amplifiers, I2S microphones and OLED display.

#### Project description

![BassFly-uHAT](https://github.com/Darmur/bassfly-uhat/blob/master/BassFly_uHat.3D-02.png)

BassFly-uHAT is an expansion board for Raspberry Pi Zero, but it will work fine with other Rasbperry Pi versions (2, 3A, 3B, 4) and with ASUS ThinkerBoard too. It's been designed following the [mechanical specification for uHAT form factor](https://github.com/raspberrypi/hats/blob/master/uhat-board-mechanical.pdf).

Together with [Volumio](https://volumio.org/) it will turn your Raspberry Pi into a tiny but powerful digital radio.



#### Specs

BassFly uHAT is powered by the following peripherals:

* 2x [TFA9879](https://www.nxp.com/docs/en/data-sheet/TFA9879.pdf) / [TFA8200](https://www.nxp.com/docs/en/data-sheet/TFA8200.pdf) amplifier from NXP (both of them can be used). They have an embedded DSP for HW volume control, HW 5-band equalizer and HW dynamic range compressor; they can deliver up to 2.5W RMS output power each (with 4Ohm load).
* 4x Tactile button, for playback control (play/pause, prev/next, vol-up/vol-down) or for safe shutdown.
* 1x RGB LED, for SD-card activity or for playback status indicator.
* 1x [0.96" I2C OLED DISPLAY MODULE 128X64 SSD1306](https://github.com/Darmur/bassfly-uhat/blob/master/pictures/OLED_module.jpg) (optional), to display an information screen including a music frequency spectrum.
* 2x [INMP441 MEMS OMNIDIRECTIONAL MICROPHONE MODULE](https://github.com/Darmur/bassfly-uhat/blob/master/pictures/MIC_module.jpg) (optional), not necessary for Volumio at the moment, but they can be used for other projects (Google-assistant, Alexa-assistant, voice-triggered in general).



#### What's available

* Schematic
* Layout
* Gerber
* BOM (two variants, one with TFA9879 and one with TFA8200)
* Pick&Place Centroid file

Nothing is missing for ordering bare or assembled PCBs from PCB manufacturers. The design has been made for keeping cost as low as possible, people with good soldering skills can try to solder all the components by hand, it's tricky but still doable.

Optional modules are marked as Not Mounted in the BOM, they can be added manually or requested to be soldered by the PCB manufacturer, they should not have problems to find them.



#### How to use

Proper driver integration is still work-in-progress, as a partial workaround a generic dt-overlay and a script launched at startup can be used. BassFly-uHAT will work fine, but no Hardware volume-control will be available (Software volume control will work fine).


##### Install script for Volumio

SSH needs to be [enabled](https://volumio.github.io/docs/User_Manual/SSH.html).
Open a SSH session and type following commands:

```
wget https://raw.githubusercontent.com/Darmur/bassfly-uhat/master/scripts/install_bassfly_volumio.sh
chmod a+x install_bassfly_volumio.sh
sudo ./install_bassfly_volumio.sh
```
Please select "Generic I2S DAC" under Volumio playback options, then reboot.


##### Install script for Raspbian/Raspios

Please type following commands (from terminal or SSH session):
```
wget https://raw.githubusercontent.com/Darmur/bassfly-uhat/master/scripts/install_bassfly_raspios.sh
chmod a+x install_bassfly_raspios.sh
sudo ./install_bassfly_raspios.sh
```
After reboot BassFly-uHAT will be up and running



