#!/bin/sh

ls *.scad | xargs -I {} sh -c 'echo "Exporting export/{}.stl"; /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o export/{}.stl {};'
