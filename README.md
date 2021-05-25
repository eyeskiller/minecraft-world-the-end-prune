# Prune Minecraft (world_the_end)

## Description

It's only question of time, while all your elytras will be found in END and you will need expand your end world, or simply reset chunks. This script removes all chunks which are behind 1000x1000 chunks, so you will never need to expand your End for elytras. 

This script keeps 1000x1000 area around center island (because of XP farms and other custom builds)

![Prune area](https://github.com/eyeskiller/minecraft-world-the-end-prune/blob/main/img/endprune.png)

*Thanks for coordinates and image: https://xisumavoid.com/pruneendchunks*

## Installation

```
git clone https://github.com/eyeskiller/minecraft-world-the-end-prune.git
```

## Configuration

You need to change paths to files in `prune.sh` file

- First you need to set location of your World The End DIM1 region directory

```
Line 4:
cd /path/to/world_the_end/DIM1/region/
```

- Second you need to set location of filelist.txt file

```
Line 14:
    if ! grep -qxFe "$i" /path/to/filelist.txt; then
```

## Running script

```
chmod +x prune.sh
./prune.sh
```
Then you simply restart your server. 


## CRON implementation

You can easily implement this script with CRONS and run them periodicaly 

__YOU NED TO PROVIDE FULL PATHS, NOT RELATIVE__

Example: This script will run every monday at 5 AM

```
0 5 * * 1 /path/to/prune.sh
```



