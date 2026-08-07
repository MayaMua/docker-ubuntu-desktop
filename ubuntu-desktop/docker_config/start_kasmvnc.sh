#!/bin/sh
PASS="${PASSWORD}"
if [ ${#PASS} -lt 6 ]; then
    PASS="123456"
fi
if [ ! -f "/home/$USER/.vnc/passwd" ]; then
    su $USER -c "echo -e \"$PASS\n$PASS\n\" | kasmvncpasswd -u $USER -o -w -r"
fi
mkdir -p /tmp/.X11-unix
chown root:root /tmp/.X11-unix 2>/dev/null || true
chmod 1777 /tmp/.X11-unix 2>/dev/null || true
rm -rf /tmp/.X1000-lock /tmp/.X11-unix/X1000

if [ ! -f "/home/$USER/.vnc/xstartup" ]; then
    cat > "/home/$USER/.vnc/xstartup" << 'XSTARTUP'
#!/bin/sh
set -x
xrdb $HOME/.Xresources 2>/dev/null || true
xhost + >/dev/null 2>&1 || true
export DISPLAY=:1000
exec dbus-launch --exit-with-session xfce4-session
XSTARTUP
    chmod +x "/home/$USER/.vnc/xstartup"
fi

# start kasmvnc
if [ ! -z ${DISABLE_HTTPS+x} ]; then
  su $USER -c "kasmvncserver :1000 -select-de xfce -interface 0.0.0.0 -websocketPort 4000 -sslOnly 0 -RectThreads $VNC_THREADS -stunServer none -publicIP 127.0.0.1"
else
  su $USER -c "kasmvncserver :1000 -select-de xfce -interface 0.0.0.0 -websocketPort 4000 -cert $HTTPS_CERT -key $HTTPS_CERT_KEY -RectThreads $VNC_THREADS -stunServer none -publicIP 127.0.0.1"
fi
su $USER -c "pulseaudio --start"
tail -f /home/$USER/.vnc/*.log
