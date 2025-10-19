# CS2 Server Segmentation Fault Solution

## Problem Description

The CS2 dedicated server crashes with a segmentation fault (exit code 139) due to a missing `libserver_valve.so` library file. This creates a dependency chain failure when MetaMod tries to load, resulting in the server being unable to initialize properly.

## Error Symptoms

```bash
failed to dlopen /home/marco/cs2/game/bin/linuxsteamrt64/libserver_valve.so 
error=libserver_valve.so: cannot open shared object file: No such file or directory

CAppSystemDict:Unable to create interface Source2ServerConfig001 from server

Segmentation fault (core dumped)
```

## Root Cause

1. **Missing Core Library**: `libserver_valve.so` is absent from the CS2 installation
2. **Incomplete Installation**: SteamCMD may not have downloaded all required files
3. **MetaMod Conflict**: MetaMod expects the original server library to exist
4. **Memory Access Violation**: CS2 tries to access functions that don't exist, causing the segfault

## Solution Files

### 1. Fixed Startup Script
**File**: `startCs2ServerAzure_fixed.sh`

**Features**:
- Validates CS2 installation with `steamcmd +app_update 730 validate +quit`
- Checks for missing `libserver_valve.so` and creates symlinks if needed
- Handles MetaMod conflicts gracefully
- Provides fallback options if segfault occurs
- Enhanced error logging and debugging

**Usage**:
```bash
chmod +x startCs2ServerAzure_fixed.sh
./startCs2ServerAzure_fixed.sh
```

### 2. Improved MetaMod Installation
**File**: `installMetaModAndPlugin_fixed.sh`

**Features**:
- Verifies CS2 installation before installing MetaMod
- Handles missing server libraries
- Better error handling and validation
- Backup creation before modifications
- Version tracking to avoid unnecessary reinstalls

**Usage**:
```bash
chmod +x installMetaModAndPlugin_fixed.sh
./installMetaModAndPlugin_fixed.sh
```

### 3. Diagnostic Tool
**File**: `diagnose_cs2_server.sh`

**Features**:
- Comprehensive system check
- Validates all critical CS2 files
- Checks MetaMod installation
- Verifies system requirements
- Provides specific recommendations

**Usage**:
```bash
chmod +x diagnose_cs2_server.sh
./diagnose_cs2_server.sh
```

### 4. Quick Fix Script
**File**: `fix_cs2_segfault.sh`

**Features**:
- Automated repair process
- Validates CS2 installation
- Creates necessary symlinks
- Tests server startup
- Step-by-step progress reporting

**Usage**:
```bash
chmod +x fix_cs2_segfault.sh
./fix_cs2_segfault.sh
```

## Quick Resolution Steps

### Option 1: Use the Quick Fix Script (Recommended)
```bash
cd /home/marco
chmod +x fix_cs2_segfault.sh
./fix_cs2_segfault.sh
```

### Option 2: Manual Fix
```bash
# 1. Validate CS2 installation
steamcmd +force_install_dir "/home/marco/cs2" \
         +login "your_username" "your_password" \
         +app_update 730 validate \
         +quit

# 2. Check if libserver_valve.so exists
ls -la /home/marco/cs2/game/bin/linuxsteamrt64/libserver_valve.so

# 3. If missing, create symlink from libserver.so
ln -sf /home/marco/cs2/game/bin/linuxsteamrt64/libserver.so \
       /home/marco/cs2/game/bin/linuxsteamrt64/libserver_valve.so

# 4. Use the fixed startup script
./startCs2ServerAzure_fixed.sh
```

### Option 3: Disable MetaMod Temporarily
```bash
# If all else fails, start without MetaMod
mv /home/marco/cs2/game/csgo/addons /home/marco/cs2/game/csgo/addons.disabled
./startCs2ServerAzure.sh
```

## Prevention

To prevent this issue in the future:

1. **Always validate CS2 installations**:
   ```bash
   steamcmd +app_update 730 validate +quit
   ```

2. **Use the fixed scripts** instead of the original ones

3. **Monitor for missing files** before starting the server

4. **Keep backups** of working configurations

## Environment Requirements

Ensure these environment variables are set:
- `ENV_STEAM_USER`: Your Steam username
- `ENV_STEAM_PASSW`: Your Steam password  
- `ENV_STEAM_CSGO_KEY`: Your CS2 server token

## System Requirements

Required packages for Ubuntu/Debian:
```bash
sudo apt-get install lib32gcc-s1 lib32stdc++6 libc6-i386
```

## Troubleshooting

### If the server still crashes:

1. **Run the diagnostic tool**:
   ```bash
   ./diagnose_cs2_server.sh
   ```

2. **Check system logs**:
   ```bash
   dmesg | grep cs2
   journalctl -u your-cs2-service
   ```

3. **Verify file permissions**:
   ```bash
   chmod +x /home/marco/cs2/game/bin/linuxsteamrt64/cs2
   chmod 755 /home/marco/cs2/game/bin/linuxsteamrt64/*.so
   ```

4. **Check for core dumps**:
   ```bash
   find /home/marco/cs2 -name "core*" -o -name "*.core"
   ```

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| `libserver_valve.so: No such file` | Run `steamcmd +app_update 730 validate +quit` |
| `Permission denied` | Run `chmod +x` on CS2 binary and scripts |
| `Interface creation failed` | Use the fixed startup script with symlink creation |
| `MetaMod conflicts` | Temporarily disable MetaMod or use fixed installation script |

## Support

If you continue experiencing issues:

1. Run the diagnostic script and share the output
2. Check the CS2 server logs for additional error messages
3. Verify your Steam account has proper permissions for dedicated servers
4. Ensure your server token (`ENV_STEAM_CSGO_KEY`) is valid

## Files Summary

- `startCs2ServerAzure_fixed.sh` - Enhanced startup script with error handling
- `installMetaModAndPlugin_fixed.sh` - Improved MetaMod installation
- `diagnose_cs2_server.sh` - Comprehensive diagnostic tool
- `fix_cs2_segfault.sh` - Automated quick fix script
- `CS2_SEGFAULT_SOLUTION.md` - This documentation

All scripts include proper error handling, logging, and fallback mechanisms to prevent segmentation faults.