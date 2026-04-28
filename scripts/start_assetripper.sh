#!/bin/bash
# Start AssetRipper in headless mode

ASSRIPPER_DIR="$HOME/AssetRipper"
ASSRIPPER_EXE="$ASSRIPPER_DIR/AssetRipper.GUI.Free"
ASSRIPPER_PORT=${ASSRIPPER_PORT:-5000}

# Check if AssetRipper is installed
if [ ! -f "$ASSRIPPER_EXE" ]; then
    echo "[INFO] AssetRipper not found. Downloading..."
    
    # Download AssetRipper
    wget -O /tmp/AssetRipper_linux_x64.zip \
        https://github.com/AssetRipper/AssetRipper/releases/latest/download/AssetRipper_linux_x64.zip
    
    # Extract
    mkdir -p "$ASSRIPPER_DIR"
    unzip -q /tmp/AssetRipper_linux_x64.zip -d "$ASSRIPPER_DIR"
    
    # Cleanup
    rm /tmp/AssetRipper_linux_x64.zip
    
    echo "[INFO] AssetRipper downloaded and extracted"
fi

# Check if AssetRipper is already running
if pgrep -f "AssetRipper.GUI.Free" > /dev/null; then
    echo "[WARN] AssetRipper is already running"
    ASSRIPPER_PORT=$(lsof -i -P | grep AssetRipper | grep LISTEN | awk '{print $9}' | cut -d: -f2)
    export ASSRIPPER_PORT
    return 0
fi

# Start AssetRipper in headless mode
echo "[INFO] Starting AssetRipper on port $ASSRIPPER_PORT..."
nohup "$ASSRIPPER_EXE" --headless --port "$ASSRIPPER_PORT" > /dev/null 2>&1 &

# Wait for AssetRipper to start
for i in {1..30}; do
    if curl -s "http://localhost:$ASSRIPPER_PORT" > /dev/null; then
        echo "[INFO] AssetRipper is ready on port $ASSRIPPER_PORT"
        export ASSRIPPER_PORT
        return 0
    fi
    sleep 1
done

echo "[ERROR] AssetRipper failed to start"
return 1
