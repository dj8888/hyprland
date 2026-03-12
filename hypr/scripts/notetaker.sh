#!/usr/bin/sh
#thanks to youtube.com/@LeafshadeInteractive

noteFilename="$HOME/Documents/notes/src/note-$(date +%Y-%m-%d).md"
mkdir -p "$(dirname "$noteFilename")"
#no error if existing, make parent directories as needed

if [ ! -f "$noteFilename" ]; then
    echo "# Notes for $(date +%Y-%m-%d)" > "$noteFilename"
fi

nvim -c "norm Go" \
    -c "norm Go## $(date +%H:%M)" \
    -c "norm G2o" \
    -c "norm zz" \
    -c "startinsert" "$noteFilename"
