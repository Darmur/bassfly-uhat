#!/bin/bash

set -o errexit

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 1>&2
   exit 1
fi

set -e

echo "INSTALLING ALSA SETTINGS FOR BASSFLY-uHAT AND BASSFLY-uHAT INITIALIZATION SCRIPT..."

sed -i \
  -e "s/^dtparam=audio=on/#\0/" \
  -e "s/^#\(dtparam=i2s=on\)/\1/" \
  /boot/config.txt
grep -q "dtoverlay=i2s-mmap" /boot/config.txt || \
  echo "dtoverlay=i2s-mmap" >> /boot/config.txt
grep -q "dtoverlay=googlevoicehat-soundcard" /boot/config.txt || \
  echo "dtoverlay=googlevoicehat-soundcard" >> /boot/config.txt
grep -q "dtparam=i2s=on" /boot/config.txt || \
  echo "dtparam=i2s=on" >> /boot/config.txt

apt update
apt -y install i2c-tools
raspi-config nonint do_i2c 0

# ALSA settings
cat <<'EOF' > /etc/asound.conf
options snd_rpi_googlemihat_soundcard index=0

pcm.spkvol {
    type            softvol
    slave.pcm       "dmix"
    control.name    "PCM"
    control.card    0
}

pcm.micboost {
    type            softvol
    slave.pcm       "dsnoop"
    control.name    "MIC"
    control.card    0
    min_dB      -10.0
    max_dB      18.0
}

pcm.asymed {
    type asym
    playback.pcm "spkvol"
    capture.pcm "micboost"
}

pcm.!default {
    type plug
    slave.pcm "asymed"
}

EOF
rm -f /home/pi/.asoundrc
rm -f /root/.asoundrc

# BASSFLY-uHAT init script
cat <<'EOF' > /usr/bin/bassfly_init.sh
#!/bin/bash

### BASSFLY-uHAT I2C ADDRESS
TFA_LEFT=0x6c
TFA_RIGHT=0x6d

### TFA EQ SETTINGS ###
EQA_WORD1=0xDD59  ## f=100, Q=0.61, Gain=-4.5 ##
EQA_WORD2=0x24CC
EQB_WORD1=0x1A65  ## f=300, Q=0.61, Gain=-3.0 ##
EQB_WORD2=0x2CDB
EQC_WORD1=0x1646  ## f=1000, Q=0.61, Gain=-0.5 ##
EQC_WORD2=0x3AEA
EQD_WORD1=0xF34D  ## f=3000, Q=0.61, Gain=+0.0 ##
EQD_WORD2=0x3EF9
EQE_WORD1=0xE05E  ## f=10000, Q=0.61, Gain=-1.5 ##
EQE_WORD2=0x34F8

### TFA SETTINGS
DEV_CTRL_RST=0x2000  ## REGISTER RST TO DEFAULT ##
DEV_CTRL_ON=0x0900  ## OPMODE ON ; POWERUP ON ##
SERIAL1_CTRL_LEFT=0x1802  ## FS 48kHz ; LEFT CH ##
SERIAL1_CTRL_RIGHT=0x1806  ## FS 48kHz ; RIGHT CH ##
VOL_CTRL=0x3016  ## ZERO CROSS ON ; GAIN 0dB ##
BYPASS_CTRL=0x9A00  ## CLIPCTRL OFF ; EQ ON ; MBDRC OFF
BASS_TRBL=0x2E13  ## TREBLE 0dB / 4.5kHz ; BASS +4dB / 450Hz ##

### TFA REGISTERS ###
TFA_DEV_CTRL=0x00
TFA_SERIAL1_CTRL=0x01
TFA_SERIAL2_CTRL=0x03
TFA_EQA_WORD1=0x05
TFA_EQA_WORD2=0x06
TFA_EQB_WORD1=0x07
TFA_EQB_WORD2=0x08
TFA_EQC_WORD1=0x09
TFA_EQC_WORD2=0x0A
TFA_EQD_WORD1=0x0B
TFA_EQD_WORD2=0x0C
TFA_EQE_WORD1=0x0D
TFA_EQE_WORD2=0x0E
TFA_BYPASS_CTRL=0x0F
TFA_BASS_TRBL=0x11
TFA_VOL_CTRL=0x13

echo "INIT BASSFLY-uHAT"
#!/bin/sh
sudo i2cset -y 1 $TFA_LEFT $TFA_DEV_CTRL $DEV_CTRL_RST w
sudo i2cset -y 1 $TFA_LEFT $TFA_VOL_CTRL $VOL_CTRL w
sudo i2cset -y 1 $TFA_LEFT $TFA_SERIAL1_CTRL $SERIAL1_CTRL_LEFT w
sudo i2cset -y 1 $TFA_LEFT $TFA_DEV_CTRL $DEV_CTRL_ON w

sudo i2cset -y 1 $TFA_RIGHT $TFA_DEV_CTRL $DEV_CTRL_RST w
sudo i2cset -y 1 $TFA_RIGHT $TFA_VOL_CTRL $VOL_CTRL w
sudo i2cset -y 1 $TFA_RIGHT $TFA_SERIAL1_CTRL $SERIAL1_CTRL_RIGHT w
sudo i2cset -y 1 $TFA_RIGHT $TFA_DEV_CTRL $DEV_CTRL_ON w

sudo i2cset -y 1 $TFA_LEFT $TFA_EQA_WORD1 $EQA_WORD1 w
sudo i2cset -y 1 $TFA_LEFT $TFA_EQA_WORD2 $EQA_WORD2 w
sudo i2cset -y 1 $TFA_LEFT $TFA_EQB_WORD1 $EQB_WORD1 w
sudo i2cset -y 1 $TFA_LEFT $TFA_EQB_WORD2 $EQB_WORD2 w
sudo i2cset -y 1 $TFA_LEFT $TFA_EQC_WORD1 $EQC_WORD1 w
sudo i2cset -y 1 $TFA_LEFT $TFA_EQC_WORD2 $EQC_WORD2 w
sudo i2cset -y 1 $TFA_LEFT $TFA_EQD_WORD1 $EQD_WORD1 w
sudo i2cset -y 1 $TFA_LEFT $TFA_EQD_WORD2 $EQD_WORD2 w
sudo i2cset -y 1 $TFA_LEFT $TFA_EQE_WORD1 $EQE_WORD1 w
sudo i2cset -y 1 $TFA_LEFT $TFA_EQE_WORD2 $EQE_WORD2 w
sudo i2cset -y 1 $TFA_LEFT $TFA_BYPASS_CTRL $BYPASS_CTRL w
sudo i2cset -y 1 $TFA_LEFT $TFA_BASS_TRBL $BASS_TRBL w

sudo i2cset -y 1 $TFA_RIGHT $TFA_EQA_WORD1 $EQA_WORD1 w
sudo i2cset -y 1 $TFA_RIGHT $TFA_EQA_WORD2 $EQA_WORD2 w
sudo i2cset -y 1 $TFA_RIGHT $TFA_EQB_WORD1 $EQB_WORD1 w
sudo i2cset -y 1 $TFA_RIGHT $TFA_EQB_WORD2 $EQB_WORD2 w
sudo i2cset -y 1 $TFA_RIGHT $TFA_EQC_WORD1 $EQC_WORD1 w
sudo i2cset -y 1 $TFA_RIGHT $TFA_EQC_WORD2 $EQC_WORD2 w
sudo i2cset -y 1 $TFA_RIGHT $TFA_EQD_WORD1 $EQD_WORD1 w
sudo i2cset -y 1 $TFA_RIGHT $TFA_EQD_WORD2 $EQD_WORD2 w
sudo i2cset -y 1 $TFA_RIGHT $TFA_EQE_WORD1 $EQE_WORD1 w
sudo i2cset -y 1 $TFA_RIGHT $TFA_EQE_WORD2 $EQE_WORD2 w
sudo i2cset -y 1 $TFA_RIGHT $TFA_BYPASS_CTRL $BYPASS_CTRL w
sudo i2cset -y 1 $TFA_RIGHT $TFA_BASS_TRBL $BASS_TRBL w
echo "BASSFLY-uHAT INIT DONE!"

EOF

chmod a+x /usr/bin/bassfly_init.sh

# BASSFLY-uHAT init service
cat <<'EOF' > /etc/systemd/system/bassfly.service
[Unit]
Description=BASSFLY-uHAT Initialization

[Service]
Type=simple
ExecStart=/bin/bash /usr/bin/bassfly_init.sh

[Install]
WantedBy=multi-user.target

EOF


systemctl daemon-reload
systemctl enable bassfly.service
systemctl start bassfly.service

echo "INSTALL ALSA SETTINGS FOR BASSFLY-uHAT AND BASSFLY-uHAT INITIALIZATION SCRIPT DONE!"
echo "PLEASE REBOOT."