# Abandoned Object Detection
Detects abandoned objects in a video, particularly useful for identifying suspicious abandoned luggage in railway stations and bus stands.
This is a project developed in MATLAB, which is used to detect abandoned objects automatically from a video, particularly useful for identifying suspicious abandoned luggage at busy places like railway stations and bus stands. This task is done the followinf steps:-

1. First frame of the video is assumed as the background image. 
2. The video is converted to frames of images and then each frame is subtracted from the background image
3. If an object remains static at one place for a fixed number of frames, then it is declared as an abandoned object
4. An alarm is raised for an abandoned object .

### Data Set Used for Testing:
  Videos at https://github.com/kevinlin311tw/ABODA
