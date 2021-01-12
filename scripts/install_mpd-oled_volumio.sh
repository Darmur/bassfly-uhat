#!/bin/bash

set -o errexit

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 1>&2
   exit 1
fi

set -e

echo "!!!  INSTALLING MPD-OLED FOR BASSFLY-uHAT AND BASSMANTIS-uHAT  !!!"

echo "!!!  ADDING SETTING TO INCREASE I2C BUS SPEED  !!!"
grep -q "dtparam=i2c_arm_baudrate=800000" /boot/userconfig.txt || \
  echo "dtparam=i2c_arm_baudrate=800000" >> /boot/userconfig.txt

echo "!!!  PLEASE SET YOUR TIME-ZONE  !!!"
sudo dpkg-reconfigure tzdata

echo "!!!  INSTALLING NECESSARY UTILITIES, PLEASE WAIT  !!!"
sudo apt update
sudo apt -y install git-core autoconf make libtool libfftw3-dev libasound2-dev build-essential make libi2c-dev i2c-tools lm-sensors libcurl4-openssl-dev libmpdclient-dev libjsoncpp-dev

echo "!!!  BUILDING AND INSTALLING CAVA, PLEASE WAIT  !!!"
cd /home/volumio/
rm -rf cava
git clone https://github.com/karlstav/cava
cd cava
./autogen.sh
./configure
make
sudo make install
rm -rf /home/volumio/cava

echo "!!!  CREATING BACKUP OF ORIGINAL MPD SETTINGS TEMPLATE, TO RESTORE ORIGINAL VOLUMIO IMAGE BEFORE UPDATE  !!!"
cp /volumio/app/plugins/music_service/mpd/mpd.conf.tmpl /home/volumio/.mpd.conf.tmpl.orig

echo "!!!  CREATING RESTORE SCRIPT  !!!"
cat <<'EOF' > /home/volumio/restore_mpd_template.sh
#!/bin/bash

cp /home/volumio/.mpd.conf.tmpl.orig /volumio/app/plugins/music_service/mpd/mpd.conf.tmpl
echo "mpd.conf.template HAS BEEN RESTORED. PLEASE PROCEED WITH VOLUMIO UPDATE, THEN RUN update_mpd_template.sh TO APPLY SETTINGS FOR CAVA"

EOF
chmod a+x /home/volumio/restore_mpd_template.sh

echo "!!!  UPDATING MPD SETTINGS TEMPLATE, TO INCLUDE PIPE FOR CAVA  !!!"
cat <<'EOF' >> /volumio/app/plugins/music_service/mpd/mpd.conf.tmpl

audio_output {
        type            "fifo"
        name            "mpd_oled_FIFO"
        path            "/tmp/mpd_oled_fifo"
        format          "44100:16:2"
}

EOF

echo "!!!  CREATING BACKUP OF MODIFIED MPD SETTINGS TEMPLATE, TO RESTORE CAVA PIPE AFTER SYSTEM UPDATE  !!!"
cp /volumio/app/plugins/music_service/mpd/mpd.conf.tmpl /home/volumio/.mpd.conf.tmpl.cava

echo "!!!  CREATING UPDATE SCRIPT  !!!"
cat <<'EOF' > /home/volumio/update_mpd_template.sh
#!/bin/bash

cp /home/volumio/.mpd.conf.tmpl.cava /volumio/app/plugins/music_service/mpd/mpd.conf.tmpl
echo "mpd.conf.template HAS BEEN UPDATED WITH SETTINGS FOR CAVA PIPE"

EOF
chmod a+x /home/volumio/update_mpd_template.sh

echo "!!!  BUILDING AND INSTALLING MPD-OLED, PLEASE WAIT  !!!"
cd /home/volumio/
rm -rf mpd_oled
git clone https://github.com/antiprism/mpd_oled
cd mpd_oled
PLAYER=VOLUMIO make
sed -i "s/mpd_oled -o 6 -b 21 -g 1 -f 15/mpd_oled -o 3 -a 3c -b 10 -g 1 -f 25 -P s/" mpd_oled.service
sudo bash install.sh
cd /home/volumio/

echo "!!!  MPD-OLED HAS BEEN INSTALLED. YOUR DISPLAY SHOULD BE UP AND RUNNING NOW  !!!"
echo "!!!  TO ENABLE THE CAVA PIPE FOR THE SPECTRUM DISPLAY, VOLUMIO MUST REGENERATE MPD.CONF AND RESTART MPD  !!!"
echo "!!!  OPEN THE WEB UI AND GO TO SETTINGS > PLAYBACK OPTIONS, THEN CLICK ON SAVE IN THE AUDIO OUTPUT SECTION  !!!"
echo "!!!  WHEN DONE, PLEASE REBOOT  !!!"
