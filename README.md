# CSGO Server used with my friends

## :warning: **This project is still in development.** :warning:

![Logo](./Misc/Pictures/ixigo-logo.png)

This repository contains the scripts used to setup and run a dedicated CSGO server for our gaming evenings.

## Requirements

- OS: [Ubuntu Server 18.04](https://releases.ubuntu.com/18.04/ubuntu-18.04.5-live-server-amd64.iso)
- CPU: Intel Core Duo E6600 (2-2.8GHz+) or AMD Phenom X3 8750+
- RAM: 2GB+
- HDD: 40GB+
- [Steam Game Server Login Token (GSLT)](https://steamcommunity.com/dev/managegameservers)
- [Steam Web API Key](https://steamcommunity.com/dev/apikey)
- [IxiGo Utils](https://github.com/marcosolina/csgo_util)

## Donwload & Install

```bash
bash <(curl -L https://raw.githubusercontent.com/marcosolina/ixi_go/main/Scripts/setup.sh)
```

## Misc

- Remove Windows characters from the scripts

  ```bash
  # Remove possible Windows characters
  sed -i -e 's/\r$//' <script_name>
  ```

- Run the server in the background

  ```bash
  # To start the server in the background
  screen -A -m -d -S ixigo -L /home/ixigo/ixi_go/Scripts/startAll.sh

  # To re-attach the process
  screen -r ixigo

  # To detach again after re-attaching
  ctrl+a and then press "d"
  ```

- Workshop maps

  ```
  host_workshop_map 3071005299    Assembly
  host_workshop_map 3070290240    Brewery
  host_workshop_map 3070766070    Mutiny
  host_workshop_map 3071899764    Vandal
  host_workshop_map 3075706807    Biome CS2
  host_workshop_map 3079872050    Assault
  host_workshop_map 3085200029    Bunker
  host_workshop_map 3084661017    Mission
  host_workshop_map 3077752384    Rush
  host_workshop_map 3100864853    codewise
  host_workshop_map 3095875614    minecraft

  they are saved in the folder game/bin/linuxsteamrt64/steamapps/workshop/content/730

  ```

- Key binding:
  - [Ping](https://steamcommunity.com/app/730/discussions/0/3112518479597019657/)
  - [autoexec](https://prosettings.net/blog/how-to-use-a-csgo-config-create-an-autoexec/)
