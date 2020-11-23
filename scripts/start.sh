#!/bin/sh
# This software includes the marthoc/docker-deconz Docker Image: Copyright (c) 2018 Mark Coombes
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

echo "Starting deCONZ..."
echo "Current deCONZ version: $DECONZ_VERSION"
echo "Web UI port: $DECONZ_WEB_PORT"
echo "Websockets port: $DECONZ_WS_PORT"

DECONZ_OPTS="--auto-connect=1 \
        --dbg-info=$DEBUG_INFO \
        --dbg-aps=$DEBUG_APS \
        --dbg-zcl=$DEBUG_ZCL \
        --dbg-zdp=$DEBUG_ZDP \
        --dbg-otau=$DEBUG_OTAU \
        --http-port=$DECONZ_WEB_PORT \
        --ws-port=$DECONZ_WS_PORT"

if [ "$DECONZ_VNC_MODE" != 0 ]; then
  
  if [ "$DECONZ_VNC_PORT" -lt 5900 ]; then
    echo "ERROR - VNC port must be 5900 or greater!"
    exit 1
  fi

  DECONZ_VNC_DISPLAY=:$(($DECONZ_VNC_PORT - 5900))
  echo "VNC port: $DECONZ_VNC_PORT"
  
  if [ ! -e /root/.vnc ]; then
    mkdir /root/.vnc
  fi
  
  # Set VNC password
  echo "$DECONZ_VNC_PASSWORD" | tigervncpasswd -f > /root/.vnc/passwd
  chmod 600 /root/.vnc/passwd

  # Cleanup previous VNC session data
  tigervncserver -kill "$DECONZ_VNC_DISPLAY"

  # Set VNC security
  tigervncserver -SecurityTypes VncAuth,TLSVnc "$DECONZ_VNC_DISPLAY"
  
  # Export VNC display variable
  export DISPLAY=$DECONZ_VNC_DISPLAY
else
  echo "VNC Disabled"
  DECONZ_OPTS="$DECONZ_OPTS -platform minimal"
fi

if [ "$DECONZ_DEVICE" != 0 ]; then
  DECONZ_OPTS="$DECONZ_OPTS --device=$DECONZ_DEVICE"
fi

if [ "$DECONZ_UPNP" != 1 ]; then
  DECONZ_OPTS="$DECONZ_OPTS --upnp=0"
fi

$SNAP/usr/bin/deCONZ $DECONZ_OPTS