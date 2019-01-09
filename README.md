![Muse 3-D display](https://github.com/arnodelorme/muse_brain_display/blob/master/muse_brain_image.png)

# Muse 3-D Brain Art Display

This Matlab program allows to display Muse measures exported using the musemonitor smartphone app to be vizualized on a 3-D brain.

This is primarily an art project, as true back projection of electrode activity on the cortex would require (1) complex inverse source localization math to account for volume condution in different mediums (skin, skull, CSF, cortex) (2) more than 4 channels (in general 64 channels are needed). Here the color of the cortex simply depends on the distance of a given vertices of the brain mesh with each of the 4 Muse electrodes, which is not realistic. At best, it is poor approximation of volume conductions effects.

# How to install and use

- You must have a copy of Matlab on your computer (Windows or Mac - not tested on Linux but should work as well). Matlab 2018a was tested on Mac and Matlab 2017b was tested on Windows 7.

- Download or clone this repository

- Start Matlab

- Go to the folder containing this program

- Type in "muse_brain" on the Matlab command line

- Select the example data file "musemonitor_example_data_file.csv" included in this repository

# Tutorial documentation

A Youtube video explains how to use the program

https://www.youtube.com/watch?v=oZDS52bRmXk

# Known limitations

- There is a zoom problem on some versions of Matlab. If this is the case, you can adjust the zoom by changing the parameter "camZoomVal" in the muse_brain.m program

- The MuseMonitor app which collects the data only works (as of Jan 2019) on Muse headsets version 1, not on the newer Muse 2. So only Muse 1 data files may be vizualized using this program. 

# Cool project

A cool project would be to connect Muse to Matlab either using LSL (Labstreaminglayer) or the OSC (Open Sound Control) protocol. The Muse SDK (Software Development Kit) supports both protocols. Then it would be possible to see changes in the 3-D brain in real time. It is not a hard project, but who has time these days. If you fork this repository to do that, let me know and I will reference it here.
