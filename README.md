# CSGO Server used with my friends / colleagues

![Logo](./Misc/Pictures/ixigo-logo.png)

This repository contains the scripts used to setup and run a dedicated CSGO server for our gaming evenings.

## Requirements

- OS: [Ubuntu Server 18.04](https://releases.ubuntu.com/18.04/ubuntu-18.04.5-live-server-amd64.iso)
- CPU: Intel Core Duo E6600 (2-2.8GHz+) or AMD Phenom X3 8750+
- RAM: 2GB+
- HDD: 40GB+
- [Steam Game Server Login Token (GSLT)](https://developer.valvesoftware.com/wiki/Counter-Strike:_Global_Offensive_Dedicated_Servers)
- [Steam Web API Key](https://developer.valvesoftware.com/wiki/CSGO_Workshop_For_Server_Operators)
- [IxiGo Utils](https://github.com/marcosolina/csgo_util)

## Donwload & Install

~~~~bash
bash <(curl -L https://raw.githubusercontent.com/marcosolina/ixi_go/main/Scripts/setup.sh)
~~~~

## Misc

- Remove Windows characters from the scripts

  ~~~~bash
  # Remove possible Windows characters
  sed -i -e 's/\r$//' <script_name>
  ~~~~
  
- Run the server in the background
  ~~~~bash
  # To start the serve in the background
  screen -A -m -d -S <CHOOSE_A_NAME> -L /path/to/the/startAll.sh
  
  # To re-attach the process
  screen -r <CHOOSE_A_NAME>
  
  # To detach again after re-attaching
  ctrl+a and then press "d"
  ~~~~

- [\[CS:GO\] Fix Competitive Warmup](https://forums.alliedmods.net/showthread.php?t=329053)
