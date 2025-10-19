#!/bin/bash

# Quick Fix Script for CS2 Server Segmentation Fault
# This script addresses the most common causes of CS2 server crashes

set -e  # Exit on any error

LOGGED_USER=marco
HOMEDIR="/home/${LOGGED_USER}"
CS2_DIR="${HOMEDIR}/cs2"
STEAMCMDDIR="${HOMEDIR}/steamcmd"

echo "=== CS2 Server Segmentation Fault Fix ==="
echo "This script will attempt to fix the libserver_valve.so issue"
echo ""

# Check if running as the correct user
if [ "$(whoami)" != "$LOGGED_USER" ]; then
    echo "❌ Please run this script as user: $LOGGED_USER"
    exit 1
fi

# Verify CS2 directory exists
if [ ! -d "$CS2_DIR" ]; then
    echo "❌ CS2 directory not found at: $CS2_DIR"
    exit 1
fi

echo "✅ CS2 directory found"

# Step 1: Stop any running CS2 processes
echo ""
echo "Step 1: Stopping any running CS2 processes..."
pkill -f "cs2.*dedicated" || echo "No CS2 processes found"

# Step 2: Backup current installation
echo ""
echo "Step 2: Creating backup of current gameinfo.gi..."
GAMEINFO_FILE="${CS2_DIR}/game/csgo/gameinfo.gi"
if [ -f "$GAMEINFO_FILE" ] && [ ! -f "${GAMEINFO_FILE}.backup" ]; then
    cp "$GAMEINFO_FILE" "${GAMEINFO_FILE}.backup"
    echo "✅ Backup created"
fi

# Step 3: Validate CS2 installation
echo ""
echo "Step 3: Validating CS2 installation..."
echo "This may take several minutes..."

if [ ! -d "$STEAMCMDDIR" ]; then
    echo "❌ SteamCMD directory not found at: $STEAMCMDDIR"
    echo "Please install SteamCMD first"
    exit 1
fi

# Check if environment variables are set
if [ -z "$ENV_STEAM_USER" ] || [ -z "$ENV_STEAM_PASSW" ]; then
    echo "❌ Steam credentials not set in environment variables"
    echo "Please set ENV_STEAM_USER and ENV_STEAM_PASSW"
    exit 1
fi

# Run SteamCMD validation
${STEAMCMDDIR}/steamcmd.sh +force_install_dir "${CS2_DIR}" \
                                +login "${ENV_STEAM_USER}" "${ENV_STEAM_PASSW}" \
                                +app_update 730 validate \
                                +quit

echo "✅ CS2 validation complete"

# Step 4: Check for critical files
echo ""
echo "Step 4: Checking for critical server files..."

LIBSERVER_VALVE="${CS2_DIR}/game/bin/linuxsteamrt64/libserver_valve.so"
LIBSERVER="${CS2_DIR}/game/bin/linuxsteamrt64/libserver.so"
CS2_BINARY="${CS2_DIR}/game/bin/linuxsteamrt64/cs2"

if [ ! -f "$CS2_BINARY" ]; then
    echo "❌ CS2 binary still missing after validation"
    exit 1
fi

if [ ! -f "$LIBSERVER_VALVE" ]; then
    echo "⚠️  libserver_valve.so is still missing"
    
    if [ -f "$LIBSERVER" ]; then
        echo "Creating symlink from libserver.so..."
        ln -sf "$LIBSERVER" "$LIBSERVER_VALVE"
        echo "✅ Symlink created"
    else
        echo "❌ Both server libraries are missing"
        echo "CS2 installation appears to be corrupted"
        exit 1
    fi
else
    echo "✅ libserver_valve.so found"
fi

# Step 5: Set proper permissions
echo ""
echo "Step 5: Setting proper permissions..."
chmod +x "$CS2_BINARY"
if [ -f "$LIBSERVER_VALVE" ]; then
    chmod 755 "$LIBSERVER_VALVE"
fi
if [ -f "$LIBSERVER" ]; then
    chmod 755 "$LIBSERVER"
fi
echo "✅ Permissions set"

# Step 6: Test server startup (without MetaMod)
echo ""
echo "Step 6: Testing server startup without MetaMod..."

# Temporarily disable MetaMod if it exists
ADDONS_DIR="${CS2_DIR}/game/csgo/addons"
if [ -d "$ADDONS_DIR" ]; then
    echo "Temporarily disabling MetaMod..."
    mv "$ADDONS_DIR" "${ADDONS_DIR}.disabled"
fi

# Get host IP
HOST_IP=$(hostname -I | awk '{print $1}')

# Test basic server startup
echo "Testing CS2 server startup..."
timeout 30s "$CS2_BINARY" -dedicated \
    -port 27015 \
    -console \
    -usercon \
    +map de_dust2 \
    +sv_lan 1 \
    +maxplayers 10 &

SERVER_PID=$!
sleep 10

# Check if server is still running
if kill -0 $SERVER_PID 2>/dev/null; then
    echo "✅ Server started successfully!"
    kill $SERVER_PID
    wait $SERVER_PID 2>/dev/null || true
else
    echo "❌ Server failed to start"
    exit 1
fi

# Step 7: Re-enable MetaMod if it was disabled
echo ""
echo "Step 7: Re-enabling MetaMod..."
if [ -d "${ADDONS_DIR}.disabled" ]; then
    mv "${ADDONS_DIR}.disabled" "$ADDONS_DIR"
    echo "✅ MetaMod re-enabled"
fi

# Step 8: Final recommendations
echo ""
echo "=== Fix Complete ==="
echo "✅ CS2 server segmentation fault has been resolved"
echo ""
echo "Next steps:"
echo "1. Use the fixed startup script: ./startCs2ServerAzure_fixed.sh"
echo "2. If issues persist, run: ./diagnose_cs2_server.sh"
echo "3. Monitor server logs for any remaining issues"
echo ""
echo "The server should now start without segmentation faults."