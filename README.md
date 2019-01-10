![Muse 3-D display](https://github.com/arnodelorme/muse_brain_display/blob/master/muse_brain_image.png)

# Muse 3-D Brain Art Display

This Matlab program allows to display Muse measures exported using the musemonitor smartphone app to be vizualized on a 3-D brain.

# Accuracy of the representation

This is primarily an art project, as true back projection of electrode activity on the cortex would require (1) complex inverse source localization math to account for volume condution in different mediums (skin, skull, CSF, cortex) (2) more than 4 channels (in general 64 channels are needed). Here the color of the cortex simply depends on the distance of a given vertices of the brain mesh with each of the 4 Muse electrodes, which is not realistic. At best, it is poor approximation of volume conductions effects.

Note about the four Muse channels: Muse records from four scalp electrodes and outputs four EEG channels, each of which must represent the difference between some electrode voltage(s) and some other electrode voltage(s). In the Muse case, the average of the two mastoid electrode signals (posterior electrodes behind the ears) is used as the common reference, meaning it is subtracted from each of the single electrode signals to form the four output channels. So the activity of a given channel does not really represent summed electrical activity arriving at the location of the single electrode, but instead, the potential difference between the voltage at that electrode and at the reference channel pair. This also means that the signals from the two mastoid electrode channels are identical except for sign. To improve the representation of this this visualization somewhat, one might transform the data to average reference and then compute spectral power. However, here I have used the spectral power values provided by the Muse headset.

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

# Future directions

One project would be to change the reference of the raw data (compute average reference) then recompute spectral power for each channel prior to vizualising power.

A second project would be to use the code for eLoreta to perform more accurate projection of activity on the brain volume, then extrapolate to the cortex surface.

Another project would be to connect Muse to Matlab either using LSL (Labstreaminglayer) or the OSC (Open Sound Control) protocol. The Muse SDK (Software Development Kit) supports both protocols. Then it would be possible to see changes in the 3-D brain in real time. 

These are not a hard projects (although the second one can be technical). Please fork this repository and make push request if you implement these changes.

# Acknowledgements

Thank you to Scott Makeig for edits and discussions. Thank you to Julia Mossbridge for design ideas.
