#!/bin/bash

# CS2 Server Diagnostic Script
# This script helps diagnose common CS2 server issues

LOGGED_USER=marco
HOMEDIR="/home/${LOGGED_USER}"
CS2_DIR="${HOMEDIR}/cs2"

echo "=== CS2 Server Diagnostic Tool ==="
echo "Date: $(date)"
echo "User: $LOGGED_USER"
echo "CS2 Directory: $CS2_DIR"
echo ""

# Check if CS2 directory exists
if [ ! -d "$CS2_DIR" ]; then
    echo "❌ ERROR: CS2 directory not found at $CS2_DIR"
    exit 1
fi

echo "✅ CS2 directory found"

# Check critical files
echo ""
echo "=== Checking Critical Files ==="

FILES_TO_CHECK=(
    "$CS2_DIR/game/bin/linuxsteamrt64/cs2"
    "$CS2_DIR/game/bin/linuxsteamrt64/libserver_valve.so"
    "$CS2_DIR/game/bin/linuxsteamrt64/libserver.so"
    "$CS2_DIR/game/csgo/gameinfo.gi"
)

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ Found: $(basename "$file")"
        if [[ "$file" == *".so" ]]; then
            echo "   Size: $(ls -lh "$file" | awk '{print $5}')"
            echo "   Permissions: $(ls -l "$file" | awk '{print $1}')"
        fi
    else
        echo "❌ Missing: $(basename "$file")"
    fi
done

# Check library dependencies
echo ""
echo "=== Checking Library Dependencies ==="

CS2_BINARY="$CS2_DIR/game/bin/linuxsteamrt64/cs2"
if [ -f "$CS2_BINARY" ]; then
    echo "Checking CS2 binary dependencies..."
    ldd "$CS2_BINARY" | grep -E "(not found|libserver)" || echo "No missing dependencies found"
else
    echo "❌ CS2 binary not found, cannot check dependencies"
fi

# Check MetaMod installation
echo ""
echo "=== Checking MetaMod Installation ==="

ADDONS_DIR="$CS2_DIR/game/csgo/addons"
GAMEINFO_FILE="$CS2_DIR/game/csgo/gameinfo.gi"

if [ -d "$ADDONS_DIR" ]; then
    echo "✅ Addons directory found"
    echo "Contents:"
    ls -la "$ADDONS_DIR"
    
    # Check MetaMod specifically
    if [ -d "$ADDONS_DIR/metamod" ]; then
        echo "✅ MetaMod directory found"
        if [ -f "$ADDONS_DIR/metamod/bin/linuxsteamrt64/server.so" ]; then
            echo "✅ MetaMod server.so found"
        else
            echo "❌ MetaMod server.so missing"
        fi
    else
        echo "❌ MetaMod directory not found"
    fi
    
    # Check CounterStrikeSharp
    if [ -d "$ADDONS_DIR/counterstrikesharp" ]; then
        echo "✅ CounterStrikeSharp directory found"
    else
        echo "❌ CounterStrikeSharp directory not found"
    fi
else
    echo "❌ Addons directory not found"
fi

# Check gameinfo.gi for MetaMod entry
if [ -f "$GAMEINFO_FILE" ]; then
    echo ""
    echo "Checking gameinfo.gi for MetaMod entry..."
    if grep -q "csgo/addons/metamod" "$GAMEINFO_FILE"; then
        echo "✅ MetaMod entry found in gameinfo.gi"
    else
        echo "❌ MetaMod entry not found in gameinfo.gi"
    fi
else
    echo "❌ gameinfo.gi not found"
fi

# Check system requirements
echo ""
echo "=== System Information ==="
echo "OS: $(uname -a)"
echo "Architecture: $(uname -m)"
echo "Available memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Available disk space: $(df -h "$CS2_DIR" | tail -1 | awk '{print $4}')"

# Check if required packages are installed
echo ""
echo "=== Checking Required Packages ==="

REQUIRED_PACKAGES=("lib32gcc-s1" "lib32stdc++6" "libc6-i386")

for package in "${REQUIRED_PACKAGES[@]}"; do
    if dpkg -l | grep -q "$package"; then
        echo "✅ $package is installed"
    else
        echo "❌ $package is NOT installed"
    fi
done

# Check for core dumps
echo ""
echo "=== Checking for Core Dumps ==="

CORE_DUMPS=$(find "$CS2_DIR" -name "core*" -o -name "*.core" 2>/dev/null)
if [ -n "$CORE_DUMPS" ]; then
    echo "⚠️  Core dumps found:"
    echo "$CORE_DUMPS"
else
    echo "✅ No core dumps found"
fi

# Check Steam login
echo ""
echo "=== Environment Variables ==="
if [ -n "$ENV_STEAM_USER" ]; then
    echo "✅ ENV_STEAM_USER is set"
else
    echo "❌ ENV_STEAM_USER is not set"
fi

if [ -n "$ENV_STEAM_PASSW" ]; then
    echo "✅ ENV_STEAM_PASSW is set"
else
    echo "❌ ENV_STEAM_PASSW is not set"
fi

if [ -n "$ENV_STEAM_CSGO_KEY" ]; then
    echo "✅ ENV_STEAM_CSGO_KEY is set"
else
    echo "❌ ENV_STEAM_CSGO_KEY is not set"
fi

# Provide recommendations
echo ""
echo "=== Recommendations ==="

if [ ! -f "$CS2_DIR/game/bin/linuxsteamrt64/libserver_valve.so" ]; then
    echo "🔧 CRITICAL: libserver_valve.so is missing"
    echo "   Solution: Run 'steamcmd +app_update 730 validate +quit' to repair CS2 installation"
fi

if [ ! -f "$CS2_DIR/game/bin/linuxsteamrt64/libserver.so" ]; then
    echo "🔧 CRITICAL: libserver.so is missing"
    echo "   Solution: Reinstall CS2 server completely"
fi

if [ -d "$ADDONS_DIR" ] && [ ! -f "$CS2_DIR/game/bin/linuxsteamrt64/libserver_valve.so" ]; then
    echo "🔧 WORKAROUND: Try starting server without MetaMod first"
    echo "   Command: mv '$ADDONS_DIR' '${ADDONS_DIR}.disabled'"
fi

echo ""
echo "=== Diagnostic Complete ==="
echo "If issues persist, try using the fixed startup script: startCs2ServerAzure_fixed.sh"