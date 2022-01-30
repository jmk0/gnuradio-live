# gnuradio-live

Scripts to generate ISO images for a live Ubuntu session with GNU
Radio installed.

## HOW-TO

There are three variables set at the start of build-gr.sh: TOP,
SRC_ISO and TGT_ISO.  TOP specifies the directory where the files will
be built, as well as where the ISOs are located (though the latter can
be changed).

At present, the GNU Radio Ubuntu packages exist for Ubuntu 20, but not
21, so the ISO for Ubuntu 20 is used as the source.

To use the scripts, change the above variables as needed, then execute
   sudo build-gr.sh

The script must be run as root as there are many root-only utilities
involved in creating the ISO image (very little, in fact, does NOT
require root).

## Known Issues

When executing a project from gnuradio-companion, you will get an
error message saying:
   The xterm executable 'x-terminal-emulator' is missing.
   You can change this setting in your gnuradio.conf, in section
   [grc], 'xterm_executable'.
This message can be ignored, and will hopefully be resolved at a later date.

Saving gnuradio-companion projects does not persist beyond a given session.

Error messages will crop up during package installation indicating an
inability to use /dev or /run/ksys.  These do not appear to have an
adverse effect on the process.

During boot of the Ubuntu session, it will complain about two files
not matching their checksums.  The files are:
   isolinux/isolinux.bin
   isolinux/boot.cat
This needs to be resolved at some point.

## Credits

The bulk of this work originates from the post by Rinzwind here:
https://askubuntu.com/questions/48535/how-to-customize-the-ubuntu-live-cd
