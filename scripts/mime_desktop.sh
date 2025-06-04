#!/bin/bash

cat > /usr/share/applications/cmus.desktop << 'EOF'
[Desktop Entry]
Name=cmus
Comment=C* Music Player
Exec=cmus %F
Icon=multimedia-player
Terminal=true
Type=Application
Categories=AudioVideo;Audio;Player
MimeType=audio/mpeg;audio/mp3;audio/flac;audio/ogg
EOF
