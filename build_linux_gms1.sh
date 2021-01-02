#!/bin/sh
g++ -m32 -O3 -fPIC -g -c -o Steamworks.gml/Steamworks.gml.o Steamworks.gml/steam_*.cpp
g++ -m32 Steamworks.gml/Steamworks.gml.o -shared -o Steamworks.gmx/extensions/Steamworks.gml/Steamworks.gml.so -Wl,-rpath,assets/ -LSteamworks/redistributable_bin/linux32 -lsteam_api
